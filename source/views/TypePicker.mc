using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

class TypePicker extends WatchUi.Picker {

	function initialize() {
		var factory = new TypePickerFactory();

		var title = new WatchUi.Text({
			:text => WatchUi.loadResource(Rez.Strings.type_what),
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
			:color => Graphics.COLOR_WHITE
		});

		var default_type = Application.getApp().getProperty("default_match_type");
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
		$.config.put(:type, values[0]);
		$.config.put(:step, $.config.get(:step) + 1);
		//remove picker from view stack to go back to initial view
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

}