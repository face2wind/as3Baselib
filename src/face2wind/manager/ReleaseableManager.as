package face2wind.manager
{
	import face2wind.view.BaseSprite;
	
	import flash.utils.Dictionary;

	/**
	 * 可释放的资源的管理器
	 * @author face2wind
	 */
	public class ReleaseableManager
	{
		public function ReleaseableManager()
		{
			releaseableObjDic = new Dictionary();
		}
		
		private static var instance:ReleaseableManager = null;
		public static function getInstence():ReleaseableManager
		{
			if(null == instance)
				instance = new ReleaseableManager();
			return instance;
		}
		
		/**
		 * 是否当前空闲（可做释放资源的操作） 
		 */		
		public static var freeNow:Boolean = true;
		
		/**
		 * 需要管理的对象字典 
		 */		
		private var releaseableObjDic:Dictionary;
		
		/**
		 * 需要管理的对象数 
		 */		
		private var objNum:int = 0;
		
		/**
		 * 释放资源间隔（秒） 
		 */		
		private var releaseInterval:int = 10;
		
		/**
		 * 启动管理 
		 * 
		 */		
		public function start():void
		{
			TimerManager.getInstance().removeItem(timerHandler);
			TimerManager.getInstance().addItem( 1000 , timerHandler);
		}
		
		/**
		 * 停止管理 
		 * 
		 */		
		public function stop():void
		{
			TimerManager.getInstance().removeItem(timerHandler);
		}
		
		/**
		 * 增加一个需管理的视图对象 
		 * @param item
		 * 
		 */		
		public function addItem(item:BaseSprite):void
		{
			releaseableObjDic[item] = releaseInterval;
			objNum ++;
			start();
		}
		
		/**
		 * 删除一个不再需要管理的视图对象 
		 * @param item
		 * 
		 */	
		public function removeItem(item:BaseSprite):void
		{
			if(null != releaseableObjDic[item])
			{
				delete releaseableObjDic[item];
				objNum--;
				if(1 > objNum)
					stop();
			}
		}
		
		/**
		 * 每秒轮询 
		 * 
		 */		
		private function timerHandler():void
		{
			for (var i:* in releaseableObjDic) 
			{
				releaseableObjDic[i] --;
				if(1 > releaseableObjDic[i])
				{
					if(freeNow)//当前空闲，可做释放操作
					{
						if((i as BaseSprite).hasResume)
							(i as BaseSprite).dispose();
						delete releaseableObjDic[i];
					objNum--;
					}
					else //等到空闲时立刻释放
						releaseableObjDic[i] = 1;
				}
			}
			if(1 > objNum)
				stop();
		}
	}
}
