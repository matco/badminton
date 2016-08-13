using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class TypeView extends Ui.View {

	function onLayout(dc) {
		setLayout(Rez.Layouts.type(dc));
	}
}

class TypeViewDelegate extends Ui.BehaviorDelegate {

	hidden var view;

	function initialize(view) {
		self.view = view;
	}

	function manageChoice(type) {
		var app = Application.getApp();
		var mp = app.getProperty("maximum_points");
		var amp = app.getProperty("absolute_maximum_points");

		$.match = new Match(type, mp, amp);
		$.match.listener = app;
		var view = new BeginnerView();
		Ui.switchToView(view, new BeginnerViewDelegate(view), Ui.SLIDE_IMMEDIATE);
	}

	function onNextPage() {
		//create double match
		manageChoice(:double);
		return true;
	}

	function onPreviousPage() {
		//create single match
		manageChoice(:single);
		return true;
	}

	function onTap(event) {
		var single = view.findDrawableById("type_single");
		var double = view.findDrawableById("type_double");
		var tapped = UIHelpers.findTappedDrawable(event, [single, double]);
		if(single.equals(tapped)) {
			manageChoice(:single);
		}
		else {
			manageChoice(:double);
		}
		return true;
	}

	function onBack() {
		Sys.exit();
	}
}