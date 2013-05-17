package de.pixelscape.remote 
{
	import flash.net.NetConnection;
	import flash.net.Responder;

	/**
	 * @author tobias.friese
	 */
	public class AMFRequest extends Responder 
	{
		public function AMFRequest(connection:NetConnection, method:String, arguments:Array = null, handleSuccess:Function = null, handleFail:Function = null)
		{
			super(handleSuccess, handleFail);
			
			var args:Array = new Array(method, this);
			if(arguments != null) args = args.concat(arguments);
			
			connection.call.apply(undefined, args);
		}
	}
}
