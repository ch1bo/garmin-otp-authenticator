const EMPTY_CODE = "______";

class Provider {
  var name_;
  var key_;
  var code_ = EMPTY_CODE;

  function initialize(name, key) {
    name_ = name;
    key_ = key;
  }

  // Update code_, potentially calculating it from key_
  function update() {
    log(WARN, "update() not implemented");
    return code_;
  }

  function equals(other) {
    return other instanceof Provider &&
      other.name_.equals(name_) &&
      other.key_.equals(key_);
  }
}

class CounterBasedProvider extends Provider {
  var counter_;
  var next_ = 0;

  function initialize(name, key, counter) {
    Provider.initialize(name, key);
    counter_ = counter;
  }

  function update() {
    var now = Time.now().value();
    if (now < next_) {
      return code_;
    }
    next_ = now + 10; // on errors retry in 10
    var k;
    try {
      // TODO(SN): profile how expensive this is
      // TODO(SN): rather check on provider creation (validate function)!
      k = base32ToBytes(key_);
    } catch (e) {
      // NOTE(SN): \n to have error message in two lines
      throw new InvalidValueException("\nkey not base32\n" + e.getErrorMessage());
    }
    code_ = toDigits(hotp(k, counter_), 6);
    return code_;
  }

  // Increment counter and get "next" code
  function next() {
    counter_++;
    logf(DEBUG, "new counter: $1$", [counter_]);
    next_ = 0; // invalidate code_
  }

  function equals(other) {
    return Provider.equals(other) &&
      other instanceof CounterBasedProvider &&
      other.counter_ == counter_;
  }
}

class TimeBasedProvider extends Provider {
  var interval_;
  var next_ = 0;

  function initialize(name, key, interval) {
    Provider.initialize(name, key);
    interval_ = interval;
  }

  function update() {
    var now = Time.now().value();
    if (now < next_) {
      return code_;
    }
    next_ = now + 10; // on errors retry in 10
    var k;
    try {
      k = base32ToBytes(key_);
    } catch (e) {
      // NOTE(SN): \n to have error message in two lines
      throw new InvalidValueException("\nkey not base32\n" + e.getErrorMessage());
    }
    code_ = toDigits(totp(k, interval_), 6);
    next_ = (now / interval_ + 1) * interval_;
    return code_;
  }

  function equals(other) {
    return Provider.equals(other) &&
      other instanceof TimeBasedProvider &&
      other.interval_ == interval_;
  }
}

// TODO(SN): dry with TimeBasedProvider
class SteamGuardProvider extends TimeBasedProvider {

  function initialize(name, key, interval) {
    TimeBasedProvider.initialize(name, key, interval);
  }

  function update() {
    var now = Time.now().value();
    if (code_ != EMPTY_CODE && now < next_) {
      return code_;
    }
    next_ = now + 10; // on errors retry in 10
    var k;
    try {
      k = base32ToBytes(key_);
    } catch (e) {
      // NOTE(SN): \n to have error message in two lines
      throw new InvalidValueException("\nkey not base32\n" + e.getErrorMessage());
    }
    code_ = toSteam(totp(k, interval_));
    next_ = (now / interval_ + 1) * interval_;
    return code_;
  }

  function equals(other) {
    return TimeBasedProvider.equals(other) &&
      other instanceof SteamGuardProvider;
  }
}

const PROVIDERS = ["CounterBasedProvider", "TimeBasedProvider", "SteamGuardProvider"];

function providerToDict(p) {
  var d = {
    "name" => p.name_,
    "key" => p.key_,
  };
  switch (p) {
  case instanceof CounterBasedProvider:
    d.put("type", "CounterBasedProvider");
    d.put("counter", p.counter_);
    break;
  case instanceof SteamGuardProvider:
    d.put("type", "SteamGuardProvider");
    d.put("interval", p.interval_);
    d.put("next", p.next_);
    break;
  case instanceof TimeBasedProvider:
    d.put("type", "TimeBasedProvider");
    d.put("interval", p.interval_);
    d.put("next", p.next_);
    break;
  }
  return d;
}

