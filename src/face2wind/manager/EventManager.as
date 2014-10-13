package face2wind.manager
{
	import face2wind.enum.EventBusEnum;
	import face2wind.event.ParamEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * 事件管理器（全局事件派发器）
	 * @author face2wind
	 */
	public class EventManager
	{
		private static var _instance:EventManager = null;
		public static function getInstance():EventManager
		{
			if(null == _instance)
				_instance = new EventManager();
			return _instance;
		}
		
		/**
		 * 事件总线列表 
		 */		
		private static var eventBuses:Array = [];
		/**
		 * 初始化事件总线 
		 * @return 
		 */		
		public static function InitBuses():void
		{
			for (var i:int = 0; i < EventBusEnum.MAX; i++) 
				eventBuses.push(new EventDispatcher())
		}
		
		/**
		 * 用指定总线监听事件  
		 * @param bus 总线类型
		 * @param type 事件的类型
		 * @param listener 处理事件的侦听器函数。此函数必须接受 Event 对象作为其唯一的参数，并且不能返回任何结果，如下面的示例所示： function(evt:Event):void <br/>函数可以有任何名称。
		 * @param useCapture 确定侦听器是运行于捕获阶段还是运行于目标和冒泡阶段。如果将 useCapture 设置为 true，则侦听器只在捕获阶段处理事件，而不在目标或冒泡阶段处理事件。如果 useCapture 为 false，则侦听器只在目标或冒泡阶段处理事件。要在所有三个阶段都侦听事件，请调用 addEventListener 两次：一次将 useCapture 设置为 true，一次将 useCapture 设置为 false。
		 * @param priority 事件侦听器的优先级。优先级由一个带符号的 32 位整数指定。数字越大，优先级越高。优先级为 n 的所有侦听器会在优先级为 n -1 的侦听器之前得到处理。如果两个或更多个侦听器共享相同的优先级，则按照它们的添加顺序进行处理。默认优先级为 0。
		 * @param useWeakReference 确定对侦听器的引用是强引用，还是弱引用。强引用（默认值）可防止您的侦听器被当作垃圾回收。弱引用则没有此作用。
		 */		
		public static function addEventListener(bus:int , type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if(!EventBusEnum.availableBus(bus))
				return;
			
			var edt:EventDispatcher = eventBuses[bus] as EventDispatcher;
			edt.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 *  指定总线移除事件监听
		 * @param bus 总线类型
		 * @param type 事件的类型
		 * @param listener 要删除的侦听器对象
		 * @param useCapture 指出是为捕获阶段还是为目标和冒泡阶段注册了侦听器。如果为捕获阶段以及目标和冒泡阶段注册了侦听器，则需要对 removeEventListener() 进行两次调用才能将这两个侦听器删除，一次调用将 useCapture() 设置为 true，另一次调用将 useCapture() 设置为 false
		 * 
		 */		
		public static function removeEventListener(bus:int , type:String, listener:Function, useCapture:Boolean=false):void
		{
			if(!EventBusEnum.availableBus(bus))
				return;
			
			var edt:EventDispatcher = eventBuses[bus] as EventDispatcher;
			edt.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * 用指定总线派发事件 
		 * @param bus 总线类型
		 * @param evt 调度到事件流中的 Event 对象。如果正在重新调度事件，则会自动创建此事件的一个克隆。在调度了事件后，其 target 属性将无法更改，因此您必须创建此事件的一个新副本以能够重新调度。
		 * @return 如果成功调度了事件，则值为 true。值 false 表示失败或对事件调用了 preventDefault()。
		 */		
		public static function dispatchEvent(bus:int , evt:Event):Boolean
		{
			if(!EventBusEnum.availableBus(bus))
				return false;
			
			var edt:EventDispatcher = eventBuses[bus] as EventDispatcher;
			return edt.dispatchEvent(evt);
		}
		
		//  下面是不同事件总线的简洁入口 ====================================================================================
		
		/**
		 * 通过控制器事件总线派发器，派发事件 
		 * @param event
		 * 
		 */		
		public function dispatchToController(event:ParamEvent):void
		{
			EventManager.dispatchEvent(EventBusEnum.CONTROLLER, event);
		}
		/**
		 * 通过控制器事件总线派发器，监听事件 
		 * @param type
		 * @param listener
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 */		
		public function bindToController(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			EventManager.addEventListener(EventBusEnum.CONTROLLER, type,listener,useCapture,priority,useWeakReference);
		}
		/**
		 * 通过控制器事件总线派发器，移除事件 
		 * @param type
		 * @param listener
		 * @param useCapture
		 */		
		public function unbindToController(type:String, listener:Function, useCapture:Boolean=false):void
		{
			EventManager.removeEventListener(EventBusEnum.CONTROLLER, type,listener,useCapture);
		}
		// =============================================================
		/**
		 * 通过数据模型事件总线派发器，派发事件 
		 * @param event
		 * 
		 */		
		public function dispatchToModel(event:ParamEvent):void
		{
			EventManager.dispatchEvent(EventBusEnum.MODEL, event);
		}
		
		/**
		 * 通过数据模型事件总线派发器，监听事件 
		 * @param type
		 * @param listener
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 */		
		public function bindToModel(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			EventManager.addEventListener(EventBusEnum.MODEL, type,listener,useCapture,priority,useWeakReference);
		}
		
		/**
		 * 通过数据模型事件总线派发器，移除事件 
		 * @param type
		 * @param listener
		 * @param useCapture
		 */		
		public function unbindToModel(type:String, listener:Function, useCapture:Boolean=false):void
		{
			EventManager.removeEventListener(EventBusEnum.MODEL, type,listener,useCapture);
		}
		// =============================================================
		/**
		 * 通过视图事件总线派发器，派发事件 
		 * @param event
		 * 
		 */		
		public function dispatchToView(event:ParamEvent):void
		{
			EventManager.dispatchEvent(EventBusEnum.VIEW, event);
		}
		
		/**
		 * 通过视图事件总线派发器，监听事件 
		 * @param type
		 * @param listener
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 */		
		public function bindToView(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			EventManager.addEventListener(EventBusEnum.VIEW, type,listener,useCapture,priority,useWeakReference);
		}
		
		/**
		 * 通过视图事件总线派发器，移除事件 
		 * @param type
		 * @param listener
		 * @param useCapture
		 */		
		public function unbindToView(type:String, listener:Function, useCapture:Boolean=false):void
		{
			EventManager.removeEventListener(EventBusEnum.VIEW, type,listener,useCapture);
		}
		// =============================================================
		/**
		 * 通过底层库事件总线派发器，派发事件 
		 * @param event
		 * 
		 */		
		public function dispatchToBaseLib(event:ParamEvent):void
		{
			EventManager.dispatchEvent(EventBusEnum.BASE_LIB, event);
		}
		
		/**
		 * 通过底层库事件总线派发器，监听事件 
		 * @param type
		 * @param listener
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 */		
		public function bindToBaseLib(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			EventManager.addEventListener(EventBusEnum.BASE_LIB, type,listener,useCapture,priority,useWeakReference);
		}
		
		/**
		 * 通过底层库事件总线派发器，移除事件 
		 * @param type
		 * @param listener
		 * @param useCapture
		 */		
		public function unbindToBaseLib(type:String, listener:Function, useCapture:Boolean=false):void
		{
			EventManager.removeEventListener(EventBusEnum.BASE_LIB, type,listener,useCapture);
		}
	}
}