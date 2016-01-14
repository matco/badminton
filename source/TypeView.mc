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

	function manageChoice(type) {
		match = new Match(type);
		match.listener = Application.getApp();
		Ui.switchToView(new BeginnerView(), new BeginnerViewDelegate(), Ui.SWIPE_RIGHT);
	}

	function onNextPage() {
		manageChoice(:double);
		return true;
	}

	function onPreviousPage() {
		manageChoice(:single);
		return true;
	}

}