package de.pixelscape.history
{

	public class Step 
	{
		/* variables */
		private var _object:*;		private var _action:Object;
		
		private var _reverseObject:*;
		private var _reverseAction:Object;

		/** constructor method */
		public function Step(object:*, action:Object, reverseObject:*, reverseAction:Object)
		{
			this._object = object;
			this._action = action;
			
			this._reverseObject = reverseObject;
			this._reverseAction = reverseAction;
		}
		
		public function execute():void
		{
			this.computeAction(this._object, this._action);
		}
		
		public function reverse():void
		{
			this.computeAction(this._reverseObject, this._reverseAction);
		}
		
		private function computeAction(object:*, action:Object):void
		{
			if(object != null)
			{
				if(action != null)
				{
					// function call
					if("functionCall" in action)
					{
						// function call
						var functionName:String = action.functionCall as String;
						
						if(functionName != null)
						{
							var arguments:Array;
							if("functionArguments" in action) arguments = action.functionArguments as Array;
							
							if(arguments == null) object[functionName]();
							else object[functionName].apply(NaN, arguments);
						}
					}
					
					// property manipulation
					for(var id:String in action)
					{
						if(id != "functionCall")
						{
							if(id != "functionAttributes")
							{
								if(id in object) object[id] = action[id];
							}
						}
					}
				}
			}
		}
		
		/* getter methods */
		public function get object():*
		{
			return this._object;
		}
		
		public function get action():Object
		{
			return this._action;
		}
		
		public function get reverseObject():*
		{
			return this._reverseObject;
		}
		
		public function get reverseAction():Object
		{
			return this._reverseAction;
		}
	}
}