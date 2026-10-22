using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.UI;
using GRGLocalisation;
using Localisation;
using TMPro;
using UnityEngine;

namespace LevelEditor;

public class LEAdderMenu : MenuBase, IAmLocalised
{
	public enum AdderSection
	{
		ROLE,
		LOCATION,
		QUIRK
	}

	private abstract class AdderMenuSection<T>
	{
		protected LEAdderMenu adder;

		protected List<T> vetoed = new List<T>();

		protected Dictionary<T, string> names = new Dictionary<T, string>();

		public AdderMenuSection(LEAdderMenu _menu, List<T> _vetoed)
		{
			adder = _menu;
			vetoed = _vetoed;
		}

		protected abstract string createNameFromKey(T _key);

		protected string getName(T _el)
		{
			if (!names.ContainsKey(_el))
			{
				names[_el] = createNameFromKey(_el);
			}
			return names[_el];
		}

		protected abstract string getName(LEAdderItem _item);

		protected abstract List<T> getInitialList();

		protected virtual List<T> sortList(List<T> _items)
		{
			_items.Sort((T _a, T _b) => getName(_a).CompareTo(getName(_b)));
			return _items;
		}

		public List<T> getFreshList()
		{
			List<T> initialList = getInitialList();
			initialList.removeRange(vetoed);
			return sortList(initialList);
		}

		public void filterItems(List<LEAdderItem> _all_items, string _input)
		{
			int num = 0;
			for (int i = 0; i < _all_items.Count; i++)
			{
				if (num < 54 && getName(_all_items[i]).ToLower().StartsWith(_input))
				{
					num++;
					_all_items[i].gameObject.SetActive(value: true);
				}
				else
				{
					_all_items[i].gameObject.SetActive(value: false);
				}
			}
		}
	}

	private class AdderRoleSection : AdderMenuSection<Roles>
	{
		private List<Roles> allowed_roles = new List<Roles>();

		private List<RoleClassifications> allowed_class = new List<RoleClassifications>();

		private Maybe<RoleClassifications> classification = new Maybe<RoleClassifications>();

		public AdderRoleSection(LEAdderMenu _adder, List<Roles> _base_roles, List<RoleClassifications> _class, List<Roles> _vetoed)
			: base(_adder, _vetoed)
		{
			allowed_roles = _base_roles;
			allowed_class = ((_class.Count == 0) ? new List<RoleClassifications>().addAll() : _class);
			setUpDropdown(_adder.all_localised);
			_adder.createRoleItems(getFreshList());
		}

		public void setUpDropdown(string _all)
		{
			adder.setUpDropdown(_all.makeListFromItem().addRange(allowed_class.Select((RoleClassifications _rc) => _rc.toString())), onClassificationChange, (int)classification.value);
		}

		private void onClassificationChange(int _option)
		{
			if (_option == 0)
			{
				if (!classification.is_some)
				{
					return;
				}
				classification = new Maybe<RoleClassifications>();
			}
			else
			{
				RoleClassifications roleClassifications = (RoleClassifications)(_option - 1);
				if (classification.is_some && classification.value == roleClassifications)
				{
					return;
				}
				classification = roleClassifications.maybe();
			}
			adder.all_items.destroyAll();
			adder.createRoleItems(getFreshList());
		}

		protected override string createNameFromKey(Roles _key)
		{
			return _key.toStringPlain();
		}

		protected override string getName(LEAdderItem _item)
		{
			return getName(_item.role.value);
		}

		protected override List<Roles> getInitialList()
		{
			List<Roles> list = ((allowed_roles.Count > 0) ? allowed_roles : adder.case_type.getRoleList());
			if (classification.is_some)
			{
				list = list.getClassification(classification.value);
			}
			return list;
		}

		protected override List<Roles> sortList(List<Roles> _items)
		{
			if (classification.is_some)
			{
				return base.sortList(_items);
			}
			_items.Sort(delegate(Roles _a, Roles _b)
			{
				int num = _a.getClassificationFromRoleType().CompareTo(_b.getClassificationFromRoleType());
				return (num != 0) ? num : getName(_a).CompareTo(getName(_b));
			});
			return _items;
		}
	}

	private class AdderLocationSection : AdderMenuSection<LocationTypes>
	{
		public AdderLocationSection(LEAdderMenu _adder, List<LocationTypes> _vetoed)
			: base(_adder, _vetoed)
		{
			_adder.hideDropdown();
			_adder.createLocationItems(getFreshList());
		}

		protected override string createNameFromKey(LocationTypes _key)
		{
			return _key.toString();
		}

		protected override string getName(LEAdderItem _item)
		{
			return getName(_item.location.value);
		}

		protected override List<LocationTypes> getInitialList()
		{
			return CollectionsExtension.addAll(new List<LocationTypes>(), (LocationTypes _l) => !_l.isScrapped() && _l.isLocationOfCaseType(adder.case_type));
		}
	}

	public const int max_items = 54;

	[SerializeField]
	private RoleVisualDataSO role_data;

	[SerializeField]
	private LocationVisualDataSO location_data;

	[Header("References")]
	[SerializeField]
	private RectTransform items_parent;

