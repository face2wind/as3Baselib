package face2wind.config
{
	import face2wind.lib.Debuger;
	import face2wind.util.ObjCloneUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * 打包管理器
	 * @author Face2wind
	 */
	public class ConfigPackerManager
	{
		public function ConfigPackerManager()
		{
			if(instance)
				throw new Error("ConfigPackerManager is singleton class and allready exists!");
			
			instance = this;
		}
		
		/**
		 * 单例
		 */
		private static var instance:ConfigPackerManager;
		/**
		 * 获取单例
		 */
		public static function getInstance():ConfigPackerManager
		{
			if(!instance)
				instance = new ConfigPackerManager();
			
			return instance;
		}
		
		protected var _allConfigManagers:Array = [];
		/**
		 * 所有需要打包的配置管理器列表（数组里对象要继承IConfig接口）
		 * @return
		 *
		 */
		public function get allConfigManagers():Array
		{
			return _allConfigManagers;
		}
		/**
		 * @private
		 */
		public function set allConfigManagers(value:Array):void
		{
			_allConfigManagers = value;
		}

		
		protected var _allLocaleManagers:Array = [];
		/**
		 * 所有需要打包的语言配置（数组里对象要继承IConfig接口）
		 * @return
		 *
		 */		
		public function get allLocaleManagers():Array
		{
			return _allLocaleManagers;
		}
		public function set allLocaleManagers(value:Array):void
		{
			_allLocaleManagers = value
		}
		
		protected var _allLoginLocaleManagers:Array = [];
		/**
		 * 所有需要打包的登录相关语言配置（数组里对象要继承IConfig接口）
		 * @return
		 *
		 */
		public function get allLoginLocaleManagers():Array
		{
			return _allLoginLocaleManagers;
		}
		/**
		 * @private
		 */
		public function set allLoginLocaleManagers(value:Array):void
		{
			_allLoginLocaleManagers = value;
		}

		
		/**
		 * 运行时资源管理引用
		 */
//		private static var resourceManager:RuntimeResourceManager = RuntimeResourceManager.getInstance();
		
		/**
		 * 所有游戏配置xml个数
		 */		
		private var configXmlNum:int ;
		
		/**
		 * 所有语言包配置xml个数
		 */		
		private var languageXmlNum:int;
		
		/**
		 * 暂存加载配置完成响应函数
		 */		
		private var xmlCompleteFunc:Function = null;
		
		/**
		 * 加载中的url对应管理器，关系字典
		 */		
		private var loadingDic:Dictionary;
		
		/**
		 * 管理器对应剩余未加载素材数
		 */		
		private var configDic:Dictionary;
		
		/**
		 * loader对应的url
		 */		
		private var urlLoaderToUrlDic:Dictionary;
		
		/**
		 * 加载所有配置xml文件
		 * @param completeFunc
		 *
		 */		
		public function loadAllConfig(completeFunc:Function):void
		{
			xmlCompleteFunc = completeFunc;
			configXmlNum = 0;
			loadingDic = new Dictionary();
			configDic = new Dictionary();
			urlLoaderToUrlDic = new Dictionary();
			var i:int;
			var k:int;
			var config:IConfig;
			var urlLoad:URLLoader;
			var url:String;
			for (i = 0; i < allConfigManagers.length; i++) 
			{
				config = allConfigManagers[i] as IConfig;
				for (k = 0; k < config.configXmlUrl.length; k++) 
				{
					configXmlNum ++;
					url = rURL("config/config/"+ConfigManager.language+"/"+config.configXmlUrl[k]);
					if(null == loadingDic[url])
						loadingDic[url] = [];
					loadingDic[url].push(config);
					if(undefined == configDic[config])
						configDic[config] = 0;
					configDic[config] ++;
					
					urlLoad=new URLLoader();
					urlLoad.addEventListener(Event.COMPLETE, completeConfigHandler);
					urlLoad.addEventListener(IOErrorEvent.IO_ERROR,ioErrorConfigHandler);
					urlLoaderToUrlDic[urlLoad] = url;
					urlLoad.load(new URLRequest(url));
				}
			}
			
			for (i = 0; i < allLocaleManagers.length; i++) 
			{
				config = allLocaleManagers[i] as IConfig;
				for (k = 0; k < config.configXmlUrl.length; k++) 
				{
					configXmlNum ++;
					url = rURL("config/locale/"+ConfigManager.language+"/"+config.configXmlUrl[k]);
					if(null == loadingDic[url])
						loadingDic[url] = [];
					loadingDic[url].push(config);
					if(undefined == configDic[config])
						configDic[config] = 0;
					configDic[config] ++;
					
					urlLoad=new URLLoader();
					urlLoad.addEventListener(Event.COMPLETE, completeConfigHandler);
					urlLoad.addEventListener(IOErrorEvent.IO_ERROR,ioErrorConfigHandler);
					urlLoaderToUrlDic[urlLoad] = url;
					urlLoad.load(new URLRequest(url));
				}
			}
			
			for (i = 0; i < allLoginLocaleManagers.length; i++) 
			{
				config = allLoginLocaleManagers[i] as IConfig;
				for (k = 0; k < config.configXmlUrl.length; k++) 
				{
					configXmlNum ++;
					url = rURL("config/locale/"+ConfigManager.language+"/"+config.configXmlUrl[k]);
					if(null == loadingDic[url])
						loadingDic[url] = [];
					loadingDic[url].push(config);
					if(undefined == configDic[config])
						configDic[config] = 0;
					configDic[config] ++;
					
					urlLoad=new URLLoader();
					urlLoad.addEventListener(Event.COMPLETE, completeConfigHandler);
					urlLoad.addEventListener(IOErrorEvent.IO_ERROR,ioErrorConfigHandler);
					urlLoaderToUrlDic[urlLoad] = url;
					urlLoad.load(new URLRequest(url));
				}
			}
		}
		
		private function ioErrorConfigHandler(e:IOErrorEvent):void
		{
			e.target.removeEventListener(Event.COMPLETE, completeConfigHandler); 
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorConfigHandler);
			var url:String = urlLoaderToUrlDic[e.target];
			Debuger.show(Debuger.LOADING , "["+url.replace(ConfigManager.cdnUrl, "") + "]" + "加载失败");
		}
		
		/**
		 * 完成加载配置文件
		 * @param e
		 *
		 */
		private function completeConfigHandler(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, completeConfigHandler); 
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorConfigHandler);
			
			var url:String = urlLoaderToUrlDic[e.target];
			configXmlNum --;
			for (var i:int = 0; i < loadingDic[url].length; i++) 
			{
				var config:IConfig = loadingDic[url][i] as IConfig;
				config.parseConfig(new XML(e.target.data) , url.substr(url.lastIndexOf("\/")+1) );
			}
			delete loadingDic[url];
			
			configDic[config] --;
			if(0 == configDic[config])
				delete configDic[config];
			if(0 == configXmlNum && null != xmlCompleteFunc) //所有xml加载完毕
			{
				xmlCompleteFunc.apply();
			}
		}
		
		/**
		 * 打包游戏配置
		 *
		 */		
		public function packageGameConfig():ByteArray
		{
			var saveDic:Dictionary = new Dictionary(); //存储所有配置的字典，直接写入二进制数据
			registerClassAlias("flash.utils.Dictionary", Dictionary);
			for (var i:int = 0; i < allConfigManagers.length; i++) 
			{
				var config:IConfig = allConfigManagers[i] as IConfig;
				config.registerClassAliasHd();
				saveDic[config.configKey] = config.dictionary;
			}
			var data:ByteArray = new ByteArray();
			data.writeObject(saveDic);
			data.compress();
			return data;
		}
		
		/**
		 * 打包语言配置
		 *
		 */		
		public function packageLanguageConfig():ByteArray
		{
			var saveDic:Dictionary = new Dictionary(); //存储所有配置的字典，直接写入二进制数据
			registerClassAlias("flash.utils.Dictionary", Dictionary);
			for (var i:int = 0; i < allLocaleManagers.length; i++) 
			{
				var config:IConfig = allLocaleManagers[i] as IConfig;
				config.registerClassAliasHd();
				saveDic[config.configKey] = config.dictionary;
			}
			var data:ByteArray = new ByteArray();
			data.writeObject(saveDic);
			data.compress();
			return data;
		}
		
		/**
		 * 打包登录-语言配置
		 *
		 */		
		public function packageLoginLanguageConfig():ByteArray
		{
			var saveDic:Dictionary = new Dictionary(); //存储所有配置的字典，直接写入二进制数据
			registerClassAlias("flash.utils.Dictionary", Dictionary);
			for (var i:int = 0; i < allLoginLocaleManagers.length; i++) 
			{
				var config:IConfig = allLoginLocaleManagers[i] as IConfig;
				config.registerClassAliasHd();
				saveDic[config.configKey] = config.dictionary;
			}
			var data:ByteArray = new ByteArray();
			data.writeObject(saveDic);
			data.compress();
			return data;
		}
		
		/**
		 * 读取游戏配置二进制数据
		 * @param data
		 *
		 */		
		public function readGameConfigByteArray(data:ByteArray):void
		{
			data.uncompress();
			registerClassAlias("flash.utils.Dictionary", Dictionary);
			var i:int;
			var config:IConfig;
			for (i = 0; i < allConfigManagers.length; i++)  //先注册类，读取数据后再写入
			{
				config = allConfigManagers[i] as IConfig;
				config.registerClassAliasHd();
			}
			var allConfigDic:Dictionary = data.readObject() as Dictionary;
			for (i = 0; i < allConfigManagers.length; i++)
			{
				config = allConfigManagers[i] as IConfig;
				config.dictionary = allConfigDic[config.configKey] as Dictionary;
			}
		}
		
		/**
		 * 读取语言包配置二进制数据
		 * @param data
		 *
		 */		
		public function readLocalConfigByteArray(data:ByteArray):void
		{
			data.uncompress();
			registerClassAlias("flash.utils.Dictionary", Dictionary);
			var i:int;
			var config:IConfig;
			for (i = 0; i < allLocaleManagers.length; i++)  //先注册类，读取数据后再写入
			{
				config = allLocaleManagers[i] as IConfig;
				config.registerClassAliasHd();
			}
			var allConfigDic:Dictionary = data.readObject() as Dictionary;
			for (i = 0; i < allLocaleManagers.length; i++)
			{
				config = allLocaleManagers[i] as IConfig;
				config.dictionary = allConfigDic[config.configKey] as Dictionary;
			}
		}
		
		/**
		 * 读取登录语言包配置二进制数据
		 * @param data
		 *
		 */		
		public function readLoginLocalConfigByteArray(data:ByteArray):void
		{
			data = ObjCloneUtil.clone(data); //用克隆数据，不要直接修改cache缓存
			data.uncompress();
			registerClassAlias("flash.utils.Dictionary", Dictionary);
			var i:int;
			var config:IConfig;
			for (i = 0; i < allLoginLocaleManagers.length; i++)  //先注册类，读取数据后再写入
			{
				config = allLoginLocaleManagers[i] as IConfig;
				config.registerClassAliasHd();
			}
			var allConfigDic:Dictionary = data.readObject() as Dictionary;
			for (i = 0; i < allLoginLocaleManagers.length; i++)
			{
				config = allLoginLocaleManagers[i] as IConfig;
				config.dictionary = allConfigDic[config.configKey] as Dictionary;
			}
		}
	}
}


