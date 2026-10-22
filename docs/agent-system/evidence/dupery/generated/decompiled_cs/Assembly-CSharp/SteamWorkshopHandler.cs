using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Steamworks;
using UnityEngine;

public class SteamWorkshopHandler
{
	private struct WorkshopItemInfo
	{
		public string title;

		public string description;

		public string[] tags;

		public string content_path;

		public string preview_path;

		public ERemoteStoragePublishedFileVisibility visibility;

		public WorkshopItemInfo(string _title, string _description, string _content_path, string _preview_path, string[] _tags, ERemoteStoragePublishedFileVisibility _vis)
		{
			title = _title;
			description = _description;
			content_path = _content_path;
			preview_path = _preview_path;
			tags = _tags;
			visibility = _vis;
		}
	}

	private CallResult<CreateItemResult_t> create_item_call = new CallResult<CreateItemResult_t>();

	private CallResult<SubmitItemUpdateResult_t> update_item_call = new CallResult<SubmitItemUpdateResult_t>();

	private Maybe<WorkshopItemInfo> item_info = new Maybe<WorkshopItemInfo>();

	private Maybe<bool> upload_success = new Maybe<bool>();

	private bool previous_upload_state;

	private string error_msg = "";

	public bool getPreviousUploadState()
	{
		return previous_upload_state;
	}

	public string getErrorMsg()
	{
		return error_msg;
	}

	private IEnumerator waitForUploadState()
	{
		while (!upload_success.is_some)
		{
			yield return null;
		}
		previous_upload_state = upload_success.value;
		upload_success = new Maybe<bool>();
	}

	public IEnumerator createNewWorkshopItem(Action<bool> _callback, string _title, string _description, string _content_path, string _preview_path, ERemoteStoragePublishedFileVisibility _visible, params string[] _tags)
	{
		createNewWorkshopItem(_title, _description, _content_path, _preview_path, _visible, _tags);
		yield return waitForUploadState();
		_callback(previous_upload_state);
	}

	private void createNewWorkshopItem(string _title, string _description, string _content_path, string _preview_path, ERemoteStoragePublishedFileVisibility _visible, params string[] _tags)
	{
		item_info = new WorkshopItemInfo(_title, _description, _content_path, _preview_path, _tags, _visible).maybe();
		SteamAPICall_t hAPICall = SteamUGC.CreateItem(SteamUtils.GetAppID(), EWorkshopFileType.k_EWorkshopFileTypeFirst);
		create_item_call.Set(hAPICall, onItemCreated);
	}

	private void onItemCreated(CreateItemResult_t _result, bool _fail)
	{
		if (_fail || _result.m_eResult != EResult.k_EResultOK)
		{
			upload_success = MaybeExtensions.maybe(_obj: false);
			error_msg = $"Failed to create Item: {_result.m_eResult}";
			throw new ArgumentException($"Failed to create Item: {_result.m_eResult}");
		}
		if (_result.m_bUserNeedsToAcceptWorkshopLegalAgreement)
		{
			Debug.Log("User must agree to terms and services!");
		}
		PublishedFileId_t nPublishedFileId = _result.m_nPublishedFileId;
		updateItem(nPublishedFileId);
	}

	private void updateItem(PublishedFileId_t _file_id, string _chane_notes = "Initial item set up.")
	{
		if (!item_info.is_some)
		{
			upload_success = MaybeExtensions.maybe(_obj: false);
			error_msg = "Item info is not some!";
			throw new ArgumentException("Item info is not some!");
		}
		UGCUpdateHandle_t uGCUpdateHandle_t = SteamUGC.StartItemUpdate(SteamUtils.GetAppID(), _file_id);
		SteamUGC.SetItemTitle(uGCUpdateHandle_t, item_info.value.title);
		SteamUGC.SetItemDescription(uGCUpdateHandle_t, item_info.value.description);
		SteamUGC.SetItemTags(uGCUpdateHandle_t, item_info.value.tags);
		SteamUGC.SetItemContent(uGCUpdateHandle_t, item_info.value.content_path);
		SteamUGC.SetItemVisibility(uGCUpdateHandle_t, item_info.value.visibility);
		SteamUGC.SetItemPreview(uGCUpdateHandle_t, item_info.value.preview_path);
		item_info = new Maybe<WorkshopItemInfo>();
		SteamAPICall_t hAPICall = SteamUGC.SubmitItemUpdate(uGCUpdateHandle_t, _chane_notes);
		update_item_call.Set(hAPICall, onSubmittedUpdateItem);
	}

