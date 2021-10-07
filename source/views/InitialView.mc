import Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Graphics;

class InitialView extends WatchUi.View {
	public static var config as MatchConfig;

	function initialize() {
		View.initialize();
		config = new MatchConfig();
		//it's not possible to start the application with a picker view
		//and it's not possible to push a view during the initialization of an other view
	}

	function onShow() {
		//when step is negative, config has been cancelled, close the application
		if(config.step == -1) {
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		}
		//if config is valid, start the match
		else if(config.isValid()) {
			var app = Application.getApp() as BadmintonScoreTrackerApp;

			//adjust match configuration with app configuration
			config.maximumPoints = app.getProperty("maximum_points");
			config.absoluteMaximumPoints = app.getProperty("absolute_maximum_points");

			//create match
			var match = new Match(config);
			app.setMatch(match);

			//prepare a new config
			config = new MatchConfig();

			//go to match view
			var view = new MatchView();
			WatchUi.switchToView(view, new MatchViewDelegate(view), WatchUi.SLIDE_IMMEDIATE);
		}
		else {
			//choose appropriate view depending on current step
			var picker, delegate;
			if(config.step == 0) {
				picker = new TypePicker();
				delegate = new TypePickerDelegate();
			}
			else if(config.step == 1) {
				picker = new SetPicker();
				delegate = new SetPickerDelegate();
			}
			else if(config.step == 2) {
				picker = new BeginnerPicker();
				delegate = new BeginnerPickerDelegate();
			}
			else {
				picker = new ServerPicker();
				delegate = new ServerPickerDelegate();
			}
			//this view is shown when application starts or when back is pressed on type picker view
			WatchUi.pushView(picker, delegate, WatchUi.SLIDE_IMMEDIATE);
		}
	}
}

class InitialViewDelegate extends WatchUi.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onBack() {
		//pop the main view to close the application
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
