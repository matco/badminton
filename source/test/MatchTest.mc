module MatchTest {

	function testNewMatch() {
		var match = new Match(:single, 21, 30);
		Assert.isFalse(match.hasBegun(), "Newly created match has not begun");
		Assert.isFalse(match.hasEnded(), "Newly created match has not ended");
		Assert.isEqual(match.getRalliesNumber(), 0, "Newly created match has 0 rally");
		Assert.isNull(match.getWinner(), "Newly created match has no winner");
		Assert.isNull(match.getDuration(), "Newly created match has no duration");
	}

	function testBeginMatch() {
		var match = new Match(:single, 21, 30);
		match.begin(:player_1);
		//Assert.isEqual(match.beginner, :player_1, "Beginner of match began with player 1 is player 1");

		Assert.isTrue(match.hasBegun(), "Began match has begun");
		Assert.isFalse(match.hasEnded(), "Began match has not ended");

		Assert.isEqual(match.getRalliesNumber(), 0, "Just began match has 0 rally");
		Assert.isNull(match.getWinner(), "Just began match has now winner");
		Assert.isNotNull(match.getDuration(), "Began match has a non null duration");
	}

	function testScore() {
		var match = new Match(:single, 21, 30);

		//try to score before the beginning of the match
		match.score(:player_1);

		Assert.isEqual(match.getScore(:player_1), 0, "Score of player 1 is 0 while match has not begun");
		Assert.isEqual(match.getScore(:player_2), 0, "Score of player 2 is 0 while match has not begun");

		match.begin(:player_1);
		match.score(:player_1);
		Assert.isEqual(match.getScore(:player_1), 1, "Score of player 1 who just scored is 1");
		Assert.isEqual(match.getScore(:player_2), 0, "Score of player 2 is still 0");

		Assert.isTrue(match.hasBegun(), "Began match has begun");
		Assert.isFalse(match.hasEnded(), "Began match has not ended");

		Assert.isEqual(match.getRalliesNumber(), 1, "Match with 1 rally has 1 rally number");
		Assert.isNull(match.getWinner(), "Just began match has no winner");
		Assert.isNotNull(match.getDuration(), "Began match has a non null duration");

		match.score(:player_1);
		match.score(:player_2);
		Assert.isEqual(match.getScore(:player_1), 2, "Score of player 1 who scored twice is 2");
		Assert.isEqual(match.getScore(:player_2), 1, "Score of player 2 who scored once is 1");
	}

	function testUndo() {
		var match = new Match(:single, 21, 30);
		match.begin(:player_1);

		match.undo();
		Assert.isEqual(match.getScore(:player_1), 0, "Undo when match has not begun does nothing");
		Assert.isEqual(match.getScore(:player_2), 0, "Undo when match has not begun does nothing");

		match.score(:player_1);
		Assert.isEqual(match.getScore(:player_1), 1, "Score of player 1 who just scored is 1");
		Assert.isEqual(match.getScore(:player_2), 0, "Score of player 2 is still 0");

		match.undo();
		Assert.isEqual(match.getScore(:player_1), 0, "Undo removes a point from the last player who scored");
		Assert.isEqual(match.getScore(:player_2), 0, "Undo does not touch the score of the other player");

		match.undo();
		Assert.isEqual(match.getScore(:player_1), 0, "Undo when match has not begun does nothing");
		Assert.isEqual(match.getScore(:player_2), 0, "Undo when match has not begun does nothing");

		match.score(:player_1);
		match.score(:player_1);
		match.score(:player_2);
		match.score(:player_1);
		Assert.isEqual(match.getScore(:player_1), 3, "Score of player 1 is now 3");
		Assert.isEqual(match.getScore(:player_2), 1, "Score of player 2 is now 1");

		match.undo();
		Assert.isEqual(match.getScore(:player_1), 2, "Undo removes a point from the last player who scored");
		Assert.isEqual(match.getScore(:player_2), 1, "Undo does not touch the score of the other player");

		match.undo();
		Assert.isEqual(match.getScore(:player_2), 0, "Undo does not touch the score of the other player");
		Assert.isEqual(match.getScore(:player_1), 2, "Undo removes a point from the last player who scored");
	}

	function testEnd() {
		var match = new Match(:single, 3, 5);
		match.begin(:player_1);

		match.score(:player_1);
		match.score(:player_1);
		match.score(:player_1);
		Assert.isEqual(match.getScore(:player_1), 3, "Score of player 1 is now 3");
		Assert.isTrue(match.hasEnded(), "Match has ended if maximum point has been reached");

		match.undo();
		Assert.isEqual(match.getScore(:player_1), 2, "Score of player 1 is now 2");
		Assert.isFalse(match.hasEnded(), "Match has not ended if no player has reached the maximum point");

		match.score(:player_2);
		match.score(:player_2);
		match.score(:player_1);
		Assert.isEqual(match.getScore(:player_1), 3, "Score of player 1 is now 3");
		Assert.isEqual(match.getScore(:player_2), 2, "Score of player 2 is now 2");
		Assert.isFalse(match.hasEnded(), "Match has not ended if there is not a difference of two points");

		match.score(:player_1);
		match.score(:player_1);
		Assert.isEqual(match.getScore(:player_1), 3, "Score of player 1 is now 5");
		Assert.isTrue(match.hasEnded(), "Match has ended if absolute maximum point has been reached");

		match.score(:player_1);
		Assert.isEqual(match.getScore(:player_1), 5, "Score after match has ended does nothing");
		match.score(:player_2);
		Assert.isEqual(match.getScore(:player_2), 2, "Score after match has ended does nothing");
	}
}
