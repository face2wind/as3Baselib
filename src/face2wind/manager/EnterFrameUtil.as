package face2wind.manager
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	/**
	 * @author Michael.Huang
	 */
	public class EnterFrameUtil
	{
		/**
		 *最大渲染函数数量
		 */
		public static const MAX_RENDER_FUN:int = 300;

		/**
		 * 当前FPS
		 */
		public static var FPS:Number = 30;

		/**
		 * 简单侦听enterFrame事件的shap
		 */
		private static const _shap:Shape = new Shape();

		/**
		 * 渲染队列
		 */
		private static var _handlers:Array = [];

		/**
		 * 渲染队列数量统计
		 */
		private static var _count:int;

		/**
		 * 是否真正渲染中
		 */
		private static var _isPlaying:Boolean = false;

		/**
		 * @priate
		 */
		private static var _step:int;

		/**
		 * 计数
		 */
		private static var _interval:int = 0;

		/**
		 * 记录每次进来的数组
		 */
		private static var _funDic:Dictionary;

		/**
		 * 记录第一次的getTime时间戳
		 */
		private static var _first_time:Number = 0;

		/**
		 * 开始
		 */
		private static function start():void
		{
			_shap.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_first_time = getTimer();
			_funDic = new Dictionary();
		}

		/**
		 * 停止
		 */
		private static function stop():void
		{
			_isPlaying = false;
			_shap.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_step = 0;
			
		}

		/**
		 * @private static
		 */
		private static function enterFrameHandler(e:Event):void
		{
			_step++;
			doRendering(_step);
		}

		/**
		 * 渲染执行
		 */
		/**
		 *
		 * @param step
		 */
		private static function doRendering(step:int):void
		{
			FPS = 1000  / (getTimer() - _first_time);
			_first_time = getTimer();
			var runCount:int = 0;
			var arr:Array;
			for (var i:* in _funDic)
			{
				arr = _funDic[i];
				if (arr != null)
				{
					var time:int = arr[0];
					var useFrame:Boolean = arr[1]; // 是使用帧还是时间戳
					var repeat:int = arr[2]; // 重复计数
					var delay:int = arr[3]; // 延迟计数
					var call:Function = arr[4]; // 回调函数
					var delayable:Boolean = arr[5]; // 是否允许延迟执行
					var hasDelayed:Boolean = arr[6]; // 是否已经延迟了
					var args:Array = arr[7];
					if (useFrame) // 如果使用帧渲染
					{
						if (_step - time >= delay || hasDelayed)
						{
							call.apply(null, args);
							runCount++;
							repeat--;
							if (repeat == 0 && _funDic.hasOwnProperty(i)) // 重复执行次数为0，删除
							{
								delete _funDic[i];
								_count--;
							}
							else
							{
								// 执行完，如果重复执行的要修改repeat,和step
								arr[0] = _step;
								arr[2] = repeat;
								arr[6] = false;
							}
								// < 0 情况会一直执行
						}
					}
					else
					{
						var curTime:int = getTimer();
						if (curTime - time >= delay || hasDelayed)
						{
							call.apply(null, args);
							runCount++;
							repeat--;
							if (repeat == 0 && _funDic.hasOwnProperty(i))
							{
								delete _funDic[i];
								_count--;
							}
							else
							{
								arr[0] = curTime;
								arr[2] = repeat;
								arr[6] = false;
							}
						}
					}
				}
			}
			if (_count <= 0) // 队列空了，停止执行
			{
				stop();
			}
		}

		/**
		 * 延迟执行方法
		 * @param delay 延迟时间，或者帧数，参考useFrame参数
		 * @param call  执行函数
		 * @param useFrame 是否使用帧数
		 * @param repeat 重复次数
		 * @param delayable 是否允许延迟执行，同一时间段执行的函数数量过多会延迟到下一帧去执行
		 * @param args 函数执行参数
		 * @return 计数id,此id可用于删除
		 *
		 */
		public static function delayCall(delay:int, call:Function, useFrame:Boolean = false, repeat:int = 1, delayable:Boolean = true, ... args):int
		{
			var arr:Array;
			if (useFrame)
			{
				arr = [_step, useFrame, repeat, delay, call, delayable, false, args];
				//_handlers.push(arr);
				_count++;
			}
			else
			{
				arr = [getTimer(), useFrame, repeat, delay, call, delayable, false, args]
				//_handlers.push(arr);
				_count++;
			}
			if (false == _isPlaying)
			{
				start();
				_isPlaying = true;
			}
			_interval++;
			_funDic[_interval] = arr;
			return _interval;
		}

		/**
		 * 删除它
		 */
		public static function removeItem(interval:int):void
		{
//			var index:int = _handlers.indexOf(item);
//			if (index != -1)
//			{
//				_handlers.splice(index, 1);
//				_count--;
//				if (_count <= 0) // 队列空了，停止执行
//				{
//					stop();
//				}
//			}
			if(!_funDic.hasOwnProperty(interval))
				return;
			
			delete _funDic[interval];
			_count--;
			
			if (_count <= 0) // 队列空了，停止执行
			{
				stop();
			}
		}
	}
}
