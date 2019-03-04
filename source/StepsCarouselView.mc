using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

using Toybox.System;
using Toybox.Time;
//using Toybox.Time.Gregorian;

class StepsCarouselView extends Ui.DataField {
//    hidden var labelResource = Rez.Strings.TotalSteps; // holds pointer to the active labelResource to display
    hidden var value = "00:00:00"; //0.0;
 //   hidden var valueFormat = "%d";
    hidden var timerRunning = false;
    hidden var ticker = 0;
 //   hidden var stepsRecorded = 0;
 //   hidden var stepsNonActive = 0;
    hidden var textCenter = Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER;
    hidden var fields = 2;
 //   hidden var field = [0, 0, 0, 0];
    hidden var carouselSeconds = 5;
    hidden var is24Hour = true;
    hidden const ZERO_TIME = "00:00";
    hidden var elapsedTime = 0;
    
	private var mHoursFont140;
	private var mHoursFont100;

    //! Initialisations
    function initialize() {
  
        DataField.initialize();
        var app = getApplicationProperties();
        carouselSeconds = app.getProperty("carouselSeconds") == null? 5 : app.getProperty("carouselSeconds");    
 //       mHoursFont140 = Ui.loadResource(Rez.Fonts.HoursFont140);
 //       mHoursFont100 = Ui.loadResource(Rez.Fonts.HoursFont100);
        
    }

