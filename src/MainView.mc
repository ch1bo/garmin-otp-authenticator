using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

using TextInput;

class MainView extends WatchUi.View {
  var timer_;
  var screen_shape_;

  function initialize() {
    View.initialize();
    screen_shape_ = System.getDeviceSettings().screenShape;
    timer_ = new Timer.Timer();
  }

  function onShow() { timer_.start(method( : update), 100, true); }

  function onHide() {
    timer_.stop();
  }

  function update() {
    var provider = currentProvider();
    if (provider != null) {
      provider.update();
    }
    WatchUi.requestUpdate();
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var provider = currentProvider();
    if (provider == null) {
      dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM,
                  "Tap to start",
                  Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      return;
    }
    // Use number font if possible
    var codeColor = Graphics.COLOR_WHITE;
    var codeFont = Graphics.FONT_NUMBER_HOT;
    var codeHeight = dc.getFontHeight(codeFont);
    switch (provider) {
    // NOTE(SN): This case deliberately falls-through
    case instanceof SteamGuardProvider:
      codeFont = Graphics.FONT_LARGE;
      codeHeight = dc.getFontHeight(codeFont);
    case instanceof TimeBasedProvider:
      // Provider name
      drawAboveCode(dc, codeHeight, Graphics.FONT_MEDIUM, provider.name_);
      // Colored OTP code depending on countdown
      var delta = provider.next_ - Time.now().value();
      if (delta > 15) {
        codeColor = Graphics.COLOR_GREEN;
      } else if (delta > 5) {
        codeColor = Graphics.COLOR_ORANGE;
      } else {
        codeColor = Graphics.COLOR_RED;
      }
      drawCode(dc, codeColor, codeFont, provider.code_);
      // Countdown text
      drawBelowCode(dc, codeHeight, Graphics.FONT_NUMBER_MILD, delta);
      drawProgress(dc, delta, 30, codeColor);
      break;
    case instanceof CounterBasedProvider:
      // Provider name
      drawAboveCode(dc, codeHeight, Graphics.FONT_MEDIUM, provider.name_);
      drawCode(dc, codeColor, codeFont, provider.code_);
      // Instructions
      drawBelowCode(dc, codeHeight, Graphics.FONT_SMALL,
                    "Press ENTER\nfor next code");
      break;
    }
  }

  function drawProgress(dc, value, max, codeColor) {
    dc.setPenWidth(dc.getHeight() / 40);
    dc.setColor(codeColor, Graphics.COLOR_TRANSPARENT);
    if (screen_shape_== System.SCREEN_SHAPE_ROUND) {
      // Available from 3.2.0
      if (dc has :setAntiAlias) {
        dc.setAntiAlias(true);
      }
      dc.drawArc(dc.getWidth() / 2, dc.getHeight() / 2, (dc.getWidth() / 2) - 2, Graphics.ARC_COUNTER_CLOCKWISE, 90, ((value * 360) / max) + 90);
      // Available from 3.2.0
      if (dc has :setAntiAlias) {
        dc.setAntiAlias(false);
      }
    } else {
      dc.fillRectangle(0, 0, ((value * dc.getWidth()) / max), dc.getHeight() / 40);
    }
  }

  function drawAboveCode(dc, codeHeight, font, text) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    var fh = dc.getFontHeight(font);
    dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - codeHeight / 2 - fh / 2,
                font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawCode(dc, codeColor, codeFont, code) {
    dc.setColor(codeColor, Graphics.COLOR_BLACK);
    dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, codeFont, code,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawBelowCode(dc, codeHeight, font, text) {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
    var fh = dc.getFontHeight(font);
    dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + codeHeight / 2 + fh / 2,
                font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }
}

class MainViewDelegate extends WatchUi.BehaviorDelegate {
  function initialize() { BehaviorDelegate.initialize(); }

  function onKey(event) {
    var key = event.getKey();
    if (key == KEY_MENU) {
      var provider = currentProvider();
      switch (provider) {
      case instanceof CounterBasedProvider:
        provider.next();
        WatchUi.requestUpdate();
        return true;
      }
    }
    BehaviorDelegate.onKey(event);
  }

  function onSelect() {
    if (_providers.size() == 0) {
      var view = new TextInput.TextInputView("Enter name", Alphabet.ALPHANUM);
      WatchUi.pushView(view, new NameInputDelegate(view), WatchUi.SLIDE_RIGHT);
    } else {
      var cur = currentProvider();
      var name = cur == null ? null : cur.name_;
      var menu = new Menu.MenuView({ :title => "OTP Authenticator" });
      menu.addItem(new Menu.MenuItem("Select entry", null, :select_entry, null));
      menu.addItem(new Menu.MenuItem("New entry", null, :new_entry, null));
      // menu.addItem(new Menu.MenuItem("Edit", name, :edit_current, null));
      menu.addItem(new Menu.MenuItem("Delete current", name, :delete_current, null));
      menu.addItem(new Menu.MenuItem("Delete all", null, :delete_all, null));
      menu.addItem(new Menu.MenuItem("Export", "to settings", :export_providers, null));
      menu.addItem(new Menu.MenuItem("Import", "from settings", :import_providers, null));
      WatchUi.pushView(menu, new MainMenuDelegate(), WatchUi.SLIDE_LEFT);
    }
  }
}

class MainMenuDelegate extends Menu.MenuDelegate {
  function initialize() { Menu.MenuDelegate.initialize(); }

