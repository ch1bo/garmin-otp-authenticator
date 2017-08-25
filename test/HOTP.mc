using Toybox.Lang;
using Toybox.System;

(:test)
function truncate_test(logger) {
  var bytes = hex2bytes("cc93cf18508d94934c64b65d8ba7667fb7cde4b0");
  var result = truncate(bytes);
  assertNumber(result);
  return result == 0x4c93cf18;
}

(:test)
function hotp_test(logger) {
  var key = "12345678901234567890".toUtf8Array();
  return hotp(key, 0, 6) == 755224;
}
