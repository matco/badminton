using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class MenuDelegate extends Ui.MenuInputDelegate {

	function initialize() {
		MenuInputDelegate.initialize();
	}

	function onMenuItem(item) {
		if(item == :menu_reset_game) {
			$.match.discard();
			//pop once to close the menu
			Ui.popView(Ui.SLIDE_IMMEDIATE);
			//return to type screen
			var view = new TypeView();
			Ui.switchToView(view, new TypeViewDelegate(view), Ui.SLIDE_IMMEDIATE);
		}
		else if(item == :menu_exit_app) {
			$.match.discard();
			//pop once to close the menu
			Ui.popView(Ui.SLIDE_IMMEDIATE);
			//pop again to close the main view hence closing the application
			Ui.popView(Ui.SLIDE_IMMEDIATE);
		}
	}
}
