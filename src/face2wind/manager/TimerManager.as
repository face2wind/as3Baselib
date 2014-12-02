package face2wind.manager
{
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * 统一Timer渲染管理类
	 * @author Michael.Huang
	 *
	 */
	public class TimerManager
	{
		private static var instance:TimerManager = null;
		
		public static function getInstance():TimerManager
		{
			if (null == instance)
				instance = new TimerManager();
			return instance;
		}
		
		public function TimerManager()
		{
			timerDic = new Dictionary();
			funcToTimerDic = new Dictionary();
			funcListDic = new Dictionary();
		}
		
		/**
		 * 存储创建的timer, key为指定的delay 
		 */		
		private var timerDic:Dictionary;
		
		/**
		 * 存储执行函数对timer引用 
		 */		
		private var funcToTimerDic:Dictionary;
		
		/**
		 * 存储执行函数队列 
		 */		
		private var funcListDic:Dictionary
		
		
		/**
		 * 添加Timer执行函数 
		 * @param delay 执行频率
		 * @param func  执行函数
		 * 
		 */		
		public function addItem(delay:int, func:Function):void
		{
			if (funcToTimerDic[func] != undefined)
				return;
			funcToTimerDic[func] = createTimer(delay);
			funcListDic[delay].push(func);
		}
		
		/**
		 * 是否已经注册了改函数
		 * @param func 执行函数
		 * @return
		 *
		 */
		public function hasItem(func:Function):Boolean
		{
			if (funcToTimerDic[func] != undefined)
				return true;
			return false;
		}
		
		/**
		 * 删除Timer执行函数 
		 * @param func
		 * 
		 */		
		public function removeItem(func:Function):void
		{
			if (funcToTimerDic[func] == undefined)
				return;
			var timer:Timer = funcToTimerDic[func];
			delete funcToTimerDic[func];
			var list:Array = funcListDic[timer.delay];
			if(!list)
				return;
			if (list.indexOf(func) > -1)
			{
				list.splice(list.indexOf(func), 1);
			}
			if (list.length == 0)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				delete funcListDic[timer.delay];
				delete timerDic[timer.delay];
			}
		}
		
		/**
		 * 根据给定延迟创建Timer 
		 * @param delay
		 * @return 
		 * 
		 */		
		private function createTimer(delay:int):Timer
		{
			if (timerDic[delay] == undefined)
			{
				var timer:Timer = new Timer(delay);
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
				timer.start();
				timerDic[delay] = timer;
			}
			if (funcListDic[delay] == undefined)
			{
				funcListDic[delay] = new Array();
			}
			return timerDic[delay];
		}
		
		private function timerHandler(e:TimerEvent):void
		{
			var list:Array = funcListDic[Timer(e.target).delay];
			for (var i:* in list)
			{
				list[i]();
			}
		}
	}
}