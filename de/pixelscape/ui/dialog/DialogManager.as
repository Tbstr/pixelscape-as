package de.pixelscape.ui.dialog
{
	import de.pixelscape.utils.TransformationUtils;		import flash.display.DisplayObjectContainer;	import flash.display.Stage;	import flash.events.EventDispatcher;	import flash.geom.Rectangle;	import flash.utils.getQualifiedSuperclassName;		
	/**
	 * @author Tobias Friese
	 */
	public class DialogManager extends EventDispatcher
	{
		/* variables */
		private static var _instance:DialogManager;
		
		private var _initialized:Boolean;
		
		private var _dialogues:Vector.<Dialog>						= new Vector.<Dialog>();
		private var _opened:Vector.<Dialog>							= new Vector.<Dialog>();
		
		private var _dialogContainer:DisplayObjectContainer;
		private var _dialogAreaWidth:Number;
		private var _dialogAreaHeight:Number;
		
		private var _alertClass:Class;

		public function DialogManager()
		{
			if(_instance == null) _instance = this;
			else throw new Error("DialogManager is a Singleton and therefore can only be accessed through DialogManager.getInstance() or DialogManager.instance");
		}

		/* singleton getters */
		public static function getInstance():DialogManager
		{
			if(_instance == null) new DialogManager();
			return _instance;
		}
		
		public static function get instance():DialogManager
		{
			return getInstance();
		}
		
		/*  static shortcuts */
		public static function alert(message:String):void
		{
			getInstance().alert(message);
		}
		
		/* methods */
		public function initialize(dialogContainer:DisplayObjectContainer, dialogAreaWidth:Number = 0, dialogAreaHeight:Number = 0):void
		{
			if(dialogContainer == null) return;
			
			_dialogContainer = dialogContainer;
			_dialogAreaWidth = dialogAreaWidth;
			_dialogAreaHeight = dialogAreaHeight;
			
			_initialized = true;
		}
		
		public function initializeAlert(AlertClass:Class):void
		{
			if(getQualifiedSuperclassName(AlertClass) == "de.pixelscape.ui.dialog::Dialog") _alertClass = AlertClass;
			else throw new Error("AlertClass has to be a subclass of the Dialog class.");
		}
		
		private function registerDialogListeners(dialog:Dialog):void
		{
			if(dialog == null) return;
			
			dialog.addEventListener(DialogEvent.OPEN, handleDialogOpen);
			dialog.addEventListener(DialogEvent.OPEN_COMPLETE, handleDialogOpenComplete);
						dialog.addEventListener(DialogEvent.CLOSE, handleDialogClose);
			dialog.addEventListener(DialogEvent.CLOSE_COMPLETE, handleDialogCloseComplete);
						dialog.addEventListener(DialogEvent.CONFIRM, handleDialogConfirm);			dialog.addEventListener(DialogEvent.NEXT, handleDialogNext);			dialog.addEventListener(DialogEvent.CANCEL, handleDialogCancel);
		}
		
		private function unregisterDialogListeners(dialog:Dialog):void
		{
			if(dialog == null) return;
			
			dialog.removeEventListener(DialogEvent.OPEN, handleDialogOpen);
			dialog.removeEventListener(DialogEvent.OPEN_COMPLETE, handleDialogOpenComplete);
			
			dialog.removeEventListener(DialogEvent.CLOSE, handleDialogClose);
			dialog.removeEventListener(DialogEvent.CLOSE_COMPLETE, handleDialogCloseComplete);
			
			dialog.removeEventListener(DialogEvent.CONFIRM, handleDialogConfirm);
			dialog.removeEventListener(DialogEvent.NEXT, handleDialogNext);
			dialog.removeEventListener(DialogEvent.CANCEL, handleDialogCancel);
		}
		
		public function alert(message:String):void
		{
			if(_alertClass == null)
			{
				throw new Error("There is no alert class defined. Iinitialize first using the initializeAlert method.");
				return;
			}
				
			var dialog:Dialog = new _alertClass("alert", {message:message});
			openDialogInternal(dialog);
		}
		
		public function addDialog(dialog:Dialog):void
		{
			if(dialog == null) return;
			
			_dialogues.push(dialog);
		}
		
		public function openDialog(id:String, data:* = null):void
		{
			var dialog:Dialog = this.getDialogByID(id);
			
			if(dialog != null) openDialogInternal(dialog, data);
			else throw new Error("A Dialog with id '" + id + "' could not be found.");
		}
		
		private function openDialogInternal(dialog:Dialog, data:* = null):void
		{
			// cancellation
			if(dialog == null) return;
			
			// set dialog area
			dialog.setDialogArea(_dialogAreaWidth, _dialogAreaHeight);
			
			// register listeners
			registerDialogListeners(dialog);
			
			// add & open
			_dialogContainer.addChild(dialog);
			dialog.open(data);
		}
		
		/* getter setter */
		public function get numDialogsOpened():uint												{ return _opened.length; }
		
		public function getDialogByID(id:String):Dialog
		{
			for each(var dialog:Dialog in _dialogues) if(dialog.id == id) return dialog;
			return null;
		}
		
		public function setDialogArea(width:Number, height:Number):void
		{
			// vars
			_dialogAreaWidth = width;
			_dialogAreaHeight = height;
			
			// set for opened
			for each(var dialog:Dialog in _opened) dialog.setDialogArea(width, height);
		}
		
		/* event handler */
		private function handleDialogOpen(e:DialogEvent):void
		{
			// add to opened queue
			_opened.push(e.dialog);
			
			// re-dispatch
			dispatchEvent(new DialogEvent(DialogEvent.OPEN, e.dialog));
		}
		
		private function handleDialogOpenComplete(e:DialogEvent):void
		{
			// re-dispatch
			dispatchEvent(new DialogEvent(DialogEvent.OPEN_COMPLETE, e.dialog));
		}
		
		private function handleDialogClose(e:DialogEvent):void
		{
			// remove from opened queue
			var oIndex:Number = _opened.indexOf(e.dialog);
			if(oIndex != -1) _opened.splice(oIndex, 1);
			
			// re-dispatch
			dispatchEvent(new DialogEvent(DialogEvent.CLOSE, e.dialog));
		}
		
		private function handleDialogCloseComplete(e:DialogEvent):void
		{
			// unregister listeners
			unregisterDialogListeners(e.dialog);
			
			// remove from container
			_dialogContainer.removeChild(e.dialog);
			
			// re-dispatch
			dispatchEvent(new DialogEvent(DialogEvent.CLOSE_COMPLETE, e.dialog));
		}
		
		private function handleDialogConfirm(e:DialogEvent):void
		{
			// re-dispatch
			dispatchEvent(new DialogEvent(DialogEvent.CONFIRM, e.dialog));
		}
		
		private function handleDialogNext(e:DialogEvent):void
		{
			// re-dispatch
			dispatchEvent(new DialogEvent(DialogEvent.NEXT, e.dialog));
		}

		private function handleDialogCancel(e:DialogEvent):void
		{
			// re-dispatch
			dispatchEvent(new DialogEvent(DialogEvent.CANCEL, e.dialog));
		}
	}
}