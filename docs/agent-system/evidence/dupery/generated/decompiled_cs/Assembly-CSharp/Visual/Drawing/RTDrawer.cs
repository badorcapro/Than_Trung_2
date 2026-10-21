using System.Linq;
using UnityEngine;
using UnityEngine.UI;

namespace Visual.Drawing;

public class RTDrawer : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RenderTexture render_texture;

	[SerializeField]
	private RawImage raw_image;

	private Texture2D texture;

	private Color32[] colour_buffer;

	private void Start()
	{
		texture = new Texture2D(render_texture.width, render_texture.height);
		raw_image.texture = texture;
		clearPixels();
	}

	public void clearPixels()
	{
		RenderTexture.active = render_texture;
		for (int i = 0; i < render_texture.width; i++)
		{
			for (int j = 0; j < render_texture.height; j++)
			{
				texture.SetPixel(i, j, new Color(0f, 0f, 0f, 0f));
			}
		}
		texture.Apply();
		Graphics.Blit(texture, render_texture);
		colour_buffer = texture.GetPixels32();
		RenderTexture.active = null;
	}

	public void stampLineBrush(Vector2Int _pos1, Vector2Int _pos2, int _radius, Color32 _colour)
	{
		(from _e in _pos1.makeLine(_pos2, _radius)
			where _e.x > 0 && _e.x < render_texture.width && _e.y > 0 && _e.y < render_texture.height
			select _e).ToList().ForEach(delegate(Vector2Int _e)
		{
			updatePix32(_e.x, _e.y, _colour);
		});
		updateTexture();
	}

	public void stampCircleBrush(int _radius, Vector2Int _ori_xy, Color32 _colour)
	{
		(from _e in _ori_xy.makeCircle(_radius)
			where _e.x > 0 && _e.x < render_texture.width && _e.y > 0 && _e.y < render_texture.height
			select _e).ToList().ForEach(delegate(Vector2Int _e)
		{
			updatePix32(_e.x, _e.y, _colour);
		});
		updateTexture();
	}

	public void stampCircleBrush(int _radius, int _ori_x, int _ori_y, Color32 _col)
	{
		stampCircleBrush(_radius, new Vector2Int(_ori_x, _ori_y), _col);
	}

	public void updateTexture()
	{
		texture.SetPixels32(colour_buffer);
		texture.Apply();
	}

	public void updatePix32(int _x, int _y, Color32 _col)
	{
		colour_buffer[_y * render_texture.width + _x] = _col;
	}
}
