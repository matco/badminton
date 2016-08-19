using Toybox.System as Sys;
using Toybox.Test as Test;

module BetterTest {

	function fail(message) {
		Sys.println("assert fails " + message);
		throw new AssertException(message);
	}

	function assertTrue(condition, message) {
		return Test.assertMessage(condition, message);
	}

	function assertFalse(condition, message) {
		return Test.assertMessage(!condition, message);
	}

	function assertNull(condition, message) {
		return Test.assertEqualMessage(condition, null, message);
	}

	function assertNotNull(condition, message) {
		return Test.assertNotEqualMessage(condition, null, message);
	}

	function assertEqual(actual, expected, message) {
		if(actual has :equals) {
			if(!actual.equals(expected)) {
				throw new AssertException("assert equal [" + message + "] fails: expected " + expected + " - actual " + actual );
				fail(message);
			}
		}
		else {
			assertSame(actual, expected, message);
		}
	}

	function assertSame(actual, expected, message) {
		if(actual != expected) {
			throw new AssertException("assert same [" + message + "] fails: expected " + expected + " - actual " + actual);
		}
	}

}