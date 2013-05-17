package de.pixelscape.utils 
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Tobias Friese
	 */
	public class TransformationUtils 
	{
		/* constants */
		private static const PI:Number = Math.PI;
				private static const ATAN2:Function = Math.atan2;		private static const SIN:Function = Math.sin;		private static const COS:Function = Math.cos;		private static const SQRT:Function = Math.sqrt;		private static const POW:Function = Math.pow;
		
		public static const FIT_TYPE_DEFAULT:String = "fitDefault";		public static const FIT_TYPE_ZOOM:String = "fitZoom";
		public static const FIT_TYPE_STRETCH:String = "fitStretch";

		/**
		 * Calculates the coordinates of an area when centered to a defined location (0,0 by default).
		 * 
		 * @param areaWidth the width of the area to center
		 * @param areaHeight the width of the area to center
		 * @param originX x value of center origin
		 * @param originY y value of center origin
		 * @param round defines if the final position-values should be rounded or not
		 * 
		 * @return a Point object containing the calculated values
		 */
		public static function calculateCenteredPosition(displayObject:DisplayObject, originX:Number = 0, originY:Number = 0, round:Boolean = false):Point
		{
			var bounds:Rectangle = displayObject.getBounds(displayObject);
			
			var targetX:Number = originX - (((bounds.width * .5) + bounds.left) * displayObject.scaleX);
			var targetY:Number = originY - (((bounds.height * .5) + bounds.top) * displayObject.scaleY);
			
			if(round)
			{
				targetX = Math.round(targetX);
				targetY = Math.round(targetY);
			}
			
			return new Point(targetX, targetY);
		}
		
		/**
		 * Centers a DisplayObject to a defined location (0,0 by default).
		 * 
		 * @param obj the DisplayObject to scale
		 * @param originX x value of center origin		 * @param originY y value of center origin
		 * @param round defines if the final position-values should be rounded or not
		 */
		public static function center(displayObject:DisplayObject, originX:Number = 0, originY:Number = 0, round:Boolean = false):void
		{
			var coordinates:Point = calculateCenteredPosition(displayObject, originX, originY, round);
			
			displayObject.x = coordinates.x;			displayObject.y = coordinates.y;
		}
		
		/**
		 * Calculates width and height values for a defined rectangle to fit in a
		 * defined space.
		 * 
		 * @param areaWidth the width of the area that should be scaled		 * @param areaHeight the height of the area that should be scaled
		 * @param width the width of the scale boundary
		 * @param height the height of the scale boundary
		 * @param overscale defines whether the displayObject should be scaled up or not
		 */
		public static function calculateFit(areaWidth:Number, areaHeight:Number, targetWidth:Number, targetHeight:Number, downscaleOnly:Boolean = false, fitType:String = FIT_TYPE_DEFAULT):Rectangle
		{
			var ratio:Number = areaWidth / areaHeight;
			var targetRatio:Number = targetWidth / targetHeight;
			
			var tWidth:Number;
			var tHeight:Number;
			
			// stretch
			if(fitType == FIT_TYPE_STRETCH) return new Rectangle(0, 0, targetWidth, targetHeight);
			
			// default & zoom
			if(ratio >= targetRatio)
			{
				if(fitType == FIT_TYPE_DEFAULT)
				{
					tWidth = targetWidth;
					tHeight = targetWidth / ratio;
				}
				else if(fitType == FIT_TYPE_ZOOM)
				{
					tWidth = targetHeight * ratio;
					tHeight = targetHeight;
				}
			}
			else
			{
				if(fitType == FIT_TYPE_DEFAULT)
				{
					tWidth = targetHeight * ratio;
					tHeight = targetHeight;
				}
				else if(fitType == FIT_TYPE_ZOOM)
				{
					tWidth = targetWidth;
					tHeight = targetWidth /ratio;
				}
			}
			
			if(downscaleOnly)
			{
				if((tWidth > areaWidth) && (tHeight > areaHeight))
				{
					tWidth = areaWidth;					tHeight = areaHeight;
				}
			}
			
			return new Rectangle(0, 0, tWidth, tHeight);
		}

		/**
		 * Scales a DisplayObject into a defined boundary.
		 * 
		 * @param displayObject the DisplayObject to scale
		 * @param width the width of the scale boundary
		 * @param height the height of the scale boundary
		 * @param overscale defines whether the displayObject should be scaled up or not
		 */
		public static function fitInto(displayObject:DisplayObject, width:Number, height:Number, downscaleOnly:Boolean = false, fitType:String = FIT_TYPE_DEFAULT):void
		{
			var values:Rectangle = calculateFit(displayObject.width, displayObject.height, width, height, downscaleOnly, fitType);
			
			displayObject.width = values.width;
			displayObject.height = values.height;
		}
		
		/**
		 * Rotates a DisplayObject around a certain center point.
		 * 
		 * @param displayObject the DisplayObject to rotate
		 * @param angle the rotation angle in radians
		 * @param rotCenterX the x value of the rotations center coordinates
		 * @param rotCenterY the y value of the rotations center coordinates
		 */
		public static function rotateAroundPoint(displayObject:DisplayObject, angle:Number, pivotX:Number, pivotY:Number, absolute:Boolean = false, globalPivot:Boolean = false):void
		{
			// global
			if(globalPivot)
			{
				var local:Point = displayObject.globalToLocal(new Point(pivotX, pivotY));
				pivotX = local.x;				pivotY = local.y;
			}
			
			// involve scale
			pivotX *= displayObject.scaleX;			pivotY *= displayObject.scaleY;
			
			// calculate
			var hyp:Number = SQRT(POW(pivotX, 2) + POW(pivotY, 2));
			
			var angleOrigin:Number = displayObject.rotation * (PI / 180);
			var angleToPivot:Number = ATAN2(pivotY, pivotX);
			var angleTarget:Number = absolute ? angle : angleOrigin + angle;
			
			// apply
			displayObject.rotation = angleTarget * (180 / PI);
			
			displayObject.x -= (COS(angleTarget + angleToPivot) * hyp) - (COS(angleOrigin + angleToPivot) * hyp);
			displayObject.y -= (SIN(angleTarget + angleToPivot) * hyp) - (SIN(angleOrigin + angleToPivot) * hyp);
		}
	}
}
