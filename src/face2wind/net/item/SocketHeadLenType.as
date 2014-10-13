package face2wind.net.item
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * 协议头长度类型枚举
	 * @author face2wind
	 */
	public class SocketHeadLenType
	{
		public function SocketHeadLenType()
		{
		}
		
		/**
		 * 一个字节 （8位）
		 */		
		public static const ONE_BYTE:int = 1;
		
		/**
		 * 两个字节 （16位）
		 */		
		public static const TWO_BYTE:int = 2;
		
		/**
		 * 四个字节 （32位）
		 */		
		public static const FOUR_BYTE:int = 4;
		
		/**
		 * 八个字节 （64位）
		 */		
		public static const EIGHT_BYTE:int = 8;
		
		/**
		 * 读取指定长度的协议头 
		 * @param cacheData 需要从中读取的数据源
		 * @param type 字节大小，只识别本类定义过的
		 * @return 协议头的值
		 */		
		public static function getHeadLen(cacheData:ByteArray, type:int):Number
		{
			if(null == cacheData || type > cacheData.bytesAvailable)
				return 0;
			
			// 根据协议头长度来读取，默认以无符号来读取，因为协议体长度不可能是负数
			var headLen:Number = 0;
			switch(type)
			{
				case ONE_BYTE:headLen = cacheData.readUnsignedByte();break;
				case TWO_BYTE:headLen = cacheData.readUnsignedShort();break;
				case FOUR_BYTE:headLen = cacheData.readUnsignedInt();break;
				case EIGHT_BYTE: // 64位整数，默认用前32位做高位，后32位为低位
					var num1:uint=cacheData.readUnsignedInt();
					var num2:uint=cacheData.readUnsignedInt();
					var max:Number=uint.MAX_VALUE+1;
					headLen = Number (num1) * max+Number(num2);
					break; 
			}
			return headLen;
		}
		
		/**
		 * 组装协议头 
		 * @param headValue 协议头数据（协议体的长度值）
		 * @param type 协议头长度（字节），只识别本类定义过的
		 * @param endian 更改或读取数据的字节顺序；Endian.BIG_ENDIAN 或 Endian.LITTLE_ENDIAN。
		 * @return 
		 */		
		public static function packHeadBytes(headValue:Number, type:int, endian:String):ByteArray
		{
			if(0 >= headValue) // 非法协议头
			return null;
			
			var headByte:ByteArray = new ByteArray();
			headByte.endian = endian;
			switch(type)
			{
				case ONE_BYTE:headByte.writeByte(headValue);break;
				case TWO_BYTE:headByte.writeShort(headValue);break;
				case FOUR_BYTE:headByte.writeUnsignedInt(headValue);break;
				case EIGHT_BYTE: // 64位整数，默认用前32位做高位，后32位为低位
					var max:Number=uint.MAX_VALUE+1;
					headByte.writeInt(int(headValue/max));
					headByte.writeInt(int(headValue%max));
					break; 
			}
			headByte.position = 0;
			return headByte;
		}
	}
}