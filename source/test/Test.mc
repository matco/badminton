module Test {
	function test() {
		ListTest.testNewList();
		ListTest.testOneElementList();
		ListTest.testTwoElementsList();

		BetterMathTest.testMin();
		BetterMathTest.testMax();

		HelpersTest.testFormatString();
		HelpersTest.testFormatDuration();

		MatchTest.testNewMatch();
		MatchTest.testBeginMatch();
		MatchTest.testScore();
	}
}