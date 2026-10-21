using Visual;

namespace AlternateModes;

public interface IMessWithCases
{
	void onCaseStart(Case _case, GameVisualManager _world);

	void onInteraction(Case _case, GameVisualManager _world);

	void onCaseEnd(Case _case, CaseSnapshot _snap, bool _solved);
}
