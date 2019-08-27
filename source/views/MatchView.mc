using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

var boundaries;
var need_full_update;

class MatchView extends Ui.View {

	const MAX_SETS = 5;
	const SET_BALL_RADIUS = 7; //width reserved to display sets

	const FIELD_HEIGHT_RATIO = 0.4; //height of opponent part compared to total height of field
	const FIELD_WIDTH_RATIO = 0.8;  //width of top opponent part compared to total width of field
	const FIELD_PADDING = 2;
	const FIELD_SCORE_RATIO = 0.7;

	const FIELD_SCORE_WIDTH_PLAYER_1 = 50;
	const FIELD_SCORE_WIDTH_PLAYER_2 = 40;

	hidden var timer;
	hidden var display_time;
	hidden var clock_24_hour;
	hidden var time_am_label;
	hidden var time_pm_label;

	function initialize() {
		View.initialize();

		timer = new Timer.Timer();
		display_time = App.getApp().getProperty("display_time");
		$.boundaries = getFieldBoundaries();
	}

	function onShow() {
		clock_24_hour = System.getDeviceSettings().is24Hour;
		time_am_label = Ui.loadResource(Rez.Strings.time_am);
		time_pm_label = Ui.loadResource(Rez.Strings.time_pm);
		timer.start(method(:onTimer), 1000, true);
		//when shown, ask for full update
		$.need_full_update = true;
	}

	function onHide() {
		timer.stop();
	}

	function onTimer() {
		Ui.requestUpdate();
	}

	function getFieldBoundaries() {
		//calculate margins
		var margin_height = $.device.screenHeight * ($.device.screenShape == Sys.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.1);
		var margin_width = $.device.screenWidth * ($.device.screenShape == Sys.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);

		//calculate time (timer and clock) height
		var time_height = Gfx.getFontHeight(Gfx.FONT_SMALL) * 1.1;

		//calculate strategic positions
		var x_center = $.device.screenWidth / 2;
		var y_top = margin_height;
		if (display_time) {
			y_top += time_height;
		}
		var y_bottom = $.device.screenHeight - margin_height - time_height;
		var y_middle = BetterMath.weightedMean(y_bottom, y_top, FIELD_HEIGHT_RATIO);

		//calculate half width of the top, the middle and the base of the field
		var half_width_top, half_width_middle, half_width_bottom;

		//rectangular watches
		if($.device.screenShape == Sys.SCREEN_SHAPE_RECTANGLE) {
			half_width_top = ($.device.screenWidth / 2) * FIELD_WIDTH_RATIO - SET_BALL_RADIUS * 2 - margin_width;
			half_width_bottom = ($.device.screenWidth / 2) - SET_BALL_RADIUS * 2 - margin_width;
		}
		//round watches
		else {
			var radius = $.device.screenWidth / 2;
			half_width_top = Geometry.chordLength(radius, margin_height) / 2 - SET_BALL_RADIUS - margin_width;
			half_width_bottom = Geometry.chordLength(radius, time_height + margin_height) / 2 - SET_BALL_RADIUS - margin_width;
		}
		half_width_middle = BetterMath.weightedMean(half_width_bottom, half_width_top, FIELD_HEIGHT_RATIO);

		//caclulate corners coordinates
		var corners = new [4];
		//top left corner
		corners[0] = [
			[x_center - half_width_top, y_top],
			[x_center - FIELD_PADDING, y_top],
			[x_center - FIELD_PADDING, y_middle - FIELD_PADDING],
			[x_center - half_width_middle, y_middle - FIELD_PADDING]
		];
		//top right corner
		corners[1] = [
			[x_center + FIELD_PADDING, y_top],
			[x_center + half_width_top, y_top],
			[x_center + half_width_middle, y_middle - FIELD_PADDING],
			[x_center + FIELD_PADDING, y_middle - FIELD_PADDING]
		];
		//bottom left corner
		corners[2] = [
			[x_center - half_width_middle, y_middle + FIELD_PADDING],
			[x_center - FIELD_PADDING, y_middle + FIELD_PADDING],
			[x_center - FIELD_PADDING, y_bottom, y_middle - FIELD_PADDING],
			[x_center - half_width_bottom, y_bottom]
		];
		//bottom right corner
		corners[3] = [
			[x_center + FIELD_PADDING, y_middle + FIELD_PADDING],
			[x_center + half_width_middle, y_middle + FIELD_PADDING],
			[x_center + half_width_bottom, y_bottom],
			[x_center + FIELD_PADDING, y_bottom]
		];

		//calculate score positions
		var score_2_container_y = BetterMath.weightedMean(y_middle, y_top, (1 - FIELD_SCORE_RATIO) / 2);
		var score_2_container_height = (y_middle - y_top) * FIELD_SCORE_RATIO;
		var score_1_container_y = BetterMath.weightedMean(y_bottom, y_middle, (1 - FIELD_SCORE_RATIO) / 2);
		var score_1_container_height = (y_bottom - y_middle) * FIELD_SCORE_RATIO;

		//calculate set positions
		var board = new [MAX_SETS];
		var x_increment = (half_width_bottom - half_width_top) / MAX_SETS;
		var y_increment = (y_bottom - y_top) / MAX_SETS;
		for(var i = 0; i < MAX_SETS; i++) {
			var x = x_center - half_width_bottom - SET_BALL_RADIUS - 2 * FIELD_PADDING + x_increment * i;
			var y = y_bottom - 15 - y_increment * i;
			board[i] = [x, y];
		}

		return {
			"x_center" => x_center,
			"y_middle" => y_middle,
			"y_bottom" => y_bottom,
			"y_top" => y_top,
			"margin_height" => margin_height,
			"corners" => corners,
			"board" => board,
			"score_2_container_y" => score_2_container_y,
			"score_2_container_height" => score_2_container_height,
			"score_2_y" => (score_2_container_y + score_2_container_height / 2 - Gfx.getFontHeight(Gfx.FONT_NUMBER_MILD) / 2 - 4),
			"score_1_container_y" => score_1_container_y,
			"score_1_container_height" => score_1_container_height,
			"score_1_y" => (score_1_container_y + score_1_container_height / 2 - Gfx.getFontHeight(Gfx.FONT_NUMBER_MEDIUM) / 2 - 4),
			"time_height" => time_height
		};
	}

