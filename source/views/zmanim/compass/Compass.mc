//* This view was mostly created by Gemini 2.5 Pro on Sep 12, 2025.
//* Some customizations were made by hand to stay consistent with the rest of the app.
//* See commit message for link to conversation.

import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.Sensor;
import Toybox.Timer;

class CompassView extends WatchUi.View {
    public var mLocationInfo as LocationInfo;

    //* The fixed coordinates for the compass to point towards.
    //* Kosel HaMa'aravi: 31.778° N, 35.2353° E
    private const TARGET_LOCATION = {
        :latitude => 31.778d,
        :longitude => 35.2353d
    };

    // --- UI & Colors ---
    private const FONT_JUSTIFICATION = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    private const NEEDLE_COLOR = Graphics.COLOR_RED;
    private const IN_ZONE_COLOR = Graphics.COLOR_DK_GREEN;
    private const TEXT_COLOR = Graphics.COLOR_BLUE;
    private const BACKGROUND_COLOR = Graphics.COLOR_BLACK;
    private const RING_TICK_COLOR = Graphics.COLOR_LT_GRAY;

    // Tolerance for the "green zone" in degrees on either side
    private const GREEN_ZONE_DEGREES = 15;

    private var _screenCenterPoint;
    private var _compassRadius as Number?;
    private var _updateTimer as Timer.Timer?;

    public function initialize(locationInfo as LocationInfo) {
        View.initialize();
        mLocationInfo = locationInfo;
    }

    public function onLayout(dc as Dc) as Void {
        _screenCenterPoint = [dc.getWidth() / 2, dc.getHeight() / 2];
        _compassRadius = _screenCenterPoint[0] - 25; // A bit more margin for the new design
    }

    //* Called when this View is brought to the foreground.
    public function onShow() as Void {
        if (_updateTimer == null) {
            _updateTimer = new Timer.Timer();
        }
        _updateTimer.start(method(:onTimer), 1000, true);
    }

    //* The callback for the timer, requesting a screen refresh.
    public function onTimer() as Void {
        WatchUi.requestUpdate();
    }

    public function onUpdate(dc as Dc) as Void {
        // --- 1. Get location and sensor data ---
        var locationInfo = mLocationInfo;
        var currentCoordinates = locationInfo != null ? locationInfo["coordinates"] : null;

        var sensorInfo = Sensor.getInfo();
        var currentHeading = sensorInfo.heading;

        // --- 2. Clear Screen & Draw Static Title ---
        dc.setColor(TEXT_COLOR, BACKGROUND_COLOR);
        dc.clear();
        drawTitle(dc);

        // --- 3. Handle missing GPS/Compass ---
        if (currentCoordinates == null || currentHeading == null) {
            drawCompassRing(dc, false); // Draw gray ring
            return;
        }

        // --- 4. Perform Calculations ---
        var currentLatRad = Math.toRadians(currentCoordinates[0]);
        var currentLonRad = Math.toRadians(currentCoordinates[1]);

        var targetLatRad = Math.toRadians(TARGET_LOCATION[:latitude]);
        var targetLonRad = Math.toRadians(TARGET_LOCATION[:longitude]);

        var bearingRad = calculateBearing(currentLatRad, currentLonRad, targetLatRad, targetLonRad);
        var distanceM = calculateDistance(currentLatRad, currentLonRad, targetLatRad, targetLonRad);

        // --- 5. Determine if User is Pointing Correctly ---
        var isInZone = isHeadingInZone(currentHeading, bearingRad);

        // --- 6. Draw UI Components ---
        drawCompassRing(dc, isInZone);
        drawTargetNeedle(dc, currentHeading, bearingRad, isInZone);
        drawInfoText(dc, bearingRad, distanceM);
    }

    //* Called when this View is removed from the screen.
    public function onHide() as Void {
        if (_updateTimer != null) {
            _updateTimer.stop();
        }
    }

    //* Draws title at the top of the screen.
    private function drawTitle(dc as Dc) as Void {
        if (_screenCenterPoint == null) {
            return;
        }
        dc.setColor(TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _screenCenterPoint[0],
            25, // Positioned near the top
            Graphics.FONT_SMALL,
            WatchUi.loadResource($.Rez.Strings.CompassTargetText),
            FONT_JUSTIFICATION
        );
    }

