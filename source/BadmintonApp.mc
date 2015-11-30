import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Attention;
import Toybox.Activity;
import Toybox.Time;
using Toybox.Application;
using Toybox.Timer;

class BadmintonApp extends Application.AppBase {
	//create bus for the whole application
	private const BUS = new Bus();
	private var match as Match?;

	//monitor activity to display alerts
	const ALERT_MAX_FREQUENCY_SECONDS = 30;
	private var activityMonitor as Timer.Timer = new Timer.Timer();
	private var lastHearRateAlert  as Moment? = null;

	private var accelerationMonitor as Timer.Timer = new Timer.Timer();

	function initialize() {
		AppBase.initialize();
	}

	function onStart(state as Dictionary?) as Void {
		//register application itself in the bus
		BUS.register(self);
	}

	function getInitialView() {
		return [new InitialView(), new InitialViewDelegate()];
	}

	function getBus() as Bus {
		return BUS;
	}

	function getMatch() as Match? {
		return match;
	}

	function setMatch(m as Match) as Void {
		match = m;
	}

	function monitorActivity() as Void {
		var activity = Activity.getActivityInfo() as Info;
		var rate = activity.currentHeartRate;

		if(rate != null) {
			var profile = UserProfile.getCurrentSport();
			var zones = UserProfile.getHeartRateZones(profile);
			if(zones != null && zones.size() > 4) {
				if(rate > zones[5]) {
					//warn only every 30 seconds
					if(lastHearRateAlert == null || (Time.now().subtract(lastHearRateAlert as Moment) as Duration).value() >= ALERT_MAX_FREQUENCY_SECONDS) {
						lastHearRateAlert = Time.now();
						if(Attention has :playTone) {
							if(Properties.getValue("enable_sound")) {
								Attention.playTone(Attention.TONE_ALERT_HI);
							}
						}
						if(Attention has :vibrate) {
							Attention.vibrate([new Attention.VibeProfile(50, 100)] as Array<VibeProfile>);
						}
					}
				}
			}
		}
	}

	function monitorAcceleration() as Void {
		var info = Sensor.getInfo();

		if(info has :accel) {
			var acceleration = info.accel;
			if(acceleration != null) {
				var xAccel = acceleration[0] as Number;
				var yAccel = acceleration[1] as Number;
				//var zAccel = acceleration[2] as Number;

				//spot high acceleration value
				var hit = 2600;
				if(BetterMath.absolute(xAccel) > hit || BetterMath.absolute(yAccel) > hit) {
					System.println("hit detected xaccel=" + xAccel + " yaccel=" + yAccel);
					Attention.vibrate([new Attention.VibeProfile(80, 100)]);
				}

				hit = 3300;
				if(BetterMath.absolute(xAccel) > hit || BetterMath.absolute(yAccel) > hit) {
					System.println("hit detected xaccel=" + xAccel + " yaccel=" + yAccel);
					Attention.playTone(Attention.TONE_START);
				}
			}
		}
	}

	function onMatchBegin() as Void {
		accelerationMonitor.start(method(:monitorAcceleration), 50, true);
		if(Properties.getValue("enable_alert_heart_rate_zone_5")) {
			activityMonitor.start(method(:monitorActivity), 1000, true);
		}
		if(Attention has :playTone) {
			if(Properties.getValue("enable_sound")) {
				Attention.playTone(Attention.TONE_START);
			}
		}
		if(Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(80, 200)] as Array<VibeProfile>);
		}
	}

	function onMatchEnd(payload as Dictionary) as Void {
		accelerationMonitor.stop();
		if(Properties.getValue("enable_alert_heart_rate_zone_5")) {
			activityMonitor.stop();
		}
		var winner = payload["winner"];
		if(winner != null && Attention has :playTone && Properties.getValue("enable_sound")) {
			Attention.playTone(winner == USER ? Attention.TONE_SUCCESS : Attention.TONE_FAILURE);
		}
		if(Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(80, 200)] as Array<VibeProfile>);
		}
	}

	function onSettingsChanged() {
		//dispatch updated settings event
		//do not name the event "onSettingsChanged" to avoid recursion
		//"onSettingsChanged" is the native event and "onUpdateSettings" is the custom event for this app (that views can catch)
		BUS.dispatch(new BusEvent(:onUpdateSettings, null));
	}
}
