module ListTest {

	function testNewList() {
		var list = new List();
		Assert.isTrue(list.isEmpty(), "Newly created list is empty");
		Assert.isEqual(list.size(), 0, "Newly created list size is 0");
		Assert.isNull(list.first(), "Getting first element of newly created list returns null");
		Assert.isNull(list.last(), "Getting last element of newly created list returns null");
	}

	function testOneElementList() {
		var list = new List();
		list.push(3);
		Assert.isFalse(list.isEmpty(), "Adding an element to a list makes it not empty");
		Assert.isEqual(list.size(), 1, "List containing 1 element has a size 1");
		Assert.isEqual(list.first(), 3, "Getting first element of a list returns the first element");
		Assert.isEqual(list.last(), 3, "Getting last element of a list returns the last element");
	}

	function testTwoElementsList() {
		var list = new List();
		list.push(3);
		list.push(5);
		Assert.isEqual(list.size(), 2, "List containing 1 element has a size 1");
		Assert.isEqual(list.first(), 3, "Getting first element of a list returns the first element");
		Assert.isEqual(list.last(), 5, "Getting last element of a list returns the last element");
	}
}
