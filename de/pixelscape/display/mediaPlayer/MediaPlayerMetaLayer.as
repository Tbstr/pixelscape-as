package de.pixelscape.display.mediaPlayer
{
	import de.pixelscape.data.MarginData;
	import de.pixelscape.data.MediaData;
	import de.pixelscape.display.Label;
	import de.pixelscape.graphics.Picasso;
	
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	
	public class MediaPlayerMetaLayer extends Sprite
	{
		/* variables */
		private var _mediaData:MediaData;
		private var _width:Number;
		private var _height:Number;
		
		/* architecture */
		private var _labelTitle:Label;
		private var _labelSubtitle:Label;
		private var _labelDescription:Label;
		
		/* constants */
		private static const MARGIN_LAYER:MarginData					= new MarginData(10, 10, 10, 10);
		private static const MARGIN_TITLE:MarginData					= new MarginData(5, 5, 2, 2);
		private static const MARGIN_SUBTITLE:MarginData					= new MarginData(5, 5, 2, 2);
		private static const MARGIN_DESCRIPTION:MarginData				= new MarginData(5, 5, 5, 5);
		
		private static const MARGIN_ELEMENTS:Number						= 5;
		
		private static const DESCRIPTION_MAX_WIDTH:Number				= 400;
		
		public function MediaPlayerMetaLayer(width:Number, height:Number)
		{
			// vars
			_mediaData = mediaData;
			_width = width;
			_height = height;
			
			// settings
			filters = [new DropShadowFilter(0, 0, 0, 1, 6, 6, .5, 3)];
			cacheAsBitmap = true;
		}
		
		private function build():void
		{
			if(_mediaData == null) return;
			
			// title
			if(_mediaData.title != null) _labelTitle = Label.create(_mediaData.title, new TextFormat("Cellini-Regular", 18, 0x335F7D), {container:this, x:MARGIN_LAYER.left + MARGIN_TITLE.left, y:MARGIN_LAYER.top + MARGIN_TITLE.top});
			
			// subtitle
			if(_mediaData.subtitle != null) _labelSubtitle = Label.create(_mediaData.subtitle, new TextFormat("VW Headline OT-Book", 12, 0x666666), {container:this, x:MARGIN_LAYER.left + MARGIN_SUBTITLE.left, y:_labelTitle == null ? MARGIN_LAYER.top + MARGIN_SUBTITLE.top : _labelTitle.y + _labelTitle.height + MARGIN_ELEMENTS + MARGIN_SUBTITLE.top});
			
			// description
			if(_mediaData.description != null) _labelDescription = Label.create(_mediaData.description, new TextFormat("VW Headline OT-Book", 14, 0xFFFFFF), {container:this, x:MARGIN_LAYER.left + MARGIN_DESCRIPTION.left});
		}
		
		private function arrange():void
		{
			if(_mediaData == null) return;
			
			// clear
			Picasso.clear(this);
			
			// title
			if(_labelTitle != null) Picasso.drawRectangle(this, 0xFFFFFF, 1, _labelTitle.x - MARGIN_TITLE.left, _labelTitle.y - MARGIN_TITLE.top, _labelTitle.width + MARGIN_TITLE.totalX, _labelTitle.height + MARGIN_TITLE.totalY);
			
			// subtitle
			if(_labelSubtitle != null) Picasso.drawRectangle(this, 0xFFFFFF, 1, _labelSubtitle.x - MARGIN_SUBTITLE.left, _labelSubtitle.y - MARGIN_SUBTITLE.top, _labelSubtitle.width + MARGIN_SUBTITLE.totalX, _labelSubtitle.height + MARGIN_SUBTITLE.totalY);
			
			// description
			if(_labelDescription != null)
			{
				_labelDescription.maxWidth = Math.min(_width - MARGIN_LAYER.totalX - MARGIN_DESCRIPTION.totalX, DESCRIPTION_MAX_WIDTH);
				_labelDescription.y = _height - _labelDescription.height - MARGIN_DESCRIPTION.bottom - MARGIN_LAYER.bottom;
				Picasso.drawRectangle(this, 0, .6, _labelDescription.x - MARGIN_DESCRIPTION.left, _labelDescription.y - MARGIN_DESCRIPTION.top, _labelDescription.width + MARGIN_DESCRIPTION.totalX, _labelDescription.height + MARGIN_DESCRIPTION.totalY);
			}
		}
		
		public function resize(width:Number, height:Number):void
		{
			_width = width;
			_height = height;
			
			arrange();
		}
		
		private function reset():void
		{
			_mediaData = null;
			
			if(_labelTitle != null)
			{
				removeChild(_labelTitle);
				_labelTitle = null;
			}
			
			if(_labelSubtitle != null)
			{
				removeChild(_labelSubtitle);
				_labelSubtitle = null;
			}
			
			if(_labelDescription != null)
			{
				removeChild(_labelDescription);
				_labelDescription = null;
			}
		}
		
		/* getter setter */
		public function get mediaData():MediaData							{ return _mediaData; }
		public function set mediaData(value:MediaData):void
		{
			if(value == null) return;
			
			reset();
			
			_mediaData = value;
			
			build();
			arrange();
		}
	}
}