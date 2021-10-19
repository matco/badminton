using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;

class MatchBoundaries {
	public var xCenter;
	public var yMiddle;
	public var yBottom;
	public var yTop;

	public var halfWidthMiddle;
	public var halfWidthBottom;

	public var marginHeight;

	public var doubleCourt;
	public var singleCourt;

	public var halfWidthTopCorridor;
	public var halfWidthBottomCorridor;

	public var corners;
	public var board;

	public var yScore1;
	public var yScore2;
}

class MatchView extends WatchUi.View {

	const MAX_SETS = 5;
	const SET_BALL_RADIUS = 7; //width reserved to display sets

	const COURT_HEIGHT_RATIO = 0.4; //height of opponent part compared to total height of the court
	const COURT_WIDTH_RATIO = 0.8; //width of top opponent part compared to total width of the court
	const COURT_CORRIDORS_SIZE = 12;

	const SCORE_PLAYER_1_FONT = Graphics.FONT_NUMBER_MEDIUM;
	const SCORE_PLAYER_2_FONT = Graphics.FONT_NUMBER_MILD;

	const TIME_HEIGHT = Graphics.getFontHeight(Graphics.FONT_SMALL) * 1.1; //height of timer and clock

	public var boundaries;

	private var timer;
	private var clock_24_hour;
	private var time_am_label;
	private var time_pm_label;

	function initialize() {
		View.initialize();

		timer = new Timer.Timer();
		calculateCourtBoundaries();
	}

	function onShow() {
		clock_24_hour = System.getDeviceSettings().is24Hour;
		time_am_label = WatchUi.loadResource(Rez.Strings.time_am);
		time_pm_label = WatchUi.loadResource(Rez.Strings.time_pm);
		timer.start(method(:onTimer), 1000, true);

		Application.getApp().bus.register(self);
	}

	function onHide() {
		timer.stop();

		Application.getApp().bus.unregister(self);
	}

	function onTimer() {
		WatchUi.requestUpdate();
	}

	function onUpdateSettings() {
		//recalculate boundaries as they may change if "diplay time" setting is updated
		calculateCourtBoundaries();
		WatchUi.requestUpdate();
	}

