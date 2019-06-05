using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.ActivityRecording as Recording;
using Toybox.Activity as Activity;
using Toybox.FitContributor as Contributor;
using Toybox.WatchUi as Ui;

class Match {

	const SCORE_PLAYER_1_FIELD_ID = 0;
	const SCORE_PLAYER_2_FIELD_ID = 1;

	hidden var type; //type of the match, :single or :double
	hidden var beginner; //store the beginner of the match, :player_1 or :player_2

	hidden var rallies; //array of all rallies

	hidden var scores; //dictionnary containing players current scores
	hidden var server; //in double, true if the player 1 (watch carrier) is currently the server

	hidden var session;
	hidden var session_field_player_1;
	hidden var session_field_player_2;

	var listener;
	var maximum_points;
	var absolute_maximum_points;

	function initialize(match_type, mp, amp) {
		type = match_type;
		maximum_points = mp;
		absolute_maximum_points = amp;

		rallies = new List();
		scores = {:player_1 => 0, :player_2 => 0};
	}

	function save() {
		if(session != null) {
			session_field_player_1.setData(scores[:player_1]);
			session_field_player_2.setData(scores[:player_2]);
			session.save();
		}
		session = null;
	}

	function discard() {
		if(session != null) {
			session.discard();
		}
		session = null;
	}

	function begin(player) {
		beginner = player;
		server = true;

		//manage activity session
		discard();
		session = Recording.createSession({:sport => Recording.SPORT_GENERIC, :subSport => Recording.SUB_SPORT_MATCH, :name => Ui.loadResource(Rez.Strings.fit_activity_name)});
		session_field_player_1 = session.createField("score_player_1", SCORE_PLAYER_1_FIELD_ID, Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_SESSION, :units => Ui.loadResource(Rez.Strings.fit_unit_label)});
		session_field_player_2 = session.createField("score_player_2", SCORE_PLAYER_2_FIELD_ID,	Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_SESSION, :units => Ui.loadResource(Rez.Strings.fit_unit_label)});
		session.start();

		if(listener != null && listener has :onMatchBegin) {
			listener.onMatchBegin();
		}
	}

	hidden function end(winner) {
		//manage activity session
		session.stop();

		if(listener != null && listener has :onMatchEnd) {
			listener.onMatchEnd(winner);
		}
	}

	function score(player) {
		if(hasBegun() && !hasEnded()) {
			//in double, change server if player 1 (watch carrier) team regains service
			if(type == :double) {
				if(rallies.last() == :player_2 && player == :player_1) {
					server = !server;
				}
			}
			rallies.push(player);
			scores[player]++;
			//detect if match has a winner
			var winner = getWinner();
			if(winner != null) {
				end(winner);
			}
		}
	}

	function undo() {
		if(rallies.size() > 0) {
			var rally = rallies.pop();
			//in double, change server if player 1 (watch carrier) team looses service
			if(type == :double) {
				if(rally == :player_1 && rallies.last() == :player_2) {
					server = !server;
				}
			}
			scores[rally]--;
			//manage activity session
			if(session.isRecording()) {
				session.start();
			}
		}
	}

	function getActivity() {
		return Activity.getActivityInfo();
	}

	function getRalliesNumber() {
		return rallies.size();
	}

	function getDuration() {
		var time = getActivity().elapsedTime;
		var seconds = time != null ? time / 1000 : 0;
		return new Time.Duration(seconds);
	}

	function getType() {
		return type;
	}

	function hasBegun() {
		return beginner != null;
	}

	function hasEnded() {
		return getWinner() != null;
	}

	function getScore(player) {
		return scores[player];
	}

	function getWinner() {
		var scorePlayer1 = getScore(:player_1);
		var scorePlayer2 = getScore(:player_2);
		if(scorePlayer1 >= absolute_maximum_points || scorePlayer1 >= maximum_points && (scorePlayer1 - scorePlayer2) > 1) {
			return :player_1;
		}
		if(scorePlayer2 >= absolute_maximum_points || scorePlayer2 >= maximum_points && (scorePlayer2 - scorePlayer1) > 1) {
			return :player_2;
		}
		return null;
	}

	function getServer() {
		//beginning of the match
		if(rallies.isEmpty()) {
			return beginner;
		}
		//last team who score
		return rallies.last();
	}

	function getHighlightedCorner() {
		var server = getServer();
		var server_score = getScore(server);
		//player 1 serves from corner 2 or 3
		if(server == :player_1) {
			return 3 - server_score % 2;
		}
		//player 2 serves from corner 0 or 1
		return server_score % 2;
	}

	//methods used from perspective of player 1 (watch carrier)
	hidden function getPlayerTeamIsServer() {
		return getServer() == :player_1;
	}

	function getPlayerCorner() {
		if(getPlayerTeamIsServer()) {
			Sys.println("player team is server");
			var highlighted_corner = getHighlightedCorner();
			if(server) {
				Sys.println("player is server");
				return highlighted_corner;
			}
			//return other corner
			return highlighted_corner == 2 ? 3 : 2;
		}
		return null;
	}

}
