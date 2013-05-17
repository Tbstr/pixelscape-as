package de.pixelscape.display.mediaPlayer
{
	import ca.turbulent.media.Pyro;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.utils.MathUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MediaPlayerVideoNavigation extends Sprite
	{
		/* variables */
		private var _width:Number;
		private var _player:Pyro;
		private var _barWidth:Number;
		private var _volumePreMute:Number;
		
		/* architecture */
		private var _playPauseButton:MediaPlayerPlayPauseButton;
		private var _bar:Sprite;
		
		private var _iconSound:Sprite;
		private var _soundBar:Sprite;
		
		/* constants */
		private static const HEIGHT:Number							= 24;
		private static const ELEMENT_OFFSET:Number					= 10;
		
		private static const BAR_STENGTH:Number						= 5;
		private static const BAR_OVERFLOW:Number					= 8;
		
		private static const SOUNDBAR_WIDTH:Number					= 50;
		
		public function MediaPlayerVideoNavigation(width:Number, player:Pyro = null)
		{
			// vars
			_width = width;
			
			// build & arrange
			build();
			arrange();
			
			// register listeners
			registerListeners();
			
			// set player
			this.player = player;
		}
		
		private function build():void
		{
			// play pause button
			_playPauseButton = new MediaPlayerPlayPauseButton(_player);
			_playPauseButton.x = ELEMENT_OFFSET;
			_playPauseButton.y = (HEIGHT - _playPauseButton.height) * .5;
			addChild(_playPauseButton);
			
			// bar
			_bar = new Sprite();
			_bar.x = _playPauseButton.x + _playPauseButton.width + ELEMENT_OFFSET;
			_bar.y = (HEIGHT - BAR_STENGTH) * .5;
			_bar.buttonMode = true;
			
			addChild(_bar);
			
			// icon sound
			_iconSound = new Sprite();
			Picasso.drawCustomShape(_iconSound, 0xFFFFFF, 1, 0, 0, [1, 0, 2, 2, 3, 2, 2, 8, 0, 2, 8, 10, 2, 3, 8, 2, 0, 8]);
			
			_iconSound.buttonMode = true;
			_iconSound.y = (HEIGHT - _iconSound.height) * .5;
			
			addChild(_iconSound);
			
			// sound bar
			_soundBar = new Sprite();
			_soundBar.y = _bar.y;
			_soundBar.buttonMode = true;
			
			addChild(_soundBar);
		}
		
		private function registerListeners():void
		{
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			
			_bar.addEventListener(MouseEvent.CLICK, handleBarClicked);
			
			_iconSound.addEventListener(MouseEvent.MOUSE_UP, handleIconSoundMouseUp);
			_soundBar.addEventListener(MouseEvent.MOUSE_DOWN, handleSoundBarMouseDown);
		}
		
		private function arrange():void
		{
			// background
			Picasso.clear(this);
			Picasso.drawRectangle(this, 0xFFFFFF, .4, 0, 0, _width, 1);
			Picasso.drawRectangle(this, 0, .6, 0, 1, _width, HEIGHT - 1);
			
			// sound bar
			_soundBar.x = _width - SOUNDBAR_WIDTH - ELEMENT_OFFSET * 2;
			redrawSoundBar();
			
			// sound icon
			_iconSound.x = _soundBar.x - _iconSound.width - ELEMENT_OFFSET;
			
			// bar
			_barWidth = _iconSound.x - _playPauseButton.width - ELEMENT_OFFSET * 4;
			redrawProgressBars();
		}
		
		private function registerPlayerListeners(player:Pyro):void
		{
			if(stage != null) addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function unregisterPlayerListeners(player:Pyro):void
		{
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function redrawProgressBars():void
		{
			Picasso.clear(_bar);
			
			if(_player != null) 
			{
				Picasso.drawRectangle(_bar, 0, 0, 0, -BAR_OVERFLOW, _barWidth * _player.loadRatio, BAR_STENGTH + BAR_OVERFLOW * 2);
				Picasso.drawRectangle(_bar, 0xFFFFFF, .5, 0, 0, _barWidth * _player.loadRatio, BAR_STENGTH);
				Picasso.drawRectangle(_bar, 0xFFFFFF, 1, 0, 0, _barWidth * _player.progressRatio , BAR_STENGTH);
			}
		}
		
		private function redrawSoundBar():void
		{
			Picasso.clear(_soundBar);
			
			Picasso.drawRectangle(_soundBar, 0, 0, 0, -BAR_OVERFLOW, SOUNDBAR_WIDTH, BAR_STENGTH + BAR_OVERFLOW * 2);
			Picasso.drawRectangle(_soundBar, 0xFFFFFF, .5, 0, 0, SOUNDBAR_WIDTH, BAR_STENGTH);
			if(_player != null) Picasso.drawRectangle(_soundBar, 0xFFFFFF, 1, 0, 0, SOUNDBAR_WIDTH * _player.volume , BAR_STENGTH);
		}
		
		/* getter setter */
		public function get player():Pyro							{ return _player; }
		public function set player(value:Pyro):void
		{
			if(_player != null) unregisterPlayerListeners(_player);

			_player = value;
			_playPauseButton.player = value;
			
			if(value != null)
			{
				registerPlayerListeners(value);
				
				redrawProgressBars();
				redrawSoundBar();
			}
		}
		
		override public function get width():Number					{ return _width; }
		override public function set width(value:Number):void
		{
			_width = value;
			arrange();
		}
		
		override public function get height():Number				{ return HEIGHT; }
		override public function set height(value:Number):void
		{
			// nothin
		}
		
		/* event handler */
		private function handleAddedToStage(e:Event):void
		{
			if(_player != null) addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function handleEnterFrame(e:Event):void
		{
			redrawProgressBars();
		}
		
		private function handleBarClicked(e:MouseEvent):void
		{
			if(_player != null)
			{
				_player.seek(_player.duration * (_bar.mouseX / _barWidth));
			}
		}
		
		private function handleIconSoundMouseUp(e:Event):void
		{
			if(_player.volume == 0)
			{
				TweenLite.to(_player, .5, {volume:_volumePreMute, ease:Cubic.easeOut, onUpdate:redrawSoundBar});
			}
			else
			{
				_volumePreMute = _player.volume;
				
				TweenLite.to(_player, .5, {volume:0, ease:Cubic.easeOut, onUpdate:redrawSoundBar});
			}
		}
		
		private function handleSoundBarMouseDown(e:MouseEvent):void
		{
			if(_player != null)
			{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, handleSoundMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, handleSoundMouseUp);
				
				handleSoundMouseMove();
			}
		}
		
		private function handleSoundMouseMove(e:MouseEvent = null):void
		{
			if(_player != null)
			{
				_player.volume = MathUtils.constrain(_soundBar.mouseX / SOUNDBAR_WIDTH, 0, 1);
				redrawSoundBar();
			}
		}
		
		private function handleSoundMouseUp(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleSoundMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleSoundMouseUp);
		}
	}
}