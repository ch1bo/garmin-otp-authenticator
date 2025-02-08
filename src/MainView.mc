import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;
import Toybox.Lang;

using Device;

class MainView extends WatchUi.View {
  var screenShape_;
  var timer_;

  function initialize() {
    View.initialize();
    screenShape_ = System.getDeviceSettings().screenShape;
    timer_ = new Timer.Timer();
  }

  function onLayout(dc) {
    log(DEBUG, "MainView onLayout");
    var provider = currentProvider();
    if (provider == null) {
      setLayout(Rez.Layouts.MainViewWithMenuHint(dc));
    } else {
      switch (provider) {
      case instanceof CounterBasedProvider:
        setLayout(Rez.Layouts.MainViewWithMenuHint(dc));
        break;
      default:
        setLayout(Rez.Layouts.MainView(dc));
        break;
      }
    }
  }

  function onShow() {
    var updateRate = Application.Properties.getValue("mainRate");
    logf(DEBUG, "MainView onShow, update rate: $1$", [updateRate]);
    if (updateRate > 0) {
      var period = 60.0 / updateRate * 1000;
      timer_.start(method(:onTimer), period, true);
    }
    onTimer();
  }

  function onHide() {
    log(DEBUG, "MainView onHide");
    timer_.stop();
  }

