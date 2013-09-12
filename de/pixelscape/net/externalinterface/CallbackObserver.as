package de.pixelscape.net.externalinterface
{
	import flash.events.EventDispatcher;
	
	public class CallbackObserver extends EventDispatcher
	{
		/* variables */
		private var _functionName:String;
		private var _callbacks:Vector.<Function>		= new Vector.<Function>();
		
		public function CallbackObserver(functionName:String)
		{
			// vars
			_functionName = functionName;
		}
		
		/* callable */
		public function callable(... args):void
		{
			// cancellation
			if(!ExternalInterfaceManager.enabled) return;
			
			// call back
			for each(var callback:Function in _callbacks) callback.apply(null, args);
		}
		
		/* callback management */
		public function addCallback(callback:Function):void
		{
			_callbacks.push(callback);
		}
		
		/* getter setter */
		public function get functionName():String			{ return _functionName; }
	}
}