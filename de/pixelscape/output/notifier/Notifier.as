package de.pixelscape.output.notifier
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Point;

	/**
	 * The Notifier class generates a notification box containing any possible message to be shown on stage at runtime.
	 * This makes traces possible where no output panel is available and can also be used as message popup within applications.
	 * 
	 * <p>Custom notifications can be created by extending the Notification class and defining it while
	 * calling the initalize method</p>
	 * 
	 * @author Tobias Friese
	 * 
	 * @version 1.1
	 * 
	 * recent changes 30.11.2008
	 */
	public class Notifier
	{
		private static var _instance:Notifier;
		
		private var _container:DisplayObjectContainer;
		private var _defaultNotificationType:Class;
		private var _initialized:Boolean					= false;		private var _muted:Boolean							= false;
		
		private var _notifications:Array					= new Array();
		private var _defaultProperties:Object;
		
		private var _stackOrigin:Point						= new Point(10, 10);
		private var _stackOffset:Number						= 10;
		
		
		/* constants */
		
		/** defines the default notification type */
		public static const TYPE_STANDARD:Class = StandardNotification;

		/** Notifier constructor */
		public function Notifier()
		{
			if(_instance != null)
			{
				throw new Error("Notifier is a Singleton and therefor can only be accessed through Notifier.getInstance()");
			}
            else
            {
            	_instance = this;
            }
		}

		/** singleton getter */
		public static function getInstance():Notifier
		{
			if(_instance == null) _instance = new Notifier();
			return _instance;
		}
		
		/** singleton getter */
		public static function get instance():Notifier
		{
			return getInstance();
		}
		
		/** notification shortcut */
		public static function notify(message:*, properties:Object = null, notificationOverride:Class = null):void
		{
			getInstance().notify(message, properties, notificationOverride);
		}
		
		/**
		 * Initalizes the Notifier for use.
		 * 
		 * @param container the DisplayObjectContainer to add the notifications to by default
		 * @param type the Notification class to be used with the messages (StandardNotification by default)
		 */
		public function initialize(container:DisplayObjectContainer, type:Class = null):void
		{
			this._container = container;
			this.defaultNotificationType = type;
			
			this._initialized = true;
		}
		
		/* getter and setter */
		
		/** returns the initialization state */
		public function get initialized():Boolean
		{
			return this._initialized;
		}
		
		/** returns the mute state */
		public function get mute():Boolean
		{
			return this._muted;
		}
		
		/** defines the mute state */
		public function set mute(value:Boolean):void
		{
			this._muted = value;
			if(value) this.clear();
		}

		/** returns the currently used Notification class */
		public function get defaultNotificationType():Class
		{
			return this._defaultNotificationType;
		}
		
		/** defines the Notification class used by default */
		public function set defaultNotificationType(value:Class):void
		{
			if(value != null)
			{
				if(value is Notification) this._defaultNotificationType = value;
			}
			else
			{
				this._defaultNotificationType = Notifier.TYPE_STANDARD;
			}
		}
		
		internal function get container():DisplayObjectContainer
		{
			return this._container;
		}
		
		/** returns the origin coordinates for stack notifications */
		public function get stackOrigin():Point
		{
			return this._stackOrigin;
		}
		
		/** defines the origin coordinates for stack notifications */
		public function set stackOrigin(value:Point):void
		{
			if(value != null) this._stackOrigin = value;
		}
		
		/** returns the y offset of stack notifications */
		public function get stackOffset():Number
		{
			return this._stackOffset;
		}
		
		/** defines the y offset of stack notifications */
		public function set stackOffset(value:Number):void
		{
			this._stackOffset = value;
		}
		
		/** returns the property object that is applied to new notifications by default */
		public function get defaultProperties():Object
		{
			return this._defaultProperties;
		}
		
		/** defines the property object that is applied to new notifications by default */
		public function set defaultProperties(value:Object):void
		{
			this._defaultProperties = value;
		}
		
		/**
		 * returns the amount of notifications in gerneral or just stack notifications
		 * 
		 * @param stackOnly defines if all Notifications shall be counted or only stack Notifications
		 */
		public function numNotifications(stackOnly:Boolean = false):uint
		{
			if(stackOnly)
			{
				var counter:uint = 0;
			
				for (var i:Number = 0; i < this._notifications.length; i++)
				{
					if(this._notifications[i].stack) counter++;
				}
				
				return counter;
			}
			
			return this._notifications.length;
		}
		
		/**
		 * Returns a Notification with a certain id.
		 * 
		 * @param id the id to search for
		 */		public function getNotificationById(id:String):Notification
		{
			if(id != null)
			{
				for (var i:Number = 0; i < this._notifications.length; i++)
				{
					if(this._notifications[i].id == id) return this._notifications[i];
				}
			}
			
			return null;
		}

		/**
		 * Creates and displays a notification.
		 * 
		 * @param message the object to be displayed
		 * @param properties an object containing properties to be applied to the used notification class
		 * @param notificationOverride a custom Notification class to be used for this notification
		 */
		public function notify(message:*, properties:Object = null, notificationOverride:Class = null):void
		{
			if(this._initialized)
			{
				if(!this._muted)
				{
					// set properties
					var mergedProperties:Object = this.mergeObjects(properties, this._defaultProperties);
					
					// create notificaton
					var nf:Notification;
					
					if(notificationOverride == null)
					{
						nf = new _defaultNotificationType(this, message, mergedProperties);
					}
					else
					{
						nf = new notificationOverride(this, message, mergedProperties);
						if(!(nf is Notification)) throw new Error("notificationOverrice class has to be from type Notification.");
					}
					
					// variables
					var container:DisplayObjectContainer = (nf.container == null) ? this._container : nf.container;
					
					// position
					if(nf.stack)
					{
						// stack
						this.positionStackNotification(nf);
					}
					else
					{
						// center
						if(nf.center)
						{
							var cWidth:Number;
							var cHeight:Number;
							
							if(container is Stage)
							{
								cWidth = Stage(container).stageWidth;								cHeight = Stage(container).stageHeight;
							}
							else
							{
								cWidth = container.width;
								cHeight = container.height;
							}
							
							nf.x = Math.round((cWidth - nf.width) * .5);							nf.y = Math.round((cHeight - nf.height) * .5);
						}
					}
					
					// init
					container.addChild(nf);
					nf.container = container;
					
					this._notifications.push(nf);
					if(nf.stack) this.rearrangeStack();
				}
			}
			else
			{
				throw new Error("The Notifier has to be initiated first using Notifier.getInstance().initiate before you can notify messages.");
			}
		}
		
		/**
		 * Removes a notification.
		 * 
		 * @param notification the Notifcation class to be removed
		 */
		public function removeNotification(notification:Notification):void
		{
			// remove from array
			for(var i:Number = 0; i < this._notifications.length; i++)
			{
				if(this._notifications[i] === notification)
				{
					notification.finalize();
					if(notification.parent != null) notification.parent.removeChild(notification);
					this._notifications.splice(i, 1);
				}
			}
			
			// rearrange stack if notification is stack element
			if(notification.stack) this.rearrangeStack();
		}
		
		/** removes all existing notifications */
		public function clear():void
		{
			for(var i:int = 0; i < this._notifications.length; i++)
			{
				this._notifications[i].finalize();
				if(this._notifications[i].parent != null) this._notifications[i].parent.removeChild(this._notifications[i]);
			}
			
			this._notifications.splice(0);
		}
		
		/* stack specific methods */
		private function positionStackNotification(nf:Notification):void
		{
			if(this.numNotifications(true) == 0)
			{
				nf.x = this._stackOrigin.x;
				nf.y = this._stackOrigin.y;
			}
			else
			{
				var lastNf:Notification = this.getLastStackNotification();
				
				nf.x = this._stackOrigin.x;
				nf.y = lastNf.y + lastNf.height + this._stackOffset;
			}
		}
		
		private function getLastStackNotification():Notification
		{
			for(var i:int = (this._notifications.length - 1); i >= 0; i--)
			{
				if(this._notifications[i].stack) return this._notifications[i];
			}
			
			return null;
		}
		
		internal function rearrangeStack():void
		{
			var yCursor:int = this._stackOrigin.y;
			for(var i:Number = 0; i < this._notifications.length; i++)
			{
				var not:Notification = this._notifications[i];
				
				if(not.stack)
				{
					if(!not.positionLocked)
					{
						if(not.y != yCursor)
						{
							// remove tween ...
							
							TweenMax.to(not, .5, {y:yCursor, ease:Cubic.easeOut});
						}
						
						yCursor += not.height + this._stackOffset;
					}
					else yCursor = not.y +  not.height + this._stackOffset;
				}
			}
		}
		
		/* functional methods */
		private function mergeObjects(obj1:Object, obj2:Object):Object
		{
			if(obj1 == null)
			{
				return obj2;
			}
			else if(obj2 == null)
			{
				return obj1;
			}
			else
			{
				var out:Object = new Object();
				
				for(var id1:String in obj2)
				{
					out[id1] = obj2[id1];
				}
				
				for(var id2:String in obj1)
				{
					out[id2] = obj1[id2];
				}
				
				return out;
			}
			
			return null;
		}
	}
}