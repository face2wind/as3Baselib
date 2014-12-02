package face2wind.manager
{
	import face2wind.enum.GameEffectLevel;

	/**
	 * 游戏特效管理器（只负责指定当前特效等级，游戏内各种动画根据此类决定一些动画或特效的程度）
	 * @author face2wind
	 */
	public class GameEffectManager
	{
		public function GameEffectManager()
		{
			if(instance)
				throw new Error("GameEffectManager is singleton class and allready exists!");
			instance = this;
		}
		
		/**
		 * 单例
		 */
		private static var instance:GameEffectManager;
		/**
		 * 获取单例
		 */
		public static function getInstance():GameEffectManager
		{
			if(!instance)
				instance = new GameEffectManager();
			
			return instance;
		}
		
		private var _curEffectLevel:int = GameEffectLevel.HIGHT_EFFECT;
		/**
		 * 当前游戏特效 
		 */
		public function get curEffectLevel():int
		{
			return _curEffectLevel;
		}
		/**
		 * @private
		 */
		public function set curEffectLevel(value:int):void
		{
			_curEffectLevel = value;
		}

	}
}