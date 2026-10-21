using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using GRGLib.PriorityQueue;
using UnityEngine;

namespace GRGLib.Extensions.AStar;

public class AStarSearch2D
{
	private Vector2Int goal;

	private Vector2Int start;

	private int overflow_tolerance;

	private Func<Vector2Int, Vector2Int, IEnumerable<Vector2Int>> get_valid_neighbours;

	private Func<Vector2Int, Vector2Int, int> get_edge_cost;

	public Dictionary<Vector2Int, Vector2Int> came_from { get; private set; } = new Dictionary<Vector2Int, Vector2Int>();

	public Dictionary<Vector2Int, int> cost_so_far { get; private set; } = new Dictionary<Vector2Int, int>();

	public AStarSearch2D(Vector2Int _start, Vector2Int _goal, Func<Vector2Int, Vector2Int, IEnumerable<Vector2Int>> _get_valid_neighbours, Func<Vector2Int, Vector2Int, int> _get_edge_cost, int _overflow_tolerance = 100000)
	{
		get_valid_neighbours = _get_valid_neighbours;
		get_edge_cost = _get_edge_cost;
		overflow_tolerance = _overflow_tolerance;
		establishMove(_start, _goal);
	}

	protected virtual void establishMove(Vector2Int _start, Vector2Int _goal)
	{
		moveToGoal(_start, _goal);
	}

	private void moveToGoal(Vector2Int _start, Vector2Int _goal)
	{
		start = _start;
		goal = _goal;
		PriorityQueue<Vector2Int, int> priorityQueue = new PriorityQueue<Vector2Int, int>();
		priorityQueue.Enqueue(_start, 0);
		came_from[_start] = _start;
		cost_so_far[_start] = 0;
		int num = 0;
		while (priorityQueue.Count > 0)
		{
			Vector2Int vector2Int = priorityQueue.Dequeue();
			if (vector2Int.Equals(_goal))
			{
				break;
			}
			if (num > overflow_tolerance)
			{
				throw new StackOverflowException("A* is overflowing - probably stuck!");
			}
			num++;
			foreach (Vector2Int item in get_valid_neighbours(vector2Int, _goal))
			{
				int num2 = cost_so_far[vector2Int] + get_edge_cost(vector2Int, item);
				if (!cost_so_far.ContainsKey(item) || num2 < cost_so_far[item])
				{
					cost_so_far[item] = num2;
					int priority = num2 + heuristic(item, _goal);
					priorityQueue.Enqueue(item, priority);
					came_from[item] = vector2Int;
				}
			}
		}
	}

	public static int heuristic(Vector2Int _a, Vector2Int _b)
	{
		return Math.Abs(_a.x - _b.x) + Math.Abs(_a.y - _b.y);
	}

	public bool goalFound()
	{
		return came_from.ContainsKey(goal);
	}

	public Maybe<List<Vector2Int>> getPath()
	{
		if (!goalFound())
		{
			return new Maybe<List<Vector2Int>>();
		}
		Vector2Int vector2Int = goal;
		List<Vector2Int> list = new List<Vector2Int>();
		while (vector2Int != start)
		{
			list.Add(vector2Int);
			vector2Int = came_from[vector2Int];
		}
		list.Reverse();
		return list.maybe();
	}

	public Maybe<Vector2Int> getFirstStep()
	{
		if (!getPath().is_some)
		{
			return new Maybe<Vector2Int>();
		}
		if (getPath().value.Count() <= 0)
		{
			return new Maybe<Vector2Int>();
		}
		return getPath().value.First().maybe();
	}
}
