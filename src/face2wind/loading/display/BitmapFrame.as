package face2wind.loading.display
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	/**
	 * @author Michael.Huang
	 */
	public class BitmapFrame
	{
		public function BitmapFrame()
		{
			
		}
		
		/**
		 * 位图数据 
		 */		
		public var bitmapData:BitmapData;
		
		/**
		 * x位置 
		 */		
		public var xpos:Number = 0;
		
		/**
		 * y位置 
		 */		
		public var ypos:Number = 0;
		
		/**
		 * 最后一次引用时间 
		 */		
		public var lastTime:int;
		/**
		 * 当前帧标签
		 */		
		public var label:String;
		
	}
}