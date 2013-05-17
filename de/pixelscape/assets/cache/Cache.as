package de.pixelscape.assets.cache
{

	/**
	 * The Cache class holds objects and returns them or cloned instances on demand.
	 * This is for quick reuse of loaded data.
	 * 
	 * @author Tobias Friese
	 */
	public class Cache
	{
		/* variables */
		private static var _instance:Cache;
		private var _data:Vector.<CacheData> = new Vector.<CacheData>();
		
		public function Cache()
		{
			if(_instance == null) _instance = this;
			else throw new Error("Cache is a Singleton and therefor can only be accessed through Cache.getInstance() or Cache.instance");
		}

		/* singleton getter */
		public static function getInstance():Cache
		{
			if(_instance == null) _instance = new Cache();
			return _instance;
		}
		
		public static function get instance():Cache
		{
			if(_instance == null) _instance = new Cache();
			return _instance;
		}
		
		/* data management */
		public function addData(id:String, object:*, cloneMethodName:String = "clone"):Boolean
		{
			if(!contains(id))
			{
				_data.push(new CacheData(id, object, cloneMethodName));
				return true;
			}
			
			return false;
		}
		
		public function removeData(id:String):Boolean
		{
			for(var i:int = 0; i < _data.length; i++)
			{
				if(_data[i].id == id)
				{
					_data.splice(i, 1);
					return true;
				}
			}
			
			return false;
		}
		
		public function contains(id:String):Boolean
		{
			for(var i:int = 0; i < _data.length; i++) if(_data[i].id == id) return true;
			return false;
		}
		
		public function getData(id:String, clone:Boolean = false):*
		{
			for(var i:int = 0; i < _data.length; i++)
			{
				if(_data[i].id == id)
				{
					if(clone) return _data[i].getClone();
					else return _data[i].object;
				}
			}
			
			return null;
		}
	}
}