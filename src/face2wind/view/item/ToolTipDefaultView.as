package face2wind.view.item
{
	import face2wind.lib.Reflection;
	import face2wind.uiComponents.CustomTextfield;
	import face2wind.util.StringUtil;
	import face2wind.view.BaseSprite;
	
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;

	/**
	 * 默认tooltip视图，只有文字和默认背景
	 * @author face2wind
	 */
	public class ToolTipDefaultView extends BaseSprite
	{
		/**
		 * 背景图 
		 */		
		private var bg:Sprite;
		
		/**
		 * 文字 
		 */		
		private var text:CustomTextfield;
		
		private var _htmlText:String = "";
		/**
		 * 设置tips文本内容 
		 */
		public function get htmlText():String
		{
			return _htmlText;
		}
		/**
		 * @private
		 */
		public function set htmlText(value:String):void
		{
			if(_htmlText == value || "" == value)
				return;
			
			_htmlText = value;
			propertyChange();
		}
		
		/**
		 * 是否使用默认sprite的graphic来draw背景 
		 */		
		private var useDrawBg:Boolean = false;

		public function ToolTipDefaultView()
		{
			super();
		}
		
		
		/**
		 * 此函数是视图的内容初始化函数<br/>对父类的覆盖 
		 * 
		 */		
		protected override function createChildren():void
		{
			super.createChildren();
			
			bg = Reflection.createInstance("backGroundSkin_1") as Sprite;
			if(null == bg)
			{
				useDrawBg = true;
				bg = new Sprite();
			}
			addChild(bg);
			
			text = new CustomTextfield();
			text.x = 9;
			text.y = 9;
			text.leading = 5;
//			text.width = 200;
			text.filters = [new GlowFilter(0x0, 1, 2, 2, 10)];
			text.color = 0xffffff;
			text.wordWrap = true;
			text.multiline = true;
			text.autoSize = TextFieldAutoSize.LEFT;
//			text.border = true;
			addChild(text);
			
			propertyChange();
		}
		
		/**
		 * 更新tips以及背景 
		 * 
		 */		
		protected override function update():void
		{
//			var patternCN:RegExp=/[\u4e00-\u9fa5] /; //中文字的正则表达式
//			var patternEN:RegExp=/[A-Za-z]/;
			//字符串有换行符的，先按照换行符划分字符串，找出最长字符串的长度
			var tempArr:Array = _htmlText.split("\n");
			var tipsArr:Array = [];
			for (var i:int = 0; i < tempArr.length; i++) 
			{
				tipsArr = tipsArr.concat((tempArr[i] as String).split("<br/>"));
			}
			var len:int = 0;
			for (var j:int = 0; j < tipsArr.length; j++) 
			{
				var tLen:int = 0;
				var tStr:String = (tipsArr[j] as String);
				tLen = StringUtil.stringLen(tStr);
//				for (var k:int = 0; k < tStr.length; k++) 
//				{
//					var charStr:String = tStr.charAt(k);
//					if(charStr.match(patternCN))
//						tLen += 2;
//					else
//						tLen += 1;
//				}
				if(tLen > len)
					len = tLen;
			}
			
//			var len:int = _htmlText.length;
			if(len < 20)
				text.width = len*8;
			else if(len < 121)
				text.width = 166;
			else if(len < 301)
				text.width = 246;
			else
				text.width = 332;
			text.htmlText = _htmlText;
			
//			text.width = 250;
//			text.htmlText = _htmlText;
//			if(text.height > 250)
//			{
//				text.width = 250;
//				text.htmlText = _htmlText;
//			}
//			else if(text.height < 100)
//			{
//				text.width = 100;
			//				text.htmlText = _htmlText;
			//			}
			var tw:Number = text.width+20;
			var th:Number = text.height+20;
			if(useDrawBg)
			{
				bg.graphics.clear();
				bg.graphics.beginFill(0x000000,0.5);
				bg.graphics.drawRoundRect(0,0,tw,th,10,10);
				bg.graphics.endFill();
			}
			else
			{
				bg.width = tw;
				bg.height = th;
			}
		}
		
		/**
		 * [继承] 恢复资源
		 * 
		 */		
		public override function resume():void
		{
			super.resume();
			
		}
		
		/**
		 * [继承] 释放资源
		 * 
		 */		
		public override function dispose():void
		{
			super.dispose();
			
		}
	}
}