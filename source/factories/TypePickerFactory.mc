using Toybox.Graphics;
using Toybox.WatchUi;

class TypePickerFactory extends WatchUi.PickerFactory {

	var types = [SINGLE, DOUBLE];
	var types_labels = [Rez.Strings.type_single, Rez.Strings.type_double];

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(types_labels[index]),
			:color => Graphics.COLOR_WHITE,
			:font=> Graphics.FONT_SMALL,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY=> WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return types[index];
	}

	function getSize() {
		return types.size();
	}

}
