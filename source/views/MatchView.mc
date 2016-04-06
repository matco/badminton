using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

var boundaries;
var need_full_update;

class MatchView extends Ui.View {

	const FIELD_RATIO = 0.4;
	const FIELD_PADDING = 2;
	const FIELD_SCORE_RATIO = 0.7;

	const FIELD_SCORE_WIDTH_PLAYER_1 = 50;
	const FIELD_SCORE_WIDTH_PLAYER_2 = 40;

	hidden var timer;

	function initialize() {
		timer = new Timer.Timer();
		boundaries = getFieldBoundaries();
	}

	//! Load your resources here
	function onLayout(dc) {
	}

	//! Restore the state of the app and prepare the view to be shown
	function onShow() {
		timer.start(method(:onTimer), 1000, true);

		//when shown, ask for full update
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
		//calculate margins
		var margin_height = device.screenHeight * (device.screenShape == Sys.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.1);
		var margin_width = device.screenWidth * (device.screenShape == Sys.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.08);

		var timer_height = Gfx.getFontHeight(Gfx.FONT_SMALL) * 1.1;

		var x_center = device.screenWidth / 2;
		var y_top = margin_height;
		var y_bottom = device.screenHeight - margin_height - timer_height;
		var y_middle = Geometry.middle(y_bottom, y_top, FIELD_RATIO);

		//calculate half width of the top, the middle and the base of the field
		var half_width_top, half_width_middle, half_width_bottom;

		//rectangular watches
		if(device.screenShape == Sys.SCREEN_SHAPE_RECTANGLE) {
			half_width_top = (device.screenWidth / 2 * 0.6) - margin_width;
			half_width_bottom = (device.screenWidth / 2 * 0.9) - margin_width;
		}
		//round watches
		else {
			var radius = device.screenWidth / 2;
			half_width_top = Geometry.chordLength(radius, y_top) / 2 - margin_width;
			half_width_bottom = Geometry.chordLength(radius, timer_height + margin_height) / 2 - margin_width;
		}
		half_width_middle = Geometry.middle(half_width_bottom, half_width_top, FIELD_RATIO);

		//calculate score position
		var score_2_container_y = Geometry.middle(y_middle, y_top, (1 - FIELD_SCORE_RATIO) / 2);
		var score_2_container_height = (y_middle - y_top) * FIELD_SCORE_RATIO;
		var score_1_container_y = Geometry.middle(y_bottom, y_middle, (1 - FIELD_SCORE_RATIO) / 2);
		var score_1_container_height = (y_bottom - y_middle) * FIELD_SCORE_RATIO;
		return {
			"x_center" => x_center,
			"y_middle" => y_middle,
			"y_bottom" => y_bottom,
			"corners" => [
				[[x_center - half_width_top, y_top], [x_center - FIELD_PADDING, y_top], [x_center - FIELD_PADDING, y_middle - FIELD_PADDING], [x_center - half_width_middle, y_middle - FIELD_PADDING]],
				[[x_center + FIELD_PADDING, y_top], [x_center + half_width_top, y_top], [x_center + half_width_middle, y_middle - FIELD_PADDING], [x_center + FIELD_PADDING, y_middle - FIELD_PADDING]],
				[[x_center - half_width_middle, y_middle + FIELD_PADDING], [x_center - FIELD_PADDING, y_middle + FIELD_PADDING], [x_center - FIELD_PADDING, y_bottom, y_middle - FIELD_PADDING], [x_center - half_width_bottom, y_bottom]],
				[[x_center + FIELD_PADDING, y_middle + FIELD_PADDING], [x_center + half_width_middle, y_middle + FIELD_PADDING], [x_center + half_width_bottom, y_bottom], [x_center + FIELD_PADDING, y_bottom]]
			],
			"score_2_container_y" => score_2_container_y,
			"score_2_container_height" => score_2_container_height,
			"score_2_y" => (score_2_container_y + score_2_container_height / 2 - Gfx.getFontHeight(Gfx.FONT_NUMBER_MILD) / 2 - 4),
			"score_1_container_y" => score_1_container_y,
			"score_1_container_height" => score_1_container_height,
			"score_1_y" => (score_1_container_y + score_1_container_height / 2 - Gfx.getFontHeight(Gfx.FONT_NUMBER_MEDIUM) / 2 - 4),
			"timer_height" => timer_height
		};
	}

	function drawField(dc) {
		var x_center = boundaries.get("x_center");

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
	}

	function drawTimer(dc) {
		var x_center = boundaries.get("x_center");
		var y_bottom = boundaries.get("y_bottom");
		var timer_height = boundaries.get("timer_height");

		//clean only the area of the timer
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.fillRectangle(0, y_bottom, dc.getWidth(), timer_height);

		//draw timer
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x_center, y_bottom + timer_height * 0.1, Gfx.FONT_SMALL, Helpers.formatDuration(match.getDuration()), Gfx.TEXT_JUSTIFY_CENTER);
	}

	//! Update the view
	function onUpdate(dc) {
		if(need_full_update) {
			need_full_update = false;
			//clean the entire screen
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
			dc.clear();
			drawField(dc);
		}
		drawTimer(dc);
	}

}

class MatchViewDelegate extends Ui.BehaviorDelegate {

	function onMenu() {
		Ui.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function manageScore(player) {
		match.score(player);
		var winner = match.getWinner();
		if(winner != null) {
			Ui.switchToView(new ResultView(), new ResultViewDelegate(), Ui.SLIDE_IMMEDIATE);
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