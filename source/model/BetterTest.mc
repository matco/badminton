import Toybox.Lang;
using Toybox.Test;

module BetterTest {

	function success(message as String) as Void {
		Test.assertMessage(true, message);
	}

	function fail(message as String) as Void {
		Test.assertMessage(false, message);
	}

	function assertTrue(condition as Boolean, message as String) as Void {
		Test.assertMessage(condition, message);
	}

	function assertFalse(condition as Boolean, message as String) as Void {
		Test.assertMessage(!condition, message);
	}

	function assertNull(condition as Object?, message as String) as Void {
		assertSame(condition, null, message);
	}

	function assertNotNull(condition as Object?, message as String) as Void {
		assertNotSame(condition, null, message);
	}

	function assertEqual(actual as Object?, expected as Object?, message as String) as Void {
		if(actual == null) {
			fail(message);
		}
		Test.assertEqualMessage(actual as Object, expected, message + " (expected [" + expected + "], actual [" + actual + "])");
	}

	function assertNotEqual(actual as Object?, expected as Object?, message as String) as Void {
		if(actual == null) {
			fail(message);
		}
		Test.assertNotEqualMessage(actual as Object, expected, message);
	}

	function assertSame(actual as Object?, expected as Object?, message as String) as Void {
		if(actual != expected) {
			throw new Test.AssertException(message + " (expected [" + expected + "], actual [" + actual + "])");
		}
	}

	function assertNotSame(actual as Object?, expected as Object?, message as String) as Void {
		if(actual == expected) {
			throw new Test.AssertException(message);
		}
	}
}
