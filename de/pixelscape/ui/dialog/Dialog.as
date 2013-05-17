package de.pixelscape.ui.dialog 
{
	import flash.display.Sprite;	

	/**
	 * @author Tobias Friese
	 */
	public class Dialog extends Sprite 
	{
		/* variables */
		private var _id:String;
		
		private var _dialogAreaWidth:Number				= 0;
		private var _dialogAreaHeight:Number			= 0;
		
		private var _opened:Boolean						= false;
		
		public function Dialog(id:String)
		{
			// vars
			_id = id;
		}
		
		public final function open(data:* = null):void
		{
			// cancellation
			if(_opened) return;
			
			// action
			onOpen(data);
			
			// set var
			_opened = true;
			
			// dispatch
			dispatchOpen();
		}
		
		protected final function openComplete():void
		{
			dispatchOpenComplete();
		}
		
		public final function close():void
		{
			// cancellation
			if(!_opened) return;
			
			// action
			onClose();
			
			// set var
			_opened = false;
			
			// dispatch
			dispatchClose();
		}
		
		protected final function closeComplete():void
		{
			dispatchCloseComplete();
		}
		
		protected final function confirm():void
		{
			dispatchConfirm();
		}
		
		protected final function next():void
		{
			dispatchNext();
		}
		
		protected final function cancel():void
		{
			dispatchCancel();
		}
		
		/* getter setter */
		public function get id():String								{ return _id; }
		
		public function get dialogAreaWidth():Number				{ return _dialogAreaWidth; }
		public function get dialogAreaHeight():Number				{ return _dialogAreaHeight; }
		
		public function setDialogArea(width:Number, height:Number):void
		{
			if(_dialogAreaWidth == width) if(_dialogAreaHeight == height) return;
			
			_dialogAreaWidth = width;
			_dialogAreaHeight = height;
			
			onDialogAreaChange();
		}
		
		public function get opened():Boolean						{ return _opened; }
		
		/* dispatch methods */
		private function dispatchOpen():void
		{
			dispatchEvent(new DialogEvent(DialogEvent.OPEN, this));
		}
		
		private function dispatchOpenComplete():void
		{
			dispatchEvent(new DialogEvent(DialogEvent.OPEN_COMPLETE, this));
		}
		
		private function dispatchClose():void
		{
			dispatchEvent(new DialogEvent(DialogEvent.CLOSE, this));
		}
		
		private function dispatchCloseComplete():void
		{
			dispatchEvent(new DialogEvent(DialogEvent.CLOSE_COMPLETE, this));
		}
		
		private function dispatchConfirm():void
		{
			dispatchEvent(new DialogEvent(DialogEvent.CONFIRM, this));
		}
		
		private function dispatchNext():void
		{
			dispatchEvent(new DialogEvent(DialogEvent.NEXT, this));
		}
		
		private function dispatchCancel():void
		{
			dispatchEvent(new DialogEvent(DialogEvent.CANCEL, this));
		}
		
		/* overrideables */
		protected function onOpen(data:* = null):void
		{
			dispatchOpenComplete();
		}
		
		protected function onClose():void
		{
			dispatchCloseComplete();
		}
		
		protected function onDialogAreaChange():void
		{
		}
		
		/* finalization */
		public function finalize():void
		{
		}
	}
}
