package de.pixelscape.display
{
	import de.pixelscape.graphics.Picasso;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;	

	/**
	 * Allows an easy implemetation of videos into an application. Only the URL to the FLV file has to be defined
	 * as constructor attribute or when calling the play method.
	 * 
	 * @author Tobias Friese
	 * 
	 * @version 1.0
	 * 
	 * recent changes: 03.03.2008
	 */
	public class VideoPanel extends Sprite
	{
		/* variables */
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _customClient:Object;
		
		private var _video:Video;
		private var _src:String;
		private var _bounds:Rectangle;
		private var _metaData:Object;
		
		private var _loop:Boolean					= false;
		private var _status:String;
		
		/* constants */
		public static const META_DATA:String 		= "VideoPanel.META_DATA";
				public static const SWITCH:String 			= "VideoPanel.SWITCH";		public static const COMPLETE:String 		= "VideoPanel.COMPLETE";
		
		public static const STATUS_CHANGED:String 	= "VideoPanel.STATUS_CHANGED";
				public static const STATUS_PLAY:String 		= "VideoPanel.STATUS_PLAY";		public static const STATUS_PAUSE:String 	= "VideoPanel.STATUS_PAUSE";		public static const STATUS_STOP:String 		= "VideoPanel.STATUS_STOP";
		
		/** constructor method */
		public function VideoPanel(src:String = null)
		{
			this._status = STATUS_STOP;
			
			// netConnection
			this._netConnection = new NetConnection();
			this._netConnection.connect(null);
			
			// netStream
			this._netStream = new NetStream(this._netConnection);
			
			this._customClient = new Object();
			this._customClient.onMetaData = metaDataHandler;
			this._customClient.onPlayStatus = playStatusHandler;
			this._netStream.client = this._customClient;
			
			// video
			this._video = new Video();
			this._video.attachNetStream(this._netStream);
			addChild(this._video);
			
			// vars
			this._src = src;

			// register listeners
			this.registerListeners();
		}
		
		private function registerListeners():void
		{
			this._netStream.addEventListener(NetStatusEvent.NET_STATUS , statusEventHandler);
			this._netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.removedFromStageHandler);
		}
		
		private function unregisterListeners():void
		{
			this._netStream.removeEventListener(NetStatusEvent.NET_STATUS , statusEventHandler);
			this._netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.removedFromStageHandler);
		}

		/* getter methods */
		
		/**
		 * @return the currently set source path
		 */
		public function get src():String
		{
			return this._src;
		}
		
		/**
		 * @return the currently loaded bytes
		 */
		public function bytesLoaded():uint
		{
			return (this._netStream != null) ? this._netStream.bytesLoaded : 0;
		}
		
		/**
		 * @return the total amount of bytes to be loaded
		 */
		public function bytesTotal():uint
		{
			return (this._netStream != null) ? this._netStream.bytesTotal : 0;
		}
		
		/**
		 * @return a value from 0 to 1 defining the current loading status
		 */
		public function get loadRatio():Number
		{
			return (this._netStream != null) ? (this._netStream.bytesLoaded / this._netStream.bytesTotal) : 0;
		}
		
		/**
		 * @return the volume from 0 to 1
		 */
		public function get volume():Number
		{
			return this._netStream.soundTransform.volume;
		}
		
		/**
		 * @return the current status of the VideoPanel object according to the STATUS_... constants.
		 */
		public function get status():String
		{
			return this._status;
		}
		
		/**
		 * @return the current NetStream object
		 */
		public function get stream():NetStream
		{
			return this._netStream;
		}
		
		/**
		 * @return smoothing property of the video object
		 */
		public function get smoothing():Boolean
		{
			return _video.smoothing;
		}
		
		/**
		 * @return framerate defined in the video files meta data
		 */
		public function get framerate():Number
		{
			if(_metaData != null)
			{
				return _metaData.framerate;
			}
			else
			{
				return 0;
			}
		}
		
		/**
		 * @return the current framerate with which the video is playing
		 */
		public function get currentFPS():Number
		{
			return _netStream.currentFPS;
		}
		
		/**
		 * @return the position of the playhead in seconds
		 */
		public function get time():Number
		{
			return _netStream.time;
		}
		
		/**
		 * @return the duration of the current stream in seconds
		 */
		public function get duration():Number
		{
			if(this._metaData != null)
			{
				return ("duration" in this._metaData) ? this._metaData.duration : 0; 
			}
			else
			{
				return 0;
			}
		}
		
		/**
		 * @return an object containing the meta data information
		 */
		public function get metaData():Object
		{
			return this._metaData;
		}

		/* setter mehods */
		
		/**
		 * defines whether the video shall be smoothed or not
		 */
		public function set smoothing(value:Boolean):void
		{
			_video.smoothing = value;
		}
		
		/**
		 * sets the volume in which the sound should be played
		 */
		public function set volume(value:Number):void
		{
			var soundTrans:SoundTransform = this._netStream.soundTransform;
			soundTrans.volume = value;
			
			this._netStream.soundTransform = soundTrans;
		}
		
		public function get loop():Boolean					{ return _loop; }
		public function set loop(value:Boolean):void		{ _loop = value; }
		
		/**
		 * Sets a new source and shows the first frame of the video without playing it.
		 * 
		 * @param src URL to the FLV file
		 */
		public function tease(src:String = null):void
		{
			if(src != null) this._src = src;
			
			if(this._src != null)
			{
				this._netStream.play(this._src);				this._netStream.seek(0);
				this._netStream.pause();
				
				this.setStatus(STATUS_PAUSE);
			}
		}
		
		/**
		 * Starts the playback of the video.
		 * 
		 * <p>The URL of the video file has to be provided as attribute if not done at the constructor method.</p>
		 * 
		 * @param src URL to the FLV file (required if not set throug the constructor method)
		 */
		public function play(src:String = null):void
		{
			if(src != null) this._src = src;
			
			if(this._src != null)
			{
				this._netStream.play(this._src);
				this.setStatus(STATUS_PLAY);
			}
		}
		
		/**
		 * Pauses the playback. Calling this method if already paused has no effect.
		 */
		public function pause():void
		{
			this._netStream.pause();
			
			this._status = STATUS_PAUSE;
			this.dispatchStatusChanged();
		}
		
		/**
		 * Pauses or resumes playback of the video.
		 */
		public function togglePause():void
		{
			this._netStream.togglePause();
			
			if(this._status == STATUS_PLAY) this._status = STATUS_PAUSE;
			else this._status = STATUS_PLAY;
			this.dispatchStatusChanged();
		}

		/**
		 * Resumes paused playback.
		 */
		public function resume():void
		{
			this._netStream.resume();
			
			this._status = STATUS_PLAY;
			this.dispatchStatusChanged();
		}
		
		/**
		 * Stops video playback.
		 */
		public function stop():void
		{
			this._netStream.close();
			this._status = STATUS_STOP;
			this.dispatchStatusChanged();
		}
		
		/**
		 * Resets video playback.
		 */
		public function reset():void
		{
			this._netStream.seek(0);
			this._netStream.pause();
			
			this.setStatus(STATUS_PAUSE);
		}
		
		/**
		 * Stops video playback.
		 */
		public function seek(offset:Number):void
		{
			this._netStream.seek(offset);
		}
		
		/**
		 * Resizes the video panel to fit into a defined region.
		 * 
		 * @param args Rectangle definition either as Rectangle object or as width and height attributes
		 */
		public function fitInto(...args):void
		{
			if(args.length == 1)
			{
				if(args[0] is Rectangle)
				{
					_bounds = args[0];
				}
			}
			else if(args.length == 2)
			{
				if((args[0] is Number) && (args[1] is Number))
				{
					_bounds = new Rectangle(0, 0, args[0], args[1]);
				}
			}
			
			if((_bounds != null) && (_metaData != null))
			{
				var vidRatio:Number = Number(_metaData.width) / Number(_metaData.height);
				var targetRatio:Number = _bounds.width / _bounds.height;
				
				var tWidth:Number;
				var tHeight:Number;
				
				if(vidRatio > targetRatio)
				{
					tWidth = _bounds.width;
					tHeight = _bounds.width / vidRatio;
				}
				else
				{
					tHeight = _bounds.height;
					tWidth = _bounds.height * vidRatio;
				}
				
				_video.width = tWidth;
				_video.height = tHeight;
			}
		}
		
		private function setStatus(status:String):void
		{
			if(status != this._status)
			{
				this._status = status;
				this.dispatchStatusChanged();
			}
		}
		
		private function dispatchStatusChanged():void
		{
			this.dispatchEvent(new Event(STATUS_CHANGED));
		}
		
		public function finalize():void
		{
			this.unregisterListeners();
			
			this._netStream.close();
			this._netConnection.close();
			
			this._netConnection = null;
			this._netStream = null;
			this._video = null;	
		}
		
		/* event handler */
		private function removedFromStageHandler(e:Event):void
		{
			this.stop();
		}
		
		private function statusEventHandler(e:NetStatusEvent):void
		{
			switch(e.info.code)
		    {
				case "NetStream.Play.StreamNotFound":
					break;
				
				case "NetStream.Play.Stop":
					
					if(_loop)
					{
						_netStream.seek(0);
					}
					else
					{
						this._status = COMPLETE;
						this.dispatchStatusChanged();
					}
					
		        	break;
		    }
			
		}
		
		private function asyncErrorHandler(e:AsyncErrorEvent):void
		{
			
		}
		
		private function metaDataHandler(info:Object):void
		{
			this._metaData = info;
			
			if(this._bounds)
			{
				fitInto();
			}
			else
			{
				this._video.width = info.width;
				this._video.height = info.height;
			}
			
			// draw canvas
			Picasso.drawRectangle(this, 0, 1, 0, 0, this.width, this.height);
			
			// dispatch event
			this.dispatchEvent(new Event(META_DATA));
		}
		
		private function playStatusHandler(info:Object):void
		{
			trace("NetClientStatus: " + String(info.code));
			
			switch(String(info.code))
			{
				case "NetStream.Play.Switch":
					this._status = STATUS_PLAY;
					this.dispatchStatusChanged();
					
					this.dispatchEvent(new Event(SWITCH));
					break;
					
				case "NetStream.Play.Complete":
					this._status = STATUS_STOP;
					this.seek(0);
					this.dispatchStatusChanged();
					
					this.dispatchEvent(new Event(STATUS_STOP));
					break;
			}
		}
	}
}
