import Toybox.Lang;
import Toybox.Test;

module ListTest {

	(:test)
	function testNewList(logger as Logger) as Boolean {
		var list = new List();
		BetterTest.assertTrue(list.isEmpty(), "Newly created list is empty");
		BetterTest.assertEqual(list.size(), 0, "Newly created list size is 0");
		try {
			list.first();
			BetterTest.fail("Getting the first element of an empty list should throw an out of bound exception");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "No first element for an empty list", "Retrieving the first element of an empty list throws an exception");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.ValueOutOfBoundsException, "Retrieving the first element of an empty list throws an exception");
		}
		try {
			list.last();
			BetterTest.fail("Getting the last element of an empty list should throw an out of bound exception");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "No last element for an empty list", "Retrieving the last element of an empty list throws an exception");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.ValueOutOfBoundsException, "Retrieving the last element of an empty list throws an exception");
		}
		return true;
	}

	(:test)
	function testOneElementList(logger as Logger) as Boolean {
		var list = new List();
		list.push(3);
		BetterTest.assertFalse(list.isEmpty(), "Adding an element to a list makes it not empty");
		BetterTest.assertEqual(list.size(), 1, "List containing 1 element has a size 1");
		BetterTest.assertEqual(list.first(), 3, "Getting first element of a list returns the first element");
		BetterTest.assertEqual(list.last(), 3, "Getting last element of a list returns the last element");
		return true;
	}

	(:test)
	function testTwoElementsList(logger as Logger) as Boolean {
		var list = new List();
		list.push(3);
		list.push(5);
		BetterTest.assertEqual(list.size(), 2, "List containing 2 elements has a size 2");
		BetterTest.assertEqual(list.first(), 3, "Getting first element of a list returns the first element");
		BetterTest.assertEqual(list.last(), 5, "Getting last element of a list returns the last element");
		return true;
	}

	(:test)
	function testRetrieval(logger as Logger) as Boolean {
		var list = new List();
		list.push(3);
		list.push(5);
		BetterTest.assertEqual(list.get(0), 3, "Get method retrieve the good element");
		BetterTest.assertEqual(list.get(1), 5, "Get method retrieve the good element");
		try {
			list.get(2);
			BetterTest.fail("Should throw an out of bound exception");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "Index 2 is bigger than list size (2)", "Retrieving an element with an index too big throws an exception");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.ValueOutOfBoundsException, "Retrieving an element with an index too big throws an exception");
		}
		return true;
	}

	(:test)
	function testIndexOf(logger as Logger) as Boolean {
		var list = new List();
		list.push(3);
		list.push(4);
		list.push(5);
		BetterTest.assertEqual(list.indexOf(3), 0, "IndexOf method returns the good index");
		BetterTest.assertEqual(list.indexOf(5), 2, "IndexOf method returns the good index");
		BetterTest.assertEqual(list.indexOf(4), 1, "IndexOf method returns the good index");
		return true;
	}

	(:test)
	function testRemoval(logger as Logger) as Boolean {
		var list = new List();
		list.push(3);
		list.push(4);
		list.push(5);
		BetterTest.assertEqual(list.get(1), 4, "Get method retrieve the good element");
		list.remove(4);
		BetterTest.assertEqual(list.get(0), 3, "Removal shift the indices properly");
		BetterTest.assertEqual(list.get(1), 5, "Removal shift the indices properly");
		try {
			list.get(2);
			BetterTest.fail("Should throw an out of bound exception");
		}
		catch(exception) {
			BetterTest.assertEqual(exception.getErrorMessage(), "Index 2 is bigger than list size (2)", "Retrieving an element with an index too big throws an exception");
			BetterTest.assertTrue(exception instanceof Toybox.Lang.ValueOutOfBoundsException, "Retrieving an element with an index too big throws an exception");
		}

		return true;
	}
}
