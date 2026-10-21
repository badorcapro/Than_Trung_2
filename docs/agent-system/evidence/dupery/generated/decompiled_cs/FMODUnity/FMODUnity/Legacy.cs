using System;
using System.Collections.Generic;

namespace FMODUnity;

internal static class Legacy
{
	[Serializable]
	public enum Platform
	{
		None,
		PlayInEditor,
		Default,
		Desktop,
		Mobile,
		MobileHigh,
		MobileLow,
		Console,
		Windows,
		Mac,
		Linux,
		iOS,
		Android,
		Deprecated_1,
		XboxOne,
		PS4,
		Deprecated_2,
		Deprecated_3,
		AppleTV,
		UWP,
		Switch,
		WebGL,
		Deprecated_4,
		Reserved_1,
		Reserved_2,
		Reserved_3,
		Count
	}

	public class PlatformSettingBase
	{
		public Platform Platform;
	}

	public class PlatformSetting<T> : PlatformSettingBase
	{
		public T Value;
	}

	[Serializable]
	public class PlatformIntSetting : PlatformSetting<int>
	{
	}

	[Serializable]
	public class PlatformStringSetting : PlatformSetting<string>
	{
	}

	[Serializable]
	public class PlatformBoolSetting : PlatformSetting<TriStateBool>
	{
	}

	public static void CopySetting<T, U>(List<T> list, Platform fromPlatform, Platform toPlatform) where T : PlatformSetting<U>, new()
	{
		T val = list.Find((T x) => x.Platform == fromPlatform);
		T val2 = list.Find((T x) => x.Platform == toPlatform);
		if (val != null)
		{
			if (val2 == null)
			{
				val2 = new T
				{
					Platform = toPlatform
				};
				list.Add(val2);
			}
			val2.Value = val.Value;
		}
		else if (val2 != null)
		{
			list.Remove(val2);
		}
	}

	public static void CopySetting(List<PlatformBoolSetting> list, Platform fromPlatform, Platform toPlatform)
	{
		CopySetting<PlatformBoolSetting, TriStateBool>(list, fromPlatform, toPlatform);
	}

	public static void CopySetting(List<PlatformIntSetting> list, Platform fromPlatform, Platform toPlatform)
	{
		CopySetting<PlatformIntSetting, int>(list, fromPlatform, toPlatform);
	}

	public static string DisplayName(Platform platform)
	{
		return platform switch
		{
			Platform.Linux => "Linux", 
			Platform.Desktop => "Desktop", 
			Platform.Console => "Console", 
			Platform.iOS => "iOS", 
			Platform.Mac => "OSX", 
			Platform.Mobile => "Mobile", 
			Platform.PS4 => "PS4", 
			Platform.Windows => "Windows", 
			Platform.UWP => "UWP", 
			Platform.XboxOne => "XBox One", 
			Platform.Android => "Android", 
			Platform.AppleTV => "Apple TV", 
			Platform.MobileHigh => "High-End Mobile", 
			Platform.MobileLow => "Low-End Mobile", 
			Platform.Switch => "Switch", 
			Platform.WebGL => "WebGL", 
			_ => "Unknown", 
		};
	}

	public static float SortOrder(Platform legacyPlatform)
	{
		return legacyPlatform switch
		{
			Platform.Desktop => 1f, 
			Platform.Windows => 1.1f, 
			Platform.Mac => 1.2f, 
			Platform.Linux => 1.3f, 
			Platform.Mobile => 2f, 
			Platform.MobileHigh => 2.1f, 
			Platform.MobileLow => 2.2f, 
			Platform.AppleTV => 2.3f, 
			Platform.Console => 3f, 
			Platform.XboxOne => 3.1f, 
			Platform.PS4 => 3.2f, 
			Platform.Switch => 3.3f, 
			_ => 0f, 
		};
	}

	public static Platform Parent(Platform platform)
	{
		switch (platform)
		{
		case Platform.Windows:
		case Platform.Mac:
		case Platform.Linux:
		case Platform.UWP:
		case Platform.WebGL:
			return Platform.Desktop;
		case Platform.MobileHigh:
		case Platform.MobileLow:
		case Platform.iOS:
		case Platform.Android:
		case Platform.AppleTV:
			return Platform.Mobile;
		case Platform.XboxOne:
		case Platform.PS4:
		case Platform.Switch:
		case Platform.Reserved_1:
		case Platform.Reserved_2:
		case Platform.Reserved_3:
			return Platform.Console;
		case Platform.Desktop:
		case Platform.Mobile:
		case Platform.Console:
			return Platform.Default;
		default:
			return Platform.None;
		}
	}

	public static bool IsGroup(Platform platform)
	{
		if ((uint)(platform - 3) <= 1u || platform == Platform.Console)
		{
			return true;
		}
		return false;
	}
}
