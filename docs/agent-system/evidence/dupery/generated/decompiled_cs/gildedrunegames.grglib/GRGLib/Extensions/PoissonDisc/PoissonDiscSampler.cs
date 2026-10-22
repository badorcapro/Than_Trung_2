using System;
using System.Collections.Generic;
using UnityEngine;

namespace GRGLib.Extensions.PoissonDisc;

public class PoissonDiscSampler
{
	private struct GridPos
	{
		public int x;

		public int y;

		public GridPos(Vector2 sample, float cellSize)
		{
			x = (int)(sample.x / cellSize);
			y = (int)(sample.y / cellSize);
		}
	}

	private const int k = 1000;

	private readonly Rect rect;

	private readonly float radius2;

	private readonly float cellSize;

	private Vector2[,] grid;

	private List<Vector2> activeSamples = new List<Vector2>();

	private System.Random random;

	public PoissonDiscSampler(float width, float height, float radius, System.Random _rnd)
	{
		rect = new Rect(0f, 0f, width, height);
		radius2 = radius * radius;
		cellSize = radius / Mathf.Sqrt(2f);
		grid = new Vector2[Mathf.CeilToInt(width / cellSize), Mathf.CeilToInt(height / cellSize)];
		random = _rnd;
	}

	public IEnumerable<Vector2> Samples()
	{
		yield return AddSample(new Vector2((float)random.NextDouble() * rect.width, (float)random.NextDouble() * rect.height));
		while (activeSamples.Count > 0)
		{
			int i = (int)(float)random.NextDouble() * activeSamples.Count;
			Vector2 vector = activeSamples[i];
			bool found = false;
			for (int j = 0; j < 1000; j++)
			{
				float f = MathF.PI * 2f * (float)random.NextDouble();
				float num = Mathf.Sqrt((float)random.NextDouble() * 3f * radius2 + radius2);
				Vector2 vector2 = vector + num * new Vector2(Mathf.Cos(f), Mathf.Sin(f));
				if (rect.Contains(vector2) && IsFarEnough(vector2))
				{
					found = true;
					yield return AddSample(vector2);
					break;
				}
			}
			if (!found)
			{
				activeSamples[i] = activeSamples[activeSamples.Count - 1];
				activeSamples.RemoveAt(activeSamples.Count - 1);
			}
		}
	}

	private bool IsFarEnough(Vector2 sample)
	{
		GridPos gridPos = new GridPos(sample, cellSize);
		int num = Mathf.Max(gridPos.x - 2, 0);
		int num2 = Mathf.Max(gridPos.y - 2, 0);
		int num3 = Mathf.Min(gridPos.x + 2, grid.GetLength(0) - 1);
		int num4 = Mathf.Min(gridPos.y + 2, grid.GetLength(1) - 1);
		for (int i = num2; i <= num4; i++)
		{
			for (int j = num; j <= num3; j++)
			{
				Vector2 vector = grid[j, i];
				if (vector != Vector2.zero)
				{
					Vector2 vector2 = vector - sample;
					if (vector2.x * vector2.x + vector2.y * vector2.y < radius2)
					{
						return false;
					}
				}
			}
		}
		return true;
	}

	private Vector2 AddSample(Vector2 sample)
	{
		activeSamples.Add(sample);
		GridPos gridPos = new GridPos(sample, cellSize);
		grid[gridPos.x, gridPos.y] = sample;
		return sample;
	}
}
