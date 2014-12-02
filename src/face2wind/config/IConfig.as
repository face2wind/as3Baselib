package face2wind.config
{
	import flash.utils.Dictionary;

	/**
	 *  配置管理器接口
	 * @author Face2wind
	 * 
	 */	
	public interface IConfig
	{
		/**
		 * 存储配置数据的字典 
		 * @return 
		 * 
		 */		
		function get dictionary():Dictionary;
		function set dictionary(dic:Dictionary):void;
		
		/**
		 * 序列化，反序列化需注册的类 
		 * 
		 */		
		function registerClassAliasHd():void;
		
		/**
		 * 所需xml列表 
		 * @return 
		 * 
		 */		
		function get configXmlUrl():Array
		
		/**
		 * 加载此类xml对应的唯一key 
		 * @return 
		 * 
		 */			
		function get configKey():String;
		
		/**
		 * 解析XML配置到字典 
		 * @param xml
		 * @return 
		 * 
		 */		
		function parseConfig(xml:XML , xmlName:String):Dictionary;
	}
}