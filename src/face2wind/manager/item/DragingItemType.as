package face2wind.manager.item
{
	/**
	 * 拖动类型（IdragingItem所需）
	 * @author face2wind
	 */
	public class DragingItemType
	{
		public function DragingItemType()
		{
		}
		/**
		 * 不能拖动（方便一些对象实时动态改变可拖动状态，而不想频繁注册和反注册） 
		 */		
		public static const NONE:int = 0;
		
		/**
		 * 只能拖进 
		 */		
		public static const DRAG_IN:int = 1;
		
		/**
		 * 只能拖出 
		 */		
		public static const DRAG_OUT:int = 2;
		
		/**
		 * 能拖进拖出 
		 */		
		public static const DRAG_IN_OUT:int = 3;
	}
}