	function drawField(dc) {
		var x_center = $.boundaries.get("x_center");

		var highlighted_corner = $.match.getHighlightedCorner();

		var corners = $.boundaries.get("corners");
		//draw corners
		for(var i = 0; i < corners.size(); i++) {
			var color = highlighted_corner == i ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_WHITE;
			dc.setColor(color, Gfx.COLOR_TRANSPARENT);
			dc.fillPolygon(corners[i]);
		}

		//draw scores container
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		//player 1 (watch carrier)
		dc.fillRoundedRectangle(x_center - FIELD_SCORE_WIDTH_PLAYER_1 / 2, $.boundaries.get("score_1_container_y"), FIELD_SCORE_WIDTH_PLAYER_1, $.boundaries.get("score_1_container_height"), 5);
		//player 2 (opponent)
		dc.fillRoundedRectangle(x_center - FIELD_SCORE_WIDTH_PLAYER_2 / 2, $.boundaries.get("score_2_container_y"), FIELD_SCORE_WIDTH_PLAYER_2, $.boundaries.get("score_2_container_height"), 5);
		//draw scores
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		var set = $.match.getCurrentSet();
		//player 1 (watch carrier)
		dc.drawText(x_center, $.boundaries.get("score_1_y"), Gfx.FONT_NUMBER_MEDIUM, set.getScore(:player_1).toString(), Gfx.TEXT_JUSTIFY_CENTER);
		//player 2 (opponent)
		dc.drawText(x_center, $.boundaries.get("score_2_y"), Gfx.FONT_NUMBER_MILD, set.getScore(:player_2).toString(), Gfx.TEXT_JUSTIFY_CENTER);

		//draw sets
		var sets = $.match.getSets();
		if(sets.size() > 1) {
			var board = $.boundaries.get("board");
			var current_set = $.match.getCurrentSetIndex();
			for(var i = 0; i < sets.size(); i++) {
				if(i == current_set) {
					dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
				}
				else {
					var set = sets[i];
					if(set == -1) {
						dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
					}
					else {
						var winner = set.getWinner();
						if(winner == :player_1) {
							dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
						}
						else {
							dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
						}
					}
				}
				dc.fillCircle(board[i][0], board[i][1], SET_BALL_RADIUS);
			}
		}

		//in double, draw a dot for the player 1 (watch carrier) position if his team is engaging
		if($.match.getType() == :double) {
			var player_corner = $.match.getPlayerCorner();
			if(player_corner != null) {
				var offset = FIELD_SCORE_WIDTH_PLAYER_1 / 2 + 20;
				var y_dot = BetterMath.mean($.boundaries.get("y_middle"), $.boundaries.get("y_bottom"));
				var x_position = player_corner == 2 ? x_center - offset : x_center + offset;
				dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
				dc.fillCircle(x_position, y_dot, 7);
			}
		}
	}

	function drawTimer(dc) {
		var x_center = $.boundaries.get("x_center");
		var y_bottom = $.boundaries.get("y_bottom");
		var margin_height = $.boundaries.get("margin_height");
		var y_top = $.boundaries.get("y_top");
		var time_height = $.boundaries.get("time_height");

		if (display_time) {
			var time_label = Helpers.formatCurrentTime(clock_24_hour, time_am_label, time_pm_label);
			//clean only the area of the time
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
			dc.fillRectangle(0, 0, dc.getWidth(), y_top);
			//draw time
			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
			dc.drawText(x_center, margin_height - time_height * 0.1, Gfx.FONT_SMALL, time_label, Gfx.TEXT_JUSTIFY_CENTER);
		}

		//clean only the area of the timer
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.fillRectangle(0, y_bottom, dc.getWidth(), time_height);
		//draw timer
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x_center, y_bottom + time_height * 0.1, Gfx.FONT_SMALL, Helpers.formatDuration($.match.getDuration()), Gfx.TEXT_JUSTIFY_CENTER);
	}

	function onUpdate(dc) {
		if($.need_full_update) {
			$.need_full_update = false;
			//clean the entire screen
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
			dc.clear();
			drawField(dc);
		}
		drawTimer(dc);
	}
}

class MatchViewDelegate extends Ui.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onMenu() {
		Ui.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function manageScore(player) {
		$.match.score(player);
		var winner = $.match.getCurrentSet().getWinner();
		if(winner != null) {
			Ui.switchToView(new SetResultView(), new SetResultViewDelegate(), Ui.SLIDE_IMMEDIATE);
		}
		else {
			$.need_full_update = true;
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
		if($.match.getTotalRalliesNumber() > 0) {
			//undo last rally
			$.match.undo();
			$.need_full_update = true;
			Ui.requestUpdate();
		}
		else if($.match.getCurrentSetIndex() == 0) {
			$.match.discard();
			//return to beginner screen if match has not started yet
			var view = new BeginnerView();
			Ui.switchToView(view, new BeginnerViewDelegate(view), Ui.SLIDE_IMMEDIATE);
		}
		return true;
	}

	function onTap(event) {
		var center = $.device.screenHeight / 2;
		if(event.getCoordinates()[1] < $.boundaries.get("y_middle")) {
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