	function calculateCourtBoundaries() {
		boundaries = new MatchBoundaries();

		//calculate margins
		var margin_height = $.device.screenHeight * ($.device.screenShape == System.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);
		var margin_width = $.device.screenWidth * ($.device.screenShape == System.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);

		//calculate strategic positions
		var x_center = $.device.screenWidth / 2;
		var y_top = margin_height;
		if(Application.getApp().getProperty("display_time")) {
			y_top += TIME_HEIGHT;
		}
		var y_bottom = $.device.screenHeight - margin_height - TIME_HEIGHT;
		var y_middle = BetterMath.weightedMean(y_bottom, y_top, COURT_HEIGHT_RATIO);

		//calculate half width of the top, the middle and the base of the court
		var half_width_top, half_width_middle, half_width_bottom;

		var court_margin = SET_BALL_RADIUS * 2 + margin_width;
		//rectangular watches
		if($.device.screenShape == System.SCREEN_SHAPE_RECTANGLE) {
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

		//caclulate court boundaries coordinates (clockwise, starting from top left point)
		boundaries.doubleCourt = [
			[x_center - half_width_top, y_top],
			[x_center + half_width_top, y_top],
			[x_center + half_width_bottom, y_bottom],
			[x_center - half_width_bottom, y_bottom]
		];

		boundaries.singleCourt = [
			[x_center - half_width_top + COURT_CORRIDORS_SIZE, y_top],
			[x_center + half_width_top - COURT_CORRIDORS_SIZE, y_top],
			[x_center + half_width_bottom - COURT_CORRIDORS_SIZE, y_bottom],
			[x_center - half_width_bottom + COURT_CORRIDORS_SIZE, y_bottom]
		];

		//calculate court corners boundaries coordinates
		boundaries.corners = new [4];
		//top left corner
		boundaries.corners[0] = [
			[x_center - half_width_top_corridor + COURT_CORRIDORS_SIZE, y_top + COURT_CORRIDORS_SIZE],
			[x_center, y_top + COURT_CORRIDORS_SIZE],
			[x_center, y_middle],
			[x_center - half_width_middle + COURT_CORRIDORS_SIZE, y_middle]
		];
		//top right corner
		boundaries.corners[1] = [
			[x_center, y_top + COURT_CORRIDORS_SIZE],
			[x_center + half_width_top_corridor - COURT_CORRIDORS_SIZE, y_top + COURT_CORRIDORS_SIZE],
			[x_center + half_width_middle - COURT_CORRIDORS_SIZE, y_middle],
			[x_center, y_middle]
		];
		//bottom left corner
		boundaries.corners[2] = [
			[x_center - half_width_middle + COURT_CORRIDORS_SIZE, y_middle],
			[x_center, y_middle],
			[x_center, y_bottom - COURT_CORRIDORS_SIZE],
			[x_center - half_width_bottom_corridor + COURT_CORRIDORS_SIZE, y_bottom - COURT_CORRIDORS_SIZE]
		];
		//bottom right corner
		boundaries.corners[3] = [
			[x_center, y_middle],
			[x_center + half_width_middle - COURT_CORRIDORS_SIZE, y_middle],
			[x_center + half_width_bottom_corridor - COURT_CORRIDORS_SIZE, y_bottom - COURT_CORRIDORS_SIZE],
			[x_center, y_bottom - COURT_CORRIDORS_SIZE]
		];

		//calculate score vertical positions
		boundaries.yScore1 = BetterMath.mean(y_bottom, y_middle);
		boundaries.yScore2 = BetterMath.mean(y_middle, y_top);

		//calculate set positions
		boundaries.board = new [MAX_SETS];
		var x_increment = (half_width_bottom - half_width_top) / MAX_SETS;
		var y_increment = (y_bottom - y_top) / MAX_SETS;
		for(var i = 0; i < MAX_SETS; i++) {
			var x = x_center - half_width_bottom - SET_BALL_RADIUS - 6 + x_increment * i;
			var y = y_bottom - 15 - y_increment * i;
			boundaries.board[i] = [x, y];
		}

		boundaries.marginHeight = margin_height;

		boundaries.xCenter = x_center;
		boundaries.yTop = y_top;
		boundaries.yMiddle = y_middle;
		boundaries.yBottom = y_bottom;

		boundaries.halfWidthMiddle = half_width_middle;
		boundaries.halfWidthBottom = half_width_bottom;
		boundaries.halfWidthTopCorridor = half_width_top_corridor;
		boundaries.halfWidthBottomCorridor = half_width_bottom_corridor;
	}

	function drawCourt(dc) {
		var x_center = boundaries.xCenter;
		var y_top = boundaries.yTop;
		var y_middle = boundaries.yMiddle;
		var y_bottom = boundaries.yBottom;
		var half_width_middle = boundaries.halfWidthMiddle;
		var half_width_bottom = boundaries.halfWidthBottom;

		//draw court
		var double_court = boundaries.doubleCourt;
		var single_court = boundaries.singleCourt;

		//draw background
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon($.match.getType() == SINGLE ? single_court : double_court);

		//draw highlighted corner
		var highlighted_corner = $.match.getHighlightedCorner();
		dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(boundaries.corners[highlighted_corner]);

		//draw bounds
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		UIHelpers.drawPolygon(dc, single_court);
		UIHelpers.drawPolygon(dc, double_court);

		//draw middle lines
		dc.drawLine(x_center, y_top, x_center, y_bottom);
		dc.drawLine(x_center - half_width_middle, y_middle, x_center + half_width_middle, y_middle);

		//draw top and bottom corridors
		var half_width_top_corridor = boundaries.halfWidthTopCorridor;
		var half_width_bottom_corridor = boundaries.halfWidthBottomCorridor;
		dc.drawLine(x_center - half_width_top_corridor, double_court[0][1] + COURT_CORRIDORS_SIZE, x_center + half_width_top_corridor, double_court[1][1] + COURT_CORRIDORS_SIZE);
		dc.drawLine(x_center - half_width_bottom_corridor, double_court[3][1] - COURT_CORRIDORS_SIZE, x_center + half_width_bottom_corridor, double_court[2][1] - COURT_CORRIDORS_SIZE);

		//in double, draw a dot for the player 1 (watch carrier) position if his team is engaging
		if($.match.getType() == DOUBLE) {
			var player_corner = $.match.getPlayerCorner();
			if(player_corner != null) {
				var offset = half_width_bottom - 30;
				var y_dot = y_bottom - 30;
				var x_position = player_corner == 2 ? (x_center - offset) : (x_center + offset);
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
				dc.fillCircle(x_position, y_dot, 7);
			}
		}
	}

	function drawScores(dc) {
		var set = $.match.getCurrentSet();

		UIHelpers.drawHighlightedText(dc, boundaries.xCenter, boundaries.yScore1, SCORE_PLAYER_1_FONT, set.getScore(YOU).toString(), 8);
		UIHelpers.drawHighlightedText(dc, boundaries.xCenter, boundaries.yScore2, SCORE_PLAYER_2_FONT, set.getScore(OPPONENT).toString(), 8);
	}

	function drawSets(dc) {
		var sets = $.match.getSets();
		if(sets.size() > 1) {
			var current_set = $.match.getCurrentSetIndex();
			for(var i = 0; i < sets.size(); i++) {
				var color;
				if(i == current_set) {
					color = Graphics.COLOR_BLUE;
				}
				else {
					var set = sets[i];
					if(set == null) {
						color = Graphics.COLOR_WHITE;
					}
					else {
						var winner = set.getWinner();
						color = winner == YOU ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
					}
				}
				dc.setColor(color, Graphics.COLOR_TRANSPARENT);
				dc.fillCircle(boundaries.board[i][0], boundaries.board[i][1], SET_BALL_RADIUS);
			}
		}
	}

	function drawTimer(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(boundaries.xCenter, boundaries.yBottom + TIME_HEIGHT * 0.1, Graphics.FONT_SMALL, Helpers.formatDuration($.match.getDuration()), Graphics.TEXT_JUSTIFY_CENTER);
	}

	function drawTime(dc) {
		var time_label = Helpers.formatCurrentTime(clock_24_hour, time_am_label, time_pm_label);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(boundaries.xCenter, boundaries.marginHeight - TIME_HEIGHT * 0.1, Graphics.FONT_SMALL, time_label, Graphics.TEXT_JUSTIFY_CENTER);
	}

	function onUpdate(dc) {
		//when onUpdate is called, the entire view is cleared (hence the badminton field) on some watches (reported by users with vivoactive 4 and venu)
		//in the simulator it's not the case for all watches
		//do not try to update only a part of the view
		//clean the entire screen
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		if(dc has :setAntiAlias) {
			dc.setAntiAlias(true);
		}
		drawCourt(dc);
		drawScores(dc);
		drawSets(dc);
		drawTimer(dc);
		if(Application.getApp().getProperty("display_time")) {
			drawTime(dc);
		}
	}
}

class MatchViewDelegate extends WatchUi.BehaviorDelegate {

