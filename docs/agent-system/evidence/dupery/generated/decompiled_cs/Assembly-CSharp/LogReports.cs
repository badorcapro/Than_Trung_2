using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Maybe;
using UnityEngine;

public class LogReports : MonoBehaviour
{
	private static int log_depth = 25;

	private Queue<string> log_queue = new Queue<string>();

	private Maybe<string> previous_log = new Maybe<string>();

	private int previous_repeat;

	public static LogReports instance { get; private set; }

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			Object.Destroy(base.gameObject);
			return;
		}
		Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
	}

	private void OnEnable()
	{
		Application.logMessageReceived += handleLog;
	}

	private void OnDisable()
	{
		Application.logMessageReceived -= handleLog;
	}

	public static void Log(string _log_string, LogType _type = LogType.Log)
	{
		if (!(instance == null))
		{
			instance.addSilentLog(_log_string, _type);
		}
	}

	public void addSilentLog(string _log_string, LogType _type = LogType.Log)
	{
		handleLog(_log_string, "silent", _type);
	}

	private void handleLog(string _logString, string _stackTrace, LogType _type)
	{
		bool flag = _type.equalToAny(LogType.Exception, LogType.Error);
		if (!flag && !shouldLog(_logString))
		{
			return;
		}
		string text = $"[{_type}] {_logString}" + (flag ? ("\n" + _stackTrace) : "");
		if (previous_log.is_some && previous_log.value == text)
		{
			previous_repeat++;
			return;
		}
		if (previous_log.is_some)
		{
			log_queue.Enqueue(((previous_repeat > 0) ? $"[x{previous_repeat + 1}] " : "") + previous_log.value);
		}
		previous_log = text.maybe();
		previous_repeat = 0;
		if (log_queue.Count > log_depth)
		{
			log_queue.Dequeue();
		}
	}

	private bool shouldLog(string _log_string)
	{
		if (_log_string == "Save (metadata): True")
		{
			return false;
		}
		return true;
	}

	public string getLogQueue()
	{
		return log_queue.ToArray().Aggregate("", (string _a, string _l) => _a = _a + _l + "\n") + (previous_log.is_some ? (((previous_repeat > 0) ? $"[x{previous_repeat + 1}] " : "") + previous_log.value) : "");
	}
}
