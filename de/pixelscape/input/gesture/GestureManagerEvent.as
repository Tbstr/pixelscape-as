package de.pixelscape.input.gesture 
{
	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * @author tobias.friese
	 */
	public class GestureManagerEvent extends Event 
	{
		/* variables */
		private var _id:String;		private var _value:*;
		private var _gestureBounds:Rectangle;
		
		/* constants */
		public static const GESTURE_MATCH:String = "gestureMatch";		public static const GESTURE_NO_MATCH:String = "gestureNoMatch";		public static const GESTURE_RECORD_START:String = "gestureRecordStart";		public static const GESTURE_RECORD_STOP:String = "gestureRecordStop";
		
		public function GestureManagerEvent(type:String, id:String = null, value:* = null, gestureBounds:Rectangle = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			this._id = id;
			this._value = value;
			this._gestureBounds = gestureBounds;
		}
		
		/* getter */
		public function get id():String
		{
			return this._id;
		}
		
		public function get value():*
		{
			return this._value;
		}
		
		public function get gestureBounds():Rectangle
		{
			return this._gestureBounds;
		}
	}
}
