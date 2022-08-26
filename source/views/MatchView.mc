import Toybox.Lang;
import Toybox.Timer;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.Activity;
using Toybox.UserProfile;

class MatchBoundaries {
	static const COURT_WIDTH_RATIO = 0.6; //width of the back compared to the front of the court
	static const COURT_SIDELINE_SIZE = 0.1;
	static const COURT_LONG_SERVICE_SIZE = 0.05;
	static const COURT_SHORT_SERVICE_SIZE = 0.1;
	//court boundaries coordinates (clockwise, starting from top left point)
	static const COURT_SINGLE = [
		[-0.5 + COURT_SIDELINE_SIZE, 1],
		[0.5 - COURT_SIDELINE_SIZE, 1],
		[0.5 - COURT_SIDELINE_SIZE, 0],
		[-0.5 + COURT_SIDELINE_SIZE, 0]
	] as Array<Array>;
	static const COURT_DOUBLE = [
		[-0.5, 1],
		[0.5, 1],
		[0.5, 0],
		[-0.5, 0]
	] as Array<Array>;
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
	static const SET_BALL_RADIUS = 7; //width reserved to display sets

	//center of the watch
	public var xCenter as Float;
	public var yCenter as Float;

	public var yMiddle as Float;
	public var yFront as Float;
	public var yBack as Float;

	public var marginHeight as Float;

	public var perspective as Perspective;

	public var court as Array<Array>;
	public var corners as Dictionary<Corner, Array>;
	public var board as Array<Array>;

	public var hrCoordinates as Dictionary<String, Array or Number>;

