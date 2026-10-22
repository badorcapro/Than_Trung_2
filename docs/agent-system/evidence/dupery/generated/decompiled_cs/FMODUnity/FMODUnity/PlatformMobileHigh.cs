namespace FMODUnity;

public class PlatformMobileHigh : PlatformMobileLow
{
	internal override string DisplayName => "High-End Mobile";

	internal override float Priority => base.Priority + 1f;

	internal override bool MatchesCurrentEnvironment
	{
		get
		{
			_ = base.Active;
			return false;
		}
	}

	static PlatformMobileHigh()
	{
		Settings.AddPlatformTemplate<PlatformMobileHigh>("fd7c55dab0fce234b8c25f6ffca523c1");
	}
}
