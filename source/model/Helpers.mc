import Toybox.Lang;
import Toybox.Time;
using Toybox.Time.Gregorian;

module Helpers {

	//TODO use Lang.format instead
	function formatString(string as String, parameters as Dictionary<String, Object>) as String {
		var result = string;
		var parameters_keys = parameters.keys();
		//compiler does no accept for loop without incrementation phase
		var i;
		for(i = 0; i < parameters_keys.size(); i++) {
			var parameter_key = "${" + parameters_keys[i] + "}";
			var parameter_index = result.find(parameter_key);
			if(parameter_index != null) {
				var result_before = parameter_index > 0 ? result.substring(0, parameter_index) : "";
				var result_after = result.substring(parameter_index + parameter_key.length(), result.length());
				var parameter = parameters[parameters_keys[i]] as Object;
				result = result_before + parameter.toString() + result_after;
				//compiler does no accept for loop without incrementation phase
				//loog again with same parameter until it is no more found in the string
				i--;
			}
		}
		return result;
	}

	function formatDuration(duration as Duration) as String {
		var time = duration.value();
		var seconds = time % 60;
		var minutes = (time / 60) % 60;
		var hours = time / 3600;
		return Lang.format("$1$:$2$:$3$", [hours.format("%02d"), minutes.format("%02d"), seconds.format("%02d")]);
	}


	function formatCurrentTime(clock_24 as Boolean, am_label as String, pm_label as String) as String {
		var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var hour = now.hour;
		var am_pm_label = am_label;
		if(!clock_24) {
			if(hour >= 12) {
				am_pm_label = pm_label;
			}
			if(hour > 12) {
				hour -= 12;
				am_pm_label = pm_label;
			} else if(hour == 0) {
				hour = 12;
				am_pm_label = pm_label;
			}
		}
		var time_label = Lang.format("$1$:$2$:$3$", [hour.format("%02d"), now.min.format("%02d"), now.sec.format("%02d")]);
		if(!clock_24) {
			time_label += " " + am_pm_label;
		}
		return time_label;
	}
}
