using Toybox.Application;

var _providers = [];
var _currentIndex = 0;

function currentProvider() {
  if (_currentIndex >= 0 && _currentIndex < _providers.size()) {
    return _providers[_currentIndex];
  }
  return null;
}

class App extends Application.AppBase {

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    var providersCount = getProperty("providers");
    if (providersCount) {
      for (var i = 0; i < providersCount; i++) {
        var name = getProperty("providers_" + i.toString() + "_name");
        var key = getProperty("providers_" + i.toString() + "_key");
        var code = getProperty("providers_" + i.toString() + "_code");
        var counter = getProperty("providers_" + i.toString() + "_counter");
        var interval = getProperty("providers_" + i.toString() + "_interval");
        var p;
        if (counter != null) {
          p = new CounterBasedProvider(name, key, counter);
        } else {
          p = new TimeBasedProvider(name, key, interval);
        }
        p.code_ = code;
        _providers.add(p);
      }
    }
    var currentIndex = getProperty("currentIndex");
    if (currentIndex != null) {
      _currentIndex = currentIndex;
    }
  }

  function onStop(state) {
    setProperty("providers", _providers.size());
    for (var i = 0; i < _providers.size(); i++) {
      var p = _providers[i];
      setProperty("providers_" + i.toString() + "_name", p.name_);
      setProperty("providers_" + i.toString() + "_key", p.key_);
      setProperty("providers_" + i.toString() + "_code", p.code_);
      switch (p) {
      case instanceof CounterBasedProvider:
        setProperty("providers_" + i.toString() + "_counter", p.counter_);
        break;
      case instanceof TimeBasedProvider:
        setProperty("providers_" + i.toString() + "_interval", p.interval_);
        break;
      }
    }
    setProperty("currentIndex", _currentIndex);
  }

  function getInitialView() {
    return [new MainView(), new MainViewDelegate()];
  }
}
