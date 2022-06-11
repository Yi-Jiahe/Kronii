import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;

class KroniiView extends WatchUi.WatchFace {
  const RELATIVE_WEEKDAY_POSITION_X = 0.13;
  const RELATIVE_WEEKDAY_POSITION_Y = 0.42;
  const RELATIVE_DATE_POSITION_X = 0.13;
  const RELATIVE_DATE_POSITION_Y = 0.5;

  const RELATIVE_BATTERY_POSITION_X = 0.37;
  const RELATIVE_BATTERY_POSITION_Y = 0.17;
  const RELATIVE_BATTERY_WIDTH = 0.07;
  const RELATIVE_BATTERY_HEIGHT = 0.04;
  const RELATIVE_BATTERY_STROKE = 0.007;

  const RELATIVE_HOUR_HAND_LENGTHS = [0.18, 0.23, 0.3, 0.27, 0.15];
  const RELATIVE_MIN_HAND_LENGTHS = [0.38, 0.42, 0.35];
  const RELATIVE_SEC_HAND_LENGTH = 0.45;

  const RELATIVE_HOUR_HAND_STROKE = 0.010;
  const RELATIVE_MIN_HAND_STROKE = 0.010;
  const RELATIVE_SEC_HAND_STROKE = 0.010;

  // Points for the tick at theta = 0 defined by the x-axis to the right and y-axis downwards, i.e. 3'o clock
  const TICK_POINTS = [[0, 0], [-0.866, 0.134], [-1, 1], [-1.5, 0.5], [-3, 0], [-1.5, -0.5], [-1, -1], [-0.866, -0.134]];
  const N_TICK_POINTS = TICK_POINTS.size();
  const MAJOR_TICK_SCALE = 0.025;
  const MINOR_TICK_SCALE = 0.020;

  var width;
  var height;

  var lowPower = false;
  var needsProtection = false;

  var months;
	var weekdays;

