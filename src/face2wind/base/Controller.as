package face2wind.base
{
	import face2wind.manager.EventManager;
	import face2wind.net.GameSocket;
	
	
	/**
	 * 控制器基类
	 * @author Liu Guobiao
	 */
	public class Controller
	{  
		/**
		 * 统一协议派发器 
		 */		
		private var socket:GameSocket = GameSocket.getInstance();
		
		/**
		 * 统一事件派发器 
		 */		
		protected var eventManager:EventManager = EventManager.getInstance();
		
		public function Controller()
		{
		}
		
		/**
		 * 封装消息
		 * @param cmd	消息消息号
		 * @param object 消息内容
		 *
		 */
		protected function sendMessage(cmd:uint, object:*=null):void
		{
			socket.sendCmdMessage(cmd , object);
		}
		
		/**
		 * 添加某个消息号的监听
		 * @param cmd	消息号
		 * @param args	处理函数
		 * 
		 */		
		protected function addCmdListener(cmd:int, hander:Function):void
		{
			socket.addCmdListener(cmd , hander);
		}
		
		/**
		 *移除 消息号监听
		 * @param cmd
		 *
		 */
		public function removeCmdListener(cmd:int, hander:Function):void
		{
			socket.removeCmdListener(cmd, hander);
		}
	}
}
