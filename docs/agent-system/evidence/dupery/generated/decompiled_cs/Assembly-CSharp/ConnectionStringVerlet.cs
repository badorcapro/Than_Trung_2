using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.UI;
using UnityEngine;

public class ConnectionStringVerlet : ConnectionStringBase
{
	public struct StringSegmentStruct
	{
		public Vector2 current_pos;

		public Vector2 old_pos;

		public StringSegmentStruct(Vector2 _pos)
		{
			current_pos = _pos;
			old_pos = _pos;
		}
	}

	[Header("Physics")]
	[SerializeField]
	private Vector2 gravity_force = new Vector2(0f, -2f);

	[SerializeField]
	private float damping_factor = 0.98f;

	private bool should_simulate;

	private bool has_points;

	private bool done_one_sim;

	private UILineRenderer line_renderer;

	private List<StringSegmentStruct> string_segments = new List<StringSegmentStruct>();

	[Header("String Points")]
	[SerializeField]
	private Vector3 string_start_point = Vector3.zero;

	[SerializeField]
	private Vector3 string_end_point = Vector3.zero;

	[SerializeField]
	private int constraint_run_count = 50;

	[SerializeField]
	private int string_segment_count = 50;

	[SerializeField]
	private float string_segment_length = 0.225f;

	private CoroutineRunner sim_runner;

	public void updateStringEndPoints(Vector2 _start, Vector2 _end)
	{
		string_start_point = _start;
		string_end_point = _end;
	}

	private void Awake()
	{
		line_renderer = GetComponent<UILineRenderer>();
		sim_runner = new CoroutineRunner(this);
	}

	public override void setUp(bool _base = false)
	{
		base.setUp(_base);
		line_renderer.setPoints(new List<Vector2>());
	}

	private void Update()
	{
		if (should_simulate && done_one_sim)
		{
			line_renderer.color = line_renderer.color.setAlpha(1f);
		}
		drawString();
	}

	private IEnumerator doSim(float _sim_length)
	{
		should_simulate = true;
		yield return _sim_length.wait();
		should_simulate = false;
	}

	public override void refreshSimulation(float _sim_length = 2f)
	{
		sim_runner.run(doSim(_sim_length));
	}

	private void FixedUpdate()
	{
		if (should_simulate)
		{
			simulate();
			for (int i = 0; i < constraint_run_count; i++)
			{
				applyConstraints();
			}
			done_one_sim = true;
		}
	}

	private void simulate()
	{
		for (int i = 0; i < string_segments.Count; i++)
		{
			StringSegmentStruct value = string_segments[i];
			Vector2 vector = (value.current_pos - value.old_pos) * damping_factor;
			value.old_pos = value.current_pos;
			value.current_pos += vector;
			value.current_pos += gravity_force * Time.fixedDeltaTime;
			string_segments[i] = value;
		}
	}

	private void applyConstraints()
	{
		StringSegmentStruct value = string_segments[0];
		value.current_pos = string_start_point;
		string_segments[0] = value;
		StringSegmentStruct value2 = string_segments[string_segment_count - 1];
		value2.current_pos = string_end_point;
		string_segments[string_segment_count - 1] = value2;
		for (int i = 0; i < string_segment_count - 1; i++)
		{
			StringSegmentStruct value3 = string_segments[i];
			StringSegmentStruct value4 = string_segments[i + 1];
			float num = (value3.current_pos - value4.current_pos).magnitude - string_segment_length;
			Vector2 vector = (value3.current_pos - value4.current_pos).normalized * num;
			if (i != 0 && i != string_segment_count - 1)
			{
				value3.current_pos -= vector * 0.5f;
				value4.current_pos += vector * 0.5f;
			}
			else if (i == string_segment_count - 2)
			{
				value3.current_pos += vector;
			}
			else
			{
				value4.current_pos += vector;
			}
			string_segments[i] = value3;
			string_segments[i + 1] = value4;
		}
	}

	private void drawString()
	{
		Vector2[] array = new Vector2[string_segment_count];
		for (int i = 0; i < string_segments.Count; i++)
		{
			array[i] = string_segments[i].current_pos;
		}
		line_renderer.setPoints(array.ToList());
	}

	public override void setStringStartPosition(Vector2 _pos)
	{
		string_start_point = _pos;
		if (!has_points)
		{
			line_renderer.addPoints(new List<Vector2>(string_segment_count));
			for (int i = 0; i < string_segment_count; i++)
			{
				string_segments.Add(new StringSegmentStruct(string_start_point));
			}
			has_points = true;
		}
	}

	public override void setStringEndPosition(Vector2 _pos)
	{
		string_end_point = _pos;
	}

	public override void setStringColour(int _colour_index, Color _colour)
	{
		colour_index = _colour_index;
		float a = line_renderer.color.a;
		line_renderer.color = _colour;
		line_renderer.color = line_renderer.color.setAlpha(a);
	}

	public override Color getStringColour()
	{
		return line_renderer.color;
	}

	protected override void retractString(bool _destroy = true)
	{
		retract().addCallback(delegate
		{
			if (_destroy)
			{
				Object.Destroy(base.gameObject);
			}
		}).start(this);
	}

	private IEnumerator retract()
	{
		refreshSimulation(2f);
		float _e = 0f;
		float duration = 0.35f;
		Vector2 start = string_end_point;
		Vector2 diff = string_start_point - string_end_point;
		while (_e < duration)
		{
			_e += CoroutineExtensions.getDeltaTime();
			string_end_point = start + diff * CoroutineExtensions.easeInOutFunc(_e / duration);
			yield return null;
		}
		string_end_point = string_start_point;
	}

	public override void recalculateString()
	{
		updateStringEndPoints(starting_pin.value.transform.localPosition, ending_pin.value.transform.localPosition);
	}
}
