package de.pixelscape.graphics
{
	import de.pixelscape.output.notifier.Notifier;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextLineMetrics;

	/**
	 * The Picasso class simplyfies basic drawing tasks, such as drawing rectangles 
	 * or circles, to a single line of code.
	 * 
	 * @author Tobias Friese
	 * @version 1.2
	 * 
	 * recent change 30.01.2009
	 */
	public class Picasso
	{
		/* constants */
		private static const CEIL:Function		= Math.ceil;		private static const FLOOR:Function		= Math.floor;		private static const ABS:Function		= Math.abs;		private static const PI:Number			= Math.PI;		private static const COS:Function		= Math.cos;		private static const SIN:Function		= Math.sin;		private static const SQRT:Function		= Math.sqrt;		private static const ATAN2:Function		= Math.atan2;
		
		// basic
		public static function clear(target:*):void
		{
			target.graphics.clear();
		}
		
		// shapes
		
		/**
		 * Draws a pixel.
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param x the x-origin
		 * @param y the y-origin
		 */
		public static function drawPixel(target:*, color:uint, alpha:Number, x:int, y:int):void
		{
			var g:Graphics = target.graphics;
			
			g.beginFill(color, alpha);
			g.lineStyle();
			g.drawRect(x, y, 1, 1);
			g.endFill();
		}
		
		/**
		 * Draws an icon pixel by pixel based on data provided as an <code>Array</code>.
		 * 
		 * <p>The <code>Array</code> holding the data for the position of each pixel is a
		 * two-dimensional <code>Array</code> representing the icons width and height, filled with either a
		 * 0 for no pixel or 1 for pixel.</p>
		 * 
		 * @example
		 * <p><listing><pre>
		 * var arr:Array = new Array();
		 * 
		 * arr.push(new Array(0,1,0,1,0));
		 * arr.push(new Array(0,0,0,0,0));
		 * arr.push(new Array(0,0,1,0,0));
		 * arr.push(new Array(1,0,0,0,1));
		 * arr.push(new Array(0,1,1,1,0));
		 * </pre></listing></p>
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param xOff the x-offset for drawing
		 * @param yOff the y-offset for drawing
		 * @param pixelArray the <code>Array</code> holding th drawing data
		 * 
		 * @see drawPixel
		 */
		public static function drawFromArray(target:*, color:uint, alpha:Number, xOff:int, yOff:int, pixelArray:Array):void
		{
			for(var y:Number = 0; y < pixelArray.length; y++)
			{
				for(var x:Number = 0; x < pixelArray[y].length; x++)
				{
					if(pixelArray[y][x] == 1)
					{
						drawPixel(target, color, alpha, x + xOff, y + yOff);
					}
				}
			}
		}
		
		/**
		 * Draws a rectangle.
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param xOff the x-offset for drawing
		 * @param yOff the y-offset for drawing
		 * @param width width of the rectangle
		 * @param height height of the rectangle
		 * @param strokeProps an Array holding attributes for the lineStyle method
		 */
		public static function drawRectangle(target:*, color:*, alpha:Number, xOff:Number, yOff:Number, width:Number, height:Number, strokeProps:Array = null):void
		{
			var g:Graphics = target.graphics;
			
			initFill(g, color, alpha);
			g.lineStyle.apply(target.graphics, strokeProps);
			g.drawRect(xOff, yOff, width, height);
			completeFill(g, color);
		}
		
		/**
		 * Draws a rectangle with rounded corners.
		 * 
		 * <p>The attribute <code>rad</code> can be a Number or an Array with 4 elements depending on
		 * your need to define one radius for all corners or different radi for each corner.</p>
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param xOff the x-offset for drawing
		 * @param yOff the y-offset for drawing
		 * @param width width of the rectangle
		 * @param height height of the rectangle
		 * @param rad the radius for all corners as Number or the radius for each single corner as Array with 4 elements(leftTop, rightTop, rightBottom, leftBottom)
		 * @param strokeProps an Array holding attributes for the lineStyle method
		 */
		public static function drawRoundedRectangle(target:*, color:*, alpha:Number, xOff:Number, yOff:Number, width:Number, height:Number, rad:*, strokeProps:Array = null):void
		{
			var g:Graphics = target.graphics;
			
			if(rad is Number)
			{
				initFill(g, color, alpha);
				g.lineStyle.apply(g, strokeProps);
				g.drawRoundRect(xOff, yOff, width, height, rad * 2, rad * 2);
				completeFill(g, color);
			}
			else if(rad is Array)
			{
				initFill(g, color, alpha);
				g.lineStyle.apply(g, strokeProps);
				g.drawRoundRectComplex(xOff, yOff, width, height, rad[0], rad[1], rad[2], rad[3]);
				completeFill(g, color);
			}
		}
		
		/**
		 * Draws a rectangle according to information from a Rectangle object.
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param rectangle a Rectangle object
		 * @param strokeProps an Array holding attributes for the lineStyle method
		 */
		public static function drawFromRectangle(target:*, color:*, alpha:Number, rectangle:Rectangle, cornerRadius:* = 0, strokeProps:Array = null):void
		{
			if(cornerRadius == 0) drawRectangle(target, color, alpha, rectangle.x, rectangle.y, rectangle.width, rectangle.height, strokeProps);
			else drawRoundedRectangle(target, color, alpha, rectangle.x, rectangle.y, rectangle.width, rectangle.height, cornerRadius, strokeProps);
		}
		
		/**
		 * Draws a custom shape.
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param xOff the x-offset for drawing
		 * @param yOff the y-offset for drawing
		 * @param rectangle a Rectangle object
		 * @param strokeProps an Array holding attributes for the lineStyle method
		 */
		public static function drawCustomShape(target:*, color:*, alpha:Number, xOff:Number, yOff:Number, shapeData:*, strokeProps:Array = null):void
		{
			var g:Graphics = target.graphics;
			
			initFill(g, color, alpha);
			g.lineStyle.apply(g, strokeProps);
			
			// array
			if(shapeData is Array)
			{
				var cursor:int = 0;
				
				var commands:Vector.<int> = new Vector.<int>();
				commands.push(1);
				
				var coordinates:Vector.<Number> = new Vector.<Number>();
				coordinates.push(xOff, yOff);
				
				while(cursor < shapeData.length)
				{
					switch(shapeData[cursor])
					{
						case 1:
						case 2:
							commands.push(shapeData[cursor]);
							coordinates.push(shapeData[cursor + 1] + xOff, shapeData[cursor + 2] + yOff);
							cursor += 3;
							break;
						
						case 3:
						case 4:
						case 5:
							commands.push(shapeData[cursor]);
							coordinates.push(shapeData[cursor + 1] + xOff, shapeData[cursor + 2] + yOff, shapeData[cursor + 3] + xOff, shapeData[cursor + 4] + yOff);
							cursor += 5;
							break;
						
						case 0:
						default:
							cursor++;
							break;
					}
				}
				
				g.drawPath(commands, coordinates);
			}
			
			completeFill(g, color);
		}
		
		/**
		 * Draws a circle.
		 * 
		 * <p>The origin is the center of the circle.</p>
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param x the x-origin
		 * @param y the y-origin
		 * @param rad radius of the circle
		 * @param strokeProps an Array holding attributes for the lineStyle method
		 */
		public static function drawCircle(target:*, color:*, alpha:Number, x:Number, y:Number, rad:Number, strokeProps:Array = null):void
		{
			var g:Graphics = target.graphics;
			
			initFill(g, color, alpha);
			g.lineStyle.apply(g, strokeProps);
			g.drawCircle(x, y, rad);
			completeFill(g, color);
		}
		
		/**
		 * Draws an ellipse.
		 * 
		 * <p>The origin is the center of the ellipse.</p>
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param x the x-origin
		 * @param y the y-origin
		 * @param xRad x-radius of the ellipse
		 * @param yRad y-radius of the ellipse
		 * @param strokeProps an Array holding attributes for the lineStyle method
		 */
		public static function drawEllipse(target:*, color:*, alpha:Number, x:Number, y:Number, xRad:Number, yRad:Number, strokeProps:Array = null):void
		{
			var g:Graphics = target.graphics;
			
			initFill(g, color, alpha);
			g.lineStyle.apply(g, strokeProps);
			g.drawEllipse(x - xRad, y - yRad, xRad * 2, yRad * 2);
			completeFill(g, color);
		}
		
		/**
		 * Draws a wedge.
		 */
		public static function drawWedge(target:*, color:*, alpha:Number, x:Number, y:Number, xRadius:Number, yRadius:Number, startAngle:Number, arc:Number, strokeProps:Array = null):void
		{
			var g:Graphics = target.graphics;
			
			initFill(g, color, alpha);
			g.lineStyle.apply(g, strokeProps);
			
			// ==============
			// mc.drawWedge() - by Ric Ewing (ric@formequalsfunction.com) - version 1.3 - 6.12.2002
			//
			// x, y = center point of the wedge.
			// startAngle = starting angle in degrees.
			// arc = sweep of the wedge. Negative values draw clockwise.
			// xRadius = radius of wedge. If [optional] yRadius is defined, then radius is the x radius.
			// yRadius = [optional] y radius for wedge.
			// ==============
			// Thanks to: Robert Penner, Eric Mueller and Michael Hurwicz for their contributions.
			// ==============
	
			// move to x,y position
			g.moveTo(x, y);
			
			// Init vars
			var segAngle:Number, theta:Number, angle:Number, angleMid:Number, segs:Number, ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number;
			
			// limit sweep to reasonable numbers
			if(ABS(arc) > 360) arc = 360;
			
			// Flash uses 8 segments per circle, to match that, we draw in a maximum
			// of 45 degree segments. First we calculate how many segments are needed
			// for our arc.
			segs = CEIL(ABS(arc) / 45);
			
			// Now calculate the sweep of each segment.
			segAngle = arc / segs;
			
			// The math requires radians rather than degrees. To convert from degrees
			// use the formula (degrees/180)*Math.PI to get radians.
			theta = -(segAngle / 180) * PI;
			
			// convert angle startAngle to radians
			angle = -(startAngle / 180) * PI;
			
			// draw the curve in segments no larger than 45 degrees.
			if(segs > 0)
			{
				// draw a line from the center to the start of the curve
				ax = x + COS(startAngle / 180 * PI) * xRadius;
				ay = y + SIN(-startAngle / 180 * PI) * yRadius;
				g.lineTo(ax, ay);
				
				// Loop for drawing curve segments
				for(var i:Number = 0; i < segs; i++)
				{
					angle += theta;
					angleMid = angle-(theta / 2);
					bx = x + COS(angle) * xRadius;
					by = y + SIN(angle) * yRadius;
					cx = x + COS(angleMid) * (xRadius / COS(theta / 2));
					cy = y + SIN(angleMid) * (yRadius / COS(theta / 2));
					g.curveTo(cx, cy, bx, by);
				}
				
				// close the wedge by drawing a line to the center
				g.lineTo(x, y);
			}
			
			completeFill(g, color);
		}
		
		/**
		 * Draws a line from one point to another.
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param thickness defines the line weight
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param x0 x-value of starting point
		 * @param y0 y-value of starting point
		 * @param x1 x-value of ending point
		 * @param y1 y-value of ending point
		 */
		public static function drawLine(target:*, thickness:Number, color:uint, alpha:Number, x0:Number, y0:Number, x1:Number, y1:Number):void
		{
			var g:Graphics = target.graphics;
			
			g.lineStyle(thickness, color, alpha);
			g.moveTo(x0, y0);
			g.lineTo(x1, y1);
		}
		
		/**
		 * Draws a dashed line from one point to another.
		 * 
		 * @param target the DisplayObject to draw into (Shape, Sprite or MovieClip)
		 * @param thickness defines the line weight
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param x0 x-value of starting point
		 * @param y0 y-value of starting point
		 * @param x1 x-value of ending point
		 * @param y1 y-value of ending point
		 * @param dashLength length of dashes
		 * @param gapLength length of gaps
		 */
		public static function drawDashedLine(target:*, thickness:Number, color:uint, alpha:Number, x0:Number, y0:Number, x1:Number, y1:Number, dashLength:Number, gapLength:Number):void
		{
			var g:Graphics = target.graphics;
			
			g.lineStyle(thickness, color, alpha);
			
			var seglength:Number, delta:Number, deltax:Number, deltay:Number, segs:Number, cx:Number, cy:Number, radians:Number;
			
			// calculate the legnth of a segment
			seglength = dashLength + gapLength;
			
			// calculate the length of the dashed line
			deltax = x1 - x0;
			deltay = y1 - y0;
			delta = SQRT((deltax * deltax) + (deltay * deltay));
			
			// calculate the number of segments needed
			segs = FLOOR(ABS(delta / seglength));
			
			// get the angle of the line in radians
			radians = ATAN2(deltay, deltax);
			
			// start the line here
			cx = x0;
			cy = y0;
			
			// add these to cx, cy to get next seg start
			deltax = COS(radians) * seglength;
			deltay = SIN(radians) * seglength;
			
			// loop through each seg
			for(var n:Number = 0; n < segs; n++)
			{
				g.moveTo(cx, cy);
				g.lineTo(cx + (COS(radians) * dashLength), cy + SIN(radians) * dashLength);
	
				cx += deltax;
				cy += deltay;
			}
			
			// handle last segment as it is likely to be partial
			g.moveTo(cx, cy);
			delta = SQRT((x1 - cx) * (x1 - cx) + (y1 - cy) * (y1 - cy));
			if(delta > dashLength)
			{
				// segment ends in the gap, so draw a full dash
				g.lineTo(cx + COS(radians) * dashLength, cy + SIN(radians) * dashLength);
			}
			else if(delta > 0)
			{
				// segment is shorter than dash so only draw what is needed
				g.lineTo(cx + COS(radians) * delta, cy + SIN(radians) * delta);
			}
			
			// move the pen to the end position
			g.moveTo(x1, y1);
		}
		
		public static function drawArc(target:*, thickness:Number, color:uint, alpha:Number, x:Number, y:Number, xRad:Number, yRad:Number, startAngle:Number, arc:Number):void
		{
			var g:Graphics = target.graphics;
			
			g.lineStyle(thickness, color, alpha);
			g.moveTo(x, y);
			
			// ==============
			// mc.drawArc() - by Ric Ewing (ric@formequalsfunction.com) - version 1.5 - 4.7.2002
			// 
			// x, y = This must be the current pen position... other values will look bad
			// radius = radius of Arc. If [optional] yRadius is defined, then r is the x radius
			// arc = sweep of the arc. Negative values draw clockwise.
			// startAngle = starting angle in degrees.
			// yRadius = [optional] y radius of arc. Thanks to Robert Penner for the idea.
			// ==============
			// Thanks to: Robert Penner, Eric Mueller and Michael Hurwicz for their contributions.
			// ==============
	
			// Init vars
			var segAngle:Number, theta:Number, angle:Number, angleMid:Number, segs:Number, ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number;
			
			// no sense in drawing more than is needed :)
			if(ABS(arc) > 360) arc = 360;
			
			// Flash uses 8 segments per circle, to match that, we draw in a maximum
			// of 45 degree segments. First we calculate how many segments are needed
			// for our arc.
			segs = CEIL(ABS(arc) / 45);
			
			// Now calculate the sweep of each segment
			segAngle = arc / segs;
			
			// The math requires radians rather than degrees. To convert from degrees
			// use the formula (degrees/180)*Math.PI to get radians. 
			theta = -(segAngle / 180) * PI;
			
			// convert angle startAngle to radians
			angle = -(startAngle / 180) * PI;
			
			// find our starting points (ax,ay) relative to the secified x,y
			ax = x - COS(angle) * xRad;
			ay = y - SIN(angle) * yRad;
			
			// if our arc is larger than 45 degrees, draw as 45 degree segments
			// so that we match Flash's native circle routines.
			if(segs > 0)
			{			
				// Loop for drawing arc segments
				for(var i:Number = 0; i < segs; i++)
				{
					// increment our angle
					angle += theta;
					
					// find the angle halfway between the last angle and the new
					angleMid = angle - (theta / 2);
					
					// calculate our end point
					bx = ax + COS(angle) * xRad;
					by = ay + SIN(angle) * yRad;
					
					// calculate our control point
					cx = ax + COS(angleMid) * (xRad / COS(theta / 2));
					cy = ay + SIN(angleMid) * (yRad / COS(theta / 2));
					
					// draw the arc segment
					g.curveTo(cx, cy, bx, by);
				}
			}
		}
		
		// BitmapData
		
		/**
		 * Draws an icon pixel by pixel based on data provided as an <code>Array</code>.
		 * 
		 * <p>The <code>Array</code> holding the data for the position of each pixel is a
		 * two-dimensional <code>Array</code> representing the icons width and height, filled with either a
		 * 0 for no pixel or 1 for pixel.</p>
		 * 
		 * @example
		 * <p><listing><pre>
		 * var arr:Array = new Array();
		 * 
		 * arr.push(new Array(0,1,0,1,0));
		 * arr.push(new Array(0,0,0,0,0));
		 * arr.push(new Array(0,0,1,0,0));
		 * arr.push(new Array(1,0,0,0,1));
		 * arr.push(new Array(0,1,1,1,0));
		 * </pre></listing></p>
		 * 
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param xOff the x-offset for drawing
		 * @param yOff the y-offset for drawing
		 * @param pixelArray the <code>Array</code> holding th drawing data
		 * 
		 * @return a BitmapData object containing the pixel information
		 */
		public static function bitmapDataFromArray(color:uint, alpha:Number, xOff:int, yOff:int, pixelArray:Array):BitmapData
		{
			var bitmapData:BitmapData = new BitmapData(pixelArray[0].length, pixelArray.length, true, 0x00000000);
			
			for(var y:Number = 0; y < pixelArray.length; y++)
			{
				for(var x:Number = 0; x < pixelArray[y].length; x++)
				{
					if(pixelArray[y][x] == 1)
					{
						bitmapData.setPixel(x + xOff, y + yOff, color);
					}
				}
			}
			
			return bitmapData;
		}
		
		/**
		 * Draws an icon pixel by pixel based on data provided as an <code>Array</code>.
		 * 
		 * <p>The <code>Array</code> holding the data for the position of each pixel is a
		 * two-dimensional <code>Array</code> representing the icons width and height, filled with either a
		 * 0 for no pixel or 1 for pixel.</p>
		 * 
		 * @example
		 * <p><listing><pre>
		 * var arr:Array = new Array();
		 * 
		 * arr.push(new Array(0,1,0,1,0));
		 * arr.push(new Array(0,0,0,0,0));
		 * arr.push(new Array(0,0,1,0,0));
		 * arr.push(new Array(1,0,0,0,1));
		 * arr.push(new Array(0,1,1,1,0));
		 * </pre></listing></p>
		 * 
		 * @param color the fill color value to draw with
		 * @param alpha the opacity value (0 to 1)
		 * @param xOff the x-offset for drawing
		 * @param yOff the y-offset for drawing
		 * @param pixelArray the <code>Array</code> holding th drawing data
		 * 
		 * @return a Bitmap object containing the pixel information
		 * 
		 * @see bitmapDataFromArray
		 */
		public static function bitmapFromArray(color:uint, alpha:Number, xOff:int, yOff:int, pixelArray:Array):Bitmap
		{
			return new Bitmap(bitmapDataFromArray(color, alpha, xOff, yOff, pixelArray));
		}
		
		// miscellaneous
		public static function textLineShade(textField:TextField, target:*, color:uint, alpha:Number = 1):void
		{
			var g:Graphics = target.graphics;
			var tlm:TextLineMetrics;
			var y:Number = 2;
			
			g.beginFill(color, alpha);
			
			for(var i:int = 0; i < textField.numLines; i++)
			{
				tlm = textField.getLineMetrics(i);
				g.drawRect(textField.x + tlm.x, textField.y + y, tlm.width, tlm.height - tlm.leading);
				
				y += tlm.height;
			}
			
			g.endFill();
		}

		// internal function
		private static function initFill(g:Graphics, color:*, alpha:Number):void
		{
			// null
			if(color == null) return;
			
			// color fill
			if(color is uint)
			{
				g.beginFill(color, alpha);
				return;
			}
			
			// basic bitmap fill
			if(color is BitmapData)
			{
				g.beginBitmapFill(color, null, true, true);
				return;
			}
			
			// advanced bitmap fill
			if(color is PBitmap)
			{
				var pb:PBitmap = PBitmap(color);
				
				g.beginBitmapFill(pb.bitmapData, pb.matrix, pb.repeat, pb.smooth);
				return;
			}
			
			// gradient fill
			if(color is PGradient)
			{
				var pg:PGradient = PGradient(color);
				
				if(alpha != 1) for(var a:int = 0; a < pg.alphas.length; a++) pg.alphas[a] *= alpha;
				g.beginGradientFill(pg.type, pg.colors, pg.alphas, pg.ratios, pg.matrix, pg.spreadMethod, pg.interpolationMethod, pg.focalPointRatio);
				
				return;
			}
		}
		
		private static function completeFill(g:Graphics, color:*):void
		{
			if(color != null) g.endFill();
		}
	}
}