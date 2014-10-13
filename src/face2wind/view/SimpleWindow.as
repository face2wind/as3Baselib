package face2wind.view
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import face2wind.lib.Reflection;
	import face2wind.manager.StageManager;
	import face2wind.view.BaseWindow;
	
	/**
	 * 基础窗口，没有皮肤，但包含窗口应有的接口
	 * @author face2wind
	 */
	public class SimpleWindow extends BaseWindow
	{
		private var _coverBg:Shape;
		
		/**
		 * 用于遮挡后面所有控件的背景
		 */
		public function get coverBg():Shape
		{
			if(null == _coverBg)
			{
				_coverBg = new Shape();
				_coverBg.cacheAsBitmap = true;
			}
			return _coverBg;
		}
		/**
		 * @private
		 */
		public function set coverBg(value:Shape):void
		{
			_coverBg = value;
		}
		
		
		public function SimpleWindow()
		{
			super();
//			x = 100;
//			y = 100;
		}
		
		/**
		 * 拖动范围 用矩形来约束
		 */
		private var _dragRect:Rectangle;
		

		
		/**
		 * 拖动对象（完全透明）
		 */		
		protected var dragSp:Sprite;
		
		private var _canDraging:Boolean = true;
		/**
		 * 是否能拖动
		 */
		public function get canDraging():Boolean
		{
			return _canDraging;
		}
		/**
		 * @private
		 */
		public function set canDraging(value:Boolean):void
		{
			_canDraging = value;
		}
		
		private var _hasCoverBg:Boolean
		
		/**
		 *是否有遮挡层
		 * @return
		 *
		 */
		public function get hasCoverBg():Boolean
		{
			return _hasCoverBg;
		}
		
		public function set hasCoverBg(value:Boolean):void
		{
			_hasCoverBg = value;
			if(value)
			{
				addChildAt(coverBg,0);		
				StageManager.getInstance().addStageResizeFunc(onStageResizeHandler,true);
			}
			else
			{
				StageManager.getInstance().removeStageResizeFunc(onStageResizeHandler);
				if(this.contains(coverBg))
					this.removeChild(coverBg);
			}
		
		}
		
		
		/**
		 * 设置窗口宽高
		 * @param newWidth
		 * @param newHeight
		 *
		 */		
		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			_w = newWidth;
			_h = newHeight;
			
			drawWindow();
		}
		
		/**
		 * 调整窗口各控件大小
		 *
		 */		
		protected function drawWindow():void
		{
			if(!initialized)
				return;
			
			dragSp.cacheAsBitmap = false;
			
			dragSp.y = 0;
			dragSp.graphics.clear();
			dragSp.graphics.beginFill(0xffffff);
			dragSp.graphics.drawRect(0,0,_w, dragSpHeight);
			dragSp.graphics.endFill();
			
			dragSp.cacheAsBitmap = true;
			
			//重设层关系
			var curIndex:int = numChildren-1;
			if(closeBtn && contains(closeBtn))
				setChildIndex(closeBtn, curIndex--);
			setChildIndex(dragSp, curIndex);
		}
		
		/**
		 * 此函数是视图的内容初始化函数<br/>对父类的覆盖
		 *
		 */		
		protected override function createChildren():void
		{
			super.createChildren();
			
			var sw:Number = StageManager.getInstance().stageWidth;
			var sh:Number = StageManager.getInstance().stageHeight;
			
			_dragRect=new Rectangle();
			_dragRect.width = sw - width;
			_dragRect.height = sh - height + 5;
			
			dragSp = new Sprite();
			dragSp.alpha = 0;
			addChild(dragSp);
			
			cacheList.push(dragSp);
		}
		
		private var _hasCloseBtn:Boolean = true;
		
		/**
		 * 是否有关闭按钮
		 */
		public function get hasCloseBtn():Boolean
		{
			return _hasCloseBtn;
		}
		
		/**
		 * 关闭按钮
		 */		
		protected var closeBtn:*;
		
		/**
		 * 拖动区域的高度
		 */		
		protected var dragSpHeight:Number = 33;
		
		/**
		 * 需要动态设置cacheAsBitmap的对象列表，子类可以把需要动态设置的对象放进来<br/>
		 * 在静止状态下置true，拖动窗口时置false
		 */		
		protected var cacheList:Array = [];
		
		/**
		 * @private
		 */
		public function set hasCloseBtn(value:Boolean):void
		{
			_hasCloseBtn = value;
			if(null == closeBtn)
				return;
			if(true == _hasCloseBtn )
			{
				if(null == closeBtn)
					closeBtn = Reflection.createSimpleButtonInstance("window_closeButton");
				if(!closeBtn.hasEventListener(MouseEvent.CLICK))
					closeBtn.addEventListener(MouseEvent.CLICK , onCloseWindowHandler);
				this.addChild(closeBtn);
			}
			else
			{
				closeBtn.removeEventListener(MouseEvent.CLICK , onCloseWindowHandler);
				closeBtn.parent.removeChild(closeBtn);
			}
		}
		
		/**
		 * 获取关闭按钮的坐标（BitmapWindow需要用） 
		 * @return 
		 * 
		 */		
		public function getCloseBtnPosition():Point
		{
			return new Point(closeBtn.x,closeBtn.y);
		}
		
		/**
		 * 关闭窗口按钮点击
		 * @param event
		 *
		 */		
		protected function onCloseWindowHandler(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			close();
		}
		
		public override function open():void
		{
			super.open();
			if(hasCoverBg)
			{
				addChildAt(coverBg,0);
				onStageResizeHandler(StageManager.getInstance().stageWidth,StageManager.getInstance().stageHeight);
			}
		}
		
		public override function close():void
		{
			if(hasCoverBg && coverBg&&contains(coverBg))
				removeChild(coverBg);
			super.close();
		}
		
		/**
		 * 当前是否鼠标按下标题（用于延时设置cache bitmap检测） 
		 */		
		private var titleMouseDown:Boolean = false;
		
		protected function onTitleMouseDownHandler(evt:MouseEvent):void
		{
			titleMouseDown = true;
			_dragRect.width = StageManager.getInstance().stageWidth - width;
			_dragRect.height = StageManager.getInstance().stageHeight - height + 5;
//			cacheAsBitmap = false;
//			EnterFrameUtil.delayCall(500,function():void //避免点击事件也触发这个
//			{
//				if(titleMouseDown)
//					allCacheAsBitmap = false;
//			});
			//暂时不做拖拉区域限制
			this.startDrag();
		}
		
		protected function onTitleMouseUpHandler(evt:MouseEvent):void
		{
			titleMouseDown = false;
			this.stopDrag();
			windowManager.refleshBitmapWindows();
//			allCacheAsBitmap = true;
//			cacheAsBitmap = true;
		}
		
		/**
		 * 是否已经初始化过了坐标
		 */		
		private var hasInitPos:Boolean = false;
		
		private var _allCacheAsBitmap:Boolean;
		/**
		 * 设置所有在cacheList列表里的对象的 CacheAsBitmap属性
		 * @return 
		 * 
		 */
		public function get allCacheAsBitmap():Boolean
		{
			return _allCacheAsBitmap;
		}

		public function set allCacheAsBitmap(value:Boolean):void
		{
			_allCacheAsBitmap = value;
			for (var i:int = 0; i < cacheList.length; i++) 
			{
				var sp:DisplayObject = cacheList[i] as DisplayObject;
				sp.cacheAsBitmap = _allCacheAsBitmap;
			}
		}

		
		/**
		 * 初始化坐标
		 *
		 */		
		protected function initPosition():void
		{
			if(hasInitPos)
				return;
			hasInitPos = true;
			var sw:Number = StageManager.getInstance().stageWidth;
			var sh:Number = StageManager.getInstance().stageHeight;
			x =(sw-_w)*0.5;
			y =( sh -_h) *0.5;
		}
		
		/**
		 * 窗口被点击，提升到顶层
		 * @param event
		 *
		 */		
		protected override function onMouseClickHandler(event:MouseEvent):void
		{
			if(event.target != closeBtn) //如果点击到关闭按钮，不做点击提升操作（都要关闭了还提升个鸟）
				super.onMouseClickHandler(event);
		}
		
		/**
		 * 舞台大小改变
		 * @param w
		 * @param h
		 *
		 */		
		private function onStageResizeHandler(w:Number, h:Number):void
		{
			_coverBg.cacheAsBitmap = false;
			coverBg.graphics.clear();
			coverBg.graphics.beginFill(0,0.3);
			coverBg.graphics.drawRect(0,0,w,h);
			coverBg.graphics.endFill();
			coverBg.x = -x;
			coverBg.y = -y;
			_coverBg.cacheAsBitmap = true;
		}
		
		/**
		 * [继承] 恢复资源
		 *
		 */		
		public override function resume():void
		{
			super.resume();
			
			initPosition();
			
			if(true == canDraging){
				dragSp.addEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseDownHandler);
				dragSp.addEventListener(MouseEvent.MOUSE_UP, onTitleMouseUpHandler);
			}
			if(true == hasCloseBtn)
				closeBtn.addEventListener(MouseEvent.CLICK , onCloseWindowHandler);
		}
		
		/**
		 * [继承] 释放资源
		 *
		 */		
		public override function dispose():void
		{
			super.dispose();
			
			if(true == canDraging){
				dragSp.removeEventListener(MouseEvent.MOUSE_DOWN, onTitleMouseDownHandler);
				dragSp.removeEventListener(MouseEvent.MOUSE_UP, onTitleMouseUpHandler);
				if(true == hasCloseBtn)
					closeBtn.removeEventListener(MouseEvent.CLICK , onCloseWindowHandler);
			}
		}
	}
}

