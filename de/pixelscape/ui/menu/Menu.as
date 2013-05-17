package de.pixelscape.ui.menu
{
	import de.pixelscape.ui.button.ButtonEvent;
	import de.pixelscape.ui.button.Button;

	import flash.display.Sprite;

	/**
	 * @author tobiasfriese
	 */
	public class Menu extends Sprite
	{
		/* statics */
		private static var _menues:Vector.<Menu>	= new Vector.<Menu>();
		
		/* variables */
		private var _groupID:String;
		private var _buttons:Vector.<Button>		= new Vector.<Button>();
		
		public function Menu(groupID:String = null)
		{
			// vars
			this._groupID = groupID;
			
			// register instance
			_menues.push(this);
		}
		
		/* static methods */
		private static function manageHighlighting(groupID:String, buttonID:String):void
		{
			for each(var menu:Menu in _menues)
			{
				if(menu.groupID == groupID) menu.manageHighlighting(buttonID);
			}
		}
		
		/* instance methods */
		protected final function registerButton(button:Button):void
		{
			button.addEventListener(ButtonEvent.MOUSE_DOWN, this.handleButtonMouseDown);
			button.addEventListener(ButtonEvent.MOUSE_UP, this.handleButtonMouseUp);
			button.addEventListener(ButtonEvent.MOUSE_OVER, this.handleButtonMouseOver);
			button.addEventListener(ButtonEvent.MOUSE_OUT, this.handleButtonMouseOut);			
			this._buttons.push(button);
		}
		
		protected final function manageHighlighting(buttonID:String):void
		{
			for each(var button:Button in this._buttons)
			{
				button.highlight = button.id == buttonID;
			}
		}
		
		/* getter setter */
		public function getButtons():Vector.<Button>
		{
			return this._buttons;
		}
		
		public function getButtonAt(index:int):Button
		{
			if(index < this._buttons.length) return this._buttons[index];
			
			return null;
		}
		
		public function getButtonByID(id:String):Button
		{
			for each(var button:Button in this._buttons)
			{
				if(button.id == id) return button;
			}
			
			return null;
		}
		
		public function get groupID():String
		{
			return this._groupID;
		}
		
		public function set groupID(value:String):void
		{
			this._groupID = value;
		}
		
		/* event handler */
		private function handleButtonMouseOver(e:ButtonEvent):void
		{
			this.dispatchEvent(e);
		}
		
		private function handleButtonMouseOut(e:ButtonEvent):void
		{
			this.dispatchEvent(e);
		}
		
		private function handleButtonMouseDown(e:ButtonEvent):void
		{
			this.dispatchEvent(e);
		}
		
		private function handleButtonMouseUp(e:ButtonEvent):void
		{
			Menu.manageHighlighting(this._groupID, e.button.id);
			this.dispatchEvent(e);
		}
	}
}
