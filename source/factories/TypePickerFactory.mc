import Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;

class TypePickerFactory extends WatchUi.PickerFactory {

	var types as Array<MatchType> = [SINGLE, DOUBLE] as Array<MatchType>;
	var types_labels as Array<Symbol> = [Rez.Strings.type_single, Rez.Strings.type_double] as Array<Symbol>;

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(types_labels[index]) as String,
			:color => Graphics.COLOR_WHITE,
			:font=> Graphics.FONT_SMALL,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY=> WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return types[index];
	}

	function getSize() as Number {
		return types.size();
	}
}
