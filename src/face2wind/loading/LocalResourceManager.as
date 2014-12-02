package face2wind.loading
{
	import face2wind.config.ConfigManager;
	import face2wind.manager.RenderManager;
	import face2wind.manager.item.IRender;
	import face2wind.uiComponents.CustomTextfield;
	
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	/**
	 *
	 * 使用ShareObject 将资源存储到本地计算机文件系统里面<br/>
	 * LocalResourceManager 提供一些简单，方便的操作方法。
	 *
	 * @author Michael.Huang
	 */
	public class LocalResourceManager extends Observable implements IRender
	{
		
		/**
		 * 指示是否空闲状态(此标志主要是因为人物行走的时候会存在不流畅现象，这个时候如果再把资源保存到本地就更加卡了，所以人物走动的时候freeNow为false，停止后为true)
		 */
		public static var freeNow:Boolean = true;
		
		//--------------------------------------------------------
		//
		// Singleton instance
		//
		//--------------------------------------------------------
		private static var instance:LocalResourceManager;
		
		public static function getInstance():LocalResourceManager
		{
			if (null == instance)
				instance = new LocalResourceManager();
			return instance;
		}
		
		//--------------------------------------------------------
		//
		// Constants
		//
		//--------------------------------------------------------
		
		/**
		 * 本地数据
		 */
		private static const LOCAL_DATA:String = "localData";
		
		/**
		 * 本地保存一些变量信息
		 */
		private static const SAVE_DATA:String = "saveData";
		
		//--------------------------------------------------------
		//
		// Construct
		//
		//--------------------------------------------------------
		
		public function LocalResourceManager()
		{
			if (instance != null)
				throw new Error("LocalResourceManager is a singleton class.");
			instance = this;
			initialize();
		}
		
		//--------------------------------------------------------
		//
		// Variables
		//
		//--------------------------------------------------------
		
		/**
		 * 是否已经初始化
		 */
		public var initialized:Boolean = false;
		
		/**
		 * 指示是否允许通过ShareObject将资源存储到本地计算机
		 */
		public var allowStore:Boolean = false;
		
		/**
		 * 指示是否已经申请了存储空间，第一次存储的时候会请求申请存储空间，如果成功设置为true
		 */
		public var hasRequestSpace:Boolean = false;
		
		/**
		 * 对当前正在存储的SharedObject引用
		 */
		private var sharedObject:SharedObject;
		
		/**
		 * 记录当前存储的路径
		 */
		private var currentPath:String;
		
		/**
		 *　刷新存储内容返回的状态值
		 */
		private var flushStatus:String;
		
		/**
		 * 存储队列(用数组存储添加的内容，不区分优先级，先进数组的优先存储)
		 */
		protected var storeQueue:Array = [];
		
		/**
		 * 记录存储队列长度
		 */
		private var _storeQueueLen:int = 0;
		
		/**
		 *  本地存储的资源路径记录对象，方便清除缓存时，查找出所有缓存的内容
		 */
		protected var localDataRef:SharedObject;
		
		/**
		 * 记录已经存储的资源路径
		 */
		protected var localDataDic:Object;
		
		/**
		 * 添加队列引用，URL作为KEY
		 */
		protected var addDic:Object;
		
		/**
		 * 提取文件队列，保存url
		 */
		protected var fetchQueue:Array = [];
		
		/**
		 * 记录提取文件队列长度
		 */
		private var _fetchQueueLen:int = 0;
		
		/**
		 * 指示是否正在询问存储
		 */
		protected var isAaskStoring:Boolean = false;
		
		/**
		 * 是否已经询问过存储
		 */
		protected var hasAskStored:Boolean = false;
		
		/**
		 * 更新索引
		 */
		//		protected var updateDictionary:Object;
		
		/**
		 * 是否已经加载更新文件内容
		 */
		protected var hasLoaded:Boolean;
		
		//---------------------------------------------------------
		//
		// 保存一些变量信息
		//
		//---------------------------------------------------------
		
		private var saveShareObject:SharedObject;
		
		/**
		 * 保存变量
		 * @param name 变量名称
		 * @param value 值
		 *
		 */
		public function saveVars(name:String, value:*):void
		{
			if (null == saveShareObject)
			{
				try
				{
					saveShareObject = SharedObject.getLocal(SAVE_DATA);
				}
				catch (e:*)
				{
					//do nothing
				}
			}
			if (saveShareObject != null)
			{
				saveShareObject.data[name] = value;
				var flushStatus:String = null;
				try
				{
					flushStatus = saveShareObject.flush();
				}
				catch (error:Error)
				{
					//do nothing
				}
				if (flushStatus != null)
				{
					switch (flushStatus)
					{
						case SharedObjectFlushStatus.PENDING:
							saveShareObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushSaveDataStatus);
							break;
						case SharedObjectFlushStatus.FLUSHED:
							break;
					}
				}
			}
		}
		
		/**
		 * 刷新事件
		 * @param event
		 */
		private function onFlushSaveDataStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case "SharedObject.Flush.Success":
					break;
				case "SharedObject.Flush.Failed":
					allowStore = false;
					break;
			}
			SharedObject(event.target).removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
		}
		
		/**
		 * 获取变量
		 * @param name 变量名
		 * @return 返回值
		 *
		 */
		public function getVars(name:String):*
		{
			if (null == saveShareObject)
			{
				try
				{
					saveShareObject = SharedObject.getLocal(SAVE_DATA);
				}
				catch (e:*)
				{
					//do nothing
				}
			}
			if (saveShareObject != null)
			{
				return saveShareObject.data[name];
			}
			return null;
		}
		
		//---------------------------------------------------------
		//
		// Public methods
		//
		//---------------------------------------------------------
		
		
		
		/**
		 * 初始化
		 */
		protected function initialize():void
		{
			
			if (!initialized)
			{
				// 初始化时先查看本地已经存储的资源列表
				localDataRef = getShoreObject(LOCAL_DATA);
				if (localDataRef != null && localDataRef.data != null)
				{
					localDataDic = new Object();
					for (var i:String in localDataRef.data)
					{
						localDataDic[i] = localDataRef.data[i];
					}
				}
				addDic = new Object();
				fetchQueue = [];
				
				hasLoaded = true
				initialized = true;
				RenderManager.getInstance().add(this);
			}
			
			//是否开启本地缓存
			allowStore = ConfigManager.openLocalCache;
			if (!allowStore)
			{
				initialized = true;
				return;
			}
			//			// 获取游戏版本
			//			var version:String = getVars("gameVersion");
			//			// 存取游戏版本
			//			saveVars("gameVersion", ConfigManager.gameVersion);
			//			if (!version) // 再次登陆查看有没有存版本号，有则本地缓存开启
			//			{
			//				allowStore = false;
			//			}
			if (!allowStore)
			{
				initialized = true;
				return;
			}
			hasAskStored = getVars("hasAskStored") as Boolean;
			
		}
		
		/**
		 * 指示该资源是否可用，首先判断它是否已经存放都本地，如果是再检测它是否是修改版本
		 * @param path
		 * @return
		 *
		 */
		public function canUseResource(path:String):Boolean
		{
			var flag:Boolean = false;
			if (false == allowStore) //如果不允许使用本地存储
				return flag;
			if (false == hasLoaded)
				return flag;
			if (localDataDic != null)
			{
				flag = localDataDic[path] != undefined && localDataDic[path] != null;
			}
			else
			{
				flag = false;
			}
			if (flag) //如果存储了它
			{
				var a:* = ConfigManager.getFileTimestamp(path);
				var b:* = localDataDic[path];
				flag = a == b; //判断修改时间戳
			}
			return flag;
		}
		
		/**
		 * 添加一个存储对象,次数只是把该对象添加到存储队列
		 *
		 * @param path    存储路径
		 * @param data    存储数据
		 * @param refresh 指示是否强制刷新该内容
		 *
		 */
		public function addItem(path:String, data:*, refresh:Boolean = true):void
		{
			if (null == path || "" == path || null == data)
				return;
			if (false == hasLoaded) // 没有加载完日志文件，都不存储
				return;
			if (allowStore)
			{
				if (addDic[path] != true)
				{
					addDic[path] = true;
					storeQueue.push(new StoreData(path, data, refresh));
					_storeQueueLen++;
				}
			}
		}
		
		/**
		 * 从本地磁盘ShareObject对象种获取存储的内容
		 * @param path
		 * @return
		 *
		 */
		public function getResource(path:String):*
		{
			var share:SharedObject = getShoreObject(path);
			if (share)
			{
				var target:* = share.data[path];
				if (target != null && target != undefined)
				{
					return target;
				}
				else //如果获取资源失败，删除引用，并返回空
				{
					removeItem(path);
					return null;
				}
			}
			return null;
			
		}
		
		/**
		 * 从本地磁盘ShareObject对象种获取存储的内容,会先放入队列中，按先进先出的顺序返回
		 * @param path
		 *
		 */
		public function getResourceByQueue(path:String):void
		{
			if (fetchQueue.indexOf(path) == -1)
			{
				fetchQueue.push(path);
				_fetchQueueLen++;
			}
		}
		
		/**
		 * 从本地磁盘ShareObject对象种获取存储的内容
		 * @param path
		 * @return
		 *
		 */
		protected function doGetResource():void
		{
			if (_fetchQueueLen <= 0)
				return;
			var path:String = fetchQueue.shift();
			_fetchQueueLen--;
			var share:SharedObject = getShoreObject(path);
			var target:*;
			if (share)
			{
				target = share.data[path];
				if (target != null && target != undefined)
				{
					// do nothing
				}
				else //如果获取资源失败，删除引用，并返回空
				{
					removeItem(path);
				}
			}
			changed = true;
			notifyObserversByargs({path: path, data: target});
		}
		
		/**
		 *
		 * 清空本地缓存
		 *
		 */
		public function clear():void
		{
			if (localDataRef != null)
			{
				for (var p:* in localDataRef.data)
				{
					var s:SharedObject = getShoreObject(p);
					if (s != null)
						s.clear();
				}
				localDataRef.clear();
			}
//			Message.show(Language.getStr("clearCacheSuccessFul"));
			localDataDic = new Object();
		}
		
		/**
		 * 删除本地可能存储的引用
		 * @param path
		 *
		 */
		public function removeLocalItem(path:String):void
		{
			delete localDataDic[path];
			var s:SharedObject = getShoreObject(path);
			if (s != null)
				s.clear();
		}
		
		//---------------------------------------------------------
		//
		// Private methods
		//
		//---------------------------------------------------------
		
		private function getShoreObject(path:String):SharedObject
		{
			var share:SharedObject;
			try
			{
				share = SharedObject.getLocal(path, "/");
			}
			catch (e:*)
			{
				//do nothing
			}
			return share;
		}
		
		/**
		 * 删除它的引用
		 * @param path
		 *
		 */
		private function removeItem(path:String):void
		{
			//delete getShoreObject(path).data[path];
			delete localDataRef.data[path];
			delete localDataDic[path];
		}
		
		/**
		 *
		 * 获取下一个存储对象
		 *
		 */
		private function getNextItem():StoreData
		{
			if (_storeQueueLen > 0)
			{
				_storeQueueLen--;
				return storeQueue.shift();
			}
			return null;
		}
		
		
		/**
		 * 存储到本地，此方法会通过ShareObject打开本地存储通道，并将内容到用户计算机上
		 *
		 * @param path 存储路径
		 * @param data 存储资源内容
		 *
		 */
		private function doStoreToLocale(path:String, data:*):void
		{
			if (isAaskStoring) //如果正在询问
				return;
			currentPath = path;
			sharedObject = getShoreObject(path);
			if (sharedObject != null)
			{
				sharedObject.data[path] = data;
				try
				{
					if (!hasRequestSpace)
					{
						// 申请无限制大小空间
						flushStatus = sharedObject.flush(1024 * 1024 * 1024);
						hasRequestSpace = true;
					}
				}
				catch (e:Error)
				{
					// 用户不允许存储任何内容到客户端
					this.storeQueue.length = 0;
					this.allowStore = false;
				}
				if (flushStatus == flash.net.SharedObjectFlushStatus.PENDING)
				{
					if (onFlushStatusCount == 0)
					{
						isAaskStoring = true;
						//这里可能会有问题~~ 暂时没有这个类
//						var tipPanel:* = ClassUtil.getSingletonInstance("com.hudoop.game.components.LocalStoreTipPanel");
//						if (tipPanel)     提取到库中时注释这段
//							tipPanel.open();
						sharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
						onFlushStatusCount = 1;
					}
				}
				delete addDic[path];
				updateStoreReference(currentPath);
			}
		}
		
		private var onFlushStatusCount:int;
		
		/**
		 * @private
		 */
		private function onFlushStatus(event:NetStatusEvent):void
		{
//			var tipPanel:* = ClassUtil.getSingletonInstance("com.hudoop.game.components.LocalStoreTipPanel");
//			if (tipPanel)  提取到库中时注释这段
//			{
//				tipPanel.close();
//			}
			isAaskStoring = false;
			switch (event.info.code)
			{
				case "SharedObject.Flush.Success":
					localDataDic[currentPath] = ConfigManager.getFileTimestamp(currentPath);
					delete addDic[currentPath];
					break;
				case "SharedObject.Flush.Failed":
					this.storeQueue.length = 0;
					this.allowStore = false;
					break;
			}
			SharedObject(event.currentTarget).removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
		}
		
		
		
		//------------------------------------------------
		// IRendering implements
		//------------------------------------------------
		
		
		
		
		/**
		 * 存储频率(单位帧数)
		 */
		private var _storeInterval:int = 37;
		
		/**
		 * @private
		 */
		private var _lastStoreFrame:int;
		
		/**
		 * 单位帧数
		 */
		private var _fetchInterval:int = 17;
		
		/**
		 * @private
		 */
		private var _lastFetchFrame:int;
		
		/**
		 * @inheritDoc
		 * @param step
		 *
		 */
		public function rendering(step:int = 0):void
		{
			if (false == allowStore)
				return;
			if (step - _lastStoreFrame > _storeInterval)
			{
				if (false == isAaskStoring)
				{
					doStoring();
				}
				_lastStoreFrame = step;
			}
			
			if (step - _lastFetchFrame > _fetchInterval)
			{
				doGetResource();
				_lastFetchFrame = step;
			}
		}
		
		
		/**
		 * @private
		 */
		public function doStoring():void
		{
			//			if (!hasAskStored)
			//			{
			//				LocalStoreTipPanel.getInstance().open();
			//				return;
			//			}
			if (false == hasLoaded) // 还没有加载完对比日志文件
				return;
			if (isAaskStoring)
				return; //指示是否正在询问存储
			if (false == freeNow)
				return;
			var data:StoreData = this.getNextItem();
			if (data != null)
			{
				if (data.refresh) //如果强制刷新，不管是否存在都存储进去
				{
					try
					{
						doStoreToLocale(data.path, data.data);
					}
					catch (e:*)
					{
						//do nothing
					}
				}
				else
				{
					if (!canUseResource(data.path)) //如果已经存在了，不执行
					{
						try
						{
							doStoreToLocale(data.path, data.data);
						}
						catch (e:*)
						{
							//do nothing
						}
					}
				}
			}
		}
		
		
		/**
		 * 更新存储引用
		 */
		private function updateStoreReference(path:String):void
		{
			if (allowStore)
			{
				localDataRef.data[path] = ConfigManager.getFileTimestamp(path);
			}
		}
		
		//-------------------------------------------------------------
		//
		// load update files
		//
		//-------------------------------------------------------------
		//		/**
		//		 * @private
		//		 */
		//		private function requestUpdateFile():void
		//		{
		//			var loader:URLLoader = new URLLoader();
		//			loader.dataFormat = flash.net.URLLoaderDataFormat.BINARY;
		//			loader.addEventListener(Event.COMPLETE, completeHandler);
		//			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		//			var url:String = ConfigManager.getResourcePath(ConfigManager.updatePath);
		//			loader.load(new URLRequest(url));
		//		}
		//
		//		/**
		//		 * @private
		//		 */
		//		private function completeHandler(event:Event):void
		//		{
		//			var bytes:ByteArray = URLLoader(event.currentTarget).data;
		//			dataDecode(bytes);
		//		}
		//
		//		/**
		//		 * @private
		//		 */
		//		private var decodeInterval:int = 0;
		//
		//		/**
		//		 * @private
		//		 */
		//		private var updateBytes:ByteArray;
		//
		//		/**
		//		 * 解压
		//		 */
		//		private function dataDecode(bytes:ByteArray):void
		//		{
		//			bytes.position = 0;
		//			bytes.uncompress();
		//			updateBytes = bytes;
		//			updateDictionary = new Object();
		//			// 分步执行解压操作，避免卡死
		//			decodeInterval = EnterFrameUtil.delayCall(60, doDataDecode, false, 0);
		//		}
		//
		//		/**
		//		 * @private
		//		 */
		//		private function doDataDecode():void
		//		{
		//			if (updateBytes.bytesAvailable > 0)
		//			{
		//				var obj:Object = updateBytes.readObject();
		//				for (var key:String in obj)
		//				{
		//					updateDictionary[key] = obj[key];
		//				}
		//			}
		//			else
		//			{
		//				EnterFrameUtil.removeItem(decodeInterval);
		//				decodeInterval = 0;
		//				hasLoaded = true;
		//			}
		//		}
		//
		//		/**
		//		 * @private
		//		 */
		//		private function ioErrorHandler(event:IOErrorEvent):void
		//		{
		//			URLLoader(event.currentTarget).removeEventListener(Event.COMPLETE, completeHandler);
		//			URLLoader(event.currentTarget).removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		//		}
		
	}
}

/**
 * 存储数据项
 * @author Michael.Huang
 *
 */
class StoreData
{
	public function StoreData(path:String, data:*, refresh:Boolean)
	{
		this.path = path;
		this.data = data;
		this.refresh = refresh;
	}
	/**
	 * 存储路径
	 */
	public var path:String;
	/**
	 * 数据内容
	 */
	public var data:*;
	
	/**
	 * 指示是否强制刷新
	 */
	public var refresh:Boolean;
}
