package de.pixelscape.display.blitting
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import de.pixelscape.graphics.PBitmap;
	import de.pixelscape.graphics.Picasso;

	public class Blitter
	{
		public static function flatten(container:DisplayObjectContainer, smoothing:Boolean = false):void
		{
			// take snapshot
			var snapshot:BlitterSnapshot = getSnapShot(container);
			
			// clear container
			Picasso.clear(container);
			while(container.numChildren != 0) container.removeChildAt(0);
			
			// draw snapshot
			Picasso.drawRectangle(container, new PBitmap(snapshot.bitmapData, new Matrix(1, 0, 0, 1, snapshot.offset.x, snapshot.offset.y), false), 1, snapshot.offset.x, snapshot.offset.y, snapshot.bitmapData.width, snapshot.bitmapData.height);
		}
		
		public static function getSnapShot(source:DisplayObject):BlitterSnapshot
		{
			// bounds
			var bounds:Rectangle = source.getBounds(source);
			
			// apply scale
			var normalizedBounds:Rectangle = bounds.clone();
			
			normalizedBounds.x 			= bounds.x * source.scaleX;
			normalizedBounds.y 			= bounds.y * source.scaleY;
			
			normalizedBounds.width 		= bounds.width * source.scaleX;
			normalizedBounds.height 	= bounds.height * source.scaleY;
			
			// draw
			var bitmapData:BitmapData = new BitmapData(normalizedBounds.width, normalizedBounds.height, true, 0x00000000);
			bitmapData.draw(source, new Matrix(source.scaleX, 0, 0, source.scaleY, -normalizedBounds.x, -normalizedBounds.y));
			
			// label
			var label:String = null;
			if(source is MovieClip) label = MovieClip(source).currentFrameLabel;
			
			// assemble snapshot
			var snapshot:BlitterSnapshot = new BlitterSnapshot(bitmapData, new Point(normalizedBounds.x, normalizedBounds.y), label);
			
			// return
			return snapshot;
		}
		
		public static function flattenMovieClip(mc:MovieClip):BitmapMovieClip
		{
			var bmc:BitmapMovieClip = new BitmapMovieClip();
			var snapshot:BlitterSnapshot;
			
			for(var i:int = 1, c:int = mc.totalFrames + 1; i < c; i++)
			{
				mc.gotoAndStop(i);
				bmc.addFrame(getSnapShot(mc));
			}
			
			bmc.init();
			
			// return
			return bmc;
		}
	}
}