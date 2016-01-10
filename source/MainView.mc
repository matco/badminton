using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class MainView extends Ui.View {

	//! Load your resources here
	function onLayout(dc) {
		//setLayout(Rez.Layouts.MainLayout(dc));
	}

	//! Restore the state of the app and prepare the view to be shown
	function onShow() {
	}

	function drawTypeScreen(dc) {
		setLayout(Rez.Layouts.type(dc));

		//call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
	}

	function drawBeginnerScreen(dc) {
		setLayout(Rez.Layouts.beginner(dc));

		//call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
	}

	function drawFinalScreen(dc, winner) {
		setLayout(Rez.Layouts.final(dc));

		//draw end of match text
		var wonText = Ui.loadResource(winner == :player_1 ? Rez.Strings.end_you_won : Rez.Strings.end_opponent_won);
		findDrawableById("final_won_text").setText(wonText);
		//draw score
		findDrawableById("final_score").setText(match.getScore(:player_1).toString() + " - " + match.getScore(:player_2).toString());
		//draw match time
		findDrawableById("final_time").setText(Helpers.formatDuration(match.getDuration()));
		//draw rallies
		var ralliesText = Ui.loadResource(Rez.Strings.end_total_rallies);
		findDrawableById("final_rallies").setText(Helpers.formatString(ralliesText, {"rallies" => match.getRalliesNumber().toString()}));

		//call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
	}

	function drawMatchScreen(dc) {
		var xCenter = dc.getWidth() / 2;
		var yCenter = dc.getHeight() / 2;

		var highlighted_corner_index = match.getHighlightedCorner();
		Sys.println("highlighted corner index " + highlighted_corner_index);
		//draw corner 0
		dc.setColor(highlighted_corner_index == 0 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon([[68,20], [xCenter - 2,20], [xCenter - 2,80], [50,80]]);
		//draw corner 1
		dc.setColor(highlighted_corner_index == 1 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon([[xCenter + 2,20], [152,20], [170,80], [xCenter + 2,80]]);
		//draw corner 2
		dc.setColor(highlighted_corner_index == 2 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon([[49,85], [xCenter - 2,85], [xCenter - 2,160], [30,160]]);
		//draw corner 3
		dc.setColor(highlighted_corner_index == 3 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon([[xCenter + 2,85], [171,85], [190,160], [xCenter + 2,160]]);

		//draw scores container
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		//player 1 (watch carrier)
		dc.fillRoundedRectangle(xCenter - 25, 94, 50, 58, 5);
		//player 2 (opponent)
		dc.fillRoundedRectangle(xCenter - 20, 29, 40, 42, 5);
		//draw scores
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		//player 1 (watch carrier)
		dc.drawText(xCenter, 89, Gfx.FONT_NUMBER_MEDIUM, match.getScore(:player_1).toString(), Gfx.TEXT_JUSTIFY_CENTER);
		//player 2 (opponent)
		dc.drawText(xCenter, 29, Gfx.FONT_NUMBER_MILD, match.getScore(:player_2).toString(), Gfx.TEXT_JUSTIFY_CENTER);

		//draw timer
		dc.drawText(xCenter, 170, Gfx.FONT_SMALL, Helpers.formatDuration(match.getDuration()), Gfx.TEXT_JUSTIFY_CENTER);
	}

	//! Update the view
	function onUpdate(dc) {
		if(!match.hasType()) {
			drawTypeScreen(dc);
		}
		else if(!match.hasBegun()) {
			drawBeginnerScreen(dc);
		}
		else {
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
			dc.clear();

			var winner = match.getWinner();
			if(winner != null) {
				drawFinalScreen(dc, winner);
			}
			else {
				drawMatchScreen(dc);
			}
		}
	}

	//! Called when this View is removed from the screen. Save the
	//! state of your app here.
	function onHide() {
	}

}

class MainViewDelegate extends Ui.BehaviorDelegate {

	function onMenu() {
		Ui.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), Ui.SLIDE_UP);
		return true;
	}

	function onKey(key) {
		Sys.println("on key " + key.getKey());
		if(key.getKey() == Ui.KEY_ENTER) {
			if(match.hasType()) {
				//random start
				if(!match.hasBegun()) {
					var beginner = Math.rand() % 2 == 0 ? :player_1 : :player_2;
					match.begin(beginner);
					Ui.requestUpdate();
					return true;
				}
				//restart game
				if(match.hasEnded()) {
					match.reset();
					Ui.requestUpdate();
					return true;
				}
			}
		}
		return false;
	}

	//player 2 (opponent) scores
	function onNextPage() {
		Sys.println("on next page");
		if(!match.hasEnded()) {
			//set match type to double
			if(!match.hasType()) {
				match.setType(:double);
			}
			//start match with player 1
			else if(!match.hasBegun()) {
				match.begin(:player_1);
			}
			//score with player 1
			else {
				match.score(:player_1);
			}
			Ui.requestUpdate();
			return true;
		}
		return false;
	}

	//player 1 (watch carrier) scores
	function onPreviousPage() {
		Sys.println("on previous page");
		if(!match.hasEnded()) {
			//set match type to single
			if(!match.hasType()) {
				match.setType(:single);
			}
			//start match with player 2
			else if(!match.hasBegun()) {
				match.begin(:player_2);
			}
			//score with player 2
			else {
				match.score(:player_2);
			}
			Ui.requestUpdate();
			return true;
		}
		return false;
	}

	//undo last point
	function onBack() {
		Sys.println("on back");
		if(match.hasType()) {
			//undo score
			if(match.getRalliesNumber() > 0) {
				match.undo();
			}
			//reset beginner
			else if(match.hasBegun()) {
				match.setBeginner(null);
			}
			//reset type
			else {
				match.setType(null);
			}
			Ui.requestUpdate();
			return true;
		}
		return false;
	}

}