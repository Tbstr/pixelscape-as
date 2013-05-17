package de.pixelscape.display 
{	import de.pixelscape.output.notifier.Notifier;
	import de.pixelscape.utils.Analysis;
	import de.pixelscape.utils.Clooney;
	import de.pixelscape.utils.FlashUtils;
	
	import flash.display.DisplayObjectContainer;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.osmf.utils.Version;

	/**	 * @author Tobias Friese	 */	public class Label extends TextField 
	{		/* variables */
		private var _minWidth:Number = 0;
		private var _maxWidth:Number = 0;
		
		private var _html:Boolean;
		
		/* static */
		private static var embedded:Array;
		
		public function Label(value:String, textFormat:TextFormat)
		{
			// computing
			if(embedded == null) registerEmbeddedFonts();
			
			this.embedFonts = (embedded.indexOf(textFormat.font) == -1) ? false : true;
			this.autoSize = TextFieldAutoSize.LEFT;
			this.selectable = false;
			
			if(textFormat != null) this.defaultTextFormat = textFormat;
			
			this.text = value;
			
			this.x = x;
			this.y = y;
		}
		
		/* static constructor */
		public static function create(value:String, textFormat:TextFormat, properties:Object = null):Label
		{
			var label:Label = new Label(value, textFormat);
			
			if(properties != null) 
			{
				// container property
				if("container" in properties)
				{
					if(properties.container is DisplayObjectContainer)
					{
						properties.container.addChild(label);
						delete properties.container;
					}
				}
				
				// other properties
				FlashUtils.setProperties(label, properties);
			}
			
			return label;
		}
		
		/* static methods */
		public static function registerEmbeddedFonts():void
		{
			embedded = new Array();
			for each(var font:Font in Font.enumerateFonts()) embedded.push(font.fontName);
		}
		
		/* methods */
		private function checkWidthBounds():void
		{
			this.wordWrap = false;
			if(_maxWidth == 0) return;
			
			if(this.width > _maxWidth)
			{
				this.width = Math.max(_maxWidth, _minWidth);
				this.wordWrap = true;
			}
		}
		
		/* getter setter */
		override public function set text(value:String):void
		{
			if(this._html) super.htmlText = value;
			else super.text = value;
			
			this.checkWidthBounds();
		}
		
		override public function set htmlText(value:String):void
		{
			text = value;
			html = true;
		}
		
		public function get html():Boolean
		{
			return this._html;
		}
		
		public function set html(value:Boolean):void
		{
			if(this._html == value) return;
			
			this._html = value;
			
			if(value) this.htmlText = this.text;
			else if(this.text == "") this.text = this.htmlText;
		}
		
		public function get maxWidth():Number
		{
			return this._maxWidth;
		}
		
		public function set maxWidth(value:Number):void
		{
			this._maxWidth = value;
			this.checkWidthBounds();
		}
		
		public function get minWidth():Number
		{
			return this._minWidth;
		}
		
		public function set minWidth(value:Number):void
		{
			this._minWidth = value;
			this.checkWidthBounds();
		}
		
		public function get textFormatOverride():Object
		{
			return null;
		}
		
		public function set textFormatOverride(value:Object):void
		{
			if(this.defaultTextFormat == null) return;
			
			var format:TextFormat = Clooney.cloneTextFormat(this.defaultTextFormat);
			FlashUtils.setProperties(format, value);
			
			this.defaultTextFormat = format;
			this.setTextFormat(format);
		}
	}}