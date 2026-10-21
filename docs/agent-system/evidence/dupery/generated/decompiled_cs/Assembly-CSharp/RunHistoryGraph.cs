using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GameStats;
using Save;
using UnityEngine;
using UnityEngine.UI;

public class RunHistoryGraph : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform graph_parent;

	[Header("Prefabs")]
	[SerializeField]
	private Image bar_prefab;

	[Header("Settings")]
	[SerializeField]
	private float graph_offset = 5f;

	[SerializeField]
	private Color normal_colour;

	[SerializeField]
	private Color selected_colour;

	private List<Image> bars = new List<Image>();

	private MultiCoroutineRunner bars_runner;

	private int selected_element = -1;

	public RectTransform rect_trans => base.transform as RectTransform;

	public bool graph_created { get; private set; }

	public void setUp()
	{
		bars_runner = new MultiCoroutineRunner(this);
	}

	public void createGraphFromData()
	{
		List<StatsSaveData> run_stats = GameHandler.StatsData.run_stats;
		createGraph(run_stats.Select((StatsSaveData _s) => new RunStats(_s).cases_solved_all).ToList());
	}

	public void createGraph(List<int> _data)
	{
		bars.destroyAll();
		_data.Max();
		int num = _data.Sum();
		float num2 = (graph_parent.sizeDelta.x - graph_offset) / (float)_data.Count;
		float num3 = graph_offset;
		float num4 = (graph_parent.sizeDelta.y - graph_offset) / (float)num;
		int num5 = 0;
		List<IEnumerator> list = new List<IEnumerator>();
		for (int i = 0; i < _data.Count; i++)
		{
			Image image = Object.Instantiate(bar_prefab, graph_parent);
			image.rectTransform.sizeDelta = new Vector2(num2, graph_offset);
			image.rectTransform.anchoredPosition = new Vector2(num3, 0f);
			bars.Add(image);
			num5 += _data[i];
			num3 += num2;
			list.Add(image.rectTransform.expandSizeDelta(new Vector2(num2, num4 * (float)num5), 0.65f, CoroutineExtensions.easeInOutFunc));
		}
		bars_runner.run(list.ToArray());
		graph_created = true;
		selectElement(_data.Count - 1);
	}

	public void selectElement(int _element_id)
	{
		if (_element_id < bars.Count)
		{
			if (selected_element != -1)
			{
				bars[selected_element].color = normal_colour;
			}
			selected_element = _element_id;
			bars[_element_id].color = selected_colour;
		}
	}
}
