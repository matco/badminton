class Bus {
	hidden var listeners;

	function initialize() {
		listeners = new List();
	}

	function register(listener) {
		listeners.push(listener.weak());
	}

	function unregister(listener) {
		listeners.remove(listener.weak());
	}

	function dispatch(event) {
		for(var i = 0; i < listeners.size(); i++) {
			var listener = listeners.get(i);
			if(listener.stillAlive()) {
				event.hit(listener.get());
			}
		}
	}
}

class BusEvent {
	hidden var method_name;
	hidden var payload;

	function initialize(mn, p) {
		method_name = mn;
		payload = p;
	}

	function hit(listener) {
		if(listener has method_name) {
			var method = listener.method(method_name);
			if(payload != null) {
				method.invoke(payload);
			}
			else {
				method.invoke();
			}
		}
	}
}
