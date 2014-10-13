package face2wind.manager
{
	import face2wind.enum.EventBusEnum;
	import face2wind.enum.LayerEnum;
	import face2wind.event.ParamEvent;
	import face2wind.manager.item.DragingItemType;
	import face2wind.manager.item.IDragingItem;
	import face2wind.view.BaseSprite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * 拖拽管理器<br/>
	 * 1 可以拖动任何继承IDragingItem接口的对象<br/>
	 * 2 手动实现startDrag和stopDrag操作，适用任何显示对象
	 * @author face2wind
	 */
	public class DragingManager
	{
		/**
		 * 拖动一个对象到另一个对象里面放开，广播事件 
		 */		
		public static const DRAGING_DATA_DONE:String = "DragingManager_DRAGING_DATA_DONE";
		
		public function DragingManager()
		{
			if(instance)
				throw new Error("DragingManager is singleton class and allready exists!");
			instance = this;
			
			dragingItemDic = new Dictionary();
			dragingItemDic2 = new Dictionary();
			dragingIcon = new Bitmap();
			layer = LayerManager.getInstance().getLayer(LayerEnum.MSG_LAYER);
			StageManager.getInstance().stage.addEventListener(MouseEvent.MOUSE_UP , onStageMouseUpHandler);
			StageManager.getInstance().stage.addEventListener(MouseEvent.MOUSE_MOVE , onStageMouseMoveHandler);
		}
		
		/**
		 * 单例
		 */
		private static var instance:DragingManager;
		/**
		 * 获取单例
		 */
		public static function getInstance():DragingManager
		{
			if(!instance)
				instance = new DragingManager();
			
			return instance;
		}
		
		/**
		 * 正在拖动的对象列表（纯拖拽） 
		 */		
		private var dragingItemDic:Dictionary;
		
		/**
		 *	是否有对象在拖动 
		 */		
		public var isDraging:Boolean;
		
		/**
		 * 当前拖动的对象个数 
		 */		
		private var curDragingNum:int = 0;
		
		/**
		 * 正在拖动的对象列表 （拖入拖出，有数据的拖拽）
		 */		
		private var dragingItemDic2:Dictionary;
		
		/**
		 * 拖动的图形对象（只是一张图片） 
		 */		
		private var dragingIcon:Bitmap;
		
		/**
		 * 放置拖动图形的层（默认是msg层） 
		 */		
		private var layer:BaseSprite;
		
		/**
		 * 当前按下的对象（准备拖动） 
		 */		
		private var curDragingItem:IDragingItem = null;
		
		/**
		 * 注册一个拖动对象，可以接收拖出拖入数据，具体见 IDragingItem
		 * @param item
		 * 
		 */		
		public function registerItem(item:IDragingItem):void
		{
			if(!(item is DisplayObject))
			{
				throw new Error("DragingManager.registerItem，item is not an DisplayObject");
				return;
			}
			if(item.dragingType == DragingItemType.DRAG_IN_OUT)
			{
				(item as DisplayObject).addEventListener(MouseEvent.MOUSE_DOWN , onItemMouseDownHandler);
				(item as DisplayObject).addEventListener(MouseEvent.MOUSE_UP , onItemMouseUpHandler);
			}
			else if(item.dragingType == DragingItemType.DRAG_IN)
			{
				(item as DisplayObject).addEventListener(MouseEvent.MOUSE_UP , onItemMouseUpHandler);
			}
			else if(item.dragingType == DragingItemType.DRAG_OUT)
			{
				(item as DisplayObject).addEventListener(MouseEvent.MOUSE_DOWN , onItemMouseDownHandler);
			}
//			startDrag(item as DisplayObject);
		}
		
		/**
		 * 反注册（注销）一个拖动对象
		 * @param item
		 * 
		 */		
		public function unregisterItem(item:IDragingItem):void
		{
			if(!(item is DisplayObject))
				return;
			(item as DisplayObject).removeEventListener(MouseEvent.MOUSE_DOWN , onItemMouseDownHandler);
			(item as DisplayObject).removeEventListener(MouseEvent.MOUSE_UP , onItemMouseUpHandler);
//			stopDrag(item as DisplayObject);
		}
		
		/**
		 * 开始拖动  
		 * @param item 拖动对象
		 * @param layer 对象被拖动时所在的层（空则默认在该对象当前父对象里拖动）
		 * 
		 */		
		public function startDrag(item:DisplayObject, layer:BaseSprite = null):void
		{
			if(null == layer) //没有指定拖动层
			{
				layer = item.parent as BaseSprite;
				if(null == layer)
					return;
			}
			var mx:Number = layer.mouseX;
			var my:Number = layer.mouseY;
			if(null != item.parent && layer != item.parent)//从原来的层到不同的拖拽层
			{
				var tp:Point = item.parent.localToGlobal(new Point(item.x,item.y));
				tp = layer.globalToLocal(new Point(item.x,item.y));
				item.x = tp.x;
				item.y = tp.y;
				item.parent.removeChild(item);
				layer.addChild(item);
			}
			else if(null == item.parent && null != layer) //新建一个对象直接拖拽
			{
				item.x = mx;
				item.y = my;
				layer.addChild(item);
			}
			curDragingNum ++;
			//记录开始拖动时，对象和鼠标坐标的偏差，拖动时一直保持这个偏差
			dragingItemDic[item] = {layer:layer, dx:mx-item.x, dy:my-item.y};
			RenderManager.getInstance().add(dragingHandle);
		}
		
		/**
		 * 停止拖动  
		 * @param item 拖动对象
		 * @param layer 对象停止拖动时放置在指定的层（为空则默认放在拖动层里）
		 * 
		 */				
		public function stopDrag(item:DisplayObject, layer:BaseSprite = null):void
		{
			if(undefined == dragingItemDic[item])//对象不在拖动中，不管
				return;
			var drData:Object = dragingItemDic[item];
			var drLayer:BaseSprite = drData.layer as BaseSprite;
			if(null != layer)
			{
				var tp:Point = drLayer.localToGlobal(new Point(item.x,item.y));
				tp = layer.globalToLocal(new Point(item.x,item.y));
				item.x = tp.x;
				item.y = tp.y;
				drLayer.removeChild(item);
				layer.addChild(item);
			}
			delete dragingItemDic[item];
			curDragingNum--;
			if(1 > curDragingNum)
				RenderManager.getInstance().remove(dragingHandle);
		}
		
		/**
		 * 拖动处理函数（有拖动对象，则实时运行） 
		 * @param step
		 * 
		 */		
		private function dragingHandle(step:int):void
		{
			for (var item:* in dragingItemDic) 
			{
				var drData:Object = dragingItemDic[item];
				var drLayer:BaseSprite = drData.layer as BaseSprite;
				var drDx:Number = drData.dx;
				var drDy:Number = drData.dy;
				var mx:Number = drLayer.mouseX;
				var my:Number = drLayer.mouseY;
				item.x = mx-drDx;
				item.y = my-drDy;
			}
		}
		
		/**
		 * 拖动对象鼠标按下 
		 * @param event
		 * 
		 */		
		protected function onItemMouseDownHandler(event:MouseEvent):void
		{
			var item:IDragingItem = event.currentTarget as IDragingItem;
			if(item.dragingType == DragingItemType.DRAG_IN ||
				item.dragingType == DragingItemType.NONE)
				return;
			curDragingItem = item;
		}
		
		/**
		 * 真正开始拖动对象（按下并移动才创建拖动对象） 
		 * @param item
		 * 
		 */		
		private function dragingItem():void
		{
			if(null == curDragingItem)
				return;
			
			var item:IDragingItem = curDragingItem;
			dragingItemDic2[item] = item.getDraginData();
			var rect:Rectangle = (item as DisplayObject).getBounds((item as DisplayObject));
			var dragingSource:IBitmapDrawable = item.dragingBitmapObj;
			if(null == dragingSource)
				dragingSource = item as IBitmapDrawable;
			var bitmapData:BitmapData = new BitmapData(rect.width+4, rect.height+4, true, 0);
			bitmapData.draw(dragingSource as IBitmapDrawable, new Matrix(1, 0, 0, 1, -rect.x+2, -rect.y+2));
			dragingIcon.bitmapData = bitmapData;
			var itemParent:DisplayObject = (item as DisplayObject).parent;
			var itemPoint:Point = new Point((item as DisplayObject).x,(item as DisplayObject).y);
			var itemGloblePoint:Point = itemParent.localToGlobal(itemPoint);
			dragingIcon.x = itemGloblePoint.x;//layer.mouseX-dragingIcon.width/2;
			dragingIcon.y = itemGloblePoint.y;//layer.mouseY-dragingIcon.height/2;
			layer.addChild(dragingIcon);
			startDrag(dragingIcon);
			if(!item.isClone && item.canAutoSetData)
				item.setDraginData(null);
			isDraging = true;
			
			curDragingItem = null;
		}
		
		/**
		 * 拖动对象鼠标弹起 
		 * @param event
		 * 
		 */	
		protected function onItemMouseUpHandler(event:MouseEvent):void
		{
			var item:IDragingItem = event.currentTarget as IDragingItem;
			if(item.dragingType == DragingItemType.DRAG_OUT ||
				item.dragingType == DragingItemType.NONE)
				return;
			curDragingItem = null;
			event.stopImmediatePropagation();
			event.stopPropagation();
			for (var dItem:* in dragingItemDic2) 
			{
				if(item == dItem)//不处理自己拖到自己的情况
				{
					resumeData();
					continue;
				}
				if(item.draginSign == dItem.draginSign) //暗号对得上，放进去
				{
//					event.stopImmediatePropagation();
//					event.stopPropagation();
					var targetData:* = item.getDraginData();
					if(null != targetData && dItem.canAutoSetData) //拖到目的容器里有数据，则交换
						dItem.setDraginData(targetData);
					if(item.canAutoSetData)
						item.setDraginData(dragingItemDic2[dItem]);
					stopDrag(dragingIcon);
					if(layer.contains(dragingIcon))
						layer.removeChild(dragingIcon);
					EventManager.dispatchEvent(EventBusEnum.BASE_LIB, new ParamEvent(DRAGING_DATA_DONE,
						{srcItem:dItem , dscItem:item , dragingData:dragingItemDic2[dItem]}));
					delete dragingItemDic2[dItem];
					break; //放了一个后就不遍历了
				}
			}
			isDraging = false;
		}
		
		/**
		 * 舞台上的鼠标弹起事件，用于没处理拖动数据时还原数据 
		 * @param event
		 * 
		 */		
		protected function onStageMouseUpHandler(event:MouseEvent):void
		{
			resumeData(false);
			isDraging = false;
		}
		
		/**
		 * 鼠标移动事件（按下并移动才会执行拖拽操作） 
		 * @param event
		 * 
		 */		
		protected function onStageMouseMoveHandler(event:MouseEvent):void
		{
			dragingItem();
		}
		
		/**
		 * 没处理拖动数据时还原数据  
		 * @param notIconUp 在IDragingItem上弹起
		 */		
		private function resumeData(isOnDragingItem:Boolean = true):void
		{
			for (var dItem:* in dragingItemDic2) 
			{
				if(!dItem.isClone)
				{
					if(dItem.canAutoSetData)
						dItem.setDraginData(dragingItemDic2[dItem]);
					if(false == isOnDragingItem)
						dItem.onDragToEmpty();
				}
				delete dragingItemDic2[dItem];
			}
			stopDrag(dragingIcon);
			if(layer.contains(dragingIcon))
				layer.removeChild(dragingIcon);
		}
	}
}