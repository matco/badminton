import Toybox.Lang;
import Toybox.Test;

module BetterMathTest {

	(:test)
	function testMin(logger as Logger) as Boolean {
		BetterTest.assertEqual(BetterMath.min(-2f, 2f), -2f, "Minimum between -2 and 2 is -2");
		BetterTest.assertEqual(BetterMath.min(2f, -2f), -2f, "Minimum between 2 and -2 is -2");
		BetterTest.assertEqual(BetterMath.min(2f, 2f), 2f, "Minimum between 2 and 2 is 2");
		BetterTest.assertEqual(BetterMath.min(2f, 3f), 2f, "Minimum between 2 and 3 is 2");
		BetterTest.assertEqual(BetterMath.min(-2f, -3f), -3f, "Minimum between -2 and -3 is -3");
		return true;
	}

	(:test)
	function testMax(logger as Logger) as Boolean {
		BetterTest.assertEqual(BetterMath.max(-2f, 2f), 2f, "Maximum between -2 and 2 is 2");
		BetterTest.assertEqual(BetterMath.max(2f, -2f), 2f, "Maximum between 2 and -2 is 2");
		BetterTest.assertEqual(BetterMath.max(2f, 2f), 2f, "Maximum between 2 and 2 is 2");
		BetterTest.assertEqual(BetterMath.max(2f, 3f), 3f, "Maximum between 2 and 3 is 3");
		BetterTest.assertEqual(BetterMath.max(-2f, -3f), -2f, "Maximum between -2 and -3 is -2");
		return true;
	}

	(:test)
	function testMean(logger as Logger) as Boolean {
		BetterTest.assertEqual(BetterMath.mean(2f, 4f), 3f, "Middle of 2 and 4 is 3");
		BetterTest.assertEqual(BetterMath.mean(-4f, 4f), 0f, "Middle of -4 and 4 is 0");
		BetterTest.assertEqual(BetterMath.mean(-4f, -2f), -3f, "Middle of -4 and -2 is -3");
		return true;
	}

	(:test)
	function testWeightedMean(logger as Logger) as Boolean {
		BetterTest.assertEqual(BetterMath.weightedMean(0f, 4f, 0.25), 1f, "1/4 of path between 0 and 4 is 1");
		BetterTest.assertEqual(BetterMath.weightedMean(0f, 4f, 0.5), 2f, "1/2 of path between 0 and 4 is 2");
		BetterTest.assertEqual(BetterMath.weightedMean(0f, 4f, 0f), 0f, "0 of path between 0 and 4 is 0");
		BetterTest.assertEqual(BetterMath.weightedMean(0f, 4f, 1f), 4f, "1 of path between 0 and 4 is 4");
		return true;
	}
}
