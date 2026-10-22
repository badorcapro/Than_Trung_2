using System;
using UnityEngine.Serialization;

namespace FMODUnity;

[Serializable]
public struct AutomatableSlots
{
	public const int Count = 16;

	[FormerlySerializedAs("slot00")]
	public float Slot00;

	[FormerlySerializedAs("slot01")]
	public float Slot01;

	[FormerlySerializedAs("slot02")]
	public float Slot02;

	[FormerlySerializedAs("slot03")]
	public float Slot03;

	[FormerlySerializedAs("slot04")]
	public float Slot04;

	[FormerlySerializedAs("slot05")]
	public float Slot05;

	[FormerlySerializedAs("slot06")]
	public float Slot06;

	[FormerlySerializedAs("slot07")]
	public float Slot07;

	[FormerlySerializedAs("slot08")]
	public float Slot08;

	[FormerlySerializedAs("slot09")]
	public float Slot09;

	[FormerlySerializedAs("slot10")]
	public float Slot10;

	[FormerlySerializedAs("slot11")]
	public float Slot11;

	[FormerlySerializedAs("slot12")]
	public float Slot12;

	[FormerlySerializedAs("slot13")]
	public float Slot13;

	[FormerlySerializedAs("slot14")]
	public float Slot14;

	[FormerlySerializedAs("slot15")]
	public float Slot15;

	public float GetValue(int index)
	{
		return index switch
		{
			0 => Slot00, 
			1 => Slot01, 
			2 => Slot02, 
			3 => Slot03, 
			4 => Slot04, 
			5 => Slot05, 
			6 => Slot06, 
			7 => Slot07, 
			8 => Slot08, 
			9 => Slot09, 
			10 => Slot10, 
			11 => Slot11, 
			12 => Slot12, 
			13 => Slot13, 
			14 => Slot14, 
			15 => Slot15, 
			_ => throw new ArgumentException($"Invalid slot index: {index}"), 
		};
	}
}
