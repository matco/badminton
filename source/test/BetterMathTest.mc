module BetterMathTest {

	(:test)
	function testMin(logger) {
		BetterTest.assertEqual(BetterMath.min(-2, 2), -2, "Minimum between -2 and 2 is -2");
		BetterTest.assertEqual(BetterMath.min(2, -2), -2, "Minimum between 2 and -2 is -2");
		BetterTest.assertEqual(BetterMath.min(2, 2), 2, "Minimum between 2 and 2 is 2");
		BetterTest.assertEqual(BetterMath.min(2, 3), 2, "Minimum between 2 and 3 is 2");
		BetterTest.assertEqual(BetterMath.min(-2, -3), -3, "Minimum between -2 and -3 is -3");
		return true;
	}

	(:test)
	function testMax(logger) {
		BetterTest.assertEqual(BetterMath.max(-2, 2), 2, "Maximum between -2 and 2 is 2");
		BetterTest.assertEqual(BetterMath.max(2, -2), 2, "Maximum between 2 and -2 is 2");
		BetterTest.assertEqual(BetterMath.max(2, 2), 2, "Maximum between 2 and 2 is 2");
		BetterTest.assertEqual(BetterMath.max(2, 3), 3, "Maximum between 2 and 3 is 3");
		BetterTest.assertEqual(BetterMath.max(-2, -3), -2, "Maximum between -2 and -3 is -2");
		return true;
	}

	(:test)
	function testMean(logger) {
		BetterTest.assertEqual(BetterMath.mean(2, 4), 3f, "Middle of 2 and 4 is 3");
		BetterTest.assertEqual(BetterMath.mean(-4, 4), 0f, "Middle of -4 and 4 is 0");
		BetterTest.assertEqual(BetterMath.mean(-4, -2), -3f, "Middle of -4 and -2 is -3");
		return true;
	}

	(:test)
	function testWeightedMean(logger) {
		BetterTest.assertEqual(BetterMath.weightedMean(0, 4, 0.25), 1f, "1/4 of path between 0 and 4 is 1");
		BetterTest.assertEqual(BetterMath.weightedMean(0, 4, 0.5), 2f, "1/2 of path between 0 and 4 is 2");
		BetterTest.assertEqual(BetterMath.weightedMean(0, 4, 0), 0, "0 of path between 0 and 4 is 0");
		BetterTest.assertEqual(BetterMath.weightedMean(0, 4, 1), 4, "1 of path between 0 and 4 is 4");
		return true;
	}
}
