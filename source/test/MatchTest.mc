module MatchTest {

	function testNewMatch() {
		var match = new Match();
		Assert.isFalse(match.hasBegun(), "Newly created match has not begun");
		Assert.isFalse(match.hasEnded(), "Newly created match has not ended");
		Assert.isEqual(match.getRalliesNumber(), 0, "Newly created match has 0 rally");
		Assert.isNull(match.getWinner(), "Newly created match has no winner");
		Assert.isNull(match.getDuration(), "Newly created match has no duration");
	}

	function testBeginMatch() {
		var match = new Match();
		match.begin(:player_1);
		//Assert.isEqual(match.beginner, :player_1, "Beginner of match began with player 1 is player 1");

		Assert.isTrue(match.hasBegun(), "Began match has begun");
		Assert.isFalse(match.hasEnded(), "Began match has not ended");

		Assert.isEqual(match.getRalliesNumber(), 0, "Just began match has 0 rally");
		Assert.isNull(match.getWinner(), "Just began match has now winner");
		Assert.isNotNull(match.getDuration(), "Began match has a non null duration");
	}

	function testScore() {
		var match = new Match();

		//try to score before the beginning of the match
		match.score(:player_1);

		Assert.isEqual(match.getScore(:player_1), 0, "Score of player 1 is 0 while match has not begun");
		Assert.isEqual(match.getScore(:player_2), 0, "Score of player 2 is 0 while match has not begun");

		match.begin(:player_1);
		match.score(:player_1);
		Assert.isEqual(match.getScore(:player_1), 1, "Score of player 1 who just scored is 1");
		Assert.isEqual(match.getScore(:player_2), 0, "Score of player 2 who just scored is 0");

		Assert.isTrue(match.hasBegun(), "Began match has begun");
		Assert.isFalse(match.hasEnded(), "Began match has not ended");

		Assert.isEqual(match.getRalliesNumber(), 1, "Match with 1 rally 1 rally number");
		Assert.isNull(match.getWinner(), "Just began match has now winner");
		Assert.isNotNull(match.getDuration(), "Began match has a non null duration");
	}
}
