using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Timer;

var boundaries;
var need_full_update;

class MatchView extends Ui.View {

	const MAX_SETS = 5;
	const SET_BALL_RADIUS = 7; //width reserved to display sets

	const COURT_HEIGHT_RATIO = 0.4; //height of opponent part compared to total height of the court
	const COURT_WIDTH_RATIO = 0.8; //width of top opponent part compared to total width of the court
	const COURT_CORRIDORS_SIZE = 12;

	const SCORE_PLAYER_1_FONT = Gfx.FONT_NUMBER_MEDIUM;
	const SCORE_PLAYER_2_FONT = Gfx.FONT_NUMBER_MILD;

	const TIME_HEIGHT = Gfx.getFontHeight(Gfx.FONT_SMALL) * 1.1; //height of timer and clock

	hidden var timer;
	hidden var display_time;
	hidden var clock_24_hour;
	hidden var time_am_label;
	hidden var time_pm_label;

	function initialize() {
		View.initialize();

		timer = new Timer.Timer();
		display_time = App.getApp().getProperty("display_time");
		$.boundaries = getCourtBoundaries();
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

	function getCourtBoundaries() {
		//calculate margins
		var margin_height = $.device.screenHeight * ($.device.screenShape == Sys.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);
		var margin_width = $.device.screenWidth * ($.device.screenShape == Sys.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);

		//calculate strategic positions
		var x_center = $.device.screenWidth / 2;
		var y_top = margin_height;
		if (display_time) {
			y_top += TIME_HEIGHT;
		}
		var y_bottom = $.device.screenHeight - margin_height - TIME_HEIGHT;
		var y_middle = BetterMath.weightedMean(y_bottom, y_top, COURT_HEIGHT_RATIO);

		//calculate half width of the top, the middle and the base of the court
		var half_width_top, half_width_middle, half_width_bottom;

		var court_margin = SET_BALL_RADIUS * 2 + margin_width;
		//rectangular watches
		if($.device.screenShape == Sys.SCREEN_SHAPE_RECTANGLE) {
			half_width_bottom = ($.device.screenWidth / 2) - court_margin;
			half_width_top = half_width_bottom * COURT_WIDTH_RATIO;
		}
		//round watches
		else {
			var radius = $.device.screenWidth / 2;
			half_width_top = Geometry.chordLength(radius, margin_height) / 2 - court_margin;
			half_width_bottom = Geometry.chordLength(radius, TIME_HEIGHT + margin_height) / 2 - court_margin;
		}
		half_width_middle = BetterMath.weightedMean(half_width_bottom, half_width_top, COURT_HEIGHT_RATIO);

		var half_width_top_corridor = BetterMath.weightedMean(half_width_bottom, half_width_top, COURT_CORRIDORS_SIZE / (y_bottom - y_top));
		var half_width_bottom_corridor = BetterMath.weightedMean(half_width_bottom, half_width_top, 1 - COURT_CORRIDORS_SIZE / (y_bottom - y_top));

		//caclulate court corners coordinates (clockwise, starting from top left point)
		var double_court = new [4];
		double_court[0] = [x_center - half_width_top, y_top];
		double_court[1] = [x_center + half_width_top, y_top];
		double_court[2] = [x_center + half_width_bottom, y_bottom];
		double_court[3] = [x_center - half_width_bottom, y_bottom];

		var single_court = new [4];
		single_court[0] = [x_center - half_width_top + COURT_CORRIDORS_SIZE, y_top];
		single_court[1] = [x_center + half_width_top - COURT_CORRIDORS_SIZE, y_top];
		single_court[2] = [x_center + half_width_bottom - COURT_CORRIDORS_SIZE, y_bottom];
		single_court[3] = [x_center - half_width_bottom + COURT_CORRIDORS_SIZE, y_bottom];

		var corners = new [4];
		//top left corner
		corners[0] = [
			[x_center - half_width_top_corridor + COURT_CORRIDORS_SIZE, y_top + COURT_CORRIDORS_SIZE],
			[x_center, y_top + COURT_CORRIDORS_SIZE],
			[x_center, y_middle],
			[x_center - half_width_middle + COURT_CORRIDORS_SIZE, y_middle]
		];
		//top right corner
		corners[1] = [
			[x_center, y_top + COURT_CORRIDORS_SIZE],
			[x_center + half_width_top_corridor - COURT_CORRIDORS_SIZE, y_top + COURT_CORRIDORS_SIZE],
			[x_center + half_width_middle - COURT_CORRIDORS_SIZE, y_middle],
			[x_center, y_middle]
		];
		//bottom left corner
		corners[2] = [
			[x_center - half_width_middle + COURT_CORRIDORS_SIZE, y_middle],
			[x_center, y_middle],
			[x_center, y_bottom - COURT_CORRIDORS_SIZE],
			[x_center - half_width_bottom_corridor + COURT_CORRIDORS_SIZE, y_bottom - COURT_CORRIDORS_SIZE]
		];
		//bottom right corner
		corners[3] = [
			[x_center, y_middle],
			[x_center + half_width_middle - COURT_CORRIDORS_SIZE, y_middle],
			[x_center + half_width_bottom_corridor - COURT_CORRIDORS_SIZE, y_bottom - COURT_CORRIDORS_SIZE],
			[x_center, y_bottom - COURT_CORRIDORS_SIZE]
		];

		//calculate score positions
		var y_score_1 = BetterMath.mean(y_bottom, y_middle);
		var y_score_2 = BetterMath.mean(y_middle, y_top);

		//calculate set positions
		var board = new [MAX_SETS];
		var x_increment = (half_width_bottom - half_width_top) / MAX_SETS;
		var y_increment = (y_bottom - y_top) / MAX_SETS;
		for(var i = 0; i < MAX_SETS; i++) {
			var x = x_center - half_width_bottom - SET_BALL_RADIUS - 6 + x_increment * i;
			var y = y_bottom - 15 - y_increment * i;
			board[i] = [x, y];
		}

		return {
			"x_center" => x_center,
			"y_middle" => y_middle,
			"y_bottom" => y_bottom,
			"y_top" => y_top,
			"half_width_middle" => half_width_middle,
			"half_width_bottom" => half_width_bottom,
			"margin_height" => margin_height,
			"double_court" => double_court,
			"single_court" => single_court,
			"half_width_top_corridor" => half_width_top_corridor,
			"half_width_bottom_corridor" => half_width_bottom_corridor,
			"corners" => corners,
			"board" => board,
			"y_score_1" => y_score_1,
			"y_score_2" => y_score_2
		};
	}

	function drawCourt(dc) {
		var x_center = $.boundaries.get("x_center");
		var y_top = $.boundaries.get("y_top");
		var y_middle = $.boundaries.get("y_middle");
		var y_bottom = $.boundaries.get("y_bottom");
		var half_width_middle = $.boundaries.get("half_width_middle");
		var half_width_bottom = $.boundaries.get("half_width_bottom");

		//draw court
		var double_court = $.boundaries.get("double_court");
		var single_court = $.boundaries.get("single_court");

		//draw background
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon($.match.getType() == :single ? single_court : double_court);

		//draw highlighted corner
		var highlighted_corner = $.match.getHighlightedCorner();
		var corners = $.boundaries.get("corners");
		dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
		dc.fillPolygon(corners[highlighted_corner]);

		//draw bounds
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		UIHelpers.drawPolygon(dc, single_court);
		UIHelpers.drawPolygon(dc, double_court);

		//draw middle lines
		dc.drawLine(x_center, y_top, x_center, y_bottom);
		dc.drawLine(x_center - half_width_middle, y_middle, x_center + half_width_middle, y_middle);

		//draw top and bottom corridors
		var half_width_top_corridor = $.boundaries.get("half_width_top_corridor");
		var half_width_bottom_corridor = $.boundaries.get("half_width_bottom_corridor");
		dc.drawLine(x_center - half_width_top_corridor, double_court[0][1] + COURT_CORRIDORS_SIZE, x_center + half_width_top_corridor, double_court[1][1] + COURT_CORRIDORS_SIZE);
		dc.drawLine(x_center - half_width_bottom_corridor, double_court[3][1] - COURT_CORRIDORS_SIZE, x_center + half_width_bottom_corridor, double_court[2][1] - COURT_CORRIDORS_SIZE);

		//in double, draw a dot for the player 1 (watch carrier) position if his team is engaging
		if($.match.getType() == :double) {
			var player_corner = $.match.getPlayerCorner();
			if(player_corner != null) {
				var offset = half_width_bottom - 30;
				var y_dot = y_bottom - 30;
				var x_position = player_corner == 2 ? (x_center - offset) : (x_center + offset);
				dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
				dc.fillCircle(x_position, y_dot, 7);
			}
		}
	}

	function drawScores(dc) {
		var x_center = $.boundaries.get("x_center");
		var y_score_1 = $.boundaries.get("y_score_1");
		var y_score_2 = $.boundaries.get("y_score_2");
		var set = $.match.getCurrentSet();

		UIHelpers.drawHighlightedText(dc, x_center, y_score_1, SCORE_PLAYER_1_FONT, set.getScore(:player_1).toString(), 8);
		UIHelpers.drawHighlightedText(dc, x_center, y_score_2, SCORE_PLAYER_2_FONT, set.getScore(:player_2).toString(), 8);
	}

	function drawSets(dc) {
		var sets = $.match.getSets();
		if(sets.size() > 1) {
			var board = $.boundaries.get("board");
			var current_set = $.match.getCurrentSetIndex();
			for(var i = 0; i < sets.size(); i++) {
				var color;
				if(i == current_set) {
					color = Gfx.COLOR_BLUE;
				}
				else {
					var set = sets[i];
					if(set == -1) {
						color = Gfx.COLOR_WHITE;
					}
					else {
						var winner = set.getWinner();
						color = winner == :player_1 ? Gfx.COLOR_GREEN : Gfx.COLOR_RED;
					}
				}
				dc.setColor(color, Gfx.COLOR_TRANSPARENT);
				dc.fillCircle(board[i][0], board[i][1], SET_BALL_RADIUS);
			}
		}
	}

	function drawTimer(dc) {
		var x_center = $.boundaries.get("x_center");
		var y_bottom = $.boundaries.get("y_bottom");

		//clean only the area of the timer
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.fillRectangle(0, y_bottom + 1, dc.getWidth(), dc.getHeight());
		//draw timer
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x_center, y_bottom + TIME_HEIGHT * 0.1, Gfx.FONT_SMALL, Helpers.formatDuration($.match.getDuration()), Gfx.TEXT_JUSTIFY_CENTER);
	}

	function drawTime(dc) {
		var margin_height = $.boundaries.get("margin_height");
		var x_center = $.boundaries.get("x_center");
		var y_top = $.boundaries.get("y_top");

		var time_label = Helpers.formatCurrentTime(clock_24_hour, time_am_label, time_pm_label);
		//clean only the area of the time
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.fillRectangle(0, 0, dc.getWidth(), y_top - 1);
		//draw time
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x_center, margin_height - TIME_HEIGHT * 0.1, Gfx.FONT_SMALL, time_label, Gfx.TEXT_JUSTIFY_CENTER);
	}

	function onUpdate(dc) {
		if($.need_full_update) {
			$.need_full_update = false;
			//clean the entire screen
			dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
			dc.clear();
			if(dc has :setAntiAlias) {
				dc.setAntiAlias(true);
			}
			drawCourt(dc);
			drawScores(dc);
			drawSets(dc);
		}
		drawTimer(dc);
		if (display_time) {
			drawTime(dc);
		}
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
			var view = new InitialView();
			Ui.switchToView(view, new InitialViewDelegate(view), Ui.SLIDE_IMMEDIATE);
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
