using Toybox.System;
using Toybox.WatchUi;

using TextInput;

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
    switch (provider) {
    case instanceof TimeBasedProvider:
      try {
        if (provider.update()) {
          _error = "";
        }
      } catch (exception) {
        _error = exception.getErrorMessage();
      }
      break;
    }
    WatchUi.requestUpdate();
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();
    var provider = currentProvider();
    if (provider == null) {
      dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_MEDIUM,
                  "Tap to start", Graphics.TEXT_JUSTIFY_CENTER);
      return;
    }
    var codeFont = Graphics.FONT_NUMBER_HOT;
    var codeHeight = dc.getFontHeight(codeFont);
    var codeColor = Graphics.COLOR_WHITE;
    // Provider text
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
    dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - codeHeight, Graphics.FONT_MEDIUM,
                provider.name_, Graphics.TEXT_JUSTIFY_CENTER);
    switch (provider) {
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
      // OTP text
      dc.setColor(codeColor, Graphics.COLOR_BLACK);
      dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - codeHeight/2, codeFont,
                  provider.code_, Graphics.TEXT_JUSTIFY_CENTER);
    }
    if (_error.length() > 0) {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
      drawTextBox(dc, 0, dc.getHeight()/2 + dc.getFontHeight(codeFont),
                  dc.getWidth(), Graphics.FONT_SMALL, _error);
    }
  }

  function drawTextBox(dc, x, y, width, font, text) {
    var ts = wrapText(dc, width, font, text);
    for (var i = 0; i < ts.size(); i++) {
      dc.drawText(x, y + dc.getFontHeight(font)*i, font,
                  ts[i], Graphics.TEXT_JUSTIFY_LEFT);
    }
  }
}

function wrapText(dc, width, font, text) {
  var lines = [];
  var w = dc.getWidth();
  var cs = text.toCharArray();
  while (dc.getTextWidthInPixels(text, font) > w) {
    // white space wrap
    while (cs.size() > 0) {
      System.print("index of ' ': ");
      var lastWS = lastIndexOf(cs, ' ');
      System.println(lastWS);
      if (lastWS == -1) {
        break;
      }
      var t = text.substring(0, lastWS);
      if (dc.getTextWidthInPixels(t, font) < w) {
        lines.add(t);
        System.println("fits: " + t);
        text = text.substring(lastWS + 1, text.length());
        break;
      }
      cs = cs.slice(0, lastWS);
    }
  }
  lines.add(text);
  return lines;
}

function lastIndexOf(array, elem) {
  for (var i = array.size() - 1; i >= 0; i--) {
    if (array[i] == elem) {
      return i;
    }
  }
  return -1;
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
      var view = new TextInput.TextInputView("Enter name", TextInput.ALPHANUM);
      WatchUi.pushView(view, new NameInputDelegate(view), WatchUi.SLIDE_RIGHT);
    } else {
      var menu = new WatchUi.Menu();
      menu.setTitle("OTP Providers");
      for (var i = 0; i < _providers.size(); i++) {
        menu.addItem(_providers[i].name_, i);
      }
      menu.addItem("New entry", :new_entry);
      menu.addItem("Delete entry", :delete_entry);
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
      var view = new TextInput.TextInputView("Enter name", TextInput.ALPHANUM);
      WatchUi.pushView(view, new NameInputDelegate(view), WatchUi.SLIDE_LEFT);
      return;
    case :delete_entry:
      var menu = new WatchUi.Menu();
      menu.setTitle("Delete provider");
      for (var i = 0; i < _providers.size(); i++) {
        menu.addItem(_providers[i].name_, _providers[i]);
      }
      WatchUi.pushView(menu, new DeleteMenuDelegate(), WatchUi.SLIDE_LEFT);
      return;
    default:
      _currentIndex = item;
      _error = "";
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
  }
}

var _enteredName = "";

class NameInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) {
    TextInputDelegate.initialize(view);
  }
  function onTextEntered(text) {
    _enteredName = text;
    var view = new TextInput.TextInputView("Enter key (Base32)", TextInput.BASE32);
    WatchUi.pushView(view, new KeyInputDelegate(view), WatchUi.SLIDE_LEFT);
  }
}

class KeyInputDelegate extends TextInput.TextInputDelegate {
  function initialize(view) {
    TextInputDelegate.initialize(view);
  }
  function onTextEntered(text) {
    _providers.add(new TimeBasedProvider(_enteredName, text, 30));
    _currentIndex = _providers.size() - 1;
    _error = "";
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
    WatchUi.popView(WatchUi.SLIDE_RIGHT);
  }
}
