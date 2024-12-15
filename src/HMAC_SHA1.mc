import Toybox.Lang;
import Toybox.Cryptography;
import Toybox.System;

// Create a message authentication code (MAC) using Keyed-Hashing for Message
// Authentication (HMAC) with SHA1 (https://tools.ietf.org/html/rfc2104)
(:glance)
function hmacSHA1(key as Bytes, message as Bytes) as Bytes {
  var BS = 64;
  if (key.size() > BS) {
    key = hashSHA1(key);
  }
  // MAC = H(K XOR opad, H(K XOR ipad, message))
  var key_ipad = new [BS];
  var key_opad = new [BS];
  for (var i = 0; i < BS; i++) {
    var k = i < key.size() ? key[i] : 0x00;
    key_ipad[i] = k ^ 0x36;
    key_opad[i] = k ^ 0x5C;
  }
  return hashSHA1(key_opad.addAll(hashSHA1(key_ipad.addAll(message))));
}

// Native SHA1 cryptography available as of connect iq 3.0.0
(:glance)
function hashSHA1(data as Bytes) as Bytes {
  log(DEBUG, "SHA1 using native cryptography");
  // Use native implementation of SHA1, this requires conversion to/from the
  // new ByteArray type (since connect iq 3.0.0)
  var sha1 = new Cryptography.Hash({:algorithm => Cryptography.HASH_SHA1});
  sha1.update(fromArray(data));
  var res = toArray(sha1.digest());
  log(DEBUG, "SHA1 done");
  return res;
}

(:glance)
function fromArray(arr as Bytes) as ByteArray {
  var bytes = []b;
  bytes.addAll(arr);
  return bytes;
}

(:glance)
function toArray(bytes as ByteArray) as Bytes {
  var arr = new [bytes.size()];
  for (var i=0; i < arr.size(); i++) {
    arr[i] = bytes[i];
  }
  return arr;
}
