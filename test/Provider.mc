using Toybox.Lang;
using Toybox.System;
using Toybox.Test;

(:test)
function provider_dict_test(logger) {
  var cp = new CounterBasedProvider("nc", "abcdefgh", 42);
  var cd = {
    "name" => "nc",
    "key" => "abcdefgh",
    "counter" => 42,
    "type" => "CounterBasedProvider",
  };
  assertDictEqual("counter dict", cd, providerToDict(cp));
  assertEqual("counter provider", cp, providerFromDict(cd));
  var tp = new TimeBasedProvider("nt", "ijklmnop", 30);
  var td = {
    "name" => "nt",
    "key" => "ijklmnop",
    "interval" => 30,
    "next" => 0,
    "type" => "TimeBasedProvider",
  };
  assertDictEqual("time dict", td, providerToDict(tp));
  assertEqual("time provider", tp, providerFromDict(td));
  var sp = new SteamGuardProvider("ns", "aaaaaaaa", 30);
  var sd = {
    "name" => "ns",
    "key" => "aaaaaaaa",
    "interval" => 30,
    "next" => 0,
    "type" => "SteamGuardProvider",
  };
  assertDictEqual("steam dict", sd, providerToDict(sp));
  assertEqual("steam provider", sp, providerFromDict(sd));
  return true;
}

(:test)
function provider_dict_padding_test(logger) {
  // == are padding base32 padding characters
  var td = {
    "name" => "nt",
    "key" => "aaaa====",
    "interval" => 30,
    "next" => 0,
    "type" => "TimeBasedProvider",
  };
  var tp = providerFromDict(td);
  tp.update();
  assertString(tp.code_);
  return tp.code_ != EMPTY_CODE;
}

(:test)
function provider_dict_strip_padding_test(logger) {
  var td = {
    "name" => "nt",
    "key" => " aa bb ",
    "interval" => 30,
    "next" => 0,
    "type" => "TimeBasedProvider",
  };
  var tp = providerFromDict(td);
  tp.update();
  assertString(tp.code_);
  return tp.code_ != EMPTY_CODE;
}

(:test)
function provider_str_test(logger) {
  var cp = new CounterBasedProvider("nc", "abcdefgh", 42);
  var cs = "CounterBasedProvider:counter=42,name=nc,key=abcdefgh";
  assertEqual("counter string", cs, serializeProvider(cp));
  assertEqual("counter provider", cp, parseProvider(cs));

  var tp = new TimeBasedProvider("nt", "ijklmnop", 30);
  var ts = "TimeBasedProvider:interval=30,name=nt,key=ijklmnop";
  assertEqual("time string", ts, serializeProvider(tp));
  assertEqual("time provider", tp, parseProvider(ts));

  var sp = new SteamGuardProvider("ns", "aaaaaaaa", 30);
  var ss = "SteamGuardProvider:interval=30,name=ns,key=aaaaaaaa";
  assertEqual("steam string", ss, serializeProvider(sp));
  assertEqual("steam provider", sp, parseProvider(ss));

  var ps = [cp, tp, sp];
  var full = cs + ";" + ts + ";" + ss + ";";
  assertEqual("full string", full, serializeProviders(ps));
  assertArrayEqual("provider list", ps, parseProviders(full));

  // Key with padding
  cp = new CounterBasedProvider("nc", "aaaa====", 42);
  cs = "CounterBasedProvider:counter=42,name=nc,key=aaaa====";
  assertEqual("counter string", cs, serializeProvider(cp));
  assertEqual("counter provider", cp, parseProvider(cs));
  return true;
}
