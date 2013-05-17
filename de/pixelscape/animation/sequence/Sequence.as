package de.pixelscape.animation.sequence
{
	import de.pixelscape.output.notifier.Notification;
	import de.pixelscape.output.notifier.Notifier;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * The Sequence class calls functions on or applies functions to Objects, defined in an <code>Array</code> with a certain time delay.
	 * This makes chainreaction-like animations and actions possible.
	 * 
	 * @author Tobias Friese
	 * 
	 * @version 1.4
	 * 
	 * recent changes 08.03.2010
	 */
	public class Sequence extends EventDispatcher
	{
		/* statics */
		private static var _sequences:Array = new Array();
		
		/* variables */
		private var _objects:Array;
		private var _delay:Number;
		private var _interval:Number;
		private var _type:String;
		
		private var _gatherFunc:Function;
		
		private var _functionName:String;
		private var _functionArguments:Array;
		
		private var _timer:Timer;
		private var _delayTimer:Timer;
		
		private var _running:Boolean;
		private var _finalized:Boolean;
		
		private var _data:Object								= new Object();
		
		/**
		 * Sequence constructor
		 * 
		 * @param objects		an Array referencing the objects to threaten
		 * @param type			a <code>String</code> defining the execution order (linear, linear-reverse, or random)
		 * @param interval		the delay between the executions in seconds
		 * 
		 * @param objectFunctionCall		optional, a method of the current processed object can be called, method name as String
		 * @param objectFunctionArguments	arguments for the optional object function call
		 */
		public function Sequence(objects:*, delay:Number, interval:Number, functionName:String = null, arguments:Array = null, type:String = "linear")
		{
			
			// objects
			if(objects is Array) _objects = objects.concat();
			
			if(objects is Vector.<*>)
			{
				_objects = new Array();
				for each(var element:* in objects) _objects.push(element);
			}
			
			if(_objects == null) return;
			
			// vars
			this._delay = delay;
			this._interval = interval * 1000;
			this._type = type;
			
			this._functionName = functionName;
			this._functionArguments = arguments;
			
			// timer
			this._timer = new Timer(this._interval);
			this._timer.addEventListener(TimerEvent.TIMER, this.handleTimerTimer);
		}
		
		/* static methods */
		public static function create(objects:*, delay:Number, interval:Number, functionName:String = null, arguments:Array = null, type:String = "linear"):Sequence
		{
			var seq:Sequence = new Sequence(objects, delay, interval, functionName, arguments, type);
			seq.addEventListener(SequenceEvent.COMPLETE, handleSequenceComplete);
			seq.start();
			
			_sequences.push(seq);
			return seq;
		}
		
		public static function checkSequences():void
		{
			var seq:Sequence;
			for(var i:int = _sequences.length - 1; i >= 0; i--)
			{
				seq = _sequences[i];
				
				if(!seq.running)
				{
					seq.finalize();
					_sequences.splice(i, 1);
				}
			}
		}

		/* object methods */
		public function start():void 
		{
			if(!this._running)
			{
				if(this._delay == 0) this.init();
				else
				{
					this._delayTimer = new Timer(this._delay * 1000, 1);
					this._delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.handleDelayTimerComplete);
					this._delayTimer.start();
				}
				
				this._running = true;
			}
			else throw new Error("Sequence is already running.");
		}

		private function init():void
		{
			// set gather function
			switch(this._type)
			{
				case SequenceType.LINEAR_REVERSE:
					this._gatherFunc = this.gatherLinearReverse;
					break;
					
				case SequenceType.RANDOM:
					this._gatherFunc = this.gatherRandom;
					break;
					
				default:
					this._gatherFunc = this.gatherLinear;
					break;
			}
			
			// start
			this._timer.start();
			this.exec(this._gatherFunc());
		}
		
		/* gather functions */
		private function gatherLinear():Object
		{
			return this._objects.shift();
		}
		
		private function gatherLinearReverse():Object
		{
			return this._objects.pop();
		}
		
		private function gatherRandom():Object
		{
			var index:uint = Math.round(Math.random() * (this._objects.length - 1));
			var obj:Object = this._objects[index];
			
			this._objects.splice(index, 1);
			
			return obj;
		}
		
		/* execution */
		private function exec(obj:*):void
		{
			// object function call
			if(this._functionName != null)
			{
				if(this._functionName in obj)
				{
					if(obj[this._functionName] is Function) obj[this._functionName].apply(obj, this._functionArguments);
					else obj[this._functionName] = this._functionArguments[0];
				}
			}
			
			// dispatch
			this.dispatchEvent(new SequenceEvent(SequenceEvent.STEP, this, obj, this._objects.length == 0));
			if(this._objects.length == 0)
			{
				// finalize
				this._timer.stop();
				this.finalize();
				this._running = false;
				
				this.dispatchEvent(new SequenceEvent(SequenceEvent.COMPLETE, this, obj, true));
			}
		}
		
		private function killDelayTimer():void
		{
			if(this._delayTimer != null)
			{
				this._delayTimer.stop();
				this._delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.handleDelayTimerComplete);
				this._delayTimer = null;
			}
		}
		
		/* getter setter */
		public function get data():Object
		{
			return _data;
		}
		
		public function get running():Boolean
		{
			return this._running;
		}
		
		/* finalization */
		public function finalize():void
		{
			if(this._finalized) return;
			
			// stop
			this.killDelayTimer();
			
			if(this._timer.running) this._timer.stop();
			this._timer.removeEventListener(TimerEvent.TIMER, this.handleTimerTimer);
			
			// kill variables
			this._objects = null;
			this._timer = null;
			
			this._finalized = true;
		}
		
		/* event handler */
		private static function handleSequenceComplete(e:SequenceEvent):void
		{
			checkSequences();
		}
		
		private function handleDelayTimerComplete(e:TimerEvent):void
		{
			this._delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.handleDelayTimerComplete);
			this._delayTimer = null;
			
			this.init();
		}

		private function handleTimerTimer(e:TimerEvent):void
		{
			// execute
			this.exec(this._gatherFunc());
		}
	}
}