package de.pixelscape.display.mediaPlayer
{
	import ca.turbulent.media.Pyro;
	import ca.turbulent.media.events.PyroEvent;
	
	import com.greensock.TweenLite;
	
	import de.pixelscape.assets.symbols.SymbolsManager;
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.ui.button.Button;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MediaPlayerPlayPauseButton extends Button
	{
		/* variables */
		private var _player:Pyro;
		
		/* architecture */
		private var _iconPlay:Shape;
		private var _iconPause:Shape;
		
		public function MediaPlayerPlayPauseButton(player:Pyro = null, id:String = null)
		{
			// super
			super(id);
			
			// vars
			_player = player;
			
			// build
			build();
			
			// register listeners
			this.addEventListener(MouseEvent.CLICK, handleClicked);
			if(player != null) registerPlayerListeners(player);
			
			// init
			getStatus();
		}
		
		private function build():void
		{
			// icons
			_iconPlay = new Shape();
			Picasso.drawRectangle(_iconPlay, 0, 0, 0, 0, 30, 20);
			Picasso.drawCustomShape(_iconPlay, 0xFFFFFF, 1, 10, 5, [1, 0, 0, 2, 10, 5, 2, 0, 10]);
			
			addChild(_iconPlay);
			
			_iconPause = new Shape();
			
			Picasso.drawRectangle(_iconPause, 0, 0, 0, 0, 30, 20);
			Picasso.drawRectangle(_iconPause, 0xFFFFFF, 1, 10, 5, 4, 10);
			Picasso.drawRectangle(_iconPause, 0xFFFFFF, 1, 16, 5, 4, 10);
			
			addChild(_iconPause);
		}
		
		private function registerPlayerListeners(player:Pyro):void
		{
			player.addEventListener(PyroEvent.PAUSED, handlePlayerStatusChanged);
			player.addEventListener(PyroEvent.UNPAUSED, handlePlayerStatusChanged);
			player.addEventListener(PyroEvent.STARTED, handlePlayerStatusChanged);
			player.addEventListener(PyroEvent.STOPPED, handlePlayerStatusChanged);
			player.addEventListener(PyroEvent.COMPLETED, handlePlayerCompleted);
		}
		
		private function unregisterPlayerListeners(player:Pyro):void
		{
			player.removeEventListener(PyroEvent.PAUSED, handlePlayerStatusChanged);
			player.removeEventListener(PyroEvent.UNPAUSED, handlePlayerStatusChanged);
			player.removeEventListener(PyroEvent.STARTED, handlePlayerStatusChanged);
			player.removeEventListener(PyroEvent.STOPPED, handlePlayerStatusChanged);
			player.removeEventListener(PyroEvent.COMPLETED, handlePlayerCompleted);
		}
		
		public function getStatus():void
		{
			if(_player == null) return;
			
			if(_player.status == Pyro.STATUS_PLAYING)
			{
				TweenLite.to(_iconPlay, .3, {alpha:0});
				TweenLite.to(_iconPause, .3, {alpha:1});
			}
			else
			{
				TweenLite.to(_iconPlay, .3, {alpha:1});
				TweenLite.to(_iconPause, .3, {alpha:0});
			}
		}
		
		/* getter setter */
		public function get player():Pyro							{ return _player; }
		public function set player(value:Pyro):void
		{
			if(_player != null) unregisterPlayerListeners(_player);
			
			_player = value;
			if(value != null) registerPlayerListeners(value);
			
			getStatus();
		}
		
		/* event handler */
		private function handleClicked(e:MouseEvent):void
		{
			switch(_player.status)
			{
				case Pyro.STATUS_READY:
				case Pyro.STATUS_STOPPED:
				case Pyro.STATUS_COMPLETED:
					_player.seek(0);
					_player.play();
					break;
				
				case Pyro.STATUS_PLAYING:
				case Pyro.STATUS_PAUSED:
					_player.togglePause();
					break;
			}
		}
		
		private function handlePlayerStatusChanged(e:Event):void
		{
			getStatus();
		}
		
		private function handlePlayerCompleted(e:PyroEvent):void
		{
			_player.stop();
			getStatus();
		}
	}
}