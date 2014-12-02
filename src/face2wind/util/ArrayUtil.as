package face2wind.util
{

	/**
	 * 数组工具类
	 * @author Administrator
	 */
	public class ArrayUtil
	{

		public static function eachIn(arr:Array, operation:Function):void
		{
			for (var i:int = 0; i < arr.length; i++)
			{
				operation(arr[i]);
			}
		}


		public static function setSize(arr:Array, size:int):void
		{
			if (size < 0)
				size = 0;
			if (size == arr.length)
			{
				return;
			}
			if (size > arr.length)
			{
				arr[size - 1] = undefined;
			}
			else
			{
				arr.splice(size);
			}
		}


		public static function removeFromArray(arr:Array, obj:Object):int
		{
			if(arr && obj)
			{
				var index:int = arr.indexOf(obj);
				if(index != -1)
				{
					arr.splice(index, 1);
					return index;
				}
			}
			return -1;
		}

		public static function removeAllFromArray(arr:Array, obj:Object):void
		{
			for (var i:int = 0; i < arr.length; i++)
			{
				if (arr[i] == obj)
				{
					arr.splice(i, 1);
					i--;
				}
			}

		}

		public static function removeAllBehindSomeIndex(array:Array, index:int):void
		{
			if (index <= 0)
			{
				array.splice(0, array.length);
				return;
			}
			var arrLen:int = array.length;
			for (var i:int = index + 1; i < arrLen; i++)
			{
				array.pop();
			}
		}

		public static function indexInArray(arr:Array, obj:Object):int
		{
			if(arr && obj)
			{
				return arr.indexOf(obj);
			}
			return -1;
		}

		public static function isInArray(arr:Array, obj:Object):Boolean
		{
			return indexInArray(arr, obj) > -1;
		}

		public static function cloneArray(arr:Array):Array
		{
			return arr.concat();
		}
		
		
		/**
		 *根据某个属性对数组进行排序,
		 * @flag 对象属性
		 * @_sort 1为从小到大 -1为从大到小 
		 */		
		public static function sortAry(ary:Array,flag:String,_sort:int):void
		{
			ary.sort(sortFun);
			function sortFun(aa:Object,bb:Object):int
			{
				var aid:int = aa[flag];
				var bid:int = bb[flag];
				if (aid > bid)
				{
					return 1 * _sort;
				}
				if (aid < bid)
				{
					return -1 * _sort;
				}
				if (aid == bid)
				{
					return 0;
				}
				return 0;
			}
		}
		
		/**
		 * 返回没有重复项的数组
		 * @param arr 原数组
		 * @return 
		 */		
		public static function createUniqArray(arr:Array):Array
		{
			var temp:Array = [];
			for(var i:int=0; i<arr.length; i++)
			{
				if(temp.indexOf(arr[i])==-1)
					temp.push(arr[i])  
			}
			return temp;
		}
	}
}
