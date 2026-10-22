using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Tutorial;
using UnityEngine;

public static class TutorialHelper
{
	public static CaseType getTutorialType(this Regions _region)
	{
		return _region switch
		{
			Regions.OFFICE => CaseType.CLOCK, 
			Regions.CASINO => CaseType.CASINO, 
			Regions.DOCKS => CaseType.DOCKS, 
			_ => (CaseType)(-1), 
		};
	}

	public static Tutorials toTutorial(this CaseType _type)
	{
		return _type switch
		{
			CaseType.CLOCK => Tutorials.OFFICE_MAIN, 
			CaseType.CASINO => Tutorials.CASINO_MAIN, 
			CaseType.DOCKS => Tutorials.DOCKS_MAIN, 
			CaseType.BACK_ALLEYS => Tutorials.BACK_ALLEYS_MAIN, 
			_ => throw new ArgumentException($"No tutorial set up for case type {_type}!"), 
		};
	}

	public static bool hasNextTutorialCase(int _case)
	{
		return _case < 8;
	}

	public static bool hasNextTutorialCase(CaseType _type, int _case)
	{
		return _type switch
		{
			CaseType.CLOCK => _case < 8, 
			CaseType.DOCKS => _case < 4, 
			CaseType.CASINO => _case < 2, 
			_ => throw new ArgumentException($"No hasNextTutorialCase set up for region {_type}!"), 
		};
	}

	public static Case createTutorialCase(CaseType _type, int _case, System.Random _rng)
	{
		return _type switch
		{
			CaseType.CLOCK => createOfficeTutorialCase(_case, _rng), 
			CaseType.DOCKS => createDockTutorialCase(_case, _rng), 
			CaseType.CASINO => createCasinoTutorialCase(_case, _rng), 
			_ => throw new ArgumentException($"No tutorial cases set up for region {_type}!!! (case: {_case})"), 
		};
	}

	public static Case createOfficeTutorialCase(int _case, System.Random _rng, int _reputation = 5)
	{
		return _case switch
		{
			1 => createOfficeTutorial1(_rng, _reputation), 
			2 => createOfficeTutorial2(_rng, _reputation), 
			3 => createOfficeTutorial3(_rng, _reputation), 
			4 => createOfficeTutorial4(_rng, _reputation), 
			5 => createOfficeTutorial5(_rng, _reputation), 
			6 => createOfficeTutorial6(_rng, _reputation), 
			7 => createOfficeTutorial7(_rng, _reputation), 
			8 => createOfficeTutorial8(_rng, _reputation), 
			_ => throw new ArgumentException($"No tutorial case {_case} set up for office region!"), 
		};
	}

