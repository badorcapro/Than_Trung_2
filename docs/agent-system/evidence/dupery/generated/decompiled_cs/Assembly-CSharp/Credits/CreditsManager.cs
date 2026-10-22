using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using GRGLib.Extensions.String;
using GRGLib.Extensions.Unity;
using GRGLocalisation;
using Localisation;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using Visual;

namespace Credits;

public class CreditsManager : MonoBehaviour, IAmLocalised
{
	private enum Titles
	{
		LEAD_ARTIST,
		PROGRAMMER_COMPOSER,
		PROGRAMMER_WRITER,
		COMPOSER,
		SPECIAL_THANKS,
		LEAD_PRODUCER,
		PRODUCER,
		PRODUCTION_COORDINATOR,
		PRODUCT_MANAGER,
		ASSOCIATE_PM,
		COMMUNITY_MANAGER,
		SOCIAL_MEDIA_EXECUTIVE,
		VIDEO_EDITOR,
		PR_INFLUENCE,
		PUBLISHING_COORDINATOR,
		PUBLISHING_EXECUTIVE,
		FINANCIAL_CONTROLLER,
		FINANCE_DIRECTOR,
		DIRECTOR,
		MANAGING_DIRECTOR,
		ARTIST,
		HEAD_OF_STUDIO,
		SOCIAL_MEDIA_MANAGER_PM,
		LEAD_ARTIST_HEAD_OF_NETWORK,
		CO_FOUNDER,
		BLANK
	}

	private enum CreditBlocks
	{
		GRG,
		YOGS_GAMES,
		YOGS,
		CONTRACTORS,
		SPECIAL_THANKS,
		BETA_TESTERS
	}

	[SerializeField]
	private CreditCharacterVisual lydia_vis;

	[SerializeField]
	private CreditCharacterVisual luke_vis;

	[SerializeField]
	private CreditCharacterVisual matt_vis;

	[SerializeField]
	private RoleVisualDataSO role_vis_data_so;

	[SerializeField]
	private Transform credit_obj;

	[Header("Credit Blocks")]
	[SerializeField]
	private CanvasGroup cb_cg;

	[SerializeField]
	private CreditBlock gilded_rune_games_cb;

	[SerializeField]
	private CreditBlock yogs_games_cb;

	[SerializeField]
	private CreditBlock yogs_cb;

	[SerializeField]
	private CreditBlock contractor_cb;

	[SerializeField]
	private CreditBlock special_thanks_cb;

	[SerializeField]
	private CreditBlock beta_testers_cb;

	[Header("Skip references")]
	[SerializeField]
	private GameObject skip_button;

	[SerializeField]
	private Image skip_circle;

	private Dictionary<int, bool> roles_interacted_with = new Dictionary<int, bool>();

	private System.Random rnd;

	private CoroutineRunner skip_circle_runner;

	private Dictionary<CreditBlocks, List<(string, Titles)>> attribution = new Dictionary<CreditBlocks, List<(string, Titles)>>();

	private Action callback;

	private CoroutineRunner credits_runner;

	private AssetKey localisation_asset => LocalisationHelper.misc_asset;

	private void Awake()
	{
		skip_circle_runner = new CoroutineRunner(this);
	}

	public void startCredits(Action _callback)
	{
		callback = _callback;
		credits_runner.run(playCredits());
		skip_button.SetActive(value: true);
	}

	private IEnumerator playCredits()
	{
		cb_cg.fade(1f, 1f).start(this);
		float starting_pos = credit_obj.transform.localPosition.y;
		yield return credit_obj.transform.moveTransform(new Vector3(credit_obj.transform.localPosition.x, starting_pos + 3000f), 42f, CoroutineExtensions.easeInFunc);
		yield return credit_obj.transform.moveTransform(new Vector3(credit_obj.transform.localPosition.x, starting_pos + 6000f), 30f, CoroutineExtensions.noEaseFunc);
		yield return credit_obj.transform.moveTransform(new Vector3(credit_obj.transform.localPosition.x, starting_pos + 6800f), 12f, CoroutineExtensions.easeOutFunc);
		yield return 2f.wait();
		callback();
	}

	public void startSkip(InputAction.CallbackContext _context)
	{
		if (credits_runner.is_running)
		{
			if (_context.performed)
			{
				onSkipStart();
			}
			if (_context.canceled)
			{
				onSkipEnd();
			}
		}
	}

	public void onSkipStart()
	{
		skip_circle_runner.run(skip_circle.fill(1f, 1.5f, CoroutineExtensions.easeInOutFunc).addCallback(onSkip));
	}

