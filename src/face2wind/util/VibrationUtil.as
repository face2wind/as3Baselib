package face2wind.util
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	
	/**
	 * 浮动（震动）工具类
	 * @author face2wind
	 */
	public class VibrationUtil
	{
		public function VibrationUtil()
		{
		}
		
		/**
		 * 垂直震动对象列表 
		 */		
		protected static var vibrationDic:Dictionary = new Dictionary();
		
		/**
		 * 立刻开始震动（以当前对象的坐标为原点，amplitude为振幅，上下/左右震动，若已有此对象的震动，则忽略） 
		 * @param obj 需要震动的对象
		 * @param direction 震动方向，1 上下，2 左右
		 * @param amplitude 振幅（像素）
		 * @param cycle 震动周期（毫秒）
		 */		
		public static function startVibration(obj:DisplayObject, direction:int = 1, amplitude:Number = 5, cycle:int = 2000):void
		{
			if(null == obj || 0 >= amplitude) // illegal params
				return;
			if(undefined != vibrationDic[obj]) // aleady has this vibration
				return;
			
			vibrationDic[obj] = { type:direction, amplitude:amplitude , originXpos:obj.x, originYpos:obj.y , cycle:cycle}; // type 1 vertical, 2 horizontal
			onTweenLiteComplete(obj, -1);
		}
		
		/**
		 * 停止一个震动 
		 * @param obj 震动对象
		 */		
		public static function stopVibration(obj:DisplayObject):void
		{
			if(undefined != vibrationDic[obj])
			{
				TweenLite.killTweensOf(obj);
				var vObj:Object = vibrationDic[obj];
				obj.x = vObj.originXpos;
				obj.y = vObj.originYpos;
				delete vibrationDic[obj];
			}
		}
		
		/**
		 * 每段运动完毕后执行的动作 
		 * @param obj
		 * @param direction
		 */		
		protected static function onTweenLiteComplete(obj:DisplayObject, direction:int = -1):void
		{
			TweenLite.killTweensOf(obj);
			var vObj:Object = vibrationDic[obj];
			if(null == vObj) // vibration data has been remove , pass
				return;
			var targetX:Number = vObj.originXpos;
			var targetY:Number = vObj.originYpos;
			if(1 == vObj.type) // vertical
				targetY = vObj.originYpos + direction*vObj.amplitude;
			else if(2 == vObj.type) // horizontal
				targetX = vObj.originXpos + direction*vObj.amplitude;
			
			TweenLite.to(obj, vObj.cycle/1000, {x:targetX, y:targetY, onComplete:onTweenLiteComplete, onCompleteParams:[obj, -1*direction]});
		}
	}
}