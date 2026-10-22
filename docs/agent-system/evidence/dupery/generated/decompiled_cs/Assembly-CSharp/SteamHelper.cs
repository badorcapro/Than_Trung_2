using System.Linq;

public static class SteamHelper
{
	public static RichPresenceStatus fromRegion(Regions _region)
	{
		switch (_region)
		{
		case Regions.OFFICE:
			return RichPresenceStatus.OFFICE;
		case Regions.CASINO:
			return RichPresenceStatus.CASINO;
		case Regions.DOCKS:
			return RichPresenceStatus.DOCKS;
		case Regions.SYNDICATE:
			return RichPresenceStatus.SYNDICATE;
		default:
		{
			global::_003CPrivateImplementationDetails_003E.ThrowSwitchExpressionException(_region);
			RichPresenceStatus result = default(RichPresenceStatus);
			return result;
		}
		}
	}

	public static bool shouldCheckFor(params Achiements[] _achiements)
	{
		return _achiements.Any((Achiements _a) => !SteamHandler.isAchieved(_a.ToString()));
	}

	public static void tryAchieveCompletion(Regions _region)
	{
		switch (_region)
		{
		case Regions.OFFICE:
			tryAchieve(Achiements.OFFICE_COMPLETE);
			break;
		case Regions.CASINO:
			tryAchieve(Achiements.CASINO_COMPLETE);
			break;
		case Regions.DOCKS:
			tryAchieve(Achiements.DOCKS_COMPLETE);
			break;
		}
	}

	public static void tryAchieve(Achiements _achievement)
	{
		if (!GameHandler.instance.level_editor_case.is_some && !SteamHandler.isAchieved(_achievement.ToString()))
		{
			SteamHandler.unlockAchievement(_achievement.ToString());
		}
	}

	public static void addToStats(AchiementStats _stats, int _increase, bool _store_immidiate = true)
	{
		if (!GameHandler.instance.level_editor_case.is_some)
		{
			SteamHandler.incremementStat(_stats.ToString(), _increase, _store_immidiate);
		}
	}
}
