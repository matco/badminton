using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class SetPicker extends Ui.Picker {

	function initialize() {
		var factory = new SetPickerFactory();

		var title = new Ui.Text({
			:text => Ui.loadResource(Rez.Strings.sets_number),
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

class SetPickerDelegate extends Ui.PickerDelegate {

	function initialize() {
		PickerDelegate.initialize();
	}

	function onCancel() {
		//remove picker from view stack
		Ui.popView(Ui.SLIDE_IMMEDIATE);
		//var view = new TypeView();
		//Ui.switchToView(view, new TypeViewDelegate(view), Ui.SLIDE_IMMEDIATE);
	}

	function onAccept(values) {
		//configure match and go to next view
		$.config[:sets_number] = values[0];
		//remove picker from view stack before going to next one
		//Ui.popView(Ui.SLIDE_IMMEDIATE);
		var view = new BeginnerView();
		Ui.switchToView(view, new BeginnerViewDelegate(view), Ui.SLIDE_IMMEDIATE);
	}

}