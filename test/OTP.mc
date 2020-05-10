using Toybox.Lang;
using Toybox.System;
using Toybox.Test;

(:test)
function truncate_test(logger) {
  var bytes = base16ToBytes("cc93cf18508d94934c64b65d8ba7667fb7cde4b0");
  var result = truncate(bytes);
  assertNumber(result);
  return result == 0x4c93cf18;
}

(:test)
function hotp_test(logger) {
  var key = "12345678901234567890".toUtf8Array();
  assertEqual("hotp code", 1284755224, hotp(key, 0));
  return true;
}
