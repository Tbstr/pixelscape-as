package de.pixelscape.utils 
{
	import flash.text.TextFormat;

	/**
	 * @author Sickdog
	 */
	public class Clooney 
	{
		public static function cloneTextFormat(src:TextFormat):TextFormat
		{
			var clone:TextFormat = new TextFormat(src.font, src.size, src.color, src.bold, src.italic, src.underline, src.url, src.target, src.align, src.leftMargin, src.rightMargin, src.indent, src.leading);
			
			clone.blockIndent		= src.blockIndent;
			clone.bullet			= src.bullet;
			clone.display			= src.display;
			clone.kerning			= src.kerning;
			clone.letterSpacing		= src.letterSpacing;
			clone.tabStops			= src.tabStops;
			
			return clone;
		}
	}
}
