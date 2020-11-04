using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class BeginnerPicker extends Ui.Picker {

	function initialize() {
		var factory = new BeginnerPickerFactory();

		var title = new Ui.Text({
			:text => Ui.loadResource(Rez.Strings.beginner_who),
			:locX => Ui.LAYOUT_HALIGN_CENTER,
			:locY => Ui.LAYOUT_VALIGN_BOTTOM,
			:color => Gfx.COLOR_WHITE
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

class BeginnerPickerDelegate extends Ui.PickerDelegate {

	function initialize() {
		PickerDelegate.initialize();
	}

	function onCancel() {
		$.config.put(:step, $.config.get(:step) - 1);
		//remove picker from view stack
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}

	function onAccept(values) {
		//update match configuration
		$.config.put(:player, values[0]);
		$.config.put(:step, $.config.get(:step) + 1);
		//remove picker from view stack to go back to initial view
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}

}