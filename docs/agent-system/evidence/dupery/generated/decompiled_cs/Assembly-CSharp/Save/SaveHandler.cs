using System;
using System.IO;
using System.Linq;
using GRGLib.Maybe;
using GRGLib.Save;
using GRGLib.Save.Json;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Save;

public class SaveHandler : MonoBehaviour
{
	public enum SaveDataVersions
	{
		INVALID,
		NEWEST,
		V0_2_51,
		V0_3_12,
		V0_4_23,
		V0_6_0,
		V0_9_34
	}

	public class GameSave
	{
		public int save_file = -1;

		private string version_number = "unset";

		public Maybe<BaseSaveData> save_data = new Maybe<BaseSaveData>();

		public bool is_previous_version
		{
			get
			{
				if (version_number != "")
				{
					return version_number != Application.version;
				}
				return false;
			}
		}

		public bool has_save_data => save_data.is_some;

		public bool is_demo_save => version_number.StartsWith("0.");

		public string save_name => getSaveName((save_file > 0) ? $"_{save_file}" : "");

		private string save_file_path_and_name => getSaveFilePath() + save_name;

		public GameSave(int _save_file = 0, bool _try_load = true)
		{
			save_file = _save_file;
			if (_try_load)
			{
				load();
			}
		}

		public bool save(GameState _state, string _scene_name = "")
		{
			save_data = ((BaseSaveData)new SaveData((_scene_name == "") ? SceneManager.GetActiveScene().name : _scene_name, _state)).maybe();
			return (save_data.value as SaveData).SaveData(save_name, getSaveFilePath());
		}

		public bool load()
		{
			version_number = JsonSaveHandler.getSaveVersionOfFile(save_file_path_and_name);
			if (version_number == "")
			{
				return false;
			}
			SaveDataVersions saveVersionType = getSaveVersionType(version_number);
			Debug.Log($"Loading save {save_file}. Version number v{version_number}. Version type {saveVersionType}");
			switch (saveVersionType)
			{
			case SaveDataVersions.NEWEST:
				save_data = JsonSaveHandler.LoadData<SaveData>(save_file_path_and_name).fmap((Func<SaveData, BaseSaveData>)((SaveData _s) => _s));
				break;
			case SaveDataVersions.V0_9_34:
				save_data = JsonSaveHandler.LoadData<SaveData_v0_9_34>(save_file_path_and_name).fmap((Func<SaveData_v0_9_34, BaseSaveData>)((SaveData_v0_9_34 _s) => _s));
				break;
			case SaveDataVersions.V0_2_51:
				save_data = JsonSaveHandler.LoadData<SaveDatav0_2_51>(save_file_path_and_name).fmap((Func<SaveDatav0_2_51, BaseSaveData>)((SaveDatav0_2_51 _s) => _s));
				break;
			case SaveDataVersions.V0_3_12:
				save_data = JsonSaveHandler.LoadData<SaveDatav0_3_12>(save_file_path_and_name).fmap((Func<SaveDatav0_3_12, BaseSaveData>)((SaveDatav0_3_12 _s) => _s));
				break;
			case SaveDataVersions.V0_4_23:
				save_data = JsonSaveHandler.LoadData<SaveDatav0_4_23>(save_file_path_and_name).fmap((Func<SaveDatav0_4_23, BaseSaveData>)((SaveDatav0_4_23 _s) => _s));
				break;
			}
			save_data.value.onLoaded();
			return save_data.is_some;
		}

		public int checkSaveVersion(params int[] _check_against)
		{
			return checkSaveVersionDetailed(convertFileVersion(version_number), _check_against);
		}
	}

	private static string metadata_save_file_base = "Meta";

	private static string stats_save_file_base = "Stats";

	private static string run_save_file_name = "Dupery";

	private static string save_file_extension = ".save";

	private static string run_save_file_name_old = "Clocklike";

	public static int max_save_files = 5;

	private Maybe<GameSave> saver = new Maybe<GameSave>();

	public GameMetaData meta_data;

	public GameStatsData stats_data;

	public SaveDataVersions meta_save_version;

	private float last_saved_time = -1f;

	public static SaveHandler instance { get; private set; }

	public Maybe<BaseSaveData> save_data
	{
		get
		{
			if (!saver.is_some)
			{
				return new Maybe<BaseSaveData>();
			}
			return saver.value.save_data;
		}
	}

