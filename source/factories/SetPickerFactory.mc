import Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;

class SetPickerFactory extends WatchUi.PickerFactory {

	var sets as Array<Number or Symbol> = [1, 3, 5, :endless] as Array<Number or Symbol>;
	var sets_labels as Array<Symbol> = [Rez.Strings.set_1, Rez.Strings.set_3, Rez.Strings.set_5, Rez.Strings.set_endless] as Array<Symbol>;

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(sets_labels[index]) as String,
			:color => Graphics.COLOR_WHITE,
			:font=> Graphics.FONT_SMALL,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY=> WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return sets[index];
	}

	function getSize() {
		return sets.size();
	}
}