	function initialize(match as Match, device as DeviceSettings, elapsed_time as Number?) {
		//calculate margins
		marginHeight = device.screenHeight * (device.screenShape == System.SCREEN_SHAPE_RECTANGLE ? 0.04 : 0.09);
		var margin_width = device.screenWidth * 0.09;

		//calculate strategic positions
		xCenter = device.screenWidth / 2f;
		yCenter = device.screenHeight / 2f;

		yBack = marginHeight;
		if(Properties.getValue("display_time")) {
			yBack += TIME_HEIGHT;
		}
		yFront = device.screenHeight - marginHeight - TIME_HEIGHT;

		var back_width, front_width;

		//calculate half widths of the front and the back of the court
		var court_margin = SET_BALL_RADIUS * 2 + margin_width;
		//rectangular watches
		if(device.screenShape == System.SCREEN_SHAPE_RECTANGLE) {
			//simulate perspective using the arbitrary court width ratio
			front_width = (device.screenWidth / 2) - court_margin;
			back_width = front_width * COURT_WIDTH_RATIO;
		}
		//round watches
		else {
			var radius = device.screenWidth / 2f;
			//use the available space to draw the court
			front_width = Geometry.chordLength(radius, yFront - yCenter) / 2f - court_margin;
			back_width = Geometry.chordLength(radius, yCenter - yBack) / 2f - court_margin;
			//however, this may not result in a good perspective, for example when the current time is displayed
			//in this case, the top and bottom margins are the same, resulting in a court that has the shape of a rectangle
			//perspective must be created it artificially
			if((back_width / front_width) > COURT_WIDTH_RATIO) {
				back_width = front_width * COURT_WIDTH_RATIO;
			}
		}

		if(elapsed_time != null) {
			var half_time = MatchView.ANIMATION_TIME / 2;
			if(elapsed_time < half_time) {
				var width = BetterMath.mean(front_width, back_width);
				var zoom = 0.7 + (0.3 * elapsed_time / half_time);
				front_width = width * zoom;
				back_width = width * zoom;

				//adjust back and front positions
				yBack = (yBack - 25 + 15 - 15 * elapsed_time / half_time);
				yFront = (yFront + 25 - 15 + 15 * elapsed_time / half_time);
			}
			else if(elapsed_time < MatchView.ANIMATION_TIME) {
				var time = elapsed_time - half_time;
				var width = BetterMath.mean(front_width, back_width);
				var width_offset = (front_width - width) * time / half_time;
				front_width = width + width_offset;
				back_width = width - width_offset;

				//adjust back and front positions
				var offset = 25 * time / half_time;
				yBack = yBack - 25 + offset;
				yFront = yFront + 25 - offset;
				//yBack = Math.sqrt(Math.pow(radius, 2) - Math.pow(back_width / 2, 2));
				//yFront = Math.sqrt(Math.pow(radius, 2) - Math.pow(front_width / 2, 2));
			}
		}

		yMiddle = BetterMath.mean(yFront, yBack);

		//perspective is defined by its two side vanishing lines
		perspective = new Perspective(
			[xCenter - front_width, yFront] as Array<Float>, [xCenter - back_width, yBack] as Array<Float>,
			[xCenter + front_width, yFront] as Array<Float>, [xCenter + back_width, yBack] as Array<Float>
		);

		//select court boundaries coordinates (clockwise, starting from top left point)
		court = perspective.transformArray(match.getType() == SINGLE ? COURT_SINGLE : COURT_DOUBLE);

		//calculate court corners boundaries coordinates
		var corner_coordinates = match.getType() == SINGLE ? COURT_SINGLE_CORNERS : COURT_DOUBLE_CORNERS;
		corners = {
			OPPONENT_RIGHT => perspective.transformArray(corner_coordinates[OPPONENT_RIGHT]) as Array<Array>,
			OPPONENT_LEFT => perspective.transformArray(corner_coordinates[OPPONENT_LEFT]) as Array<Array>,
			YOU_LEFT => perspective.transformArray(corner_coordinates[YOU_LEFT]) as Array<Array>,
			YOU_RIGHT => perspective.transformArray(corner_coordinates[YOU_RIGHT]) as Array<Array>
		};

		//calculate set positions
		board = new [Match.MAX_SETS] as Array<Array>;
		for(var i = 0; i < Match.MAX_SETS; i++) {
			var y = 0.1 + 0.7 * i / Match.MAX_SETS;
			//dot not align the balls using the real perspective
			//display them parallel to the left side of the court instead
			var transformed_coordinates = perspective.transform([-0.5, y] as Array<Float>);
			board[i] = [transformed_coordinates[0] - SET_BALL_RADIUS * 2, transformed_coordinates[1]];
		}

		//calculate hear rate position
		var hr_center = BetterMath.roundAll(perspective.transform([0.75, 0.6])) as Array<Numeric>;
		//size the icon according to the size of the tiny font
		var size = Math.round(Graphics.getFontHeight(Graphics.FONT_TINY) * 0.2);
		var icon_center = [hr_center[0], hr_center[1] - size * 2];
		//the heart icon is composed of two a-little-more-than-half circles, a triangle, and a rectangle to cover the space between the two circles
		var angle = Math.PI / 4;
		var circle_y_extension = Math.round(size * Math.sin(angle));
		var circle_x_extension = Math.round(size * (1 - Math.cos(angle)));
		hrCoordinates = {
			"center" => hr_center,
			"size" => size,
			"icon_center" => icon_center,
			"circle_y_extension" => circle_y_extension,
			"heart_circle_left" => [icon_center[0] - size, icon_center[1]],
			"heart_circle_right" => [icon_center[0] + size, icon_center[1]],
			"heart_triangle" => [
				[icon_center[0] - 2 * size + circle_x_extension, icon_center[1] + circle_y_extension],
				[icon_center[0] + 2 * size - circle_x_extension, icon_center[1] + circle_y_extension],
				[icon_center[0], icon_center[1] + 2 * size]
			],
			"heart_rectangle" => [
				[icon_center[0] - size / 2, icon_center[1]],
				[icon_center[0] + size / 2, icon_center[1]],
				[icon_center[0] + size / 2, icon_center[1] + size],
				[icon_center[0] - size / 2, icon_center[1] + size]
			]
		};
	}
}

class MatchView extends WatchUi.View {
	const SCORE_PLAYER_1_FONT = Graphics.FONT_LARGE;
	const SCORE_PLAYER_2_FONT = Graphics.FONT_MEDIUM;

