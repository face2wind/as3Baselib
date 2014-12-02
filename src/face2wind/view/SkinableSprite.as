package face2wind.view
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import face2wind.lib.Debuger;
	import face2wind.lib.ObjectPool;
	import face2wind.lib.Reflection;
	import face2wind.manager.EnterFrameUtil;
	import face2wind.manager.FiltersManager;
	import face2wind.uiComponents.ResBitmap;
	
	/**
	 * 可设置皮肤的基础视图对象类<br/>
	 * 默认会监听部分鼠标事件（用于改变显示的皮肤）
	 * @author face2wind
	 */
	public class SkinableSprite extends BaseSprite
	{
		/**
		 * 普通状态的皮肤 （鼠标移走、鼠标弹起时会恢复到普通状态皮肤）
		 */		
		public static var NORMAL_SKIN:String = "SkinableSprite_NORMAL_SKIN";
		
		/**
		 * 鼠标按下时的皮肤
		 */		
		public static var MOUSE_DOWN_SKIN:String = "SkinableSprite_MOUSE_DOWN_SKIN";
		
		/**
		 * 鼠标移上来时的皮肤
		 */		
		public static var MOUSE_OVER_SKIN:String = "SkinableSprite_MOUSE_OVER_SKIN";
		
		/**
		 * desable状态下的皮肤
		 */		
		public static var DISABLE_SKIN:String = "SkinableSprite_DISABLE_SKIN";
		
		/**
		 * 当前正在显示的对象引用
		 * @return
		 *
		 */		
		private var curOnShowObj:DisplayObject;
		
		/**
		 * 底层，用于加载背景
		 */		
		protected var bgLayer:BaseSprite;
		
		/**
		 * 中间层，用于加入其他对象
		 */		
		protected var otherLayer:BaseSprite;
		
		/**
		 * 最顶层，用于获取事件
		 */		
		private var topLayer:BaseSprite;
		
		public function SkinableSprite()
		{
			super();
			skinCacheDic = new Dictionary();
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			bgLayer = new BaseSprite();
			addChild(bgLayer);
			otherLayer = new BaseSprite();
			addChild(otherLayer);
			topLayer = new BaseSprite();
			topLayer.alpha = 0;
			addChild(topLayer);
			
			skinsDic = new Dictionary();
			
			hasCacheSkin = true;
		}
		
		protected function onMouseDownHandler(event:MouseEvent):void
		{
			EnterFrameUtil.delayCall(1,function():void //下帧渲染，防止其他事件监听不成功
			{
				if(_disable) //对象灰掉了，不再处理变更
					return;
				if(_lockSkin) //对象被锁定皮肤了，不处理
					return;
				var obj:DisplayObject = skinsDic[SkinableSprite.MOUSE_DOWN_SKIN];
				if(obj && obj != curOnShowObj)
				{
					if(curOnShowObj && contains(curOnShowObj))
						bgLayer.removeChild(curOnShowObj);
					curOnShowObj = obj;
					bgLayer.addChild(obj);
				}
			});
		}
		
		protected function onMouseUpHandler(event:MouseEvent):void
		{
			EnterFrameUtil.delayCall(1,function():void //下帧渲染，防止其他事件监听不成功
			{
				if(_disable) //对象灰掉了，不再处理变更
					return;
				if(_lockSkin) //对象被锁定皮肤了，不处理
					return;
				
				var obj:DisplayObject = skinsDic[SkinableSprite.NORMAL_SKIN];
				if(obj && obj != curOnShowObj)
				{
					if(curOnShowObj && contains(curOnShowObj))
						bgLayer.removeChild(curOnShowObj);
					curOnShowObj = obj;
					bgLayer.addChild(obj);
				}
			});
		}
		
		protected function onMouseOverHandler(event:MouseEvent):void
		{
			EnterFrameUtil.delayCall(1,function():void //下帧渲染，防止其他事件监听不成功
			{
				if(_disable) //对象灰掉了，不再处理变更
					return;
				if(_lockSkin) //对象被锁定皮肤了，不处理
					return;
				
				var obj:DisplayObject = skinsDic[SkinableSprite.MOUSE_OVER_SKIN];
				if(obj && obj != curOnShowObj)
				{
					if(curOnShowObj && contains(curOnShowObj))
						bgLayer.removeChild(curOnShowObj);
					curOnShowObj = obj;
					bgLayer.addChild(obj);
				}
			});
		}
		
		protected function onMouseOutHandler(event:MouseEvent):void
		{
			EnterFrameUtil.delayCall(1,function():void //下帧渲染，防止其他事件监听不成功
			{
				if(_disable) //对象灰掉了，不再处理变更
					return;
				if(_lockSkin) //对象被锁定皮肤了，不处理
					return;
				
				var obj:DisplayObject = skinsDic[SkinableSprite.NORMAL_SKIN];
				if(obj && obj != curOnShowObj)
				{
					if(curOnShowObj && contains(curOnShowObj))
						bgLayer.removeChild(curOnShowObj);
					curOnShowObj = obj;
					bgLayer.addChild(obj);
				}
			});
		}
		
		/**
		 * 存放皮肤的字典
		 */		
		private var skinsDic:Dictionary;
		
		/**
		 * 皮肤对应的值，缓存字典（用于未初始化前设置皮肤的保存，初始化时再设置） 
		 */		
		private var skinCacheDic:Dictionary;
		
		/**
		 * 设置皮肤
		 * @param type 类型（普通，鼠标划过，鼠标按下，等等）
		 * @param value 对应的皮肤，可以是显示对象，类或者素材对应的字符串（素材路径或者导出类）
		 *
		 */		
		public function setSkin(type:String, value:* = null):void
		{
			if(!initialized)
			{
				skinCacheDic[type] = value;
				return;
			}
			if(null == value)
			{
				delete skinsDic[type];				
				return;
			}
			var curShowing:Boolean = false; //当前要设置的皮肤是否正在显示
			var oldObj:DisplayObject = skinsDic[type];
			if(oldObj && contains(oldObj))//若当前正在显示，则移除
			{
				curShowing = true;
				bgLayer.removeChild(oldObj);
				ObjectPool.disposeObject(oldObj);
			}
			
			if(value is DisplayObject)
			{
				skinsDic[type] = value;
			}
			else if(value is Class)
			{
				var cls:Class = value as Class;
				skinsDic[type] = ObjectPool.getObject(cls);
				
				//发现new出来的不是可视对象，则删除
				if(!(skinsDic[type] is DisplayObject))
					delete skinsDic[type];
			}
			else if(value is String)//根据反射或动态素材加载
			{
				var resPath:String = value as String;
				var bm:ResBitmap;
				if(resPath.indexOf("/") != -1) //有详细路径，是动态加载素材
				{
					bm = ObjectPool.getObject(ResBitmap);
					bm.source = value as String;
					skinsDic[type] = bm;
				}
				else
				{
					var reflectionObj:* = Reflection.createDisplayObjInstance(resPath);
					if(null != reflectionObj)
						skinsDic[type] = reflectionObj;
				}
			}
			else
			{
				Debuger.show(Debuger.BASE_LIB , "SkinableSprite.setSkin get a illegal param");
				return;
			}
			
			//当前在设置普通背景，则修改标记位，把普通背景加进来
			if(SkinableSprite.NORMAL_SKIN == type) 
				curShowing = true;
			if(curShowing && skinsDic[type])
			{
				curOnShowObj = skinsDic[type];
				bgLayer.addChild(skinsDic[type]);
			}
		}
		
		/**
		 * 锁定到某个皮肤 
		 * @param skin
		 * 
		 */		
		public function lockOnSkin(skin:String):void
		{
			if(_disable) //对象灰掉了，不再处理变更
				return;
			
			var obj:DisplayObject = skinsDic[skin];
			if(obj)
			{
				_lockSkin = true;
				if(curOnShowObj && contains(curOnShowObj))
					bgLayer.removeChild(curOnShowObj);
				curOnShowObj = obj;
				bgLayer.addChild(obj);
			}
		}
		
		/**
		 * 恢复锁定的皮肤 
		 */		
		public function unlockSkin():void
		{
			_lockSkin = false;
			var obj:DisplayObject = skinsDic[SkinableSprite.NORMAL_SKIN];
			if(obj && obj != curOnShowObj)
			{
				if(curOnShowObj && contains(curOnShowObj))
					bgLayer.removeChild(curOnShowObj);
				curOnShowObj = obj;
				bgLayer.addChild(obj);
			}
		}
		
		protected var _width:Number = 0;
		public override function set width(value:Number):void
		{
			if(_width == value)
				return;
			
			_width = value;
			widthChange = true;
			propertyChange();
		}
		
		protected var _height:Number = 0;
		public override function set height(value:Number):void
		{
			if(_height == value)
				return;
			
			_height = value;
			heightChange = true;
			propertyChange();
		}
		
		protected override function update():void
		{
			super.update();
			var obj:DisplayObject;
			if(hasCacheSkin) //初始化时才执行一次
			{
				for (var type:String in skinCacheDic) 
				{
					setSkin(type, skinCacheDic[type]);
					delete skinCacheDic[type];
				}
				if(0 == _width)
					_width = width;
				if(0 == _height)
					_height = height;
				hasCacheSkin = false;
			}
			if(heightChange)
			{
				updateTopLayer();
				obj = skinsDic[SkinableSprite.NORMAL_SKIN];
				if(obj)
					obj.height = _height;
				obj = skinsDic[SkinableSprite.MOUSE_DOWN_SKIN];
				if(obj)
					obj.height = _height;
				obj = skinsDic[SkinableSprite.MOUSE_OVER_SKIN];
				if(obj)
					obj.height = _height;
				obj = skinsDic[SkinableSprite.DISABLE_SKIN];
				if(obj)
					obj.height = _height;
				//				super.height = _height;
				heightChange = false;
			}
			if(widthChange)
			{
				updateTopLayer();
				obj = skinsDic[SkinableSprite.NORMAL_SKIN];
				if(obj)
					obj.width = _width;
				obj = skinsDic[SkinableSprite.MOUSE_DOWN_SKIN];
				if(obj)
					obj.width = _width;
				obj = skinsDic[SkinableSprite.MOUSE_OVER_SKIN];
				if(obj)
					obj.width = _width;
				obj = skinsDic[SkinableSprite.DISABLE_SKIN];
				if(obj)
					obj.width = _width;
				//				super.width = _width;
				widthChange = false;
			}
		}
		
		/**
		 * 重绘事件获取区
		 *
		 */		
		private function updateTopLayer():void
		{
			topLayer.graphics.clear();
			topLayer.graphics.beginFill(0xffffff);
			topLayer.graphics.drawRect(0,0, _width,_height);
			topLayer.graphics.endFill();
		}
		
		protected var _disable:Boolean = false;
		
		/**
		 * 是否不可用状态（只是灰掉素材，响应事件的移除外面控制）
		 * @return
		 *
		 */
		public function get disable():Boolean
		{
			return _disable;
		}
		
		public function set disable(value:Boolean):void
		{
			if(_disable == value)
				return;
			
			_disable = value;
			mouseEnabled = !value;
			mouseChildren = !value;
			var disableSkin:DisplayObject = skinsDic[SkinableSprite.DISABLE_SKIN];
			var normalSkin:DisplayObject = skinsDic[SkinableSprite.NORMAL_SKIN];
			var mDownSkin:DisplayObject = skinsDic[SkinableSprite.MOUSE_DOWN_SKIN];
			var mUpSkin:DisplayObject = skinsDic[SkinableSprite.MOUSE_OVER_SKIN];
			if(_disable)
			{
				if(disableSkin)
				{
					if(curOnShowObj && contains(curOnShowObj))
						bgLayer.removeChild(curOnShowObj);
					bgLayer.addChild(disableSkin);
				}
				else
				{
					if(normalSkin)
						normalSkin.filters = [FiltersManager.grayColorMatrixFilter];
					if(mDownSkin)
						mDownSkin.filters = [FiltersManager.grayColorMatrixFilter];
					if(mUpSkin)
						mUpSkin.filters = [FiltersManager.grayColorMatrixFilter];
					//					if(null != curOnShowObj)
					//						curOnShowObj.filters = [FiltersManager.grayColorMatrixFilter];
				}
			}
			else
			{
				if(disableSkin)
				{
					if(contains(disableSkin))
						bgLayer.removeChild(disableSkin);
					bgLayer.addChild(curOnShowObj);
				}
				else
				{
					if(normalSkin)
						normalSkin.filters = [];
					if(mDownSkin)
						mDownSkin.filters = [];
					if(mUpSkin)
						mUpSkin.filters = [];
					//					if(null != curOnShowObj)
					//						curOnShowObj.filters = [];
				}
			}
		}
		
		/**
		 * 高度改变 
		 */		
		private var heightChange:Boolean = false;
		/**
		 * 宽度改变 
		 */		
		private var widthChange:Boolean = false;
		private var hasCacheSkin:Boolean;
		
		/**
		 * 锁定某个皮肤 
		 */		
		private var _lockSkin:Boolean = false;
		
		/**
		 * 被加到显示列表时执行 
		 */		
		public override function onShowHandler():void
		{
			super.onShowHandler();
			addEventListener( MouseEvent.MOUSE_DOWN , onMouseDownHandler);
			addEventListener( MouseEvent.MOUSE_UP , onMouseUpHandler);
			addEventListener( MouseEvent.MOUSE_OVER , onMouseOverHandler);
			addEventListener( MouseEvent.MOUSE_OUT , onMouseOutHandler);
		}
		
		/**
		 * 从显示列表移除时执行 
		 */		
		public override function onHideHandler():void
		{
			super.onHideHandler();
			removeEventListener( MouseEvent.MOUSE_DOWN , onMouseDownHandler);
			removeEventListener( MouseEvent.MOUSE_UP , onMouseUpHandler);
			removeEventListener( MouseEvent.MOUSE_OVER , onMouseOverHandler);
			removeEventListener( MouseEvent.MOUSE_OUT , onMouseOutHandler);
		}
	}
}


