package de.pixelscape.utils 
{

	/**
	 * This class provides utility methods for handling Strings.
	 * 
	 * @author Tobias Friese
	 * 
	 * @version 1.0
	 * 
	 * recent changes: 03.03.2008
	 */
	public class StringUtils 
	{
		/**
		 * Returns a modified version of a String where certain characters were replaced with other caracters.
		 * 
		 * @param str The String object to replace characters in
		 * @param args n Strings defining the characters to be replaced followed by a String defining the characters to replace with (so amount of attributes in args has to be even)
		 * 
		 * @return modified String
		 */
		public static function replace(str:String, ...args):String
		{
			if((args.length % 2) == 0)
			{
				for(var i:Number = 0; i < args.length; i += 2)
				{
					if((args[i] is String) && (args[i + 1] is String))
					{
						str = str.split(args[i]).join(args[i + 1]);
					}
					else
					{
						throw new Error("Replacement input is not of type String.");
					}
				}
				
				return(str);
			}
			else
			{
				throw new Error("Incorrect number of arguments. Arguments defined in args have to be even.");
				return "";
			}
		}
		
		/**
		 * Returns a modified version of a String where certain characters were removed.
		 * 
		 * @param str The String object to remove characters in
		 * @param args n Strings defining the characters to be removed
		 * 
		 * @return modified String
		 */
		public static function remove(str:String, ...args):String
		{
			for(var i:uint = 0; i < args.length; i++) str = str.split(String(args[i])).join("");
			return str;
		}
		
		/**
		 * Returns a modified version of a String where whitespaces at the beginning and at the end are terminated.
		 * Optional characters to be removed can be defined.
		 * 
		 * @param str The String object to modify
		 * @param args Strings defining characters to be replaced
		 * 
		 * @return modified String
		 */
		public static function clean(str:String, trim:* = null, trimStartEnd:* = null):String
		{
			if(str != null)
			{
				var trimArr:Array;
				var trimStartEndArr:Array;
				
				// check variables
				if(trim is String) trimArr = [trim];
				else if(trim is Array) trimArr = trim;
				
				if(trimStartEnd is String) trimStartEndArr = [trimStartEnd];
				else if(trimStartEnd is Array) trimStartEndArr = trimStartEnd;
				
				// trim
				if(trimArr != null)
				{
					for(var i:uint = 0; i < trimArr.length; i++)
					{
						if(trimArr[i] is String)
						{
							str = str.split(trimArr[i]).join("");
						}
						else
						{
							throw new Error("Replacement input is not of type String.");
						}
					}
				}
				
				// trim start end
				if(trimStartEndArr != null)
				{
					while(true)
					{
						var startchar:String = str.charAt(0);
						var startTrimmed:Boolean = false;
						
						for(var j:uint = 0; j < trimStartEndArr.length; j++)
						{
							if(trimStartEndArr[j] == startchar)
							{
								str = str.substring(1);
								startTrimmed = true;
								break;
							}
						}
						
						if(!startTrimmed) break;
					}
					
					while(true)
					{
						var endChar:String = str.charAt(str.length - 1);
						var endTrimmed:Boolean = false;
						
						for(var k:uint = 0; k < trimStartEndArr.length; k++)
						{
							if(trimStartEndArr[k] == endChar)
							{
								str = str.substr(0, str.length - 1);
								endTrimmed = true;
								break;
							}
						}
						
						if(!endTrimmed) break;
					}
				}
			}
			
			return str;
		}
		
		/**
		 * Returns all characters after the occurance of a certain String.
		 * 
		 * @param str String to check
		 * @param occ occurance to find
		 * 
		 * @return the characters after the occurance or the whole string if no occurance has been found.
		 */
		public static function getAfter(str:String, occ:String):String
		{
			var occIndex:int = str.indexOf(occ);
			
			if(occIndex == -1) return str;
			return str.substr(occIndex + occ.length);
		}
		
		/**
		 * Returns all characters before the occurance of a certain String.
		 * 
		 * @param str String to check
		 * @param occ occurance to find
		 * 
		 * @return the characters before the occurance or the whole string if no occurance has been found.
		 */
		public static function getBefore(str:String, occ:String):String
		{
			var occIndex:int = str.indexOf(occ);
			
			if(occIndex == -1) return str;
			return str.substring(0, occIndex);
		}
		
		/**
		 * Simply returns if a string contains a speciffic occurence or characters.
		 * 
		 * @param str the Strig to search in
		 * @param occ the characters to wearch for
		 * 
		 * @return true if found, false if not
		 */
		public static function contains(str:String, occ:String):Boolean
		{
			return (str.indexOf(occ) != -1);
		}
		
		/**
		 * Checks weather a String is a vaild eMail address or not.
		 * 
		 * @param str String to check
		 * 
		 * @return true for valid, false for not valid
		 */
		public static function validMail(str:String):Boolean
		{
			if(str == null) return false;
			
			var regExp:RegExp = /([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}/;
			return regExp.test(str);
		}
		
		/**
		 * Checks weather a String is a vaild weblink or not.
		 * 
		 * @param str String to check
		 * 
		 * @return true for valid, false for not valid
		 */
		public static function validURL(str:String):Boolean
		{
			if(str == null) return false;
			
			var regExp:RegExp = /http:\/\/[0-9a-zA-Z.-_&?= ]+\.[a-zA-Z]{2,6}[0-9a-zA-Z.-_&?=\/ ]*/;
			return regExp.test(str);
		}
		
		public static function extractNumber(input:String):Number
		{
			var cleanedString:String = "";			var cleanedNumber:Number;
			
			if(input != null)
			{
				for(var i:uint = 0; i < input.length; i++)
				{
					var char:String = input.charAt(i);
					
					if(char.search("[0-9]|\\.|,|-") == 0)
					{
						if(char == ",") cleanedString += ".";
						else cleanedString += char;
					}
				}
				
				cleanedNumber = Number(cleanedString);
				
				if(isNaN(cleanedNumber)) return 0;
				else return Number(cleanedNumber);
			}
			
			return 0;
		}
		
		public static function leadingZero(num:Number, digits:int = 2):String
		{
			var str:String = String(num);
			
			var pre:String;
			var post:String;
			
			if(str.indexOf(".") == -1) pre = str;
			else
			{
				pre = getBefore(str, ".");
				post = getAfter(str, ".");
			}
			
			while(pre.length < digits) pre = "0" + pre;
			
			if(post == null) return pre;
			else return (pre + "." + post);
		}
	}
}
