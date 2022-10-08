using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;

class MatchBoundaries {
	static const COURT_WIDTH_RATIO = 0.7; //width of the back compared to the front of the court
	static const COURT_SIDELINE_SIZE = 0.1;
	static const COURT_LONG_SERVICE_SIZE = 0.05;
	static const COURT_SHORT_SERVICE_SIZE = 0.1;
	//court boundaries coordinates (clockwise, starting from top left point)
	static const COURT_SINGLE = [
		[-0.5 + COURT_SIDELINE_SIZE, 1],
		[0.5 - COURT_SIDELINE_SIZE, 1],
		[0.5 - COURT_SIDELINE_SIZE, 0],
		[-0.5 + COURT_SIDELINE_SIZE, 0]
	];
	static const COURT_DOUBLE = [
		[-0.5, 1],
		[0.5, 1],
		[0.5, 0],
		[-0.5, 0]
	];
	//corners boundaries coordinate
	static const COURT_SINGLE_CORNERS = {
		//OPPONENT_RIGHT is the top left corner
		OPPONENT_RIGHT => [
			[-0.5 + COURT_SIDELINE_SIZE, 1],
			[0, 1],
			[0, 0.5 + COURT_SHORT_SERVICE_SIZE],
			[-0.5 + COURT_SIDELINE_SIZE, 0.5 + COURT_SHORT_SERVICE_SIZE]
		],
		//OPPONENT_LEFT is the top right corner
		OPPONENT_LEFT => [
			[0, 1],
			[0.5 - COURT_SIDELINE_SIZE, 1],
			[0.5 - COURT_SIDELINE_SIZE, 0.5 + COURT_SHORT_SERVICE_SIZE],
			[0, 0.5 + COURT_SHORT_SERVICE_SIZE]
		],
		//YOU_LEFT is the bottom left corner
		YOU_LEFT => [
			[-0.5 + COURT_SIDELINE_SIZE, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0, 0],
			[-0.5 + COURT_SIDELINE_SIZE, 0]
		],
		//YOU_RIGHT is the bottom right corner
		YOU_RIGHT => [
			[0, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0.5 - COURT_SIDELINE_SIZE, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0.5 - COURT_SIDELINE_SIZE, 0],
			[0, 0]
		]
	};
	static const COURT_DOUBLE_CORNERS = {
		//OPPONENT_RIGHT is the top left corner
		OPPONENT_RIGHT => [
			[-0.5, 1 - COURT_LONG_SERVICE_SIZE],
			[0, 1 - COURT_LONG_SERVICE_SIZE],
			[0, 0.5 + COURT_SHORT_SERVICE_SIZE],
			[-0.5, 0.5 + COURT_SHORT_SERVICE_SIZE]
		],
		//OPPONENT_LEFT is the top right corner
		OPPONENT_LEFT => [
			[0, 1 - COURT_LONG_SERVICE_SIZE],
			[0.5, 1 - COURT_LONG_SERVICE_SIZE],
			[0.5, 0.5 + COURT_SHORT_SERVICE_SIZE],
			[0, 0.5 + COURT_SHORT_SERVICE_SIZE]
		],
		//YOU_LEFT is the bottom left corner
		YOU_LEFT => [
			[-0.5, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0, COURT_LONG_SERVICE_SIZE],
			[-0.5, COURT_LONG_SERVICE_SIZE]
		],
		//YOU_RIGHT is the bottom right corner
		YOU_RIGHT => [
			[0, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0.5, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0.5, COURT_LONG_SERVICE_SIZE],
			[0, COURT_LONG_SERVICE_SIZE]
		]
	};

	static const TIME_HEIGHT = Graphics.getFontHeight(Graphics.FONT_SMALL) * 1.1; //height of timer and clock
	public var SET_BALL_RADIUS; //width reserved to display sets

	//center of the watch
	public var xCenter;
	public var yCenter;

	public var yMiddle;
	public var yFront;
	public var yBack;

	public var marginHeight;

	public var perspective;

	public var court;
	public var corners;
	public var board;

