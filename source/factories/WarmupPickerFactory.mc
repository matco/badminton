import Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;

//do not use a confirmation (WatchUi.Confirmation) to stay consistent with other pickers
class WarmupPickerFactory extends WatchUi.PickerFactory {

	private const WARMUP as Array<Boolean> = [false, true] as Array<Boolean>;
	private const WARMUP_LABELS as Array<ResourceId> = [Rez.Strings.warmup_no, Rez.Strings.warmup_yes] as Array<ResourceId>;

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(WARMUP_LABELS[index]) as String,
			:color => Graphics.COLOR_WHITE,
			:font => Graphics.FONT_SMALL,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY => WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return WARMUP[index];
	}

	function getSize() as Number {
		return WARMUP.size();
	}
}
