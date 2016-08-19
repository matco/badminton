module MatchTest {

	(:test)
	function testNewMatch(logger) {
		var match = new Match(:single, 21, 30);
		BetterTest.assertFalse(match.hasBegun(), "Newly created match has not begun");
		BetterTest.assertFalse(match.hasEnded(), "Newly created match has not ended");
		BetterTest.assertEqual(match.getRalliesNumber(), 0, "Newly created match has 0 rally");
		BetterTest.assertNull(match.getWinner(), "Newly created match has no winner");
		BetterTest.assertNull(match.getDuration(), "Newly created match has no duration");
		return true;
	}

	(:test)
	function testBeginMatch(logger) {
		var match = new Match(:single, 21, 30);
		match.begin(:player_1);
		//BetterTest.assertEqual(match.beginner, :player_1, "Beginner of match began with player 1 is player 1");

		BetterTest.assertTrue(match.hasBegun(), "Began match has begun");
		BetterTest.assertFalse(match.hasEnded(), "Began match has not ended");

		BetterTest.assertEqual(match.getRalliesNumber(), 0, "Just began match has 0 rally");
		BetterTest.assertNull(match.getWinner(), "Just began match has now winner");
		BetterTest.assertNotNull(match.getDuration(), "Began match has a non null duration");
		return true;
	}

	(:test)
	function testScore(logger) {
		var match = new Match(:single, 21, 30);

		//try to score before the beginning of the match
		match.score(:player_1);

		BetterTest.assertEqual(match.getScore(:player_1), 0, "Score of player 1 is 0 while match has not begun");
		BetterTest.assertEqual(match.getScore(:player_2), 0, "Score of player 2 is 0 while match has not begun");

		match.begin(:player_1);
		match.score(:player_1);
		BetterTest.assertEqual(match.getScore(:player_1), 1, "Score of player 1 who just scored is 1");
		BetterTest.assertEqual(match.getScore(:player_2), 0, "Score of player 2 is still 0");

		BetterTest.assertTrue(match.hasBegun(), "Began match has begun");
		BetterTest.assertFalse(match.hasEnded(), "Began match has not ended");

		BetterTest.assertEqual(match.getRalliesNumber(), 1, "Match with 1 rally has 1 rally number");
		BetterTest.assertNull(match.getWinner(), "Just began match has no winner");
		BetterTest.assertNotNull(match.getDuration(), "Began match has a non null duration");

		match.score(:player_1);
		match.score(:player_2);
		BetterTest.assertEqual(match.getScore(:player_1), 2, "Score of player 1 who scored twice is 2");
		BetterTest.assertEqual(match.getScore(:player_2), 1, "Score of player 2 who scored once is 1");
		return true;
	}

	(:test)
	function testUndo(logger) {
		var match = new Match(:single, 21, 30);
		match.begin(:player_1);

		match.undo();
		BetterTest.assertEqual(match.getScore(:player_1), 0, "Undo when match has not begun does nothing");
		BetterTest.assertEqual(match.getScore(:player_2), 0, "Undo when match has not begun does nothing");

		match.score(:player_1);
		BetterTest.assertEqual(match.getScore(:player_1), 1, "Score of player 1 who just scored is 1");
		BetterTest.assertEqual(match.getScore(:player_2), 0, "Score of player 2 is still 0");

		match.undo();
		BetterTest.assertEqual(match.getScore(:player_1), 0, "Undo removes a point from the last player who scored");
		BetterTest.assertEqual(match.getScore(:player_2), 0, "Undo does not touch the score of the other player");

		match.undo();
		BetterTest.assertEqual(match.getScore(:player_1), 0, "Undo when match has not begun does nothing");
		BetterTest.assertEqual(match.getScore(:player_2), 0, "Undo when match has not begun does nothing");

		match.score(:player_1);
		match.score(:player_1);
		match.score(:player_2);
		match.score(:player_1);
		BetterTest.assertEqual(match.getScore(:player_1), 3, "Score of player 1 is now 3");
		BetterTest.assertEqual(match.getScore(:player_2), 1, "Score of player 2 is now 1");

		match.undo();
		BetterTest.assertEqual(match.getScore(:player_1), 2, "Undo removes a point from the last player who scored");
		BetterTest.assertEqual(match.getScore(:player_2), 1, "Undo does not touch the score of the other player");

		match.undo();
		BetterTest.assertEqual(match.getScore(:player_2), 0, "Undo does not touch the score of the other player");
		BetterTest.assertEqual(match.getScore(:player_1), 2, "Undo removes a point from the last player who scored");
		return true;
	}

	(:test)
	function testEnd(logger) {
		var match = new Match(:single, 3, 5);
		match.begin(:player_1);

		match.score(:player_1);
		match.score(:player_1);
		match.score(:player_1);
		BetterTest.assertEqual(match.getScore(:player_1), 3, "Score of player 1 is now 3");
		BetterTest.assertTrue(match.hasEnded(), "Match has ended if maximum point has been reached");

		match.undo();
		BetterTest.assertEqual(match.getScore(:player_1), 2, "Score of player 1 is now 2");
		BetterTest.assertFalse(match.hasEnded(), "Match has not ended if no player has reached the maximum point");

		match.score(:player_2);
		match.score(:player_2);
		match.score(:player_1);
		BetterTest.assertEqual(match.getScore(:player_1), 3, "Score of player 1 is now 3");
		BetterTest.assertEqual(match.getScore(:player_2), 2, "Score of player 2 is now 2");
		BetterTest.assertFalse(match.hasEnded(), "Match has not ended if there is not a difference of two points");

		match.score(:player_1);
		match.score(:player_1);
		BetterTest.assertEqual(match.getScore(:player_1), 4, "Score of player 1 is now 4");
		BetterTest.assertTrue(match.hasEnded(), "Match has ended if absolute maximum point has been reached");

		match.score(:player_1);
		BetterTest.assertEqual(match.getScore(:player_1), 4, "Score after match has ended does nothing");
		match.score(:player_2);
		BetterTest.assertEqual(match.getScore(:player_2), 2, "Score after match has ended does nothing");
		return true;
	}
}
