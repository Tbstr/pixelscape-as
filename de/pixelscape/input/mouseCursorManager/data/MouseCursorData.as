package de.pixelscape.input.mouseCursorManager.data
{
	public class MouseCursorData
	{
		/* variables */
		private var _id:String;
		
		public function MouseCursorData(id:String)
		{
			// vars
			_id = id;
		}
		
		/* getter */
		public function get id():String								{ return _id; }
	}
}