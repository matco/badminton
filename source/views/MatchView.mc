using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;

class MatchBoundaries {
	static const COURT_HEIGHT_RATIO = 0.4; //height of opponent part compared to total height of the court
	static const COURT_WIDTH_RATIO = 0.8; //width of top opponent part compared to total width of the court
	static const COURT_CORRIDORS_SIZE = 12;

	static const TIME_HEIGHT = Graphics.getFontHeight(Graphics.FONT_SMALL) * 1.1; //height of timer and clock
	static const SET_BALL_RADIUS = 7; //width reserved to display sets

	public var xCenter;
	public var yMiddle;
	public var yBottom;
	public var yTop;

	public var halfWidthTop;
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

	function initialize(device) {
		//calculate margins
		marginHeight = device.screenHeight * (device.screenShape == System.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);
		var margin_width = device.screenWidth * (device.screenShape == System.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);

		//calculate strategic positions
		xCenter = device.screenWidth / 2f;
		yTop = marginHeight;
		if(Application.getApp().getProperty("display_time")) {
			yTop += TIME_HEIGHT;
		}
		yBottom = device.screenHeight - marginHeight - TIME_HEIGHT;
		yMiddle = BetterMath.weightedMean(yBottom, yTop, COURT_HEIGHT_RATIO);

		//calculate half width of the top, the middle and the base of the court
		var court_margin = SET_BALL_RADIUS * 2f + margin_width;
		//rectangular watches
		if(device.screenShape == System.SCREEN_SHAPE_RECTANGLE) {
			halfWidthBottom = (device.screenWidth / 2) - court_margin;
			halfWidthTop = halfWidthBottom * COURT_WIDTH_RATIO;
		}
		//round watches
		else {
			var radius = device.screenWidth / 2f;
			halfWidthTop = Geometry.chordLength(radius, marginHeight) / 2f - court_margin;
			halfWidthBottom = Geometry.chordLength(radius, TIME_HEIGHT + marginHeight) / 2f - court_margin;
		}
		halfWidthMiddle = BetterMath.weightedMean(halfWidthBottom, halfWidthTop, COURT_HEIGHT_RATIO);
		halfWidthTopCorridor = BetterMath.weightedMean(halfWidthBottom, halfWidthTop, COURT_CORRIDORS_SIZE / (yBottom - yTop));
		halfWidthBottomCorridor = BetterMath.weightedMean(halfWidthBottom, halfWidthTop, 1 - COURT_CORRIDORS_SIZE / (yBottom - yTop));

		//caclulate court boundaries coordinates (clockwise, starting from top left point)
		doubleCourt = [
			[xCenter - halfWidthTop, yTop],
			[xCenter + halfWidthTop, yTop],
			[xCenter + halfWidthBottom, yBottom],
			[xCenter - halfWidthBottom, yBottom]
		];
		singleCourt = [
			[xCenter - halfWidthTop + COURT_CORRIDORS_SIZE, yTop],
			[xCenter + halfWidthTop - COURT_CORRIDORS_SIZE, yTop],
			[xCenter + halfWidthBottom - COURT_CORRIDORS_SIZE, yBottom],
			[xCenter - halfWidthBottom + COURT_CORRIDORS_SIZE, yBottom]
		];

		//calculate court corners boundaries coordinates
		corners = new [4];
		//top left corner
		corners[0] = [
			[xCenter - halfWidthTopCorridor + COURT_CORRIDORS_SIZE, yTop + COURT_CORRIDORS_SIZE],
			[xCenter, yTop + COURT_CORRIDORS_SIZE],
			[xCenter, yMiddle],
			[xCenter - halfWidthMiddle + COURT_CORRIDORS_SIZE, yMiddle]
		];
		//top right corner
		corners[1] = [
			[xCenter, yTop + COURT_CORRIDORS_SIZE],
			[xCenter + halfWidthTopCorridor - COURT_CORRIDORS_SIZE, yTop + COURT_CORRIDORS_SIZE],
			[xCenter + halfWidthMiddle - COURT_CORRIDORS_SIZE, yMiddle],
			[xCenter, yMiddle]
		];
		//bottom left corner
		corners[2] = [
			[xCenter - halfWidthMiddle + COURT_CORRIDORS_SIZE, yMiddle],
			[xCenter, yMiddle],
			[xCenter, yBottom - COURT_CORRIDORS_SIZE],
			[xCenter - halfWidthBottomCorridor + COURT_CORRIDORS_SIZE, yBottom - COURT_CORRIDORS_SIZE]
		];
		//bottom right corner
		corners[3] = [
			[xCenter, yMiddle],
			[xCenter + halfWidthMiddle - COURT_CORRIDORS_SIZE, yMiddle],
			[xCenter + halfWidthBottomCorridor - COURT_CORRIDORS_SIZE, yBottom - COURT_CORRIDORS_SIZE],
			[xCenter, yBottom - COURT_CORRIDORS_SIZE]
		];

		//calculate score vertical positions
		yScore1 = BetterMath.mean(yBottom, yMiddle);
		yScore2 = BetterMath.mean(yMiddle, yTop);

		//calculate set positions
		board = new [Match.MAX_SETS];
		var x_increment = (halfWidthBottom - halfWidthTop) / Match.MAX_SETS;
		var y_increment = (yBottom - yTop) / Match.MAX_SETS;
		for(var i = 0; i < Match.MAX_SETS; i++) {
			var x = xCenter - halfWidthBottom - SET_BALL_RADIUS - 6 + x_increment * i;
			var y = yBottom - 15 - y_increment * i;
			board[i] = [x, y];
		}
	}
}

