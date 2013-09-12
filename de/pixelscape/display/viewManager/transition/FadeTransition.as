package de.pixelscape.display.viewManager.transition
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Ease;

	/**
	 * @author tobiasfriese
	 */
	public class FadeTransition extends ViewTransition
	{
		/* variables */
		private var _duration:Number;
		private var _easing:Ease;		private var _delay:Number;
		
		public function FadeTransition(duration:Number = .5, easing:Ease = null, delay:Number = 0)
		{
			_duration = duration;
			_easing = easing;
			_delay = delay;
		}
		
		override protected function onStart(forward:Boolean):void
		{
			newView.alpha = 0;			TweenLite.to(newView, _duration, {alpha:1, ease:_easing, delay:_delay, onComplete:dispatchTransitionComplete});
		}
	}
}
