import Toybox.Lang;
import Toybox.Timer;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Activity;
using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.UserProfile;

class MatchBoundaries {
	static const COURT_WIDTH_RATIO = 0.6; //width of the back compared to the front of the court
	static const COURT_SIDELINE_SIZE = 0.1;
	static const COURT_LONG_SERVICE_SIZE = 0.05;
	static const COURT_SHORT_SERVICE_SIZE = 0.1;
	//court boundaries coordinates (clockwise, starting from top left point)
	static const COURT_SINGLE = [
		[-0.5 + COURT_SIDELINE_SIZE, 1f],
		[0.5 - COURT_SIDELINE_SIZE, 1f],
		[0.5 - COURT_SIDELINE_SIZE, 0f],
		[-0.5 + COURT_SIDELINE_SIZE, 0f]
	] as Array<Point2D>;
	static const COURT_DOUBLE = [
		[-0.5, 1f],
		[0.5, 1f],
		[0.5, 0f],
		[-0.5, 0f]
	] as Array<Point2D>;
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
		//USER_LEFT is the bottom left corner
		USER_LEFT => [
			[-0.5 + COURT_SIDELINE_SIZE, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0, 0],
			[-0.5 + COURT_SIDELINE_SIZE, 0]
		],
		//USER_RIGHT is the bottom right corner
		USER_RIGHT => [
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
		//USER_LEFT is the bottom left corner
		USER_LEFT => [
			[-0.5, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0, 0.5 - COURT_SHORT_SERVICE_SIZE],
			[0, COURT_LONG_SERVICE_SIZE],
			[-0.5, COURT_LONG_SERVICE_SIZE]
		],
		//USER_RIGHT is the bottom right corner
		USER_RIGHT => [
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

	public var court as Array<Point2D>;
	public var corners as Dictionary<Corner, Array<Point2D>>;
	public var board as Array<Point2D>;

	public var heart as Heart;

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

		yMiddle = BetterMath.mean(yFront, yBack) as Float;

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
			OPPONENT_RIGHT => perspective.transformArray(corner_coordinates[OPPONENT_RIGHT] as Array<Point2D>),
			OPPONENT_LEFT => perspective.transformArray(corner_coordinates[OPPONENT_LEFT] as Array<Point2D>),
			USER_LEFT => perspective.transformArray(corner_coordinates[USER_LEFT] as Array<Point2D>),
			USER_RIGHT => perspective.transformArray(corner_coordinates[USER_RIGHT] as Array<Point2D>)
		} as Dictionary<Corner, Array<Point2D>>;

		//calculate set positions
		board = new [Match.MAX_SETS] as Array<Point2D>;
		for(var i = 0; i < Match.MAX_SETS; i++) {
			var y = 0.1 + 0.7 * i / Match.MAX_SETS;
			//dot not align the balls using the real perspective
			//display them parallel to the left side of the court instead
			var transformed_coordinates = perspective.transform([-0.5, y]);
			board[i] = [transformed_coordinates[0] - SET_BALL_RADIUS * 2, transformed_coordinates[1]];
		}

		//calculate hear rate position
		var heart_coordinates = BetterMath.roundAll(perspective.transform([0.75, 0.6])) as Point2D;
		//size the icon according to the size of the tiny font
		var size = Math.round(Graphics.getFontHeight(Graphics.FONT_TINY) * 0.2);
		heart = new Heart({
			:locX => heart_coordinates[0],
			:locY => heart_coordinates[1] - size * 2,
			:size => size
		});
	}
}

class MatchView extends WatchUi.View {
	const SCORE_PLAYER_1_FONT = Graphics.FONT_LARGE;
	const SCORE_PLAYER_2_FONT = Graphics.FONT_MEDIUM;

	const REFRESH_TIME_ANIMATION = 50;
	const REFRESH_TIME_STANDARD = 1000;
	static const ANIMATION_TIME = 800;

	public var boundaries as MatchBoundaries?;

	private var match as Match;

	private var clock24Hour as Boolean;
	private var timeAMLabel as String;
	private var timePMLabel as String;

	private var startTime as Number;
	private var refreshTime as Number = REFRESH_TIME_STANDARD;
	private var enableAnimation as Boolean;
	private var inAnimation as Boolean = false;
	private var refreshTimer as Timer.Timer;

