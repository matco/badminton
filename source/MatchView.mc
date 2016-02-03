using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

var boundaries;
var need_full_update;

class MatchView extends Ui.View {

	const MARGIN_TOP = 20;
	const MARGIN_BOTTOM = 50;
	const MARGIN_SIDE = 16;

	const FIELD_RATIO = 0.4;
	const FIELD_PADDING = 2;
	const FIELD_SCORE_RATIO = 0.7;

	const FIELD_SCORE_WIDTH_PLAYER_1 = 50;
	const FIELD_SCORE_WIDTH_PLAYER_2 = 40;

	hidden var timer;

	//! Load your resources here
	function onLayout(dc) {
		timer = new Timer.Timer();
		boundaries = getFieldBoundaries();
	}

	//! Restore the state of the app and prepare the view to be shown
	function onShow() {
		timer.start(method(:onTimer), 1000, true);

		need_full_update = true;
	}

	//! Called when this View is removed from the screen. Save the
	//! state of your app here.
	function onHide() {
		timer.stop();
	}

	function onTimer() {
		Ui.requestUpdate();
	}

	function getFieldBoundaries() {
		var radius = device.screenWidth / 2;
		var x_center = radius;
		var y_bottom = device.screenHeight - MARGIN_BOTTOM;
		var y_middle = Geometry.middle(y_bottom, MARGIN_TOP, FIELD_RATIO);
		//calculate half width of the top of the field
		var half_width_top = Geometry.chordLength(radius, MARGIN_TOP) / 2 - MARGIN_SIDE;
		//calculate half width of the base of the field
		var half_width_bottom = Geometry.chordLength(radius, MARGIN_BOTTOM) / 2 - MARGIN_SIDE;
		//calculate half width of the middle of the field
		var half_width_middle = Geometry.middle(half_width_bottom, half_width_top, FIELD_RATIO);
		//calculate score position
		var score_2_container_y = Geometry.middle(y_middle, MARGIN_TOP, (1 - FIELD_SCORE_RATIO) / 2);
		var score_2_container_height = (y_middle - MARGIN_TOP) * FIELD_SCORE_RATIO;
		var score_1_container_y = Geometry.middle(y_bottom, y_middle, (1 - FIELD_SCORE_RATIO) / 2);
		var score_1_container_height = (y_bottom - y_middle) * FIELD_SCORE_RATIO;
		return {
			"x_center" => x_center,
			"y_middle" => y_middle,
			"y_bottom" => y_bottom,
			"corners" => [
				[[x_center - half_width_top, MARGIN_TOP], [x_center - FIELD_PADDING, MARGIN_TOP], [x_center - FIELD_PADDING, y_middle - FIELD_PADDING], [x_center - half_width_middle, y_middle - FIELD_PADDING]],
				[[x_center + FIELD_PADDING, MARGIN_TOP], [x_center + half_width_top, MARGIN_TOP], [x_center + half_width_middle, y_middle - FIELD_PADDING], [x_center + FIELD_PADDING, y_middle - FIELD_PADDING]],
				[[x_center - half_width_middle, y_middle + FIELD_PADDING], [x_center - FIELD_PADDING, y_middle + FIELD_PADDING], [x_center - FIELD_PADDING, y_bottom, y_middle - FIELD_PADDING], [x_center - half_width_bottom, y_bottom]],
				[[x_center + FIELD_PADDING, y_middle + FIELD_PADDING], [x_center + half_width_middle, y_middle + FIELD_PADDING], [x_center + half_width_bottom, y_bottom], [x_center + FIELD_PADDING, y_bottom]]
			],
			"score_2_container_y" => score_2_container_y,
			"score_2_container_height" => score_2_container_height,
			"score_2_y" => (score_2_container_y + score_2_container_height / 2 - Gfx.getFontHeight(Gfx.FONT_NUMBER_MILD) / 2 - 4),
			"score_1_container_y" => score_1_container_y,
			"score_1_container_height" => score_1_container_height,
			"score_1_y" => (score_1_container_y + score_1_container_height / 2 - Gfx.getFontHeight(Gfx.FONT_NUMBER_MEDIUM) / 2 - 4)
		};
	}

