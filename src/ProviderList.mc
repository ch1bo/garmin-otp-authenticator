import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProviderListView extends WatchUi.CustomMenu {
  function initialize(providers as Lang.Array<Provider>) {
    var h = System.getDeviceSettings().screenHeight;
    logf(DEBUG, "dc height $1$", [h]);
    WatchUi.CustomMenu.initialize(h / 3, Graphics.COLOR_BLACK, {
      :title => new WatchUi.Text({
        :text => "Select",
        :locX => WatchUi.LAYOUT_HALIGN_CENTER,
        :locY => WatchUi.LAYOUT_VALIGN_CENTER
      }),
      :theme => WatchUi.MENU_THEME_DEFAULT
    });
    for (var i = 0; i < providers.size(); i++) {
      var p = providers[i];
      p.update();
      self.addItem(new WatchUi.CustomMenuItem(i, {
        :drawable => new CustomEntryDrawable(p)
      }));
    }
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
}
