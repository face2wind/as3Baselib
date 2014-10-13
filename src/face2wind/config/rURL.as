package face2wind.config
{
	/**
	 * 把资源路径转换成完整路径 
	 */	
	public function rURL(url:String):String
	{
		if(url.indexOf(ConfigManager.cdnUrl) > -1)
			return url;
		return ConfigManager.cdnUrl + url;
	}
}