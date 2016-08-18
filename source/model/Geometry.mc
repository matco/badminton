using Toybox.System as Sys;
using Toybox.Math as Math;

module Geometry {

	function mean(number1, number2) {
		return weightedMean(number1, number2, 0.5);
	}

	function weightedMean(number1, number2, weight) {
		return (number1 - number2).abs() * weight + BetterMath.min(number1, number2);
	}

	function chordLength(radius, distance) {
		return 2 * Math.sqrt(distance * (2 * radius - distance));
	}

}