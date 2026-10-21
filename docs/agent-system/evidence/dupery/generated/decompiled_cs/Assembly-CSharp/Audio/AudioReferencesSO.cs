using FMODUnity;
using GRGLib.Serializable;
using UnityEngine;

namespace Audio;

[CreateAssetMenu(menuName = "ScriptableObject/Audio/Audio References")]
public class AudioReferencesSO : ScriptableObject
{
	[SerializeField]
	private SerializableDictionary<Music, EventReference> music_references;

	[SerializeField]
	private SerializableDictionary<Sfx, EventReference> sfx_references;

	[SerializeField]
	private SerializableDictionary<Atmo, EventReference> atmo_references;

	public EventReference this[Music _music] => music_references[_music];

	public EventReference this[Sfx _sfx] => sfx_references[_sfx];

	public EventReference this[Atmo _atmo] => atmo_references[_atmo];
}