	public static Case createOfficeTutorial1(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(3, 3), _reputation, new List<Roles>
		{
			Roles.PRIEST,
			Roles.SCOUNDREL
		}, new List<RoleData>
		{
			Roles.PRIEST.createRole(1, new Vector2Int(0, 1), _rng, new Maybe<RoleData>()),
			Roles.SCOUNDREL.createRole(2, new Vector2Int(2, 1), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(1, 2))
		}, 1.maybe());
	}

	public static Case createOfficeTutorial2(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(3, 3), _reputation, new List<Roles>
		{
			Roles.PRIEST,
			Roles.MOBSTER
		}, new List<RoleData>
		{
			Roles.PRIEST.createRole(1, new Vector2Int(0, 1), _rng, new Maybe<RoleData>()),
			Roles.MOBSTER.createSetRoleWithDisguise(2, new Vector2Int(2, 1), _rng, Roles.PRIEST)
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(0, 2))
		}, 2.maybe());
	}

	public static Case createOfficeTutorial3(System.Random _rng, int _reputation = 5)
	{
		Spectre spectre = Roles.SPECTRE.createSetRoleWithDisguise(4, new Vector2Int(1, 1), _rng, Roles.THERAPIST, delegate(Therapist _t)
		{
			_t.createAndForceSetInfo(3);
		}) as Spectre;
		spectre.forceTargetAddress(3);
		return new ClockCase(new Vector2Int(3, 3), _reputation, new List<Roles>
		{
			Roles.PRIEST,
			Roles.THERAPIST,
			Roles.MAILMAN,
			Roles.REPORTER,
			Roles.SPECTRE,
			Roles.MOBSTER
		}, new List<RoleData>
		{
			(Roles.MAILMAN.createRole(1, new Vector2Int(0, 0), _rng, new Maybe<RoleData>()) as Mailman).createAndForceSetInfo(Roles.PRIEST, Roles.THERAPIST),
			Roles.REPORTER.createRole(2, new Vector2Int(2, 0), _rng, new Maybe<RoleData>()),
			Roles.PRIEST.createRole(3, new Vector2Int(0, 1), _rng, new Maybe<RoleData>()),
			spectre,
			Roles.MOBSTER.createSetRoleWithDisguise(5, new Vector2Int(1, 2), _rng, Roles.REPORTER, delegate(Reporter _r)
			{
				_r.createAndForceSetInfo(2);
			})
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(1, 0))
		}, 3.maybe());
	}

	public static Case createOfficeTutorial4(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(3, 3), _reputation, new List<Roles>
		{
			Roles.PRIEST,
			Roles.MAILMAN,
			Roles.MATHEMATICIAN,
			Roles.TAILOR,
			Roles.MOBSTER
		}, new List<RoleData>
		{
			Roles.MOBSTER.createSetRoleWithDisguise(1, new Vector2Int(0, 0), _rng, Roles.TAILOR),
			Roles.TAILOR.createRole(2, new Vector2Int(2, 0), _rng, new Maybe<RoleData>()),
			Roles.MAILMAN.createSetRole(3, new Vector2Int(0, 2), _rng, delegate(Mailman _m)
			{
				_m.createAndForceSetInfo(Roles.TAILOR, Roles.MATHEMATICIAN);
			}),
			Roles.PRIEST.createRole(4, new Vector2Int(2, 2), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(1, 1))
		}, 4.maybe());
	}

	public static Case createOfficeTutorial5(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(3, 3), _reputation, new List<Roles>
		{
			Roles.PRIEST,
			Roles.VIGILANTE,
			Roles.MATHEMATICIAN,
			Roles.WEATHERMAN,
			Roles.SURGIN,
			Roles.CRITIC,
			Roles.MOBSTER
		}, new List<RoleData>
		{
			Roles.CRITIC.createSetRoleWithDisguise(1, new Vector2Int(0, 0), _rng, Roles.MATHEMATICIAN, delegate(Mathematician _m)
			{
				_m.createAndForceSetInfo(4);
			}),
			Roles.PRIEST.createRole(2, new Vector2Int(2, 0), _rng, new Maybe<RoleData>()),
			Roles.WEATHERMAN.createSetRole(3, new Vector2Int(1, 1), _rng, delegate(Weatherman _w)
			{
				_w.createAndForceSetInfo(new List<int> { 2, 4, 6 });
			}),
			Roles.MOBSTER.createSetRoleWithDisguise(4, new Vector2Int(0, 2), _rng, Roles.PRIEST),
			Roles.VIGILANTE.createRole(5, new Vector2Int(1, 2), _rng, new Maybe<RoleData>()),
			Roles.SURGIN.createRole(6, new Vector2Int(2, 2), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(0, 1))
		}, 5.maybe());
	}

	public static Case createOfficeTutorial6(System.Random _rng, int _reputation = 5)
	{
		Barkeep barkeep = Roles.BARKEEP.createSetRoleWithDisguise(3, new Vector2Int(2, 0), _rng, Roles.REPORTER, delegate(Reporter _r)
		{
			_r.createAndForceSetInfo(4);
		}) as Barkeep;
		barkeep.forceNoTouch(6);
		return new ClockCase(new Vector2Int(3, 3), _reputation, new List<Roles>
		{
			Roles.POISONER,
			Roles.PRIEST,
			Roles.REPORTER,
			Roles.BLOOD_HOUND,
			Roles.THERAPIST,
			Roles.MAILMAN,
			Roles.BARKEEP,
			Roles.MATHEMATICIAN
		}, new List<RoleData>
		{
			Roles.POISONER.createSetRoleWithDisguise(1, new Vector2Int(0, 0), _rng, Roles.REPORTER, delegate(Reporter _r)
			{
				_r.createAndForceSetInfo(3);
			}),
			Roles.PRIEST.createRole(2, new Vector2Int(1, 0), _rng, new Maybe<RoleData>()),
			barkeep,
			Roles.REPORTER.createRole(4, new Vector2Int(2, 1), _rng, new Maybe<RoleData>()),
			Roles.BLOOD_HOUND.createRole(5, new Vector2Int(0, 2), _rng, new Maybe<RoleData>()),
			Roles.DRUNKARD.createSetRoleWithDisguise(6, new Vector2Int(1, 2), _rng, Roles.MAILMAN, delegate(Mailman _m)
			{
				_m.createAndForceSetInfo(Roles.MATHEMATICIAN, Roles.PRIEST);
			}),
			Roles.THERAPIST.createRole(7, new Vector2Int(2, 2), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(1, 1))
		}, 6.maybe(), new Dictionary<RoleClassifications, int>
		{
			{
				RoleClassifications.INNOCENT,
				5
			},
			{
				RoleClassifications.MEDDLER,
				0
			},
			{
				RoleClassifications.UNDERLING,
				2
			},
			{
				RoleClassifications.TRAITOR,
				0
			}
		});
	}

	public static Case createOfficeTutorial7(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(3, 3), _reputation, new List<Roles>
		{
			Roles.SURGIN,
			Roles.BLOOD_HOUND,
			Roles.CLOCK_MAKER,
			Roles.MOBSTER,
			Roles.PRIEST,
			Roles.SERIAL_KILLER,
			Roles.REPORTER,
			Roles.THERAPIST
		}, new List<RoleData>
		{
			Roles.SURGIN.createSetRole(1, new Vector2Int(0, 0), _rng, delegate(Surgin _s)
			{
				_s.forceKillAtTrigger();
			}),
			Roles.THERAPIST.createRole(2, new Vector2Int(1, 0), _rng, new Maybe<RoleData>()),
			Roles.BLOOD_HOUND.createRole(3, new Vector2Int(2, 0), _rng, new Maybe<RoleData>()),
			Roles.MOBSTER.createSetRoleWithDisguise(4, new Vector2Int(0, 1), _rng, Roles.CLOCK_MAKER, delegate(ClockMaker _cm)
			{
				_cm.createAndForceSetInfo(11);
			}),
			Roles.CLOCK_MAKER.createRole(5, new Vector2Int(1, 1), _rng, new Maybe<RoleData>()),
			Roles.REPORTER.createRole(6, new Vector2Int(1, 2), _rng, new Maybe<RoleData>()),
			Roles.SERIAL_KILLER.createSetRoleWithDisguise(7, new Vector2Int(2, 2), _rng, Roles.CLOCK_MAKER, delegate(ClockMaker _cm)
			{
				_cm.createAndForceSetInfo(5);
			})
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(0, 2)),
			new ClockTower(_rng, new Vector2Int(2, 1), new List<(int, ClockTower.ClockTowerRingAttribution)> { (8, ClockTower.ClockTowerRingAttribution.CLOCKTOWER) }, new List<int>())
		}, 7.maybe());
	}

	public static Case createOfficeTutorial8(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(3, 3), _reputation, new List<Roles>
		{
			Roles.THERAPIST,
			Roles.CONMAN,
			Roles.MATHEMATICIAN,
			Roles.COPYCAT,
			Roles.VIGILANTE,
			Roles.MOBSTER
		}, new List<RoleData>
		{
			Roles.THERAPIST.createRole(1, new Vector2Int(0, 0), _rng, new Maybe<RoleData>()),
			Roles.CONMAN.createSetRoleWithDisguise(2, new Vector2Int(1, 0), _rng, Roles.MATHEMATICIAN),
			Roles.COPYCAT.createSetRoleWithDisguise(3, new Vector2Int(0, 1), _rng, Roles.VIGILANTE),
			Roles.MATHEMATICIAN.createRole(4, new Vector2Int(2, 1), _rng, new Maybe<RoleData>()),
			Roles.VIGILANTE.createRole(5, new Vector2Int(1, 2), _rng, new Maybe<RoleData>()),
			Roles.MOBSTER.createSetRoleWithDisguise(6, new Vector2Int(2, 2), _rng, Roles.THERAPIST, delegate(Therapist _t)
			{
				_t.createAndForceSetInfo(3);
			})
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(1, 1))
		}, 8.maybe());
	}

	public static DocksCase createDockTutorialCase(int _case, System.Random _rng, int _reputation = 5)
	{
		return _case switch
		{
			1 => createDockTutorial1(_rng, _reputation), 
			2 => createDockTutorial2(_rng, _reputation), 
			3 => createDockTutorial3(_rng, _reputation), 
			4 => createDockTutorial4(_rng, _reputation), 
			_ => throw new ArgumentException($"No tutorial case {_case} set up for docks region!"), 
		};
	}

	public static DocksCase createDockTutorial1(System.Random _rng, int _reputation = 5)
	{
		return new DocksCase(new Vector2Int(3, 3), _reputation, 12, new List<Roles> { Roles.SCOUNDREL }, new List<RoleData> { Roles.SCOUNDREL.createRole(1, new Vector2Int(2, 2), _rng, new Maybe<RoleData>()) }, new List<LocationData>
		{
			new Docks(_rng, new Vector2Int(0, 0))
		}, 1.maybe());
	}

	public static DocksCase createDockTutorial2(System.Random _rng, int _reputation = 5)
	{
		return new DocksCase(new Vector2Int(3, 3), _reputation, 16, new List<Roles>
		{
			Roles.NAVIGATOR,
			Roles.FISHERMAN,
			Roles.PIRATE,
			Roles.COASTGUARD,
			Roles.SHARK,
			Roles.MATHEMATICIAN,
			Roles.DIVER
		}, new List<RoleData>
		{
			Roles.SHARK.createSetRoleWithDisguise(1, new Vector2Int(2, 0), _rng, Roles.NAVIGATOR),
			Roles.FISHERMAN.createRole(2, new Vector2Int(0, 1), _rng, new Maybe<RoleData>()),
			Roles.COASTGUARD.createRole(3, new Vector2Int(1, 1), _rng, new Maybe<RoleData>()),
			Roles.PIRATE.createSetRoleWithDisguise(4, new Vector2Int(0, 2), _rng, Roles.MATHEMATICIAN, delegate(Mathematician _m)
			{
				_m.createAndForceSetInfo(3);
			}),
			Roles.DIVER.createSetRole(5, new Vector2Int(2, 2), _rng, delegate(Diver _d)
			{
				_d.createAndForceSetInfo(4);
			})
		}, new List<LocationData>
		{
			new Docks(_rng, new Vector2Int(1, 2))
		}, 2.maybe());
	}

	public static DocksCase createDockTutorial3(System.Random _rng, int _reputation = 5)
	{
		return new DocksCase(new Vector2Int(3, 3), _reputation, 16, new List<Roles>
		{
			Roles.NAVIGATOR,
			Roles.GUNNER,
			Roles.SHIPWRECKED,
			Roles.ANGLERFISH,
			Roles.FISHERMAN,
			Roles.REPORTER
		}, new List<RoleData>
		{
			Roles.NAVIGATOR.createRole(1, new Vector2Int(1, 0), _rng, new Maybe<RoleData>()),
			Roles.GUNNER.createSetRole(2, new Vector2Int(0, 1), _rng, delegate(Gunner _g)
			{
				_g.setForcedTarget(1);
			}),
			Roles.SHIPWRECKED.createSetRoleWithDisguise(3, new Vector2Int(1, 1), _rng, Roles.NAVIGATOR),
			Roles.ANGLERFISH.createSetRoleWithDisguise(4, new Vector2Int(2, 1), _rng, Roles.FISHERMAN),
			Roles.REPORTER.createRole(5, new Vector2Int(2, 2), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new Docks(_rng, new Vector2Int(1, 2))
		}, 3.maybe());
	}

	public static DocksCase createDockTutorial4(System.Random _rng, int _reputation = 5)
	{
		Squid squid = Roles.SQUID.createSetRoleWithDisguise(5, new Vector2Int(2, 2), _rng, Roles.LOOKOUT) as Squid;
		squid.setForcedTarget(3);
		return new DocksCase(new Vector2Int(4, 4), _reputation, 21, new List<Roles>
		{
			Roles.CRABER,
			Roles.LOOKOUT,
			Roles.COASTGUARD,
			Roles.MINELAYER,
			Roles.FISHERMAN,
			Roles.SQUID,
			Roles.PIRATE_CAPTAIN,
			Roles.FALL_GUY,
			Roles.GUNNER,
			Roles.DIVER,
			Roles.BARRELMAN
		}, new List<RoleData>
		{
			Roles.CRABER.createRole(1, new Vector2Int(3, 0), _rng, new Maybe<RoleData>()),
			Roles.LOOKOUT.createRole(2, new Vector2Int(1, 1), _rng, new Maybe<RoleData>()),
			Roles.MINELAYER.createSetRoleWithDisguise(3, new Vector2Int(2, 1), _rng, Roles.FISHERMAN),
			Roles.COASTGUARD.createRole(4, new Vector2Int(0, 2), _rng, new Maybe<RoleData>()),
			squid,
			Roles.PIRATE_CAPTAIN.createSetRoleWithDisguise(6, new Vector2Int(3, 2), _rng, Roles.DIVER),
			Roles.FALL_GUY.createRole(7, new Vector2Int(1, 3), _rng, new Maybe<RoleData>()),
			Roles.BARRELMAN.createRole(8, new Vector2Int(3, 3), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new Docks(_rng, new Vector2Int(0, 3)),
			new NavalMine(_rng, new Vector2Int(1, 2))
		}, 4.maybe());
	}

	public static CasinoCase createCasinoTutorialCase(int _case, System.Random _rng, int _reputation = 5)
	{
		return _case switch
		{
			1 => createCasinoTutorial1(_rng), 
			2 => createCasinoTutorial2(_rng), 
			_ => throw new ArgumentException($"No tutorial case {_case} set up for docks region!"), 
		};
	}

	public static CasinoCase createCasinoTutorial1(System.Random _rng)
	{
		return new CasinoCase(new Vector2Int(3, 3), 80, 1f, new Maybe<(CasinoCard, CasinoCard)>(), new List<Roles>
		{
			Roles.MOBSTER,
			Roles.REPORTER,
			Roles.THERAPIST
		}, new List<RoleData>
		{
			Roles.MOBSTER.createSetRoleWithDisguise(1, new Vector2Int(0, 1), _rng, Roles.REPORTER, delegate(Reporter _r)
			{
				_r.createAndForceSetInfo(1);
			}),
			Roles.THERAPIST.createRole(2, new Vector2Int(1, 1), _rng, new Maybe<RoleData>()),
			Roles.REPORTER.createRole(3, new Vector2Int(1, 2), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(2, 0))
		}, 1.maybe());
	}

	public static CasinoCase createCasinoTutorial2(System.Random _rng)
	{
		return new CasinoCase(new Vector2Int(3, 3), 80, 1f, (new CasinoCard(new CasinoCardInfo(6, CasinoCardInfo.Suit.CLUBS)), new CasinoCard(new CasinoCardInfo(12, CasinoCardInfo.Suit.HEARTS))).maybe(), new List<Roles>
		{
			Roles.VALET,
			Roles.THERAPIST,
			Roles.WEATHERMAN,
			Roles.PICKPOCKET,
			Roles.REPORTER,
			Roles.VISIONARY,
			Roles.COPYCAT,
			Roles.HOT_SHOT,
			Roles.DEBT_COLLECTOR
		}, new List<RoleData>
		{
			Roles.VALET.createRole(1, new Vector2Int(0, 0), _rng, new Maybe<RoleData>()),
			Roles.THERAPIST.createRole(2, new Vector2Int(1, 0), _rng, new Maybe<RoleData>()),
			Roles.WEATHERMAN.createSetRole(3, new Vector2Int(2, 0), _rng, delegate(Weatherman _w)
			{
				_w.createAndForceSetInfo(new List<int> { 1, 4, 6 });
			}),
			Roles.PICKPOCKET.createSetRoleWithDisguise(4, new Vector2Int(1, 1), _rng, Roles.REPORTER, delegate(Reporter _r)
			{
				_r.createAndForceSetInfo(1);
			}),
			Roles.VISIONARY.createRole(5, new Vector2Int(2, 1), _rng, new Maybe<RoleData>()),
			Roles.COPYCAT.createSetRoleWithDisguise(6, new Vector2Int(0, 2), _rng, Roles.THERAPIST),
			Roles.HOT_SHOT.createRole(7, new Vector2Int(1, 2), _rng, new Maybe<RoleData>()),
			Roles.DEBT_COLLECTOR.createSetRoleWithDisguise(8, new Vector2Int(2, 2), _rng, Roles.HOT_SHOT)
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(0, 1))
		}, 3.maybe());
	}

	public static Case dep_createTutorial2(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(4, 4), _reputation, new List<Roles>
		{
			Roles.PRIEST,
			Roles.THERAPIST,
			Roles.MAILMAN,
			Roles.REPORTER,
			Roles.CASANOVA,
			Roles.MOBSTER
		}, new List<RoleData>
		{
			(Roles.MAILMAN.createRole(1, new Vector2Int(1, 1), _rng, new Maybe<RoleData>()) as Mailman).createAndForceSetInfo(Roles.PRIEST, Roles.THERAPIST),
			Roles.REPORTER.createRole(2, new Vector2Int(3, 1), _rng, new Maybe<RoleData>()),
			Roles.PRIEST.createRole(3, new Vector2Int(1, 2), _rng, new Maybe<RoleData>()),
			Roles.CASANOVA.createSetRoleWithDisguise(4, new Vector2Int(2, 2), _rng, Roles.THERAPIST, delegate(Therapist _t)
			{
				_t.createAndForceSetInfo(3);
			}),
			Roles.MOBSTER.createSetRoleWithDisguise(5, new Vector2Int(2, 3), _rng, Roles.REPORTER, delegate(Reporter _r)
			{
				_r.createAndForceSetInfo(2);
			})
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(0, 0))
		}, 2.maybe());
	}

	public static Case dep_createTutorial6(System.Random _rng, int _reputation = 5)
	{
		Barkeep barkeep = Roles.BARKEEP.createSetRoleWithDisguise(5, new Vector2Int(1, 2), _rng, Roles.REPORTER, delegate(Reporter _r)
		{
			_r.createAndForceSetInfo(2);
		}) as Barkeep;
		barkeep.forceNoTouch(4);
		return new ClockCase(new Vector2Int(4, 4), _reputation, new List<Roles>
		{
			Roles.THERAPIST,
			Roles.PRIEST,
			Roles.REPORTER,
			Roles.ROMANTIC,
			Roles.TAILOR,
			Roles.MATHEMATICIAN,
			Roles.DRUNKARD,
			Roles.BARKEEP,
			Roles.SCOUNDREL
		}, new List<RoleData>
		{
			Roles.ROMANTIC.createSetRole(1, new Vector2Int(2, 0), _rng, delegate(Romantic _w)
			{
				_w.setForcedPartner(6);
			}),
			Roles.TAILOR.createRole(2, new Vector2Int(1, 1), _rng, new Maybe<RoleData>()),
			Roles.THERAPIST.createRole(3, new Vector2Int(2, 1), _rng, new Maybe<RoleData>()),
			Roles.DRUNKARD.createSetRoleWithDisguise(4, new Vector2Int(3, 1), _rng, Roles.MATHEMATICIAN, delegate(Mathematician _m)
			{
				_m.createAndForceSetInfo(6);
			}),
			barkeep,
			Roles.SCOUNDREL.createRole(6, new Vector2Int(2, 2), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(0, 1))
		}, 6.maybe(), new Dictionary<RoleClassifications, int>
		{
			{
				RoleClassifications.INNOCENT,
				4
			},
			{
				RoleClassifications.MEDDLER,
				0
			},
			{
				RoleClassifications.UNDERLING,
				2
			},
			{
				RoleClassifications.TRAITOR,
				0
			}
		});
	}

	public static Case dep_createTutorial7(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(4, 4), _reputation, new List<Roles>
		{
			Roles.BOUNTY_HUNTER,
			Roles.MATHEMATICIAN,
			Roles.THERAPIST,
			Roles.ROMANTIC,
			Roles.REPORTER,
			Roles.POISONER,
			Roles.MAILMAN
		}, new List<RoleData>
		{
			Roles.BOUNTY_HUNTER.createSetRole(1, new Vector2Int(1, 0), _rng, delegate(BountyHunter _w)
			{
				_w.setForcedTarget(2, new List<int> { 2, 5, 6 });
			}),
			Roles.MATHEMATICIAN.createRole(2, new Vector2Int(0, 1), _rng, new Maybe<RoleData>()),
			Roles.THERAPIST.createRole(3, new Vector2Int(1, 1), _rng, new Maybe<RoleData>()),
			Roles.ROMANTIC.createSetRole(4, new Vector2Int(2, 1), _rng, delegate(Romantic _w)
			{
				_w.setForcedPartner(3);
			}),
			Roles.REPORTER.createSetRole(5, new Vector2Int(1, 2), _rng, delegate(Reporter _m)
			{
				_m.createAndForceSetInfo(3);
			}),
			Roles.POISONER.createSetRoleWithDisguise(6, new Vector2Int(1, 3), _rng, Roles.MAILMAN, delegate(Mailman _m)
			{
				_m.createAndForceSetInfo(Roles.MAILMAN, Roles.POISONER);
			})
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(0, 2))
		}, 7.maybe());
	}

	public static Case dep_createOfficeTutorial7(System.Random _rng, int _reputation = 5)
	{
		Barkeep barkeep = Roles.BARKEEP.createSetRoleWithDisguise(6, new Vector2Int(0, 2), _rng, Roles.REPORTER, delegate(Reporter _r)
		{
			_r.createAndForceSetInfo(2);
		}) as Barkeep;
		barkeep.forceNoTouch(5);
		return new ClockCase(new Vector2Int(3, 3), _reputation, new List<Roles>
		{
			Roles.MOBSTER,
			Roles.THERAPIST,
			Roles.PRIEST,
			Roles.BLOOD_HOUND,
			Roles.TAILOR,
			Roles.MATHEMATICIAN,
			Roles.REPORTER,
			Roles.DRUNKARD,
			Roles.BARKEEP,
			Roles.SCOUNDREL
		}, new List<RoleData>
		{
			Roles.MOBSTER.createSetRoleWithDisguise(1, new Vector2Int(1, 0), _rng, Roles.THERAPIST, delegate(Therapist _t)
			{
				_t.createAndForceSetInfo(3);
			}),
			Roles.BLOOD_HOUND.createRole(2, new Vector2Int(2, 0), _rng, new Maybe<RoleData>()),
			Roles.TAILOR.createRole(3, new Vector2Int(0, 1), _rng, new Maybe<RoleData>()),
			Roles.THERAPIST.createRole(4, new Vector2Int(1, 1), _rng, new Maybe<RoleData>()),
			Roles.DRUNKARD.createSetRoleWithDisguise(5, new Vector2Int(2, 1), _rng, Roles.MATHEMATICIAN, delegate(Mathematician _m)
			{
				_m.createAndForceSetInfo(7);
			}),
			barkeep,
			Roles.SCOUNDREL.createRole(7, new Vector2Int(1, 2), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(2, 2))
		}, 6.maybe(), new Dictionary<RoleClassifications, int>
		{
			{
				RoleClassifications.INNOCENT,
				4
			},
			{
				RoleClassifications.MEDDLER,
				0
			},
			{
				RoleClassifications.UNDERLING,
				3
			},
			{
				RoleClassifications.TRAITOR,
				0
			}
		});
	}

	public static Case dep_createOfficeTutorial10(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(4, 4), _reputation, new List<Roles>
		{
			Roles.BOUNTY_HUNTER,
			Roles.MATHEMATICIAN,
			Roles.THERAPIST,
			Roles.CONMAN,
			Roles.REPORTER,
			Roles.POISONER,
			Roles.BLOOD_HOUND
		}, new List<RoleData>
		{
			Roles.BOUNTY_HUNTER.createSetRole(1, new Vector2Int(1, 0), _rng, delegate(BountyHunter _w)
			{
				_w.setForcedTarget(3, new List<int> { 2, 3, 4 });
			}),
			Roles.CONMAN.createSetRoleWithDisguise(2, new Vector2Int(0, 1), _rng, Roles.MATHEMATICIAN),
			Roles.THERAPIST.createSetRole(3, new Vector2Int(1, 1), _rng, delegate(Therapist _t)
			{
				_t.createAndForceSetInfo(4);
			}),
			Roles.MATHEMATICIAN.createRole(4, new Vector2Int(2, 1), _rng, new Maybe<RoleData>()),
			Roles.REPORTER.createSetRole(5, new Vector2Int(1, 2), _rng, delegate(Reporter _m)
			{
				_m.createAndForceSetInfo(3);
			}),
			Roles.POISONER.createSetRoleWithDisguise(6, new Vector2Int(1, 3), _rng, Roles.BLOOD_HOUND, delegate(BloodHound _m)
			{
				_m.createAndForceSetInfo(2);
			})
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(0, 2))
		}, 7.maybe());
	}

	public static Case createTestCase(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(4, 4), _reputation, new List<Roles>
		{
			Roles.REPORTER,
			Roles.WEATHERMAN,
			Roles.PRIEST,
			Roles.SKEPTIC,
			Roles.MAILMAN,
			Roles.MATHEMATICIAN,
			Roles.CLOCK_MAKER,
			Roles.YOUNGSTER,
			Roles.MILKMAN,
			Roles.CONMAN
		}, new List<RoleData>
		{
			Roles.CONMAN.createSetRoleWithDisguise(1, new Vector2Int(1, 0), _rng, Roles.SKEPTIC),
			Roles.REPORTER.createRole(2, new Vector2Int(2, 0), _rng, new Maybe<RoleData>()),
			Roles.YOUNGSTER.createRole(3, new Vector2Int(3, 1), _rng, new Maybe<RoleData>()),
			Roles.CLOCK_MAKER.createRole(4, new Vector2Int(1, 2), _rng, new Maybe<RoleData>()),
			Roles.MATHEMATICIAN.createRole(5, new Vector2Int(0, 3), _rng, new Maybe<RoleData>()),
			Roles.MAILMAN.createRole(6, new Vector2Int(1, 3), _rng, new Maybe<RoleData>()),
			Roles.SKEPTIC.createRole(7, new Vector2Int(2, 3), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(0, 0)),
			new ClockTower(_rng, new Vector2Int(2, 1), new List<(int, ClockTower.ClockTowerRingAttribution)> { (2, ClockTower.ClockTowerRingAttribution.CLOCKTOWER) }, new List<int>())
		}, new Maybe<int>(), new List<CaseQuirks>
		{
			CaseQuirks.EVIL_GAZE,
			CaseQuirks.TEMPERANCE,
			CaseQuirks.SHOT_IN_THE_DARK,
			CaseQuirks.DARK_WHISPERS,
			CaseQuirks.SWIFT_JUSTICE
		});
	}

	public static Case createTestCase2(System.Random _rng, int _reputation = 5)
	{
		return new ClockCase(new Vector2Int(4, 4), _reputation, new List<Roles>
		{
			Roles.REPORTER,
			Roles.WEATHERMAN,
			Roles.PRIEST,
			Roles.SKEPTIC,
			Roles.MAILMAN,
			Roles.MATHEMATICIAN,
			Roles.CLOCK_MAKER,
			Roles.YOUNGSTER,
			Roles.MILKMAN,
			Roles.CONMAN
		}, new List<RoleData>
		{
			Roles.SCOUNDREL.createRole(1, new Vector2Int(0, 0), _rng, new Maybe<RoleData>()),
			Roles.CONMAN.createSetRoleWithDisguise(2, new Vector2Int(1, 0), _rng, Roles.SKEPTIC),
			Roles.SKEPTIC.createRole(3, new Vector2Int(3, 0), _rng, new Maybe<RoleData>()),
			Roles.WEATHERMAN.createRole(4, new Vector2Int(0, 1), _rng, new Maybe<RoleData>()),
			Roles.PRIEST.createRole(5, new Vector2Int(0, 2), _rng, new Maybe<RoleData>()),
			Roles.MILKMAN.createRole(6, new Vector2Int(3, 2), _rng, new Maybe<RoleData>()),
			Roles.CRITIC.createSetRoleWithDisguise(7, new Vector2Int(0, 3), _rng, Roles.MATHEMATICIAN),
			Roles.TAILOR.createRole(8, new Vector2Int(3, 3), _rng, new Maybe<RoleData>())
		}, new List<LocationData>
		{
			new CrimeScene(_rng, new Vector2Int(2, 0))
		}, new Maybe<int>());
	}
}
