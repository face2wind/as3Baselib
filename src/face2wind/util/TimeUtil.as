package face2wind.util
{

	/**
	 * @author Michael.Huang
	 */
	public class TimeUtil
	{

		private static var d:Date;

		// return ranges
		public static const SILENT:uint = 0;
		public static const SECONDS:uint = 1;
		public static const MINUTES:uint = 2;
		public static const HOURS:uint = 3;
		public static const DAYS:uint = 4;

		/**
		 * 格式化Date对象，返回格式为：年-月-日  时:分:秒<br/>
		 * returns date in the format: YYYY-MM-DD HH:MM:SS
		 * @return
		 */
		public static function formatedDateTime(date:Date = null):String
		{
			var dateStr:String = formatedDate(date) + " " + formatedTime(date);
			return dateStr;
		}

		/**
		 * 格式化Date对象，返回格式为：年-月-日
		 * returns date in the format: YYYY-MM-DD
		 * @return
		 */
		public static function formatedDate(date:Date = null):String
		{
			if (null == date)
			{
				d = new Date();
			}
			else
			{
				d = date;
			}
			var dateStr:String = String(d.fullYear) + "-" + ((d.month + 1) < 10 ? "0" : "") + String(d.month + 1) + "-" + (d.date < 10 ? "0" : "") + String(d.date);
			return dateStr;
		}

		/**
		 * 格式化Date对象，返回格式为：时:分:秒
		 * returns time in the format: HH:MM:SS
		 * @return
		 */
		public static function formatedTime(date:Date = null):String
		{
			if (null == date)
			{
				d = new Date();
			}
			else
			{
				d = date;
			}
			var timeStr:String = (d.hours < 10 ? "0" : "") + String(d.hours) + ":" + (d.minutes < 10 ? "0" : "") + String(d.minutes) + ":" + (d.seconds < 10 ? "0" : "") + String(d.seconds);
			return timeStr;
		}

		/**
		 * 格式化一个倒计时数，返回格式为：  分:秒
		 * returns time in the format: MM:SS
		 * @param time 倒计时数（秒）
		 * @return
		 */
		public static function formatedTimerCount(time:Number, range:uint = MINUTES):String
		{
			//trace(time)
			var hours:Number = Math.floor(time / 3600);
			var minutes:Number = Math.floor((time / 60) % 60);
			var seconds:Number = Math.floor(time % 60);
			var timeStr:String = (range >= HOURS ? maintainTwoCharacterTimeFormat(hours) + ":" : "") + (range >= MINUTES ? maintainTwoCharacterTimeFormat(minutes) + ":" : "") + (range >= SECONDS ? maintainTwoCharacterTimeFormat(seconds) : "");
			return timeStr;
		}
		
		/**
		 * 格式化一个倒计时数，返回格式为：  x天x小时x分钟x秒
		 * @param time 倒计时数（秒）
		 * @return
		 */
		public static function formatedTimeIntoCN(time:Number, range:uint = MINUTES):String
		{
			var temp:Number = time;
			var days:Number = Math.floor(temp / 86400);
			temp -= days * 86400;
			var hours:Number = Math.floor(temp / 3600);
			temp -= hours * 3600;
			var minutes:Number = Math.floor(temp / 60);
			temp -= minutes * 60;
			var seconds:Number = Math.floor(temp % 60);
			var timeStr:String = ((range >= DAYS && days > 0) ? days + "天":"") + ((range >= HOURS && hours > 0) ?hours + "小时" : "") + ((range >= MINUTES && minutes > 0) ?minutes+ "分钟" : "") + (range >= SECONDS ?seconds + "秒": "");
			return timeStr;
		}
		
		/**
		 * 把数字转换成字符串，保持两位（若小于10，则在前面加0，保持两个字符） 
		 * @param num
		 * @return 
		 * 
		 */		
		private static function maintainTwoCharacterTimeFormat(num:Number):String
		{
			return (num < 10 ? "0" : "") + String(num);
		}

		/**
		 *剩余时间
		 * @param startTime  开始时间
		 * @param endTime   结束时间
		 * @param isReal    是否要添加补零
		 * @return
		 *
		 */
		public static function reaminTime(startTime:Number, endTime:Number, isReal:Boolean = false, hasDay:Boolean = false):String
		{
			var time:int = endTime - startTime;

			var hours:Number = Math.floor(time / 3600);
			var minutes:Number = Math.floor((time / 60) % 60);
			var seconds:Number = Math.floor(time % 60);
			var timeStr:String = "";
			if (hasDay)
			{
				var days:Number = Math.floor(hours / 24);
				hours = hours % 24;
				if (isReal)
				{
					timeStr = String(days) + "天" + (hours < 10 ? "0" : "") + String(hours) + ":" + (minutes < 10 ? "0" : "") + String(minutes) + ":" + (seconds < 10 ? "0" : "") + String(seconds);
				}
				else
				{
					timeStr = days + ":" + hours + ":" + minutes + ":" + seconds;
				}

			}
			else
			{
				if (isReal)
				{
					timeStr = (hours < 10 ? "0" : "") + String(hours) + ":" + (minutes < 10 ? "0" : "") + String(minutes) + ":" + (seconds < 10 ? "0" : "") + String(seconds);
				}
				else
				{
					timeStr = hours + ":" + minutes + ":" + seconds;
				}
			}
			return timeStr;
		}
	}
}
