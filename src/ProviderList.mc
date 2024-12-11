import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProviderList extends WatchUi.CustomMenu {
  function initialize(providers as Lang.Array<Provider>) {
    var h = System.getDeviceSettings().screenHeight;
    logf(DEBUG, "ProviderList initialize dc height $1$", [h]);
    // // TODO: Heights and locations taken from fenix847 simulator.json -> make this a device-specific drawable
    WatchUi.CustomMenu.initialize(h / 4, Graphics.COLOR_BLACK, {
      :title => new TitleDrawable("OTP Providers"),
      :titleItemHeight => (h * 0.3).toNumber(),
      :theme => WatchUi.MENU_THEME_BLUE, // XXX: CIQ >= 4.1.8
      :dividerType => DIVIDER_TYPE_ICON // XXX: CIQ >= 5.0.1
    });

    // FIXME: update entries continuously
    for (var i = 0; i < providers.size(); i++) {
      var p = providers[i];
      p.update();
      addItem(new ProviderMenuItem(i, p));
    }

    addItem(new ButtonMenuItem(:edit, "Edit"));
  }

  function onHide() {
    log(DEBUG, "ProviderList onHide");
    WatchUi.CustomMenu.onHide();
  }

  function onLayout(dc) {
    logf(DEBUG, "ProviderList onLayout $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    WatchUi.CustomMenu.onLayout(dc);
  }

  function onShow() {
    log(DEBUG, "ProviderList onShow");
    WatchUi.CustomMenu.onShow();
  }

  function drawTitle(dc) {
    logf(DEBUG, "ProviderList drawTitle $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    WatchUi.CustomMenu.drawTitle(dc);
  }

  function drawFooter(dc) {
    logf(DEBUG, "ProviderList drawFooter $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    WatchUi.CustomMenu.drawFooter(dc);
  }

  function drawForeground(dc) {
    logf(DEBUG, "ProviderList drawForeground $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    // NOTE: Using a layout to specify input hints to be able to use the
    // 'personality' builtin style
    // XXX: ordering of items in layout matters
    var menuHint = Rez.Layouts.ProviderList(dc)[0];
    menuHint.draw(dc);
  }
}

class TitleDrawable extends WatchUi.Drawable {
  var titleText_ as Drawable;
  var menuHeader_ as Bitmap;

  function initialize(title as String) {
    WatchUi.Drawable.initialize({});
    titleText_ = new WatchUi.Text({
      :text => title,
      :font => Graphics.FONT_AUX2, // TODO: CIQ >= 4.2.2
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
      :justification => Graphics.TEXT_JUSTIFY_VCENTER
    });
    menuHeader_ = new WatchUi.Bitmap({ :rezId =>Rez.Drawables.MenuHeaderBackground });
  }

  function draw(dc) {
    logf(DEBUG, "Fenix8Title draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    menuHeader_.draw(dc);
    titleText_.draw(dc);
  }
}

class ButtonMenuItem extends WatchUi.CustomMenuItem {
  var text_ as String;

  function initialize(identifier, text as String) {
    WatchUi.CustomMenuItem.initialize(identifier, {});

    // Disable divider symbol on CIQ >= 5.0.1
    setDividerIcon(null);

    text_ = text;
  }

  function draw(dc) {
    logf(DEBUG, "ButtonMenuItem draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    var w = dc.getWidth();
    var h = dc.getHeight();
    var xmargin = w / 4;
    var ymargin = h / 4;
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    if (isFocused()) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    }
    if (isSelected()) {
      dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    }
    dc.drawText(w / 2,
                h / 2,
                Graphics.FONT_AUX2, // TODO: CIQ >= 4.2.2
                text_,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    dc.setPenWidth(2);
    dc.drawRectangle(xmargin, ymargin, w - 2 * xmargin, h - 2 * ymargin);
  }
}

class ProviderListDelegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    WatchUi.Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    switch (item.getId()) {
      case :edit:
        log(INFO, "Edit button pressed");
        WatchUi.pushView(new MainMenu(), new MainMenuDelegate(), WatchUi.SLIDE_LEFT);
        break;
      default:
        break;
    }
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
