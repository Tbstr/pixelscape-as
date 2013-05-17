package de.pixelscape.utils {
	import flash.geom.Point;
	
	/**
	 * This class provides methods for mathematical tasks.
	 * 
	 * @author Tobias Friese
	 * 
	 * @version 1.0
	 * 
	 * recent changes: 03.03.2008
	 */
	public class MathUtils
	{
		private static const ABS:Function				= Math.abs;
		
		/**
		 * Faster version of the regulat Math.abs().
		 * 
		 * @param value numerical value make positive
		 * 
		 * @return positive value of given one.
		 */
		public function abs(value:Number):Number
		{
			return value < 0 ? -value : value;
		}

		/**
		 * Constrains a numerical input to a defined range.
		 * 
		 * @param value numerical value to constrain
		 * @param min lower limit
		 * @param max upper limit
		 * 
		 * @return constrained Number
		 */
		public static function constrain(value:Number, min:Number, max:Number, roundValue:Boolean = false):Number
		{
			if(min == max) return min;
			
			if(min < max)
			{
				if(value < min) return min;
				if(value > max) return max;
			}
			
			if(min > max)
			{
				if(value > min) return min;
				if(value < max) return max;
			}
			
			return (roundValue ? Math.round(value) : value);
		}
		
		/**
		 * Calculates the distance between two 2-dimensional points.
		 * 
		 * @param x0 x value of first point
		 * @param y0 y value of first point
		 * @param x1 x value of second point
		 * @param y1 y value of second point
		 * 
		 * @return distance
		 */
		public static function dist(x0:Number, y0:Number, x1:Number, y1:Number):Number
		{
			var xDiff:Number = x1 - x0;
			var yDiff:Number = y1 - y0;
			
			return (Math.sqrt(Math.pow(xDiff, 2) + Math.pow(yDiff, 2)));
		}
		
		/**
		 * Finds the nearest of points to a reference point.
		 * 
		 * @param referencePoint the reference point
		 * @param pointArray An Array of Points to check.
		 * 
		 * @return nearest point
		 */
		public static function nearestPoint(referencePoint:Point, pointArray:Array):Point
		{
			var rDist:Number;
			var point:Point;
			
			for(var i:uint = 0; i < pointArray.length; i++)
			{
				var dist:Number = Math.sqrt(Math.pow(pointArray[i].x - referencePoint.x, 2) + Math.pow(pointArray[i].y - referencePoint.y, 2));
				
				if(point == null)
				{
					rDist = dist;
					point = pointArray[i];
				}
				else
				{
					if(dist < rDist)
					{
						rDist = dist;
						point = pointArray[i];
					}
				}
			}
			
			return point;
		}
		
		/**
		 * Checks if a number is in a certain range.
		 * 
		 * @param value the number to check
		 * @param min lower limit of range
		 * @param max upper limit of range
		 * 
		 * @return true if in range, false if not
		 */
		public static function inRange(value:Number, min:Number, max:Number):Boolean
		{
			if(min < max)
			{
				if((value >= min) && (value <= max)) return true;
			}			else if(min > max)
			{
				if((value >= max) && (value <= min)) return true;
			}
			else if(min == max)
			{
				return true;
			}
			
			return false; 
		}
		
		/**
		 * Generates a random number within a predefined range.
		 * 
		 * @param min lower limit
		 * @param max upper limit
		 * @param round specifies whether the outcome should be rounded or not
		 * 
		 * @return random number
		 */
		public static function randomRange(min:Number, max:Number, round:Boolean = false):Number
		{
			if(round) return Math.round((Math.random() * (max - min)) + min);
			else return (Math.random() * (max - min)) + min;
		}
		
		/**
		 * Converts an angle degrees into radians.
		 * 
		 * @param angleDeg angle in degrees
		 * 
		 * @return andle in radians
		 */
		public static function deg2rad(angleDeg:Number):Number
		{
			return (angleDeg * (Math.PI / 180));
		}
		
		/**
		 * Converts an angle from radians in degrees.
		 * 
		 * @param angleRad angle in radians
		 * 
		 * @return angle in degrees
		 */
		public static function rad2deg(angleRad:Number):Number
		{
			return (angleRad * (180 / Math.PI));
		}
		
		public static function nearest(reference:Number, candidates:Array):Number
		{
			var dist:Number;
			var nearestDist:Number = Infinity;
			var currentCandidate:Number;
			
			for each(var candidate:Number in candidates)
			{
				dist = ABS(candidate - reference);
				
				if(dist < nearestDist)
				{
					nearestDist = dist;
					currentCandidate = candidate;
				}
			}
			
			return currentCandidate;
		}
	}
}
