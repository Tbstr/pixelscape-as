package de.pixelscape.data 
{

	/**
	 * This class holds information and manipulation methods for vector calculation.
	 * 
	 * @author Tobias Friese
	 */
	public class PSVector 
	{
		private var _x:Number		= 0;		private var _y:Number		= 0;
		
		private var _length:Number	= 0;		private var _angle:Number	= 0;
		
		public function PSVector(x:Number, y:Number)
		{
			this._x = x;
			this._y = y;
			
			// calculate length and angle
			this._length = Math.sqrt(Math.pow(this._x, 2) + Math.pow(this._y, 2));
			this._angle = Math.atan2(this._y, this._x);
		}
		
		/* getter setter */
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			this._x = value;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			this._y = value;
		}
		
		public function get length():Number
		{
			return _length;
		}
		
		public function set length(value:Number):void
		{
			this._length = value;
			
			this._x = Math.cos(this._angle) * value;
			this._y = Math.sin(this._angle) * value;
		}
		
		public function get angle():Number
		{
			return _angle;
		}
		
		public function set angle(value:Number):void
		{
			while(value > Math.PI) value -= Math.PI * 2;
			while(value < -Math.PI) value += Math.PI * 2;
			
			this._angle = value;
			
			this._x = Math.cos(value) * this._length;
			this._y = Math.sin(value) * this._length;
		}
		
		/* methods */
		public function add(v:PSVector):PSVector
		{
			return new PSVector(this._x + v.x, this._y + v.y);
		}
		
		public function subtract(v:PSVector):PSVector
		{
			return new PSVector(this._x - v.x, this._y - v.y);
		}
		
		public function multiply(value:*):PSVector
		{
			if(value is PSVector) return new PSVector(this._x * PSVector(value).x, this._y * PSVector(value).y);
			if(value is Number) return new PSVector(this._x * value, this._y * value);
			return null;
		}
		
		public function divide(value:*):PSVector
		{
			if(value is PSVector) return new PSVector(this._x / PSVector(value).x, this._y / PSVector(value).y);
			if(value is Number) return new PSVector(this._x / value, this._y / value);
			return null;
		}
		
		public function toString():String
		{
			return ("[Vector] (x:" + this._x + " ,y:" + this._y + " ,angle:" + this._angle + " ,length:" + this._length +")");
		}
	}
}