	private void onSubmittedUpdateItem(SubmitItemUpdateResult_t _result, bool _fail)
	{
		if (_fail || _result.m_eResult != EResult.k_EResultOK)
		{
			upload_success = MaybeExtensions.maybe(_obj: false);
			error_msg = $"Failed submitting item to workshop! {_result.m_eResult}";
			throw new ArgumentException(error_msg);
		}
		error_msg = "";
		upload_success = MaybeExtensions.maybe(_obj: true);
		Debug.Log("Upload Successfull!");
		SteamFriends.ActivateGameOverlayToWebPage($"steam://url/CommunityFilePage/{_result.m_nPublishedFileId}");
	}

	public static Maybe<T> tryLoadItem<T>(Func<string, Maybe<T>> _load_function)
	{
		foreach (string item in loadAllInstalledItemPaths())
		{
			Maybe<T> maybe = _load_function(item);
			if (maybe.is_some)
			{
				return maybe;
			}
		}
		return new Maybe<T>();
	}

	public static List<T> loadAllInstalledItems<T>(Func<string, T> _load_function)
	{
		return (from _path in loadAllInstalledItemPaths()
			select _load_function(_path)).ToList();
	}

	public static List<T> loadAllInstalledItemsOfType<T>(Func<string, Maybe<T>> _load_function)
	{
		List<T> result = new List<T>();
		loadAllInstalledItemPaths().ForEach(delegate(string _path)
		{
			Maybe<T> maybe = _load_function(_path);
			if (maybe.is_some)
			{
				result.Add(maybe.value);
			}
		});
		return result;
	}

	public static List<T> loadAllInstalledItemsOfType<T>(Func<string, bool> _filter, Func<string, T> _load_function)
	{
		return (from _path in loadAllInstalledItemPaths()
			where _filter(_path)
			select _load_function(_path)).ToList();
	}

	public static List<string> loadAllInstalledItemPaths()
	{
		return (from _id in getAllSubscribedItems()
			where (SteamUGC.GetItemState(_id) & 4) != 0
			select loadWorkshopItemPath(_id)).ToList();
	}

	public static PublishedFileId_t[] getAllSubscribedItems()
	{
		uint numSubscribedItems = SteamUGC.GetNumSubscribedItems();
		PublishedFileId_t[] array = new PublishedFileId_t[numSubscribedItems];
		SteamUGC.GetSubscribedItems(array, numSubscribedItems);
		return array;
	}

	public static string loadWorkshopItemPath(PublishedFileId_t _id)
	{
		uint itemState = SteamUGC.GetItemState(_id);
		if ((itemState & 4) == 0)
		{
			throw new ArgumentException($"Item {_id} is not installed! (Item state: {itemState})");
		}
		ulong punSizeOnDisk = 0uL;
		string pchFolder = "";
		uint punTimeStamp = 0u;
		if (!SteamUGC.GetItemInstallInfo(_id, out punSizeOnDisk, out pchFolder, 1024u, out punTimeStamp))
		{
			throw new ArgumentException($"Failed to load workshop item path for file: {_id}!");
		}
		return pchFolder;
	}

	public static uint getNumSubscribedItems()
	{
		return SteamUGC.GetNumSubscribedItems();
	}
}
