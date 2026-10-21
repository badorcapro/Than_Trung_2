using System.Collections.Generic;
using System.IO;
using GRGLib.Extensions.Collections;
using GRGLib.Save;
using GRGLib.Serializable;
using GRGLocalisation;
using Localisation;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Regions/(old) Region Data")]
public class _dep_RegionDataSO : ScriptableObject, IAmLocalised
{
	public Regions region;

	public CaseType case_type;

	[SerializeField]
	private string english_region_name;

	[SerializeField]
	private string english_fired_end_text;

	[Header("Roles")]
	[SerializeField]
	private List<Roles> starting_available_roles;

	[SerializeField]
	private List<Roles> allowed_roles;

	[SerializeField]
	private bool allow_all_roles;

	[Header("Case Quirks")]
	[Range(-1f, 101f)]
	public int case_quirks_threshold = 50;

	[SerializeField]
	private List<CaseQuirks> allowed_quirks;

	[SerializeField]
	private bool allow_all_quirks;

	[Header("Traitors")]
	public bool allow_traitors;

	public int min_traitors_last = 1;

	public string region_name => localisation_asset.checkTranslation(loc_name_key, () => english_region_name);

	public string fired_end_text => localisation_asset.checkTranslation(loc_end_fired_key, () => english_fired_end_text);

	public int findable_roles_count => starting_available_roles.Count + allowed_roles.Count;

	private string loc_name_key => $"R{(int)region} [name]";

	private string loc_end_fired_key => $"R{(int)region} [fired]";

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public List<Roles> getStartingRoles()
	{
		return starting_available_roles.copy();
	}

	public List<Roles> getAllowedRoles()
	{
		if (!allow_all_roles)
		{
			return allowed_roles.copy();
		}
		return case_type.getRoleList(SettingsHandler.allow_test_roles);
	}

	public bool canRoleAppear(Roles _role)
	{
		if (!starting_available_roles.Contains(_role))
		{
			return getAllowedRoles().Contains(_role);
		}
		return true;
	}

	public List<CaseQuirks> getAllowedQuirks()
	{
		if (!allow_all_quirks)
		{
			return allowed_quirks;
		}
		return CaseQuirkHelper.getAllQuirks((CaseQuirks _q) => _q.createQuirk().isCompatible(case_type));
	}

	public bool canQuirkAppear(CaseQuirks _quirk)
	{
		return getAllowedQuirks().Contains(_quirk);
	}

	public void printRoleCsv()
	{
		Dictionary<Roles, STupple<string, string>> dictionary = new Dictionary<Roles, STupple<string, string>>();
		foreach (Roles item in new List<Roles>().addAll())
		{
			dictionary[item] = new STupple<string, string>(starting_available_roles.Contains(item) ? "#" : "", allowed_roles.Contains(item) ? "#" : "");
		}
		List<List<string>> list = new List<List<string>>();
		list.Add(new List<string> { "Role", "Starting", "Available" });
		foreach (KeyValuePair<Roles, STupple<string, string>> item2 in dictionary)
		{
			list.Add(new List<string>
			{
				item2.Key.ToString(),
				item2.Value.Item1,
				item2.Value.Item2
			});
		}
		list.printToCSV($"{region}Roles.csv", Path.Combine(Application.dataPath, "../Build/Debug/"));
	}
}
