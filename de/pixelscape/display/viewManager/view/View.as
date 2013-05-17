package de.pixelscape.display.viewManager.view
{
	import de.pixelscape.display.viewManager.ViewManager;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class View extends Sprite
	{
		/* variables */
		private var _id:String;
		
		private var _canvasWidth:Number		= 1000;
		private var _canvasHeight:Number	= 1000;
		
		private var _maskEnabled:Boolean	= false;		private var _enabled:Boolean		= true;
		
		private var _manager:ViewManager;
		
		/* architecture */
		private var _viewMask:Shape;
		
		public function View(id:String)
		{
			// vars
			this._id = id;
		}
		
		/* methods */
		public function init(data:Object = null):void
		{
			if(this._enabled) this.onInit(data == null ? {} : data);
		}
		
		protected function triggerResize():void
		{
			this.onCanvasResize(this._canvasWidth, this._canvasHeight);
		}
		
		/* getter setter */
		public function setCanvasSize(width:Number, height:Number):void
		{
			if(this._canvasWidth == width) if(this._canvasHeight == height) return;
			
			// vars
			this._canvasWidth = width;
			this._canvasHeight = height;
			
			// mask
			if(this._viewMask != null)
			{
				this._viewMask.graphics.clear();
				this._viewMask.graphics.beginFill(0);
				this._viewMask.graphics.drawRect(0, 0, this._canvasWidth, this._canvasHeight);
				this._viewMask.graphics.endFill();
			}
			
			// child methods
			this.onCanvasResize(width, height);
		}
		
		public function get id():String
		{
			return this._id;
		}
		
		public function get maskEnabled():Boolean
		{
			return this._maskEnabled;
		}
		
		public function set maskEnabled(value:Boolean):void
		{
			if(this._maskEnabled == value) return;
			this._maskEnabled = value;
			
			if(value)
			{
				this._viewMask = new Shape();
				this._viewMask.graphics.beginFill(0);
				this._viewMask.graphics.drawRect(0, 0, this._canvasWidth, this._canvasHeight);				this._viewMask.graphics.endFill();
				
				this.mask = this._viewMask;
				this.addChild(this._viewMask);
			}
			else
			{
				this.removeChild(this._viewMask);
				this.mask = null;
				this._viewMask = null;
			}
		}
		
		public function get enabled():Boolean
		{
			return this._enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if(value != this._enabled)
			{
				this._enabled = value;
				
				if(value) this.onEnable();
				else this.onDisable();
			}
		}
		
		public function get canvasWidth():Number
		{
			return this._canvasWidth;
		}
		
		public function get canvasHeight():Number
		{
			return this._canvasHeight;
		}
		
		public function get manager():ViewManager
		{
			return _manager;
		}
		
		public function set manager(value:ViewManager):void
		{
			this._manager = value;
		}
		
		/* child methods [to be overwritten] */
		protected function onInit(data:Object):void									{}
		protected function onEnable():void											{}
		protected function onDisable():void											{}
		protected function onCanvasResize(width:Number, height:Number):void			{}
		protected function onFinalize():void										{}
		
		// finalization
		public function finalize():void
		{
			// finalize
			_manager = null;
			
			// dispatch handle
			onFinalize();
		}
	}
}