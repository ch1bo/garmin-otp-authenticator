// Implementation of the Secure Hashing Algorithm 1 (SHA-1)
// rfc3174 https://tools.ietf.org/html/rfc3174
// loosely ported from the reference implementation and a version by
// Uwe Hollerbach, which is based on Peter C. Gutmann's implementation
// as found in Applied Cryptography by Bruce Schneier

// Notes:
// * Maximum length is 2^63
// * 64bit signed integers (Long) are used throughout to capture 32bit values as
//   right-shifts on 32bit signed integers (Number) perform sign extension i.e.
//   0x80000000 >> 31 = 0xFFFFFFFF, which is undesirable for this implementation

using Toybox.System;

// TODO(SN): optimize: operates on 8bit values, stored as 32bit numbers
function hashSHA1(data) {
  var sha1 = new SHA1();
  sha1.input(data);
  return sha1.result();
}

const MAX_LENGTH = 0x7FFFFFFFFFFFFFFFl;

class SHA1 {
  var H0 = 0x67452301l;
  var H1 = 0xEFCDAB89l;
  var H2 = 0x98BADCFEl;
  var H3 = 0x10325476l;
  var H4 = 0xC3D2E1F0l;
  var computed = false;

  // 512-bit message block as 8-bit Numbers
  var block_ = new [64];
  var index_ = 0;

  var length_ = 0l;

  function input(data) {
    for (var i = 0; i < data.size(); i++) {
      if (length_ == MAX_LENGTH) {
        System.println("WARNING: max length reached");
        return;
      }
      block_[index_] = data[i];
      index_ += 1;
      length_ += 8;
      if (index_ == 64) {
        process();
      }
    }
  }

  function result() {
    if (!computed) {
      pad(); // also processes
      // clear message
      for(var i = 0; i < 64; i++) {
        block_[i] = 0;
      }
      length_ = 0l;
      computed = true;
    }
    var digest = new [20];
    digest[ 0] = t8(H0 >> 24);
    digest[ 1] = t8(H0 >> 16);
    digest[ 2] = t8(H0 >> 8);
    digest[ 3] = t8(H0);
    digest[ 4] = t8(H1 >> 24);
    digest[ 5] = t8(H1 >> 16);
    digest[ 6] = t8(H1 >> 8);
    digest[ 7] = t8(H1);
    digest[ 8] = t8(H2 >> 24);
    digest[ 9] = t8(H2 >> 16);
    digest[10] = t8(H2 >> 8);
    digest[11] = t8(H2);
    digest[12] = t8(H3 >> 24);
    digest[13] = t8(H3 >> 16);
    digest[14] = t8(H3 >> 8);
    digest[15] = t8(H3);
    digest[16] = t8(H4 >> 24);
    digest[17] = t8(H4 >> 16);
    digest[18] = t8(H4 >> 8);
    digest[19] = t8(H4);
    return digest;
  }

  private const K0 = 0x5A827999l;
  private const K1 = 0x6ED9EBA1l;
  private const K2 = 0x8F1BBCDCl;
  private const K3 = 0xCA62C1D6l;

  private function process() {
    var W = new [80];
    for(var t = 0; t < 16; t++) {
      W[t] = (t8(block_[t * 4]) << 24) |
        (t8(block_[t * 4 + 1]) << 16) |
        (t8(block_[t * 4 + 2]) << 8) |
        t8(block_[t * 4 + 3]);
    }
    // b
    for(var t = 16; t < 80; t++) {
      W[t] = r32(1, W[t-3] ^ W[t-8] ^ W[t-14] ^ W[t-16]);
    }
    // c
    var A = H0;
    var B = H1;
    var C = H2;
    var D = H3;
    var E = H4;
    var T;
    // d
    for(var t = 0; t < 20; t++) {
      T = t32(r32(5, A) + ((B & C) | ((~B) & D)) + E + W[t] + K0);
      E = D;
      D = C;
      C = r32(30, B);
      B = A;
      A = T;
    }
    for(var t = 20; t < 40; t++) {
      T = t32(r32(5, A) + (B ^ C ^ D) + E + W[t] + K1);
      E = D;
      D = C;
      C = r32(30, B);
      B = A;
      A = T;
    }
    for(var t = 40; t < 60; t++) {
      T = t32(r32(5, A) + ((B & C) | (B & D) | (C & D)) + E + W[t] + K2);
      E = D;
      D = C;
      C = r32(30, B);
      B = A;
      A = T;
    }
    for(var t = 60; t < 80; t++) {
      T = t32(r32(5, A) + (B ^ C ^ D) + E + W[t] + K3);
      E = D;
      D = C;
      C = r32(30, B);
      B = A;
      A = T;
    }
    // e
    H0 = t32(H0 + A);
    H1 = t32(H1 + B);
    H2 = t32(H2 + C);
    H3 = t32(H3 + D);
    H4 = t32(H4 + E);

    index_ = 0;
  }

  private function pad() {
    // Bytes 55 - 64 are required to store the padding marker and message length
    var maxIndex = 55;
    if (index_ > maxIndex) {
      // Start padding, fill and process block
      block_[index_] = 0x80; index_++;
      while(index_ < 64) {
        block_[index_] = 0x00; index_++;
      }
      process();
    } else {
      // Start padding
      block_[index_] = 0x80; index_++;
    }
    // Pad with 0s and store length
    while(index_ <= maxIndex) {
      block_[index_] = 0x00; index_++;
    }
    block_[index_] = t8(length_ >> 56); index_++;
    block_[index_] = t8(length_ >> 48); index_++;
    block_[index_] = t8(length_ >> 40); index_++;
    block_[index_] = t8(length_ >> 32); index_++;
    block_[index_] = t8(length_ >> 24); index_++;
    block_[index_] = t8(length_ >> 16); index_++;
    block_[index_] = t8(length_ >> 8); index_++;
    block_[index_] = t8(length_); index_++;
    process();
  }
}

function r32(n, x) {
  return t32((x << n) | (x >> (32 - n)));
}

function t32(x) {
  return x & 0xffffffffl;
}

function t8(x) {
  return x & 0xffl;
}
