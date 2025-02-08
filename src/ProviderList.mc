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
    log(DEBUG, "ProviderList creating menu items");
    for (var i = 0; i < _providers.size(); i++) {
      var p = _providers[i];
      p.update();
      addItem(mkProviderListItem(p, i));
    }
    addItem(new WatchUi.MenuItem("Configure", null, :configure, {}));

    var updateRate = Application.Properties.getValue("glanceRate");
    logf(DEBUG, "ProviderList update rate: $1$", [updateRate]);
    if (updateRate > 0) {
      var period = 60.0 / updateRate * 1000;
      timer_.start(method(:onTimer), period, true);
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
        saveCurrentIndex();
        // Pop to hide menu and switch to replace main view
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        WatchUi.switchToView(new MainView(), new MainViewDelegate(), WatchUi.SLIDE_LEFT);
        break;
    }
  }
}
