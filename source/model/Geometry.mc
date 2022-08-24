using Toybox.Math;

module Geometry {

	function chordLength(radius, distance) {
		return 2 * Math.sqrt(distance * (2 * radius - distance));
	}
}

/*
Perspective offers a simple coordinate system over the coordinate system of the watch. It does the following:
- transform the coordinates of a point into its coordinates in a single point perspective projection
- transform these coordinates into the coordinates system of the watch
The axis system for Perspective is like the perpendicular symbol (⊥):
- the y-axis is a vertical line at the center of the perspective (the only line that is perfectly vertical in the perspective) and ranges from 0 at the front to 1 at the back
- the x-axis is an horizontal line at the front (the baseline of the perspective) and ranges from -0.5 far left to 0.5 far right
*/
class Perspective {

	private var origin;
	private var frontWidth;
	private var backWidth;
	private var depth; //visible depth
	private var maxDepth; //maximum depth from the baseline to the perspective point

	function initialize(front_left_corner, back_left_corner, front_right_corner, back_right_corner) {
		origin = [
			BetterMath.mean(front_right_corner[0], front_left_corner[0]),
			front_left_corner[1]
		];
		frontWidth = front_right_corner[0] - front_left_corner[0];
		backWidth = back_right_corner[0] - back_left_corner[0];
		depth = front_left_corner[1] - back_left_corner[1];
		maxDepth = frontWidth * depth / (frontWidth - backWidth);
	}

	function transform(coordinate) {
		return [
			//x is in [-0.5,0.5] and must be adjusted to the right perspective
			origin[0] + (maxDepth - coordinate[1] * depth) * coordinate[0] * frontWidth / maxDepth,
			//y is in [0,1] and must be adjusted to [0,depth]
			origin[1] - coordinate[1] * depth
		];
	}

	function transformArray(coordinates) {
		var transformed_coordinates = new [coordinates.size()];
		for(var i = 0; i < coordinates.size(); i++) {
			transformed_coordinates[i] = transform(coordinates[i]);
		}
		return transformed_coordinates;
	}

	function drawVanishingLine(dc, x) {
		drawPartialVanishingLine(dc, x, 0, 1);
	}

	function drawPartialVanishingLine(dc, x, y1, y2) {
		var beginning = transform([x, y1]);
		var end = transform([x, y2]);
		dc.drawLine(beginning[0], beginning[1], end[0], end[1]);
	}

	function drawTransversalLine(dc, y) {
		var beginning = transform([-0.5, y]);
		var end = transform([0.5, y]);
		dc.drawLine(beginning[0], beginning[1], end[0], end[1]);
	}

	function fillPolygon(dc, coordinates) {
		dc.fillPolygon(transformArray(coordinates));
	}

}
