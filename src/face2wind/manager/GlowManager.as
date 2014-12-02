package face2wind.manager
{
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;

	/**
	 * 闪烁管理器，用滤镜和timer做成的闪烁效果
	 * @author face2wind
	 */
	public class GlowManager
	{
		/**
		 * 发光数组
		 */
		private var defaultF:Array = [
			new GlowFilter(0xFFFF00, 1, 2, 2, 5), 
			new GlowFilter(0xFFFF00, 1, 3, 3, 5), 
			new GlowFilter(0xFFFF00, 1, 5, 5, 5), 
			new GlowFilter(0xFFFF00, 1, 7, 7, 5), 
			new GlowFilter(0xFFFF00, 1, 8, 8, 5), 
			new GlowFilter(0xFFFF00, 1, 10, 10, 5), 
			new GlowFilter(0xFFFF00, 1, 10, 10, 5), 
			new GlowFilter(0xFFFF00, 1, 8, 8, 5), 
			new GlowFilter(0xFFFF00, 1, 7, 7, 5), 
			new GlowFilter(0xFFFF00, 1, 5, 5, 5), 
			new GlowFilter(0xFFFF00, 1, 3, 3, 5), 
			new GlowFilter(0xFFFF00, 1, 2, 2, 5)];
		
		public function GlowManager()
		{
			if(instance)
				throw new Error("GlowManager is singleton class and allready exists!");
			instance = this;
			
			filterDic = new Dictionary();
			glowingDic = new Dictionary();
		}
		
		/**
		 * 单例
		 */
		private static var instance:GlowManager;
		/**
		 * 获取单例
		 */
		public static function getInstance():GlowManager
		{
			if(!instance)
				instance = new GlowManager();
			
			return instance;
		}
		
		/**
		 * 颜色滤镜列表字典 
		 */		
		private var filterDic:Dictionary;
		
		/**
		 * 正在发光的对象 
		 */		
		private var glowingDic:Dictionary;
		
		/**
		 * 当前正在发光的对象个数 
		 */		
		private var curGlowingNum:int = 0;
		
		/**
		 * 默认滤镜的颜色 
		 */		
		private var defaultFilterColor:uint = 0xFFFF00;
		
		/**
		 * timer的index，用于停止计时器 
		 */		
		private var timerIndex:int = -1;
		
		/**
		 * 创建一个颜色对应的滤镜列表
		 * @param color
		 * @return 
		 * 
		 */		
		private function createFilterList(color:uint):Array
		{
			var tmpArr:Array = filterDic[color];
			if(null == tmpArr)
			{
				tmpArr = [
					new GlowFilter(color, 1, 2, 2, 5), 
					new GlowFilter(color, 1, 3, 3, 5), 
					new GlowFilter(color, 1, 5, 5, 5), 
					new GlowFilter(color, 1, 7, 7, 5), 
					new GlowFilter(color, 1, 8, 8, 5), 
					new GlowFilter(color, 1, 10, 10, 5), 
					new GlowFilter(color, 1, 10, 10, 5), 
					new GlowFilter(color, 1, 8, 8, 5), 
					new GlowFilter(color, 1, 7, 7, 5), 
					new GlowFilter(color, 1, 5, 5, 5), 
					new GlowFilter(color, 1, 3, 3, 5), 
					new GlowFilter(color, 1, 2, 2, 5)];
				filterDic[color] = tmpArr;
			}
			return tmpArr;
		}
		
		/**
		 * 让一个显示对象发光（一个对象只能注册一个发光动画，后注册的会覆盖前面的）
		 * @param obj 显示对象
		 * @param color 发光的颜色，默认黄色
		 * 
		 */		
		public function glowItem(obj:DisplayObject , color:uint = 0xFFFF00):void
		{
			if(null == obj)
				return;
			var filters:Array = createFilterList(color);
			glowingDic[obj] = {object:obj, filters:filters , curIndex:0};
			curGlowingNum++;
			if(1 == curGlowingNum)
				timerIndex = EnterFrameUtil.delayCall(100, onRenderHandler , false, 0);
		}
		
		/**
		 * 让某个已发光对象停止发光 
		 * @param obj
		 * 
		 */		
		public function stopGlowItem(obj:DisplayObject ):void
		{
			if(null == obj || 
				null == glowingDic[obj]) //之前没注册过此对象
				return;
			obj.filters = [];
			delete glowingDic[obj];
			curGlowingNum--;
			if(1 > curGlowingNum)
				EnterFrameUtil.removeItem(timerIndex);
		}
		
		private function onRenderHandler():void
		{
			for each( var obj:* in glowingDic)
			{
				var dObj:DisplayObject = obj.object;
				var filterList:Array = obj.filters ;
				dObj.filters = [filterList[obj.curIndex]];
				obj.curIndex++;
				if(obj.curIndex >= filterList.length) //闪到最后一个滤镜，倒回第一个滤镜
					obj.curIndex = 0;
			}
		}
	}
}