package de.pixelscape.utils 
{
	/**
	 * @author tobiasfriese
	 */
	public class ColorUtils 
	{
		public static function dec2rgb(color:uint):Object
		{
			return {r:(color & 0xFF0000) >> 16, g:(color & 0x00FF00) >> 8, b:color & 0x0000FF};
		}
		
		public static function rgb2dec(red:uint, green:uint, blue:uint):uint
		{
			red = Math.min(255, red);			green = Math.min(255, green);			blue = Math.min(255, blue);
			
			return ((red << 16) | (green << 8) | blue);
		}
		
		public static function offsetRGB(color:uint, redOffset:int, greenOffset:int, blueOffset:int):uint
		{
			var red:int		= (color & 0xFF0000) >> 16;			var green:int	= (color & 0x00FF00) >> 8;			var blue:int	= (color & 0x0000FF);
			
			red				= MathUtils.constrain(red + redOffset, 0, 255);			green			= MathUtils.constrain(green + greenOffset, 0, 255);			blue			= MathUtils.constrain(blue + blueOffset, 0, 255);
			
			return ((red << 16) | (green << 8) | blue);
		}
		
		public static function multiplyRGB(color:uint, redMultiplier:Number, greenMultiplier:Number, blueMultiplier:Number):uint
		{
			var red:int		= (color & 0xFF0000) >> 16;
			var green:int	= (color & 0x00FF00) >> 8;
			var blue:int	= (color & 0x0000FF);
			
			red				= MathUtils.constrain(red * redMultiplier, 0, 255);
			green			= MathUtils.constrain(green * greenMultiplier, 0, 255);
			blue			= MathUtils.constrain(blue * blueMultiplier, 0, 255);
			
			return ((red << 16) | (green << 8) | blue);
		}
		
		public static function fade(color1:uint, color2:uint, ratio:Number):uint
		{
			// constrain ratio
			if(ratio < 0) ratio = 0;
			else if(ratio > 1) ratio = 1;
			
			// vars
			var rgb1:Object = dec2rgb(color1);			var rgb2:Object = dec2rgb(color2);
			
			return rgb2dec(rgb1.r + ((rgb2.r - rgb1.r) * ratio), rgb1.g + ((rgb2.g - rgb1.g) * ratio), rgb1.b + ((rgb2.b - rgb1.b) * ratio));
		}
	}
}
