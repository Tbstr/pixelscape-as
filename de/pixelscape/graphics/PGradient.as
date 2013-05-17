package de.pixelscape.graphics
{
	import flash.display.Shape;
	import flash.geom.Matrix;

	public class PGradient
	{
		/* variables */
		private var _type:String;
		private var _colors:Array;
		private var _alphas:Array;
		private var _ratios:Array;
		private var _matrix:Matrix;
		private var _spreadMethod:String;
		private var _interpolationMethod:String;
		private var _focalPointRatio:Number;
		
		public function PGradient(type:String, colors:Array, alphas:Array, ratios:Array, matrix:* = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0)
		{
			// vars
			_type					= type;
			_colors					= colors;
			_alphas					= alphas;
			_ratios					= ratios;
			_matrix					= computeMatrixInput(matrix);
			_spreadMethod			= spreadMethod;
			_interpolationMethod	= interpolationMethod;
			_focalPointRatio		= focalPointRatio;
		}
		
		private function computeMatrixInput(matrix:*):Matrix
		{
			// null
			if(matrix == null) return null;
			
			// matrix
			if(matrix is Matrix) return matrix;
			
			// array (gradient box attributes)
			if(matrix is Array)
			{
				var outMatrix:Matrix = new Matrix();
				outMatrix.createGradientBox.apply(null, matrix as Array);
					
				return outMatrix;
			}
			
			return null;
		}
		
		/* getter */
		public function get type():String										{ return _type; }
		public function get colors():Array										{ return _colors; }
		public function get alphas():Array										{ return _alphas; }
		public function get ratios():Array										{ return _ratios; }
		public function get matrix():Matrix										{ return _matrix; }
		public function get spreadMethod():String								{ return _spreadMethod; }
		public function get interpolationMethod():String						{ return _interpolationMethod; }
		public function get focalPointRatio():Number							{ return _focalPointRatio; }
	}
}