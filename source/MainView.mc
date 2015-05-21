using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class MainView extends Ui.View {

	//! Load your resources here
	function onLayout(dc) {
		setLayout(Rez.Layouts.MainLayout(dc));
	}

	//! Restore the state of the app and prepare the view to be shown
	function onShow() {
	}

	//! Update the view
	function onUpdate(dc) {
		var xCenter = dc.getWidth() / 2;
		var yCenter = dc.getHeight() / 2;

		if(!match.hasBegun()) {
			//update localized text
			findDrawableById("welcome_who_start_label").setText(Rez.Strings.welcome_who_start);
			findDrawableById("welcome_opponent_up_label").setText(Rez.Strings.welcome_opponent_up);
			findDrawableById("welcome_you_down_label").setText(Rez.Strings.welcome_you_down);
			findDrawableById("welcome_random_label").setText(Rez.Strings.welcome_random);
			//call the parent onUpdate function to redraw the layout
			View.onUpdate(dc);
			dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLUE);
			//player 1
			dc.fillPolygon([[0,yCenter], [10,yCenter - 10], [10,yCenter + 10]]);
			//player 2
			dc.fillPolygon([[15,165], [20,150], [30,170]]);
			//random
			dc.fillPolygon([[dc.getWidth() - 15,55], [dc.getWidth() - 30,55], [dc.getWidth() - 20,70]]);
		}
		else {
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
			dc.clear();

			var winner = match.getWinner();
			if(winner != null) {
				dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
				//draw end of match text
				var wonText = Ui.loadResource(winner == :player_1 ? Rez.Strings.end_you_won : Rez.Strings.end_opponent_won);
				dc.drawText(xCenter, yCenter - 60, Gfx.FONT_LARGE, wonText, Gfx.TEXT_JUSTIFY_CENTER);
				//draw score
				dc.drawText(xCenter, yCenter - 20, Gfx.FONT_LARGE, match.scores[:player_1].toString() + " - " + match.scores[:player_2].toString(), Gfx.TEXT_JUSTIFY_CENTER);
				//draw match time
				dc.drawText(xCenter, yCenter + 28, Gfx.FONT_SMALL, Helpers.formatDuration(match.getDuration()), Gfx.TEXT_JUSTIFY_CENTER);
				//draw strokes
				var strokesText = Ui.loadResource(Rez.Strings.end_total_strokes);
				dc.drawText(xCenter, yCenter + 52, Gfx.FONT_SMALL, Helpers.formatString(strokesText, {"strokes" => match.getStrokesNumber().toString()}), Gfx.TEXT_JUSTIFY_CENTER);
				return;
			}

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
			dc.drawText(xCenter, 89, Gfx.FONT_NUMBER_MEDIUM, match.scores[:player_1].toString(), Gfx.TEXT_JUSTIFY_CENTER);
			//player 2 (opponent)
			dc.drawText(xCenter, 29, Gfx.FONT_NUMBER_MILD, match.scores[:player_2].toString(), Gfx.TEXT_JUSTIFY_CENTER);

			//draw timer
			dc.drawText(xCenter, 170, Gfx.FONT_SMALL, Helpers.formatDuration(match.getDuration()), Gfx.TEXT_JUSTIFY_CENTER);
		}
	}

	//! Called when this View is removed from the screen. Save the
	//! state of your app here.
	function onHide() {
	}

}