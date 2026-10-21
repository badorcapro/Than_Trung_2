using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using GRGLib.PriorityQueue;
using UnityEngine;

namespace GRGLib.Extensions.AStar;

public class AStarSearch
{
	private Vector3Int goal;

	private Vector3Int start;

	private int overflow_tolerance;

	private Func<Vector3Int, Vector3Int, IEnumerable<Vector3Int>> get_valid_neighbours;

	private Func<Vector3Int, Vector3Int, int> get_edge_cost;

	public Dictionary<Vector3Int, Vector3Int> came_from { get; private set; } = new Dictionary<Vector3Int, Vector3Int>();

	public Dictionary<Vector3Int, int> cost_so_far { get; private set; } = new Dictionary<Vector3Int, int>();

	public AStarSearch(Vector3Int _start, Vector3Int _goal, Func<Vector3Int, Vector3Int, IEnumerable<Vector3Int>> _get_valid_neighbours, Func<Vector3Int, Vector3Int, int> _get_edge_cost, int _overflow_tolerance = 100000)
	{
		get_valid_neighbours = _get_valid_neighbours;
		get_edge_cost = _get_edge_cost;
		overflow_tolerance = _overflow_tolerance;
		establishMove(_start, _goal);
	}

	protected virtual void establishMove(Vector3Int _start, Vector3Int _goal)
	{
		moveToGoal(_start, _goal);
	}

	private void moveToGoal(Vector3Int _start, Vector3Int _goal)
	{
		start = _start;
		goal = _goal;
		PriorityQueue<Vector3Int, int> priorityQueue = new PriorityQueue<Vector3Int, int>();
		priorityQueue.Enqueue(_start, 0);
		came_from[_start] = _start;
		cost_so_far[_start] = 0;
		int num = 0;
		while (priorityQueue.Count > 0)
		{
			Vector3Int vector3Int = priorityQueue.Dequeue();
			if (vector3Int.Equals(_goal))
			{
				break;
			}
			if (num > overflow_tolerance)
			{
				throw new StackOverflowException("A* is overflowing - probably stuck!");
			}
			num++;
			foreach (Vector3Int item in get_valid_neighbours(vector3Int, _goal))
			{
				int num2 = cost_so_far[vector3Int] + get_edge_cost(vector3Int, item);
				if (!cost_so_far.ContainsKey(item) || num2 < cost_so_far[item])
				{
					cost_so_far[item] = num2;
					int priority = num2 + heuristic(item, _goal);
					priorityQueue.Enqueue(item, priority);
					came_from[item] = vector3Int;
				}
			}
		}
	}

	public static int heuristic(Vector3Int _a, Vector3Int _b)
	{
		return Math.Abs(_a.x - _b.x) + Math.Abs(_a.y - _b.y);
	}

	public bool goalFound()
	{
		return came_from.ContainsKey(goal);
	}

	public Maybe<List<Vector3Int>> getPath()
	{
		if (!goalFound())
		{
			return new Maybe<List<Vector3Int>>();
		}
		Vector3Int vector3Int = goal;
		List<Vector3Int> list = new List<Vector3Int>();
		while (vector3Int != start)
		{
			list.Add(vector3Int);
			vector3Int = came_from[vector3Int];
		}
		list.Reverse();
		return list.maybe();
	}

	public Maybe<Vector3Int> getFirstStep()
	{
		if (!getPath().is_some)
		{
			return new Maybe<Vector3Int>();
		}
		if (getPath().value.Count() <= 0)
		{
			return new Maybe<Vector3Int>();
		}
		return getPath().value.First().maybe();
	}
}
