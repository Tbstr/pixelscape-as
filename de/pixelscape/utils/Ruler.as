package de.pixelscape.utils
{
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.output.notifier.Notifier;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Ruler extends Sprite
	{
		/* statics */
		private static var _instances:Vector.<Ruler> = new Vector.<Ruler>();
		
		/* variables */
		private var _selectedObject:DisplayObject;
		
		private var _target:DisplayObject;
		private var _stage:Stage;
		
		private var _selection:Rectangle = new Rectangle();
		
		public function Ruler(target:DisplayObject = null)
		{
			// cancellate
			if(TopLevelUtils.stage == null) return;
			
			// vars
			_stage = TopLevelUtils.stage;
			
			// init
			_stage.addChild(this);
			
			// start
			if(target != null) initTarget(target);
			else initTargetSelection();
			
			// add to onstances list
			_instances.push(this);
		}
		
		private function initTarget(target:DisplayObject):void
		{
			// vars
			_target = target;
			
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMeasureMouseDown);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, handleMeasureKeyDown);
			
			// notify start
			Notifier.notify('ruler started');
		}
		
		private function initTargetSelection():void
		{
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, handleSelectMouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, handleSelectMouseDown);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, handleSelectKeyDown);
			
			Notifier.notify('select target object space');
		}
		
		/* statics */
		public static function start(target:DisplayObject = null):void
		{
			new Ruler(target);
		}
		
		/* methods */
		private function redraw(rect:Rectangle, mode:int = 0):void
		{
			// cancellation
			if(rect == null) return;
			
			// clear
			clear();
			
			// draw
			switch(mode)
			{
				case 1:
					Picasso.drawFromRectangle(this, 0xff8000, .3, rect, 0, [1, 0xff8000, 2]);
					break;
				
				default:
					Picasso.drawFromRectangle(this, 0, .3, rect, 0, [1, 0xff8000, 1]);
					break;
			}
		}
		
		private function clear():void
		{
			Picasso.clear(this);
		}
		
		private function report():void
		{
			var localOrig:Point = _target.globalToLocal(_selection.topLeft);
			
			var message:String = '';
			message += "x: "+localOrig.x;
			message += "\ny: "+localOrig.y;
			message += "\nw: "+_selection.width;
			message += "\nh: "+_selection.height;
			
			Notifier.notify(message);
		}
		
		/* event handler */
		private function handleSelectMouseMove(e:MouseEvent):void
		{
			var objs:Array = _stage.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			
			var nearestObj:DisplayObject	= null;
			var nearestDist:Number			= Number.MAX_VALUE;
			
			var objBounds:Rectangle;
			var currDist:Number;
			
			for each(var obj:DisplayObject in objs)
			{
				objBounds = obj.getBounds(TopLevelUtils.stage);
				
				currDist = MathUtils.dist(e.stageX, e.stageY, objBounds.x + (objBounds.width * .5), objBounds.y + (objBounds.height * .5));
				if(currDist < nearestDist)
				{
					nearestObj = obj;
					nearestDist = currDist;
				}
			}
			
			if(nearestObj != null)
			{
				if(nearestObj !== _selectedObject)
				{
					_selectedObject = nearestObj;
					redraw(nearestObj.getBounds(_stage), 1);
				}
			}
		}
		
		private function handleSelectMouseDown(e:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleSelectMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleSelectMouseDown);
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleSelectKeyDown);
			
			clear();
			
			initTarget(_selectedObject);
		}
		
		private function handleSelectKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == 27) finalize();
		}
		
		private function handleMeasureMouseDown(e:MouseEvent):void
		{
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMeasureMouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, handleMeasureMouseUp);
			
			_selection.x = e.stageX;
			_selection.y = e.stageY;
			_selection.width = 0;
			_selection.height = 0;
		}
		
		private function handleMeasureMouseMove(e:MouseEvent):void
		{
			_selection.width = e.stageX - _selection.x;
			_selection.height = e.stageY - _selection.y;
			
			redraw(_selection);
		}
		
		private function handleMeasureMouseUp(e:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMeasureMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, handleMeasureMouseUp);
			
			report();
			clear();
		}
		
		private function handleMeasureKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == 27) finalize();
		}
		
		/* finalization */
		public function finalize():void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleSelectMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleSelectMouseDown);
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleSelectKeyDown);
			
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMeasureMouseDown);
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleMeasureKeyDown);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMeasureMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, handleMeasureMouseUp);

			if(parent != null) parent.removeChild(this);
			
			_target = null;
			_stage = null;
			
			Notifier.notify('ruler closed');
		}
		
	}
}