using System;
using System.Collections.Generic;
using System.Net.Http;
using UnityEngine;

public static class BugReporterHelper
{
	private static string form_url = "https://docs.google.com/forms/d/e/1FAIpQLSenv4P0Gdy2X4IAN8om3pEtIicM2JhcUW5VSxq5nuy0Zoteng/formResponse";

	private static string version_nb_entry_id = "entry.971459854";

	private static string steam_id_entry_id = "entry.154525905";

	private static string os_entry_id = "entry.748589519";

	private static string screensize_entry_id = "entry.1285064353";

	private static string input_entry_id = "entry.1761180678";

	private static string main_message_entry_id = "entry.1866200198";

	private static string log_entry_id = "entry.1937127967";

	private static string save_entry_id = "entry.862375495";

	public static async void Send(string _main_message, string _log, string _save, string _input_device, Action<bool> _on_send)
	{
		Dictionary<string, string> nameValueCollection = new Dictionary<string, string>
		{
			{
				version_nb_entry_id,
				"v" + Application.version
			},
			{
				steam_id_entry_id,
				SteamHandler.getUser64BitID()
			},
			{
				os_entry_id,
				SteamHandler.onSteamDeck() ? "SteamDeck" : SystemInfo.operatingSystem
			},
			{
				screensize_entry_id,
				$"{Screen.width}x{Screen.height}"
			},
			{ input_entry_id, _input_device },
			{ main_message_entry_id, _main_message },
			{ log_entry_id, _log },
			{ save_entry_id, _save }
		};
		try
		{
			using HttpClient httpClient = new HttpClient();
			FormUrlEncodedContent content = new FormUrlEncodedContent(nameValueCollection);
			if ((await httpClient.PostAsync(form_url, content)).IsSuccessStatusCode)
			{
				Debug.Log("Send Debug Message Success");
				_on_send(obj: true);
			}
			else
			{
				Debug.LogError("Failed to send debug message!");
				_on_send(obj: false);
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong sending bug report! \n{arg}");
			_on_send(obj: false);
		}
	}
}
