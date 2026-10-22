using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLocalisation;
using Hover;
using Localisation;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Codex;

public abstract class CodexEntryPage : CodexPage, IAmLocalised
{
	public static float max_text_height = 1100f;

	[SerializeField]
	protected CodexVisualDataSO codex_visuals;

	[Space]
	[SerializeField]
	protected Image icon_image;

	[SerializeField]
	protected TMP_Text name_text;

	[SerializeField]
	protected CodexPageText main_description;

	[SerializeField]
	protected TMP_Text credit_text;

	[SerializeField]
	protected Image credit_star;

	[Header("Prefabs")]
	[SerializeField]
	protected CodexPageText page_text_prefab;

	protected List<CodexPageText> extra_texts = new List<CodexPageText>();

	protected string loc_credit_key => "Codex [creditation]";

	protected string loc_temp_key => "Codex [demo_temp]";

	protected AssetKey loc_asset_key => LocalisationHelper.misc_asset;

	protected virtual void setUp(Sprite _icon, string _name, string _desc, List<(DescriptionType, string)> _extra_descriptions, Maybe<(string, Color)> _credits)
	{
		icon_image.sprite = _icon;
		name_text.text = _name;
		main_description.setUp(_desc, codex_visuals[DescriptionType.MAIN]);
		CodexPageText codexPageText = main_description;
		for (int i = 0; i < _extra_descriptions.Count; i++)
		{
			CodexPageText codexPageText2 = Object.Instantiate(page_text_prefab, codexPageText.transform);
			codexPageText2.setUp(_extra_descriptions[i].Item2, codex_visuals[_extra_descriptions[i].Item1]);
			extra_texts.Add(codexPageText2);
			codexPageText = codexPageText2;
		}
		setUpCreditation(_credits);
		setTextSizes();
	}

	protected void setUpCreditation(Maybe<(string, Color)> _credits)
	{
		if (_credits.is_some)
		{
			credit_text.gameObject.SetActive(value: true);
			credit_star.color = _credits.value.Item2;
			credit_text.text = getCreditText(_credits.value.Item1);
			credit_text.ForceMeshUpdate();
			credit_text.rectTransform.sizeDelta = new Vector2(credit_text.renderedWidth, credit_text.rectTransform.sizeDelta.y);
		}
		else
		{
			credit_text.gameObject.SetActive(value: false);
			credit_text.text = "";
		}
	}

	protected void setTextSizes()
	{
		0.01f.wait(delegate
		{
			float num = main_description.sizeText(0f);
			for (int i = 0; i < extra_texts.Count; i++)
			{
				num = extra_texts[i].sizeText(num) + 50f;
			}
			if (num > max_text_height)
			{
				float num2 = num - max_text_height;
				float changeable_height = 0f;
				List<(CodexPageText, float)> list = extra_texts.Aggregate(new List<(CodexPageText, float)>(), delegate(List<(CodexPageText, float)> _a, CodexPageText _e)
				{
					float num3 = _e.calculateMaxHeightChange();
					if (num3 > 0f)
					{
						changeable_height += num3;
						_a.Add((_e, num3));
					}
					return _a;
				});
				if (changeable_height < num2)
				{
					float num4 = main_description.calculateMaxHeightChange();
					if (num4 > 0f)
					{
						changeable_height += num4;
						list.Add((main_description, num4));
					}
				}
				float reduce_multi = Mathf.Min(1f, num2 / changeable_height);
				list.ForEach(delegate((CodexPageText, float) _t)
				{
					_t.Item1.reduceTextHeightBy(_t.Item2 * reduce_multi);
				});
			}
		}).start(this);
	}

	public void setUpControllerInspect(ControllerKeySearchHandler _key_search)
	{
		_key_search.setUpPageKeywordsLinks(getAllHoverableTexts());
	}

	protected virtual List<TMP_Text> getAllHoverableTexts()
	{
		return new List<TMP_Text> { main_description.getText() }.addRange(extra_texts.Select((CodexPageText _t) => _t.getText()));
	}

	private string getCreditText(string _data)
	{
		if (GRGLocalisationHandler.needs_translation)
		{
			string _result = "";
			if (GRGLocalisationHandler.instance.translateAndReplace(loc_asset_key, loc_credit_key, out _result, _data))
			{
				return _result;
			}
		}
		return englishCredit(_data);
	}

	protected string englishCredit(string _data)
	{
		return "Idea from " + _data;
	}

	protected string tempDemoRoleEnglish()
	{
		return "Temporary Role!";
	}
}
