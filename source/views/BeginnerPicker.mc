using Toybox.WatchUi;
using Toybox.Graphics;

class BeginnerPicker extends WatchUi.Picker {

	function initialize() {
		var factory = new BeginnerPickerFactory();

		var title = new WatchUi.Text({
			:text => WatchUi.loadResource(Rez.Strings.beginner_who),
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

class BeginnerPickerDelegate extends WatchUi.PickerDelegate {

	function initialize() {
		PickerDelegate.initialize();
	}

	function onCancel() {
		$.config.put(:step, $.config.get(:step) - 1);
		//remove picker from view stack
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onAccept(values) {
		//update match configuration
		$.config.put(:player, values[0]);
		$.config.put(:step, $.config.get(:step) + 1);
		//remove picker from view stack to go back to initial view
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

}