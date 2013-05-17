package de.pixelscape.parser 
{
	import de.pixelscape.output.notifier.Notifier;
	
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * @author Tobias Friese
	 */
	public class TextParser 
	{
		public static function applyStyleTags(target:TextField, ...styleTags):void
		{
			var text:String = target.text;
			var defaultFormat:TextFormat = target.getTextFormat();
			var stack:Array = new Array();
			
			for(var i:int = 0; i < styleTags.length; i++)
			{
				// get tag
				var styleTag:StyleTag;
				
				if(styleTags[i] is StyleTag) styleTag = styleTags[i];
				else continue;
				
				// parse
				var occurance:Array;
				while((occurance = getOccurance(text, styleTag)) != null)
				{
					text = text.substring(0, occurance[0]) + text.substring(occurance[0] + styleTag.startTag.length, occurance[1]) + text.substr(occurance[1] + styleTag.endTag.length);
					stack.push([occurance[0], occurance[1] - styleTag.endTag.length + 1, styleTag.textFormat]);
				}
			}
			
			target.text = text;
			
			target.setTextFormat(defaultFormat);
			for(var j:int = 0; j < stack.length; j++) target.setTextFormat(stack[j][2], stack[j][0], stack[j][1]);
		}
		
		private static function getOccurance(text:String, styleTag:StyleTag):Array
		{
			var startIndex:int = text.indexOf(styleTag.startTag);
			if(startIndex == -1) return null;
			
			var endIndex:int = text.indexOf(styleTag.endTag, startIndex + styleTag.startTag.length);
			if(endIndex == -1) return null;
			
			return [startIndex, endIndex];
		}
	}
}
