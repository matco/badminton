import Toybox.Lang;
import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.FitContributor;
import Toybox.Time;

enum Player {
	YOU = 1,
	OPPONENT = 2
}

enum MatchType {
	SINGLE = 1,
	DOUBLE = 2
}

enum Corner {
	OPPONENT_RIGHT = 0, //top left corner on the screen
	OPPONENT_LEFT = 1, //top right corner on the screen
	YOU_LEFT = 2, //bottom left corner on the screen
	YOU_RIGHT = 3 //bottom right corner on the screen
}

class MatchConfig {
	public var step as Number = 0;
	public var type as MatchType?;
	public var sets as Number?;
	public var beginner as Player?;
	public var server as Boolean?;
	public var maximumPoints as Number?;
	public var absoluteMaximumPoints as Number?;

	function isValid() as Boolean {
		return type == SINGLE && step == 3 || step == 4;
	}
}

class Match {
	static const MAX_SETS = 5;

	const OPPOSITE_CORNER = {
		OPPONENT_RIGHT => YOU_RIGHT,
		OPPONENT_LEFT => YOU_LEFT,
		YOU_LEFT => OPPONENT_LEFT,
		YOU_RIGHT => OPPONENT_RIGHT
	} as Dictionary<Corner, Corner>;

	const TOTAL_SCORE_PLAYER_1_FIELD_ID = 0;
	const TOTAL_SCORE_PLAYER_2_FIELD_ID = 1;
	const SET_WON_PLAYER_1_FIELD_ID = 2;
	const SET_WON_PLAYER_2_FIELD_ID = 3;
	const SET_SCORE_PLAYER_1_FIELD_ID = 4;
	const SET_SCORE_PLAYER_2_FIELD_ID = 5;
	const RALLY_DURATION_FIELD_ID = 6;
	const RALLY_DURATION_SERVING_FIELD_ID = 7;
	const RALLY_DURATION_RECEIVING_FIELD_ID = 8;

	private var type as MatchType; //type of the match, SINGLE or DOUBLE
	private var maximumSets as Number?; //maximum number of sets for this match, null for match in endless mode
	private var sets as List; //list of played sets

	private var server as Boolean; //in double, true if the watch carrier is the first to serve (among himself and his teammate)
	private var winner as Player?; //store the winner of the match, YOU or OPPONENT
	private var ended as Boolean; //store if the match has ended

	private var maximumPoints as Number;
	private var absoluteMaximumPoints as Number;

	private var stats as MatchStats;

	private var session as Session;
	private var fieldSetPlayer1 as Field;
	private var fieldSetPlayer2 as Field;
	private var fieldSetScorePlayer1 as Field;
	private var fieldSetScorePlayer2 as Field;
	private var fieldScorePlayer1 as Field;
	private var fieldScorePlayer2 as Field;
	private var fieldRallyDuration as Field;
	private var fieldRallyDurationServing as Field;
	private var fieldRallyDurationReceiving as Field;

