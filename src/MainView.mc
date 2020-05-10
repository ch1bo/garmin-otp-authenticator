using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

using TextInput;

var _error = "";
var _errorTicks = 0;

function displayError(str) {
  _error = str;
  _errorTicks = 25;
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

  function onShow() {
    timer_.start(method(:update), 100, true);
  }

  function onHide() {
    timer_.stop();
  }

  function update() {
    var provider = currentProvider();
    try {
      if (provider != null && provider has :update &&
          !(provider instanceof CounterBasedProvider)) {
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
      dc.drawText(dc.getWidth()/2, dc.getHeight()/2,
                  Graphics.FONT_MEDIUM, "Tap to start",
                  Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      return;
    }
    // Use number font if possible
    var codeColor = Graphics.COLOR_WHITE;
    var codeFont = Graphics.FONT_NUMBER_HOT;
    var codeHeight = dc.getFontHeight(codeFont);
    // Note: This switch deliberately falls-through
    switch (provider) {
    case instanceof SteamGuardProvider:
      codeFont = Graphics.FONT_LARGE;
      codeHeight = dc.getFontHeight(codeFont);
    case instanceof TimeBasedProvider:
      // Countdown text
      var delta = provider.next_ - Time.now().value();
      dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK);
      dc.drawText(dc.getWidth()/2, dc.getHeight()/2 + codeHeight/2, Graphics.FONT_NUMBER_MILD,
                  delta, Graphics.TEXT_JUSTIFY_CENTER);
      // Colored OTP code depending on countdown
      if (delta > 15) {
        codeColor = Graphics.COLOR_GREEN;
      } else if (delta > 5) {
        codeColor = Graphics.COLOR_ORANGE;
      } else {
        codeColor = Graphics.COLOR_RED;
      }
    case instanceof CounterBasedProvider:
      // Provider text
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
      dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - codeHeight/2 - dc.getFontHeight(Graphics.FONT_MEDIUM),
                  Graphics.FONT_MEDIUM, provider.name_, Graphics.TEXT_JUSTIFY_CENTER);
      // OTP text
      dc.setColor(codeColor, Graphics.COLOR_BLACK);
      dc.drawText(dc.getWidth()/2, dc.getHeight()/2, codeFont,
                  provider.code_, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    if (_errorTicks > 0) {
      _errorTicks--;
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
      dc.drawText(dc.getWidth()/2, dc.getHeight()/2 + dc.getFontHeight(codeFont), Graphics.FONT_SMALL, _error,
                  Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }
}

class MainViewDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onKey(event) {
    var key = event.getKey();
    if (key == KEY_ENTER) {
      var provider = currentProvider();
      switch (provider) {
      case instanceof CounterBasedProvider:
        provider.update();
        WatchUi.requestUpdate();
        return;
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
      menu.setTitle("OTP Providers");
      for (var i = 0; i < _providers.size(); i++) {
        menu.addItem(_providers[i].name_, i);
      }
      menu.addItem("New entry", :new_entry);
      menu.addItem("Delete entry", :delete_entry);
      menu.addItem("Delete ALL", :delete_all);
      menu.addItem("Export", :export_providers);
      menu.addItem("Import", :import_providers);
      WatchUi.pushView(menu, new ProvidersMenuDelegate(), WatchUi.SLIDE_LEFT);
    }
  }
}

class ProvidersMenuDelegate extends WatchUi.MenuInputDelegate {
  function initialize() {
    MenuInputDelegate.initialize();
  }
  function onMenuItem(item) {
    switch(item) {
    case :new_entry:
      var view = new TextInput.TextInputView("Enter name", Alphabet.ALPHANUM);
      WatchUi.switchToView(view, new NameInputDelegate(view), WatchUi.SLIDE_LEFT);
      return;
    case :delete_entry:
      var menu = new WatchUi.Menu();
      menu.setTitle("Delete provider");
      for (var i = 0; i < _providers.size(); i++) {
        menu.addItem(_providers[i].name_, _providers[i]);
      }
      WatchUi.pushView(menu, new DeleteMenuDelegate(), WatchUi.SLIDE_LEFT);
      return;
    case :delete_all:
      log(DEBUG, "TODO: Ask for confirmation");
      _providers = [];
      _currentIndex = 0;
      return;
    case :export_providers:
      exportToSettings();
      log(DEBUG, "TODO: Show instructions");
      return;
    case :import_providers:
      importFromSettings();
      saveProviders();
      log(DEBUG, "TODO: Show instructions");
      return;
    default:
      _currentIndex = item;
      clearError();
      WatchUi.requestUpdate();
    }
  }
}

class DeleteMenuDelegate extends WatchUi.MenuInputDelegate {
  function initialize() {
    MenuInputDelegate.initialize();
  }
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
  function initialize(view) {
    TextInputDelegate.initialize(view);
  }
  function onTextEntered(text) {
    _enteredName = text;
    var view = new TextInput.TextInputView("Enter key (Base32)", Alphabet.BASE32);
    WatchUi.pushView(view, new KeyInputDelegate(view), WatchUi.SLIDE_LEFT);
  }
}

var _enteredKey = "";

class KeyInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) {
    TextInputDelegate.initialize(view);
  }
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
  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    var provider;
    switch(item) {
    case :time:
      provider = new TimeBasedProvider(_enteredName, _enteredKey, 30);
      break;
    case :counter:
      provider = new CounterBasedProvider(_enteredName, _enteredKey, 0);
      return;
    case :steam:
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