  function initialize() {
    WatchFace.initialize();

    months = [
			WatchUi.loadResource(Rez.Strings.Mon0),
			WatchUi.loadResource(Rez.Strings.Mon1),
			WatchUi.loadResource(Rez.Strings.Mon2),
			WatchUi.loadResource(Rez.Strings.Mon3),
			WatchUi.loadResource(Rez.Strings.Mon4),
			WatchUi.loadResource(Rez.Strings.Mon5),
			WatchUi.loadResource(Rez.Strings.Mon6),
			WatchUi.loadResource(Rez.Strings.Mon7),
			WatchUi.loadResource(Rez.Strings.Mon8),
			WatchUi.loadResource(Rez.Strings.Mon9),
			WatchUi.loadResource(Rez.Strings.Mon10),
			WatchUi.loadResource(Rez.Strings.Mon11)
		];
		
		weekdays = [
			WatchUi.loadResource(Rez.Strings.Day0),
			WatchUi.loadResource(Rez.Strings.Day1),
			WatchUi.loadResource(Rez.Strings.Day2),
			WatchUi.loadResource(Rez.Strings.Day3),
			WatchUi.loadResource(Rez.Strings.Day4),
			WatchUi.loadResource(Rez.Strings.Day5),
			WatchUi.loadResource(Rez.Strings.Day6)
		];
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    width = dc.getWidth();
    height = dc.getHeight();

    if (
      System.getDeviceSettings() has :requiresBurnInProtection &&
      System.getDeviceSettings().requiresBurnInProtection
    ) {
      needsProtection = true;
    }

    setLayout(Rez.Layouts.WatchFace(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    var clockTime = System.getClockTime();
    var hours = clockTime.hour;
    var minutes = clockTime.min;
    var seconds = clockTime.sec;

    var systemStats = System.getSystemStats();

    if (lowPower) {
      drawBackground(dc);
      drawTicks(dc);
      drawDate(dc);
      drawBattery(dc, systemStats);

      drawHand(dc, 60, minutes, 60,seconds,:minute);
      drawHand(dc, 12.0, hours, 60, minutes, :hour);
    } else {
      drawBackground(dc);
      drawTicks(dc);
      drawDate(dc);
      drawBattery(dc, systemStats);

      drawHand(dc, 60, seconds, 0,0, :second);
      drawHand(dc, 60, minutes, 60, seconds, :minute);
      drawHand(dc, 12.0, hours, 60, minutes, :hour);
    }

    //   var view = View.findDrawableById("TimeLabel") as Text;

    //   // Call the parent onUpdate function to redraw the layout
    //   View.onUpdate(dc);
  }

  function drawBackground(dc) {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
  }

  function drawTicks(dc) {
    dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
    var points = new [N_TICK_POINTS];
    var scale;

    for (var angle = 0; angle < 360; angle += 30) {
      if (angle % 90 == 0) {
        scale = MAJOR_TICK_SCALE * width;
      } else {
        scale = MINOR_TICK_SCALE * width;
      }

      var computedAngle = Math.toRadians(angle);

      var offset = [width/2 * (1 + 0.95 * Math.cos(computedAngle)), width/2 * (1 + 0.95 * Math.sin(computedAngle))];
      var sineAngle = Math.sin(computedAngle);
      var cosineAngle = Math.cos(computedAngle);

      for (var i = 0; i < N_TICK_POINTS; i += 1){
        // For a rotation in the positive direction about the origin
        // x' = x*cos(theta) - y*sin(theta)
        // y' = x*sin(theta) + y*cos(theta)
        points[i] = [offset[0] + (TICK_POINTS[i][0] * cosineAngle - TICK_POINTS[i][1] * sineAngle) * scale, offset[1] + (TICK_POINTS[i][0] * sineAngle + TICK_POINTS[i][1] * cosineAngle) * scale];
      }
      dc.fillPolygon(points);
    }
  }

  function drawHand(dc, num, time, offsetNum, offsetTime, hand) {
    var angle = Math.toRadians((360 / num) * time) - Math.PI / 2;
    var center = width / 2;

    if (offsetNum != 0) {
      var section = 360.0 / num / offsetNum;
      angle += Math.toRadians(section * offsetTime);
    }

    if (hand == :hour) {
      var lineWidth = RELATIVE_HOUR_HAND_STROKE * width;

      dc.setPenWidth(lineWidth);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      for (var i = 0; i < 5; i++) {
        var length = RELATIVE_HOUR_HAND_LENGTHS[i] * width;
        var offset = (i - 2) * lineWidth * 1.5;
        var offsetX = Math.round(Math.cos(angle + Math.PI / 2)) * offset;
        var offsetY = Math.round(Math.sin(angle + Math.PI / 2)) * offset;
        var x1 = center + offsetX;
        var y1 = center + offsetY;
        var x2 = center + Math.round(Math.cos(angle) * length) + offsetX;
        var y2 = center + Math.round(Math.sin(angle) * length) + offsetY;
        dc.drawLine(x1, y1, x2, y2);
      }
      dc.fillCircle(center, center, lineWidth * 4);
    } else if (hand == :minute) {
      var lineWidth = RELATIVE_MIN_HAND_STROKE * width;

      dc.setPenWidth(lineWidth);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      for (var i = 0; i < 3; i++) {
        var length = RELATIVE_MIN_HAND_LENGTHS[i] * width;
        var offset = (i - 2) * lineWidth * 1.5;
        var offsetX = Math.round(Math.cos(angle + Math.PI / 2)) * offset;
        var offsetY = Math.round(Math.sin(angle + Math.PI / 2)) * offset;
        var x1 = center + offsetX;
        var y1 = center + offsetY;
        var x2 = center + Math.round(Math.cos(angle) * length) + offsetX;
        var y2 = center + Math.round(Math.sin(angle) * length) + offsetY;
        dc.drawLine(x1, y1, x2, y2);
      }
    } else if (hand == :second) {
      dc.setPenWidth(RELATIVE_HOUR_HAND_STROKE * width);
      dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);

      var length = RELATIVE_SEC_HAND_LENGTH * width;
      var x2 = center + Math.round(Math.cos(angle) * length);
      var y2 = center + Math.round(Math.sin(angle) * length);
      dc.drawLine(center, center, x2, y2);
    }
  }

  function drawDate(dc) {
      var dateinfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		  var month = months[dateinfo.month-1];
      var weekday = weekdays[dateinfo.day_of_week-1];
      var date = dateinfo.day;

      dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
      dc.drawText(RELATIVE_WEEKDAY_POSITION_X * width, RELATIVE_WEEKDAY_POSITION_Y * width, Graphics.FONT_XTINY, weekday, Graphics.TEXT_JUSTIFY_LEFT);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      dc.drawText(RELATIVE_DATE_POSITION_X * width, RELATIVE_DATE_POSITION_Y * width, Graphics.FONT_XTINY, Lang.format("$1$ $2$", [month, date]), Graphics.TEXT_JUSTIFY_LEFT);
  }

  function drawBattery(dc, systemStats) {
		var battery = systemStats.battery;

    var batteryPositionX = RELATIVE_BATTERY_POSITION_X * width;
    var batteryPositionY = RELATIVE_BATTERY_POSITION_Y * width;
    var batteryWidth = RELATIVE_BATTERY_WIDTH * width;
    var batteryHeight = RELATIVE_BATTERY_HEIGHT * width;
    var lineWidth = RELATIVE_BATTERY_STROKE * width;

    // Battery Border
    dc.setPenWidth(lineWidth);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawRectangle(batteryPositionX, batteryPositionY, batteryWidth, batteryHeight);
    var x = batteryPositionX + batteryWidth + 0.2 * lineWidth;
    dc.drawLine(x, batteryPositionY + 0.3 * batteryHeight, x, batteryPositionY + 0.7 * batteryHeight);

    // Battery Indicator
		if (battery < 10) {
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);			
		} else if (battery < 20) {
			dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);			
		} else {
      dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    }
    dc.fillRectangle(batteryPositionX + lineWidth, batteryPositionY + 1.5 * lineWidth, battery * 0.01 * (batteryWidth - 2 * lineWidth), batteryHeight - 2.5 * lineWidth);

  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    lowPower = false;
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {
    lowPower = true;
  }
}
