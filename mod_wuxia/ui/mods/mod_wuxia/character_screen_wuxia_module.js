/* ============================================================================
 * BB Wuxia Mod - Icon-Slot Drag-and-Drop Martial Arts UI (Strict ES3)
 * Replaces the vanilla CharacterScreenPerksModule grid in-place.
 * ============================================================================ */

(function () {
	'use strict';

	// ------------------------------------------------------------------------
	// 1. Datasource SQ.call Bridges
	// ------------------------------------------------------------------------
	if (typeof CharacterScreenDatasource !== 'undefined') {
		CharacterScreenDatasource.prototype.notifyBackendWXGetState = function (_entityId, _callback) {
			if (this.mSQHandle !== null) {
				SQ.call(this.mSQHandle, 'onWXGetState', _entityId, _callback);
			}
		};

		CharacterScreenDatasource.prototype.notifyBackendWXEquipFromStash = function (_entityId, _stashIndex, _slotIndex, _isFragment, _confirmed, _callback) {
			if (this.mSQHandle !== null) {
				SQ.call(this.mSQHandle, 'onWXEquipFromStash', [_entityId, _stashIndex, _slotIndex, _isFragment, _confirmed], _callback);
			}
		};

		CharacterScreenDatasource.prototype.notifyBackendWXInfusePill = function (_entityId, _stashIndex, _slotIndex, _callback) {
			if (this.mSQHandle !== null) {
				SQ.call(this.mSQHandle, 'onWXInfusePill', [_entityId, _stashIndex, _slotIndex], _callback);
			}
		};

		CharacterScreenDatasource.prototype.notifyBackendWXCraftPages = function (_entityId, _manualID, _callback) {
			if (this.mSQHandle !== null) {
				SQ.call(this.mSQHandle, 'onWXCraftPages', [_entityId, _manualID], _callback);
			}
		};

		CharacterScreenDatasource.prototype.notifyBackendWXGetWashPreview = function (_entityId, _targetAttrIdx, _replaceAttrIdx, _useProtectPill, _callback) {
			if (this.mSQHandle !== null) {
				SQ.call(this.mSQHandle, 'onWXGetWashPreview', [_entityId, _targetAttrIdx, _replaceAttrIdx, _useProtectPill], _callback);
			}
		};

		CharacterScreenDatasource.prototype.notifyBackendWXExecuteWash = function (_entityId, _targetAttrIdx, _replaceAttrIdx, _useProtectPill, _usePendingChance, _callback) {
			if (this.mSQHandle !== null) {
				SQ.call(this.mSQHandle, 'onWXExecuteWash', [_entityId, _targetAttrIdx, _replaceAttrIdx, _useProtectPill, _usePendingChance], _callback);
			}
		};
	}

	// ------------------------------------------------------------------------
	// 2. Replace CharacterScreenPerksModule with 7-Slot Icon & Drag-Drop Panel
	// ------------------------------------------------------------------------
	if (typeof CharacterScreenPerksModule === 'undefined') {
		return;
	}

	var origCreateDIV = CharacterScreenPerksModule.prototype.createDIV;
	var origLoadFromData = CharacterScreenPerksModule.prototype.loadFromData;
	var origShow = CharacterScreenPerksModule.prototype.show;

	CharacterScreenPerksModule.prototype.createDIV = function (_parentDiv) {
		origCreateDIV.call(this, _parentDiv);

		// Hide vanilla 7-row perk tree grid while preserving the tab wrapper
		if (this.mListScrollContainer) {
			this.mListScrollContainer.hide();
		} else if (this.mContainer) {
			this.mContainer.children().hide();
		}

		this.mWXState = null;
		this.mWXFilter = 'all';
		this.mWXDragPayload = null;
		this.mWXWashState = {
			targetAttrIdx: -1,
			replaceAttrIdx: -1,
			useProtectPill: false,
			usePendingChance: false
		};

		this.wxBuildRootDOM(this.mContainer || _parentDiv);
	};

	CharacterScreenPerksModule.prototype.show = function () {
		origShow.call(this);
		this.wxRefreshFromBackend();
	};

	CharacterScreenPerksModule.prototype.loadFromData = function (_brother) {
		origLoadFromData.call(this, _brother);
		this.mWXCurrentEntityId = (_brother && typeof _brother.id !== 'undefined') ? _brother.id : null;
		this.wxRefreshFromBackend();
	};

	CharacterScreenPerksModule.prototype.wxBuildRootDOM = function (_host) {
		var self = this;

		this.mWXRoot = $('<div class="wx-panel"></div>');
		_host.append(this.mWXRoot);

		// Top Summary Bar
		this.mWXHeader = $(
			'<div class="wx-header">' +
				'<div class="wx-summary-tags">' +
					'<span class="wx-tag wx-tag-ap" data-wx="ap">行动点: 9 AP</span>' +
					'<span class="wx-tag wx-tag-el" data-wx="element">主修: 未修内功</span>' +
					'<span class="wx-tag wx-tag-harmony" data-wx="conflict">内息调和</span>' +
				'</div>' +
				'<button type="button" class="wx-btn wx-btn-wash" data-wx="open-wash">✦ 洗经伐髓</button>' +
			'</div>'
		);
		this.mWXRoot.append(this.mWXHeader);

		// Status Toast Line
		this.mWXToast = $('<div class="wx-toast"></div>');
		this.mWXRoot.append(this.mWXToast);

		// Middle: 7 Square Icon Slots (Row 1 = 5 specialized, Row 2 = 2 free)
		this.mWXSlotsWrap = $(
			'<div class="wx-slots-section">' +
				'<div class="wx-slots-row wx-slots-row-main" data-wx="slots-row-1"></div>' +
				'<div class="wx-slots-row wx-slots-row-free" data-wx="slots-row-2"></div>' +
			'</div>'
		);
		this.mWXRoot.append(this.mWXSlotsWrap);

		// Bottom: Stash Manuals, Pages & Pills Icon Grid Drawer
		this.mWXDrawer = $(
			'<div class="wx-drawer">' +
				'<div class="wx-filter-bar" data-wx="filters">' +
					'<button type="button" class="wx-filter-btn is-active" data-filter="all">全部</button>' +
					'<button type="button" class="wx-filter-btn" data-filter="neigong">内功</button>' +
					'<button type="button" class="wx-filter-btn" data-filter="waigong">外功</button>' +
					'<button type="button" class="wx-filter-btn" data-filter="qinggong">轻功</button>' +
					'<button type="button" class="wx-filter-btn" data-filter="henglian">横练</button>' +
					'<button type="button" class="wx-filter-btn" data-filter="page">残页</button>' +
					'<button type="button" class="wx-filter-btn" data-filter="pill">丹药</button>' +
				'</div>' +
				'<div class="wx-stash-grid" data-wx="stash-grid"></div>' +
			'</div>'
		);
		this.mWXRoot.append(this.mWXDrawer);

		// Floating Tooltip Box (anchored cleanly inside panel)
		this.mWXTooltip = $('<div class="wx-tooltip" style="display:none;"></div>');
		this.mWXRoot.append(this.mWXTooltip);

		// Modal Overlay Container (Scatter Confirm & Marrow Wash)
		this.mWXModal = $('<div class="wx-modal-backdrop" style="display:none;"></div>');
		this.mWXRoot.append(this.mWXModal);

		// Bind filter clicks
		this.mWXDrawer.find('.wx-filter-btn').on('click', function () {
			self.mWXFilter = $(this).attr('data-filter');
			self.mWXDrawer.find('.wx-filter-btn').removeClass('is-active');
			$(this).addClass('is-active');
			self.wxRenderStashGrid();
		});

		// Bind Marrow Wash modal trigger
		this.mWXHeader.find('[data-wx="open-wash"]').on('click', function () {
			self.wxOpenWashModal();
		});
	};

	CharacterScreenPerksModule.prototype.wxShowToast = function (_msg, _isError) {
		if (!this.mWXToast) return;
		this.mWXToast.removeClass('is-error is-ok');
		if (!_msg) {
			this.mWXToast.text('').hide();
			return;
		}
		this.mWXToast.addClass(_isError ? 'is-error' : 'is-ok').text(_msg).show();
	};

	CharacterScreenPerksModule.prototype.wxRefreshFromBackend = function () {
		var self = this;
		if (!this.mDataSource) return;

		var entityId = this.mWXCurrentEntityId;
		if (entityId === null && this.mDataSource.getSelectedBrother) {
			var selected = this.mDataSource.getSelectedBrother();
			if (selected && typeof selected.id !== 'undefined') {
				entityId = selected.id;
				this.mWXCurrentEntityId = entityId;
			}
		}
		if (entityId === null) return;

		this.mDataSource.notifyBackendWXGetState(entityId, function (_data) {
			if (_data && _data.ok) {
				self.mWXState = _data;
				self.wxRenderAll();
			}
		});
	};

	CharacterScreenPerksModule.prototype.wxRenderAll = function () {
		if (!this.mWXState || !this.mWXState.brother) return;
		this.wxRenderHeader();
		this.wxRenderSlots();
		this.wxRenderStashGrid();
	};

	CharacterScreenPerksModule.prototype.wxRenderHeader = function () {
		var bro = this.mWXState.brother;
		var apText = '常驻: ' + bro.actionPointsMax + ' AP';
		if (bro.permanentAPBonus > 0) {
			apText += ' (孤本+' + bro.permanentAPBonus + ')';
		}
		this.mWXHeader.find('[data-wx="ap"]').text(apText);
		this.mWXHeader.find('[data-wx="element"]').text('主修: ' + bro.mainElementLabel);

		var conflictEl = this.mWXHeader.find('[data-wx="conflict"]');
		if (bro.hasConflict) {
			conflictEl.removeClass('wx-tag-harmony').addClass('wx-tag-conflict').text('⚠ 内息相克');
		} else {
			conflictEl.removeClass('wx-tag-conflict').addClass('wx-tag-harmony').text('内息调和');
		}

		var washBtn = this.mWXHeader.find('[data-wx="open-wash"]');
		var totalWashSources = (this.mWXState.washPillCount || 0) + (bro.pendingWashChances || 0);
		if (totalWashSources > 0) {
			washBtn.addClass('has-chance').text('✦ 洗经伐髓 (' + totalWashSources + ')');
		} else {
			washBtn.removeClass('has-chance').text('✦ 洗经伐髓');
		}
	};

	CharacterScreenPerksModule.prototype.wxRenderSlots = function () {
		var self = this;
		var bro = this.mWXState.brother;
		var row1 = this.mWXSlotsWrap.find('[data-wx="slots-row-1"]').empty();
		var row2 = this.mWXSlotsWrap.find('[data-wx="slots-row-2"]').empty();

		for (var i = 0; i < bro.slots.length; i++) {
			var s = bro.slots[i];
			var card = this.wxCreateSlotElement(s);
			if (i < 5) {
				row1.append(card);
			} else {
				row2.append(card);
			}
		}

		// Attach HTML5 drop handlers onto every unlocked slot
		this.mWXSlotsWrap.find('.wx-slot-box').each(function () {
			var el = this;
			var slotIdx = parseInt($(el).attr('data-slot-index'), 10);

			el.ondragover = function (evt) {
				if (!self.mWXDragPayload) return;
				if (self.wxCanDropOnSlot(self.mWXDragPayload, slotIdx)) {
					evt.preventDefault();
					$(el).addClass('is-drop-hover');
				}
			};
			el.ondragleave = function () {
				$(el).removeClass('is-drop-hover');
			};
			el.ondrop = function (evt) {
				evt.preventDefault();
				$(el).removeClass('is-drop-hover');
				self.wxClearDropHighlights();
				if (self.mWXDragPayload) {
					self.wxHandleDropOnSlot(self.mWXDragPayload, slotIdx);
					self.mWXDragPayload = null;
				}
			};
		});
	};

	CharacterScreenPerksModule.prototype.wxCreateSlotElement = function (_s) {
		var self = this;
		var qualityCls = _s.manualID ? ('wx-q-' + _s.quality) : 'wx-q-empty';
		var lockCls = _s.unlocked ? '' : ' is-locked';
		var fragBadge = _s.isFragment ? '<span class="wx-frag-badge">残</span>' : '';

		var innerHtml = '';
		if (!_s.unlocked) {
			innerHtml = '<div class="wx-slot-lock">🔒<span>' + _s.unlockLevel + '级开</span></div>';
		} else if (_s.manualID) {
			innerHtml = '<img class="wx-slot-icon" src="coui://gfx/' + _s.icon + '" alt="" />' + fragBadge;
		} else {
			innerHtml = '<div class="wx-slot-plus">＋</div>';
		}

		// 3 Mastery dots + thin progress bar
		var dotsHtml = '';
		var pct = 0;
		var barCls = 'wx-exp-fill';
		if (_s.manualID) {
			for (var d = 1; d <= 3; d++) {
				dotsHtml += '<span class="wx-dot' + (d <= _s.tier ? ' is-lit' : '') + '"></span>';
			}
			if (_s.isFragment) {
				pct = 100;
				barCls += ' is-frag';
			} else if (_s.tier >= 3 || _s.expNeeded <= 0) {
				pct = 100;
				barCls += ' is-max';
			} else {
				pct = Math.min(100, Math.floor((_s.exp / _s.expNeeded) * 100));
				if (_s.blockedByReq) {
					barCls += ' is-blocked';
				}
			}
		}

		var wrap = $(
			'<div class="wx-slot-card">' +
				'<div class="wx-slot-box ' + qualityCls + lockCls + '" data-slot-index="' + _s.slotIndex + '">' +
					innerHtml +
				'</div>' +
				'<div class="wx-slot-meta">' +
					'<div class="wx-dots">' + dotsHtml + '</div>' +
					'<div class="wx-exp-bar"><div class="' + barCls + '" style="width:' + pct + '%;"></div></div>' +
					'<div class="wx-slot-caption">' + (_s.manualID ? _s.name : _s.slotLabel) + '</div>' +
				'</div>' +
			'</div>'
		);

		wrap.find('.wx-slot-box').on('mouseenter', function () {
			self.wxShowSlotTooltip(_s);
		}).on('mouseleave', function () {
			self.mWXTooltip.hide();
		});

		return wrap;
	};

	CharacterScreenPerksModule.prototype.wxRenderStashGrid = function () {
		var self = this;
		var grid = this.mWXDrawer.find('[data-wx="stash-grid"]').empty();
		var items = this.mWXState.stashItems || [];
		var shown = 0;

		for (var i = 0; i < items.length; i++) {
			var it = items[i];
			if (!this.wxPassesFilter(it)) continue;
			shown++;
			grid.append(this.wxCreateStashTile(it));
		}

		if (shown === 0) {
			grid.append('<div class="wx-empty-hint">行囊中暂无对应武学秘籍、残页或修为丹药。</div>');
		}
	};

	CharacterScreenPerksModule.prototype.wxPassesFilter = function (_it) {
		if (this.mWXFilter === 'all') return true;
		if (this.mWXFilter === 'page') return _it.itemKind === 'page';
		if (this.mWXFilter === 'pill') return _it.itemKind === 'pill_infuse';
		return _it.itemKind === 'manual' && _it.category === this.mWXFilter;
	};

	CharacterScreenPerksModule.prototype.wxCreateStashTile = function (_it) {
		var self = this;
		var qCls = 'wx-q-' + (_it.quality || 'common');
		var corner = '';
		if (_it.itemKind === 'page') {
			corner = '<span class="wx-tile-count' + (_it.canCraft ? ' is-craftable' : '') + '">' + _it.totalPages + '/' + _it.fragmentsNeeded + '</span>';
		} else if (_it.itemKind === 'pill_infuse') {
			corner = '<span class="wx-tile-count is-pill">+' + _it.expAmount + '</span>';
		}

		var tile = $(
			'<div class="wx-stash-tile ' + qCls + '" draggable="true">' +
				'<img class="wx-tile-icon" src="coui://gfx/' + _it.icon + '" alt="" />' +
				corner +
				'<div class="wx-tile-name">' + _it.name + '</div>' +
			'</div>'
		);

		// HTML5 Drag start / end
		var domEl = tile[0];
		domEl.ondragstart = function (evt) {
			self.mWXDragPayload = _it;
			if (evt.dataTransfer) {
				evt.dataTransfer.setData('text/plain', String(_it.stashIndex));
			}
			self.wxHighlightValidSlots(_it);
		};
		domEl.ondragend = function () {
			self.mWXDragPayload = null;
			self.wxClearDropHighlights();
		};

		// Hover tooltip
		tile.on('mouseenter', function () {
			self.wxShowStashTooltip(_it);
		}).on('mouseleave', function () {
			self.mWXTooltip.hide();
		});

		// Right-click shortcut: craft pages if full, or quick-equip into first matching empty slot
		tile.on('contextmenu', function (evt) {
			evt.preventDefault();
			if (_it.itemKind === 'page' && _it.canCraft) {
				self.wxTriggerCraftPages(_it.manualID);
				return;
			}
			var targetIdx = self.wxFindFirstEmptySlotFor(_it);
			if (targetIdx >= 0) {
				self.wxHandleDropOnSlot(_it, targetIdx);
			} else {
				self.wxShowToast('无空闲匹配插槽，请直接拖拽至目标插槽进行覆盖或灌注。', true);
			}
		});

		// Left-click craft shortcut on full page stack
		if (_it.itemKind === 'page' && _it.canCraft) {
			tile.on('dblclick', function () {
				self.wxTriggerCraftPages(_it.manualID);
			});
		}

		return tile;
	};

	CharacterScreenPerksModule.prototype.wxCanDropOnSlot = function (_item, _slotIndex) {
		var bro = this.mWXState && this.mWXState.brother;
		if (!bro || _slotIndex < 0 || _slotIndex >= bro.slots.length) return false;
		var slot = bro.slots[_slotIndex];
		if (!slot.unlocked) return false;

		if (_item.itemKind === 'pill_infuse') {
			return (slot.manualID !== null && !slot.isFragment && slot.tier < 3);
		}
		if (_item.itemKind === 'manual' || (_item.itemKind === 'page' && _item.allowFragmentLearn)) {
			for (var i = 0; i < slot.allowedCategories.length; i++) {
				if (slot.allowedCategories[i] === _item.category) return true;
			}
		}
		return false;
	};

	CharacterScreenPerksModule.prototype.wxFindFirstEmptySlotFor = function (_item) {
		var bro = this.mWXState && this.mWXState.brother;
		if (!bro) return -1;
		for (var i = 0; i < bro.slots.length; i++) {
			var s = bro.slots[i];
			if (_item.itemKind === 'pill_infuse') {
				if (this.wxCanDropOnSlot(_item, i)) return i;
			} else if (s.unlocked && !s.manualID && this.wxCanDropOnSlot(_item, i)) {
				return i;
			}
		}
		return -1;
	};

	CharacterScreenPerksModule.prototype.wxHighlightValidSlots = function (_item) {
		var self = this;
		this.mWXSlotsWrap.find('.wx-slot-box').each(function () {
			var idx = parseInt($(this).attr('data-slot-index'), 10);
			if (self.wxCanDropOnSlot(_item, idx)) {
				$(this).addClass('is-drop-valid');
			}
		});
	};

	CharacterScreenPerksModule.prototype.wxClearDropHighlights = function () {
		this.mWXSlotsWrap.find('.wx-slot-box').removeClass('is-drop-valid is-drop-hover');
	};

	CharacterScreenPerksModule.prototype.wxHandleDropOnSlot = function (_item, _slotIndex) {
		var self = this;
		var entityId = this.mWXCurrentEntityId;
		if (entityId === null) return;

		if (_item.itemKind === 'pill_infuse') {
			this.mDataSource.notifyBackendWXInfusePill(entityId, _item.stashIndex, _slotIndex, function (_res) {
				if (_res && _res.ok) {
					self.mWXState = _res;
					self.wxRenderAll();
					self.wxShowToast(_res.actionMessage, false);
				} else {
					self.wxShowToast((_res && _res.reason) ? _res.reason : '灌注失败。', true);
				}
			});
			return;
		}

		var isFrag = (_item.itemKind === 'page');
		this.wxSubmitEquip(entityId, _item.stashIndex, _slotIndex, isFrag, false);
	};

	CharacterScreenPerksModule.prototype.wxSubmitEquip = function (_entityId, _stashIndex, _slotIndex, _isFragment, _confirmed) {
		var self = this;
		this.mDataSource.notifyBackendWXEquipFromStash(_entityId, _stashIndex, _slotIndex, _isFragment, _confirmed, function (_res) {
			if (!_res) return;
			if (_res.needsConfirm) {
				self.wxOpenConfirmModal(_res, function () {
					self.wxSubmitEquip(_entityId, _stashIndex, _slotIndex, _isFragment, true);
				});
				return;
			}
			if (_res.ok) {
				self.mWXState = _res;
				self.wxRenderAll();
				self.wxShowToast(_res.actionMessage, false);
			} else {
				self.wxShowToast(_res.reason || '装入失败。', true);
			}
		});
	};

	CharacterScreenPerksModule.prototype.wxTriggerCraftPages = function (_manualID) {
		var self = this;
		this.mDataSource.notifyBackendWXCraftPages(this.mWXCurrentEntityId, _manualID, function (_res) {
			if (_res && _res.ok) {
				self.mWXState = _res;
				self.wxRenderAll();
				self.wxShowToast(_res.actionMessage, false);
			} else {
				self.wxShowToast((_res && _res.reason) ? _res.reason : '拼合失败。', true);
			}
		});
	};

	// ------------------------------------------------------------------------
	// 3. Tooltips
	// ------------------------------------------------------------------------
	CharacterScreenPerksModule.prototype.wxShowSlotTooltip = function (_s) {
		var html = '';
		if (!_s.unlocked) {
			html = '<div class="wx-tt-title">' + _s.slotLabel + '（未解锁）</div>' +
				'<div class="wx-tt-desc">角色达到 ' + _s.unlockLevel + ' 级后自动解锁该武学插槽。</div>';
		} else if (!_s.manualID) {
			html = '<div class="wx-tt-title">' + _s.slotLabel + '（空槽）</div>' +
				'<div class="wx-tt-desc">从下方行囊拖拽对应武学秘籍至此即可装配修习。</div>';
		} else {
			html = '<div class="wx-tt-title">' + _s.name + ' [' + _s.qualityLabel + ' · ' + _s.tierLabel + ']</div>';
			if (_s.isFragment) {
				html += '<div class="wx-tt-warn">⚠ 残本强修：最高止步一重，战斗行气有概率失控耗气！</div>';
			}
			html += '<div class="wx-tt-desc">' + _s.description + '</div>';
			for (var i = 0; i < _s.levelSummaries.length; i++) {
				var lv = _s.levelSummaries[i];
				var lit = (lv.tier <= _s.tier) ? ' is-unlocked' : '';
				html += '<div class="wx-tt-tier' + lit + '">' + lv.title + '：' + lv.text + '</div>';
			}
			if (!_s.isFragment && _s.tier < 3 && _s.expNeeded > 0) {
				html += '<div class="wx-tt-exp">当前火候：' + _s.exp + ' / ' + _s.expNeeded + '（可拖拽「凝神丸」灌注）</div>';
			}
			if (_s.blockedByReq && _s.missingReqs && _s.missingReqs.length > 0) {
				html += '<div class="wx-tt-warn">突破三重尚缺：' + _s.missingReqs.join('；') + '</div>';
			}
		}
		this.mWXTooltip.html(html).show();
	};

	CharacterScreenPerksModule.prototype.wxShowStashTooltip = function (_it) {
		var html = '<div class="wx-tt-title">' + _it.name + ' [' + _it.qualityLabel + ' · ' + _it.categoryLabel + ']</div>' +
			'<div class="wx-tt-desc">' + _it.description + '</div>';
		if (_it.itemKind === 'manual') {
			html += '<div class="wx-tt-tier is-unlocked">一重：' + _it.tier1Summary + '</div>';
			html += '<div class="wx-tt-tier">三重：' + _it.tier3Summary + '</div>';
			html += '<div class="wx-tt-exp">拖拽至上方对应武学插槽装配（或右键快装）。</div>';
		} else if (_it.itemKind === 'page') {
			html += '<div class="wx-tt-exp">残页进度：' + _it.totalPages + ' / ' + _it.fragmentsNeeded + '</div>';
			if (_it.canCraft) {
				html += '<div class="wx-tt-tier is-unlocked">右键或双击立即拼合完整秘籍！</div>';
			} else if (_it.allowFragmentLearn) {
				html += '<div class="wx-tt-warn">未集齐时拖拽至插槽可冒险「残本强修」（限一重且有走火入魔风险）。</div>';
			}
		} else if (_it.itemKind === 'pill_infuse') {
			html += '<div class="wx-tt-tier is-unlocked">拖拽至任意未满重武学插槽，立即灌注 +' + _it.expAmount + ' 火候。</div>';
		}
		this.mWXTooltip.html(html).show();
	};

	// ------------------------------------------------------------------------
	// 4. Scatter Overwrite / Fragment Confirm Modal
	// ------------------------------------------------------------------------
	CharacterScreenPerksModule.prototype.wxOpenConfirmModal = function (_info, _onConfirm) {
		var self = this;
		var lines = [];
		if (_info.isOverwrite) {
			lines.push('装入《' + _info.newManualName + '》将散去并永久销毁旧功法《' + _info.oldManualName + '》！');
			lines.push('角色将承受 ' + _info.penaltyDays + ' 天「散功虚弱」' + (_info.causesInternalInjury ? '，并附加轻度「内伤」（须服护心丹或调养）。' : '。'));
		}
		if (_info.isFragment) {
			lines.push('⚠ 残本强修风险：强行修炼残页最高止步一重，且实战行气存在失控耗气与走火入魔风险。');
		}

		var box = $(
			'<div class="wx-modal-box">' +
				'<div class="wx-modal-title">' + (_info.isOverwrite ? '散功重修确认' : '残本强修警告') + '</div>' +
				'<div class="wx-modal-body"><p>' + lines.join('</p><p>') + '</p></div>' +
				'<div class="wx-modal-actions">' +
					'<button type="button" class="wx-btn wx-btn-danger" data-wx="confirm-yes">确认执行</button>' +
					'<button type="button" class="wx-btn" data-wx="confirm-no">取消</button>' +
				'</div>' +
			'</div>'
		);

		box.find('[data-wx="confirm-yes"]').on('click', function () {
			self.mWXModal.hide().empty();
			_onConfirm();
		});
		box.find('[data-wx="confirm-no"]').on('click', function () {
			self.mWXModal.hide().empty();
		});

		this.mWXModal.empty().append(box).show();
	};

	// ------------------------------------------------------------------------
	// 5. Marrow Wash (洗经伐髓) Transparent Probability Modal
	// ------------------------------------------------------------------------
	CharacterScreenPerksModule.prototype.wxOpenWashModal = function () {
		var self = this;
		if (!this.mWXState || !this.mWXState.brother) return;
		var bro = this.mWXState.brother;
		var washPills = this.mWXState.washPillCount || 0;
		var protectPills = this.mWXState.protectPillCount || 0;
		var pendingChances = bro.pendingWashChances || 0;

		this.mWXWashState = {
			targetAttrIdx: -1,
			replaceAttrIdx: -1,
			useProtectPill: false,
			usePendingChance: (pendingChances > 0)
		};

		var attrHtml = '';
		for (var i = 0; i < 8; i++) {
			var stars = '';
			for (var st = 0; st < bro.talents[i]; st++) stars += '★';
			if (!stars) stars = '无星';
			attrHtml +=
				'<button type="button" class="wx-attr-btn" data-attr-idx="' + i + '">' +
					'<span class="wx-attr-name">' + bro.attrLabels[i] + ' (' + bro.baseStats[i] + ')</span>' +
					'<span class="wx-attr-stars">' + stars + '</span>' +
				'</button>';
		}

		var sourceLine = pendingChances > 0
			? '将消耗：孤本大成洗髓契机（余 ' + pendingChances + ' 次）'
			: ('将消耗：行囊「洗髓丹」（余 ' + washPills + ' 颗）');

		var box = $(
			'<div class="wx-modal-box wx-modal-wash">' +
				'<div class="wx-modal-title">✦ 洗经伐髓 · 重塑根骨（原版最多 3 项带星）</div>' +
				'<div class="wx-modal-body">' +
					'<div class="wx-wash-source">' + sourceLine + '</div>' +
					'<div class="wx-wash-label">1. 选择要冲击/开星的目标属性：</div>' +
					'<div class="wx-attr-grid" data-wx="wash-targets">' + attrHtml + '</div>' +
					'<div class="wx-wash-replace-wrap" data-wx="replace-wrap" style="display:none;">' +
						'<div class="wx-wash-label">2. 已有 3 项带星，请选择要洗去替换的旧带星属性（易筋换星）：</div>' +
						'<div class="wx-attr-grid" data-wx="wash-replaces"></div>' +
					'</div>' +
					'<label class="wx-protect-check">' +
						'<input type="checkbox" data-wx="use-protect"' + (protectPills <= 0 ? ' disabled="disabled"' : '') + ' />' +
						' 辅服「护脉丹」（余 ' + protectPills + ' 颗）：成功率 +5%，并免除失败永久暗疾风险' +
					'</label>' +
					'<div class="wx-wash-preview" data-wx="wash-preview">请选择目标属性查看实时成功率与风险。</div>' +
				'</div>' +
				'<div class="wx-modal-actions">' +
					'<button type="button" class="wx-btn wx-btn-danger" data-wx="wash-exec" disabled="disabled">开始洗髓</button>' +
					'<button type="button" class="wx-btn" data-wx="wash-close">关闭</button>' +
				'</div>' +
			'</div>'
		);

		box.find('[data-wx="wash-targets"] .wx-attr-btn').on('click', function () {
			var idx = parseInt($(this).attr('data-attr-idx'), 10);
			self.mWXWashState.targetAttrIdx = idx;
			self.mWXWashState.replaceAttrIdx = -1;
			box.find('[data-wx="wash-targets"] .wx-attr-btn').removeClass('is-selected');
			$(this).addClass('is-selected');
			self.wxUpdateWashReplaceList(box);
			self.wxQueryWashPreview(box);
		});

		box.find('[data-wx="use-protect"]').on('change', function () {
			self.mWXWashState.useProtectPill = $(this).is(':checked');
			self.wxQueryWashPreview(box);
		});

		box.find('[data-wx="wash-exec"]').on('click', function () {
			self.mDataSource.notifyBackendWXExecuteWash(
				self.mWXCurrentEntityId,
				self.mWXWashState.targetAttrIdx,
				self.mWXWashState.replaceAttrIdx,
				self.mWXWashState.useProtectPill,
				self.mWXWashState.usePendingChance,
				function (_res) {
					self.mWXModal.hide().empty();
					if (_res && _res.ok) {
						self.mWXState = _res;
						self.wxRenderAll();
						var okRoll = _res.washResult && _res.washResult.Succeeded;
						self.wxShowToast(_res.actionMessage, !okRoll);
					} else {
						self.wxShowToast((_res && _res.reason) ? _res.reason : '洗经伐髓未能执行。', true);
					}
				}
			);
		});

		box.find('[data-wx="wash-close"]').on('click', function () {
			self.mWXModal.hide().empty();
		});

		this.mWXModal.empty().append(box).show();
	};

	CharacterScreenPerksModule.prototype.wxUpdateWashReplaceList = function (_box) {
		var self = this;
		var bro = this.mWXState.brother;
		var targetIdx = this.mWXWashState.targetAttrIdx;
		var starredCount = 0;
		for (var k = 0; k < 8; k++) {
			if (bro.talents[k] > 0) starredCount++;
		}

		var wrap = _box.find('[data-wx="replace-wrap"]');
		var list = _box.find('[data-wx="wash-replaces"]').empty();

		if (targetIdx >= 0 && bro.talents[targetIdx] === 0 && starredCount >= 3) {
			for (var i = 0; i < 8; i++) {
				if (bro.talents[i] > 0) {
					var btn = $('<button type="button" class="wx-attr-btn" data-replace-idx="' + i + '">' + bro.attrLabels[i] + ' (' + bro.talents[i] + '★)</button>');
					btn.on('click', function () {
						self.mWXWashState.replaceAttrIdx = parseInt($(this).attr('data-replace-idx'), 10);
						list.find('.wx-attr-btn').removeClass('is-selected');
						$(this).addClass('is-selected');
						self.wxQueryWashPreview(_box);
					});
					list.append(btn);
				}
			}
			wrap.show();
		} else {
			wrap.hide();
		}
	};

	CharacterScreenPerksModule.prototype.wxQueryWashPreview = function (_box) {
		var self = this;
		var st = this.mWXWashState;
		var previewEl = _box.find('[data-wx="wash-preview"]');
		var execBtn = _box.find('[data-wx="wash-exec"]');
		var bro = this.mWXState.brother;
		var hasCost = ((this.mWXState.washPillCount || 0) > 0 || (bro.pendingWashChances || 0) > 0);

		if (st.targetAttrIdx < 0) {
			execBtn.prop('disabled', true);
			return;
		}

		this.mDataSource.notifyBackendWXGetWashPreview(
			this.mWXCurrentEntityId,
			st.targetAttrIdx,
			st.replaceAttrIdx,
			st.useProtectPill,
			function (_pv) {
				if (!_pv || !_pv.Ok) {
					previewEl.html('<span class="wx-tt-warn">' + ((_pv && _pv.Reason) ? _pv.Reason : '暂不可洗髓。') + '</span>');
					execBtn.prop('disabled', true);
					return;
				}
				var modeText = _pv.IsReplaceMode
					? ('易筋换星：洗去「' + _pv.ReplaceAttrName + '」原有星级 → 「' + _pv.TargetAttrName + '」升至 1★')
					: ('冲星升级：「' + _pv.TargetAttrName + '」' + _pv.CurrentStar + '★ → ' + _pv.NextStar + '★');
				var riskText = _pv.PermInjuryRisk > 0
					? ('失败必致重度内伤「经脉震荡」，且有 ' + _pv.PermInjuryRisk + '% 概率留下永久暗疾！')
					: '失败将消耗丹药并触发重度内伤「经脉震荡」（无永久暗疾风险）。';

				previewEl.html(
					'<div>' + modeText + '</div>' +
					'<div class="wx-chance-line">最终成功率：<strong>' + _pv.FinalChance + '%</strong>（基础 ' + _pv.BaseChance + '% + 筹备加成 +' + _pv.PrepBonus + '%）</div>' +
					'<div class="wx-tt-warn">' + riskText + '</div>'
				);
				execBtn.prop('disabled', !hasCost);
			}
		);
	};
})();