	const REFRESH_TIME_ANIMATION = 50;
	const REFRESH_TIME_STANDARD = 1000;
	const ANIMATION_TIME = 800;

	public var boundaries as MatchBoundaries?;

	private var clock24Hour as Boolean;
	private var timeAMLabel as String;
	private var timePMLabel as String;

	private var startTime as Number;
	private var refreshTime = null as Number?;
	private var inAnimation = false;
	private var refreshTimer as Timer.Timer;

	function initialize() {
		View.initialize();
		clock24Hour = System.getDeviceSettings().is24Hour;
		timeAMLabel = WatchUi.loadResource(Rez.Strings.time_am) as String;
		timePMLabel = WatchUi.loadResource(Rez.Strings.time_pm) as String;

		startTime = System.getTimer();
		refreshTimer = new Timer.Timer();
	}

	function calculateBoundaries(elapsed_time as Number?) as Void {
		var match = (Application.getApp() as BadmintonApp).getMatch();
		var device = System.getDeviceSettings();
		boundaries = new MatchBoundaries(match, device, elapsed_time);
	}

	function onShow() as Void {
		(Application.getApp() as BadmintonApp).getBus().register(self);
		inAnimation = Properties.getValue("enable_animation");
		var refresh_time = inAnimation ? REFRESH_TIME_ANIMATION : REFRESH_TIME_STANDARD;
		setRefreshTime(refresh_time);
	}

	function onHide() as Void {
		refreshTimer.stop();
		(Application.getApp() as BadmintonApp).getBus().unregister(self);
	}

	function getElapsedTime() as Number {
		return System.getTimer() - startTime;
	}

	function refresh() as Void {
		WatchUi.requestUpdate();
	}

	function setRefreshTime(time as Number) as Void {
		if(refreshTime != time) {
			refreshTime = time;
			refreshTimer.stop();
			refreshTimer.start(method(:refresh), refreshTime, true);
			System.println("set refresh time to " + time);
		}
	}

	function onUpdateSettings() as Void {
		//recalculate boundaries as they may change if "display time" setting is updated
		//calculate the boundaries as they should be after the animation has ended
		calculateBoundaries(ANIMATION_TIME);
		WatchUi.requestUpdate();
	}

	function drawCourt(dc as Dc, match as Match) as Void {
		//draw background
		dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(boundaries.court);

		//draw serving and receiving corners
		var serving_corner = match.getServingCorner();
		var receiving_corner = match.getReceivingCorner();
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(boundaries.corners[serving_corner] as Array<Array>);
		dc.fillPolygon(boundaries.corners[receiving_corner] as Array<Array>);

		//draw bounds
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		//draw left sideline for doubles
		boundaries.perspective.drawVanishingLine(dc, -0.5);
		//draw left sideline for singles
		boundaries.perspective.drawVanishingLine(dc, -0.5 + MatchBoundaries.COURT_SIDELINE_SIZE);
		//draw middle line in two parts
		boundaries.perspective.drawPartialVanishingLine(dc, 0f, 0f, 0.4);
		boundaries.perspective.drawPartialVanishingLine(dc, 0f, 0.6, 1f);
		//draw right sideline for singles
		boundaries.perspective.drawVanishingLine(dc, 0.5 - MatchBoundaries.COURT_SIDELINE_SIZE);
		//draw right sideline for doubles
		boundaries.perspective.drawVanishingLine(dc, 0.5);

		//draw front long service line for singles
		boundaries.perspective.drawTransversalLine(dc, 0f);
		//draw front long service line for doubles
		boundaries.perspective.drawTransversalLine(dc, MatchBoundaries.COURT_LONG_SERVICE_SIZE);
		//draw front short service line
		boundaries.perspective.drawTransversalLine(dc, 0.5 - MatchBoundaries.COURT_SHORT_SERVICE_SIZE);
		//draw net line
		boundaries.perspective.drawTransversalLine(dc, 0.5);
		//draw back short service line
		boundaries.perspective.drawTransversalLine(dc, 0.5 + MatchBoundaries.COURT_SHORT_SERVICE_SIZE);
		//draw back long service line for doubles
		boundaries.perspective.drawTransversalLine(dc, 1f - MatchBoundaries.COURT_LONG_SERVICE_SIZE);
		//draw back long service line for singles
		boundaries.perspective.drawTransversalLine(dc, 1f);

		//draw a dot for the player 1 (watch carrier) position
		var player_x = match.getPlayerCorner() == YOU_LEFT ? -0.28 : 0.28 as Float;
		var player_coordinates = boundaries.perspective.transform([player_x, 0.12] as Array<Float>) as Array<Float>;
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(player_coordinates[0], player_coordinates[1], 7);
	}

