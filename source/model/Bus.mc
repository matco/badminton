import Toybox.Lang;

class Bus {
	private var listeners as List;

	function initialize() {
		listeners = new List();
	}

	function register(listener as Object) as Void {
		listeners.push(listener.weak());
	}

	function unregister(listener as Object) as Void {
		listeners.remove(listener.weak());
	}

	function dispatch(event as BusEvent) as Void {
		for(var i = 0; i < listeners.size(); i++) {
			var reference = listeners.get(i) as WeakReference;
			if(reference.stillAlive()) {
				var listener = reference.get();
				if(listener != null) {
					event.hit(listener);
				}
			}
		}
	}
}

class BusEvent {
	private var method_name as Symbol;
	private var payload as Object?;

	function initialize(mn as Symbol, p as Object?) {
		method_name = mn;
		payload = p;
	}

	function hit(listener as Object) as Void {
		if(listener has method_name) {
			if(payload != null) {
				var method = listener.method(method_name) as Method(payload as Object?) as Void;
				method.invoke(payload);
			}
			else {
				var method = listener.method(method_name) as Method() as Void;
				method.invoke();
			}
		}
	}
}
