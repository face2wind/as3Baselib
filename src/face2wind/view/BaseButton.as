package face2wind.view
{
	import flash.text.TextFieldAutoSize;
	
	import face2wind.uiComponents.CustomTextfield;
	

	/**
	 * 所有按钮的基类
	 * @author face2wind
	 */
	public class BaseButton extends SkinableSprite
	{
		/**
		 * 按钮构造函数 
		 * @param normalSkin 普通状态下的皮肤（也是鼠标弹起的皮肤）
		 * @param mouseDownSkin 鼠标按下的皮肤
		 * @param mouseOverSkin 鼠标移上的皮肤
		 * @param disableSkin 禁用状态下的皮肤
		 * 
		 */		
		public function BaseButton(normalSkin:String, mouseDownSkin:String = null, mouseOverSkin:String = null, disableSkin:String = null)
		{
			super();
			
			buttonMode = true;
			updateBtnSkins(normalSkin, mouseDownSkin, mouseOverSkin, disableSkin);
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			labelTxt = new CustomTextfield();
			labelTxt.mouseEnabled = false;
			labelTxt.selectable = false;
			labelTxt.mouseWheelEnabled = false;
			labelTxt.textColor = 0xffffff;
//			labelTxt.border = true;
			labelTxt.wordWrap = false;
//			labelTxt.size = 16;
//			labelTxt.height = 18;
			labelTxt.autoSize = TextFieldAutoSize.LEFT;
			otherLayer.addChild(labelTxt);
		}
		
		/**
		 * 重新设置按钮皮肤 
		 * @param normalSkin 普通状态下的皮肤（也是鼠标弹起的皮肤）
		 * @param mouseDownSkin 鼠标按下的皮肤
		 * @param mouseOverSkin 鼠标移上的皮肤
		 * @param disableSkin 禁用状态下的皮肤
		 * 
		 */	
		public function updateBtnSkins(normalSkin:String, mouseDownSkin:String = null, mouseOverSkin:String = null, disableSkin:String = null):void
		{
			setSkin(SkinableSprite.NORMAL_SKIN , normalSkin);
			setSkin(SkinableSprite.MOUSE_DOWN_SKIN , mouseDownSkin);
			setSkin(SkinableSprite.MOUSE_OVER_SKIN , mouseOverSkin);
			setSkin(SkinableSprite.DISABLE_SKIN , disableSkin);			
		}
		
		/**
		 * 按钮文本 
		 */		
		protected var labelTxt:CustomTextfield;
		
		private var _label:String = "";
		/**
		 * 设置当前按钮上显示的文字 
		 * @return 
		 * 
		 */
		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			if(null == value)
				return;
			_label = value;
			labelChange = true;
			propertyChange();
		}
		
		private var _labelColor:uint = 0xffffff;
		/**
		 * 标签颜色，默认白色 
		 */
		public function get labelColor():uint
		{
			return _labelColor;
		}
		/**
		 * @private
		 */
		public function set labelColor(value:uint):void
		{
			if(_labelColor == value)
				return;
			
			_labelColor = value;
			labelColorChange = true;
			propertyChange();
		}
		
		/**
		 * 宽高改变 
		 */		
		private var whChange:Boolean = false;
		/**
		 * label改变 
		 */		
		private var labelChange:Boolean = false;
		
		/**
		 * 标签颜色改变 
		 */		
		private var labelColorChange:Boolean = false;

		/**
		 * 更新label文本坐标，置于按钮最中央 
		 * 
		 */		
		private function updateLabelPosition():void
		{
			var tmpSize:Number = (_height/2)-2;
			if(tmpSize < 12)
				tmpSize = 12;
			labelTxt.size = tmpSize;
			labelTxt.x = (_width-labelTxt.width)/2;
			labelTxt.y = (_height-labelTxt.height)/2;
//			trace("labelTxt.x = " + labelTxt.y);
		}
		
		public override function set height(value:Number):void
		{
			super.height = value;
			whChange = true;
			propertyChange();
		}
		
		public override function set width(value:Number):void
		{
			super.width = value;
			whChange = true;
			propertyChange();
		}
		
		protected override function update():void
		{
			super.update();
			if(whChange)
			{
				updateLabelPosition();
				whChange = false;
			}
			if(labelChange)
			{
				labelTxt.text = label;
				labelTxt.htmlText = "<a href='event:1'>" + labelTxt.text + "</a>";
				updateLabelPosition();
				labelChange = false;
			}
			if(labelColorChange)
			{
				labelColorChange = false;
				labelTxt.textColor = labelColor;
			}
		}
	}
}
