import Toybox.Lang;
import Toybox.Graphics;
using Toybox.Math;

module Geometry {

	function chordLength(radius as Float, inner_radius as Float) as Float {
		return 2f * Math.sqrt(Math.pow(radius, 2) - Math.pow(inner_radius, 2)) as Float;
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

	private var origin as Array<Float>;
	private var height as Float;
	private var frontWidth as Float;
	private var backWidth as Float;
	private var depth as Float?; //depth from the baseline to the perspective point

	function initialize(front_left_corner as Array<Float>, back_left_corner as Array<Float>, front_right_corner as Array<Float>, back_right_corner as Array<Float>) {
		origin = [
			BetterMath.mean(front_right_corner[0], front_left_corner[0]),
			front_left_corner[1]
		] as Array<Float>;
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

	function transform(coordinate as Array<Float>) as Array<Float> {
		//y is in [0,1] and must be scaled to [0,height]
		var adjusted_y = coordinate[1] * height as Float;
		//x is in [-0.5,0.5] and must be scaled [-frontWidth / 2,frontWidth / 2]
		var adjusted_x = coordinate[0] * frontWidth as Float;
		//x must be adjusted to the perspective if any
		if(depth != null) {
			adjusted_x = adjusted_x - adjusted_y * adjusted_x / depth;
		}
		//finally, translate scaled coordinates in the watch coordinates
		return [origin[0] + adjusted_x, origin[1] - adjusted_y] as Array<Float>;
	}

	function transformArray(coordinates as Array<Array<Float>>) as Array<Array<Float>> {
		var transformed_coordinates = new [coordinates.size()] as Array<Array<Float>>;
		for(var i = 0; i < coordinates.size(); i++) {
			transformed_coordinates[i] = transform(coordinates[i]);
		}
		return transformed_coordinates;
	}

	function drawVanishingLine(dc as Dc, x as Float) as Void {
		drawPartialVanishingLine(dc, x, 0f, 1f);
	}

	function drawPartialVanishingLine(dc as Dc, x as Float, y1 as Float, y2 as Float) as Void {
		var beginning = transform([x, y1] as Array<Float>);
		var end = transform([x, y2] as Array<Float>);
		dc.drawLine(beginning[0], beginning[1], end[0], end[1]);
	}

	function drawTransversalLine(dc as Dc, y as Float) as Void {
		var beginning = transform([-0.5, y] as Array<Float>);
		var end = transform([0.5, y] as Array<Float>);
		dc.drawLine(beginning[0], beginning[1], end[0], end[1]);
	}

	function fillPolygon(dc as Dc, coordinates as Array<Array<Float>>) as Void {
		dc.fillPolygon(transformArray(coordinates));
	}

}
