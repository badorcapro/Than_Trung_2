using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using Leads;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObject/Stamp Visual Data SO")]
public class StampVisualDataSO : ScriptableObject
{
	[Header("Settings")]
	[SerializeField]
	private RoleVisualDataSO role_visual_data;

	[SerializeField]
	private CaseQuirksVisualDataSO quirk_visual_data;

	[SerializeField]
	private SerializableDictionary<StampType, Sprite> stamp_backgrounds;

	[SerializeField]
	private Sprite backup_stamp_background;

	[SerializeField]
	private StampFacade stamp_prefab;

	[SerializeField]
	private StampFacade quirk_stamp_prefab;

	[SerializeField]
	private StampFacade role_stamp_prefab;

	public Sprite this[StampType _type] => getStampBackground(_type);

	public StampFacade this[StampReference _ref, Transform _parent] => createStamp(_ref, _parent, StampFacade.scale);

	public StampFacade this[StampReference _ref, Transform _parent, float _scale] => createStamp(_ref, _parent, _scale);

	private Sprite getStampBackground(StampType _stamp)
	{
		return stamp_backgrounds.getOrDefault(_stamp, backup_stamp_background);
	}

	private StampFacade createStamp(StampReference _ref, Transform _parent, float _scale)
	{
		switch (_ref.stamp_type)
		{
		case StampType.QUIRK:
		{
			StampFacade stampFacade4 = Object.Instantiate(quirk_stamp_prefab, _parent);
			stampFacade4.setUpStamp(getStampBackground(_ref.stamp_type), quirk_visual_data[_ref.data_as_quirk], Color.white, _scale);
			return stampFacade4;
		}
		case StampType.ROLE_IN_PLAY:
		case StampType.ROLE_SUSPECTED:
		case StampType.ROLE_NOT_IN_PLAY:
		{
			StampFacade stampFacade3 = Object.Instantiate(role_stamp_prefab, _parent);
			stampFacade3.setUpStamp(getStampBackground(_ref.stamp_type), role_visual_data[_ref.data_as_role], Color.black, _scale);
			return stampFacade3;
		}
		case StampType.PLUS_ONE_CASE:
		case StampType.INCREASE_BOARD_SIZE:
		case StampType.REP_GAIN:
		case StampType.CHIPS_GAIN:
		{
			StampFacade stampFacade2 = Object.Instantiate(stamp_prefab, _parent);
			stampFacade2.setUpStamp(getStampBackground(_ref.stamp_type), _scale);
			return stampFacade2;
		}
		default:
		{
			Debug.LogError($"Not sure how to set up stamp of type {_ref.stamp_type}!");
			StampFacade stampFacade = Object.Instantiate(stamp_prefab, _parent);
			stampFacade.setUpStamp(getStampBackground(_ref.stamp_type), _scale);
			return stampFacade;
		}
		}
	}

	public StampFacade createStampWithCusomIcon(StampReference _ref, Sprite _icon, Transform _parent)
	{
		return createStampWithCusomIcon(_ref, _icon, _parent, StampFacade.scale);
	}

	public StampFacade createStampWithCusomIcon(StampReference _ref, Sprite _icon, Transform _parent, float _scale)
	{
		switch (_ref.stamp_type)
		{
		case StampType.QUIRK:
		{
			StampFacade stampFacade4 = Object.Instantiate(quirk_stamp_prefab, _parent);
			stampFacade4.setUpStamp(getStampBackground(_ref.stamp_type), _icon, Color.white, _scale);
			return stampFacade4;
		}
		case StampType.ROLE_IN_PLAY:
		case StampType.ROLE_SUSPECTED:
		case StampType.ROLE_NOT_IN_PLAY:
		{
			StampFacade stampFacade3 = Object.Instantiate(role_stamp_prefab, _parent);
			stampFacade3.setUpStamp(getStampBackground(_ref.stamp_type), _icon, Color.black, _scale);
			return stampFacade3;
		}
		case StampType.PLUS_ONE_CASE:
		case StampType.INCREASE_BOARD_SIZE:
		case StampType.REP_GAIN:
		case StampType.CHIPS_GAIN:
		{
			StampFacade stampFacade2 = Object.Instantiate(stamp_prefab, _parent);
			stampFacade2.setUpStamp(getStampBackground(_ref.stamp_type), _scale);
			return stampFacade2;
		}
		default:
		{
			Debug.LogError($"Not sure how to set up stamp of type {_ref.stamp_type}!");
			StampFacade stampFacade = Object.Instantiate(stamp_prefab, _parent);
			stampFacade.setUpStamp(getStampBackground(_ref.stamp_type), _scale);
			return stampFacade;
		}
		}
	}
}
