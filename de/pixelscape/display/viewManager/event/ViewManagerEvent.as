package de.pixelscape.display.viewManager.event
{
	import flash.events.Event;
	
	public class ViewManagerEvent extends Event
	{
		/* variables */
		
		/* constants */
		public static const VIEW_OPENED:String								= "viewOpened";
		public static const VIEW_NEXT:String								= "viewNext";
		public static const VIEW_PREVIOUS:String							= "viewPrevious";
		public static const VIEW_CLOSED:String								= "viewClosed";
		public static const VIEW_CHANGED:String								= "viewChanged";
		
		public function ViewManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			// super
			super(type, bubbles, cancelable);
		}
	}
}