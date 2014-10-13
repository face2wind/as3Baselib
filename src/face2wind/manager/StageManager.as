package face2wind.manager
{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * 舞台管理器，统一管理舞台相关操作
	 * @author face2wind
	 */
	public class StageManager
	{
		private var _stage:Stage = null;
		
		public function StageManager()
		{
			resizeFuncDic = new Dictionary();
		}
		
		private static var _instance:StageManager = null;
		public static function getInstance():StageManager
		{
			if(null == _instance)
				_instance = new StageManager();
			return _instance;
		}
		
		public function set stage(value:Stage):void
		{
			if(null == value)
				return;
			_stage = value;
			_stage.scaleMode = StageScaleMode.NO_SCALE ;
			_stage.align = StageAlign.TOP_LEFT;
			_stage.stageFocusRect = false;
			
			_stage.addEventListener(Event.RESIZE, onResize);
		}
		
		public function get stage():Stage
		{
			return _stage;
		}
		
		/**
		 * 舞台帧频 
		 * @param rate
		 * 
		 */		
		public function set frameRate(rate:Number):void
		{
			if(_stage)
				_stage.frameRate = rate;
		}
		
		/**
		 * 存储舞台大小变化响应函数列表 
		 */		
		private var resizeFuncDic:Dictionary;
		
		/**
		 * 舞台宽 
		 * @return 
		 * 
		 */		
		public function get stageWidth():Number
		{
			if(_stage)
				return _stage.stageWidth;
			else
				return 0;
		}
		
		/**
		 * 舞台高 
		 * @return 
		 * 
		 */		
		public function get stageHeight():Number
		{
			if(_stage)
				return _stage.stageHeight;
			else
				return 0;
		}
		
		/**
		 * 舞台大小改变 
		 * @param e
		 * 
		 */		
		private function onResize(e:Event = null):void
		{
			var w:Number = stageWidth;
			var h:Number = stageHeight;
			for each (var func:Function in resizeFuncDic) 
			{
				func.apply(null, [w , h]);
			}
		}
		
		/**
		 * 增加一个响应函数，舞台大小变化时触发  
		 * @param func
		 * @param runNow 是否立刻执行一次
		 * 
		 */
		public function addStageResizeFunc(func:Function , runNow:Boolean = false):void
		{
			if(null == func)
				return;
			resizeFuncDic[func] = func;
			if(runNow)
				func.apply(null, [stageWidth , stageHeight]);
		}
		
		/**
		 *删除一个响应函数
		 * @param func
		 * 
		 */		
		public function removeStageResizeFunc(func:Function):void
		{
			if(undefined != resizeFuncDic[func])
				delete resizeFuncDic[func];
		}
	}
}