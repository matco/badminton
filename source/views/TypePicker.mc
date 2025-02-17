import Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application.Properties;

class TypePicker extends WatchUi.Picker {

	function initialize() {
		var factory = new TypePickerFactory();

		var title = new WatchUi.Text({
			:text => WatchUi.loadResource(Rez.Strings.type_what) as String,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
			:color => Graphics.COLOR_WHITE
		});

		var default_type = Properties.getValue("default_match_type") as Number?;
		if(default_type == null) {
			default_type = 0;
		}

		Picker.initialize({
			:title => title,
			:pattern => [factory],
			:defaults => [default_type]
		});
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		Picker.onUpdate(dc);
	}
}

class TypePickerDelegate extends WatchUi.PickerDelegate {
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
		view.type = values[0] as MatchType;
		view.step++;
		//remove picker from the view stack to go back to the initial view
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
