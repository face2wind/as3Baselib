package face2wind.view
{
	import com.greensock.TweenLite;
	
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import face2wind.lib.ObjectPool;
	import face2wind.uiComponents.CustomTextfield;
	
	
	/**
	 * 动态显示一行一行的提示信息组件<br/>
	 * 每一句文字都会居中，文字中点x坐标是0
	 * @author Face2wind
	 */
	public class MessageView extends BaseSprite
	{
		public function MessageView()
		{
			super();
		}
		
		/**
		 * 文本统一用的格式，为空则不用 
		 */		
		public var txtFormat:TextFormat = null;
		
		/**
		 * 同时显示的最大文本数量 
		 */		
		public var maxNum:int = 5;
		
		/**
		 * 每条信息显示的时间 
		 */		
		public var msgShowingTime:int = 2;
		
		/**
		 *  信息缓存
		 */		
		private var msgArry:Array = [];
		
		/**
		 * 每一行显示信息上下间隔 
		 */		
		public var distence:int = 30;
		
		/**
		 *  增加一条要显示的信息（关键：移动和透明度改变分两个异步进程走）
		 * @param str 信息内容
		 * @param isUpDir 是否向上滚动，默认是
		 * 
		 */		
		public function show( str:String , isUpDir:Boolean = true):void
		{
			if ("" == str || null == str)
				return;
			var defaultY:int;
			//获取对应存储message的数组
			if (null == msgArry)
				return;
			var msgTxt:CustomTextfield = ObjectPool.getObject(CustomTextfield);//new BaseTextField();
			msgTxt.alpha = 0;
			msgTxt.y = distence;
			if( null != txtFormat)
				msgTxt.defaultTextFormat = txtFormat;
			msgTxt.autoSize = TextFieldAutoSize.LEFT;
			msgTxt.htmlText = str;
			msgTxt.x = -msgTxt.width/2;
			addChild(msgTxt);
			msgTxt.visible = false;
			
			var tmpTxt:CustomTextfield = null;
			//若超过最大数量，把第一条直接删除
			if (maxNum <= msgArry.length)
			{
				tmpTxt = msgArry.shift();
				var index:int = msgArry.indexOf(tmpTxt);
				if (-1 != index)
					msgArry.splice(index, 1);
				if (contains(tmpTxt))
					removeChild(tmpTxt);
				ObjectPool.disposeObject(tmpTxt);
			}
			//其余msg重设动画，目的不同
			var len:int = msgArry.length;
			for (var i:int = 0; i < len; i++)
			{
				tmpTxt = msgArry[i] as CustomTextfield;
				TweenLite.killTweensOf(tmpTxt);
				if(false == tmpTxt.data.hasShow)
					tmpTxt.alpha = 1; //防止有些文字alpha未缓动到1就被这里cut断了
				if (-1 != tmpTxt.data.stopTimer)
					clearTimeout(tmpTxt.data.stopTimer);
				TweenLite.to(tmpTxt, 0.5, {y:  (i-len)*distence});
			}
			startShowMsg(msgTxt);
			msgArry.push(msgTxt);
			msgTxt.data = {};
			msgTxt.data.hasShow = false; //是否已经到达过alpha为1的状态
			msgTxt.data.fadeTimer = setTimeout(fadeMsg, msgShowingTime*1000+500, msgTxt);
		}
		
		
		/**
		 * 开始显示信息
		 * @param msgTxt
		 * @param obj
		 *
		 */
		private function startShowMsg(msgTxt:CustomTextfield):void
		{
			msgTxt.visible = true;
			TweenLite.to(msgTxt, 1, {y:msgTxt.y - distence, alpha: 1 , onComplete: onShowComplete, onCompleteParams: [msgTxt]});
		}
		
		/**
		 * 显示动画缓动完毕 
		 * 
		 */		
		private function onShowComplete(msgTxt:CustomTextfield):void
		{
			msgTxt.data.hasShow = true;
		}
		
		/**
		 * 开始降低透明度，msg消失 
		 * @param msgTxt
		 * 
		 */		
		private function fadeMsg(msgTxt:CustomTextfield):void
		{
			if (-1 != msgTxt.data.fadeTimer)
			{
				clearTimeout(msgTxt.data.fadeTimer);
				msgTxt.data.fadeTimer = -1;
			}
			var i:int = msgArry.indexOf(msgTxt);
			if (-1 != i)
				msgArry.splice(i, 1);
			TweenLite.killTweensOf(msgTxt);
			msgTxt.data.fadeTimer = setTimeout(fadeComplete, 1000 , msgTxt);
			TweenLite.to(msgTxt, 1, {y: msgTxt.y - distence ,alpha:0});
		}
		
		/**
		 * 信息展示完毕，隐藏，完全删除
		 * @param item
		 *
		 */
		private function fadeComplete(msgTxt:CustomTextfield):void
		{
			if (-1 != msgTxt.data.fadeTimer)
			{
				clearTimeout(msgTxt.data.fadeTimer);
				msgTxt.data.fadeTimer = -1;
			}
			TweenLite.killTweensOf(msgTxt);
			if (contains(msgTxt))
				removeChild(msgTxt);
			ObjectPool.disposeObject(msgTxt);
		}
	}

}