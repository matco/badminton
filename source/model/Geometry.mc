using Toybox.System as Sys;
using Toybox.Math as Math;

module Geometry {

	function mean(number1, number2) {
		return weightedMean(number1, number2, 0.5);
	}

	function weightedMean(number1, number2, weight) {
		return (number1 - number2).abs() * weight + BetterMath.min(number1, number2);
	}

	function chordLength(radius, height) {
		return 2 * Math.sqrt(height * (2 * radius - height));
	}

}