	function drawScores(dc as Dc, match as Match) as Void {
		var set = match.getCurrentSet();
		var server_team = set.getServerTeam();

		var player_1_coordinates = boundaries.perspective.transform([0f, 0.25] as Array<Float>);
		var player_2_coordinates = boundaries.perspective.transform([0f, 0.75] as Array<Float>);
		var player_1_color = server_team == YOU ? Graphics.COLOR_BLUE : Graphics.COLOR_WHITE;
		var player_2_color = server_team == OPPONENT ? Graphics.COLOR_BLUE : Graphics.COLOR_WHITE;
		UIHelpers.drawHighlightedNumber(dc, player_1_coordinates[0], player_1_coordinates[1], SCORE_PLAYER_1_FONT, set.getScore(YOU).toString(), player_1_color, 2, 4);
		UIHelpers.drawHighlightedNumber(dc, player_2_coordinates[0], player_2_coordinates[1], SCORE_PLAYER_2_FONT, set.getScore(OPPONENT).toString(), player_2_color, 2, 4);
	}

	function drawSets(dc as Dc, match as Match) as Void {
		//do not draw sets in endless mode
		if(!match.isEndless()) {
			var maximum_sets = match.getMaximumSets();
			if(maximum_sets > 1) {
				var sets = match.getSets();
				for(var i = 0; i < maximum_sets; i++) {
					var color;
					if(i < sets.size()) {
						var set = sets.get(i) as MatchSet;
						if(set.hasEnded()) {
							var winner = set.getWinner();
							color = winner == YOU ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
						}
						else {
							color = Graphics.COLOR_BLUE;
						}
					}
					else {
						color = Graphics.COLOR_WHITE;
					}
					dc.setColor(color, Graphics.COLOR_TRANSPARENT);
					dc.fillCircle(boundaries.board[i][0] as Float, boundaries.board[i][1] as Float, MatchBoundaries.SET_BALL_RADIUS);
				}
			}
		}
	}

	function drawHeartRate(dc as Dc) as Void {
		var rate = Activity.getActivityInfo().currentHeartRate;

		if(rate != null) {
			var profile = UserProfile.getCurrentSport();
			var zones = UserProfile.getHeartRateZones(profile);

			//choose color for the heart icon depending on the current user zone
			var color = Graphics.COLOR_GREEN;
			if(zones != null && zones.size() > 4) {
				if(rate > zones[4]) {
					color= Graphics.COLOR_RED;
				}
				else if(rate > zones[3]) {
					color = Graphics.COLOR_YELLOW;
				}
			}

			var hr_coordinates = boundaries.hrCoordinates;
			var size = hr_coordinates["size"] as Numeric;
			var icon_center = hr_coordinates["icon_center"] as Array<Numeric>;
			var circle_y_extension = hr_coordinates["circle_y_extension"];
			dc.setColor(color, Graphics.COLOR_TRANSPARENT);
			//draw half circles by clipping the bottom part of full circles
			//add a margin on the top and bottom because rounded coordinates may result in bad clipping
			var margin = 1;
			dc.setClip(
				icon_center[0] as Numeric - size * 2 - margin,
				icon_center[1] as Numeric - size - margin,
				size * 4 + 2 * margin,
				size + circle_y_extension + 2 * margin);
			var heart_circle_left = hr_coordinates["heart_circle_left"] as Array<Numeric>;
			dc.fillCircle(heart_circle_left[0] as Numeric, heart_circle_left[1] as Numeric, size);
			var heart_circle_right = hr_coordinates["heart_circle_right"] as Array<Numeric>;
			dc.fillCircle(heart_circle_right[0] as Numeric, heart_circle_right[1] as Numeric, size);
			dc.clearClip();
			dc.fillPolygon(hr_coordinates["heart_triangle"] as Array<Array>);
			dc.fillPolygon(hr_coordinates["heart_rectangle"] as Array<Array>);
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			var center = hr_coordinates["center"] as Array<Numeric>;
			dc.drawText(center[0], center[1], Graphics.FONT_TINY, rate.toString(), Graphics.TEXT_JUSTIFY_CENTER);
		}
	}

