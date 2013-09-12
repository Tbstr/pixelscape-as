package de.pixelscape.utils 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Ease;
	
	import flash.display.DisplayObject;

	/**
	 * @author tobias.friese
	 */
	public class TransformationCache 
	{
		/* variables */
		private var _x:Number;		private var _y:Number;
		private var _z:Number;

		private var _scaleX:Number;		private var _scaleY:Number;
		private var _scaleZ:Number;

		private var _rotationX:Number;
		private var _rotationY:Number;
		private var _rotationZ:Number;

		public function TransformationCache(displayObject:DisplayObject)
		{
			// take snapshot
			snapShot(displayObject);
		}

		public function snapShot(displayObject:DisplayObject):void
		{
			// cancellation
			if(displayObject == null) return;
			
			// take properties
			_x = displayObject.x;
			_y = displayObject.y;
			_z = displayObject.z;
			
			_scaleX = displayObject.scaleX;
			_scaleY = displayObject.scaleY;
			_scaleZ = displayObject.scaleZ;
			
			_rotationX = displayObject.rotationX;
			_rotationY = displayObject.rotationY;
			_rotationZ = displayObject.rotationZ;
		}

		public function apply(displayObject:DisplayObject, position:Boolean = true, scalation:Boolean = true, rotation:Boolean = true):void
		{
			// cancellation
			if(displayObject == null) return;
			
			// apply
			if(position)
			{
				displayObject.x = _x;				displayObject.y = _y;
				displayObject.z = _z;
			}
			
			if(scalation)
			{
				displayObject.scaleX = _scaleX;				displayObject.scaleY = _scaleY;
				displayObject.scaleZ = _scaleZ;
			}
						if(rotation)
			{
				displayObject.rotationX = _rotationX;
				displayObject.rotationY = _rotationY;
				displayObject.rotationZ = _rotationZ;
			}
		}

		public function applyTweened(displayObject:DisplayObject, time:Number, transition:Ease, position:Boolean = true, scalation:Boolean = true, rotation:Boolean = true):void
		{
			if(position)	TweenLite.to(displayObject, time, {x:_x, y:_y, z:_z, ease:transition});
			if(scalation)	TweenLite.to(displayObject, time, {scaleX:_scaleX, scaleY:_scaleY, scaleZ:_scaleZ, ease:transition});
			if(rotation)	TweenLite.to(displayObject, time, {rotationX:_rotationX, rotationY:_rotationY, rotationZ:_rotationZ, ease:transition});
		}

		/* getter setter */
		public function get x():Number					{ return _x; }
		public function get y():Number					{ return _y; }
		public function get z():Number					{ return _z; }

		public function get scaleX():Number				{ return _scaleX; }
		public function get scaleY():Number				{ return _scaleY; }
		public function get scaleZ():Number				{ return _scaleZ; }

		public function get rotationX():Number			{ return _rotationX; }
		public function get rotationY():Number			{ return _rotationY; }
		public function get rotationZ():Number			{ return _rotationZ; }
	}
}