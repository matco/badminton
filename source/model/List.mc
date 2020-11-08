class List {
	const INITIAL_SIZE = 10;

	hidden var elements;
	hidden var length;

	function initialize() {
		elements = new [INITIAL_SIZE];
		length = 0;
	}

	function size() {
		return length;
	}

	function isEmpty() {
		return length == 0;
	}

	function get(index) {
		if(index >= length) {
			throw new Toybox.Lang.ValueOutOfBoundsException("Index " + index + " is bigger than list size (" + length + ")");
		}
		return elements[index];
	}

	function indexOf(element) {
		return elements.indexOf(element);
	}

	function remove(element) {
		length--;
		return elements.remove(element);
	}

	function push(element) {
		if(length + 1 > elements.size()) {
			grow();
		}
		elements[length] = element;
		length++;
	}

	function pop() {
		length--;
		return elements[length];
	}

	function first() {
		return length > 0 ? elements[0] : null;
	}

	function last() {
		return length > 0 ? elements[length - 1] : null;
	}

	hidden function grow() {
		var new_elements = new [elements.size() + INITIAL_SIZE];
		for(var i = 0; i < length; i++) {
			new_elements[i] = elements[i];
		}
		elements = new_elements;
	}

}