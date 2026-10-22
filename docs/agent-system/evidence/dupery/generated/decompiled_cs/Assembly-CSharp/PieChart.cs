using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using GRGLocalisation;
using GameStats;
using Localisation;
using TMPro;
using UnityEngine;

public class PieChart : MonoBehaviour, IAmLocalised
{
	private class PieChartSettings
	{
		public string name;

		public Dictionary<string, int> data;

		public PieChartSettings(string _name, Dictionary<string, int> _data)
		{
			name = _name;
			data = _data;
		}
	}

	private class PieSliceSetting
	{
		public string section;

		public Color section_colour;

		public float size;

		public int data;

		public PieSliceSetting(string _section, Color _color, float _size, int _data)
		{
			section = _section;
			section_colour = _color;
			size = _size;
			data = _data;
		}

		public PieSliceSetting(string _section, Color _color, int _data)
		{
			float num = _data;
			section = _section;
			section_colour = _color;
			size = num;
			data = _data;
		}

		public void normaliseSize(float _total)
		{
			size /= _total;
		}
	}

	[Header("References")]
	[SerializeField]
	private TMP_Text pie_chart_title;

	[SerializeField]
	private RectTransform pie_slice_parent;

	[Header("Prefabs")]
	[SerializeField]
	private PieSlice pie_slice_prefab;

	[Header("Settings")]
	[SerializeField]
	private List<Color> pie_slice_colours;

	private List<PieSlice> slices = new List<PieSlice>();

	private int current;

	private List<PieChartSettings> possible_charts = new List<PieChartSettings>();

	private CoroutineRunner hover_check_runner;

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	private string loc_inv_title_key => "PieChartTitle [investigate]";

	private string loc_arr_title_key => "PieChartTitle [arrests]";

	private string loc_dea_title_key => "PieChartTitle [dead]";

	private string loc_abs_title_key => "PieChartTitle [abilities]";

	private string loc_esc_title_key => "PieChartTitle [escaped]";

	private void Awake()
	{
		hover_check_runner = new CoroutineRunner(this);
	}

	public void setPossibleCharts(CaseStats _stats)
	{
		possible_charts.Clear();
		possible_charts.Add(new PieChartSettings(localisation_asset.checkTranslation(loc_arr_title_key, englishArrested, _check_keywords: false), _stats.arrested.keySelect((Roles _r) => _r.toString())));
		possible_charts.Add(new PieChartSettings(localisation_asset.checkTranslation(loc_dea_title_key, englishDied, _check_keywords: false), _stats.died.keySelect((Roles _r) => _r.toString())));
		if (_stats.ability_used.Count > 0)
		{
			possible_charts.Add(new PieChartSettings(localisation_asset.checkTranslation(loc_abs_title_key, englishAbilities, _check_keywords: false), _stats.ability_used.keySelect((Roles _r) => _r.toString())));
		}
		if (_stats is DocksCaseStats docksCaseStats && docksCaseStats.evil_uncaptured.Count > 0)
		{
			possible_charts.Add(new PieChartSettings(localisation_asset.checkTranslation(loc_esc_title_key, englishEscaped, _check_keywords: false), docksCaseStats.evil_uncaptured.keySelect((Roles _r) => _r.toString())));
		}
		possible_charts.Add(new PieChartSettings(localisation_asset.checkTranslation(loc_inv_title_key, englishInvestigate, _check_keywords: false), _stats.investigated.keySelect((Roles _r) => _r.toString())));
		current = 0;
		setUp(possible_charts[current]);
	}

	private string englishInvestigate()
	{
		return "Roles Investigated";
	}

	private string englishArrested()
	{
		return "Roles Arrested";
	}

	private string englishDied()
	{
		return "Roles Died";
	}

	private string englishAbilities()
	{
		return "Abilities Used";
	}

	private string englishEscaped()
	{
		return "Roles Escaped";
	}

	private void setUp(PieChartSettings _chart_data)
	{
		pie_chart_title.text = _chart_data.name;
		List<PieSliceSetting> list = new List<PieSliceSetting>();
		float total_size = 0f;
		int num = 0;
		foreach (KeyValuePair<string, int> datum in _chart_data.data)
		{
			total_size += datum.Value;
			list.Add(new PieSliceSetting(datum.Key, pie_slice_colours[num % pie_slice_colours.Count], datum.Value));
			num++;
		}
		list = list.OrderByDescending((PieSliceSetting _s) => _s.size).ToList();
		list.ForEach(delegate(PieSliceSetting _s)
		{
			_s.normaliseSize(total_size);
		});
		setUpSlices(list);
	}

	private void setUpSlices(List<PieSliceSetting> _settings)
	{
		float num = 0f;
		for (int i = 0; i < _settings.Count; i++)
		{
			if (i >= slices.Count)
			{
				slices.Add(Object.Instantiate(pie_slice_prefab, pie_slice_parent));
			}
			slices[i].setUp((i == 0) ? 0f : (360f - num * 360f), _settings[i].size, _settings[i].section_colour, _settings[i].section, _settings[i].data.ToString());
			num += _settings[i].size;
		}
		for (int j = _settings.Count; j < slices.Count; j++)
		{
			slices[j].close();
		}
	}

	public void swapGraph(bool _right)
	{
		current += (_right ? 1 : (-1));
		current %= possible_charts.Count;
		if (current < 0)
		{
			current += possible_charts.Count;
		}
		setUp(possible_charts[current]);
	}

	public void startHoverCheck()
	{
		hover_check_runner.run(checkHovering());
	}

	public void stopHoverCheck()
	{
		hover_check_runner.stop();
		slices.ForEach(delegate(PieSlice _s)
		{
			_s.onUnhover();
		});
	}

	private IEnumerator checkHovering()
	{
		Maybe<PieSlice> last_hovering = new Maybe<PieSlice>();
		while (true)
		{
			Maybe<PieSlice> maybe = findHoveringSlice();
			if (last_hovering.is_some && (!maybe.is_some || maybe.value != last_hovering.value))
			{
				last_hovering.value.onUnhover();
				last_hovering = new Maybe<PieSlice>();
			}
			if (maybe.is_some && !last_hovering.is_some)
			{
				maybe.value.onHover();
				last_hovering = maybe;
			}
			yield return null;
		}
	}

	private Maybe<PieSlice> findHoveringSlice()
	{
		List<PieSlice> list = slices.Where((PieSlice _s) => _s.open).ToList();
		if (list.Count == 0)
		{
			return new Maybe<PieSlice>();
		}
		float x = list[0].rect_transform.sizeDelta.x;
		Vector2 vector = Input.mousePosition - Camera.main.WorldToScreenPoint(pie_slice_parent.position);
		if (vector.magnitude > x * 0.51f)
		{
			return new Maybe<PieSlice>();
		}
		float num = Vector2.SignedAngle(Vector2.down, vector.normalized) - 180f;
		for (int i = 0; i < list.Count; i++)
		{
			if (0f - num < list[i].rotation_end)
			{
				return list[i].maybe();
			}
		}
		return new Maybe<PieSlice>();
	}
}
