using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class TypeView extends Ui.View {

	//! Load your resources here
	function onLayout(dc) {
		setLayout(Rez.Layouts.type(dc));
	}

	//! Restore the state of the app and prepare the view to be shown
	function onShow() {
	}

	//! Called when this View is removed from the screen. Save the
	//! state of your app here.
	function onHide() {
	}

}

class TypeViewDelegate extends Ui.BehaviorDelegate {

	hidden var view;

	function initialize(view) {
		self.view = view;
	}

	function discardMatch() {
		if(match != null) {
			match.discard();
			match = null;
		}
	}

	function manageChoice(type) {
		discardMatch();
		match = new Match(type);
		match.listener = Application.getApp();
		var view = new BeginnerView();
		Ui.pushView(view, new BeginnerViewDelegate(view), Ui.SLIDE_IMMEDIATE);
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
		var single = view.findDrawableById("type_single");
		var double = view.findDrawableById("type_double");
		var tapped = UIHelpers.findTappedDrawable(event, [single, double]);
		if("type_single".equals(tapped.identifier)) {
			manageChoice(:single);
		}
		else {
			manageChoice(:double);
		}
		return true;
	}

	function onBack() {
		discardMatch();
		Sys.exit();
	}

}