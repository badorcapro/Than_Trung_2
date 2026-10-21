using System;

namespace Nodes;

public class SpriteAssetStringNode : StringNodeBase
{
	public enum SpriteAssets
	{
		ABILITY_ON,
		ABILITY_OFF,
		CHIPS,
		AFFECTED_COSTS
	}

	[NodeEnum]
	public SpriteAssets asset;

	public int sizePercent = 100;

	[NodeEnum]
	public TextAnimationType animation;

	protected override string fetchNodeString(IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return getString();
	}

	private string getString()
	{
		return createString(getLink(), _bold: false, _italic: false, TextColour.DEFAULT, animation, 1f, sizePercent);
	}

	private string getLink()
	{
		return asset switch
		{
			SpriteAssets.ABILITY_ON => TextHelper.ability_on_sprite_link, 
			SpriteAssets.ABILITY_OFF => TextHelper.ability_off_sprite_link, 
			SpriteAssets.CHIPS => TextHelper.chips_sprite_link, 
			SpriteAssets.AFFECTED_COSTS => TextHelper.affected_by_multi_sprite_link, 
			_ => throw new ArgumentException($"No link set up for sprite asset {asset}!"), 
		};
	}

	protected override string localisationReplacements(string _localised_text, IStringFetcher _fetcher, DialogueSpeachers _speacher)
	{
		return _localised_text.Replace(getStringKey(), getString());
	}

	private string getStringKey()
	{
		return $"{{SA_{UID}}}";
	}
}
