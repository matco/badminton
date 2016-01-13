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

	function onNextPage() {
		//set match type to double
		match.setType(:double);
		Ui.switchToView(new BeginnerView(), new BeginnerViewDelegate(), Ui.SWIPE_RIGHT);
		return true;
	}

	function onPreviousPage() {
		//set match type to single
		match.setType(:single);
		Ui.switchToView(new BeginnerView(), new BeginnerViewDelegate(), Ui.SWIPE_RIGHT);
		return true;
	}

}