using Toybox.System as Sys;
using Toybox.Math as Math;

module UIHelpers {

	function findTappedDrawable(event, drawables) {
		var coordinate = event.getCoordinates();
		var event_x = coordinate[0];
		var event_y = coordinate[1];
		//first loop to detect if tap occurs inside one of the drawable
		for(var i = 0; i < drawables.size(); i++) {
			var drawable = drawables[i];
			//start by y axis because menus options are generally placed vertically
			if(event_y >= drawable.locY && event_y <= (drawable.locY + drawable.height) && event_x >= (drawable.locX) && event_x <= (drawable.locX + drawable.width)) {
				Sys.println("tap on drawable " + drawable.identifier);
				return drawable;
			}
		}
		//second loop to find closest drawable
		var closest = {};
		for(var i = 0; i < drawables.size(); i++) {
			var drawable = drawables[i];
			var drawable_x = drawable.locX + drawable.width / 2;
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