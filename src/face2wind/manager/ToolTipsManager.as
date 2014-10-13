package face2wind.manager
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import face2wind.enum.LayerEnum;
	import face2wind.view.BaseSprite;
	import face2wind.view.item.IToolTipsView;
	import face2wind.view.item.ToolTipDefaultView;
	
	/**
	 * 对象tips管理器
	 * @author face2wind
	 */
	public class ToolTipsManager
	{
		public function ToolTipsManager()
		{
			if(instance)
				throw new Error("ToolTipsManager is singleton class and allready exists!");
			
			instance = this;
			
			tooltipDic = new Dictionary();
			viewClassDic = new Dictionary();
			layer = LayerManager.getInstance().getLayer(LayerEnum.MSG_LAYER);
			defTipsView = new ToolTipDefaultView();
		}
		
		/**
		 * 存储所有tooltip对象的字典
		 */		
		private var tooltipDic:Dictionary;
		
		/**
		 * 函数字典
		 */		
		private var viewClassDic:Dictionary;
		
		/**
		 * 单例
		 */
		private static var instance:ToolTipsManager;
		/**
		 * 获取单例
		 */
		public static function getInstance():ToolTipsManager
		{
			if(!instance)
				instance = new ToolTipsManager();
			
			return instance;
		}
		
		/**
		 * tips显示所在的层
		 */		
		private var layer:BaseSprite;
		
		/**
		 * 默认tips显示对象
		 */		
		private var defTipsView:ToolTipDefaultView;
		
		/**
		 * 记录当前鼠标进去的对象 
		 */		
		private var curMouseInObj:DisplayObject = null;
		
		/**
		 * 为一个显示对象增加一个tooltip<br/>
		 * 若tipsclass为空，则使用默认的tips外观，内容为tips变量内容 <br/>
		 * 若tipsclass非空，则使用tipsclass对应的类做tips外观，getDataFunc函数获取tips类对应所需数据（此时会忽视tips变量内容）
		 * @param obj 目标对象
		 * @param tips 简单tips文字内容
		 * @param tipsClass 指定的tips显示类
		 * @param getDataFunc 提供tips显示类所需数据的函数
		 *
		 */		
		public function setTooltips(obj:DisplayObject , tips:String , tipsClass:Class = null, getDataFunc:Function = null):void
		{
			if(null == obj)
				return;
			if( (null == tips || "" == tips) && (null == tipsClass) )
				return;
			
			if(null == tooltipDic[obj])
			{
				obj.addEventListener(MouseEvent.MOUSE_OVER , onObjMouseOverHandler);
				obj.addEventListener(MouseEvent.MOUSE_OUT , onObjMouseOutHandler);
			}
			else //已有tips对象了，更新一下里面的tips内容
			{
				if(null == tipsClass && curMouseInObj == obj) //用的是普通tips
				{
					defTipsView.htmlText = tips;
					resetTipsViewPosition(defTipsView);
				}
				else
				{
					var tipsView:BaseSprite = viewClassDic[tipsClass];
					if(null != tipsView && //已经创建过这个对象才重设一下数据
						curMouseInObj == obj) 
					{
						if(null != tipsView && null != getDataFunc)
							(tipsView as IToolTipsView).data = getDataFunc.call(null,obj);
						resetTipsViewPosition(tipsView);
					}
				}
			}
			tooltipDic[obj] = {tipsStr:tips , tipsClass:tipsClass , dataFunc:getDataFunc};
		}
		
		/**
		 * 移除一个对象的tooltip所有相关内容
		 * @param obj 目标对象
		 *
		 */		
		public function removeTooltips(obj:DisplayObject):void
		{
			if(null != tooltipDic[obj])
			{
				obj.removeEventListener(MouseEvent.MOUSE_OVER , onObjMouseOverHandler);
				obj.removeEventListener(MouseEvent.MOUSE_OUT , onObjMouseOutHandler);
				if(null != tooltipDic[obj].tipsClass)
				{
					var tipsView:BaseSprite = getTipsView(tooltipDic[obj].tipsClass);
					if(tipsView && layer.contains(tipsView))
						layer.removeChild(tipsView);
				}
				delete tooltipDic[obj];
			}
		}
		
		/**
		 * 获取tips类对应的实例对象（相同tips类对应的实体只有一个）
		 * @param cls
		 * @return
		 *
		 */		
		private function getTipsView(cls:Class):BaseSprite
		{
			if(null == viewClassDic[cls])
				viewClassDic[cls] = new cls();
			return viewClassDic[cls] as BaseSprite;
		}
		
		/**
		 * 根据当前鼠标位置和tips视图大小重设视图位置
		 * @param tipsView
		 *
		 */		
		private function resetTipsViewPosition(tipsView:BaseSprite):void
		{
			var sw:Number = StageManager.getInstance().stageWidth; //舞台宽高
			var sh:Number = StageManager.getInstance().stageHeight;
			var tw:Number = tipsView.width;//tips宽高
			var th:Number = tipsView.height;
			if(tipsView._h > 0){
				th = tipsView._h;
			}
			if(tipsView._w > 0){
				tw = tipsView._w;
			}
			var mx:Number = StageManager.getInstance().stage.mouseX; //当前鼠标坐标
			var my:Number = StageManager.getInstance().stage.mouseY;
			var tx:Number = 0; //目的坐标
			var ty:Number = 0;
			var sp:Number = 20; //鼠标和tips间隔
			if(mx + tw + sp> sw) //如果（放在鼠标右边，tips会超出边界）
				tx = mx-tw-sp;
			else
				tx = mx+sp;
			if(my - th - sp < 0) //如果（放在鼠标上面面，tips会超出上边界）
			{
				ty = my+sp;
				if(ty+th > sh)//新的坐标导致tips超出下界，则以下界网上推
					ty = sh-th;
				if(ty < 0) //tips左上角超出上界，则y坐标固定到0
					ty = 0;
			}
			else
			{
				ty = my-th-sp;
				if(ty < 0)
					ty = 0;
			}
			tipsView.x = tx;
			tipsView.y = ty;
		}
		
		/**
		 * 目标对象鼠标移入事件
		 * @param event
		 *
		 */		
		protected function onObjMouseOverHandler(event:MouseEvent):void
		{
			var obj:DisplayObject = event.currentTarget as DisplayObject;
			curMouseInObj = obj;
			var data:Object = tooltipDic[obj];
			if(null != data)
			{
				var tipsView:BaseSprite;
				if(null != data.tipsClass)
				{
					tipsView = getTipsView(data.tipsClass);
					layer.addChild(tipsView);
					if(null != tipsView && null != data.dataFunc)
						(tipsView as IToolTipsView).data = (data.dataFunc as Function).call(null,obj);
					resetTipsViewPosition(tipsView);
					//					tipsView.startDrag();
					DragingManager.getInstance().startDrag(tipsView);
				}
				else
				{
					defTipsView.htmlText = data.tipsStr;
					layer.addChild(defTipsView);
					resetTipsViewPosition(defTipsView);
					//					defTipsView.startDrag();
					DragingManager.getInstance().startDrag(defTipsView);
				}
			}
		}
		
		/**
		 * 目标对象鼠标移动出事件
		 * @param event
		 *
		 */		
		protected function onObjMouseOutHandler(event:MouseEvent):void
		{
			var obj:DisplayObject = event.currentTarget as DisplayObject;
			curMouseInObj = null;
			var data:Object = tooltipDic[obj];
			if(null != data.tipsClass)
			{
				var tipsView:BaseSprite;
				tipsView = getTipsView(data.tipsClass);
				if(tipsView)
				{
					tipsView.stopDrag();
					DragingManager.getInstance().stopDrag(tipsView);
					if(layer.contains(tipsView))
						layer.removeChild(tipsView);
				}
			}
			else
			{
				defTipsView.stopDrag();
				DragingManager.getInstance().stopDrag(defTipsView);
				if(layer.contains(defTipsView))
					layer.removeChild(defTipsView);
			}
		}
	}
}

