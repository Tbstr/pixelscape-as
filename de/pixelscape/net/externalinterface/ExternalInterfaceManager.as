package de.pixelscape.net.externalinterface
{
	import flash.external.ExternalInterface;
	
	public class ExternalInterfaceManager
	{
		/* variables */
		private static var _enabled:Boolean								= true;
		private static var _observers:Vector.<CallbackObserver>			= new Vector.<CallbackObserver>;
		
		/* calls & events */
		public static function call(functionName:String, ... args):void
		{
			// cancellation
			if(!ExternalInterface.available) return;
			if(!_enabled) return;
			
			// call
			args.unshift(functionName)
			ExternalInterface.call.apply(ExternalInterface, args);
		}
		
		public static function registerForCall(functionName:String, callback:Function):void
		{
			// cancellation
			if(!ExternalInterface.available) return;
			
			// manage observer
			var observer:CallbackObserver = getObserverByFunctionName(functionName);
			if(observer == null)
			{
				observer = new CallbackObserver(functionName);
				ExternalInterface.addCallback(functionName, observer.callable);
				
				_observers.push(observer);
			}
			
			observer.addCallback(callback);
		}
		
		/* getter setter */
		private static function getObserverByFunctionName(functionName:String):CallbackObserver
		{
			for each(var observer:CallbackObserver in _observers)
			{
				if(observer.functionName == functionName) return observer;
			}
			
			return null;
		}
		
		public static function get available():Boolean							{ return ExternalInterface.available; }
		
		public static function get enabled():Boolean							{ return _enabled; }
		public static function set enabled(value:Boolean):void					{ _enabled = value; }
		
		public static function get marshallExceptions():Boolean					{ return ExternalInterface.marshallExceptions; }
		public static function set marshallExceptions(value:Boolean):void		{ ExternalInterface.marshallExceptions = value; }
		
		public static function get objectID():String							{ return ExternalInterface.objectID; }
	}
}