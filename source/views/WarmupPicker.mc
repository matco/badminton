import Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application.Properties;

class WarmupPicker extends WatchUi.Picker {

	function initialize() {
		var factory = new WarmupPickerFactory();

		var title = new WatchUi.Text({
			:text => WatchUi.loadResource(Rez.Strings.warmup_confirmation) as String,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
			:color => Graphics.COLOR_WHITE
		});

		var default_warmup_settings = Properties.getValue("default_match_warmup") as Boolean?;
		if(default_warmup_settings == null) {
			default_warmup_settings = false;
		}

		Picker.initialize({
			:title => title,
			:pattern => [factory],
			:defaults => [default_warmup_settings ? 1 : 0]
		});
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		Picker.onUpdate(dc);
	}
}

class WarmupPickerDelegate extends WatchUi.PickerDelegate {
	private var view as InitialView;

	function initialize(view as InitialView) {
		PickerDelegate.initialize();
		self.view = view;
	}

	function onCancel() {
		view.step--;
		//remove picker from the view stack
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onAccept(values) {
		//update match configuration
		view.warmup = values[0] as Boolean;
		view.step++;
		//remove picker from the view stack to go back to the initial view
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
