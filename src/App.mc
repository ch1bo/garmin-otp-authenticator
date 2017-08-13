using Toybox.Application;

var gProviders = [];
var gCurrentIndex = 0;

class App extends Application.AppBase {

  function initialize() {
    AppBase.initialize();
  }

  function onStart(state) {
    var providers = getProperty("gProviders");
    if (providers != null) {
      gProviders = providers;
    }
    var currentIndex = getProperty("gCurrentIndex");
    if (currentIndex != null) {
      gCurrentIndex = currentIndex;
    }
  }

  function onStop(state) {
    setProperty("gProviders", gProviders);
    setProperty("gCurrentIndex", gCurrentIndex);
  }

  function getInitialView() {
    return [new MainView(), new MainViewDelegate()];
  }
}
