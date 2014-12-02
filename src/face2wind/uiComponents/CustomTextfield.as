package face2wind.uiComponents
{
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.system.IME;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import face2wind.view.BaseSprite;

    /**
     * 自定义文本显示类。
     *  可 设置字体，颜色 ，字边缘颜色..
     * @author liudisong
     *
     */
    public class CustomTextfield extends TextField
    {
        /**
         * 文本格式设置对象
         */
        private var _textFormat:TextFormat;
        /**
         * 文字描边
         */
        private var _glowFilter:GlowFilter;
        /**
         * 滤镜数组
         */
        private var _filterArray:Array;

        /**是否添加下划线效果*/
        private var _isUnderLine:Boolean;
        private var _tempHtmLText:String;

        private var _isAutoSize:Boolean = true;
		
		public static var fontStyle:String = "黑体";//系统显示统一字体
		
		private static var _helpTextfield:CustomTextfield;
		
		/**
		 * 携带的数据 
		 */		
		public var data:Object;

        public function CustomTextfield(isGlow:Boolean = true
            , glowFilter:GlowFilter = null)
        {
            super();
            if (isGlow)
            {
                _filterArray = [];
                if (glowFilter == null)
                {
                    _glowFilter = new GlowFilter(0x0, 1, 2, 2, 5);
                }
                else
                {
                    _glowFilter = glowFilter;
                }

                _filterArray.push(_glowFilter);
                filters = _filterArray;
            }
            _textFormat = new TextFormat();
//			设置默认显示
            _textFormat.align = TextFormatAlign.LEFT;
            _textFormat.color = 0xffffff;
            _textFormat.size = 12;
            _textFormat.font = fontStyle;
			_textFormat.letterSpacing = 1;
            defaultTextFormat = _textFormat;
            height = 21; //默认高度
            _isUnderLine = false;
			selectable = false;
            mouseEnabled = false; // 默认不接收鼠标事件
            mouseWheelEnabled = false;
        }

        /**
         * 文本宽高为文字宽高
         */
        public function setWidthHeightFromText():void
        {
            width = textWidth + 5;
            height = textHeight + 5;
        }

        /**
         * 设置对其方式
         * @param value
         *
         */
        public function set align(value:String):void
        {
            _textFormat.align = value;
            defaultTextFormat = _textFormat;
            text = text;
        }

        /**
         * 指定文本是否为粗体字。默认值为 null，这意味着不使用粗体字。如果值为 true，则文本为粗体字。
         * @param value
         *
         */
        public function set bold(value:Object):void
        {
            _textFormat.bold = value;
            defaultTextFormat = _textFormat;
            text = text;
        }

        /**
         * 指示文本的颜色。
         * 包含三个 8 位 RGB 颜色成分的数字；例如，0xFF0000 为红色，0x00FF00 为绿色。默认值为 null，这意味着 Flash Player 使用黑色 (0x000000)。
         * @param value
         *
         */
        public function set color(value:Object):void
        {
            _textFormat.color = value;
            defaultTextFormat = _textFormat;
            text = text;
        }

        /**
         * 使用此文本格式的文本的字体名称，以字符串形式表示。默认值为 null，这意味着 Flash Player 对文本使用 Times New Roman 字体
         * @param value
         *
         */
        public function set font(value:String):void
        {
            _textFormat.font = value;
            defaultTextFormat = _textFormat;
            text = text;
        }

        /**
         * 使用此文本格式的文本的磅值。默认值为 null，这意味着使用的磅值为 12
         * @param value
         *
         */
        public function set size(value:Object):void
        {
            _textFormat.size = value;
            defaultTextFormat = _textFormat;
            text = text;
        }

        /**
         * 设置字间距
         * @param value
         *
         */
        public function set letterSpacing(value:Object):void
        {
            _textFormat.letterSpacing = value;
            defaultTextFormat = _textFormat;
            text = text;
        }

        public function get letterSpacing():Object
        {
            return _textFormat.letterSpacing;
        }

        /**
         * 设置行间距
         * @param value
         *
         */
        public function set leading(value:Object):void
        {
            _textFormat.leading = value;
            defaultTextFormat = _textFormat;
            text = text;
        }

        /**
         * 设置下划线
         * @param value
         *
         */
        public function set underline(value:Object):void
        {
            _textFormat.underline = value;
            defaultTextFormat = _textFormat;
            text = text;
        }

        /**
         * 设置字体边缘的颜色
         * @param value
         *
         */
        public function set textBorderColor(value:uint):void
        {
            _glowFilter.color = value;
            filters = _filterArray;

        }

        /**
         * 设置边缘的透明度
         * @param value
         *
         */
        public function set textBorderAlpha(value:Number):void
        {
            _glowFilter.alpha = value;
            filters = _filterArray;

        }

        /**
         * 设置字体边缘X方向模糊度
         * @param value
         *
         */
        public function set textBorderBlurX(value:Number):void
        {
            _glowFilter.blurX = value;
            filters = _filterArray;
        }

        /**
         * 设置字体边缘Y方向的模糊度
         * @param value
         *
         */
        public function set textBorderBlurY(value:Number):void
        {
            _glowFilter.blurY = value;
            filters = _filterArray;
        }

        /**
         * 印记或跨页的强度。
         * 该值越高，压印的颜色越深，而且发光与背景之间的对比度也越强。有效值为 0 到 255。默认值为 2。
         * @param value
         *
         */
        public function set textBorderStrength(value:Number):void
        {
            _glowFilter.strength = value;
            filters = _filterArray;
        }

        /**
         *  指定发光是否为内侧发光。 值 true 表示内侧发光。 默认值为 false，即外侧发光（对象外缘周围的发光）。
         * @return
         *
         */
        public function get inner():Boolean
        {
            return _glowFilter.inner;
        }

        /**
         * 指定发光是否为内侧发光。 值 true 表示内侧发光。 默认值为 false，即外侧发光（对象外缘周围的发光）。
         * @param value
         *
         */
        public function set inner(value:Boolean):void
        {
            _glowFilter.inner = value;
            filters = _filterArray;
        }

        override public function set defaultTextFormat(format:TextFormat):void
        {
            if (styleSheet != null)
            {
                styleSheet = null;
            }
            format.font = fontStyle;
            super.defaultTextFormat = format;

            _textFormat = format;
        }


        /**
         * 销毁对象资源
         *
         */
        public function dispose():void
        {
//			ObjectShare.getInstance().setObject(this);
        }

        override public function set type(value:String):void
        {
            super.type = value;
            if (TextFieldType.INPUT == value)
            {
				selectable = true;
                addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
                addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
            }
        }

        private function focusInHandler(e:FocusEvent):void
        {
            IME.enabled = true;
        }

        private function focusOutHandler(e:FocusEvent):void
        {
            IME.enabled = false;
        }

        public function set isUnderLine(b:Boolean):void
        {
            _isUnderLine = b;
            if (_isUnderLine)
            {
                this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
                this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
            }
            else
            {
                this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
                this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
            }
        }

        public function get isUnderLine():Boolean
        {
            return _isUnderLine;
        }

        private function rollOverHandler(event:MouseEvent):void
        {
            _tempHtmLText = htmlText;
            htmlText = "<u>" + htmlText + "</u>";
        }

        private function rollOutHandler(event:MouseEvent):void
        {
            htmlText = _tempHtmLText;
        }

        override public function set htmlText(value:String):void
        {
			if(null == value) //防止传入一个空值报错
				value = "";
			
            super.htmlText = value;
            defaultTextFormat = _textFormat;

            if (_isAutoSize == false)
                return;

            //判断文本内容是否能够全部显示， 不能显示则进行自适应  设置了autoSize的不处理，因为无法正常获取文本宽度
            if (autoSize != "none" || type == TextFieldType.INPUT)
                return;
				
            //如果是设置了自动换行，应该是考虑了宽度位置，这个时候宽度不做处理
            if ((textWidth + 5) > width && !(wordWrap || multiline))
                width = textWidth + 5;
            if (textHeight > height)
                height = textHeight + 5;
        }

        override public function set text(value:String):void
        {
			if(null == value) //防止传入一个空值报错
				value = "";
			
            super.text = value;

            if (_isAutoSize == false)
                return;

            //判断文本内容是否能够全部显示， 不能显示则进行自适应  设置了autoSize的不处理，因为无法正常获取文本宽度
            if (autoSize != "none" || type == TextFieldType.INPUT)
                return;
            //如果是设置了自动换行，应该是考虑了宽度位置，这个时候宽度不做处理
            if ((textWidth + 5) > width && !(wordWrap || multiline))
                width = textWidth + 5;
            if (textHeight > height)
                height = textHeight + 5;
        }

        /**
         * 显隐滤镜<br/>
         * lua添加于2012/8/2
         * @param b
         *
         */
        public function setFiltersShow(b:Boolean):void
        {
            if (b)
                filters = _filterArray;
            else
                filters = null;
        }

        public function set isAutoSize(value:Boolean):void
        {
            _isAutoSize = value;
        }
		
		/**
		 * 调整文本位置 
		 * @param xpos
		 * @param ypos
		 * 
		 */		
		public function move(xpos:Number,ypos:Number):void
		{
			this.x = xpos;
			this.y = ypos;
		} 
		
		/**
		 * 快速创建CustomTextField对象并返回
		 * @param x坐标
		 * @param y坐标
		 * @param text 文本内容
		 * @param obj 被addChild的对象 （可选）
		 * @return 
		 * 
		 */		
		public static function quickCreate(x:Number,y:Number,text:String,obj:BaseSprite = null):CustomTextfield
		{
			var TF:CustomTextfield = new CustomTextfield();
			TF.move(x,y);
			TF.htmlText = text;
			if(obj)
			{
				obj.addChild(TF);
			}
//			if(-1 != color)
//			{
//				TF.color = color
//			}
			return TF;
		}
		
    }
}
