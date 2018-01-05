using Toybox.Lang;
using Toybox.Math;
using Toybox.Test;
using Toybox.System;

function assertNumber(v) {
  switch(v) {
  case instanceof Lang.Number:
    return;
  }
  Test.assert(false);
}

function assertAllNumber(values) {
  for (var i = 0; i < values.size(); i++) {
    assertNumber(values[i]);
  }
}

function assertEqual(message, expected, actual) {
  Test.assertEqualMessage(expected, actual, Lang.format(message + " not equal\nexpected: $1$\n but got: $2$", [expected, actual]));
}

function assertArrayEqual(message, expected, actual) {
  var equal = arrayEqual(expected, actual);
  Test.assertMessage(equal, message + " not equal\nexpected: " + arrayToString(expected) + "\n but got: " + arrayToString(actual));
}

function arrayToString(xs) {
  var str = "[";
  for(var i = 0; i < xs.size(); i++) {
    str += xs[i].toString();
    if (i < xs.size() - 1) {
      str += ", ";
    }
  }
  return str + "]";
}

function arrayEqual(a, b) {
  if (a.size() != b.size()) {
    return false;
  }
  for(var i = 0; i < a.size(); i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
