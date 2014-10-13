package face2wind.util
{
	import flash.external.ExternalInterface;

	/**
	 * 外部交互类（比如网页，js）
	 * @author Face2wind
	 */
	public class ExternalUtil
	{
		public function ExternalUtil()
		{
		}
		
		/**
		 * 是否容许调用js函数 
		 */		
		public static var enableJs:Boolean = true;
		
		/**
		 * 调用js函数，同（ExternalInterface）
		 * @param functionName
		 * @param parameters
		 * @return 
		 * 
		 */		
		public static function jsCall(functionName:String, ...parameters):*
		{
			if(enableJs)
				ExternalInterface.call(functionName, parameters);
		}
	}
}
