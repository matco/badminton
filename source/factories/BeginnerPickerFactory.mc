import Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;

class BeginnerPickerFactory extends WatchUi.PickerFactory {

	var beginners as Array<Player or Symbol> = [YOU, OPPONENT, :random] as Array<Player or Symbol>;
	var beginners_label as Array<Symbol> = [Rez.Strings.beginner_you, Rez.Strings.beginner_opponent, Rez.Strings.beginner_random] as Array<Symbol>;

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(beginners_label[index]) as String,
			:color => Graphics.COLOR_WHITE,
			:font=> Graphics.FONT_SMALL,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY=> WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return beginners[index];
	}

	function getSize() {
		return beginners.size();
	}
}
