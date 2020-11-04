using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class TypePickerFactory extends Ui.PickerFactory {

	var types = [:single, :double];
	var types_labels = [Rez.Strings.type_single, Rez.Strings.type_double];

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new Ui.Text({
			:text => Ui.loadResource(types_labels[index]),
			:color => Gfx.COLOR_WHITE,
			:font=> Gfx.FONT_MEDIUM,
			:locX => Ui.LAYOUT_HALIGN_CENTER,
			:locY=> Ui.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return types[index];
	}

	function getSize() {
		return types.size();
	}

}
