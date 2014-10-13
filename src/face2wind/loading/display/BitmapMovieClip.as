package face2wind.loading.display
{
	import face2wind.manager.EnterFrameUtil;
	import face2wind.manager.TimerManager;
	import face2wind.view.BaseSprite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;

	/**
	 * The BitmapMovieClip class like the <b>MovieClip</b> class, usually we use it to play the bitmap movie.
	 * When use the MovieClip to display, it will holder more CPU, so we use the memory to change the CPU and display it.
	 *
	 * @author Michael.Huang
	 */
	public class BitmapMovieClip extends BaseSprite
	{
		public function BitmapMovieClip(data:MovieClipData = null)
		{
			super();
			_bitmap = new Bitmap();
			addChild(_bitmap);
			this.movieClipData = data;
		}

		//----------------------------------------------
		//
		//  Variables
		//
		//----------------------------------------------

		/**
		 * 是否使用timer渲染
		 */
		public var userTimerRendering:Boolean = false;
		
		/**
		 *  是否停止在最后一帧
		 */		
		public var isStopLast:Boolean = false;

		/**
		 * 是否正在播放
		 */
		public var isPlaying:Boolean = false;

		/**
		 * 是否循环播放动画
		 */
		protected var isLoop:Boolean = false;

		/**
		 * 动画开始帧
		 */
		protected var startFrame:int = 0;

		/**
		 * 动画结束帧
		 */
		protected var endFrame:int = 0;

		/**
		 * 动画播放完成后执行的函数
		 */
		protected var complete:Function;

		/**
		 * 动画结束后执行函数的参数
		 */
		protected var completeArgs:Array;

		//---------------------------------------------------------------------------
		//
		//  Getter and setter
		//
		//---------------------------------------------------------------------------

		//----------------------------------------------
		// offsetX
		//----------------------------------------------

		private var _offsetX:Number = 100;

		/**
		 * 动画相对于原点(0,0)偏移量，此数值影响使用BitmapMovieUtil.getMovieDataFromMovieClip方法
		 * @see BitmapMovieUtil
		 */
		public function get offsetX():Number
		{
			return _offsetX;
		}

		/**
		 * @private
		 */
		public function set offsetX(value:Number):void
		{
			_offsetX = value;
		}

		//----------------------------------------------
		// offsetY
		//----------------------------------------------
		private var _offsetY:Number = 100;

		/**
		 *
		 * 动画相对于原点(0,0)偏移量，此数值影响使用BitmapMovieUtil.getMovieDataFromMovieClip方法
		 * @see BitmapMovieUtil
		 *
		 */
		public function get offsetY():Number
		{
			return _offsetY;
		}

		/**
		 * @private
		 */
		public function set offsetY(value:Number):void
		{
			_offsetY = value;
		}

		//----------------------------------------------
		// delay
		//----------------------------------------------
		private var _delay:int = 100;

		/**
		 * 延迟执行动画的时间，单位毫秒, 设置此值影响动画渲染方式
		 */
		public function get delay():int
		{
			return _delay;
		}

		/**
		 * @private
		 */
		public function set delay(value:int):void
		{
			if (_delay == value)
				return;
			_delay = value;
			// 渲染频率改变，要重新设置
			isPlaying = false;
		}


		//----------------------------------------------
		// movieClipData
		//----------------------------------------------
		protected var _movieClipData:MovieClipData;

		/**
		 * 动画实际数据源
		 * @return movieClipData MovieClipData
		 */
		public function get movieClipData():MovieClipData
		{
			return _movieClipData;
		}

		/**
		 * @private
		 */
		public function set movieClipData(value:MovieClipData):void
		{
			_movieClipData = value;
			if (_movieClipData != null)
			{
				_currentFrame = 1;
				_totalFrames = _movieClipData.totalFrames;
				gotoAndStop(_currentFrame);
			}
		}

		//----------------------------------------------
		// currentFrame
		//----------------------------------------------
		protected var _currentFrame:int = 0;

		/**
		 *
		 * 当前帧
		 *
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}

		//----------------------------------------------
		// totalFrames
		//----------------------------------------------
		protected var _totalFrames:int = 0;

		/**
		 *
		 * 总共帧数
		 *
		 */
		public function get totalFrames():int
		{
			return _totalFrames;
		}

		//----------------------------------------------
		// bitmapData
		//----------------------------------------------
		private var _bitmapData:BitmapData;

		/**
		 *  当前帧的BitmapData
		 */
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}

		//----------------------------------------------
		// bitmap
		//----------------------------------------------
		private var _bitmap:Bitmap;

		/**
		 * 当前帧的Bitmap
		 *
		 */
		public function get bitmap():Bitmap
		{
			return _bitmap;
		}

		//----------------------------------------------
		// source
		//----------------------------------------------
		private var _source:*;

		/**
		 *
		 * 数据源，当前只支持MovieClip
		 *
		 */
		public function get source():*
		{
			return _source;
		}

		/**
		 *
		 * @private
		 *
		 */
		public function set source(value:*):void
		{
			if (_source == value)
				return;
			_source = value;
			if (_source != null)
			{
				if (_source is MovieClip)
				{
					var data:MovieClipData = new MovieClipData();
					data.offsetX = offsetX;
					data.offsetY = offsetY;
					data.source = _source as MovieClip;
					movieClipData = data;
					if(isGotoAndPlay) //有设置过播放
						gotoAndPlay(startFrame ,isLoop , startFrame, endFrame , complete , completeArgs);
					else
						gotoAndStop(_currentFrame);
				}
			}
			else
			{
				dispose();
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function get height():Number
		{
			return -_bitmap.y;
		}

		//----------------------------------------------
		//
		//  Methods
		//
		//----------------------------------------------

		/**
		 * @private
		 */
		private var _interval:int;

		/**
		 * 播放
		 */
		protected function playing():void
		{
			if (false == isPlaying)
			{
				if (userTimerRendering)
				{
					TimerManager.getInstance().removeItem(rendering)
					TimerManager.getInstance().addItem(delay, rendering);
				}
				else
				{
					if (_interval > 0)
					{
						EnterFrameUtil.removeItem(_interval);
						_interval = 0;
					}

					_interval = EnterFrameUtil.delayCall(delay, rendering, false, 0, true);
				}
				isPlaying = true;
			}
		}

		/**
		 * @private
		 */
		protected function enterFrameHandler(event:Event):void
		{
			rendering();
		}

		/**
		 * @private
		 */
		protected function rendering():void
		{
			if (_currentFrame >= endFrame)
			{
				if (isLoop)
				{
					_currentFrame = startFrame;
				}
				else
				{
					dispatchEvent(new Event("moviewComplete"));
					if (complete != null)
					{
						complete.apply(this, completeArgs);
					}
					stop();
				}
				if (_timeInterval > 0)
				{
					EnterFrameUtil.removeItem(_timeInterval);
					_timeInterval = 0;
				}
				dispatchEvent(new Event("playEnd"));

			}
			else
			{
				_currentFrame++;
			}
			setCurrentFrame(_currentFrame);
		}

		/**
		 * 停止在最后一帧 
		 */		
		public function stopAtLast():void
		{
			isStopLast = true;
			gotoAndStop(_currentFrame);
			_movieClipData = null;
		}
		/**
		 *@private 
		 */		
		protected var _timeInterval:int;

		/**
		 * 超时自动停止
		 */
		public function timeoutStop(time:int = 2000):void
		{
			if (_timeInterval > 0)
			{
				EnterFrameUtil.removeItem(_timeInterval);
				_timeInterval = 0;
			}
			_timeInterval = EnterFrameUtil.delayCall(time,doTimeoutStop);
		}

		private function doTimeoutStop():void
		{
			_timeInterval = 0;
			dispatchEvent(new Event("playEnd"));
		}

		/**
		 * @private
		 */
		protected function setCurrentFrame(frameIndex:int):void
		{
			var frame:BitmapFrame;
			if (_movieClipData != null)
			{
				if ((_movieClipData.framelist != null) && (frameIndex > 0) && (frameIndex <= _movieClipData.totalFrames))
				{
					frame = _movieClipData.getBitmapFrameByIndex(frameIndex - 1);
					if (frame != null)
					{
						_bitmapData = frame.bitmapData;
						_bitmap.bitmapData = _bitmapData;
						_bitmap.x = -frame.xpos;
						_bitmap.y = -frame.ypos;
					}
				}
			}
		}

		/**
		 * 是否设置了指定帧播放，用于dispose后恢复 
		 */		
		protected var isGotoAndPlay:Boolean = false;
		/**
		 * 从指定帧开始播放
		 *
		 * @param frame
		 * @param isLoop
		 * @param start
		 * @param end
		 * @param complete
		 *
		 */
		public function gotoAndPlay(frame:*, isLoop:Boolean = true, start:* = null, end:* = null, complete:Function = null, completeArgs:Array = null):void
		{
			if (_movieClipData == null)
				return;
			this.isLoop = isLoop;
			startFrame = start;
			endFrame = end;
			_currentFrame = frame;
			if (start == null)
			{
				startFrame = 1;
			}
			else
			{
				startFrame = int(start);
			}
			if (end == null)
			{
				endFrame = _totalFrames;
			}
			else
			{
				endFrame = int(end);
			}
			this.complete = complete;
			this.completeArgs = completeArgs;
			setCurrentFrame(_currentFrame);
			playing();
			isGotoAndPlay = true;
		}

		/**
		 * 停止在指定帧
		 * @param frame
		 *
		 */
		public function gotoAndStop(frame:*):void
		{
			if (_movieClipData == null)
				return;
			_currentFrame = frame;
			setCurrentFrame(_currentFrame);
			stop();
			isGotoAndPlay = false;
		}

		/**
		 * 暂停
		 */
		public function puase():void
		{
			gotoAndStop(_currentFrame);
		}

		/**
		 *
		 * 将当前播放头向前移动一帧
		 *
		 */
		public function prevFrame():void
		{
			gotoAndStop(Math.max(currentFrame - 1, 1));
		}

		/**
		 *
		 * 将当前播放头向后移动一帧
		 *
		 */
		public function nextFrame():void
		{
			gotoAndStop(Math.min(currentFrame + 1, _movieClipData.framelist.length));
		}

		/**
		 *
		 * 停止当前渲染， 如果使用timer渲染删除timer,如果使用enterFrame事件，删除事件
		 */
		public function stop():void
		{
			if (userTimerRendering)
			{
				TimerManager.getInstance().removeItem(rendering);
			}
			else
			{
				if (_interval > 0)
				{
					EnterFrameUtil.removeItem(_interval);
					_interval = 0;
				}
			}
			isPlaying = false;
		}

		/**
		 * 播放动画
		 *
		 * @param isLoop
		 * @param completeHandler
		 *
		 */
		public function play(isLoop:Boolean = true, completeHandler:Function = null, completeArgs:Array = null):void
		{
			this.gotoAndPlay(1, isLoop, null, null, completeHandler, completeArgs);
		}

		/**
		 * 是否碰撞
		 * @param isShape 是否使用形状检测碰撞
		 * @return
		 *
		 */
		public function isHit(isShape:Boolean = false):Boolean
		{
			var flag:Boolean = false;
			try
			{
				if (bitmap && bitmapData && bitmapData.height != 0 && bitmapData.width != 0)
				{
					if (isShape)
					{
						if (bitmap.mouseX > 0 && bitmap.mouseX < bitmap.width && bitmap.mouseY > 0 && bitmap.mouseY < bitmap.height)
						{
							flag = true;
						}
					}
					else
					{
						var pixel:uint = bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY);
						flag = pixel > 0;
					}
				}
			}
			catch (e:Error)
			{

			}
			return flag;
		}
		
		/**
		 * 恢复
		 */
		public override function resume():void
		{
			super.resume();
			_bitmap.bitmapData = _bitmapData;
			if(isGotoAndPlay) //有设置过播放
				gotoAndPlay(startFrame ,isLoop , startFrame, endFrame , complete , completeArgs);
			else
				gotoAndStop(_currentFrame);
		}
		
		/**
		 * 销毁 (此处并没用销毁所创建的MovieClipData图片)
		 */
		public override function dispose():void
		{
			super.dispose();
			stop();
			_bitmapData = null;
			_bitmap.bitmapData = _bitmapData;
//			this.movieClipData = null;
//			_bitmapData = null;
//			_source = null;
//			complete = null;
//			completeArgs = null;
		}
	}
}
