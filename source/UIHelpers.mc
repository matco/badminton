import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Math;
using Toybox.Graphics;
using Toybox.System;

module UIHelpers {

	//for now consider all drawables are labels and are justified
	//improve this as soon as a method getJustification exists
	function findTappedDrawable(event as ClickEvent, drawables as Array<Drawable>) as Drawable? {
		var coordinate = event.getCoordinates();
		var event_x = coordinate[0];
		var event_y = coordinate[1];
		//System.println("press at " + event_x + "," + event_y);
		//first loop to detect if tap occurs inside one of the drawable
		for(var i = 0; i < drawables.size(); i++) {
			var drawable = drawables[i];
			//System.println("check drawable " + drawable.identifier + " with position " + drawable.locX + "," + drawable.locY + " and dimension " + drawable.width + " - " + drawable.height);
			//start by y axis because menus options are generally placed vertically
			if(event_y >= drawable.locY && event_y <= (drawable.locY + drawable.height)) {
				//drawable.locX is the center of the drawable because of the justification
				if(event_x >= (drawable.locX - drawable.width / 2) && event_x <= (drawable.locX + drawable.width / 2)) {
					//System.println("tap on drawable " + drawable.identifier);
					return drawable;
				}
			}
		}
		//second loop to find closest drawable
		var closest_distance = null as Float?;
		var closest_drawable = null as Drawable?;
		for(var i = 0; i < drawables.size(); i++) {
			var drawable = drawables[i];
			var drawable_x = drawable.locX;
			var drawable_y = drawable.locY + drawable.height / 2;
			var distance = Math.pow(drawable_x - event_x, 2) + Math.pow(drawable_y - event_y, 2);
			if(closest_distance == null || distance < closest_distance) {
				closest_distance = distance;
				closest_drawable = drawable;
			}
		}
		//System.println("tap close to drawable " + closest_drawable.identifier);
		return closest_drawable;
	}

	function drawPolygon(dc as Dc, points as Array<Point2D>) as Void {
		var counts = points.size();
		for(var i = 0; i < counts; i++) {
			var next_index = (i + 1) % counts;
			dc.drawLine(points[i][0], points[i][1], points[next_index][0], points[next_index][1]);
		}
	}

	function drawHighlightedNumber(dc as Dc, x as Numeric, y as Numeric, font as FontType, text as String, color as Number, vertical_padding as Number, horizontal_padding as Number) as Void {
		var dimensions = dc.getTextDimensions(text, font);
		//the font height includes a default top margin that is useless
		var offset = dimensions[1] * 0.12;
		//calculate the real height of the text that will be actually be displayed
		//remove the font descent because numbers don't have any descent
		var font_height = (dimensions[1] - Graphics.getFontDescent(font));
		//calculate the dimensions of the highlighting rectangle
		var width = dimensions[0] + 2 * horizontal_padding;
		var height = font_height + 2 * vertical_padding;
		//draw the highlighting rectangle
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		dc.fillRoundedRectangle(x - width / 2, y - height / 2, width, height, 5);
		//draw the score
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);
		//manually center the text vertically by discarding the top margin and removing half of the real height of the text
		dc.drawText(x, y - offset - font_height / 2, font, text, Graphics.TEXT_JUSTIFY_CENTER);
	}
}
