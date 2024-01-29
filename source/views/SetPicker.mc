import Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.Graphics;

class SetPicker extends WatchUi.Picker {

	function initialize() {
		var factory = new SetPickerFactory();

		var title = new WatchUi.Text({
			:text => WatchUi.loadResource(Rez.Strings.sets_number) as String,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
			:color => Graphics.COLOR_WHITE
		});

		var default_number_of_sets = Properties.getValue("default_match_number_of_sets") as Number;
		if(default_number_of_sets == null) {
			default_number_of_sets = 0;
		}

		Picker.initialize({
			:title => title,
			:pattern => [factory],
			:defaults => [default_number_of_sets]
		});
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		Picker.onUpdate(dc);
	}
}

class SetPickerDelegate extends WatchUi.PickerDelegate {

	function initialize() {
		PickerDelegate.initialize();
	}

	function onCancel() {
		InitialView.config.step--;
		//remove picker from view stack
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onAccept(values) {
		//update match configuration
		var value = values[0];
		if(value == :endless) {
			InitialView.config.sets = null;
		}
		else {
			InitialView.config.sets = value as Number;
		}
		InitialView.config.step++;
		//remove picker from view stack to go back to initial view
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
