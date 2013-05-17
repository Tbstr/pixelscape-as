package de.pixelscape.display.viewManager
{
	import de.pixelscape.display.viewManager.data.ViewManagerCycleType;
	import de.pixelscape.display.viewManager.event.ViewManagerEvent;
	import de.pixelscape.display.viewManager.transition.ViewTransition;
	import de.pixelscape.display.viewManager.view.View;
	import de.pixelscape.graphics.Picasso;
	import de.pixelscape.output.notifier.Notifier;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;

	public class ViewManager extends EventDispatcher
	{
		/* instance variables */
		private static var _instance:ViewManager;		private static var _instances:Object = new Object();
		
		/* variables */
		private var _container:DisplayObjectContainer;
		
		private var _views:Vector.<View>					= new Vector.<View>();
		private var _currentView:View						= null;
		
		private var _canvasWidth:Number						= -1;
		private var _canvasHeight:Number					= -1;
		
		private var _mask:Shape;
		private var _maskEnabled:Boolean					= false;
				
		private var _cycleType:String						= ViewManagerCycleType.BOUND;
		private var _defaultTransition:ViewTransition		= null;
		
		private var _transitionRunning:Boolean				= false;
		private var _initialized:Boolean;
		
		public function ViewManager()
		{}
		
		/* [multi] singleton getter */
		public static function getInstance(id:String = null):ViewManager
		{
			if(id == null)
			{
				if(_instance == null) _instance = new ViewManager();
				return _instance;
			}
			
			if(id in _instances) return _instances[id];
			else
			{
				var viewManager:ViewManager = new ViewManager();
				_instances[id] = viewManager;
				return viewManager;
			}
		}
		
		public static function get instance():ViewManager
		{
			if(_instance == null) _instance = new ViewManager();
			return _instance;
		}
		
		/* initiation */
		public function initialize(container:DisplayObjectContainer, width:Number, height:Number):void
		{
			this._container = container;
			
			this._canvasWidth = width;
			this._canvasHeight = height;
			
			this._initialized = true;
		}
		
		private function initCheck():Boolean
		{
			if(!this._initialized) throw new Error("ViewManager has not yet been initialized. Please initialize using the initialize() method befor calling other class methods.");
			return this._initialized;
		}
		
		/* view handling */
		public function registerView(view:View):void
		{
			if(!initCheck()) return;
			
			if(this.getViewByID(view.id) == null)
			{
				view.setCanvasSize(this._canvasWidth, this._canvasHeight);
				view.manager = this;
				view.enabled = false;
				
				this._views.push(view);
			}
			else throw new Error("A View with id »" + view.id + "« is already registered.");
		}
		
		public function view(view:*, data:Object = null, animated:Boolean = true, transitionOverride:ViewTransition = null):Boolean
		{
			if(!initCheck()) return false;
			
			var viewInstance:View;
			
			// null
			if(view == null) return this.viewInternal(null, null, animated, transitionOverride);
			
			// id
			if(view is String)
			{
				viewInstance = this.getViewByID(String(view));
				
				if(viewInstance != null) return this.viewInternal(viewInstance, data, animated, transitionOverride);
				else throw new Error("View with id »" + String(view) + "« is not defined.");
			}
			
			// index
			if(view is int)
			{
				if((view >= 0) && (view < this._views.length))
				{
					viewInstance = this._views[int(view)];
					return this.viewInternal(viewInstance, data, animated, transitionOverride);
				}
				else throw new Error("Index out of range.");
			}
			
			// view
			if(view is View)
			{
				if(this._views.indexOf(view) != -1) return this.viewInternal(View(view), data, animated, transitionOverride);
				else throw new Error("View »" + View(view).toString() + "« is not registered for this ViewManager.");
			}
			
			return false;
		}
		
		private function viewInternal(view:View, data:Object = null, animated:Boolean = true, transitionOverride:ViewTransition = null):Boolean
		{
			// cancellation
			if(_transitionRunning)			return false;
			if(view === _currentView)		return false;
			
			// variables
			var success:Boolean				= false;
			
			var opening:Boolean				= _currentView == null;
			var closing:Boolean				= view == null;
			
			var transition:ViewTransition 	= transitionOverride == null ? _defaultTransition : transitionOverride;
			
			_transitionRunning = true;
			
			// direction
			var forward:Boolean;
			
			if(view == null) forward = false;
			else if(_cycleType == ViewManagerCycleType.LOOP) forward = true;
			else forward = _views.indexOf(view) > _views.indexOf(_currentView);
			
			// with animation
			if(animated)
			{
				// animation
				var recentView:View = _currentView;
				
				if(transition != null && !transition.running)
				{
					addView(view, data);
					
					if(transition !== _defaultTransition) transition.addEventListener(ViewTransition.TRANSITION_COMPLETE, handleTransitionComplete, false, 0, true);
					transition.start(recentView, view, forward);
					
					success = true;
				}
				else
				{
					animated = false;
				}
			}
			
			// without animation
			if(!animated)
			{
				// no animation
				removeView(_currentView);
				addView(view, data);
				
				_transitionRunning = false;
				success = true;
			}
			
			// dispatch
			if(success)
			{
				dispatchViewChanged();
				
				if(opening) dispatchViewOpened();
				if(closing) dispatchViewClosed();
			}
			
			// return
			return success;
		}
		
		public function viewNext(data:Object = null, animated:Boolean = true, transitionOverride:ViewTransition = null):Boolean
		{
			if(!initCheck()) return false;
			
			var currentIndex:int = this.getViewIndex(this._currentView);
			var success:Boolean = false;
			
			if(currentIndex != -1)
			{
				if(++currentIndex < this._views.length) success = this.viewInternal(this._views[currentIndex], data, animated, transitionOverride);
				else if(this._cycleType == ViewManagerCycleType.LOOP) success = this.viewInternal(this._views[0], data, animated, transitionOverride);
			}
			
			// dispatch
			if(success) dispatchViewNext();
			
			// return
			return success;
		}
		
		public function viewPrevious(data:Object = null, animated:Boolean = true, transitionOverride:ViewTransition = null):Boolean
		{
			if(!initCheck()) return false;
			
			var currentIndex:int = this.getViewIndex(this._currentView);
			var success:Boolean = false; 
			
			if(currentIndex != -1)
			{
				if(--currentIndex >= 0) success = this.viewInternal(this._views[currentIndex], data, animated, transitionOverride);
				else if(this._cycleType == ViewManagerCycleType.LOOP) success = this.viewInternal(this._views[this._views.length - 1], data, animated, transitionOverride);
			}
			
			// dispatch
			if(success) dispatchViewPrevious();
			
			// return
			return success;
		}
		
		private function addView(view:View, data:Object = null):void
		{
			if(view != null)
			{
				// add
				this._container.addChild(view);
				
				// init
				view.enabled = true;
				view.setCanvasSize(this._canvasWidth, this._canvasHeight);
				view.init(data);
			}
			
			// variables
			this._currentView = view;
		}
		
		private function removeView(view:View):void
		{
			if(view != null)
			{
				view.enabled = false;
				if(this._container.contains(view)) this._container.removeChild(view);
			}
		}
		
		public function enumerateViews():Vector.<String>
		{
			var ids:Vector.<String> = new Vector.<String>();
			for(var i:int = 0; i < this._views.length; i++) ids.push(this._views[i].id);
			
			return ids;
		}
		
		public function closeView(animated:Boolean = true, transitionOverride:ViewTransition = null):void
		{
			if(_currentView != null) viewInternal(null, null, animated, transitionOverride);
		}
		
		public function clearView():void
		{
			if(this._currentView == null) return;
			
			this.removeView(this._currentView);
			this._currentView = null;
		}
		
		/* getter setter */
		private function getViewByID(id:String):View
		{
			for each(var view:View in this._views)
			{
				if(view.id == id) return view;
			}
			
			return null;
		}
		
		private function getViewIndex(view:View):int
		{
			for(var i:int = 0; i < this._views.length; i++) if(this._views[i] === view) return i;
			return -1;
		}
		
		public function hasView(id:String):Boolean
		{
			for each(var view:View in _views) if(view.id == id) return true;
			return false;
		}
		
		public function get canvasWidth():Number
		{
			return _canvasWidth;
		}
		
		public function get canvasHeight():Number
		{
			return _canvasHeight;
		}
		
		public function setCanvasSize(width:Number, height:Number):void
		{
			if(!initCheck()) return;
			
			this._canvasWidth = width;
			this._canvasHeight = height;
			
			// mask
			if(this._mask != null)
			{
				Picasso.clear(this._mask);
				Picasso.drawRectangle(this._mask, 0, 1, 0, 0, width, height);
			}
			
			// current view
			if(this._currentView != null) this._currentView.setCanvasSize(width, height);
		}
		
		public function get initialized():Boolean
		{
			return this._initialized;
		}
		
		public function get maskEnabled():Boolean
		{
			return this._maskEnabled;
		}
		
		public function set maskEnabled(value:Boolean):void
		{
			if(this._maskEnabled != value)
			{
				this._maskEnabled = value;
				
				if(value)
				{
					this._mask = new Shape();
					Picasso.drawRectangle(this._mask, 0, 1, 0, 0, this._canvasWidth, this._canvasHeight);
					
					this._container.addChild(this._mask);
					this._container.mask = this._mask;
				}
				else
				{
					this._container.mask = null;
					this._container.removeChild(this._mask);
					this._mask = null;
				}
			}
		}
		
		public function get cycleType():String
		{
			return this._cycleType;
		}
		
		public function set cycleType(value:String):void
		{
			switch(value)
			{
				case ViewManagerCycleType.BOUND:
				case ViewManagerCycleType.LOOP:
				
					this._cycleType = value;
					break;
			}
		}
		
		public function get defaultTransitionName():String
		{
			return getQualifiedClassName(this._defaultTransition);
		}
		
		public function set defaultTransition(value:ViewTransition):void
		{
			if(this._defaultTransition != null) this._defaultTransition.removeEventListener(ViewTransition.TRANSITION_COMPLETE, this.handleTransitionComplete);
			if(value != null) value.addEventListener(ViewTransition.TRANSITION_COMPLETE, this.handleTransitionComplete);

			this._defaultTransition = value;
		}
		
		public function get numViews():int
		{
			return this._views.length;
		}
		
		public function get currentView():View
		{
			return this._currentView;
		}
		
		public function get currentViewID():String
		{
			if(this._currentView != null) return this._currentView.id;
			return null;
		}
		
		public function get currentViewIndex():int
		{
			if(this._currentView != null) return this.getViewIndex(this._currentView);
			return -1;
		}
		
		/* dispatch methods */
		private function dispatchViewOpened():void
		{
			dispatchEvent(new ViewManagerEvent(ViewManagerEvent.VIEW_OPENED));
		}
		
		private function dispatchViewNext():void
		{
			dispatchEvent(new ViewManagerEvent(ViewManagerEvent.VIEW_NEXT));
		}
		
		private function dispatchViewPrevious():void
		{
			dispatchEvent(new ViewManagerEvent(ViewManagerEvent.VIEW_PREVIOUS));
		}
		
		private function dispatchViewClosed():void
		{
			dispatchEvent(new ViewManagerEvent(ViewManagerEvent.VIEW_CLOSED));
		}
		
		private function dispatchViewChanged():void
		{
			dispatchEvent(new ViewManagerEvent(ViewManagerEvent.VIEW_CHANGED));
		}
		
		/* event handler */
		private function handleTransitionComplete(e:Event):void
		{
			var viewTransition:ViewTransition = ViewTransition(e.currentTarget);
			
			// remove old view
			removeView(viewTransition.oldView);
			
			// set vars
			_transitionRunning = false;
			
			// unregister & finalize if overridden
			if(viewTransition !== _defaultTransition)
			{
				viewTransition.removeEventListener(ViewTransition.TRANSITION_COMPLETE, handleTransitionComplete);
				viewTransition.finalize();
			}
		}
	}
}