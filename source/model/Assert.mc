using Toybox.System as Sys;

class AssertionError extends Toybox.Lang.Exception {
}

module Assert {

	function fail(message) {
		Sys.println("assert fails " + message);
		throw new AssertionError(message);
	}

	function isEqual(actual, expected, message) {
		if(actual has :equals) {
			if(!actual.equals(expected)) {
				Sys.println("assert equal fails: expected " + expected + " - actual " + actual);
				fail(message);
			}
		}
		else {
			isSame(actual, expected, message);
		}
	}

	function isSame(actual, expected, message) {
		if(actual != expected) {
			Sys.println("assert same fails: expected " + expected + " - actual " + actual);
			fail(message);
		}
	}

	function isTrue(condition, message) {
		isSame(condition, true, message);
	}

	function isFalse(condition, message) {
		isSame(condition, false, message);
	}

	function isNull(condition, message) {
		if(condition != null) {
			fail(message);
		}
	}

	function isNotNull(condition, message) {
		if(condition == null) {
			fail(message);
		}
	}

}