// Implementation of HMAC: Keyed-Hashing for Message Authentication for SHA1
// rfc2104 https://tools.ietf.org/html/rfc2104

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
