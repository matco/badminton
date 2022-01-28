using Toybox.Graphics;
using Toybox.WatchUi;

class ServerPickerFactory extends WatchUi.PickerFactory {

	var servers = [true, false];
	var servers_label = [Rez.Strings.server_you, Rez.Strings.server_teammate];

	function initialize() {
		PickerFactory.initialize();
	}

	function getDrawable(index, selected) {
		return new WatchUi.Text({
			:text => WatchUi.loadResource(servers_label[index]),
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
