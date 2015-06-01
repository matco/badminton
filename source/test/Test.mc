module Test {
	function test() {
		ListTest.testNewList();
		ListTest.testOneElementList();
		ListTest.testTwoElementsList();

		HelpersTest.testFormatString();
		HelpersTest.testFormatDuration();

		MatchTest.testNewMatch();
		MatchTest.testBeginMatch();
		MatchTest.testScore();
	}
}