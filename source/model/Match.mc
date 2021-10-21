using Toybox.Time;
using Toybox.ActivityRecording;
using Toybox.Activity;
using Toybox.FitContributor;
using Toybox.WatchUi;

enum Player {
	YOU = 1,
	OPPONENT = 2
}

enum MatchType {
	SINGLE = 1,
	DOUBLE = 2
}

class MatchConfig {
	public var step = 0;
	public var type;
	public var sets;
	public var beginner;
	public var server;
	public var maximumPoints;
	public var absoluteMaximumPoints;

	function isValid() {
		return type == SINGLE && step == 3 || step == 4;
	}
}

class Match {
	static const MAX_SETS = 5;

	const TOTAL_SCORE_PLAYER_1_FIELD_ID = 0;
	const TOTAL_SCORE_PLAYER_2_FIELD_ID = 1;
	const SET_WON_PLAYER_1_FIELD_ID = 2;
	const SET_WON_PLAYER_2_FIELD_ID = 3;
	const SET_SCORE_PLAYER_1_FIELD_ID = 4;
	const SET_SCORE_PLAYER_2_FIELD_ID = 5;

	private var type; //type of the match, SINGLE or DOUBLE
	private var sets; //array of all sets, containing null for a set not played

	private var server; //in double, true if the player 1 (watch carrier) is currently the server
	private var winner; //store the winner of the match, YOU or OPPONENT

	private var maximum_points;
	private var absolute_maximum_points;

	private var session;
	private var session_field_set_player_1;
	private var session_field_set_player_2;
	private var session_field_set_score_player_1;
	private var session_field_set_score_player_2;
	private var session_field_score_player_1;
	private var session_field_score_player_2;

