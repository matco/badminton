import Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

class BeginnerPicker extends WatchUi.Picker {

	function initialize() {
		var factory = new BeginnerPickerFactory();

		var title = new WatchUi.Text({
			:text => WatchUi.loadResource(Rez.Strings.beginner_who) as String,
			:locX => WatchUi.LAYOUT_HALIGN_CENTER,
			:locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
			:color => Graphics.COLOR_WHITE
		});

		Picker.initialize({
			:title => title,
			:pattern => [factory],
			:defaults => [0]
		});
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		Picker.onUpdate(dc);
	}
}

class BeginnerPickerDelegate extends WatchUi.PickerDelegate {
	private var view as InitialView;

	function initialize(view as InitialView) {
		PickerDelegate.initialize();
		self.view = view;
	}

	function onCancel() as Boolean {
		view.step--;
		//remove picker from the view stack
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onAccept(values) as Boolean {
		//update match configuration
		var value = values[0];
		if(value == :random) {
			var number = Math.rand();
			view.beginner = number % 2 == 0 ? USER : OPPONENT;
		}
		else {
			view.beginner = values[0] as Team;
		}
		view.step++;
		//remove picker from the view stack to go back to the initial view
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
