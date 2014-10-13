package face2wind.loading
{
	/**
	 * 队列加载子项
	 * @author face2wind
	 */
	public class QueueLoadingItem
	{
		public function QueueLoadingItem()
		{
			
		}
		
		/**
		 * 素材名称（不是必须的） 
		 */		
		public var name:String = "";
		
		/**
		 * 素材路径（针对运行目录的相对路径） 
		 */		
		public var resUrl:String = "";
		
		/**
		 * 是否可自动回收（用于RuntimeResourceManager.load） 
		 */		
		public var canGC:Boolean = true;
		
		/**
		 *  如果加载的内容是SWF,加载完成后指示是否转换成MovieClipData（用于RuntimeResourceManager.load） 
		 */		
		public var transform:Boolean = false;
		
		private var _priorityLevel:int = PriorityEnum.NORMAL;
		/**
		 * 加载优先级（见PriorityEnum） （用于RuntimeResourceManager.load） 
		 */
		public function get priorityLevel():int
		{
			return _priorityLevel;
		}
		/**
		 * @private
		 */
		public function set priorityLevel(value:int):void
		{
			if(PriorityEnum.LOWEST > value) // 纠正非法的值
				value = PriorityEnum.LOWEST;
			if(PriorityEnum.REAL_TIME < value) // 纠正非法的值
				value = PriorityEnum.REAL_TIME;
			_priorityLevel = value;
		}

	}
}