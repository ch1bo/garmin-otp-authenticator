using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

module TextInput {

const ALPHA = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
               "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
               "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
               "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];

class TextInputView extends WatchUi.View {

  var cursor_;
  var alphabet_;
  var text_;
  var confirm_ = false;

  function initialize(alphabet) {
    View.initialize();
    alphabet_ = alphabet;
    cursor_ = 0;
    text_ = "";
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var fh = dc.getFontHeight(Graphics.FONT_SMALL);
    dc.drawText(5, dc.getHeight()/2 - fh/2, Graphics.FONT_SMALL, text_, Graphics.TEXT_JUSTIFY_LEFT);
    var tw = dc.getTextWidthInPixels(text_, Graphics.FONT_SMALL);
    var fw = dc.getTextWidthInPixels("M", Graphics.FONT_SMALL);
    var max = dc.getWidth() - fw - 10;
    var x = tw + 15;
    drawAlphabet(dc, x > max ? max : x);
  }

  function drawAlphabet(dc, x) {
    if (confirm_) {
      dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
    } else {
      dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
    }
    drawLetter(dc, x, 0);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    drawLetter(dc, x, -3);
    drawLetter(dc, x, -2);
    drawLetter(dc, x, -1);
    drawLetter(dc, x, 1);
    drawLetter(dc, x, 2);
    drawLetter(dc, x, 3);
  }

  function drawLetter(dc, x, pos) {
    var fh = dc.getFontHeight(Graphics.FONT_SMALL);
    var y = (dc.getHeight() / 2 - fh / 2) + pos * (fh + 5);
    var c = alphabet_[limit(cursor_ + pos, alphabet_.size())];
    dc.drawText(x, y, Graphics.FONT_SMALL, c, Graphics.TEXT_JUSTIFY_CENTER);
  }

  // Action handlers

  // TOD(SN): move logic to delegate, hold state in common object?
  function onUp() {
    cursor_ = limit(cursor_ + 1, alphabet_.size());
    confirm_ = false;
    WatchUi.requestUpdate();
  }

  function onDown() {
    cursor_ = limit(cursor_ - 1, alphabet_.size());
    confirm_ = false;
    WatchUi.requestUpdate();
  }

  function enter() {
    text_ = text_ + alphabet_[limit(cursor_, alphabet_.size())];
    confirm_ = false;
    WatchUi.requestUpdate();
  }

  function backspace() {
    text_ = text_.substring(0, text_.length()-1);
    confirm_ = false;
    WatchUi.requestUpdate();
  }

  function confirm(confirm) {
    confirm_ = confirm;
    WatchUi.requestUpdate();
  }
}

class TextInputDelegate extends WatchUi.InputDelegate {

  var last_key_ = null;
  var view_;

  function initialize(view) {
    InputDelegate.initialize();
    view_ = view;
  }

  function onSwipe(evt) {
    var swipe = evt.getDirection();
    if (swipe == SWIPE_UP) {
      view_.onUp();
    } else if (swipe == SWIPE_RIGHT) {
      view_.enter();
    } else if (swipe == SWIPE_DOWN) {
      view_.onDown();
    } else if (swipe == SWIPE_LEFT) {
      view_.backspace();
    }
    return true;
  }

  function onTap(event) {
    view_.enter();
    return false;
  }

  function onKey(event) {
    var key = event.getKey();
    switch (key) {
    case KEY_UP:
      view_.onUp();
      break;
    case KEY_DOWN:
      view_.onDown();
      break;
    case KEY_ENTER:
      if (last_key_ == KEY_ENTER) {
        onTextEntered(view_.text_);
        WatchUi.popView(WatchUi.SLIDE_LEFT);
      } else {
        view_.confirm(true);
      }
      break;
    case KEY_ESC:
      if (last_key_ == KEY_ESC) {
        onCancel();
        WatchUi.popView(WatchUi.SLIDE_LEFT);
      } else {
        view_.confirm(false);
      }
      break;
    }
    last_key_ = key;
    return true;
  }

  function onTextEntered(text) {
    System.println("TextInput: " + text);
  }

  function onCancel() {
    System.println("TextInput canceled");
  }
}

}

function limit(i, max) {
  if (i < 0) {
    return max + i;
  } else {
    return i % max;
  }
}
