using Toybox.Time as Time;

module BetterMathTest {

	function testMin() {
		Assert.isEqual(BetterMath.min(-2, 2), -2, "Minimum between -2 and 2 is -2");
		Assert.isEqual(BetterMath.min(2, -2), -2, "Minimum between 2 and -2 is -2");
		Assert.isEqual(BetterMath.min(2, 2), 2, "Minimum between 2 and 2 is 2");
		Assert.isEqual(BetterMath.min(2, 3), 2, "Minimum between 2 and 3 is 2");
		Assert.isEqual(BetterMath.min(-2, -3), -3, "Minimum between -2 and -3 is -3");
	}

	function testMax() {
		Assert.isEqual(BetterMath.max(-2, 2), 2, "Maximum between -2 and 2 is 2");
		Assert.isEqual(BetterMath.max(2, -2), 2, "Maximum between 2 and -2 is 2");
		Assert.isEqual(BetterMath.max(2, 2), 2, "Maximum between 2 and 2 is 2");
		Assert.isEqual(BetterMath.max(2, 3), 3, "Maximum between 2 and 3 is 3");
		Assert.isEqual(BetterMath.max(-2, -3), -2, "Maximum between -2 and -3 is -2");
	}
}