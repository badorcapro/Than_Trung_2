using Audio;
using GRGLib.Maybe;

public interface IHaveAudio
{
	Maybe<Sfx> play_sfx_immidiate { get; }

	void resetWantedSfx();
}
