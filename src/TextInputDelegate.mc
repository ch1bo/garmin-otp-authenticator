using Toybox.WatchUi;
using Toybox.System;

class TextInputDelegate extends WatchUi.InputDelegate {

  var last_key_ = null;
  var view_;

  function initialize(view) {
    InputDelegate.initialize();
    view_ = view;
  }

  function onSwipe(evt) {
    var swipe = evt.getDirection();

    if (swipe == SWIPE_UP) {
      System.println("SWIPE_UP");
      view_.onUp();
    } else if (swipe == SWIPE_RIGHT) {
      System.println("SWIPE_RIGHT");
      view_.enter();
    } else if (swipe == SWIPE_DOWN) {
      System.println("SWIPE_DOWN");
      view_.onDown();
    } else if (swipe == SWIPE_LEFT) {
      System.println("SWIPE_LEFT");
      view_.backspace();
    }

    return true;
  }

  function onTap(event) {
    System.println("ON_TAP");
    view_.enter();
    return false;
  }

  function onKey(event) {
    var key = event.getKey();
    var str = getKeyString(key);
    if (str != null) {
      System.println(str);
    }
    switch (key) {
    case KEY_UP:
      view_.onUp();
      break;
    case KEY_DOWN:
      view_.onDown();
      break;
    case KEY_ENTER:
      if (last_key_ == KEY_ENTER) {
        System.exit();
      } else {
        view_.confirm(true);
      }
      break;
    case KEY_ESC:
      if (last_key_ == KEY_ESC) {
        System.exit();
      } else {
        view_.confirm(false);
      }
      break;
    }
    last_key_ = key;
    return true;
  }

  function getKeyString(key) {
    if (key == KEY_POWER) {
      return "KEY_POWER";
    } else if (key == KEY_LIGHT) {
      return "KEY_LIGHT";
    } else if (key == KEY_ZIN) {
      return "KEY_ZIN";
    } else if (key == KEY_ZOUT) {
      return "KEY_ZOUT";
    } else if (key == KEY_ENTER) {
      return "KEY_ENTER";
    } else if (key == KEY_ESC) {
      return "KEY_ESC";
    } else if (key == KEY_FIND) {
      return "KEY_FIND";
    } else if (key == KEY_MENU) {
      return "KEY_MENU";
    } else if (key == KEY_DOWN) {
      return "KEY_DOWN";
    } else if (key == KEY_DOWN_LEFT) {
      return "KEY_DOWN_LEFT";
    } else if (key == KEY_DOWN_RIGHT) {
      return "KEY_DOWN_RIGHT";
    } else if (key == KEY_LEFT) {
      return "KEY_LEFT";
    } else if (key == KEY_RIGHT) {
      return "KEY_RIGHT";
    } else if (key == KEY_UP) {
      return "KEY_UP";
    } else if (key == KEY_UP_LEFT) {
      return "KEY_UP_LEFT";
    } else if (key == KEY_UP_RIGHT) {
      return "KEY_UP_RIGHT";
    } else if (key == KEY_PAGE) {
      return "KEY_PAGE";
    } else if (key == KEY_START) {
      return "KEY_START";
    } else if (key == KEY_LAP) {
      return "KEY_LAP";
    } else if (key == KEY_RESET) {
      return "KEY_RESET";
    } else if (key == KEY_SPORT) {
      return "KEY_SPORT";
    } else if (key == KEY_CLOCK) {
      return "KEY_CLOCK";
    } else if (key == KEY_MODE) {
      return "KEY_MODE";
    }

    return null;
  }
}
