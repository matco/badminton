using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class BeginnerPickerFactory extends Ui.PickerFactory {

	var beginners = [YOU, OPPONENT];
	var beginners_label = [Rez.Strings.beginner_you, Rez.Strings.beginner_opponent];

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new Ui.Text({
			:text => Ui.loadResource(beginners_label[index]),
			:color => Gfx.COLOR_WHITE,
			:font=> Gfx.FONT_SMALL,
			:locX => Ui.LAYOUT_HALIGN_CENTER,
			:locY=> Ui.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return beginners[index];
	}

	function getSize() {
		return beginners.size();
	}

}
