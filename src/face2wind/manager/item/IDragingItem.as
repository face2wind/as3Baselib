package face2wind.manager.item
{
	import flash.display.IBitmapDrawable;

	/**
	 * 拖拽对象接口 
	 * @author face2wind
	 */	
	public interface IDragingItem
	{
		/**
		 *  有数据拖拽进来的时候会执行此函数，
		 * @param value
		 * @return 设置数据是否成功（是否可拖进来）
		 * 
		 */		
		function setDraginData(value:*):Boolean;
		
		/**
		 * 从此对象拖拽出去的时候，会调用此函数获取对应的数据，设到目的对象中 
		 * @return 
		 * 
		 */		
		function getDraginData():*;
		
		/**
		 * 拖动时用于生成拖动bitmap的对象（照这个对象draw一个bitmap） 
		 * @return 
		 * 
		 */		
		function get dragingBitmapObj():IBitmapDrawable;
		
		/**
		 *  确定是否需要自动设置数据（拖动完毕的时候，除了抛拖动事件外，还会直接交换两个格子的数据）
		 * @return 
		 * 
		 */		
		function get canAutoSetData():Boolean;
		
		/**
		 * 在拖出时，是否克隆一个对象拖出去，false时表示直接把原对象置空 
		 * @return 
		 * 
		 */		
		function get isClone():Boolean;
		
		/**
		 * 拖拽暗号（key），相同key的对象才能互相拖拽数据  
		 * @return 
		 * 
		 */		
		function get draginSign():String;
		
		/**
		 * 拖动的对象类型（用于判断不同类型对象间拖动） DragingObjectType
		 * @return 
		 * 
		 */		
		function get itemType():int;
			
		/**
		 * 拖拽类型<br/>
		 * 见DragingItemType
		 * @return 
		 */		
		function get dragingType():int;
		
		/**
		 * 当拖动到不是接收区（拖拽到的目的地不是IDragingItem对象）<br/>
		 * 会触发这个函数
		 */		
		function onDragToEmpty():void;
	}
}