	public void onSkipEnd()
	{
		skip_circle_runner.run(skip_circle.fill(0f, 0.35f, CoroutineExtensions.easeInOutFunc));
	}

	private void onSkip()
	{
		credits_runner.stop();
		callback();
	}

	private string getEnglishTitle(Titles _title)
	{
		return _title switch
		{
			Titles.LEAD_ARTIST => "Lead Artist", 
			Titles.PROGRAMMER_COMPOSER => "Developer & Composer", 
			Titles.PROGRAMMER_WRITER => "Developer & Writer", 
			Titles.COMPOSER => "Composer", 
			Titles.SPECIAL_THANKS => "Special Thanks To", 
			Titles.LEAD_PRODUCER => "Lead Producer", 
			Titles.PRODUCER => "Producer", 
			Titles.PRODUCTION_COORDINATOR => "Production Coordinator", 
			Titles.PRODUCT_MANAGER => "Product Manager", 
			Titles.ASSOCIATE_PM => "Associate Product Manager", 
			Titles.COMMUNITY_MANAGER => "Community Manager", 
			Titles.SOCIAL_MEDIA_EXECUTIVE => "Social Media Executive", 
			Titles.VIDEO_EDITOR => "Video Editor", 
			Titles.PR_INFLUENCE => "PR and Influencer Manager", 
			Titles.PUBLISHING_COORDINATOR => "Publishing Coordinator", 
			Titles.PUBLISHING_EXECUTIVE => "Publishing Executive", 
			Titles.FINANCIAL_CONTROLLER => "Financial Controller", 
			Titles.FINANCE_DIRECTOR => "Finance Director", 
			Titles.DIRECTOR => "Director", 
			Titles.MANAGING_DIRECTOR => "Managing Director", 
			Titles.ARTIST => "Artist", 
			Titles.HEAD_OF_STUDIO => "Head of Studio", 
			Titles.SOCIAL_MEDIA_MANAGER_PM => "Social Media Manager & Production Manager", 
			Titles.LEAD_ARTIST_HEAD_OF_NETWORK => "Lead Artist & Head of Network", 
			Titles.CO_FOUNDER => "Co-Founder", 
			_ => "", 
		};
	}

	private void setAttribution()
	{
		attribution[CreditBlocks.GRG] = new List<(string, Titles)>
		{
			("Lydia Barraclough", Titles.LEAD_ARTIST),
			("Matthew Brebner", Titles.PROGRAMMER_COMPOSER),
			("Luke Eyre", Titles.PROGRAMMER_WRITER)
		};
		attribution[CreditBlocks.YOGS_GAMES] = new List<(string, Titles)>
		{
			("Isaac Haslehurst", Titles.LEAD_PRODUCER),
			("Cael McKinney", Titles.PRODUCER),
			("Robin Mawhinney", Titles.PRODUCTION_COORDINATOR),
			("Matt Plumb", Titles.PRODUCT_MANAGER),
			("Tvesha Sinha", Titles.ASSOCIATE_PM),
			("Liz Morley", Titles.COMMUNITY_MANAGER),
			("Jennifer Summers", Titles.SOCIAL_MEDIA_EXECUTIVE),
			("Reece Parsons", Titles.VIDEO_EDITOR),
			("Charlotte Willis", Titles.PR_INFLUENCE),
			("Charlotte Pang", Titles.PUBLISHING_COORDINATOR),
			("Alex Turner", Titles.PUBLISHING_EXECUTIVE),
			("Dhurata Limaja", Titles.FINANCIAL_CONTROLLER),
			("Hilary Cole", Titles.FINANCE_DIRECTOR),
			("Rich Keith", Titles.DIRECTOR),
			("Simon Byron", Titles.MANAGING_DIRECTOR)
		};
		attribution[CreditBlocks.YOGS] = new List<(string, Titles)>
		{
			("Nina-Serena", Titles.ARTIST),
			("Jack Bailey", Titles.ARTIST),
			("Daf H", Titles.HEAD_OF_STUDIO),
			("Sarah R", Titles.SOCIAL_MEDIA_MANAGER_PM),
			("Harry Marshall", Titles.LEAD_ARTIST_HEAD_OF_NETWORK),
			("Lewis Brindley", Titles.CO_FOUNDER),
			("Simon Lane", Titles.CO_FOUNDER)
		};
		attribution[CreditBlocks.CONTRACTORS] = new List<(string, Titles)> { ("Edward Brebner", Titles.COMPOSER) };
		attribution[CreditBlocks.SPECIAL_THANKS] = new List<(string, Titles)>
		{
			("Helen Eyre", Titles.BLANK),
			("Ann Esain", Titles.BLANK),
			("Genevieve Brebner", Titles.BLANK),
			("Briony Turner", Titles.BLANK),
			("Alastair Janse van Rensburg", Titles.BLANK),
			("Charlie Walpole", Titles.BLANK),
			("Kirsten Wotherspoon", Titles.BLANK),
			("Ethan Baker", Titles.BLANK)
		};
		attribution[CreditBlocks.BETA_TESTERS] = new List<(string, Titles)>
		{
			("gv", Titles.BLANK),
			("Rsvdark", Titles.BLANK),
			("Exiliado89", Titles.BLANK),
			("KittyFireSt0rm", Titles.BLANK),
			("vitvitcher", Titles.BLANK),
			("Wind", Titles.BLANK),
			("Sequest", Titles.BLANK),
			("NotSoDogNinja", Titles.BLANK),
			("gooseum", Titles.BLANK)
		};
	}

