using Toybox.Graphics;
using Toybox.WatchUi;

class BeginnerPickerFactory extends WatchUi.PickerFactory {

	var beginners = [YOU, OPPONENT];
	var beginners_label = [Rez.Strings.beginner_you, Rez.Strings.beginner_opponent];

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(beginners_label[index]),
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
