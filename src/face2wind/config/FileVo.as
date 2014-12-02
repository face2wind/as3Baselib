package face2wind.config
{
	/**
	 * @author Michael.Huang
	 */
	public class FileVo
	{
		public function FileVo()
		{
			
		}
		
		/**
		 * 文件路径 
		 */		
		public var path:String;
		
		/**
		 * 文件大小 
		 */		
		public var size:int;
		
		/**
		 * 文件修改时间戳（加载的时候当做版本号来使用） 
		 */		
		public var timestamp:int
		
	}
}