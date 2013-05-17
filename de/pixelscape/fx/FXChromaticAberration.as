package de.pixelscape.fx 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/**
	 * @author Sickdog
	 */
	public class FXChromaticAberration extends Sprite 
	{
		/* variables */
		private var _displayObject:DisplayObject;
		
		private var _redX:Number;
		private var _redY:Number;
		
		private var _greenX:Number;
		private var _greenY:Number;
		
		private var _blueX:Number;
		private var _blueY:Number;
		
		private var _blur:Number;
		
		private var _overlayDisplayObject:Boolean;
		
		public function FXChromaticAberration(displayObject:DisplayObject, redX:Number = 0, redY:Number = 0, greenX:Number = 0, greenY:Number = 0, blueX:Number = 0, blueY:Number = 0, blur:Number = 0, overlayDisplayObject:Boolean = false)
		{
			// vars
			_displayObject = displayObject;
			
			_redX = redX;
			_redY = redY;
			_greenX = greenX;
			_greenY = greenY;
			_blueX = blueX;
			_blueY = blueY;
			
			_blur = blur;
			
			_overlayDisplayObject = overlayDisplayObject;
			
			// settings
			cacheAsBitmap = true;
		}
		
		public function update():void
		{
			// cancellation
			if(_displayObject.width == 0) return;
			if(_displayObject.height == 0) return;
			
			// clear
			while(numChildren > 0) removeChildAt(0);
			
			// generate
			var rgb:Array = createRGBLayers(_displayObject);
			
			var red:Bitmap = rgb[0];			var green:Bitmap = rgb[1];			var blue:Bitmap = rgb[2];
			
			// position
			red.x += redX;
			red.y += redY;
			
			green.x += greenX;
			green.y += greenY;
			
			blue.x += blueX;
			blue.y += blueY;
			
			// blur
			if(_blur != 0)
			{
				var blurFilter:BlurFilter = new BlurFilter(_blur, _blur, 3);
				
				red.filters = new Array(blurFilter);
				green.filters = new Array(blurFilter);
				blue.filters = new Array(blurFilter);
			}
			
			// add
			addChild(red);
			addChild(green);
			addChild(blue);
			
			if(_overlayDisplayObject) addChild(_displayObject);
		}
		
		private function createRGBLayers(target:DisplayObject):Array 
		{
			var bounds:Rectangle = target.getBounds(target);
			
			// red
			var red:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x000000000);
			red.draw(target, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y), new ColorTransform(1, 0, 0));
			
			var bmpRed:Bitmap = new Bitmap(red);
			bmpRed.x = bounds.x;
			bmpRed.y = bounds.y;
			bmpRed.blendMode = BlendMode.ADD;
			
			// green
			var green:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x000000000);
			green.draw(target, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y), new ColorTransform(0, 1, 0));
			
			var bmpGreen:Bitmap = new Bitmap(green);
			bmpGreen.x = bounds.x;
			bmpGreen.y = bounds.y;
			bmpGreen.blendMode = BlendMode.ADD;
			
			// blue
			var blue:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0x000000000);
			blue.draw(target, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y), new ColorTransform(0, 0, 1));
			
			var bmpBlue:Bitmap = new Bitmap(blue);
			bmpBlue.x = bounds.x;
			bmpBlue.y = bounds.y;
			bmpBlue.blendMode = BlendMode.ADD;
			
			return new Array(bmpRed, bmpGreen, bmpBlue);
		}
		
		/* getter setter */
		public function get displayObject():DisplayObject		{ return _displayObject; }
		
		public function get redX():Number						{ return _redX; }
		public function set redX(value:Number):void				{ _redX = value; }
		
		public function get redY():Number						{ return _redY; }
		public function set redY(value:Number):void				{ _redY = value; }
		
		public function get greenX():Number						{ return _greenX; }
		public function set greenX(value:Number):void			{ _greenX = value; }
		
		public function get greenY():Number						{ return _greenY; }
		public function set greenY(value:Number):void			{ _greenY = value; }
		
		public function get blueX():Number						{ return _blueX; }
		public function set blueX(value:Number):void			{ _blueX = value; }
		
		public function get blueY():Number						{ return _blueY; }
		public function set blueY(value:Number):void			{ _blueY = value; }
		
		/* finalization */
		public function finalize():void
		{
			this._displayObject = null;
		}
	}
}
