using Toybox.Math;

module Geometry {

	function chordLength(radius, inner_radius) {
		return 2 * Math.sqrt(Math.pow(radius, 2) - Math.pow(inner_radius, 2));
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
	private var height;
	private var frontWidth;
	private var backWidth;
	private var depth; //depth from the baseline to the perspective point

	function initialize(front_left_corner, back_left_corner, front_right_corner, back_right_corner) {
		origin = [
			BetterMath.mean(front_right_corner[0], front_left_corner[0]),
			front_left_corner[1]
		];
		height = front_left_corner[1] - back_left_corner[1];
		frontWidth = front_right_corner[0] - front_left_corner[0];
		backWidth = back_right_corner[0] - back_left_corner[0];
		//if back width and front width are equals, it means there is no perpective
		if(backWidth == frontWidth) {
			//System.println("No perspective if back width and front width are equal");
			depth = null;
		}
		else {
			depth = frontWidth * height / (frontWidth - backWidth);
		}
	}

	function transform(coordinate) {
		//y is in [0,1] and must be scaled to [0,height]
		var adjusted_y = coordinate[1] * height;
		//x is in [-0.5,0.5] and must be scaled [-frontWidth / 2,frontWidth / 2]
		var adjusted_x = coordinate[0] * frontWidth;
		//x must be adjusted to the perspective if any
		if(depth != null) {
			adjusted_x = adjusted_x - adjusted_y * adjusted_x / depth;
		}
		//finally, translate scaled coordinates in the watch coordinates
		return [origin[0] + adjusted_x, origin[1] - adjusted_y];
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
