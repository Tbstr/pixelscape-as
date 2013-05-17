package de.pixelscape.graphics
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class PBitmap
	{
		/* variables */
		private var _bitmapData:BitmapData;
		private var _matrix:Matrix;
		private var _repeat:Boolean;
		private var _smooth:Boolean;
		
		public function PBitmap(bitmapData:BitmapData, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false)
		{
			// vars
			_bitmapData = bitmapData;
			_matrix = matrix;
			_repeat = repeat;
			_smooth = smooth;
		}
		
		/* getter */
		public function get bitmapData():BitmapData			{ return _bitmapData; }
		public function get matrix():Matrix					{ return _matrix; }
		public function get repeat():Boolean				{ return _repeat; }
		public function get smooth():Boolean				{ return _smooth; }
	}
}