package de.pixelscape.display.blitting
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BlitterSnapshot
	{
		/* variables */
		private var _offset:Point;
		private var _bitmapData:BitmapData;
		
		public function BlitterSnapshot(bitmapData:BitmapData, offset:Point)
		{
			// vars
			_bitmapData = bitmapData;
			_offset = offset;
		}
		
		/* getter */
		public function get bitmapData():BitmapData			{ return _bitmapData; }
		public function get offset():Point					{ return _offset; }
	}
}