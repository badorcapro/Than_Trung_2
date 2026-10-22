using UnityEngine;

namespace Visual;

public abstract class WorldAnimationEffect : MonoBehaviour
{
	public abstract void startAnimation(RoleData _role, CaseSnapshot _snap, BoardVisualManager _board_visual);

	public abstract void stopAnimation();
}
