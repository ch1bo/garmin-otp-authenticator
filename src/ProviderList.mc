import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Render global _providers as a Menu2
class ProviderList extends WatchUi.Menu2 {
  var timer_;

  function initialize() {
    var h = System.getDeviceSettings().screenHeight;
    logf(DEBUG, "ProviderList initialize dc height $1$", [h]);
    WatchUi.Menu2.initialize({
      :title => "OTP Providers",
      :dividerType => DIVIDER_TYPE_ICON // Ignored on CIQ < 5.0.1
    });
    timer_ = new Timer.Timer();
  }

  function onHide() {
    log(DEBUG, "ProviderList onHide");
    WatchUi.Menu2.onHide();
    timer_.stop();
  }

  function onShow() {
    log(DEBUG, "ProviderList onShow");
    WatchUi.Menu2.onShow();
    // TODO: Test this
    if (canImportFromSettings()) {
      log(DEBUG, "ProviderList can import");
      askImportConfirmation();
    } else {
      log(DEBUG, "ProviderList creating menu items");
      for (var i = 0; i < _providers.size(); i++) {
        var p = _providers[i];
        p.update();
        // FIXME: check memory consumption on vivoactive3
        // addItem(new WatchUi.MenuItem(p.name_, p.code_, i, {}));
        addItem(new WatchUi.IconMenuItem(p.name_, p.code_, i, new ProviderIcon(p), {}));
      }
      addItem(new WatchUi.MenuItem("Configure", null, :configure, {}));

      var updateRate = Application.Properties.getValue("glanceRate");
      logf(DEBUG, "ProviderList update rate: $1$", [updateRate]);
      if (updateRate > 0) {
        var period = 60.0 / updateRate * 1000;
        timer_.start(method(:onTimer), period, true);
      }
    }
  }

  function onTimer() as Void {
    for (var i = 0; i < _providers.size(); i++) {
      var p = _providers[i];
      p.update();
      getItem(i).setSubLabel(p.code_);
    }
    WatchUi.requestUpdate();
  }
}

function loadProviderIcon(resourceId) {
  return new WatchUi.Bitmap({
    :rezId => resourceId,
    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
    :locY => WatchUi.LAYOUT_VALIGN_CENTER
  });
}

class ProviderIcon extends WatchUi.Drawable {
  var provider_ as Provider;

  // FIXME: too big for fenix7 and surely other devices
  // FIXME: icons for white background menus
  const ICON_TIME_BASED_GREEN = loadProviderIcon($.Rez.Drawables.TimeBasedGreen);
  const ICON_TIME_BASED_ORANGE = loadProviderIcon($.Rez.Drawables.TimeBasedOrange);
  const ICON_TIME_BASED_RED = loadProviderIcon($.Rez.Drawables.TimeBasedRed);
  const ICON_COUNTER_BASED = loadProviderIcon($.Rez.Drawables.CounterBased);
  const ICON_COUNTER_STEAM = loadProviderIcon($.Rez.Drawables.SteamGuard);

  function initialize(provider as Provider) {
    WatchUi.Drawable.initialize({});
    provider_ = provider;
  }

  function draw(dc) {
    logf(DEBUG, "ProviderIcon draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    // TODO: move icon selection into Provider class?
    switch (provider_) {
      case instanceof SteamGuardProvider:
        // TODO: colored steam icons
        ICON_COUNTER_STEAM.draw(dc);
        break;
      case instanceof TimeBasedProvider:
        var delta = (provider_ as TimeBasedProvider).next_ - Time.now().value();
        if (delta < 5) {
          ICON_TIME_BASED_RED.draw(dc);
        } else if (delta <= 10) {
          ICON_TIME_BASED_ORANGE.draw(dc);
        } else {
          ICON_TIME_BASED_GREEN.draw(dc);
        }
        break;
      case instanceof CounterBasedProvider:
        ICON_COUNTER_BASED.draw(dc);
        break;
    }
  }
}

class ProviderListDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    WatchUi.Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    switch (item.getId()) {
      case :configure:
        WatchUi.switchToView(new MainMenu(), new MainMenuDelegate(), WatchUi.SLIDE_LEFT);
        break;
      default:
        _currentIndex = item.getId();
        logf(DEBUG, "Setting current index $1$", [_currentIndex]);
        saveProviders();
        WatchUi.switchToView(new MainView(), new MainViewDelegate(), WatchUi.SLIDE_LEFT);
        break;
    }
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
