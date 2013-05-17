package de.pixelscape.display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;		

	/**
	 * The ColorPanel class generates different types of color schemes to be used as colorpicker.
	 * 
	 * @author Tobias Friese
	 * 
	 * Color generation code from Ryan Taylor | http://www.boostworthy.com
	 */
	public class ColorPanel extends Sprite 
	{
		private var _panelWidth:uint;		private var _panelHeight:uint;
		
		private var _type:String;
		
		private var _lastPreviewColor:uint;		private var _lastPickedColor:uint;
		
		private var _bitmapData:BitmapData;
		private var _bitmap:Bitmap;
		
		private var _cursor:Shape;
		private var _cursorColor:uint;
		
		public static const TYPE_BAR:String = "typeBar";//		public static const TYPE_CIRCLE:String = "typeCircle";		
		public static const COLOR_PICKED:String = "colorPicked";		public static const COLOR_PREVIEW:String = "colorPreview";
		
		/**
		 *  ColorPanel constructor
		 *  
		 *  @param width the width of the ColorPanel		 *  @param height the height of the ColorPanel
		 *  @param type the display type (defines colors and shape of the panel)
		 * 
		 */
		public function ColorPanel(width:uint, height:uint, type:String = TYPE_BAR)
		{
			_panelWidth			= width;
			_panelHeight		= height;
			
			_type				= type;
			
			_lastPreviewColor	= 0;			_lastPickedColor	= 0;
			
			_cursorColor		= 0xCCCCCC;
			
			// build
			build();
			
			// event listeners
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		private function build():void
		{
			// scheme
			redrawScheme();
			
			// cursor
			_cursor = new Shape();
			_cursor.visible = false;
			
			with(_cursor.graphics)
			{
				beginFill(_cursorColor, 1);
				lineStyle();
				
				drawRect(0,0,1,1);
				
				drawRect(0, -5, 1, 3);				drawRect(2, 0, 3, 1);				drawRect(0, 2, 1, 3);				drawRect(-5, 0, 3, 1);
			}
		}
		
		private function redrawScheme():void
		{
			switch(_type)
			{
				default:
					redrawBarScheme();
					break;
			}
		}
		
		private function redrawBarScheme():void
		{
			var nWidth		  : Number;
			var nHeight		  : Number;
			
			var nColorPercent : Number;
			var nRadians      : Number;
			var nR            : Number;
			var nG            : Number;
			var nB            : Number;
			var nColor        : Number;
			var objMatrixW    : Matrix;
			var objMatrixB    : Matrix;			var nHalfHeight   : Number;
			
			// Clear the graphics container.
			graphics.clear();
			
			// set width and height
			nWidth = _panelWidth;			nHeight = _panelHeight;
			
			// Calculate half of the height.
			nHalfHeight = nHeight * 0.5;
			
			// Loop through all of the pixels from '0' to the specified width.
			for(var i:int = 0; i < nWidth; i++)
			{
				// Calculate the color percentage based on the current pixel.
				nColorPercent = i / nWidth;
				
				// Calculate the radians of the angle to use for rotating color values.
				nRadians = (-360 * nColorPercent) * (Math.PI / 180);
				
				// Calculate the RGB channels based on the angle.
				nR = Math.cos(nRadians)                   * 127 + 128 << 16;
				nG = Math.cos(nRadians + 2 * Math.PI / 3) * 127 + 128 << 8;
				nB = Math.cos(nRadians + 4 * Math.PI / 3) * 127 + 128;
				
				// OR the individual color channels together.
				nColor  = nR | nG | nB;
				
				// Create new matrices for the white and black gradient lines.
				objMatrixW = new Matrix();
				objMatrixW.createGradientBox(1, nHalfHeight, Math.PI * 0.5, 0, 0);
				objMatrixB = new Matrix();
				objMatrixB.createGradientBox(1, nHalfHeight, Math.PI * 0.5, 0, nHalfHeight);
				
				// Each color slice is made up of two lines - one for fading from white to the 
				// color, and one for fading from the color to black.
				graphics.lineStyle(1, 0, 1, false, LineScaleMode.NONE, CapsStyle.NONE);
				graphics.lineGradientStyle(GradientType.LINEAR, [0xFFFFFF, nColor], [1, 1], [0, 255], objMatrixW);
				graphics.moveTo(i, 0);
				graphics.lineTo(i, nHalfHeight);
				graphics.lineGradientStyle(GradientType.LINEAR, [nColor, 0], [1, 1], [0, 255], objMatrixB);
				graphics.moveTo(i, nHalfHeight);
				graphics.lineTo(i, nHeight);
			}
			
			// convert to bitmap
			if(_bitmapData != null) _bitmapData.dispose();
			if(_bitmap != null) removeChild(_bitmap);
			
			_bitmapData = new BitmapData(this.width, this.height);
			_bitmapData.draw(this);
			
			this.graphics.clear();
			
			_bitmap = new Bitmap(_bitmapData);
			addChild(_bitmap);
		}
		
		/* getter methods */
		
		/** returns the width of the panel */
		override public function get width():Number
		{
			return _panelWidth;
		}
		
		/** returns the height of the panel */
		override public function get height():Number
		{
			return _panelHeight;
		}
		
		/** returns the last previewed color */
		public function get lastPreviewColor():uint
		{
			return _lastPreviewColor;
		}
		
		/** returns the last picked color */
		public function get lastPickedColor():uint
		{
			return _lastPickedColor;
		}

		/* setter methods */
		
		/** defines the width of the panel */
		public function set panelWidth(value:uint):void
		{
			_panelWidth = value;
			
			redrawScheme();
		}
		
		/** defines the height of the panel */
		public function set panelHeight(value:uint):void
		{
			_panelHeight = value;
			
			redrawScheme();
		}
		
		/** defines the type of the panel */
		public function set type(value:String):void
		{
			_type = value;
			
			redrawScheme();
		}
		
		// methods
		private function constrain(value:Number, min:Number, max:Number):Number
		{
			if(value < min) return min;
			if(value > max) return max;
			return value;
		}
		
		/**
		 * Returns the color value at the defined coordinates.
		 * 
		 * @param x the x coordinate for the pixel to be picked		 * @param y the y coordinate for the pixel to be picked
		 */
		public function pick(x:int, y:int):uint
		{
			return _bitmapData.getPixel(constrain(x, 0, _panelWidth - 1), constrain(y, 0, _panelHeight - 1));
		}
		
		// event handler
		private function addedToStageHandler(e:Event):void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function removedFromStageHandler(e:Event):void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseDownHandler(e:MouseEvent):void
		{
			// set listener
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseMoveHandler(e:MouseEvent):void
		{
			_lastPreviewColor = pick(this.mouseX, this.mouseY);
			
			dispatchEvent(new Event(COLOR_PREVIEW));
		}

		private function mouseUpHandler(e:MouseEvent):void
		{
			_lastPickedColor = pick(this.mouseX, this.mouseY);
			
			dispatchEvent(new Event(COLOR_PICKED));
			
			// remove listener
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
	}
}
