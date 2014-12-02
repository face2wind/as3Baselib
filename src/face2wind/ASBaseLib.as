package face2wind
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	
	import face2wind.config.ConfigManager;
	import face2wind.loading.RuntimeResourceManager;
	import face2wind.manager.EventManager;
	import face2wind.manager.LayerManager;
	import face2wind.manager.RenderManager;
	import face2wind.manager.StageManager;

	/**
	 * 基础类库入口，这里包含类库的各种启动器开关 
	 * @author Administrator
	 */	
	public class ASBaseLib
	{
		/**
		 *  主应用程序入口对象
		 */		
		private static var main:Sprite;
		
		/**
		 *  主应用程序加载完毕后执行的回调
		 */		
		private static var onLoadMainComplete:Function;
		
		/**
		 * 加载主程序携带的参数列表 
		 */		
		private static var swfParam:Object;
		
		/**
		 * 启动类库（初始化类库）  
		 * @param main 主应用程序入口对象
		 * @param onStart 主应用程序加载完毕后执行的回调
		 */
		public static function initialize(_main:Sprite , onStart:Function = null):void
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*"); 
			
			main = _main;
			onLoadMainComplete = onStart;
			
			StageManager.getInstance().stage = _main.stage;
			LayerManager.getInstance().fatherLayer = _main;
			RenderManager.getInstance().start();
			EventManager.InitBuses();
			RuntimeResourceManager.getInstance().startLoadNow = true;
			
			main.loaderInfo.addEventListener(Event.COMPLETE, completeInfoHandler);
		}
		
		/**
		 * 此swf加载完毕
		 * @param e
		 *
		 */		
		private static function completeInfoHandler(e:Event):void
		{
			main.loaderInfo.removeEventListener(Event.COMPLETE, completeInfoHandler);
			
			swfParam = main.loaderInfo.parameters;
			ConfigManager.setUrlParams(swfParam);
			var str:String = decodeURI(main.loaderInfo.url);
//			ConfigManager.sourceDir = str.substr(0, str.indexOf("loader.swf"));
			ConfigManager.sourceDir = str.substr(0, str.lastIndexOf("/")+1);
			
			if(null != onLoadMainComplete)
				onLoadMainComplete.apply();
		}
	}
}