package face2wind.lib
{
	import face2wind.view.BaseSprite;
	import face2wind.view.item.IReleaseable;
	
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * 对象池管理器，避免频繁创建和删除对象
	 * @author face2wind
	 */
	public class ObjectPool
	{

		/**
		 * 最大保留的待回收对象数
		 */
		public static var MAX_POOLING_SIZE:int = 50;

		/**
		 * 对象池
		 */
		private static var pools:Dictionary = new Dictionary(false);


		/**
		 * Get the type of class's pooling
		 * @param type Class
		 * @return
		 *
		 */
		private static function getPool(type:Class):Array
		{
			return type in pools ? pools[type] : pools[type] = [];
		}

		/**
		 * This variable only use to record the object who was disposed and was pushed to the pooling,<br/>
		 * some times it would be repeat recycle.
		 */
		private static var dicPools:Dictionary = new Dictionary(false);

		/**
		 * To return the refrence dictionary
		 * @param type Class
		 * @return
		 *
		 */
		private static function getDicPool(type:Class):Dictionary
		{
			return type in dicPools ? dicPools[type] : dicPools[type] = new Dictionary();
		}

		/**
		 * Get an object of the specified type. If such an object exists in the pool then
		 * it will be returned. If such an object doesn't exist, a new one will be created.
		 *
		 * @param type The type of object required.
		 * @param parameters If there are no instances of the object in the pool, a new one
		 * will be created and these parameters will be passed to the object constrictor.
		 * Because you can't know if a new object will be created, you can't rely on these
		 * parameters being used. They are here to enable pooling of objects that require
		 * parameters in their constructor.
		 */
		public static function getObject(type:Class, ... parameters):*
		{
			var pool:Array = getPool(type);
			var dic:Dictionary = getDicPool(type);
			var obj:*;
			if (pool.length > 0)
			{
				obj = pool.pop();
				if (obj in dic)
					delete dic[obj];
				//从对象池里拿出来，要先resume一下
				if(obj is BaseSprite)
				{
					if(!(obj as BaseSprite).hasResume)
						(obj as BaseSprite).resume();
				}
				else if(obj is IReleaseable)
					(obj as IReleaseable).resume();
			}
			else
			{
				obj = construct(type, parameters);
			}
			return obj;
		}
		
		private static function construct(type:Class, parameters:Array):*
		{
			switch( parameters.length )
			{
				case 0:
					return new type();
				case 1:
					return new type( parameters[0] );
				case 2:
					return new type( parameters[0], parameters[1] );
				case 3:
					return new type( parameters[0], parameters[1], parameters[2] );
				case 4:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3] );
				case 5:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4] );
				case 6:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5] );
				case 7:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6] );
				case 8:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7] );
				case 9:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8] );
				case 10:
					return new type( parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8], parameters[9] );
				default:
					return null;
			}
		}

		/**
		 * Return an object to the pool for retention and later reuse. Note that the object
		 * still exists, so you need to clean up any event listeners etc. on the object so
		 * that the events stop occuring.
		 *
		 * @param object The object to return to the object pool.
		 * @param type The type of the object. If you don't indicate the object type then the
		 * object is inspected to find its type. This is a little slower than specifying the
		 * type yourself.
		 */
		public static function disposeObject(object:*, type:Class = null):void
		{
			if(null == object)
				return;
			if (!type)
			{
				var typeName:String = getQualifiedClassName(object);
				try
				{
					type = getDefinitionByName(typeName) as Class;
				}
				catch (e:*)
				{
					//do nothing	
					return;
				}
			}
			if(type == Array) // 是数组类型，则回收数组里面的内容
			{
				for (var i:int = 0; i < object.length; i++) 
					disposeObject(object[i]);
				return;
			}
			var dic:Dictionary = getDicPool(type);
			if (object in dic) // It's allready exist
				return;
			var pool:Array = getPool(type);
			if (pool.length < MAX_POOLING_SIZE)
			{
				pool.push(object);
				if(object is BaseSprite)
				{
					if((object as BaseSprite).hasResume)
						(object as BaseSprite).dispose();
				}
				else if(object is IReleaseable)
					(object as IReleaseable).dispose();
				dic[object] = true;
			}
		}


		/**
		 * Clear the type of the class all instance and remove the type class reference.
		 * This method usuelly do garbage collection.
		 * @param type The type of the object.
		 *
		 */
		public static function clearAllObjectByClass(type:Class):void
		{
			if (pools.hasOwnProperty(type))
			{
				delete pools[type];
			}
			if (dicPools.hasOwnProperty(type))
			{
				delete dicPools[type];
			}
		}

		/**
		 * This method release all object.
		 */
		public static function releaseAllRefrence():void
		{
			pools = new Dictionary(false);
			dicPools = new Dictionary(false);
		}

	}
}
