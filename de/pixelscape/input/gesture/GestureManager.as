package de.pixelscape.input.gesture 
{
	import de.pixelscape.graphics.brushes.StandardBrush;
	import de.pixelscape.utils.MathUtils;
	import de.pixelscape.utils.TopLevelUtils;

	import com.greensock.TweenLite;
	import com.greensock.easing.Sine;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Tobias Friese
	 */
	public class GestureManager extends EventDispatcher
	{
		/* variables */
		private var _stage:Stage							= TopLevelUtils.stage;		private var _recordTarget:DisplayObject;
		
		private var _segmentSize:Number;
		private var _actions:Array							= new Array();
		
		private var _records:Object							= new Object();
		
		private var _drawTraces:Boolean;		private var _traceContainer:DisplayObjectContainer;
		
		/* constants */
		private static const NUM_SECTORS:uint				= 8;
		private static const MIN_DIST:Number				= 8;		private static const MAX_COST:uint					= 5;
		
		private static const DIST:Function					= MathUtils.dist;
		private static const ATAN2:Function					= Math.atan2;		private static const FLOOR:Function					= Math.floor;		private static const ABS:Function					= Math.abs;		private static const MIN:Function					= Math.min;		private static const PI:Number						= Math.PI;		private static const TWO_PI:Number					= Math.PI * 2;
		
		public function GestureManager(recordTarget:DisplayObject = null)
		{
			// vars
			this.recordTarget = recordTarget;
			this._segmentSize = PI / (NUM_SECTORS * .5);
		}
		
		/* methods */
		public function addGesture(gestureCode:String, action:*):void
		{
			this._actions.push(new GestureAction(gestureCode, action));
		}
		
		private function execute(recID:String, gestureArray:Array, bounds:Rectangle):void
		{
			var costCache:uint = 100000;			var actionCache:GestureAction;
			
			var tmpCost:uint;
			var tmpAction:GestureAction;
			
			for(var i:int = 0; i < this._actions.length; i++)
			{
				tmpAction = this._actions[i];
				tmpCost = this.costLevenshtein(this._actions[i].gesture.array, gestureArray);
				
				if(tmpCost < costCache)
				{
					costCache = tmpCost;
					actionCache = tmpAction;
				}
			}
			
			if(actionCache != null)
			{
				if(costCache <= MAX_COST)
				{
					if(actionCache.action is Function) actionCache.action();
					this.dispatchMatch(recID, actionCache.action, bounds);
					return;
				}
			}
			
			// no match
			this.dispatchNoMatch(recID, bounds);
		}
		
		/* recording */
		public function recordStart(recID:String, x:Number, y:Number):void
		{
			if(this._records[recID] == undefined)
			{
				var rec:Object = new Object();
				rec.gIDCache = new Array();
				rec.recentCode = -1;
				rec.recentPosition = new Point(x, y);
				rec.gestureBounds = new Rectangle(x, y);
				
				if(this._drawTraces)
				{
					var brush:StandardBrush = new StandardBrush(2, 0xFFFFFF, .6);
					brush.start((this._traceContainer == null) ? this._stage : this._traceContainer, x, y);
					
					rec.traceBrush = brush;
				}
				
				this._records[recID] = rec;
				
				this.dispatchRecordStart(recID);
			}
			else throw new Error("Gesture recording with id '" + recID + "' is already running.");
		}
		
		public function recordUpdate(recID:String, x:Number, y:Number):void
		{
			if(this._records[recID] != undefined)
			{
				var rec:Object = this._records[recID];
				var recentPosition:Point = rec.recentPosition;
				var bounds:Rectangle = rec.gestureBounds;
				
				if(DIST(x, y, recentPosition.x, recentPosition.y) >= MIN_DIST)
				{
					var angle:Number = (ATAN2(y - recentPosition.y, x - recentPosition.x) + TWO_PI + (this._segmentSize * .5)) % TWO_PI;
					var code:int = FLOOR(angle / this._segmentSize);
					
					if(code != rec.recentCode)
					{
						rec.gIDCache.push(code);
						rec.recentCode = code;
					}
					
					// bounds
					if(bounds.left > x) bounds.left = x;					if(bounds.right < x) bounds.right = x;
					if(bounds.top > y) bounds.top = y;
					if(bounds.bottom < y) bounds.bottom = y;
					
					// trace
					if(rec.hasOwnProperty("traceBrush")) rec.traceBrush.draw(x, y);
					
					// restore
					recentPosition.x = x;
					recentPosition.y = y;
				}
			}
			else throw new Error("No recording with id '" + recID + "' running.");
		}
		
		public function recordEnd(recID:String):void
		{
			if(this._records[recID] != undefined)
			{
				var rec:Object = this._records[recID];
				
				this.dispatchRecordStop(recID, rec.gestureBounds);
				this.execute(recID, rec.gIDCache, rec.gestureBounds);
				
				// remove trace
				if(rec.hasOwnProperty("traceBrush"))
				{
					var display:Shape = rec.traceBrush.display;
					TweenLite.to(display, .3, {alpha:0, ease:Sine.easeIn, onComplete:display.parent.removeChild, onCompleteParams:[display]});
				}
				
				// clean up
				this._records[recID] = null;				delete this._records[recID];			}
			else throw new Error("No recording with id '" + recID + "' running.");
		}
		
		/* listeners */
		private function registerRecordListeners(recordTarget:DisplayObject):void
		{
			recordTarget.addEventListener(MouseEvent.MOUSE_DOWN, this.handleRecordMouseDown);
		}
		
		private function unregisterRecordListeners(recordTarget:DisplayObject):void
		{
			recordTarget.removeEventListener(MouseEvent.MOUSE_DOWN, this.handleRecordMouseDown);
		}
		
		/* levenshtein cost */
		private function costLevenshtein(a:Array, b:Array):uint
		{
			// point
			if(a[0] == -1) return b.length == 0 ? 0 : 100000;
			
			// precalc difangles
			var d:Array = this.fill2DTable(a.length + 1, b.length + 1, 0);
			var w:Array = d.slice();
			
			for(var x:uint = 1; x <= a.length; x++)
			{
				for(var y:uint = 1; y < b.length; y++)
				{
					d[x][y] = difAngle(a[x - 1], b[y - 1]);
				}
			}
			
			// max cost
			for(y = 1; y <= b.length; y++) w[0][y] = 100000;
			for(x = 1; x <= a.length; x++) w[x][0] = 100000;
			w[0][0] = 0;
			
			// levenshtein application
			var cost:uint = 0;
			var pa:uint;
			var pb:uint;
			var pc:uint;
			
			for(x = 1; x <= a.length; x++)
			{
				for(y = 1; y < b.length; y++)
				{
					cost = d[x][y];
					pa = w[x - 1][y] + cost;
					pb = w[x][y - 1] + cost;
					pc = w[x - 1][y - 1] + cost;
					w[x][y] = MIN(MIN(pa, pb), pc);
				}
			}
			
			return w[x - 1][y - 1];
		}

		private function fill2DTable(w:uint, h:uint, f:*):Array
		{
			var o:Array = new Array(w);
			for(var x:uint = 0; x < w; x++)
			{
				o[x] = new Array(h);
				for(var y:uint = 0; y < h; y++) o[x][y] = f;
			}
			
			return o;
		}

		private function difAngle(a:uint, b:uint):uint
		{
			var dif:uint = ABS(a - b);
			if(dif > NUM_SECTORS * .5) dif = NUM_SECTORS - dif;
			
			return dif;
		}

		/* getter setter */
		public function get recordTarget():DisplayObject
		{
			return this._recordTarget;
		}
		
		public function set recordTarget(value:DisplayObject):void
		{
			if(this._recordTarget != null) this.unregisterRecordListeners(this._recordTarget);
			
			if(value != null)
			{
				this._recordTarget = value;
				this.registerRecordListeners(this._recordTarget);
			}
			else this._recordTarget = null;
		}
		
		public function get drawTraces():Boolean
		{
			return this._drawTraces;
		}
		
		public function set drawTraces(value:Boolean):void
		{
			this._drawTraces = value;
		}
		
		public function get traceContainer():DisplayObjectContainer
		{
			return this._traceContainer;
		}

		public function set traceContainer(value:DisplayObjectContainer):void
		{
			this._traceContainer = value;
		}
		
		/* dispatch methods */
		private function dispatchMatch(id:String, value:*, bounds:Rectangle = null):void
		{
			this.dispatchEvent(new GestureManagerEvent(GestureManagerEvent.GESTURE_MATCH, id,	value, bounds));
		}
		
		private function dispatchNoMatch(id:String, bounds:Rectangle = null):void
		{
			this.dispatchEvent(new GestureManagerEvent(GestureManagerEvent.GESTURE_NO_MATCH, id,	null, bounds));
		}
		
		private function dispatchRecordStart(id:String):void
		{
			this.dispatchEvent(new GestureManagerEvent(GestureManagerEvent.GESTURE_RECORD_START, id, null));
		}
		
		private function dispatchRecordStop(id:String, bounds:Rectangle = null):void
		{
			this.dispatchEvent(new GestureManagerEvent(GestureManagerEvent.GESTURE_RECORD_STOP, id, null, bounds));
		}
		
		/* finalization */
		public function finalize():void
		{
			this._stage = null;
			
			if(this._recordTarget != null)
			{
				this.unregisterRecordListeners(this.recordTarget);
				this._recordTarget = null;
			}
		}
		
		/* event handler */
		private function handleRecordMouseDown(e:MouseEvent):void
		{
			this.recordStart("default", e.stageX, e.stageY);
			
			// liseners
			this._stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleRecordMouseMove);			this._stage.addEventListener(MouseEvent.MOUSE_UP, this.handleRecordMouseUp);
		}
		
		private function handleRecordMouseMove(e:MouseEvent):void
		{
			this.recordUpdate("default", e.stageX, e.stageY);
		}

		private function handleRecordMouseUp(e:MouseEvent):void
		{
			this._stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleRecordMouseMove);
			this._stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleRecordMouseUp);
			
			this.recordEnd("default");
		}
	}
}
