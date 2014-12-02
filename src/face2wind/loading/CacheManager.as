package face2wind.loading
{
	import face2wind.loading.display.MovieClipData;
	import face2wind.manager.RenderManager;
	import face2wind.manager.item.IRender;
	
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

//	CONFIG::logger
//	{
//		import com.hudoop.game.modules.log.Loger;
//	}
//
//
//
//	CONFIG::debug
//	{
//		import org.as3commons.logging.ILogger;
//		import org.as3commons.logging.LoggerFactory;
//	}

	/**
	 * 对象缓存(缓存位图和MovieClipData)
	 * @author Michael.Huang
	 */
	public class CacheManager implements IRender
	{

//		CONFIG::debug
//		{
//			/**
//			 * 日志
//			 */
//			private static var logger:ILogger = LoggerFactory.getClassLogger(CacheManager);
//		}


		//--------------------------------------------------
		//
		// Singleton instance
		//
		//--------------------------------------------------

		private static var instance:CacheManager;

		/**
		 * 获取 CacheManager单实例引用
		 * @return
		 *
		 */
		public static function getInstance():CacheManager
		{
			if (null == instance)
				instance = new CacheManager();
			return instance;
		}

		//--------------------------------------------------
		//
		// Construct
		//
		//--------------------------------------------------

		public function CacheManager()
		{
			cacheDictionary = new Dictionary();
			referenceDictionary = new Dictionary();
			timeoutDictionary = new Dictionary();
			gcDictionary = new Dictionary();
//			CONFIG::debug
//			{
//				nameDictionary = new Dictionary(true);
//			}
			//添加到渲染列表中...
			RenderManager.getInstance().add(this);
		}

		/**
		 * 存储记录可以垃圾回收的资源
		 */
		protected var gcDictionary:Dictionary;

		/**
		 * 存储资源引用计数器列表(每一个资源默认不使用的时候计数为0，使用一次计数+1, 不使用回收一次计数-1)
		 */
		protected var referenceDictionary:Dictionary;

		/**
		 * 存储缓存加载完成的资源
		 */
		protected var cacheDictionary:Dictionary;

		/**
		 * 存储对象引用时间戳(超过1分钟未引用即从缓存中删除)
		 */
		protected var timeoutDictionary:Dictionary;

//		CONFIG::debug
//		{
//			/**
//			 * 记录资源的路径
//			 */
//			protected var nameDictionary:Dictionary;
//		}

		/**
		 * 销毁队列
		 */
		private var _disposeList:Array = [];
		/**
		 * @private
		 */
		private var _disposeLen:int = 0;

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
			if (null == target || null == path || "" == path) //路径和资源对象不能为空
				return;
			gcDictionary[path] = gc;
//			CONFIG::debug
//			{
//				nameDictionary[target] = path;
//			}
			if (!hasResource(path))
			{
				referenceDictionary[target] = 0;
				cacheDictionary[path] = target;
			}
			else
			{
				if (overWrite)
				{
					if (cacheDictionary[path] is BitmapData)
					{
						BitmapData(cacheDictionary[path]).dispose();
					}
					cacheDictionary[path] = target;
				}
			}
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
			var target:* = cacheDictionary[path];
			if (target != null && target != undefined)
			{
				if (target is BitmapData)
				{
					(target as BitmapData).dispose();
				}
				else if (target is MovieClipData)
				{
					(target as MovieClipData).disposeAll();
				}
				delete cacheDictionary[path];
				delete gcDictionary[path];
				delete referenceDictionary[target];
				delete timeoutDictionary[target];
//				CONFIG::debug
//				{
//					delete nameDictionary[path];
//				}
			}
			target = null;
		}

		/**
		 * 回收资源(此时并没用彻底从缓存中删除该资源，只是将引用计数-1)
		 * @param target
		 *
		 */
		public function recycleResource(target:*):void
		{
			if (null == target)
				return;
			var obj:*
			if (target is String)
			{
				if (gcDictionary[target] == true) //先判断此资源是否可以垃圾回收，如果是在设置引用计数-1
				{
					obj = getResource(target as String);
					if (obj != null)
					{
//						CONFIG::debug
//						{
//							if (ConfigManager.traceCacheEnable)
//							{
//								logger.debug("回收资源-->[" + nameDictionary[target] + "]-->当前引用计数-->" + referenceDictionary[obj]);
//							}
//						}
						// 最好不要小于0
						referenceDictionary[obj] = referenceDictionary[obj] - 1;
//						CONFIG::debug
//						{
//							if (ConfigManager.traceCacheEnable)
//							{
//								logger.debug("回收完成后-->[" + nameDictionary[target] + "]-->引用计数-->" + referenceDictionary[obj]);
//							}
//						}
					}
				}
			}
			else
			{
				if (target in referenceDictionary)
				{
//					CONFIG::debug
//					{
//						if (ConfigManager.traceCacheEnable)
//						{
//							logger.debug("回收资源-->[" + nameDictionary[target] + "]-->当前引用计数-->" + referenceDictionary[target]);
//						}
//					}
					var refCount:int = referenceDictionary[target];
					referenceDictionary[target] = refCount - 1;
//					CONFIG::debug
//					{
//						if (ConfigManager.traceCacheEnable)
//						{
//							logger.debug("回收完成后-->[" + nameDictionary[target] + "]-->引用计数-->" + referenceDictionary[target]);
//						}
//					}
				}
			}
		}

		/**
		 * 使用资源
		 * @param path 资源路径
		 * @return
		 *
		 */
		public function useResource(path:String):*
		{
			var target:* = getResource(path);
			// 如果再销毁队列中，要移除
			var index:int = _disposeList.indexOf(path);
			if (index >= 0)
			{
				_disposeList.splice(index, 1);
			}
			var refCount:int = referenceDictionary[target];
			// 引用计数+1
			referenceDictionary[target] = refCount + 1;
			timeoutDictionary[target] = flash.utils.getTimer();
//			CONFIG::debug
//			{
//				if (ConfigManager.traceCacheEnable)
//				{
//					logger.debug("使用资源-->" + path + "-->引用计数-->" + referenceDictionary[target]);
//				}
//			}
			return target;

		}

		/**
		 *
		 * 从缓存列表里面获取出相应资源
		 *
		 * @param path 资源路径
		 *
		 * @return
		 *
		 */
		private function getResource(path:String):*
		{
			if (hasResource(path))
			{
				return cacheDictionary[path];
			}
			return null;
		}

		/**
		 * 判断缓存列表里面是否存在该资源，如果存在为true,否则false
		 * @param path 资源路径
		 * @return True or false
		 *
		 */
		public function hasResource(path:String):Boolean
		{
			return path in cacheDictionary;
		}


		/**
		 * 失效时间3分钟
		 */
		private const invalidateTime:int = 120000;

		/**
		 *
		 * 垃圾回收
		 * @param force 是否强制回收
		 */
		public function gc():void
		{
			var time:int = flash.utils.getTimer();
			for (var i:* in cacheDictionary)
			{
				if (gcDictionary[i] == true) //可以垃圾回收
				{
					var target:* = cacheDictionary[i];
//					CONFIG::debug
//					{
//						if (ConfigManager.traceCacheEnable)
//						{
//							logger.debug("垃圾回收-->" + i + "-->引用次数-->" + referenceDictionary[target]);
//						}
//					}
//					CONFIG::logger
//					{
//						Loger.debug("垃圾回收-->" + i + "-->引用次数-->" + referenceDictionary[target],2);
//					}
					var refCount:int = referenceDictionary[target];
					if (refCount <= 0)
					{
						var refTime:int = timeoutDictionary[target] ? timeoutDictionary[target] : 0;
						if ((time - refTime) > invalidateTime) //上一次引用时间距离现在超过5秒
						{
							if (_disposeList.indexOf(i) == -1)
							{
								// 放入销毁队列中
								_disposeList.push(i);
								_disposeLen++;
							}
						}
					}
				}
			}
		}

		/**
		 * 上一次GC帧
		 */
		private var _lastGcStep:int = 0;

		/**
		 * GM频率,900帧来一次
		 */
		private const gcInterval:int = 600;

		/**
		 * 上一次释放时间
		 */
		private var _lastDisposeStep:int;

		//------------------------------------------------
		// IRendering implements
		//------------------------------------------------

		/**
		 * @inheritDoc
		 * @param step
		 *
		 */
		public function rendering(step:int = 0):void
		{
			if (step - _lastGcStep > gcInterval)
			{
				gc();
				_lastGcStep = step;
			}
			if (_disposeLen > 0)
			{
				if (step - _lastDisposeStep > 5)
				{
					var path:String = _disposeList.shift();
					removeResource(path);
					_disposeLen--;
					_lastDisposeStep = step;
				}
			}
		}

	}
}
