using Toybox.Graphics;
using Toybox.WatchUi;

class SetPickerFactory extends WatchUi.PickerFactory {

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => getValue(index).format("%d"),
			:color => Graphics.COLOR_WHITE,
			:font=> Graphics.FONT_NUMBER_MILD,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY=> WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return index * 2 + 1;
	}

	function getSize() {
		return 3;
	}
}
