using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class TypeView extends Ui.View {

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.type(dc));
	}
}

class TypeViewDelegate extends Ui.BehaviorDelegate {

	hidden var view;

	function initialize(view) {
		BehaviorDelegate.initialize();
		self.view = view;
	}

	function manageChoice(type) {
		$.config = {:type => type};
		//do not switch to view because it will fails with a picker
		Ui.pushView(new SetPicker(), new SetPickerDelegate(), Ui.SLIDE_IMMEDIATE);
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
		//pop the main view to close the application
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
}