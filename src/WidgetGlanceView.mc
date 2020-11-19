using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

using TextInput;

(:glance)
class WidgetGlanceView extends WatchUi.GlanceView {
  var timer_;
  function initialize() {
    GlanceView.initialize();
    timer_ = new Timer.Timer();
  }

  function onShow() { timer_.start(method( : update), 500, true); }

  function onHide() {
    timer_.stop();
  }

  function update() {
    var provider = currentProvider();
    if (provider != null) {
      provider.update();
    }
    WatchUi.requestUpdate();
  }

  function drawMain(dc, text, font, codeColor, space) {
    dc.setColor(codeColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(0, dc.getHeight() / 2 - dc.getFontHeight(font) / 2 - space, font, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawSub(dc, text, font, codeColor, space) {
    dc.setColor(codeColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(0, dc.getHeight() / 2 + dc.getFontHeight(font) / 2 + space, font, 
                text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawProgress(dc, value, max, codeColor) {
      var h = dc.getHeight();
      var w = dc.getWidth();

      dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
      dc.fillRectangle(value * w / max + (h / 20), h / 2 - 1, w, h / 20);
      dc.setColor(codeColor, Graphics.COLOR_TRANSPARENT);
      dc.fillRectangle(0, h / 2 - (h / 20), value * w / max, h / 10 + 1);
  }

  function onUpdate(dc) {
    var mainColor = Graphics.COLOR_WHITE;
    var mainFont = Graphics.FONT_GLANCE;
    var subColor = Graphics.COLOR_DK_GRAY;
    var subFont = Graphics.FONT_GLANCE;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    var provider = currentProvider();
    if (provider == null) {
      drawMain(dc, "OTP Authenticator", mainFont, mainColor, 0);
      drawSub(dc, "Tap to start", subFont, subColor, 0);
      return;
    }

    subFont = Graphics.FONT_GLANCE_NUMBER;

    switch (provider) {
    case instanceof SteamGuardProvider:
      subFont = Graphics.FONT_GLANCE;
    case instanceof TimeBasedProvider:
      // Colored OTP code depending on countdown
      var delta = provider.next_ - Time.now().value();
      if (delta > 15) {
        subColor = Graphics.COLOR_GREEN;
      } else if (delta > 5) {
        subColor = Graphics.COLOR_ORANGE;
      } else {
        subColor = Graphics.COLOR_RED;
      }

      drawProgress(dc, delta, 30, subColor);
    case instanceof CounterBasedProvider:
      drawMain(dc, provider.name_, mainFont, mainColor, 4);
      drawSub(dc, provider.code_, subFont, subColor, 4);
      break;
    }
  }
}

