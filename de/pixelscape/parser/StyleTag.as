package de.pixelscape.parser 
{
	import flash.text.TextFormat;

	/**
	 * @author Tobias Friese
	 */
	public class StyleTag 
	{
		/* variables */
		private var _startTag:String;		private var _endTag:String;
		
		private var _textFormat:TextFormat;
		
		public function StyleTag(startTag:String, endTag:String, textFormat:TextFormat)
		{
			this._startTag = startTag;			this._endTag = endTag;
			
			this._textFormat = textFormat;
		}
		
		/* getter setter */
		public function get startTag():String
		{
			return this._startTag;
		}
		
		public function get endTag():String
		{
			return this._endTag;
		}
		
		public function get textFormat():TextFormat
		{
			return this._textFormat;
		}
	}
}
