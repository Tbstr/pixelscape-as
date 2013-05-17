package de.pixelscape.display.blitting
{
	import de.pixelscape.graphics.PBitmap;
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.output.notifier.Notifier;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BitmapMovieClip extends Bitmap
	{
		/* variables */
		private var _frames:Vector.<BitmapData>			= new Vector.<BitmapData>();
		private var _framePositions:Vector.<Point>		= new Vector.<Point>();
		
		private var _canvas:BitmapData;
		private var _bounds:Rectangle;
		
		private var _loop:Boolean						= false;
		
		private var _currentFrame:int					= 0;
		private var _playing:Boolean					= false;
		
		private var _initialized:Boolean				= false;
		
		/* constructor */
		public function BitmapMovieClip(pixelSnapping:String = 'auto', smoothing:Boolean = false)
		{
			// super
			super(null, pixelSnapping,smoothing);
		}
		
		/* initialization */
		public function addFrame(bitmapData:BitmapData, offset:Point):void
		{
			_frames.push(bitmapData);
			_framePositions.push(offset);
		}
		
		public function init():void
		{
			// calculate canvas bounds
			var bounds:Rectangle = new Rectangle(_framePositions[0].x, _framePositions[0].y, _frames[0].width, _frames[0].height);
			
			var bitmapData:BitmapData;
			var framePosition:Point;
			
			var i:int = _frames.length;
			while(--i > 0)
			{
				// get data
				bitmapData = _frames[i];
				framePosition = _framePositions[i];
				
				// match
				bounds.left = Math.min(bounds.left, framePosition.x);
				bounds.top = Math.min(bounds.top, framePosition.y);
				
				bounds.right = Math.max(bounds.right, framePosition.x + bitmapData.width);
				bounds.bottom = Math.max(bounds.bottom, framePosition.y+ bitmapData.height);
			}
			
			i = _frames.length;
			while(--i > -1)
			{
				framePosition = _framePositions[i];
				
				framePosition.x -= bounds.x;
				framePosition.y -= bounds.y;
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
			_canvas.copyPixels(_frames[index], _frames[index].rect, _framePositions[index]);
		}
		
		public function play(fromFrame:int = -1):void
		{
			// cancellation
			if(_playing) return;
			if(!_loop && _currentFrame >= _frames.length) return;
			
			// seek
			if(fromFrame != -1) seek(fromFrame);
			
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
		
		public function seek(frame:int):void
		{
			// cancellation
			if(frame < 0) return;
			if(frame >= _frames.length) return;
			
			_currentFrame = frame;
			drawFrame(frame);
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
	}
}