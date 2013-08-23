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
		
		public static function shuffle(array:Array):Array
		{
			// cancellation
			if(array == null) return null;
			
			// shuffle
			var shuffled:Array = new Array();
			var index:int;
			
			for(var i:int = array.length - 1; i >= 0; i--)
			{
				index = Math.round(Math.random() * i);
				
				shuffled.push(array[index]);
				array.splice(index, 1);
			}
			
			// return
			return shuffled;
		}
	}
}
