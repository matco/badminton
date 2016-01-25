using Toybox.System as Sys;
using Toybox.Math as Math;

module Geometry {

	function middle(number1, number2, ratio) {
		if(ratio == null) {
			ratio = 0.5;
		}
		return (number1 - number2).abs() * ratio + BetterMath.min(number1, number2);
	}

	function chordLength(radius, height) {
		return 2 * Math.sqrt(height * (2 * radius - height));
	}

}