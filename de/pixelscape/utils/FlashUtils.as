package de.pixelscape.utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.Font;
	
	import de.pixelscape.output.notifier.Notifier;

	/**
	 * @author tobias.friese
	 */
	public class FlashUtils 
	{
		/* variables */
		private static var _dragMouseOrigin:Point		= null;
		private static var _dragObject:DisplayObject	= null;
		private static var _dragObjectOrigin:Point		= null;
		private static var _dragging:Boolean 			= false;
		
		public static function getParentByClass(displayObject:DisplayObject, parentClassType:Class):DisplayObjectContainer
		{
			var parent:DisplayObjectContainer = displayObject.parent;
			while(parent != null)
			{
				if(parent is parentClassType) return parent;
				parent = parent.parent;
			}
			
			return null;
		}
		
		public static function getObjectUnderPoint(container:DisplayObjectContainer, point:Point, classRestriction:Class = null):*
		{
			var underPoint:Array = container.getObjectsUnderPoint(point);
			var object:DisplayObject;
			
			if(classRestriction == null) return underPoint[underPoint.length - 1];
			else
			{
				var i:int = underPoint.length;
				while(--i > -1)
				{
					if(underPoint[i] is classRestriction) object = underPoint[i];
					else object = getParentByClass(underPoint[i], classRestriction);
					
					if(object != null) return object;
				}
			}
			
			return null;
		}
		
		public static function copyProperties(target:*, source:Object):*
		{
			if(target != null) if(source != null) for(var key:String in source) target[key] = source[key];
			return target;
		}
		
		public static function setProperties(object:*, properties:Object):*
		{
			if(object != null)
			{
				if(properties != null)
				{
					for(var key:String in properties)
					{
						if(key in object)
						{
							if(!(object[key] is Function)) object[key] = properties[key];
						}
					}
				}
			}
			
			return object;
		}
		
		public static function secureRemove(container:DisplayObjectContainer, object:DisplayObject):Boolean
		{
			if(object.parent === container)
			{
				container.removeChild(object);
				return true;
			}
			
			return false;
		}
		
		public static function stopAll(content:DisplayObjectContainer):void
		{
			// stop if mc
			if(content is MovieClip) MovieClip(content).stop();
			
			// stop subs
			if(content.numChildren != 0)
			{
				var child:DisplayObject;
				for(var i:int = 0, n:int = content.numChildren; i < n; i++)
				{
					child = content.getChildAt(i);
					if(child is DisplayObjectContainer) stopAll(DisplayObjectContainer(child));
				}
			}
		}
		
		public static function clearContainer(container:DisplayObjectContainer):void
		{
			if(container == null) return;
			while(container.numChildren != 0) container.removeChildAt(0);
		}
		
		public static function listFonts(deviceFonts:Boolean = false):void
		{
			var out:String = '';
			var fonts:Array = Font.enumerateFonts(deviceFonts);
			
			for each(var font:Font in fonts)
			{
				out += font.fontName + ', ' + font.fontStyle + ', ' + font.fontType + "\n";
			}
			
			Notifier.notify(out);
		}
		
		/* dragging */
		public static function makeDraggable(object:DisplayObject):void
		{
			// cancellation
			if(object == null) return;
			
			// set listener
			object.addEventListener(MouseEvent.MOUSE_DOWN, handleDragMouseDown);
		}
		
		public static function makeUndraggable(object:DisplayObject):void
		{
			// cancellation
			if(object == null) return;
			
			// set listener
			object.removeEventListener(MouseEvent.MOUSE_DOWN, handleDragMouseDown);
		}
		
		public static function startDrag(object:DisplayObject):void
		{
			// cancellation
			if(TopLevelUtils.stage == null) return;
			if(_dragging) return;
			
			// set vars
			var stage:Stage = TopLevelUtils.stage;
			
			_dragObject = object;
			
			_dragMouseOrigin = new Point(stage.mouseX, stage.mouseY);
			_dragObjectOrigin = new Point(_dragObject.x, _dragObject.y);
			
			// set listeners
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDragMouseMove);
			
			// set vars
			_dragging = true;
		}
		
		public static function stopDrag():void
		{
			// remove listeners
			TopLevelUtils.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDragMouseMove);
			
			// set vars
			_dragMouseOrigin = null;
			_dragObjectOrigin = null;
			_dragObject = null;
			
			_dragging = false;
		}
		
		public static function handleDragMouseDown(e:MouseEvent):void
		{
			// start drag
			startDrag(DisplayObject(e.currentTarget));
			
			// add listener
			TopLevelUtils.stage.addEventListener(MouseEvent.MOUSE_UP, handleDragMouseUp);
		}
		
		public static function handleDragMouseMove(e:MouseEvent):void
		{
			var stage:Stage = TopLevelUtils.stage;
			
			_dragObject.x  = _dragObjectOrigin.x + (stage.mouseX - _dragMouseOrigin.x);
			_dragObject.y  = _dragObjectOrigin.y + (stage.mouseY - _dragMouseOrigin.y);
		}
		
		public static function handleDragMouseUp(e:MouseEvent):void
		{
			// remove listener
			TopLevelUtils.stage.removeEventListener(MouseEvent.MOUSE_UP, handleDragMouseUp);
			
			// stop drag
			stopDrag();
		}
	}
}
