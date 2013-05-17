package de.pixelscape.remote 
{
	import de.pixelscape.utils.Analysis;
	import flash.net.NetConnection;

	/**
	 * @author tobias.friese
	 */
	public class AMFConnector 
	{
		/* statics */
		private static var _instance:AMFConnector;
		
		/* variables */
		private var _gateway:String;
		private var _connection:NetConnection;
		private var _requests:Array					= new Array();

		public function AMFConnector()
		{
			if(_instance == null) _instance = this;
			else throw new Error("AMFConnector is a singleton and therefor can only be accessed througn AMFConnector.getInstance().");
		}
		
		/* static getter */
		public static function getInstance():AMFConnector
		{
			if(_instance == null) new AMFConnector();
			return _instance;
		}
		
		public static function get instance():AMFConnector
		{
			if(_instance == null) new AMFConnector();
			return _instance;
		}
		
		/* methods */
		public function connect(gateway:String):void
		{
			this._gateway = gateway;
			
			this._connection = new NetConnection();
			this._connection.connect(gateway);
		}
		
		public function request(method:String, arguments:Array = null, handleSuccess:Function = null, handleFail:Function = null):void
		{
			if(handleFail == null) handleFail = this.handleFailDefault;
			
			var request:AMFRequest = new AMFRequest(this._connection, method, arguments, handleSuccess, handleFail);
			this._requests.push(request);
		}
		
		/* event handler */
		private function handleFailDefault(data:Object):void 
		{
			trace("AMFConnector Error");
			trace("");
			
			Analysis.traceObject(data);
			
			trace("");
		}
	}
}
