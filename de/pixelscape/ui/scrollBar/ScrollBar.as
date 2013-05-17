package de.pixelscape.ui.scrollBar 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import de.pixelscape.display.ScrollBox;
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.output.notifier.Notifier;
	import de.pixelscape.utils.MathUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedSuperclassName;
	

	/**
	 * @author Tobias Friese
	 */
	public class ScrollBar extends Sprite 
	{
		/* variables */
		private var _sizeRatio:Number						= 1;
		private var _positionRatio:Number					= 0;
		
		private var _scrollBox:ScrollBox;
		private var _scrollBoxOrientation:String			= "y";
		
		/* constants */
		public static const SIZE_CHANGED:String				= "sizeChanged";
		public static const POSITION_CHANGED:String			= "positionChanged";

		public function ScrollBar()
		{
		}
		
		/* scroll box management */
		public function appendScrollBox(scrollBox:ScrollBox, orientation:String = "y"):void
		{
			// clear old
			if(_scrollBox != null) unregisterScrollBoxListeners(_scrollBox);
			
			// set new
			_scrollBox = scrollBox;
			_scrollBoxOrientation = orientation;
			
			if(_scrollBox == null)
			{
				sizeRatio = 1;
				positionRatio = 0;
			}
			else
			{
				// retrieve
				getSizeFromScrollBox();
				getPositionFromScrollBox();
				
				// register listeners
				registerScrollBoxListeners(scrollBox);
			}
			
		}
		
		private function registerScrollBoxListeners(scrollBox:ScrollBox):void
		{
			scrollBox.addEventListener(ScrollBox.SIZE_CHANGED, this.handleScrollBoxSizeChanged);
			scrollBox.addEventListener(ScrollBox.POSITION_CHANGED, this.handleScrollBoxPositionChanged);
		}
		
		private function unregisterScrollBoxListeners(scrollBox:ScrollBox):void
		{
			scrollBox.removeEventListener(ScrollBox.SIZE_CHANGED, this.handleScrollBoxSizeChanged);
			scrollBox.removeEventListener(ScrollBox.POSITION_CHANGED, this.handleScrollBoxPositionChanged);
		}
		
		private function getSizeFromScrollBox():void
		{
			if(_scrollBox != null) sizeRatio = (_scrollBoxOrientation == "x") ? _scrollBox.sizeRatioX : _scrollBox.sizeRatioY;
		}
		
		private function getPositionFromScrollBox():void
		{
			if(_scrollBox != null) positionRatio = (_scrollBoxOrientation == "x") ? _scrollBox.positionRatioX : _scrollBox.positionRatioY;
		}
		
		public function update():void
		{
			getSizeFromScrollBox();
			getPositionFromScrollBox();
		}
		
		/* getter setter */
		public function get sizeRatio():Number
		{
			return _sizeRatio;
		}
		
		public function set sizeRatio(value:Number):void
		{
			// set
			_sizeRatio = MathUtils.constrain(value, 0, 1);
			
			// dispatch
			onSizeChanged();
			dispatchSizeChanged();
		}
		
		public function get positionRatio():Number
		{
			return _positionRatio;
		}
		
		public function set positionRatio(value:Number):void
		{
			// set
			_positionRatio = MathUtils.constrain(value, 0, 1);
			
			// dispatch
			onPositionChanged();
			dispatchPositionChanged();
		}
		
		public function get scrollBox():ScrollBox
		{
			return _scrollBox;
		}
		
		/* dispatch methods */
		private function dispatchSizeChanged():void
		{
			dispatchEvent(new Event(SIZE_CHANGED));
		}
		
		private function dispatchPositionChanged():void
		{
			// scroll box
			if(_scrollBox != null)
			{
				if(_scrollBoxOrientation == "x") _scrollBox.scrollXTo(_positionRatio, true, false);
				else _scrollBox.scrollYTo(_positionRatio, true, false);
			}
			
			// dispatch
			dispatchEvent(new Event(POSITION_CHANGED));
		}
		
		/* event handler */
		private function handleScrollBoxSizeChanged(e:Event):void
		{
			getSizeFromScrollBox();
		}
		
		private function handleScrollBoxPositionChanged(e:Event):void
		{
			getPositionFromScrollBox();
		}
		
		/* override handler */
		protected function onSizeChanged():void
		{
		}
		
		protected function onPositionChanged():void
		{
		}
		
		/* finalization */
		public function finalize():void
		{
		}
	}
}