	public Maybe<GameState> game_state
	{
		get
		{
			if (!save_data.is_some)
			{
				return new Maybe<GameState>();
			}
			return save_data.value.toGameState().maybe();
		}
	}

	public int save_file_number { get; private set; }

	private string stats_save_file_name => stats_save_file_base + ((save_file_number > 0) ? $"_{save_file_number}" : "");

	private string metadata_save_file_name => metadata_save_file_base + ((save_file_number > 0) ? $"_{save_file_number}" : "");

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			UnityEngine.Object.Destroy(base.gameObject);
			return;
		}
		UnityEngine.Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		save_file_number = Mathf.Clamp(SettingsHandler.save_number, 0, max_save_files - 1);
		loadMetadata();
		loadGameStats();
	}

	private static string getSaveFilePath()
	{
		return SteamHandler.getUser64BitID() + "/";
	}

	private static string getSaveName(string _extra)
	{
		return run_save_file_name + _extra + save_file_extension;
	}

	private static string getSaveNameOld()
	{
		return run_save_file_name_old + save_file_extension;
	}

	private string getSaveName()
	{
		return getSaveName((save_file_number > 0) ? $"_{save_file_number}" : "");
	}

	public bool trySwitchSaveFileNumber(int _number)
	{
		if (_number < 0 || _number >= max_save_files)
		{
			return false;
		}
		save_file_number = _number;
		loadMetadata();
		loadGameStats();
		saver = new Maybe<GameSave>();
		return true;
	}

	public bool doesValidGameSaveFileExist()
	{
		if (!File.Exists(Application.persistentDataPath + "/" + getSaveFilePath() + getSaveName()))
		{
			return false;
		}
		return true;
	}

	public bool doesGameSaveFileExist()
	{
		if (File.Exists(Application.persistentDataPath + "/" + getSaveFilePath() + getSaveName()))
		{
			return true;
		}
		string text = Application.persistentDataPath + "/" + getSaveFilePath() + getSaveNameOld();
		if (File.Exists(text))
		{
			FileHandler.writeStringToFile(FileHandler.readFile(text), getSaveName(), Application.persistentDataPath + "/" + getSaveFilePath());
			FileHandler.deleteFile(text, "", _persistent_data: false);
			return true;
		}
		return false;
	}

	public bool doesStatsSaveFileExist()
	{
		return checkFileExistsAndProperLocation(stats_save_file_name + save_file_extension);
	}

	public bool doesMetaSaveFileExist()
	{
		return checkFileExistsAndProperLocation(metadata_save_file_name + save_file_extension);
	}

	private bool checkFileExistsAndProperLocation(string _file_name)
	{
		if (File.Exists(Application.persistentDataPath + "/" + getSaveFilePath() + _file_name))
		{
			return true;
		}
		return false;
	}

	public void reset()
	{
		saver = new Maybe<GameSave>();
	}

	public bool startGame(bool _move_scene = true)
	{
		saver = getSaveOrCreate().maybe();
		GameSave value = saver.value;
		if (value.is_demo_save)
		{
			checkForAchievements(game_state.value);
		}
		if (_move_scene && value.save_data.is_some && value.save_data.value.reload_scene != null && value.save_data.value.reload_scene.Length > 3)
		{
			GameHandler.instance.moveToScene(value.save_data.value.reload_scene);
			return true;
		}
		return false;
	}

	private void checkForAchievements(GameState _state)
	{
	}

	public void saveMetaData()
	{
		Debug.Log("Save (metadata): " + meta_data.SaveData(metadata_save_file_name + save_file_extension, getSaveFilePath()));
	}

	private void loadGameStats()
	{
		if (!doesStatsSaveFileExist())
		{
			stats_data = new GameStatsData();
			return;
		}
		getSaveVersionType(JsonSaveHandler.getSaveVersionOfFile(getSaveFilePath() + stats_save_file_name + save_file_extension));
		stats_data = JsonSaveHandler.TryLoad(getSaveFilePath() + stats_save_file_name + save_file_extension, () => new GameStatsData());
	}

	private void loadMetadata()
	{
		if (!doesMetaSaveFileExist())
		{
			meta_data = new GameMetaData();
			return;
		}
		meta_save_version = getSaveVersionType(JsonSaveHandler.getSaveVersionOfFile(getSaveFilePath() + metadata_save_file_name + save_file_extension));
		meta_data = JsonSaveHandler.TryLoad(getSaveFilePath() + metadata_save_file_name + save_file_extension, () => new GameMetaData());
	}

	public void saveGameStats()
	{
		Debug.Log("Save (stats): " + stats_data.SaveData(stats_save_file_name + save_file_extension, getSaveFilePath()));
	}

	public bool save(GameState _state, bool _save_stats = false, string _moving_scene_name = "")
	{
		if (!saver.is_some)
		{
			Debug.LogError("Cannot save when the saver is not some! Please call 'startGameSave' before this function!");
			return false;
		}
		bool num = saver.value.save(_state, _moving_scene_name);
		if (!num)
		{
			Debug.LogWarning("Save (game) failed!");
		}
		saveMetaData();
		if (_save_stats)
		{
			saveGameStats();
		}
		if (num)
		{
			last_saved_time = Time.realtimeSinceStartup;
		}
		return num;
	}

	public void createSaverIfNotSome()
	{
		if (!saver.is_some)
		{
			saver = new GameSave(save_file_number).maybe();
		}
	}

	public GameSave getSaveOrCreate()
	{
		createSaverIfNotSome();
		return saver.value;
	}

	public void deleteSave()
	{
		FileHandler.deleteFile(getSaveName(), getSaveFilePath());
		reset();
	}

	public string getTimeSinceLastSave()
	{
		int num = Mathf.RoundToInt((Time.realtimeSinceStartup - last_saved_time) / 60f);
		if (num == 0)
		{
			return "less than 1 minute";
		}
		return string.Format("{0} minute{1}", num, (num == 1) ? "" : "s");
	}

	private static (int[], SaveDataVersions)[] getSaveVersions()
	{
		return new(int[], SaveDataVersions)[6]
		{
			(new int[3] { 0, 9, 35 }, SaveDataVersions.NEWEST),
			(new int[3] { 0, 7, 0 }, SaveDataVersions.V0_9_34),
			(new int[3] { 0, 4, 24 }, SaveDataVersions.V0_6_0),
			(new int[3] { 0, 3, 13 }, SaveDataVersions.V0_4_23),
			(new int[3] { 0, 2, 52 }, SaveDataVersions.V0_3_12),
			(new int[3] { 0, 0, 1 }, SaveDataVersions.V0_2_51)
		};
	}

	private static int[] convertFileVersion(string _version)
	{
		return (from _vn in _version.Split('.')
			select int.Parse(_vn)).ToArray();
	}

	private static int checkSaveVersionDetailed(int[] _file_version, int[] _save_version)
	{
		for (int i = 0; i < _file_version.Length; i++)
		{
			if (_save_version.Length <= i)
			{
				return 1;
			}
			if (_file_version[i] > _save_version[i])
			{
				return 1;
			}
			if (_file_version[i] < _save_version[i])
			{
				return -1;
			}
		}
		if (_save_version.Length != _file_version.Length)
		{
			return -1;
		}
		return 0;
	}

	private static bool checkSaveVersion(int[] _file_version, int[] _save_version)
	{
		for (int i = 0; i < _file_version.Length; i++)
		{
			if (_save_version.Length <= i)
			{
				return true;
			}
			if (_file_version[i] > _save_version[i])
			{
				return true;
			}
			if (_file_version[i] < _save_version[i])
			{
				return false;
			}
		}
		return _save_version.Length == _file_version.Length;
	}

	private static SaveDataVersions getSaveVersionType(string _version_number)
	{
		try
		{
			if (_version_number == "")
			{
				return SaveDataVersions.INVALID;
			}
			int[] file_version = convertFileVersion(_version_number);
			(int[], SaveDataVersions)[] saveVersions = getSaveVersions();
			for (int i = 0; i < saveVersions.Length; i++)
			{
				if (checkSaveVersion(file_version, saveVersions[i].Item1))
				{
					return saveVersions[i].Item2;
				}
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to get the proper save file type for version number given! {_version_number}.\nError:{arg}");
		}
		Debug.LogError("Failed to get the proper save file type for version number given! " + _version_number + ".\nError: Version number seems to be older than the oldest save file version!!!");
		return SaveDataVersions.INVALID;
	}
}
