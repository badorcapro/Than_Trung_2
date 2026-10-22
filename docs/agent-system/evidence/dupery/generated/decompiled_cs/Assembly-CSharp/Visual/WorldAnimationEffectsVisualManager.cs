using System.Collections.Generic;
using System.Linq;
using GRGLib.Serializable;
using UnityEngine;

namespace Visual;

public class WorldAnimationEffectsVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform animation_parent;

	[SerializeField]
	private BoardVisualManager board_visual;

	[Header("Prefabs")]
	[SerializeField]
	private SerializableDictionary<IHaveAnimation.RoleAnimations, WorldAnimationEffect> animation_effect_prefabs;

	private Dictionary<Roles, WorldAnimationEffect> animations = new Dictionary<Roles, WorldAnimationEffect>();

	public void checkForWorldAnimations(CaseSnapshot _snapshot)
	{
		List<RoleData> list = _snapshot.address_occupents.Values.Where((RoleData _a) => _a is IHaveAnimation).ToList();
		if (list.Count <= 0)
		{
			return;
		}
		foreach (RoleData item in list)
		{
			IHaveAnimation haveAnimation = item as IHaveAnimation;
			if (haveAnimation.play_animation_immediate.is_some)
			{
				playWorldAnimation(item, _snapshot, haveAnimation.play_animation_immediate.value);
				haveAnimation.resetWantedAnimation();
			}
			else if (haveAnimation.stop_animation_immediate)
			{
				stopWorldAnimation(item);
				haveAnimation.resetWantedAnimation();
			}
		}
	}

	public void playWorldAnimation(RoleData _role, CaseSnapshot _snapshot, IHaveAnimation.RoleAnimations _animation)
	{
		if (animation_effect_prefabs.ContainsKey(_animation))
		{
			WorldAnimationEffect worldAnimationEffect = Object.Instantiate(animation_effect_prefabs[_animation], animation_parent);
			worldAnimationEffect.startAnimation(_role, _snapshot, board_visual);
			animations[_role.role] = worldAnimationEffect;
		}
	}

	public void stopWorldAnimation(RoleData _role)
	{
		if (animations.ContainsKey(_role.role))
		{
			animations[_role.role].stopAnimation();
			animations.Remove(_role.role);
		}
	}
}
