import Toybox.Lang;
import Toybox.Time;
import Toybox.Test;

module MatchTest {

	function create_match_config(type as MatchType, sets as Number?, beginner as Team, server as Boolean, maximum_points as Number, absolute_maximum_points as Number) as MatchConfig {
		var config = new MatchConfig();
		config.type = type;
		config.sets = sets;
		config.beginner = beginner;
		config.server = server;
		config.maximumPoints = maximum_points;
		config.absoluteMaximumPoints = absolute_maximum_points;
		return config;
	}

	(:test)
	function testNewMatch(logger as Logger) as Boolean {
		var match = new Match(create_match_config(SINGLE, 1, USER, true, 21, 30));
		BetterTest.assertEqual(match.getType(), SINGLE, "Match is created with correct type");
		BetterTest.assertEqual(match.getMaximumSets(), 1, "Match is created with corret maximum number of set");
		BetterTest.assertEqual(match.getSets().size(), 1, "Match has only one set at the beginning");

		BetterTest.assertEqual(match.getDuration().value(), 0, "Newly created match has a duration of 0");
		BetterTest.assertFalse(match.hasEnded(), "Newly created match has not ended");
		BetterTest.assertNull(match.getWinner(), "Newly created match has no winner");

		var set = match.getCurrentSet();
		BetterTest.assertEqual(set.getBeginner(), USER, "Match first set is created with the right beginner");
		BetterTest.assertFalse(set.hasEnded(), "Match first set has not ended");
		BetterTest.assertNull(set.getWinner(), "Match first set has no winner");

		return true;
	}

	(:test)
	function testScore(logger as Logger) as Boolean {
		var match = new Match(create_match_config(SINGLE, 1, USER, true, 21, 30));
		var set = match.getCurrentSet();

		BetterTest.assertEqual(set.getScore(USER), 0, "Newly created match has a set score of 0 for player 1");
		BetterTest.assertEqual(set.getScore(OPPONENT), 0, "Newly created match has a set score of 0 for player 2");
		BetterTest.assertEqual(match.getTotalScore(USER), 0, "Newly created match has a total score of 0 for player 1");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 0, "Newly created match has a total score of 0 for player 2");
		BetterTest.assertEqual(match.getTotalRalliesNumber(), 0, "Newly created match has 0 rally");

