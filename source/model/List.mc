import Toybox.Lang;

class List {
	const INITIAL_SIZE = 10;

	private var elements as Array<Object>;
	private var length as Number;

	function initialize() {
		elements = new [INITIAL_SIZE] as Array<Object>;
		length = 0;
	}

	function size() as Number {
		return length;
	}

	function isEmpty() as Boolean {
		return length == 0;
	}

	function get(index as Number) as Object {
		if(index >= length) {
			throw new Toybox.Lang.ValueOutOfBoundsException("Index " + index + " is bigger than list size (" + length + ")");
		}
		return elements[index];
	}

	function indexOf(element as Object) as Number {
		return elements.indexOf(element);
	}

	function remove(element as Object) as Object {
		length--;
		return elements.remove(element);
	}

	function push(element as Object) as Void {
		if(length + 1 > elements.size()) {
			grow();
		}
		elements[length] = element;
		length++;
	}

	function pop() as Object {
		length--;
		return elements[length];
	}

	function first() as Object {
		if(length == 0) {
			throw new Toybox.Lang.ValueOutOfBoundsException("No first element for an empty list");
		}
		return elements[0];
	}

	function last() as Object {
		if(length == 0) {
			throw new Toybox.Lang.ValueOutOfBoundsException("No last element for an empty list");
		}
		return elements[length - 1];
	}

	private function grow() as Void {
		var new_elements = new [elements.size() + INITIAL_SIZE] as Array<Object>;
		for(var i = 0; i < length; i++) {
			new_elements[i] = elements[i];
		}
		elements = new_elements;
	}
}
