package de.pixelscape.fx 
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Ease;
	import com.greensock.easing.Expo;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import de.pixelscape.graphics.Picasso;

	/**
	 * @author Sickdog
	 */
	public class FXScanline extends Sprite
	{
		/* variables */
		private var _displayObject:DisplayObject;
		private var _bounds:Rectangle;
		
		private var _duration:Number		= 1;
		private var _ease:Ease				= Expo.easeInOut;
		
		/* architecture */
		private var _mask:Shape;		private var _line:Sprite;

		public function FXScanline(displayObject:DisplayObject) 
		{
			// vars
			this._displayObject = displayObject;
			
			// mask
			this._mask = new Shape();
			this.addChild(this._mask);
			
			// line
			this._line = new Sprite();
			this.addChild(this._line);
		}
		
		/* statics */
		public static function show(target:DisplayObject, container:DisplayObjectContainer, depthIndex:int = -1):FXScanline
		{
			var instance:FXScanline = new FXScanline(target);
			instance.show(container, depthIndex);
			
			return instance;
		}
		
		public static function hide(target:DisplayObject):FXScanline
		{
			var instance:FXScanline = new FXScanline(target);
			instance.hide();
			
			return instance;
		}

		/* methods */
		private function applyBounds():void
		{
			// bounds
			var bounds:Rectangle = this._bounds= this._displayObject.getBounds(this._displayObject);
			
			// mask
			Picasso.clear(this._mask);
			Picasso.drawRectangle(this._mask, 0, 1, 0, 0, bounds.width, bounds.height);
			
			// line
			Picasso.drawRectangle(this._line, 0xFFFFFF, 1, 0, 0, bounds.width, 1);
			this._line.addChild(FXChromaticAberration.snapshot(this._line, -1, 1, 0, 0, 1, -1, 2));
			
			//_targeton
			this.x = this._displayObject.x + bounds.x;
			this.y = this._displayObject.y + bounds.y;
		}
		
		private function add():void
		{
			if(this._displayObject.parent != null)
			{
				this._displayObject.mask = this._mask;
				this._displayObject.parent.addChild(this);
			}
		}
		
		private function remove(removeDisplayObject:Boolean = false):void
		{
			if(removeDisplayObject) if(this._displayObject.parent != null) this._displayObject.parent.removeChild(this._displayObject);
			
			this._displayObject.mask = null;
			this.parent.removeChild(this);
		}
		
		public function show(container:DisplayObjectContainer, depthIndex:int = -1):void
		{
			this.applyBounds();
			
			this._mask.scaleY = 0;
			this._line.alpha = 0;			this._line.y = 0;
					
			if(container != null) container.addChildAt(this._displayObject, depthIndex == -1 ? container.numChildren : depthIndex);
			this.add();
			
			TweenLite.to(this._mask, this._duration, {scaleY:1, ease:this._ease, delay:.1, onComplete:this.remove});
						TweenMax.to(this._line, this._duration, {y:this._bounds.height, ease:this._ease, delay:.1});			TweenMax.to(this._line, .1, {alpha:1, ease:Cubic.easeIn});			TweenMax.to(this._line, .1, {alpha:0, ease:Cubic.easeOut, delay:this._duration - .1});
		}
		
		public function hide():void
		{
			this.applyBounds();
			
			this._mask.scaleY = 1;
			this._line.alpha = 0;
			this._line.y = this._bounds.height - 1;
			
			this.add();
			
			TweenLite.to(this._mask, this._duration, {scaleY:0, ease:this._ease, delay:.1, onComplete:this.remove, onCompleteParams:[true]});
			
			TweenMax.to(this._line, this._duration, {y:0, ease:this._ease, delay:.1});
			TweenMax.to(this._line, .2, {alpha:1, ease:Cubic.easeIn});
			TweenMax.to(this._line, .2, {alpha:0, ease:Cubic.easeOut, delay:this._duration - .2});
		}
	}
}
