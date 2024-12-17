import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

(:glance)
class WidgetGlanceView extends WatchUi.GlanceView {
  var timer_;

  function initialize() {
    GlanceView.initialize();
    timer_ = new Timer.Timer();
  }

  function onShow() {
    var updateRate = Application.Properties.getValue("glanceRate");
    logf(DEBUG, "GlanceView onShow, update rate: $1$", [updateRate]);
    if (updateRate > 0) {
      var period = 60.0 / updateRate * 1000;
      timer_.start(method(:onTimer), period, true);
    }
    onTimer();
  }

  function onHide() {
    log(DEBUG, "GlanceView onHide");
    timer_.stop();
  }

  function onTimer() {
    var provider = currentProvider();
    if (provider != null) {
      provider.update();
    }
    WatchUi.requestUpdate();
  }

  function onUpdate(dc) {
    log(DEBUG, "GlanceView onUpdate");
    var mainColor = Graphics.COLOR_WHITE;
    var mainFont = Graphics.FONT_GLANCE;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.clear();

    var provider = currentProvider();
    if (provider == null) {
      drawMain(dc, "OTP Authenticator", mainFont, mainColor, 0);
      drawSub(dc, "Open to start", Graphics.FONT_GLANCE, Graphics.COLOR_WHITE, 0);
      return;
    }

    var subFont = Graphics.FONT_GLANCE_NUMBER;
    var subColor = Graphics.COLOR_WHITE;
    switch (provider) {
    case instanceof SteamGuardProvider:
      subFont = Graphics.FONT_GLANCE;
    case instanceof TimeBasedProvider:
      // Colored OTP code depending on countdown
      var delta = (provider as TimeBasedProvider).next_ - Time.now().value();
      subColor = Device.getCountdownColor(delta);
      drawProgress(dc, delta, 30, subColor);
    case instanceof CounterBasedProvider:
      drawMain(dc, provider.name_, mainFont, mainColor, 4);
      drawSub(dc, provider.code_, subFont, subColor, 4);
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

