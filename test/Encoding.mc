using Toybox.Lang;
using Toybox.System;
using Toybox.Test;

(:test)
function base16_test1(logger) {
  var bytes = [0xDE, 0xAD, 0xBE, 0xEF];
  var res = base16ToBytes("deadbeef");
  assertArrayEqual("byte array", bytes, res);
  var res2 = bytesToBase16(res);
  assertEqual("encoded string", "DEADBEEF", res2);
  return true;
}

(:test)
function base16_test2(logger) {
  var bytes = [0x0A, 0xBC];
  var res = base16ToBytes("abc");
  assertArrayEqual("byte array", bytes, res);
  var res2 = bytesToBase16(res);
  assertEqual("encoded string", "0ABC", res2);
  return true;
}

(:test)
function base16_zero_msb(logger) {
  assertArrayEqual("byte array", [0x0, 0x0f], base16ToBytes("000f"));
  assertEqual("encoded string", "000F", bytesToBase16([0x0, 0x0f]));
  return true;
}

(:test)
function base32_test(logger) {
  assertArrayEqual("base32 bytes", "fooba".toUtf8Array(),
                   base32ToBytes("MZXW6YTB"));
  assertEqual("encoded string", "MZXW6YTB",
              bytesToBase32("fooba".toUtf8Array()));
  return true;
}

(:test)
  function base32_test2(logger) {
  // assertArrayEqual("base32 bytes", "fooba".toUtf8Array(),
  //                  base32ToBytes("MZXW6YTB"));
  assertEqual("encoded string", "MZXW6YTBMZXW6YTB",
              bytesToBase32("foobafooba".toUtf8Array()));
  return true;
}
