using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class TypePicker extends Ui.Picker {

	function initialize() {
		var factory = new TypePickerFactory();

		var title = new Ui.Text({
			:text => Ui.loadResource(Rez.Strings.type_what),
			:locX => Ui.LAYOUT_HALIGN_CENTER,
			:locY => Ui.LAYOUT_VALIGN_BOTTOM,
			:color => Gfx.COLOR_WHITE
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

class TypePickerDelegate extends Ui.PickerDelegate {

	function initialize() {
		PickerDelegate.initialize();
	}

	function onCancel() {
		$.config.put(:step, $.config.get(:step) - 1);
		//remove picker from view stack
		Ui.popView(Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function onAccept(values) {
		//update match configuration
		$.config.put(:type, values[0]);
		$.config.put(:step, $.config.get(:step) + 1);
		//remove picker from view stack to go back to initial view
		Ui.popView(Ui.SLIDE_IMMEDIATE);
		return true;
	}

}