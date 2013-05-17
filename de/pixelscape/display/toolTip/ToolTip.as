package de.pixelscape.display.toolTip 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;

	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Tobias Friese
	 */
	public class ToolTip extends Sprite 
	{
		/* variables */
		protected var _content:*;
		
		protected var _delay:Number;
		protected var _timer:Timer;
		
		public function ToolTip(content:*, delay:Number = 0)
		{
			this._content = content;
			this._delay = delay;
		}
		
		public function initialize():void
		{
			if(this._delay == 0) this.show();
			else
			{
				this._timer = new Timer(this._delay * 1000, 1);
				this._timer.addEventListener(TimerEvent.TIMER, this.show);
				this._timer.start();
			}
		}
		
		public function show(e:TimerEvent = null):void
		{
			TweenLite.to(this, .3, {alpha:1, ease:Cubic.easeOut});
		}
		
		public function hide(onComplete:Function = null):void
		{
			// timer
			if(_timer != null) if(_timer.running == true) _timer.stop();
			
			if(this.alpha == 0) onComplete();
			else TweenLite.to(this, .3, {alpha:0, ease:Cubic.easeOut, onComplete:onComplete});
		}
		
		public function finalize():void
		{
			// timer
			if(_timer != null) if(_timer.running == true) _timer.stop();
			
			// remove from display list
			if(parent != null) parent.removeChild(this);
		}
	}
}
