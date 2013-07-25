package de.pixelscape.ui.button 
{
	import de.pixelscape.graphics.Picasso;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * @author Baseclass for buttons.
	 */
	public class Button extends Sprite 
	{
		/* variables */
		private var _id:String;
		
		private var _mouseDownCoordinates:Point			= new Point();
		private var _draging:Boolean;
		private var _dispatchDragEvents:Boolean			= false;
		
		private var _highlight:Boolean;
		private var _enabled:Boolean					= true;
		
		private var _data:Object						= new Object();
		private var _actions:Vector.<ButtonAction>		= new Vector.<ButtonAction>();

		private var _hitArea:Sprite						= this as Sprite;

		public function Button(id:String = null)
		{
			_id = id;
			
			_hitArea.buttonMode = true;
			registerButtonListeners(_hitArea);
		}
		
		private function registerButtonListeners(target:EventDispatcher):void
		{
			target.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOverInternal);
			target.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOutInternal);
			target.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDownInternal);
		}
		
		private function unregisterButtonListeners(target:EventDispatcher):void
		{
			target.removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOverInternal);
			target.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOutInternal);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDownInternal);
			
			if(stage != null)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoveInternal);
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUpInternal);
			}
		}
		
		public function dummyInit(x:Number, y:Number, width:Number, height:Number):void
		{
			this.x = x;
			this.y = y;
			
			Picasso.drawRectangle(this, 0, 0, 0, 0, width, height);
		}
		
		/* action handling */
		public function addAction(eventType:String, functionCall:Function, ...arguments):void
		{
			_actions.push(new ButtonAction(eventType, functionCall, arguments));
		}
		
		private function executeEvents(eventType:String):void
		{
			for(var i:uint = 0; i < this._actions.length; i++)
			{
				if(ButtonAction(_actions[i]).eventType == eventType) ButtonAction(_actions[i]).execute();
			}
		}
		
		/* getter setter */
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			this._id = value;
		}
		
		public function get dispatchDragEvents():Boolean
		{
			return _dispatchDragEvents;
		}
		
		public function set dispatchDragEvents(value:Boolean):void
		{
			_dispatchDragEvents = value;
		}
		
		override public function get hitArea():Sprite
		{
			return this._hitArea;
		}
		
		override public function set hitArea(value:Sprite):void
		{
			if(value == _hitArea) return;
			if(value == null) return;
			
			unregisterButtonListeners(_hitArea);
			_hitArea.buttonMode = false;
			
			registerButtonListeners(value);
			value.buttonMode = true;
			
			super.hitArea = new Sprite();
			
			_hitArea = value;
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if(_enabled == value) return;
			
			_enabled = value;
			
			if(value)
			{
				registerButtonListeners(hitArea);
				buttonMode = true;
				setEnabled();
			}
			else
			{
				unregisterButtonListeners(hitArea);
				buttonMode = false;
				setDisabled();
			}
		}
		
		public function get highlight():Boolean
		{
			return _highlight;
		}
		
		public function set highlight(value:Boolean):void
		{
			if(_highlight == value) return;
			
			_highlight = value;
			
			if(value) setHighlight();
			else unsetHighlight();
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function get mouseDownCoordinates():Point
		{
			return _mouseDownCoordinates;
		}

		/* dispatch methods */
		private function dispatchMouseOver():void
		{
			executeEvents(ButtonEvent.MOUSE_OVER);
			dispatchEvent(new ButtonEvent(ButtonEvent.MOUSE_OVER, this));
		}
		
		private function dispatchMouseOut():void
		{
			executeEvents(ButtonEvent.MOUSE_OUT);
			dispatchEvent(new ButtonEvent(ButtonEvent.MOUSE_OUT, this));
		}
		
		private function dispatchDragOut():void
		{
			executeEvents(ButtonEvent.MOUSE_DRAG_OUT);
			dispatchEvent(new ButtonEvent(ButtonEvent.MOUSE_DRAG_OUT, this));
		}
		
		private function dispatchMouseDown():void
		{
			executeEvents(ButtonEvent.MOUSE_DOWN);
			dispatchEvent(new ButtonEvent(ButtonEvent.MOUSE_DOWN, this));
		}
		
		private function dispatchMouseUp():void
		{
			executeEvents(ButtonEvent.MOUSE_UP);
			dispatchEvent(new ButtonEvent(ButtonEvent.MOUSE_UP, this));
		}
		
		private function dispatchDragStart():void
		{
			executeEvents(ButtonEvent.DRAG_START);
			dispatchEvent(new ButtonEvent(ButtonEvent.DRAG_START, this));
		}
		
		private function dispatchDragProgress():void
		{
			executeEvents(ButtonEvent.DRAG_PROGRESS);
			dispatchEvent(new ButtonEvent(ButtonEvent.DRAG_PROGRESS, this));
		}
		
		private function dispatchDragEnd():void
		{
			executeEvents(ButtonEvent.DRAG_END);
			dispatchEvent(new ButtonEvent(ButtonEvent.DRAG_END, this));
		}
		
		/* event handler */
		private function handleMouseOverInternal(e:MouseEvent):void
		{
			setHover();
			dispatchMouseOver();
		}
		
		private function handleMouseOutInternal(e:MouseEvent):void
		{
			unsetHover();
			if(_draging) dispatchDragOut();
			dispatchMouseOut();
		}
		
		private function handleMouseDownInternal(e:MouseEvent):void
		{
			_mouseDownCoordinates.x = e.stageX;
			_mouseDownCoordinates.y = e.stageY;
			
			if(_dispatchDragEvents) stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoveInternal);			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUpInternal);
			
			// dispatch
			dispatchMouseDown();
		}

		private function handleMouseMoveInternal(e:MouseEvent):void
		{
			if(!_draging) 
			{
				_draging = true;
				dispatchDragStart();
			}
			
			dispatchDragProgress();
		}
		
		private function handleMouseUpInternal(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMoveInternal);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUpInternal);
			
			if(hitTestPoint(e.stageX, e.stageY))
			{
				dispatchMouseUp();
			}
			else if(_draging) 
			{
				_draging = false;
				dispatchDragEnd();
			}
		}
		
		/* child methods [to be overwritten] */
		protected function setEnabled():void
		{
		}
		
		protected function setDisabled():void
		{
		}
		
		protected function setHover():void
		{
		}
		
		protected function unsetHover():void
		{
		}
		
		protected function setHighlight():void
		{
		}
		
		protected function unsetHighlight():void
		{
		}
		
		/* finalization */
		public function finalize():void
		{
			// unregister listeners
			unregisterButtonListeners(_hitArea);
			
			// finalize actions
			for each(var action:ButtonAction in _actions) action.finalize();
		}
	}
}