  function onTimer() {
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
    // XXX: input hints are drawn behind progress arc
    View.onUpdate(dc);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var provider = currentProvider();
    if (provider == null) {
      dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM,
                  "Press to start",
                  Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      return;
    } else {
      // Use number font if possible
      var codeColor = Graphics.COLOR_WHITE;
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
        delta = delta < 0 ? 0 : delta;
        codeColor = Device.getCountdownColor(delta);
        drawCode(dc, codeColor, codeFont, provider.code_);
        if (subscreenIsTopRight) {
          drawBelowCode(dc, codeHeight, Graphics.FONT_MEDIUM, provider.name_);
        } else {
          drawAboveCode(dc, codeHeight, Graphics.FONT_MEDIUM, provider.name_);
        }
        drawProgress(dc, delta, 30, codeColor);
        break;
      case instanceof CounterBasedProvider:
        drawCode(dc, codeColor, codeFont, provider.code_);
        if (subscreenIsTopRight) {
          drawBelowCode(dc, codeHeight, Graphics.FONT_MEDIUM, provider.name_);
          drawTopLeftOfSubscreen(dc, Graphics.FONT_SMALL, "MENU for next");
        } else {
          drawAboveCode(dc, codeHeight, Graphics.FONT_MEDIUM, provider.name_);
          drawBelowCode(dc, codeHeight, Graphics.FONT_SMALL, "MENU for next");
        }
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
    } else if (screenShape_== System.SCREEN_SHAPE_ROUND) {
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
    dc.setColor(codeColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(dc.getWidth() / 2, getCodeY(dc), codeFont, code,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawAboveCode(dc, codeHeight, font, text) {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    // TODO: use TextArea to position / wrap text?
    var fh = dc.getFontHeight(font);
    dc.drawText(dc.getWidth() / 2, getCodeY(dc) - codeHeight / 2 - fh / 2,
                font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawBelowCode(dc, codeHeight, font, text) {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    var fh = dc.getFontHeight(font);
    dc.drawText(dc.getWidth() / 2, getCodeY(dc) + codeHeight / 2 + fh / 2,
                font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawTopLeftOfSubscreen(dc, font, text) {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    var subscreen = Device.getSubscreen();
    // According to style guide subtitle 9px from left
    // https://developer.garmin.com/connect-iq/user-experience-guidelines/instinct-2022/
    dc.drawText(9, subscreen.height / 2,
                font, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }
}

class MainViewDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onKey(event) {
    var key = event.getKey();
    logf(DEBUG, "MainView onKey $1$", [key]);
    if (isActionButton(key)) {
      return onAction();
    }
    return false;
  }

  function onTap(event as ClickEvent) as Boolean {
    logf(DEBUG, "MainView onTap $1$", [event.getCoordinates()]);
    if (isInActionArea(event.getCoordinates())) {
      return onAction();
    } else if (_providers.size() == 0) {
      var menu = new ProviderMenu("New provider", null);
      WatchUi.pushView(menu, new ProviderMenuDelegate(menu, null), WatchUi.SLIDE_LEFT);
    } else {
      WatchUi.pushView(new ProviderList(), new ProviderListDelegate(), WatchUi.SLIDE_LEFT);
    }
    return false;
  }

  function onSelect() {
    log(DEBUG, "MainView onSelect");
    // Menu for devices without action menu / glance
    if (!(WatchUi has :ActionMenu)) {
      if (_providers.size() == 0) {
        var menu = new ProviderMenu("New provider", null);
        WatchUi.pushView(menu, new ProviderMenuDelegate(menu, null), WatchUi.SLIDE_LEFT);
      } else {
        WatchUi.pushView(new ProviderList(), new ProviderListDelegate(), WatchUi.SLIDE_LEFT);
      }
      return true;
    }
    return false;
  }

  // Next mode to open provider list
  function onNext() {
    log(DEBUG, "MainView onNext");
    WatchUi.pushView(new ProviderList(), new ProviderListDelegate(), WatchUi.SLIDE_LEFT);
    return true;
  }

  // Next page to open provider list
  function onNextPage() {
    log(DEBUG, "MainView onNextPage");
    WatchUi.pushView(new ProviderList(), new ProviderListDelegate(), WatchUi.SLIDE_LEFT);
    return true;
  }

  // Previous mode to open provider list
  function onPrevious() {
    log(DEBUG, "MainView onPrevious");
    WatchUi.pushView(new ProviderList(), new ProviderListDelegate(), WatchUi.SLIDE_LEFT);
    return true;
  }

  // Previous page to open provider list
  function onPreviousPage() {
    log(DEBUG, "MainView onPreviousPage");
    WatchUi.pushView(new ProviderList(), new ProviderListDelegate(), WatchUi.SLIDE_LEFT);
    return true;
  }

  // Menu or enter button
  function onMenu() {
    log(DEBUG, "MainView onMenu");
    if (_providers.size() == 0) {
      var menu = new ProviderMenu("New provider", null);
      WatchUi.pushView(menu, new ProviderMenuDelegate(menu, null), WatchUi.SLIDE_LEFT);
    } else {
      var provider = currentProvider();
      switch (provider) {
      case instanceof CounterBasedProvider:
        (provider as CounterBasedProvider).next();
        WatchUi.requestUpdate();
        return true;
      }
    }
    return false;
  }

  // Action menu selected
  function onAction() as Lang.Boolean {
    log(DEBUG, "MainView onAction");
    if (_providers.size() == 0) {
      var menu = new ProviderMenu("New provider", null);
      WatchUi.pushView(menu, new ProviderMenuDelegate(menu, null), WatchUi.SLIDE_LEFT);
    } else {
      var provider = currentProvider();
      showProviderActionMenu(provider);
    }
    return true;
  }
}

function isActionButton(button as WatchUi.Key) as Lang.Boolean {
  return Rez.Styles has :system_input__action_menu &&
    Rez.Styles.system_input__action_menu has :button &&
    button == Rez.Styles.system_input__action_menu.button;
}

//! Function to see if a tap falls within the touch area for
//! a action menu.
//! @param x X coord of tap
//! @param y Y coord of tap
//! @return true if tapped, false otherwise
// FIXME: tap on fenix8 not working like native (system_input__action_menu has no x1, y1, x2, y2)
function isInActionArea(coord as Array<Numeric>) as Boolean {
  if (Rez.Styles has :system_input__action_menu &&
      Rez.Styles.system_input__action_menu has :x1 &&
      Rez.Styles.system_input__action_menu has :y1 &&
      Rez.Styles.system_input__action_menu has :x2 &&
      Rez.Styles.system_input__action_menu has :y2) {

    var x = coord[0];
    var y = coord[1];

    if (x >= Rez.Styles.system_input__action_menu.x1 &&
        x <= Rez.Styles.system_input__action_menu.x2 &&
        y >= Rez.Styles.system_input__action_menu.y1 &&
        y <= Rez.Styles.system_input__action_menu.y2) {
      return true;
    }
  }
  return false;
}
