package de.pixelscape.display
{
	import flash.text.Font;
	import flash.text.FontType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import de.pixelscape.utils.Clooney;
	
	
	public class PSTextField extends flash.text.TextField
	{
		/* statics */
		private static var embeddedList:Array					= null;
		
		/* variables */
		private var _text:String;
		private var _format:TextFormat;
		private var _html:Boolean;
		private var _maxWidth:Number;
		
		public function PSTextField(text:String, format:TextFormat, html:Boolean = false, maxWidth:Number = -1)
		{
			// vars
			_text = text;
			_format = Clooney.cloneTextFormat(format);
			_html = html;
			_maxWidth = maxWidth;
			
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
			
			if(maxWidth != -1)
			{
				width = maxWidth;
				
				multiline = true;
				wordWrap = true;
				autoSize = TextFieldAutoSize.LEFT;
			}
			
			// apply format
			defaultTextFormat = _format;
			
			// set text
			if(html)
			{
				condenseWhite = true;
				htmlText = text;
			}
			else this.text = text;
		}
	}
}