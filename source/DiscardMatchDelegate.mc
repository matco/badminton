import Toybox.Lang;
import Toybox.WatchUi;

class DiscardMatchConfirmationDelegate extends WatchUi.ConfirmationDelegate {

	function initialize() {
		ConfirmationDelegate.initialize();
	}

	function redirectToInitialView() as Void {
		WatchUi.switchToView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
	}

	function onResponse(value) as Boolean {
		if(value == CONFIRM_YES) {
			var match = (Application.getApp() as BadmintonApp).getMatch() as Match;
			match.discard();
			//pop once to close the confirmation dialog
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			//BUG! it does not work to switch to another view here, as in a menu
			//see here https://forums.garmin.com/developer/connect-iq/f/discussion/361156/why-i-am-not-able-to-pushview-in-the-confirmation-delegate
			//the view will be popped after this method is executed (alongside the confirmation dialog)
			//the workaround is to push another instance of the same view onto the view stack
			//by pushing the same view, this other instance will be popped out but the real view will stay
			//by the way, not popping the configuration dialog does not help
			//in that case, the switch will work, displaying the wanted view
			//however the current view will not be removed from the stack
			//that means that if the user presses back in the destination view, he will return to the current view
			WatchUi.switchToView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
			WatchUi.pushView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		return true;
	}
}