	function initialize(disable_animation as Boolean) {
		View.initialize();
		match = (Application.getApp() as BadmintonApp).getMatch() as Match;

		clock24Hour = System.getDeviceSettings().is24Hour;
		timeAMLabel = WatchUi.loadResource(Rez.Strings.time_am) as String;
		timePMLabel = WatchUi.loadResource(Rez.Strings.time_pm) as String;

		startTime = System.getTimer();
		refreshTimer = new Timer.Timer();

		enableAnimation = Properties.getValue("enable_animation") as Boolean && !disable_animation;
	}

	function calculateBoundaries(elapsed_time as Number?) as Void {
		var device = System.getDeviceSettings();
		boundaries = new MatchBoundaries(match, device, elapsed_time);
	}

	function onShow() as Void {
		(Application.getApp() as BadmintonApp).getBus().register(self);
		inAnimation = enableAnimation;
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
		refreshTime = time;
		refreshTimer.stop();
		refreshTimer.start(method(:refresh), refreshTime, true);
		System.println("set refresh time to " + time);
	}

	function onUpdateSettings() as Void {
		//recalculate boundaries as they may change if "display time" setting is updated
		//calculate the boundaries as they should be after the animation has ended
		calculateBoundaries(ANIMATION_TIME);
		WatchUi.requestUpdate();
	}

	function drawCourt(dc as Dc, match as Match) as Void {
		//boundaries cannot be null at this point
		var bd = boundaries as MatchBoundaries;

		//draw background
		dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(bd.court);

		//draw serving and receiving corners
		var serving_corner = match.getServingCorner();
		var receiving_corner = match.getReceivingCorner();
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(bd.corners[serving_corner] as Array<Point2D>);
		dc.fillPolygon(bd.corners[receiving_corner] as Array<Point2D>);

		//draw bounds
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		//draw left sideline for doubles
		bd.perspective.drawVanishingLine(dc, -0.5);
		//draw left sideline for singles
		bd.perspective.drawVanishingLine(dc, -0.5 + MatchBoundaries.COURT_SIDELINE_SIZE);
		//draw middle line in two parts
		bd.perspective.drawPartialVanishingLine(dc, 0f, 0f, 0.4);
		bd.perspective.drawPartialVanishingLine(dc, 0f, 0.6, 1f);
		//draw right sideline for singles
		bd.perspective.drawVanishingLine(dc, 0.5 - MatchBoundaries.COURT_SIDELINE_SIZE);
		//draw right sideline for doubles
		bd.perspective.drawVanishingLine(dc, 0.5);

		//draw front long service line for singles
		bd.perspective.drawTransversalLine(dc, 0f);
		//draw front long service line for doubles
		bd.perspective.drawTransversalLine(dc, MatchBoundaries.COURT_LONG_SERVICE_SIZE);
		//draw front short service line
		bd.perspective.drawTransversalLine(dc, 0.5 - MatchBoundaries.COURT_SHORT_SERVICE_SIZE);
		//draw net line
		bd.perspective.drawTransversalLine(dc, 0.5);
		//draw back short service line
		bd.perspective.drawTransversalLine(dc, 0.5 + MatchBoundaries.COURT_SHORT_SERVICE_SIZE);
		//draw back long service line for doubles
		bd.perspective.drawTransversalLine(dc, 1f - MatchBoundaries.COURT_LONG_SERVICE_SIZE);
		//draw back long service line for singles
		bd.perspective.drawTransversalLine(dc, 1f);

		//draw a dot for the user position
		var player_x = match.getUserCorner() == USER_LEFT ? -0.28 : 0.28 as Float;
		var player_coordinates = bd.perspective.transform([player_x, 0.12] as Point2D);
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(player_coordinates[0], player_coordinates[1], 7);
	}

	function drawScores(dc as Dc, match as Match) as Void {
		var set = match.getCurrentSet();
		var server_team = set.getServerTeam();

		//boundaries cannot be null at this point
		var bd = boundaries as MatchBoundaries;

		var player_1_coordinates = bd.perspective.transform([0f, 0.25] as Point2D);
		var player_2_coordinates = bd.perspective.transform([0f, 0.75] as Point2D);
		var player_1_color = server_team == USER ? Graphics.COLOR_BLUE : Graphics.COLOR_WHITE;
		var player_2_color = server_team == OPPONENT ? Graphics.COLOR_BLUE : Graphics.COLOR_WHITE;
		UIHelpers.drawHighlightedNumber(dc, player_1_coordinates[0], player_1_coordinates[1], SCORE_PLAYER_1_FONT, set.getScore(USER).toString(), player_1_color, 2, 4);
		UIHelpers.drawHighlightedNumber(dc, player_2_coordinates[0], player_2_coordinates[1], SCORE_PLAYER_2_FONT, set.getScore(OPPONENT).toString(), player_2_color, 2, 4);
	}

