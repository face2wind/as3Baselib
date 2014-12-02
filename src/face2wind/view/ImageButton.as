package face2wind.view
{
	/**
	 * 图片按钮 - 简单封装基础皮肤，方便设置图片按钮
	 * @author face2wind
	 */
	public class ImageButton extends SkinableSprite
	{
		/**
		 * 空类型（没有后缀说明是用反射获取swf中的素材，非空则动态加载） 
		 */		
		public static const EMPTY:String = "";
		
		/**
		 * png类型
		 */		
		public static const PNG:String = ".png";
		
		/**
		 * jpg类型
		 */		
		public static const JPG:String = ".jpg";
		
		/**
		 * 按钮构造函数 （根据前后缀加载对应的素材：前缀+[1-4]（代表[普通，按下，鼠标移上，灰掉]皮肤）+后缀，比如 "res/icon" ".png"，或者 "btn" ""）
		 * @param normalSkin 按钮皮肤前缀
		 * @param endType 按钮皮肤后缀，默认是EMPTY
		 * 
		 */		
		public function ImageButton(normalSkin:String , endType:String = "")
		{
			super();
			
			buttonMode = true;
			updateBtnSkins(normalSkin, endType);
		}
		

		/**
		 * 重新设置按钮皮肤  （根据前后缀加载对应的素材：前缀+[1-4]（代表[普通，按下，鼠标移上，灰掉]皮肤）+后缀，比如 "res/icon" ".png"，或者 "btn" ""）
		 * @param normalSkin 按钮皮肤前缀
		 * @param endType 按钮皮肤后缀，默认是EMPTY
		 * 
		 */
		public function updateBtnSkins(normalSkin:String , endType:String = EMPTY):void
		{
			setSkin(SkinableSprite.NORMAL_SKIN , normalSkin + "1" + endType);
			setSkin(SkinableSprite.MOUSE_DOWN_SKIN , normalSkin + "2" + endType);
			setSkin(SkinableSprite.MOUSE_OVER_SKIN , normalSkin + "3" + endType);
			setSkin(SkinableSprite.DISABLE_SKIN , normalSkin + "4" + endType);	
		}
	}
}