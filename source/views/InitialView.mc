using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;

var config;

class InitialView extends WatchUi.View {

	function initialize() {
		View.initialize();
		initializeConfig();
		//it's not possible to start the application with a picker view
		//and it's not possible to push a view during the initialization of an other view
	}

	function initializeConfig() {
		$.config = {:step => 0};
	}

	function onShow() {
		var step = $.config.get(:step);
		//when step is negative, close the application
		if(step == -1) {
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		}
		//when step is 3, start the match
		else if(step == 3) {
			//create match
			var type = $.config[:type];
			var sets_number = $.config[:sets_number];
			var player = $.config[:player];
			initializeConfig();

			var app = Application.getApp();
			var mp = app.getProperty("maximum_points");
			var amp = app.getProperty("absolute_maximum_points");

			$.match = new Match(type, sets_number, player, mp, amp);

			//go to match view
			WatchUi.switchToView(new MatchView(), new MatchViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		else {
			//choose appropricate view depending on current step
			var picker, delegate;
			if(step == 0) {
				picker = new TypePicker();
				delegate = new TypePickerDelegate();
			}
			else if(step == 1) {
				picker = new SetPicker();
				delegate = new SetPickerDelegate();
			}
			else {
				picker = new BeginnerPicker();
				delegate = new BeginnerPickerDelegate();
			}
			//this view is shown when application starts or when back is pressed on type picker view
			WatchUi.pushView(picker, delegate, WatchUi.SLIDE_IMMEDIATE);
		}
	}
}

class InitialViewDelegate extends WatchUi.BehaviorDelegate {

	function initialize(view) {
		BehaviorDelegate.initialize();
	}

	function onBack() {
		//pop the main view to close the application
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}