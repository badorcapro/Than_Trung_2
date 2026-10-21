using System;
using UnityEngine;

namespace GRGLib.Extensions.Bezier;

[Serializable]
public struct SplinePoint
{
	public Vector3 point;

	[HideInInspector]
	[SerializeField]
	private Vector3 m_constraint_before;

	[HideInInspector]
	[SerializeField]
	private Vector3 m_constraint_after;

	public Vector3 constraint_before => point + m_constraint_before;

	public Vector3 constraint_after => point + m_constraint_after;

	public SplinePoint(Vector3 _point, Vector3 _constraint_before, Vector3 _constraint_after)
	{
		point = _point;
		m_constraint_after = _constraint_after;
		m_constraint_before = _constraint_before;
	}

	public Vector3 getRelativeConstraintBefore()
	{
		return m_constraint_before;
	}

	public Vector3 getRelativeConstraintAfter()
	{
		return m_constraint_after;
	}
}
