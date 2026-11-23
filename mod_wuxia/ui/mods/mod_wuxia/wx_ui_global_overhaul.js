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
		'wx_bldg_taxidermist':   '百工丹坊',
		'wx_bldg_alchemist':     '火器奇珍局',
		'wx_bldg_arena':         '生死演武擂',
		'wx_bldg_port':          '漕运官渡口',
		'wx_bldg_barber':        '江湖易容阁',
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

	function wxSyncTownPlaquePosition(_settlementBox, _el, _plaque) {
		if (!_settlementBox || !_settlementBox.length || !_el || !_el.length || !_plaque || !_plaque.length) return;
		var domEl = _el[0];
		var domBox = _settlementBox[0];
		if (!domEl || !domBox) return;

		var elW = domEl.offsetWidth || _el.outerWidth() || 0;
		var elH = domEl.offsetHeight || _el.outerHeight() || 0;
		if (elW < 10 || elH < 10) return;

		var elLeft = domEl.offsetLeft;
		var elTop = domEl.offsetTop;
		var boxW = domBox.clientWidth || _settlementBox.innerWidth() || 1024;
		var boxH = domBox.clientHeight || _settlementBox.innerHeight() || 600;
		var pW = _plaque[0].offsetWidth || _plaque.outerWidth() || 112;
		var pH = _plaque[0].offsetHeight || _plaque.outerHeight() || 26;

		var leftPx = Math.round(elLeft + (elW - pW) * 0.5);
		var topPx = Math.round(elTop + elH - pH * 0.48);
		if (leftPx < 6) leftPx = 6;
		if (leftPx + pW > boxW - 6) leftPx = Math.max(6, boxW - pW - 6);
		if (topPx < 6) topPx = 6;
		if (topPx + pH > boxH - 4) topPx = Math.max(6, boxH - pH - 4);

		_plaque.css({
			left: leftPx + 'px',
			top: topPx + 'px',
			right: 'auto',
			bottom: 'auto'
		});
	}

	function wxRefreshTownBuildingPlaques(_mod) {
		if (!_mod || !_mod.mContainer) return;
		wxUpgradeImagesIn(_mod.mContainer);

		var settlementBox = _mod.mContainer.find('.settlement-container:first');
		if (!settlementBox.length) return;
		settlementBox.find('.wx-town-shop-sign').remove();
		settlementBox.find('.wx-town-teahouse-btn').remove();

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
				wxSyncTownPlaquePosition(settlementBox, el, plaque);
				el.off('.wxSignLoad').one('load.wxSignLoad', function () {
					wxSyncTownPlaquePosition(settlementBox, el, plaque);
				});
				setTimeout(function () {
					wxSyncTownPlaquePosition(settlementBox, el, plaque);
				}, 45);
				el.off('.wxSign').on('mouseenter.wxSign', function () {
					plaque.addClass('is-hovered');
				}).on('mouseleave.wxSign', function () {
					plaque.removeClass('is-hovered');
				});
			})(sIdx);
		}
	}

	if (typeof WorldTownScreenMainDialogModule !== 'undefined' && WorldTownScreenMainDialogModule.prototype.loadFromData) {
		var origTownMainLoad = WorldTownScreenMainDialogModule.prototype.loadFromData;
		WorldTownScreenMainDialogModule.prototype.loadFromData = function (_data) {
			origTownMainLoad.call(this, _data);
			wxRefreshTownBuildingPlaques(this);
		};
		if (typeof Screens !== 'undefined' && Screens['WorldTownScreen'] && Screens['WorldTownScreen'].mMainDialogModule) {
			Screens['WorldTownScreen'].mMainDialogModule.loadFromData = WorldTownScreenMainDialogModule.prototype.loadFromData;
		}
	}

	// ------------------------------------------------------------------------
	// 4B. Town Disguise Pavilion (`铜镜江湖易容阁` — WorldTownScreenBarberDialogModule)
	// ------------------------------------------------------------------------
	function wxReloadDisguisePortrait(_mod, _imgPath) {
		if (!_mod || !_mod.mContainer || !_imgPath) return;
		var prefix = (typeof Path !== 'undefined' && Path.PROCEDURAL) ? Path.PROCEDURAL : 'coui://';
		var fullSrc = (_imgPath.indexOf('coui://') === 0 || _imgPath.indexOf('procedural://') === 0) ? _imgPath : (prefix + _imgPath);

		// 1. Force-update the main mirror portrait (`mDetailsPanel.CharacterImage`) even if vanilla set it to TempEntity!
		var mainImg = (_mod.mDetailsPanel && _mod.mDetailsPanel.CharacterImage && _mod.mDetailsPanel.CharacterImage.length)
			? _mod.mDetailsPanel.CharacterImage
			: null;
		if (mainImg) {
			mainImg.attr('src', 'coui://gfx/ui/icons/action_points.png');
			setTimeout(function () {
				mainImg.attr('src', fullSrc);
				if (typeof mainImg.centerImageWithinParent === 'function') {
					mainImg.centerImageWithinParent(0, 0, 1.0, false);
				}
				mainImg.removeClass('opacity-none');
			}, 16);
		}

		// 2. Force-update the selected brother's left-roster thumbnail
		var selEntry = _mod.mSelectedEntry || _mod.mContainer.find('.list-entry.is-selected:first');
		if (selEntry && selEntry.length) {
			var listImg = selEntry.find('.column.is-left img:first');
			if (listImg.length) {
				var entryData = selEntry.data('entry') || {};
				entryData.ImagePath = _imgPath;
				var ox = ('ImageOffsetX' in entryData && entryData.ImageOffsetX !== null) ? entryData.ImageOffsetX : 0;
				var oy = ('ImageOffsetY' in entryData && entryData.ImageOffsetY !== null) ? entryData.ImageOffsetY : 0;
				listImg.attr('src', 'coui://gfx/ui/icons/action_points.png');
				setTimeout(function () {
					listImg.attr('src', fullSrc);
					if (typeof listImg.centerImageWithinParent === 'function') {
						listImg.centerImageWithinParent(ox, oy, 0.64);
					}
					listImg.removeClass('opacity-none');
				}, 16);
			}
		}
	}

	function wxEnsureDisguisePanel(_mod) {
		if (!_mod || !_mod.mContainer) return null;
		if (_mod.mDialogContainer) {
			_mod.mDialogContainer.find('.header:first .title:first').text('铜镜江湖易容阁');
			_mod.mDialogContainer.find('.header:first .sub-title:first').text('千面修容改换冠发名号 · 敛息潜踪消解江湖恩怨');
		}

		var dCont = (_mod.mDetailsPanel && _mod.mDetailsPanel.Container && _mod.mDetailsPanel.Container.length)
			? _mod.mDetailsPanel.Container
			: _mod.mContainer.find('.details-container:first');
		if (!dCont || !dCont.length) return null;
		dCont.addClass('wx-barber-details');

		// Hide vanilla European barber arrow rows & Accept button while keeping top Character portrait + name row intact
		dCont.children().each(function () {
			var ch = $(this);
			if (ch.hasClass('wx-disguise-root') || ch.hasClass('is-character-container')) return;
			ch.hide();
		});

		var root = dCont.children('.wx-disguise-root');
		if (!root.length) {
			root = $('<div class="wx-disguise-root"></div>');
			dCont.append(root);
		}
		return root;
	}

	function wxRenderDisguisePanel(_mod, _res) {
		var root = wxEnsureDisguisePanel(_mod);
		if (!root || !root.length || !_res || !_res.ok) return;

		_mod.mWXCurrentBroID = _res.broId;
		if (_mod.mDetailsPanel && _mod.mDetailsPanel.CharacterName && _mod.mDetailsPanel.CharacterName.length) {
			_mod.mDetailsPanel.CharacterName.html(wxEsc(_res.fullName));
		}
		var selEntry = _mod.mContainer.find('.is-selected:first');
		if (selEntry.length) {
			var entryData = selEntry.data('entry');
			if (entryData && entryData.ID === _res.broId) {
				entryData.Name = _res.fullName;
				var nmNode = selEntry.find('.name:first');
				if (nmNode.length) nmNode.html(wxEsc(_res.fullName));
			}
		}
		wxReloadDisguisePortrait(_mod, _res.imagePath);
		if (typeof _res.money === 'number') {
			wxSyncWorldAndTownMoney(_res.money);
		}

		var lb = _res.labels || {};
		var isFem = !!lb.isFemale;
		var parts = [
			{ key: 'face',  title: '面容相貌', val: lb.faceLabel || '',  dis: false },
			{ key: 'hair',  title: '发髻冠式', val: lb.hairLabel || '',  dis: false },
			{ key: 'tone',  title: '鬓发色泽', val: lb.toneLabel || '',  dis: false },
			{ key: 'beard', title: '胡须风仪', val: isFem ? '女侠无须' : (lb.beardLabel || ''), dis: isFem },
			{ key: 'scar',  title: '战痕面饰', val: lb.scarLabel || '',  dis: false }
		];

		var rowsHtml = '';
		for (var i = 0; i < parts.length; i++) {
			var p = parts[i];
			var dCls = p.dis ? ' is-disabled' : '';
			rowsHtml +=
				'<div class="wx-disguise-step-row">' +
					'<span class="wx-disguise-step-lbl">' + wxEsc(p.title) + '</span>' +
					'<span class="wx-disguise-arr' + dCls + '" data-dstep="' + p.key + '" data-ddir="-1">&lsaquo;</span>' +
					'<span class="wx-disguise-step-val">' + wxEsc(p.val) + '</span>' +
					'<span class="wx-disguise-arr' + dCls + '" data-dstep="' + p.key + '" data-ddir="1">&rsaquo;</span>' +
				'</div>';
		}

		var curMoney = (typeof _res.money === 'number') ? _res.money : 0;
		var hostCnt = _res.hostileSectCount || 0;
		var vendCnt = _res.vendettaCount || 0;
		var coldFacCnt = _res.coldFactionCount || 0;
		var dCd = _res.disguiseCd || 0;
		var oCd = _res.officialCd || 0;

		var statusParts = [];
		if (hostCnt > 0) {
			statusParts.push('恶交宗门 ' + hostCnt + ' 派' + (vendCnt > 0 ? ('（寻仇追杀 ' + vendCnt + '）') : ''));
		} else {
			statusParts.push('九州各派暂无追杀恶交');
		}
		if (coldFacCnt > 0) {
			statusParts.push('盘查冷淡藩镇：' + wxEsc(_res.coldFactionName || (coldFacCnt + ' 镇')));
		}

		var vendCost = _res.vendettaCost || 600;
		var clrDis = (dCd > 0 || hostCnt <= 0 || curMoney < vendCost) ? ' is-disabled' : '';
		var clrLbl = dCd > 0
			? ('易容消解追杀(隔' + dCd + '日)')
			: ('秘术易容 · 消解追杀令(' + vendCost + '两)');
		var facDis = (oCd > 0 || coldFacCnt <= 0 || curMoney < 800) ? ' is-disabled' : '';
		var facLbl = oCd > 0
			? ('伪造官凭路引(隔' + oCd + '日)')
			: '伪造路引 · 周旋藩镇官凭(800两)';

		root.html(
			'<div class="wx-disguise-sec-hdr">千面修容 · 四十八相男女面谱</div>' +
			rowsHtml +
			'<div class="wx-disguise-mini-bar">' +
				'<span class="wx-disguise-btn" data-drnd="random">随机男侠</span>' +
				'<span class="wx-disguise-btn" data-drnd="random_fem">随机女侠</span>' +
				'<span class="wx-disguise-btn" data-drnd="reset_bg">归复本相</span>' +
			'</div>' +
			'<div class="wx-sect-gold-line"></div>' +
			'<div class="wx-disguise-sec-hdr">改换字号 · 隐姓埋名</div>' +
			'<div class="wx-disguise-inp-row">' +
				'<input type="text" class="wx-disguise-inp" data-dinp="name" maxlength="16" value="' + wxEsc(_res.name || '') + '" placeholder="侠客本名" />' +
				'<input type="text" class="wx-disguise-inp" data-dinp="title" maxlength="16" value="' + wxEsc(_res.title || '') + '" placeholder="江湖绰号(可空)" />' +
				'<span class="wx-disguise-btn" data-dact="rename">改换名号</span>' +
			'</div>' +
			'<div class="wx-sect-gold-line"></div>' +
			'<div class="wx-disguise-sec-hdr">秘术敛息 · 消解追缉与官凭</div>' +
			'<div class="wx-disguise-status">' + statusParts.join(' · ') + '</div>' +
			'<div>' +
				'<span class="wx-disguise-btn' + clrDis + '" data-dact="vendetta" title="耗银 600 两改换形貌暗记，大幅缓和至多两家恶交/寻仇宗门敌意（+22）并甩脱城外追杀队">' + wxEsc(clrLbl) + '</span>' +
				'<span class="wx-disguise-btn' + facDis + '" data-dact="faction" title="耗银 800 两托驿馆暗桩换发官凭路引，缓和关系最低的地方藩镇/都护府盘查敌意（+12）">' + wxEsc(facLbl) + '</span>' +
			'</div>'
		);

		root.find('input').on('keydown keyup keypress', function (_e) {
			_e.stopPropagation();
		});

		root.find('[data-dstep]').on('click', function () {
			if (!_mod.mSQHandle) return;
			var part = $(this).attr('data-dstep');
			var dir = parseInt($(this).attr('data-ddir'), 10) || 1;
			SQ.call(_mod.mSQHandle, 'onWXBarberStepPart', [_mod.mWXCurrentBroID, part, dir], function (_r) {
				if (_r && _r.ok) wxRenderDisguisePanel(_mod, _r);
			});
		});

		root.find('[data-drnd]').on('click', function () {
			if (!_mod.mSQHandle) return;
			var mode = $(this).attr('data-drnd');
			SQ.call(_mod.mSQHandle, 'onWXBarberStepPart', [_mod.mWXCurrentBroID, mode, 1], function (_r) {
				if (_r && _r.ok) wxRenderDisguisePanel(_mod, _r);
			});
		});

		root.find('[data-dact="rename"]').on('click', function () {
			if (!_mod.mSQHandle) return;
			var nm = root.find('[data-dinp="name"]').val() || '';
			var tt = root.find('[data-dinp="title"]').val() || '';
			SQ.call(_mod.mSQHandle, 'onWXBarberRename', [_mod.mWXCurrentBroID, nm, tt], function (_r) {
				if (!_r) return;
				if (!_r.ok) {
					wxShowFloatingBanner(_mod.mContainer, _r.reason || '改换名号失败。', true);
					return;
				}
				wxRenderDisguisePanel(_mod, _r);
				if (_r.actionMessage) wxShowFloatingBanner(_mod.mContainer, _r.actionMessage, false);
			});
		});

		root.find('[data-dact="vendetta"]').on('click', function () {
			if (!_mod.mSQHandle || $(this).hasClass('is-disabled')) return;
			SQ.call(_mod.mSQHandle, 'onWXBarberClearVendetta', [_mod.mWXCurrentBroID], function (_r) {
				if (!_r) return;
				if (!_r.ok) {
					wxShowFloatingBanner(_mod.mContainer, _r.reason || '无法执行秘术易容。', true);
					return;
				}
				wxRenderDisguisePanel(_mod, _r);
				if (_r.actionMessage) wxShowFloatingBanner(_mod.mContainer, _r.actionMessage, false);
			});
		});

		root.find('[data-dact="faction"]').on('click', function () {
			if (!_mod.mSQHandle || $(this).hasClass('is-disabled')) return;
			SQ.call(_mod.mSQHandle, 'onWXBarberEaseFaction', [_mod.mWXCurrentBroID], function (_r) {
				if (!_r) return;
				if (!_r.ok) {
					wxShowFloatingBanner(_mod.mContainer, _r.reason || '无法打点官凭。', true);
					return;
				}
				wxRenderDisguisePanel(_mod, _r);
				if (_r.actionMessage) wxShowFloatingBanner(_mod.mContainer, _r.actionMessage, false);
			});
		});
	}

	function wxQueryDisguiseForSelected(_mod, _element) {
		if (!_mod || !_mod.mSQHandle) return;
		var el = (_element && _element.length) ? _element : (_mod.mContainer ? _mod.mContainer.find('.is-selected:first') : null);
		var entry = (el && el.length) ? el.data('entry') : null;
		var broId = (entry && typeof entry.ID !== 'undefined') ? entry.ID : 0;
		SQ.call(_mod.mSQHandle, 'onWXBarberGetState', [broId], function (_res) {
			if (_res && _res.ok) {
				wxRenderDisguisePanel(_mod, _res);
			}
		});
	}

	if (typeof WorldTownScreenBarberDialogModule !== 'undefined') {
		if (WorldTownScreenBarberDialogModule.prototype.createDIV) {
			var origBarberCreateDIV = WorldTownScreenBarberDialogModule.prototype.createDIV;
			WorldTownScreenBarberDialogModule.prototype.createDIV = function (_parentDiv) {
				origBarberCreateDIV.call(this, _parentDiv);
				wxUpgradeImagesIn(this.mContainer);
				wxEnsureDisguisePanel(this);
			};
		}
		if (WorldTownScreenBarberDialogModule.prototype.loadFromData) {
			var origBarberLoad = WorldTownScreenBarberDialogModule.prototype.loadFromData;
			WorldTownScreenBarberDialogModule.prototype.loadFromData = function (_data) {
				var self = this;
				origBarberLoad.call(this, _data);
				wxUpgradeImagesIn(this.mContainer);
				setTimeout(function () {
					wxEnsureDisguisePanel(self);
					wxQueryDisguiseForSelected(self, null);
				}, 35);
			};
		}
		if (WorldTownScreenBarberDialogModule.prototype.updateDetailsPanel) {
			var origBarberUpdateDetails = WorldTownScreenBarberDialogModule.prototype.updateDetailsPanel;
			WorldTownScreenBarberDialogModule.prototype.updateDetailsPanel = function (_element) {
				var self = this;
				origBarberUpdateDetails.call(this, _element);
				wxEnsureDisguisePanel(this);
				setTimeout(function () {
					wxEnsureDisguisePanel(self);
					wxQueryDisguiseForSelected(self, _element);
				}, 30);
			};
		}
		if (typeof Screens !== 'undefined' && Screens['WorldTownScreen'] && Screens['WorldTownScreen'].mBarberDialogModule) {
			var liveBarber = Screens['WorldTownScreen'].mBarberDialogModule;
			liveBarber.loadFromData = WorldTownScreenBarberDialogModule.prototype.loadFromData;
			liveBarber.updateDetailsPanel = WorldTownScreenBarberDialogModule.prototype.updateDetailsPanel;
			wxEnsureDisguisePanel(liveBarber);
		}
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
				this.mNoCraftablesLabel.text('当前分类暂无配方。');
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
			if (this.mDialogContainer) {
				if (!_data || !_data.Title || _data.Title.indexOf('剥制') !== -1 || _data.Title.indexOf('炼丹') !== -1) {
					this.mDialogContainer.find('.header:first .title:first').text('百工丹坊');
				}
				this.mDialogContainer.find('.header:first .sub-title:first').text('选择工坊，或在下方按图制作');
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
				this.mDialogContainer.find('.header:first .title:first').text('忠义英魂录');
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
					this.mDialogContainer.find('.header:first .sub-title:first').text('自竖旗闯荡江湖以来，尚无同袍马革裹尸');
				} else {
					this.mDialogContainer.find('.header:first .sub-title:first').text('已有 ' + _data.Fallen.length + ' 位江湖同道喋血沙场，英名长存');
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
			var wasSanctum = !!(wxSectModalState.data && wxSectModalState.data.inSanctum);
			var h = wxSectModalState.sqHandle || window.WX_SectRPCHandle;
			existing.remove();
			$(document).off('keydown.wxSectModal');
			if (wasSanctum && h) {
				SQ.call(h, 'onWXCloseSanctum', null);
			}
			if (wxSectModalState.popupHostDS && wxSectModalState.popupHostDS.notifyBackendPopupDialogIsVisible) {
				wxSectModalState.popupHostDS.notifyBackendPopupDialogIsVisible(false);
			}
			wxSectModalState.popupHostDS = null;
		}
	}

	function wxRenderSectDetail(_pane, _s, _payload, _onActionDone) {
		if (!_s) {
			_pane.html('<div style="padding:2rem 0;color:#bd9d71;font-style:italic;text-align:center;">左键点击左侧宗门查阅渊源、独立山门方位、交情与传承秘籍。<br/><br/>（尚未结识的隐世宗门，可赴酒楼茶座结交、向酒保打探秘闻或踏勘荒山山门逐一揭开）</div>');
			return;
		}
		var localRegion = _payload ? _payload.localRegion : '';
		var inTown = !!(_payload && _payload.inTown);
		var inSanctum = !!(_payload && _payload.inSanctum);
		var curMoney = (_payload && typeof _payload.money === 'number') ? _payload.money : 0;
		var relCls = _s.relation > 0 ? 'is-pos' : (_s.relation < 0 ? 'is-neg' : 'is-neu');
		var relSign = _s.relation > 0 ? ('+' + _s.relation) : String(_s.relation);
		var isLoc = (_s.region === localRegion);

		var metaParts = [wxEsc(_s.regionLabel) + (isLoc ? '（当前地界）' : ''), wxEsc(_s.alignmentLabel)];
		if (_s.isVendetta) {
			metaParts.push('<span style="color:#CD2626;font-style:normal;">寻仇追缉中</span>');
		}

		var anchorLine = '';
		if (_s.hasSanctum) {
			if (_s.sanctumDiscovered && _s.anchorTownName) {
				var sDir = _s.anchorDir ? (_s.anchorDir + (_s.anchorDist >= 0 ? (' · ' + _s.anchorDist + ' 格') : '')) : '';
				anchorLine = '独立山门：<span style="color:#ffe28a;">【' + wxEsc(_s.anchorTownName) + '】</span>' +
					(sDir ? (' <span style="color:#bd9d71;">（' + wxEsc(sDir) + '）</span>') : '') + '<br/>';
			} else {
				anchorLine = '独立山门：<span style="color:#bd9d71;">云深不知处（可向酒肆酒保打探或踏勘名山寻访）</span><br/>';
			}
		} else if (_s.anchorTownName) {
			var dirStr = _s.anchorDir ? (_s.anchorDir + (_s.anchorDist >= 0 ? (' · ' + _s.anchorDist + ' 格') : '')) : '';
			anchorLine = '常驻茶座：<span style="color:#ffe28a;">【' + wxEsc(_s.anchorTownName) + ' · 酒楼茶座】</span>' +
				(dirStr ? (' <span style="color:#bd9d71;">（' + wxEsc(dirStr) + '）</span>') : '') + '<br/>';
		}

		var seatHtml = (_s.isAtSanctum || _s.isSeatedInTown)
			? ('<span class="wx-sect-seat-pill">' + wxEsc(_s.seatBadge || (_s.isAtSanctum ? '亲临山门' : '茶座在席')) + '</span>')
			: '';

		var html =
			'<div class="wx-t-title" style="font-size:2.0rem;line-height:2.6rem;">' + wxEsc(_s.name) + seatHtml + '</div>' +
			'<div style="font-size:1.35rem;color:#bd9d71;font-style:italic;margin-bottom:0.5rem;">' + metaParts.join(' · ') + '</div>' +
			'<div class="wx-sect-gold-line"></div>' +
			'<div style="font-size:1.35rem;line-height:1.95rem;color:#bd9d71;font-style:italic;margin-bottom:0.65rem;">' + wxEsc(_s.description) + '</div>' +
			'<div style="font-size:1.38rem;line-height:2.0rem;margin-bottom:0.65rem;">' +
				anchorLine +
				'当前交情：<span class="wx-sect-rel-num ' + relCls + '" style="float:none;">' + relSign + ' · ' + wxEsc(_s.statusLabel) + '</span><br/>' +
				'寻仇红线：<span style="color:#CD2626;">&le; ' + _s.vendettaRel + '</span> <span style="color:#bd9d71;font-style:italic;">（交情 &ge;25 可飞鸽约见；镇派真传须亲赴山门）</span>' +
			'</div>';

		function wxTeaBtnHtml(_op, _ico, _label, _extraCls, _tip) {
			var tipAttr = _tip ? (' title="' + wxEsc(_tip) + '"') : '';
			return (
				'<span class="wx-tea-btn has-ico' + (_extraCls || '') + '" data-tea-op="' + _op + '"' + tipAttr + '>' +
					'<img class="wx-tea-btn-ico" src="coui://gfx/' + _ico + '" alt="" />' +
					'<span>' + wxEsc(_label) + '</span>' +
				'</span>'
			);
		}

		if (_s.isAtSanctum) {
			var sealDays = _s.sealDays || 0;
			var sealedDis = sealDays > 0;

			var sBanqDis = (sealedDis || _s.banquetCd > 0 || curMoney < 350) ? ' is-disabled' : '';
			var sBanqLbl = (_s.banquetCd > 0)
				? ('递帖奉茗(隔' + _s.banquetCd + '日)')
				: '递帖奉茗(350两 · 交情+18)';

			var qInfo = _s.questInfo || { active: false, canComplete: false, cd: 0, label: '接领宗门法帖(交情+22)', detail: '' };
			var qDis = (sealedDis || (!qInfo.active && (qInfo.cd > 0 || _s.relation < -15)) || (qInfo.active && !qInfo.canComplete)) ? ' is-disabled' : '';

			var empCd = _s.empowerCd || 0;
			var empDis = (sealedDis || empCd > 0 || _s.relation < 30 || curMoney < 450) ? ' is-disabled' : '';
			var empLbl = empCd > 0
				? ('长老灌顶(隔' + empCd + '日)')
				: (_s.relation < 30 ? '长老灌顶(需交情≥30)' : '长老灌顶(450两 · 火候+160)');

			var healCd = _s.healCd || 0;
			var healDis = (sealedDis || healCd > 0 || _s.relation < 15 || curMoney < 380) ? ' is-disabled' : '';
			var healLbl = healCd > 0
				? ('运功疗内伤(隔' + healCd + '日)')
				: (_s.relation < 15 ? '运功疗内伤(需交情≥15)' : '运功拔除内伤(380两)');

			var herbCd = _s.herbCd || 0;
			var herbDis = (sealedDis || herbCd > 0 || _s.relation < 20 || curMoney < 360) ? ' is-disabled' : '';
			var herbLbl = herbCd > 0
				? ('道地药庐(隔' + herbCd + '日)')
				: (_s.relation < 20 ? '采买道地灵草(需交情≥20)' : '采买本门灵草(360两)');

			var sAlcDis = (sealedDis || (_s.alcCd || 0) > 0 || _s.relation < 35 || curMoney < 480) ? ' is-disabled' : '';
			var sAlcLbl = (_s.alcCd || 0) > 0
				? ('求教古丹方(隔' + _s.alcCd + '日)')
				: (_s.relation < 35 ? '求教丹房古方(需交情≥35)' : '求教丹房古方(480两)');

			var recCd = _s.recruitCd || 0;
			var recCost = _s.recruitCost || 1800;
			var recDis = (sealedDis || recCd > 0 || _s.relation < 45 || curMoney < recCost) ? ' is-disabled' : '';
			var recLbl = recCd > 0
				? ('求贤择徒(隔' + recCd + '日)')
				: (_s.relation < 45 ? '延请真传弟子(需交情≥45)' : ('延请真传弟子入队(' + recCost + '两)'));

			var sSparDis = (sealedDis || _s.sparCd > 0) ? ' is-disabled' : '';
			var sSparLbl = (_s.sparCd > 0)
				? ('演武拆招(隔' + _s.sparCd + '日)')
				: '点到拆招(交情+15 · 历练)';

			var trMinRel = (_s.alignment === 'outlaw') ? 0 : 10;
			var trCd = _s.trialCd || 0;
			var trDis = (sealedDis || trCd > 0 || _s.relation < trMinRel) ? ' is-disabled' : '';
			var trLbl = trCd > 0
				? ('护山大阵(隔' + trCd + '日)')
				: (_s.relation < trMinRel ? ('闯护山大阵(需交情≥' + trMinRel + ')') : '闯护山大阵(实战赢残页灵草)');

			var rdCd = _s.raidCd || 0;
			var rdDis = (sealDays > 0 || rdCd > 0) ? ' is-disabled' : '';
			var rdLbl = (sealDays > 0 || rdCd > 0)
				? ('重创封山(余' + Math.max(sealDays, rdCd) + '日)')
				: '生死踢馆(强攻夺真传秘籍)';

			var sealBannerHtml = sealDays > 0
				? ('<div style="color:#e87a42;font-size:1.26rem;margin-bottom:0.35rem;">【封山戒严】本门前番遭强攻重创，当前紧闭山门疗伤（尚余 ' + sealDays + ' 日重开堂口）</div>')
				: '';
			var questDetailHtml = qInfo.detail
				? ('<div style="color:#bd9d71;font-size:1.22rem;font-style:italic;margin:0.2rem 0 0.35rem 0;">' + wxEsc(qInfo.detail) + '</div>')
				: '';

			html +=
				'<div class="wx-tea-actions">' +
					'<div style="font-size:1.38rem;color:#ffe28a;margin-bottom:0.35rem;">【' + wxEsc(_payload.sanctumName || (_s.name + '山门')) + '】山门四大堂口</div>' +
					sealBannerHtml +
					'<div class="wx-tea-hall-hdr">知客堂 · 拜山与宗门法帖</div>' +
					wxTeaBtnHtml('banquet', 'ui/wx_icons/wx_glyph_sect_token.png', sBanqLbl, sBanqDis, '奉上名茶厚礼拜会掌门与长老，提升本门交情') +
					wxTeaBtnHtml('quest', 'ui/wx_icons/wx_icon_ambition.png', qInfo.label, qDis, qInfo.detail || '接领或缴付本门知客堂法帖差事') +
					questDetailHtml +
					'<div class="wx-tea-hall-hdr">传功堂与药庐 · 授业疗伤炼丹</div>' +
					wxTeaBtnHtml('empower', 'ui/wx_icons/wx_icon_qi.png', empLbl, empDis, '传功长老以真气助一名未满重功法侠客贯通关窍（+160火候）') +
					wxTeaBtnHtml('heal', 'ui/wx_icons/wx_asset_medicine.png', healLbl, healDis, '为全队拔除【经脉内伤】【散功虚弱】并调满气血') +
					wxTeaBtnHtml('herbs', 'ui/wx_icons/wx_glyph_herb_cabinet.png', herbLbl, herbDis, '购入 2 株本门秘植《山海本草》道地灵药并直接收入百草药柜') +
					wxTeaBtnHtml('alchemy', 'ui/wx_icons/wx_glyph_cauldron.png', sAlcLbl, sAlcDis, '向本门丹房长老奉银求教一道尚未录入《丹经手札》的秘传丹方') +
					'<div class="wx-tea-hall-hdr">求贤堂 · 延请真传弟子下山</div>' +
					wxTeaBtnHtml('recruit', 'ui/icons/asset_brothers.png', recLbl, recDis, '延请 1 名兼修本门内功与外功的 2 级本门真传弟子加入义社') +
					'<div class="wx-tea-hall-hdr">演武校场 · 真武闯阵与生死踢馆</div>' +
					wxTeaBtnHtml('spar', 'ui/wx_icons/wx_slot_mainhand.png', sSparLbl, sSparDis, '与本门高手点到拆招，赢取武学火候与宗门交情') +
					wxTeaBtnHtml('battle-trial', 'ui/wx_icons/wx_icon_melee_def.png', trLbl, trDis, '进入真实战术战场挑战本门护山大阵！不伤和气，破阵立赢秘籍残页、道地灵草、500两彩头及+18交情') +
					wxTeaBtnHtml('battle-raid', 'ui/wx_icons/wx_icon_melee_skill.png', rdLbl, ' is-danger' + rdDis, '拔刃强攻本门山门重阵！胜之可强夺镇派秘籍与库银，但将结下不共戴天死仇(-65交情)') +
				'</div>';
		} else if (inTown && _s.isSeatedInTown) {
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
					'<div style="font-size:1.3rem;color:#ffe28a;margin-bottom:0.35rem;">【' + wxEsc(_payload.townName) + ' · 酒楼二楼茶座】门人雅席</div>' +
					wxTeaBtnHtml('banquet', 'ui/wx_icons/wx_glyph_sect_token.png', banqLbl, banqDisabled, '设茗款待落座门人，增进宗门交情') +
					wxTeaBtnHtml('spar', 'ui/wx_icons/wx_slot_mainhand.png', sparLbl, sparDisabled, '与门人拆招印证武学火候') +
					wxTeaBtnHtml('offend', 'ui/wx_icons/wx_seal_cinnabar.png', '撕毁门帖(-35)', ' is-danger', '当众撕毁该派拜帖，结下梁子') +
				'</div>';
		} else if (inTown && !_s.isSeatedInTown) {
			var whereHint = (_s.hasSanctum && _s.sanctumDiscovered && _s.anchorTownName)
				? ('亲赴荒山山门【' + wxEsc(_s.anchorTownName) + '】登门拜山')
				: (_s.anchorTownName ? ('前往【' + wxEsc(_s.anchorTownName) + '】酒楼茶座寻访') : '向酒保打探其山门方位后登门拜山');
			html +=
				'<div class="wx-tea-actions" style="font-size:1.28rem;color:#bd9d71;font-style:italic;">' +
					'该宗门传人今日未在此城酒楼落座。可' + whereHint + '；若交情达 25 以上，在任意城池酒楼皆可飞鸽约见。' +
				'</div>';
		} else if (inSanctum && !_s.isAtSanctum) {
			html +=
				'<div class="wx-tea-actions" style="font-size:1.28rem;color:#bd9d71;font-style:italic;">' +
					'当前正身处他派山门。若欲拜会【' + wxEsc(_s.name) + '】，须前往其本门山门或州县酒楼茶座。' +
				'</div>';
		} else {
			var roWhere = (_s.hasSanctum && _s.sanctumDiscovered && _s.anchorTownName)
				? ('亲赴荒山山门【' + wxEsc(_s.anchorTownName) + '】登门拜山，或入州县【迎客酒肆 · 二楼茶座】')
				: (_s.anchorTownName ? ('前往【' + wxEsc(_s.anchorTownName) + ' · 迎客酒肆】二楼茶座') : '前往州县【迎客酒肆 · 二楼茶座】或向酒保打探山门方位');
			html +=
				'<div class="wx-tea-actions" style="font-size:1.26rem;color:#bd9d71;font-style:italic;">' +
					'随身《江湖名刺录》仅供查阅门派渊源与交情 —— 如需设茗结交、拆招或奉脩请教秘籍，请' + roWhere + '操作。' +
				'</div>';
		}

		var revCnt = (typeof _s.revealedManualCount === 'number') ? _s.revealedManualCount : _s.manuals.length;
		html += '<div style="font-size:1.5rem;color:#dda21f;margin-bottom:0.4rem;">独门武库（已探明 ' + revCnt + ' / ' + _s.manuals.length + ' 部）</div>';

		if (_s.manuals.length === 0) {
			html += '<div style="color:#bd9d71;font-style:italic;">该宗门暂无对外传授之秘籍。</div>';
		} else {
			var canInteractHere = (_s.isAtSanctum || (inTown && _s.isSeatedInTown));
			for (var i = 0; i < _s.manuals.length; i++) {
				var m = _s.manuals[i];
				var bookSrc = m.bookIcon ? ('coui://gfx/' + m.bookIcon) : 'coui://gfx/ui/items/misc/wx_book_waigong_sect.png';
				if (m.isRevealed === false) {
					html +=
						'<div class="wx-sect-manual-item has-book is-masked">' +
							'<div class="wx-sect-manual-fig">' +
								'<img class="wx-sect-manual-ico is-dim" src="' + wxEsc(bookSrc) + '" alt="" />' +
								'<img class="wx-sect-manual-skico" src="coui://gfx/ui/wx_icons/wx_glyph_lock_sm.png" alt="" />' +
							'</div>' +
							'<div class="wx-sect-manual-body">' +
								'<div><span style="color:#a3875c;">《？？？》</span><span class="wx-sect-own-tag">秘传未显</span></div>' +
								'<div style="font-size:1.28rem;color:#8e7550;font-style:italic;">' +
									wxEsc(m.qualityLabel) + ' · ' + wxEsc(m.categoryLabel) + '　' + wxEsc(m.maskedHint || ('需交情 ≥' + m.minRel + ' 方显真容')) +
									'<div class="clear-both"></div>' +
								'</div>' +
							'</div>' +
							'<div class="clear-both"></div>' +
						'</div>';
					continue;
				}

				var reqStr = m.requiresSanctum
					? '<span style="color:#CD2626;">镇派绝学 · 须亲赴本门山门</span>'
					: (m.unlocked
						? '<span style="color:#dda21f;">交情达标(&ge;' + m.minRel + ')</span>'
						: '<span style="color:#CD2626;">需交情 &ge;' + m.minRel + '</span>');

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
				if (canInteractHere) {
					var canBuy = m.unlocked && !m.requiresSanctum && curMoney >= m.price;
					var buyTip = m.requiresSanctum
						? '须赴山门请教'
						: (!m.unlocked ? '交情未达' : (curMoney < m.price ? '银两不足' : '奉上束脩请教秘籍'));
					buyHtml = '<span class="wx-tea-buy-btn' + (canBuy ? '' : ' is-disabled') + '" data-buy-mid="' + m.id + '" title="' + wxEsc(buyTip) + '">' +
						(canBuy ? '奉脩请教' : buyTip) + '</span>';
				}

				var skBadgeHtml = '';
				if (m.skillIcon) {
					var skRel = (m.skillIcon.indexOf('ui/') === 0) ? m.skillIcon : ('ui/' + m.skillIcon);
					skBadgeHtml = '<img class="wx-sect-manual-skico" src="coui://gfx/' + wxEsc(skRel) + '" alt="" />';
				}

				html +=
					'<div class="wx-sect-manual-item has-book">' +
						'<div class="wx-sect-manual-fig">' +
							'<img class="wx-sect-manual-ico" src="' + wxEsc(bookSrc) + '" alt="" />' +
							skBadgeHtml +
						'</div>' +
						'<div class="wx-sect-manual-body">' +
							'<div><span style="color:#dda21f;">《' + wxEsc(m.name) + '》</span>' + ownBadge + '</div>' +
							'<div style="font-size:1.3rem;color:#bd9d71;">' +
								wxEsc(m.qualityLabel) + ' · ' + wxEsc(m.categoryLabel) + '　' + reqStr + '　束脩 ' + m.price + ' 两' + buyHtml +
								'<div class="clear-both"></div>' +
							'</div>' +
						'</div>' +
						'<div class="clear-both"></div>' +
					'</div>';
			}
		}
		_pane.html(html);

		if ((_s.isAtSanctum || (inTown && _s.isSeatedInTown)) && wxSectModalState.sqHandle) {
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
			_pane.find('[data-tea-op="alchemy"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXSanctumAskAlchemy', [_s.id], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-tea-op="quest"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXSanctumHandleQuest', [_s.id], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-tea-op="empower"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXSanctumElderEmpower', [_s.id], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-tea-op="heal"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXSanctumHealInternal', [_s.id], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-tea-op="herbs"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXSanctumBuyHerbs', [_s.id], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-tea-op="recruit"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXSanctumRecruitDisciple', [_s.id], function (_res) {
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-tea-op="battle-trial"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXSanctumStartBattle', [_s.id, 'trial'], function (_res) {
					if (_res && _res.ok && _res.closeModal) {
						wxCloseSectDirectory();
						return;
					}
					if (_onActionDone) _onActionDone(_res);
				});
			});
			_pane.find('[data-tea-op="battle-raid"]').on('click', function () {
				SQ.call(wxSectModalState.sqHandle, 'onWXSanctumStartBattle', [_s.id, 'raid'], function (_res) {
					if (_res && _res.ok && _res.closeModal) {
						wxCloseSectDirectory();
						return;
					}
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
		var prevSelected = wxSectModalState.selectedId;
		wxCloseSectDirectory();
		wxSectModalState.data = _payload;
		wxSectModalState.popupHostDS = _optionalDS || null;
		if (_payload && _payload.sanctumSectID) {
			wxSectModalState.selectedId = _payload.sanctumSectID;
		} else {
			wxSectModalState.selectedId = prevSelected;
		}
		if (wxSectModalState.popupHostDS && wxSectModalState.popupHostDS.notifyBackendPopupDialogIsVisible) {
			wxSectModalState.popupHostDS.notifyBackendPopupDialogIsVisible(true);
		}

		var host = $('.root-screen:first');
		if (!host.length) host = $(document.body);

		var startRegion = 'all';
		if (_initialFilter === 'sanctum' && _payload.inSanctum) {
			startRegion = 'sanctum';
		} else if (_initialFilter === 'teahouse' && _payload.inTown) {
			startRegion = 'teahouse';
		}
		wxSectModalState.region = startRegion;
		wxSectModalState.vendettaOnly = false;
		wxSectModalState.query = '';

		var regBtnsHtml = '';
		if (_payload.inSanctum) {
			regBtnsHtml += '<span class="wx-sect-tab' + (startRegion === 'sanctum' ? ' is-active' : '') + '" data-sreg="sanctum">本门山门</span>';
		} else if (_payload.inTown) {
			regBtnsHtml += '<span class="wx-sect-tab' + (startRegion === 'teahouse' ? ' is-active' : '') + '" data-sreg="teahouse">酒肆茶座(' + (_payload.townSeatedCount || 0) + ')</span>';
		}
		var knownCnt = (typeof _payload.knownSectCount === 'number') ? _payload.knownSectCount : _payload.sects.length;
		var totalCnt = (typeof _payload.totalSectCount === 'number') ? _payload.totalSectCount : knownCnt;
		regBtnsHtml += '<span class="wx-sect-tab' + (startRegion === 'all' ? ' is-active' : '') + '" data-sreg="all">已识(' + knownCnt + '/' + totalCnt + ')</span>';
		for (var r = 0; r < _payload.regions.length; r++) {
			var rg = _payload.regions[r];
			var isHere = (rg.id === _payload.localRegion);
			regBtnsHtml += '<span class="wx-sect-tab" data-sreg="' + rg.id + '">' + wxEsc(rg.label) + (isHere ? '★' : '') + '</span>';
		}

		var rumorBtnHtml = '';
		if (_payload.inTown) {
			var rCd = _payload.rumorCd || 0;
			var rDis = (rCd > 0 || (_payload.money || 0) < 160) ? ' is-disabled' : '';
			var rTxt = rCd > 0 ? ('打探秘闻(隔' + rCd + '日)') : '向酒保打探山门/丹方(160两)';
			rumorBtnHtml = '<span class="wx-sect-rumor-btn' + rDis + '" data-sect-act="rumor" title="赏酒保 160 两纹银，打探一处尚未现世的名门山门坐落或一道失传丹方">' + wxEsc(rTxt) + '</span>';
		}

		var hdrTitle = _payload.inSanctum
			? ('【' + wxEsc(_payload.sanctumName || '宗门山门') + '】登门拜山 · 宗门议事堂')
			: (_payload.inTown
				? ('【' + wxEsc(_payload.townName) + ' · 迎风酒楼】二楼江湖茶座')
				: ('江湖名刺录（已结识 ' + knownCnt + ' / ' + totalCnt + ' 宗门）'));
		var moneyBadgeHtml = (typeof _payload.money === 'number')
			? ('<div class="wx-sect-money-badge">纹银：<span>' + wxFormatCommaMoney(_payload.money) + '</span> 两</div>')
			: '';
		var closeBtnText = _payload.inSanctum ? '辞别下山' : '关闭';

		var backdrop = $(
			'<div class="wx-sect-backdrop ui-control">' +
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
						rumorBtnHtml +
						'<input type="text" class="wx-sect-search" data-sect-act="search" placeholder="搜已识门派 / 山门 / 秘籍" />' +
					'</div>' +
					'<div class="wx-sect-body">' +
						'<div class="wx-sect-list-pane" data-sect="list"></div>' +
						'<div class="wx-sect-detail-pane" data-sect="detail"></div>' +
					'</div>' +
					'<div class="wx-sect-foot">' +
						'<span class="wx-sect-foot-btn" data-sect-act="close">' + closeBtnText + '</span>' +
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
			var kCnt = (typeof _res.knownSectCount === 'number') ? _res.knownSectCount : (_res.sects ? _res.sects.length : 0);
			var tCnt = (typeof _res.totalSectCount === 'number') ? _res.totalSectCount : kCnt;
			backdrop.find('[data-sreg="all"]').text('已识(' + kCnt + '/' + tCnt + ')');
			if (_res.inTown) {
				backdrop.find('[data-sreg="teahouse"]').text('酒肆茶座(' + (_res.townSeatedCount || 0) + ')');
				var rBtn = backdrop.find('[data-sect-act="rumor"]');
				if (rBtn.length) {
					var cd = _res.rumorCd || 0;
					var dis = (cd > 0 || (_res.money || 0) < 160);
					rBtn.toggleClass('is-disabled', dis);
					rBtn.text(cd > 0 ? ('打探秘闻(隔' + cd + '日)') : '向酒保打探山门/丹方(160两)');
				}
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
				if (wxSectModalState.region === 'sanctum') {
					if (!s.isAtSanctum) continue;
				} else if (wxSectModalState.region === 'teahouse') {
					if (!s.isSeatedInTown) continue;
				} else if (wxSectModalState.region !== 'all' && s.region !== wxSectModalState.region) {
					continue;
				}
				if (wxSectModalState.vendettaOnly && !s.isVendetta && s.relation > -15) continue;
				if (wxSectModalState.query) {
					var hay = (s.name + ' ' + s.regionLabel + ' ' + (s.anchorTownName || '') + ' ' + s.description).toLowerCase();
					for (var m = 0; m < s.manuals.length; m++) {
						if (s.manuals[m].isRevealed !== false) {
							hay += ' ' + s.manuals[m].name.toLowerCase();
						}
					}
					if (hay.indexOf(wxSectModalState.query) === -1) continue;
				}

				if (!firstMatch) firstMatch = s;
				if (s.id === wxSectModalState.selectedId) selObj = s;

				var relCls = s.relation > 0 ? 'is-pos' : (s.relation < 0 ? 'is-neg' : 'is-neu');
				var relStr = (s.relation > 0 ? ('+' + s.relation) : String(s.relation)) + ' · ' + s.statusLabel;
				var subParts = [];
				if (s.isAtSanctum) {
					subParts.push('<span style="color:#ffe28a;font-style:normal;">[亲临山门]</span>');
				} else if (s.isSeatedInTown) {
					subParts.push('<span style="color:#ffe28a;font-style:normal;">[' + wxEsc(s.seatBadge || '茶座在席') + ']</span>');
				}
				if (s.hasSanctum) {
					if (s.sanctumDiscovered && s.anchorTownName) {
						var sTail = (s.anchorDist > 0 && s.anchorDir) ? ('(' + wxEsc(s.anchorDir) + s.anchorDist + '格)') : '';
						subParts.push('山门:' + wxEsc(s.anchorTownName) + sTail);
					} else {
						subParts.push('山门未探');
					}
				} else if (s.anchorTownName) {
					var distTail = (s.anchorDist > 0 && s.anchorDir) ? ('(' + wxEsc(s.anchorDir) + s.anchorDist + '格)') : '';
					subParts.push('常驻:' + wxEsc(s.anchorTownName) + distTail);
				} else {
					subParts.push(wxEsc(s.regionLabel));
				}
				if (s.isVendetta) subParts.push('<span style="color:#CD2626;font-style:normal;">寻仇追缉</span>');
				subParts.push(wxEsc(s.alignmentLabel));
				var revM = (typeof s.revealedManualCount === 'number') ? s.revealedManualCount : s.manuals.length;
				subParts.push('秘传 ' + revM + '/' + s.manuals.length);

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
				var emptyMsg = (_payload.sects && _payload.sects.length === 0)
					? '初涉江湖，尚未结识任何门派。<br/>可步入州县【迎风酒楼 · 二楼江湖茶座】会晤各派行客、向酒保打探隐世山门，或游历山川探访独立山门！'
					: '没有符合当前筛选条件的已结识宗门';
				listPane.append('<div style="padding:3rem 1.2rem;color:#bd9d71;font-style:italic;text-align:center;line-height:2.1rem;">' + emptyMsg + '</div>');
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

		backdrop.find('[data-sect-act="rumor"]').on('click', function () {
			if ($(this).hasClass('is-disabled') || !wxSectModalState.sqHandle) return;
			SQ.call(wxSectModalState.sqHandle, 'onWXTavernInquireRumor', null, function (_res) {
				handleActionResponse(_res);
			});
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

	if (typeof WorldScreen !== 'undefined') {
		WorldScreen.prototype.wxOpenSanctumModal = function (_payload) {
			if (!_payload || !_payload.ok) return;
			var h = this.mSQHandle || window.WX_SectRPCHandle;
			if (h) {
				window.WX_SectRPCHandle = h;
				wxSectModalState.sqHandle = h;
			}
			wxRenderSectModalDOM(_payload, null, 'sanctum');
		};
		if (typeof Screens !== 'undefined' && Screens['WorldScreen']) {
			Screens['WorldScreen'].wxOpenSanctumModal = WorldScreen.prototype.wxOpenSanctumModal;
		}
	}

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
			origWorldOptCreate.call(this, _parentDiv);
			wxUpgradeImagesIn(this.mContainer);
			if (this.mSQHandle !== null) window.WX_SectRPCHandle = this.mSQHandle;
		};
	}

	if (typeof WorldRelationsScreen !== 'undefined') {
		var origRelCreateDIV = WorldRelationsScreen.prototype.createDIV;
		WorldRelationsScreen.prototype.createDIV = function (_parentDiv) {
			var self = this;
			origRelCreateDIV.call(this, _parentDiv);
			wxUpgradeImagesIn(this.mContainer);

			if (this.mDialogContainer) {
				this.mDialogContainer.find('.header:first .title:first').text('江湖录 · 朝堂与宗门');
				this.mDialogContainer.find('.header:first .sub-title:first').text('查阅朝堂藩镇邦交，或点击上方两侧翻阅随身只读【江湖宗门名刺】与【丹经与药柜录】');
				if (!this.mDialogContainer.find('.wx-rel-sect-btn').length) {
					var relSectBtn = $(
						'<div class="wx-rel-sect-btn" title="翻阅随身只读《江湖名刺录》已结识门派、独立山门方位与已探明传承（结交请赴酒肆茶座或山门）">' +
							'<img src="coui://gfx/ui/wx_icons/wx_glyph_sect_token.png" alt="" />江湖宗门名刺' +
						'</div>'
					);
					relSectBtn.on('click', function () {
						if (self.mSQHandle !== null && window.WX_OpenSectDirectory) {
							window.WX_OpenSectDirectory(self.mSQHandle, null, 'all');
						}
					});
					this.mDialogContainer.append(relSectBtn);

					var relAlcBtn = $(
						'<div class="wx-rel-alc-btn" title="翻阅随身只读《丹经手札》已悟丹方、百工器谱与百草药柜账册（开炉炼丹、重锻与存取奇材请赴城镇百工丹坊）">' +
							'<img src="coui://gfx/ui/wx_icons/wx_glyph_herb_cabinet.png" alt="" />丹经与药柜录' +
						'</div>'
					);
					relAlcBtn.on('click', function () {
						if (self.mSQHandle !== null && window.WX_OpenAlchemyCauldron) {
							window.WX_OpenAlchemyCauldron(self.mSQHandle, null, null, null, 'cauldron');
						}
					});
					this.mDialogContainer.append(relAlcBtn);
				}
			}
		};

		if (WorldRelationsScreen.prototype.loadFromData) {
			var origRelLoad = WorldRelationsScreen.prototype.loadFromData;
			WorldRelationsScreen.prototype.loadFromData = function (_data) {
				origRelLoad.call(this, _data);
				if (this.mDialogContainer) {
					this.mDialogContainer.find('.header:first .sub-title:first').text('查阅朝堂藩镇邦交，或点击上方两侧翻阅随身只读【江湖宗门名刺】与【丹经与药柜录】');
				}
			};
		}
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

		if (_mod.mDialogContainer) {
			_mod.mDialogContainer.find('.header:first .title:first').text('开山立社 · 新闯江湖');
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
	// 10B. Save & Load Campaign Menu Banner Sanitizer (prevents `ui/banners/.png` & missing foreign mod banners)
	// ------------------------------------------------------------------------
	function wxSanitizeSaveBanner(_raw, _fallbackSeed) {
		var s = String(_raw || '');
		var m = /^banner_([0-9]+)$/.exec(s);
		if (m) {
			var num = parseInt(m[1], 10);
			if ((num >= 1 && num <= 36) || (num >= 51 && num <= 66)) {
				return s;
			}
		}
		var seedStr = String(_fallbackSeed || s || 'wx');
		var h = 0;
		for (var i = 0; i < seedStr.length; i++) {
			h = (h * 31 + seedStr.charCodeAt(i)) & 0x7fffffff;
		}
		return 'banner_' + (51 + (h % 16));
	}

	function wxSanitizeCampaignRowData(_data) {
		if (!_data || typeof _data !== 'object') return;
		var imgKey = (typeof CampaignMenuModulesIdentifier !== 'undefined' && CampaignMenuModulesIdentifier.Campaign && CampaignMenuModulesIdentifier.Campaign.Image)
			? CampaignMenuModulesIdentifier.Campaign.Image
			: 'image';
		var nameKey = (typeof CampaignMenuModulesIdentifier !== 'undefined' && CampaignMenuModulesIdentifier.Campaign && CampaignMenuModulesIdentifier.Campaign.Name)
			? CampaignMenuModulesIdentifier.Campaign.Name
			: 'name';
		_data[imgKey] = wxSanitizeSaveBanner(_data[imgKey], _data[nameKey]);
	}

	if (typeof LoadCampaignMenuModule !== 'undefined' && LoadCampaignMenuModule.prototype.addCampaignEntryToList) {
		var origLoadAddEntry = LoadCampaignMenuModule.prototype.addCampaignEntryToList;
		LoadCampaignMenuModule.prototype.addCampaignEntryToList = function (_data) {
			wxSanitizeCampaignRowData(_data);
			return origLoadAddEntry.call(this, _data);
		};
		if (typeof Screens !== 'undefined') {
			if (Screens['MainMenuScreen'] && Screens['MainMenuScreen'].mLoadCampaignModule) {
				Screens['MainMenuScreen'].mLoadCampaignModule.addCampaignEntryToList = LoadCampaignMenuModule.prototype.addCampaignEntryToList;
			}
			if (Screens['WorldScreen'] && Screens['WorldScreen'].mLoadCampaignModule) {
				Screens['WorldScreen'].mLoadCampaignModule.addCampaignEntryToList = LoadCampaignMenuModule.prototype.addCampaignEntryToList;
			}
		}
	}

	if (typeof SaveCampaignMenuModule !== 'undefined' && SaveCampaignMenuModule.prototype.addCampaignEntryToList) {
		var origSaveAddEntry = SaveCampaignMenuModule.prototype.addCampaignEntryToList;
		SaveCampaignMenuModule.prototype.addCampaignEntryToList = function (_data) {
			wxSanitizeCampaignRowData(_data);
			return origSaveAddEntry.call(this, _data);
		};
		if (typeof Screens !== 'undefined' && Screens['WorldScreen'] && Screens['WorldScreen'].mSaveCampaignModule) {
			Screens['WorldScreen'].mSaveCampaignModule.addCampaignEntryToList = SaveCampaignMenuModule.prototype.addCampaignEntryToList;
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
		['军团声望',   '江湖威名'],
		['战团声望',   '江湖威名'],
		['公司声望',   '江湖威名'],
		['雇用随从',   '延揽江湖幕僚'],
		['非战斗随从', '江湖幕僚'],
		['随从栏位',   '幕僚席位'],
		['随从席位',   '幕僚席位'],
		['名随从',     '名江湖幕僚'],
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

	// =========================================================================
	// 12. Options Menu -> Gameplay Panel: Wuxia Combat VFX & Actor Motion Toggles
	// =========================================================================
	var WX_OPT_STORAGE_VFX = 'wx_opt_skill_vfx';
	var WX_OPT_STORAGE_MOTION = 'wx_opt_actor_motion';
	var wxOptPanelUid = 0;

	function wxReadStoredCombatOptions() {
		var res = { hasStored: false, showSkillVfx: true, enableActorMotion: true };
		try {
			if (typeof window !== 'undefined' && window.localStorage) {
				var v = window.localStorage.getItem(WX_OPT_STORAGE_VFX);
				var m = window.localStorage.getItem(WX_OPT_STORAGE_MOTION);
				if (v !== null) {
					res.hasStored = true;
					res.showSkillVfx = (v !== '0' && v !== 'false');
				}
				if (m !== null) {
					res.hasStored = true;
					res.enableActorMotion = (m !== '0' && m !== 'false');
				}
			}
		} catch (_e) {}
		return res;
	}

	function wxWriteStoredCombatOptions(_opts) {
		if (!_opts) return;
		try {
			if (typeof window !== 'undefined' && window.localStorage) {
				window.localStorage.setItem(WX_OPT_STORAGE_VFX, _opts.showSkillVfx ? '1' : '0');
				window.localStorage.setItem(WX_OPT_STORAGE_MOTION, _opts.enableActorMotion ? '1' : '0');
			}
		} catch (_e) {}
	}

	function wxEnsureDataSourceCombatOptions(_ds) {
		if (!_ds) return { showSkillVfx: true, enableActorMotion: true };
		if (!_ds.mWXCombatOptions) {
			var stored = wxReadStoredCombatOptions();
			_ds.mWXCombatOptions = {
				showSkillVfx: stored.showSkillVfx,
				enableActorMotion: stored.enableActorMotion
			};
		}
		return _ds.mWXCombatOptions;
	}

	function wxPushCombatOptionsToBackend(_ds, _opts) {
		if (!_ds || !_ds.mSQHandle || !_opts) return;
		try {
			SQ.call(_ds.mSQHandle, 'onWXApplyCombatOptions', [
				_opts.showSkillVfx ? true : false,
				_opts.enableActorMotion ? true : false
			]);
		} catch (_e) {}
	}

	function wxApplyCheckboxVisuals(_panel, _opts) {
		if (!_panel || !_opts) return;
		_panel.mWXSyncingCheckboxes = true;
		try {
			if (_panel.mWXSkillVfxCheckbox && _panel.mWXSkillVfxCheckbox.length > 0) {
				_panel.selectCheckboxOption(_panel.mWXSkillVfxCheckbox, _opts.showSkillVfx === true);
			}
			if (_panel.mWXActorMotionCheckbox && _panel.mWXActorMotionCheckbox.length > 0) {
				_panel.selectCheckboxOption(_panel.mWXActorMotionCheckbox, _opts.enableActorMotion === true);
			}
		} catch (_e) {}
		_panel.mWXSyncingCheckboxes = false;
	}

	function wxBindGameplayCombatTooltips(_panel) {
		if (!_panel) return;
		try {
			if (_panel.mWXSkillVfxLabel && _panel.mWXSkillVfxLabel.length > 0) {
				_panel.mWXSkillVfxLabel.bindTooltip({ contentType: 'ui-element', elementId: 'menu-screen.options.WXSkillVfx' });
			}
			if (_panel.mWXActorMotionLabel && _panel.mWXActorMotionLabel.length > 0) {
				_panel.mWXActorMotionLabel.bindTooltip({ contentType: 'ui-element', elementId: 'menu-screen.options.WXActorMotion' });
			}
		} catch (_e) {}
	}

	function wxUnbindGameplayCombatTooltips(_panel) {
		if (!_panel) return;
		try {
			if (_panel.mWXSkillVfxLabel && _panel.mWXSkillVfxLabel.length > 0) {
				_panel.mWXSkillVfxLabel.unbindTooltip();
			}
			if (_panel.mWXActorMotionLabel && _panel.mWXActorMotionLabel.length > 0) {
				_panel.mWXActorMotionLabel.unbindTooltip();
			}
		} catch (_e) {}
	}

	function wxEnsureGameplayCombatControls(_panel) {
		if (!_panel || !_panel.mContainer || _panel.mContainer.length === 0) return;
		if (_panel.mWXCombatRow && _panel.mWXCombatRow.length > 0 && _panel.mContainer.find('.wx-combat-options-row').length > 0) {
			return;
		}

		var cols = _panel.mContainer.children('.column');
		var rightCol = cols.length >= 2 ? cols.eq(1) : _panel.mContainer;
		if (!rightCol || rightCol.length === 0) return;

		wxOptPanelUid = wxOptPanelUid + 1;
		var vfxId = 'cb-wx-skill-vfx-' + wxOptPanelUid;
		var motId = 'cb-wx-actor-motion-' + wxOptPanelUid;

		var row = $('<div class="row wx-combat-options-row"></div>');
		rightCol.append(row);

		var title = $('<div class="title title-font-big font-color-title">山海武侠 · 战斗演出</div>');
		row.append(title);

		var ctrlVfx = $('<div class="control"></div>');
		row.append(ctrlVfx);
		var cbVfx = $('<input type="checkbox" id="' + vfxId + '" name="wx-skill-vfx" />');
		ctrlVfx.append(cbVfx);
		var lblVfx = $('<label class="text-font-normal font-color-subtitle" for="' + vfxId + '">显示武学招式特效动画</label>');
		ctrlVfx.append(lblVfx);
		cbVfx.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});

		var ctrlMot = $('<div class="control"></div>');
		row.append(ctrlMot);
		var cbMot = $('<input type="checkbox" id="' + motId + '" name="wx-actor-motion" />');
		ctrlMot.append(cbMot);
		var lblMot = $('<label class="text-font-normal font-color-subtitle" for="' + motId + '">启用侠客出招身法动作</label>');
		ctrlMot.append(lblMot);
		cbMot.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});

		_panel.mWXCombatRow = row;
		_panel.mWXSkillVfxCheckbox = cbVfx;
		_panel.mWXSkillVfxLabel = lblVfx;
		_panel.mWXActorMotionCheckbox = cbMot;
		_panel.mWXActorMotionLabel = lblMot;
		_panel.mWXSyncingCheckboxes = false;

		cbVfx.on('ifChecked ifUnchecked', null, _panel, function (_event) {
			var self = _event.data;
			if (!self || self.mWXSyncingCheckboxes || !self.mDataSource) return;
			var opts = wxEnsureDataSourceCombatOptions(self.mDataSource);
			opts.showSkillVfx = (self.mWXSkillVfxCheckbox.prop('checked') === true);
		});

		cbMot.on('ifChecked ifUnchecked', null, _panel, function (_event) {
			var self = _event.data;
			if (!self || self.mWXSyncingCheckboxes || !self.mDataSource) return;
			var opts = wxEnsureDataSourceCombatOptions(self.mDataSource);
			opts.enableActorMotion = (self.mWXActorMotionCheckbox.prop('checked') === true);
		});

		var initOpts = wxEnsureDataSourceCombatOptions(_panel.mDataSource);
		wxApplyCheckboxVisuals(_panel, initOpts);
	}

	function wxSyncGameplayPanelOptions(_panel) {
		if (!_panel) return;
		wxEnsureGameplayCombatControls(_panel);
		var ds = _panel.mDataSource;
		var opts = wxEnsureDataSourceCombatOptions(ds);
		wxApplyCheckboxVisuals(_panel, opts);

		if (ds && ds.mSQHandle) {
			try {
				SQ.call(ds.mSQHandle, 'onWXQueryCombatOptions', null, function (_res) {
					if (_res && typeof _res === 'object') {
						if (typeof _res.showSkillVfx === 'boolean') {
							opts.showSkillVfx = _res.showSkillVfx;
						}
						if (typeof _res.enableActorMotion === 'boolean') {
							opts.enableActorMotion = _res.enableActorMotion;
						}
						wxApplyCheckboxVisuals(_panel, opts);
					}
				});
			} catch (_e) {}
		}
	}

	function wxResetGameplayPanelDefaults(_panel) {
		if (!_panel) return;
		wxEnsureGameplayCombatControls(_panel);
		var opts = wxEnsureDataSourceCombatOptions(_panel.mDataSource);
		opts.showSkillVfx = true;
		opts.enableActorMotion = true;
		wxApplyCheckboxVisuals(_panel, opts);
	}

	function wxSyncStoredOptionsOnConnect(_ds) {
		if (!_ds || !_ds.mSQHandle) return;
		var stored = wxReadStoredCombatOptions();
		var opts = wxEnsureDataSourceCombatOptions(_ds);
		if (stored.hasStored) {
			opts.showSkillVfx = stored.showSkillVfx;
			opts.enableActorMotion = stored.enableActorMotion;
			wxPushCombatOptionsToBackend(_ds, opts);
		} else {
			try {
				SQ.call(_ds.mSQHandle, 'onWXQueryCombatOptions', null, function (_res) {
					if (_res && typeof _res === 'object') {
						if (typeof _res.showSkillVfx === 'boolean') {
							opts.showSkillVfx = _res.showSkillVfx;
						}
						if (typeof _res.enableActorMotion === 'boolean') {
							opts.enableActorMotion = _res.enableActorMotion;
						}
					}
				});
			} catch (_e) {}
		}
	}

	if (typeof OptionsMenuModuleDatasource !== 'undefined') {
		if (!OptionsMenuModuleDatasource.prototype._wxCombatOptsPatched) {
			OptionsMenuModuleDatasource.prototype._wxCombatOptsPatched = true;

			var origOptDsConnect = OptionsMenuModuleDatasource.prototype.onConnection;
			OptionsMenuModuleDatasource.prototype.onConnection = function (_handle) {
				origOptDsConnect.call(this, _handle);
				wxSyncStoredOptionsOnConnect(this);
			};

			var origOptDsApplyGameplay = OptionsMenuModuleDatasource.prototype.applyGameplayOptions;
			OptionsMenuModuleDatasource.prototype.applyGameplayOptions = function () {
				origOptDsApplyGameplay.call(this);
				var opts = wxEnsureDataSourceCombatOptions(this);
				wxWriteStoredCombatOptions(opts);
				wxPushCombatOptionsToBackend(this, opts);
			};
		}
	}

	if (typeof OptionsMenuModuleGameplayPanel !== 'undefined') {
		if (!OptionsMenuModuleGameplayPanel.prototype._wxCombatOptsPatched) {
			OptionsMenuModuleGameplayPanel.prototype._wxCombatOptsPatched = true;

			var origGpCreateDIV = OptionsMenuModuleGameplayPanel.prototype.createDIV;
			OptionsMenuModuleGameplayPanel.prototype.createDIV = function (_parentDiv) {
				origGpCreateDIV.call(this, _parentDiv);
				wxEnsureGameplayCombatControls(this);
			};

			var origGpBindTooltips = OptionsMenuModuleGameplayPanel.prototype.bindTooltips;
			OptionsMenuModuleGameplayPanel.prototype.bindTooltips = function () {
				origGpBindTooltips.call(this);
				wxBindGameplayCombatTooltips(this);
			};

			var origGpUnbindTooltips = OptionsMenuModuleGameplayPanel.prototype.unbindTooltips;
			OptionsMenuModuleGameplayPanel.prototype.unbindTooltips = function () {
				wxUnbindGameplayCombatTooltips(this);
				origGpUnbindTooltips.call(this);
			};

			var origGpDestroyDIV = OptionsMenuModuleGameplayPanel.prototype.destroyDIV;
			OptionsMenuModuleGameplayPanel.prototype.destroyDIV = function () {
				if (this.mWXSkillVfxCheckbox) {
					this.mWXSkillVfxCheckbox.remove();
					this.mWXSkillVfxCheckbox = null;
				}
				if (this.mWXActorMotionCheckbox) {
					this.mWXActorMotionCheckbox.remove();
					this.mWXActorMotionCheckbox = null;
				}
				this.mWXSkillVfxLabel = null;
				this.mWXActorMotionLabel = null;
				this.mWXCombatRow = null;
				origGpDestroyDIV.call(this);
			};

			var origGpShow = OptionsMenuModuleGameplayPanel.prototype.show;
			OptionsMenuModuleGameplayPanel.prototype.show = function () {
				wxSyncGameplayPanelOptions(this);
				origGpShow.call(this);
			};

			var origGpOnLoaded = OptionsMenuModuleGameplayPanel.prototype.onOptionsLoaded;
			OptionsMenuModuleGameplayPanel.prototype.onOptionsLoaded = function (_dataSource, _data) {
				origGpOnLoaded.call(this, _dataSource, _data);
				wxSyncGameplayPanelOptions(this);
			};

			var origGpOnDefaults = OptionsMenuModuleGameplayPanel.prototype.onDefaultsLoaded;
			OptionsMenuModuleGameplayPanel.prototype.onDefaultsLoaded = function (_dataSource, _data) {
				origGpOnDefaults.call(this, _dataSource, _data);
				wxResetGameplayPanelDefaults(this);
			};
		}
	}

	if (typeof OptionsMenuModule !== 'undefined') {
		if (!OptionsMenuModule.prototype._wxCombatOptsPatched) {
			OptionsMenuModule.prototype._wxCombatOptsPatched = true;
			var origOptModShow = OptionsMenuModule.prototype.show;
			OptionsMenuModule.prototype.show = function (_data) {
				origOptModShow.call(this, _data);
				if (this.mGameplayPanel) {
					wxSyncGameplayPanelOptions(this.mGameplayPanel);
				}
			};
		}
	}

	// Patch any already-instantiated OptionsMenuModule instances across Screens (MainMenuScreen, IngameMenuScreen, etc.)
	if (typeof Screens !== 'undefined') {
		for (var wxScrKey in Screens) {
			if (!Screens.hasOwnProperty(wxScrKey)) continue;
			var wxScr = Screens[wxScrKey];
			if (!wxScr || !wxScr.mOptionsMenuModule) continue;
			var wxOptMod = wxScr.mOptionsMenuModule;
			if (wxOptMod.mDataSource && wxOptMod.mDataSource.mSQHandle) {
				wxSyncStoredOptionsOnConnect(wxOptMod.mDataSource);
			}
			if (wxOptMod.mGameplayPanel) {
				if (wxOptMod.mGameplayPanel.mContainer) {
					wxEnsureGameplayCombatControls(wxOptMod.mGameplayPanel);
					wxBindGameplayCombatTooltips(wxOptMod.mGameplayPanel);
				}
				if (wxOptMod.mDataSource && !wxOptMod.mGameplayPanel._wxLiveListenerAdded && typeof OptionsMenuModuleDatasourceIdentifier !== 'undefined') {
					wxOptMod.mGameplayPanel._wxLiveListenerAdded = true;
					(function (_panel) {
						wxOptMod.mDataSource.addListener(OptionsMenuModuleDatasourceIdentifier.Options.Loaded, function () {
							wxSyncGameplayPanelOptions(_panel);
						});
						wxOptMod.mDataSource.addListener(OptionsMenuModuleDatasourceIdentifier.Options.Reseted, function () {
							wxResetGameplayPanelDefaults(_panel);
						});
					})(wxOptMod.mGameplayPanel);
				}
			}
		}
	}
})();