		match.score(USER);
		BetterTest.assertEqual(set.getScore(USER), 1, "Score of player 1 is set to 1 after player 1 scored");
		BetterTest.assertEqual(set.getScore(OPPONENT), 0, "Score of player 2 is still 0 after player 1 scored");
		BetterTest.assertEqual(match.getTotalScore(USER), 1, "Total score of player 1 is set to 1 after player 1 scored once");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 0, "Total score of player 2 is still 0 after player 1 scored once");
		BetterTest.assertEqual(match.getTotalRalliesNumber(), 1, "Rallies are counted properly");

		match.score(USER);
		BetterTest.assertEqual(set.getScore(USER), 2, "Score of player 1 is set to 2 after player 1 scored twice");
		BetterTest.assertEqual(set.getScore(OPPONENT), 0, "Score of player 2 is still 0 after player 1 scored twice");
		BetterTest.assertEqual(match.getTotalScore(USER), 2, "Total score of player 1 is set to 2 after player 1 scored twice");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 0, "Total score of player 2 is still 0 after player 1 scored twice");
		BetterTest.assertEqual(match.getTotalRalliesNumber(), 2, "Rallies are counted properly");

		match.score(USER);
		match.score(OPPONENT);
		BetterTest.assertEqual(set.getScore(USER), 3, "Score of player 1 who scored twice is 2");
		BetterTest.assertEqual(set.getScore(OPPONENT), 1, "Score of player 2 who scored once is 1");
		BetterTest.assertEqual(match.getTotalScore(USER), 3, "Total score of player 1 who scored twice is 2");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 1, "Total score of player 2 who scored once is 1");
		BetterTest.assertEqual(match.getTotalRalliesNumber(), 4, "Rallies are counted properly");

		return true;
	}

	(:test)
	function testUndo(logger as Logger) as Boolean {
		var match = new Match(create_match_config(SINGLE, 1, USER, true, 21, 30));
		var set = match.getCurrentSet();

		match.undo();
		BetterTest.assertEqual(set.getScore(USER), 0, "Undo when match has not begun does nothing");
		BetterTest.assertEqual(set.getScore(OPPONENT), 0, "Undo when match has not begun does nothing");
		BetterTest.assertEqual(match.getTotalScore(USER), 0, "Undo when match has not begun does nothing");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 0, "Undo when match has not begun does nothing");

		match.score(USER);
		match.undo();

		BetterTest.assertEqual(set.getScore(USER), 0, "Undo removes a point from the last player who scored");
		BetterTest.assertEqual(set.getScore(OPPONENT), 0, "Undo does not touch the score of the other player");
		BetterTest.assertEqual(match.getTotalScore(USER), 0, "Undo removes a point from the last player who scored");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 0, "Undo does not touch the score of the other player");
		BetterTest.assertEqual(match.getTotalRalliesNumber(), 0, "Undo handles rallies property");

		match.undo();
		BetterTest.assertEqual(match.getTotalScore(USER), 0, "Undo when match has not begun does nothing");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 0, "Undo when match has not begun does nothing");
		BetterTest.assertEqual(match.getTotalRalliesNumber(), 0, "Undo handles rallies property");

		match.score(USER);
		match.score(USER);
		match.score(OPPONENT);
		match.score(USER);
		BetterTest.assertEqual(set.getScore(USER), 3, "Score of player 1 is now 3");
		BetterTest.assertEqual(set.getScore(OPPONENT), 1, "Score of player 2 is now 1");
		BetterTest.assertEqual(match.getTotalScore(USER), 3, "Total score of player 1 is now 3");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 1, "Total score of player 2 is now 1");
		BetterTest.assertEqual(match.getTotalRalliesNumber(), 4, "Total number of rallies is now 4");

		match.undo();
		BetterTest.assertEqual(match.getTotalScore(USER), 2, "Undo removes a point from the last player who scored");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 1, "Undo does not touch the score of the other player");
		BetterTest.assertEqual(match.getTotalRalliesNumber(), 3, "Undo handles rallies property");

		match.undo();
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 0, "Undo does not touch the score of the other player");
		BetterTest.assertEqual(match.getTotalScore(USER), 2, "Undo removes a point from the last player who scored");
		BetterTest.assertEqual(match.getTotalRalliesNumber(), 2, "Undo handles rallies property");

		return true;
	}

	(:test)
	function testSet(logger as Logger) as Boolean {
		var match = new Match(create_match_config(SINGLE, 3, USER, true, 3, 5));
		var set = match.getCurrentSet();

		try {
			match.nextSet();
			BetterTest.fail("Next set cannot be called if current set has not ended");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "Unable to start next set if current set has not ended", "It is not possible to start next set if current set has not ended");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.OperationNotAllowedException, "It is not possible to start next set if current set has not ended");
		}

		match.score(USER);
		match.score(USER);

		try {
			match.nextSet();
			BetterTest.fail("Next set cannot be called if current set has not ended");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "Unable to start next set if current set has not ended", "It is not possible to start next set if current set has not ended");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.OperationNotAllowedException, "It is not possible to start next set if current set has not ended");
		}

		match.score(USER);
		BetterTest.assertEqual(set.getScore(USER), 3, "Score of player 1 in first set is 3");
		BetterTest.assertTrue(set.hasEnded(), "Set has ended if maximum point has been reached");

		try {
			match.score(USER);
			BetterTest.fail("Scoring after the set has ended should throw an operation not allowed exception");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "Unable to score in a set that has ended", "It is not possible to score after a set has ended");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.OperationNotAllowedException, "It is not possible to score after a set has ended");
		}

		match.nextSet();
		set = match.getCurrentSet();

		BetterTest.assertEqual(set.getScore(USER), 0, "Score of player 1 in second set is 0");
		BetterTest.assertEqual(set.getScore(OPPONENT), 0, "Score of player 2 in second set is 0");

		return true;
	}

	(:test)
	function testEnd(logger as Logger) as Boolean {
		//single set match, using undo
		var match = new Match(create_match_config(SINGLE, 1, USER, true, 3, 5));
		var set = match.getCurrentSet();
		BetterTest.assertFalse(match.hasEnded(), "Match has not ended if no rallies have been played");

		match.score(USER);
		BetterTest.assertFalse(match.hasEnded(), "Match has not ended if its single set has not ended");

		match.score(USER);
		match.score(USER);
		BetterTest.assertEqual(set.getScore(USER), 3, "Score of player 1 is now 3");
		BetterTest.assertTrue(set.hasEnded(), "Set has ended if maximum point has been reached");
		BetterTest.assertTrue(match.hasEnded(), "Match has ended if its single set has ended");

		match.undo();
		BetterTest.assertEqual(set.getScore(USER), 2, "Score of player 1 is now 2");
		BetterTest.assertFalse(set.hasEnded(), "Set has not ended if no player has reached the maximum point");
		BetterTest.assertFalse(match.hasEnded(), "Match has not ended if its single set has not ended");

		match.score(OPPONENT);
		match.score(OPPONENT);
		match.score(USER);
		BetterTest.assertEqual(set.getScore(USER), 3, "Score of player 1 is now 3");
		BetterTest.assertEqual(set.getScore(OPPONENT), 2, "Score of player 2 is now 2");
		BetterTest.assertFalse(set.hasEnded(), "Set has not ended if there is not a difference of two points");
		BetterTest.assertFalse(match.hasEnded(), "Match has not ended if its single has not ended");
		BetterTest.assertEqual(match.getSetsWon(USER), 0, "Player 1 won no set if no set have been completed");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won no set if no set have been completed");

		match.score(OPPONENT);
		match.score(USER);
		match.score(USER);
		BetterTest.assertEqual(set.getScore(USER), 5, "Score of player 1 is now 5");
		BetterTest.assertTrue(set.hasEnded(), "Set has ended if absolute maximum point has been reached");
		BetterTest.assertTrue(match.hasEnded(), "Match has ended if its single set has ended");
		BetterTest.assertEqual(match.getSetsWon(USER), 1, "Player 1 won 1 set");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won 0 set");

		//multi sets match
		match = new Match(create_match_config(SINGLE, 3, USER, true, 3, 5));
		set = match.getCurrentSet();

		match.score(USER);
		match.score(USER);
		match.score(USER);

		BetterTest.assertEqual(set.getScore(USER), 3, "Score of player 1 is now 3");
		BetterTest.assertTrue(set.hasEnded(), "Set has ended if maximum point has been reached");
		BetterTest.assertFalse(match.hasEnded(), "Match has not ended if only one of its sets has ended");
		BetterTest.assertEqual(match.getSetsWon(USER), 1, "Player 1 won 1 set");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won no set");

		match.nextSet();
		set = match.getCurrentSet();

		match.score(USER);
		match.score(USER);
		match.score(USER);
		BetterTest.assertTrue(set.hasEnded(), "Set has ended if maximum point has been reached");
		BetterTest.assertTrue(match.hasEnded(), "Match has ended if all its sets have ended");
		BetterTest.assertEqual(match.getSetsWon(USER), 2, "Player 1 won 2 set");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won no set");

		try {
			match.score(USER);
			BetterTest.fail("Scoring after the match has ended should throw an operation not allowed exception");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "Unable to score in a match that has ended", "It is not possible to score after a match has ended");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.OperationNotAllowedException, "It is not possible to score after a match has ended");
		}

		return true;
	}

	(:test)
	function testEndPrematurely(logger as Logger) as Boolean {
		//match ended prematurely while no set has been ended
		var match = new Match(create_match_config(SINGLE, 1, USER, true, 3, 5));
		var set = match.getCurrentSet();

		match.score(USER);
		match.score(USER);
		BetterTest.assertFalse(match.hasEnded(), "Match has not ended if its single set has not ended");

		match.end(null);
		BetterTest.assertTrue(match.hasEnded(), "Match has ended if the user ended it prematurely");
		BetterTest.assertEqual(match.getWinner(), USER, "Match is won by the player with the highest score");
		BetterTest.assertEqual(set.getScore(USER), 2, "Score of player 1 is now 2");
		BetterTest.assertEqual(set.getScore(OPPONENT), 0, "Score of player 2 is now 0");
		BetterTest.assertEqual(match.getSetsWon(USER), 0, "Player 1 won no set if no set have been completed");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won no set if no set have been completed");

		try {
			match.end(null);
			BetterTest.fail("Match cannot be ended twice");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "Unable to end a match that has already been ended", "It is not possible to end a match that has already been ended");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.OperationNotAllowedException, "It is not possible to end a match that has already been ended");
		}

		//match ended while second set is being played
		match = new Match(create_match_config(SINGLE, null, USER, true, 3, 5));
		set = match.getCurrentSet();

		match.score(USER);
		match.score(USER);
		match.score(USER);

		match.nextSet();

		match.score(OPPONENT);

		match.end(null);
		BetterTest.assertTrue(match.hasEnded(), "Match has ended if the user ended it prematurely");
		BetterTest.assertEqual(match.getWinner(), USER, "Match is won by the player with the most sets won");
		BetterTest.assertEqual(match.getSetsWon(USER), 1, "Player 1 won 1 set");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won 0 set");

		try {
			match.end(null);
			BetterTest.fail("Match cannot be ended twice");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "Unable to end a match that has already been ended", "It is not possible to end a match that has already been ended");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.OperationNotAllowedException, "It is not possible to end a match that has already been ended");
		}

		return true;
	}

	(:test)
	function testEndless(logger as Logger) as Boolean {
		//match ended while no set has been ended
		var match = new Match(create_match_config(SINGLE, null, USER, true, 3, 5));
		var set = match.getCurrentSet();

		match.score(USER);
		match.score(USER);
		match.score(OPPONENT);
		BetterTest.assertEqual(set.getScore(USER), 2, "Score of player 1 is now 2");
		BetterTest.assertEqual(set.getScore(OPPONENT), 1, "Score of player 2 is now 1");
		BetterTest.assertFalse(match.hasEnded(), "Match can never end automatically in endless mode");
		BetterTest.assertEqual(match.getSetsWon(USER), 0, "Player 1 won no set if no set have been completed");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won no set if no set have been completed");

		match.end(null);
		BetterTest.assertEqual(match.getWinner(), USER, "Match is won by the player with the highest score");

		//match ended while second set is being played
		match = new Match(create_match_config(SINGLE, null, USER, true, 3, 5));
		set = match.getCurrentSet();

		match.score(USER);
		match.score(USER);
		match.score(USER);
		BetterTest.assertEqual(set.getScore(USER), 3, "Score of player 1 is now 3");
		BetterTest.assertFalse(match.hasEnded(), "Match can never end automatically in endless mode");
		BetterTest.assertEqual(match.getSetsWon(USER), 1, "Player 1 won 1 set");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won 0 set");

		match.nextSet();
		set = match.getCurrentSet();
		BetterTest.assertEqual(match.getSets().size(), 2, "A new set has been created");

		match.score(OPPONENT);
		BetterTest.assertEqual(set.getScore(USER), 0, "Score of player 1 is now 0");
		BetterTest.assertEqual(set.getScore(OPPONENT), 1, "Score of player 2 is now 1");
		BetterTest.assertFalse(match.hasEnded(), "Match can never end automatically in endless mode");
		BetterTest.assertEqual(match.getSetsWon(USER), 1, "Player 1 won 1 set");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won 0 set");

		match.end(null);
		BetterTest.assertEqual(match.getWinner(), USER, "Match is won by the player with the most sets won");
		BetterTest.assertEqual(match.getSetsWon(USER), 1, "Player 1 won 1 set");
		BetterTest.assertEqual(match.getSetsWon(OPPONENT), 0, "Player 2 won 0 set");

		try {
			match.end(null);
			BetterTest.fail("Match cannot be ended twice");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "Unable to end a match that has already been ended", "It is not possible to end a match that has already been ended");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.OperationNotAllowedException, "It is not possible to end a match that has already been ended");
		}

		//match draw while no set has been ended
		match = new Match(create_match_config(SINGLE, null, USER, true, 3, 5));
		set = match.getCurrentSet();

		match.score(USER);
		match.score(USER);
		match.score(OPPONENT);
		match.score(OPPONENT);
		BetterTest.assertEqual(set.getScore(USER), 2, "Score of player 1 is now 2");
		BetterTest.assertEqual(set.getScore(OPPONENT), 2, "Score of player 2 is now 2");
		BetterTest.assertFalse(match.hasEnded(), "Match can never end automatically in endless mode");

		match.end(null);
		BetterTest.assertNull(match.getWinner(), "There is no winner if both players have the same score in the first set");

		//match draw in the third set
		match = new Match(create_match_config(SINGLE, null, USER, true, 3, 5));

		//first set
		match.score(USER);
		match.score(USER);
		match.score(OPPONENT);
		match.score(USER);

		match.nextSet();

		//second set
		match.score(OPPONENT);
		match.score(OPPONENT);
		match.score(USER);
		match.score(OPPONENT);

		match.nextSet();

		BetterTest.assertEqual(match.getSets().size(), 3, "A new set has been created");
		set = match.getCurrentSet();

		match.score(USER);
		match.score(OPPONENT);

		BetterTest.assertEqual(match.getTotalScore(USER), 5, "Total score of player 1 is 5");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 5, "Total score of player 2 is 5");

		match.end(null);
		BetterTest.assertNull(match.getWinner(), "There is no winner if both players have the same number of sets won and the same total score");

		//match ended after the same number of sets won but different total scores
		match = new Match(create_match_config(SINGLE, null, USER, true, 3, 5));

		//first set
		match.score(USER);
		match.score(USER);
		match.score(OPPONENT);
		match.score(USER);

		match.nextSet();

		//second set
		match.score(OPPONENT);
		match.score(OPPONENT);
		match.score(OPPONENT);

		match.nextSet();

		BetterTest.assertEqual(match.getSets().size(), 3, "A new set has been created");
		set = match.getCurrentSet();

		match.score(USER);
		match.score(OPPONENT);

		BetterTest.assertEqual(match.getTotalScore(USER), 4, "Total score of player 1 is 4");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 5, "Total score of player 2 is 5");

		match.end(null);
		BetterTest.assertEqual(match.getWinner(), OPPONENT, "If both players have the same number of sets won, the match is won by the player with the highest score");

		//match ended after the third set has ended
		match = new Match(create_match_config(SINGLE, null, USER, true, 3, 5));
		set = match.getCurrentSet();

		match.score(USER);
		match.score(USER);
		match.score(USER);

		match.nextSet();

		match.score(OPPONENT);
		match.score(OPPONENT);
		match.score(OPPONENT);

		match.nextSet();

		match.score(USER);
		match.score(USER);
		match.score(USER);

		match.end(null);
		BetterTest.assertEqual(match.getWinner(), USER, "Match is won by the player with the most sets won");
		BetterTest.assertEqual(match.getTotalScore(USER), 6, "Total score of player 1 is 6");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 3, "Total score of player 2 is 3");

		return true;
	}

	(:test)
	function testServer(logger as Logger) as Boolean {
		//single, player begins the match
		var match = new Match(create_match_config(SINGLE, 1, USER, true, 21, 30));
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In singles, player team serves if it begins a match");
		BetterTest.assertTrue(match.getUserIsServer(), "In singles, the player is the server if he begins the match");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In singles, the player serves from the right if his score is even");

		match.score(USER); //1-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In singles, player team serves while it's winning rallies");
		BetterTest.assertTrue(match.getUserIsServer(), "In singles, the player is the server while he's winning rallies");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In singles, the player serves from the left if his score is odd");

		match.score(USER); //2-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In singles, player team serves while it's winning rallies");
		BetterTest.assertTrue(match.getUserIsServer(), "In singles, the player is the server while he's winning rallies");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In singles, the player serves from the right if his score is even");

		match.score(OPPONENT); //2-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In singles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In singles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In singles, the player receives the service on the left if the opponent serves and his score is odd");

		match.score(USER); //3-1
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In singles, player team serves if it won a rally back");
		BetterTest.assertTrue(match.getUserIsServer(), "In singles, the player is the server if he won a rally back");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In singles, the player serves from the left if his score is odd");

		match.discard();

		//single, opponent begins the match
		match = new Match(create_match_config(SINGLE, 1, OPPONENT, true, 21, 30));
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In singles, player team does not serve if the opponent begins a match");
		BetterTest.assertFalse(match.getUserIsServer(), "In singles, the player is not the server if the opponent begins the match");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In singles, the player receives the service on the right if the opponent serves and his score is even");

		match.score(USER); //1-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In singles, player team serves if it won a rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In singles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In singles, the player serves from the left if his score is odd");

		match.score(USER); //2-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In singles, player team serves while it's winning rallies");
		BetterTest.assertTrue(match.getUserIsServer(), "In singles, the player is the server while he's winning rallies");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In singles, the player serves from the right if his score is even");

		match.score(OPPONENT); //2-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In singles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In singles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In singles, the player receives the service on the left if the opponent serves and his score is even");

		match.score(USER); //3-1
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In singles, player team serves if it won a rally back");
		BetterTest.assertTrue(match.getUserIsServer(), "In singles, the player is the server if he won a rally back");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In singles, the player serves from the left if his score is odd");

		match.discard();

		//double, player team begins the match and is the first server
		match = new Match(create_match_config(DOUBLE, 1, USER, true, 21, 30));
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it begins a match");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if his team begins the match and he is the first server");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player serves from the right if his team's score is even");

		match.score(OPPONENT); //0-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player stays in place after his team lost the service");

		match.score(USER); //1-1
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is odd");

		match.undo(); //0-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player stays in place after his team lost the service");

		match.undo(); //0-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it begins a match");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if his team begins the match and he is the first server");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player serves from the right if his team's score is even");

		match.score(USER); //1-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player serves from the left if his team's score is odd");

		match.score(USER); //2-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won another rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won another rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player serves from the right if his team's score is even");

		match.score(OPPONENT); //2-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player stays in place after his team lost the service");

		match.score(USER); //3-1
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is odd");

		match.score(OPPONENT); //3-2
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player stays in place after his team lost the service");

		match.score(USER); //4-2
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player serves from the right if his team's score is even");

		match.discard();

		//double, player team begins the match and his teammate is the first server
		match = new Match(create_match_config(DOUBLE, 1, USER, false, 21, 30));
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it begins a match");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, player is not the server if his team begins the match and his teammate is the first server");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is even");

		match.score(OPPONENT); //0-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player stays in place after his team lost the service");

		match.score(USER); //1-1
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player teammate is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player serves from the left if his team's score is odd");

		match.undo(); //0-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player stays in place after his team lost the service");

		match.undo(); //0-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it begins a match");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if his team begins the match and his teammate is the first server");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is even");

		match.score(USER); //1-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is odd");

		match.score(USER); //2-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won another rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won another rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is even");

		match.score(OPPONENT); //2-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player stays in place after his team lost the service");

		match.score(USER); //3-1
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player serves from the left if his team's score is odd");

		match.score(OPPONENT); //3-2
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player stays in place after his team lost the service");

		match.score(USER); //4-2
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is even");

		match.discard();

		//double, opponent team begins the match and the player is the first server
		match = new Match(create_match_config(DOUBLE, 1, OPPONENT, true, 21, 30));
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if the opponent team begins a match");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if the opponent team begins the match");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player is ready to be serving when he will regain the service if the opponent team serves first");

		match.score(USER); //1-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player serves from the left if his team's score is odd");

		match.score(USER); //2-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won another rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won another rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player serves from the right if his team's score is even");

		match.undo(); //1-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player serves from the left if his team's score is odd");

		match.undo(); //0-0
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if the opponent team begins a match");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if the opponent team begins the match");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player is ready to be serving when he will regain the service if the opponent team serves first");

		match.score(OPPONENT); //0-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player is ready to be serving when he will regain the service if the opponent team serves first");

		match.score(OPPONENT); //0-2
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost another rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost another rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player is ready to be serving when he will regain the service if the opponent team serves first");

		match.score(USER); //1-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player serves from the left if his team's score is odd");

		match.score(USER); //2-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won another rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won another rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player serves from the right if his team's score is even");

		match.score(OPPONENT); //2-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player stays in place after his team lost the service");

		match.score(USER); //3-1
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is even");

		match.discard();

		//double, opponent team begins the match and his teammate is the first server
		match = new Match(create_match_config(DOUBLE, 1, OPPONENT, false, 21, 30));
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if the opponent team begins a match");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if the opponent team begins the match");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player is ready to be non serving when his team will regain the service if the opponent team serves first");

		match.score(USER); //1-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is odd");

		match.score(USER); //2-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won another rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won another rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is even");

		match.undo(); //1-0
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is odd");

		match.undo(); //0-0
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if the opponent team begins a match");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if the opponent team begins the match");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player is ready to be non serving when his team will regain the service if the opponent team serves first");

		match.score(OPPONENT); //0-1
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player is ready to be non serving when his team will regain the service if the opponent team serves first");

		match.score(OPPONENT); //0-2
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost another rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost another rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player is ready to be non serving when his team will regain the service if the opponent team serves first");

		match.score(USER); //1-2
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player teammate is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_RIGHT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is odd");

		match.score(USER); //2-2
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won another rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is the server if he won another rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player takes the non serving corner if his teammate is serving and his team's score is even");

		match.score(OPPONENT); //2-3
		BetterTest.assertFalse(match.getUserTeamIsServer(), "In doubles, player team does not serve if it lost a rally");
		BetterTest.assertFalse(match.getUserIsServer(), "In doubles, the player is not the server if he lost a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player stays in place after his team lost the service");

		match.score(USER); //3-3
		BetterTest.assertTrue(match.getUserTeamIsServer(), "In doubles, player team serves if it won a rally");
		BetterTest.assertTrue(match.getUserIsServer(), "In doubles, the player is the server if he won a rally");
		BetterTest.assertEqual(match.getUserCorner(), USER_LEFT, "In doubles, the player serves from the left if his team's score is odd");

		return true;
	}

	function scorePoints(match as Match, points as Number) as Void {
		for(var i = 0; i < points; i++) {
			match.score(USER);
			match.score(OPPONENT);
		}
	}

	(:test)
	function testMemory(logger as Logger) as Boolean {
		//create a very complex match
		var match = new Match(create_match_config(SINGLE, Match.MAX_SETS, USER, true, 21, 30));
		//set 1, won by USER
		scorePoints(match, 29);
		match.score(USER);
		//set 2, won by OPPONENT
		match.nextSet();
		scorePoints(match, 29);
		match.score(OPPONENT);
		//set 3, won by USER
		match.nextSet();
		scorePoints(match, 29);
		match.score(USER);
		//set 4, won by OPPONENT
		match.nextSet();
		scorePoints(match, 29);
		match.score(OPPONENT);
		//set 5, won by USER
		match.nextSet();
		scorePoints(match, 29);
		match.score(USER);
		//end of match, won by USER 3-2
		BetterTest.assertTrue(match.hasEnded(), "Match has ended if all its sets have ended");
		BetterTest.assertEqual(match.getTotalScore(USER), 148, "Total score of player 1 is 148");
		BetterTest.assertEqual(match.getTotalScore(OPPONENT), 147, "Total score of player 2 is 147");

		var stats = match.calculateStats();
		//with this configuration, the player won while serving only 3 times
		//at the very beginning of the match and when starting set number 3 and 5
		BetterTest.assertEqual(stats.percentageWinningServing, 2, "Percentage of rallies won while serving is correct");
		BetterTest.assertEqual(stats.percentageWinningReceiving, 98, "Percentage of rallies won while not serving is correct");

		return true;
	}

	(:test)
	function testStats(logger as Logger) as Boolean {
		var match = new Match(create_match_config(SINGLE, 1, YOU, true, 10, 10));
		match.score(YOU);
		match.score(YOU);
		match.score(YOU);
		//serving rallies won: 3/3 - non serving rallies won: 0/0
		match.score(OPPONENT);
		//serving rallies won: 3/4 - non serving rallies won: 0/0

		var stats = match.calculateStats();
		BetterTest.assertEqual(stats.percentageWinningServing, 75, "During the match, percentage of rallies won while serving is correct");
		BetterTest.assertNull(stats.percentageWinningReceiving, "During the match, percentage of rallies won while not serving cannot be calculated if there was no non serving rallies");

		match.score(OPPONENT);
		match.score(OPPONENT);
		match.score(OPPONENT);
		//serving rallies won 3/4: - non serving rallies won: 0/3
		match.score(YOU);
		//serving rallies won: 3/4 - non serving rallies won: 1/4
		match.score(YOU);
		match.score(YOU);
		match.score(YOU);
		match.score(YOU);
		match.score(YOU);
		match.score(YOU);
		//serving rallies won: 9/10 - non serving rallies won: 1/4

		stats = match.calculateStats();
		BetterTest.assertEqual(stats.percentageWinningServing, 90, "Percentage of rallies won while serving is correct");
		BetterTest.assertEqual(stats.percentageWinningReceiving, 25, "Percentage of rallies won while receiving is correct");

		match.discard();

		match = new Match(create_match_config(SINGLE, 1, YOU, true, 2, 2));
		match.score(YOU);
		match.score(YOU);
		//serving rallies won: 2/2

		stats = match.calculateStats();
		BetterTest.assertEqual(stats.percentageWinningServing, 100, "Percentage of rallies won while serving is correct");
		BetterTest.assertNull(stats.percentageWinningReceiving, "Percentage of rallies won while receiving cannot be calculated if there was no non serving rallies");

		match.discard();

		match = new Match(create_match_config(SINGLE, 1, OPPONENT, true, 2, 2));
		match.score(YOU);
		//serving rallies won 0/0: - non serving rallies won: 1/1
		match.score(YOU);
		//serving rallies won 1/1: - non serving rallies won: 1/1

		stats = match.calculateStats();
		BetterTest.assertEqual(stats.percentageWinningServing, 100, "Percentage of rallies won while serving is correct");
		BetterTest.assertEqual(stats.percentageWinningReceiving, 100, "Percentage of rallies won while receiving is correct");

		match.discard();

		match = new Match(create_match_config(SINGLE, 1, OPPONENT, true, 2, 2));
		match.score(OPPONENT);
		match.score(OPPONENT);
		//non serving rallies won: 0/2

		stats = match.calculateStats();
		BetterTest.assertNull(stats.percentageWinningServing, "Percentage of rallies won while serving cannot be calculated if there was no serving rallies");
		BetterTest.assertEqual(stats.percentageWinningReceiving, 0, "Percentage of rallies won while receiving is correct");

		match.discard();

		match = new Match(create_match_config(SINGLE, 1, OPPONENT, true, 5, 5));
		scorePoints(match, 4);
		match.score(YOU);
		//serving rallies won: 0/9 - non serving rallies won: 9/9

		stats = match.calculateStats();
		BetterTest.assertEqual(stats.percentageWinningServing, 0, "Percentage of rallies won while serving is correct");
		BetterTest.assertEqual(stats.percentageWinningReceiving, 100, "Percentage of rallies won while receiving is correct");

		match.discard();

		return true;
	}
}
