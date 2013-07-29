package de.pixelscape.display.blitting
{
	import flash.display.BitmapData;
	import flash.geom.Point;

	public class BlitterSnapshot
	{
		/* variables */
		private var _offset:Point;
		private var _bitmapData:BitmapData;
		private var _label:String;
		
		public function BlitterSnapshot(bitmapData:BitmapData, offset:Point, label:String = null)
		{
			// vars
			_bitmapData = bitmapData;
			_offset = offset;
			_label = label;
		}
		
		/* getter */
		public function get bitmapData():BitmapData			{ return _bitmapData; }
		public function get offset():Point					{ return _offset; }
		public function get label():String					{ return _label; }
	}
}