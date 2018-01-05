using Toybox.Lang;
using Toybox.System;

// Implementation of Base16 and Base32 encoding
// rfc3548 https://tools.ietf.org/html/rfc3548

function base16ToBytes(string) {
  // pad zero
  var l = string.length();
  if (l % 2 == 1) {
    string = "0" + string;
    l = l + 1;
  }
  var cs = string.toCharArray();
  var bs = new [l/2];
  for (var i = 0; i < cs.size(); i += 2) {
    bs[i/2] = hex(cs[i]) << 4 | hex(cs[i+1]);
  }
  return bs;
}

function hex(char) {
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
  default:
    throw new UnexpectedSymbolException(c);
  }
}

function bytesToBase16(bytes) {
  var str = "";
  for (var i = 0; i < bytes.size(); i++) {
    if (bytes[i] == null) {
      throw new UnexpectedSymbolException("null");
    }
    if (bytes[i] < 0x10) {
      str += "0";
    }
    str += bytes[i].format("%X");
  }
  return str;
}

function base32ToBytes(str) {
  var cs = str.toCharArray();
  if (cs.size() % 8 != 0) {
    throw new InvalidValueException("multiple of 40 bit / 8 characters");
  }
  var bs = new [cs.size() / 8 * 5];
  for (var i = 0; i < cs.size(); i += 8) {
    var j = i / 8 * 5;
    bs[j] = b32toi(cs[i]) & 0x1F << 3 | b32toi(cs[i+1]) & 0x1C >> 2; // 5 + 3
    bs[j+1] = b32toi(cs[i+1]) & 0x03 << 6 | b32toi(cs[i+2]) & 0x1F << 1 | b32toi(cs[i+3]) & 0x10 >> 4; // 2 + 5 + 1
    bs[j+2] = b32toi(cs[i+3]) & 0x0F << 4 | b32toi(cs[i+4]) & 0x1E >> 1; // 4 + 4
    bs[j+3] = b32toi(cs[i+4]) & 0x01 << 7 | b32toi(cs[i+5]) & 0x1F << 2 | b32toi(cs[i+6]) & 0x18 >> 3; // 1 + 5 + 2
    bs[j+4] = b32toi(cs[i+6]) & 0x07 << 5 | b32toi(cs[i+7]) & 0x1F; // 3 + 5;
  }
  return bs;
}

function bytesToBase32(bytes) {
  if (bytes.size() % 5 != 0) {
    throw new InvalidValueException("multiple of 40 bit / 5 bytes required");
  }
  var str = "";
  for (var i = 0; i < bytes.size(); i += 5) {
    str += itob32(bytes[i] & 0xF8 >> 3); // 5
    str += itob32((bytes[i] & 0x07 << 2) | (bytes[i+1] & 0xC0 >> 6)); // 3+2
    str += itob32(bytes[i+1] & 0x3E >> 1); // 5
    str += itob32((bytes[i+1] & 0x01 << 4) | (bytes[i+2] & 0xF0 >> 4)); // 1+4
    str += itob32((bytes[i+2] & 0x0F << 1) | (bytes[i+3] & 0x80 >> 7)); // 4+1
    str += itob32(bytes[i+3] & 0x7C >> 2); // 5
    str += itob32((bytes[i+3] & 0x03 << 3) | (bytes[i+4] & 0xE0 >> 5)); // 2+3
    str += itob32(bytes[i+4] & 0x1F); // 5
  }
  return str;
}

function b32toi(c) {
  switch(c.toUpper()) {
  case 'A': return 0;
  case 'B': return 1;
  case 'C': return 2;
  case 'D': return 3;
  case 'E': return 4;
  case 'F': return 5;
  case 'G': return 6;
  case 'H': return 7;
  case 'I': return 8;
  case 'J': return 9;
  case 'K': return 10;
  case 'L': return 11;
  case 'M': return 12;
  case 'N': return 13;
  case 'O': return 14;
  case 'P': return 15;
  case 'Q': return 16;
  case 'R': return 17;
  case 'S': return 18;
  case 'T': return 19;
  case 'U': return 20;
  case 'V': return 21;
  case 'W': return 22;
  case 'X': return 23;
  case 'Y': return 24;
  case 'Z': return 25;
  case '2': return 26;
  case '3': return 27;
  case '4': return 28;
  case '5': return 29;
  case '6': return 30;
  case '7': return 31;
  default:
    throw new UnexpectedSymbolException(c);
  }
}

function itob32(i) {
  switch(i) {
  case 0 : return 'A';
  case 1 : return 'B';
  case 2 : return 'C';
  case 3 : return 'D';
  case 4 : return 'E';
  case 5 : return 'F';
  case 6 : return 'G';
  case 7 : return 'H';
  case 8 : return 'I';
  case 9 : return 'J';
  case 10: return 'K';
  case 11: return 'L';
  case 12: return 'M';
  case 13: return 'N';
  case 14: return 'O';
  case 15: return 'P';
  case 16: return 'Q';
  case 17: return 'R';
  case 18: return 'S';
  case 19: return 'T';
  case 20: return 'U';
  case 21: return 'V';
  case 22: return 'W';
  case 23: return 'X';
  case 24: return 'Y';
  case 25: return 'Z';
  case 26: return '2';
  case 27: return '3';
  case 28: return '4';
  case 29: return '5';
  case 30: return '6';
  case 31: return '7';
  default:
    throw new UnexpectedSymbolException(i.toString());
  }
}

class UnexpectedSymbolException extends Lang.Exception {
  var symbol_;

  function initialize(symbol) {
    Exception.initialize();
    symbol_ = symbol;
  }

  function getErrorMessage() {
    return "Unexpected symbol: " + symbol_;
  }
}

class InvalidValueException extends Lang.Exception {
  var value_;

  function initialize(value) {
    Exception.initialize();
    value_ = value;
  }

  function getErrorMessage() {
    return "Invalid value: " + value_;
  }
}
