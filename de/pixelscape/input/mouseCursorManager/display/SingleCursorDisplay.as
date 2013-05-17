package de.pixelscape.input.mouseCursorManager.display
{
	import de.pixelscape.input.mouseCursorManager.data.MouseCursorData;
	import de.pixelscape.input.mouseCursorManager.data.SingleCursor;
	
	public class SingleCursorDisplay extends MouseCursorDisplay
	{
		/* variables */
		private var _data:SingleCursor;
		
		public function SingleCursorDisplay(data:SingleCursor)
		{
			// vars
			_data = data;
			
			// build
			addChild(_data.cursor);
		}
	}
}