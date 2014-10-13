package face2wind.net
{
	import face2wind.lib.Debuger;
	import face2wind.net.SocketConnection;
	import face2wind.net.item.ICommandMap;
	import face2wind.net.item.SocketDataType;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.describeType;
	
	/**
	 * 逻辑层的socket链接器<br/>
	 * 约定协议体的内容为：协议号（2字节）+协议内容
	 * @author face2wind
	 */
	public class GameSocket extends SocketConnection
	{
		/**
		 * 构造函数
		 */		
		public function GameSocket()
		{
			super();
			if(instance)
				throw new Error("GameSocket is singleton class and allready exists!");
			instance = this;
			endian = Endian.LITTLE_ENDIAN;
			cmdSocketListenerDic = new Dictionary();
		}
		
		/**
		 * 单例
		 */
		private static var instance:GameSocket;
		/**
		 * 获取单例
		 */
		public static function getInstance():GameSocket
		{
			if(!instance)
				instance = new GameSocket();
			
			return instance;
		}
		
		/**
		 * 根据协议号来监听数据返回的函数列表 
		 */		
		private var cmdSocketListenerDic:Dictionary;
		
		private var _cmdMap:ICommandMap;
		/**
		 * 协议映射器 
		 */
		public function get cmdMap():ICommandMap
		{
			return _cmdMap;
		}
		/**
		 * @private
		 */
		public function set cmdMap(value:ICommandMap):void
		{
			_cmdMap = value;
		}
		
		
		/**
		 * 管理器自身处理协议体 
		 * @param data 从socket里读取到的协议体
		 */		
		protected override function handleBodyBytes(data:ByteArray):void
		{
			var cmd:int = data.readUnsignedShort(); // 读取2字节的协议号
			var scmd:* = unpackData("SC"+cmd, data);
			Debuger.show(Debuger.SOCKET, "Receive Socket SC"+cmd+" , Size : "+data.length+" byte  ((((((((((((((((((((((((((((((((((((((((((");
			var cmdSocketListenerList:Array = cmdSocketListenerDic[cmd];
			for (var i:int = 0; i < cmdSocketListenerList.length; i++) 
			{
				var handler:Function = cmdSocketListenerList[i] as Function;
				if(scmd)  // 有协议数据
					handler.apply(null, [scmd]);
				else  // 空协议
					handler.apply();
			}
		}
		
		/**
		 * 发送一个协议内容 
		 * @param cmd 协议号
		 * @param data 协议内容对象
		 */		
		public function sendCmdMessage(cmd:int, data:*):void
		{
			if(!isConnected) // socket还未连接上，不处理
			{
				Debuger.show(Debuger.SOCKET, "Socket has not connected , can't send CMD Message ( " + cmd + " )");
				return;
			}
			var bytes:ByteArray = new ByteArray();
			bytes.endian = endian;
			bytes.writeShort(cmd);
			bytes.writeBytes( packData("CS"+cmd, data) );
			Debuger.show(Debuger.SOCKET, "Send Socket CS"+cmd+" , Size : "+bytes.length+" byte  >>>>>>>>>>>>>>>>>>>>>");
			sendBytesData(bytes);
		}
		
		/**
		 * 增加一个协议监听 
		 * @param cmd 协议号
		 * @param handler 处理协议的函数
		 */		
		public function addCmdListener(cmd:int, handler:Function):void
		{
			if(null == handler)
				return;
			
			if(undefined == cmdSocketListenerDic[cmd])
				cmdSocketListenerDic[cmd] = [];
			var cmdSocketListenerList:Array = cmdSocketListenerDic[cmd];
			if(-1 == cmdSocketListenerList.indexOf(handler))
				cmdSocketListenerList.push(handler);
		}
		
		/**
		 * 移除一个协议监听 
		 * @param cmd 协议号
		 * @param handler 处理协议的函数
		 */		
		public function removeCmdListener(cmd:int, handler:Function):void
		{
			if(null == handler)
				return;
			
			if(undefined == cmdSocketListenerDic[cmd])
				return;
			var cmdSocketListenerList:Array = cmdSocketListenerDic[cmd];
			if(-1 != cmdSocketListenerList.indexOf(handler))
				cmdSocketListenerList.splice(cmdSocketListenerList.indexOf(handler));
		}
		
		/**
		 * 打包逻辑层传来的数据，用于发送给服务端
		 * @param className 类名（用于在协议映射器里查询）
		 * @param object 需要发送的参数对象
		 * @return
		 */
		private function packData(className:String, cmdObject:Object):ByteArray
		{
			if(null == cmdMap)
			{
				throw new Error("GameSocket can not work with cmdMap is null ! ");
				return null;
			}
			
			var byteArray:ByteArray=new ByteArray();
			byteArray.endian = endian;
			var tmpBytearray:ByteArray;
			var attributes:Array = cmdMap.getCMDAttributes(className);
			for each (var attribute:Object in attributes)
			{
				var isNormalType:Boolean = SocketDataType.isNormalType(attribute.type);
				if(isNormalType) // 是基础数据类型，直接解析 ===============================
					SocketDataType.writeData(cmdObject[attribute.name], byteArray, attribute.type);
				else if(SocketDataType.ARRAY == attribute.type) // 数组  =======================
				{
					var arrayLen:uint = cmdObject[attribute.name].length;
					byteArray.writeShort(arrayLen); // 先写入数组长度
					var arrIsNormalType:Boolean = SocketDataType.isNormalType(attribute.subType);
					for (var i:int=0; i < arrayLen; i++)
					{
						var arrValue:* = cmdObject[attribute.name][i]; // 数组里的值
						if(arrIsNormalType)
							SocketDataType.writeData(arrValue, byteArray, attribute.subType);
						else  // 数组里面只包含一个数组的情况就不处理了，一般不可能出现（二维数组先扁平化再发过来），所以这里直接当作其他数据类型写入
						{
							tmpBytearray = packData(attribute.subType, arrValue);
							tmpBytearray.position = 0;
							byteArray.writeBytes( tmpBytearray );
						}
					}
				}
				else //  自定义类型 ==================================================
				{
					tmpBytearray = packData(attribute.type, cmdObject[attribute.name]);
					tmpBytearray.position = 0;
					byteArray.writeBytes( tmpBytearray );
				}
			}
			return byteArray;
		}
		
		/**
		 * 将二进制数据映射到对象，供逻辑层使用
		 * @param className 类名（用于在协议映射器里查询）
		 * @param valueObject  需要映射的对象
		 * @return
		 */
		private function unpackData(className:String, dataBytes:ByteArray):Object
		{
			if(null == cmdMap)
			{
				throw new Error("GameSocket can not work with cmdMap is null ! ");
				return null;
			}
			
			var attributes:Array = cmdMap.getCMDAttributes(className) // 获取到当前类内部属性列表
			var valueClass:Class = cmdMap.getScmdClass(className); // 获取到当前类对象
			if(null == attributes || null == valueClass)
				return null;
			var valueObject:* = new valueClass();
			for each (var attribute:Object in attributes)
			{
				if (dataBytes.bytesAvailable <= 0)//如果数据包没有了  将停止解析
					break;
				
				var isNormalType:Boolean = SocketDataType.isNormalType(attribute.type);
				if(isNormalType) // 是基础数据类型，直接解析 ===============================
					valueObject[attribute.name] = SocketDataType.readData(dataBytes, attribute.type);
				else if(SocketDataType.ARRAY == attribute.type) // 数组  =======================
				{
					var arrayLen:uint=dataBytes.readShort(); // 先读取数组长度
					valueObject[attribute.name] = []; // 先清理一下协议定义里方便阅读的类名
					var arrAttribute:Array=valueObject[attribute.name];
					var arrIsNormalType:Boolean = SocketDataType.isNormalType(attribute.subType);
					for (var i:int=0; i < arrayLen; i++)
					{
						if(arrIsNormalType)
							arrAttribute.push(SocketDataType.readData(dataBytes, attribute.subType));
						else  // 数组里面只包含一个数组的情况就不处理了，一般不可能出现（二维数组先扁平化再发过来），所以这里直接当作其他数据类型解析
							arrAttribute.push( unpackData( attribute.subType, dataBytes) );
					}
				}
				else //  自定义类型 ==================================================
				{
					valueObject[attribute.name] = unpackData( attribute.type, dataBytes);
				}
			}
			return valueObject;
		}
	}
}