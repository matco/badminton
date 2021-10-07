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

	private var type as MatchType; //type of the match, SINGLE or DOUBLE
	private var sets as Array<MatchSet?>; //array of all sets, containing null for a set not played

	private var server as Boolean; //in double, true if the player 1 (watch carrier) is currently the server
	private var winner as Player?; //store the winner of the match, YOU or OPPONENT

	private var maximumPoints as Number;
	private var absoluteMaximumPoints as Number;

	private var session as Session;
	private var fieldSetPlayer1 as Field;
	private var fieldSetPlayer2 as Field;
	private var fieldSetScorePlayer1 as Field;
	private var fieldSetScorePlayer2 as Field;
	private var fieldScorePlayer1 as Field;
	private var fieldScorePlayer2 as Field;

	function initialize(config as MatchConfig) {
		type = config.type as MatchType;

		//in singles, the server is necessary the watch carrier
		//in doubles, server is either the watch carrier or his teammate
		server = config.type == DOUBLE ? config.server as Boolean : true;

		//prepare array of sets and create first set
		sets = new [config.sets] as Array<MatchSet?>;
		sets[0] = new MatchSet(config.beginner as Player);
		for(var i = 1; i < config.sets as Number; i++) {
			sets[i] = null;
		}

		maximumPoints = config.maximumPoints as Number;
		absoluteMaximumPoints = config.absoluteMaximumPoints as Number;

		//manage activity session
		session = ActivityRecording.createSession({:sport => ActivityRecording.SPORT_GENERIC, :subSport => ActivityRecording.SUB_SPORT_MATCH, :name => WatchUi.loadResource(Rez.Strings.fit_activity_name) as String});
		fieldSetPlayer1 = session.createField("set_player_1", SET_WON_PLAYER_1_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_set_unit_label) as String});
		fieldSetPlayer2 = session.createField("set_player_2", SET_WON_PLAYER_2_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_set_unit_label) as String});
		fieldScorePlayer1 = session.createField("score_player_1", TOTAL_SCORE_PLAYER_1_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label) as String});
		fieldScorePlayer2 = session.createField("score_player_2", TOTAL_SCORE_PLAYER_2_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label) as String});
		fieldSetScorePlayer1 = session.createField("set_score_player_1", SET_SCORE_PLAYER_1_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_LAP, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label) as String});
		fieldSetScorePlayer2 = session.createField("set_score_player_2", SET_SCORE_PLAYER_2_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_LAP, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label) as String});
		session.start();

		(Application.getApp() as BadmintonScoreTrackerApp).getBus().dispatch(new BusEvent(:onMatchBegin, null));
	}

	function save() as Void {
		//session can only be save once
		session.save();
	}

	function discard() as Void {
		session.discard();
	}

	hidden function end(winner_player as Player) as Void {
		winner = winner_player;
		var event = new BusEvent(:onMatchEnd, winner as Object);
		(Application.getApp() as BadmintonScoreTrackerApp).getBus().dispatch(event);
	}

	function nextSet() as Void {
		//manage activity session
		session.addLap();

		//the player who won the previous game will serve first in the next set
		var i = getCurrentSetIndex();
		var beginner = (sets[i] as MatchSet).getWinner();

		//create next set
		sets[i +1] = new MatchSet(beginner as Player);
	}

	function getSetsNumber() as Number {
		return sets.size();
	}

	function getCurrentSetIndex() as Number {
		var i = 0;
		while(i < sets.size() && sets[i] != null) {
			i++;
		}
		return i - 1;
	}

	function getCurrentSet() as MatchSet {
		return sets[getCurrentSetIndex()] as MatchSet;
	}

	function score(scorer as Player) as Void {
		if(!hasEnded()) {
			var set = getCurrentSet();
			set.score(scorer);

			//detect if match has a set winner
			var set_winner = isSetWon(set);
			if(set_winner != null) {
				set.end(set_winner);

				//manage activity session
				fieldSetScorePlayer1.setData(set.getScore(YOU));
				fieldSetScorePlayer2.setData(set.getScore(OPPONENT));

				var match_winner = isWon();
				if(match_winner != null) {
					end(match_winner);

					//manage activity session
					fieldSetPlayer1.setData(getSetsWon(YOU));
					fieldSetPlayer2.setData(getSetsWon(OPPONENT));
					fieldScorePlayer1.setData(getTotalScore(YOU));
					fieldScorePlayer2.setData(getTotalScore(OPPONENT));
					session.stop();
				}
			}
		}
	}

	hidden function isSetWon(set as MatchSet) as Player? {
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

	hidden function isWon() as Player? {
		var winning_sets = sets.size() / 2;
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
			winner = null;
			set.undo();
		}
	}

	function getActivity() as Info {
		return Activity.getActivityInfo();
	}

	function getDuration() as Duration {
		var time = getActivity().elapsedTime;
		var seconds = time != null ? time / 1000 : 0;
		return new Time.Duration(seconds);
	}

	function getType() as MatchType {
		return type;
	}

	function getSets() as Array<MatchSet?> {
		return sets;
	}

	function hasEnded() as Boolean {
		return winner != null;
	}

	function getTotalRalliesNumber() as Number {
		var i = 0;
		var number = 0;
		while(i < sets.size() && sets[i] != null) {
			number += (sets[i] as MatchSet).getRalliesNumber();
			i++;
		}
		return number;
	}

	function getTotalScore(player as Player) as Number {
		var score = 0;
		for(var i = 0; i <= getCurrentSetIndex(); i++) {
			score = score + (sets[i] as MatchSet).getScore(player);
		}
		return score;
	}

	function getSetsWon(player as Player) as Number {
		var won = 0;
		for(var i = 0; i <= getCurrentSetIndex(); i++) {
			if((sets[i] as MatchSet).getWinner() == player) {
				won++;
			}
		}
		return won;
	}

	function getWinner() as Player {
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
		return OPPOSITE_CORNER[serving_corner];
	}

	function getPlayerIsServer() as Boolean {
		var player_corner = getPlayerCorner();
		return player_corner == getServingCorner();
	}

	//methods used from perspective of player 1 (watch carrier)
	function getPlayerTeamIsServer() as Boolean {
		return getServerTeam() == YOU;
	}

	function getPlayerCorner() as Corner {
		var current_set = getCurrentSet();
		//in singles, the player 1 (watch carrier) position only depends on the current score
		if(type == SINGLE) {
			var server = current_set.getServerTeam();
			var server_score = current_set.getScore(server);
			return server_score % 2 == 0 ? YOU_RIGHT : YOU_LEFT;
		}
		//in doubles, it's not possible to give the position using only the current score
		//remember that the one who serves changes each time the team gains the service (winning a rally while not serving)
		var beginner = current_set.getBeginner();
		var rallies = current_set.getRallies();
		//initialize the corner differently depending on which team begins the set and which player starts to serve
		//while the player 1 team (watch carrier) did not get a service, the position of the player depends on who has been configured to serve first (among the player and his teammate)
		var corner = beginner == YOU ? server ? YOU_RIGHT : YOU_LEFT : server ? YOU_LEFT : YOU_RIGHT;
		for(var i = 0; i < rallies.size(); i++) {
			var previous_rally = i > 0 ? rallies.get(i - 1) : beginner;
			var current_rally = rallies.get(i);
			if(previous_rally == current_rally && current_rally == YOU) {
				corner = corner == YOU_RIGHT ? YOU_LEFT : YOU_RIGHT;
			}
		}
		return corner;
	}
}
