package face2wind.view
{
	import flash.events.MouseEvent;
	import face2wind.manager.WindowManager;
	
	/**
	 * 基础窗体对象
	 * @author face2wind
	 */
	public class BaseWindow extends BaseSprite
	{
		/**
		 * 窗口管理器 
		 */		
		protected var windowManager:WindowManager = WindowManager.getInstence();
		
		public function BaseWindow()
		{
			super();
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
		}
		
		/**
		 * 当前是否为open状态 
		 */		
		private var _isOpened:Boolean = false;
		/**
		 * 当前窗口是否为打开状态 
		 */		
		public function isOpen():Boolean
		{
			return _isOpened;
		}
		
		/**
		 * 打开窗口 
		 * 
		 */		
		public function open():void
		{
//			cacheAsBitmap = true;
			_isOpened = true;
			windowManager.popup(this);
		}
		
		/**
		 * 关闭窗口 
		 * 
		 */		
		public function close():void
		{
			if(!_isOpened)
				return;
//			cacheAsBitmap = false;
			_isOpened = false;
			windowManager.removeObj(this);
		}
		
		/**
		 * 切换窗口的弹出状态<br/>
		 * 若正在显示窗口，则关闭窗口；反之则弹出窗口 
		 */		
		public function toggleShow():void
		{
			if(_isOpened)
				close();
			else
				open();
		}
		
		public override function resume():void
		{
			super.resume();
			
			//这里之所以用MOUSE_DOWN，是因为点击提起窗口的处理要先于其他点击操作，否则会有其他显示上的BUG
			addEventListener(MouseEvent.MOUSE_DOWN , onMouseClickHandler);
		}
		
		public override function dispose():void
		{
			super.dispose();
			
			removeEventListener(MouseEvent.MOUSE_DOWN , onMouseClickHandler);
		}
		
		/**
		 * 窗口被点击，提升到顶层 
		 * @param event
		 * 
		 */		
		protected function onMouseClickHandler(event:MouseEvent):void
		{
			if(isOnshow) //当前窗口在显示中才提到顶层，避免出现窗口已关闭，却因为执行到这里被弹起
				windowManager.popup(this);
		}
	}
}
