import Toybox.Lang;
import Toybox.System;
import Toybox.Test;

(:test)
function hmacSHA1_test_empty(logger) {
  var mac = hmacSHA1([], []);
  Test.assertEqual(mac.size(), 20);
  for (var i = 0; i < mac.size(); i++) {
    assertNumber(mac[i]);
  }
  var expected = base16ToBytes("fbdb1d1b18aa6c08324b7d64b71fb76370690e1d");
  return bytesEqual(expected, mac);
}

(:test)
function hmacSHA1_test1(logger) {
  var mac = hmacSHA1("key".toUtf8Array(),
                     "The quick brown fox jumps over the lazy dog".toUtf8Array());
  Test.assertEqual(mac.size(), 20);
  for (var i = 0; i < mac.size(); i++) {
    assertNumber(mac[i]);
  }
  var expected = base16ToBytes("de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9");
  return bytesEqual(expected, mac);
}
