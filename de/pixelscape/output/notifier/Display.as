package de.pixelscape.output.notifier 
{	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.utils.TransformationUtils;

	import com.greensock.TweenLite;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;

	/**	 * @author Tobias Friese	 */	public class Display extends Sprite 
	{		private var _path:String;		private var _type:String;
		private var _bounds:Rectangle;
		
		private var _margins:Array = new Array(5, 5, 5, 5);
		
		private var _loader:Loader;

		/* architecture */
		
			// image
			private var _image:Bitmap;
			
			// sound
			private var _sound:Sound;
			private var _soundChannel:SoundChannel;

			private var _playSign:Shape;			private var _pauseSign:Shape;

		/* constants */
		public static const TYPE_IMAGE:String = "typeImage";		public static const TYPE_VIDEO:String = "typeVideo";		public static const TYPE_SOUND:String = "typeSound";
		
		public static const READY:String = "ready";
		public function Display(path:String, type:String, bounds:Rectangle = null)
		{
			this._path = path;
			this._type = type;
			this._bounds = bounds;
		}
		
		public function init():void
		{
			 this.build();
		}
		
		private function build():void
		{
			switch(this._type)
			{
				case TYPE_IMAGE:
					this.loadImage();
					break;
					
				case TYPE_SOUND:
					this.loadSound();
					break;
			}
		}
		
		private function loadImage():void
		{
			this._loader = new Loader();
			this._loader.contentLoaderInfo.addEventListener(Event.INIT, this.handleImageLoadInit);			this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.handleIOError);
			this._loader.load(new URLRequest(this._path));
		}
		
		private function buildImage():void
		{
			if(this._image != null)
			{
				if(this._bounds != null)
				{
					this._image.smoothing = true;
					TransformationUtils.fitInto(this._image, this._bounds.width - this._margins[1] - this._margins[3], this._bounds.height - this._margins[0] - this._margins[2], true);
				}
				
				this._image.x = this._margins[3];				this._image.y = this._margins[0];
				
				this.drawBackground(this._image.width + this._margins[1] + this._margins[3], this._image.height + this._margins[0] + this._margins[2]);
				this.addChild(this._image);
				
				this.dispatchDisplayReady();
			}
			else
			{
				this.buildBroken();
			}
		}
		
		private function loadSound():void
		{
			this._sound = new Sound();
			this._sound.addEventListener(IOErrorEvent.IO_ERROR, this.handleIOError);
			this._sound.addEventListener(Event.OPEN, handleSoundOpen);
			this._sound.load(new URLRequest(this._path));
		}
		
		private function buildSound():void
		{
			// background
			this.drawBackground(30, 30);
			
			// play sign
			this._playSign = new Shape();
			
			with(this._playSign.graphics)
			{
				beginFill(0xFFFFFF, 1);
				lineTo(12, 7);				lineTo(0, 14);
				lineTo(0, 0);
				endFill();
			}
			
			TransformationUtils.center(this._playSign, 15, 15);
			this._playSign.x += 1;
			
			this.addChild(this._playSign);
			
			// pause sign
			this._pauseSign = new Shape();
			this._pauseSign.alpha = 0;
			
			Picasso.drawRectangle(this._pauseSign, 0XFFFFFF, 1, 0, 0, 4, 12);			Picasso.drawRectangle(this._pauseSign, 0XFFFFFF, 1, 7, 0, 4, 12);
			
			TransformationUtils.center(this._pauseSign, 15, 15);
			this.addChild(this._pauseSign);
			
			// sound progress
//			this._soundProgress = new Shape();
//			this._soundProgress.rotation = -90;//			this._soundProgress.x = 25;//			this._soundProgress.y = 7;
//			
//			Picasso.drawArc(this._soundProgress, 2, 0xFFFFFF, 1, 0, 0, 18, 18, 0, 350);
//			
//			this.addChild(this._soundProgress);
			
			// add listener
			this.addEventListener(MouseEvent.CLICK, this.handleClickSound);
			
			// dispatch ready
			this.dispatchDisplayReady();
		}
		
		private function buildBroken():void
		{
			// create
			var cross:Shape = new Shape();
			cross.x = this._margins[3];			cross.y = this._margins[0];
			
			Picasso.drawLine(cross, 3, 0xBB0000, 1, 0, 0, 10, 10);
			Picasso.drawLine(cross, 3, 0xBB0000, 1, 10, 0, 0, 10);
			
			this.drawBackground(10 + this._margins[1] + this._margins[3], 10 + this._margins[0] + this._margins[2]);
			this.addChild(cross);
			
			this.dispatchDisplayReady();
		}
		
		private function toggleSound():void
		{
			if(this._soundChannel == null)
			{
				this._soundChannel = this._sound.play();
				
				//Tweener.removeTweens(this._playSign, "alpha");				//Tweener.removeTweens(this._pauseSign, "alpha");
				
				TweenLite.to(this._playSign, .3, {alpha:0});				TweenLite.to(this._pauseSign, .3, {alpha:1});
			}
			else
			{
				this._soundChannel.stop();
				this._soundChannel = null;
				
				//Tweener.removeTweens(this._playSign, "alpha");
				//Tweener.removeTweens(this._pauseSign, "alpha");
				
				TweenLite.to(this._playSign, .3, {alpha:1});
				TweenLite.to(this._pauseSign, .3, {alpha:0});
			}
		}
		
		private function drawBackground(width:Number, height:Number):void
		{
			this.graphics.clear();
			Picasso.drawRoundedRectangle(this, 0, .8, 0, 0, width, height, 3);
		}
		
		private function dispatchDisplayReady():void
		{
			this.dispatchEvent(new Event(READY));
		}
		
		public function finalize():void
		{
			// kill loader
			if(this._loader != null)
			{
				if(this._loader.contentLoaderInfo.bytesLoaded != this._loader.contentLoaderInfo.bytesTotal)
				{
					this._loader.close();
					this._loader = null;
				}
			}
			
			// kill sound
			if(this._soundChannel != null)
			{
				this._soundChannel.stop();
				this._soundChannel = null;
				
				try 
				{
					this._sound.close();
				}
				catch(e:Error)
				{
					// not'n
				}
				
				this._sound = null;
			}
		}
		
		/* event handler */
		private function handleIOError(e:IOErrorEvent):void
		{
			if(this._loader != null) this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.handleIOError);			if(this._sound != null) this._sound.removeEventListener(IOErrorEvent.IO_ERROR, this.handleIOError);
			
			this.buildBroken();
		}

		private function handleImageLoadInit(e:Event):void
		{
			this._loader.contentLoaderInfo.removeEventListener(Event.INIT, this.handleImageLoadInit);
			
			this._image = this._loader.content as Bitmap;
			this.buildImage();
		}
		
		private function handleSoundOpen(e:Event):void
		{
			this._sound.removeEventListener(Event.OPEN, this.handleSoundOpen);
			
			this.buildSound();
		}

		private function handleClickSound(e:MouseEvent):void
		{
			this.toggleSound();
		}
	}}