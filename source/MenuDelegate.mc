using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class ResetConfirmationDelegate extends Ui.ConfirmationDelegate {
	function onResponse(value) {
		if(value != 0) {
			match.reset();
			Ui.requestUpdate();
		}
	}
}

class MenuDelegate extends Ui.MenuInputDelegate {

	function onMenuItem(item) {
		if(item == :menu_reset_game) {
			//var reset_confirmation = new Ui.Confirmation("Are you sure you want to reset?");
			//Ui.pushView(reset_confirmation, new ResetConfirmationDelegate(), Ui.SLIDE_IMMEDIATE);
			Sys.println("reset app");
			Ui.switchToView(new TypeView(), new TypeViewDelegate(), Ui.SLIDE_IMMEDIATE);
		}
	}
}
