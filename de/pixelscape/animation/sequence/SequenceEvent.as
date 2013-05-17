package de.pixelscape.animation.sequence 
{
	import flash.events.Event;

	/**
	 * @author Tobias Friese
	 */
	public class SequenceEvent extends Event 
	{
		private var _sequence:Sequence;		private var _currentObject:*;		private var _last:Boolean;
		
		
		/* constants */
		
		/** Dispatched for each object when its processing time is reached. */
		public static const STEP:String = "Sequence.STEP";
		/** Dispatched when last object has been processed. */		public static const COMPLETE:String = "Sequence.COMPLETE";
		
		/** SequenceEvent constructor */
		public function SequenceEvent(type:String, sequence:Sequence, currentObject:*, last:Boolean = false, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			this._sequence = sequence;			this._currentObject = currentObject;
			this._last = last;
		}
		
		
		/* getter methods */
		
		/** The Sequence class this Event was dispatched from. */
		public function get sequence():Sequence
		{
			return this._sequence;
		}
		
		/** The currently processed object. */
		public function get currentObject():*
		{
			return this._currentObject;
		}
		
		/** Defines if the current object is the last or not */
		public function get last():Boolean
		{
			return this._last;
		}
	}
}
