package face2wind.lib
{
	import face2wind.enum.EventBusEnum;
	import face2wind.event.ParamEvent;
	import face2wind.manager.EventManager;
	import face2wind.util.StringUtil;
	
	import flash.utils.Dictionary;

	/**
	 * 调试信息输出类
	 * @author face2wind
	 */
	public class Debuger
	{
		/**
		 * 类库内的打印类信息（其他类型可写在其他类里） 
		 */		
		public static var BASE_LIB:String = "baseLib";
		
		/**
		 * 类库协议输出
		 */		
		public static var SOCKET:String = "socket";
		
		/**
		 * 类库 - 加载模块 
		 */		
		public static var LOADING:String = "loading";
		
		/**
		 * 调试信息输出事件
		 */		
		public static var EVENT_DEBUGER_MSG:String = "Debuger_EVENT_DEBUGER_MSG";
		
		/**
		 * 记录哪些模块可以输出调试信息 
		 */		
		private static var moduleDebugDic:Dictionary = new Dictionary();
		
		/**
		 * 设置对应模块是否可输出debug信息 
		 * @param module 对应模块名
		 * @param canDebug 能否输出调试信息
		 * 
		 */		
		public static function setModuleDebug( module:String , canDebug:Boolean):void
		{
			moduleDebugDic[module] = canDebug;
		}
		
		/**
		 * 显示一条调试信息 
		 * @param module 对应模块名
		 * @param msg 调试信息
		 * 
		 */		
		public static function show( module:String , msg:String, _data:Object=null):void
		{
			if(null == msg || "" == msg)
				return;
			
			if(null != moduleDebugDic[module] && true == moduleDebugDic[module])
			{
				trace(StringUtil.removeHtml(msg));
				EventManager.dispatchEvent(EventBusEnum.BASE_LIB,
					new ParamEvent(EVENT_DEBUGER_MSG , {module:module,msg:msg,data:_data}));
			}
		}
	}
}
