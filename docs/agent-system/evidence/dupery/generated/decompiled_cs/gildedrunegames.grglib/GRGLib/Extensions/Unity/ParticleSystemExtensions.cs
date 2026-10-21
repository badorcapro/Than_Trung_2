using UnityEngine;

namespace GRGLib.Extensions.Unity;

public static class ParticleSystemExtensions
{
	public static void setConstantStartColourAlpha(this ParticleSystem _system, float _alpha)
	{
		_system.setConstantStartColour(_system.main.startColor.color.setAlpha(_alpha));
	}

	public static void setConstantStartColour(this ParticleSystem _system, Color _colour)
	{
		ParticleSystem.MainModule main = _system.main;
		ParticleSystem.MinMaxGradient startColor = main.startColor;
		startColor.color = _colour;
		main.startColor = startColor;
	}

	public static void setConstantRateOverTimeEmission(this ParticleSystem _system, float _rate)
	{
		ParticleSystem.EmissionModule emission = _system.emission;
		ParticleSystem.MinMaxCurve rateOverTime = emission.rateOverTime;
		rateOverTime.constant = _rate;
		emission.rateOverTime = rateOverTime;
	}

	public static void setConstantsRateOverTimeEmission(this ParticleSystem _system, float _min, float _max)
	{
		ParticleSystem.EmissionModule emission = _system.emission;
		ParticleSystem.MinMaxCurve rateOverTime = emission.rateOverTime;
		rateOverTime.constantMin = _min;
		rateOverTime.constantMax = _max;
		emission.rateOverTime = rateOverTime;
	}
}
