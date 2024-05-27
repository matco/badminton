import Toybox.Lang;
import Toybox.Graphics;
using Toybox.Math;

/*
Heart allows to draw a heart shape at a specific position and size
the heart shape is composed of two a-little-more-than-half circles, a triangle, and a rectangle to cover the space between the two circles
*/
class Heart {
	static const CLIP_MARGIN = 1;

	private var origin as Point2D;
	private var size as Numeric;

	private var leftCircle as Point2D;
	private var rightCircle as Point2D;
	private var triangle as Array<Point2D>;
	private var rectangle as Array<Point2D>;

	private var yCircleExtension as Numeric;
	private var xCircleExtension as Numeric;

	function initialize(origin as Point2D, size as Numeric) {
		self.origin = origin;
		self.size = size;

		leftCircle = [origin[0] - size, origin[1]];
		rightCircle = [origin[0] + size, origin[1]];

		var angle = Math.PI / 4;
		yCircleExtension = Math.round(size * Math.sin(angle));
		xCircleExtension = Math.round(size * (1 - Math.cos(angle)));
		triangle = [
			[origin[0] - 2 * size + xCircleExtension, origin[1] + yCircleExtension],
			[origin[0] + 2 * size - xCircleExtension, origin[1] + yCircleExtension],
			[origin[0], origin[1] + 2 * size]
		];
		rectangle = [
			[origin[0] - size / 2, origin[1]],
			[origin[0] + size / 2, origin[1]],
			[origin[0] + size / 2, origin[1] + size],
			[origin[0] - size / 2, origin[1] + size]
		];
	}

	function draw(dc as Dc) as Void {
		//draw half circles by clipping the bottom part of full circles
		//add a margin on the top and bottom because rounded coordinates may result in bad clipping
		dc.setClip(
			origin[0] as Numeric - size * 2 - CLIP_MARGIN,
			origin[1] as Numeric - size - CLIP_MARGIN,
			size * 4 + 2 * CLIP_MARGIN,
			size + yCircleExtension + 2 * CLIP_MARGIN);
		dc.fillCircle(leftCircle[0], leftCircle[1], size);
		dc.fillCircle(rightCircle[0], rightCircle[1], size);
		dc.clearClip();
		dc.fillPolygon(triangle);
		dc.fillPolygon(rectangle);
	}
}
