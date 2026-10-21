public interface IHaveAbility
{
	bool abilityExhausted { get; }

	int numberTargets { get; }

	string getAbilityPrompt();
}
