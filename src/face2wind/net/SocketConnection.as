package face2wind.net
{
	import face2wind.event.ParamEvent;
	import face2wind.lib.Debuger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import face2wind.net.item.SocketHeadLenType;
	
	/**
	 * 自定义socket连接管理器<br/>
	 * 约定协议内容为：协议头+协议体（协议头记录了协议体的数据长度，协议体则由逻辑层约定）<br/>
	 * 若不是协议头+协议体这样的通讯定义，则不要用此类
	 * @author face2wind
	 */
	public class SocketConnection extends EventDispatcher
	{
		/**
		 * 连接成功事件 
		 */		
		public static const CONNECTED:String = "SocketConnection_CONNECTED";
		
		/**
		 * 出错事件 
		 */		
		public static const ERROR:String = "SocketConnection_ERROR";
		
		/**
		 * 连接对象 
		 */		
		private var _socket:Socket;
		
		/**
		 * 协议头的长度（字节）建议用SocketHeadLenType
		 */
		private var _headByte:int = SocketHeadLenType.TWO_BYTE;
		/**
		 * 协议头的长度（字节）建议用SocketHeadLenType
		 */
		public function set headByte(value:int):void
		{
			_headByte = value;
		}
		
		private var _isConnected:Boolean = false;
		/**
		 * 是否已经连接上 
		 */
		public function get isConnected():Boolean
		{
			return _isConnected;
		}
		
		private var _listeningEvent:Boolean = false;
		/**
		 * 设置当前socket是否监听必要事件 
		 * @param value
		 */
		public function set listeningEvent(value:Boolean):void
		{
			if(_listeningEvent == value)
				return;
			_listeningEvent = value;
			if(_listeningEvent)
			{
				_socket.addEventListener(Event.CLOSE, closeHandler);
				_socket.addEventListener(Event.CONNECT, connectHandler);
				_socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				_socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			}
			else
			{
				_socket.removeEventListener(Event.CLOSE, closeHandler);
				_socket.removeEventListener(Event.CONNECT, connectHandler);
				_socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				_socket.removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			}
		}
		
		private var _serverIP:String = "127.0.0.1";
		/**
		 * 服务器IP地址
		 */
		public function get serverIP():String
		{
			return _serverIP;
		}
		
		private var _serverPort:int = 8888;
		/**
		 * 服务器端口
		 */
		public function get serverPort():int
		{
			return _serverPort;
		}
		
		public function SocketConnection()
		{
			super();
			
			if(instance)
				throw new Error("SocketConnection is singleton class and allready exists!");
			instance = this;
			
			_socket = new Socket();
			_socket.endian = Endian.BIG_ENDIAN;
			
			cacheData = new ByteArray();
			cacheData.endian = endian;
		}
		
		/**
		 * 单例
		 */
		private static var instance:SocketConnection;
		/**
		 * 获取单例
		 */
		public static function getInstance():SocketConnection
		{
			if(!instance)
				instance = new SocketConnection();
			
			return instance;
		}
		
		/**
		 *  表示数据的字节顺序。可能的值为来自 flash.utils.Endian 类的常量、Endian.BIG_ENDIAN（默认值） 或 Endian.LITTLE_ENDIAN。
		 */
		public function get endian():String
		{
			return _socket.endian;
		}
		/**
		 * @private
		 */
		public function set endian(value:String):void
		{
			_socket.endian = value;
			cacheData.endian = endian;
		}

		
		/**
		 * 发起连接 
		 * @param ip 连接的IP
		 * @param port 连接的端口
		 */		
		public function connectTo(ip:String = "127.0.0.1", port:int = 8888):void
		{
			_serverIP = ip;
			_serverPort = port;
			listeningEvent = true;
			_socket.connect(_serverIP, _serverPort);
			Debuger.show(Debuger.SOCKET,"Socket try to connect");
		}
		
		/**
		 * 按照上一次的IP和端口，重新连接（若当前已连接上，则忽略） 
		 */		
		public function reconnect():void
		{
			if(_socket.connected)
				return;
			
			listeningEvent = true;
			_socket.connect(_serverIP, _serverPort);
			Debuger.show(Debuger.SOCKET,"Socket try to reconnect");
		}
		
		/**
		 * 关闭连接 
		 */		
		public function close():void
		{
			listeningEvent = false;
			Debuger.show(Debuger.SOCKET,"Socket try to close");
			_socket.close();
		}
		
		/**
		 *当服务端关闭后触发
		 * @param event
		 *
		 */
		private function closeHandler(event:Event):void
		{
			_isConnected = false;
			Debuger.show(Debuger.SOCKET,"Socket has closed");
			this.dispatchEvent(new ParamEvent(ERROR,{code:1}));
		}
		
		/**
		 * 连接socket成功 
		 * @param event
		 */		
		private function connectHandler(event:Event):void
		{
			_isConnected = true;
			Debuger.show(Debuger.SOCKET,"Socket connected");
			this.dispatchEvent(new ParamEvent(CONNECTED));
		}
		
		/**
		 * IO异常
		 * @param event
		 *
		 */
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			_isConnected = false;
			this.dispatchEvent(new ParamEvent(ERROR,{code:2}));
			Debuger.show(Debuger.SOCKET,"Socket IO Error : " + event.text);
			try
			{
				_socket.close();
			}
			catch (e:Error)
			{
			}
		}
		
		/**
		 *安全异常
		 * @param event
		 *
		 */
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			_isConnected = false;
			this.dispatchEvent(new ParamEvent(ERROR,{code:3}));
			Debuger.show(Debuger.SOCKET,"Socket security Error : " + event.text);
		}
		
		/**
		 * 读取当前协议内容时的缓存（数据没来齐之前的缓存）
		 */		
		private var cacheData:ByteArray;
		
		/**
		 * 协议体长度（若为0，则表示协议头还没读取） 
		 */		
		private var bytesBodyLen:Number = 0;
		
		/**
		 *收到服务端发送数据触发
		 * @param event
		 */
		private function socketDataHandler(event:ProgressEvent):void
		{
			_socket.readBytes(cacheData, cacheData.length, _socket.bytesAvailable);
			
			var tmpBytes:ByteArray; // 临时用的数据
			
			if(0 == bytesBodyLen)  // 当前正在等待接收协议头数据
			{
				if(_headByte > cacheData.bytesAvailable) // 当前接收到的数据不够协议头长度，等待下次数据过来
					return;
				
				cacheData.position = 0;
				bytesBodyLen = SocketHeadLenType.getHeadLen(cacheData, _headByte);
			}
			else  // 当前正在等待接收协议体数据
			{
				if(bytesBodyLen > cacheData.bytesAvailable) // 当前接收到的数据不够协议体长度，等待下次数据过来
					return;
				
				var bodyBytes:ByteArray = new ByteArray();
				bodyBytes.endian = endian;
				cacheData.position = 0;
				cacheData.readBytes(bodyBytes, 0, bytesBodyLen);
				
				handleBodyBytes(bodyBytes);
				for (var i:int = 0; i < receiveDataHandlerList.length; i++) 
				{
					var fun:Function = receiveDataHandlerList[i] as Function;
					fun.apply(null, [bodyBytes]);
				}
				
				bytesBodyLen = 0; // 协议读完了，把协议体长度重置，重新开始读协议头
			}
			
			// 读取完数据后，把后面的数据保存好，已读的数据抛弃
			{
				tmpBytes = new ByteArray();
				tmpBytes.endian = endian;
				cacheData.readBytes(tmpBytes, 0, cacheData.bytesAvailable); // 把未读的内容读取出来
				
				cacheData.clear(); // 清空数据
				cacheData.position = 0;
				
				tmpBytes.position = 0;tmpBytes.length
				tmpBytes.readBytes(cacheData); // 剩余数据回写到缓存里
				tmpBytes.clear();
				
				cacheData.position = 0;
			}
			
			if( 0 == bytesBodyLen && _headByte <= cacheData.bytesAvailable) // 下一个是读协议头，而且内容足够了，则继续解析
				socketDataHandler(null);
			if( 0 < bytesBodyLen && bytesBodyLen <= cacheData.bytesAvailable) // 下一个是读协议体，而且内容足够了，则继续解析
				socketDataHandler(null);
		}
		
		/**
		 * 管理器自身处理协议体 
		 * @param data
		 */		
		protected function handleBodyBytes(data:ByteArray):void
		{
			// 留给子类继承，交给逻辑层处理
		}
		
		/**
		 * 接收到数据的处理函数列表 
		 */		
		private var receiveDataHandlerList:Array = [];
		
		/**
		 * 发送一个协议数据（会自动在数据前面加多一个协议头）
		 * @param data 发送的数据
		 * @param addHead 是否增加协议头（默认增加）
		 */		
		public function sendBytesData(data:ByteArray, addHead:Boolean = true):void
		{
			if(null == data)
				return;
			
			data.position = 0;
			if(addHead) // 自动在前面写入协议头
				_socket.writeBytes( SocketHeadLenType.packHeadBytes(data.length, _headByte, endian) );
			_socket.writeBytes(data);
			_socket.flush();
		}
		
		/**
		 * 增加一个协议体数据处理函数（每次解析完一个协议体都会调用此函数） 
		 * @param handler
		 */		
		public function addDataHandler(handler:Function):void
		{
			if(null == handler)
				return;
			
			if(-1 == receiveDataHandlerList.indexOf(handler))
				receiveDataHandlerList.push(handler);
		}
		
		/**
		 * 移除一个协议体数据处理函数
		 * @param handler
		 */		
		public function removeDataHandler(handler:Function):void
		{
			if(null == handler)
				return;
			
			if(-1 != receiveDataHandlerList.indexOf(handler))
				receiveDataHandlerList.splice(receiveDataHandlerList.indexOf(handler));
		}
	}
}