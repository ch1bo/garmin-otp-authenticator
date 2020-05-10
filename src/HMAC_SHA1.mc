// Implementation of HMAC: Keyed-Hashing for Message Authentication for SHA1
// rfc2104 https://tools.ietf.org/html/rfc2104
using Toybox.Cryptography;
using Toybox.System;

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

function hashSHA1(data) {
  if (Toybox has :Cryptography) {
    log(DEBUG, "using native cryptography");
    // Use native implementation (since connect iq 3.0.0)
    var sha1 = new Cryptography.Hash({ :algorithm => Cryptography.HASH_SHA1});
    // System.println(data);
    sha1.update(data);
    var res = sha1.digest();
    System.println(res);
    return res;
  } else {
    log(DEBUG, "using polyfilled cryptography");
    var sha1 = new SHA1();
    sha1.input(data);
    return sha1.result();
  }
}
