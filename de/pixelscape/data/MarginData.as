package de.pixelscape.data
{
	public class MarginData
	{
		/* variables */
		public var left:Number;
		public var right:Number;
		public var top:Number;
		public var bottom:Number;
		
		public function MarginData(left:Number = 0, right:Number = 0, top:Number = 0, bottom:Number = 0)
		{
			this.left		= left;
			this.right		= right;
			this.top		= top;
			this.bottom		= bottom;
		}
		
		/* getter */
		public function get totalX():Number						{ return left + right; }
		public function get totalY():Number						{ return top + bottom; }
	}
}