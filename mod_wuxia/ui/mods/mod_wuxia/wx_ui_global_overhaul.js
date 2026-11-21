/* ============================================================================
 * BB Wuxia Mod - Global System UI Synchronization & Overhaul Bus (v2)
 * Vanilla-Isomorphic Architecture: Uses 100% vanilla UI textures, fonts, and
 * palette (#dda21f / #d7b174 / #bd9d71 / #CD2626 / #d6dbe9), while delivering
 * Positive Qi bar, Wuxia silver/supply icons, Town Shop signboards, Vault slot
 * highlights, and a Vanilla-skinned 44-Sect Relations Dialog.
 * Strictly ES3-compliant (zero let/const/arrow/template-literals/class).
 * ============================================================================ */

(function () {
	'use strict';

	function wxEsc(_s) {
		if (_s === null || typeof _s === 'undefined') return '';
		return String(_s)
			.split('&').join('&amp;')
			.split('<').join('&lt;')
			.split('>').join('&gt;')
			.split('"').join('&quot;');
	}

	function wxShowFloatingBanner(_host, _msg, _isErr) {
		if (!_host || !_host.length || !_msg) return;
		var banner = _host.children('.wx-screen-banner');
		if (!banner.length) {
			banner = $('<div class="wx-screen-banner" style="display:none;"></div>');
			_host.append(banner);
		}
		if (banner.data('wxTimer')) {
			clearTimeout(banner.data('wxTimer'));
		}
		banner
			.removeClass('is-ok is-err')
			.addClass(_isErr ? 'is-err' : 'is-ok')
			.text(_msg)
			.stop(true, true)
			.show();
		var tid = setTimeout(function () {
			banner.fadeOut(240);
		}, 3200);
		banner.data('wxTimer', tid);
	}

	// ------------------------------------------------------------------------
	// 1. O(1) Economy & Jianghu Asset Icon Mapping (Vanilla stat/slot icons kept!)
	// ------------------------------------------------------------------------
	var WX_ICON_MAP = {
		'ui/icons/asset_money.png':       'ui/wx_icons/wx_asset_money.png',
		'ui/icons/asset_daily_money.png': 'ui/wx_icons/wx_asset_money.png',
		'ui/icons/money.png':             'ui/wx_icons/wx_icon_money.png',
		'ui/tooltips/money.png':          'ui/wx_icons/wx_icon_money_small.png',
		'ui/icons/asset_food.png':        'ui/wx_icons/wx_asset_food.png',
		'ui/icons/asset_daily_food.png':  'ui/wx_icons/wx_asset_food.png',
		'ui/icons/asset_supplies.png':    'ui/wx_icons/wx_asset_supplies.png',
		'ui/icons/asset_ammo.png':        'ui/wx_icons/wx_asset_ammo.png',
		'ui/icons/asset_medicine.png':    'ui/wx_icons/wx_asset_medicine.png',
		'ui/icons/relations.png':         'ui/wx_icons/wx_glyph_sect_token.png'
	};

	if (typeof Asset !== 'undefined') {
		Asset.ICON_ASSET_MONEY       = 'ui/wx_icons/wx_asset_money.png';
		Asset.ICON_ASSET_DAILY_MONEY = 'ui/wx_icons/wx_asset_money.png';
		Asset.ICON_MONEY             = 'ui/wx_icons/wx_icon_money.png';
		Asset.ICON_MONEY_SMALL       = 'ui/wx_icons/wx_icon_money_small.png';
		Asset.ICON_ASSET_FOOD        = 'ui/wx_icons/wx_asset_food.png';
		Asset.ICON_ASSET_DAILY_FOOD  = 'ui/wx_icons/wx_asset_food.png';
		Asset.ICON_ASSET_SUPPLIES    = 'ui/wx_icons/wx_asset_supplies.png';
		Asset.ICON_ASSET_AMMO        = 'ui/wx_icons/wx_asset_ammo.png';
		Asset.ICON_ASSET_MEDICINE    = 'ui/wx_icons/wx_asset_medicine.png';
		Asset.ICON_RELATIONS         = 'ui/wx_icons/wx_glyph_sect_token.png';
		Asset.HEADER_TACTICAL_COMBAT_DIALOG        = 'ui/wx_skin/wx_header_jianghu.png';
		Asset.HEADER_COMBAT_RESULT_DIALOG          = 'ui/wx_skin/wx_header_jianghu_large.png';
		Asset.HEADER_WORLD_TOWN_SCREEN_MAIN_DIALOG = 'ui/wx_skin/wx_header_jianghu_large.png';
		Asset.HEADER_EVENT_POPUP                   = 'ui/wx_skin/wx_header_jianghu.png';
		Asset.HEADER_EVENT_POPUP_LARGE             = 'ui/wx_skin/wx_header_jianghu_large.png';
	}

	function wxUpgradeImagesIn(_root) {
		if (!_root || !_root.length) return;
		var gfxPrefix = (typeof Path !== 'undefined' && Path.GFX) ? Path.GFX : 'coui://gfx/';
		_root.find('img').each(function () {
			var src = $(this).attr('src') || '';
			if (!src || src.indexOf('wx_') !== -1) return;
			var gIdx = src.indexOf('gfx/');
			var rel = (gIdx !== -1) ? src.substring(gIdx + 4) : src;
			if (WX_ICON_MAP.hasOwnProperty(rel)) {
				$(this).attr('src', gfxPrefix + WX_ICON_MAP[rel]);
			}
		});
	}

	wxUpgradeImagesIn($(document.body));

	// ------------------------------------------------------------------------
	// 2. Vanilla-Isomorphic Item Slot Ownership Tags & Orange Highlight Glow
	// ------------------------------------------------------------------------
	function wxClearItemSlotBadge(_slot) {
		if (!_slot || !_slot.length) return;
		_slot.children('.wx-item-slot-badge, .wx-item-slot-hl').remove();
	}

	function wxDecorateItemSlot(_slot, _item) {
		if (!_slot || !_slot.length) return;
		wxClearItemSlotBadge(_slot);
		if (!_item || typeof _item !== 'object' || !_item.wxItemKind) return;

		if (_item.wxItemKind === 'manual') {
			var vBooks = _item.wxVaultBooks || 0;
			var lCnt = _item.wxLearnedCnt || 0;
			if (vBooks <= 0 && lCnt <= 0) {
				_slot.append('<div class="wx-item-slot-badge is-new">新</div>');
			}
		} else if (_item.wxItemKind === 'page') {
			var totalP = (_item.wxVaultPages || 0) + (_item.wxStackPages || 1);
			var reqP = _item.wxPagesReq || 3;
			if (totalP >= reqP) {
				_slot.prepend('<div class="wx-item-slot-hl"></div>');
			}
			_slot.append('<div class="wx-item-slot-badge is-page">' + totalP + '/' + reqP + '</div>');
		}
	}

	if ($.fn && $.fn.assignListItemImage) {
		var origAssignListItemImg = $.fn.assignListItemImage;
		$.fn.assignListItemImage = function (_imagePath) {
			if (!_imagePath) {
				wxClearItemSlotBadge(this);
			}
			return origAssignListItemImg.apply(this, arguments);
		};
	}

	// ------------------------------------------------------------------------
	// 3. Character Screen Left Panel: Positive Qi Bar, 8 Stats & Level-Up
	// ------------------------------------------------------------------------
	var WX_STAT_ROW_LABELS = {
		hitpoints:    '气血',
		fatigue:      '内息',
		bravery:      '定力',
		initiative:   '身法',
		meleeSkill:   '武艺',
		rangeSkill:   '射艺',
		meleeDefense: '招架',
		rangeDefense: '避暗'
	};

	var WX_SLOT_MILESTONES = {
		3:  '3 级贯通穴位：轻功身法',
		5:  '5 级贯通穴位：横练杂学',
		7:  '7 级贯通穴位：进阶专精（外功 / 横练）',
		9:  '9 级贯通穴位：自由穴（可辅修第二门内功）',
		11: '11 级贯通穴位：宗师穴'
	};

	if (typeof CharacterScreenStatsModule !== 'undefined') {
		var origSetProgressbarValues = CharacterScreenStatsModule.prototype.setProgressbarValues;
		CharacterScreenStatsModule.prototype.setProgressbarValues = function (_data) {
			if (!_data || typeof ProgressbarValueIdentifier === 'undefined') {
				return origSetProgressbarValues.call(this, _data);
			}
			var d = $.extend({}, _data);
			var k = ProgressbarValueIdentifier;

			if ((k.Fatigue in d) && (k.FatigueMax in d) && d[k.FatigueMax] !== null) {
				var availQi = Math.max(0, d[k.FatigueMax] - d[k.Fatigue]);
				d[k.Fatigue] = availQi;
				d[k.FatigueLabel] = availQi + ' / ' + d[k.FatigueMax];
			}

			origSetProgressbarValues.call(this, d);
		};
	}

	if (typeof CharacterScreenLeftPanelHeaderModule !== 'undefined') {
		if (CharacterScreenLeftPanelHeaderModule.prototype.setLevelUpDialogContentProgressbarValue) {
			var origSetLvlBarVal = CharacterScreenLeftPanelHeaderModule.prototype.setLevelUpDialogContentProgressbarValue;
			CharacterScreenLeftPanelHeaderModule.prototype.setLevelUpDialogContentProgressbarValue = function (_progressbarDiv, _data, _valueKey, _valueMaxKey) {
				origSetLvlBarVal.call(this, _progressbarDiv, _data, _valueKey, _valueMaxKey);
				if (_progressbarDiv && (_valueKey in _data) && _data[_valueKey] !== null && (_valueKey in WX_STAT_ROW_LABELS)) {
					_progressbarDiv.changeProgressbarLabel(WX_STAT_ROW_LABELS[_valueKey] + ' ' + _data[_valueKey]);
				}
			};
		}

		if (CharacterScreenLeftPanelHeaderModule.prototype.createLevelUpDialogSubHeader) {
			var origCreateLvlSub = CharacterScreenLeftPanelHeaderModule.prototype.createLevelUpDialogSubHeader;
			CharacterScreenLeftPanelHeaderModule.prototype.createLevelUpDialogSubHeader = function () {
				var res = origCreateLvlSub.call(this);
				if (res && this.mDataSource && this.mDataSource.getSelectedBrother) {
					var sel = this.mDataSource.getSelectedBrother();
					var ch = (sel && typeof CharacterScreenIdentifier !== 'undefined' && (CharacterScreenIdentifier.Entity.Character.Key in sel))
						? sel[CharacterScreenIdentifier.Entity.Character.Key]
						: null;
					var curLv = (ch && (CharacterScreenIdentifier.Entity.Character.Level in ch)) ? ch[CharacterScreenIdentifier.Entity.Character.Level] : 0;
					var pendingUps = (ch && ('levelUp' in ch) && ch.levelUp && typeof ch.levelUp === 'object' && ('length' in ch.levelUp)) ? ch.levelUp.length : 1;
					var milestoneLv = (pendingUps > 1) ? (curLv - pendingUps + 1) : curLv;
					if (milestoneLv in WX_SLOT_MILESTONES) {
						res.append('<div class="wx-lvlup-slot-banner">' + WX_SLOT_MILESTONES[milestoneLv] + '</div>');
					}
				}
				return res;
			};
		}

		if (CharacterScreenLeftPanelHeaderModule.prototype.createDismissDialogContent) {
			var origCreateDismiss = CharacterScreenLeftPanelHeaderModule.prototype.createDismissDialogContent;
			CharacterScreenLeftPanelHeaderModule.prototype.createDismissDialogContent = function (_dialog) {
				var res = origCreateDismiss.call(this, _dialog);
				if (res) {
					wxUpgradeImagesIn(res);
					var desc = res.find('.font-color-description:first');
					if (desc.length) {
						desc.html(desc.html().split('战团').join('江湖义社').split('克朗').join('两纹银'));
					}
					var comp = res.find('label.blub:first');
					if (comp.length) {
						comp.html(comp.html().split('补偿金').join('遣散盘缠').split('赔偿金').join('遣散盘缠').split('克朗').join('两纹银'));
					}
				}
				return res;
			};
		}
	}

	if (typeof CharacterScreenInventoryListModule !== 'undefined' && CharacterScreenInventoryListModule.prototype.assignItemToSlot) {
		var origCharAssignSlot = CharacterScreenInventoryListModule.prototype.assignItemToSlot;
		CharacterScreenInventoryListModule.prototype.assignItemToSlot = function (_entityId, _owner, _slot, _item) {
			origCharAssignSlot.call(this, _entityId, _owner, _slot, _item);
			wxDecorateItemSlot(_slot, _item);
		};
	}

	// ------------------------------------------------------------------------
	// 4. Town Interior Screen: Leather Plaque Signboards (`wx-town-shop-sign`)
	// ------------------------------------------------------------------------
	var WX_BLDG_SIGN_LABELS = {
		'wx_bldg_crowd':         '招贤茶摊',
		'wx_bldg_marketplace':   '百货集市',
		'wx_bldg_tavern':        '迎客酒肆',
		'wx_bldg_temple':        '济世禅祠',
		'wx_bldg_weaponsmith':   '百炼铸剑坊',
		'wx_bldg_armorsmith':    '甲胄制革局',
		'wx_bldg_fletcher':      '神臂弓弩坊',
		'wx_bldg_training_hall': '讲武演武馆',
		'wx_bldg_taxidermist':   '百工炼丹房',
		'wx_bldg_alchemist':     '火器奇珍局',
		'wx_bldg_arena':         '生死演武擂',
		'wx_bldg_port':          '漕运官渡口',
		'wx_bldg_barber':        '梳篦修容铺',
		'wx_bldg_kennel':        '塞外驯犬坊'
	};

	function wxResolveBuildingSign(_src) {
		if (!_src || typeof _src !== 'string') return '';
		for (var stem in WX_BLDG_SIGN_LABELS) {
			if (WX_BLDG_SIGN_LABELS.hasOwnProperty(stem) && _src.indexOf(stem) !== -1) {
				return WX_BLDG_SIGN_LABELS[stem];
			}
		}
		return '';
	}

	if (typeof WorldTownScreenMainDialogModule !== 'undefined' && WorldTownScreenMainDialogModule.prototype.loadFromData) {
		var origTownMainLoad = WorldTownScreenMainDialogModule.prototype.loadFromData;
		WorldTownScreenMainDialogModule.prototype.loadFromData = function (_data) {
			origTownMainLoad.call(this, _data);
			if (!this.mContainer) return;
			wxUpgradeImagesIn(this.mContainer);

			var settlementBox = this.mContainer.find('.settlement-container:first');
			if (!settlementBox.length) return;
			settlementBox.find('.wx-town-shop-sign').remove();
			settlementBox.find('.wx-town-teahouse-btn').remove();

			var teaBtn = $(
				'<div class="wx-town-teahouse-btn" title="步入本城茶肆二楼雅座，拜会驻城宗门、地界行客与同道师门传人，设茗论交、拆招印证并直接请教本门真传秘籍">' +
					'<img src="coui://gfx/ui/wx_icons/wx_glyph_sect_token.png" alt="" />江湖茶肆' +
				'</div>'
			);
			teaBtn.on('click', function () {
				if (window.WX_OpenSectDirectory && window.WX_SectRPCHandle) {
					window.WX_OpenSectDirectory(window.WX_SectRPCHandle, null, 'teahouse');
				}
			});
			settlementBox.append(teaBtn);

			for (var sIdx = 0; sIdx <= 5; sIdx++) {
				(function (_idx) {
					var slotImgs = settlementBox.children('img.slot' + _idx).not('.no-pointer-events');
					if (!slotImgs.length) return;
					var el = slotImgs.first();
					var src = el.attr('src') || '';
					if (src.indexOf('wx_bldg_') === -1) return;
					var label = wxResolveBuildingSign(src);
					if (!label) return;
					var plaque = $('<div class="wx-town-shop-sign for-slot' + _idx + '">' + label + '</div>');
					settlementBox.append(plaque);
					el.on('mouseenter.wxSign', function () {
						plaque.addClass('is-hovered');
					});
					el.on('mouseleave.wxSign', function () {
						plaque.removeClass('is-hovered');
					});
				})(sIdx);
			}
		};
	}

	if (typeof WorldTownScreenTavernDialogModule !== 'undefined' && WorldTownScreenTavernDialogModule.prototype.createDIV) {
		var origTavernCreateDIV = WorldTownScreenTavernDialogModule.prototype.createDIV;
		WorldTownScreenTavernDialogModule.prototype.createDIV = function (_parentDiv) {
			origTavernCreateDIV.call(this, _parentDiv);
			if (this.mDialogContainer && !this.mDialogContainer.find('.wx-tavern-teahouse-btn').length) {
				var tTeaBtn = $(
					'<div class="wx-tavern-teahouse-btn" title="移步茶肆雅座拜会本城宗门与同道传人，设席论交或请教秘籍">' +
						'<img src="coui://gfx/ui/wx_icons/wx_glyph_sect_token.png" alt="" />赴茶肆拜会宗门' +
					'</div>'
				);
				tTeaBtn.on('click', function () {
					if (window.WX_OpenSectDirectory && window.WX_SectRPCHandle) {
						window.WX_OpenSectDirectory(window.WX_SectRPCHandle, null, 'teahouse');
					}
				});
				this.mDialogContainer.append(tTeaBtn);
			}
		};
	}

	// ------------------------------------------------------------------------
	// 5. World Event Scroll: Jianghu Header Banner & Cinnabar Chapter Seal
	// ------------------------------------------------------------------------
	function wxClassifyEventChapter(_title) {
		var t = String(_title || '');
		if (t.indexOf('茶') !== -1 || t.indexOf('择席') !== -1 || t.indexOf('请教') !== -1 || t.indexOf('拜师') !== -1) {
			return '江湖茶肆 · 宗门择席';
		}
		if (t.indexOf('鬼市') !== -1 || t.indexOf('拍卖') !== -1 || t.indexOf('竞拍') !== -1) {
			return '无常鬼市 · 暗拍秘宝';
		}
		if (t.indexOf('山海') !== -1 || t.indexOf('猎妖') !== -1 || t.indexOf('图志') !== -1 || t.indexOf('凶兽') !== -1) {
			return '大荒异志 · 山海秘闻';
		}
		if (t.indexOf('武林大会') !== -1 || t.indexOf('擂台') !== -1) {
			return '天下英雄 · 武林盛会';
		}
		if (t.indexOf('寻仇') !== -1 || t.indexOf('追缉') !== -1) {
			return '江湖恩怨 · 宗门寻仇';
		}
		if (t.indexOf('玄宫') !== -1 || t.indexOf('魔窟') !== -1 || t.indexOf('禁地') !== -1 || t.indexOf('秘境') !== -1) {
			return '凶险绝地 · 武林秘境';
		}
		return '江湖行旅 · 奇遇卷宗';
	}

	if (typeof WorldEventScreen !== 'undefined') {
		var origEvUpdateHeader = WorldEventScreen.prototype.updateHeader;
		WorldEventScreen.prototype.updateHeader = function (_data) {
			if (_data && typeof _data.title === 'string') {
				_data.title = wxHarmonizeTooltipText(_data.title);
			}
			origEvUpdateHeader.call(this, _data);
			if (this.mDialogContainer) {
				var hdrImg = this.mDialogContainer.findDialogHeaderImage();
				if (hdrImg && hdrImg.length) {
					var cur = hdrImg.attr('src') || '';
					if (cur.indexOf('wx_') === -1) {
						hdrImg.attr('src', 'coui://gfx/ui/wx_skin/wx_header_jianghu.png');
					}
				}
			}
			this.mWXCurrentEventTitle = (_data && _data.title) ? _data.title : '';
		};

		var origEvRenderContent = WorldEventScreen.prototype.renderContent;
		WorldEventScreen.prototype.renderContent = function (_data) {
			if (_data && jQuery.isArray(_data)) {
				for (var ci = 0; ci < _data.length; ci++) {
					var entry = _data[ci];
					if (!entry || typeof entry !== 'object') continue;
					if (typeof entry.text === 'string') {
						entry.text = wxHarmonizeTooltipText(entry.text);
					}
					if (typeof entry.title === 'string') {
						entry.title = wxHarmonizeTooltipText(entry.title);
					}
					if (entry.items && jQuery.isArray(entry.items)) {
						for (var ii = 0; ii < entry.items.length; ii++) {
							if (entry.items[ii] && typeof entry.items[ii].text === 'string') {
								entry.items[ii].text = wxHarmonizeTooltipText(entry.items[ii].text);
							}
						}
					}
				}
			} else if (_data && typeof _data === 'object') {
				if (typeof _data.text === 'string') {
					_data.text = wxHarmonizeTooltipText(_data.text);
				}
				if (_data.list && jQuery.isArray(_data.list)) {
					for (var li = 0; li < _data.list.length; li++) {
						if (_data.list[li] && typeof _data.list[li].text === 'string') {
							_data.list[li].text = wxHarmonizeTooltipText(_data.list[li].text);
						}
					}
				}
			}
			origEvRenderContent.call(this, _data);
			if (this.mContentContainer) {
				wxUpgradeImagesIn(this.mContentContainer);
				var chapter = wxClassifyEventChapter(this.mWXCurrentEventTitle);
				var seal = $(
					'<div class="wx-event-chapter-seal">' +
						'<img src="coui://gfx/ui/wx_icons/wx_seal_cinnabar.png" alt="" />' +
						wxEsc(chapter) +
					'</div>'
				);
				this.mContentContainer.prepend(seal);
			}
		};

		if (WorldEventScreen.prototype.renderButtons) {
			var origEvRenderBtns = WorldEventScreen.prototype.renderButtons;
			WorldEventScreen.prototype.renderButtons = function (_data, _hasBigButtons) {
				var btnList = jQuery.isArray(_data) ? _data : ((_data && jQuery.isArray(_data.buttons)) ? _data.buttons : null);
				if (btnList) {
					for (var bi = 0; bi < btnList.length; bi++) {
						if (btnList[bi] && typeof btnList[bi].text === 'string') {
							btnList[bi].text = wxHarmonizeTooltipText(btnList[bi].text);
						}
						if (btnList[bi] && typeof btnList[bi].tooltip === 'string') {
							btnList[bi].tooltip = wxHarmonizeTooltipText(btnList[bi].tooltip);
						}
					}
				}
				origEvRenderBtns.call(this, _data, _hasBigButtons);
			};
		}
	}

	// ------------------------------------------------------------------------
	// 6. Town Shop (市集/书肆/铁匠铺): Ownership Tags + Quick Sweep to 藏经阁
	// ------------------------------------------------------------------------
	if (typeof WorldTownScreenShopDialogModule !== 'undefined') {
		var origShopCreateDIV = WorldTownScreenShopDialogModule.prototype.createDIV;
		WorldTownScreenShopDialogModule.prototype.createDIV = function (_parentDiv) {
			var self = this;
			origShopCreateDIV.call(this, _parentDiv);
			wxUpgradeImagesIn(this.mContainer);

			var rightHdr = this.mContainer ? this.mContainer.find('.column.is-right > .row.is-header:first') : null;
			if (rightHdr && rightHdr.length) {
				rightHdr.text('商肆货架');
			}

			var midBtnBox = this.mContainer ? this.mContainer.find('.column.is-middle .button-container:first') : null;
			if (midBtnBox && midBtnBox.length && !midBtnBox.find('.wx-shop-sweep-btn').length) {
				var sweepBtn = $('<div class="wx-shop-sweep-btn" title="将仓库内购得或存留的秘籍与残页一键收入藏经阁">典籍入阁</div>');
				sweepBtn.on('click', function () {
					if (!self.mSQHandle) return;
					SQ.call(self.mSQHandle, 'onWXSweepShopManuals', null, function (_res) {
						if (_res && _res.ok) {
							if ('StashSpaceUsed' in _res) self.mStashSpaceUsed = _res.StashSpaceUsed;
							if ('StashSpaceMax' in _res)  self.mStashSpaceMax  = _res.StashSpaceMax;
							if ('Stash' in _res && _res.Stash !== null) {
								self.loadStashData(_res.Stash);
							}
							if (self.mShopSlots && self.mShopList) {
								self.assignItems(WorldTownScreenShop.ItemOwner.Shop, self.mShopList, self.mShopSlots, self.mShopListScrollContainer);
							}
							wxShowFloatingBanner(self.mDialogContainer, _res.actionMessage, _res.movedCount === 0);
						}
					});
				});
				midBtnBox.append(sweepBtn);
			}
		};

		var origShopAssignSlot = WorldTownScreenShopDialogModule.prototype.assignItemToSlot;
		WorldTownScreenShopDialogModule.prototype.assignItemToSlot = function (_owner, _slot, _item) {
			origShopAssignSlot.call(this, _owner, _slot, _item);
			wxDecorateItemSlot(_slot, _item);
		};
	}

	// ------------------------------------------------------------------------
	// 7. Town Taxidermist (百工丹坊 · 炼丹铸宝): Vanilla Button Category Filters
	// ------------------------------------------------------------------------
	function wxClassifyBlueprint(_bp) {
		var id = (_bp && _bp.ID) ? String(_bp.ID) : '';
		var nm = (_bp && _bp.Name) ? String(_bp.Name) : '';
		if (id.indexOf('shanhai') !== -1 ||
			id.indexOf('wx_bp_armor_') !== -1 || id.indexOf('wx_bp_helm_') !== -1 || id.indexOf('wx_bp_shd_') !== -1 || id.indexOf('wx_bp_acc_') !== -1 || id.indexOf('wx_bp_relic_') !== -1 ||
			id.indexOf('wx_armor_') !== -1 || id.indexOf('wx_helm_') !== -1 || id.indexOf('wx_shd_') !== -1 || id.indexOf('wx_acc_') !== -1 || id.indexOf('wx_relic_') !== -1) {
			return 'shanhai';
		}
		if (id.indexOf('wx_bp_beast_') !== -1 || id.indexOf('wx_bp_up_') !== -1 || id.indexOf('wx_beast_') !== -1 || id.indexOf('wx_up_') !== -1) {
			return 'craft';
		}
		if (id.indexOf('pill') !== -1 || nm.indexOf('丹') !== -1 || nm.indexOf('丸') !== -1 || nm.indexOf('散') !== -1 || nm.indexOf('膏') !== -1) {
			return 'pill';
		}
		return 'craft';
	}

	if (typeof WorldTownScreenTaxidermistDialogModule !== 'undefined') {
		var origTaxCreateDIV = WorldTownScreenTaxidermistDialogModule.prototype.createDIV;
		WorldTownScreenTaxidermistDialogModule.prototype.createDIV = function (_parentDiv) {
			var self = this;
			this.mWXCraftFilter = 'all';
			origTaxCreateDIV.call(this, _parentDiv);
			wxUpgradeImagesIn(this.mContainer);

			if (this.mDetailsPanel && this.mDetailsPanel.CraftButton) {
				this.mDetailsPanel.CraftButton.changeButtonText('开炉炼制');
			}
			if (this.mNoCraftablesLabel && this.mNoCraftablesLabel.length) {
				this.mNoCraftablesLabel.text('行囊尚无异兽奇材或山海内丹，讨伐山泽异兽与秘境大妖即可开炉炼丹铸宝。');
			}

			var leftCol = this.mContainer ? this.mContainer.find('.column.is-left:first') : null;
			if (leftCol && leftCol.length && !leftCol.find('.wx-craft-filter-bar').length) {
				var fBar = $(
					'<div class="wx-craft-filter-bar">' +
						'<span class="wx-cflt-btn is-active" data-cflt="all">全部配方</span>' +
						'<span class="wx-cflt-btn" data-cflt="pill">灵丹妙药</span>' +
						'<span class="wx-cflt-btn" data-cflt="shanhai">山海神装</span>' +
						'<span class="wx-cflt-btn" data-cflt="craft">百工奇物</span>' +
					'</div>'
				);
				fBar.find('[data-cflt]').on('click', function () {
					self.mWXCraftFilter = $(this).attr('data-cflt');
					fBar.find('[data-cflt]').removeClass('is-active');
					$(this).addClass('is-active');
					self.wxApplyBlueprintFilter();
				});
				leftCol.prepend(fBar);
				leftCol.addClass('has-wx-craft-filters');
			}
		};

		WorldTownScreenTaxidermistDialogModule.prototype.wxApplyBlueprintFilter = function () {
			if (!this.mListScrollContainer || !this.mBlueprints) return;
			this.mListScrollContainer.empty();
			var shown = 0;
			var flt = this.mWXCraftFilter || 'all';
			for (var i = 0; i < this.mBlueprints.length; i++) {
				var bp = this.mBlueprints[i];
				if (flt !== 'all' && wxClassifyBlueprint(bp) !== flt) continue;
				this.addListEntry(bp);
				shown++;
			}
			if (this.mNoCraftablesLabel) {
				this.mNoCraftablesLabel.toggleClass('display-none', shown > 0);
			}
			if (shown > 0) {
				this.selectListEntry(this.mListContainer.findListEntryByIndex(0), true);
			} else {
				this.selectListEntry(null);
			}
		};

		var origTaxLoadData = WorldTownScreenTaxidermistDialogModule.prototype.loadFromData;
		WorldTownScreenTaxidermistDialogModule.prototype.loadFromData = function (_data) {
			origTaxLoadData.call(this, _data);
			if (_data && (!_data.Title || _data.Title.indexOf('剥制') !== -1)) {
				this.mDialogContainer.findDialogTitle().html('百工丹坊');
			}
			if (this.mWXCraftFilter && this.mWXCraftFilter !== 'all') {
				this.wxApplyBlueprintFilter();
			}
		};
	}

	// ------------------------------------------------------------------------
	// 8. Post-Battle Combat Result & Loot Screen + Obituary (忠义英魂录)
	// ------------------------------------------------------------------------
	if (typeof TacticalCombatResultScreen !== 'undefined') {
		var origResCreateDIV = TacticalCombatResultScreen.prototype.createDIV;
		TacticalCombatResultScreen.prototype.createDIV = function (_parentDiv) {
			origResCreateDIV.call(this, _parentDiv);
			wxUpgradeImagesIn(this.mContainer);
			if (this.mSwitchToStatisticsButton) {
				this.mSwitchToStatisticsButton.find('.label:first').html('战功名录');
			}
			if (this.mSwitchToLootButton) {
				this.mSwitchToLootButton.find('.label:first').html('缴获战利');
			}
		};
	}

	if (typeof TacticalCombatResultScreenDatasource !== 'undefined' && TacticalCombatResultScreenDatasource.prototype.loadFromData) {
		var origResDsLoad = TacticalCombatResultScreenDatasource.prototype.loadFromData;
		TacticalCombatResultScreenDatasource.prototype.loadFromData = function (_data, _withoutNotify) {
			origResDsLoad.call(this, _data, _withoutNotify);
			if (_data && _data.wxSweepMessage) {
				var dlg = $('.tactical-combat-result-screen .ui-control.dialog:first');
				wxShowFloatingBanner(dlg, _data.wxSweepMessage, false);
			}
		};
	}

	if (typeof TacticalCombatResultScreenLootPanel !== 'undefined') {
		var origLootCreateDIV = TacticalCombatResultScreenLootPanel.prototype.createDIV;
		TacticalCombatResultScreenLootPanel.prototype.createDIV = function (_parentDiv) {
			var self = this;
			origLootCreateDIV.call(this, _parentDiv);
			wxUpgradeImagesIn(this.mContainer);

			var midContent = this.mContainer ? this.mContainer.find('.column.is-middle .row.is-content:first') : null;
			if (midContent && midContent.length && !midContent.find('.wx-loot-sweep-btn').length) {
				var lootSweepBtn = $('<div class="wx-loot-sweep-btn" title="将战利品与仓库中的秘籍、残页直接归入藏经阁">典籍入阁</div>');
				lootSweepBtn.on('click', function () {
					if (!self.mDataSource || !self.mDataSource.mSQHandle) return;
					SQ.call(self.mDataSource.mSQHandle, 'onWXSweepCombatLootManuals', null, function (_res) {
						if (_res && _res.ok) {
							self.mDataSource.loadFromData(_res);
							var dlg = $('.tactical-combat-result-screen .ui-control.dialog:first');
							wxShowFloatingBanner(dlg, _res.wxSweepMessage, _res.movedCount === 0);
						}
					});
				});
				midContent.append(lootSweepBtn);
			}
		};

		var origLootAssignSlot = TacticalCombatResultScreenLootPanel.prototype.assignItemToSlot;
		TacticalCombatResultScreenLootPanel.prototype.assignItemToSlot = function (_owner, _slot, _item) {
			origLootAssignSlot.call(this, _owner, _slot, _item);
			wxDecorateItemSlot(_slot, _item);
		};
	}

	if (typeof WorldObituaryScreen !== 'undefined') {
		var origObitCreateDIV = WorldObituaryScreen.prototype.createDIV;
		WorldObituaryScreen.prototype.createDIV = function (_parentDiv) {
			origObitCreateDIV.call(this, _parentDiv);
			if (this.mDialogContainer) {
				this.mDialogContainer.findDialogTitle().html('忠义英魂录');
			}
			if (this.mColumnName)     this.mColumnName.html('侠名');
			if (this.mColumnTime)     this.mColumnTime.html('同行日');
			if (this.mColumnBattles)  this.mColumnBattles.html('历战');
			if (this.mColumnKills)    this.mColumnKills.html('斩敌');
			if (this.mColumnKilledBy) this.mColumnKilledBy.html('陨落之由');
		};

		var origObitLoad = WorldObituaryScreen.prototype.loadFromData;
		WorldObituaryScreen.prototype.loadFromData = function (_data) {
			origObitLoad.call(this, _data);
			if (_data && _data.Fallen && this.mDialogContainer) {
				if (_data.Fallen.length === 0) {
					this.mDialogContainer.findDialogSubTitle().text('自竖旗闯荡江湖以来，尚无同袍马革裹尸');
				} else {
					this.mDialogContainer.findDialogSubTitle().text('已有 ' + _data.Fallen.length + ' 位江湖同道喋血沙场，英名长存');
				}
			}
		};
	}

	// ------------------------------------------------------------------------
	// 9. 44-Sect Jianghu Directory & Interactive Town Tea-House (`江湖茶肆 · 宗门雅座`)
	// ------------------------------------------------------------------------
	var wxSectModalState = {
		region: 'all',
		vendettaOnly: false,
		query: '',
		selectedId: null,
		data: null,
		sqHandle: null,
		popupHostDS: null
	};

	function wxFormatCommaMoney(_n) {
		var s = String(Math.max(0, parseInt(_n, 10) || 0));
		return s.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
	}

	function wxSyncWorldAndTownMoney(_money) {
		if (typeof _money !== 'number') return;
		var fmt = wxFormatCommaMoney(_money);
		$('.world-town-screen .asset-container.is-money .label, .world-screen .asset-container.is-money .label').text(fmt);
		$('.wx-sect-money-badge span').text(fmt);
	}

	function wxShowSectToast(_dlg, _msg, _isErr) {
		if (!_dlg || !_dlg.length || !_msg) return;
		_dlg.find('.wx-sect-toast').remove();
		var t = $('<div class="wx-sect-toast' + (_isErr ? ' is-err' : '') + '">' + wxEsc(_msg) + '</div>');
		_dlg.append(t);
		setTimeout(function () {
			t.fadeOut(280, function () { t.remove(); });
		}, 3800);
	}

	function wxCloseSectDirectory() {
		var existing = $('.wx-sect-backdrop');
		if (existing.length) {
			existing.remove();
			$(document).off('keydown.wxSectModal');
			if (wxSectModalState.popupHostDS && wxSectModalState.popupHostDS.notifyBackendPopupDialogIsVisible) {
				wxSectModalState.popupHostDS.notifyBackendPopupDialogIsVisible(false);
			}
			wxSectModalState.popupHostDS = null;
		}
	}

	function wxRenderSectDetail(_pane, _s, _payload, _onActionDone) {
		if (!_s) {
			_pane.html('<div style="padding:2rem 0;color:#bd9d71;font-style:italic;text-align:center;">左键点击左侧宗门查阅渊源、驻地山门、交情与传承秘籍</div>');
			return;
		}
		var localRegion = _payload ? _payload.localRegion : '';
		var inTown = !!(_payload && _payload.inTown);
		var curMoney = (_payload && typeof _payload.money === 'number') ? _payload.money : 0;
		var relCls = _s.relation > 0 ? 'is-pos' : (_s.relation < 0 ? 'is-neg' : 'is-neu');
		var relSign = _s.relation > 0 ? ('+' + _s.relation) : String(_s.relation);
		var isLoc = (_s.region === localRegion);

		var metaParts = [wxEsc(_s.regionLabel) + (isLoc ? '（当前地界）' : ''), wxEsc(_s.alignmentLabel)];
		if (_s.isVendetta) {
			metaParts.push('<span style="color:#CD2626;font-style:normal;">寻仇追缉中</span>');
		}

		var anchorLine = '';
		if (_s.anchorTownName) {
			var dirStr = _s.anchorDir ? (_s.anchorDir + (_s.anchorDist >= 0 ? (' · ' + _s.anchorDist + ' 格') : '')) : '';
			anchorLine = '驻地城池：<span style="color:#ffe28a;">【' + wxEsc(_s.anchorTownName) + '】</span>' +
				(dirStr ? (' <span style="color:#bd9d71;">（' + wxEsc(dirStr) + '）</span>') : '') + '<br/>';
		}

		var seatHtml = _s.isSeatedInTown
			? ('<span class="wx-sect-seat-pill">' + wxEsc(_s.seatBadge || '茶肆在座') + '</span>')
			: '';

		var html =
			'<div class="wx-t-title" style="font-size:2.0rem;line-height:2.6rem;">' + wxEsc(_s.name) + seatHtml + '</div>' +
			'<div style="font-size:1.35rem;color:#bd9d71;font-style:italic;margin-bottom:0.5rem;">' + metaParts.join(' · ') + '</div>' +
			'<div class="wx-sect-gold-line"></div>' +
			'<div style="font-size:1.35rem;line-height:1.95rem;color:#bd9d71;font-style:italic;margin-bottom:0.65rem;">' + wxEsc(_s.description) + '</div>' +
			'<div style="font-size:1.38rem;line-height:2.0rem;margin-bottom:0.65rem;">' +
				anchorLine +
				'当前交情：<span class="wx-sect-rel-num ' + relCls + '" style="float:none;">' + relSign + ' · ' + wxEsc(_s.statusLabel) + '</span><br/>' +
				'寻仇红线：<span style="color:#CD2626;">&le; ' + _s.vendettaRel + '</span> <span style="color:#bd9d71;font-style:italic;">（交情 &ge;25 可凭飞鸽传书在各城茶肆约见）</span>' +
			'</div>';

		if (inTown && _s.isSeatedInTown) {
			var banqDisabled = (_s.banquetCd > 0 || curMoney < 350) ? ' is-disabled' : '';
			var banqLbl = (_s.banquetCd > 0)
				? ('设茗款待(隔' + _s.banquetCd + '日)')
				: '设茗款待(350两 · 交情+15)';
			var sparDisabled = (_s.sparCd > 0) ? ' is-disabled' : '';
			var sparLbl = (_s.sparCd > 0)
				? ('拆招印证(隔' + _s.sparCd + '日)')
				: '拆招印证(交情+12 · 历练)';

			html +=
				'<div class="wx-tea-actions">' +
					'<div style="font-size:1.3rem;color:#ffe28a;margin-bottom:0.35rem;">【' + wxEsc(_payload.townName) + ' · 江湖茶肆】传人雅座</div>' +
					'<span class="wx-tea-btn' + banqDisabled + '" data-tea-op="banquet">' + wxEsc(banqLbl) + '</span>' +
					'<span class="wx-tea-btn' + sparDisabled + '" data-tea-op="spar">' + wxEsc(sparLbl) + '</span>' +
					'<span class="wx-tea-btn is-danger" data-tea-op="offend">撕毁门帖(-35)</span>' +
				'</div>';
		} else if (inTown && !_s.isSeatedInTown) {
			html +=
				'<div class="wx-tea-actions" style="font-size:1.28rem;color:#bd9d71;font-style:italic;">' +
					'该宗门传人今日未在此城落座。可前往驻地【' + wxEsc(_s.anchorTownName || '本门山门') + '】茶肆拜会；若交情达 25 以上，在任意城池茶肆皆可飞鸽约见。' +
				'</div>';
		}

		html += '<div style="font-size:1.5rem;color:#dda21f;margin-bottom:0.4rem;">独门藏书（' + _s.manuals.length + ' 部）</div>';

		if (_s.manuals.length === 0) {
			html += '<div style="color:#bd9d71;font-style:italic;">该宗门暂无对外传授之秘籍。</div>';
		} else {
			for (var i = 0; i < _s.manuals.length; i++) {
				var m = _s.manuals[i];
				var reqStr = m.unlocked
					? '<span style="color:#dda21f;">交情达标(&ge;' + m.minRel + ')</span>'
					: '<span style="color:#CD2626;">需交情 &ge;' + m.minRel + '</span>';

				var ownBadge = '';
				if ((m.vaultBooks || 0) <= 0 && (m.learnedCount || 0) <= 0) {
					ownBadge = '<span class="wx-sect-own-tag is-new">未收录</span>';
				} else {
					var parts = [];
					if (m.vaultBooks > 0) parts.push('阁藏 ' + m.vaultBooks);
					if (m.learnedCount > 0) parts.push('已习 ' + m.learnedCount + ' 人');
					ownBadge = '<span class="wx-sect-own-tag">' + parts.join(' · ') + '</span>';
				}

				var buyHtml = '';
				if (inTown && _s.isSeatedInTown) {
					var canBuy = m.unlocked && curMoney >= m.price;
					var buyTip = !m.unlocked ? '交情未达' : (curMoney < m.price ? '银两不足' : '奉上束脩请教秘籍');
					buyHtml = '<span class="wx-tea-buy-btn' + (canBuy ? '' : ' is-disabled') + '" data-buy-mid="' + m.id + '" title="' + wxEsc(buyTip) + '">' +
						(canBuy ? '奉脩请教' : buyTip) + '</span>';
				}

				html +=
					'<div class="wx-sect-manual-item">' +
						'<div><span style="color:#dda21f;">《' + wxEsc(m.name) + '》</span>' + ownBadge + '</div>' +
						'<div style="font-size:1.3rem;color:#bd9d71;">' +
							wxEsc(m.qualityLabel) + ' · ' + wxEsc(m.categoryLabel) + '　' + reqStr + '　束脩 ' + m.price + ' 两' + buyHtml +
							'<div class="clear-both"></div>' +
						'</div>' +
					'</div>';
			}
		}
		_pane.html(html);

		if (inTown && _s.isSeatedInTown && wxSectModalState.sqHandle) {
			_pane.find('[data-tea-op="banquet"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXTeaHouseBanquet', [_s.id], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-tea-op="spar"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXTeaHouseSpar', [_s.id, 'spar'], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-tea-op="offend"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXTeaHouseSpar', [_s.id, 'offend'], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-buy-mid]').on('click', function () {
				var mid = $(this).attr('data-buy-mid');
				if (!mid) return;
				SQ.call(wxSectModalState.sqHandle, 'onWXTeaHouseBuyManual', [_s.id, mid], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
		}
	}

	function wxRenderSectModalDOM(_payload, _optionalDS, _initialFilter) {
		wxCloseSectDirectory();
		wxSectModalState.data = _payload;
		wxSectModalState.popupHostDS = _optionalDS || null;
		if (wxSectModalState.popupHostDS && wxSectModalState.popupHostDS.notifyBackendPopupDialogIsVisible) {
			wxSectModalState.popupHostDS.notifyBackendPopupDialogIsVisible(true);
		}

		var host = $('.root-screen:first');
		if (!host.length) host = $(document.body);

		var startRegion = (_initialFilter === 'teahouse' && _payload.inTown) ? 'teahouse' : 'all';
		wxSectModalState.region = startRegion;
		wxSectModalState.vendettaOnly = false;
		wxSectModalState.query = '';

		var regBtnsHtml = '';
		if (_payload.inTown) {
			regBtnsHtml += '<span class="wx-sect-tab' + (startRegion === 'teahouse' ? ' is-active' : '') + '" data-sreg="teahouse">本城茶肆(' + (_payload.townSeatedCount || 0) + ')</span>';
		}
		regBtnsHtml += '<span class="wx-sect-tab' + (startRegion === 'all' ? ' is-active' : '') + '" data-sreg="all">九州(' + _payload.sects.length + ')</span>';
		for (var r = 0; r < _payload.regions.length; r++) {
			var rg = _payload.regions[r];
			var isHere = (rg.id === _payload.localRegion);
			regBtnsHtml += '<span class="wx-sect-tab" data-sreg="' + rg.id + '">' + wxEsc(rg.label) + (isHere ? '★' : '') + '</span>';
		}

		var hdrTitle = _payload.inTown
			? ('【' + wxEsc(_payload.townName) + ' · 江湖茶肆】宗门雅座与名刺录')
			: '江湖四十四宗门 · 九州山门与名刺录';
		var moneyBadgeHtml = (typeof _payload.money === 'number')
			? ('<div class="wx-sect-money-badge">纹银：<span>' + wxFormatCommaMoney(_payload.money) + '</span> 两</div>')
			: '';

		var backdrop = $(
			'<div class="wx-sect-backdrop">' +
				'<div class="wx-sect-dialog">' +
					'<div class="wx-sect-hdr">' +
						'<div class="wx-sect-hdr-title"><img src="coui://gfx/ui/wx_icons/wx_glyph_sect_token.png" alt=""/>' + hdrTitle + '</div>' +
						moneyBadgeHtml +
						'<div class="wx-sect-hdr-close" data-sect-act="close" title="关闭"><img src="coui://gfx/ui/skin/icon_cross.png" alt=""/></div>' +
					'</div>' +
					'<div class="wx-sect-gold-line"></div>' +
					'<div class="wx-sect-toolbar">' +
						regBtnsHtml +
						'<span class="wx-sect-tab" data-sect-act="vendetta">结仇</span>' +
						'<input type="text" class="wx-sect-search" data-sect-act="search" placeholder="搜门派 / 驻地 / 秘籍" />' +
					'</div>' +
					'<div class="wx-sect-body">' +
						'<div class="wx-sect-list-pane" data-sect="list"></div>' +
						'<div class="wx-sect-detail-pane" data-sect="detail"></div>' +
					'</div>' +
					'<div class="wx-sect-foot">' +
						'<span class="wx-sect-foot-btn" data-sect-act="close">关闭</span>' +
					'</div>' +
				'</div>' +
			'</div>'
		);

		host.append(backdrop);

		var dialogBox = backdrop.find('.wx-sect-dialog:first');
		var listPane = backdrop.find('[data-sect="list"]');
		var detailPane = backdrop.find('[data-sect="detail"]');

		function handleActionResponse(_res) {
			if (!_res) return;
			if (!_res.ok) {
				wxShowSectToast(dialogBox, _res.reason || '无法执行该操作。', true);
				return;
			}
			_payload = _res;
			wxSectModalState.data = _res;
			wxSyncWorldAndTownMoney(_res.money);
			if (_res.inTown) {
				backdrop.find('[data-sreg="teahouse"]').text('本城茶肆(' + (_res.townSeatedCount || 0) + ')');
			}
			refreshList();
			if (_res.actionMessage) {
				wxShowSectToast(dialogBox, _res.actionMessage, false);
			}
		}

		function refreshList() {
			listPane.empty();
			var sects = _payload.sects || [];
			var firstMatch = null;
			var selObj = null;

			for (var i = 0; i < sects.length; i++) {
				var s = sects[i];
				if (wxSectModalState.region === 'teahouse') {
					if (!s.isSeatedInTown) continue;
				} else if (wxSectModalState.region !== 'all' && s.region !== wxSectModalState.region) {
					continue;
				}
				if (wxSectModalState.vendettaOnly && !s.isVendetta && s.relation > -15) continue;
				if (wxSectModalState.query) {
					var hay = (s.name + ' ' + s.regionLabel + ' ' + (s.anchorTownName || '') + ' ' + s.description).toLowerCase();
					for (var m = 0; m < s.manuals.length; m++) {
						hay += ' ' + s.manuals[m].name.toLowerCase();
					}
					if (hay.indexOf(wxSectModalState.query) === -1) continue;
				}

				if (!firstMatch) firstMatch = s;
				if (s.id === wxSectModalState.selectedId) selObj = s;

				var relCls = s.relation > 0 ? 'is-pos' : (s.relation < 0 ? 'is-neg' : 'is-neu');
				var relStr = (s.relation > 0 ? ('+' + s.relation) : String(s.relation)) + ' · ' + s.statusLabel;
				var subParts = [];
				if (s.isSeatedInTown) {
					subParts.push('<span style="color:#ffe28a;font-style:normal;">[' + wxEsc(s.seatBadge || '茶肆在座') + ']</span>');
				}
				if (s.anchorTownName) {
					var distTail = (s.anchorDist > 0 && s.anchorDir) ? ('(' + wxEsc(s.anchorDir) + s.anchorDist + '格)') : '';
					subParts.push('驻地:' + wxEsc(s.anchorTownName) + distTail);
				} else {
					subParts.push(wxEsc(s.regionLabel));
				}
				if (s.isVendetta) subParts.push('<span style="color:#CD2626;font-style:normal;">寻仇追缉</span>');
				subParts.push(wxEsc(s.alignmentLabel));
				subParts.push('藏书 ' + s.manuals.length + ' 部');

				var row = $(
					'<div class="wx-sect-row" data-sid="' + s.id + '">' +
						'<div class="wx-sect-row-top">' +
							'<span class="wx-sect-name">' + wxEsc(s.name) + '</span>' +
							'<span class="wx-sect-rel-num ' + relCls + '">' + wxEsc(relStr) + '</span>' +
							'<div class="clear-both"></div>' +
						'</div>' +
						'<div class="wx-sect-row-sub">' + subParts.join(' · ') + '</div>' +
					'</div>'
				);

				(function (_sect) {
					row.on('click', function () {
						wxSectModalState.selectedId = _sect.id;
						listPane.find('.wx-sect-row').removeClass('is-selected');
						$(this).addClass('is-selected');
						wxRenderSectDetail(detailPane, _sect, _payload, handleActionResponse);
					});
				})(s);

				listPane.append(row);
			}

			var active = selObj || firstMatch;
			if (active) {
				wxSectModalState.selectedId = active.id;
				listPane.find('[data-sid="' + active.id + '"]').addClass('is-selected');
				wxRenderSectDetail(detailPane, active, _payload, handleActionResponse);
			} else {
				listPane.append('<div style="padding:3rem 1rem;color:#bd9d71;font-style:italic;text-align:center;">没有符合筛选条件的江湖宗门</div>');
				wxRenderSectDetail(detailPane, null, _payload, handleActionResponse);
			}
		}

		backdrop.find('[data-sreg]').on('click', function () {
			wxSectModalState.region = $(this).attr('data-sreg');
			backdrop.find('[data-sreg]').removeClass('is-active');
			$(this).addClass('is-active');
			refreshList();
		});

		backdrop.find('[data-sect-act="vendetta"]').on('click', function () {
			wxSectModalState.vendettaOnly = !wxSectModalState.vendettaOnly;
			$(this).toggleClass('is-active', wxSectModalState.vendettaOnly);
			refreshList();
		});

		var sInput = backdrop.find('[data-sect-act="search"]');
		sInput.on('keydown keyup keypress', function (_e) {
			if (_e.keyCode === 27) {
				wxCloseSectDirectory();
				return false;
			}
			_e.stopPropagation();
		});
		sInput.on('keyup change input', function () {
			var raw = $(this).val() || '';
			wxSectModalState.query = raw.replace(/^\s+|\s+$/g, '').toLowerCase();
			refreshList();
		});

		$(document).on('keydown.wxSectModal', function (_e) {
			if (_e.keyCode === 27) {
				wxCloseSectDirectory();
				_e.stopPropagation();
				return false;
			}
		});

		backdrop.find('[data-sect-act="close"]').on('click', function () {
			wxCloseSectDirectory();
		});
		backdrop.on('click', function (_e) {
			if ($(_e.target).hasClass('wx-sect-backdrop')) {
				wxCloseSectDirectory();
			}
		});

		refreshList();
	}

	window.WX_OpenSectDirectory = function (_sqHandle, _optionalDS, _initialFilter) {
		var h = _sqHandle || window.WX_SectRPCHandle;
		if (!h) return;
		window.WX_SectRPCHandle = h;
		wxSectModalState.sqHandle = h;
		SQ.call(h, 'onWXGetSectRelations', null, function (_res) {
			if (_res && _res.ok) {
				wxRenderSectModalDOM(_res, _optionalDS, _initialFilter);
			}
		});
	};

	if (typeof WorldScreenTopbarOptionsModule !== 'undefined') {
		if (WorldScreenTopbarOptionsModule.prototype.onConnection) {
			var origWorldOptConn = WorldScreenTopbarOptionsModule.prototype.onConnection;
			WorldScreenTopbarOptionsModule.prototype.onConnection = function (_handle) {
				origWorldOptConn.call(this, _handle);
				if (_handle) window.WX_SectRPCHandle = _handle;
			};
		}
		var origWorldOptCreate = WorldScreenTopbarOptionsModule.prototype.createDIV;
		WorldScreenTopbarOptionsModule.prototype.createDIV = function (_parentDiv) {
			var self = this;
			origWorldOptCreate.call(this, _parentDiv);
			wxUpgradeImagesIn(this.mContainer);
			if (this.mSQHandle !== null) window.WX_SectRPCHandle = this.mSQHandle;

			if (this.mContainer && !this.mContainer.find('.wx-world-sect-btn').length) {
				var sectBtn = $(
					'<div class="wx-world-sect-btn" title="查阅九州四十四大江湖门派山门驻地、交情与独门秘籍">' +
						'<img src="coui://gfx/ui/wx_icons/wx_glyph_sect_token.png" alt="" />江湖名刺' +
					'</div>'
				);
				sectBtn.on('click', function () {
					if (self.mSQHandle !== null && window.WX_OpenSectDirectory) {
						window.WX_OpenSectDirectory(self.mSQHandle, null, 'all');
					}
				});
				this.mContainer.append(sectBtn);
			}
		};
	}

	if (typeof WorldRelationsScreen !== 'undefined') {
		var origRelCreateDIV = WorldRelationsScreen.prototype.createDIV;
		WorldRelationsScreen.prototype.createDIV = function (_parentDiv) {
			var self = this;
			origRelCreateDIV.call(this, _parentDiv);
			wxUpgradeImagesIn(this.mContainer);

			if (this.mDialogContainer) {
				this.mDialogContainer.findDialogTitle().html('朝堂藩镇与江湖宗门');
				var tabBar = this.mDialogContainer.findDialogTabContainer().find('.l-tab-container:first');
				if (tabBar.length && !tabBar.find('.wx-rel-sect-btn').length) {
					var relSectBtn = $(
						'<div class="wx-rel-sect-btn" title="查阅九州四十四大江湖门派山门驻地、交情与传承秘籍">' +
							'<img src="coui://gfx/ui/wx_icons/wx_glyph_sect_token.png" alt="" />江湖宗门名刺' +
						'</div>'
					);
					relSectBtn.on('click', function () {
						if (self.mSQHandle !== null && window.WX_OpenSectDirectory) {
							window.WX_OpenSectDirectory(self.mSQHandle, null, 'all');
						}
					});
					tabBar.append(relSectBtn);
				}
			}
		};
	}

	if (typeof WorldScreenTopbarAssetsModule !== 'undefined') {
		var origWorldAssetsCreate = WorldScreenTopbarAssetsModule.prototype.createDIV;
		WorldScreenTopbarAssetsModule.prototype.createDIV = function (_parentDiv) {
			origWorldAssetsCreate.call(this, _parentDiv);
			wxUpgradeImagesIn(this.mContainer);
		};
	}

	// ------------------------------------------------------------------------
	// 10. New Campaign Screen Overhaul (Origins / Banners / Settings)
	// ------------------------------------------------------------------------
	var WX_DEFAULT_COMPANY_NAMES = [
		'长风义社', '听雨剑庐', '威远镖行', '神州侠隐社', '山河聚义堂', '沧海行营', '太行义从', '玄甲游侠社'
	];

	function wxFilterWuxiaBanners(_arr) {
		if (!_arr || !jQuery.isArray(_arr)) return _arr;
		var out = [];
		var i;
		for (i = 0; i < _arr.length; i++) {
			var b = String(_arr[i] || '');
			if (b.indexOf('banner_5') === 0 || b.indexOf('banner_6') === 0) {
				out.push(b);
			}
		}
		return out.length > 0 ? out : _arr;
	}

	function wxApplyNewCampaignOverhaul(_mod) {
		if (!_mod || !_mod.mContainer) return;

		if (_mod.mDialogContainer && _mod.mDialogContainer.findDialogTitle) {
			_mod.mDialogContainer.findDialogTitle().html('开山立社 · 新闯江湖');
		}
		if (_mod.mOriginSelectionPanel) {
			_mod.mOriginSelectionPanel.find('.title:first').html('江湖出身流派');
		}
		if (_mod.mCompanyCrisisSelectionPanel) {
			var cTitles = _mod.mCompanyCrisisSelectionPanel.find('.column:first .title');
			if (cTitles.length >= 1) $(cTitles[0]).html('义社名号');
			if (cTitles.length >= 2) $(cTitles[1]).html('武林大势（中后期浩劫）');
		}
		if (_mod.mCompanyName && typeof _mod.mCompanyName.getInputText === 'function') {
			var curName = _mod.mCompanyName.getInputText();
			if (!curName || curName === '战场兄弟' || curName === 'Battle Brothers') {
				var pick = WX_DEFAULT_COMPANY_NAMES[Math.floor(Math.random() * WX_DEFAULT_COMPANY_NAMES.length)];
				_mod.mCompanyName.setInputText(pick);
			}
		}

		if (_mod.mEvilRandomLabel)               _mod.mEvilRandomLabel.html('天机莫测（随机大势）');
		if (_mod.mEvilWarLabel)                  _mod.mEvilWarLabel.html('藩镇节度争霸');
		if (_mod.mEvilGreenskinsLabel)           _mod.mEvilGreenskinsLabel.html('南疆五毒与药人犯境');
		if (_mod.mEvilUndeadLabel)               _mod.mEvilUndeadLabel.html('前朝玄宫尸傀浩劫');
		if (_mod.mEvilCrusadeLabel)              _mod.mEvilCrusadeLabel.html('西域都护与中原兵燹');
		if (_mod.mEvilPermanentDestructionLabel) _mod.mEvilPermanentDestructionLabel.html('兵燹焦土（州县可被永久焚毁）');

		if (_mod.mDifficultySelectionPanel) {
			var lTitles = _mod.mDifficultySelectionPanel.find('.column:first .title');
			if (lTitles.length >= 1) $(lTitles[0]).html('行商生计难度');
			if (lTitles.length >= 2) $(lTitles[1]).html('起家盘缠');
			if (lTitles.length >= 3) $(lTitles[2]).html('山河气运种子');
			var rTitles = _mod.mDifficultySelectionPanel.find('.column:eq(1) .title');
			if (rTitles.length >= 1) $(rTitles[0]).html('江湖凶险难度');
			if (rTitles.length >= 2) $(rTitles[1]).html('生死无悔模式');
		}

		if (_mod.mEconomicDifficultyEasyLabel)   _mod.mEconomicDifficultyEasyLabel.html('宽裕（初涉江湖）');
		if (_mod.mEconomicDifficultyNormalLabel) _mod.mEconomicDifficultyNormalLabel.html('常道（百业维艰）');
		if (_mod.mEconomicDifficultyHardLabel)   _mod.mEconomicDifficultyHardLabel.html('窘迫（乱世米贵）');

		if (_mod.mBudgetDifficultyEasyLabel)     _mod.mBudgetDifficultyEasyLabel.html('丰厚盘缠');
		if (_mod.mBudgetDifficultyNormalLabel)   _mod.mBudgetDifficultyNormalLabel.html('寻常盘缠');
		if (_mod.mBudgetDifficultyHardLabel)     _mod.mBudgetDifficultyHardLabel.html('囊中羞涩');

		if (_mod.mDifficultyEasyLabel)           _mod.mDifficultyEasyLabel.html('初窥门径');
		if (_mod.mDifficultyNormalLabel)         _mod.mDifficultyNormalLabel.html('刀口舔血');
		if (_mod.mDifficultyHardLabel)           _mod.mDifficultyHardLabel.html('九死一生');

		if (_mod.mIronmanCheckboxLabel)          _mod.mIronmanCheckboxLabel.html('生死无悔（铁人单档 · 落子无悔）');
		if (_mod.mExplorationCheckboxLabel)      _mod.mExplorationCheckboxLabel.html('迷雾山河（舆图未探）');

		if (_mod.mBanners && jQuery.isArray(_mod.mBanners)) {
			var filtered = wxFilterWuxiaBanners(_mod.mBanners);
			if (filtered.length > 0 && filtered.length !== _mod.mBanners.length) {
				_mod.mBanners = filtered;
				_mod.mCurrentBannerIndex = Math.floor(Math.random() * filtered.length);
				if (_mod.mBannerImage && typeof Path !== 'undefined') {
					_mod.mBannerImage.attr('src', Path.GFX + 'ui/banners/' + _mod.mBanners[_mod.mCurrentBannerIndex] + '.png');
				}
			}
		}
	}

	if (typeof NewCampaignMenuModule !== 'undefined') {
		var origNCCreateDIV = NewCampaignMenuModule.prototype.createDIV;
		var origNCShow = NewCampaignMenuModule.prototype.show;
		var origNCSetBanners = NewCampaignMenuModule.prototype.setBanners;

		NewCampaignMenuModule.prototype.createDIV = function (_parentDiv) {
			origNCCreateDIV.call(this, _parentDiv);
			wxApplyNewCampaignOverhaul(this);
		};

		NewCampaignMenuModule.prototype.show = function () {
			wxApplyNewCampaignOverhaul(this);
			origNCShow.call(this);
		};

		NewCampaignMenuModule.prototype.setBanners = function (_data) {
			origNCSetBanners.call(this, wxFilterWuxiaBanners(_data));
		};

		if (typeof Screens !== 'undefined' && Screens['MainMenuScreen'] && Screens['MainMenuScreen'].mNewCampaignModule) {
			wxApplyNewCampaignOverhaul(Screens['MainMenuScreen'].mNewCampaignModule);
		}
	}

	// ------------------------------------------------------------------------
	// 11. Universal Hover Tooltip Terminology & Economy Icon Harmonizer
	// ------------------------------------------------------------------------
	var WX_TOOLTIP_TERM_PAIRS = [
		['每回合疲劳恢复', '每回合内息恢复'],
		['疲劳值恢复率', '内息调息恢复'],
		['疲劳恢复率',   '内息调息恢复'],
		['疲劳值上限',   '内息上限'],
		['最大疲劳值',   '内息上限'],
		['最大疲劳',     '内息上限'],
		['疲劳上限',     '内息上限'],
		['可用疲劳值',   '可用内息'],
		['可用疲劳',     '可用内息'],
		['基础疲劳',     '基础内息'],
		['累积疲劳值',   '消耗内息'],
		['累积疲劳',     '消耗内息'],
		['产生疲劳',     '消耗内息'],
		['增加疲劳',     '消耗内息'],
		['造成疲劳',     '震损敌方内息'],
		['当前疲劳值',   '当前已耗内息'],
		['当前疲劳',     '当前已耗内息'],
		['疲劳恢复',     '内息调息恢复'],
		['疲劳惩罚',     '内息负重折损'],
		['疲劳消耗',     '内息消耗'],
		['点疲劳值',     '点内息'],
		['点疲劳',       '点内息'],
		['疲劳值',       '内息'],
		['疲劳',         '内息'],
		['Maximum Fatigue', '内息上限'],
		['Max. Fatigue',    '内息上限'],
		['Fatigue Recovery','内息调息恢复'],
		['Fatigue',         '内息'],
		['近战技能',   '武艺'],
		['近战命中',   '武艺'],
		['远程技能',   '射艺'],
		['远程命中',   '射艺'],
		['近战防御',   '招架'],
		['远程防御',   '避暗'],
		['先攻值',     '身法'],
		['先攻',       '身法'],
		['决心',       '定力'],
		['意志',       '定力'],
		['生命值',     '气血'],
		['行动点',     '行动力'],
		['剥制工坊',   '百工炼丹房'],
		['剥制匠',     '百工丹师'],
		['绿皮入侵',   '南疆五毒与药人犯境'],
		['绿皮',       '五毒奇兵与炼体药人'],
		['亡灵灾祸',   '前朝玄宫尸傀浩劫'],
		['贵族战争',   '藩镇节度争霸'],
		['圣战',       '西域都护与中原兵燹'],
		['哥布林',     '五毒密林伏兵'],
		['兽人',       '关外狂暴药人'],
		['死灵法师',   '湘西控魂妖道'],
		['吸血鬼',     '玄宫血煞尸魔'],
		['食尸鬼',     '食腐山魈'],
		['树精',       '千年木魅'],
		['林德虫',     '岭南毒蛟'],
		['巨魔',       '荒山巨猿'],
		['女巫',       '迷魂妖姬'],
		['梦魇',       '魇魅'],
		['佣兵团',     '江湖义社'],
		['雇佣兵',     '江湖豪客'],
		['你打算出多少克朗', '这趟差事打算出多少纹银'],
		['多少克朗',   '多少纹银'],
		['克朗',       '两纹银'],
		['两两纹银',   '两纹银'],
		['特长点',     '武学修为'],
		['特长树',     '武学经脉']
	];

	function wxHarmonizeTooltipText(_str) {
		if (!_str || typeof _str !== 'string') return _str;
		var s = _str;
		for (var i = 0; i < WX_TOOLTIP_TERM_PAIRS.length; i++) {
			var from = WX_TOOLTIP_TERM_PAIRS[i][0];
			if (s.indexOf(from) !== -1) {
				s = s.split(from).join(WX_TOOLTIP_TERM_PAIRS[i][1]);
			}
		}
		return s;
	}

	function wxHarmonizeTooltipRows(_rows) {
		if (!_rows || !jQuery.isArray(_rows)) return;
		for (var i = 0; i < _rows.length; i++) {
			var row = _rows[i];
			if (row && typeof row === 'object') {
				if (typeof row.text === 'string') {
					row.text = wxHarmonizeTooltipText(row.text);
				}
				if (typeof row.label === 'string') {
					row.label = wxHarmonizeTooltipText(row.label);
				}
				if (typeof row.title === 'string') {
					row.title = wxHarmonizeTooltipText(row.title);
				}
				if (typeof row.icon === 'string') {
					var rel = row.icon.indexOf('gfx/') === 0 ? row.icon.substring(4) : row.icon;
					if (WX_ICON_MAP.hasOwnProperty(rel)) {
						row.icon = WX_ICON_MAP[rel];
					}
				}
				if (row.children && jQuery.isArray(row.children)) {
					wxHarmonizeTooltipRows(row.children);
				}
			}
		}
	}

	if (typeof TooltipModule !== 'undefined' && TooltipModule.prototype.buildFromData) {
		var origTooltipBuild = TooltipModule.prototype.buildFromData;
		TooltipModule.prototype.buildFromData = function (_data, _shouldBeUpdated, _contentType) {
			wxHarmonizeTooltipRows(_data);
			origTooltipBuild.call(this, _data, _shouldBeUpdated, _contentType);
			if (this.mContainer) {
				wxUpgradeImagesIn(this.mContainer);
			}
		};
		if (typeof Screens !== 'undefined' && Screens['TooltipScreen'] && Screens['TooltipScreen'].mTooltipModule) {
			Screens['TooltipScreen'].mTooltipModule.buildFromData = TooltipModule.prototype.buildFromData;
		}
	}
})();
