class Provider {
  var name_;
  var key_;
  var code_ = "______";

  function initialize(name, key) {
    name_ = name;
    key_ = key;
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
}
