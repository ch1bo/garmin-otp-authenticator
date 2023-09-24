import Toybox.Lang;
import Toybox.Math;
import Toybox.Test;
import Toybox.System;

function assertNumber(v) {
  switch(v) {
  case instanceof Lang.Number:
    return;
  }
  Test.assert(false);
}

function assertAllNumber(values as Array<Number>) {
  for (var i = 0; i < values.size(); i++) {
    assertNumber(values[i]);
  }
}

function assertString(v) {
  switch(v) {
  case instanceof Lang.String:
    return;
  }
  Test.assert(false);
}

function assertEqual(message, expected, actual) {
  Test.assertEqualMessage(expected, actual, Lang.format(message + " not equal\nexpected: $1$\n but got: $2$", [expected, actual]));
}

function assertArrayEqual(message, expected, actual) {
  var equal = arrayEqual(expected, actual);
  Test.assertMessage(equal, message + " not equal\nexpected: " + expected + "\n but got: " + actual);
}

function assertDictEqual(message, expected, actual) {
  var equal = dictEqual(expected, actual);
  Test.assertMessage(equal, message + " not equal\nexpected: " + expected + "\n but got: " + actual);
}

function arrayToString(xs as Array<Object>) {
  var str = "[";
  for(var i = 0; i < xs.size(); i++) {
    str += xs[i].toString();
    if (i < xs.size() - 1) {
      str += ", ";
    }
  }
  return str + "]";
}

function arrayEqual(a as Array<Object>, b as Array<Object>) {
  if (a.size() != b.size()) {
    return false;
  }
  for(var i = 0; i < a.size(); i++) {
    if (!a[i].equals(b[i])) {
      return false;
    }
  }
  return true;
}

function dictEqual(a as Dictionary<String, Object>, b as Dictionary<String, Object>) {
  if (a.size() != b.size()) {
    return false;
  }
  var ks = a.keys();
  for (var i = 0; i < a.size(); i++) {
    if (!a.get(ks[i]).equals(b.get(ks[i]))) {
      return false;
    }
  }
  return true;
}
