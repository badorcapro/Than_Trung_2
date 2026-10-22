using System;
using System.Collections.Generic;
using ControllerSupport;
using GRGLib.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;
using GRGLocalisation;
using Hover;
using Localisation;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using Visual;

namespace Codex;

public class CodexMenu : MenuBase, IAmLocalised
{
	[Header("Referecences")]
	[SerializeField]
	private RectTransform page_parent;

	[SerializeField]
	private CaseControllerSupportHandler controller_support;

	[SerializeField]
	private JiggleButton close_button;

	[SerializeField]
	private Image close_button_image;

	[SerializeField]
	private CodexAnimationManager paralax_manager;

	[SerializeField]
	private ControllerKeySearchHandler key_search;

	[SerializeField]
	private TemporaryToolTip inspect_tooltip;

	[Header("Settings")]
	[SerializeField]
	private Sprite close_button_sprite;

	[SerializeField]
	private Sprite back_button_sprite;

	[Header("Prefabs")]
	[SerializeField]
	private CodexRoleMenu role_menu_prefab;

	[SerializeField]
	private CodexRolePage default_role_page_prefab;

	[SerializeField]
	private SerializableDictionary<Roles, CodexRolePage> specific_role_page_prefabs;

	[SerializeField]
	private CodexQuirkPage default_quirk_page_prefab;

	[SerializeField]
	private SerializableDictionary<CaseQuirks, CodexQuirkPage> specific_quirk_page_prefabs;

	[SerializeField]
	private CodexRoleShortcuts shortcuts_page_prefab;

	private Maybe<CodexPage> open_page = new Maybe<CodexPage>();

	private Maybe<SuspectVisual> return_suspect = new Maybe<SuspectVisual>();

	private Maybe<Action> override_close = new Maybe<Action>();

	private AssetKey localisation_asset => LocalisationHelper.ui_asset;

	public void openRegionPage(Regions _region, bool _open_codex = true)
	{
		openRegionPage(_region, RoleClassifications.INNOCENT, _open_codex);
	}

	public void openRegionPageWithToggle(Regions _region, RoleClassifications _classification, List<Roles> _selected, List<Roles> _locked, Dictionary<RoleClassifications, int> _min_needed, Action<List<Roles>> _callback, bool _open_codex = true)
	{
		openPage(_select_button: false, _open_codex, delegate
		{
			CodexRoleMenu page = UnityEngine.Object.Instantiate(role_menu_prefab, page_parent);
			page.setUpCodexWithSelection(this, _classification, close_button, _region, _locked, _selected, _min_needed, _callback);
			inspect_tooltip.close();
			override_close = MaybeExtensions.maybe<Action>(delegate
			{
				_callback(page.role_selection.value.selected);
				closeMenu();
				override_close = new Maybe<Action>();
			});
			return page;
		});
	}

	public void openRegionPage(Regions _region, RoleClassifications _class, bool _open_codex = true)
	{
		openPage(_select_button: false, _open_codex, delegate
		{
			CodexRoleMenu codexRoleMenu = UnityEngine.Object.Instantiate(role_menu_prefab, page_parent);
			codexRoleMenu.setUpCodex(this, _class, close_button, _region.maybe());
			inspect_tooltip.close();
			return codexRoleMenu;
		});
	}

	public void openRoleMenuPage(bool _open_codex = true, RoleClassifications _class = RoleClassifications.INNOCENT)
	{
		openPage(_select_button: false, _open_codex, delegate
		{
			CodexRoleMenu codexRoleMenu = UnityEngine.Object.Instantiate(role_menu_prefab, page_parent);
			codexRoleMenu.setUpCodex(this, _class, close_button, new Maybe<Regions>());
			inspect_tooltip.close();
			return codexRoleMenu;
		});
	}

	public void openQuirksPageWithToggle(Regions _region, List<CaseQuirks> _selected, List<CaseQuirks> _locked, MinMaxInt _required, Action<List<CaseQuirks>> _callback, bool _open_codex = true)
	{
		openPage(_select_button: false, _open_codex, delegate
		{
			CodexRoleMenu page = UnityEngine.Object.Instantiate(role_menu_prefab, page_parent);
			page.setUpCodexWithSelection(this, close_button, _region, _locked, _selected, _required, _callback);
			inspect_tooltip.close();
			override_close = MaybeExtensions.maybe<Action>(delegate
			{
				_callback(page.quirk_selection.value.selected);
				closeMenu();
				override_close = new Maybe<Action>();
			});
			return page;
		});
	}

	public void openQuirkMenuPage(Maybe<Regions> _region, bool _open_codex = true)
	{
		openPage(_select_button: false, _open_codex, delegate
		{
			CodexRoleMenu codexRoleMenu = UnityEngine.Object.Instantiate(role_menu_prefab, page_parent);
			codexRoleMenu.setUpCodexQuirks(this, close_button, _region);
			inspect_tooltip.close();
			return codexRoleMenu;
		});
	}

	public void openShortcutMenuPage(Maybe<Regions> _current_region, RoleClassifications _current_classification, bool _open_codex = true)
	{
		openPage(_select_button: false, _open_codex, delegate
		{
			CodexRoleShortcuts codexRoleShortcuts = UnityEngine.Object.Instantiate(shortcuts_page_prefab, page_parent);
			codexRoleShortcuts.setupPage(close_button, input);
			inspect_tooltip.close();
			changeCloseButtonToBackWithCallback(delegate
			{
				if (_current_region.is_some)
				{
					openRegionPage(_current_region.value, _current_classification, _open_codex: false);
				}
				else
				{
					openRoleMenuPage(_open_codex: false, _current_classification);
				}
			});
			return codexRoleShortcuts;
		});
	}

