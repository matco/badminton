using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class MenuDelegate extends Ui.MenuInputDelegate {

	function onMenuItem(item) {
		if(item == :menu_reset_game) {
			Sys.println("reset app");
			Ui.switchToView(new TypeView(), new TypeViewDelegate(), Ui.SLIDE_IMMEDIATE);
		}
	}
}
