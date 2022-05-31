import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module Main {
  var width;
  var height;

  const RELATIVE_HOUR_HAND_LENGTH = 0.2;
  const RELATIVE_MIN_HAND_LENGTH = 0.4;
  const RELATIVE_SEC_HAND_LENGTH = 0.4;

  const RELATIVE_HOUR_HAND_STROKE = 0.013;
  const RELATIVE_MIN_HAND_STROKE = 0.013;
  const RELATIVE_SEC_HAND_STROKE = 0.01;

  const COLORS = [
    Graphics.COLOR_BLACK,
    Graphics.COLOR_WHITE,
    Graphics.COLOR_LT_GRAY,
    Graphics.COLOR_DK_GRAY,
    Graphics.COLOR_BLUE,
    0x02084f,
    Graphics.COLOR_RED,
    0x730000,
    Graphics.COLOR_GREEN,
    0x004f15,
    0xaa00ff,
    Graphics.COLOR_PINK,
    Graphics.COLOR_ORANGE,
    Graphics.COLOR_YELLOW,
  ];

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
      if (lowPower) {
        if (needsProtection) {
          drawBackground(dc);
        }
      } else {
        drawBackground(dc);
        drawHands(dc);
      }

      //   var view = View.findDrawableById("TimeLabel") as Text;

      //   // Call the parent onUpdate function to redraw the layout
      //   View.onUpdate(dc);
    }

    function drawBackground(dc) {
      dc.setColor(0x004f94, 0x004f94);
      dc.clear();
    }

    function drawHands(dc) {
      var clockTime = System.getClockTime();
      var hours = clockTime.hour;
      var minutes = clockTime.min;
      var seconds = clockTime.sec;

      dc.setColor(0xffffff, Graphics.COLOR_TRANSPARENT);

      drawHand(
        dc,
        12.0,
        hours,
        60,
        minutes,
        RELATIVE_HOUR_HAND_LENGTH * width,
        RELATIVE_HOUR_HAND_STROKE * width
      );
      drawHand(
        dc,
        60,
        minutes,
        60,
        seconds,
        RELATIVE_MIN_HAND_LENGTH * width,
        RELATIVE_MIN_HAND_STROKE * width
      );
      drawHand(
        dc,
        60,
        seconds,
        0,
        0,
        RELATIVE_SEC_HAND_LENGTH * width,
        RELATIVE_SEC_HAND_STROKE * width
      );
    }

    function drawHand(dc, num, time, offsetNum, offsetTime, length, stroke) {
      var angle = Math.toRadians((360 / num) * time) - Math.PI / 2;
      var center = width / 2;

      if (offsetNum != 0) {
        var section = 360.0 / num / offsetNum;
        angle += Math.toRadians(section * offsetTime);
      }

      var x2 = center + Math.round(Math.cos(angle) * length);
      var y2 = center + Math.round(Math.sin(angle) * length);

      dc.setPenWidth(stroke);
      dc.drawLine(center, center, x2, y2);
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