class MatchView extends WatchUi.View {
	const SCORE_PLAYER_1_FONT = Graphics.FONT_NUMBER_MEDIUM;
	const SCORE_PLAYER_2_FONT = Graphics.FONT_NUMBER_MILD;

	public var boundaries;

	private var timer;
	private var clock_24_hour;
	private var time_am_label;
	private var time_pm_label;

	function initialize() {
		View.initialize();

		timer = new Timer.Timer();
		boundaries = new MatchBoundaries(System.getDeviceSettings());
	}

	function onShow() {
		clock_24_hour = System.getDeviceSettings().is24Hour;
		time_am_label = WatchUi.loadResource(Rez.Strings.time_am);
		time_pm_label = WatchUi.loadResource(Rez.Strings.time_pm);
		timer.start(method(:onTimer), 1000, true);

		Application.getApp().getBus().register(self);
	}

	function onHide() {
		timer.stop();

		Application.getApp().getBus().unregister(self);
	}

	function onTimer() {
		WatchUi.requestUpdate();
	}

	function onUpdateSettings() {
		//recalculate boundaries as they may change if "diplay time" setting is updated
		boundaries = new MatchBoundaries(System.getDeviceSettings());
		WatchUi.requestUpdate();
	}

	function drawCourt(dc) {
		var x_center = boundaries.xCenter;
		var y_top = boundaries.yTop;
		var y_middle = boundaries.yMiddle;
		var y_bottom = boundaries.yBottom;

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
		dc.drawLine(x_center - boundaries.halfWidthMiddle, y_middle, x_center + boundaries.halfWidthMiddle, y_middle);

		//draw top and bottom corridors
		dc.drawLine(
			x_center - boundaries.halfWidthTopCorridor,
			double_court[0][1] + MatchBoundaries.COURT_CORRIDORS_SIZE,
			x_center + boundaries.halfWidthTopCorridor,
			double_court[1][1] + MatchBoundaries.COURT_CORRIDORS_SIZE
		);
		dc.drawLine(
			x_center - boundaries.halfWidthBottomCorridor,
			double_court[3][1] - MatchBoundaries.COURT_CORRIDORS_SIZE,
			x_center + boundaries.halfWidthBottomCorridor,
			double_court[2][1] - MatchBoundaries.COURT_CORRIDORS_SIZE
		);

		//in double, draw a dot for the player 1 (watch carrier) position if his team is engaging
		if($.match.getType() == DOUBLE) {
			var player_corner = $.match.getPlayerCorner();
			if(player_corner != null) {
				var offset = boundaries.halfWidthBottom - 30;
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
				dc.fillCircle(boundaries.board[i][0], boundaries.board[i][1], MatchBoundaries.SET_BALL_RADIUS);
			}
		}
	}

	function drawTimer(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(boundaries.xCenter, boundaries.yBottom + MatchBoundaries.TIME_HEIGHT * 0.1, Graphics.FONT_SMALL, Helpers.formatDuration($.match.getDuration()), Graphics.TEXT_JUSTIFY_CENTER);
	}

	function drawTime(dc) {
		var time_label = Helpers.formatCurrentTime(clock_24_hour, time_am_label, time_pm_label);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(boundaries.xCenter, boundaries.marginHeight - MatchBoundaries.TIME_HEIGHT * 0.1, Graphics.FONT_SMALL, time_label, Graphics.TEXT_JUSTIFY_CENTER);
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
