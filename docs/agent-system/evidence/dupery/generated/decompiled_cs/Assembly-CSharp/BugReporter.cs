using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using GRGLocalisation;
using Save;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class BugReporter : MenuBase
{
	[Header("References")]
	[SerializeField]
	private TMP_InputField bug_description;

	[SerializeField]
	private JiggleButton submit_button;

	[SerializeField]
	private CanvasGroup reporting_section;

	[SerializeField]
	private CanvasGroup sent_section;

	[SerializeField]
	private CanvasGroup error_group;

	[SerializeField]
	private Button sent_button;

	private CoroutineRunner report_fade_runner;

	private CoroutineRunner sent_fade_runner;

	private CoroutineRunner error_fade_runner;

	private bool sending_message;

	private string input_device_start;

	private bool can_send
	{
		get
		{
			if (!sending_message)
			{
				return bug_description.text.Length > 5;
			}
			return false;
		}
	}

	protected override void Awake()
	{
		base.Awake();
		report_fade_runner = new CoroutineRunner(this);
		sent_fade_runner = new CoroutineRunner(this);
		error_fade_runner = new CoroutineRunner(this);
		sending_message = false;
	}

	public void setInputDevice()
	{
		input_device_start = input.currentControlScheme;
		if (input_device_start == null || input_device_start == "")
		{
			input_device_start = GameHandler.instance.most_recent_control_scheme;
		}
	}

	public void checkSubmitInteractability()
	{
		submit_button.interactable = can_send;
	}

	public void submitBugReport()
	{
		if (can_send)
		{
			sending_message = true;
			if (input_device_start == null || input_device_start.Trim() == "")
			{
				input_device_start = input.currentControlScheme;
			}
			string logQueue = LogReports.instance.getLogQueue();
			BugReporterHelper.Send(bug_description.text, logQueue, getSaveString(logQueue), input_device_start + $" | {GRGLocalisationHandler.instance.current_language}", sentMessage);
		}
	}

	private void sentMessage(bool _success)
	{
		sending_message = false;
		if (_success)
		{
			reporting_section.interactable = false;
			reporting_section.blocksRaycasts = false;
			report_fade_runner.run(reporting_section.fade(0f, 0.15f));
			sent_fade_runner.run(sent_section.fade(1f, 0.25f).addCallback(delegate
			{
				sent_section.interactable = true;
				sent_section.blocksRaycasts = true;
				if (input.isUsingGamepad())
				{
					sent_button.Select();
				}
			}));
			return;
		}
		error_fade_runner.run(error_group.fade(1f, 0.15f, CoroutineExtensions.easeInOutFunc).addCallback(delegate
		{
			error_fade_runner.run(4f.wait(delegate
			{
				error_fade_runner.run(error_group.fade(0f, 1f, CoroutineExtensions.easeInOutFunc));
			}));
		}));
	}

	private string getSaveString(string _log)
	{
		if (GameHandler.instance.current_scene == "MainMenuScene")
		{
			return "MainMenuScene";
		}
		if (SaveHandler.instance.save_data.is_some)
		{
			SaveData saveData = new SaveData(GameHandler.instance.current_scene, SaveHandler.instance.save_data.value.toGameState());
			string text = JsonUtility.ToJson(saveData);
			if (text.Length >= 21000 - _log.Length)
			{
				saveData.lines_data = new Maybe<LinesSave>();
				saveData.pins_data = new Maybe<PinsSave>();
				saveData.strings_data = new Maybe<StringSave>();
				text = JsonUtility.ToJson(saveData);
				if (text.Length >= 21000 - _log.Length)
				{
					text = ((!saveData.current_case.is_some) ? ("E1 - No current case, save too long. Scene: " + GameHandler.instance.current_scene) : JsonUtility.ToJson(saveData.current_case.value));
					if (text.Length >= 20000 - _log.Length)
					{
						text = "E2 - Current case too long!";
					}
				}
			}
			return text;
		}
		if (GameHandler.State.current_case.is_some)
		{
			string text2 = JsonUtility.ToJson(GameHandler.State.current_case.value);
			if (text2.Length >= 21000 - _log.Length)
			{
				text2 = "E3 - Current case too long!";
			}
			return text2;
		}
		return GameHandler.instance.current_scene;
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		bug_description.text = "";
		submit_button.interactable = false;
		reporting_section.putOn();
		sent_section.putOn(_on: false);
		sending_message = false;
	}

	public void openQQ()
	{
		"https://qm.qq.com/q/holtUCsdNK".openUrl();
	}
}
