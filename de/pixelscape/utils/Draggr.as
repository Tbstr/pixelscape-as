package de.pixelscape.utils
{
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.output.notifier.Notifier;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Draggr extends Sprite
	{
		/* statics */
		private static var _instances:Vector.<Draggr> = new Vector.<Draggr>();
		
		/* variables */
		private var _selectedObject:DisplayObject;
		
		private var _target:DisplayObject;
		private var _stage:Stage;
		
		public function Draggr()
		{
			// cancellate
			if(TopLevelUtils.stage == null) return;
			
			// vars
			_stage = TopLevelUtils.stage;
			
			// init
			_stage.addChild(this);
			
			// start
			initTargetSelection();
			
			// add to onstances list
			_instances.push(this);
		}
		
		/* statics */
		public static function start():void
		{
			new Draggr();
		}
		
		/* init */
		
		private function initTargetSelection():void
		{
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, handleSelectMouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, handleSelectMouseDown);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, handleAbortKeyDown);
			
			Notifier.notify("DRAGGR\nselect target object and move");
		}
		
		private function initTarget(target:DisplayObject):void
		{
			// vars
			_target = target;
			
			// start
			FlashUtils.startDrag(target);
			_stage.addEventListener(MouseEvent.MOUSE_UP, handleMoveMouseUp);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, handleAbortKeyDown);
		}
		
		/* methods */
		private function redraw(rect:Rectangle):void
		{
			// cancellation
			if(rect == null) return;
			
			// draw
			clear();
			Picasso.drawFromRectangle(this, 0xff8000, .3, rect, 0, [1, 0xff8000, 2]);

		}
		
		private function clear():void
		{
			Picasso.clear(this);
		}
		
		private function report():void
		{
			var message:String = "DRAGGR\n\n";
			message += String(_target)+"\n\n";
			message += "x: "+_target.x;
			message += "\ny: "+_target.y;
			
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
					redraw(nearestObj.getBounds(_stage));
				}
			}
		}
		
		private function handleSelectMouseDown(e:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleSelectMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleSelectMouseDown);
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleAbortKeyDown);
			
			clear();
			initTarget(_selectedObject);
		}
		
		private function handleAbortKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == 27)
			{
				finalize();
				Notifier.notify("DRAGGR\naborted");
			}
		}
		
		private function handleMoveMouseUp(e:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_UP, handleMoveMouseUp);
			
			FlashUtils.stopDrag();			
			report();
			
			finalize();
		}
		
		/* finalization */
		public function finalize():void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleSelectMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleSelectMouseDown);
			
			_stage.removeEventListener(MouseEvent.MOUSE_UP, handleMoveMouseUp);
			
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleAbortKeyDown);
			
			FlashUtils.stopDrag();
			
			if(parent != null) parent.removeChild(this);
			
			_target = null;
			_stage = null;
		}
		
	}
}