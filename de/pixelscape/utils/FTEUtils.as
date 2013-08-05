package de.pixelscape.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;

	public class FTEUtils
	{
		public static function textLine(value:String, elementFormat:ElementFormat, properties:Object = null):TextLine
		{
			// text element
			var textElement:TextElement = new TextElement(value, elementFormat);
			
			// text block
			var textBlock:TextBlock = new TextBlock(textElement);
			
			// text line
			var textLine:TextLine = textBlock.createTextLine();
			
			// apply properties
			applyProperties(textLine, properties);
			
			// return text line
			return textLine;
		}
		
		private static function applyProperties(object:Object, properties:Object):void
		{
			// cancellation
			if(object == null) return;
			if(properties == null) return;
			
			// container
			if('container' in properties)
			{
				if(object is DisplayObject && properties.container is DisplayObjectContainer)
				{
					properties.container.addChild(object);
					delete properties.container;
				}
			}
			
			// set properties
			FlashUtils.setProperties(object, properties);
		}
	}
}