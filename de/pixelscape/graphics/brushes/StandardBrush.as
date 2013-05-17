package de.pixelscape.graphics.brushes 
{
	import de.pixelscape.graphics.brushes.Brush;

	import flash.display.Graphics;
	import flash.display.Shape;

	/**
	 * @author tobias.friese
	 */
	public class StandardBrush extends Brush 
	{
		/* variables */
		private var _thickness:Number;		private var _color:uint;		private var _alpha:Number;
		
		private var _display:Shape;
		
		public function StandardBrush(thickness:Number, color:uint, alpha:Number)
		{
			this._thickness = thickness;			this._color = color;			this._alpha = alpha;
		}
		
		/* drawing */
		override protected function onStart(x:Number, y:Number):void
		{
			this._display = new Shape();
			this._canvas.addChild(this._display);
		}

		override protected function onDraw(x:Number, y:Number):void
		{
			var g:Graphics = this._display.graphics;
			
			g.clear();
			g.lineStyle(this._thickness, this._color, this._alpha);
			g.moveTo(this._path[0].x, this._path[0].y);
			
			for(var i:int = 1; i < this._path.length; i++) g.lineTo(this._path[i].x, this._path[i].y);
		}
		
		/* getter setter */
		public function get display():Shape
		{
			return this._display;
		}
	}
}
