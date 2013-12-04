package de.pixelscape.utils 
{

	/**
	 * @author tobias.friese
	 */
	public class DateUtils 
	{
		public static function time24to12(value:Number):Number
		{
			value = value % 12 >> 0;
			if(value == 0) value =  12;
			
			return value; 
		}
		
		public static function amPm(hour24:Number):String
		{
			return (hour24 < 12 ? "am" : "pm");
		}
		
		public static function leadingZero(value:Number):String
		{
			return (value < 10 ? "0" : "") + String(value);
		}
		
		public static function getDayAsString(day:Number, short:Boolean = false):String
		{
			switch(day)
			{
				case 0:		return short ? "Sun" : "Sunday";
				case 1:		return short ? "Mon" : "Monday";
				case 2:		return short ? "Tue" : "Tuesday";
				case 3:		return short ? "Wed" : "Wednesday";
				case 4:		return short ? "Thu" : "Thursday";
				case 5:		return short ? "Fri" : "Friday";
				case 6:		return short ? "Sat" : "Saturday";
			}
			
			return null;
		}
		
		public static function getMonthAsString(month:Number, short:Boolean = false):String
		{
			switch(month)
			{
				case 0:		return short ? "Jan" : "January";
				case 1:		return short ? "Feb" : "February";
				case 2:		return short ? "Mar" : "March";
				case 3:		return short ? "Apr" : "April";
				case 4:		return short ? "May" : "May";
				case 5:		return short ? "Jun" : "June";
				case 6:		return short ? "Jul" : "July";
				case 7:		return short ? "Aug" : "August";
				case 8:		return short ? "Sep" : "September";
				case 9:		return short ? "Oct" : "October";
				case 10:	return short ? "Nov" : "November";
				case 11:	return short ? "Dec" : "December";
			}
			
			return null;
		}
		
		public static function getDatePostfix(date:Number):String
		{
			if((date % 10) ==  1) return "st";
			if((date % 10) ==  2) return "nd";
			if((date % 10) ==  3) return "rd";
			
			return "th";
		}
		
		public static function stringToDate(str:String):Date
		{
			str = str.toLowerCase();
			str = StringUtils.replace(str, "\t", " ");
			while(str.indexOf("  ") != -1) str = str.split("  ").join(" ");
			
			// vars
			var regExp:RegExp;
			var tmp:String;
			var split:Array;
			
			var date:Date = new Date();
			date.hours = 0;
			date.minutes = 0;
			date.seconds = 0;
			date.milliseconds = 0;
			
			var dateSet:Boolean;
			var timeSet:Boolean;
			
			// now
			if(str.indexOf("now") != -1) return new Date();
			
			// [d]d.[m]m.[[yy]yy]
			regExp = /[0-9]{1,2}\.[0-9]{1,2}\.([0-9]{4}|[0-9]{2})*/;
			if(regExp.test(str))
			{
				tmp = str.match(regExp)[0];
				split = tmp.split(".");
				
				date.date = int(split[0]);
				date.month = int(split[1]) - 1;
				if(split[2] != "") date.fullYear = String(split[2]).length == 2 ? int((int(split[2]) > 50 ? "19" : "20") + split[2]) : int(split[2]);
				
				dateSet = true;
			}
			
			// month nth [[yy]yy]
			if(!dateSet)
			{
				regExp = /[a-z]+ [0-9]{1,2}(st|nd|rd|th)*( ([0-9]{4}|[0-9]{2}))*/;
				if(regExp.test(str))
				{
					tmp = str.match(regExp)[0];
					split = tmp.split(" ");
					
					var month:int = -1;
					switch(split[0])
					{
						case "jan":
						case "january":		month = 0; break;
						case "feb":
						case "february":	month = 1; break;
						case "mar":
						case "march":		month = 2; break;
						case "apr":
						case "april":		month = 3; break;
						case "may":			month = 4; break;
						case "jun":
						case "june":		month = 5; break;
						case "jul":
						case "july":		month = 6; break;
						case "aug":
						case "august":		month = 7; break;
						case "sept":
						case "september":	month = 8; break;
						case "oct":
						case "october":		month = 9; break;
						case "nov":
						case "november":	month = 10; break;
						case "dec":
						case "december":	month = 11; break;
					}
					
					if(month != -1)
					{
						date.month = month;
						date.date = int(StringUtils.remove(String(split[1]), "st", "nd", "rd", "th"));
						if(split.length == 3) date.fullYear = String(split[2]).length == 2 ? int((int(split[2]) > 50 ? "19" : "20") + split[2]) : int(split[2]);
						
						dateSet = true;
					}
				}
			}
			
			// tomorrow, yesterday, monday, tuesday, ...
			if(!dateSet)
			{
				regExp = /day after tomorrow|tomorrow|yesterday|monday|tuesday|wednesday|thursday|friday|saturday|sunday/;
				if(regExp.test(str))
				{
					tmp = str.match(regExp)[0];
					
					var dayID:int = -1;
					switch(tmp)
					{
						case "day after tomorrow":		date.date += 2;			break;
						case "tomorrow":				date.date += 1;			break;
						case "yesterday":				date.date -= 1;			break;
						case "sunday":					dayID = 0;				break;
						case "monday":					dayID = 1;				break;
						case "tuesday":					dayID = 2;				break;
						case "wednesday":				dayID = 3;				break;
						case "thursday":				dayID = 4;				break;
						case "friday":					dayID = 5;				break;
						case "saturday":				dayID = 6;				break;
					}
					
					if(dayID != -1) date.date += (dayID - date.day + 7) % 7;
					
					dateSet = true;
				}
			}
			
			// [h]h:mm[ pm]
			regExp = /[0-9]{1,2}:[0-9]{2}( *(am|pm))*/;
			if(regExp.test(str))
			{
				tmp = str.match(regExp)[0];
				
				date.hours = int(StringUtils.getBefore(tmp, ":"));
				date.minutes = int(StringUtils.getAfter(tmp, ":").substr(0, 2));
				
				if(tmp.indexOf("pm") != -1) if(date.hours < 12) date.hours += 12;
				
				timeSet = true;
			}
			
			// [h]h[ pm]|[ h]
			if(!timeSet)
			{
				regExp = new RegExp("[0-9]{1,2}( *(am|pm)| *h| *o'clock)");
				if(regExp.test(str))
				{
					tmp = str.match(regExp)[0];
					
					date.hours = int(tmp.match("[0-9]+")[0]);
					if(tmp.indexOf("pm") != -1) if(date.hours < 12) date.hours += 12;
					
					timeSet = true;
				}
			}
			
			// morning, mid day, ...
			if(!timeSet)
			{
				regExp = /(at )*(early morning|morning|midday|afternoon|noon|evening|night|midnight)/;
				if(regExp.test(str))
				{
					tmp = str.match(regExp)[0];
					tmp = StringUtils.remove(tmp, "at", " ");
					
					switch(tmp)
					{
						case "earlymorning": date.hours = 6; break;
						case "morning": date.hours = 8; break;
						case "midday":
						case "noon": date.hours = 12; break;
						case "afternoon": date.hours = 16; break;
						case "evening": date.hours = 18; break;
						case "night": date.hours = 22; break;
						case "midnight": date.hours = 24; break;
					}
					
					timeSet = true;
				}
			}
			
			return date;
		}
		
		public static function microtime():int
		{
			var date:Date = new Date();
			return date.getTime();
		}
	}
}
