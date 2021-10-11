using Toybox.System as Sys;
using Toybox.Math as Math;
using Toybox.Graphics as Gfx;

module UIHelpers {

	//for now consider all drawables are labels and are justified
	//improve this as soon as a method getJustification exists
	function findTappedDrawable(event, drawables) {
		var coordinate = event.getCoordinates();
		var event_x = coordinate[0];
		var event_y = coordinate[1];
		//Sys.println("press at " + event_x + "," + event_y);
		//first loop to detect if tap occurs inside one of the drawable
		for(var i = 0; i < drawables.size(); i++) {
			var drawable = drawables[i];
			//Sys.println("check drawable " + drawable.identifier + " with position " + drawable.locX + "," + drawable.locY + " and dimension " + drawable.width + " - " + drawable.height);
			//start by y axis because menus options are generally placed vertically
			if(event_y >= drawable.locY && event_y <= (drawable.locY + drawable.height)) {
				//drawable.locX is the center of the drawable because of the justification
				if(event_x >= (drawable.locX - drawable.width / 2) && event_x <= (drawable.locX + drawable.width / 2)) {
					//Sys.println("tap on drawable " + drawable.identifier);
					return drawable;
				}
			}
		}
		//second loop to find closest drawable
		var closest_distance = null;
		var closest_drawable = null;
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
		//Sys.println("tap close to drawable " + closest_drawable.identifier);
		return closest_drawable;
	}

	function drawPolygon(dc, points) {
		var counts = points.size();
		for(var i = 0; i < counts; i++) {
			var next_index = (i + 1) % counts;
			dc.drawLine(points[i][0], points[i][1], points[next_index][0], points[next_index][1]);
		}
	}

	function drawHighlightedText(dc, x, y, font, text, padding) {
		var dimensions = dc.getTextDimensions(text, font);
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.fillRoundedRectangle(x - dimensions[0] / 2 - padding, y - dimensions[1] / 2, dimensions[0] + 2 * padding, dimensions[1], 5);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawText(x, y, font, text, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
	}
}