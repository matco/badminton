using Toybox.System as Sys;
using Toybox.Math as Math;

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
					Sys.println("tap on drawable " + drawable.identifier);
					return drawable;
				}
			}
		}
		//second loop to find closest drawable
		var closest = {};
		for(var i = 0; i < drawables.size(); i++) {
			var drawable = drawables[i];
			var drawable_x = drawable.locX;
			var drawable_y = drawable.locY + drawable.height / 2;
			var distance = Math.pow(drawable_x - event_x, 2) + Math.pow(drawable_y - event_y, 2);
			if(!closest.hasKey("distance") || distance < closest.get("distance")) {
				closest.put("distance", distance);
				closest.put("drawable", drawable);
			}
		}
		Sys.println("tap close to drawable " + closest.get("drawable").identifier);
		return closest.get("drawable");
	}
}