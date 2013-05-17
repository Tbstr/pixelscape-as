package de.pixelscape.input.mouseCursorManager
{
	import de.pixelscape.input.mouseCursorManager.data.InteractiveCursor;
	import de.pixelscape.input.mouseCursorManager.data.MouseCursorData;
	import de.pixelscape.input.mouseCursorManager.data.SingleCursor;
	import de.pixelscape.input.mouseCursorManager.display.InteractiveCursorDisplay;
	import de.pixelscape.input.mouseCursorManager.display.MouseCursorDisplay;
	import de.pixelscape.input.mouseCursorManager.display.SingleCursorDisplay;
	import de.pixelscape.output.notifier.Notifier;
	import de.pixelscape.utils.TopLevelUtils;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;

	public class MouseCursorManager
	{
		/* variables */
		private static var _instance:MouseCursorManager;
		
		private var _cursors:Object										= new Object();
		private var _triggers:Dictionary								= new Dictionary();
		
		private var _defaultCursorData:MouseCursorData;
		
		private var _currentCursorData:MouseCursorData;
		private var _currentCursorDisplay:MouseCursorDisplay;
		
		private var _stage:Stage;
		private var _container:DisplayObjectContainer;
		
		private var _stageListenerAdded:Boolean							= false;
		private var _initialized:Boolean								= false;
		
		public function MouseCursorManager()
		{
			if(_instance == null) _instance = this;
			else throw new Error("Singleton Dude!");
		}
		
		/* static getter */
		public static function getInstance():MouseCursorManager
		{
			if(_instance == null) new MouseCursorManager();
			return _instance;
		}
		
		public static function get instance():MouseCursorManager
		{
			if(_instance == null) new MouseCursorManager();
			return _instance;
		}
		
		/* static shortcuts */
//		public static function initialize(stage:Stage, container:DisplayObjectContainer):void						{ getInstance().initialize(stage, container); }
//		public static function addCursor(mouseCursorData:MouseCursorData):void										{ getInstance().addCursor(mouseCursorData); }
//		public static function addTrigger(trigger:InteractiveObject, cursorId:String):void							{ getInstance().addTrigger(trigger, cursorId); }
//		public static function removeTrigger(trigger:InteractiveObject):void										{ getInstance().removeTrigger(trigger); }
		
		/* methods */
		public function initialize(stage:Stage, container:DisplayObjectContainer):void
		{
			if(stage == null) return;
			if(container == null) return;
			
			_stage = stage;
			_container = container;
			
			_initialized = true;
		}
		
		public function addCursor(mouseCursorData:MouseCursorData):void
		{
			if(mouseCursorData == null) return;
			_cursors[mouseCursorData.id] = mouseCursorData;
		}
		
		public function addTrigger(trigger:InteractiveObject, cursorId:String):void
		{
			if(trigger == null) return;
			if(cursorId == null) return;
			
			trigger.addEventListener(MouseEvent.MOUSE_OVER, handleTriggerMouseOver);
			trigger.addEventListener(MouseEvent.MOUSE_OUT, handleTriggerMouseOut);
			
			_triggers[trigger] = cursorId;
		}
		
		public function removeTrigger(trigger:InteractiveObject):void
		{
			if(trigger == null) return;
			
			trigger.removeEventListener(MouseEvent.MOUSE_OVER, handleTriggerMouseOver);
			trigger.removeEventListener(MouseEvent.MOUSE_OUT, handleTriggerMouseOut);
			
			delete _triggers[trigger];
		}
		
		public function setCursor(id:String):void
		{
			// get cursor data
			var cursorData:MouseCursorData = _cursors[id];
			
			// cancellation
			if(cursorData === _currentCursorData) return;
			
			// remove old cursor
			if(_currentCursorDisplay != null) _container.removeChild(_currentCursorDisplay);
			
			_currentCursorData = null;
			_currentCursorDisplay = null;
			
			// place & set listener
			if(cursorData != null)
			{
				// hide mouse
				Mouse.hide();
				
				// generate display
				var cursorDisplay:MouseCursorDisplay;
				
				if(cursorData is SingleCursor) cursorDisplay = new SingleCursorDisplay(SingleCursor(cursorData));
				if(cursorData is InteractiveCursor) cursorDisplay = new InteractiveCursorDisplay(InteractiveCursor(cursorData));
				
				// add
				_container.addChild(cursorDisplay);
				
				// register listeners
				registerStageListener();
				
				// set vars
				_currentCursorData = cursorData;
				_currentCursorDisplay = cursorDisplay;
				
				// initial positioning
				handleMouseMove();
			}
			else
			{
				// show mouse
				Mouse.show();
				
				// remove listeners
				unregisterStageListener();
			}
		}
		
		private function registerStageListener():void
		{
			if(_stageListenerAdded) return;
			
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_stageListenerAdded = true;
		}
		
		private function unregisterStageListener():void
		{
			if(!_stageListenerAdded) return;
			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			_stageListenerAdded = false;
		}
		
		/* getter setter */
		public function get defaultCursor():String
		{
			if(_defaultCursorData == null) return null;
			return _defaultCursorData.id;
		}
		
		public function set defaultCursor(id:String):void
		{
			if(id in _cursors) _defaultCursorData = _cursors[id];
			else _defaultCursorData = null;
		}
		
		/* event handler */
		private function handleTriggerMouseOver(e:MouseEvent):void
		{
			setCursor(_triggers[e.currentTarget]);
		}
		
		private function handleTriggerMouseOut(e:MouseEvent):void
		{
			setCursor(null);
		}
		
		private function handleMouseMove(e:MouseEvent = null):void
		{
			_currentCursorDisplay.x = _container.mouseX;
			_currentCursorDisplay.y = _container.mouseY;
		}
	}
}