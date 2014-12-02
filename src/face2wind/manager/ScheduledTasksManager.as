package face2wind.manager
{
	import face2wind.manager.TimerManager;
	import face2wind.util.TimeUtil;
	
	import flash.utils.Dictionary;
	
	/**
	 * 计划任务管理器（把一个函数注册到任意时间点执行）<br/>
	 * @author face2wind
	 */
	public class ScheduledTasksManager
	{
		public function ScheduledTasksManager()
		{
			if(instance)
				throw new Error("ScheduledTasksManager is singleton class and allready exists!");
			instance = this;
			
			dayDic = new Dictionary();
			weekDic = new Dictionary();
			moonDic = new Dictionary();
			yearDic = new Dictionary();
			scheduleTimeDic = new Dictionary();
		}
		
		/**
		 * 单例
		 */
		private static var instance:ScheduledTasksManager;
		/**
		 * 获取单例
		 */
		public static function getInstance():ScheduledTasksManager
		{
			if(!instance)
				instance = new ScheduledTasksManager();
			
			return instance;
		}
		
		/**
		 * 天循环任务列表 
		 */		
		private var dayDic:Dictionary;
		
		/**
		 * 周循环任务列表 
		 */		
		private var weekDic:Dictionary;
		
		/**
		 * 月循环任务列表 
		 */		
		private var moonDic:Dictionary;
		
		/**
		 * 年循环任务列表 
		 */		
		private var yearDic:Dictionary;
		
		/**
		 * 当前计划任务列表的内容（防止重复） 
		 */		
		private var scheduleTimeDic:Dictionary;
		
		/**
		 * 下一个计划任务（维护一个单向链表，根据时间排序，最近要执行的排前面） 
		 */		
		private var nextScheduled:ScheduledTaskItem = null;
		
		/**
		 * 当前轮询频率 
		 */		
		private var curInterval:int =  0;
		
		/**
		 * 是否显示调试信息 
		 */		
		private var showDebugMsg:Boolean = false;
		
		/**
		 * 获取当前时间（秒） 
		 * @return 
		 */		
		private function getNowTime():int
		{
			return new Date().time/1000;//ServerTimeManager.getInstance().now;
		}
		
		/**
		 * 插入节点（插入时排序） 
		 * @param sItem
		 */		
		private function insertScheduledNode(sItem:ScheduledTaskItem):void
		{
			if( undefined != scheduleTimeDic[sItem.func+"_"+sItem.time] )
				return;
			if(getNowTime() > sItem.time) // 已经过时，忽略掉
				return;
			
			if(null == nextScheduled)
			{
				nextScheduled = sItem;
			}
			else if(sItem.time < nextScheduled.time)
			{
				sItem.nextScheduled = nextScheduled;
				nextScheduled = sItem;
			}
			else
			{
				var insertItem:ScheduledTaskItem = nextScheduled;
				var index:int = 2;
				while(insertItem.nextScheduled != null  &&
					sItem.time >= insertItem.nextScheduled.time)
				{
					insertItem = insertItem.nextScheduled;
					index ++;
				}
				sItem.nextScheduled = insertItem.nextScheduled;
				insertItem.nextScheduled = sItem;
			}
			scheduleTimeDic[sItem.func+"_"+sItem.time] = true;
			updateSchedule();
		}
		
		/**
		 *  删除一个或多个链表（若time是0，则表示删除所有func对应的计划任务）
		 * @param func
		 * @param time 时间戳（秒）
		 */		
		private function deleteScheduledWithFuncTime(func:Function, time:int = 0):void
		{
			if(undefined != scheduleTimeDic[func+"_"+time])
				return;
			
			var preScheduled:ScheduledTaskItem = null;
			var curScheduled:ScheduledTaskItem = nextScheduled;
			while(null != curScheduled)
			{
				if(
					curScheduled.func == func &&
					(curScheduled.time == time || 1 > time)
				) // 要删除指定的节点
				{
					delete scheduleTimeDic[func+"_"+time];
					var ori:ScheduledTaskItem = curScheduled;
					if(null == preScheduled) // 上一个节点是空，说明在头部
						nextScheduled = ori.nextScheduled;
					else
						preScheduled.nextScheduled = ori.nextScheduled;
					ori.nextScheduled = null;
					ori = null;
				}
				curScheduled = curScheduled.nextScheduled;
			}
			updateSchedule();
		}
		
		/**
		 * 删除第一个任务
		 */		
		private function deleteFirstScheduled():void
		{
			var ori:ScheduledTaskItem = nextScheduled;
			nextScheduled = ori.nextScheduled;
			ori.nextScheduled = null;
			delete scheduleTimeDic[ori.func+"_"+ori.time];
		}
		
		/**
		 * 更新计划任务（轮训间隔） 
		 */		
		private function updateSchedule():void
		{
			if(null == nextScheduled)
				return;
			var now:int = getNowTime();
			var interval:int = nextScheduled.time - now;
			if(0 > interval)
			{
				deleteFirstScheduled();
				return;
			}
			// 根据当前时间跟最近计划任务的时间差，调整轮询频率
			if(interval < (60*2)) // 剩余时间小于2分钟，轮询频率调到最频繁（每秒）
				interval = 1;
			else if(interval < (60*10))
				interval = 60;
			else if(interval < (60*30) )
				interval = 60*5;
			else if(interval < (60*60) )
				interval = 60*10;
			else if(interval < (60*60*24) )
				interval = 60*30;
			else
				interval = 60*60*12;
			if( interval != curInterval )
			{
				curInterval = interval;
				if(showDebugMsg)
					trace("change interval to : " + curInterval + " s");
				TimerManager.getInstance().removeItem(scheduleTimer);
				TimerManager.getInstance().addItem(curInterval*1000, scheduleTimer);
			}
		}
		
		/**
		 * 打印当前的链表信息 
		 */		
		private function showList():void
		{
			if(!showDebugMsg)
				return;
			var insertItem:ScheduledTaskItem = nextScheduled;
			var preTime:int = getNowTime();
			var msg:String = "||--"+coverTime(insertItem.time-preTime)+"--||";
			preTime = insertItem.time;
			insertItem = insertItem.nextScheduled;
			while(insertItem)
			{
				msg += "--"+coverTime(insertItem.time-preTime)+"--||";
				preTime = insertItem.time;
				insertItem = insertItem.nextScheduled;
			}
			trace(msg);
		}
		
		/**
		 * 把剩余的秒数时间转换成方便看的格式 
		 * @param sec
		 * @return 
		 */		
		private function coverTime(sec:int):String
		{
			var time:int = sec*1000;
			var format:String = "";
			if(60 > sec)
				format = "ss秒";
			else if((60*60) > sec)
				format = "mm分ss秒";
			else if((24*60*60) > sec)
				format = "hh时mm分ss秒";
			else
				format = "DD天hh时mm分ss秒";
			return TimeUtil.formatedTimeIntoCN(time);
		}
		
		/**
		 * 轮询函数 
		 */		
		private function scheduleTimer():void
		{
			showList();
			if(null == nextScheduled)
			{
				if(showDebugMsg)
					trace("all complete ! Stop !");
				TimerManager.getInstance().removeItem(scheduleTimer);
				return;
			}
			var now:int = getNowTime();
			if(nextScheduled.time > now) // 下一个任务时间未到
			{
				updateSchedule();
				return;
			}
			
			var ori:ScheduledTaskItem = nextScheduled;
			ori.func.apply();
			deleteFirstScheduled();
		}
		
		/**
		 * 开始年轮询 
		 */		
		private function startYearSchedule():void
		{
			var scheduledNum:int = 0;
			var item:ScheduledTaskItem;
			var now:int = getNowTime();
			for each(item in yearDic)
			{
				if(now > item.time) // 时间已过时，加多一周时间，重新进入计划任务
				{
					var itemDate:Date = new Date(item.time);
					itemDate.fullYear ++;
					item.time = itemDate.time/1000;
				}
				insertScheduledNode(item);
				scheduledNum ++;
			}
			if(0 < scheduledNum)
			{
				var date:Date = new Date(getNowTime()*1000);
				date.fullYear ++;
				date.month = 0;
				date.date = 1;
				date.hours = 0;
				date.minutes = 0;
				date.seconds = 1;
				var time:int = (date.time/1000); // 明年1月1号
				item = new ScheduledTaskItem();
				item.func = startWeekSchedule;
				item.time = time;
				insertScheduledNode(item);
			}
		}
		
		/**
		 * 开始月轮询 
		 * 
		 */		
		private function startMoonSchedule():void
		{
			var scheduledNum:int = 0;
			var item:ScheduledTaskItem;
			var now:int = getNowTime();
			for each(item in moonDic)
			{
				if(now > item.time) // 时间已过时，加多一周时间，重新进入计划任务
				{
					var itemDate:Date = new Date(item.time);
					if(11 == itemDate.month) 
					{
						itemDate.month = 0;
						itemDate.fullYear ++;
					}
					else
						itemDate.month ++;
					item.time = itemDate.time/1000;
				}
				insertScheduledNode(item);
				scheduledNum ++;
			}
			if(0 < scheduledNum)
			{
				var date:Date = new Date(getNowTime()*1000);
				// 月份+1
				if(11 == date.month) 
				{
					date.month = 0;
					date.fullYear ++;
				}
				else
					date.month ++;
				date.date = 1;
				date.hours = 0;
				date.minutes = 0;
				date.seconds = 1;
				var time:int = (date.time/1000); // 下个月1号
				item = new ScheduledTaskItem();
				item.func = startWeekSchedule;
				item.time = time;
				insertScheduledNode(item);
			}
		}
		
		/**
		 * 开始周轮询 
		 * 
		 */		
		private function startWeekSchedule():void
		{
			var scheduledNum:int = 0;
			var item:ScheduledTaskItem;
			var now:int = getNowTime();
			var weekTime:int = 7*24*60*60;
			for each(item in weekDic)
			{
				if(now > item.time) // 时间已过时，加多一周时间，重新进入计划任务
					item.time += weekTime;
				insertScheduledNode(item);
				scheduledNum ++;
			}
			if(0 < scheduledNum)
			{
				var date:Date = new Date(getNowTime()*1000);
				date.hours = 0;
				date.minutes = 0;
				date.seconds = 1;
				var time:int = (date.time/1000) + (7-date.day)*24*60*60; // 下周日凌晨0点轮询一次
				item = new ScheduledTaskItem();
				item.func = startWeekSchedule;
				item.time = time;
				insertScheduledNode(item);
			}
		}
		
		/**
		 * 开始天轮询 
		 */		
		private function startDaySchedule():void
		{
			var scheduledNum:int = 0;
			var item:ScheduledTaskItem;
			var now:int = getNowTime();
			var dayTime:int = 24*60*60;
			for each(item in dayDic)
			{
				if(now > item.time) // 时间已过时，加多一周时间，重新进入计划任务
					item.time += dayTime;
				insertScheduledNode(item);
				scheduledNum ++;
			}
			if(0 < scheduledNum)
			{
				var date:Date = new Date(getNowTime()*1000);
				date.hours = 0;
				date.minutes = 0;
				date.seconds = 1;
				var time:int = (date.time/1000) + 24*60*60; // 明天凌晨0点轮询一次
				item = new ScheduledTaskItem();
				item.func = startDaySchedule;
				item.time = time;
				insertScheduledNode(item);
			}
		}
		
		/**
		 *  注册一个年循环任务（每年指定时间执行任务） 
		 * @param func 执行的任务函数
		 * @param moon 月份（1-12）
		 * @param day 天数（1-31）只检测正常区间，如果该月28天，传入31也不会当作错误
		 * @param hour 小时（0-23）
		 * @param minute 分钟（0-59）
		 * @param second 秒（0-59）
		 * 
		 */		
		public function registerToYearDay(func:Function, moon:int, day:int, hour:int = 0, minute:int = 0, second:int = 0):void
		{
			var date:Date = new Date(getNowTime()*1000);
			date.month = moon;
			date.date = day;
			date.hours = hour;
			date.minutes = minute;
			date.seconds = second;
			var time:int = date.time/1000;
			if(undefined != yearDic[func+"_"+time]) // 之前已有对应时间对应函数的计划任务，忽略
				return;
			var item:ScheduledTaskItem = new ScheduledTaskItem();
			item.func = func;
			item.time = time;
			yearDic[func+"_"+time] = item;
			
			startYearSchedule();
		}
		
		/**
		 * 注册一个月循环任务（每月指定时间执行任务） 
		 * @param func 执行的任务函数
		 * @param day 天数（1-31）只检测正常区间，如果该月28天，传入31也不会当作错误
		 * @param hour 小时（0-23）
		 * @param minute 分钟（0-59）
		 * @param second 秒（0-59）
		 */		
		public function registerToMoonDay(func:Function, day:int, hour:int = 0, minute:int = 0, second:int = 0):void
		{
			var date:Date = new Date(getNowTime()*1000);
			date.date = day;
			date.hours = hour;
			date.minutes = minute;
			date.seconds = second;
			var time:int = date.time/1000;
			if(undefined != moonDic[func+"_"+time]) // 之前已有对应时间对应函数的计划任务，忽略
				return;
			var item:ScheduledTaskItem = new ScheduledTaskItem();
			item.func = func;
			item.time = time;
			moonDic[func+"_"+time] = item;
			
			startMoonSchedule();
		}
		
		/**
		 * 注册一个周循环任务（每周指定时间执行任务） 
		 * @param func 执行的任务函数
		 * @param day 周几（1-7）
		 * @param hour 小时（0-23）
		 * @param minute 分钟（0-59）
		 * @param second 秒（0-59）
		 */	
		public function registerToWeekDay(func:Function, day:int, hour:int = 0, minute:int = 0, second:int = 0):void
		{
			var date:Date = new Date(getNowTime()*1000);
			date.hours = hour;
			date.minutes = minute;
			date.seconds = second;
			var time:int = date.time/1000;
			if(undefined != weekDic[func+"_"+time]) // 之前已有对应时间对应函数的计划任务，忽略
				return;
			var item:ScheduledTaskItem = new ScheduledTaskItem();
			item.func = func;
			item.time = time + (day-date.day)*24*60*60;
			weekDic[func+"_"+time] = item;
			
			startWeekSchedule();
		}
		
		/**
		 * 注册一个天循环任务（每天指定时间执行任务） 
		 * @param func 执行的任务函数
		 * @param hour 小时（0-23）
		 * @param minute 分钟（0-59）
		 * @param second 秒（0-59）
		 */
		public function registerToDay(func:Function, hour:int = 0, minute:int = 0, second:int = 0):void
		{
			var date:Date = new Date(getNowTime()*1000);
			date.hours = hour;
			date.minutes = minute;
			date.seconds = second;
			var time:int = date.time/1000;
			if(undefined != dayDic[func+"_"+time]) // 之前已有对应时间对应函数的计划任务，忽略
				return;
			var item:ScheduledTaskItem = new ScheduledTaskItem();
			item.func = func;
			item.time = time;
			dayDic[func+"_"+time] = item;
			
			startDaySchedule();
		}
		
		/**
		 * 注册一个精确时间点的单次执行任务 
		 * @param func 执行的任务函数
		 * @param date 执行任务的时间点
		 */		
		public function registerToTime(func:Function, date:Date ):void
		{
			var sItem:ScheduledTaskItem = new ScheduledTaskItem();
			sItem.func = func;
			sItem.time = date.time/1000;
			insertScheduledNode(sItem);
		}
		
		/**
		 * 移除func对应的所有计划任务（若time是0，则表示删除所有func对应的计划任务）
		 * @param func
		 * @param time 时间戳（秒）
		 * 
		 */			
		public function unregisterFunc(func:Function, time:int = 0):void
		{
			var key:String;
			for (key in dayDic)
			{
				if(key.substr(0, key.indexOf("_")) == String(func))
					delete dayDic[key];
			}
			for (key in weekDic)
			{
				if(key.substr(0, key.indexOf("_")) == String(func))
					delete weekDic[key];
			}
			for (key in moonDic)
			{
				if(key.substr(0, key.indexOf("_")) == String(func))
					delete moonDic[key];
			}
			for (key in yearDic)
			{
				if(key.substr(0, key.indexOf("_")) == String(func))
					delete yearDic[key];
			}
			deleteScheduledWithFuncTime(func, time);
		}
	}
}

/**
 *  计划任务项
 * @author jieyou
 */	
class ScheduledTaskItem
{
	function ScheduledTaskItem()
	{
	}
	
	/**
	 * 具体执行任务的时间戳（秒） 
	 */		
	public var time:int;
	
	/**
	 * 执行的任务函数 
	 */		
	public var func:Function;
	
	/**
	 * 下一个计划任务 
	 */
	public var nextScheduled:ScheduledTaskItem = null;
}