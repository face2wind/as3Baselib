package face2wind.loading
{
	import face2wind.config.ConfigManager;
	import face2wind.event.ParamEvent;
	import face2wind.event.PropertyChangeEvent;
	import face2wind.lib.Debuger;
	import face2wind.loading.display.MovieClipData;
	import face2wind.manager.EnterFrameUtil;
	import face2wind.util.ArrayUtil;
	import face2wind.util.StringUtil;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * 运行时统一加载资源管理类， 如一些人物的动画，元素图标等等
	 * @author Michael.Huang
	 */
	public class RuntimeResourceManager extends EventDispatcher implements IObserver
	{
		/**
		 * 只用于runtime加载的进度中的事件 
		 */		
		public static const LOADING_PROGRESS:String = "RuntimeResourceManager_LOADING_PROGRESS";
		
		/**
		 * 放弃加载某个素材（加载失败）
		 */		
		public static const LOADING_FAIL:String = "RuntimeResourceManager_LOADING_FAIL";
		
		/**
		 * 本地资源存储引用
		 */
		private static var localResource:LocalResourceManager = LocalResourceManager.getInstance();
		
		/**
		 * 缓存管理器引用
		 */
		private static var cacheMgr:CacheManager = CacheManager.getInstance();
		
		
		
		//--------------------------------------------------
		//
		// Singleton instance
		//
		//--------------------------------------------------
		
		private static var instance:RuntimeResourceManager;
		
		/**
		 * 获取 RuntimeResourceManager单实例引用
		 * @return
		 *
		 */
		public static function getInstance():RuntimeResourceManager
		{
			if (null == instance)
				instance = new RuntimeResourceManager();
			return instance;
		}
		
		//--------------------------------------------------
		//
		// Construct
		//
		//--------------------------------------------------
		public function RuntimeResourceManager()
		{
			defaultContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			gcDictionary = new Dictionary();
			loadingDictionary = new Dictionary();
			loadingCountDictionary = new Dictionary();
			unloadTimeoutDictionary = new Dictionary();
			
			loaderDictionary = new Dictionary();
			completeDictionary = new Dictionary();
			errorDictionary = new Dictionary();
			transformDictionary = new Dictionary();
			tryCountDic = new Dictionary();
			queueDic = new Dictionary();
			tmpDataDic = new Dictionary();
			cachedDictionary = new Dictionary();
			intervalDictionary = new Dictionary();
			ldecDictionary = new Dictionary();
			localResource.addObserver(this);
			_lastFreeQueueTime = getTimer();
		}
		
		//---------------------------------------
		//
		// Variables  
		//
		//---------------------------------------
		
		public var defaultContext:LoaderContext;
		
		/**
		 * 记录曾经加载过的url
		 */
		protected var cachedDictionary:Dictionary;
		
		/**
		 * 存储记录可以垃圾回收的资源
		 */
		protected var gcDictionary:Dictionary;
		
		/**
		 * 存储记录进入加载流程的资源
		 */
		protected var loadingDictionary:Dictionary;
		
		/**
		 * 统计进入加载流程的资源的次数
		 */
		protected var loadingCountDictionary:Dictionary;
		
		/**
		 * 记录卸载的时间戳
		 */
		protected var unloadTimeoutDictionary:Dictionary;
		
		/**
		 * 存储记录加载资源创建的URLLoader或者Loader
		 */
		protected var loaderDictionary:Dictionary;
		
		/**
		 * 针对SWF资源,特意使用一个存储字典,存储那些需要转换成MovieClipData的资源
		 */
		protected var transformDictionary:Dictionary;
		
		/**
		 * 存储资源加载完成后执行函数队列引用
		 */
		protected var completeDictionary:Dictionary;
		
		/**
		 * 存储资源加载失败后执行函数队列引用
		 */
		protected var errorDictionary:Dictionary;
		
		/**
		 * 加载尝试次数统计
		 */
		protected var tryCountDic:Dictionary;
		
		/**
		 * 记录使用loadDisplay方法后，由于二进制数据损坏，导致没有完成事件，也没有报错事件抛出<br/>
		 * 为了加载顺利，如果1秒钟后不成功，即说明失败，这个时候记录那个时间戳 
		 */		
		protected var intervalDictionary:Dictionary;
		
		/**
		 * 将二进制数据还原成可视数据失败后统计次数，次数超过3次就忽略 
		 */		
		protected var ldecDictionary:Dictionary;
		
		/**
		 * 等待加载的队列
		 */
		protected var loaderQueue:Array = [];
		
		/**
		 * 等待加载的队列引用
		 */
		protected var queueDic:Dictionary;
		
		/**
		 * 存放只使用一次就释放的数据 
		 */		
		protected var tmpDataDic:Dictionary;
		
		/**
		 * 最大连接数
		 */
		public var maxConnections:int = 5;
		
		/**
		 * 最大尝试次数
		 */
		public var maxTries:int = 2;
		//---------------------------------------
		//
		// Getter ans setter
		//
		//---------------------------------------
		
		private var _startLoadNow:Boolean;
		
		/**
		 * 开始加载，为了使加载资源延迟进行(首先加载主界面，再加载聊天模块),startLoadNow为true的情况下才开始加载队列
		 */
		public function get startLoadNow():Boolean
		{
			return _startLoadNow;
		}
		
		/**
		 * @private
		 */
		public function set startLoadNow(value:Boolean):void
		{
			if (_startLoadNow == value)
				return;
			var oldValue:* = _startLoadNow;
			_startLoadNow = value;
			// 抛出属性改变事件
			dispatchEvent(PropertyChangeEvent.createUpdateEvent("startLoadNow", oldValue, _startLoadNow));
			clearTimeout(setStartLoadNowTimeout);
			if (_startLoadNow)
			{
				doLoad();
			}
			else
			{
				// 1分钟后如果还没有自动恢复加载，则开始继续加载
				setStartLoadNowTimeout = setTimeout(setStartLoadNow, 30000);
			}
		}
		
		/**
		 * @private
		 */
		private var _currentCount:int;
		
		/**
		 * 当前连接数
		 */
		public function get currentCount():int
		{
			return _currentCount;
		}
		
		/**
		 * @private
		 */
		public function set currentCount(value:int):void
		{
			var oldValue:int = _currentCount;
			_currentCount = value;
			if (oldValue > value)
			{
				doLoad();
			}
		}
		
		
		/**
		 * @private
		 */
		private var setStartLoadNowTimeout:int;
		
		/**
		 * 开始加重
		 */
		protected function setStartLoadNow():void
		{
			clearTimeout(setStartLoadNowTimeout);
			startLoadNow = true;
		}
		
		
		//---------------------------------------
		//
		// public methods
		//
		//---------------------------------------
		
		
		
		/**
		 * 将加载完成得资源存放到缓存列表<code>cacheDictionary</code>
		 *
		 * @param path 资源路径
		 * @param obj  加载完成后处理过后的资源(可能是swf, 也可能是bitmap或者MovieClipData等)
		 * @param overWrite 是否可以重写
		 * @param gc 是否可以垃圾回收
		 *
		 */
		public function addResource(path:String, target:*, overWrite:Boolean = false, gc:Boolean = false):void
		{
			cacheMgr.addResource(path, target, overWrite, gc);
		}
		
		/**
		 * 把素材增加到临时缓存，用一次后则删除 
		 * @param path
		 * @param target
		 * 
		 */		
		public function addTmpResource(path:String, target:*):void
		{
			tmpDataDic[path] = target;
		}
		
		/**
		 *
		 * 删除资源(资源回收的时候调用此方法，此时删除引用计数)
		 *
		 * @param path 资源路径
		 *
		 */
		public function removeResource(path:String):void
		{
			cacheMgr.removeResource(path);
		}
		
		
		/**
		 * @private
		 */
		private var _lastFreeQueueTime:int;
		
		/**
		 * 将一些长时间存在队列中，但是又没有开始加载的资源，从队列中移除
		 */
		public function freeQueue():void
		{
			var time:int = getTimer();
			if (time - _lastFreeQueueTime < 45000) // 1分钟释放一次没有加载的队列
				return;
			_lastFreeQueueTime = time;
			for (var path:String in loadingCountDictionary)
			{
				if (loadingCountDictionary[path] == 0)
				{
					if ((time - unloadTimeoutDictionary[path]) >= 2000) // 10秒钟
					{
						if (isLoading(path) && !hasResource(path)) // 可能存在加载队列中，但是没有开始加载
						{
							var item:LoadItem = queueDic[path];
							if (item && loaderQueue.indexOf(item) != -1) // 已经放入到加载队列中，但是还没有开始加载
							{
								stopResource(path);
							}
						}
					}
				}
			}
		}
		
		
		/**
		 * 停止加载该资源，并且从加载队列中移除
		 * @param path
		 *
		 */
		public function stopResource(path:String):void
		{
			var item:LoadItem = queueDic[path];
			var index:int = loaderQueue.indexOf(item);
			if (index > -1)
			{
				loaderQueue.splice(index, 1);
			}
			delete queueDic[path];
			delete gcDictionary[path];
			delete loadingDictionary[path];
			delete completeDictionary[path];
			delete errorDictionary[path];
			delete transformDictionary[path];
			delete loadingCountDictionary[path];
			delete unloadTimeoutDictionary[path];
		}
		
		/**
		 * 卸载资源加载，这个方法主要是用来标记那些在加载队列中，但是知道资源被释放都没有加载出来的资源，<br/>
		 * 卸载之后会记录一个时间戳，标记最后一次卸载时间，加上时间戳避免短时间内资源加载卸载频繁，<br/>
		 * 导致队列添加和删除频繁造成的性能损耗
		 * @param path 资源路径
		 *
		 */
		public function unload(path:String, complete:Function = null, error:Function = null):void
		{
			if (path != null && path != "")
			{
				if (isLoading(path) && !hasResource(path)) // 可能存在加载队列中，但是没有开始加载
				{
					var item:LoadItem = queueDic[path];
					if (item && loaderQueue.indexOf(item) != -1) // 已经放入到加载队列中，但是还没有开始加载
					{
						loadingCountDictionary[path] -= 1;
						var ars:Array;
						if (complete != null)
						{
							if (path in completeDictionary)
							{
								ars = completeDictionary[path];
								ArrayUtil.removeFromArray(ars, complete);
							}
						}
						if (error != null)
						{
							if (path in errorDictionary)
							{
								ars = errorDictionary[path];
								ArrayUtil.removeFromArray(ars, error);
							}
						}
						if (loadingCountDictionary[path] <= 0)
						{
							// 记录一下卸载的时间戳，超过一定时间，加载次数还是<=0,直接从队列中移除
							unloadTimeoutDictionary[path] = getTimer();
						}
					}
				}
			}
		}
		
		/**
		 * 回收资源(此时并没用彻底从缓存中删除该资源，只是将引用计数-1)
		 * @param target
		 *
		 */
		public function recycleResource(target:*):void
		{
			cacheMgr.recycleResource(target);
		}
		
		/**
		 * 使用资源
		 * @param path 资源路径
		 * @return
		 *
		 */
		public function useResource(path:String):*
		{
			var data:* = cacheMgr.useResource(path);
			if(null == data)
			{
				data = tmpDataDic[path];
				if(data)
					delete tmpDataDic[path];
			}
			return data;
		}
		
		/**
		 * 判断缓存列表里面是否存在该资源，如果存在为true,否则false
		 * @param path 资源路径
		 * @return True or false
		 *
		 */
		public function hasResource(path:String):Boolean
		{
			var has:Boolean = cacheMgr.hasResource(path);
			return has;
		}
		
		/**
		 * 加载资源(此方法只针对那些不需要尝试多次加载的资源，以后可能会引用本地资源管理加载)
		 * @param path	 资源路径
		 * @param gc 	指示是否可以进行垃圾回收, 默认为true
		 * @param complete 	加载完成后执行的函数
		 * @param error 		加载失败后执行的函数
		 * @param transform 	如果加载的内容是SWF,加载完成后指示是否转换成MovieClipData
		 * @param forceReload 是否强制重新加载（无视内存缓存和本地缓存）
		 */
		public function load(path:String, gc:Boolean = true, complete:Function = null, error:Function = null, transform:Boolean = true, priority:int = 1, forceReload:Boolean = false):void
		{
			if(StringUtil.isEmpty(path))//资源路径不能为空 
				return;
			this.addCompleteHandler(path, complete);	
			this.addErrorHandler(path, error);
			
			if (hasResource(path) && false == forceReload) //如果该资源已经存在缓存列表里面
			{
				Debuger.show(Debuger.LOADING, "[ " + path + " ]" + "资源已经存在缓存列表里面 , 直接执行加载完成后动作.");
				//直接执行加载完成后动作
				doComplelteHandlers(path);
				return;
			}
			if (path in loadingCountDictionary)
			{
				loadingCountDictionary[path] += 1;
			}
			else
			{
				loadingCountDictionary[path] = 1;
			}
			if (isLoading(path)) //如果资源正在加载
			{
				Debuger.show(Debuger.LOADING,"[ " + path + " ]" + "资源正在加载..., 当前加载引用为:" + loadingCountDictionary[path]);
				
				var lit:LoadItem = queueDic[path];
				if (lit != null) // 更新 优先级
				{
					lit.priority = priority;
				}
				return;
			}
			var name:String = path.substr(-3, 3);
			if (name == ResourceType.SWF) //只有SWF资源才转换
				transformDictionary[path] = transform;
			
			//所有的资源都使用二进制形式加载，加载完成后如果是可视化资源，
			//再使用Loader.loadBytes方法还原成具体可视化对象
			gcDictionary[path] = gc;
			loadingDictionary[path] = true;
			var rPath:String = path.replace(ConfigManager.cdnUrl , "");
			if (localResource.canUseResource(rPath) && false == forceReload) //如果本地已经存储了该资源，从本地获取它
			{
				Debuger.show(Debuger.LOADING,"[ " + path + " ]" + "本地已经存储了该资源, 使用本地缓存.");
				if (LocalResourceManager.freeNow) // 如果空闲，就不使用队列了
				{
					var data:ByteArray = localResource.getResource(rPath);
					if (data != null && data.length > 0)
					{
						loadDisplayObject(path, data, transform);
						return;
					}
				}
				else
				{
					localResource.getResourceByQueue(rPath);
					return;
				}
			}
			var index:int = loaderQueue.indexOf(path);
			if (priority >= PriorityEnum.REAL_TIME) // 优先级是实时，或更高，马上加载
			{
				if (index < 0)
				{
					loadByteData(path , forceReload);
				}
				else
				{
					// 提升到及时加载的时候要从原来队列中的移除掉
					loaderQueue.splice(index, 1);
				}
			}
			else
			{
				if (index < 0)
				{
					// 如果曾经加载过，那么马上加载，不再加人队列中
					if (path in cachedDictionary && cachedDictionary[path])
					{
						Debuger.show(Debuger.LOADING, "[ " + path + " ]" + "浏览器已经缓存，直接加载");
						loadByteData(path , forceReload);
					}
					else
					{
						var item:LoadItem = new LoadItem();
						item.url = path;
						item.priority = priority;
						item.addTime = getTimer();
						item.forceReload = forceReload;
						loaderQueue.push(item);
						queueDic[path] = item;
						
						Debuger.show(Debuger.LOADING, "[ " + path + " ]" + "成攻添加到加载队列");
						
						// 排序一下
						loaderQueue.sort(sortFun);
						// 开始加载
						doLoad();
					}
				}
			}
		}
		
		/**
		 * 排序函数, 优先级越大，越靠前，优先级一样添加的越早越靠前
		 */
		private function sortFun(a:LoadItem, b:LoadItem):int
		{
			if (a.priority > b.priority)
			{
				return -1;
			}
			else if (a.priority < b.priority)
			{
				return 1;
			}
			else if (a.priority == b.priority)
			{
				if (a.addTime > b.addTime)
				{
					return 1;
				}
				else if (a.addTime == b.addTime)
				{
					return 0;
				}
				else if (a.addTime < b.addTime)
				{
					return -1;
				}
			}
			return 1;
		}
		
		
		/**
		 * 开始加载
		 */
		private function doLoad():void
		{
			if (false == _startLoadNow)
				return;
			while (currentCount < maxConnections && loaderQueue.length > 0)
			{
				var item:LoadItem = loaderQueue.shift();
				loadByteData(item.url , item.forceReload);
				delete queueDic[item.url];
			}
		}
		
		/**
		 * 加载二进制数据
		 * @param path
		 * @random 添加随机参数
		 *
		 */
		private function loadByteData(path:String, random:Boolean = false):void
		{
			if(StringUtil.isEmpty(path))
				return;
			var urlLoader:URLLoader = new URLLoader();
			//			var url:String = rURL(path);
			var url:String = "";
			if(random)
				url = path + "?random=" + Math.random().toString();
			else
				url = ConfigManager.getResourcePath(path, true);
			
			// 素材地址转义一下，否则无法加载到包含中文路径的素材
			var shuIndex:int = url.indexOf("|");
			if(url.indexOf("file:") != -1) // 本地文件，|号不要被转义了，一般都是：file:///E|...这种（好像linux下才有）
			{
				var startUrl:String = url.substr(shuIndex+1);
				url = url.substr(0,shuIndex+1)+encodeURI(startUrl);
			}
			else
				url = encodeURI(url);
			
			var request:URLRequest = new URLRequest(url);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, urlLoadCompleteHandler);
			urlLoader.addEventListener(ProgressEvent.PROGRESS , onItemProgressHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoadIoErrorHandler);
			urlLoader.load(request);
			loaderDictionary[urlLoader] = path;
			if (path in tryCountDic)
			{
				tryCountDic[path] = tryCountDic[path] + 1;
			}
			else
			{
				tryCountDic[path] = 0;
			}
			
			Debuger.show(Debuger.LOADING, "[ " + path + " ]" + "正在加载二进制数据中...，累计尝试:" + tryCountDic[path] + "次.");
			currentCount++;
			
		}		
		
		/**
		 * 加载可视化对象 
		 * @param path
		 * @param data
		 * @param transform 如果加载的内容是SWF,加载完成后指示是否转换成MovieClipData
		 * @param tempComplete
		 * @param tempError
		 * 
		 */		
		public function loadDisplayObject(path:String, data:ByteArray, transform:Boolean = true,tempComplete:Function = null,tempError:Function = null):void
		{
			if (null == data || null == path)
				return;
			Debuger.show(Debuger.LOADING, "[ " + path + " ]" + "开始二进制数据还原成swf或图片");
			
			this.addCompleteHandler(path, tempComplete);	//因为外部也要用这个方法 加载
			this.addErrorHandler(path, tempError);
			
			var loader:Loader = new Loader();
			loaderDictionary[loader.contentLoaderInfo] = path;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			if (path.indexOf(ResourceType.SWF) != -1)
			{
				transformDictionary[path] = transform;
				var context:LoaderContext;
				if (transform)
				{
					context = new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain));
				}
				else
				{
					context = defaultContext;
				}
				//放到当前应用程序域下
				loader.loadBytes(data, context);
				context = null;
			}
			else
			{
				// 图片不需要LoaderContext
				loader.loadBytes(data);
			}
			
			intervalDictionary[loader.contentLoaderInfo] = EnterFrameUtil.delayCall(1000,ioErrorHandler,false,1,false,null,loader.contentLoaderInfo);
		}
		
		/**
		 * 指示该资源正在加载(添加到加载队列的也算)
		 * @param str
		 * @return
		 *
		 */
		public function isLoading(str:String):Boolean
		{
			return loadingDictionary[str] == true;
		}
		
		/**
		 * 获取正在加载的资源的统计次数
		 * @param path
		 * @return
		 *
		 */
		public function loadingCount(path:String):int
		{
			if (path in loadingCountDictionary)
			{
				return loadingCountDictionary[path];
			}
			return 0;
		}
		
		
		
		/**
		 * 添加完成加载后执行函数
		 * @param path
		 * @param handler
		 *
		 */
		private function addCompleteHandler(path:String, handler:Function):void
		{
			if (null == path || null == handler)
				return;
			var completes:Array;
			if (completeDictionary[path] != null && completeDictionary[path] != undefined)
			{
				completes = completeDictionary[path] as Array;
			}
			else
			{
				completes = [];
			}
			if (!ArrayUtil.isInArray(completes, handler))
			{
				completes.push(handler);
			}
			completeDictionary[path] = completes;
		}
		
		/**
		 * 添加加载失败后执行函数
		 * @param path
		 * @param handler
		 *
		 */
		private function addErrorHandler(path:String, handler:Function):void
		{
			if (null == path || null == handler)
				return;
			var errors:Array;
			if (errorDictionary[path] != null && errorDictionary[path] != undefined)
			{
				errors = errorDictionary[path] as Array;
			}
			else
			{
				errors = [];
			}
			if (!ArrayUtil.isInArray(errors, handler))
			{
				errors.push(handler);
			}
			errorDictionary[path] = errors;
		}
		
		/**
		 * 执行加载完成后动作
		 * @param path 资源路径
		 *
		 */
		private function doComplelteHandlers(path:String):void
		{
			if (path in completeDictionary)
			{
				var completes:Array;
				completes = completeDictionary[path] as Array;
				var func:Function;
				for (var i:int = 0; i < completes.length; i++)
				{
					func = completes[i];
					func.call(this, path);
				}
				//执行完后删除引用
				delete completeDictionary[path];
				if (path in errorDictionary)
				{
					delete errorDictionary[path];
				}
			}
			// 删除加载统计
			delete loadingCountDictionary[path];
			//删除loading引用
			delete loadingDictionary[path];
		}
		
		/**
		 * 执行加载失败后动作
		 * @param path 资源路径
		 *
		 */
		private function doErrorHandlers(path:String):void
		{
			if (path in errorDictionary)
			{
				var errors:Array;
				errors = errorDictionary[path] as Array;
				var func:Function;
				for (var i:int = 0; i < errors.length; i++)
				{
					func = errors[i];
					func.call(this, path);
				}
				//执行完后删除引用
				delete errorDictionary[path];
				if (path in completeDictionary)
				{
					delete completeDictionary[path];
				}
			}
			// 删除加载统计
			delete loadingCountDictionary[path];
			//删除loading引用
			delete loadingDictionary[path];
			dispatchEvent(new ParamEvent(LOADING_FAIL, {url:path}));
		}
		
		
		
		//----------------------------------------------------
		//
		// Event Handlers
		//
		//----------------------------------------------------
		
		/**
		 * 加载二进制数据成功
		 */
		private function urlLoadCompleteHandler(e:Event):void
		{
			var urlLoader:URLLoader = e.currentTarget as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, urlLoadCompleteHandler);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS , onItemProgressHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoadIoErrorHandler);
			var url:String = loaderDictionary[urlLoader];
			Debuger.show(Debuger.LOADING, "[ " + url + " ]" + "二进制数据中加载成功");
			delete loaderDictionary[urlLoader];
			delete tryCountDic[url];
			var data:ByteArray = urlLoader.data;
			//			var vo:FileVo = ConfigManager.getFileInfo(url);
			var rPath:String = url.replace(ConfigManager.cdnUrl , "");
			if (data != null && localResource.allowStore)
			{
				// 将二进制数据添加的本地存储队列
				localResource.addItem(rPath, data);
				localResource.doStoring();
			}
			
			var name:String = url.substr(-3, 3);
			switch (name)
			{
				case ResourceType.SWF:
				case ResourceType.JPG:
				case ResourceType.PNG:
					if (name == ResourceType.SWF) // 只有SWF才考虑
						loadDisplayObject(url, data, transformDictionary[url]);
					else
						loadDisplayObject(url, data, false);
					break;
				case ResourceType.MZT:
					addResource(url, data, true, false);
					doComplelteHandlers(url);
					break;
				default:
					addTmpResource(url, data);
					doComplelteHandlers(url);
					break;
			}
			urlLoader = null;
			cachedDictionary[url] = true;
			currentCount--;
		}
		
		/**
		 * 加载二进制数据失败
		 */
		private function urlLoadIoErrorHandler(e:IOErrorEvent):void
		{
			var urlLoader:URLLoader = e.currentTarget as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, urlLoadCompleteHandler);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS , onItemProgressHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoadIoErrorHandler);
			var url:String = loaderDictionary[urlLoader];
			
			delete loaderDictionary[urlLoader];
			currentCount--;
			var tryTimes:int = tryCountDic[url];
			Debuger.show(Debuger.LOADING, "[ " + url + " ]" + "二进制数据中加载失败，尝试次数:" + tryTimes + "次, 最大尝试次数:" + maxTries + "次.");
			if (tryTimes < maxTries)
			{
				// load Again
				loadByteData(url,true);
			}
			else
			{
				doErrorHandlers(url);
				delete transformDictionary[url];
				urlLoader = null;
			}
			urlLoader = null;
		}
		
		/**
		 * 加载二进制文件进度反馈 
		 * 
		 */		
		private function onItemProgressHandler(e:ProgressEvent):void
		{
			var urlLoader:URLLoader = e.currentTarget as URLLoader;
			var url:String = loaderDictionary[urlLoader];
			dispatchEvent(new ParamEvent(
				RuntimeResourceManager.LOADING_PROGRESS,
				{url:url,  bytesLoaded:e.bytesLoaded,  bytesTotal:e.bytesTotal}));
		}
		
		
		/**
		 * 加载swf失败
		 * @param e
		 *
		 */
		private function ioErrorHandler(event:IOErrorEvent, target:LoaderInfo = null):void
		{
			var loaderInfo:LoaderInfo;
			if(event != null)
			{
				loaderInfo = event.currentTarget as LoaderInfo;
			}
			else 
			{
				if(target != null)
					loaderInfo = target;
			}
			var url:String = loaderDictionary[loaderInfo];
			if(null == url)
				return;
			// 清理延迟执行函数
			var interval:int = intervalDictionary[loaderInfo];
			EnterFrameUtil.removeItem(interval);
			delete intervalDictionary[loaderInfo]
			
			Debuger.show(Debuger.LOADING, "[ " + url + " ]" + "加载swf或位图失败");
			if(event)
				Debuger.show(Debuger.LOADING, "[ " + url + " ]" + event.text);
			
			delete loaderDictionary[loaderInfo];
			EventDispatcher(loaderInfo).removeEventListener(Event.COMPLETE, completeHandler);
			EventDispatcher(loaderInfo).removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			// 加载失败，把可能存在本地缓存中的删除掉
			if (localResource.canUseResource(url))
			{
				localResource.removeLocalItem(url);
			}
			
			if (url in ldecDictionary)
			{
				ldecDictionary[url] = ldecDictionary[url] + 1;
			}
			else
			{
				ldecDictionary[url] = 1;
			}
			
			if(ldecDictionary[url] < maxTries)
			{
				// 还原数据出错后，再加载一次
				loadByteData(url,true);
			}
			else
			{
				doErrorHandlers(url);
			}
		}
		
		/**
		 *
		 * 资源加载完成
		 *
		 */
		private function completeHandler(event:Event):void
		{
			//删除事件引用
			EventDispatcher(event.currentTarget).removeEventListener(Event.COMPLETE, completeHandler);
			EventDispatcher(event.currentTarget).removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			var url:String = loaderDictionary[loaderInfo];
			var rPath:String = url.replace(ConfigManager.cdnUrl , "");
			
			// 清理延迟执行函数
			var interval:int = intervalDictionary[loaderInfo];
			EnterFrameUtil.removeItem(interval);
			delete intervalDictionary[loaderInfo];
			delete ldecDictionary[url];
			Debuger.show(Debuger.LOADING, "[ " + url + " ]" + "加载swf或位图成功");
			//删除loader引用
			delete loaderDictionary[loaderInfo];
			if (loaderInfo.content != null)
			{
				var transform:Boolean = transformDictionary[url];
				if (loaderInfo.content is MovieClip) //如果是swf动画
				{
					var movie:MovieClip = loaderInfo.content as MovieClip;
					// 加载进来先stop，避免渲染
					movie.stop();
					if (transform) //如果是转换存MovieClipData缓存
					{
						var data:MovieClipData = new MovieClipData(movie, loaderInfo.applicationDomain, url);
						//将资源存放到缓存列表
						addResource(url, data, true, gcDictionary[url]);
						loaderInfo.loader.unload();
					}
					else
					{
						//将资源存放到缓存列表
						instance.addResource(url, movie, true, gcDictionary[url]);
					}
				}
				else if (loaderInfo.content is Bitmap) //如果是图片
				{
					var bitmap:Bitmap = loaderInfo.content as Bitmap;
					//将资源存放到缓存列表
					addResource(url, bitmap.bitmapData, true, gcDictionary[url]);
					//卸载资源
					loaderInfo.loader.unload();
				}
				delete transformDictionary[url];
			}
			loaderInfo = null;
			doComplelteHandlers(url);
		}
		
		//--------------------------------------------------------
		// IObserver implements
		//--------------------------------------------------------
		
		
		/**
		 * @inheritDoc
		 */
		public function update(o:Observable, args:*):void
		{
			if (args != null)
			{
				var path:String = args.path;
				var data:ByteArray = args.data;
				var transform:Boolean = transformDictionary[path] ? transformDictionary[path] : false;
				if (loadingDictionary[path] && data != null && data.length > 0)
				{
					Debuger.show(Debuger.LOADING, "[ " + path + " ]" + "获取本地缓成功");
					loadDisplayObject(path, data, transform);
					return;
				}
				else // 本地缓存加载失败，则重新添加到加载队列加载
				{
					Debuger.show(Debuger.LOADING, "[ " + path + " ]" + "获取本地缓失败");
					
					// 清除本地引用 
					localResource.removeLocalItem(path);
					// 清除加载状态
					delete loadingDictionary[path];
					// 加载统计-1
					loadingCountDictionary[path] -= 1;
					// 重新开始
					load(path, true, null, null, transform);
				}
				args = null;
			}
		}
		
		
		//---------------------------------------------
		// 提供一个方法，预加载场景数据
		//---------------------------------------------
		/**
		 * 预加载一个场景数据
		 * @param id
		 * @param loadNow
		 *
		 */
		public function preLoadScene(id:*, loadNow:Boolean = false):void
		{
			if (id <= 0)
				return;
			var priority:int = PriorityEnum.LOWEST;
			if (loadNow)
			{
				priority = PriorityEnum.REAL_TIME;
			}
			// 提前把下一个出口需要的数据加载进来
			//		var url:String = "assets/mapAssets/scene/" + id + "/map.xx";
			//		load(url, false, null, null, false, priority);
			//		var sid:* = SceneMapConfig.getInstance().getSceneRoot(id);
			//		if (null == sid || undefined == sid)
			//			sid = id;
			//		url = "assets/mapAssets/scene/" + sid + "/front/small.jpg";
			//		load(url, false, null, null, false, priority);
		}
		
	}
}


/**
 * 资源类型，用于RuntimeResourceManager
 * @author Michael.Huang
 */
class ResourceType
{
	/**
	 * SWF 文件
	 */
	public static const SWF:String = "swf";
	
	/**
	 * PNG图片
	 */
	public static const PNG:String = "png";
	
	/**
	 * JPG图片
	 */
	public static const JPG:String = "jpg";
	
	/**
	 * XML文件
	 */
	public static const XML:String = "xml"
	
	/**
	 * 地图数据文件
	 */
	public static const MZT:String = ".xx"
	
}

/**
 * 用于RuntimeResourceManager的加载项信息 
 * @author Michael.Huang
 */
class LoadItem
{
	public function LoadItem()
	{
	}
	
	/**
	 * url地址
	 */
	public var url:String;
	
	/**
	 * 优先级
	 */
	public var priority:int;
	
	/**
	 * 添加时间
	 */
	public var addTime:int;
	
	/**
	 * 是否强制加载最新的（无视内存缓存和本地缓存） 
	 */	
	public var forceReload:Boolean = false;
}