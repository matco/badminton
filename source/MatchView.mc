using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

var need_full_update;

class MatchView extends Ui.View {


	//! Load your resources here
	function onLayout(dc) {
	}

	//! Restore the state of the app and prepare the view to be shown
	function onShow() {
		need_full_update = true;
	}

	function drawField(dc) {
		var x_center = dc.getWidth() / 2;

		var highlighted_corner = match.getHighlightedCorner();
		Sys.println("highlighted corner " + highlighted_corner);
		//draw corner 0
		dc.setColor(highlighted_corner == 0 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon([[68,20], [x_center - 2,20], [x_center - 2,80], [50,80]]);
		//draw corner 1
		dc.setColor(highlighted_corner == 1 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon([[x_center + 2,20], [152,20], [170,80], [x_center + 2,80]]);
		//draw corner 2
		dc.setColor(highlighted_corner == 2 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon([[49,85], [x_center - 2,85], [x_center - 2,160], [30,160]]);
		//draw corner 3
		dc.setColor(highlighted_corner == 3 ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon([[x_center + 2,85], [171,85], [190,160], [x_center + 2,160]]);

		//draw scores container
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		//player 1 (watch carrier)
		dc.fillRoundedRectangle(x_center - 25, 94, 50, 58, 5);
		//player 2 (opponent)
		dc.fillRoundedRectangle(x_center - 20, 29, 40, 42, 5);
		//draw scores
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		//player 1 (watch carrier)
		dc.drawText(x_center, 89, Gfx.FONT_NUMBER_MEDIUM, match.getScore(:player_1).toString(), Gfx.TEXT_JUSTIFY_CENTER);
		//player 2 (opponent)
		dc.drawText(x_center, 29, Gfx.FONT_NUMBER_MILD, match.getScore(:player_2).toString(), Gfx.TEXT_JUSTIFY_CENTER);

		//in double, draw a dot for the player 1 (watch carrier) position if his team is engaging
		if(match.getType() == :double) {
			var player_corner = match.getPlayerCorner();
			if(player_corner != null) {
				var x_position = player_corner == 2 ? 65 : x_center + 45;
				dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
				dc.fillCircle(x_position, 120, 7);
			}
		}

		//draw timer
		drawTimer(dc);
	}

	function drawTimer(dc) {
		var x_center = dc.getWidth() / 2;

		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x_center, 170, Gfx.FONT_SMALL, Helpers.formatDuration(match.getDuration()), Gfx.TEXT_JUSTIFY_CENTER);
	}

	//! Update the view
	function onUpdate(dc) {
		if(need_full_update) {
			//clean the entire screen
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
			dc.clear();
			drawField(dc);
			need_full_update = false;
		}
		else {
			//clean only the area of the timer
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
			dc.fillRectangle(0, 170, dc.getWidth(), 26);
			drawTimer(dc);
		}
	}

	//! Called when this View is removed from the screen. Save the
	//! state of your app here.
	function onHide() {
	}

}

class MatchViewDelegate extends Ui.BehaviorDelegate {

	function onMenu() {
		Ui.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), Ui.SLIDE_UP);
		return true;
	}

	function manageScore() {
		var winner = match.getWinner();
		if(winner != null) {
			Ui.switchToView(new ResultView(), new ResultViewDelegate(), Ui.SWIPE_RIGHT);
		}
		else {
			need_full_update = true;
			Ui.requestUpdate();
		}
	}

	//player 2 (opponent) scores
	function onNextPage() {
		//score with player 1
		match.score(:player_1);
		manageScore();
		return true;
	}

	//player 1 (watch carrier) scores
	function onPreviousPage() {
		//score with player 2
		match.score(:player_2);
		manageScore();
		return true;
	}

	//undo last point
	function onBack() {
		//undo score
		if(match.getRalliesNumber() > 0) {
			match.undo();
			need_full_update = true;
			Ui.requestUpdate();
		}
		else {
			Ui.switchToView(new BeginnerView(), new BeginnerViewDelegate(), Ui.SWIPE_LEFT);
		}
		return true;
	}

}