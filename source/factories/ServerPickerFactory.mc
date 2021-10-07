import Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;

class ServerPickerFactory extends WatchUi.PickerFactory {

	var servers as Array<Boolean> = [true, false] as Array<Boolean>;
	var servers_label as Array<Symbol> = [Rez.Strings.server_you, Rez.Strings.server_teammate] as Array<Symbol>;

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(servers_label[index]) as String,
			:color => Graphics.COLOR_WHITE,
			:font=> Graphics.FONT_SMALL,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY=> WatchUi.LAYOUT_VALIGN_CENTER
		});
	}

	function getValue(index) {
		return servers[index];
	}

	function getSize() {
		return servers.size();
	}
}
