import Toybox.Lang;
using Toybox.WatchUi;

class MenuDelegate extends WatchUi.MenuInputDelegate {

	function initialize() {
		MenuInputDelegate.initialize();
	}

	function onMenuItem(item) {
		if(item == :menu_end_game) {
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			var save_match_confirmation = new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.end_save_garmin_connect) as String);
			WatchUi.pushView(save_match_confirmation, new SaveMatchConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		else if(item == :menu_reset_game) {
			var match = (Application.getApp() as BadmintonScoreTrackerApp).getMatch();
			match.discard();
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			//return to type screen
			WatchUi.switchToView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
	}
}
