package de.pixelscape.ui
{
	import de.pixelscape.utils.TransformationUtils;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	public class MouseCursor extends Sprite
	{
		/* vars */
		private var _enabled:Boolean			= false;
		
		/* architecture */
		private var _container:DisplayObjectContainer;
		private var _symbol:DisplayObject;
		
		/* constants */
		
		public function MouseCursor(container:DisplayObjectContainer, symbol:DisplayObject = null, autoEnable:Boolean = true)
		{
			// vars
			_container = container;
			_symbol = symbol;
			
			// build
			if(symbol != null) addChild(symbol);
			
			// settings
			hitArea = new Sprite();
			if(autoEnable) enabled = true;
		}
		
		private function registerEventListeners():void
		{
			_container.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		
		private function unregisterEventListeners():void
		{
			_container.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		
		public function centerSymbol():void
		{
			if(_symbol == null) return;
			TransformationUtils.center(_symbol);
		}
		
		public function offsetSymbol(x:Number, y:Number):void
		{
			if(_symbol == null) return;
			_symbol.x = x;
			_symbol.y = y;
		}
		
		private function update():void
		{
			x = _container.mouseX;
			y = _container.mouseY;
		}
		
		public function kill():void
		{
			finalize();
		}
		
		/* getter setter */
		public function get enabled():Boolean					{ return _enabled; }
		public function set enabled(value:Boolean):void
		{
			if(value == _enabled) return;
			
			// set var
			_enabled = value;
			
			// action
			if(value)
			{
				Mouse.hide();
				
				_container.addChild(this);
				
				update();
				registerEventListeners();
			}
			else
			{
				unregisterEventListeners();
				_container.removeChild(this);
				
				Mouse.show();
			}
		}
		
		/* event handler */
		private function handleMouseMove(e:MouseEvent):void
		{
			update();
		}
		
		/* finalization */
		public function finalize():void
		{
			if(parent != null) parent.removeChild(this);
			Mouse.show();
		}
	}
}