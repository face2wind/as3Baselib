package face2wind.manager
{
	import face2wind.enum.GameEffectLevel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	/**
	 * 性能管理器（监测游戏性能）
	 * @author face2wind
	 */
	public class PerformanceManager extends EventDispatcher
	{
		public function PerformanceManager()
		{
			if(instance)
				throw new Error("PerformanceManager is singleton class and allready exists!");
			instance = this;
		}
		
		/**
		 * 单例
		 */
		private static var instance:PerformanceManager;
		/**
		 * 获取单例
		 */
		public static function getInstance():PerformanceManager
		{
			if(!instance)
				instance = new PerformanceManager();
			
			return instance;
		}
		
		/**
		 * 渲染延时 
		 */		
		private var renderingDelay:int = 10;
		
		/**
		 * 记录上一次时间，做为对比 
		 */		
		private var lastTime:int = 0;
		
		private var _curPerformance:int = 0;
		/**
		 * 当前性能、游戏流畅度（暂定性能标识是0-1，0是最低性能，1是最高性能） 
		 */
		public function get curPerformance():int
		{
			return _curPerformance;
		}
		/**
		 * @private
		 */
		public function set curPerformance(value:int):void
		{
			_curPerformance = value;
		}

		/**
		 * 是否检测游戏性能 
		 * @param value
		 */		
		public function set monitoring(value:Boolean):void
		{
			if(value)
			{
				RenderManager.getInstance().add(rendering);
			}
			else
			{
				RenderManager.getInstance().remove(rendering);
			}
		}
		
		protected function rendering(index:int):void
		{
			if(index%renderingDelay == 0)
			{
				var fpsNum:Number = 1000 * renderingDelay / (getTimer() - lastTime);
				if(fpsNum < 20 ) //降帧厉害，说明性能很差；帧太低，说明卡，不要其他动画特效
				{
					curPerformance = 0;
					GameEffectManager.getInstance().curEffectLevel = GameEffectLevel.NO_EFFECT;
				}
				else
				{
					curPerformance = 1;
					GameEffectManager.getInstance().curEffectLevel = GameEffectLevel.HIGHT_EFFECT;
				}
				lastTime = getTimer();
			}
		}
	}
}