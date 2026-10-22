public class CasinoCaseActionPayload : CaseActionPayload
{
	public int chips;

	public bool chips_hidden;

	public float cost_multi;

	public CasinoCard left_card;

	public CasinoCard right_card;

	public CasinoCaseActionPayload(int _current_chips, bool _hide_chips, float _cost_multi, CasinoCard _left, CasinoCard _right)
	{
		bool flag = _hide_chips;
		chips = _current_chips;
		chips_hidden = flag;
		cost_multi = _cost_multi;
		left_card = _left;
		right_card = _right;
	}
}
