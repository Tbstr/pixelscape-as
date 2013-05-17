package de.pixelscape.input.mouseCursorManager.data
{
	public class InteractiveCursor extends MouseCursorData
	{
		/* vars */
		private var _cursorDefault:SingleCursor;
		private var _cursorMouseDown:SingleCursor;
		
		public function InteractiveCursor(id:String, cursorDefault:SingleCursor, cursorMouseDown:SingleCursor)
		{
			// super
			super(id);
			
			// vars
			_cursorDefault = cursorDefault;
			_cursorMouseDown = cursorMouseDown;
		}
		
		/* getter */
		public function get cursorDefault():SingleCursor						{ return _cursorDefault; }
		public function get cursorMouseDown():SingleCursor						{ return _cursorMouseDown; }
	}
}