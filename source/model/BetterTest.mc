using Toybox.System as Sys;
using Toybox.Test as Test;

module BetterTest {

	function assertTrue(condition, message) {
		return Test.assertMessage(condition, message);
	}

	function assertFalse(condition, message) {
		return Test.assertMessage(!condition, message);
	}

	function assertNull(condition, message) {
		return assertSame(condition, null, message);
	}

	function assertNotNull(condition, message) {
		return assertNotSame(condition, null, message);
	}

	function assertEqual(actual, expected, message) {
		return Test.assertEqualMessage(actual, expected, message);
	}

	function assertNotEqual(actual, expected, message) {
		return Test.assertNotEqualMessage(actual, expected, message);
	}

	function assertSame(actual, expected, message) {
		if(actual != expected) {
			throw new Test.AssertException("ASSERTION FAILED: " + message + " (expected [" + expected + "], actual [" + actual, "]");
		}
	}

	function assertNotSame(actual, expected, message) {
		if(actual == expected) {
			throw new Test.AssertException("ASSERTION FAILED: " + message);
		}
	}

}