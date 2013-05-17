package de.pixelscape.input 
{
	import de.pixelscape.output.notifier.Notifier;

	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;

	/**
	 * This class provides controls for reaction on keyboard input.
	 * 
	 * @author Tobias Friese
	 * @version 0.6
	 * 
	 * recent changes: 6.5.2008 14:00
	 */
	public class KeyboardAgent 
	{
		/* variables */
		private static var _instance:KeyboardAgent;
		
		private var _dispatcher:EventDispatcher;
		
		private var _enabled:Boolean;

		private var _keywords:Array;		private var _keys:Array;
		
		private var _string:String;
		private var _timestamp:uint;
		
		private var _keyCodeTraceMode:Boolean;		private var _charCodeTraceMode:Boolean;
		
		/* constants */
		private static const KEY_CODE:String = "keyCode";		private static const CHAR_CODE:String = "charCode";
		
		/** constructor method */
		public function KeyboardAgent()
		{
			if(_instance)
			{
				throw new Error("KeyboardAgent is a Singleton and therefor can only be accessed through KeyboardAgent.getInstance()");
			}
            else
            {
            	_instance = this;
            }
            
            // vars
            this._enabled		= true;
            
            this._keywords		= new Array();            this._keys			= new Array();
            
            this._string		= "";            this._timestamp		= 0;
		}
		
		/** singleton getter */
		public static function getInstance():KeyboardAgent
		{
			if(_instance == null) _instance = new KeyboardAgent();
			return _instance;
		}
		
		/** singleton getter */
		public static function get instance():KeyboardAgent
		{
			if(_instance == null) _instance = new KeyboardAgent();
			return _instance;
		}
		
		/**
		 * This method initializes the KeyboardAgent. Without initialization
		 * keyboard input will not be tracked.
		 * 
		 * @param dispatcher The EventDispatcher on which the keyboard activities should be tracked.
		 */
		public function initialize(dispatcher:EventDispatcher):void
		{
			this._dispatcher = dispatcher;
			
			// set listener
			registerListeners();
		}
		
		/* getter methods */
		
		/** Returns the EventDispatcher that the KeyboardAgent is applied to. */
		public function get dispatcher():EventDispatcher
		{
			return _dispatcher;
		}
		
		/** Returns if the KeyboardAgent is enabled or not. */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		/** Returns the number of registered keys. */
		public function get numKeys():uint
		{
			return _keys.length;
		}
		
		/** Returns the number of registered keywords. */
		public function get numKeywords():uint
		{
			return _keywords.length;
		}

		/* setter methods */
		
		/** Defines a new EventDispatcher to track the keyboard activities from. */
		public function set dispatcher(value:EventDispatcher):void
		{
			if(value !== _dispatcher)
			{
				unregisterListeners();
				
				// set var
				this._dispatcher = value;
				
				registerListeners();
			}
		}
		
		/** Enables or disables the tracking of keyboard events. */
		public function set enabled(value:Boolean):void
		{
			if(value != _enabled)
			{
				_enabled = value;
				
				if(_dispatcher != null)
				{
					if(value == true)
					{
						registerListeners();
					}
					else
					{
						unregisterListeners();
					}
				}
			}
		}
		
		/* registration methods */
		
		/**
		 * Adds a new key to the tracking list.
		 * 
		 * <p>Input of a char as String or a keyCode is possible.</p>
		 * 
		 * @param input char as String or keyCode
		 * @param callFunction the function that should be called when key is pressed
		 * 
		 * @return true or false depending on success of registration
		 */
		public function addKey(input:*, callFunction:Function, ...args):Boolean
		{
			var code:uint;
			var type:String;
			
			// value detection
			if(input is String)
			{
				if(input.length > 0)
				{
					code = (input as String).charCodeAt(0);
					type = CHAR_CODE;
				}
			}
			
			if(input is uint)
			{
				code = input;
				type = KEY_CODE;
			}
			
			// add to stack
			if(type != null)
			{
				_keys.push({code:code, type:type, callFunction:callFunction, arguments:args});
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * Removes a registered key from tracking list.
		 * 
		 * @param input char as String or keyCode
		 * @param callFunction the function that should be called when key is pressed
		 */
		public function removeKey(input:*, callFunction:Function):void
		{
			var code:uint;
			var type:String;
			
			// value detection
			if(input is String)
			{
				if(input.length > 0)
				{
					code = (input as String).charCodeAt(0);
					type = CHAR_CODE;
				}
			}
			
			// remove
			if(type != null)
			{
				for(var i:uint = 0; i < _keys.length; i++)
				{
					var keyObject:Object = _keys[i];
					
					if(keyObject.code != code) continue;					if(keyObject.type != type) continue;					if(keyObject.callFunction !== callFunction) continue;					
					_keys.splice(i, 1);
				}
			}
		}
		
		/**
		 * Adds a new keyword to the tracking list.
		 * 
		 * @param keyword the keyword to be tracked
		 * @param callFunction the function that should be called when keyword is tracked
		 */
		public function addKeyword(keyword:String, callFunction:Function, ...args):void
		{
			_keywords.push({keyword:keyword, callFunction:callFunction, arguments:args});
		}
		
		/**
		 * Removes a new keyword to the tracking list.
		 * 
		 * @param keyword the keyword to be removed
		 * @param callFunction the function that should be called when keyword is tracked
		 */
		public function removeKeyword(keyword:String, callFunction:Function):void
		{
			for(var i:uint = 0; i < _keywords.length; i++)
			{
				if(_keywords[i].keyword == keyword) _keywords.splice(i, 1);
			}
		}
		
		/* methods */
		private function registerListeners():void
		{
			if(_dispatcher != null)
			{
				_dispatcher.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}
		}
		
		private function unregisterListeners():void
		{
			if(_dispatcher != null)
			{
				_dispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				
				_dispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerKeyCodeTrace);
				_dispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerCharCodeTrace);
			}
		}
		
		private function checkKey(charCode:uint, keyCode:uint):void
		{
			// check for keys
			if(_keys.length > 0)
			{
				for(var i:uint = 0; i < _keys.length; i++)
				{
					var keyObject:Object = _keys[i];
					
					switch(keyObject.type)
					{
						case CHAR_CODE:
							if(keyObject.code != charCode) continue;
							break;
							
						case KEY_CODE:
							if(keyObject.code != keyCode) continue;
							break;
					}
						
					if(keyObject.arguments.length == 0)
					{
						keyObject.callFunction();
					}
					else
					{
						keyObject.callFunction.apply(NaN, keyObject.arguments);
					}
				}
			}
		}
		
		private function checkKeyword(charCode:uint):void
		{
			if(_keywords.length > 0)
			{
				var currentTime:uint = getTimer();
				var diff:uint = currentTime - _timestamp;
				_timestamp = currentTime;
				
				if(diff > 1000) _string = "";
				_string += String.fromCharCode(charCode);
				
				// check keywords
				for(var j:uint = 0; j < _keywords.length; j++)
				{
					var keywordObject:Object = _keywords[j];
					
					if(_string.indexOf(keywordObject.keyword) !== -1)
					{
						_string = "";
						
						if(keywordObject.arguments.length == 0)
						{
							keywordObject.callFunction();
						}
						else
						{
							keywordObject.callFunction.apply(NaN, keywordObject.arguments);
						}
					}
				}
			}
		}
		
		/* getter setter */
		public function get traceKeyCode():Boolean
		{
			return this._keyCodeTraceMode;
		}
		
		public function set traceKeyCode(value:Boolean):void
		{
			if(this._keyCodeTraceMode != value)
			{
				if(value) this._dispatcher.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerKeyCodeTrace);
				else this._dispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerKeyCodeTrace);
				
				this._keyCodeTraceMode = value;
			}
		}
		
		public function get traceCharCode():Boolean
		{
			return this._charCodeTraceMode;
		}
		
		public function set traceCharCode(value:Boolean):void
		{
			if(this._charCodeTraceMode != value)
			{
				if(value) this._dispatcher.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerCharCodeTrace);
				else this._dispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerCharCodeTrace);
				
				this._charCodeTraceMode = value;
			}
		}

		/**
		 * Prepares KeyboardAgend for garbage collection.
		 */
		public function finalize():void
		{
			unregisterListeners();
			
			_keys = null;			_keywords = null;
		}
		
		/* event handler */
		private function keyDownHandler(e:KeyboardEvent):void
		{
			checkKey(e.charCode, e.keyCode);			checkKeyword(e.charCode);
		}
		
		private function keyDownHandlerKeyCodeTrace(e:KeyboardEvent):void
		{
			if(!Notifier.instance.initialized) Notifier.instance.initialize(this._dispatcher as DisplayObjectContainer);
			Notifier.notify("keyCode: " + e.keyCode);
		}
		
		private function keyDownHandlerCharCodeTrace(e:KeyboardEvent):void
		{
			if(!Notifier.instance.initialized) Notifier.instance.initialize(this._dispatcher as DisplayObjectContainer);
			Notifier.notify("charCode: " + e.charCode);
		}
	}
}
