package de.pixelscape.sound
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	public class SoundElement extends EventDispatcher
	{
		/* variables */
		private var _sound:Sound;
		private var _channel:SoundChannel;
		
		private var _volume:Number						= 1;
		private var _loops:int							= 0;
		
		private var _playing:Boolean					= false;
		
		public function SoundElement(sound:Sound)
		{
			// vars
			_sound = sound;
		}
		
		/* playback */
		public function play(startTime:Number = 0, loops:int = 0):void
		{
			// finalize current playback
			finalizePlayback();
			
			// set vars
			_loops = loops;
			
			// play
			_channel = _sound.play(startTime, loops, new SoundTransform(_volume));
			_playing = true;
			
			// append listeners
			_channel.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
		}
		
		public function stop():void
		{
			// cancellation
			if(!_playing) return;
			
			// finalize playback
			finalizePlayback();
		}
		
		private function finalizePlayback():void
		{
			// cancellation
			if(!_playing) return;
			
			// finalize channel
			_channel.stop();
			_channel.removeEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
			_channel = null;
			
			// set var
			_playing = false;
		}
		
		/* getter setter */
		public function get volume():Number					{ return _volume; }
		public function set volume(value:Number):void
		{
			_volume = value;
			
			if(_playing) _channel.soundTransform = new SoundTransform(_volume);
		}
		
		public function get loops():int						{ return _loops; }
		public function get playing():Boolean				{ return _playing; }
		
		/* event handler */
		private function handleSoundComplete(e:Event):void
		{
			// finalize playback
			finalizePlayback();
			
			// redispatch
			dispatchEvent(e);
		}
	}
}