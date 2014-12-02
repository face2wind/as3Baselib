package face2wind.manager
{
	import face2wind.enum.GameEffectLevel;
	import face2wind.enum.LayerEnum;
	import face2wind.lib.ObjectPool;
	import face2wind.view.BaseSprite;
	import face2wind.view.BaseWindow;
	import face2wind.view.BitmapWindow;
	import face2wind.view.SimpleWindow;
	
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	/**
	 * 窗口管理器
	 * @author face2wind
	 */
	public class WindowManager
	{
		private var layerManager:LayerManager;
		
		public function WindowManager()
		{
			layerManager = LayerManager.getInstance();
			gEffManager = GameEffectManager.getInstance();
			windowBitmapDic = new Dictionary();
			windowBmTimeDic = new Dictionary();
			bitmapWindowDic = new Dictionary();
		}
		
		private static var instance:WindowManager = null;
		public static function getInstence():WindowManager
		{
			if(null == instance)
				instance = new WindowManager();
			return instance;
		}
		
		/**
		 * 记录当前处于顶层的窗口 
		 */		
		private var curTopObj:BaseSprite = null;
		
		/**
		 * 游戏特效等级管理 
		 */		
		protected var gEffManager:GameEffectManager;
		
		/**
		 * 把显示对象移到顶层<br/>
		 * 若显示对象未加到窗口层，则addChild到该层 
		 * @param BaseSprite
		 * 
		 */		
		public function popup(obj:BaseSprite):void
		{
			if(null == obj)
				return;
			var layer:BaseSprite = layerManager.getLayer(LayerEnum.WINDOW_LAYER) as BaseSprite;
			if(layer)
			{
				if(null != obj.parent && obj.parent != layer) //包含在窗口层的对象才做处理
					return;
				if(layer.contains(obj))
				{
					var childIndex:int =  layer.getChildIndex(obj);
					if(childIndex < layer.numChildren-1)
					{
						layer.setChildIndex(obj, layer.numChildren-1);
//						if(GameEffectManager.getInstance().curEffectLevel == GameEffectLevel.NO_EFFECT)
//							layer.setChildIndex(obj, layer.numChildren-1);
//						else
//							playPopUpEffect(obj); 建成不喜欢这个效果，隐藏掉
					}
				}
				else
				{
					layer.addChild(obj);
				}
				curTopObj = obj;
				ReleaseableManager.getInstence().removeItem(obj);
				refleshBitmapWindows();
			}
		}
		
		/**
		 * 播放弹出窗口到顶部的动画（借鉴Linux）测试~
		 * @param obj
		 * 
		 */		
		private function playPopUpEffect(obj:BaseSprite):void
		{
			var layer:BaseSprite = layerManager.getLayer(LayerEnum.WINDOW_LAYER) as BaseSprite;
			var childNum:int = layer.numChildren;
			var child:BaseWindow;
			var someWindowMove:Boolean = false;
			var objIndex:int = layer.getChildIndex(obj); //要弹起的窗口的下标
			for (var i:int = 0; i < childNum; i++) 
			{
				child = layer.getChildAt(i) as BaseWindow;
				if(null == child)
					continue;
				if(child == obj) //弹起的窗口对象，不做处理
					continue;
				if(i < objIndex) //弹起窗口以下的窗口，不用做移动动画
					continue;
				var dstP:Point = calculateDstPoint(child, obj);
				if(null != dstP) //不需要移动，则不管
				{
					someWindowMove = true;
					TweenLite.to(child , 0.2 , {x:dstP.x, y:dstP.y,onComplete:function(xx:Number, yy:Number,dstObj:BaseSprite):void
					{
						TweenLite.killTweensOf(dstObj);
						TweenLite.to(dstObj , 0.2 , {x:xx, y:yy});
					}, onCompleteParams:[child.x,child.y,child]});
				}
			}
			if(someWindowMove)
				EnterFrameUtil.delayCall(200 , function():void
				{
					if(layer.contains(obj))
						layer.setChildIndex(obj, childNum-1);
				});
			else
				layer.setChildIndex(obj, childNum-1);
		}
		
		/**
		 * 在弹出动画中，计算当前窗体运动的中间点（当前窗口让位） 
		 * @param child 当前窗口
		 * @param obj 要弹起的窗口
		 * @return 
		 * 
		 */		
		private function calculateDstPoint(child:BaseSprite, obj:BaseSprite):Point
		{
			if( (child.x-obj.x) > obj.width ||
				(obj.x-child.x) > child.width ||
				(child.y-obj.y) > obj.height ||
				(obj.y-child.y) > child.height) //两个窗口没有重叠
				return null;
			
			//四个方向的移动中点坐标
			var upP:Point = new Point(child.x ,obj.y-child.height);
			var downP:Point = new Point(child.x ,obj.y+obj.height);
			var leftP:Point = new Point(obj.x-child.width, child.y);
			var rightP:Point = new Point(obj.x+obj.width, child.y);
			
			var upD:Number = child.y - upP.y;
			var downD:Number = downP.y - child.y;
			var leftD:Number = child.x - leftP.x;
			var rightD:Number = rightP.x - child.x;
			
			//选择一个移动比较少的方向做为目标点
			if(upD < downD &&
				upD < leftD &&
				upD < rightD)
				return upP;
			else if(downD < upD &&
				downD < leftD &&
				downD < rightD)
				return downP;
			else if(leftD < upD &&
				leftD < downD &&
				leftD < rightD)
				return leftP;
			else if(rightD < upD &&
				rightD < leftD &&
				rightD < downD)
				return rightP;
			return null;
//			
//			var centerP1:Point = new Point();
//			centerP1.x = child.x;//+child.width/2;
//			centerP1.y = child.y;//+child.height/2;
//			var centerP2:Point = new Point();
//			centerP2.x = obj.x;//+obj.width/2;
//			centerP2.y = obj.y;//+obj.height/2;
//			var xDst:Number = Math.abs(centerP1.x-centerP2.x);//两个窗口的中心点距离
//			var yDst:Number = Math.abs(centerP1.y-centerP2.y)
//			if(xDst > Math.max(child.width/2,obj.width/2) &&
//				yDst > Math.max(child.height/2,obj.height/2) ) //两个窗口没有重叠
//				return null;
//			else
//			{
//				var dstP:Point = new Point(child.x,child.y);
//				if(xDst < yDst) //x偏移的比较少，则采用x偏移坐标
//				{
//					if(centerP1.x > centerP2.x)
//						dstP.x = obj.x-child.width;
//					else
//						dstP.x = obj.x+obj.width;
//				}
//				else
//				{
//					if(centerP1.y > centerP2.y)
//						dstP.y = obj.y+obj.height;
//					else
//						dstP.y = obj.y-child.height;
//				}
//				return dstP;
//			}
		}
		
		/**
		 * 窗口出现之前的缩放程度 
		 */		
		private var windowScale:Number = 0.4;
		
		/**
		 * 保存窗口对应的快照bitmap 
		 */		
		private var windowBitmapDic:Dictionary;
		
		/**
		 * 保存窗口快照剩余时间
		 */		
		private var windowBmTimeDic:Dictionary;
		
		/**
		 * 当前保留缩略图的窗口数 
		 */		
		private var windowBmSize:int = 0;
		
		/**
		 *  被替换的窗口字典
		 */		
		private var bitmapWindowDic:Dictionary;
		
		/**
		 *  移除对象的显示
		 * @param BaseSprite
		 * 
		 */		
		public function removeObj(obj:BaseSprite):void
		{
			if(null == obj)
				return;
			var layer:BaseSprite = layerManager.getLayer(LayerEnum.WINDOW_LAYER) as BaseSprite;
			if(layer.contains(obj))
			{
				if(null != obj.parent && obj.parent != layer) //包含在窗口层的对象才做处理
					return;
				//若允许，播放窗口最小化效果
				if(gEffManager.curEffectLevel != GameEffectLevel.NO_EFFECT)
					playWindowMinEff(obj);
				
				layer.removeChild(obj);
//				obj.lastBeenRemoveTime = getTimer();
				obj.isOnshow = false;//layer.isOnshow;
				//由于resume和dispose都是迭代执行到所有子对象，所以只需注册最底层容器对象即可实现所有其子对象资源释放
				ReleaseableManager.getInstence().addItem(obj);
				
				
				refleshBitmapWindows();
			}
		}
		
		/**
		 * 刷新bitmap窗口（一些被其他窗口遮住的窗口用一张静态bitmap暂时替换） 
		 * 
		 */		
		public function refleshBitmapWindows():void
		{
			return;
			var layer:BaseSprite = layerManager.getLayer(LayerEnum.WINDOW_LAYER) as BaseSprite;
			var num:int = layer.numChildren;
			var upSpList:Array = []; //在当前检测对象上层的对象列表
//			var curBmNum:int = 0; //当前已用bm替换的窗口数量，测试用~~
			for (var i:int = num-1; i >= 0; i--) 
			{
				var curWindow:BaseSprite = layer.getChildAt(i) as BaseSprite;
				if(null == curWindow)
					continue;
				var x1:Number = curWindow.x;
				var y1:Number = curWindow.y;
				var width1:Number = curWindow.width;
				var height1:Number = curWindow.height;
				var curObjArea:int = curWindow.width*curWindow.height;
				var coverNum:int = 0; //挡住当前窗口的其他窗口数
				var curHitArea:int = 0; //被上层窗口挡住的面积（上层有多个窗口，不做精确叠加面积，只做简单相加操作）
				for (var j:int = 0; j < upSpList.length; j++) 
				{
					var upWin:DisplayObject = upSpList[j] as DisplayObject;
					
					var x2:Number = upWin.x;
					var y2:Number = upWin.y;
					var width2:Number = upWin.width;
					var height2:Number = upWin.height;
					
					var endx:Number = Math.max(x1+width1,x2+width2);  
					var startx:Number = Math.min(x1,x2);  
					var overWidth:Number = width1+width2-(endx-startx);  
					
					var endy:Number = Math.max(y1+height1,y2+height2);  
					var starty:Number = Math.min(y1,y2);  
					var overHeight:Number = height1+height2-(endy-starty);  
					
					var overArea:Number = overWidth*overHeight;
					curHitArea += overArea;
					if(overArea > 0)
						coverNum ++;
				}
				var rate:Number = (curHitArea / curObjArea) ;
				//覆盖面积超过一定比率则当作当前窗口基本被覆盖
				if( 1 == coverNum && rate > 0.8 ||
					rate > 1)
				{
					if(curWindow is SimpleWindow)
					{
						changeBitmapWindow(curWindow);
					}
//					curBmNum ++;
				}
				else
				{
					if(curWindow is BitmapWindow)
						changeBitmapWindow(curWindow);
				}
				upSpList.push(curWindow);
			}
//			trace("当前bm窗口数："+curBmNum);
		}
		
		/**
		 * 切换窗口和bitmap窗口的状态<br/>
		 * 是普通窗口则变成bitmap窗口，反之一样 
		 * @param window
		 * 
		 */		
		public function changeBitmapWindow(window:BaseSprite):void
		{
			var layer:BaseSprite = layerManager.getLayer(LayerEnum.WINDOW_LAYER) as BaseSprite;
			if(null == window || !layer.contains(window))
				return;
		
			var bmW:BitmapWindow;
			var smW:SimpleWindow;
			var index:int = layer.getChildIndex(window);
			if(window is SimpleWindow)
			{
				smW = window as SimpleWindow;
				bmW = getBmWindow(window as SimpleWindow);
//				bmW.move(smW.x , smW.y);
				smW.lockReleaseble = true;
				layer.addChildAt(bmW , index);
				layer.removeChild(smW);
			}
			else if(window is BitmapWindow)
			{
				bmW = window as BitmapWindow;
				smW = bmW.source;
//				smW.move(bmW.x , bmW.y);
				layer.addChildAt(smW , index);
				layer.removeChild(bmW);
				smW.lockReleaseble = false;
			}
		}
		
		/**
		 * 弹起一个bitmap窗口 
		 * @param window
		 * 
		 */		
		public function popupBitmapWindow(window:BitmapWindow):void
		{
			changeBitmapWindow(window);
			popup(window.source);
		}
		
		/**
		 * 隐藏一个bitmap窗口 
		 * @param window
		 * 
		 */		
		public function removeBitmapWindow(window:BitmapWindow):void
		{
			changeBitmapWindow(window);
//			removeObj(window.source);
			window.source.close();
		}
		
		/**
		 * 获取一个bitmap窗口 
		 * @param curWindow
		 * @return 
		 * 
		 */		
		private function getBmWindow(curWindow:SimpleWindow):BitmapWindow
		{
			var bm:BitmapWindow = bitmapWindowDic[curWindow];
			if(null == bm)
			{
				bitmapWindowDic[curWindow] = ObjectPool.getObject(BitmapWindow);
				bm = bitmapWindowDic[curWindow];
			}
			bm.source = curWindow;
			bm.move(curWindow.x,curWindow.y);
			return bitmapWindowDic[curWindow];
		}
		
		/**
		 * 播放窗口最小化动画 
		 * @param obj
		 * 
		 */		
		private function playWindowMinEff(obj:BaseSprite):void
		{
			var layer:BaseSprite = layerManager.getLayer(LayerEnum.WINDOW_LAYER) as BaseSprite;
			var bm:Bitmap = getWindowScaleBitmap(obj);
			
			var globalPoint:Point = getTopLeftPoint(obj,obj.parent.localToGlobal(new Point(obj.x,obj.y)));
			
			bm.x = globalPoint.x;
			bm.y = globalPoint.y;
			
			layer.addChild(bm);
			var targetX:Number = bm.x + (1-windowScale)*obj.width/2;
			var targetY:Number = bm.y + (1-windowScale)*obj.height/2;
			TweenLite.killTweensOf(this);
			TweenLite.to(bm, 0.3 , {alpha:0, x:targetX, y:targetY,scaleX:windowScale, scaleY:windowScale,
				onComplete:onCloseCompleteHandler, onCompleteParams:[obj]});
		}
		
		/**
		 * 获取显示对象左上角顶点
		 * @param obj 显示对象
		 * @param minPoint 左上角
		 * @return 
		 */		
		private function getTopLeftPoint(obj:DisplayObject,minPoint:Point):Point
		{
			//先跟自身顶点比较
			var curMinPoint:Point = minPoint;
			var globalPoint:Point = obj.parent.localToGlobal(new Point(obj.x,obj.y));
			curMinPoint.x = Math.min(globalPoint.x,curMinPoint.x);
			curMinPoint.y = Math.min(globalPoint.y,curMinPoint.y);
			//跟子对象顶点比较
			if(obj is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = obj as DisplayObjectContainer;
				var tmpPoint:Point;
				for(var i:int = 0;i < container.numChildren; i++)
				{
					tmpPoint = getTopLeftPoint(container.getChildAt(i),curMinPoint);
					curMinPoint.x = Math.min(tmpPoint.x,curMinPoint.x);
					curMinPoint.y = Math.min(tmpPoint.y,curMinPoint.y);
				}
			}
			return curMinPoint;
		}
		
		/**
		 * 获取指定窗口对应的bitmap拷贝 
		 * @param window
		 * @return 
		 * 
		 */		
		private function getWindowScaleBitmap(window:BaseSprite):Bitmap
		{
			var bm:Bitmap = windowBitmapDic[window] as Bitmap;
			if(null == bm)
			{
				bm = ObjectPool.getObject(Bitmap);
			}
			
			if(null == bm.bitmapData)
			{
				if(10 < windowBmSize) //保留的缩略图太多，开始清理
				{
					var now:Number = getTimer();
					for (var i:* in windowBmTimeDic) 
					{
						if( (now - windowBmTimeDic[i]) > 10000 ) //超过10秒的缩略图都删除
						{
							windowBitmapDic[i].bitmapData = null;
							ObjectPool.disposeObject(windowBitmapDic[i], Bitmap);
							delete windowBitmapDic[i];
							delete windowBmTimeDic[i];
						}
					}
				}
				
				windowBitmapDic[window] = bm;
				windowBmTimeDic[window] = getTimer(); //记录使用这个bitmap的时间
				windowBmSize ++;
				var rect:Rectangle = window.getBounds(window);
				var bitmapData:BitmapData = new BitmapData(window.width, window.height, true, 0);
				bitmapData.draw(window, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
				bm.bitmapData = bitmapData;
			}
			return bm;
		}
		
		/**
		 * 关闭动画播放完毕 
		 * @param window
		 * 
		 */		
		public function onCloseCompleteHandler(window:BaseSprite):void
		{
			var bm:Bitmap = windowBitmapDic[window] as Bitmap;
			var layer:BaseSprite = layerManager.getLayer(LayerEnum.WINDOW_LAYER) as BaseSprite;
			if(layer.contains(bm))
				layer.removeChild(bm);
			bm.scaleX = bm.scaleY = 1;
			bm.alpha = 1;
		}
	}
}
