using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Surgin : ClockRoleData
{
	private bool ability_tripped;

	private int trigger_hour = 12;

	private int victim = -1;

	private Maybe<bool> force_kill = new Maybe<bool>();

	public override Roles role => Roles.SURGIN;

	public override string english_name => "Surgeon";

	public override string english_description => $"On the {trigger_hour}th hour I might {Keywords.KILL.toString()} an {TextHelper.innocentRole}.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.SPECIAL, "I " + Keywords.KILL.toString() + " 50% of the time."),
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I never " + Keywords.KILL.toString() + ".")
	};

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => victim > 0;

	public Surgin(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Surgin(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			ability_tripped = _save.unique_data.StartsWith("t");
			string s = _save.unique_data.Replace("t", "");
			victim = ((_save.unique_data.Length == 0) ? (-1) : int.Parse(s));
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nData: {_save.unique_data}\nError: {arg}");
			ability_tripped = true;
			victim = -1;
		}
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		if (_new_time >= trigger_hour && !base.dead && !base.arrested && !ability_tripped)
		{
			ability_tripped = true;
			if (!base.has_bad_info)
			{
				if (force_kill.is_some && !force_kill.value)
				{
					return _board;
				}
				if (force_kill.is_some || random.Next(0, 2) == 0 || base.case_ref.hasMarkerQuirk(CaseQuirks.MEDICAL_BREAKTHROUGH))
				{
					List<RoleData> list = _board.getRolesInPlay().Values.Where((RoleData _e) => _e.getVisualClassification() == RoleClassifications.INNOCENT && !_e.getIsDead()).ToList();
					if (list.Count == 0)
					{
						return _board;
					}
					victim = list.getRandomElementFromList(random).getAddress();
					return base.case_ref.killAddress(victim, ((RoleData)this).maybe()).board;
				}
			}
		}
		return _board;
	}

	protected override void setDisguiseData(Case _case_ref)
	{
		if (_case_ref != null && _case_ref is ClockCase clockCase && clockCase.getTrueHoursPassed() >= trigger_hour)
		{
			ability_tripped = true;
		}
	}

	public void forceKillAtTrigger(bool _true = true)
	{
		force_kill = _true.maybe();
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		if (victim != -1)
		{
			return checkTranslationWithReplace(base.loc_default_truth_key, () => getTruthEnglish(trigger_hour.ToString(), victim.ToString()), trigger_hour, victim);
		}
		return base.getTruthString();
	}

	private string getTruthEnglish(string _data, string _data_2)
	{
		return "At " + _data + "h, I killed #" + _data_2;
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == victim;
		}
		return false;
	}

	public override List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		if (victim != -1)
		{
			return getRevealLineToTarget(victim, RevealLineColour.RED, _snap);
		}
		return new List<RevealLineSettings>();
	}

	public override string getUniqueSaveData()
	{
		if (!ability_tripped)
		{
			return "";
		}
		return $"t{victim}";
	}
}
