package face2wind.view
{	
	
	import face2wind.manager.EventManager;
	import face2wind.manager.FiltersManager;
	import face2wind.manager.ReleaseableManager;
	import face2wind.manager.ToolTipsManager;
	import face2wind.view.item.IReleaseable;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * 基础图形对象
	 * @author face2wind
	 */
	public class BaseSprite extends Sprite implements IReleaseable
	{
		public function BaseSprite()
		{
			super();
		}
		
		/**
		 * 统一事件派发器 
		 */		
		protected var eventManager:EventManager = EventManager.getInstance();
		
		/**
		 * 保存当前窗口宽度
		 * @return
		 */		
		public var _w:Number = 0;
		
		/**
		 * 保存当前窗口高度
		 * @return
		 */		
		public var _h:Number = 0;
		
		/**
		 * 设置窗口宽高
		 * @param newWidth
		 * @param newHeight
		 *
		 */		
		public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			_w = newWidth;
			_h = newHeight;
		}
		
		private var _initialized:Boolean = false;
		
		/**
		 * 是否已初始化 （是否已createChilden）
		 */		
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		//		/**
		//		 * 此对象上一次被移除的时间戳<br/>
		//		 * 用于在适当时间之后自动释放资源<br/>
		//		 * 用getTimer()获取
		//		 */		
		//		public var lastBeenRemoveTime:int;
		
		private var _isOnshow:Boolean = false;
		/**
		 * 是否处于被显示状态（被最底层容器直接或间接包含） <br/>
		 * set方法会递归设置所有子对象
		 */
		public function get isOnshow():Boolean
		{
			return _isOnshow;
		}
		/**
		 * @private
		 */
		public function set isOnshow(value:Boolean):void
		{
			_isOnshow = value;
			var num:int = numChildren;
			var childObj:BaseSprite = null;
			for (var i:int = 0; i < num; i++) 
			{
				childObj = getChildAt(i) as BaseSprite;
				if(null != childObj)
				{
					childObj.isOnshow = value;
				}
			}
		}
		
		private var _preFilterForFade:Array = [];
		private var _fade:Boolean = false;
		/**
		 * 是否变灰
		 */
		public function get fade():Boolean
		{
			return _fade;
		}
		/**
		 * @private
		 */
		public function set fade(value:Boolean):void
		{
			//不给重复设置，否则_preFilterForFade就没意义了
			if(value == _fade)
				return;
			
			_fade = value;
			if(value)
			{
				_preFilterForFade = filters;
				filters = FiltersManager.greyFilters;
			}
			else
				filters = _preFilterForFade;
		}
		
		/**
		 * 重写设置滤镜方法，把fade属性考虑进去<br/>如果当前设置了变灰，这个设置不会立刻生效，而是暂时存到 _preFilterForFade
		 * @param value
		 * 
		 */		
		public override function set filters(value:Array):void
		{
			if(fade)
				_preFilterForFade = value;
			else
				super.filters = value;
		}
		
		
		/**
		 * 告诉父类当前有属性改变，要更新界面（若已初始化，则会直接调用update函数，否则等初始化时才调用） 
		 * 
		 */		
		protected function propertyChange():void
		{
			if(initialized)
				update();
		}
		
		/**
		 * 界面由于属性更改而更新的处理函数 
		 * 
		 */		
		protected function update():void
		{
			//留给子类覆盖
		}
		
		
		/**
		 * 根据变量创建或取消tooltip
		 * 
		 */		
		private function resetToolTip():void
		{
			if(!initialized)
				return;
			
			if(null != _toolTipClass) //使用自定义tooltip
				ToolTipsManager.getInstance().setTooltips(this, "", _toolTipClass , _tooltipDataFunc);
			else if("" != _tooltipStr) //使用默认tooltip
				ToolTipsManager.getInstance().setTooltips(this, _tooltipStr);
			else
				ToolTipsManager.getInstance().removeTooltips(this);
		}
		
		private var _tooltipStr:String = "";
		/**
		 * 为此对象加入一个默认背景的tooltip提示 
		 * @param value
		 * 
		 */		
		public function set tooltip(value:String):void
		{
			_tooltipStr = value;
			if(initialized)
				resetToolTip();
		}
		
		private var _toolTipClass:Class = null;
		private var _tooltipDataFunc:Function = null;
		/**
		 * 设置自定义tips视图类的tooltip
		 * @param toolTipClass tooltip视图类
		 * @param tooltipDataFunc 获取toolTipClass所需的数据的函数
		 * 
		 */		
		public function setExtraToolTip(toolTipClass:Class , tooltipDataFunc:Function):void
		{
			_toolTipClass = toolTipClass;
			_tooltipDataFunc = tooltipDataFunc;
			resetToolTip();
		}
		
		/**
		 * 删除tooltip 
		 * 
		 */		
		public function cancelTooltip():void
		{
			_toolTipClass = null;
			_tooltipStr = "";
			resetToolTip();
		}
		
		/**
		 * 此函数是视图的内容初始化函数<br/>
		 * 在被BaseSprite对象Addchild的时候触发一次
		 * 
		 */		
		protected function createChildren():void
		{
			resetToolTip();
		}
		
		/**
		 * 强制初始化对象<br/>
		 * 一般在父对象不是baseSprite时才用这个初始化 
		 * 
		 */		
		public function forceCreateChild():void
		{
			if(!_initialized)
				doInit();
		}
		
		/**
		 * 重写方法，增加初始化判断
		 * @param child
		 * @return 
		 * 
		 */		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			doAddChild(child);
			return child;
		}
		
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			super.addChildAt(child,index);
			doAddChild(child);
			return child;
		}
		
		/**
		 * 做初始化操作，不开放给子类 
		 * 
		 */		
		private function doInit():void
		{
			createChildren();
			_initialized = true;
			update();
		}
		
		/**
		 * 做增加对象操作 
		 * @param child
		 */		
		private function doAddChild(child:DisplayObject):void
		{
			var _child:BaseSprite = child as BaseSprite;
			var _irelease:IReleaseable = child as IReleaseable;
			if(_child)
			{
				_child.isOnshow = isOnshow;
				if( !_child.initialized)
					_child.doInit();
				//自己在显示列表里
				if(isOnshow)
				{
					_child.autoReleaseable = false;
					if(!_child._hasResume)
						_child.resume();
					if(!_child.hasShow)
						_child.onShowHandler()
				}
			}
			else if(_irelease) //处理非BaseSprite的情况
			{
				if(isOnshow) //自己在显示列表里
					_irelease.resume();
				_irelease.onShowHandler();
			}
		}
		
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			super.removeChild(child);
			doRemoveChild(child);
			return child;
		}
		
		public override function removeChildAt(index:int):DisplayObject
		{
			var obj:DisplayObject = super.removeChildAt(index);
			doRemoveChild(obj);
			return obj;
		}
		
		/**
		 * 做移除对象操作 
		 * @param obj
		 */		
		private function doRemoveChild(child:DisplayObject):void
		{
			var _child:BaseSprite = child as BaseSprite;
			if(_child && _child.initialized)
			{
				if(_child.hasShow)
					_child.onHideHandler();
				//此对象在显示列表里，说明子对象从显示到不显示，加入资源回收管理器
				if(isOnshow )
					_child.autoReleaseable = true;
			}
			else if(child is IReleaseable) //处理非BaseSprite的情况
			{
				(child as IReleaseable).onHideHandler();
				if(isOnshow) //自己在显示列表里
					(child as IReleaseable).dispose();
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
		 * 重设大小
		 * @param xpos
		 * @param ypos
		 * 
		 */		
		public function resize(w:Number , h:Number):void
		{
			width = w;
			height = h;
		}
		
		/**
		 *  删除所有子对象
		 * 
		 */		
		public function removeAllChildren():void
		{
			while(0 < numChildren)
				this.removeChildAt(0);
		}
		
		private var _hasResume:Boolean = false;
		/**
		 * dispose后是否已经resume过了，当前是否处于resume后的状态<br/>
		 * 用于控制不能连续resume或dispose 
		 */
		public function get hasResume():Boolean
		{
			return _hasResume;
		}
		
		private var _hasShow:Boolean = false;
		/**
		 * onHideHandler后是否已经onShowHandler过了，当前是否处于onShowHandler后的状态<br/>
		 * 用于控制不能连续onShowHandler或onHideHandler 
		 */
		public function get hasShow():Boolean
		{
			return _hasShow;
		}
		
		private var _lockReleaseble:Boolean = false;
		/**
		 * 是否锁住的资源释放和恢复的操作 
		 */
		public function get lockReleaseble():Boolean
		{
			return _lockReleaseble;
		}
		/**
		 * @private
		 */
		public function set lockReleaseble(value:Boolean):void
		{
			_lockReleaseble = value;
		}
		
		/**
		 * 注册自动释放管理器，一段时间后释放本身的资源<br/>
		 * （反注册会递归到子孙节点，防止出现BUG:<br/>
		 *  一个对象被addchild，注册了releaseable，父容器被移除，此对象没有反注册releaseable） 
		 * @param value
		 */		
		private function set autoReleaseable(value:Boolean):void
		{
			if(value)
			{
				ReleaseableManager.getInstence().addItem(this);
			}
			else
			{
				ReleaseableManager.getInstence().removeItem(this);
				var num:int = numChildren;
				var childObj:BaseSprite = null;
				for (var i:int = 0; i < num; i++) 
				{
					childObj = getChildAt(i) as BaseSprite;
					if(null != childObj)
						childObj.autoReleaseable = false;
				}
			}
		}
		
		/**
		 * 被加到显示列表时执行 
		 */		
		public function onShowHandler():void
		{
			if(hasShow)
				return;
			
			_hasShow = true;
			var num:int = numChildren;
			var childObj:IReleaseable = null;
			for (var i:int = 0; i < num; i++) 
			{
				childObj = getChildAt(i) as IReleaseable;
				if(null != childObj)
					childObj.onShowHandler();
			}
		}
		
		/**
		 * 从显示列表移除时执行 
		 */		
		public function onHideHandler():void
		{
			if(!hasShow)
				return;
			
			_hasShow = false;
			var num:int = numChildren;
			var childObj:IReleaseable = null;
			for (var i:int = 0; i < num; i++) 
			{
				childObj = getChildAt(i) as IReleaseable;
				if(null != childObj)
					childObj.onHideHandler();
			}
		}
		
		/**
		 * 恢复资源<br/>
		 * 迭代调用所有此对象的子对象的resume函数 
		 * 
		 */		
		public function resume():void
		{
			if(lockReleaseble)
				return;
			if(_hasResume)
				return;
			
			_hasResume = true;
			var num:int = numChildren;
			var childObj:IReleaseable = null;
			for (var i:int = 0; i < num; i++) 
			{
				childObj = getChildAt(i) as IReleaseable;
				if(null != childObj)
					childObj.resume();
			}
			resetToolTip();
		}
		
		
		/**
		 * 释放资源<br/>
		 * 迭代调用所有此对象的子对象的dispose函数 
		 * 
		 */	
		public function dispose():void
		{
			if(lockReleaseble)
				return;
			if(!_hasResume)
				return;
			
			_hasResume = false;
			var num:int = numChildren;
			var childObj:IReleaseable = null;
			for (var i:int = 0; i < num; i++) 
			{
				childObj = getChildAt(i) as IReleaseable;
				if(null != childObj)
					childObj.dispose();
			}
			ToolTipsManager.getInstance().removeTooltips(this);
		}
	}
}
