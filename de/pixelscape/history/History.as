package de.pixelscape.history 
{
	import de.pixelscape.utils.Analysis;		import de.pixelscape.output.notifier.Notifier;			/**
	 * @author Tobias Friese
	 */
	public class History 
	{
		/* variables */
		private static var _instance:History;
		
		private var _stack:Array 			= new Array();
		private var _cursor:int	 			= -1;
		
		private var _referencePoint:int 	= -1;
		
		
		public function History()
		{
			if(_instance == null) _instance = this;
			else throw new Error("History is a singleton class and therefor can only be accessed throug History.getInstance() or History.instance.");
		}
		
		/* singleton getter */
		public static function getInstance():History
		{
			if(_instance == null) _instance = new History();
			return _instance;
		}
		
		/* singleton getter */
		public static function get instance():History
		{
			return getInstance();
		}

		/* methods */
		public function add(object:*, action:Object, reverseObject:*, reverseAction:Object):void
		{
			if(this._cursor != (this._stack.length - 1)) this._stack.splice(this._cursor + 1);
			if(reverseObject == null) reverseObject = object;
			
			var step:Step = new Step(object, action, reverseObject, reverseAction);
			
			this._stack.push(step);
			this._cursor = this._stack.length - 1;
		}
		
		public function historyBack():void
		{
			if(this._stack.length > 0)
			{
				if(this._cursor >= 0)
				{
					Step(this._stack[this._cursor]).reverse();
					this._cursor--;
				}
			}
		}
		
		public function historyForward():void
		{
			if(_cursor < (_stack.length - 1))
			{
				_cursor++;
				Step(this._stack[this._cursor]).execute();
			}
		}
		
		public function updateReferencePoint():void
		{
			this._referencePoint = this._cursor;
		}

		public function clear():void
		{
			this._stack.splice(0);
			this._cursor = -1;
		}
		
		/* getter setter */
		public function get numSteps():uint
		{
			return this._stack.length;
		}
		
		public function get hasChanges():Boolean
		{
			return !(this._cursor == this._referencePoint);
		}
		
		/* finalization */
		public function finalize():void
		{
			// release variables
			this._stack = null;
		}
	}
}
