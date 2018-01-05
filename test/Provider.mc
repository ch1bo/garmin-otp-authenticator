using Toybox.Lang;
using Toybox.System;
using Toybox.Test;

(:test)
function provider_test(logger) {
  var cp = new CounterBasedProvider("nc", "abcdefgh", 42);
  var cd = {
    "name" => "nc",
    "key" => "abcdefgh",
    "code" => "______",
    "counter" => 42
  };
  assertDictEqual("counter dict", cd, providerToDict(cp));
  assertEqual("counter provider", cp, providerFromDict(cd));
  var tp = new TimeBasedProvider("nt", "ijklmnop", 30);
  var td = {
    "name" => "nt",
    "key" => "ijklmnop",
    "code" => "______",
    "interval" => 30,
    "next" => 0
  };
  assertDictEqual("time dict", td, providerToDict(tp));
  assertEqual("time provider", tp, providerFromDict(td));
  return true;
}