	function drawTimer(dc as Dc, match as Match) as Void {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(
			boundaries.xCenter,
			boundaries.yFront + MatchBoundaries.TIME_HEIGHT * 0.1 as Float,
			Graphics.FONT_SMALL,
			Helpers.formatDuration(match.getDuration()),
			Graphics.TEXT_JUSTIFY_CENTER
		);
	}

	function drawTime(dc as Dc) as Void {
		var time_label = Helpers.formatCurrentTime(clock24Hour, timeAMLabel, timePMLabel);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(
			boundaries.xCenter,
			boundaries.marginHeight - MatchBoundaries.TIME_HEIGHT * 0.1 as Float,
			Graphics.FONT_SMALL,
			time_label,
			Graphics.TEXT_JUSTIFY_CENTER
		);
	}

	function onUpdate(dc as Dc) {
		//when onUpdate is called, the entire view is cleared (hence the badminton court) on some watches (reported by users with vivoactive 4 and venu)
		//in the simulator it's not the case for all watches
		//do not try to update only a part of the view
		//clean the entire screen
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.clear();
		if(dc has :setAntiAlias) {
			dc.setAntiAlias(true);
		}

		var app = (Application.getApp() as BadmintonApp);
		var match = app.getMatch();

		if(inAnimation) {
			var elapsed_time = getElapsedTime();
			if(elapsed_time > ANIMATION_TIME) {
				inAnimation = false;
				setRefreshTime(REFRESH_TIME_STANDARD);
			}
			calculateBoundaries(elapsed_time);
		}
		else if(boundaries == null) {
			calculateBoundaries(null);
		}

		drawCourt(dc, match);

		if(!inAnimation) {
			drawScores(dc, match);
			drawSets(dc, match);
			drawTimer(dc, match);

			if(Properties.getValue("display_time")) {
				drawTime(dc);
			}

			if(Properties.getValue("display_heart_rate")) {
				//disable anti aliasing to draw a pixel perfect icon
				if(dc has :setAntiAlias) {
					dc.setAntiAlias(false);
				}
				drawHeartRate(dc);
			}
		}
	}
}

class MatchViewDelegate extends WatchUi.BehaviorDelegate {

	private var view as MatchView;

	function initialize(v as MatchView) {
		view = v;
		BehaviorDelegate.initialize();
	}

	function onMenu() {
		var menu = new WatchUi.Menu2({:title => Rez.Strings.menu_title});
		menu.addItem(new WatchUi.MenuItem(Rez.Strings.menu_end_game, null, :menu_end_game, null));
		menu.addItem(new WatchUi.MenuItem(Rez.Strings.menu_reset_game, null, :menu_reset_game, null));

		WatchUi.pushView(menu, new MatchMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function manageScore(player as Player) as Boolean {
		var match = (Application.getApp() as BadmintonApp).getMatch();
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
		var match = (Application.getApp() as BadmintonApp).getMatch();
		if(match.getTotalRalliesNumber() > 0) {
			//undo last rally
			match.undo();
			WatchUi.requestUpdate();
		}
		else if(match.getSets().size() == 1) {
			match.discard();
			//return to the initial view if the match has not been started yet
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
