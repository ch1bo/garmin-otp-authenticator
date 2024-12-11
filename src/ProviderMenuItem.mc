import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class ProviderMenuItem extends WatchUi.CustomMenuItem {
  var provider_;

  function initialize(identifier, provider as Provider) {
    log(DEBUG, "ProviderMenuItem initialize");
    WatchUi.CustomMenuItem.initialize(identifier, {});
    provider_ = provider;
  }

  function draw(dc) {
    logf(DEBUG, "ProviderMenuItem draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    var mainColor = Graphics.COLOR_WHITE;
    var mainFont = Graphics.FONT_SMALL;
    var subColor = Graphics.COLOR_DK_GRAY;
    var subFont = Graphics.FONT_SMALL;
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.clear();
    switch (provider_) {
    case instanceof SteamGuardProvider:
      subFont = Graphics.FONT_GLANCE;
    case instanceof TimeBasedProvider:
      // Colored OTP code depending on countdown
      var delta = (provider_ as TimeBasedProvider).next_ - Time.now().value();
      subColor = CountdownColor.getCountdownColor(delta);
      drawProgress(dc, delta, 30, subColor);
    case instanceof CounterBasedProvider:
      drawMain(dc, provider_.name_, mainFont, mainColor, 4);
      drawSub(dc, provider_.code_, subFont, subColor, 4);
      break;
    }
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
}