	private string getStringFromAttribution(CreditBlocks _cb)
	{
		return attribution[_cb].Aggregate("", (string _a, (string, Titles) _b) => _a += ((_b.Item2 == Titles.BLANK) ? (_b.Item1 + "\n") : (_b.Item1 + " <indent=35%>" + getEnglishTitle(_b.Item2) + "</indent>\n"))).removeFromEnd(1);
	}

	private void Start()
	{
		roles_interacted_with[0] = false;
		roles_interacted_with[1] = false;
		roles_interacted_with[2] = false;
		credits_runner = new CoroutineRunner(this);
		AudioHandler.Music.playMusic(Music.A_MT);
		cb_cg.putOn(_on: false);
		setAttribution();
		rnd = RandomExtensions.freshRandom();
		gilded_rune_games_cb.updateBlock(getStringFromAttribution(CreditBlocks.GRG));
		yogs_games_cb.updateBlock(getStringFromAttribution(CreditBlocks.YOGS_GAMES));
		yogs_cb.updateBlock(getStringFromAttribution(CreditBlocks.YOGS));
		contractor_cb.updateBlock(getStringFromAttribution(CreditBlocks.CONTRACTORS));
		special_thanks_cb.updateBlock(getStringFromAttribution(CreditBlocks.SPECIAL_THANKS));
		beta_testers_cb.updateBlock(getStringFromAttribution(CreditBlocks.BETA_TESTERS));
		RoleData roleData = Roles.ARTIST.createEmptyRole();
		roleData.setAlignment(Alignments.EVIL);
		RoleData roleData2 = Roles.JELLYFISH.createEmptyRole();
		roleData2.setAlignment(Alignments.GOOD);
		lydia_vis.setUp(roleData, "*Pop pop pop*", "Lydia", role_vis_data_so, 1, lydia_vis.transform.localPosition, rnd);
		matt_vis.setUp(roleData2, "*Blub Blub*", "Matt", role_vis_data_so, 2, matt_vis.transform.localPosition, rnd);
		luke_vis.setUp(Roles.GHOST.createEmptyRole(), "Hi!", "Luke", role_vis_data_so, 3, luke_vis.transform.localPosition, rnd);
		lydia_vis.setupCreditSoundCallbacks(delegate
		{
			AudioHandler.Sfx.playSfx(Sfx.LYDIA_INV);
			updateState(0);
		}, delegate
		{
			AudioHandler.Sfx.playSfx(Sfx.LYDIA_ARR);
			updateState(0);
		});
		matt_vis.setupCreditSoundCallbacks(delegate
		{
			AudioHandler.Sfx.playSfx(Sfx.MATT_INV);
			updateState(1);
		}, delegate
		{
			AudioHandler.Sfx.playSfx(Sfx.MATT_ARR);
			updateState(1);
		});
		luke_vis.setupCreditSoundCallbacks(delegate
		{
			AudioHandler.Sfx.playSfx(Sfx.LUKE_INV);
			updateState(2);
		}, delegate
		{
			AudioHandler.Sfx.playSfx(Sfx.LUKE_ARR);
			updateState(2);
		});
	}

	private void updateState(int _id)
	{
		roles_interacted_with[_id] = true;
		updateCreditStartedState();
	}

	private void updateCreditStartedState()
	{
		if (!credits_runner.is_running && roles_interacted_with.Values.All((bool _e) => _e))
		{
			startCredits(delegate
			{
				GameHandler.instance.moveToScene(GameHandler.instance.is_credits_replay ? "MainMenuScene" : "SummaryScene");
			});
		}
	}

	private string getLocKey(Titles _titles)
	{
		return $"Credits [t{(int)_titles}]";
	}
}
