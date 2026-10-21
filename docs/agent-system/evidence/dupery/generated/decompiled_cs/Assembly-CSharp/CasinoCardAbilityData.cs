public class CasinoCardAbilityData : AbilityData
{
	public CasinoCard card_picked;

	public override string as_debug => card_picked.info.ToString();

	public CasinoCardAbilityData(CasinoCard _card)
	{
		card_picked = _card;
	}
}
