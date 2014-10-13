package face2wind.loading
{
	import face2wind.util.ArrayUtil;

	/**
	 * @author Michael.Huang
	 */
	public class Observable
	{

		/**
		 * Construct
		 */
		public function Observable()
		{
			observers = new Array();
		}


		/**
		 * 存储IObserver 列表
		 */
		protected var observers:Array;

		//-----------------------------------------------
		// changed
		//-----------------------------------------------
		protected var _changed:Boolean = false;

		/**
		 * 指示对象是否改变
		 */
		public function get changed():Boolean
		{
			return _changed;
		}

		/**
		 * @private
		 */
		public function set changed(value:Boolean):void
		{
			_changed = value;
		}

		/**
		 * 特殊通知，指定通知对象
		 */
		protected function notifyObserver(ob:Observable, o:IObserver, args:*):void
		{
			if (!changed)
				return;
			changed = false;
			var isIn:int = ArrayUtil.indexInArray(observers, o);
			if (isIn != -1)
				o.update(ob, args);
		}

		/**
		 * 通知观察者，并携带指定参数对象
		 * @param args
		 */
		public function notifyObserversByargs(args:*):void
		{
			if (!changed)
				return;
			changed = false;
			for (var i:int = 0; i < observers.length; i++)
			{
				(observers[i] as IObserver).update(this, args);
			}
		}

		/**
		 * 通知所有观察者
		 */		
		public function notifyObservers():void
		{
			notifyObserversByargs(null);
		}

		/**
		 * 添加一个观察 
		 * @param o IObserver
		 */		
		public function addObserver(o:IObserver):void
		{
			var isIn:int = ArrayUtil.indexInArray(observers, o);
			if (isIn == -1)
			{
				observers.push(o);
			}
		}

		/**
		 * 删除指定观察者对象
		 * @param o IObserver
		 */		
		public function removeObserver(o:IObserver):void
		{
			ArrayUtil.removeFromArray(observers, o);
		}
		
		/**
		 * 删除所有观察者对象
		 */
		public function removeAllObservers():void
		{
			observers.length = 0;
		}
	}
}
