package de.pixelscape.assets.cache 
{

	/**
	 * @author Tobias Friese
	 */
	public class CacheData 
	{
		/* variables */
		private var _id:String;
		private var _object:*;
		private var _cloneMethodName:String;
		
		public function CacheData(id:String, object:*, cloneMethodName:String = "clone")
		{
			// vars
			_id = id;
			_object = object;
			_cloneMethodName = cloneMethodName;
		}
		
		public function getClone():*
		{
			if(_cloneMethodName in _object) return _object[_cloneMethodName]();
			else throw new Error("Object isn't cloneable.");
			
			return null;
		}
		
		/* getter setter */
		public function get id():String							{ return _id; }
		public function get object():*							{ return _object; }
		public function get cloneMethodName():String			{ return _cloneMethodName; }
	}
}
