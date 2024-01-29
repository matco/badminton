import Toybox.Lang;
import Toybox.Test;
import Toybox.System;
import Toybox.Activity;
import Toybox.ActivityRecording;

module IQTest {

	//this is more a documentation than a test
	//this test can be run on the Fenix 5 (max API v3.1.0), the Fenix 6 (max API v3.4.0) or the Fenix 7 (max API v4.2.0)
	(:test)
	function testActivity(logger as Logger) as Boolean {
		var version = System.getDeviceSettings().monkeyVersion;
		var v320 = version[0] > 3 || version[0] == 3 && version[1] >= 2;
		var v410 = version[0] > 4 || version[0] == 4 && version[1] >= 1;
		System.println("Version: " + version);
		System.println("Has new properties: " + v320 + " - Has new sports: " + v410);

		//devices >= 3.2.0 have all the new properties in Activity, if checked with "has"
		//even if they don't support the new sports, they are available
		if(v320) {
			BetterTest.assertFalse(Activity has :SPORT_LEAP_FROG, "The new activity properties does not include leap frog");
			BetterTest.assertTrue(Activity has :SPORT_CYCLING, "The new activity properties includes cycling");
			//the following assert should be valid only for devices >= 4.1.0
			BetterTest.assertTrue(Activity has :SPORT_RACKET, "The new activity properties includes racket");
		}
		//devices < 3.2.0 don't have the new properties in Activity, if checked with "has"
		else {
			BetterTest.assertFalse(Activity has :SPORT_LEAP_FROG, "The new activity properties does not include leap frog");
			BetterTest.assertFalse(Activity has :SPORT_CYCLING, "The new activity properties does not include cycling");
			BetterTest.assertFalse(Activity has :SPORT_RACKET, "The new activity properties does not include racket");
		}

		//however, all devices have the new properties in Activity, if checked directly!
		BetterTest.assertEqual(Activity.SPORT_CYCLING, 2, "All devices have the new activity properties that includes cycling (stored as 2)");
		BetterTest.assertEqual(Activity.SPORT_RACKET, 64, "All devices have the new activity properties that includes racket (stored as 64)");

		//by the way, all devices have the old properties in ActivityRecording
		BetterTest.assertTrue(ActivityRecording has :SPORT_CYCLING, "All devices have the old activity recording properties that includes cycling");
		BetterTest.assertEqual(ActivityRecording.SPORT_CYCLING, 2, "All devices have the old activity recording properties that includes cycling (stored as 2)");
		BetterTest.assertFalse(ActivityRecording has :SPORT_RACKET, "The old activity recording properties does not include racket");

		//this means that "has" can not be used to decide if the new sports and sub sports can be used
		//but the new enum can be used on all devices (and this removes the deprecation messages)
		var sport = Activity has :SPORT_RACKET ? Activity.SPORT_RACKET : Activity.SPORT_GENERIC;
		if(v410) {
			BetterTest.assertEqual(sport, 64, "For devices >= 4.1.0, selected sport is racket");
		}
		else if(v320) {
			BetterTest.assertEqual(sport, 64, "This assert should not be valid, devices < 4.1.0 should fallback to the generic sport");
		}
		else {
			BetterTest.assertEqual(sport, 0, "In old versions, fallback to the generic sport");
		}

		var sub_sport = Activity has :SUB_SPORT_BADMINTON ? Activity.SUB_SPORT_BADMINTON : Activity.SUB_SPORT_MATCH;
		if(v410) {
			BetterTest.assertEqual(sub_sport, 95, "For devices >= 4.1.0, selected sub sport is badminton");
		}
		else if(v320) {
			BetterTest.assertEqual(sub_sport, 95, "This assert should not be valid, devices < 4.1.0 should fallback to match");
		}
		else {
			BetterTest.assertEqual(sub_sport, 22, "In old versions, fallback to match");
		}

		//however, this looks like a bug of the simulator
		//on a device, it's better to check the device version and to use the appropriate properties, even if this triggers deprecation messages
		//var sport = v410 ? Activity.SPORT_RACKET : ActivityRecording.SPORT_GENERIC;
		//var sub_sport = v410 ? Activity.SUB_SPORT_BADMINTON : ActivityRecording.SUB_SPORT_MATCH;

		return true;
	}
}
