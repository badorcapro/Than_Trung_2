using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Librarian : ClockRoleData
{
	private const int trigger_hour = 5;

	private List<int> targets = new List<int>();

	private int starting_hour = -1;

	public override Roles role => Roles.LIBRARIAN;

	public override string english_name => "Librarian";

	public override string english_description => $"{TextHelper.whenInvestigated} and every {5} hours after that, I {Keywords.ANNOUNCE.toString()} an {Keywords.ADDRESS.toString()} from the column containing the most {TextHelper.evilRoles}. " + "I will " + Keywords.ANNOUNCE.toString() + " the " + TextHelper.addresses + " of the " + TextHelper.goodRoles + " in that column first.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " " + TextHelper.addresses + " from the column containing the most " + TextHelper.goodRoles + " starting with the " + TextHelper.addresses + " of the " + TextHelper.evilRoles + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public Librarian(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Librarian(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			starting_hour = int.Parse(array[0]);
			targets = array[1].fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			targets = new List<int>();
			starting_hour = -1;
		}
	}

	protected override string generateClockInfoString(ClockCaseSnapshot _snap)
	{
		if (starting_hour == -1)
		{
			starting_hour = base.clock_case.getTrueHoursPassed();
			createInitialTarget(_snap.board);
		}
		if (targets.Count > 0)
		{
			return getInfo(targets);
		}
		Debug.LogError($"No targets set but trying to generate info? {role}!");
		return "";
	}

	private string getInfo(List<int> _targets)
	{
		return checkTranslationWithReplace(() => getInfoEnglish(CaseHelper.getSimpleMultiAddress(_targets)), () => CaseHelper.getSimpleMultiAddress(_targets));
	}

	private string getInfoEnglish(string _data)
	{
		return "I read about " + _data + ".";
	}

	public override string getUniqueSaveData()
	{
		return $"{starting_hour}#{targets.toStringCommaSeperated()}";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (_investigated_address == base.address)
		{
			starting_hour = base.clock_case.getTrueHoursPassed();
			createInitialTarget(_board);
		}
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	private void createInitialTarget(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		(List<RoleData>, List<RoleData>) tuple = _board.getRolesInPlay().Values.split((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL);
		List<RoleData> item = tuple.Item1;
		List<RoleData> item2 = tuple.Item2;
		Dictionary<int, List<int>> column_goods = new Dictionary<int, List<int>>();
		Dictionary<int, List<int>> column_evils = new Dictionary<int, List<int>>();
		item.ForEach(delegate(RoleData _r)
		{
			column_evils.addOrCreate(_r.getBoardPosition().x, _r.getAddress());
		});
		item2.ForEach(delegate(RoleData _r)
		{
			column_goods.addOrCreate(_r.getBoardPosition().x, _r.getAddress());
		});
		Dictionary<int, List<int>> obj = (base.has_bad_info ? column_goods : column_evils);
		List<int> list = new List<int>();
		int num = 0;
		foreach (KeyValuePair<int, List<int>> item3 in obj)
		{
			if (item3.Value.Count > num)
			{
				list = item3.Key.makeListFromItem();
				num = item3.Value.Count;
			}
			else if (item3.Value.Count == num)
			{
				list.Add(item3.Key);
			}
		}
		int randomElementFromList = list.getRandomElementFromList(random);
		List<int> list2 = ((!base.has_bad_info) ? (column_goods.ContainsKey(randomElementFromList) ? column_goods[randomElementFromList] : new List<int>()) : (column_evils.ContainsKey(randomElementFromList) ? column_evils[randomElementFromList] : new List<int>()));
		if (list2.Count > 0)
		{
			targets.Add(list2.getRandomElementFromList(random));
			return;
		}
		List<int> list3 = (base.has_bad_info ? column_goods[randomElementFromList] : column_evils[randomElementFromList]);
		targets.Add(list3.getRandomElementFromList(random));
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		if (!base.investigated || base.dead || starting_hour == -1)
		{
			return _board;
		}
		checkAddTarget(_board, _new_time);
		return base.onTimePassedAction(_board, _rep, _new_time);
	}

	private void checkAddTarget(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _time)
	{
		if ((_time - starting_hour) / 5 + 1 == targets.Count)
		{
			return;
		}
		List<RoleData> list = (from _r in _board.getRolesInColumn(_board.getRolesInPlay()[targets[0]].getBoardPosition(), base.case_ref.board_size)
			where !targets.Contains(_r.getAddress())
			select _r).ToList();
		if (list.Count > 0)
		{
			Alignments prioritise = (base.has_bad_info ? Alignments.EVIL : Alignments.GOOD);
			List<RoleData> list2 = list.Where((RoleData _r) => _r.getVisualAlignment() == prioritise).toListSafe();
			if (list2.Count == 0)
			{
				targets.Add(list.getRandomElementFromList(random).getAddress());
			}
			else
			{
				targets.Add(list2.getRandomElementFromList(random).getAddress());
			}
			resetInfo();
		}
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return targets.Contains(_occupent.maybe_a.value.getAddress());
	}
}
