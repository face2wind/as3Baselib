package face2wind.util
{
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	/**
	 * 字符串处理工具
	 * @author face2wind
	 */
	public class StringUtil
	{
		/**
		 * 用于过滤html标签的文本 
		 */		
		private static var tf:TextField = new TextField();
		
		/**
		 * Returns value is a string type value.
		 * with undefined or null value, false returned.
		 */
		public static function isString(value:*):Boolean
		{
			return value is String;
		}
		
		public static function castString(str:*):String
		{
			return str as String;
		}
		
		/**
		 * 移除字符串里的html标记 
		 * @param str
		 * @return 
		 * 
		 */		
		public static function removeHtml(str:String):String
		{
			tf.htmlText = str;
			return tf.text;
		}
		
		/**
		 * replace oldString with newString in targetString
		 */
		public static function replace(targetString:String, oldString:String, newString:String):String
		{
			return targetString.split(oldString).join(newString);
		}
		
		/**
		 * remove the blankspaces of left and right in target String<br/>
		 * 删除字符串前后的空格
		 */
		public static function trim(targetString:String):String
		{
			return trimLeft(trimRight(targetString));
		}
		
		/**
		 * remove only the blankspace on targetString's left<br/>
		 * 删除字符串左边的空格
		 */
		public static function trimLeft(targetString:String):String
		{
			var tempIndex:int = 0;
			var tempChar:String = "";
			for (var i:int = 0; i < targetString.length; i++)
			{
				tempChar = targetString.charAt(i);
				if (tempChar != " ")
				{
					tempIndex = i;
					break;
				}
			}
			return targetString.substr(tempIndex);
		}
		
		/**
		 * remove only the blankspace on targetString's right<br/>
		 * 删除字符串右边的空格
		 */
		public static function trimRight(targetString:String):String
		{
			var tempIndex:int = targetString.length - 1;
			var tempChar:String = "";
			for (var i:int = targetString.length - 1; i >= 0; i--)
			{
				tempChar = targetString.charAt(i);
				if (tempChar != " ")
				{
					tempIndex = i;
					break;
				}
			}
			return targetString.substring(0, tempIndex + 1);
		}
		
		public static function getCharsArray(targetString:String, hasBlankSpace:Boolean):Array
		{
			var tempString:String = targetString;
			if (hasBlankSpace == false)
			{
				tempString = trim(targetString);
			}
			return tempString.split("");
		}
		
		/**
		 * 检测字符串targetString是否以指定字符串subString开头 
		 * @param targetString
		 * @param subString
		 * @return 
		 */		
		public static function startsWith(targetString:String, subString:String):Boolean
		{
			return (targetString.indexOf(subString) == 0);
		}
		
		/**
		 *  检测字符串targetString是否以指定字符串subString结尾
		 * @param targetString
		 * @param subString
		 * @return 
		 */		
		public static function endsWith(targetString:String, subString:String):Boolean
		{
			return (targetString.lastIndexOf(subString) == (targetString.length - subString.length));
		}
		
		/**
		 * 字符串是否全是小写字母 
		 * @param chars
		 * @return 
		 * 
		 */		
		public static function isLetter(chars:String):Boolean
		{
			if (chars == null || chars == "")
			{
				return false;
			}
			for (var i:int = 0; i < chars.length; i++)
			{
				var code:uint = chars.charCodeAt(i);
				if (code < 65 || code > 122 || (code > 90 && code < 97))
				{
					return false;
				}
			}
			return true;
		}
		
		/**
		 * 判断是否为空
		 * @param target 要判断的字符串
		 * @return 如果为空返回true，如果不空返回false
		 *
		 */
		public static function isEmpty(target:String):Boolean
		{
			if (null == target || "" == target)
			{
				return true;
			}
			else
			{
				if ("" != trim(target))
				{
					return false;
				}
				else
				{
					return true;
				}
			}
		}
		
		/**
		 * 获取字符串的字节数
		 */
		public static function stringLen(char:String):int
		{
			var obj:ByteArray = new ByteArray();
			obj.writeMultiByte(char, "cn-gb");
			return obj.length;
		}
		
		public static function stringChars(char:String):int
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(char);
			bytes.position = 0;
			return bytes.length;
		}
		
		
		/**
		 * 截取字符串的功能
		 * @param char 传入的字符串（即需要截取的）
		 * @param len 需要截取的字节数
		 * @param truncateToFit 是否适应用“...”
		 * @return
		 *
		 */
		public static function lenControl(char:String, len:int, truncateToFit:Boolean = false):String
		{
			var strEd:String = "";
			for (var i:int = 0; i < char.length; i++)
			{
				strEd = char.substr(0, i + 1);
				if (stringLen(strEd) >= len)
				{
					if (truncateToFit)
					{
						strEd += "...";
					}
					break;
				}
			}
			return strEd;
		}
		
		/**
		 * 字符拼接
		 * @param str 格式   aaaa#0bb#1  #0表示 args中第一个插入到str的参数
		 * @param args
		 * @return
		 *
		 */
		public static function formatString(str:String, ... args):String
		{
			var result:String;
			result = str;
			for (var i:int = 1; i <= args.length; i++)
			{
				result = result.replace("$" + i, args[i - 1].toString());
			}
			return result;
		}
		
		/**
		 * 指定参数，替换内容（替换掉"替换符+i"）不改变原字符串
		 * @param target 内容
		 * @param args 替换数组
		 * @param sb  替换符
		 * @return
		 *
		 */
		public static function replaceByArgs(target:String, args:Array = null, sb:String = "$"):String
		{
			var result:String = target;
			if (args != null)
			{
				for (var i:int = 0; i < args.length; i++)
				{
					result = result.replace(sb + (i + 1), args[i] != null ? args[i] : "");
				}
			}
			return result;
		}
		
		/**
		 * 指定参数，替换内容（直接替换掉"替换符"）不改变原字符串
		 * @param target 内容
		 * @param args 替换数组
		 * @param sb  替换符
		 * @return
		 *
		 */
		public static function replaceByArgs2(target:String, args:Array = null, sb:String = "$$"):String
		{
			var result:String = target;
			if (args != null)
			{
				while(0 < args.length)
				{
					result = result.replace(sb , args.shift() );
				}
			}
			return result;
		}
		
		/**
		 * 获取在指定编码下字符串的长度
		 * @param str
		 * @param charCode 字符编码
		 * @return
		 *
		 */
		public static function getLengthFromByte(str:String
												 , charCode:String = "UTF-8"):int
		{
			
			if (!str)
				return 0;
			
			var bytes:ByteArray = new ByteArray();
			
			bytes.writeMultiByte(str, charCode);
			bytes.position = 0;
			
			var len:int = bytes.length;
			
			return len;
		}
		
		/**
		 * 拼合字符串
		 * @param color (#xxxxxx)
		 * @param linkData (点击链接的数据)
		 * @param linkText (链接文本)
		 *
		 */
		public static function mergeStr(color:String, linkData:String
										, linkText:String, isUnline:Boolean = true):String
		{
			var str:String = "<a href = 'event:" + linkData + "'><font color = '" + color + "'>" + linkText + "</font></a>";
			
			if (isUnline)
			{
				str = "<u>" + str + "</u>";
			}
			
			return str;
		}
		
		/**
		 * 恢复无法识别的‘\n’符号，一般是从locale.xml里读取出来的内容 
		 * @param str
		 * @return 
		 * 
		 */		
		public static function resumeNewLineChar(str:String):String
		{
			var arr:Array = str.split("\\n");
			var len:int = arr.length;
			var dirStr:String = arr[0];
			for (var i:int = 1; i < len; i++) 
			{
				dirStr = dirStr + "\n" + arr[i];
			}
			return dirStr;
		}
		
		/**
		 * 字符倒转
		 * @param str
		 * @return 
		 */		
		public static function reverse(str:String):String
		{
			var strArr:Array = [];
			for(var i:int = 0;i < str.length;i++)
			{
				strArr.push(str.charAt(i));
			}
			var result:String = "";
			while(strArr.length > 0)
			{
				result += strArr.pop();
			}
			return result;
		}
		
	}
}
