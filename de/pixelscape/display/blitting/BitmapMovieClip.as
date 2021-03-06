package de.pixelscape.display.blitting
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BitmapMovieClip extends Bitmap
	{
		/* variables */
		private var _frames:Vector.<BlitterSnapshot>			= new Vector.<BlitterSnapshot>();
		
		private var _canvas:BitmapData;
		private var _bounds:Rectangle;
		
		private var _loop:Boolean								= false;
		
		private var _currentFrame:int							= 0;
		private var _playing:Boolean							= false;
		
		private var _initialized:Boolean						= false;
		
		/* constructor */
		public function BitmapMovieClip(pixelSnapping:String = 'auto', smoothing:Boolean = false)
		{
			// super
			super(null, pixelSnapping, smoothing);
		}
		
		/* initialization */
		public function addFrame(snapshot:BlitterSnapshot):void
		{
			_frames.push(snapshot);
		}
		
		public function init():void
		{
			// calculate canvas bounds
			var firstFrame:BlitterSnapshot = _frames[0];
			var bounds:Rectangle = new Rectangle(firstFrame.offset.x, firstFrame.offset.y, firstFrame.bitmapData.width, firstFrame.bitmapData.height);
			
			var bitmapData:BitmapData;
			var framePosition:Point;
			
			var i:int = _frames.length;
			while(--i != 0)
			{
				// get data
				bitmapData = _frames[i].bitmapData;
				framePosition = _frames[i].offset;
				
				// match
				bounds.left = Math.min(bounds.left, framePosition.x);
				bounds.top = Math.min(bounds.top, framePosition.y);
				
				bounds.right = Math.max(bounds.right, framePosition.x + bitmapData.width);
				bounds.bottom = Math.max(bounds.bottom, framePosition.y+ bitmapData.height);
			}
			
			_bounds = bounds;
			
			// apply offset
			x += bounds.x;
			y += bounds.y;
			
			// canvas
			_canvas = new BitmapData(bounds.width, bounds.height, true, 0x00000000);
			this.bitmapData = _canvas;
			
			// draw first frame
			drawFrame(0);
			
			// var
			_initialized = true;
		}
		
		private function drawFrame(index:int):void
		{
			// clear
			_canvas.fillRect(_canvas.rect, 0x00000000);
			
			// draw frame
			var frame:BlitterSnapshot = _frames[index];
			
			var offset:Point = frame.offset.clone();
			offset.offset(-_bounds.x, -_bounds.y);
			
			_canvas.copyPixels(frame.bitmapData, frame.bitmapData.rect, offset);
		}
		
		public function play(fromFrame:* = null):void
		{
			// cancellation
			if(_playing) return;
			if(!_loop && _currentFrame >= _frames.length) return;
			
			// seek
			if(fromFrame != null) seek(fromFrame);
			
			// play
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			// set var
			_playing = true;
		}
		
		public function stop():void
		{
			// cancellation
			if(!_playing) return;
			
			// stop
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			// set var
			_playing = false;
		}
		
		public function seek(frame:*):void
		{
			// numeric
			if(frame is int)
			{
				// cancellation
				if(frame < 0) return;
				if(frame >= _frames.length) return;
				
				_currentFrame = frame;
				drawFrame(frame);
				
				return;
			}
			
			// frame label
			if(frame is String)
			{
				var i:int = _frames.length;
				while(--i != -1)
				{
					if(_frames[i].label == frame)
					{
						_currentFrame = i;
						drawFrame(i);
						
						return;
					}
				}
			}
		}
		
		/* getter setter */
		override public function get x():Number			{ return super.x - _bounds.x }
		override public function set x(value:Number):void
		{
			super.x = value + _bounds.x;
		}
		
		override public function get y():Number			{ return super.y - _bounds.y }
		override public function set y(value:Number):void
		{
			super.y = value + _bounds.y;
		}
		
		public function get loop():Boolean				{ return _loop; }
		public function set loop(value:Boolean):void	{ _loop = value; }
		
		public function get numFrames():int				{ return _frames.length; }
		
		/* event handler */
		private function handleEnterFrame(e:Event):void
		{
			if(_loop)
			{
				_currentFrame = (_currentFrame + 1) % _frames.length;
				drawFrame(_currentFrame);
			}
			else
			{
				_currentFrame++;
				drawFrame(_currentFrame);
				
				if(_currentFrame == _frames.length - 1)
				{
					// stop
					stop();
					
					// dispatch
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		
		/* finalization */
		public function finalize():void
		{
			
		}
		
		/* clone */
		public function clone():BitmapMovieClip
		{
			var clone:BitmapMovieClip = new BitmapMovieClip(pixelSnapping, smoothing);
			
			for each(var frame:BlitterSnapshot in _frames) clone.addFrame(frame);
			clone.init();
			
			clone.x = x;
			clone.y = y;
			
			clone.scaleX = scaleX;
			clone.scaleY = scaleY;
			
			clone.loop = loop;
			
			clone.seek(_currentFrame);
			if(_playing) clone.play();
			
			// return
			return clone;
		}
	}
}