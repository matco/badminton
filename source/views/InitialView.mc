import Toybox.Lang;
using Toybox.Application.Properties;
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
			//adjust match configuration with app configuration
			config.maximumPoints = Properties.getValue("maximum_points") as Number;
			config.absoluteMaximumPoints = Properties.getValue("absolute_maximum_points") as Number;

			//create match
			var match = new Match(config, false);

			var app = Application.getApp() as BadmintonApp;
			app.setMatch(match);

			var warmup = config.warmup;

			//prepare a new config
			config = new MatchConfig();

			if(warmup) {
				//go to warmup view
				WatchUi.switchToView(new WarmupView(), new WarmupViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			else {
				//go to match view
				var view = new MatchView(false);
				WatchUi.switchToView(view, new MatchViewDelegate(view), WatchUi.SLIDE_IMMEDIATE);
			}
		}
		else {
			//choose appropriate view depending on current step
			var picker, delegate;
			if(config.step == 0) {
				picker = new TypePicker();
				delegate = new TypePickerDelegate();
			}
			else if(config.step == 1) {
				picker = new WarmupPicker();
				delegate = new WarmupPickerDelegate();
			}
			else if(config.step == 2) {
				picker = new SetPicker();
				delegate = new SetPickerDelegate();
			}
			else if(config.step == 3) {
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
		//pop the current view, which is necessarily a picker
		//this will discard the current picker, and display this view (that is under the picker in the view stack)
		//if the picker that was displayed is the first, the application will close itself (when the onShow is executed)
		//if another picker was displayed, the previous picker will be pushed onto the view stack
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
