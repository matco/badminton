using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class MenuDelegate extends Ui.MenuInputDelegate {

	function initialize() {
		MenuInputDelegate.initialize();
	}

	function onMenuItem(item) {
		if(item == :menu_end_game) {
			//pop once to close the menu
			Ui.popView(Ui.SLIDE_IMMEDIATE);
			var save_match_confirmation = new Ui.Confirmation(Ui.loadResource(Rez.Strings.end_save_garmin_connect));
			Ui.pushView(save_match_confirmation, new SaveMatchConfirmationDelegate(), Ui.SLIDE_IMMEDIATE);
		}
		else if(item == :menu_reset_game) {
			$.match.discard();
			//pop once to close the menu
			Ui.popView(Ui.SLIDE_IMMEDIATE);
			//return to type screen
			var view = new InitialView();
			Ui.switchToView(view, new InitialViewDelegate(view), Ui.SLIDE_IMMEDIATE);
		}
	}
}
