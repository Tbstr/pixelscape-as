package de.pixelscape.display
{
	import flash.display.DisplayObjectContainer;
	import flash.text.Font;
	import flash.text.FontType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import de.pixelscape.utils.Clooney;
	import de.pixelscape.utils.FlashUtils;
	
	
	public class PSTextField extends flash.text.TextField
	{
		/* statics */
		private static var embeddedList:Array					= null;
		
		/* variables */
		private var _lastAppliedText:String;
		
		private var _format:TextFormat;
		private var _html:Boolean;
		private var _maxWidth:Number;
		
		/* constructor */
		public function PSTextField(text:String, format:TextFormat, html:Boolean = false, maxWidth:Number = -1)
		{
			// vars
			_format = Clooney.cloneTextFormat(format);
			
			this.maxWidth = maxWidth;
			this.html = html;
			
			// set embedded state
			if(embeddedList == null) embeddedList = Font.enumerateFonts();
			for each(var fontDef:Font in embeddedList)
			{
				if(fontDef.fontName == _format.font)
				{
					if(fontDef.fontType == FontType.EMBEDDED)
					{
						embedFonts = true;
						break;
					}
				}
			}
			
			// settings
			selectable = false;
			condenseWhite = true;
			
			// apply format
			defaultTextFormat = _format;
			
			// set text
			this.text = text;
		}
		
		/* static constructor */
		public static function create(value:String, textFormat:TextFormat, properties:Object = null):PSTextField
		{
			// create
			var tf:PSTextField = new PSTextField(value, textFormat);
			
			// apply properties
			if(properties != null) 
			{
				// container property
				if("container" in properties)
				{
					if(properties.container is DisplayObjectContainer)
					{
						properties.container.addChild(tf);
						delete properties.container;
					}
				}
				
				// other properties
				FlashUtils.setProperties(tf, properties);
			}
			
			return tf;
		}
		
		/* getter setter */
		override public function get text():String
		{
			if(_html) return super.htmlText;
			else return super.text;
		}
		override public function set text(value:String):void
		{
			// cancellation
			if(value == null) return;
			
			// vars
			_lastAppliedText = value;
			
			// apply
			if(_html) super.htmlText = value;
			else super.text = value;
		}
		
		override public function get htmlText():String					{ return text; }
		override public function set htmlText(value:String):void
		{
			_html = true;
			text = value;
		}
		
		public function get html():Boolean								{ return _html; }
		public function set html(value:Boolean):void
		{
			// cancellation
			if(value == _html) return;
			
			// set
			_html = value;
			
			// re apply text
			if(_lastAppliedText != null) text = _lastAppliedText;
		}
		
		public function get maxWidth():Number							{ return _maxWidth; }
		public function set maxWidth(value:Number):void
		{
			// cancellation
			if(_maxWidth == value) return;
			
			// set
			_maxWidth = value;
			
			// apply
			if(value == -1)
			{
				width = 100;
				
				multiline = false;
				wordWrap = false;
				autoSize = TextFieldAutoSize.NONE;
			}
			else
			{
				width = maxWidth;
				
				multiline = true;
				wordWrap = true;
				autoSize = TextFieldAutoSize.LEFT;
			}
		}
	}
}