	[SerializeField]
	private AnimatedLayoutGroup layout_group;

	[SerializeField]
	private TMP_InputField input_field;

	[SerializeField]
	private TMP_Dropdown dropdown;

	[Header("Prefabs")]
	[SerializeField]
	private LEAdderItem item_prefab;

	private CaseType case_type;

	private string last_string = "";

	private List<LEAdderItem> all_items = new List<LEAdderItem>();

	private AdderSection section;

	private Maybe<AdderRoleSection> role_selection = new Maybe<AdderRoleSection>();

	private Maybe<AdderLocationSection> location_selection = new Maybe<AdderLocationSection>();

	private Action<LEAdderItem> on_choice;

	private Action<int> on_dropdown;

	public string all_localised => localisation_asset.checkTranslation("All", () => "All");

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public void setUpChoiceCallback(Action<LEAdderItem> _on_choice)
	{
		on_choice = _on_choice;
	}

	private void setUp(CaseType _case_type)
	{
		case_type = _case_type;
		last_string = "";
		input_field.SetTextWithoutNotify("");
	}

	public void setUpRoles(CaseType _case_type, List<Roles> _vetoed)
	{
		setUpRoles(_case_type, _case_type.getRoleList(), new List<RoleClassifications>().addAll(), _vetoed);
	}

	public void setUpRoles(CaseType _case_type, List<Roles> _available, List<RoleClassifications> _allowed, List<Roles> _vetoed)
	{
		setUp(_case_type);
		all_items.destroyAll();
		role_selection = new AdderRoleSection(this, _available, _allowed, _vetoed).maybe();
		section = AdderSection.ROLE;
		checkLayout();
	}

	public void setUpLocations(CaseType _case_type, List<LocationTypes> _vetoed)
	{
		setUp(_case_type);
		all_items.destroyAll();
		section = AdderSection.LOCATION;
		location_selection = new AdderLocationSection(this, _vetoed).maybe();
		checkLayout();
	}

	private void hideDropdown()
	{
		dropdown.gameObject.SetActive(value: false);
	}

	private void setUpDropdown(List<string> _options, Action<int> _callback, int _default_value)
	{
		dropdown.gameObject.SetActive(value: true);
		dropdown.ClearOptions();
		dropdown.AddOptions(_options);
		dropdown.SetValueWithoutNotify(_default_value);
		on_dropdown = _callback;
	}

	public void onDropdownChange(int _option)
	{
		on_dropdown(_option);
		if (last_string != "")
		{
			filterList(last_string);
		}
		checkLayout();
	}

	public void onInput(string _input)
	{
		filterList(_input);
		last_string = _input;
		checkLayout();
	}

	private void resetList()
	{
		switch (section)
		{
		case AdderSection.ROLE:
			if (!role_selection.is_some)
			{
				Debug.LogError("Adder menu is in role section but role selection is not set up (resetList)!");
			}
			else
			{
				createRoleItems(role_selection.value.getFreshList());
			}
			break;
		case AdderSection.LOCATION:
			if (!location_selection.is_some)
			{
				Debug.LogError("Adder menu is in location section but location selection is not set up (resetList)!");
			}
			else
			{
				createLocationItems(location_selection.value.getFreshList());
			}
			break;
		}
	}

	private void filterList(string _input)
	{
		switch (section)
		{
		case AdderSection.ROLE:
			if (!role_selection.is_some)
			{
				Debug.LogError("Adder menu is in role section but role selection is not set up (filterList)!");
			}
			else
			{
				role_selection.value.filterItems(all_items, _input.ToLower());
			}
			break;
		case AdderSection.LOCATION:
			if (!location_selection.is_some)
			{
				Debug.LogError("Adder menu is in location section but location selection is not set up (filterList)!");
			}
			else
			{
				location_selection.value.filterItems(all_items, _input.ToLower());
			}
			break;
		default:
			Debug.LogError($"No filter set up for adder section {section}!");
			break;
		}
	}

	private void checkLayout()
	{
		0.01f.wait(delegate
		{
			layout_group.checkUpdateWithOrder();
		}).start(this);
	}

	private void createRoleItems(List<Roles> _roles)
	{
		for (int i = 0; i < _roles.Count; i++)
		{
			LEAdderItem lEAdderItem = UnityEngine.Object.Instantiate(item_prefab, items_parent);
			lEAdderItem.setUp(_roles[i], role_data, onSelection);
			if (i >= 54)
			{
				lEAdderItem.gameObject.SetActive(value: false);
			}
			all_items.Add(lEAdderItem);
		}
	}

	private void createLocationItems(List<LocationTypes> _locations)
	{
		for (int i = 0; i < _locations.Count; i++)
		{
			LEAdderItem lEAdderItem = UnityEngine.Object.Instantiate(item_prefab, items_parent);
			lEAdderItem.setUp(_locations[i], location_data, onSelection);
			if (i >= 54)
			{
				lEAdderItem.gameObject.SetActive(value: false);
			}
			all_items.Add(lEAdderItem);
		}
	}

	private void onSelection(LEAdderItem _item)
	{
		if (base.is_open)
		{
			on_choice(_item);
			closeMenu();
		}
	}
}
