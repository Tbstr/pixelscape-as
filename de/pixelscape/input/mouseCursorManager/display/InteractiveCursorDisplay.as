package de.pixelscape.input.mouseCursorManager.display
{
	import de.pixelscape.input.mouseCursorManager.data.InteractiveCursor;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class InteractiveCursorDisplay extends MouseCursorDisplay
	{
		/* variables */
		private var _data:InteractiveCursor;
		private var _currentCursor:DisplayObject;
		
		public function InteractiveCursorDisplay(data:InteractiveCursor)
		{
			// vars
			_data = data;
			
			// build
			setCursor(_data.cursorDefault.cursor);
			
			// register listeners
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
		}
		
		private function setCursor(cursor:DisplayObject):void
		{
			if(cursor == null) return;
			if(cursor == _currentCursor) return;
			
			if(_currentCursor != null) removeChild(_currentCursor);
			
			addChild(cursor);
			_currentCursor = cursor;
		}
		
		/* event handler */
		private function handleAddedToStage(e:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		}
		
		private function handleRemovedFromStage(e:Event):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		}
		
		private function handleMouseDown(e:MouseEvent):void
		{
			if(_data.cursorMouseDown != null) setCursor(_data.cursorMouseDown.cursor);
		}
		
		private function handleMouseUp(e:MouseEvent):void
		{
			setCursor(_data.cursorDefault.cursor);
		}
	}
}