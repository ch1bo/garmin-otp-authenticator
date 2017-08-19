using Toybox.System;
using Toybox.WatchUi;

using TextInput;

class MainView extends WatchUi.View {
  function initialize() {
    View.initialize();
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var text = "Tap to start";
    if (_providers.size() != 0) {
      text = _providers[_currentIndex].name_;
    }
    dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_MEDIUM, text, Graphics.TEXT_JUSTIFY_CENTER);
  }
}

class MainViewDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
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
      WatchUi.pushView(view, new NameInputDelegate(view), WatchUi.SLIDE_RIGHT);
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
    WatchUi.pushView(view, new KeyInputDelegate(view), WatchUi.SLIDE_RIGHT);
  }
}

class KeyInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) {
    TextInputDelegate.initialize(view);
  }
  function onTextEntered(text) {
    System.print("key: ");
    System.println(text);
    _providers.add(new Provider(_enteredName, text));
    _currentIndex = _providers.size() - 1;
    WatchUi.requestUpdate();
  }
}
