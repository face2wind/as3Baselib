package face2wind.enum
{
	/**
	 * 层枚举
	 * @author face2wind
	 */
	public class LayerEnum
	{
		/**
		 * 最顶层 
		 */		
		public static var TOP_LAYER:int = 10;
		
		/**
		 * 提示信息层 
		 */		
		public static var MSG_LAYER:int = 9;
		
		/**
		 * 加载层 
		 */		
		public static var LOADING_LAYER:int = 8;
		
		/**
		 * 放在窗口上面的特效层（比如交接任务的文字特效提示）
		 */		
		public static var HIGHT_EFFECT_LAYER:int = 7;
		
		/**
		 *世界地图层 
		 */		
		public static var WORLD_MAP_LAYER:int = 6;
		
		/**
		 *战斗层 
		 */		
		public static var COMBAT_LAYER:int = 5;
		
		/**
		 * 窗口层 
		 */		
		public static var WINDOW_LAYER:int = 4;
		
		/**
		 * 屏幕特效层（送花，天气等效果） 
		 */		
		public static var EFFECT_LAYER:int = 3;
		
		/**
		 * 界面UI层 
		 */		
		public static var UI_LAYER:int = 2;
		
		/**
		 * 场景层 
		 */		
		public static var SCENE_LAYER:int = 1;
		
		/**
		 * 最底层 
		 */		
		public static var FLOOR_LAYER:int = 0;
		
		/**
		 *检测输入的层是否合法 
		 * @param layerindex
		 * @return 
		 * 
		 */		
		public static function availableLayer(layerindex:int):Boolean
		{
			return (FLOOR_LAYER < layerindex && TOP_LAYER > layerindex);
		}
	}
}
