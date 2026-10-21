using TMPro;
using UnityEngine;

namespace GRGLib.TextAnimation;

public class CombineAnimationsManager : TextAnimationManager
{
	private TextAnimationManager[] managers;

	public CombineAnimationsManager(TMP_Text _text, params TextAnimationManager[] _managers)
		: base(_text)
	{
		managers = _managers;
	}

	public override Vector3 VertexOffset(Vector3 _vert_origin, TMP_MeshInfo _mesh, int _char_id, int _vertex_index)
	{
		Vector3 vector = _vert_origin;
		TextAnimationManager[] array = managers;
		for (int i = 0; i < array.Length; i++)
		{
			vector = array[i].VertexOffset(vector, _mesh, _char_id, _vertex_index);
		}
		return vector;
	}

	public override void onUpdate()
	{
		base.onUpdate();
		TextAnimationManager[] array = managers;
		for (int i = 0; i < array.Length; i++)
		{
			array[i].onUpdate();
		}
	}
}
