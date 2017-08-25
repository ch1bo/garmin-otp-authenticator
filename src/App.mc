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
    var providers = getProperty("_providers");
    if (providers != null) {
      _providers = providers;
    }
    var currentIndex = getProperty("_currentIndex");
    if (currentIndex != null) {
      _currentIndex = currentIndex;
    }
  }

  function onStop(state) {
    setProperty("_providers", _providers);
    setProperty("_currentIndex", _currentIndex);
  }

  function getInitialView() {
    return [new MainView(), new MainViewDelegate()];
  }
}
