package de.pixelscape.display.toolTip {
	import de.pixelscape.utils.TopLevelUtils;	import flash.display.DisplayObject;	import flash.display.Stage;	import flash.events.MouseEvent;	import flash.geom.Point;	/**
	 * @author Tobias Friese
	 */
	public class ToolTipManager 
	{
		/* variables */		private static var _instance:ToolTipManager;
		
		private var _stage:Stage = TopLevelUtils.instance.stage;
		private var _stack:Array = new Array();				private var _toolTipClass:Class = StandardToolTip;
				public function ToolTipManager()
		{
			if(_instance == null) _instance = this;
			else throw new Error("ToolTipManager is a Singleton and therefor can only be accessed through ToolTipManager.getInstance()");
		}
		
		/** singleton getter */
		public static function getInstance():ToolTipManager
		{
			if(_instance == null) _instance = new ToolTipManager();
			return _instance;
		}				public static function get instance():ToolTipManager		{			return getInstance();		}
		
		/* registration methods */
		public function registerToolTip(target:DisplayObject, content:*, xOff:Number = 0, yOff:Number = 0, delay:Number = 0):void
		{
			var triggerData:TriggerData = new TriggerData(target, content, xOff, yOff, delay);			this._stack.push(triggerData);						target.addEventListener(MouseEvent.MOUSE_OVER, this.handleTargetMouseOver);			target.addEventListener(MouseEvent.MOUSE_OUT, this.handleTargetMouseOut);
		}				public function unregisterToolTip(target:DisplayObject):void		{			for(var i:int = (this._stack.length - 1); i >= 0; i--)			{				if(this._stack[i].target === target) this._stack.splice(i, 1);			}		}
		
		/* methods */
		private function createToolTip(tData:TriggerData):void
		{
			if(tData != null)
			{
				// kill old				if(tData.toolTip != null) tData.toolTip.finalize();								// create new				var globalPosition:Point = tData.target.localToGlobal(new Point(tData.xOff, tData.yOff));
				
				var toolTip:ToolTip = new _toolTipClass(tData.content, tData.delay);				toolTip.x = globalPosition.x;				toolTip.y = globalPosition.y;								toolTip.initialize();								this._stage.addChild(toolTip);								tData.toolTip = toolTip;
			}
		}
		
		private function killToolTip(tData:TriggerData):void
		{
			if(tData != null)
			{
				if(tData.toolTip != null)
				{
					tData.toolTip.hide(tData.toolTip.finalize);
					tData.toolTip = null;
				}
			}
		}
		
		private function getDataByTarget(displayObject:DisplayObject):TriggerData
		{
			for(var i:uint = 0; i < this._stack.length; i++)
			{
				if(this._stack[i].target === displayObject) return this._stack[i];
			}
			
			return null;
		}
				/* getter setter */		public function get numToolTips():uint		{			return _stack.length;		}		
		/* event handler */
		private function handleTargetMouseOver(e:MouseEvent):void
		{
			this.createToolTip(this.getDataByTarget(e.currentTarget as DisplayObject));
		}
		
		private function handleTargetMouseOut(e:MouseEvent):void
		{
			this.killToolTip(this.getDataByTarget(e.currentTarget as DisplayObject));
		}
	}
	
	
}
