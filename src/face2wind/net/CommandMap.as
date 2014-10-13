package face2wind.net
{
	
	import flash.utils.Dictionary;
	import face2wind.net.item.ICommandMap;

	/**
	 * 协议识别器（在逻辑层新建一个类直接继承此类，并重写init函数）
	 * @author face2wind
	 */	
	public class CommandMap implements ICommandMap
	{
		public function CommandMap()
		{
			_scmdClassDic = new Dictionary();
			_cmdAttributes = new Dictionary();
			initScmdClassDic();
			initCMDAttributes();
		}
		
		/**
		 *  初始化S2C的协议类对象列表
		 */		
		protected function initScmdClassDic():void
		{
			//  留给逻辑层的子类覆盖
		}
		
		/**
		 * 初始化所有协议属性信息 
		 */		
		protected function initCMDAttributes():void
		{
			//  留给逻辑层的子类覆盖
		}
		
		/**
		 *  S2C的协议类对象列表
		 */		
		protected var _scmdClassDic:Dictionary;
		
		/**
		 * 所有协议属性信息 
		 */		
		protected var _cmdAttributes:Dictionary;
		
		/**
		 * 获取S2C的协议类对象，用于构造对应的协议接收类对象 
		 * @param cmd 协议类名（SCMD+协议号，或者CCMD+协议号，或者其他）
		 * @return 
		 */		
		public function getScmdClass(cmd:String):Class
		{
			return _scmdClassDic[cmd];
		}
		
		/**
		 * 获取对应协议类的属性列表（按定义顺序排列，且包含属性类型） 
		 * @param cmd 协议类名（SCMD+协议号，或者CCMD+协议号，或者其他）
		 * @return 
		 */		
		public function getCMDAttributes(cmd:String):Array
		{
			return _cmdAttributes[cmd];
		}
	}
}