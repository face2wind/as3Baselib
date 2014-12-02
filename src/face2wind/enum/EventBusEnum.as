package face2wind.enum
{
	/**
	 * 事件总线类型（事件派发器类型） 
	 * @author face2wind
	 */	
	public class EventBusEnum
	{
		/**
		 * 类库内部总线 
		 */		
		public static var BASE_LIB:int = 0;
		
		/**
		 * 控制器总线 
		 */		
		public static var CONTROLLER:int = 1;
		
		/**
		 * 视图层总线 
		 */		
		public static var VIEW:int = 2;
		
		/**
		 * 数据层总线 
		 */		
		public static var MODEL:int = 3;
		
		/**
		 * 最大值（只用于创建，对外部无意义） 
		 */		
		public static var MAX:int = 4;
		
		/**
		 * 是否是已存在（合法）的事件总线类型 
		 * @param bus
		 * @return 
		 */		
		public static function availableBus(bus:int):Boolean
		{
			if(-1 < bus && MAX > bus)
				return true;
			else
				return false;
		}
	}
}