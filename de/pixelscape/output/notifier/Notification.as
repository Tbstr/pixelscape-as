package de.pixelscape.output.notifier 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * Baseclass for notifications.
	 * 	 * @author Tobias Friese	 */	public class Notification extends Sprite
	{		/* variables */
		protected var _notifier:Notifier;
		
		protected var _id:String;
		
		protected var _message:*;		protected var _messageAsString:String;
		
		protected var _delay:Number							= 5;
		protected var _stack:Boolean						= false;		protected var _lockPosition:Boolean					= false;
		protected var _center:Boolean						= false;
		protected var _container:DisplayObjectContainer;
		protected var _properties:Object;
		protected var _isWebPath:Boolean;		protected var _isImagePath:Boolean;		protected var _isVideoPath:Boolean;		protected var _isSoundPath:Boolean;
		
		protected var _delayTimer:Timer;
		
		/* constants */
		protected var FILE_TYPES_IMAGE:Array				= new Array(".jpg", ".jpeg", ".png", ".gif");		protected var FILE_TYPES_VIDEO:Array				= new Array(".flv");		protected var FILE_TYPES_SOUND:Array				= new Array(".mp3", ".wav");
		
		/**
		 * Notification constructor
		 * 
		 * @param notifier the Notifier class this notification belongs to
		 * @param message the object to be notified
		 * @param properties custom properties to be applied to this Notification object
		 */
		public function Notification(notifier:Notifier, message:*, properties:Object = null)
		{	
			// set message
			this._message = message;
			
			if(message == null) this._messageAsString = "null";
			else
			{
				if(message is String) this._messageAsString = message;
				else
				{
					if("toString" in message) this._messageAsString = message.toString();
					else this._messageAsString = String(message);
				}
			}
			
			this._notifier = notifier;
			this._properties = properties;
			
			// set message type
//			this.setTypeProperties();
			
			// apply properties
			this.applyProperties();
			
			// set up timer
			this._delayTimer = new Timer(this._delay * 1000, 1);
			this._delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.handleDelayTimerComplete);
			this._delayTimer.start();
		}
		
		protected function setTypeProperties():void
		{
			this._isWebPath = this.webPathCheck(this._messageAsString);
			this._isImagePath = this.fileTypeCheck(this._messageAsString, FILE_TYPES_IMAGE);			this._isVideoPath = this.fileTypeCheck(this._messageAsString, FILE_TYPES_VIDEO);			this._isSoundPath = this.fileTypeCheck(this._messageAsString, FILE_TYPES_SOUND);
		}
		
		protected function isPath():Boolean
		{
			if(this._isWebPath) return true;			if(this._isImagePath) return true;			if(this._isVideoPath) return true;			if(this._isSoundPath) return true;
			
			return false;
		}
		
		protected function webPathCheck(value:String):Boolean
		{
			value = value.toLowerCase();
			value = this.cleanPath(value);
			
			if(value.indexOf("http://") == 0)
			{
				return true;
			}
			
			if(value.indexOf("www.") == 0)
			{
				return true;
			}
			
			return false;
		}
		
		protected function cleanPath(path:String):String
		{
			while(path.indexOf(" ") == 0)
			{
				path = path.substr(1);
			}
			
			while(path.indexOf(" ") == (path.length - 1))
			{
				path = path.substr(0, path.length - 1);
			}
			
			if(path.indexOf("www.") == 0) path = "http://" + path; 			
			
			return path;
		}
		
		protected function fileTypeCheck(path:String, types:Array):Boolean
		{
			path = this.cleanPath(path);
			
			for(var i:Number = 0; i < types.length; i++)
			{
				var index:int = path.indexOf(types[i]);
				
				if(index != -1)
				{
					if(index == (path.length - types[i].length)) return true;
				}
			}
			
			return false;
		}
		
		/** applies the submitted properties to this object */
		protected function applyProperties():void
		{
			if(this._properties != null)
			{
				for(var id:String in this._properties)
				{
					if(id in this) this[id] = this._properties[id];
				}
			}
		}
		
		/**
		 * Starts closing process.
		 * 
		 * Override this method for individual closing process in subclasses.
		 */
		protected function close():void
		{
			this.remove();
		}
		
		protected function remove():void
		{
			this._notifier.removeNotification(this);
		}
		
		/* getter and setter */
		public function get id():String
		{
			return this._id;
		}
		
		public function set id(value:String):void
		{
			this._id = value;
		}
		
		public function get stack():Boolean
		{
			return this._stack;
		}
		
		public function set stack(value:Boolean):void
		{
			if(this._stack != value)
			{
				this._stack = value;
				
				if(value == true)
				{
					// check center
					 this._center = false;
					
					// check container
					this._container = null;
				}
			}
		}
		
		public function get positionLocked():Boolean
		{
			return this._lockPosition;
		}

		public function get delay():Number
		{
			return this._delay;
		}
		
		public function set delay(value:Number):void
		{
			this._delay = value;
		}
		
		public function get message():String
		{
			return this._message;
		}
		
		public function get container():DisplayObjectContainer
		{
			return this._container;
		}
		
		public function set container(value:DisplayObjectContainer):void
		{
			if(this._container != value)
			{
				this._container = value;
				
				if(value != null)
				{
					if(value != this._notifier.container)
					{
						this._stack = false;
					}
				}
			}
		}
		
		public function get center():Boolean
		{
			return this._center;
		}
		
		public function set center(value:Boolean):void
		{
			if(this._center != value)
			{
				this._center = value;
				
				if(value == true)
				{
					this._stack = false;
				}
			}
		}
		
		public function finalize():void
		{
			// kill timer
			if(this._delayTimer.running) this._delayTimer.stop();
		}

		/* event handler */
		private function handleDelayTimerComplete(e:TimerEvent):void
		{
			this.close();
		}
	}}