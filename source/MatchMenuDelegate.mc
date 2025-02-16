import Toybox.Lang;
import Toybox.WatchUi;

class MatchMenuDelegate extends WatchUi.Menu2InputDelegate {

	function initialize() {
		Menu2InputDelegate.initialize();
	}

	function onSelect(item as MenuItem) {
		var id = item.getId();
		var match = (Application.getApp() as BadmintonApp).getMatch() as Match;
		if(id == :menu_resume_match) {
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			//go back to the match screen
			var view = new MatchView(true);
			WatchUi.switchToView(view, new MatchViewDelegate(view), WatchUi.SLIDE_IMMEDIATE);
		}
		else if(id == :menu_end_match) {
			match.end(null);
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			//go to result screen
			WatchUi.switchToView(new ResultView(), new ResultViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		else if(id == :menu_reset_match) {
			match.discard();
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			//go to the initial screen
			WatchUi.switchToView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		else if(id == :menu_exit) {
			match.discard();
			//pop once to close the menu
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			//exit the app
			System.exit();
		}
	}
}
