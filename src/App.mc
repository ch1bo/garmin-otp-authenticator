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
        var counter = getProperty("providers_" + i.toString() + "_counter");
        _providers.add(new Provider(name, key, counter));
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
      setProperty("providers_" + i.toString() + "_name", _providers[i].name_);
      setProperty("providers_" + i.toString() + "_key", _providers[i].key_);
      setProperty("providers_" + i.toString() + "_counter", _providers[i].counter_);
    }
    setProperty("currentIndex", _currentIndex);
  }

  function getInitialView() {
    return [new MainView(), new MainViewDelegate()];
  }
}