	function initialize(match, device) {
		//calculate margins
		marginHeight = device.screenHeight * (device.screenShape == System.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);
		var margin_width = device.screenWidth * (device.screenShape == System.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);

		//calculate strategic positions
		xCenter = device.screenWidth / 2f;
		yCenter = device.screenHeight / 2f;

		yBack = marginHeight;
		if(Application.getApp().getProperty("display_time")) {
			yBack += TIME_HEIGHT;
		}
		yFront = device.screenHeight - marginHeight - TIME_HEIGHT;
		yMiddle = BetterMath.mean(yFront, yBack);

		var back_width, front_width;
		if(match.getSetsNumber() <= 5){
			 SET_BALL_RADIUS = 7;
		}else if(match.getSetsNumber() == 7){
			SET_BALL_RADIUS = 5;
		}else if(match.getSetsNumber() == 9){
			SET_BALL_RADIUS = 4;
		}else if(match.getSetsNumber() == 11){
			SET_BALL_RADIUS = 3;
		}
		//calculate half widths of the front and the back of the court
		var court_margin = SET_BALL_RADIUS * 2 + margin_width;
		//rectangular watches
		if(device.screenShape == System.SCREEN_SHAPE_RECTANGLE) {
			front_width = (device.screenWidth / 2) - court_margin;
			back_width = front_width * COURT_WIDTH_RATIO;
		}
		//round watches
		else {
			var radius = device.screenWidth / 2f;
			front_width = Geometry.chordLength(radius, yFront - yCenter) / 2f - court_margin;
			back_width = Geometry.chordLength(radius, yCenter - yBack) / 2f - court_margin;
		}

		//perspective is defined by its two side vanishing lines
		perspective = new Perspective(
			[xCenter - front_width, yFront], [xCenter - back_width, yBack],
			[xCenter + front_width, yFront], [xCenter + back_width, yBack]
		);

		//select court boundaries coordinates (clockwise, starting from top left point)
		court = perspective.transformArray(match.getType() == SINGLE ? COURT_SINGLE : COURT_DOUBLE);

		//calculate court corners boundaries coordinates
		var corner_coordinates = match.getType() == SINGLE ? COURT_SINGLE_CORNERS : COURT_DOUBLE_CORNERS;
		corners = {
			OPPONENT_RIGHT => perspective.transformArray(corner_coordinates[OPPONENT_RIGHT]),
			OPPONENT_LEFT => perspective.transformArray(corner_coordinates[OPPONENT_LEFT]),
			YOU_LEFT => perspective.transformArray(corner_coordinates[YOU_LEFT]),
			YOU_RIGHT => perspective.transformArray(corner_coordinates[YOU_RIGHT])
		};

		//calculate set positions
		board = new [match.getSetsNumber()];
		for(var i = 0; i < match.getSetsNumber(); i++) {
			var y = 0.1 + 0.7 * i / match.getSetsNumber();
			//dot not align the balls using the real perspective
			//display them parallel to the left side of the court instead
			var transformed_coordinates = perspective.transform([-0.5, y]);
			board[i] = [transformed_coordinates[0] - SET_BALL_RADIUS * 2, transformed_coordinates[1]];
		}
	}
}

class MatchView extends WatchUi.View {
	const SCORE_PLAYER_1_FONT = Graphics.FONT_LARGE;
	const SCORE_PLAYER_2_FONT = Graphics.FONT_MEDIUM;

	public var boundaries;

	private var timer;
	private var clock24Hour;
	private var timeAMLabel;
	private var timePMLabel;

	function initialize() {
		View.initialize();
		calculateBoundaries();
		timer = new Timer.Timer();
	}

	function calculateBoundaries() {
		var match = Application.getApp().getMatch();
		boundaries = new MatchBoundaries(match, System.getDeviceSettings());
	}

	function onShow() {
		clock24Hour = System.getDeviceSettings().is24Hour;
		timeAMLabel = WatchUi.loadResource(Rez.Strings.time_am);
		timePMLabel = WatchUi.loadResource(Rez.Strings.time_pm);
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
		//recalculate boundaries as they may change if "display time" setting is updated
		calculateBoundaries();
		WatchUi.requestUpdate();
	}