	function initialize(config) {
		type = config.type;

		//server is either the watch carrier ot his teammate
		//if the player 1 (watch carrier) does not start the match, inverse the server because this boolean is toggled each time the serve changes side
		server = config.beginner == YOU ? config.server : !config.server;

		//prepare array of sets and create first set
		sets = new [config.sets];
		sets[0] = new MatchSet(config.beginner);
		for(var i = 1; i < config.sets; i++) {
			sets[i] = null;
		}

		maximum_points = config.maximumPoints;
		absolute_maximum_points = config.absoluteMaximumPoints;

		//manage activity session
		session = ActivityRecording.createSession({:sport => ActivityRecording.SPORT_GENERIC, :subSport => ActivityRecording.SUB_SPORT_MATCH, :name => WatchUi.loadResource(Rez.Strings.fit_activity_name)});
		session_field_set_player_1 = session.createField("set_player_1", SET_WON_PLAYER_1_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_set_unit_label)});
		session_field_set_player_2 = session.createField("set_player_2", SET_WON_PLAYER_2_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_set_unit_label)});
		session_field_score_player_1 = session.createField("score_player_1", TOTAL_SCORE_PLAYER_1_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label)});
		session_field_score_player_2 = session.createField("score_player_2", TOTAL_SCORE_PLAYER_2_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label)});
		session_field_set_score_player_1 = session.createField("set_score_player_1", SET_SCORE_PLAYER_1_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_LAP, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label)});
		session_field_set_score_player_2 = session.createField("set_score_player_2", SET_SCORE_PLAYER_2_FIELD_ID, FitContributor.DATA_TYPE_SINT8, {:mesgType => FitContributor.MESG_TYPE_LAP, :units => WatchUi.loadResource(Rez.Strings.fit_score_unit_label)});
		session.start();

		Application.getApp().getBus().dispatch(new BusEvent(:onMatchBegin, null));
	}

	function save() {
		//session can only be save once
		session.save();
	}

	function discard() {
		session.discard();
	}

	hidden function end(winner_player) {
		winner = winner_player;

		Application.getApp().getBus().dispatch(new BusEvent(:onMatchEnd, winner));
	}

	function nextSet() {
		//manage activity session
		session.addLap();

		//the player who won the previous game will serve first in the next set
		var i = getCurrentSetIndex();
		var beginner = sets[i].getWinner();

		//create next set
		sets[i +1] = new MatchSet(beginner);
	}

	function getSetsNumber() {
		return sets.size();
	}

	function getCurrentSetIndex() {
		var i = 0;
		while(i < sets.size() && sets[i] != null) {
			i++;
		}
		return i - 1;
	}

	function getCurrentSet() {
		return sets[getCurrentSetIndex()];
	}

	function score(scorer) {
		if(!hasEnded()) {
			var set = getCurrentSet();
			var previous_rally = set.getRallies().last();
			set.score(scorer);

			//in double, change server if player 1 (watch carrier) team regains service
			if(type == DOUBLE) {
				if(previous_rally == OPPONENT && scorer == YOU) {
					server = !server;
				}
			}

			//detect if match has a set winner
			var set_winner = isSetWon(set);
			if(set_winner != null) {
				set.end(set_winner);

				//manage activity session
				session_field_set_score_player_1.setData(set.getScore(YOU));
				session_field_set_score_player_2.setData(set.getScore(OPPONENT));

				var match_winner = isWon();
				if(match_winner != null) {
					end(match_winner);

					//manage activity session
					session_field_set_player_1.setData(getSetsWon(YOU));
					session_field_set_player_2.setData(getSetsWon(OPPONENT));
					session_field_score_player_1.setData(getTotalScore(YOU));
					session_field_score_player_2.setData(getTotalScore(OPPONENT));
					session.stop();
				}
			}
		}
	}

	hidden function isSetWon(set) {
		var scorePlayer1 = set.getScore(YOU);
		var scorePlayer2 = set.getScore(OPPONENT);
		if(scorePlayer1 >= absolute_maximum_points || scorePlayer1 >= maximum_points && (scorePlayer1 - scorePlayer2) > 1) {
			return YOU;
		}
		if(scorePlayer2 >= absolute_maximum_points || scorePlayer2 >= maximum_points && (scorePlayer2 - scorePlayer1) > 1) {
			return OPPONENT;
		}
		return null;
	}

	hidden function isWon() {
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

	function undo() {
		winner = null;

		var set = getCurrentSet();
		var undone_rally = set.getRallies().last();
		set.undo();

		//in double, change server if player 1 (watch carrier) team looses service
		if(type == DOUBLE) {
			if(undone_rally == YOU && set.getRallies().last() == OPPONENT) {
				server = !server;
			}
		}
	}

	function getActivity() {
		return Activity.getActivityInfo();
	}

	function getDuration() {
		var time = getActivity().elapsedTime;
		var seconds = time != null ? time / 1000 : 0;
		return new Time.Duration(seconds);
	}

	function getType() {
		return type;
	}

	function getSets() {
		return sets;
	}

	function hasEnded() {
		return winner != null;
	}

	function getTotalRalliesNumber() {
		var i = 0;
		var number = 0;
		while(i < sets.size() && sets[i] != null) {
			number += sets[i].getRalliesNumber();
			i++;
		}
		return number;
	}

	function getTotalScore(player) {
		var score = 0;
		for(var i = 0; i <= getCurrentSetIndex(); i++) {
			score = score + sets[i].getScore(player);
		}
		return score;
	}

	function getSetsWon(player) {
		var won = 0;
		for(var i = 0; i <= getCurrentSetIndex(); i++) {
			if(sets[i].getWinner() == player) {
				won++;
			}
		}
		return won;
	}

	function getWinner() {
		return winner;
	}

	function getServerTeam() {
		return getCurrentSet().getServerTeam();
	}

	function getHighlightedCorner() {
		return getCurrentSet().getHighlightedCorner();
	}

	//methods used from perspective of player 1 (watch carrier)
	hidden function getPlayerTeamIsServer() {
		return getServerTeam() == YOU;
	}

	function getPlayerCorner() {
		if(getPlayerTeamIsServer()) {
			var highlighted_corner = getHighlightedCorner();
			if(server) {
				return highlighted_corner;
			}
			//return other corner
			return highlighted_corner == 2 ? 3 : 2;
		}
		return null;
	}
}
