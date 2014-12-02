package face2wind.event
{
	import flash.events.Event;
	
	/**
	 * 属性改变事件生成器
	 * @author Michael.Huang
	 */
	public class PropertyChangeEvent extends Event
	{
		/**
		 * 属性改变事件 
		 */		
		public static const PROPERTY_CHANGE:String = "PropertyChangeEvent_PROPERTY_CHANGE";
		
		/**
		 * 变化的属性名 
		 */		
		public var property:*;
		
		/**
		 * 属性原来的值 
		 */		
		public var oldValue:*;
		
		/**
		 * 属性改变后的值 
		 */		
		public var newValue:*;
		
		/**
		 * 快速创建出一个属性改变事件 
		 * @param property 属性名
		 * @param oldValue 属性变更前的值
		 * @param newValue 属性变更后的值
		 * @return 
		 * 
		 */		
		public static function createUpdateEvent(
			property:Object,
			oldValue:Object,
			newValue:Object):PropertyChangeEvent
		{
			var event:PropertyChangeEvent =
				new PropertyChangeEvent(PROPERTY_CHANGE);
			
			event.oldValue = oldValue;
			event.newValue = newValue;
			event.property = property;
			
			return event;
		}
		
		/**
		 * 创建属性改变事件 
		 * @param type 事件的类型，可以作为 Event.type 访问。
		 * @param bubbles 确定 Event 对象是否参与事件流的冒泡阶段。默认值为 false
		 * @param canCelable 确定是否可以取消 Event 对象。默认值为 false
		 * @param property 属性名
		 * @param oldValue 属性变更前的值
		 * @param newValue 属性变更后的值
		 */		
		public function PropertyChangeEvent(type:String, bubbles:Boolean = false,
											canCelable:Boolean = false,
											property:Object = null, 
											oldValue:Object = null,
											newValue:Object = null)
		{
			super(type, bubbles, canCelable);
			
			this.property = property;
			this.oldValue = oldValue;
			this.newValue = newValue;
		}
		
		/**
		 * 克隆一个一样的事件出来 
		 * @return 
		 */		
		override public function clone():Event
		{
			return new PropertyChangeEvent(type, bubbles, cancelable, property, oldValue, newValue);
		}
	}
}