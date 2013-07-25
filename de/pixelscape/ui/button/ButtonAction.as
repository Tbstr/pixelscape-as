package de.pixelscape.ui.button 
{

	/**
	 * @author Tobias Friese
	 */
	public class ButtonAction 
	{
		/* variables */
		private var _eventType:String;
		private var _functionCall:Function;
		private var _arguments:Array;
		
		public function ButtonAction(eventType:String, functionCall:Function, arguments:Array)
		{
			this._eventType = eventType;
			this._functionCall = functionCall;
			this._arguments = arguments;
		}
		
		public function execute():void
		{
			if(this._functionCall != null) this._functionCall.apply(undefined, this._arguments);
		}
		
		/* getter setter */
		public function get eventType():String
		{
			return this._eventType;
		}
		
		public function get functionCall():Function
		{
			return this._functionCall;
		}
		
		public function get arguments():Array
		{
			return this._arguments;
		}
		
		/* finalization */
		public function finalize():void
		{
			_eventType = null;
			_functionCall = null;
			_arguments = null;
		}
	}
}
