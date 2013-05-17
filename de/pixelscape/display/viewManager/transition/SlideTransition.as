package de.pixelscape.display.viewManager.transition
{
	import com.greensock.TweenLite;

	import flash.geom.Point;

	/**
	 * @author tobiasfriese
	 */
	public class SlideTransition extends ViewTransition
	{
		/* variables */
		private var _direction:String;
		private var _duration:Number;
		private var _easing:Function;
		private var _delay:Number;
		
		/* constants */
		public static const DIRECTION_LEFT:String			= "left";		public static const DIRECTION_RIGHT:String			= "right";		public static const DIRECTION_UP:String				= "up";		public static const DIRECTION_DOWN:String			= "down";		public static const DIRECTION_AUTOMATIC_X:String	= "automaticX";		public static const DIRECTION_AUTOMATIC_Y:String	= "automaticY";
		
		public function SlideTransition(direction:String = "automaticX", duration:Number = .5, easing:Function = null, delay:Number = 0)
		{
			this._direction = direction;
			this._duration = duration;
			this._easing = easing;
			this._delay = delay;
		}
		
		override protected function onStart(forward:Boolean):void
		{
			var inPos:Point;			var outPos:Point;
			
			switch(this._direction)
			{
				case DIRECTION_LEFT:
					inPos = new Point(this.newView.canvasWidth, 0);
					if(this.oldView != null) outPos = new Point(-this.oldView.canvasWidth, 0);
					break;
					
				case DIRECTION_RIGHT:
					inPos = new Point(-this.newView.canvasWidth, 0);
					if(this.oldView != null) outPos = new Point(this.oldView.canvasWidth, 0);
					break;
					
				case DIRECTION_UP:
					inPos = new Point(0, this.newView.canvasHeight);
					if(this.oldView != null) outPos = new Point(0, -this.oldView.canvasHeight);
					break;
					
				case DIRECTION_DOWN:
					inPos = new Point(0, -this.newView.canvasHeight);
					if(this.oldView != null) outPos = new Point(0, this.oldView.canvasHeight);
					break;
				
				case DIRECTION_AUTOMATIC_X:
				default:
					
					if(forward)
					{
						inPos = new Point(this.newView.canvasWidth, 0);
						if(this.oldView != null) outPos = new Point(-this.oldView.canvasWidth, 0);
					}
					else
					{
						inPos = new Point(-this.newView.canvasWidth, 0);
						if(this.oldView != null) outPos = new Point(this.oldView.canvasWidth, 0);
					}
					
					break;
				
				case DIRECTION_AUTOMATIC_Y:
					
					if(forward)
					{
						inPos = new Point(0, this.newView.canvasHeight);
						if(this.oldView != null) outPos = new Point(0, -this.oldView.canvasHeight);
					}
					else
					{
						inPos = new Point(0, -this.newView.canvasHeight);
						if(this.oldView != null) outPos = new Point(0, this.oldView.canvasHeight);
					}
					
					break;
			}
			
			this.newView.x = inPos.x;			this.newView.y = inPos.y;
			
			if(oldView != null) TweenLite.to(oldView, _duration, {x:outPos.x, y:outPos.y, ease:_easing});
			TweenLite.to(newView, _duration, {x:0, y:0, ease:_easing, delay:_delay, onComplete:completeTransition});
		}
		
		private function completeTransition():void
		{
			// reset old
			if(oldView != null)
			{
				oldView.x = 0;
				oldView.y = 0;
			}
			
			// dispatch
			dispatchTransitionComplete();
		}
	}
}
