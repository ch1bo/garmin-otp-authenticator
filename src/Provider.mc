class Provider {
  var name_;
  var key_;
  var counter_;
  var code_ = "______";

  function initialize(name, key, counter) {
    name_ = name;
    key_ = key;
    counter_ = counter;
  }

  function updateCode() {
    code_ = hotp(key_.toUtf8Array(), counter_, 6);
    counter_++;
  }
}
