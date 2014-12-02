package face2wind.net.item
{
	/**
	 * 协议映射器，提供所有协议（包括S2C和C2S）的字段信息（顺序和类型） 
	 * @author face2wind
	 */	
	public interface ICommandMap
	{
		/**
		 * 获取S2C的协议类对象，用于构造对应的协议接收类对象 
		 * @param cmd 协议类名（SCMD+协议号，或者CCMD+协议号，或者其他）
		 * @return 
		 */		
		function getScmdClass(cmd:String):Class;
		
		/**
		 * 获取对应协议类的属性列表（按定义顺序排列，且包含属性类型） 
		 * @param cmd 协议类名（SCMD+协议号，或者CCMD+协议号，或者其他）
		 * @return 
		 */			
		function getCMDAttributes(cmd:String):Array
	}
}