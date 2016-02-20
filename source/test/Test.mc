using Toybox.System as Sys;

module Test {
	function test() {
		ListTest.testNewList();
		ListTest.testOneElementList();
		ListTest.testTwoElementsList();

		BetterMathTest.testMin();
		BetterMathTest.testMax();

		GeometryTest.testMiddle();

		HelpersTest.testFormatString();
		HelpersTest.testFormatDuration();

		MatchTest.testNewMatch();
		MatchTest.testBeginMatch();
		MatchTest.testScore();

		Sys.println("Tests executed successfully");	
	}
}