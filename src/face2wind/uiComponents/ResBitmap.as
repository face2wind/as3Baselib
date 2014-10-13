package face2wind.uiComponents
{
	import face2wind.lib.Reflection;
	import face2wind.loading.RuntimeResourceManager;
	import face2wind.view.item.IReleaseable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	

	/**
	 * 图片对象，支持绝对路径素材加载或者用类名去反射bitmapData<br/>
	 * 不支持鼠标事件
	 * @author face2wind
	 */
	public class ResBitmap extends Bitmap implements IReleaseable
	{

		/**
		 *  运行时资源管理器引用
		 */
		private static var resourceManager:RuntimeResourceManager = RuntimeResourceManager.getInstance();

		public function ResBitmap(source:* = null, cacheable:Boolean = true, priority:int = 15)
		{
			super(null, "auto", false);
			this.cacheable = cacheable;
			this.priority = priority;
			this.source = source;
		}

		/**
		 * 加载优先级
		 */
		public var priority:int;

		/**
		 * 是否缓存
		 */
		public var cacheable:Boolean;

		/**
		 * 备份资源路径，用于资源释放后恢复 
		 */		
		private var _sourceBackup:String;
		private var _source:String;
		/**
		 * 图片素材路径（绝对路径，或者swf中的类名）
		 */
		public function get source():String
		{
			return _source;
		}
		/**
		 * @private
		 */
		public function set source(value:String):void
		{
			if (_source == value)
				return;
			if (_source != null && _source != "")
			{
				// 卸载可能未开始加载的资源
				resourceManager.unload(_source);
			}
			if (value != null && value != "")
			{
				var path:String = value;
				_source = path;
				bitmapData = null;
				//默认判断没有'/'符号则是从反射中获取素材，有'/'符号则用加载器加载
				if(-1 == path.indexOf("\/"))
				{
					bitmapData = Reflection.createBitmapDataInstance(path);
					dispatchEvent(new Event(Event.COMPLETE));
				}
				else
				{
					if (resourceManager.hasResource(path))
					{
						bitmapData = resourceManager.useResource(path);
						dispatchEvent(new Event(Event.COMPLETE));
					}
					else
					{
						resourceManager.load(path, cacheable, loadCompleteHandler, null, false, priority);
					}
				}
			}
			else
			{
				_source = null;
				bitmapData = null;
			}
		}
		
		/**
		 * 缩放到的宽度（0表示不做缩放） 
		 */		
		private var targetWidth:Number = 0;
		
		/**
		 * 缩放到的高度（0表示不做缩放） 
		 */		
		private var targetHeight:Number = 0;
		
		/**
		 * 当前是否等比缩放<br/>（决定targetWidth，和targetHeight的用法） 
		 */		
		private var isEqualResize:Boolean = false;
		
		/**
		 * @private
		 */
		override public function set bitmapData(value:BitmapData):void
		{
			if (super.bitmapData == value)
				return;
			if (super.bitmapData != null)
			{
				//将之前引用的图片计数-1
				resourceManager.recycleResource(super.bitmapData);
			}
			super.bitmapData = value;
			if (super.bitmapData != null)
			{
				resizeWithScale();
			}
		}

		/**
		 * 加载成功
		 * @param url
		 */
		private function loadCompleteHandler(url:String):void
		{
			if (_source == url)
			{
				bitmapData = resourceManager.useResource(_source);
				resizeWithScale();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * 移动坐标 
		 * @param xpos
		 * @param ypos
		 * 
		 */		
		public function move(xpos:Number , ypos:Number):void
		{
			x = xpos;
			y = ypos;
		}
		
		/**
		 * 等比缩放到指定宽度 
		 * @param _width
		 * 
		 */		
		public function scaleToWidth(_width:Number):void
		{
			isEqualResize = true;
			targetWidth = _width;
			targetHeight = 0; //缩放模式，同时只能有一个目标长宽属性
			
			resizeWithScale();
		}
		
		/**
		 * 等比缩放到指定宽度 
		 * @param _width
		 * 
		 */		
		public function scaleToHeight(_height:Number):void
		{
			isEqualResize = true;
			targetWidth = 0; //缩放模式，同时只能有一个目标长宽属性
			targetHeight = _height;
			
			resizeWithScale();
		}
		
		/**
		 * 重写宽度设置（素材为加载则暂存宽度值，等加载完毕再设置）<br/>
		 * 此属性和缩放属性是互斥，设置了这个，缩放属性会失效
		 * @param value
		 * 
		 */		
		public override function set width(value:Number):void
		{
			isEqualResize = false;
			if(null == bitmapData) //素材还没加载，先存着数据，加载完再还原
				targetWidth = value;
			else
				super.width = value;
		}
		
		/**
		 * 重写高度设置（素材为加载则暂高度度值，等加载完毕再设置） <br/>
		 * 此属性和缩放属性是互斥，设置了这个，缩放属性会失效
		 * @param value
		 * 
		 */		
		public override function set height(value:Number):void
		{
			isEqualResize = false;
			if(null == bitmapData) //素材还没加载，先存着数据，加载完再还原
				targetHeight = value;
			else
				super.height = value;
		}
		
		/**
		 * 根据缩放参数重设大小 
		 */		
		private function resizeWithScale():void
		{
			if(null == bitmapData)
				return;
			
			var bmW:Number = super.bitmapData.width;
			var bmH:Number = super.bitmapData.height;
			if(isEqualResize)
			{
				var rate:Number = -1;
				if(0 < targetWidth)
					rate = targetWidth/bmW;
				if(0 < targetHeight)
					rate = targetHeight/bmH;
				if(0 < rate)
				{
					width = bmW*rate;
					height = bmH*rate;
				}
			}
			else
			{
				if(0 < targetWidth)
					width = targetWidth;
				else
					width = bmW;
				if(0 < targetHeight)
					height = targetHeight;
				else
					height = bmH;
			}
		}
		
		/**
		 * 重设宽高大小（不管有没有加载到素材） 
		 * @param w
		 * @param h
		 * 
		 */		
		public function resize(w:Number , h:Number):void
		{
			isEqualResize = false;
			
			targetWidth = w;
			targetHeight = h;
			
			resizeWithScale();
		}
		
		/**
		 * 被加到显示列表时执行  
		 */		
		public function onHideHandler():void
		{
		}
		
		/**
		 * 从显示列表移除时执行  
		 */			
		public function onShowHandler():void
		{
		}
		
		public function resume():void
		{
			if(null != _sourceBackup)
				source = _sourceBackup;
		}

		/**
		 * 释放
		 */
		public function dispose():void
		{
			if(null != _source && "" != _source)
				_sourceBackup = _source;
			source = null;
		}
	}
}
