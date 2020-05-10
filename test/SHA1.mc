using Toybox.System;
using Toybox.Test;

(:test)
  function t32_test(logger) {
  return t32(0xffffff00000001l) == 1;
}

(:test)
  function r32_test(logger) {
  return r32(1, 0x80000000l) == 0x00000001l;
}

(:test)
function r32_test2(logger) {
  return r32(1, 0xEC6D6E6Fl) == 0xD8DADCDFl;
}

(:test)
function hashSHA1_test1(logger) {
  var message = "abc".toUtf8Array();
  var expected = [0xA9, 0x99, 0x3E, 0x36,
                  0x47, 0x06, 0x81, 0x6A,
                  0xBA, 0x3E, 0x25, 0x71,
                  0x78, 0x50, 0xC2, 0x6C,
                  0x9C, 0xD0, 0xD8, 0x9D];
  var sha1 = new SHA1();
  sha1.input(message);
  var digest = sha1.result();
  Test.assertEqual(digest.size(), 20);
  assertAllNumber(digest);
  return arrayEqual(expected, digest);
}

(:test)
function hashSHA1_test2(logger) {
  var message = ("abcdbcdecdefdefgefghfghighijhi" +
               "jkijkljklmklmnlmnomnopnopq").toUtf8Array();
  var expected = [0x84, 0x98, 0x3E, 0x44,
                  0x1C, 0x3B, 0xD2, 0x6E,
                  0xBA, 0xAE, 0x4A, 0xA1,
                  0xF9, 0x51, 0x29, 0xE5,
                  0xE5, 0x46, 0x70, 0xF1];
  var sha1 = new SHA1();
  sha1.input(message);
  var digest = sha1.result();
  Test.assertEqual(digest.size(), 20);
  assertAllNumber(digest);
  return arrayEqual(expected, digest);
}

// Note: This test is very slow, disable it for development
(:test)
function hashSHA1_test3(logger) {
  var expected = [0x34, 0xAA, 0x97, 0x3C,
                  0xD4, 0xC4, 0xDA, 0xA4,
                  0xF6, 0x1E, 0xEB, 0x2B,
                  0xDB, 0xAD, 0x27, 0x31,
                  0x65, 0x34, 0x01, 0x6F];
  var sha1 = new SHA1();
  for (var i = 0; i < 1000000; i++) {
    sha1.input([0x61]);
    if (i % 10000 == 0) {
      System.print(i / 10000);
      System.println("%");
    }
  }
  var digest = sha1.result();
  Test.assertEqual(digest.size(), 20);
  assertAllNumber(digest);
  return arrayEqual(expected, digest);
}

(:test)
function hashSHA1_test4(logger) {
  var message = ("01234567012345670123456701234567" +
                 "01234567012345670123456701234567").toUtf8Array();
  var expected = [0xDE, 0xA3, 0x56, 0xA2,
                  0xCD, 0xDD, 0x90, 0xC7,
                  0xA7, 0xEC, 0xED, 0xC5,
                  0xEB, 0xB5, 0x63, 0x93,
                  0x4F, 0x46, 0x04, 0x52];
  var sha1 = new SHA1();
  for (var i = 0; i < 10; i++) {
    sha1.input(message);
  }
  var digest = sha1.result();
  Test.assertEqual(digest.size(), 20);
  assertAllNumber(digest);
  return arrayEqual(expected, digest);
}
