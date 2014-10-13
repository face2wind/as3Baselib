package face2wind.config
{
	/**
	 * 把资源路径里的{language}替换成当前使用的语言字符 <br/>
	 * isCompletePath 是否完整路径，若不是，则会先调用一次rUrl
	 */	
	public function rLanguage(url:String , isCompletePath:Boolean = true):String
	{
		var newUrl:String;
		newUrl = url.replace("{language}", ConfigManager.language);
		if(false == isCompletePath)
			newUrl = rURL(newUrl);
		return newUrl;
	}
}
