package face2wind.event
{
	import flash.events.Event;
	
	/**
	 * 带参数的事件
	 * @author face2wind
	 * 
	 */	
	public class ParamEvent extends Event
	{
		/**
		 * 事件携带的数据 
		 */		
		public var param:Object;
		
		public function ParamEvent(type:String, newParam:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			param = newParam;
		}
	}
}