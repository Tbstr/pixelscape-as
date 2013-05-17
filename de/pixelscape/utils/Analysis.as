package de.pixelscape.utils
{
	/**
	 * This class provides analytical methods.
	 * 
	 * @author Tobias Friese
	 * 
	 * @version 1.1
	 * 
	 * recent change: 02.09.2008
	 */
	public class Analysis
	{		
		/**
		 * Traces all properties and sub-properties of the given object.
		 * 
		 * @param obj the Object to trace
		 */
		public static function traceObject(obj:Object):void
		{
			trace(objectToString(obj));
		}
		
		/**
		 * Returns all properties and sub-properties of the given object as String.
		 * 
		 * @param obj the Object to trace
		 */
		public static function objectToString(obj:Object, pre:String = ""):String
		{
			var str:String = "";
			
			if(obj is Array)
			{
				str += "array(" + obj.length + ")";
				str += "\n" + pre + "   |";
				
				for(var arrKey:String in obj)
				{
					str += "\n" + pre + "   |-[" + arrKey + "] : ";
					str += objectToString(obj[arrKey], pre + "   |");
				}
				
				str += "\n" + pre;
			}
			
			else if(obj is Boolean)		str += String(obj);			else if(obj is String)		str += "\"" + obj + "\"";			else if(obj is Number)		str += String(obj);			else if(obj == null)		str += "null";
			
			else
			{
				str += "object " + String(obj);
				str += "\n" + pre + "   |";
				
				for(var objKey:String in obj)
				{
					str += "\n" + pre + "   |-[\"" + objKey + "\"] : ";
					str += objectToString(obj[objKey], pre + "   |");
				}
				
				str += "\n" + pre;
			}
			
			return str;
		}
	}
}