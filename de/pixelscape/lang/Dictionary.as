package de.pixelscape.lang
{
	import de.pixelscape.output.notifier.Notifier;
	import de.pixelscape.utils.StringUtils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
		public class Dictionary extends EventDispatcher
	{
		/* variables */
		private static var _instance:Dictionary;
		
		private var _vocabulary:XML;
		private var _urlLoader:URLLoader;
		
		private var _defaultLanguage:String = Languages.GLOBAL;
		
		/* constants */
		public static const LIBRARY_LOADED:String = "Dictionary.libraryLoaded";
				public function Dictionary()
		{
			if(_instance == null) _instance = this;
			else throw new Error("Dictionary is a singleton class and therefor can only be accessed through Dictionary.getInstance() or Dictionary.instance.");
		}
		
		public static function getInstance():Dictionary
		{
			if(_instance == null) _instance = new Dictionary();
			return _instance;
		}
		
		public static function get instance():Dictionary
		{
			return getInstance();
		}
		
		public function loadLibrary(library:*):void
		{
			if(library is String)
			{
				this._urlLoader = new URLLoader();
				this._urlLoader.addEventListener(Event.COMPLETE, this.handleLibraryLoaded);
				this._urlLoader.load(new URLRequest(String(library)));
			}
			else if(library is XML)
			{
				this._vocabulary = XML(library);
				this.dispatchLibraryLoaded();
			}
		}
		
		public function get(id:String, lang:String = null):String
		{
			if(this._vocabulary != null)
			{
				if(lang == null) lang = this._defaultLanguage;
				var errMsg:String;
				
				var entries:XMLList = this._vocabulary.entry.(@id == id);
				if(entries.length() > 0)
				{
					var attributes:XMLList = XML(entries[0]).attribute(lang);
					
					if(attributes.length() > 0) return attributes[0].toString();
					else
					{
						var childNodes:XMLList = XML(entries[0]).child(lang);
						if(childNodes.length() > 0) return StringUtils.clean(childNodes[0].toString(), ["\r", "\t"], " ");
						else errMsg = "No vocabulary found for language code \"" + lang + "\" on id \"" + id + "\".";
					}
				}
				else errMsg = "No vocabulary found with id \"" + id + "\".";
			}
			else errMsg = "No library loaded. Use Dictionary.loadLibrary() first.";
			
			if(errMsg != null)
			{
				if(Notifier.instance.initialized) Notifier.notify(errMsg);
				else trace(errMsg);
			}
			
			return("-----");
		}
		
		/* static shortcuts */
		public static function loadLibrary(library:*):void
		{
			_instance.loadLibrary(library);
		}
		
		public static function get(id:String, lang:String = null):String
		{
			return _instance.get(id, lang);
		}
		
		/* getter setter */
		public function get libraryLoaded():Boolean
		{
			return (this._vocabulary != null);
		}
		
		public function set defaultLanguage(value:String):void
		{
			this._defaultLanguage = value;
		}
		
		public function get defaultLanguage():String
		{
			return this._defaultLanguage;
		}
		
		/* event dispatcher */
		private function dispatchLibraryLoaded():void
		{
			this.dispatchEvent(new Event(LIBRARY_LOADED));
		}
		
		/* event handler */
		private function handleLibraryLoaded(e:Event):void
		{
			this._urlLoader.removeEventListener(Event.COMPLETE, this.handleLibraryLoaded);
			this._vocabulary = new XML(URLLoader(e.currentTarget).data);
			this._urlLoader = null;
			
			this.dispatchLibraryLoaded();
		}
	}
}