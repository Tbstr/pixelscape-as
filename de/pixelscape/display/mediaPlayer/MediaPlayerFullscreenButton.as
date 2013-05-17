package de.pixelscape.display.mediaPlayer
{
	import com.greensock.TweenLite;
	
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.ui.button.Button;
	import de.pixelscape.ui.button.ButtonEvent;
	import de.pixelscape.utils.TransformationUtils;
	
	import flash.display.Shape;
	import flash.events.Event;
	
	public class MediaPlayerFullscreenButton extends Button
	{
		/* variables */
		private var _mediaPlayer:MediaPlayer;
		
		/* architecture */
		private var _backgorund:Shape;
		private var _iconNormal:Shape;
		private var _iconFull:Shape;
		
		public function MediaPlayerFullscreenButton(mediaPlayer:MediaPlayer)
		{
			// super
			super();
			
			// vars
			_mediaPlayer = mediaPlayer;
			
			// build
			build();
			
			// register listeners
			registerListeners();
		}
		
		private function build():void
		{
			// background
			_backgorund = new Shape();
			Picasso.drawRoundedRectangle(_backgorund, 0, .8, 0, 0, 30, 30, 3);
			
			addChild(_backgorund);
			
			// icons
			_iconNormal = new Shape();
			_iconNormal.cacheAsBitmap = true;
			
			Picasso.drawRectangle(_iconNormal, null, 1, .5, .5, 23, 19, [1, 0xFFFFFF, 1]);
			Picasso.drawCustomShape(_iconNormal, 0xFFFFFF, 1, 3, 3, [2, 5, 0, 2, 0, 5]);
			Picasso.drawCustomShape(_iconNormal, 0xFFFFFF, 1, 16, 3, [2, 5, 0, 2, 5, 5]);
			Picasso.drawCustomShape(_iconNormal, 0xFFFFFF, 1, 16, 12, [1, 5, 0, 2, 5, 5, 2, 0, 5]);
			Picasso.drawCustomShape(_iconNormal, 0xFFFFFF, 1, 3, 12, [2, 5, 5, 2, 0, 5]);
			
			TransformationUtils.center(_iconNormal, _backgorund.width * .5, _backgorund.height * .5);
			
			addChild(_iconNormal);
			
			_iconFull = new Shape();
			_iconFull.cacheAsBitmap = true;
			_iconFull.alpha = 0;
			
			Picasso.drawCustomShape(_iconFull, 0xFFFFFF, 1, 0, 0, [1, 5, 5, 2, 0, 5, 2, 5, 0]);
			Picasso.drawCustomShape(_iconFull, 0xFFFFFF, 1, 24, 0, [1, 0, 5, 2, -5, 5, 2, -5, 0]);
			Picasso.drawCustomShape(_iconFull, 0xFFFFFF, 1, 24, 20, [1, -5, 0, 2, -5, -5, 2, 0, -5]);
			Picasso.drawCustomShape(_iconFull, 0xFFFFFF, 1, 0, 20, [1, 0, -5, 2, 5, -5, 2, 5, 0]);
			Picasso.drawRectangle(_iconFull, null, 1, 7.5, 7.5, 9, 5, [1, 0xFFFFFF, 1]);
			
			TransformationUtils.center(_iconFull, _backgorund.width * .5, _backgorund.height * .5);
			
			addChild(_iconFull);
		}
		
		private function registerListeners():void
		{
			addEventListener(ButtonEvent.MOUSE_UP, handleMouseUp);
			
			_mediaPlayer.addEventListener(MediaPlayer.DISPLAY_FULLSCREEN, handleMediaPlayerFullscreen);
			_mediaPlayer.addEventListener(MediaPlayer.DISPLAY_NORMAL, handleMediaPlayerNormalscreen);
		}
		
		/* overrides */
		override protected function setEnabled():void
		{
		}
		
		override protected function setDisabled():void
		{
		}
		
		override protected function setHover():void
		{
		}
		
		override protected function unsetHover():void
		{
		}
		
		override protected function setHighlight():void
		{
			TweenLite.to(_iconNormal, .3, {alpha:0});
			TweenLite.to(_iconFull, .3, {alpha:1});
		}
		
		override protected function unsetHighlight():void
		{
			TweenLite.to(_iconNormal, .3, {alpha:1});
			TweenLite.to(_iconFull, .3, {alpha:0});
		}
		
		/* event handler */
		private function handleMouseUp(e:ButtonEvent):void
		{
			_mediaPlayer.fullscreenMode = !_mediaPlayer.fullscreenMode;
		}
		
		private function handleMediaPlayerFullscreen(e:Event):void
		{
			highlight = true;
		}
		
		private function handleMediaPlayerNormalscreen(e:Event):void
		{
			highlight = false;
		}
	}
}