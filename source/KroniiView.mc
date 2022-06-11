import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module Main {
  var width;
  var height;

  const RELATIVE_HOUR_HAND_LENGTHS = [0.18, 0.23, 0.3, 0.27, 0.15];
  const RELATIVE_MIN_HAND_LENGTHS = [0.38, 0.42, 0.35];
  const RELATIVE_SEC_HAND_LENGTH = 0.45;

  const RELATIVE_HOUR_HAND_STROKE = 0.008;
  const RELATIVE_MIN_HAND_STROKE = 0.008;
  const RELATIVE_SEC_HAND_STROKE = 0.009;

  // Points for the tick at theta = 0 defined by the x-axis to the right and y-axis downwards, i.e. 3'o clock
  const TICK_POINTS = [[0, 0], [-0.866, 0.134], [-1, 1], [-1.5, 0.5], [-3, 0], [-1.5, -0.5], [-1, -1], [-0.866, -0.134]];
  const N_TICK_POINTS = TICK_POINTS.size();
  const MAJOR_TICK_SCALE = 0.030;
  const MINOR_TICK_SCALE = 0.020;

  class KroniiView extends WatchUi.WatchFace {
    var lowPower = false;
    var needsProtection = false;

    function initialize() {
      WatchFace.initialize();
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
      if (lowPower && needsProtection) {
          drawBackground(dc);
      } else {
        drawBackground(dc);
        drawTicks(dc);
        drawHands(dc);
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

        var offset = [width/2 * (1 + Math.cos(computedAngle)), width/2 * (1 + Math.sin(computedAngle))];
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

    function drawHands(dc) {
      var clockTime = System.getClockTime();
      var hours = clockTime.hour;
      var minutes = clockTime.min;
      var seconds = clockTime.sec;

      drawHand(
        dc,
        12.0,
        hours,
        60,
        minutes,
        :hour
      );
      drawHand(
        dc,
        60,
        minutes,
        60,
        seconds,
        :minute
      );
      drawHand(
        dc,
        60,
        seconds,
        0,
        0,
        :second
      );
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
          var offset = (i - 2) * lineWidth * 1.2;
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
          var offset = (i - 2) * lineWidth * 1.2;
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
}