  function onMenuItem(identifier) {
    switch (identifier) {
    case :select_entry:
      var selectMenu = new Menu.MenuView({ :title => "Select" });
      for (var i = 0; i < _providers.size(); i++) {
        selectMenu.addItem(new Menu.MenuItem(_providers[i].name_, null, i, null));
      }
      Menu.switchTo(selectMenu, new SelectMenuDelegate(), WatchUi.SLIDE_LEFT);
      return true; // don't pop view
    case :new_entry:
      var view = new TextInput.TextInputView("Enter name", Alphabet.ALPHANUM);
      WatchUi.switchToView(view, new NameInputDelegate(view), WatchUi.SLIDE_RIGHT);
      return true; // don't pop view
    case :delete_current:
      WatchUi.pushView(new WatchUi.Confirmation("Really delete?"),
                       new DeleteCurrentConfirmationDelegate(), WatchUi.SLIDE_LEFT);
      return true; // don't pop view
    case :delete_all:
      WatchUi.pushView(new WatchUi.Confirmation("Really delete?"),
                       new DeleteAllConfirmationDelegate(), WatchUi.SLIDE_LEFT);
      return true; // don't pop view
    case :export_providers:
      exportToSettings();
      break;
    case :import_providers:
      importFromSettings();
      saveProviders();
      break;
    }
    return false;
  }
}

class SelectMenuDelegate extends Menu.MenuDelegate {
  function initialize() { Menu.MenuDelegate.initialize(); }

  function onMenuItem(identifier) {
    selectProvider(identifier);
  }
}

class DeleteCurrentConfirmationDelegate extends WatchUi.ConfirmationDelegate {
  function initialize() { WatchUi.ConfirmationDelegate.initialize(); }

  function onResponse(response) {
    switch (response) {
      case WatchUi.CONFIRM_YES:
        deleteCurrentProvider();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        break;
      case WatchUi.CONFIRM_NO:
        break;
    }
  }
}

class DeleteAllConfirmationDelegate extends WatchUi.ConfirmationDelegate {
  function initialize() { WatchUi.ConfirmationDelegate.initialize(); }

  function onResponse(response) {
    switch (response) {
      case WatchUi.CONFIRM_YES:
        deleteAllProviders();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        break;
      case WatchUi.CONFIRM_NO:
        break;
    }
  }
}

// Name, key and type input view stack

var _enteredName = "";

class NameInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) { TextInputDelegate.initialize(view); }
  function onTextEntered(text) {
    _enteredName = text;
    var view = new TextInput.TextInputView("Enter key", Alphabet.BASE32);
    WatchUi.pushView(view, new KeyInputDelegate(view), WatchUi.SLIDE_LEFT);
  }
}

var _enteredKey = "";

class KeyInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) { TextInputDelegate.initialize(view); }
  function onTextEntered(text) {
    _enteredKey = text;

    var menu = new WatchUi.Menu();
    menu.setTitle("Select type");
    menu.addItem("Time based", :time);
    menu.addItem("Counter based", :counter);
    menu.addItem("Steam guard", :steam);
    WatchUi.pushView(menu, new TypeMenuDelegate(), WatchUi.SLIDE_LEFT);
  }
}

class TypeMenuDelegate extends WatchUi.MenuInputDelegate {
  function initialize() { MenuInputDelegate.initialize(); }

  function onMenuItem(item) {
    // NOTE(SN) When creating providers here, we rely on the fact, that any
    // input provided here (as it uses the Alphabet.BASE32) can be converted to
    // bytes without errors, i.e. base32ToBytes(_enteredKey) will not throw.
    // This is possible, because base32ToBytes also accepts empty strings or
    // strings only consisting of padding.
    var provider;
    switch (item) {
    case:
    time:
      provider = new TimeBasedProvider(_enteredName, _enteredKey, 30);
      break;
    case:
    counter:
      provider = new CounterBasedProvider(_enteredName, _enteredKey, 0);
      break;
    case:
    steam:
      provider = new SteamGuardProvider(_enteredName, _enteredKey, 30);
      break;
    }
    if (provider != null) {
      _providers.add(provider);
      _currentIndex = _providers.size() - 1;
      saveProviders();
    }
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
