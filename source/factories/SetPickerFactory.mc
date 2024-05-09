import Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;

class SetPickerFactory extends WatchUi.PickerFactory {

	private const SETS as Array<Number or Symbol> = [1, 3, 5, :endless] as Array<Number or Symbol>;
	private const SETS_LABELS as Array<ResourceId> = [Rez.Strings.set_1, Rez.Strings.set_3, Rez.Strings.set_5, Rez.Strings.set_endless] as Array<ResourceId>;

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(SETS_LABELS[index]) as String,
			:color => Graphics.COLOR_WHITE,
			:font=> Graphics.FONT_SMALL,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY=> WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return SETS[index];
	}

	function getSize() {
		return SETS.size();
	}
}
