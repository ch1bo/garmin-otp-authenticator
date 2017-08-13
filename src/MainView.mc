using Toybox.System;
using Toybox.WatchUi;

using TextInput;

var providers_ = ["first", "second", "third", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"];
var currentIndex_ = 0;

class MainView extends WatchUi.View {
  function initialize() {
    View.initialize();
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var provider = providers_[currentIndex_];
    dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_MEDIUM, provider, Graphics.TEXT_JUSTIFY_CENTER);
  }
}

class MainViewDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onSelect() {
    var menu = new WatchUi.Menu();
    menu.setTitle("OTP Providers");
    for (var i = 0; i < providers_.size(); i++) {
      menu.addItem(providers_[i], i);
    }
    menu.addItem("New entry", :new_entry);
    WatchUi.pushView(menu, new ProvidersMenuDelegate(), WatchUi.SLIDE_LEFT);
  }
}

class ProvidersMenuDelegate extends WatchUi.MenuInputDelegate {
  function initialize() {
    MenuInputDelegate.initialize();
  }
  function onMenuItem(item) {
    if (item == :new_entry) {
      var view = new TextInput.TextInputView(TextInput.ALPHA);
      WatchUi.switchToView(view, new NewEntryTextInputDelegate(view), WatchUi.SLIDE_RIGHT);
    } else {
      currentIndex_ = item;
      WatchUi.requestUpdate();
    }
  }
}

class NewEntryTextInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) {
    TextInputDelegate.initialize(view);
  }
  function onTextEntered(text) {
    providers_.add(text);
    currentIndex_ = providers_.size() - 1;
    WatchUi.requestUpdate();
  }
}
