package face2wind.uiComponents
{
	
	import face2wind.view.BaseSprite;
	
	import flash.events.Event;
	
	/**
	 * 图片对象，基于ResBitmap的组合实现，可接收鼠标事件
	 * @author face2wind
	 */
	public class ResImage extends BaseSprite
	{
		
		/**
		 * 存放图片的实体
		 */		
		protected var resbm:ResBitmap;
		
		/**
		 * ResImage构造函数
		 * @param source        路径源
		 * @param cacheable     是否缓存
		 * @param priority      加载优先级
		 *
		 */
		public function ResImage(_nsource:* = null, _cacheable:Boolean = true, _priority:int = 15)
		{
			_source = _nsource;
			cacheable = _cacheable;
			priority = _priority;
			resbm = new ResBitmap(_source , cacheable , priority);
			resbm.addEventListener(Event.COMPLETE , loadCompleteHandler);
		}
		
		/**
		 * 是否缓存 
		 */		
		private var cacheable:Boolean;
		
		/**
		 * 加载优先级 
		 */		
		private var priority:int;
		
		private var _source:String;
		/**
		 * 图片素材路径（绝对路径，或者swf中的类名）
		 */
		public function set source(value:String):void
		{
			_source = value;
			if(initialized)
				resbm.source = value;
		}
		
		public function get source():String
		{
			return _source;
		}
		
		/**
		 * 加载成功，把resbitmap加载成功的事件抛出去
		 * @param url
		 */
		protected function loadCompleteHandler(e:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * 等比缩放，尽量满屏，并且不超出屏幕 
		 * @param _width
		 * @param _width
		 */		
		public function scaleFixToWidthAndHeight(_width:Number = 0,_height:Number = 0):void
		{
			resbm.scaleFixToWidthAndHeight(_width,_height);
		}
		
		/**
		 * 等比缩放到指定宽度 
		 * @param _width
		 * 
		 */		
		public function scaleToWidth(_width:Number):void
		{
			resbm.scaleToWidth(_width);
		}
		
		/**
		 * 等比缩放到指定宽度 
		 * @param _width
		 * 
		 */		
		public function scaleToHeight(_height:Number):void
		{
			resbm.scaleToHeight(_height);
		}
		
		/**
		 * 重设resbitmap实体宽高 
		 * @param w
		 * @param h
		 * 
		 */		
		public function resetBmSize(w:Number, h:Number):void
		{
			resbm.resize(w,h);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			resbm.source = _source;
			addChild(resbm);
		}
		
		
		/**
		 * 重写高度设置（素材为加载则暂高度度值，等加载完毕再设置） <br/>
		 * 此属性和缩放属性是互斥，设置了这个，缩放属性会失效
		 * @param value
		 * 
		 */		
		public override function get width():Number
		{
			if(resbm)
				return resbm.width;
			else
				return 0;
		}
		
		
		/**
		 * 重写高度设置（素材为加载则暂高度度值，等加载完毕再设置） <br/>
		 * 此属性和缩放属性是互斥，设置了这个，缩放属性会失效
		 * @param value
		 * 
		 */		
		public override function get height():Number
		{
			if(resbm)
				return resbm.width;
			else
				return 0;
		}
		
		/**
		 * 恢复资源
		 */		
		public override function resume():void
		{
			super.resume();
//			resbm.addEventListener(Event.COMPLETE , loadCompleteHandler);
//			resbm.resume();
		}
		
		/**
		 * 释放
		 */
		public override function dispose():void
		{
			super.dispose();
//			resbm.removeEventListener(Event.COMPLETE , loadCompleteHandler);
//			resbm.dispose();
		}
	}
}


