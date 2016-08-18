using Toybox.System as Sys;
using Toybox.Math as Math;

module Geometry {

	function chordLength(radius, distance) {
		return 2 * Math.sqrt(distance * (2 * radius - distance));
	}

}