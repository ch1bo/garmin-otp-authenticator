import Toybox.Lang;
import Toybox.StringUtil;
import Toybox.Application;

const EMPTY_CODE = "------";

(:glance)
class Provider {
  var name_;
  var key_;

  var keyBytes_;
  var code_ = EMPTY_CODE;

  function initialize(name, key) {
    name_ = name;
    key_ = key;
    keyBytes_ = base32ToBytes(key);
  }

  // Update code_, potentially calculating it from keyBytes_
  function update() {
    log(WARN, "update() not implemented");
    return code_;
  }

  function equals(other) {
    return other instanceof Provider &&
      other.name_.equals(name_) &&
      other.key_.equals(key_);
  }

  function getTypeString() {
    return "Generic";
  }
}

(:glance)
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
    code_ = toDigits(hotp(keyBytes_, counter_), 6);
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

  function getTypeString() {
    return "Counter based";
  }
}

(:glance)
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
    code_ = toDigits(totp(keyBytes_, interval_), 6);
    next_ = (now / interval_ + 1) * interval_;
    return code_;
  }

  function equals(other) {
    return Provider.equals(other) &&
      other instanceof TimeBasedProvider &&
      other.interval_ == interval_;
  }

  function getTypeString() {
    return "Time based";
  }
}

(:glance)
class SteamGuardProvider extends TimeBasedProvider {

  function initialize(name, key, interval) {
    TimeBasedProvider.initialize(name, key, interval);
  }

  function update() {
    var now = Time.now().value();
    if (now < next_) {
      return code_;
    }
    next_ = now + 10; // on errors retry in 10
    code_ = toSteam(totp(keyBytes_, interval_));
    next_ = (now / interval_ + 1) * interval_;
    return code_;
  }

  function equals(other) {
    return TimeBasedProvider.equals(other) &&
      other instanceof SteamGuardProvider;
  }

  function getTypeString() {
    return "Steam guard";
  }
}

const PROVIDERS = ["CounterBasedProvider", "TimeBasedProvider", "SteamGuardProvider"];

typedef ProviderDict as Dictionary<PropertyKeyType, PropertyValueType>;

function providerToDict(p as Provider) as ProviderDict {
  var d = {
    "name" => p.name_,
    "key" => p.key_,
  };
  switch (p) {
  case instanceof CounterBasedProvider:
    d.put("type", "CounterBasedProvider");
    d.put("counter", (p as CounterBasedProvider).counter_);
    break;
  case instanceof SteamGuardProvider:
    d.put("type", "SteamGuardProvider");
    d.put("interval", (p as SteamGuardProvider).interval_);
    d.put("next", (p as SteamGuardProvider).next_);
    break;
  case instanceof TimeBasedProvider:
    d.put("type", "TimeBasedProvider");
    d.put("interval", (p as TimeBasedProvider).interval_);
    d.put("next", (p as TimeBasedProvider).next_);
    break;
  }
  return d;
}

(:glance)
function providerFromDict(d as ProviderDict) as Provider {
  var p = null;
  var counter = d.get("counter");
  if (counter == null) {
    counter = 0;
  }
  var interval = d.get("interval");
  if (interval == null) {
    interval = 30;
  }
  // Strip and pad if necessary to be more liberal in what keys we accept.
  var key = strip(d.get("key"));
  switch (d.get("type")) {
  case "CounterBasedProvider":
    p = new CounterBasedProvider(d.get("name"), key, counter);
    break;
  case "SteamGuardProvider":
    p = new SteamGuardProvider(d.get("name"), key, interval);
    break;
  case "TimeBasedProvider":
    p = new TimeBasedProvider(d.get("name"), key, interval);
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

function serializeProviders(ps as Array<Provider>) {
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
  // TODO(SN): persist keyBytes_ instead? -> breaking change
  s += "key=" + p.key_;
  return s;
}

function parseProviders(s as String) as Array<Provider> {
  var ps = [];
  var parts = split(s, ";");
  for (var i = 0; i < parts.size(); i++) {
    ps.add(parseProvider(parts[i]));
  }
  return ps;
}

function parseProvider(s as String) as Provider {
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
function split(str as String, del as String) as Array<String> {
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

// Trim and filter whitespace (space, newlines, carriage returns and tabs) from
// a string.
(:glance)
function strip(str as String) {
  var out = [];
  var cs = str.toCharArray();
  for (var i = 0; i < cs.size(); i++) {
    if (cs[i] != ' ' && cs[i] != '\n' && cs[i] != '\r' && cs[i] != '\t') {
      out.add(cs[i]);
    }
  }
  return StringUtil.charArrayToString(out);
}
