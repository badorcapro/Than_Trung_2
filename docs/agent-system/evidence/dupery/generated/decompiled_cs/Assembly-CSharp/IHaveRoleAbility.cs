public interface IHaveRoleAbility : IHaveAbility
{
	bool allowSelfTarget { get; }

	bool validateTarget(RoleData _roll_candidate);
}
