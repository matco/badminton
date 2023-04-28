import Toybox.Lang;
import Toybox.WatchUi;

class MatchMenuDelegate extends WatchUi.Menu2InputDelegate {

	function initialize() {
		Menu2InputDelegate.initialize();
	}

	function onSelect(item as MenuItem) {
		var id = item.getId();
		var match = (Application.getApp() as BadmintonScoreTrackerApp).getMatch();
		if(id == :menu_end_game) {
			match.end(null);
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			//go to result screen
			WatchUi.switchToView(new ResultView(), new ResultViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		else if(id == :menu_reset_game) {
			match.discard();
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			//return to type screen
			WatchUi.switchToView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
	}
}
