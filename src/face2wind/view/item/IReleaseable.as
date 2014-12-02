package face2wind.view.item
{
	/**
	 * 可释放资源的对象接口
	 * @author face2wind
	 * 
	 */	
	public interface IReleaseable
	{
		/**
		 * 恢复资源 
		 * 
		 */		
		function resume():void;
		
		/**
		 * 释放资源 
		 * 
		 */		
		function dispose():void;
		
		/**
		 * 被加到显示列表时执行  
		 */		
		function onHideHandler():void;
		
		/**
		 * 从显示列表移除时执行  
		 */			
		function onShowHandler():void;
	}
}