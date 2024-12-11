import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ProviderList extends WatchUi.CustomMenu {
  var providers_ as Lang.Array<Provider>;
  var timer_;

  function initialize(providers as Lang.Array<Provider>) {
    providers_ = providers;

    var h = System.getDeviceSettings().screenHeight;
    logf(DEBUG, "ProviderList initialize dc height $1$", [h]);
    // // TODO: Heights and locations taken from fenix847 simulator.json -> make this a device-specific drawable
    WatchUi.CustomMenu.initialize(h / 4, Graphics.COLOR_BLACK, {
      :title => new CustomTitle("OTP Providers"),
      :titleItemHeight => (h * 0.3).toNumber(),
      :theme => WatchUi.MENU_THEME_BLUE, // XXX: CIQ >= 4.1.8
      :footer => new CustomFooter()
    });
    for (var i = 0; i < providers.size(); i++) {
      addItem(new ProviderMenuItem(i, providers[i]));
    }
    addItem(new ButtonMenuItem(:edit, "Edit"));

    timer_ = new Timer.Timer();
    timer_.start(method(:updateProviders), 1000, true);
  }

  function updateProviders() as Void {
    for (var i = 0; i < providers_.size(); i++) {
      providers_[i].update();
    }
    WatchUi.requestUpdate();
  }

  function onHide() {
    log(DEBUG, "ProviderList onHide");
    WatchUi.CustomMenu.onHide();
    timer_.stop();
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

class CustomTitle extends WatchUi.Drawable {
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
    logf(DEBUG, "CustomTitle draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    menuHeader_.draw(dc);
    titleText_.draw(dc);
  }
}

class CustomFooter extends WatchUi.Drawable {
  var button_ as WatchUi.Button;
  var footerText_ as WatchUi.Text;

  function initialize() {
    WatchUi.Drawable.initialize({});

    button_ = new WatchUi.Button({
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
      :width => 100,
      :height => 50,
      :background => Graphics.COLOR_LT_GRAY,
      :stateDefault => Graphics.COLOR_RED,
      :stateHighlighted => Graphics.COLOR_WHITE,
      :stateSelected => Graphics.COLOR_BLUE,
      :stateDisabled => Graphics.COLOR_PURPLE,
      :behavior => :onSelect
    });

    footerText_ = new WatchUi.Text({
      :text => "Edit",
      :font => Graphics.FONT_AUX2, // TODO: CIQ >= 4.2.2
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
      :justification => Graphics.TEXT_JUSTIFY_VCENTER
    });
  }

  function onSelect() {
    log(DEBUG, "CustomFooter button pressed");
    footerText_.setColor(Graphics.COLOR_BLUE);
  }

  function draw(dc) {
    logf(DEBUG, "CustomFooter draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    button_.draw(dc);
    footerText_.draw(dc);
  }
}

class ButtonMenuItem extends WatchUi.CustomMenuItem {
  var text_ as String;

  function initialize(identifier, text as String) {
    WatchUi.CustomMenuItem.initialize(identifier, {});
    text_ = text;
  }

  function draw(dc) {
    logf(DEBUG, "ButtonMenuItem draw $1$ $2$", [dc.getWidth(), dc.getHeight()]);
    var w = dc.getWidth();
    var h = dc.getHeight();
    var xmargin = w / 10;
    var ymargin = h / 4;
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    if (isFocused()) {
      log(DEBUG, "ButtonMenuItem focused");
      dc.drawCircle(10, h / 2, 10);
      WatchUi.requestUpdate();
      dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    }
    // XXX: item stays selected after pressing once
    // if (isSelected()) {
    //   log(DEBUG, "ButtonMenuItem selected");
    //   dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
    // }
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
        _currentIndex = item.getId();
        logf(DEBUG, "Setting current index $1$", [_currentIndex]);
        saveProviders();
        WatchUi.pushView(new MainView(), new MainViewDelegate(), WatchUi.SLIDE_LEFT);
        break;
    }
  }

  function onFooter() {
    log(DEBUG, "onFooter");
    // WatchUi.pushView(new MainMenu(), new MainMenuDelegate(), WatchUi.SLIDE_LEFT);
  }

  function onBack() {
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
