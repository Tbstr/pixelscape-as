package de.pixelscape.ui.dialog 
{
	import flash.events.Event;
	
	/**
	 * @author Sickdog
	 */
	public class DialogEvent extends Event 
	{
		/* variables */
		private var _dialog:Dialog;
		
		/* constants */
		public static const OPEN:String					= "dialogOpen";
		public static const OPEN_COMPLETE:String		= "dialogOpenComplete";
				public static const CLOSE:String				= "dialogClose";
		public static const CLOSE_COMPLETE:String		= "dialogCloseComplete";
		
		public static const CONFIRM:String				= "dialogConfirm";		public static const NEXT:String					= "dialogNext";		public static const CANCEL:String				= "dialogCancel";		
		public function DialogEvent(type:String, dialog:Dialog, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			this._dialog = dialog;
		}
		
		/* getter setter */
		public function get dialog():Dialog				{ return this._dialog; }
	}
}