	function initialize(config as MatchConfig) {
		type = config.type as MatchType;
		maximumSets = config.sets;

		//in singles, the server is necessary the watch carrier
		//in doubles, server is either the watch carrier or his teammate
		server = config.type == DOUBLE ? config.server as Boolean : true;

		ended = false;

		//prepare array of sets and create first set
		sets = new List();
		sets.push(new MatchSet(type, config.beginner as Player, server));

		maximumPoints = config.maximumPoints as Number;
		absoluteMaximumPoints = config.absoluteMaximumPoints as Number;

		//determine sport and subsport
		//it would be better to use feature detection instead of checking the version, but this does not work, see IQTest.mc
		var version = System.getDeviceSettings().monkeyVersion;
		var v410 = version[0] > 4 || version[0] == 4 && version[1] >= 1;
		var sport = v410 ? Activity.SPORT_RACKET : ActivityRecording.SPORT_GENERIC;
		var sub_sport = v410 ? Activity.SUB_SPORT_BADMINTON : ActivityRecording.SUB_SPORT_MATCH;

		//manage activity session
		session = ActivityRecording.createSession({:sport => sport, :subSport => sub_sport, :name => WatchUi.loadResource(Rez.Strings.fit_activity_name) as String});
		fieldSetPlayer1 = session.createField("set_player_1", SET_WON_PLAYER_1_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_set_unit_label) as String});
		fieldSetPlayer2 = session.createField("set_player_2", SET_WON_PLAYER_2_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_set_unit_label) as String});
		fieldScorePlayer1 = session.createField("score_player_1", TOTAL_SCORE_PLAYER_1_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label) as String});
		fieldScorePlayer2 = session.createField("score_player_2", TOTAL_SCORE_PLAYER_2_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label) as String});
		fieldSetScorePlayer1 = session.createField("set_score_player_1", SET_SCORE_PLAYER_1_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_LAP, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label) as String});
		fieldSetScorePlayer2 = session.createField("set_score_player_2", SET_SCORE_PLAYER_2_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_LAP, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label) as String});
		fieldRallyDuration = session.createField("rally_duration", RALLY_DURATION_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_duration_label) as String});
		fieldRallyDurationServing = session.createField("rally_duration_serving", RALLY_DURATION_SERVING_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_duration_label) as String});
		fieldRallyDurationReceiving = session.createField("rally_duration_receiving", RALLY_DURATION_RECEIVING_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_duration_label) as String});
		session.start();

		(Application.getApp() as BadmintonApp).getBus().dispatch(new BusEvent(:onMatchBegin, null));
	}

	function save() as Void {
		//session can only be save once
		session.save();
	}

	function discard() as Void {
		session.discard();
	}

	function end(winner_player as Player?) as Void {
		if(hasEnded()) {
			throw new OperationNotAllowedException("Unable to end a match that has already been ended");
		}
		ended = true;

		var you_sets_won = getSetsWon(YOU);
		var opponent_sets_won = getSetsWon(OPPONENT);
		var you_total_score = getTotalScore(YOU);
		var opponent_total_score = getTotalScore(OPPONENT);

		//in endless mode, the winner must be determined now
		if(isEndless()) {
			//determine winner based on sets
			if(you_sets_won != opponent_sets_won) {
				winner = you_sets_won > opponent_sets_won ? YOU : OPPONENT;
			}
			//determine winner based on total score
			if(winner == null && you_total_score != opponent_total_score) {
				winner = you_total_score > opponent_total_score ? YOU : OPPONENT;
			}
		}
		else {
			winner = winner_player;
		}

		//manage activity session
		fieldSetPlayer1.setData(you_sets_won);
		fieldSetPlayer2.setData(opponent_sets_won);
		fieldScorePlayer1.setData(you_total_score);
		fieldScorePlayer2.setData(opponent_total_score);

		calculateStats();

		System.println(stats.averageRallyDuration);
		System.println(stats.averageRallyDurationServing);
		System.println(stats.averageRallyDurationReceiving);
		fieldRallyDuration.setData(stats.averageRallyDuration);
		//duration may be null if the player did not serve any rally
		if(stats.averageRallyDurationServing != null) {
			fieldRallyDurationServing.setData(stats.averageRallyDurationServing);
		}
		//duration may be null if the player did not receive any rally
		if(stats.averageRallyDurationReceiving != null) {
			fieldRallyDurationReceiving.setData(stats.averageRallyDurationReceiving);
		}
		session.stop();

		//encapsulate event payload in an object so this object can never be null
		var event = new BusEvent(:onMatchEnd, {"winner" => winner});
		(Application.getApp() as BadmintonApp).getBus().dispatch(event);
	}

	function nextSet() as Void {
		var set = getCurrentSet();

		if(!set.hasEnded()) {
			throw new OperationNotAllowedException("Unable to start next set if current set has not ended");
		}

		//manage activity session
		session.addLap();

		//the player who won the previous game will serve first in the next set
		var beginner = set.getWinner();

		//create next set
		sets.push(new MatchSet(type, beginner as Player, server));
	}

	function getMaximumSets() as Number? {
		return maximumSets;
	}

	function getCurrentSet() as MatchSet {
		return sets.last() as MatchSet;
	}

	function score(scorer as Player) as Void {
		if(hasEnded()) {
			throw new OperationNotAllowedException("Unable to score in a match that has ended");
		}
		var set = getCurrentSet();
		set.score(scorer);

		//manage activity session
		//remember that the match can be ended anytime (if the user decides to stop it)
		//the activity must always be kept up to date
		fieldSetScorePlayer1.setData(set.getScore(YOU));
		fieldSetScorePlayer2.setData(set.getScore(OPPONENT));

		//end the set if it has been won
		var set_winner = isSetWon(set);
		if(set_winner != null) {
			set.end(set_winner);

			if(!isEndless()) {
				var match_winner = isWon();
				if(match_winner != null) {
					end(match_winner);
				}
			}
		}
	}

	private function isSetWon(set as MatchSet) as Player? {
		var scorePlayer1 = set.getScore(YOU);
		var scorePlayer2 = set.getScore(OPPONENT);
		if(scorePlayer1 >= absoluteMaximumPoints || scorePlayer1 >= maximumPoints && (scorePlayer1 - scorePlayer2) > 1) {
			return YOU;
		}
		if(scorePlayer2 >= absoluteMaximumPoints || scorePlayer2 >= maximumPoints && (scorePlayer2 - scorePlayer1) > 1) {
			return OPPONENT;
		}
		return null;
	}

	private function isWon() as Player? {
		//in endless mode, no winner can be determined wile the match has not been ended
		if(isEndless()) {
			return null;
		}
		var winning_sets = maximumSets as Number / 2; //if not in endless mode, maximum sets cannot be null
		var player_1_sets = getSetsWon(YOU);
		if(player_1_sets > winning_sets) {
			return YOU;
		}
		var player_2_sets = getSetsWon(OPPONENT);
		if(player_2_sets > winning_sets) {
			return OPPONENT;
		}
		return null;
	}

	function undo() as Void {
		var set = getCurrentSet();
		if(set.getRallies().size() > 0) {
			ended = false;
			winner = null;
			set.undo();
		}
	}

	function getDuration() as Duration {
		var info = Activity.getActivityInfo() as Info;
		var time = info.elapsedTime;
		var seconds = time != null ? time / 1000 : 0;
		return new Time.Duration(seconds);
	}

	function getType() as MatchType {
		return type;
	}

	function isEndless() as Boolean {
		return maximumSets == null;
	}

	function getSets() as List {
		return sets;
	}

	function hasEnded() as Boolean {
		return ended;
	}

	function getTotalRalliesNumber() as Number {
		var number = 0;
		for(var i = 0; i < sets.size(); i++) {
			var set = sets.get(i) as MatchSet;
			number += set.getRalliesNumber();
		}
		return number;
	}

	function getTotalScore(player as Player) as Number {
		var score = 0;
		for(var i = 0; i < sets.size(); i++) {
			var set = sets.get(i) as MatchSet;
			score += set.getScore(player);
		}
		return score;
	}

	function getSetsWon(player as Player) as Number {
		var won = 0;
		for(var i = 0; i < sets.size(); i++) {
			var set = sets.get(i) as MatchSet;
			if(set.getWinner() == player) {
				won++;
			}
		}
		return won;
	}

	function getWinner() as Player? {
		return winner;
	}

	function getServerTeam() as Player {
		return getCurrentSet().getServerTeam();
	}

	function getServingCorner() as Corner {
		return getCurrentSet().getServingCorner();
	}

	function getReceivingCorner() as Corner {
		var serving_corner = getServingCorner();
		return OPPOSITE_CORNER[serving_corner] as Corner;
	}

	function getPlayerIsServer() as Boolean {
		return getPlayerCorner() == getServingCorner();
	}

	//methods used from perspective of player 1 (watch carrier)
	function getPlayerTeamIsServer() as Boolean {
		return getServerTeam() == YOU;
	}

	function getPlayerCorner() as Corner {
		return getCurrentSet().getPlayerCorner();
	}

	function calculateStats() as Void {
		var count = 0;
		var count_serving = 0;
		var count_receiving = 0;

		var duration_rallies = 0;
		var duration_rallies_serving = 0;
		var duration_rallies_receiving = 0;

		var winning_serving = 0;
		var winning_receiving = 0;

		var sets = getSets();
		for(var i = 0; i < sets.size(); i++) {
			var rallies = sets.get(i).getRallies();
			count += rallies.size();
			for(var j = 0; j < rallies.size(); j++) {
				var rally = rallies.get(j);
				if(rally.hasEnded()) {
					duration_rallies += rally.getDuration();
					if(rally.getBeginner() == YOU) {
						count_serving++;
						duration_rallies_serving += rally.getDuration();
						if(rally.getWinner() == YOU) {
							winning_serving++;
						}
					}
					else {
						count_receiving++;
						duration_rallies_receiving += rally.getDuration();
						if(rally.getWinner() == YOU) {
							winning_receiving++;
						}
					}
				}
			}
		}

		stats = new MatchStats();
		stats.averageRallyDuration = duration_rallies / count;
		stats.averageRallyDurationServing = count_serving > 0 ? Math.round(duration_rallies_serving / count_serving) : null;
		stats.averageRallyDurationReceiving = count_receiving > 0 ? Math.round(duration_rallies_receiving / count_receiving) : null;
		stats.percentageWinningServing = count_serving > 0 ? Math.round(100 * winning_serving / count_serving) : null;
		stats.percentageWinningReceiving = count_receiving > 0 ? Math.round(100 * winning_receiving / count_receiving) : null;
	}

	function getStats() as MatchStats {
		return stats;
	}
}
