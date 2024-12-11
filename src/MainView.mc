import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

using CountdownColor;
using Device;
using TextInput;

// TODO: pass provider instead of using global _currentIndex / currentProvider()
class MainView extends WatchUi.View {
  var screen_shape_;
  var timer_;
  var update_rate_;

  function initialize() {
    View.initialize();
    screen_shape_ = System.getDeviceSettings().screenShape;
    timer_ = new Timer.Timer();
    update_rate_ = Application.Properties.getValue("mainRate");
  }

  function onShow() {
    logf(DEBUG, "MainView onShow, update rate: $1$", [update_rate_]);
    if (update_rate_ > 0) {
      var period = 60.0 / update_rate_ * 1000;
      timer_.start(method(:update), period, true);
    }
    update();
  }

  function onHide() {
    log(DEBUG, "MainView onHide");
    timer_.stop();
  }

  function update() {
    var provider = currentProvider();
    if (provider != null) {
      provider.update();
    }
    WatchUi.requestUpdate();
  }

  // XXX: This is getting unwieldy, especially for handling the special cases
  // for devices with a subscreen on the top right corner (instinct2). Should:
  // Create a device specific layout to also avoid conditionals in the rendering
  // logic.
  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var provider = currentProvider();
    if (provider == null) {
      dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM,
                  "ENTER to start",
                  Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      return;
    } else {
      // Use number font if possible
      var codeColor = Graphics.COLOR_GREEN;
      var codeFont = getMaxNumberFont(dc, provider.code_);
      var codeHeight = dc.getFontHeight(codeFont);
      var subscreenIsTopRight = Device.subscreenIsTopRight(dc.getWidth());
      switch (provider) {
      // NOTE(SN): This case deliberately falls-through
      case instanceof SteamGuardProvider:
        codeFont = Graphics.FONT_LARGE;
        codeHeight = dc.getFontHeight(codeFont);
      case instanceof TimeBasedProvider:
        var delta = (provider as TimeBasedProvider).next_ - Time.now().value();
        var deltaText = delta < 0 ? "--" : delta.toString();
        delta = delta < 0 ? 0 : delta;
        codeColor = CountdownColor.getCountdownColor(delta);
        drawCode(dc, codeColor, codeFont, provider.code_);
        if (subscreenIsTopRight) {
          // Provider name
          drawBelowCode(dc, codeHeight, Graphics.FONT_MEDIUM, provider.name_);
          // Countdown text
          drawTopLeftOfSubscreen(dc, codeHeight, Graphics.FONT_NUMBER_MILD, deltaText);
        } else {
          // Provider name
          drawAboveCode(dc, codeHeight, Graphics.FONT_MEDIUM, provider.name_);
          // Countdown text
          drawBelowCode(dc, codeHeight, Graphics.FONT_NUMBER_MILD, deltaText);
        }
        drawProgress(dc, delta, 30, codeColor);
        break;
      case instanceof CounterBasedProvider:
        // Provider name
        drawAboveCode(dc, codeHeight, Graphics.FONT_MEDIUM, provider.name_);
        drawCode(dc, codeColor, codeFont, provider.code_);
        // Instructions
        drawBelowCode(dc, codeHeight, Graphics.FONT_SMALL,
                      "ENTER for next code");
        break;
      }
    }
  }

  function drawProgress(dc, value, max, codeColor) {
    // Available from 3.2.0
    if (dc has :setAntiAlias) {
      dc.setAntiAlias(true);
    }
    dc.setPenWidth(dc.getHeight() / 40);
    dc.setColor(codeColor, Graphics.COLOR_TRANSPARENT);
    var subscreen = Device.getSubscreen();
    if (subscreen != null) {
      // Use the subscreen to paint a clock like countdown
      dc.setPenWidth(subscreen.width / 2);
      dc.drawArc(
        subscreen.x + subscreen.width / 2,
        subscreen.y + subscreen.height / 2,
        // I don't understand how the radius parameter works
        // Apparently a quarter width works to get a complete circle
        subscreen.width / 4,
        Graphics.ARC_COUNTER_CLOCKWISE,
        90, ((value * 360) / max) + 90
      );
    } else if (screen_shape_== System.SCREEN_SHAPE_ROUND) {
      // Use the whole screen to paint a clock like countdown
      dc.drawArc(
        dc.getWidth() / 2,
        dc.getHeight() / 2,
        (dc.getWidth() / 2) - 2,
        Graphics.ARC_COUNTER_CLOCKWISE,
        90, ((value * 360) / max) + 90
      );
    } else {
      // Fallback to a very basic bar at the top of the screen
      dc.fillRectangle(0, 0, ((value * dc.getWidth()) / max), dc.getHeight() / 40);
    }
  }

  // Determine the maximum font size for some text
  function getMaxNumberFont(dc, text) {
    var fonts = [Graphics.FONT_NUMBER_THAI_HOT, Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MEDIUM];
    for (var i = 0; i < fonts.size(); i++) {
      var codeWidth = dc.getTextWidthInPixels(text, fonts[i]);
      var dcWidth = dc.getWidth();
      // Leave some border for potential progress drawing (arc)
      if (codeWidth < dcWidth - 5) {
        return fonts[i];
      }
    }
    return Graphics.FONT_NUMBER_MILD;
  }

  function getCodeY(dc) {
    var subscreenIsTopRight = Device.subscreenIsTopRight(dc.getWidth());
    var subscreen = Device.getSubscreen();
    var dcHeight = dc.getHeight();
    if (subscreenIsTopRight) {
      var drawableHeight = subscreen.height + (dcHeight - subscreen.height);
      // Not exactly one quarter, because of visual gravity: more space above 
      // than below (in spite of room above not being used because of subscreen)
      return subscreen.height + (drawableHeight / 4.8);
    } else {
      return dcHeight / 2;
    }
  }

  function drawCode(dc, codeColor, codeFont, code) {
    dc.setColor(codeColor, Graphics.COLOR_BLACK);
    dc.drawText(dc.getWidth() / 2, getCodeY(dc), codeFont, code,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawAboveCode(dc, codeHeight, font, text) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    var fh = dc.getFontHeight(font);
    dc.drawText(dc.getWidth() / 2, getCodeY(dc) - codeHeight / 2 - fh / 2,
                font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawBelowCode(dc, codeHeight, font, text) {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
    var fh = dc.getFontHeight(font);
    dc.drawText(dc.getWidth() / 2, getCodeY(dc) + codeHeight / 2 + fh / 2,
                font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawTopLeftOfSubscreen(dc, codeHeight, font, text) {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
    var subscreen = Device.getSubscreen();
    // Don't center exactly in the middle because instinct subscreen is round
    var x = (dc.getWidth() - subscreen.width) / 2.3;
    dc.drawText(x, subscreen.height / 2,
                font, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }
}

class MainViewDelegate extends WatchUi.BehaviorDelegate {
  function initialize() { BehaviorDelegate.initialize(); }

  function onKey(event) {
    var key = event.getKey();
    logf(DEBUG, "onKey $1$", [key]);
    if (key == KEY_MENU || key == KEY_ENTER) {
      var provider = currentProvider();
      switch (provider) {
      case instanceof CounterBasedProvider:
        (provider as CounterBasedProvider).next();
        WatchUi.requestUpdate();
        return true;
      }
    } else if (key == KEY_DOWN || key == KEY_UP) {
      var delta = key == KEY_DOWN ? 1 : -1;
      _currentIndex += delta;
      if (_currentIndex < 0) {
        _currentIndex = _providers.size() - 1;
      } else if (_currentIndex >= _providers.size()) {
        _currentIndex = 0;
      }
      logf(DEBUG, "quick switch to index $1$", [_currentIndex]);
      saveProviders();
      WatchUi.requestUpdate();
      return true;
    }
    return BehaviorDelegate.onKey(event);
  }

  function onSelect() {
    if (_providers.size() == 0) {
      WatchUi.pushView(new NewItemMenu("New item", null, null, :time), new NewItemMenuDelegate(), WatchUi.SLIDE_RIGHT);
    } else {
      WatchUi.pushView(new MainMenu(), new MainMenuDelegate(), WatchUi.SLIDE_RIGHT);
    }
    return true;
  }
}
