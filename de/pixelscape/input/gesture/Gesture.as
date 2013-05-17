package de.pixelscape.input.gesture 
{

	/**
	 * @author tobias.friese
	 */
	public class Gesture 
	{
		/* variables */
		private var _gestureCode:String;		private var _gestureCodeArray:Array;
		
		public function Gesture(code:String)
		{
			this._gestureCode = code;
			
			// parse to array
			this._gestureCodeArray = new Array(code.length);
			for(var i:uint = 0; i < code.length; i++) this._gestureCodeArray[i] = parseInt(code.charAt(i));
		}
		
		/* getter */
		public function get code():String
		{
			return this._gestureCode;
		}
		
		public function get array():Array
		{
			return this._gestureCodeArray;
		}
	}
}
