package de.pixelscape.display 
{
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.utils.MathUtils;
	import de.pixelscape.utils.TransformationUtils;

	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author tobias.friese
	 */
	public class ZoomBox extends Sprite 
	{
		/* variables */
		private var _bmp:BitmapData;
		
		private var _maxWidth:Number;
		private var _maxHeight:Number;
		
		/* architecture */
		private var _bitmap:Bitmap;
		private var _mask:Shape;
		private var _hitArea:Sprite;
		
		/* constants */
		private static const CONSTRAIN:Function = MathUtils.constrain;
		
		public function ZoomBox(bmp:BitmapData, maxWidth:Number, maxHeight:Number)
		{
			// vars
			this._bmp = bmp;
			this._maxWidth = maxWidth;
			this._maxHeight = maxHeight;
			
			// build
			this.build();
			
			// register eventlisteners
			this.registerEventListeners();
		}

		private function build():void
		{
			// bitmap
			this._bitmap = new Bitmap(this._bmp);
			this._bitmap.smoothing = true;
			TransformationUtils.fitInto(this._bitmap, this._maxWidth, this._maxHeight, true);
			
			this.addChild(this._bitmap);
			
			// mask
			this._mask = new Shape();
			Picasso.drawRectangle(this._mask, 0, 1, 0, 0, this._bitmap.width, this._bitmap.height);
			this._bitmap.mask = this._mask;
			
			this.addChild(this._mask);
			
			// hit area
			this._hitArea = new Sprite();
			Picasso.drawRectangle(this._hitArea, 0, 0, 0, 0, this._bitmap.width, this._bitmap.height);
			
			this.addChild(this._hitArea);
		}

		private function registerEventListeners():void
		{
			this._hitArea.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouseDown);
		}
		
		/* event handler */
		private function handleMouseDown(e:MouseEvent):void
		{
			TweenLite.to(this._bitmap, .3, {scaleX:1, scaleY:1, ease:Cubic.easeOut});
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp);
			this.stage.addEventListener(Event.ENTER_FRAME, this.handleEnterFrame);
		}
		
		private function handleEnterFrame(e:Event):void
		{
			var diffX:Number = ((this._mask.width - this._bitmap.width) * CONSTRAIN((this.mouseX / this._mask.width), 0, 1)) - this._bitmap.x;
			var diffY:Number = ((this._mask.height - this._bitmap.height) * CONSTRAIN((this.mouseY / this._mask.height), 0, 1)) - this._bitmap.y;

			this._bitmap.x += diffX * .5;
			this._bitmap.y += diffY * .5;
		}

		private function handleMouseUp(e:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleMouseUp);
			this.stage.removeEventListener(Event.ENTER_FRAME, this.handleEnterFrame);
			
			TweenLite.to(this._bitmap, .3, {width:this._mask.width, height:this._mask.height, x:0, y:0, ease:Cubic.easeOut});
		}
	}
}
