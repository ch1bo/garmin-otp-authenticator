using Toybox.Math;

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

function hex2bytes(string) {
  var cs = string.toCharArray();
  var bs = new [cs.size()/2 + cs.size()%2];
  for (var i = 0; i < cs.size(); i++) {
    var j = i / 2;
    var b = h2b(cs[i]);
    if (i % 2 == 0) {
      bs[j] = b;
    } else {
      bs[j] = bs[j] << 4 | b;
    }
  }
  return bs;
}

function h2b(char) {
  switch(char.toUpper()) {
  case '0': return 0x0;
  case '1': return 0x1;
  case '2': return 0x2;
  case '3': return 0x3;
  case '4': return 0x4;
  case '5': return 0x5;
  case '6': return 0x6;
  case '7': return 0x7;
  case '8': return 0x8;
  case '9': return 0x9;
  case 'A': return 0xA;
  case 'B': return 0xB;
  case 'C': return 0xC;
  case 'D': return 0xD;
  case 'E': return 0xE;
  case 'F': return 0xF;
  default: return null;
  }
}

function bytes2hex(bytes) {
  var str = "";
  for (var i = 0; i < bytes.size(); i++) {
    if (bytes[i] != null) {
      str += bytes[i].format("%X");
    } else {
      str += "-";
    }
  }
  return str;
}
