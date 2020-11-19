using Toybox.Lang;
using Toybox.Math;
using Toybox.StringUtil;
using Toybox.Time;

// Convert an OTP code to a digit string (arfc6238/rfc4226)
// Note: Max number of digits is 9 to stay in range of signed 32bit
//       Number where 6 digits is commonly used.
(:glance)
function toDigits(n, digits) {
  if (digits > 9) {
    digits = 9;
  }
  var code = (n % DIGITS[digits]).toString();
  while (code.length() < digits) {
    code = "0" + code;
  }
  return code;
}

const DIGITS = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000];

// Convert an OTP number to a steam guard compatible string.
(:glance)
function toSteam(n) {
  var code = [];
  var length = Alphabet.STEAM.size();
  for (var i = 0; i < 5; i++) {
    code.add(Alphabet.STEAM[n % length]);
    n /= length;
  }
  return StringUtil.charArrayToString(code);
}

// Implementation of TOTP: Time-Based One-Time Password Algorithm
// rfc6238 https://tools.ietf.org/html/rfc6238

// Notes:
//  * T0 is defaulted to Unix Epoch

(:glance)
function totp(key, period) {
  return hotp(key, Time.now().value() / period);
}

// Implementation of HOTP: An HMAC-Based One-Time Password Algorithm
// rfc4226 https://tools.ietf.org/html/rfc4226

(:glance)
function hotp(key, counter) {
  var data = new [8];
  for (var i = data.size() - 1; i >= 0; i--) {
    data[i] = counter & 0xff;
    counter = counter >> 8;
  }
  return truncate(hmacSHA1(key, data));
}

(:glance)
function truncate(bytes) {
  if (bytes.size() != 20) {
    throw new Lang.UnexpectedTypeException();
  }
  // Offset is the low-order 4 bits of the byte at 19
  var offset = bytes[19] & 0xf;
  // Return the last 31 bits of the 4-byte word at offset
  return (bytes[offset] & 0x7f) << 24
    | (bytes[offset+1] & 0xff) << 16
    | (bytes[offset+2] & 0xff) << 8
    | (bytes[offset+3] & 0xff);

}
