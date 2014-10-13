package face2wind.net.item
{
	import flash.utils.ByteArray;

	/**
	 * 网络协议交互用的 - 数据类型
	 * @author face2wind
	 */
	public class SocketDataType
	{
		public function SocketDataType()
		{
		}
		
		/**
		 * 有符号8位整型 
		 */		
		public static const INT8:String = "int8";
		
		/**
		 * 无符号8位整型 
		 */		
		public static const UINT8:String = "uint8";
		
		/**
		 * 有符号16位整型 
		 */		
		public static const INT16:String = "int16";
		
		/**
		 * 无符号16位整型 
		 */		
		public static const UINT16:String = "uint16";
		
		/**
		 * 有符号32位整型 
		 */		
		public static const INT32:String = "int32";
		
		/**
		 * 无符号32位整型 
		 */		
		public static const UINT32:String = "uint32";
		
		/**
		 * 有符号64位整型 （AS的Number类型精度只有52位[另加1位符号位，总共53位]，所以这个值要慎用）
		 */		
		public static const INT64:String = "int64";
		
		/**
		 * 无符号64位整型 （理论上是不支持这个数据类型的，写出来提示一下）
		 */		
		public static const UINT64:String = "uint64";
		
		/**
		 * 字符串类型 
		 */		
		public static const STRING:String = "string";
		
		/**
		 * 数组类型 
		 */		
		public static const ARRAY:String = "array";
		
		/**
		 * 是否普通数据类型，数组和其他类型则返回false 
		 * @param type
		 * @return 
		 */		
		public static function isNormalType(type:String):Boolean
		{
			switch(type)
			{
				case INT8:
				case INT16:
				case INT32:
				case INT64:
				case UINT8:
				case UINT16:
				case UINT32:
				case UINT64:
				case STRING:
					return true;
			}
			return false;
		}
		
		/**
		 * 根据指定的数据类型，从指定二进制数据里读出数据并返回
		 * @param dataBytes 数据源
		 * @param type 数据类型
		 * @return 读取到的数据（根据不同数据类型返回不同类型的数据）
		 */		
		public static function readData(dataBytes:ByteArray, type:String):*
		{
			if (type == SocketDataType.UINT32)
			{
				return dataBytes.readShort();
			}
			else if (type == SocketDataType.STRING)
			{
				return dataBytes.readUTF();
			}
			else if (type == SocketDataType.INT64)
			{
				var num1:uint=dataBytes.readUnsignedInt();
				var num2:uint=dataBytes.readUnsignedInt();
				var max:Number=uint.MAX_VALUE+1;
				var num:Number=Number (num1) * max+Number(num2);
				return num;
			}
			else if (type == SocketDataType.INT32)
			{
				return dataBytes.readInt();
			}
			else if (type == SocketDataType.INT16)
			{
				return dataBytes.readShort();
			}
			else if (type == SocketDataType.INT8)
			{
				return dataBytes.readByte();
			}
			return null;
		}
		
		/**
		 * 把指定的值按照指定类型写入指定byteArray 
		 * @param value 要写入的值
		 * @param byteArray 待写入的数据
		 * @param type 数据类型
		 */		
		public static function writeData(value:* , byteArray:ByteArray, type:String):void
		{
			if (type == STRING)
			{
				byteArray.writeUTF(String(value));
			}
			else if (type == INT64)
			{
				var max:Number = uint.MAX_VALUE+1;
				byteArray.writeInt(int(value/max));
				byteArray.writeInt(int(value%max));
			}
			else if (type == UINT32)
			{
				byteArray.writeShort(uint(value));
			}
			else if (type == INT32)
			{
				byteArray.writeInt(int(value));
			}
			else if (type == INT16)
			{
				byteArray.writeShort(value);
			}
			else if (type == INT8)
			{
				byteArray.writeByte(value);
			}
		}
	}
}