package face2wind.util
{
	import flash.utils.ByteArray;

	/**
	 * 对象拷贝工具
	 * @author Face2wind
	 */
	public class ObjCloneUtil
	{
		public function ObjCloneUtil()
		{
		}
		
		/**
		 * 克隆一个对象（用ByteArray做对象拷贝）克隆前先registerClassAlias 
		 * @param obj
		 * @return 
		 * 
		 */		
		public static function clone(obj:*):*
		{
			if(null == clone)
				return null;
			var fooBA:ByteArray = new ByteArray();
			fooBA.writeObject(obj);
			fooBA.position = 0;
			return fooBA.readObject() ;
		}
	}
}
