package de.pixelscape.display
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.output.notifier.Notifier;
	import de.pixelscape.utils.MathUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * This class provides functionality for displaying and scrolling
	 * any type of display data in a specified area.
	 * 
	 * This is very useful for scrollable text, images, a.s.o.
	 * 
	 * @author Tobias Friese
	 * 
	 * @version 1.2
	 * 
	 * recent change: 14.01.2009
	 */
	public class ScrollBox extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		
		private var _transition:Function					= Cubic.easeOut;
		private var _time:Number							= .5;
		
		private var _positionX:Number						= 0;
		private var _positionY:Number						= 0;
		
		private var _pixelHinting:Boolean					= false;
		private var _maskEnabled:Boolean					= true;
		
		private var _mouseWheelEnabled:Boolean				= false;
		private var _mouseWheelDirection:String				= "wheelDirectionY";
		private var _mouseWheelSpeed:Number					= 50;
		
		public var data:*;
		
		/* architecture */
		private var _container:Sprite;
		private var _mask:Shape;
		
		/* constants */
		public static const WHEEL_DIRECTION_X:String		= "wheelDirectionX";		public static const WHEEL_DIRECTION_Y:String		= "wheelDirectionY";
		
		public static const POSITION_CHANGED:String			= "positionChanged";		public static const SIZE_CHANGED:String				= "sizeChanged";
		
		/**
		 * ScrollBox constructor
		 * 
		 * @param width the width of the visible scroll area		 * @param height the height of the visible scroll area
		 */
		public function ScrollBox(width:Number, height:Number)
		{
			// vars
			this._width		= width;
			this._height	= height;
			
			// build
			this.build();
			
			// event listener
			this.registerEventListeners();
		}
		
		private function build():void
		{
			// background
			Picasso.drawRectangle(this, 0, 0, 0, 0, this._width, this._height);
			
			// container
			this._container = new Sprite();
			super.addChild(this._container);
			
			// mask
			this._mask = new Shape();
			Picasso.drawRectangle(this._mask, 0, 1, 0, 0, this._width, this._height);
			this._container.mask = this._mask;
			super.addChild(this._mask);
		}
		
		private function registerEventListeners():void
		{
			this.addEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage);
		}
		
		private function unregisterEventListeners():void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.handleRemovedFromStage);
			
			if(this.stage != null) this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel);
		}
		
		public function resize(width:Number, height:Number):void
		{
			// set var
			this._width = width;
			this._height = height;
			
			// draw
			Picasso.clear(this._mask);
			Picasso.drawRectangle(this._mask, 0, 1, 0, 0, width, height);
			
			this.checkBounds();
			this.dispatchSizeChanged();
		}
			
		/* getter setter */
		
		/** returns the initially defined width of this ScrollBox */
		override public function get width():Number
		{
			return this._width;
		}
		
		/** sets a new width of the display area */
		override public function set width(value:Number):void
		{
			this.resize(value, this._height);
		}
		
		/** returns the initially defined height of this ScrollBox */
		override public function get height():Number
		{
			return this._height;
		}
		
		/** sets a new height of the display area */
		override public function set height(value:Number):void
		{
			this.resize(this._width, value);
		}
		
		/** returns the amount of DisplayObjects that are child of the container */
		override public function get numChildren():int
		{
			return this._container.numChildren;
		}
		
		/** returns a boolean that defines if mouse wheel scrolling is enabled or not */
		public function get mouseWheelEnabled():Boolean
		{
			return this._mouseWheelEnabled;
		}
		
		/** specifies whether this instance should be affected by mousewheel scrolling or not */
		public function set mouseWheelEnabled(value:Boolean):void
		{
			if(this._mouseWheelEnabled != value)
			{
				this._mouseWheelEnabled = value;
				
				if(value == true)
				{
					if(stage != null) stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel);
				}
				else
				{
					if(stage != null) stage.removeEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel);
				}
			}
		}
		
		/** returns the mousewheel scrolling direction as String */
		public function get mouseWheelDirection():String
		{
			return this._mouseWheelDirection;
		}
		
		/** defines the scrolling-direction the mousewheel should scroll*/
		public function set mouseWheelDirection(value:String):void
		{
			this._mouseWheelDirection = value;
		}
		
		/** returns the speed for mouse scrolling in pixels */
		public function get mouseWheelScrollSpeed():Number
		{
			return this._mouseWheelSpeed;
		}
		
		/** defines the scrolling speed for the mouse wheel in pixel*/
		public function set mouseWheelScrollSpeed(value:Number):void
		{
			this._mouseWheelSpeed = value;
		}

		private function get absoluteContainerWidth():Number
		{
			var bounds:Rectangle = this._container.getBounds(this._container);
			
			return (bounds.x + bounds.width);
		}
		
		private function get absoluteContainerHeight():Number
		{
			var bounds:Rectangle = _container.getBounds(_container);
			
			return (bounds.y + bounds.height);
		}
		
		public function get contentWidth():Number
		{
			return absoluteContainerWidth;
		}
		
		public function get contentHeight():Number
		{
			return absoluteContainerHeight;
		}
		
		/** returns the container instance for manual manipulation */
		public function get container():Sprite
		{
			return this._container;
		}
		
		/** returns a ratio value defining relationship from displayed width to total width*/
		public function get sizeRatioX():Number
		{
			return (this._width / absoluteContainerWidth);
		}
		
		/** returns a ratio value defining relationship from displayed height to total height*/
		public function get sizeRatioY():Number
		{
			return (this._height / absoluteContainerHeight);
		}
		
		/** returns a ratio value defining relationship from actual x-position to maximum x-position*/
		public function get positionRatioX():Number
		{
			return (this._positionX / (this._width - absoluteContainerWidth));
		}
		
		/** returns a ratio value defining relationship from actual y-position to maximum y-position*/
		public function get positionRatioY():Number
		{
			return (this._positionY / (this._height - absoluteContainerHeight));
		}
		
		/** returns whether this instance is scrollable in x-direction */
		public function get scrollableX():Boolean
		{
			if(absoluteContainerWidth > this._width) return true;
			return false;
		}
		
		/** returns whether this instance is scrollable in y-direction */
		public function get scrollableY():Boolean
		{
			if(absoluteContainerHeight > this._height) return true;
			return false;
		}
		
		/** returns whether the viewable area should is through a mask or not*/
		public function get maskEnabled():Boolean
		{
			return _maskEnabled;
		}
		
		/** specifies whether the viewable area should be limited through a mask or not (default: true)*/
		public function set maskEnabled(value:Boolean):void
		{
			if(_maskEnabled == value) return;
			_maskEnabled = value;
			
			if(value)
			{
				super.addChild(this._mask);
				this._container.mask = this._mask;
			}
			else
				
			{
				this._container.mask = null;
				super.removeChild(this._mask);
			}
		}

		/* child adding routines for container */
		
		/** 
		 * adds a new DisplayObject to the scroll-container
		 * 
		 * @param child the DisplayObject to add to the scroll-container
		 */
		override public function addChild(child:DisplayObject):DisplayObject
		{
			return this._container.addChild(child);
			
			this.dispatchSizeChanged();
		}
		
		/** 
		 * adds a new DisplayObject to the scroll-container at a defined depth-index
		 * 
		 * @param child the DisplayObject to add to the scroll-container
		 * @param index the depth index to set the new child to
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			return this._container.addChildAt(child, index);
			
			this.dispatchSizeChanged();
		}
		
		/** 
		 * removes a DisplayObject from the scroll-container
		 * 
		 * @param child the DisplayObject to be removed
		 */
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			return this._container.removeChild(child);
			
			this.dispatchSizeChanged();
		}
		
		/** 
		 * removes the DisplayObject at a defined depth from the container
		 * 
		 * @param index the depth index of the DisplayObject to remove
		 */
		override public function removeChildAt(index:int):DisplayObject
		{
			return this._container.removeChildAt(index);
			
			this.dispatchSizeChanged();
		}
		
		/** 
		 * returns the DisplayObject at a defined depth from the container
		 * 
		 * @param index the depth index of the DisplayObject to get
		 */
		override public function getChildAt(index:int):DisplayObject
		{
			return this._container.getChildAt(index);
		}
		
		/** 
		 * removes all childs and drawen graphics from the container
		 */
		public function clearContainer():void
		{
			this._container.graphics.clear();
			
			while(this._container.numChildren > 0)
			{
				this._container.removeChildAt(0);
			}
			
			checkBounds();
			this.dispatchSizeChanged();
		}
		
		/* other methods */
		
		/**
		 * Sets the tweening parameters.
		 * 
		 * @param transition the transition name or function of the movement
		 * @param time the duration for the animation
		 */
		public function setTween(transition:Function, time:Number):void
		{
			this._transition = transition;
			this._time = time;
		}
		
		/**
		 * Checks the actual state of this instance for possibly
		 * illegal arrangements and corrects them.
		 * 
		 * Prevents from ugly appeareance when display data has been changed
		 * from outside.
		 */
		public function checkBounds():void
		{
			// x
			if(this.scrollableX)
			{
				if(this._container.x < (this._width - this.absoluteContainerWidth))
				{
					this._positionX = this._width - this.absoluteContainerWidth;
					this._container.x = this._pixelHinting ? Math.round(this._positionX) : this._positionX;
				}
			}
			else this._positionX = this._container.x = 0;
			
			// y
			if(this.scrollableY)
			{
				if(this._container.y < (this._height - this.absoluteContainerHeight))
				{
					this._positionY = this._height - this.absoluteContainerHeight;
					this._container.y = (this._pixelHinting) ? Math.round(this._positionY) : this._positionY;
				}
			}
			else this._positionY = this._container.y = 0;
		}
		
		/* scrolling methods */
		
		/**
		 * Scrolls by certain pixels in x and y direction.
		 * 
		 * @param stepX scroll distance in x direction (in pixel)
		 * @param stepY scroll distance in y direction (in pixel)
		 * @param tween defines whether the scrolling should be animated or instant
		 */
		public function scrollBy(stepX:Number, stepY:Number, tween:Boolean = true, dispatch:Boolean = true):void
		{
			this.scrollXBy(stepX, tween, false);
			this.scrollYBy(stepY, tween, false);
			
			if(dispatch) this.dispatchPositionChanged();
		}
		
		/**
		 * Scrolls by certain pixels in x direction.
		 * 
		 * @param stepX scroll distance in x direction (in pixel)
		 * @param tween defines whether the scrolling should be animated or instant
		 */
		public function scrollXBy(stepX:Number, tween:Boolean = true, dispatch:Boolean = true):void
		{
			stepX *= -1;
			
			if(this.scrollableX)
			{
				if(stepX != 0)
				{
					this._positionX = MathUtils.constrain(this._positionX + stepX, this._width - this.absoluteContainerWidth, 0);
					
					if(this._container.x != this._positionX)
					{
						var tPos:Number = this._pixelHinting ? Math.round(this._positionX) : this._positionX;
						
						if(tween) TweenLite.to(this._container, this._time, {x:tPos, ease:this._transition});
						else this._container.x = tPos;
					}
					
					if(dispatch) this.dispatchPositionChanged();
				}
			}
		}
		
		/**
		 * Scrolls by certain pixels in y direction.
		 * 
		 * @param stepY scroll distance in y direction (in pixel)
		 * @param tween defines whether the scrolling should be animated or instant
		 */
		public function scrollYBy(stepY:Number, tween:Boolean = true, dispatch:Boolean = true):void
		{
			stepY = -stepY;
			
			if(this.scrollableY)
			{
				if(stepY != 0)
				{
					this._positionY = MathUtils.constrain(this._positionY + stepY, this._height - this.absoluteContainerHeight, 0);
					
					if(this._container.y != this._positionY)
					{
						var tPos:Number = this._pixelHinting ? Math.round(this._positionY) : this._positionY;
						
						if(tween) TweenLite.to(this._container, this._time, {y:tPos, ease:this._transition});
						else this._container.y = tPos;
					}
					
					if(dispatch) this.dispatchPositionChanged();
				}
			}
		}
		
		/**
		 * Scrolls to a defined position in x and y direction.
		 * 
		 * @param ratioX target position in x direction (ratio from 0 to 1)
		 * @param ratioY target position in y direction (ratio from 0 to 1)
		 * @param tween defines whether the scrolling should be animated or instant
		 */
		public function scrollTo(ratioX:Number, ratioY:Number, tween:Boolean = true, dispatch:Boolean = true):void
		{
			this.scrollXTo(ratioX, tween, false);
			this.scrollYTo(ratioY, tween, false);
			
			if(dispatch) this.dispatchPositionChanged();
		}
		
		/**
		 * Scrolls to a defined position in x direction.
		 * 
		 * @param ratio target position in x direction (ratio from 0 to 1)
		 * @param tween defines whether the scrolling should be animated or instant
		 */
		public function scrollXTo(ratio:Number, tween:Boolean = true, dispatch:Boolean = true):void
		{
			if(this.scrollableX)
			{
				// constrain
				ratio = MathUtils.constrain(ratio, 0, 1);
				
				// calculate
				this._positionX = (this._width - this.absoluteContainerWidth) * ratio;
				
				// move
				var tPos:Number = this._pixelHinting ? Math.round(this._positionX) : this._positionX;
				
				if(tween) TweenLite.to(this._container, this._time, {x:tPos, ease:this._transition});
				else this._container.x = tPos;
				
				if(dispatch) this.dispatchPositionChanged();
			}
		}
		
		/**
		 * Scrolls to a defined position in y direction.
		 * 
		 * @param ratio target position in y direction (ratio from 0 to 1)
		 * @param tween defines whether the scrolling should be animated or instant
		 */
		public function scrollYTo(ratio:Number, tween:Boolean = true, dispatch:Boolean = true):void
		{
			if(this.scrollableY)
			{
				// constrain
				ratio = MathUtils.constrain(ratio, 0, 1);
				
				// calculate
				this._positionY = (this._height - this.absoluteContainerHeight) * ratio;
				
				// move
				var tPos:Number = this._pixelHinting ? Math.round(this._positionY) : this._positionY;
				
				if(tween) TweenLite.to(this._container, this._time, {y:tPos, ease:this._transition});
				else this._container.y = tPos;
				
				if(dispatch) this.dispatchPositionChanged();
			}
		}
		
		/* finalization */
		public function finalize():void
		{
			this.unregisterEventListeners();
		}
		
		/* event dispatcher */
		private function dispatchPositionChanged():void
		{
			this.dispatchEvent(new Event(POSITION_CHANGED));
		}
		
		private function dispatchSizeChanged():void
		{
			this.dispatchEvent(new Event(SIZE_CHANGED));
		}
		
		/* event handler */
		private function handleAddedToStage(e:Event):void
		{
			if(this._mouseWheelEnabled) this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel);
		}

		private function handleRemovedFromStage(e:Event):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, this.handleMouseWheel);
		}
		
		private function handleMouseWheel(e:MouseEvent):void
		{
			if(this._mask.hitTestPoint(stage.mouseX, stage.mouseY))
			{
				if(e.delta > 0)
				{
					if(this._mouseWheelDirection == WHEEL_DIRECTION_X) this.scrollXBy(-this._mouseWheelSpeed);
					else this.scrollYBy(-this._mouseWheelSpeed);
					
				}
				else if(e.delta < 0)
				{
					if(this._mouseWheelDirection == WHEEL_DIRECTION_X) this.scrollXBy(this._mouseWheelSpeed);
					else this.scrollYBy(this._mouseWheelSpeed);
				}
			}
		}
	}
}