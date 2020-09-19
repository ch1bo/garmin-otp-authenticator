using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

using TextInput;

var _error = "";
var _errorTicks = 0;

function displayError(str) {
  _error = str;
  _errorTicks = 50; // ~ 5 sec with the 100ms refresh (see Timer below)
}

function clearError() {
  _error = "";
  _errorTicks = 0;
}

class MainView extends WatchUi.View {
  var timer_;
  function initialize() {
    View.initialize();
    timer_ = new Timer.Timer();
  }

  function onShow() { timer_.start(method( : update), 100, true); }

  function onHide() {
    timer_.stop();
  }

  function update() {
    var provider = currentProvider();
    try {
      if (provider != null) {
        provider.update();
      }
    } catch (exception) {
      var msg = exception.getErrorMessage();
      log(ERROR, msg);
      exception.printStackTrace();
      displayError(msg);
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
    if (_errorTicks > 0) {
      _errorTicks--;
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
      dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_SMALL,
                  _error,
                  Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }

  function drawAboveCode(dc, codeHeight, font, text) {
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
    var fh = dc.getFontHeight(font);
    dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - codeHeight / 2 - fh - 5,
                font, text, Graphics.TEXT_JUSTIFY_CENTER);
  }

  function drawCode(dc, codeColor, codeFont, code) {
    dc.setColor(codeColor, Graphics.COLOR_BLACK);
    dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, codeFont, code,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawBelowCode(dc, codeHeight, font, text) {
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
    dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + codeHeight / 2 + 10,
                font, text, Graphics.TEXT_JUSTIFY_CENTER);
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
      var menu = new WatchUi.Menu();
      menu.setTitle("OTP");
      for (var i = 0; i < _providers.size(); i++) {
        menu.addItem(_providers[i].name_, i);
      }
      menu.addItem("New entry", : new_entry);
      menu.addItem("Delete entry", : delete_entry);
      menu.addItem("Delete ALL", : delete_all);
      menu.addItem("Export", : export_providers);
      menu.addItem("Import", : import_providers);
      WatchUi.pushView(menu, new ProvidersMenuDelegate(), WatchUi.SLIDE_LEFT);
    }
  }
}

class ProvidersMenuDelegate extends WatchUi.MenuInputDelegate {
  function initialize() { MenuInputDelegate.initialize(); }
  function onMenuItem(item) {
    switch (item) {
    case:
    new_entry:
      var view = new TextInput.TextInputView("Enter name", Alphabet.ALPHANUM);
      WatchUi.switchToView(view, new NameInputDelegate(view),
                           WatchUi.SLIDE_LEFT);
      return;
    case:
    delete_entry:
      var menu = new WatchUi.Menu();
      menu.setTitle("Delete entry");
      for (var i = 0; i < _providers.size(); i++) {
        menu.addItem(_providers[i].name_, _providers[i]);
      }
      WatchUi.switchToView(menu, new DeleteMenuDelegate(), WatchUi.SLIDE_LEFT);
      return;
    case:
    delete_all:
      log(DEBUG, "TODO: Ask for confirmation");
      _providers = [];
      _currentIndex = 0;
      return;
    case:
    export_providers:
      exportToSettings();
      log(DEBUG, "TODO: Show instructions");
      return;
    case:
    import_providers:
      importFromSettings();
      saveProviders();
      log(DEBUG, "TODO: Show instructions");
      return;
    default:
      _currentIndex = item;
      saveProviders();
      clearError();
      WatchUi.requestUpdate();
    }
  }
}

class DeleteMenuDelegate extends WatchUi.MenuInputDelegate {
  function initialize() { MenuInputDelegate.initialize(); }
  function onMenuItem(item) {
    var provider = currentProvider();
    if (provider != null && provider == item) {
      _currentIndex = 0;
    }
    _providers.remove(item);
    saveProviders();
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
    menu.addItem("Time based", : time);
    menu.addItem("Counter based", : counter);
    menu.addItem("Steam guard", : steam);
    WatchUi.pushView(menu, new TypeMenuDelegate(), WatchUi.SLIDE_LEFT);
  }
}

class TypeMenuDelegate extends WatchUi.MenuInputDelegate {
  function initialize() { MenuInputDelegate.initialize(); }

  function onMenuItem(item) {
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
      clearError();
      saveProviders();
    }
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
