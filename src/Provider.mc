class Provider {
  var name_;
  var key_;
  var code_ = "______";

  function initialize(name, key) {
    name_ = name;
    key_ = key;
  }

  function equals(other) {
    return other instanceof Provider &&
      other.name_.equals(name_) &&
      other.key_.equals(key_);
  }
}

class CounterBasedProvider extends Provider {
  var counter_;

  function initialize(name, key, counter) {
    Provider.initialize(name, key);
    counter_ = counter;
  }

  function update() {
    code_ = hotp(base32ToBytes(key_), counter_, 6);
    counter_++;
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
      return false;
    }
    next_ = now + 10; // on errors retry in 10
    var k;
    try {
      k = base32ToBytes(key_);
    } catch (exception instanceof InvalidValueException) {
      throw new InvalidValueException("key not base32");
    }
    code_ = totp(k, interval_, 6);
    next_ = (now / interval_ + 1) * interval_;
    return true;
  }

  function equals(other) {
    return Provider.equals(other) &&
      other instanceof TimeBasedProvider &&
      other.interval_ == interval_;
  }
}

function providerToDict(p) {
  var d = {
    "name" => p.name_,
    "key" => p.key_,
    "code" => p.code_
  };
  switch (p) {
  case instanceof CounterBasedProvider:
    d.put("counter", p.counter_);
    break;
  case instanceof TimeBasedProvider:
    d.put("interval", p.interval_);
    d.put("next", p.next_);
    break;
  }
  return d;
}

function providerFromDict(d) {
  var p = null;
  if (d.hasKey("counter")) {
    p = new CounterBasedProvider(d.get("name"), d.get("key"),
                                 d.get("counter"));
  } else if (d.hasKey("interval")) {
    p = new TimeBasedProvider(d.get("name"), d.get("key"),
                              d.get("interval"));
    p.next_ = d.get("next");
  } else {
    throw new InvalidValueException("not a provider dict");
  }
  p.code_ = d.get("code");
  return p;
}
