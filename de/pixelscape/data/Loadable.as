package de.pixelscape.data
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.core.LoaderCore;
	import com.greensock.loading.core.LoaderItem;
	
	import de.pixelscape.assets.cache.Cache;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Loadable extends EventDispatcher
	{
		/* variables */
		private var _loader:LoaderMax;
		private var _linkedLoadables:Vector.<Loadable>;
		
		private var _loaded:Boolean							= true;
		
		public function Loadable()
		{
		}
		
		/* methods */
		protected function appendToLoader(loader:LoaderCore, cacheByURL:Boolean = false):void
		{
			// cancellation
			if(loader == null) return;
			
			// lazy creation
			if(_loader == null)
			{
				_loader = new LoaderMax();
				_loaded = false;
			}
			
			// append
			if(cacheByURL && loader is LoaderItem)
			{
				var loaderItem:LoaderItem = LoaderItem(loader);
				
				if(!Cache.instance.contains("loadableloader_" + loaderItem.url))
				{
					_loader.append(loaderItem);
					Cache.instance.addData("loadableloader_" + loaderItem.url, loaderItem);
				}
				else
				{
					_loader.append(Cache.instance.getData("loadableloader_" + loaderItem.url));
				}
			}
			else _loader.append(loader);
		}
		
		public function linkLoadable(loadable:Loadable):void
		{
			// cancellation
			if(loadable == null) return;
			
			// lazy creation
			if(_linkedLoadables == null) _linkedLoadables = new Vector.<Loadable>();
			
			// add
			_linkedLoadables.push(loadable);
		}
		
		public function load():void
		{
			// load
			if(_loader != null)
			{
				if(_loader.status == LoaderStatus.READY)
				{
					// kill cache buster
					for each(var loaderCore:LoaderCore in _loader.getChildren()) if(loaderCore is LoaderItem) LoaderItem(loaderCore).vars.noCache = false;
					
					// add listeners
					_loader.addEventListener(LoaderEvent.COMPLETE, handleLoaderComplete);
					_loader.addEventListener(LoaderEvent.IO_ERROR, handleLoaderIOError);
					
					// load
					_loader.load();
				}
			}
			
			// linked
			if(_linkedLoadables != null)
			{
				for each(var linked:Loadable in _linkedLoadables)
				{
					if(!linked.loaded)
					{
						linked.addEventListener(Event.COMPLETE, handleLinkedComplete);
						linked.load();
					}
				}
			}
		}
		
		private function finalizeLoadingProcess():void
		{
			// cancellation
			if(_loaded) return;
			
			// remove listener
			_loader.removeEventListener(LoaderEvent.COMPLETE, handleLoaderComplete);
			
			// call trigger
			onLoadComplete(_loader);
			
			// set vars
			_loader = null;
			_loaded = true;
			
			// dispatch complete
			if(loaded) dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/* getter setter */
		public function get loaded():Boolean
		{
			if(_linkedLoadables == null) return _loaded;
			else
			{
				if(!_loaded) return false;
				else
				{
					for each(var linked:Loadable in _linkedLoadables) if(!linked.loaded) return false;
					return true;
				}
			}
		}
		
		public function get loadProgress():Number
		{
			var loadProgress:Number = _loaded ? 1 : _loader.progress;
			
			// linked
			if(_linkedLoadables != null)
			{
				for each(var linked:Loadable in _linkedLoadables) loadProgress += linked.loadProgress;
				loadProgress = loadProgress / (_linkedLoadables.length + 1);
			}
			
			// return
			return loadProgress;
		}
		
		/* event handler */
		private function handleLoaderIOError(e:LoaderEvent):void
		{
			// create error message
			var errorMessage:String = "Loadable Error. Unable to load the following files:\n\n"
			
			for each(var loader:LoaderCore in _loader.getChildren())
			{
				if(loader.status == LoaderStatus.FAILED)
				{
					var loaderId:String = loader is LoaderItem ? LoaderItem(loader).url : loader.toString();
					errorMessage += "» " + loaderId + "\n";
				}
			}
			
			// throw
			throw new Error(errorMessage);
		}
		
		private function handleLoaderComplete(e:LoaderEvent):void
		{
			finalizeLoadingProcess();
		}
		
		private function handleLinkedComplete(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, handleLinkedComplete);
			
			if(loaded) dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/* overrides */
		protected function onLoadComplete(loader:LoaderMax):void
		{
		}
	}
}