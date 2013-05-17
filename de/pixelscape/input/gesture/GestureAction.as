package de.pixelscape.input.gesture 
{

	/**
	 * @author tobias.friese
	 */
	public class GestureAction 
	{
		/* variables */
		private var _gesture:Gesture;
		private var _action:*;
		
		public function GestureAction(gestureCode:String, action:*)
		{
			this._gesture = new Gesture(gestureCode);
			this._action = action;
		}
		
		/* getter */
		public function get gesture():Gesture
		{
			return this._gesture;
		}
		
		public function get action():*
		{
			return this._action;
		}
	}
}
