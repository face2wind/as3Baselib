package face2wind.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import face2wind.lib.Reflection;
	import face2wind.manager.WindowManager;

	/**
	 * 窗口对象的一个bitmap映射视图，用于WindowManager里把替换一些被挡住的窗口，减少可视对象，提高性能
	 * @author face2wind
	 */
	public class BitmapWindow extends BaseSprite
	{
		public function BitmapWindow()
		{
			super();
		}
		
		/**
		 * 此函数是视图的内容初始化函数<br/>对父类的覆盖 
		 * 
		 */		
		protected override function createChildren():void
		{
			super.createChildren();
			
			bm = new Bitmap();
			addChild(bm);
			
			closeBtn = Reflection.createSimpleButtonInstance("window_closeButton");
			addChild(closeBtn);
			
			updateBitmap();
		}
		
		private var _source:SimpleWindow;
		/**
		 * 当前要拷贝的窗口对象 
		 * @return 
		 * 
		 */
		public function get source():SimpleWindow
		{
			return _source;
		}
		/**
		 * @private
		 */
		public function set source(value:SimpleWindow):void
		{
			_source = value;
			updateBitmap();
		}
		
		private var bm:Bitmap;
		
		/**
		 * 关闭按钮，实现关闭效果 
		 */		
		private var closeBtn:SimpleButton;
		
		/**
		 * 更新bitmap图形 
		 * 
		 */		
		private function updateBitmap():void
		{
			if(null == source || !initialized)
				return;
			
			var rect:Rectangle = source.getBounds(source);
			var bitmapData:BitmapData = new BitmapData(source.width, source.height, true, 0);
			bitmapData.draw(source, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
			bm.bitmapData = bitmapData;
			
			var cp:Point = source.getCloseBtnPosition();
			closeBtn.x = cp.x;
			closeBtn.y = cp.y;
		}
		
		protected function onMouseDownHandler(event:MouseEvent):void
		{
			if(event.target == closeBtn)//过滤掉关闭按钮的鼠标按下事件
				return;
			WindowManager.getInstence().popupBitmapWindow(this);
		}
		
		protected function onCloseWindowHandler(event:MouseEvent):void
		{
			WindowManager.getInstence().removeBitmapWindow(this);
		}
		
		/**
		 * [继承] 恢复资源
		 * 
		 */		
		public override function resume():void
		{
			super.resume();
			
			addEventListener(MouseEvent.MOUSE_DOWN , onMouseDownHandler);
			closeBtn.addEventListener(MouseEvent.CLICK , onCloseWindowHandler);
		}
		
		/**
		 * [继承] 释放资源
		 * 
		 */		
		public override function dispose():void
		{
			super.dispose();
			
			removeEventListener(MouseEvent.MOUSE_DOWN , onMouseDownHandler);
			closeBtn.removeEventListener(MouseEvent.CLICK , onCloseWindowHandler);
		}
	}
}