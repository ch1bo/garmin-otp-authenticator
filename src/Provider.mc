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
    code_ = hotp(key_.toUtf8Array(), counter_, 6);
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
    if (now > next_) {
      code_ = totp(key_.toUtf8Array(), interval_, 6);
      next_ = now + now % interval_;
    }
  }
}
