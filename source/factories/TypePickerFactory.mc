import Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;

class TypePickerFactory extends WatchUi.PickerFactory {

	private const TYPES as Array<MatchType> = [SINGLE, DOUBLE] as Array<MatchType>;
	private const TYPES_LABELS as Array<ResourceId> = [Rez.Strings.type_single, Rez.Strings.type_double] as Array<ResourceId>;

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(TYPES_LABELS[index]) as String,
			:color => Graphics.COLOR_WHITE,
			:font => Graphics.FONT_SMALL,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY => WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return TYPES[index];
	}

	function getSize() as Number {
		return TYPES.size();
	}
}
