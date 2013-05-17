package de.pixelscape.input.mouseCursorManager.data
{
	import flash.display.DisplayObject;

	public class SingleCursor extends MouseCursorData
	{
		/* variables */
		private var _cursor:DisplayObject;
		
		private var _offsetX:Number;
		private var _offsetY:Number;
		
		public function SingleCursor(id:String, cursor:DisplayObject, offsetX:Number = 0, offsetY:Number = 0)
		{
			// super
			super(id);
			
			// vars
			_cursor			= cursor;
			_offsetX		= offsetX;
			_offsetY		= offsetY;
			
			// set cursor position
			_cursor.x = offsetX;
			_cursor.y = offsetY;
		}
		
		/* getter */
		public function get cursor():DisplayObject					{ return _cursor; }
		public function get offsetX():Number						{ return _offsetX; }
		public function get offsetY():Number						{ return _offsetY; }
	}
}