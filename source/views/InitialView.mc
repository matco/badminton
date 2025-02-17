import Toybox.Lang;
using Toybox.Application.Properties;
using Toybox.WatchUi;
using Toybox.Graphics;

class InitialView extends WatchUi.View {
	public var config as MatchConfig;
	public var step as Number;

	function initialize() {
		View.initialize();
		config = new MatchConfig();
		step = 0;
		//it's not possible to start the application with a picker view
		//and it's not possible to push a view during the initialization of an other view
	}

	function isConfigValid() as Boolean {
		return config.type == SINGLE && step == 4 || step == 5;
	}

	function onShow() {
		//when step is negative, config has been cancelled, close the application
		if(step == -1) {
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		}
		//if config is valid, start the match
		else if(isConfigValid()) {
			//adjust match configuration with app configuration
			config.maximumPoints = Properties.getValue("maximum_points") as Number;
			config.absoluteMaximumPoints = Properties.getValue("absolute_maximum_points") as Number;

			//create match
			var match = new Match(config);

			var app = Application.getApp() as BadmintonApp;
			app.setMatch(match);

			var warmup = config.warmup;

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
			if(step == 0) {
				picker = new TypePicker();
				delegate = new TypePickerDelegate(self);
			}
			else if(step == 1) {
				picker = new WarmupPicker();
				delegate = new WarmupPickerDelegate(self);
			}
			else if(step == 2) {
				picker = new SetPicker();
				delegate = new SetPickerDelegate(self);
			}
			else if(step == 3) {
				picker = new BeginnerPicker();
				delegate = new BeginnerPickerDelegate(self);
			}
			else {
				picker = new ServerPicker();
				delegate = new ServerPickerDelegate(self);
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
