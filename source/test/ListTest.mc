module ListTest {

	(:test)
	function testNewList(logger) {
		var list = new List();
		BetterTest.assertTrue(list.isEmpty(), "Newly created list is empty");
		BetterTest.assertEqual(list.size(), 0, "Newly created list size is 0");
		BetterTest.assertNull(list.first(), "Getting first element of newly created list returns null");
		BetterTest.assertNull(list.last(), "Getting last element of newly created list returns null");
		return true;
	}

	(:test)
	function testOneElementList(logger) {
		var list = new List();
		list.push(3);
		BetterTest.assertFalse(list.isEmpty(), "Adding an element to a list makes it not empty");
		BetterTest.assertEqual(list.size(), 1, "List containing 1 element has a size 1");
		BetterTest.assertEqual(list.first(), 3, "Getting first element of a list returns the first element");
		BetterTest.assertEqual(list.last(), 3, "Getting last element of a list returns the last element");
		return true;
	}

	(:test)
	function testTwoElementsList(logger) {
		var list = new List();
		list.push(3);
		list.push(5);
		BetterTest.assertEqual(list.size(), 2, "List containing 2 elements has a size 2");
		BetterTest.assertEqual(list.first(), 3, "Getting first element of a list returns the first element");
		BetterTest.assertEqual(list.last(), 5, "Getting last element of a list returns the last element");
		return true;
	}
}
