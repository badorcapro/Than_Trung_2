using TMPro;
using UnityEngine;

namespace GRGLib.TextAnimation;

public abstract class TextAnimationManager
{
	public TMP_Text text;

	public int start_index;

	public int end_index = -1;

	public TextAnimationManager(TMP_Text _text, int _start_index = 0, int _end_index = -1)
	{
		text = _text;
		start_index = _start_index;
		end_index = _end_index;
	}

	public abstract Vector3 VertexOffset(Vector3 _vert_origin, TMP_MeshInfo _mesh, int _char_id, int _vertex_index);

	public virtual void onUpdate()
	{
	}
}
