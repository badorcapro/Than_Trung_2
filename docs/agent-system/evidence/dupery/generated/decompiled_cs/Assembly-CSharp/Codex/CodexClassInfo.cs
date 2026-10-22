using System.Collections.Generic;
using System.Linq;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace Codex;

public class CodexClassInfo : MonoBehaviour, IAmLocalised
{
	[Header("References")]
	[SerializeField]
	private TMP_Text description;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_discovered_key => "Codex [disc]";

	private string loc_selectedRoles_key => "Codex [sele_R]";

	private string loc_selectedQuirks_key => "Codex [sele_Q]";

	private string loc_selectedQuirksMost_key => "Codex [sele_QM]";

	public void setUpAsSelection(int _min_required, int _current_selected, bool _roles)
	{
		description.text = (_roles ? getSelectRolesText(_min_required, _current_selected) : getSelectQuirksText(_min_required, _current_selected));
	}

	public void setUpAsMaxQuirkSelection(int _max_required, int _current_selected)
	{
		description.text = getSelectQuirksMaxText(_max_required, _current_selected);
	}

	public void setUpClass(RoleClassifications _classification, List<Roles> _roles)
	{
		description.text = GameHandler.Text.getDescription(_classification);
		List<Roles> list = _roles.Where((Roles _r) => _r.getClassificationFromRoleType() == _classification).ToList();
		List<Roles> discovered_all = GameHandler.StatsData.roles_discovered;
		int discovered = list.Aggregate(0, (int _a, Roles _r) => _a + (discovered_all.Contains(_r) ? 1 : 0));
		TMP_Text tMP_Text = description;
		tMP_Text.text = tMP_Text.text + "\n\n" + getDiscoveredText(discovered, list.Count);
	}

	public void setUpQuirks(List<CaseQuirks> _quirks)
	{
		description.text = GameHandler.Text.getQuirksDescription();
		TMP_Text tMP_Text = description;
		tMP_Text.text = tMP_Text.text + "\n\n" + getDiscoveredText(GameHandler.StatsData.played_case_quirks.Count((CaseQuirks _q) => _quirks.Contains(_q)), _quirks.Count);
	}

	private string getDiscoveredText(int _discovered, int _total)
	{
		return localisation_asset.checkTranslationWithData(loc_discovered_key, englishDiscovered, $"{_discovered}/{_total}");
	}

	private string englishDiscovered(string _data)
	{
		return "Discovered: " + _data;
	}

	private string getSelectRolesText(int _min, int _selected)
	{
		return localisation_asset.checkTranslationWithData(loc_selectedRoles_key, englishSelectRoles, _min.ToString(), _selected.ToString());
	}

	private string getSelectQuirksText(int _min, int _selected)
	{
		return localisation_asset.checkTranslationWithData(loc_selectedQuirks_key, englishSelectQuirks, _min.ToString(), _selected.ToString());
	}

	private string getSelectQuirksMaxText(int _min, int _selected)
	{
		return localisation_asset.checkTranslationWithData(loc_selectedQuirksMost_key, englishSelectQuirksMax, _min.ToString(), _selected.ToString());
	}

	private string englishSelectRoles(string _d1, string _d2)
	{
		return "Select at least " + _d1 + " roles. (" + _d2 + " currently selected)";
	}

	private string englishSelectQuirks(string _d1, string _d2)
	{
		return "Select at least " + _d1 + " quirks. (" + _d2 + " currently selected)";
	}

	private string englishSelectQuirksMax(string _d1, string _d2)
	{
		return "Select at most " + _d1 + " quirks. (" + _d2 + " currently selected)";
	}
}