    private function drawCompassRing(dc as Dc, isInZone as Boolean) as Void {
        if (_screenCenterPoint == null || _compassRadius == null) {
            return;
        }

        dc.setPenWidth(1);
        var majorTickLength = 10;
        var minorTickLength = 5;

        // Loop through 360 degrees to draw ticks
        for (var i = 0; i < 360; i += 15) {
            var angleRad = Math.toRadians(i);
            var isMajorTick = i % 90 == 0;
            var tickLength = isMajorTick ? majorTickLength : minorTickLength;

            // Determine color: The top tick turns green when in the zone
            var tickColor = RING_TICK_COLOR;
            if (i == 0 && isInZone) {
                tickColor = IN_ZONE_COLOR;
                dc.setPenWidth(3); // Make the target tick bolder when green
            } else {
                dc.setPenWidth(isMajorTick ? 2 : 1);
            }

            var outerX = _screenCenterPoint[0] + _compassRadius * Math.sin(angleRad);
            var outerY = _screenCenterPoint[1] - _compassRadius * Math.cos(angleRad);
            var innerX = _screenCenterPoint[0] + (_compassRadius - tickLength) * Math.sin(angleRad);
            var innerY = _screenCenterPoint[1] - (_compassRadius - tickLength) * Math.cos(angleRad);

            dc.setColor(tickColor, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(innerX, innerY, outerX, outerY);
        }
    }

    //* Draws a triangular needle. Color is determined by isInZone status.
    private function drawTargetNeedle(dc as Dc, heading as Float, bearing as Double, isInZone as Boolean) as Void {
        if (_screenCenterPoint == null || _compassRadius == null) {
            return;
        }

        var arrowColor = isInZone ? IN_ZONE_COLOR : NEEDLE_COLOR;

        var needleAngle = bearing - heading;
        var needleLength = _compassRadius - 15; // Make it fit inside the new ring
        var needleWidth = 15;

        var needlePoints = [
            [0, -needleLength],
            [-needleWidth / 2, 0],
            [needleWidth / 2, 0]
        ];

        var cos = Math.cos(needleAngle);
        var sin = Math.sin(needleAngle);

        for (var i = 0; i < needlePoints.size(); i++) {
            var x = needlePoints[i][0] * cos - needlePoints[i][1] * sin;
            var y = needlePoints[i][0] * sin + needlePoints[i][1] * cos;
            needlePoints[i][0] = _screenCenterPoint[0] + x;
            needlePoints[i][1] = _screenCenterPoint[1] + y;
        }

        dc.setColor(arrowColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(needlePoints);
    }

    //* Draws the bearing and distance text at the bottom.
    private function drawInfoText(dc as Dc, bearingRad as Double, distanceM as Double) as Void {
        if (_screenCenterPoint == null) {
            return;
        }

        var bearingDeg = Math.toDegrees(bearingRad);
        if (bearingDeg < 0) {
            bearingDeg += 360;
        }

        var distanceMi = distanceM * 0.000621371;
        var bearingStr = Lang.format("$1$°", [bearingDeg.format("%03d")]);
        var distanceStr = Lang.format("$1$ mi", [distanceMi.format("%.1f")]);

        dc.setColor(TEXT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_screenCenterPoint[0], _screenCenterPoint[1] * 2 - 45, Graphics.FONT_SMALL, bearingStr, FONT_JUSTIFICATION);
        dc.drawText(_screenCenterPoint[0], _screenCenterPoint[1] * 2 - 25, Graphics.FONT_SMALL, distanceStr, FONT_JUSTIFICATION);
    }

    //* Checks if the user's heading is within the green zone tolerance of the bearing.
    private function isHeadingInZone(headingRad as Float, bearingRad as Double) as Boolean {
        var bearingDeg = Math.toDegrees(bearingRad);
        var headingDeg = Math.toDegrees(headingRad);

        var diff = (bearingDeg - headingDeg).abs();
        if (diff > 180) {
            diff = 360.0 - diff;
        }
        return diff <= GREEN_ZONE_DEGREES;
    }

    private function calculateBearing(lat1 as Double, lon1 as Double, lat2 as Double, lon2 as Double) as Double {
        var y = Math.sin(lon2 - lon1) * Math.cos(lat2);
        var x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1);
        return Math.atan2(y, x);
    }

    private function calculateDistance(lat1 as Double, lon1 as Double, lat2 as Double, lon2 as Double) as Double {
        var R = 6371000;
        var dLat = lat2 - lat1;
        var dLon = lon2 - lon1;
        var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
