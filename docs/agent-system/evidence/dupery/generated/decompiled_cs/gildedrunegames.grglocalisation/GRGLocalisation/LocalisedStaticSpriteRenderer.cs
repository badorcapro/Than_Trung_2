using UnityEngine;

namespace GRGLocalisation;

public class LocalisedStaticSpriteRenderer : LocalisedStaticVisualBase<SpriteRenderer>
{
	protected override void setSprite(Sprite _sprite)
	{
		visual.sprite = _sprite;
	}

	protected override Sprite getSprite(SpriteRenderer _visual)
	{
		return visual.sprite;
	}

	private void Reset()
	{
		visual = GetComponent<SpriteRenderer>();
		if (!(visual == null) && !(visual.sprite == null))
		{
			key = ((visual.sprite.name.Length < 15) ? visual.sprite.name : visual.sprite.name.Substring(0, 15));
		}
	}
}
