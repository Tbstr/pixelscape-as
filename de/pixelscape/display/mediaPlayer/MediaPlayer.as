package de.pixelscape.display.mediaPlayer
{
	import ca.turbulent.media.Pyro;
	import ca.turbulent.media.events.PyroEvent;
	
	import com.greensock.TweenLite;
	
	import de.pixelscape.data.MediaData;
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.utils.TransformationUtils;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class MediaPlayer extends Sprite
	{
		/* variables */
		private var _media:Vector.<MediaData>;
		
		private var _width:Number;
		private var _height:Number;
		
		private var _mediaCursor:int										= -1;
		private var _currentMedia:DisplayObject;
		
		private var _metaInfoVisible:Boolean								= false;
		private var _metaInfoTimer:Timer;
		
		private var _showControls:Boolean									= true;
		private var _showMeta:Boolean										= true;
		
		private var _loop:Boolean											= false;
		
		private var _fullscreenMode:Boolean									= false;
		private var _enabled:Boolean										= true;
		
		
		/* architecture */
		private var _container:Sprite;
		
		private var _background:Shape;
		
		private var _contentContainer:Sprite;
		private var _contentMask:Shape;
		
		private var _metaLayer:MediaPlayerMetaLayer;
		private var _videoNavigation:MediaPlayerVideoNavigation;
		private var _fullscreenButton:MediaPlayerFullscreenButton;
		
		/* constants */
		public static const MEDIA_CHANGED:String							= "mediaChanged";
		
		public static const VIDEO_METADATA_RECEIVED:String					= "videoMetaDataReceived";
		public static const VIDEO_COMPLETED:String							= "videoCompleted";
		public static const SELF_RESIZED:String								= "selfResized";
		
		public static const DISPLAY_FULLSCREEN:String						= "displayFullscreen";							
		public static const DISPLAY_NORMAL:String							= "displayNormal";							
		
		public function MediaPlayer(media:Vector.<MediaData>, width:Number, height:Number)
		{
			// var
			_media = media;
			_width = width;
			_height = height;
			
			_metaInfoTimer = new Timer(3000, 1);
			
			// build & arrange
			build();
			arrange();
			
			// event listener
			registerListeners();
		}
		
		private function build():void
		{
			// container
			_container = new Sprite();
			addChild(_container);
			
			// background
			_background = new Shape();
			_container.addChild(_background);
			
			// content container
			_contentContainer = new Sprite();
			_container.addChild(_contentContainer);
			
			// content mask
			_contentMask = new Shape();
			_container.addChild(_contentMask);
			
			_contentContainer.mask = _contentMask;
			
			// meta label
			_metaLayer = new MediaPlayerMetaLayer(_width, _height);
			_metaLayer.alpha = 0;
			
			// video navigation
			_videoNavigation = new MediaPlayerVideoNavigation(_width);
			_videoNavigation.alpha = 0;
			
			// fullscreen button
			_fullscreenButton = new MediaPlayerFullscreenButton(this);
			_fullscreenButton.alpha = 0;
		}
		
		private function registerListeners():void
		{
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			
			_metaInfoTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleVideoNavigationTimerComplete);
		}
		
		private function registerVideoListeners(pyro:Pyro):void
		{
			pyro.addEventListener(PyroEvent.COMPLETED, handleVideoCompleted, false, 999);
			pyro.addEventListener(PyroEvent.METADATA_RECEIVED, handleVideoMetadataReceived);
		}
		
		private function unregisterVideoListeners(pyro:Pyro):void
		{
			pyro.removeEventListener(PyroEvent.COMPLETED, handleVideoCompleted);
			pyro.removeEventListener(PyroEvent.METADATA_RECEIVED, handleVideoMetadataReceived);
		}
		
		private function arrange():void
		{
			var width:Number = _fullscreenMode ? stage.stageWidth : _width;
			var height:Number = _fullscreenMode ? stage.stageHeight : _height;
			
			// background
			Picasso.clear(_background);
			Picasso.drawRectangle(_background, 0, 0, 0, 0, width, height);
			
			// content
			if(_currentMedia != null)
			{
				if(_currentMedia is Bitmap)
				{
					TransformationUtils.fitInto(_currentMedia, width, height, false, TransformationUtils.FIT_TYPE_ZOOM);
					TransformationUtils.center(_currentMedia, width * .5, height * .5);
				}
				
				if(_currentMedia is Pyro)
				{
					Pyro(_currentMedia).resize(width, height);
					
					Picasso.clear(_currentMedia);
					Picasso.drawRectangle(_currentMedia, 0, 1, 0, 0, _currentMedia.width, _currentMedia.height);
				}
			}
			
			// content mask
			Picasso.clear(_contentMask);
			Picasso.drawRectangle(_contentMask, 0, 1, 0, 0, width, height);
			
			// video navigation
			_videoNavigation.width = width;
			_videoNavigation.y = height - _videoNavigation.height;
			
			// full screen button
			_fullscreenButton.x = width - _fullscreenButton.width - 10;
			_fullscreenButton.y = 10;
			
			// meta layer
			arrangeMetaLayer();
		}
		
		private function arrangeMetaLayer():void
		{
			var width:Number = _fullscreenMode ? stage.stageWidth : _width;
			var height:Number = _fullscreenMode ? stage.stageHeight : _height;
			
			if(_currentMedia is Pyro) _metaLayer.resize(width, height - _videoNavigation.height);
			else _metaLayer.resize(width, height);
		}
		
		/* media management */
		public function showMedia(index:int, transition:Boolean = true):void
		{
			// cancellation
			if(index >= _media.length) return;
			if(index == _mediaCursor) return;
			
			// finish current
			if(_currentMedia != null)
			{
				// pyro
				if(_currentMedia is Pyro)
				{
					var currentPyro:Pyro = Pyro(_currentMedia);
					
					unregisterVideoListeners(currentPyro);
					currentPyro.stop();
					currentPyro.kill();
					
					_videoNavigation.player = null;
				}
			}
			
			// clear
			if(index < 0)
			{
				if(_currentMedia != null) _contentContainer.removeChild(_currentMedia);
				
				_currentMedia = null;
				_mediaCursor = -1;
				
				return;
			}
			
			// create
			var mediaData:MediaData = _media[index];
			var mediaDisplay:DisplayObject;
			
			switch(mediaData.type)
			{
				case MediaData.IMAGE:
					
					mediaDisplay = new Bitmap(mediaData.content, "auto", true);
					
					TransformationUtils.fitInto(mediaDisplay, _width, _height, false, TransformationUtils.FIT_TYPE_ZOOM);
					TransformationUtils.center(mediaDisplay, _width * .5, _height * .5);
					
					break;
				
				case MediaData.VIDEO:
					
					var pyro:Pyro = new Pyro(_width, _height, Pyro.STAGE_EVENTS_MECHANICS_ALL_OFF);
					pyro.smoothing = true;
					
					registerVideoListeners(pyro);
					
					Picasso.drawRectangle(pyro, 0, 1, 0, 0, _width, _height);
					_videoNavigation.player = pyro;
					
					pyro.play(mediaData.path);
					
					mediaDisplay = pyro;
					
					break;
			}
			
			// add
			_contentContainer.addChild(mediaDisplay);
			
			// intro
			if(transition)
			{
				mediaDisplay.alpha = 0;
				
				if(_currentMedia == null) TweenLite.to(mediaDisplay, .5, {alpha:1});
				else TweenLite.to(mediaDisplay, .5, {alpha:1, onComplete:_contentContainer.removeChild, onCompleteParams:[_currentMedia]});
			}
			else if(_currentMedia != null) _contentContainer.removeChild(_currentMedia);
			
			// set var
			_mediaCursor = index;
			_currentMedia = mediaDisplay;
			
			// set meta label & show
			_metaLayer.mediaData = mediaData;
			
			arrangeMetaLayer();
			showMetaInfo();
			
			_metaInfoTimer.reset();
			_metaInfoTimer.start();
			
			// dispatch
			dispatchEvent(new Event(MEDIA_CHANGED));
		}
		
		public function next():void
		{
			showMedia((_mediaCursor + 1) % _media.length);
		}
		
		public function previous():void
		{
			showMedia((_mediaCursor + _media.length - 1) % _media.length);
		}
		
		private function showMetaInfo():void
		{
			// cancellation
			if(_metaInfoVisible) return;
			
			// meta label
			if(_showMeta)
			{
				_container.addChild(_metaLayer);
				
				TweenLite.killTweensOf(_metaLayer);
				TweenLite.to(_metaLayer, .3, {alpha:1});
			}
			
			// video navigation
			if(_showControls)
			{
				if(_currentMedia is Pyro)
				{
					_container.addChild(_videoNavigation);
					
					TweenLite.killTweensOf(_videoNavigation);
					TweenLite.to(_videoNavigation, .3, {alpha:1});
				}
			}
			
			// fullscreen button
			if(_showControls)
			{
				if(_currentMedia is Pyro)
				{
					_container.addChild(_fullscreenButton);
					
					TweenLite.killTweensOf(_fullscreenButton);
					TweenLite.to(_fullscreenButton, .3, {alpha:1});
				}
			}
			
			// var
			_metaInfoVisible = true;
		}
		
		private function hideMetaInfo():void
		{
			// cancellation
			if(!_metaInfoVisible) return;
			
			// meta label
			if(_container.contains(_metaLayer))
			{
				TweenLite.killTweensOf(_metaLayer);
				TweenLite.to(_metaLayer, .3, {alpha:0, onComplete:_container.removeChild, onCompleteParams:[_metaLayer]});
			}
			
			// video navigation
			if(_container.contains(_videoNavigation))
			{
				TweenLite.killTweensOf(_videoNavigation);
				TweenLite.to(_videoNavigation, .3, {alpha:0, onComplete:_container.removeChild, onCompleteParams:[_videoNavigation]});
			}
			
			// fullscreen button
			if(_container.contains(_fullscreenButton))
			{
				TweenLite.killTweensOf(_fullscreenButton);
				TweenLite.to(_fullscreenButton, .3, {alpha:0, onComplete:_container.removeChild, onCompleteParams:[_fullscreenButton]});
			}
			
			// var
			_metaInfoVisible = false;
		}
		
		public function startFullscreenMode():void
		{
			// cancellation
			if(_fullscreenMode) return;
			if(stage == null) return;
			
			// set var
			_fullscreenMode = true;
			
			// do
			stage.addChild(_container);
			stage.addEventListener(Event.RESIZE, handleStageResize);
			
			arrange();
			
			// dispatch
			dispatchEvent(new Event(DISPLAY_FULLSCREEN));
		}
		
		public function stopFullscreenMode():void
		{
			// cancellation
			if(!_fullscreenMode) return;
			
			// set var
			_fullscreenMode = false;
			
			// do
			stage.removeEventListener(Event.RESIZE, handleStageResize);
			
			addChild(_container);
			arrange();
			
			// dispatch
			dispatchEvent(new Event(DISPLAY_NORMAL));
		}
		
		public function reset():void
		{
			showMedia(-1);
		}
		
		public function resize(width:Number, height:Number):void
		{
			_width = width;
			_height = height;
			
			if(!_fullscreenMode) arrange();
		}
		
		/* getter setter */
		public function get media():Vector.<MediaData>							{ return _media; }
		
		override public function get width():Number								{ return _width; }
		override public function set width(value:Number):void
		{
			resize(value, _height);
		}
		
		override public function get height():Number							{ return _height; }
		override public function set height(value:Number):void
		{
			resize(_width, value);
		}
		
		public function get enabled():Boolean									{ return _enabled; }
		public function set enabled(value:Boolean):void
		{
			if(value == _enabled) return;
			_enabled = value;
			
			if(value)
			{
				if(_currentMedia is Pyro) Pyro(_currentMedia).play();
			}
			else
			{
				if(_currentMedia is Pyro) Pyro(_currentMedia).stop();
			}
			
		}
		
		public function get aspectRatio():Number								{ return _width / _height; }
		public function get currentMediaIndex():int								{ return _mediaCursor; }
		
		public function get showControls():Boolean								{ return _showControls; }
		public function set showControls(value:Boolean):void					{ _showControls = value; }
		
		public function get showMeta():Boolean									{ return _showMeta; }
		public function set showMeta(value:Boolean):void						{ _showMeta = value; }
		
		public function get loop():Boolean										{ return _loop; }
		public function set loop(value:Boolean):void							{ _loop = value; }
		
		public function get fullscreenMode():Boolean							{ return _fullscreenMode; }
		public function set fullscreenMode(value:Boolean):void
		{
			if(value) startFullscreenMode();
			else stopFullscreenMode();
		}
		
		public function get videoMetaData():Object
		{
			if(_currentMedia is Pyro) return Pyro(_currentMedia).metadata;
			return null;
		}
		
		/* event handler */
		private function handleAddedToStage(e:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		
		private function handleRemovedFromStage(e:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_metaInfoTimer.reset();
			
			showMedia(-1);
		}
		
		private function handleMouseMove(e:MouseEvent):void
		{
			if(_background.hitTestPoint(e.stageX, e.stageY))
			{
				showMetaInfo();
				
				_metaInfoTimer.reset();
				if(_currentMedia is Pyro) _metaInfoTimer.start();
			}
			else
			{
				if(_metaInfoTimer.running)
				{
					_metaInfoTimer.stop();
					_metaInfoTimer.reset();
				}
				
				hideMetaInfo();
			}
		}
		
		private function handleVideoNavigationTimerComplete(e:TimerEvent):void
		{
			hideMetaInfo();
		}
		
		private function handleVideoCompleted(e:PyroEvent):void
		{
			// loop
			if(_loop)
			{
				var currentIndex:int = _mediaCursor;
				
				showMedia(-1, false);
				showMedia(currentIndex, false);
			}
			
			// dispatch
			dispatchEvent(new Event(VIDEO_COMPLETED));
		}
		
		private function handleVideoMetadataReceived(e:PyroEvent):void
		{
			// dispatch
			dispatchEvent(new Event(VIDEO_METADATA_RECEIVED));
		}
		
		private function handleStageResize(e:Event):void
		{
			arrange();
		}
	}
}