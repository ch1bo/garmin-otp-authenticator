using Toybox.System;
using Toybox.WatchUi;

using TextInput;

class MainView extends WatchUi.View {
  var timer;

  function initialize() {
    View.initialize();
    timer = new Timer.Timer();
  }

  function onShow() {
    timer.start(method(:update), 100, true);
  }

  function onHide() {
    timer.stop();
  }

  function update() {
    var provider = currentProvider();
    switch (provider) {
    case instanceof TimeBasedProvider:
      provider.update();
      break;
    }
    WatchUi.requestUpdate();
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var provider = currentProvider();
    var font = Graphics.FONT_MEDIUM;
    var fh = dc.getFontHeight(font);
    dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - fh, font,
                provider ? provider.name_ : "Tap to start", Graphics.TEXT_JUSTIFY_CENTER);
    if (provider) {
      dc.drawText(dc.getWidth()/2, dc.getHeight()/2 + fh, font,
                  provider.code_, Graphics.TEXT_JUSTIFY_CENTER);
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
      var view = new TextInput.TextInputView("Enter name", TextInput.ALPHA);
      WatchUi.pushView(view, new NameInputDelegate(view), WatchUi.SLIDE_RIGHT);
    } else {
      var menu = new WatchUi.Menu();
      menu.setTitle("OTP Providers");
      for (var i = 0; i < _providers.size(); i++) {
        menu.addItem(_providers[i].name_, i);
      }
      menu.addItem("New entry", :new_entry);
      WatchUi.pushView(menu, new ProvidersMenuDelegate(), WatchUi.SLIDE_LEFT);
    }
  }
}

class ProvidersMenuDelegate extends WatchUi.MenuInputDelegate {
  function initialize() {
    MenuInputDelegate.initialize();
  }
  function onMenuItem(item) {
    if (item == :new_entry) {
      var view = new TextInput.TextInputView("Enter name", TextInput.ALPHA);
      WatchUi.pushView(view, new NameInputDelegate(view), WatchUi.SLIDE_LEFT);
      return;
    }
    _currentIndex = item;
    WatchUi.requestUpdate();
  }
}

var _enteredName = "";

class NameInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) {
    TextInputDelegate.initialize(view);
  }
  function onTextEntered(text) {
    System.print("name: ");
    System.println(text);
    _enteredName = text;
    var view = new TextInput.TextInputView("Enter key", TextInput.ALPHA);
    WatchUi.pushView(view, new KeyInputDelegate(view), WatchUi.SLIDE_LEFT);
  }
}

class KeyInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) {
    TextInputDelegate.initialize(view);
  }
  function onTextEntered(text) {
    System.print("key: ");
    System.println(text);
    _providers.add(new TimeBasedProvider(_enteredName, text, 30));
    _currentIndex = _providers.size() - 1;
    WatchUi.requestUpdate();
  }
}
