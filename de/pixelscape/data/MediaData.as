package de.pixelscape.data
{
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	
	import de.pixelscape.data.Loadable;
	
	import flash.display.BitmapData;

	public class MediaData extends Loadable
	{
		/* variables */
		private var _path:String;
		
		private var _thumbPath:String;
		private var _thumb:BitmapData;
		
		private var _title:String;
		private var _subtitle:String;
		private var _description:String;
		
		private var _type:String								= "unknown";
		private var _content:*;
		
		/* constants */
		public static const IMAGE:String						= "image";
		public static const VIDEO:String						= "video";
		
		public function MediaData(mediaPath:String, thumbPath:String = null, title:String = null, subtitle:String = null, description:String = null)
		{
			// vars
			_path = mediaPath;
			_thumbPath = thumbPath;
			
			_title = title;
			_subtitle = subtitle;
			_description = description;
			
			// append thumb
			if(_thumbPath != null) appendToLoader(new ImageLoader(_thumbPath, {name:"thumb"}), true);
			
			// check type
			checkType();
		}
		
		private function checkType():void
		{
			var regExp:RegExp;
			
			// image
			regExp = /.*\.(jpg|jpeg|png)/;
			
			if(regExp.test(_path.toLowerCase()))
			{
				_type = IMAGE;
				appendToLoader(new ImageLoader(_path, {name:"image"}), true);
				return;
			}
			
			// video
			regExp = /.*\.(flv|f4v|mov|m4v)/;
			
			if(regExp.test(_path.toLowerCase()))
			{
				_type = VIDEO
				return;
			}
		}
		
		/* getter setter */
		public function get path():String										{ return _path; }
		public function get type():String										{ return _type; }
		
		public function get thumb():BitmapData									{ return _thumb; }
		public function get content():*											{ return _content; }
		
		public function get title():String										{ return _title; }
		public function get subtitle():String									{ return _subtitle; }
		public function get description():String								{ return _description; }
		
		
		/* event handler */
		override protected function onLoadComplete(loader:LoaderMax):void
		{
			// content
			switch(_type)
			{
				case IMAGE:
					_content = loader.getContent("image").rawContent.bitmapData;
					break;
			}
			
			// thumb
			var thumbContent:* = loader.getContent("thumb");
			if(thumbContent != null) _thumb = thumbContent.rawContent.bitmapData;
		}
	}
}