	function drawField(dc) {
		var x_center = boundaries.get("x_center");
		var y_bottom = boundaries.get("y_bottom");

		var highlighted_corner = match.getHighlightedCorner();
		Sys.println("highlighted corner " + highlighted_corner);

		var corners = boundaries.get("corners");
		//draw corners
		for(var i = 0; i < corners.size(); i++) {
			var color = highlighted_corner == i ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE;
			dc.setColor(color, Gfx.COLOR_TRANSPARENT);
			dc.fillPolygon(corners[i]);
		}

		//draw scores container
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		//player 1 (watch carrier)
		dc.fillRoundedRectangle(x_center - FIELD_SCORE_WIDTH_PLAYER_1 / 2, boundaries.get("score_1_container_y"), FIELD_SCORE_WIDTH_PLAYER_1, boundaries.get("score_1_container_height"), 5);
		//player 2 (opponent)
		dc.fillRoundedRectangle(x_center - FIELD_SCORE_WIDTH_PLAYER_2 / 2, boundaries.get("score_2_container_y"), FIELD_SCORE_WIDTH_PLAYER_2, boundaries.get("score_2_container_height"), 5);
		//draw scores
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		//player 1 (watch carrier)
		dc.drawText(x_center, boundaries.get("score_1_y"), Gfx.FONT_NUMBER_MEDIUM, match.getScore(:player_1).toString(), Gfx.TEXT_JUSTIFY_CENTER);
		//player 2 (opponent)
		dc.drawText(x_center, boundaries.get("score_2_y"), Gfx.FONT_NUMBER_MILD, match.getScore(:player_2).toString(), Gfx.TEXT_JUSTIFY_CENTER);

		//in double, draw a dot for the player 1 (watch carrier) position if his team is engaging
		if(match.getType() == :double) {
			var player_corner = match.getPlayerCorner();
			if(player_corner != null) {
				var offset = FIELD_SCORE_WIDTH_PLAYER_1 / 2 + 20;
				var y_dot = Geometry.middle(boundaries.get("y_middle"), boundaries.get("y_bottom"));
				var x_position = player_corner == 2 ? x_center - offset : x_center + offset;
				dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
				dc.fillCircle(x_position, y_dot, 7);
			}
		}

		//draw timer
		drawTimer(dc);
	}

	function drawTimer(dc) {
		var x_center = dc.getWidth() / 2;
		var y_bottom = dc.getHeight() - (MARGIN_BOTTOM / 2) - 13;

		//clean only the area of the timer
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.fillRectangle(0, y_bottom, dc.getWidth(), 26);

		//draw timer
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x_center, y_bottom, Gfx.FONT_SMALL, Helpers.formatDuration(match.getDuration()), Gfx.TEXT_JUSTIFY_CENTER);
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
			drawTimer(dc);
		}
	}

}

class MatchViewDelegate extends Ui.BehaviorDelegate {

	function onMenu() {
		Ui.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), Ui.SLIDE_UP);
		return true;
	}

	function manageScore(player) {
		match.score(player);
		var winner = match.getWinner();
		if(winner != null) {
			Ui.switchToView(new ResultView(), new ResultViewDelegate(), Ui.SWIPE_RIGHT);
		}
		else {
			need_full_update = true;
			Ui.requestUpdate();
		}
	}

	function onNextPage() {
		//score with player 1 (watch carrier)
		manageScore(:player_1);
		return true;
	}

	function onPreviousPage() {
		//score with player 2 (opponent)
		manageScore(:player_2);
		return true;
	}

	//undo last action
	function onBack() {
		if(match.getRalliesNumber() > 0) {
			//undo last rally
			match.undo();
			need_full_update = true;
			Ui.requestUpdate();
		}
		else {
			//return to beginner screen if match has not started yet
			var view = new BeginnerView();
			Ui.switchToView(view, new BeginnerViewDelegate(view), Ui.SWIPE_LEFT);
		}
		return true;
	}

	function onTap(event) {
		var center = device.screenHeight / 2;
		if(event.getCoordinates()[1] < boundaries.get("y_middle")) {
			//score with player 2 (opponent)
			manageScore(:player_2);
		}
		else {
			//score with player 1 (watch carrier)
			manageScore(:player_1);
		}
		return true;
	}

}