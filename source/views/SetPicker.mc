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

		var default_number_of_sets = Properties.getValue("default_match_number_of_sets") as Number?;
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
		var value = values[0];
		if(value == :endless) {
			view.config.sets = null;
		}
		else {
			view.config.sets = value as Number;
		}
		view.step++;
		//remove picker from the view stack to go back to the initial view
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
