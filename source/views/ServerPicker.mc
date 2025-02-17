import Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Graphics;

class ServerPicker extends WatchUi.Picker {

	function initialize() {
		var factory = new ServerPickerFactory();

		var title = new WatchUi.Text({
			:text => WatchUi.loadResource(Rez.Strings.server_who) as String,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
			:color => Graphics.COLOR_WHITE
		});

		Picker.initialize({
			:title => title,
			:pattern => [factory],
			:defaults => [0]
		});
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		Picker.onUpdate(dc);
	}
}

class ServerPickerDelegate extends WatchUi.PickerDelegate {
	private var view as InitialView;

	function initialize(view as InitialView) {
		PickerDelegate.initialize();
		self.view = view;
	}

	function onCancel() {
		view.step--;
		//remove picker from the view stack
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onAccept(values) {
		//update match configuration
		view.server = values[0] as Boolean;
		view.step++;
		//remove picker from the view stack to go back to the initial view
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
