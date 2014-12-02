package face2wind.loading.display
{
	import face2wind.lib.Reflection;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.getTimer;

	/**
	 * 存储位图队列数据
	 * @author Michael.Huang
	 */
	public class MovieClipData
	{

		/**
		 * 类名称
		 */
		public static var CLASS_NAME:String = "image";

		/**
		 * 记录上一次draw时间 ，为避免一帧draw多个mc情况，使用一个时间间隔来确保流畅
		 */
		public static var LAST_DRAW_TIME:int = 0;

		/**
		 * 1毫秒draw的个数统计
		 */
		public static var CURRENT_DRAW_COUNT:int = 0;

		public function MovieClipData(source:MovieClip = null, app:ApplicationDomain = null, path:String = null)
		{
			this.app = app;
			this.source = source;
			this.path = path;
		}

		/**
		 * 保存对ApplicationDomain引用，方便反射类
		 */
		public var app:ApplicationDomain;

		/**
		 * 资源路径
		 */
		public var path:String = null;

		/**
		 * 获取当前动画总帧数
		 */
		public var totalFrames:int = 0;

		/**
		 * 记录注册点x偏移量
		 */
		public var offsetX:Number = 100;

		/**
		 * 记录注册点y偏移量
		 */
		public var offsetY:Number = 100;

		/**
		 * 存储位图列表
		 */
		public var framelist:Vector.<BitmapFrame>;

		/**
		 * FrameList length
		 */
		public var length:int = 0;

		/**
		 * 指示是否存在类信息，如果有只找一遍，否则使用draw模式
		 */
		private var hasClassInfo:Boolean;

		/**
		 * 是否检查了类信息
		 */
		private var hasCheckClassInfo:Boolean = false;

		private var _source:MovieClip;

		/**
		 * 动画资源MovieClip
		 */
		public function get source():MovieClip
		{
			return _source;
		}

		/**
		 * @private
		 */
		public function set source(value:MovieClip):void
		{
			_source = value;
			if (_source != null)
			{
				totalFrames = _source.totalFrames;
				framelist = new Vector.<BitmapFrame>(totalFrames);
				length = totalFrames;
			}
		}

		/**
		 * 获取指定帧的位图，如果已经存在存储列表中，直接返回，如果没有从新创建
		 * @param index
		 * @return
		 *
		 */
		public function getBitmapFrameByIndex(index:int):BitmapFrame
		{
			if (length == 0)
			{
				if (totalFrames <= 0)
					return null;
				else
					framelist = new Vector.<BitmapFrame>(totalFrames);
			}
			var frame:BitmapFrame = framelist[index];
			var rect:Rectangle;
			if (null == frame)
			{
				var time:int = getTimer();
				if (time - LAST_DRAW_TIME < 2) // 确保每1ms最多只draw了3次
				{
					CURRENT_DRAW_COUNT++;
					if (CURRENT_DRAW_COUNT > 3)
						return frame;
				}
				else
				{
					CURRENT_DRAW_COUNT = 0;
				}
				if (_source != null)
				{
					LAST_DRAW_TIME = time;	
					var bitmapData:BitmapData;
					var cls:Class;
					var className:String;
					if (_source.hasOwnProperty("uid"))
					{
						className = _source["uid"] + "_" + (index * 2 + 1);
						cls = Reflection.getClass(className, app);
						if (cls != null)
						{
							bitmapData = new cls(0, 0) as BitmapData;
							frame = new BitmapFrame();
							frame.xpos = -_source["positions"][index].x + offsetX;
							frame.ypos = -_source["positions"][index].y + offsetY;
							frame.bitmapData = bitmapData;
							framelist[index] = frame;
						}
						else // 如果失败了，走一遍draw的流程
						{
							_source.gotoAndStop(index + 1);
							rect = _source.getBounds(_source);
							bitmapData = new BitmapData(_source.width, _source.height, true, 0);
							bitmapData.lock();
							bitmapData.draw(_source, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
							bitmapData.unlock();
							frame = new BitmapFrame();
							frame.xpos = -rect.x + offsetX;
							frame.ypos = -rect.y + offsetY;
							frame.bitmapData = bitmapData;
							framelist[index] = frame;
						}
					}
					else
					{
						_source.gotoAndStop(index + 1);
						rect = _source.getBounds(_source);
						if (rect.width > 0 && rect.height > 0)
						{
							className = CLASS_NAME + (index * 2 + 1);
							if (false == hasCheckClassInfo) //只做一次
							{
								if (app != null && app.hasDefinition(className))
								{
									cls = Reflection.getClass(className, app);
									if (cls != null)
									{
										hasClassInfo = true;
									}
								}
								hasCheckClassInfo = true;
							}
							else //少了查找类信息校验，减少计算消耗
							{
								if (hasClassInfo)
								{
									cls = Reflection.getClass(className, app);
								}
								else
								{
									cls = null;
								}
							}
							if (cls != null)
							{
								bitmapData = new cls(0, 0) as BitmapData;
							}
							else //没有类信息，直接使用draw模式
							{
								bitmapData = new BitmapData(rect.width, rect.height, true, 0);
								bitmapData.lock();
								bitmapData.draw(_source, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
								bitmapData.unlock();
							}
							frame = new BitmapFrame();
							frame.xpos = -rect.x + offsetX;
							frame.ypos = -rect.y + offsetY;
							frame.bitmapData = bitmapData;
							framelist[index] = frame;
						}
					}
				}
			}
			if (frame != null)
			{
				// 刷新时间戳
				frame.lastTime = getTimer();
			}
			return frame;
		}

		/**
		 * 销毁指定帧位图数据
		 * @param index 帧(0开始)
		 *
		 */
		public function dispose(index:int):void
		{
			if (index > -1 && index < framelist.length)
			{
				if (framelist[index] != null && framelist[index] != undefined)
				{
					framelist[index].bitmapData.dispose();
					framelist[index].bitmapData = null;
				}
			}
		}

		/**
		 *
		 * 销毁所有创建的BitmapFrame
		 *
		 */
		public function disposeAll():void
		{
			var len:int = framelist.length - 1;
			while (len > -1)
			{
				dispose(len);
				len--;
			}
			framelist.length = 0;
			length = 0;
			app = null;
			_source = null;
		}


		/**
		 *
		 * 释放长时间未使用过的BitmaData数据
		 * @return 是否全部回收完,如果全部回收完毕返回true
		 */
		public function releaseTimeoutBitmapData():Boolean
		{
			var time:int = getTimer();
			var diff:int = 0;
			var frame:BitmapFrame;
			var length:int = framelist != null ? framelist.length : 0;
			var flag:Boolean = true;
			for (var i:int = 0; i < length; i++)
			{
				frame = framelist[i];
				if (frame != null)
				{
					diff = time - frame.lastTime;
					if (diff > 180000) //1.5分钟不使用就释放
					{
						//释放
						dispose(i);
						framelist[i] = null;
					}
					else
					{
						flag = false;
					}
				}
			}
			return flag;
		}
	}
}
