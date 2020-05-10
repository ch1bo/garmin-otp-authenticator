using Toybox.Cryptography;
using Toybox.System;

// Create a message authentication code (MAC) using Keyed-Hashing for Message
// Authentication (HMAC) with SHA1 (https://tools.ietf.org/html/rfc2104)
//
// key (Array<Number>) - key bytes (8-bit Numbers)
// text (String) - massage to authenticate
// return (Array<Number>) - MAC bytes (8-bit Numbers)
function hmacSHA1(key, text) {
  var BS = 64;
  if (key.size() > BS) {
    key = hashSHA1(key);
  }
  // MAC = H(K XOR opad, H(K XOR ipad, text))
  var key_ipad = new [BS];
  var key_opad = new [BS];
  for (var i = 0; i < BS; i++) {
    var k = i < key.size() ? key[i] : 0x00;
    key_ipad[i] = k ^ 0x36;
    key_opad[i] = k ^ 0x5C;
  }
  return hashSHA1(key_opad.addAll(hashSHA1(key_ipad.addAll(text))));
}

// Local function to switch between native and polyfilled SHA1 implementation
function hashSHA1(data) {
  if (Toybox has :Cryptography) {
    log(DEBUG, "SHA1 using native cryptography");
    // Use native implementation of SHA1, this requires conversion to/from the
    // new ByteArray type (since connect iq 3.0.0)
    var sha1 = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA1});
    sha1.update(fromArray(data));
    var res = toArray(sha1.digest());
    log(DEBUG, "SHA1 done");
    return res;
  } else {
    log(DEBUG, "SHA1 using polyfilled cryptography");
    var sha1 = new SHA1();
    sha1.input(data);
    var res = sha1.result();
    log(DEBUG, "SHA1 done");
    return res;
  }
}

(:connectiq3)
function fromArray(arr) {
  var bytes = []b;
  bytes.addAll(arr);
  return bytes;
}

(:connectiq3)
function toArray(bytes) {
  var arr = new [bytes.size()];
  for (var i=0; i < arr.size(); i++) {
    arr[i] = bytes[i];
  }
  return arr;
}
