using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

var single = null;
var double = null;

class TypeView extends Ui.View {

	//! Load your resources here
	function onLayout(dc) {
		setLayout(Rez.Layouts.type(dc));
	}
	//! Restore the state of the app and prepare the view to be shown
	function onShow() {
		var single = view.findDrawableById("type_single");
		var double = view.findDrawableById("type_double");
	}

	function onHide() {
		single = null;
		double = null;
	}
}

class TypeViewDelegate extends Ui.BehaviorDelegate {

	function manageChoice(type) {
		var app = Application.getApp();
		var mp = app.getProperty("maximum_points");
		var amp = app.getProperty("absolute_maximum_points");

		match = new Match(type, mp, amp);
		match.listener = app;
		Ui.switchToView(new BeginnerView(), new BeginnerViewDelegate(), Ui.SLIDE_IMMEDIATE);
	}

	function onNextPage() {
		//create double match
		manageChoice(:double);
		return true;
	}

	function onPreviousPage() {
		//create single match
		manageChoice(:single);
		return true;
	}

	function onTap(event) {
		if (single == null || double == null) {
			return false;
		}

		var tapped = UIHelpers.findTappedDrawable(event, [single, double]);
		if(single.identifier == tapped.identifier) {
			manageChoice(:single);
		}
		else {
			manageChoice(:double);
		}
		return true;
	}

	function onBack() {
		Sys.exit();
	}

}