	private var view;

	function initialize(v) {
		view = v;
		BehaviorDelegate.initialize();
	}

	function onMenu() {
		WatchUi.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function manageScore(player) {
		$.match.score(player);
		var winner = $.match.getCurrentSet().getWinner();
		if(winner != null) {
			WatchUi.switchToView(new SetResultView(), new SetResultViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		else {
			WatchUi.requestUpdate();
		}
		return true;
	}

	function onNextPage() {
		//score with player 1 (watch carrier)
		return manageScore(YOU);
	}

	function onPreviousPage() {
		//score with player 2 (opponent)
		return manageScore(OPPONENT);
	}

	//undo last action
	function onBack() {
		if($.match.getTotalRalliesNumber() > 0) {
			//undo last rally
			$.match.undo();
			WatchUi.requestUpdate();
		}
		else if($.match.getCurrentSetIndex() == 0) {
			$.match.discard();
			//return to beginner screen if match has not started yet

			WatchUi.switchToView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		return true;
	}

	function onTap(event) {
		if(event.getCoordinates()[1] < view.boundaries.yMiddle) {
			//score with player 2 (opponent)
			manageScore(OPPONENT);
		}
		else {
			//score with player 1 (watch carrier)
			manageScore(YOU);
		}
		return true;
	}
}