	function drawSets(dc as Dc, match as Match) as Void {
		//do not draw sets in endless mode
		if(!match.isEndless()) {
			//if not in endless mode, maximum sets cannot be null
			var maximum_sets = match.getMaximumSets() as Number;
			if(maximum_sets > 1) {
				var sets = match.getSets();

				//boundaries cannot be null at this point
				var bd = boundaries as MatchBoundaries;

				for(var i = 0; i < maximum_sets; i++) {
					var color;
					if(i < sets.size()) {
						var set = sets.get(i) as MatchSet;
						if(set.hasEnded()) {
							var winner = set.getWinner();
							color = winner == USER ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
						}
						else {
							color = Graphics.COLOR_BLUE;
						}
					}
					else {
						color = Graphics.COLOR_WHITE;
					}
					dc.setColor(color, Graphics.COLOR_TRANSPARENT);
					dc.fillCircle(bd.board[i][0] as Float, bd.board[i][1] as Float, MatchBoundaries.SET_BALL_RADIUS);
				}
			}
		}
	}

	function drawTimer(dc as Dc, match as Match) as Void {
		//boundaries cannot be null at this point
		var bd = boundaries as MatchBoundaries;

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(
			bd.xCenter,
			bd.yFront + MatchBoundaries.TIME_HEIGHT * 0.1 as Float,
			Graphics.FONT_SMALL,
			Helpers.formatDuration(match.getDuration()),
			Graphics.TEXT_JUSTIFY_CENTER
		);
	}

	function drawTime(dc as Dc) as Void {
		//boundaries cannot be null at this point
		var bd = boundaries as MatchBoundaries;

		var time_label = Helpers.formatCurrentTime(clock24Hour, timeAMLabel, timePMLabel);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(
			bd.xCenter,
			bd.marginHeight - MatchBoundaries.TIME_HEIGHT * 0.1 as Float,
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
				//boundaries cannot be null at this point
				var bd = boundaries as MatchBoundaries;
				bd.heart.draw(dc);
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
		menu.addItem(new WatchUi.MenuItem(Rez.Strings.menu_resume_match, null, :menu_resume_match, null));
		menu.addItem(new WatchUi.MenuItem(Rez.Strings.menu_resume_match_later, null, :menu_resume_match_later, null));
		menu.addItem(new WatchUi.MenuItem(Rez.Strings.menu_end_match, null, :menu_end_match, null));
		menu.addItem(new WatchUi.MenuItem(Rez.Strings.menu_reset_match, null, :menu_reset_match, null));
		menu.addItem(new WatchUi.MenuItem(Rez.Strings.menu_exit, null, :menu_exit, null));

		WatchUi.pushView(menu, new MatchMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onKey(event as WatchUi.KeyEvent) {
		if(event.getKey() == KEY_ENTER) {
			return onMenu();
		}
		return false;
	}

	function manageScore(team as Team) as Boolean {
		var match = (Application.getApp() as BadmintonApp).getMatch() as Match;
		match.score(team);
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
		//user team scores
		return manageScore(USER);
	}

	function onPreviousPage() {
		//opponent team scores
		return manageScore(OPPONENT);
	}

	//undo last action
	function onBack() {
		var match = (Application.getApp() as BadmintonApp).getMatch() as Match;
		if(match.getTotalRalliesNumber() > 0) {
			//undo last rally
			match.undo();
			WatchUi.requestUpdate();
		}
		else if(match.getSets().size() == 1) {
			if(match.hasWarmup()) {
				//do not try to get back to the warmup phase
				//ending the warmup added a lap in the activity, so it is not possible to go back
				//ask for confirmation before discarding the match
				//user may not want to loose the warmup phase
				var discard_match_confirmation = new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.discard_match) as String);
				WatchUi.pushView(discard_match_confirmation, new DiscardMatchConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			else {
				//the match can be discarded without configuration because it has not been started yet
				match.discard();
				//return to the initial view
				WatchUi.switchToView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
		return true;
	}

	function onTap(event) {
		if(view.boundaries != null) {
			//boundaries cannot be null at this point
			var bd = view.boundaries as MatchBoundaries;
			if(event.getCoordinates()[1] < bd.yMiddle) {
				//opponent team scores
				manageScore(OPPONENT);
			}
			else {
				//user team scores
				manageScore(USER);
			}
		}
		return true;
	}
}
