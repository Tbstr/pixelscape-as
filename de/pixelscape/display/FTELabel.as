package de.pixelscape.display
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	import de.pixelscape.utils.FlashUtils;
	
	public class FTELabel extends Sprite
	{
		/* variables */
		private var _text:String;
		private var _format:ElementFormat;
		
		private var _textElement:TextElement;
		private var _textBlock:TextBlock;
		
		private var _maxWidth:Number;
		private var _align:String;
		
		private var _numLines:int;
		
		/* constants */
		private static const MAX_WIDTH_DEFAULT:Number		= 1000000;
		
		public static const ALIGN_LEFT:String				= 'left';
		public static const ALIGN_CENTER:String				= 'center';
		public static const ALIGN_RIGHT:String				= 'right';
		
		/* constructor */
		public function FTELabel(text:String, format:ElementFormat, maxWidth:Number = 1000000, align:String = 'left')
		{
			// vars
			_text = text;
			_format = format;
			
			_maxWidth = maxWidth;
			_align = align;
			
			// build
			build();
		}
		
		private function build():void
		{
			// clear
			removeChildren();
			
			// text element
			_textElement = new TextElement(_text, _format);
			
			// text block
			_textBlock = new TextBlock(_textElement);
			
			// text line(s)
			var y:Number = 0;
			var c:int = 0;
			var line:TextLine = null;
			while((line = _textBlock.createTextLine(line, _maxWidth)) != null)
			{
				// position
				line.y = y + line.totalAscent;
				
				switch(_align)
				{
					case ALIGN_CENTER:
						line.x = (_maxWidth - line.width) * .5;
						break;
					
					case ALIGN_RIGHT:
						line.x = _maxWidth - line.width;
						break;
				}
				
				// add
				addChild(line);
				
				// advance
				y += line.height;
				c++;
			}
			
			// set vars
			_numLines = c;
		}
		
		/* static constructor */
		public static function create(text:String, format:ElementFormat, properties:Object = null):FTELabel
		{
			// prepare vars
			var maxWidth:Number 						= MAX_WIDTH_DEFAULT;
			var align:String							= 'left';
			var container:DisplayObjectContainer 		= null;
			
			if(properties != null)
			{
				if('maxWidth' in properties) maxWidth = Number(properties.maxWidth); delete properties.maxWidth;
				if('align' in properties) align = String(properties.align); delete properties.align;
				if('container' in properties) container = DisplayObjectContainer(properties.container); delete properties.container;
			}
			
			// create label
			var label:FTELabel = new FTELabel(text, format, maxWidth, align);
			
			// apply propeties
			if(properties != null) FlashUtils.setProperties(label, properties);
			
			// add to container
			if(container != null) container.addChild(label);
			
			// return
			return label;
		}
		
		/* getter setter */
		public function get text():String				{ return _text; }
		public function set text(value:String):void
		{
			// cancellation
			if(value == _text) return;
			
			// set
			_text = value;
			build();
		}
		
		public function get align():String				{ return _align; }
		public function get maxWidth():Number			{ return _maxWidth; }
		public function get numLines():int				{ return _numLines; }
		
		override public function get width():Number
		{
			if(_align == ALIGN_LEFT && _maxWidth == MAX_WIDTH_DEFAULT) return super.width;
			return _maxWidth;
		}
		
		override public function set width(value:Number):void
		{
			_maxWidth = value;
			build();
		}
			
	}
}