    function showField (fieldNr) {
        var activityMonitorInfo = getActivityMonitorInfo();
        
        
        if (fieldNr == 1) {
//            labelResource = Rez.Strings.TotalSteps;
            
/*			var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			var dateString = Lang.format(
    										"$1$:$2$:$3$",
    										[
        										today.hour,
        										today.min,
        										today.sec
    										]
										);*/
										
           //time
           var clockTime = System.getClockTime();
        	var time, ampm;
        	if (is24Hour) {
              time = Lang.format("$1$ $2$", [clockTime.hour.format("%.2d"), clockTime.min.format("%.2d")]);
              ampm = "";
            } else {
              time = Lang.format("$1$ $2$", [computeHour(clockTime.hour).format("%.2d"), clockTime.min.format("%.2d")]);
              ampm = (clockTime.hour < 12) ? "M" : "m";
              time = time; // + "  "; //+ ampm;
            }
																				
            value = time;
            
 //           value = activityMonitorInfo.steps;
        } else if (fieldNr == 2) {
//            labelResource = Rez.Strings.ActiveSteps;
 //           value = stepsRecorded;
        	//duration
        	var duration;
        	if (elapsedTime != null && elapsedTime > 0) {
            	var hours = null;
            	var minutes = elapsedTime / 1000 / 60;
            	var seconds = elapsedTime / 1000 % 60;
            
            	if (minutes >= 60) {
                	hours = minutes / 60;
                	minutes = minutes % 60;
            	}
            
            	if (hours == null) {
                	duration = minutes.format("%02d") + ":" + seconds.format("%02d");
            	} else {
                	duration = hours.format("%02d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
            	}
        	} else {
            	duration = ZERO_TIME;
        	} 
            value = duration;
        }
    }

    function onLayout(dc) {
        setDeviceSettingsDependentVariables();
        onUpdate(dc);
    }

    function setDeviceSettingsDependentVariables() {
 //       hasBackgroundColorOption = (self has :getBackgroundColor);
        
        is24Hour = System.getDeviceSettings().is24Hour;        
    }

    //! Calculations we need to do every second even when the data field is not visible
    function compute(info) {
/*        var activityMonitorInfo = getActivityMonitorInfo();
        if (timerRunning) {
            stepsRecorded = activityMonitorInfo.steps - stepsNonActive;
        }*/
 
         elapsedTime = info.elapsedTime != null ? info.elapsedTime : 0;        
        
        var timerSlot = (ticker % (fields*carouselSeconds));
//        valueFormat = "%d";
//        System.println(timerSlot);

        if (timerSlot <= carouselSeconds-1) {
            showField(1);
        } else if (timerSlot <= carouselSeconds*2-1) {
            showField(2);
        } else {
 //           value = 0;
          value = "00:00:00";
        }

        if (timerRunning) {
            ticker++;
        }
    }

    //! Display the value you computed here. This will be called once a second when the data field is visible.
    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var backgroundColor = getBackgroundColor();
        // set background color
        dc.setColor(backgroundColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle (0, 0, width, height);
        // set foreground color
        dc.setColor((backgroundColor == Gfx.COLOR_BLACK) ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        // do layout
        var textwidth  = dc.getTextWidthInPixels(value, Gfx.FONT_NUMBER_THAI_HOT);
        var textheight = dc.getFontHeight(Gfx.FONT_NUMBER_THAI_HOT);
//        if (isSingleFieldLayout()) {
/*		  System.print("text width : ");
		  System.print(textwidth);
		  System.print("  -  width : ");
		  System.println(width);
		  System.print("text height : ");
		  System.print(textheight);
		  System.print("  -  height : ");
		  System.println(height);*/
          if ((textwidth < width) and (textheight < height)) {
 //           dc.drawText(width / 2, height / 2 - 40, Gfx.FONT_TINY, Ui.loadResource(labelResource), textCenter);
 //           dc.drawText(width / 2, height / 2, Gfx.FONT_LARGE, value, textCenter);
            dc.drawText(width / 2, height / 2, Gfx.FONT_NUMBER_THAI_HOT, value, textCenter);
        } else {
 //           dc.drawText(width / 2, 5 + (height - 55) / 2, Gfx.FONT_TINY, Ui.loadResource(labelResource), textCenter);
            textwidth = dc.getTextWidthInPixels(value, Gfx.FONT_NUMBER_HOT);
            textheight = dc.getFontHeight(Gfx.FONT_NUMBER_HOT);
//            if (is24Hour) {          
          if ((textwidth < width)  and (textheight < height)) {
              dc.drawText(width / 2, height  / 2, Gfx.FONT_NUMBER_HOT, value, textCenter);
            }
            else {
              dc.drawText(width / 2, height / 2, Gfx.FONT_NUMBER_MEDIUM, value, textCenter);
            }
        }
    }

    //! Timer transitions from stopped to running state
    function onTimerStart() {
        if (!timerRunning) {
//            stepsNonActive = getActivityMonitorInfo().steps - stepsRecorded;
            timerRunning = true;
        }
    }

    //! Timer transitions from running to stopped state
    function onTimerStop() {
        timerRunning = false;
        ticker = 0;
    }

    //! Activity is ended
    function onTimerReset() {
//        stepsRecorded = 0;
    }

    function isSingleFieldLayout() {
        return (DataField.getObscurityFlags() == OBSCURE_TOP | OBSCURE_LEFT | OBSCURE_BOTTOM | OBSCURE_RIGHT);
        
/*        
         var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 22;
        	labelView.setJustification(Gfx.TEXT_JUSTIFY_RIGHT);
        	labelView.setColor(Gfx.COLOR_BLACK);

            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 0;
            valueView.setFont(Gfx.FONT_NUMBER_MEDIUM);
        }
        
        
*/        
    }

    function getActivityMonitorInfo() {
        return Toybox.ActivityMonitor.getInfo();
    }

    function getApplicationProperties() {
        return Application.getApp();
    }
    
     function computeHour(hour) {
        if (hour < 1) {
            return hour + 12;
        }
        if (hour >  12) {
            return hour - 12;
        }
        return hour;      
    }
       
/* 	function stringReplace(str, oldString, newString)
	{
		var result = str;

		while (true)
		{
			var index = result.find(oldString);

			if (index != null)
			{
				var index2 = index+oldString.length();
				result = result.substring(0, index) + newString + result.substring(index2, result.length());
			}
			else
			{
				return result;
			}
		}

		return null;
  	}   */
}
