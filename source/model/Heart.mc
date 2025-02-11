import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Activity;
import Toybox.Math;
import Toybox.WatchUi;

/*
Heart allows to draw a heart shape at a specific position and size
the heart shape is composed of two a-little-more-than-half circles, a triangle, and a rectangle to cover the space between the two circles
*/
class Heart extends WatchUi.Drawable {
	static const CLIP_MARGIN = 1;

	private var origin as Point2D;
	public var size as Numeric;

	private var leftCircle as Point2D;
	private var rightCircle as Point2D;
	private var triangle as Array<Point2D>;
	private var rectangle as Array<Point2D>;

	private var yCircleExtension as Numeric;
	private var xCircleExtension as Numeric;

	function initialize(parameters as Dictionary) {
		var locX = parameters.get(:locX) as Number;
		var locY = parameters.get(:locY) as Number;

		//BUG! pass only location parameters to the parent constructor because type checking does not work properly
		Drawable.initialize({
			:locX => locX,
			:locY => locY
		});

		self.origin = [locX, locY] as Point2D;
		self.size = parameters.get(:size) as Number;

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
		var activity = Activity.getActivityInfo() as Info;
		var rate = activity.currentHeartRate;

		if(rate != null) {
			var profile = UserProfile.getCurrentSport();
			var zones = UserProfile.getHeartRateZones(profile);

			//choose color for the heart icon depending on the current user zone
			var color = Graphics.COLOR_GREEN;
			if(zones != null && zones.size() > 4) {
				if(rate > zones[4]) {
					color= Graphics.COLOR_RED;
				}
				else if(rate > zones[3]) {
					color = Graphics.COLOR_YELLOW;
				}
			}

			//disable anti aliasing to draw a pixel perfect icon
			if(dc has :setAntiAlias) {
				dc.setAntiAlias(false);
			}

			dc.setColor(color, Graphics.COLOR_TRANSPARENT);

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

			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(origin[0], origin[1] + 2.5 * size, Graphics.FONT_XTINY, rate.toString(), Graphics.TEXT_JUSTIFY_CENTER);
		}
	}
}
