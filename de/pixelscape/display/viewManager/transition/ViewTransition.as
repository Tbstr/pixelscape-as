package de.pixelscape.display.viewManager.transition
{
	import de.pixelscape.display.viewManager.view.View;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * @author tobiasfriese
	 */
	public class ViewTransition extends EventDispatcher
	{
		/* variables */
		private var _oldView:View;		private var _newView:View;
		
		private var _running:Boolean;
		
		/* constants */
		public static const TRANSITION_COMPLETE:String		= "transitionComplete";
		
		public final function start(oldView:View, newView:View, forward:Boolean):void
		{
			if(!_running)
			{
				_oldView = oldView;
				_newView = newView;
				
				onStart(forward);
				
				_running = true;
			}
		}
		
		/* getter setter */
		public function get oldView():View
		{
			return _oldView;
		}
		
		public function get newView():View
		{
			return _newView;
		}
		
		public function get running():Boolean
		{
			return _running;
		}
		
		/* dispatch methods */
		protected function dispatchTransitionComplete():void
		{
			_running = false;
			dispatchEvent(new Event(TRANSITION_COMPLETE));
		}
		
		/* child methods */
		protected function onStart(forward:Boolean):void {}
		
		/* finalize */
		public function finalize():void
		{
			_oldView = null;
			_newView = null;
		}
	}
}
