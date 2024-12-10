import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProviderListView extends WatchUi.CustomMenu {
  function initialize(providers as Lang.Array<Provider>) {
    var h = System.getDeviceSettings().screenHeight;
    logf(DEBUG, "ProviderListView initialize dc height $1$", [h]);
    // TODO: switch for CIQ < 3.4 and/or use layout?
    var title = new WatchUi.TextArea({
      :text => "OTP Providers",
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER
    });
    WatchUi.CustomMenu.initialize(h / 3, Graphics.COLOR_BLACK, {
      :title => title,
      :theme => WatchUi.MENU_THEME_DEFAULT
    });

    // FIXME: update entries continuously
    for (var i = 0; i < providers.size(); i++) {
      var p = providers[i];
      p.update();
      self.addItem(new WatchUi.CustomMenuItem(i, { :drawable => new CustomEntryDrawable(p) }));
    }
  }

  // function onLayout(dc) {
  //   log(DEBUG, "onLayout");
  //   WatchUi.CustomMenu.onLayout(dc);
  //   var layout = Rez.Layouts.ProviderList(dc);
  //   logf(DEBUG, "layout $1$", [layout]);
  //   setLayout(layout);
  // }

  function drawForeground(dc) {
    log(DEBUG, "drawForeground");
    // NOTE: Using a layout to specify input hints to be able to use the
    // 'personality' builtin style
    // XXX: ordering of items in layout matters
    var inputHint = Rez.Layouts.ProviderList(dc)[0];
    inputHint.draw(dc);
  }
}

class ProviderListDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    WatchUi.Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    _currentIndex = item.getId();
    logf(DEBUG, "setting current index $1$", [_currentIndex]);
    saveProviders();
  }

  function onBack() {
    log(DEBUG, "onBack");
  }

  function onKey(event) {
    logf(DEBUG, "onKey $1$", [event]);
    return false;
  }

  function onTap(event) {
    logf(DEBUG, "onTap $1$", [event]);
    return false;
  }
}
