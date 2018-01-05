using Toybox.Application;

var _providers = [];
var _currentIndex = 0;
var _error = "";

function currentProvider() {
  if (_currentIndex >= 0 && _currentIndex < _providers.size()) {
    return _providers[_currentIndex];
  }
  return null;
}

function loadProviders() {
  var ps = Application.Storage.getValue("providers");
  if (ps) {
    for (var i = 0; i < ps.size(); i++) {
      try {
        _providers.add(providerFromDict(ps[i]));
      } catch (exception) {
        _error = exception.getErrorMessage();
      }
    }
  }
  var ci = Application.Storage.getValue("currentIndex");
  if (ci != null) {
    _currentIndex = ci;
  }
}

function saveProviders() {
  var ps = new [_providers.size()];
  for (var i = 0; i < _providers.size(); i++) {
    ps[i] = providerToDict(_providers[i]);
  }
  Application.Storage.setValue("providers", ps);
  Application.Storage.setValue("currentIndex", _currentIndex);
}

class App extends Application.AppBase {

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    loadProviders();
  }

  function onStop(state) {
    saveProviders();
  }

  function getInitialView() {
    return [new MainView(), new MainViewDelegate()];
  }
}
