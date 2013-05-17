package de.pixelscape.animation 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Tobias Friese
	 */
	public class DelayedCall 
	{
		/* statics */
		private static var _instances:Vector.<DelayedCall> = new Vector.<DelayedCall>();
		
		/* variables */
		private var _id:String;
		private var _args:Array;
		private var _timer:Timer;
		private var _running:Boolean;
		
		public function DelayedCall(id:String, delay:Number, args:Array)
		{
			// vars
			_id = id;
			_args = args;
			
			// setup
			_timer = new Timer(delay * 1000, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);
			_timer.start();
			
			_running = true;
		}
		
		/* statics */
		public static function create(id:String, delay:Number, ...args):DelayedCall
		{
			// create
			var call:DelayedCall = new DelayedCall(id, delay, args);
			_instances.push(call);
			
			// return
			return call;
		}
		
		public static function kill(id:String):Boolean
		{
			var success:Boolean = false;
			
			for each(var call:DelayedCall in _instances)
			{
				if(call.id == id)
				{
					call.finalize();
					success = true;
				}
			}
			
			return success;
		}
		
		private static function clean():void
		{
			for(var i:int = (_instances.length - 1); i >= 0; i--) if(_instances[i].running == false) _instances.splice(i, 1);
		}

		/* getter setter */
		public function get id():String
		{
			return _id;
		}
		
		public function get running():Boolean
		{
			return _running;
		}
		
		/* finalization */
		public function finalize():void
		{
			if(_timer != null)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, handleTimerComplete);
				_timer = null;
			}
			
			_args = null;
			
			_running = false;
			clean();
		}
		
		/* event handler */
		private function handleTimerComplete(e:TimerEvent):void
		{
			var args:Array = _args;
			var i:int = 0;
			var call:*;
			var param:*;
			
			while(i < args.length)
			{
				call = args[i];
				param = (i + 1) < args.length ? args[i + 1] : null;
				
				if(call is Function)
				{
					if((param as Array) != null)
					{
						call.apply(undefined, param);
						
						i += 2;
						continue;
					}
					else call.call(undefined);
				}
				
				i++;
			}
			
			// finalize
			finalize();
		}
	}
}
