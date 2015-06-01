using Toybox.System as Sys;
using Toybox.Lang as Lang;

module Helpers {

	//TODO use Lang.format instead
	function formatString(string, parameters) {
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
				result = result_before + parameters[parameters_keys[i]] + result_after;
				//compiler does no accept for loop without incrementation phase
				//loog again with same parameter until it is no more found in the string
				i--;
			}
		}
		return result;
	}

	function formatDuration(duration) {
		var value = duration.value();
		var seconds = value % 60;
		var minutes = (value / 60) % 60;
		var hours = value / 3600;
		return hours.format("%02d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
	}
}