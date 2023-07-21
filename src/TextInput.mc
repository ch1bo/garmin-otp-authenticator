using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;

using Device;

module TextInput {

// Using a latin1 character as unicode was not supported on all devices
const CHECKMARK = '»';

class TextInputView extends WatchUi.View {

  var alphabet_;
  var confirm_ = false;
  var cursor_;
  var text_;
  var title_;

  function initialize(title, alphabet) {
    View.initialize();
    title_ = title;
    alphabet_ = new [0];
    alphabet_.addAll(alphabet);
    alphabet_.add(CHECKMARK);
    cursor_ = 0;
    text_ = "";
  }

  // XXX: This layout is suboptimal for the instinct2: The prompt text should
  // not be on the top left corner, but also needs to be left to not flow into
  // the subscreen. Also, the alphabet stretches to far top and overflows with
  // the prompt text. Should: Create a device specific layout to also avoid
  // conditionals in the rendering logic.
  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var font = Graphics.FONT_SMALL;
    var hasSubscreen = Device.getSubscreen() != null;
    // This assumes the subscreen is in the top right corner (as it is for
    // instinct2)
    var textJustify = hasSubscreen ? Graphics.TEXT_JUSTIFY_LEFT : Graphics.TEXT_JUSTIFY_CENTER;
    var textX = hasSubscreen ? 5 : dc.getWidth() / 2;
    dc.drawText(textX, 10, font, title_, textJustify);
    var textWidth = dc.getTextWidthInPixels(text_, font);
    // min width required for alphabet is widest char (M) + margins
    var alphabetWidth = dc.getTextWidthInPixels("M", font) + 15;
    var x = 5;
    if (textWidth + alphabetWidth >= dc.getWidth()) {
      x = dc.getWidth() - alphabetWidth - textWidth;
    }
    if (!confirm_) {
      drawAlphabet(dc, x + textWidth + 15);
    } else {
      dc.drawText(textX, 35, font, "Confirm?", textJustify);
      // Green is not visible on black and white displays, do not use
      if (Device.getPalette() != Device.BLACK_AND_WHITE) {
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
      }
    }
    dc.drawText(x, dc.getHeight()/2, font, text_,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawAlphabet(dc, x) {
    if (!confirm_) {
      dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
    }
    drawLetter(dc, x, 0);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    drawLetter(dc, x, -2);
    drawLetter(dc, x, -1);
    drawLetter(dc, x, 1);
    drawLetter(dc, x, 2);
    drawLetter(dc, x, 3);
  }

  function drawLetter(dc, x, pos) {
    var font = Graphics.FONT_SMALL;
    var fh = dc.getFontHeight(font);
    var y = dc.getHeight() / 2 + pos * (fh + 3);
    var c = alphabet_[limit(cursor_ + pos, alphabet_.size())];
    dc.drawText(x, y, font, c,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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
    var selected_char = alphabet_[limit(cursor_, alphabet_.size())];
    // On some devices long-pressing the select button acts as a shortcut,
    // adding this secondary way to confirm the input works around this
    if (selected_char == CHECKMARK) {
      self.confirm(true);
      return;
    }
    text_ = text_ + selected_char;
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

class TextInputDelegate extends WatchUi.BehaviorDelegate {

  var view_;
  var timer_;

  function initialize(view) {
    BehaviorDelegate.initialize();
    view_ = view;
    timer_ = new Timer.Timer();
  }

  function onTextEntered(text) {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }

  function onCancel() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }

  // BehaviorDelegate methods

  function onNextPage() {
    log(DEBUG, "onNextPage");
    view_.onUp();
    return true;
  }

  function onPreviousPage() {
    log(DEBUG, "onPreviousPage");
    view_.onDown();
    return true;
  }

  function onNextMode() {
    log(DEBUG, "onNextMode");
    return false;
  }

  function onPreviousMode() {
    log(DEBUG, "onPreviousMode");
    return false;
  }

  function onSelect() {
    log(DEBUG, "onSelect");
    // TODO(SN): smelly access on view state
    if (view_.confirm_) {
      view_.confirm_ = false;
      onTextEntered(view_.text_);
    } else {
      view_.enter();
    }
    return true;
  }

  function onBack() {
    log(DEBUG, "onBack");
    // TODO(SN): hold state here or in view?
    if (view_.text_.length() > 0) {
      view_.backspace();
    } else {
      onCancel();
    }
    return true;
  }

  function onMenu() {
    log(DEBUG, "onMenu");
    // TODO(SN): another hack
    if (view_.confirm_) {
      onTextEntered(view_.text_);
    } else {
      view_.confirm(true);
    }
    return true;
  }

  // InputDelegate methods

  function onSwipe(evt) {
    log(DEBUG, Lang.format("onSwipe: $1$", [evt]));
    var swipe = evt.getDirection();
    if (swipe == SWIPE_UP) {
      view_.onUp();
      return true;
    }
    if (swipe == SWIPE_DOWN) {
      view_.onDown();
      return true;
    }
    return false;
  }

  // Handle long press manually (e.g. FR245)
  function onKeyPressed(evt) {
    log(DEBUG, Lang.format("onKeyPressed: $1$", [evt.getKey()]));
    if (evt.getKey() == WatchUi.KEY_ENTER) {
      timer_.start(method(:onMenu), 1000, false);
    }
    return true;
  }

  function onKeyReleased(evt) {
    log(DEBUG, Lang.format("onKeyReleased: $1$", [evt.getKey()]));
    timer_.stop();
    return true;
  }
}

}

// Drop characters from front until fitting
function ellipsizeFront(dc, text, font, max_width) {
  var ellipsis = "..";
  if (dc.getTextWidthInPixels(text, font) > max_width) {
    do {
      text = text.substring(1, text.length());
    } while (dc.getTextWidthInPixels(ellipsis + text, Graphics.FONT_SMALL) > max_width);
    return ellipsis + text;
  }
  return text;
}

function limit(i, max) {
  if (i < 0) {
    return max + i;
  } else {
    return i % max;
  }
}
