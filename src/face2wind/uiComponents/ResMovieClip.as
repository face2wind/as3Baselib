/*
* Copyright(c) 2011 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
* either express or implied. See the License for the specific language
* governing permissions and limitations under the License.
*/
package face2wind.uiComponents
{
	
	import face2wind.event.ParamEvent;
	import face2wind.lib.Reflection;
	import face2wind.loading.RuntimeResourceManager;
	import face2wind.loading.display.BitmapMovieClip;
	import face2wind.loading.display.MovieClipData;
	
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	[Event(name = "complete", type = "flash.events.Event")]
	/**
	 * @author Michael.Huang
	 */
	public class ResMovieClip extends BitmapMovieClip
	{
		
		/**
		 *  运行时资源管理器引用
		 */
		private static var resourceManager:RuntimeResourceManager = RuntimeResourceManager.getInstance();
		
		/**
		 * @private
		 */
		private static var _defaultMovieClipData:MovieClipData;
		
		/**
		 * @private
		 */
		private static var _defaultMovieClipData_0:MovieClipData;
		
		/**
		 * @private
		 */
		private static var _defaultMovieClipData_1:MovieClipData;
		
		/**
		 * @private
		 */
		private static var _defaultMovieClipData_2:MovieClipData;
		
		/**
		 * @private
		 */
		private static var _defaultMovieClipData_3:MovieClipData;
		
		
		
		/**
		 * 获取默认动画资源
		 * @return
		 *
		 */
		public static function getDefaultMovieClipData(type:int = 4):MovieClipData
		{
//			switch (type)
//			{
//				case 0:
//					if (null == _defaultMovieClipData_0)
//					{
//						_defaultMovieClipData_0 = new MovieClipData();
//						_defaultMovieClipData_0.source = Reflection.createMovieClipInstance(CommonSkinConfig.DEFAULT_ASSET_0);
//					}
//					return _defaultMovieClipData_0;
//				case 1:
//					if (null == _defaultMovieClipData_1)
//					{
//						_defaultMovieClipData_1 = new MovieClipData();
//						_defaultMovieClipData_1.source = Reflection.createMovieClipInstance(CommonSkinConfig.DEFAULT_ASSET_1);
//					}
//					return _defaultMovieClipData_1;
//				case 2:
//					if (null == _defaultMovieClipData_2)
//					{
//						_defaultMovieClipData_2 = new MovieClipData();
//						_defaultMovieClipData_2.source = Reflection.createMovieClipInstance(CommonSkinConfig.DEFAULT_ASSET_2);
//					}
//					return _defaultMovieClipData_2;
//				case 3:
//					if (null == _defaultMovieClipData_3)
//					{
//						_defaultMovieClipData_3 = new MovieClipData();
//						_defaultMovieClipData_3.source = Reflection.createMovieClipInstance(CommonSkinConfig.DEFAULT_ASSET_3);
//					}
//					return _defaultMovieClipData_3;
//				default:
//					if (null == _defaultMovieClipData)
//					{
//						_defaultMovieClipData = new MovieClipData();
//						_defaultMovieClipData.source = Reflection.createMovieClipInstance(CommonSkinConfig.DEFAULT_ASSET);
//					}
//					return _defaultMovieClipData;
//			}
			return null;
			
		}
		
		/**
		 * ResMovieClip 构造函数
		 * @param data          数据源
		 * @param priority      加载优先级
		 *
		 */
		public function ResMovieClip(data:MovieClipData = null, priority:int = 10)
		{
			this.priority = priority;
			//			this.userTimerRendering = true;
			super(data);
			
		}
		
		/**
		 * 加载优先级
		 */
		public var priority:int;
		
		/**
		 *  是否回收缓存的资源
		 */
		public var gcable:Boolean = true;
		
		/**
		 * 指示是否使用默认资源
		 */
		public var useDefaultAsset:Boolean = false;
		
		/**
		 * 当前是否是默认资源 
		 */		
		private var _isDefaultAssetNow:Boolean = false;
		
		/**
		 * 自动播放
		 */
		public var isAutoPlay:Boolean = true;
		
		/**
		 * 是否循环播放
		 */
		public var loopPlay:Boolean = true;
		
		/**
		 * 备份资源路径，用于释放资源后恢复 
		 */		
		private var _sourceBackup:String;
		
		private var _source:String;
		
		/**
		 *  资源路径
		 */
		override public function get source():*
		{
			return _source
		}
		
		/**
		 * 设置资源路径
		 * @param value
		 *
		 */
		override public function set source(value:*):void
		{
			if (_source == value)
				return;
			var tmpSource:String = _source;
			_source = value;
			_sourceBackup = _source;
			if (movieClipData != null) //先回收引用
			{
				resourceManager.recycleResource(movieClipData);
			}
			if (null == _source || "" == _source)
			{
				movieClipData = null;
				if(null != tmpSource && "" != tmpSource)
					resourceManager.unload(tmpSource);
				super.dispose();
//				dispose();
			}
			else
			{//默认判断没有'/'符号则是从反射中获取素材，有'/'符号则用加载器加载
				if(-1 == _source.indexOf("\/"))
				{
					var rfData:MovieClipData = new MovieClipData(
						Reflection.createMovieClipInstance(_source), ApplicationDomain.currentDomain, _source);
					if(rfData)
					{
						movieClipData = rfData as MovieClipData;
						isStopLast = false;
						_isDefaultAssetNow = false;
						dispatchEvent(new ParamEvent(Event.COMPLETE,{url:_source}));
						if (isAutoPlay)
							play(loopPlay);
						return;
					}
				}
				else
				{
					if (resourceManager.hasResource(_source))
					{
						var data:* = resourceManager.useResource(_source);
						if (data && (data is MovieClipData))
						{
							movieClipData = data as MovieClipData;
							isStopLast = false;
							_isDefaultAssetNow = false;
							dispatchEvent(new ParamEvent(Event.COMPLETE,{url:_source}));
							if (isAutoPlay)
								play(loopPlay);
							return;
						}
						else
						{
							resourceManager.removeResource(_source);
						}
					}
				}
				if (useDefaultAsset)
				{
					if(false == isStopLast)
					{
						if (null == movieClipData)
						{
							_isDefaultAssetNow = true;
							movieClipData = getDefaultMovieClipData(_defaultAssetType);
						}
						else
						{
							if(false == _isDefaultAssetNow)
							{
								stopAtLast();
							}
						}
					}
				}
				resourceManager.load(_source, gcable, completeHandler, errorHandler, true, priority);
			}
		}
		
		
		private var _defaultAssetType:int = 4;
		
		/**
		 * 默认资源类型，0女，1男，2怪物,3npc,4默认
		 */
		public function get defaultAssetType():int
		{
			return _defaultAssetType;
		}
		
		/**
		 * @private
		 */
		public function set defaultAssetType(value:int):void
		{
			_defaultAssetType = value;
		}
		
		/**
		 * @private 
		 */		
		override public function isHit(isShape:Boolean=false):Boolean
		{
			if(_isDefaultAssetNow)
			{
				return super.isHit(true);
			}
			return super.isHit(isShape);
		}
		
		/**
		 * 加载成功
		 * @param url
		 */
		private function completeHandler(url:String):void
		{
			if (_source == url)
			{
				var data:* = resourceManager.useResource(_source);
				if (data && (data is MovieClipData))
				{
					movieClipData = data as MovieClipData;
					isStopLast = false;
					_isDefaultAssetNow = false;
					dispatchEvent(new ParamEvent(Event.COMPLETE,{url:_source}));
					if (isAutoPlay)
						play(loopPlay);
				}
			}
		}
		
		/**
		 * 加载资源失败
		 * @param path
		 *
		 */
		private function errorHandler(url:String):void
		{
			if (url == _source)
			{
				//加载默认资源
				if (useDefaultAsset)
				{
					movieClipData = getDefaultMovieClipData(_defaultAssetType);
					_isDefaultAssetNow = true;
				}
			}
		}
		
		public override function resume():void
		{
			super.resume();
			source = _sourceBackup;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function dispose():void
		{
			super.dispose();
			if (movieClipData != null) //先回收引用
				resourceManager.recycleResource(movieClipData);
			if(useDefaultAsset)
				_isDefaultAssetNow = true;
			if (_source != null && _source != "")
				resourceManager.unload(_source);
			_source = null;
		}
	}
}
