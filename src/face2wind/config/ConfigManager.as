package face2wind.config
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import face2wind.util.StringUtil;
	
	/**
	 * 基本配置管理
	 * @author Face2wind
	 */
	public class ConfigManager
	{
		private static var CONFIG_PATH:String = "/config/config.xml";
		
		// 这些数据从嵌入网页的swf中用JS获取  ==========================================================
		
		/**
		 * 资源加载路径（正式服不用这个，用CDN路径） 
		 */		
		public static var sourceDir:String = "";
		
		
		// 以下数据来自config.xml ======================================================================
		
		/**
		 * 服务端IP 
		 */		
		public static var serverIP:String = "";
		
		/**
		 * 端口 
		 */		
		public static var port:int = 0;
//		
//		/**
//		 * 服务器ID（平台N服） 后台废弃了
//		 */		
//		public static var serverID:String = "";
		
		/**
		 * 服务器KEY，用于登录验证 
		 */		
		public static var serverKey:String = "";
		
		/**
		 * 角色登录名 
		 */		
		public static var pname:String = "";
		
		/**
		 * 是否使用游客模式(0:否 1:是) 
		 */		
		public static var guest_mode:Boolean =  false;
		
		/**
		 * 是否登录器登录 
		 */		
		public static var from_launcher:Boolean = false;
		
		/**
		 * 游戏版本 
		 */		
		public static var gameVersion:String = "2014-09-13";
		
		/**
		 * 项目语言 
		 */		
		public static var language:String = "zh_CN";

		/**
		 * 是否在加载界面显示debug信息 
		 */		
		public static var loadingDebugMsg:Boolean = false;
		
		/**
		 * 平台 
		 */		
		public static var platform:int = 1;
		
		private static var _cdnUrl:String = ""; 
		/**
		 * CDN的URL地址<br/>
		 * 如果这个为空的话就则用的是和loader.swf一样的资源路径
		 */
		public static function get cdnUrl():String
		{
			if("" != _cdnUrl)
				return _cdnUrl;
			else
				return sourceDir;
		}
		/**
		 * @private
		 */
		public static function set cdnUrl(value:String):void
		{
			_cdnUrl = value;
		}
		/**
		 *战报KEY 
		 */
		public static var webCombatLoaderReqId:String ="";
		/**
		 *战报PHP地址 
		 */		
		public static var webReportUrl:String = "";
		/**
		 * 是否开启本地缓存 
		 */		
		public static var openLocalCache:Boolean = false;
		
		/**
		 * 预加载的资源列表 
		 */		
		public static var preLoadRes:Array = [];
		
		public function ConfigManager()
		{
		}
		
		/**
		 * 解析从config.xml里读取的配置 
		 * @param data
		 * 
		 */		
		public static function setConfigData(data:XML):void
		{
//			serverIP = String(data.socket.ip);
//			port = int(data.socket.port);
////			serverID = String(data.socket.server_id);
//			serverKey = String(data.socket.serverKey);
//			//如果用户名为空，说明之前没接收过从网页来的参数，使用配置里的玩家帐号
//			if(StringUtil.isEmpty(pname))
//				pname = String(data.socket.pname);
//			guest_mode = (1 == int(data.socket.guest_mode));
//			from_launcher = (1 == int(data.socket.from_launcher));
//			gameVersion = String(data.flash.gameVersion);
//			language =  String(data.flash.language);
//			platform =  int(data.flash.platform);
//			enableJs = (int(data.flash.enableJs) == 1);
//			loadingDebugMsg = (int(data.flash.loadingDebugMsg) > 0);
//			cdnUrl =  String(data.flash.cdn);
//			openLocalCache = (1 == int(data.flash.openLocalCache));
//			
//			var preLoadResList:XMLList = data.preLoadRes.item;
//			for (var i:int = 0; i < preLoadResList.length(); i++) 
//			{
//				var loadObj:Object = new Object();
//				loadObj.name = String(preLoadResList[i].@name);
//				loadObj.title = String(preLoadResList[i].@title);
//				loadObj.type = String(preLoadResList[i].@type);
//				loadObj.path = rLanguage(String(preLoadResList[i]));
//				preLoadRes.push(loadObj);
//			}
		}
		
		/**
		 * 获取分析url参数
		 */
		public static function setUrlParams(params:Object):void
		{
			parameters = params;
			pname = params["pname"] == null ? "" : params["pname"];
			pname = unescape(pname);
		}
		
		/**
		 * 获取真实的资源路径
		 * @param path
		 * @addVersion true|false 是否添加版本号
		 * @useRoot 是否使用根目录下
		 * @dv 专门给场景加载的固定参数，暂时这样
		 * @return
		 *
		 */
		public static function getResourcePath(path:String, addVersion:Boolean = true, useRoot:Boolean = true,dv:int=0):String
		{
			var url:String;
			if(useRoot)
				url = rURL(path);
			else
				url = path;
			if(addVersion)
			{
				var vo:FileVo = getFileInfo(path);
				if (vo != null)
				{
					url = url + "?version=" + vo.timestamp;
				}
				else
				{
					url = url + "?version=" + gameVersion;
				}
			}
			return url;
		}
		
		//----------------------------------------------
		//
		// 文件版本日志相关
		//
		//----------------------------------------------
		
		/**
		 * @private
		 */
		private static var fileDic:Dictionary = new Dictionary();
		
		/**
		 * 解析扫描文件内容
		 * @param data
		 *
		 */
		public static function parseVesion(data:ByteArray):void
		{
			if (null == data)
				return;
			try
			{
				data.uncompress();
				data.position = 0;
				
				var type:String = data.readUTF();
				var key:String = data.readUTF();
				
				while (data.bytesAvailable)
				{
					var vo:FileVo = new FileVo();
					vo.path = data.readUTF();
					vo.timestamp = data.readInt();
					//					vo.size = data.readInt();
					fileDic[vo.path] = vo;
				}
			}
			catch(e:*)
			{
				// do nothing
			}
		}
		
		/**
		 * 获取文件信息
		 * @param path
		 * @return
		 *
		 */
		public static function getFileInfo(path:String):FileVo
		{
			return fileDic[path];
		}
		
		/**
		 * 获取文件更新时间戳
		 * @param path
		 * @return
		 *
		 */		
		public static function getFileTimestamp(path:String):int
		{
			var vo:FileVo = getFileInfo(path);
			if(vo != null)
				return vo.timestamp;
			return 0;			
		}
		
		/**
		 * 获取文件大小
		 * @param path
		 * @return
		 *
		 */		
		public static function getFileSize(path:String):int
		{
			var vo:FileVo = getFileInfo(path);
			if(vo != null)
				return vo.size;
			return 0;
		}
		
		private static var loader:URLLoader;
		
		/**
		 * 网页传过来的参数 
		 */		 
		public static var parameters:Object;
		
		/**
		 * 是否支持允许游戏直接调用JS接口（只适用于网页，flash单窗口本地调试别开启，会报错） 
		 */		
		public static var enableJs:Boolean = false;
		
		private static function validate_completeHandler(e:Event):void
		{
			trace(e);
		}
	}
}
