class Provider {
  var name_;
  var key_;
  var code_ = "______";
  var counter_ = 0l;

  function initialize(name, key) {
    name_ = name;
    key_ = key.toUtf8Array();
  }

  function updateCode() {
    code_ = hotp(key_, counter_, 6).toString();
    while (code_.length() < 6) {
      code_ = "0" + code_;
    }
    counter_++;
  }
}
