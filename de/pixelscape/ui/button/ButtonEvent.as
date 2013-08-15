package de.pixelscape.ui.button 
{
	import flash.events.Event;		

	/**
	 * @author Tobias Friese
	 */
	public class ButtonEvent extends Event
	{
		/* variables */
		private var _button:Button;
		
		/* constants */
		public static const MOUSE_OVER:String		= "Button.MOUSE_OVER";
		public static const MOUSE_OUT:String		= "Button.MOUSE_OUT";		public static const MOUSE_DRAG_OUT:String	= "Button.MOUSE_DRAG_OUT";
		
		public static const MOUSE_DOWN:String		= "Button.MOUSE_DOWN";
		public static const MOUSE_UP:String			= "Button.MOUSE_UP";
				public static const DRAG_START:String		= "Button.DRAG_START";		public static const DRAG_PROGRESS:String	= "Button.DRAG_PROGRESS";		public static const DRAG_END:String			= "Button.DRAG_END";		
		public function ButtonEvent(type:String, button:Button, bubbles:Boolean = false, canceable:Boolean = false)
		{
			super(type, bubbles, canceable);
			
			this._button = button;
		}
		
		/* getter setter */
		public function get button():Button
		{
			return this._button;
		}
		
		/* clone */
		override public function clone():Event
		{
			return new ButtonEvent(type, _button, bubbles, cancelable);
		}
	}
}
