package face2wind.manager
{
	import face2wind.enum.LayerEnum;
	import face2wind.view.BaseSprite;
	
	import flash.display.Sprite;
	
	/**
	 * 层管理类<br/>
	 * 使用前先set fatherLayer
	 * @author face2wind
	 */
	public class LayerManager
	{
		public function LayerManager()
		{
		}
		
		/**
		 * 所有层数组 
		 */		
		private var allLayers:Array = null;
		
		private static var _instance:LayerManager = null;
		public static function getInstance():LayerManager
		{
			if(null == _instance)
				_instance = new LayerManager();
			return _instance;
		}
		
		/**
		 * 指定所有层的父层，一般是程序的主层 
		 * @param layer
		 * 
		 */		
		public function set fatherLayer( fatherLayer:Sprite ):void
		{
			var layerNum:int = LayerEnum.TOP_LAYER + 1;
			var layer:BaseSprite;
			allLayers = [];
			for (var i:int = 0; i < layerNum; i++) 
			{
				layer = createLayer();
				allLayers.push(layer);
				fatherLayer.addChild(layer);
			}
		}
		
		
		/**
		 * 创建层对象<br/>
		 * 默认是sprite，子类可重写此函数<br/>
		 * 层对象必须是sprite或者其子类
		 * @return 
		 * 
		 */		
		protected function createLayer():BaseSprite
		{
			var layer:BaseSprite =  new BaseSprite();
			layer.isOnshow = true;
			layer.mouseEnabled = false;
			return layer;
		}
		
		/**
		 * 获取对应的层对象 
		 * @param layerIndex
		 * 
		 */		
		public function getLayer(layerIndex:int):BaseSprite
		{
			if(allLayers && allLayers.length > layerIndex)
				return allLayers[layerIndex] as BaseSprite;
			else 
				return null;
		}
	}
}