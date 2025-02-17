import Toybox.Lang;
import Toybox.Timer;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Activity;
using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.UserProfile;

class WarmupView extends WatchUi.View {

	private var clock24Hour as Boolean;
	private var timeAMLabel as String;
	private var timePMLabel as String;

	private var refreshTimer as Timer.Timer;

	private var heart as Heart?;

	function initialize() {
		View.initialize();

		clock24Hour = System.getDeviceSettings().is24Hour;
		timeAMLabel = WatchUi.loadResource(Rez.Strings.time_am) as String;
		timePMLabel = WatchUi.loadResource(Rez.Strings.time_pm) as String;

		refreshTimer = new Timer.Timer();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.warmup(dc));
	}

	function onShow() {
		(findDrawableById("warmup_title") as Text).setText(WatchUi.loadResource(Rez.Strings.warmup_title) as String);

		//add the heart manually
		var device = System.getDeviceSettings();
		var size = Math.round(Graphics.getFontHeight(Graphics.FONT_TINY) * 0.4);
		heart = new Heart({
			:locX => device.screenWidth / 2f,
			:locY => device.screenHeight * 40 / 100,
			:size => size,
		});

		refreshTimer.start(method(:refresh), 1000, true);
	}

	function onHide() as Void {
		refreshTimer.stop();
	}

	function refresh() as Void {
		WatchUi.requestUpdate();
	}

	function onUpdateSettings() as Void {
		WatchUi.requestUpdate();
	}

	function onUpdate(dc as Dc) {
		View.onUpdate(dc);

		(heart as Heart).draw(dc);

		var match = (Application.getApp() as BadmintonApp).getMatch() as Match;

		var match_duration = Helpers.formatDuration(match.getDuration());
		(findDrawableById("warmup_duration") as Text).setText(match_duration);

		var time = Helpers.formatCurrentTime(clock24Hour, timeAMLabel, timePMLabel);
		(findDrawableById("warmup_time") as Text).setText(time);
	}
}

class WarmupViewDelegate extends WatchUi.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onSelect() {
		var match = (Application.getApp() as BadmintonApp).getMatch() as Match;
		match.endWarmup();
		//go to match view
		var view = new MatchView(false);
		WatchUi.switchToView(view, new MatchViewDelegate(view), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onBack() {
		var discard_match_confirmation = new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.discard_match) as String);
		WatchUi.pushView(discard_match_confirmation, new DiscardMatchConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
