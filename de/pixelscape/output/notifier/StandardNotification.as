package de.pixelscape.output.notifier 
{	import de.pixelscape.graphics.Picasso;

	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**	 * @author Tobias Friese	 */	public class StandardNotification extends Notification 
	{
		private var _maxWidth:Number = 250;
		private var _margins:Array = new Array(10, 10, 10, 10);
		
		private var _textFormat:TextFormat = new TextFormat("Tahoma", 11, 0xFFFFFF);
		
		private var _backgroundColor:uint = 0x000000;
		private var _backgroundAlpha:Number = 0.8;
		private var _roundness:Number = 3;
		
		private var _displayBounds:Rectangle = new Rectangle(0, 0, 300, 120);
		
		/* architecture */
		private var _rollArea:Sprite;
		
		private var _messageContainer:Sprite;
		private var _textField:TextField;		private var _background:Shape;
		private var _frame:Shape;
		private var _messageHitArea:Sprite;
		
		private var _buttonContainer:Sprite;
		private var _closeButton:Sprite;
		private var _copyButton:Sprite;
		
		private var _display:Display;

		public function StandardNotification(notifier:Notifier, message:*, properties:Object = null)
		{			this._stack = true;
			
			super(notifier, message, properties);
			
			this.build();
			this.registerListeners();
			this.intro();		}
		
		private function build():void
		{
			// message container
			this._messageContainer = new Sprite();
			this._messageContainer.buttonMode = true;
			
			// textField
			this._textField = new TextField();
			this._textField.x = this._margins[3];
			this._textField.y = this._margins[0];
			
			this._textField.autoSize = "left";
			this._textField.selectable = false;
			this._textField.text = this._messageAsString;
			this._textField.setTextFormat(this._textFormat);
			
			if(this._textField.width > (this._maxWidth - this._margins[1] - this._margins[3]))
			{
				this._textField.width = (this._maxWidth - this._margins[1] - this._margins[3]);
				this._textField.wordWrap = true;
			}
			
			var messageWidth:Number = this._textField.width + this._margins[1] + this._margins[3]; 			var messageHeight:Number = this._textField.height + this._margins[0] + this._margins[2]; 
			
			// background
			this._background = new Shape();
			Picasso.drawRoundedRectangle(this._background, this._backgroundColor, this._backgroundAlpha, 0, 0, messageWidth, messageHeight, this._roundness);
			
			// message hit area
			this._messageHitArea = new Sprite();
			Picasso.drawRoundedRectangle(this._messageHitArea, 0x000000, 0, 0, 0, messageWidth, messageHeight, this._roundness);
			
			// frame
			this._frame = new Shape();
			Picasso.drawRoundedRectangle(this._frame, 0x000000, 0, 0, 0, messageWidth, messageHeight, this._roundness, [2, 0xFFFFFF, 1]);
			
			this._messageContainer.addChild(this._background);			this._messageContainer.addChild(this._textField);
			this._messageContainer.addChild(this._messageHitArea);			
			this.addChild(this._messageContainer);
			
			// button container
			this._buttonContainer = new Sprite();
			this._buttonContainer.alpha = 0;
			this._buttonContainer.x = this._messageContainer.width + 3;			this._buttonContainer.y = 10;
			
			// close button
			this._closeButton = new Sprite();
			this._closeButton.buttonMode = true;
			
			Picasso.drawRoundedRectangle(this._closeButton, this._backgroundColor, this._backgroundAlpha, 0, 0, 12, 12, 3);
			Picasso.drawLine(this._closeButton, 2, 0xFFFFFF, 1, 4, 4, 8, 8);			Picasso.drawLine(this._closeButton, 2, 0xFFFFFF, 1, 8, 4, 4, 8);
			
			this._buttonContainer.addChild(this._closeButton);
			
			// copy button
			this._copyButton = new Sprite();			this._copyButton.y = 15;
			this._copyButton.buttonMode = true;
			
			Picasso.drawRoundedRectangle(this._copyButton, this._backgroundColor, this._backgroundAlpha, 0, 0, 12, 12, 3);
			Picasso.drawArc(this._copyButton, 2, 0xFFFFFF, 1, 8, 4.5, 2.5, 2.5, 45, 270);
			
			this._buttonContainer.addChild(this._copyButton);
			
			// roll area
			this._rollArea = new Sprite();
			Picasso.drawRectangle(this._rollArea, 0, 0, 0, 0, this._buttonContainer.x + this._buttonContainer.width, this._messageContainer.height);
			this.addChildAt(this._rollArea, 0);
			
			// display
			if(this._isImagePath)
			{
				this._display = new Display(this.cleanPath(this._messageAsString), Display.TYPE_IMAGE, this._displayBounds);
				this._display.addEventListener(Display.READY, this.handleDisplayReady);
				this._display.init();
			}
			
			if(this._isSoundPath)
			{
				this._display = new Display(this.cleanPath(this._messageAsString), Display.TYPE_SOUND);
				this._display.addEventListener(Display.READY, this.handleDisplayReady);
				this._display.init();
			}
		}
		
		private function registerListeners():void
		{
			this._messageHitArea.addEventListener(MouseEvent.MOUSE_OVER, this.handleMouseOver);			this._messageHitArea.addEventListener(MouseEvent.MOUSE_OUT, this.handleMouseOut);
			
			if(this.isPath()) this._messageContainer.addEventListener(MouseEvent.CLICK, this.handleMouseClick);			this._closeButton.addEventListener(MouseEvent.CLICK, this.handleMouseClick);			this._copyButton.addEventListener(MouseEvent.CLICK, this.handleMouseClick);
		}
		
		private function unregisterListeners():void
		{
			this._messageHitArea.removeEventListener(MouseEvent.MOUSE_OVER, this.handleMouseOver);
			this._messageHitArea.removeEventListener(MouseEvent.MOUSE_OUT, this.handleMouseOut);
			
			this._messageContainer.removeEventListener(MouseEvent.CLICK, this.handleMouseClick);
			this._closeButton.removeEventListener(MouseEvent.CLICK, this.handleMouseClick);
			this._copyButton.removeEventListener(MouseEvent.CLICK, this.handleMouseClick);
			
			if(this._display != null)
			{
				this._display.removeEventListener(Display.READY, this.handleDisplayReady);
			}
			
			if(this.stage != null) this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
		}
		
		private function intro():void
		{
			this.alpha = 0;
			TweenMax.to(this, .3, {alpha:1});
		}
		
		private function showButtons():void
		{
			// show buttons
			//Tweener.removeTweens(this._buttonContainer, "alpha", "y");
			TweenMax.to(this._buttonContainer, .3, {alpha:1, y:0, ease:Cubic.easeOut});
			
			this.addChild(this._buttonContainer);
			
			// move display
			if(this._display != null)
			{
				//Tweener.removeTweens(this._display, "x");
				TweenMax.to(this._display, .3, {x:(this._buttonContainer.x + this._buttonContainer.width + 5), ease:Cubic.easeOut});
			}
		}
		
		private function hideButtons():void
		{
			// hide buttons
			//Tweener.removeTweens(this._buttonContainer, "alpha", "y");
			TweenMax.to(this._buttonContainer, .3, {alpha:0, y:10, ease:Cubic.easeIn, onComplete:this.handleHideButtonsComplete});			
			// move display
			if(this._display != null)
			{
				//Tweener.removeTweens(this._display, "x");
				TweenMax.to(this._display, .5, {x:(this._messageContainer.width + 5), ease:Cubic.easeIn});
			}
		}
		
		override protected function close():void
		{
			if(this.parent != null)
			{
				if(this.hitTestPoint(this.stage.mouseX, this.stage.mouseY))
				{
					this.addEventListener(MouseEvent.MOUSE_OUT, this.handleCloseMouseOut);
					return;
				}
			}
			
			TweenMax.to(this, .3, {alpha:0, onComplete:this.remove});
		}
		
		/* getter & setter methods */
		override public function get width():Number
		{
			return this._messageContainer.width;
		}

		public function set maxWidth(value:Number):void
		{
			this._maxWidth = value;
		}
		
		public function set margins(value:Array):void
		{
			if(value != null)
			{
				if(value.length == 4)
				{
					this._margins = value;
				}
			}
		}
		
		public function set textFormat(value:TextFormat):void
		{
			if(value != null)
			{
				this._textFormat = value;
			}
		}
		
		public function set backgroundColor(value:uint):void
		{
			this._backgroundColor = value;
		}

		public function set backgroundAlpha(value:Number):void
		{
			this._backgroundAlpha = value;
		}
		
		public function set roundness(value:Number):void
		{
			this._roundness = value;
		}
		
		public function set displayBounds(value:Rectangle):void
		{
			if(value != null)
			{
				if(value.width > this._maxWidth) value.width = this._maxWidth;
				this._displayBounds = value;
			}
		}
		
		override public function finalize():void
		{
			super.finalize();
			
			// unregister listeners
			this.unregisterListeners();
			
			// finalize elements
			if(this._display != null) this._display.finalize();
		}
		
		/* event handler */
		private function handleDisplayReady(e:Event):void
		{
			this._display.removeEventListener(Display.READY, this.handleDisplayReady);
			
			// intro display
			this._display.x = this._messageContainer.width + 20;
			this._display.y = 0;
			this._display.alpha = 0;
			
			TweenMax.to(this._display, .5, {x:this._messageContainer.width + 5, alpha:1, ease:Cubic.easeOut});
			
			this.addChild(this._display);
			
			// rearrange stack
			this._notifier.rearrangeStack();
		}
		
		private function handleMouseOver(e:MouseEvent):void
		{
			this._lockPosition = true;
			this._messageContainer.addChild(this._frame);
			this.showButtons();
			
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
		}
		
		private function handleMouseMove(e:MouseEvent):void
		{
			if(!this._rollArea.hitTestPoint(this.stage.mouseX, this.stage.mouseY))
			{
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
				this.hideButtons();
			}
		}
		
		private function handleMouseOut(e:MouseEvent):void
		{
			this._messageContainer.removeChild(this._frame);
			this._lockPosition = false;
		}
		
		private function handleCloseMouseOut(e:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_OUT, this.handleCloseMouseOut);
			this.close();
		}
		
		private function handleMouseClick(e:MouseEvent):void
		{
			switch(e.currentTarget)
			{
				case this._closeButton:
					this.close();
					this.hideButtons();
					break;
					
				case this._copyButton:
					System.setClipboard(this._messageAsString);
					this.hideButtons();
					break;
				
				case this._messageContainer:
					navigateToURL(new URLRequest(this.cleanPath(this._messageAsString)), "_blank");
					break;
			}
		}
		
		private function handleHideButtonsComplete():void
		{
			if(this.contains(this._buttonContainer)) this.removeChild(this._buttonContainer);
		}
	}}