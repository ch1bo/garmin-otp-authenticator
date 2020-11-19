using Toybox.Lang;
using Toybox.System;
using Toybox.Test;

(:test)
function base16_test1(logger) {
  assertArrayEqual("decoded bytes", [0xDE, 0xAD, 0xBE, 0xEF],
                   base16ToBytes("deadbeef"));
  assertEqual("encoded string", "DEADBEEF",
              bytesToBase16([0xDE, 0xAD, 0xBE, 0xEF]));
  return true;
}

(:test)
function base16_test2(logger) {
  assertArrayEqual("decoded bytes", [0x0A, 0xBC], base16ToBytes("abc"));
  assertEqual("encoded string", "0ABC", bytesToBase16([0x0A, 0xBC]));
  return true;
}

(:test)
function base16_zero_msb(logger) {
  assertArrayEqual("decoded bytes", [0x0, 0x0f], base16ToBytes("000f"));
  assertEqual("encoded string", "000F", bytesToBase16([0x0, 0x0f]));
  return true;
}

(:test)
function base32_test(logger) {
  assertArrayEqual("decoded bytes", "fooba".toUtf8Array(),
                   base32ToBytes("MZXW6YTB"));
  assertEqual("encoded string", "MZXW6YTB",
              bytesToBase32("fooba".toUtf8Array()));
  return true;
}

(:test)
  function base32_test2(logger) {
  assertArrayEqual("decoded bytes", "foobafooba".toUtf8Array(),
                   base32ToBytes("MZXW6YTBMZXW6YTB"));
  assertEqual("encoded string", "MZXW6YTBMZXW6YTB",
              bytesToBase32("foobafooba".toUtf8Array()));
  return true;
}

(:test)
function base32_test3(logger) {
  assertArrayEqual("decoded bytes", [0xff, 0xff, 0xff, 0xff, 0xff],
                   base32ToBytes("77777777"));
  assertEqual("encoded string", "77777777",
              bytesToBase32([0xff, 0xff, 0xff, 0xff, 0xff]));
  return true;
}

(:test)
function base32_decode_padded(logger) {
  assertArrayEqual("decoded bytes", [],
                   base32ToBytes(""));
  assertArrayEqual("decoded bytes", [0, 0, 0, 0, 0],
                   base32ToBytes("========"));
  assertArrayEqual("decoded bytes", [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                   base32ToBytes("================"));
  assertArrayEqual("decoded bytes", "f".toUtf8Array(),
                   base32ToBytes("MY======"));
  assertArrayEqual("decoded bytes", "fo".toUtf8Array(),
                   base32ToBytes("MZXQ===="));
  assertArrayEqual("decoded bytes", "foo".toUtf8Array(),
                   base32ToBytes("MZXW6==="));
  assertArrayEqual("decoded bytes", "foob".toUtf8Array(),
                   base32ToBytes("MZXW6YQ="));
  assertArrayEqual("decoded bytes", "foobafo".toUtf8Array(),
                   base32ToBytes("MZXW6YTBMZXQ===="));
  return true;
}

(:test)
function padBase32_test(logger) {
  assertEqual("padded base32", "", padBase32(""));
  assertEqual("padded base32", "========", padBase32("="));
  assertEqual("padded base32", "MY======", padBase32("MY"));
  assertEqual("padded base32", "MZXQ====", padBase32("MZXQ"));
  assertEqual("padded base32", "MZXW6===", padBase32("MZXW6"));
  assertEqual("padded base32", "MZXW6YQ=", padBase32("MZXW6YQ"));
  return true;
}