	function drawCourt(dc, match) {
		//draw background
		dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(boundaries.court);

		//draw serving and receiving corners
		var serving_corner = match.getServingCorner();
		var receiving_corner = match.getReceivingCorner();
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(boundaries.corners[serving_corner]);
		dc.fillPolygon(boundaries.corners[receiving_corner]);

		//draw bounds
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		//draw left sideline for doubles
		boundaries.perspective.drawVanishingLine(dc, -0.5);
		//draw left sideline for singles
		boundaries.perspective.drawVanishingLine(dc, -0.5 + MatchBoundaries.COURT_SIDELINE_SIZE);
		//draw middle line in two parts
		boundaries.perspective.drawPartialVanishingLine(dc, 0, 0, 0.4);
		boundaries.perspective.drawPartialVanishingLine(dc, 0, 0.6, 1);
		//draw right sideline for singles
		boundaries.perspective.drawVanishingLine(dc, 0.5 - MatchBoundaries.COURT_SIDELINE_SIZE);
		//draw right sideline for doubles
		boundaries.perspective.drawVanishingLine(dc, 0.5);

		//draw front long service line for singles
		boundaries.perspective.drawTransversalLine(dc, 0);
		//draw front long service line for doubles
		boundaries.perspective.drawTransversalLine(dc, MatchBoundaries.COURT_LONG_SERVICE_SIZE);
		//draw front short service line
		boundaries.perspective.drawTransversalLine(dc, 0.5 - MatchBoundaries.COURT_SHORT_SERVICE_SIZE);
		//draw net line
		boundaries.perspective.drawTransversalLine(dc, 0.5);
		//draw back short service line
		boundaries.perspective.drawTransversalLine(dc, 0.5 + MatchBoundaries.COURT_SHORT_SERVICE_SIZE);
		//draw back long service line for doubles
		boundaries.perspective.drawTransversalLine(dc, 1 - MatchBoundaries.COURT_LONG_SERVICE_SIZE);
		//draw back long service line for singles
		boundaries.perspective.drawTransversalLine(dc, 1);

		//draw a dot for the player 1 (watch carrier) position
		var player_x = match.getPlayerCorner() == YOU_LEFT ? -0.28 : 0.28;
		var player_coordinates = boundaries.perspective.transform([player_x, 0.12]);
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(player_coordinates[0], player_coordinates[1], 7);
	}

	function drawScores(dc, match) {
		var set = match.getCurrentSet();
		var server_team = set.getServerTeam();

		var player_1_coordinates = boundaries.perspective.transform([0, 0.25]);
		var player_2_coordinates = boundaries.perspective.transform([0, 0.75]);
		var player_1_color = server_team == YOU ? Graphics.COLOR_BLUE : Graphics.COLOR_WHITE;
		var player_2_color = server_team == OPPONENT ? Graphics.COLOR_BLUE : Graphics.COLOR_WHITE;
		UIHelpers.drawHighlightedNumber(dc, player_1_coordinates[0], player_1_coordinates[1], SCORE_PLAYER_1_FONT, set.getScore(YOU).toString(), player_1_color, 2, 4);
		UIHelpers.drawHighlightedNumber(dc, player_2_coordinates[0], player_2_coordinates[1], SCORE_PLAYER_2_FONT, set.getScore(OPPONENT).toString(), player_2_color, 2, 4);
	}

	function drawSets(dc, match) {
		var sets = match.getSets();
		if(sets.size() > 1) {
			var current_set = match.getCurrentSetIndex();
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
				dc.fillCircle(boundaries.board[i][0], boundaries.board[i][1], boundaries.SET_BALL_RADIUS);
			}
		}
	}

	function drawTimer(dc, match) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(boundaries.xCenter, boundaries.yFront + MatchBoundaries.TIME_HEIGHT * 0.1, Graphics.FONT_SMALL, Helpers.formatDuration(match.getDuration()), Graphics.TEXT_JUSTIFY_CENTER);
	}

	function drawTime(dc) {
		var time_label = Helpers.formatCurrentTime(clock24Hour, timeAMLabel, timePMLabel);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(boundaries.xCenter, boundaries.marginHeight - MatchBoundaries.TIME_HEIGHT * 0.1, Graphics.FONT_SMALL, time_label, Graphics.TEXT_JUSTIFY_CENTER);
	}

	function onUpdate(dc) {
		//when onUpdate is called, the entire view is cleared (hence the badminton court) on some watches (reported by users with vivoactive 4 and venu)
		//in the simulator it's not the case for all watches
		//do not try to update only a part of the view
		//clean the entire screen
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		if(dc has :setAntiAlias) {
			dc.setAntiAlias(true);
		}

		var app = Application.getApp();

		var match = app.getMatch();
		drawCourt(dc, match);
		drawScores(dc, match);
		drawSets(dc, match);
		drawTimer(dc, match);

		if(app.getProperty("display_time")) {
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
		var match = Application.getApp().getMatch();
		match.score(player);
		var winner = match.getCurrentSet().getWinner();
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
		var match = Application.getApp().getMatch();
		if(match.getTotalRalliesNumber() > 0) {
			//undo last rally
			match.undo();
			WatchUi.requestUpdate();
		}
		else if(match.getCurrentSetIndex() == 0) {
			match.discard();
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
