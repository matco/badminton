using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class MenuDelegate extends Ui.MenuInputDelegate {

	function initialize() {
		MenuInputDelegate.initialize();
	}

	function onMenuItem(item) {
		if(item == :menu_reset_game) {
			//return to type screen
			var view = new TypeView();
			Ui.switchToView(view, new TypeViewDelegate(view), Ui.SLIDE_IMMEDIATE);
		}
		else if(item == :menu_exit_app) {
			Ui.popView(Ui.SLIDE_IMMEDIATE);
		}
	}
}
