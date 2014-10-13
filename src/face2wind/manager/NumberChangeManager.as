package face2wind.manager
{
	import flash.utils.Dictionary;
	

	/**
	 * 数字变化管理器
	 * @author face2wind
	 */
	public class NumberChangeManager
	{
		public function NumberChangeManager()
		{
			if(instance)
				throw new Error("NumberChangeManager is singleton class and allready exists!");
			instance = this;
		}
		
		/**
		 * 单例
		 */
		private static var instance:NumberChangeManager;
		/**
		 * 获取单例
		 */
		public static function getInstance():NumberChangeManager
		{
			if(!instance)
				instance = new NumberChangeManager();
			
			return instance;
		}
		
		/**
		 * 改变函数列表 
		 */		
		private static var changingDic:Dictionary = new Dictionary();
		
		/**
		 * 允许变化的最大时间间隔，秒（超过这个时间自动修改指定的step以降到这个时间内变化完） 
		 */		
		private static var MAX_TIME:int = 5;
		
		/**
		 * 当前注册的正在改变的响应函数个数 
		 */		
		private static var curChangingNum:int = 0;
		
		/**
		 * timer索引 
		 */		
		private static var interval:int = 0;
		
		/**
		 * 开始改变数字，从 starNum变到endNum，使用func回调，参数是当前数字（指定变化步数）
		 * @param starNum 开始数字
		 * @param endNum 结束数字
		 * @param func 回调
		 * @param step 变化速度（每次变化的增量值）
		 * 
		 */				
		public static function startWithStep(starNum:int , endNum:int , func:Function , step:int = 1):void
		{
			if(starNum == endNum)
				return;
			
			var stepNum:int = Math.abs(starNum-endNum)/step;
			var rate:int = StageManager.getInstance().stage.frameRate;
			if(stepNum > MAX_TIME*rate)
				step = Math.abs(starNum-endNum)/(MAX_TIME*rate);
			
			var direction:int = 1;
			if(starNum > endNum)
				direction = -1;
			curChangingNum ++;
			changingDic[func] = 
				{func:func, direction:direction, starNum:starNum, endNum:endNum , step:step , curNum:starNum};
			if(1 == curChangingNum) //从0到1，增加监听
				interval = EnterFrameUtil.delayCall(1, timerFunc , false , 0);
		}
		
		/**
		 *  开始改变数字，从 starNum变到endNum，使用func回调，参数是当前数字（指定动画时间）
		 * @param starNum 开始数字
		 * @param endNum 结束数字
		 * @param func 回调
		 * @param time 动画时间（秒）
		 * 
		 */		
		public static function startWithTime(starNum:int , endNum:int , func:Function , time:Number = 2):void
		{
			if(starNum == endNum)
				return;
			
			if(time > MAX_TIME)
				time = MAX_TIME;
			var rate:int = StageManager.getInstance().stage.frameRate;
			var step:int = Math.abs(starNum-endNum)/rate*time;
			if(step <= 0){
				step = 1;
			}
			var direction:int = 1;
			if(starNum > endNum)
				direction = -1;
			curChangingNum ++;
			changingDic[func] = 
				{func:func, direction:direction, starNum:starNum, endNum:endNum , step:step , curNum:starNum};
			if(1 == curChangingNum) //从0到1，增加监听
				interval = EnterFrameUtil.delayCall(1, timerFunc , false , 0);
		}
		
		/**
		 * 终止一个数字的变化 
		 * @param func
		 * 
		 */		
		public static function stop(func:Function):void
		{
			var obj:* = changingDic[func];
			if(null == obj)
				return;
			var func:Function = obj.func as Function;
			var end:int = obj.endNum as int;
			if(null != func)
				func.apply(null,[end]);
			delete changingDic[func];
			curChangingNum --;
			if(0 == curChangingNum)//从1到0，移除监听
				EnterFrameUtil.removeItem(interval);
		}
		
		private static function timerFunc():void
		{
			for each(var obj:* in changingDic)
			{
				obj.curNum += (obj.direction*obj.step);
				if(obj.curNum == obj.endNum ||
					(obj.curNum-obj.endNum)*obj.direction > 0) //超出指定变化范围
				{
					obj.func.apply(null,[obj.endNum]);
					delete changingDic[obj.func];
					curChangingNum --;
					if(0 == curChangingNum)//从1到0，移除监听
						EnterFrameUtil.removeItem(interval);
				}
				else
					obj.func.apply(null,[obj.curNum]);
			}
		}
	}
}