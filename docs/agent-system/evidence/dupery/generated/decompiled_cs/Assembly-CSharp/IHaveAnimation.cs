using GRGLib.Maybe;

public interface IHaveAnimation
{
	public enum RoleAnimations
	{
		JUDGE_SUSPECT_SHAKE
	}

	Maybe<RoleAnimations> play_animation_immediate { get; }

	bool stop_animation_immediate { get; }

	void resetWantedAnimation();
}
