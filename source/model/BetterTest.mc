using Toybox.Test as Test;

module BetterTest {

	function success(message) {
		Test.assertMessage(true, message);
	}

	function fail(message) {
		Test.assertMessage(false, message);
	}

	function assertTrue(condition, message) {
		Test.assertMessage(condition, message);
	}

	function assertFalse(condition, message) {
		Test.assertMessage(!condition, message);
	}

	function assertNull(condition, message) {
		assertSame(condition, null, message);
	}

	function assertNotNull(condition, message) {
		assertNotSame(condition, null, message);
	}

	function assertEqual(actual, expected, message) {
		Test.assertEqualMessage(actual, expected, message);
	}

	function assertNotEqual(actual, expected, message) {
		Test.assertNotEqualMessage(actual, expected, message);
	}

	function assertSame(actual, expected, message) {
		if(actual != expected) {
			throw new Test.AssertException("ASSERTION FAILED: " + message + " (expected [" + expected + "], actual [" + actual + "]");
		}
	}

	function assertNotSame(actual, expected, message) {
		if(actual == expected) {
			throw new Test.AssertException("ASSERTION FAILED: " + message);
		}
	}
}
