package face2wind.loading
{
	import face2wind.event.ParamEvent;
	import face2wind.lib.Debuger;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * 队列加载器 - 依赖于RuntimeResourceManager
	 * @author face2wind
	 */
	public class QueueResourceLoader extends EventDispatcher
	{
		/**
		 * 子项加载进度事件 
		 */		
		public static const ITEM_PROGRESS:String = "QueueResourceLoader_ITEM_PROGRESS";
		
		/**
		 * 子项加载完毕事件 
		 */		
		public static const ITEM_LOAD_COMPLETE:String = "QueueResourceLoader_ITEM_LOAD_COMPLETE";
		
		/**
		 * 队列所有素材加载完毕事件 
		 */	
		public static const ALL_LOAD_COMPLETE:String = "QueueResourceLoader_ALL_LOAD_COMPLETE";
		
		public function QueueResourceLoader()
		{
			super();
			
			queueList = [];
			queueDic = new Dictionary();
			hasLoadDic = new Dictionary();
			
			loader = RuntimeResourceManager.getInstance();
			loader.addEventListener(RuntimeResourceManager.LOADING_PROGRESS, onItemLoadProgressHandler);
		}
		
		/**
		 * 底层加载器 
		 */		
		private var loader:RuntimeResourceManager;
		
		/**
		 * 加载列表 
		 */		
		private var queueList:Array;
		
		/**
		 * 加载列表字典 
		 */		
		private var queueDic:Dictionary;
		
		/**
		 * 已经加载完毕的对象 
		 */		
		private var hasLoadDic:Dictionary;
		
		/**
		 * 是否正在加载中 
		 */		
		private var isLoading:Boolean = false;
		
		/**
		 * 当前正在加载的对象 
		 */		
		private var curLoadingItem:QueueLoadingItem = null;
		
		/**
		 * 增加一个加载项（同一个资源只能加载一次，若当前已有加载，会增加失败）
		 * @param item
		 * @return 0 增加成功，1 该资源正在加载，2 该资源已加载过
		 */		
		public function addLoadingItem(item:QueueLoadingItem):int
		{
			if(null != queueDic[item.resUrl])
				return 1;
			if(null != hasLoadDic[item.resUrl])
				return 2;
			queueList.push(item);
			queueDic[item.resUrl] = item;
//			if(1 == queueList.length) //原加载队列是空的，则立刻开始加载
//				loadingNext();
			return 0;
		}
		
		/**
		 * 删除一个加载项 
		 * @param url 加载的资源路径
		 */		
		public function removeLoadingItem(url:String):void
		{
			
		}
		
		/**
		 * 开始顺序加载队列中的素材（若已经加载则直接忽略此次调用） 
		 */		
		public function startLoading():void
		{
			loadingNext();
		}
		
		/**
		 * 加载下一个 
		 */		
		private function loadingNext():void
		{
			if(1 > queueList.length) //加载队列已为空，停止加载
			{
				isLoading = false;
				dispatchEvent(new ParamEvent(ALL_LOAD_COMPLETE));
				return;
			}
			if(isLoading)
				return;
			isLoading = true;
			curLoadingItem = queueList.shift();
			loader.load(curLoadingItem.resUrl, curLoadingItem.canGC, onItemLoadCompleteHandler, onLoadErrorHandler, curLoadingItem.transform , curLoadingItem.priorityLevel);
		}
		
		/**
		 * 单个文件加载进度
		 * @param event
		 * 
		 */		
		protected function onItemLoadProgressHandler(event:ParamEvent):void
		{
			if(event.param.url != curLoadingItem.resUrl) //不是当前正在加载的内容，屏蔽
				return;
			
			dispatchEvent(new ParamEvent(ITEM_PROGRESS, 
				{ item:curLoadingItem, bytesLoaded:event.param.bytesLoaded , bytesTotal:event.param.bytesTotal} ));
		}
		
		/**
		 * 单个加载完毕事件 
		 * @param url
		 */		
		private function onItemLoadCompleteHandler(url:String):void
		{
			dispatchEvent(new ParamEvent(ITEM_LOAD_COMPLETE, { item:curLoadingItem }));
			isLoading = false;
			loadingNext();
		}
		
		/**
		 * 加载失败 
		 * @param url
		 */		
		private function onLoadErrorHandler(url:String):void
		{
			isLoading = false;
			Debuger.show(Debuger.LOADING, "Error : QueueResourceLoader load resource [ "+url+" ]  ");
			loadingNext();
		}
	}
}