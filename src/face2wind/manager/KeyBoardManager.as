package face2wind.manager
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	import face2wind.manager.StageManager;
	
	/**
	 * 键盘按键管理器
	 * @author face2wind
	 */
	public class KeyBoardManager
	{
		public function KeyBoardManager()
		{
			if(instance)
				throw new Error("KeyBoardManager is singleton class and allready exists!");
			instance = this;
			
			keyDownFuncDic = new Dictionary();
			keyUpFuncDic = new Dictionary();
			keyDownHandlerList = [];
			keyUpHandlerList = [];
			
			var st:Stage = StageManager.getInstance().stage;
			st.addEventListener(KeyboardEvent.KEY_DOWN , onKeyDownHandler);
			st.addEventListener(KeyboardEvent.KEY_UP , onKeyUpHandler);
		}
		
		/**
		 * 单例
		 */
		private static var instance:KeyBoardManager;
		/**
		 * 获取单例
		 */
		public static function getInstance():KeyBoardManager
		{
			if(!instance)
				instance = new KeyBoardManager();
			
			return instance;
		}
		
		/**
		 * 键盘按下 
		 * @param event
		 * 
		 */		
		protected function onKeyDownHandler(event:KeyboardEvent):void
		{
			//			trace(event.keyCode);
			var fArr:Array = keyDownFuncDic[event.keyCode];
			var f:Function;
			if(null != fArr && 0 < fArr.length)
			{
				for (var i:int = 0; i < fArr.length; i++) 
				{
					f = fArr[i];
					f.apply();
				}
			}
			
			for (var j:int = 0; j < keyDownHandlerList.length; j++) 
			{
				f = keyDownHandlerList[j];
				f.apply(null,[event.keyCode]);
			}
		}
		
		/**
		 * 键盘弹起 
		 * @param event
		 * 
		 */		
		protected function onKeyUpHandler(event:KeyboardEvent):void
		{
			var fArr:Array = keyUpFuncDic[event.keyCode];
			var f:Function;
			if(null != fArr && 0 < fArr.length)
			{
				for (var i:int = 0; i < fArr.length; i++) 
				{
					f = fArr[i];
					f.apply();
				}
			}
			
			for (var j:int = 0; j < keyUpHandlerList.length; j++) 
			{
				f = keyUpHandlerList[i];
				f.apply(null,[event.keyCode]);
			}
		}
		
		/**
		 * 键盘按下响应事件列表 
		 */		
		private var keyDownFuncDic:Dictionary;
		
		/**
		 * 键盘弹起事件响应列表 
		 */		
		private var keyUpFuncDic:Dictionary;
		
		/**
		 * 键盘按下响应事件列表(带参数的函数，而且任何key都触发)
		 */		
		private var keyDownHandlerList:Array;
		
		/**
		 * 键盘弹起事件响应列表 (带参数的函数，而且任何key都触发)
		 */		
		private var keyUpHandlerList:Array;
		
		/**
		 * 增加一个键盘按下响应事件<br/>
		 * key为指定触发handler函数的keycode，若key为0，则表示任何keycode都会触发函数，并且函数要带参数（keycode） 
		 * @param handler 
		 * @param key
		 * 
		 */		
		public function addKeyDownHandler(handler:Function , key:uint = 0):void
		{
			if(0 == key)
			{
				if(-1 == keyDownHandlerList.indexOf(keyDownHandlerList))
					keyDownHandlerList.push(handler);
			}
			else
			{
				var fArr:Array = keyDownFuncDic[key];
				if(null == fArr)
				{
					keyDownFuncDic[key] = [];
					fArr = keyDownFuncDic[key];
				}
				var index:int = fArr.indexOf(handler);
				if(-1 == index) //不重复添加同一个回调函数
					fArr.push(handler);
			}
		}
		
		/**
		 * 移除一个键盘按下响应事件 
		 * @param key
		 * @param handler
		 * 
		 */		
		public function removeKeyDownHandler(handler:Function , key:uint = 0):void
		{
			if(0 == key)
			{
				if(-1 != keyDownHandlerList.indexOf(handler))
					keyDownHandlerList.splice(keyDownHandlerList.indexOf(handler),1);
			}
			else
			{
				var fArr:Array = keyDownFuncDic[key];
				if(null == fArr)
				{
					keyDownFuncDic[key] = [];
					fArr = keyDownFuncDic[key];
				}
				var index:int = fArr.indexOf(handler);
				if(-1 != index)
					fArr.splice(index,1);
			}
		}
		
		/**
		 * 增加一个键盘弹起响应事件 
		 * @param key
		 * @param handler
		 * 
		 */		
		public function addKeyUpHandler(handler:Function , key:uint = 0):void
		{
			if(0 == key)
			{
				if(-1 == keyUpHandlerList.indexOf(handler))
					keyUpHandlerList.push(handler);
			}
			else
			{
				var fArr:Array = keyUpFuncDic[key];
				var index:int = fArr.indexOf(handler);
				if(-1 == index) //不重复添加同一个回调函数
					fArr.push(handler);
			}
		}
		
		/**
		 * 增加一个键盘按下响应事件 
		 * @param key
		 * @param handler
		 * 
		 */		
		public function removeKeyUpHandler(handler:Function , key:uint = 0):void
		{
			if(0 == key)
			{
				if(-1 != keyUpHandlerList.indexOf(handler))
					keyUpHandlerList.splice(keyUpHandlerList.indexOf(handler),1);
			}
			else
			{
				var fArr:Array = keyUpFuncDic[key];
				var index:int = fArr.indexOf(handler);
				if(-1 != index)
					fArr.splice(index,1);
			}
		}
	}
}