using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class SetPickerFactory extends Ui.PickerFactory {

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new Ui.Text({
			:text => getValue(index).format("%d"),
			:color => Gfx.COLOR_WHITE,
			:font=> Gfx.FONT_NUMBER_MILD,
			:locX => Ui.LAYOUT_HALIGN_CENTER,
			:locY=> Ui.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return index * 2 + 1;
	}

	function getSize() {
		return 3;
	}

}
