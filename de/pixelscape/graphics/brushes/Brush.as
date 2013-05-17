package de.pixelscape.graphics.brushes 
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	/**
	 * @author Tobias Friese
	 */
	public class Brush 
	{
		/* variables */
		protected var _canvas:DisplayObjectContainer;
		
		protected var _path:Array;
		protected var _recentPosition:Point;
		
		protected var _drawing:Boolean;
		
		public final function start(canvas:DisplayObjectContainer, x:Number, y:Number):void
		{
			if(!this._drawing)
			{
				this._canvas = canvas;
				
				this._path = new Array();
				this._recentPosition = new Point();
				
				this._drawing = true;
				
				this.onStart(x, y);
				
				// recent
				this._recentPosition.x = x;				this._recentPosition.y = y;
				
				// path
				this._path.push(this._recentPosition.clone());
			}
			else throw new Error("Brush has already been started. End first using the end() method.");
		}

		public final function draw(x:Number, y:Number):void
		{
			if(this._drawing)
			{
				this.onDraw(x, y);
				
				// recent
				this._recentPosition.x = x;
				this._recentPosition.y = y;
				
				// path
				this._path.push(this._recentPosition.clone());
			}
			else throw new Error("Brush has to be started first using method start().");
		}
		
		public final function end():void
		{
			if(this._drawing)
			{
				this.onEnd();
				
				this._canvas = null;
				this._path = null;
				this._recentPosition = null;
				
				this._drawing = false;
			}
			else throw new Error("Brush has not been started.");
		}

		/* childclass caller */
		protected function onStart(x:Number, y:Number):void {}
		protected function onDraw(x:Number, y:Number):void {}
		protected function onEnd():void {}
		
		/* getter setter */
		public function get drawing():Boolean
		{
			return this._drawing;
		}
	}
}
