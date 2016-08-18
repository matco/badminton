using Toybox.System as Sys;

module Test {
	function test() {
		ListTest.testNewList();
		ListTest.testOneElementList();
		ListTest.testTwoElementsList();

		BetterMathTest.testMin();
		BetterMathTest.testMax();

		GeometryTest.testMean();
		GeometryTest.testChordLength();

		HelpersTest.testFormatString();
		HelpersTest.testFormatDuration();

		MatchTest.testNewMatch();
		MatchTest.testBeginMatch();
		MatchTest.testScore();
		MatchTest.testUndo();
		MatchTest.testEnd();

		Sys.println("Tests executed successfully");
	}
}