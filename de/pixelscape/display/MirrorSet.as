package de.pixelscape.display
 {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;	
	
	/**
	 * 	The MirrorSet class generates a horizontal reflection for any added DisplayObject.
	 * 	
	 * 	@author Tobias Friese
	 * 	
	 * 	@example
	 * 	<p><listing><pre>
	 * 	import de.pixelscape.display.MirrorSet;
	 * 
	 * 	private var fbMirrorSet:MirrorSet;
	 * 
	 *	fbMirrorSet = new MirrorSet(displayObject.width, displayObject.height, 100, .6);
	 *	fbMirrorSet.x = 360;
	 *	fbMirrorSet.y = 240;
	 *	fbMirrorSet.addChildToContainer(displayObject);
	 *	fbMirrorSet.updateMirror();
	 *	</pre></listing></p>
	 * 	
	 * 	@version 1.2
	 * 	
	 * 	recent changes: 03.03.2008
	 */
	public class MirrorSet extends Sprite
	{
		
		private var _cntWidth:int;
		private var _cntHeight:int;
		
		private var _mLength:int;
		private var _mAlpha:Number;
		
		private var _container:Sprite;
		private var _containerMask:Shape;
		private var _mirror:Bitmap;
		
		private var _gradientContainer:Shape;
		
		private var _mirrorBitmap:BitmapData;
		private var _alphaMap:BitmapData;
		
		private var _capturing:Boolean;
		
		/** constructor method */
		public function MirrorSet(cntWidth:int, cntHeight:int, mLength:int, mAlpha:Number)
		{
			this._cntWidth			= cntWidth;
			this._cntHeight			= cntHeight;
			
			this._mLength			= mLength;
			this._mAlpha				= mAlpha;
			
			this._capturing			= false;
			
			build();
		}
		
		private function build():void
		{
			// container
			_container = new Sprite();
			_container.x = -Math.round(_cntWidth / 2);
			_container.y = -_cntHeight;
			addChild(_container);
			
			// mask
			_containerMask = new Shape();
			_containerMask.x = -Math.round(_cntWidth / 2);
			_containerMask.y = -_cntHeight;
			_containerMask.visible = false;
			
			with(_containerMask.graphics)
			{
				beginFill(0x000000, 1);
				lineStyle();
				drawRect(0, 0, _cntWidth, _cntHeight);
				endFill();
			}
			
			addChild(_containerMask);
			
			// mirror
			_mirrorBitmap = new BitmapData(_cntWidth, _mLength, true, 0x00000000);
			
			_mirror = new Bitmap(_mirrorBitmap);
			_mirror.x = _container.x;
			_mirror.y = _mLength;
			_mirror.scaleY = -1;
			_mirror.alpha = _mAlpha;
			addChild(_mirror);
			
			// gradientContainer
			_gradientContainer = new Shape();
			
			var gMatrix:Matrix = new Matrix();
			gMatrix.createGradientBox(_cntWidth, _mLength, Math.PI / 2, 0, 0);
			
			with(_gradientContainer.graphics)
			{
				beginGradientFill("linear", [0x000000, 0xFFFFFF], [100, 100], [0, 255], gMatrix, "pad");
				lineTo(_cntWidth, 0);
				lineTo(_cntWidth, _mLength);
				lineTo(0, _mLength);
				endFill();
			}
			
			// alphaMap
			_alphaMap = new BitmapData(_cntWidth, _mLength);
		}
		
		/**
		 * Adds a DisplayObject to the MirrorSet so that it can be captured. If <code>startUpdating()</code> is not yet called
		 * the <code>updateMirror()</code> method has to be called to render the reflection.
		 * 
		 * @param content the DisplayObject to add to the set
		 */
		public function addChildToContainer(content:DisplayObject):void
		{
			_container.addChild(content);
		}
		
		/**
		 * Returns the container Sprite for advanced manipulation.
		 */
		public function getContainer():Sprite
		{
			return(_container);
		}
		
		/**
		 * Returns the mirror Bitmap for advanced manipulation.
		 */
		public function getMirror():Bitmap
		{
			return(_mirror);
		}
		
		/**
		 * Captures the DisplayObjects added to the set and generates the reflection.
		 */
		public function updateMirror(e:Event = null):void
		{
			// img
			_mirrorBitmap.fillRect(_mirrorBitmap.rect, 0x00000000);
			_mirrorBitmap.draw(this, new Matrix(1, 0, 0, 1, Math.round(_cntWidth / 2), _mLength), null, "normal", new Rectangle(0, 0, _cntWidth, _mLength));

			_alphaMap.copyChannel(_mirrorBitmap, _mirrorBitmap.rect, new Point(0, 0), 8, 1);
			_alphaMap.draw(_gradientContainer, new Matrix(), null, "multiply");
			
			_mirrorBitmap.copyChannel(_alphaMap, _alphaMap.rect, new Point(0, 0), 1, 8);
		}
		
		/**
		 * Starts a continuous capturing phase so that animated content can be seen in the reflection as well.
		 */
		public function startUpdating():void
		{
			addEventListener(Event.ENTER_FRAME, updateMirror);
			_capturing = true;
		}
		
		/**
		 * Stops the previously started capturing phase.
		 */
		public function stopUpdating():void
		{
			removeEventListener(Event.ENTER_FRAME, updateMirror);
			_capturing = false;
		}
	}
}