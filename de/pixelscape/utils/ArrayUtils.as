package de.pixelscape.utils 
{

	/**
	 * @author Tobias Friese
	 */
	public class ArrayUtils 
	{
		public static function getByClass(array:Array, classType:Class):Array
		{
			var out:Array;
			var entry:*;
			
			if(array != null)
			{
				out = new Array();
				
				for(var i:int = 0; i < array.length; i++)
				{
					entry = array[i];
					if(entry is classType) out.push(entry);
				}
			}
			
			return out;
		}
	}
}