	public void openShortcutMenuPage(Maybe<Regions> _current_region, bool _open_codex = true)
	{
		openPage(_select_button: false, _open_codex, delegate
		{
			CodexRoleShortcuts codexRoleShortcuts = UnityEngine.Object.Instantiate(shortcuts_page_prefab, page_parent);
			codexRoleShortcuts.setupPage(close_button, input);
			inspect_tooltip.close();
			changeCloseButtonToBackWithCallback(delegate
			{
				openQuirkMenuPage(_current_region, _open_codex: false);
			});
			return codexRoleShortcuts;
		});
	}

	public void openPage(Roles _role, Maybe<CaseSnapshot> _snap, bool _open_codex = true)
	{
		openPage(_select_button: true, _open_codex, delegate
		{
			CodexRolePage codexRolePage = createRolePage(_role);
			codexRolePage.setUpPage(_role, _snap);
			checkInspectTootip();
			return codexRolePage;
		});
	}

	public void openPage(CaseQuirks _quirk, bool _open_codex = true)
	{
		openPage(_select_button: true, _open_codex, delegate
		{
			CodexQuirkPage codexQuirkPage = createQuirkPage(_quirk);
			codexQuirkPage.setUpPage(_quirk);
			checkInspectTootip();
			return codexQuirkPage;
		});
	}

	private void openPage(bool _select_button, bool _open_codex, Func<CodexPage> _create_page)
	{
		if (controller_support != null && controller_support.selected_suspect.is_some)
		{
			return_suspect = controller_support.selected_suspect.value.maybe();
		}
		if (_open_codex)
		{
			openMenu();
		}
		bool flag = false;
		if (open_page.is_some)
		{
			flag = true;
			open_page.value.fadeOutAndDestroy();
		}
		CodexPage codexPage = _create_page();
		if (flag)
		{
			codexPage.fadeIn();
		}
		else
		{
			codexPage.immidiateFadeIn();
		}
		open_page = codexPage.maybe();
		if (_select_button && GameHandler.instance.using_gamepad)
		{
			close_button.Select();
		}
	}

	protected override void Awake()
	{
		base.Awake();
		inspect_tooltip.setUp(input);
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		if (open_page.is_some)
		{
			open_page.value.immidiateDestroy();
			open_page = new Maybe<CodexPage>();
		}
		if (GameHandler.instance.using_gamepad && return_suspect.is_some)
		{
			return_suspect.value.getSelectable().Select();
			return_suspect = new Maybe<SuspectVisual>();
		}
	}

	protected override void onMenuOpening()
	{
		base.onMenuOpening();
		paralax_manager.openAnimation();
	}

	protected override void onMenuClosing()
	{
		base.onMenuClosing();
		paralax_manager.closeAnimation();
	}

	private CodexRolePage createRolePage(Roles _role)
	{
		if (specific_role_page_prefabs.ContainsKey(_role))
		{
			return UnityEngine.Object.Instantiate(specific_role_page_prefabs[_role], page_parent);
		}
		return UnityEngine.Object.Instantiate(default_role_page_prefab, page_parent);
	}

	private CodexQuirkPage createQuirkPage(CaseQuirks _quirk)
	{
		if (specific_quirk_page_prefabs.ContainsKey(_quirk))
		{
			return UnityEngine.Object.Instantiate(specific_quirk_page_prefabs[_quirk], page_parent);
		}
		return UnityEngine.Object.Instantiate(default_quirk_page_prefab, page_parent);
	}

	public Selectable getCloseSelectable()
	{
		return close_button;
	}

	public void onCloseOrBack()
	{
		if (override_close.is_some)
		{
			override_close.value();
			override_close = new Maybe<Action>();
			close_button_image.sprite = close_button_sprite;
		}
		else
		{
			closeMenu();
		}
	}

	public void changeCloseButtonToBackWithCallback(Action _on_back)
	{
		close_button_image.sprite = back_button_sprite;
		override_close = _on_back.maybe();
	}

	public override void onDeviceChange(PlayerInput _input)
	{
		if (!base.is_closed)
		{
			base.onDeviceChange(_input);
			key_search.onDeviceChange(_input);
			if (!_input.isUsingGamepad())
			{
				inspect_tooltip.close();
			}
			else
			{
				inspect_tooltip.open();
			}
		}
	}

	public void onInspect(InputAction.CallbackContext _context)
	{
		if (!_context.canceled && _context.performed && open_page.is_some && open_page.value is CodexEntryPage codexEntryPage)
		{
			if (key_search.is_open)
			{
				key_search.closeMenu();
				return;
			}
			openNewMenu(key_search);
			codexEntryPage.setUpControllerInspect(key_search);
		}
	}

	public void onBack(InputAction.CallbackContext _context)
	{
		if (!_context.canceled && _context.performed)
		{
			if (key_search.is_open)
			{
				key_search.closeMenu();
			}
			else
			{
				onCloseOrBack();
			}
		}
	}

	private void checkInspectTootip()
	{
		if (GameHandler.instance.using_gamepad)
		{
			inspect_tooltip.open();
		}
		else
		{
			inspect_tooltip.close();
		}
	}

	private string checkTranslation(string _english_and_key)
	{
		if (GRGLocalisationHandler.needs_translation && GRGLocalisationHandler.instance.translate(localisation_asset, _english_and_key, out var _result))
		{
			return _result;
		}
		return _english_and_key;
	}
}
