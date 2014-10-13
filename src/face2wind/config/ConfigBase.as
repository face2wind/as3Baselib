package face2wind.config
{
	import flash.utils.Dictionary;
	
	/**
	 * 配置管理器基类
	 * @author Face2wind
	 */
	public class ConfigBase implements IConfig
	{
		public function ConfigBase()
		{
		}
		
		private var _dic:Dictionary;
		public function get dictionary():Dictionary
		{
			if(null == _dic)
				_dic = new Dictionary();
			return _dic;
		}
		public function set dictionary(dic:Dictionary):void
		{
			_dic = dic;
		}
		
		// 以下函数是需要子类重写的 ===================================================
		
		public function registerClassAliasHd():void
		{
		}
		
		public function get configXmlUrl():Array
		{
			return null;
		}
		
		public function get configKey():String
		{
			return null;
		}
		
		public function parseConfig(xml:XML, xmlName:String):Dictionary
		{
			return dictionary;
		}
	}
}
