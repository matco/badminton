import Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;

class BeginnerPickerFactory extends WatchUi.PickerFactory {

	private const BEGINNERS as Array<Player or Symbol> = [YOU, OPPONENT, :random] as Array<Player or Symbol>;
	private const BEGINNERS_LABELS as Array<ResourceId> = [Rez.Strings.beginner_you, Rez.Strings.beginner_opponent, Rez.Strings.beginner_random] as Array<ResourceId>;

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(BEGINNERS_LABELS[index]) as String,
			:color => Graphics.COLOR_WHITE,
			:font=> Graphics.FONT_SMALL,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY=> WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return BEGINNERS[index];
	}

	function getSize() {
		return BEGINNERS.size();
	}
}
