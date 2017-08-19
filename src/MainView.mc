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
    if (gProviders.size() != 0) {
      text = gProviders[gCurrentIndex];
    }
    dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_MEDIUM, text, Graphics.TEXT_JUSTIFY_CENTER);
  }
}

class MainViewDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onSelect() {
    if (gProviders.size() == 0) {
      var view = new TextInput.TextInputView("Provider name", TextInput.ALPHA);
      WatchUi.pushView(view, new NameInputDelegate(view), WatchUi.SLIDE_RIGHT);
    } else {
      var menu = new WatchUi.Menu();
      menu.setTitle("OTP Providers");
      for (var i = 0; i < gProviders.size(); i++) {
        menu.addItem(gProviders[i], i);
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
      var view = new TextInput.TextInputView("Name", TextInput.ALPHA);
      WatchUi.pushView(view, new NameInputDelegate(view), WatchUi.SLIDE_RIGHT);
      return;
    }
    gCurrentIndex = item;
    WatchUi.requestUpdate();
  }
}

class NewEntryTextInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) {
    TextInputDelegate.initialize(view);
  }
  function onTextEntered(text) {
    gProviders.add(text);
    gCurrentIndex = gProviders.size() - 1;
    WatchUi.requestUpdate();
  }
}
