import Toybox.Lang;
import Toybox.WatchUi;

class MatchMenuDelegate extends WatchUi.Menu2InputDelegate {

	function initialize() {
		Menu2InputDelegate.initialize();
	}

	function onSelect(item as MenuItem) {
		var id = item.getId();
		if(id == :menu_end_game) {
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			var save_match_confirmation = new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.end_save_garmin_connect) as String);
			WatchUi.pushView(save_match_confirmation, new SaveMatchConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		else if(id == :menu_reset_game) {
			var match = (Application.getApp() as BadmintonScoreTrackerApp).getMatch();
			match.discard();
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			//return to type screen
			WatchUi.switchToView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
	}
}
