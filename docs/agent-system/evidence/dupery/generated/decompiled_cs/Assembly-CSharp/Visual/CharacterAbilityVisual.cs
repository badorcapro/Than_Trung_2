using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class CharacterAbilityVisual : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private Image ability_available;

	[SerializeField]
	private Image ability_used;

	public bool available { get; private set; } = true;

	public void onInvestigate(RoleData _data)
	{
		if (!_data.getHasAnyAbility())
		{
			group.alpha = 0f;
			available = false;
			return;
		}
		available = !_data.getIsAbilityExhausted();
		ability_available.color = new Color(1f, 1f, 1f, available ? 1 : 0);
		ability_used.color = new Color(1f, 1f, 1f, (!available) ? 1 : 0);
		group.blocksRaycasts = true;
		group.alpha = 1f;
	}

	public void onUseAbility()
	{
		available = false;
		ability_available.fade(0f, 0.35f, CoroutineExtensions.easeInOutFunc).start(this);
		ability_used.fade(1f, 0.35f, CoroutineExtensions.easeInOutFunc).start(this);
	}

	public void restoreAbility(RoleData _data)
	{
		if (!_data.getHasAnyAbility())
		{
			Debug.LogError("Cannot restore ability or role that does not have an ability!");
			return;
		}
		available = !_data.getIsAbilityExhausted();
		ability_available.color = new Color(1f, 1f, 1f, available ? 1 : 0);
		ability_used.color = new Color(1f, 1f, 1f, (!available) ? 1 : 0);
	}

	public void revealAbility()
	{
		ability_available.color = new Color(1f, 1f, 1f, available ? 1 : 0);
		ability_used.color = new Color(1f, 1f, 1f, (!available) ? 1 : 0);
		group.blocksRaycasts = true;
		group.alpha = 1f;
	}
}
