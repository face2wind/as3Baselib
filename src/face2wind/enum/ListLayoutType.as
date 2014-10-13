package face2wind.enum
{
	/**
	 * 列表对象布局类型
	 * @author Face2wind
	 */
	public class ListLayoutType
	{
		public function ListLayoutType()
		{
		}
		//定义这两个变量，用于检测是否合理布局类型
		private static var MIN:int = 0;
		private static var MAX:int = 4;
			
		/**
		 * 垂直布局 
		 */		
		public static var VERTICAL:int = 1;
		
		/**
		 * 水平布局 
		 */		
		public static var HORIZONTAL:int = 2;
		
		/**
		 * 先水平，再垂直（水平布局到列表宽度后换行） 
		 */		
		public static var HORIZONTAL_TO_VERTICAL:int = 3;
		
		/**
		 * 检测对应的值是否是已定义布局类型 
		 * @param value
		 * @return 
		 */		
		public static function check(value:int):Boolean
		{
			return (MIN < value && MAX > value);
		}
	}
}
