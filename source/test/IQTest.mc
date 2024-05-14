import Toybox.Lang;
import Toybox.Test;
import Toybox.System;
import Toybox.Activity;
import Toybox.ActivityRecording;

module IQTest {

	//this is more a documentation than a test
	//the goal is to show that the "has" keyword cannot be used to check if the new sports and sub sports are available
	//remember that Activity.SPORT_RACKET and Activity.SUB_SPORT_BADMINTON are available only in v4.1.6+
	//also remember that the sports and sub sports properties have been moved from ActivityRecording to Activity in v3.2.0+
	//this test should be run on the Fenix 5 (max API v3.1.0), the Fenix 6 (max API v3.4.0) and the Fenix 7 (max API v5.0.0)
	//with these devices, the test will pass because the asserts have been modified to accomodate the bugs in the simulator (see "BUG!" comments below)
	//this test will fail properly when run on the Forerunner 945 (max API v3.3.1)
	(:test)
	function testActivity(logger as Logger) as Boolean {
		var version = System.getDeviceSettings().monkeyVersion;
		var v320 = version[0] > 3 || version[0] == 3 && version[1] >= 2;
		var v410 = version[0] > 4 || version[0] == 4 && version[1] >= 1;
		System.println("Version: " + version);
		System.println("Has new properties: " + v320 + " - Has new sports: " + v410);

		//v3.2.0+ devices have all the new properties in Activity, if checked with "has"
		//even if they don't support the new sports, they are available
		if(v320) {
			//BetterTest.assertFalse(Activity has :SPORT_LEAP_FROG, "The new activity properties does not include leap frog"); disabled to satisfy the compiler
			BetterTest.assertTrue(Activity has :SPORT_CYCLING, "The new activity properties includes cycling");
			//BUG! the following assert should throw an exception on v4.1.0- devices
			//it should be valid only for v4.1.0+ devices, however it also works on the Fenix 5 and 6
			BetterTest.assertTrue(Activity has :SPORT_RACKET, "The new activity properties includes racket");
		}
		//3.2.0- devices don't have the new properties in Activity, if checked with "has", as expected
		else {
			//BetterTest.assertFalse(Activity has :SPORT_LEAP_FROG, "The new activity properties does not include leap frog"); disabled to satisfy the compiler
			BetterTest.assertFalse(Activity has :SPORT_CYCLING, "The new activity properties does not include cycling");
			BetterTest.assertFalse(Activity has :SPORT_RACKET, "The new activity properties does not include racket");
		}

		//however, all devices have the new properties in Activity, if checked directly (not using "has")!
		BetterTest.assertEqual(Activity.SPORT_CYCLING, 2, "All devices have the new activity properties that includes cycling (stored as 2)");
		BetterTest.assertEqual(Activity.SPORT_RACKET, 64, "All devices have the new activity properties that includes racket (stored as 64)");

		//by the way, all devices have the old properties in ActivityRecording
		BetterTest.assertTrue(ActivityRecording has :SPORT_CYCLING, "All devices have the old activity recording properties that includes cycling");
		BetterTest.assertEqual(ActivityRecording.SPORT_CYCLING, 2, "All devices have the old activity recording properties that includes cycling (stored as 2)");
		//BetterTest.assertFalse(ActivityRecording has :SPORT_RACKET, "The old activity recording properties does not include racket"); disabled to satisfy the compiler

		//this means that the "has" keyword cannot be used to decide if the new sports and sub sports are available
		//but the new enum can be used on all devices (and this removes the deprecation messages)
		var sport = Activity has :SPORT_RACKET ? Activity.SPORT_RACKET : Activity.SPORT_GENERIC;
		if(v410) {
			BetterTest.assertEqual(sport, 64, "For v4.1.0+ devices, selected sport is racket");
		}
		else if(v320) {
			//BUG! the following assert should throw an exception on v4.1.0- devices
			BetterTest.assertEqual(sport, 64, "This assert should not be valid, v4.1.0- devices should fallback to the generic sport");
		}
		else {
			BetterTest.assertEqual(sport, 0, "In old versions, fallback to the generic sport");
		}

		var sub_sport = Activity has :SUB_SPORT_BADMINTON ? Activity.SUB_SPORT_BADMINTON : Activity.SUB_SPORT_MATCH;
		if(v410) {
			BetterTest.assertEqual(sub_sport, 95, "For v4.1.0+ devices, selected sub sport is badminton");
		}
		else if(v320) {
			//BUG! the following assert should throw an exception on v4.1.0- devices
			BetterTest.assertEqual(sub_sport, 95, "This assert should not be valid, v4.1.0- devices should fallback to match");
		}
		else {
			BetterTest.assertEqual(sub_sport, 22, "In old versions, fallback to match");
		}

		//on a device, it's better to check the device version and to use the appropriate properties, even if this triggers deprecation messages
		//var sport = v410 ? Activity.SPORT_RACKET : ActivityRecording.SPORT_GENERIC;
		//var sub_sport = v410 ? Activity.SUB_SPORT_BADMINTON : ActivityRecording.SUB_SPORT_MATCH;

		return true;
	}
}