function providerFromDict(d) {
  var p = null;
  var counter = d.get("counter");
  if (counter == null) {
    counter = 0;
  }
  var interval = d.get("interval");
  if (interval == null) {
    interval = 30;
  }
  switch (d.get("type")) {
  case "CounterBasedProvider":
    p = new CounterBasedProvider(d.get("name"), d.get("key"), counter);
    break;
  case "SteamGuardProvider":
    p = new SteamGuardProvider(d.get("name"), d.get("key"), interval);
    break;
  case "TimeBasedProvider":
    p = new TimeBasedProvider(d.get("name"), d.get("key"), 30);
    break;
  default:
    throw new InvalidValueException("not a provider dict");
  }
  return p;
}

// Pretty unsafe but simple serialization. Unsafe because strings are not
// escaped and '=' are dropped, thus padding needs to be re-added (leaks base32
// knowledge abstraction).
// TODO(SN): use Dictonary.toString() and make this parsable? -> breaking change

function serializeProviders(ps) {
  var s = "";
  for (var i = 0; i < ps.size(); i++) {
    s += serializeProvider(ps[i]) + ";";
  }
  return s;
}

function serializeProvider(p) {
  var s = "";
  switch (p) {
  case instanceof CounterBasedProvider:
    s += "CounterBasedProvider:";
    s += "counter=" + p.counter_.toString() + ",";
    break;
  case instanceof SteamGuardProvider:
    s += "SteamGuardProvider:";
    s += "interval=" + p.interval_.toString() + ",";
    break;
  case instanceof TimeBasedProvider:
    s += "TimeBasedProvider:";
    s += "interval=" + p.interval_.toString() + ",";
    break;
  }
  s += "name=" + p.name_ + ",";
  s += "key=" + p.key_;
  return s;
}

function parseProviders(s) {
  var ps = [];
  var parts = split(s, ";");
  for (var i = 0; i < parts.size(); i++) {
    ps.add(parseProvider(parts[i]));
  }
  return ps;
}

function parseProvider(s) {
  var i = s.find(":");
  if (i == null) {
    throw new InvalidValueException("no serialized provider: " + s);
  }
  var type = s.substring(0, i);
  var rest = s.substring(i+1, s.length());
  var tokens = split(rest, ",");
  if (type.equals("CounterBasedProvider")) {
    if (tokens.size() != 3) {
      throw new InvalidValueException("input mismatch: " + rest);
    }
    var counter = parseNumber(tokens[0], "counter");
    var name = parseString(tokens[1], "name");
    var key = padBase32(parseString(tokens[2], "key"));
    return new CounterBasedProvider(name, key, counter);
  }
  if (type.equals("SteamGuardProvider")) {
    if (tokens.size() != 3) {
      throw new InvalidValueException("input mismatch: " + rest);
    }
    var interval = parseNumber(tokens[0], "interval");
    var name = parseString(tokens[1], "name");
    var key = padBase32(parseString(tokens[2], "key"));
    return new SteamGuardProvider(name, key, interval);
  }
  if (type.equals("TimeBasedProvider")) {
    if (tokens.size() != 3) {
      throw new InvalidValueException("input mismatch: " + rest);
    }
    var interval = parseNumber(tokens[0], "interval");
    var name = parseString(tokens[1], "name");
    var key = padBase32(parseString(tokens[2], "key"));
    return new TimeBasedProvider(name, key, interval);
  }
  throw new InvalidValueException("not a provider dict");
}

// Parse a key=value string from str
function parseString(str, key) {
  var parts = split(str, "=");
  if (parts.size() < 1 || !parts[0].equals(key)) {
    throw new InvalidValueException("no parse of key '" + key + "'");
  }
  return parts.size() == 1 ? "" : parts[1];
}

// Parse a key=value number from str
function parseNumber(str, key) {
  var parts = split(str, "=");
  if (parts.size() != 2 || !parts[0].equals(key)) {
    throw new InvalidValueException("no parse of key '" + key + "'");
  }
  return parts[1].toNumber();
}

// Split a string into an array of strings at del
function split(str, del) {
  var parts = [];
  var last = 0;
  var next = findNext(str, del, 0);
  while (next != null) {
    parts.add(str.substring(last, next));
    last = next+1;
    next = findNext(str, del, last);
  }
  if (last != str.length()) {
    parts.add(str.substring(last, str.length()));
  }
  return parts;
}

// Like String.find(q) but starting from index i
function findNext(str, q, i) {
  var x = str.substring(i, str.length()).find(q);
  return x != null ? x + i : null;
}
