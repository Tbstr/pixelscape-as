package de.pixelscape.utils 
{
	import flash.display.Stage;	
	/**
	 * @author Tobias Friese
	 */
	public class TopLevelUtils
	{
		/* statics */
		private static var _instance:TopLevelUtils;
		
		/* variables */
		private var _stage:Stage;
		private var _data:Object = new Object();

		public function TopLevelUtils()
		{
			if(_instance == null) _instance = this;
			else throw new Error("TopLevelUtils is a singleton and therefor can only be accessed through TopLevelUtils.getInstance() or TopLevelUtils.instance.");
		}
		
		/* singleton getter */
		public static function getInstance():TopLevelUtils
		{
			if(_instance == null) _instance = new TopLevelUtils();
			return _instance;
		}
		
		public static function get instance():TopLevelUtils
		{
			return getInstance();
		}
		
		/* static shortcuts */
		public static function initialize(stage:Stage):void
		{
			getInstance().initialize(stage);
		}
		
		public static function get stage():Stage
		{
			return getInstance().stage;
		}
		
		/* methods */
		public function initialize(stage:Stage):void
		{
			this._stage = stage;
		}
		
		public function setLink(id:String, object:*):void
		{
			this._data[id] = object;
		}
		
		public function getLink(id:String):*
		{
			if(id in this._data) return this._data[id];
			else return null;
		}
		
		/* getter setter */
		public function get stage():Stage
		{
			if(this._stage == null) throw new Error("Global reference to the stage has not yet been set. Initialize the TopLevelUtils at the beginning of your main class first, using TopLevelUtils.initialize(stage).");
			return this._stage;
		}
	}
}
