/* ============================================================================
 * BB Wuxia Mod - 3-Tab Character Screen UI v2 (Vanilla-Isomorphic · ES3 Native)
 * 100% Vanilla Textures & Typography Palette (#dda21f / #d7b174 / #bd9d71 / #CD2626)
 *   - Tab 1 (兵甲行囊): Vanilla Stash + Actionable Glow + Quick Vault Store
 *   - Tab 2 (武学修为): 7 Perk-Style Acupoint Discs + Gold Meridian + Slot Shelf
 *   - Tab 3 (藏经阁): Vanilla Slot Grid + Leather Inspector + Craft/Infuse/Learn
 *   - Modals: Vanilla Wood-Plank Popup + Level-Up-Style Marrow Wash (洗经伐髓)
 * Strictly ES3-compliant: zero let/const/arrow/template-literals/class.
 * ============================================================================ */

(function () {
	'use strict';

	if (typeof CharacterScreenDatasource === 'undefined' || typeof CharacterScreenPerksModule === 'undefined') {
		return;
	}

	var WX_CN_NUM = ['零', '一', '二', '三', '四', '五', '六', '七', '八'];
	var WX_TIER_SHORT = ['', '一重', '二重', '三重'];
	var WX_CAT_LABELS = {
		neigong:  '内功心法',
		waigong:  '外功套路',
		qinggong: '轻功身法',
		henglian: '横练杂学'
	};
	var WX_CAT_EMBLEMS = {
		neigong:  'ui/perks/wx_emblem_neigong.png',
		waigong:  'ui/perks/wx_emblem_sword.png',
		qinggong: 'ui/perks/wx_emblem_qinggong.png',
		henglian: 'ui/perks/wx_emblem_henglian.png'
	};
	var WX_STAT_ICONS = [
		'health', 'fatigue', 'bravery', 'initiative',
		'melee_skill', 'ranged_skill', 'melee_defense', 'ranged_defense'
	];

	var wxGlobalToastTimer = null;
	function wxShowGlobalToast(_msg, _isError) {
		if (!_msg) return;
		if (window.WX_Showcase && window.WX_Showcase.plaque) {
			window.WX_Showcase.plaque({
				title: _isError ? '未能成行' : '武学传讯',
				message: _msg,
				icon: _isError ? 'ui/wx_icons/wx_seal_cinnabar.png' : 'ui/wx_icons/wx_icon_qi.png',
				isError: !!_isError
			});
			return;
		}
		var host = $('.character-screen-container:first');
		if (!host.length) return;
		var box = host.children('.wx-global-toast');
		if (!box.length) {
			box = $('<div class="wx-global-toast" style="display:none;"><span></span></div>');
			host.append(box);
		}
		if (wxGlobalToastTimer !== null) {
			clearTimeout(wxGlobalToastTimer);
			wxGlobalToastTimer = null;
		}
		box.removeClass('is-ok is-error').addClass(_isError ? 'is-error' : 'is-ok');
		box.children('span').text(_msg);
		box.stop(true, true).show();
		wxGlobalToastTimer = setTimeout(function () {
			box.fadeOut(220);
			wxGlobalToastTimer = null;
		}, 3200);
	}

	function wxEscapeHtml(_str) {
		if (_str === null || typeof _str === 'undefined') return '';
		return String(_str)
			.split('&').join('&amp;')
			.split('<').join('&lt;')
			.split('>').join('&gt;')
			.split('"').join('&quot;');
	}

	function wxCatsLabel(_cats) {
		if (!_cats || !_cats.length) return '任意武学';
		if (_cats.length >= 4) return '任意武学';
		var out = [];
		for (var i = 0; i < _cats.length; i++) {
			out.push(WX_CAT_LABELS[_cats[i]] || _cats[i]);
		}
		return out.join(' / ');
	}

	function wxXpBarHtml(_exp, _need, _isMax, _widthRem) {
		var pct = _isMax ? 100 : (_need > 0 ? Math.min(100, Math.floor((_exp / _need) * 100)) : 100);
		var st = _widthRem ? (' style="width:' + _widthRem + 'rem;"') : '';
		return '<div class="wx-vxp"' + st + '><div class="wx-f" style="width:' + pct + '%;"></div></div>';
	}

	function wxSwapSlotHtml(_iconPath, _isRound) {
		if (!_iconPath) return '<span class="wx-vslot"></span>';
		return '<span class="wx-vslot"><img class="wx-it' + (_isRound ? ' is-round' : '') + '" src="coui://gfx/' + _iconPath + '" alt=""/></span>';
	}

	function wxCreateScrollArea(_wrapDiv) {
		if (typeof _wrapDiv.createList === 'function') {
			var list = _wrapDiv.createList(2, null, true);
			var sc = list.findListScrollContainer();
			return {
				isNativeList: true,
				list: list,
				body: sc,
				refresh: function () {
					list.trigger('update', true);
				}
			};
		}
		var fallback = $('<div class="wx-fallback-scroll"></div>');
		_wrapDiv.append(fallback);
		return {
			isNativeList: false,
			list: null,
			body: fallback,
			refresh: function () {}
		};
	}

	function wxBindSafeInput(_input, _dataSource) {
		_input.on('keydown keyup keypress', function (_evt) {
			_evt.stopPropagation();
		});
		_input.on('focus', function () {
			if (_dataSource && _dataSource.notifyBackendPopupDialogIsVisible) {
				_dataSource.notifyBackendPopupDialogIsVisible(true);
			}
		});
		_input.on('blur', function () {
			if (_dataSource && _dataSource.notifyBackendPopupDialogIsVisible) {
				_dataSource.notifyBackendPopupDialogIsVisible(false);
			}
		});
	}

	// Shared Wood-Plank Popup Modal Manager on `.character-screen-container`
	var wxActiveModalDS = null;
	function wxOpenScreenModal(_box, _dataSource, _owner) {
		wxCloseScreenModal();
		var wash = _box.hasClass('wx-wash-dialog');
		var host = _owner ? _owner.closest(wash ? '.character-screen' : '.character-screen-container') : $('.character-screen-container:visible').last();
		if (!host.length) host = $(document.body);
		wxActiveModalDS = _dataSource || null;
		if (wxActiveModalDS && wxActiveModalDS.notifyBackendPopupDialogIsVisible) {
			wxActiveModalDS.notifyBackendPopupDialogIsVisible(true);
		}
		var backdrop = $('<div class="wx-modal-backdrop"></div>');
		if (wash) backdrop.addClass('wx-wash-backdrop');
		backdrop.append(_box);
		host.append(backdrop);

		backdrop.find('[data-wx-close="1"]').on('click', function () {
			wxCloseScreenModal();
		});
		backdrop.on('click', function (_e) {
			if ($(_e.target).hasClass('wx-modal-backdrop')) {
				wxCloseScreenModal();
			}
		});
		$(document).on('keydown.wxScreenModal', function (_e) {
			if ($('.wx-fx-backdrop').length > 0) return;
			if (_e.keyCode === 27) {
				wxCloseScreenModal();
				_e.stopPropagation();
				return false;
			}
		});
	}

	function wxCloseScreenModal() {
		var existing = $('.wx-modal-backdrop');
		if (existing.length) {
			existing.remove();
			$(document).off('keydown.wxScreenModal');
			if (wxActiveModalDS && wxActiveModalDS.notifyBackendPopupDialogIsVisible) {
				wxActiveModalDS.notifyBackendPopupDialogIsVisible(false);
			}
			wxActiveModalDS = null;
		}
	}

	function wxSetTabBadge(_btn, _count) {
		if (!_btn || !_btn.length) return;
		_btn.children('.wx-tab-badge').remove();
		if (_count && _count > 0) {
			_btn.append('<span class="wx-tab-badge">' + _count + '</span>');
		}
	}

	// ------------------------------------------------------------------------
	// 1. Datasource SQ.call Bridges & Live Vanilla State Sync
	// ------------------------------------------------------------------------
	var origNotifyEquipItem = CharacterScreenDatasource.prototype.notifyBackendEquipInventoryItem;
	CharacterScreenDatasource.prototype.notifyBackendEquipInventoryItem = function (_brotherId, _sourceItemId, _sourceItemIdx, _callback) {
		var ds = this;
		origNotifyEquipItem.call(this, _brotherId, _sourceItemId, _sourceItemIdx, function (_data) {
			if (_callback) {
				_callback(_data);
			}
			if (_data && typeof _data === 'object' && ('wxManualNotice' in _data) && _data.wxManualNotice) {
				if (_data.wxManualNotice.wxShowcase && window.WX_Showcase) {
					window.WX_Showcase.play(_data.wxManualNotice.wxShowcase, { sqHandle: ds.mSQHandle });
				} else {
					wxShowGlobalToast(_data.wxManualNotice.message, !_data.wxManualNotice.ok);
				}
				if (ds.mWXOnExternalStateChanged) {
					ds.mWXOnExternalStateChanged();
				}
			}
		});
	};

	function wxForceReloadProceduralPortrait(_imgPath) {
		if (!_imgPath) return;
		var prefix = (typeof Path !== 'undefined' && Path.PROCEDURAL) ? Path.PROCEDURAL : 'coui://';
		var fullSrc = (_imgPath.indexOf('coui://') === 0) ? _imgPath : (prefix + _imgPath);
		var entityPrefix = fullSrc;
		var qIdx = fullSrc.indexOf('?');
		if (qIdx > 0) entityPrefix = fullSrc.substring(0, qIdx);

		$('.character-screen-container img').each(function () {
			var el = $(this);
			var cur = el.attr('src') || '';
			if (cur === fullSrc || (entityPrefix.indexOf('procedural://') !== -1 && cur.indexOf(entityPrefix) === 0)) {
				el.attr('src', 'coui://gfx/ui/icons/action_points.png');
				setTimeout(function () {
					el.attr('src', fullSrc);
				}, 16);
			}
		});
	}

	var origUpdateBrother = CharacterScreenDatasource.prototype.updateBrother;
	if (typeof origUpdateBrother === 'function') {
		CharacterScreenDatasource.prototype.updateBrother = function (_data) {
			origUpdateBrother.call(this, _data);
			if (_data && typeof _data === 'object') {
				var imgPath = null;
				if (typeof CharacterScreenIdentifier !== 'undefined' && CharacterScreenIdentifier.Entity && (CharacterScreenIdentifier.Entity.ImagePath in _data)) {
					imgPath = _data[CharacterScreenIdentifier.Entity.ImagePath];
				} else if ('imagePath' in _data) {
					imgPath = _data.imagePath;
				}
				if (imgPath) {
					wxForceReloadProceduralPortrait(imgPath);
				}
				if (this.mWXOnExternalStateChanged && !this.mWXSuppressExtSync) {
					this.mWXOnExternalStateChanged();
				}
			}
		};
	}

	CharacterScreenDatasource.prototype.wxApplyVanillaSync = function (_res) {
		if (!_res || typeof _res !== 'object') return;
		this.mWXSuppressExtSync = true;
		try {
			if ('stashSpaceUsed' in _res) {
				this.mStashSpaceUsed = _res.stashSpaceUsed;
			}
			if ('stashSpaceMax' in _res) {
				this.mStashSpaceMax = _res.stashSpaceMax;
			}
			if (this.mInventoryModule && typeof this.mInventoryModule.updateSlotsLabel === 'function') {
				this.mInventoryModule.updateSlotsLabel();
			}
			if (('uiStash' in _res) && _res.uiStash !== null && jQuery.isArray(_res.uiStash)) {
				this.loadStashList(_res.uiStash);
			}
			if (('uiBrother' in _res) && _res.uiBrother !== null && typeof _res.uiBrother === 'object') {
				this.updateBrother(_res.uiBrother);
			}
		} finally {
			this.mWXSuppressExtSync = false;
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXGetState = function (_entityId, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXGetState', [_entityId], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXEquipLearned = function (_entityId, _slotIndex, _manualID, _confirmed, _callback, _expectedManualID) {
		if (this.mSQHandle !== null) {
			var args = [_entityId, _slotIndex, _manualID, _confirmed ? true : false];
			if (typeof _expectedManualID !== 'undefined') args.push(_expectedManualID);
			SQ.call(this.mSQHandle, 'onWXEquipLearned', args, _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXLearnAndEquip = function (_entityId, _slotIndex, _manualID, _isFragment, _confirmed, _callback, _expectedManualID) {
		if (this.mSQHandle !== null) {
			var args = [_entityId, _slotIndex, _manualID, _isFragment ? true : false, _confirmed ? true : false];
			if (typeof _expectedManualID !== 'undefined') args.push(_expectedManualID);
			SQ.call(this.mSQHandle, 'onWXLearnAndEquip', args, _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXUnequipSlot = function (_entityId, _slotIndex, _confirmed, _expectedManualID, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXUnequipSlot', [_entityId, _slotIndex, _confirmed ? true : false, _expectedManualID || null], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXLearnFromLibrary = function (_entityId, _manualID, _isFragment, _confirmed, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXLearnFromLibrary', [_entityId, _manualID, _isFragment ? true : false, _confirmed ? true : false], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXLibraryStoreAll = function (_entityId, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXLibraryStoreAll', [_entityId], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXLibraryWithdraw = function (_entityId, _manualID, _isPage, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXLibraryWithdraw', [_entityId, _manualID, _isPage ? true : false], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXLibrarySetAutoStore = function (_entityId, _enabled, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXLibrarySetAutoStore', [_entityId, _enabled ? true : false], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXLibraryCraft = function (_entityId, _manualID, _allowWildcard, _confirmed, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXLibraryCraft', [_entityId, _manualID, _allowWildcard ? true : false, _confirmed ? true : false], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXLibraryCraftAll = function (_entityId, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXLibraryCraftAll', [_entityId], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXInfusePill = function (_entityId, _stashIndex, _slotIndex, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXInfusePill', [_entityId, _stashIndex, _slotIndex], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXInfuseLibraryPage = function (_entityId, _pageManualID, _slotIndex, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXInfuseLibraryPage', [_entityId, _pageManualID, _slotIndex], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXUsePill = function (_entityId, _stashIndex, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXUsePill', [_entityId, _stashIndex], _callback);
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

	CharacterScreenDatasource.prototype.notifyBackendWXGetSectRelations = function (_callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXGetSectRelations', null, _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXSavePreset = function (_entityId, _presetIdx, _label, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXSavePreset', [_entityId, _presetIdx, _label || ''], _callback);
		}
	};

	CharacterScreenDatasource.prototype.notifyBackendWXApplyPreset = function (_entityId, _presetIdx, _confirmed, _callback) {
		if (this.mSQHandle !== null) {
			SQ.call(this.mSQHandle, 'onWXApplyPreset', [_entityId, _presetIdx, _confirmed ? true : false], _callback);
		}
	};

	// ------------------------------------------------------------------------
	// 2. Right Panel Header: 3 Vanilla Tab Buttons (兵甲行囊 | 武学修为 | 藏经阁)
	// ------------------------------------------------------------------------
	if (typeof CharacterScreenRightPanelHeaderModule !== 'undefined') {
		var origHdrCreateDIV = CharacterScreenRightPanelHeaderModule.prototype.createDIV;
		var origHdrDestroyDIV = CharacterScreenRightPanelHeaderModule.prototype.destroyDIV;
		var origHdrUpdateBro = CharacterScreenRightPanelHeaderModule.prototype.updateButtonsByBrother;
		var origHdrUpdateInvMode = CharacterScreenRightPanelHeaderModule.prototype.updateButtonsByInventoryMode;
		var origHdrSelectInv = CharacterScreenRightPanelHeaderModule.prototype.selectInventoryPanel;
		var origHdrSelectPerks = CharacterScreenRightPanelHeaderModule.prototype.selectPerksPanel;

		CharacterScreenRightPanelHeaderModule.prototype.mSwitchToWXLibraryButton = null;
		CharacterScreenRightPanelHeaderModule.prototype.mOnSwitchToWXLibraryCallback = null;

		CharacterScreenRightPanelHeaderModule.prototype.setOnSwitchToWXLibraryCallback = function (_cb) {
			this.mOnSwitchToWXLibraryCallback = _cb;
		};

		CharacterScreenRightPanelHeaderModule.prototype.wxSyncTabActive = function (_which) {
			if (this.mSwitchToInventoryButton) {
				this.mSwitchToInventoryButton.removeClass('is-selected');
				if (_which === 'inv') this.mSwitchToInventoryButton.addClass('is-selected');
			}
			if (this.mSwitchToPerksButton) {
				this.mSwitchToPerksButton.removeClass('is-selected');
				if (_which === 'perks') this.mSwitchToPerksButton.addClass('is-selected');
			}
			if (this.mSwitchToWXLibraryButton) {
				this.mSwitchToWXLibraryButton.removeClass('is-selected');
				if (_which === 'lib') this.mSwitchToWXLibraryButton.addClass('is-selected');
			}
		};

		CharacterScreenRightPanelHeaderModule.prototype.selectInventoryPanel = function () {
			if (typeof origHdrSelectInv === 'function') origHdrSelectInv.call(this);
			this.wxSyncTabActive('inv');
		};

		CharacterScreenRightPanelHeaderModule.prototype.selectPerksPanel = function () {
			if (typeof origHdrSelectPerks === 'function') origHdrSelectPerks.call(this);
			this.wxSyncTabActive('perks');
		};

		CharacterScreenRightPanelHeaderModule.prototype.selectWXLibraryPanel = function () {
			this.wxSyncTabActive('lib');
		};

		CharacterScreenRightPanelHeaderModule.prototype.wxUpdateTabLabels = function (_broMartial, _libSummary) {
			if (this.mSwitchToPerksButton) {
				this.mSwitchToPerksButton.findButtonText().html('武学修为');
				var hint = (_broMartial && _broMartial.equipableSlotHintCount) ? _broMartial.equipableSlotHintCount : 0;
				wxSetTabBadge(this.mSwitchToPerksButton, hint);
			}
			if (this.mSwitchToWXLibraryButton) {
				this.mSwitchToWXLibraryButton.findButtonText().html('藏经阁');
				if (_libSummary) {
					wxSetTabBadge(this.mSwitchToWXLibraryButton, _libSummary.craftableCount || 0);
				}
			}
		};

		CharacterScreenRightPanelHeaderModule.prototype.createDIV = function (_parentDiv) {
			var self = this;
			origHdrCreateDIV.call(this, _parentDiv);

			if (this.mSwitchToInventoryButton) {
				this.mSwitchToInventoryButton.findButtonText().html('兵甲行囊');
			}
			if (this.mSwitchToPerksButton) {
				this.mSwitchToPerksButton.findButtonText().html('武学修为');
			}

			var midContainer = this.mContainer.find('.buttons-container.is-middle:first');
			if (midContainer.length && !this.mSwitchToWXLibraryButton) {
				var libLayout = $('<div class="l-button is-wx-library"/>');
				midContainer.append(libLayout);
				this.mSwitchToWXLibraryButton = libLayout.createTabTextButton('藏经阁', function () {
					if (self.mOnSwitchToWXLibraryCallback !== null && jQuery.isFunction(self.mOnSwitchToWXLibraryCallback)) {
						self.mOnSwitchToWXLibraryCallback();
					} else if (self.mParent && typeof self.mParent.switchToWXLibrary === 'function') {
						self.mParent.switchToWXLibrary();
					}
				}, null, 'tab-button', 7);
			}
		};

		CharacterScreenRightPanelHeaderModule.prototype.destroyDIV = function () {
			if (this.mSwitchToWXLibraryButton) {
				this.mSwitchToWXLibraryButton.remove();
				this.mSwitchToWXLibraryButton = null;
			}
			origHdrDestroyDIV.call(this);
		};

		CharacterScreenRightPanelHeaderModule.prototype.updateButtonsByBrother = function (_brother) {
			origHdrUpdateBro.call(this, _brother);
			var wxM = (_brother && _brother.wxMartial) ? _brother.wxMartial : null;
			this.wxUpdateTabLabels(wxM, null);
		};

		if (typeof origHdrUpdateInvMode === 'function') {
			CharacterScreenRightPanelHeaderModule.prototype.updateButtonsByInventoryMode = function (_inventoryMode) {
				origHdrUpdateInvMode.call(this, _inventoryMode);
				if (!this.mSwitchToInventoryButton) return;
				if (typeof CharacterScreenDatasourceIdentifier !== 'undefined' && _inventoryMode === CharacterScreenDatasourceIdentifier.InventoryMode.Ground) {
					this.mSwitchToInventoryButton.findButtonText().html('地面拾遗');
				} else {
					this.mSwitchToInventoryButton.findButtonText().html('兵甲行囊');
				}
			};
		}
	}

	// ------------------------------------------------------------------------
	// 3. Tab 1 Strip: Hint & Quick "典籍入阁" Vanilla Short Button
	// ------------------------------------------------------------------------
	if (typeof CharacterScreenInventoryListModule !== 'undefined') {
		var origInvCreateDIV = CharacterScreenInventoryListModule.prototype.createDIV;
		var origInvDestroyDIV = CharacterScreenInventoryListModule.prototype.destroyDIV;
		var origInvModeUpdated = CharacterScreenInventoryListModule.prototype.onInventoryModeUpdated;

		CharacterScreenInventoryListModule.prototype.createDIV = function (_parentDiv) {
			var self = this;
			origInvCreateDIV.call(this, _parentDiv);

			if (this.mSlotCountPanel) {
				this.mWXStripHint = $('<div class="wx-stash-strip-hint">右键秘籍可直接研读；典籍入阁后不占仓库格</div>');
				this.mWXQuickStoreBtn = $('<div class="wx-stash-quick-store-btn" title="将仓库内秘籍与残页一键收入藏经阁">典籍入阁</div>');
				this.mSlotCountPanel.append(this.mWXStripHint);
				this.mSlotCountPanel.append(this.mWXQuickStoreBtn);
				this.mWXQuickStoreBtn.on('click', function () {
					var sel = self.mDataSource ? self.mDataSource.getSelectedBrother() : null;
					var eid = (sel && typeof sel.id !== 'undefined') ? sel.id : 0;
					self.mDataSource.notifyBackendWXLibraryStoreAll(eid, function (_res) {
						if (_res && _res.ok) {
							self.mDataSource.wxApplyVanillaSync(_res);
							wxShowGlobalToast(_res.actionMessage, false);
							if (self.mDataSource.mWXOnExternalStateChanged) {
								self.mDataSource.mWXOnExternalStateChanged(_res);
							}
						} else if (_res && _res.reason) {
							wxShowGlobalToast(_res.reason, true);
						}
					});
				});
			}
		};

		CharacterScreenInventoryListModule.prototype.destroyDIV = function () {
			if (this.mWXStripHint) {
				this.mWXStripHint.remove();
				this.mWXStripHint = null;
			}
			if (this.mWXQuickStoreBtn) {
				this.mWXQuickStoreBtn.remove();
				this.mWXQuickStoreBtn = null;
			}
			origInvDestroyDIV.call(this);
		};

		CharacterScreenInventoryListModule.prototype.onInventoryModeUpdated = function (_dataSource, _mode) {
			origInvModeUpdated.call(this, _dataSource, _mode);
			var showStashTools = (_dataSource && _dataSource.isInStashMode && _dataSource.isInStashMode());
			if (this.mWXStripHint) {
				if (showStashTools) this.mWXStripHint.show();
				else this.mWXStripHint.hide();
			}
			if (this.mWXQuickStoreBtn) {
				if (showStashTools) this.mWXQuickStoreBtn.show();
				else this.mWXQuickStoreBtn.hide();
			}
		};
	}

	// ------------------------------------------------------------------------
	// 4. Tab 3 Module: CharacterScreenWuxiaLibraryModule (藏经阁 — 原版仓库同构)
	// ------------------------------------------------------------------------
	var CharacterScreenWuxiaLibraryModule = function (_parent, _dataSource) {
		this.mParent = _parent;
		this.mDataSource = _dataSource;
		this.mContainer = null;
		this.mScrollArea = null;
		this.mState = null;
		this.mCurrentEntityId = null;
		this.mKindFilter = 'all'; // 'all' | 'page'
		this.mCatFilter = null;   // null | 'neigong' | 'waigong' | 'qinggong' | 'henglian'
		this.mWeaponOnly = false;
		this.mUnlearnedOnly = false;
		this.mSearchQuery = '';
		this.mInspectedKey = null;

		this.mDataSource.addListener(CharacterScreenDatasourceIdentifier.Brother.Updated, jQuery.proxy(this.onBrotherUpdated, this));
		this.mDataSource.addListener(CharacterScreenDatasourceIdentifier.Brother.Selected, jQuery.proxy(this.onBrotherSelected, this));
	};

	CharacterScreenWuxiaLibraryModule.prototype.register = function (_parentDiv) {
		if (this.mContainer !== null) return;
		this.mContainer = $('<div class="wx-library-module opacity-none no-pointer-events"/>');
		_parentDiv.append(this.mContainer);
		this.buildDOM();
	};

	CharacterScreenWuxiaLibraryModule.prototype.unregister = function () {
		wxCloseScreenModal();
		if (this.mScrollArea && this.mScrollArea.isNativeList && this.mScrollArea.list) {
			this.mScrollArea.list.destroyList();
		}
		this.mScrollArea = null;
		if (this.mContainer !== null) {
			this.mContainer.empty();
			this.mContainer.remove();
			this.mContainer = null;
		}
	};

	CharacterScreenWuxiaLibraryModule.prototype.show = function () {
		if (!this.mContainer) return;
		this.mContainer.removeClass('opacity-none no-pointer-events').addClass('opacity-full is-top');
		this.refreshFromBackend();
	};

	CharacterScreenWuxiaLibraryModule.prototype.hide = function () {
		if (!this.mContainer) return;
		wxCloseScreenModal();
		this.mContainer.removeClass('opacity-full is-top').addClass('opacity-none no-pointer-events');
	};

	CharacterScreenWuxiaLibraryModule.prototype.isVisible = function () {
		return this.mContainer !== null && this.mContainer.hasClass('opacity-full');
	};

	CharacterScreenWuxiaLibraryModule.prototype.onBrotherUpdated = function (_ds, _brother) {
		if (_ds.isSelectedBrother(_brother)) {
			this.onBrotherSelected(_ds, _brother);
		}
	};

	CharacterScreenWuxiaLibraryModule.prototype.onBrotherSelected = function (_ds, _brother) {
		if (!_brother) return;
		if (typeof CharacterScreenIdentifier !== 'undefined' && CharacterScreenIdentifier.Entity && (CharacterScreenIdentifier.Entity.Id in _brother)) {
			this.mCurrentEntityId = _brother[CharacterScreenIdentifier.Entity.Id];
		} else if (typeof _brother.id !== 'undefined') {
			this.mCurrentEntityId = _brother.id;
		}
		if (this.isVisible()) {
			this.refreshFromBackend();
		}
	};

	CharacterScreenWuxiaLibraryModule.prototype.buildDOM = function () {
		var self = this;
		this.mPanel = $('<div class="wx-lib-panel"></div>');
		this.mContainer.append(this.mPanel);

		this.mFilterBar = $(
			'<div class="wx-fbar">' +
				'<span class="wx-vb wx-vb3 is-sel" data-lib="flt-all" title="全部典籍"><img class="is-flat" src="coui://gfx/ui/buttons/filter_all.png" alt=""/></span>' +
				'<span class="wx-vb wx-vb3" data-lib-cat="neigong" title="内功心法"><img src="coui://gfx/' + WX_CAT_EMBLEMS.neigong + '" alt=""/></span>' +
				'<span class="wx-vb wx-vb3" data-lib-cat="waigong" title="外功套路"><img src="coui://gfx/' + WX_CAT_EMBLEMS.waigong + '" alt=""/></span>' +
				'<span class="wx-vb wx-vb3" data-lib-cat="qinggong" title="轻功身法"><img src="coui://gfx/' + WX_CAT_EMBLEMS.qinggong + '" alt=""/></span>' +
				'<span class="wx-vb wx-vb3" data-lib-cat="henglian" title="横练杂学"><img src="coui://gfx/' + WX_CAT_EMBLEMS.henglian + '" alt=""/></span>' +
				'<span class="wx-gap"></span>' +
				'<span class="wx-vb wx-vb3" data-lib="flt-page" title="只看残页"><img src="coui://gfx/ui/items/misc/wx_page_sect.png" alt=""/></span>' +
				'<span class="wx-vb wx-vb3" data-lib="wpn-only" title="适配当前主手兵器"><img class="is-flat" src="coui://gfx/ui/buttons/filter_weapons.png" alt=""/></span>' +
				'<span class="wx-vb wx-vb3" data-lib="unl-only" title="只看当前侠客未习"><img src="coui://gfx/ui/icons/unlocked_small.png" alt=""/></span>' +
				'<span class="wx-gap"></span>' +
				'<input type="text" class="wx-vinput" data-lib="search" placeholder="搜秘籍" />' +
				'<span class="wx-r">' +
					'<span class="wx-vb wx-vb2 is-dis" data-lib="craft-all" style="width:9.0rem;margin-right:0.25rem;" title="一键拼合已凑齐残页">拼合</span>' +
					'<span class="wx-vb wx-vb3" data-lib="open-alc" style="margin-right:0.25rem;" title="丹经与药柜录（随身翻阅；开炉炼丹、神兵重锻与存取奇材请赴城镇百工丹坊）"><img src="coui://gfx/ui/wx_icons/wx_glyph_herb_cabinet.png" alt=""/></span>' +
					'<span class="wx-vb wx-vb3" data-lib="open-sects" title="江湖宗门名刺录（随身翻阅；结交请教请赴迎客酒肆茶座或独立山门）"><img src="coui://gfx/ui/wx_icons/wx_glyph_sect_token.png" alt=""/></span>' +
				'</span>' +
			'</div>'
		);
		this.mPanel.append(this.mFilterBar);

		this.mToast = $('<div class="wx-toast" style="display:none;"><span></span></div>');
		this.mPanel.append(this.mToast);

		var gridHost = $('<div class="wx-lib-g wx-scroll-host"></div>');
		this.mInspector = $(
			'<div class="wx-insp is-lib">' +
				'<div class="wx-insp-body" data-lib="insp-body"></div>' +
				'<div class="wx-insp-foot" data-lib="insp-foot"></div>' +
			'</div>'
		);
		this.mStrip = $('<div class="wx-strip"></div>');

		this.mPanel.append(gridHost);
		this.mPanel.append(this.mInspector);
		this.mPanel.append(this.mStrip);

		this.mScrollArea = wxCreateScrollArea(gridHost);
		this.mInspBody = this.mInspector.find('[data-lib="insp-body"]');
		this.mInspFoot = this.mInspector.find('[data-lib="insp-foot"]');
		this.mVisibleSlotMap = {};

		this.mScrollArea.body.on('click', '.wx-vslot', function () {
			var slot = $(this);
			var key = slot.attr('data-lib-key');
			var it = key ? self.mVisibleSlotMap[key] : null;
			if (!it) return;
			self.mInspectedKey = key;
			self.mScrollArea.body.find('.wx-vslot .wx-sring').remove();
			slot.append('<div class="wx-sring"></div>');
			self.renderInspector(it);
		});

		this.mScrollArea.body.on('contextmenu dblclick', '.wx-vslot', function (_e) {
			_e.preventDefault();
			_e.stopPropagation();
			var key = $(this).attr('data-lib-key');
			var it = key ? self.mVisibleSlotMap[key] : null;
			if (!it) return false;
			self.mInspectedKey = key;
			var isPage = (it.itemKind === 'page');
			if (!isPage && !it.alreadyLearned) {
				self.executeCardAction(it, 'learn');
			} else if (isPage && it.canCraft) {
				self.executeCardAction(it, 'craft');
			} else {
				self.renderGrid();
			}
			return false;
		});

		this.mFilterBar.find('[data-lib="flt-all"]').on('click', function () {
			self.mKindFilter = 'all';
			self.mCatFilter = null;
			self.syncFilterButtons();
			self.renderGrid();
		});

		this.mFilterBar.find('[data-lib-cat]').on('click', function () {
			var c = $(this).attr('data-lib-cat');
			self.mCatFilter = (self.mCatFilter === c) ? null : c;
			self.syncFilterButtons();
			self.renderGrid();
		});

		this.mFilterBar.find('[data-lib="flt-page"]').on('click', function () {
			self.mKindFilter = (self.mKindFilter === 'page') ? 'all' : 'page';
			self.syncFilterButtons();
			self.renderGrid();
		});

		this.mFilterBar.find('[data-lib="wpn-only"]').on('click', function () {
			self.mWeaponOnly = !self.mWeaponOnly;
			self.syncFilterButtons();
			self.renderGrid();
		});

		this.mFilterBar.find('[data-lib="unl-only"]').on('click', function () {
			self.mUnlearnedOnly = !self.mUnlearnedOnly;
			self.syncFilterButtons();
			self.renderGrid();
		});

		var searchInput = this.mFilterBar.find('[data-lib="search"]');
		wxBindSafeInput(searchInput, this.mDataSource);
		searchInput.on('keyup change input', function () {
			var raw = $(this).val() || '';
			self.mSearchQuery = raw.replace(/^\s+|\s+$/g, '').toLowerCase();
			self.renderGrid();
		});

		this.mFilterBar.find('[data-lib="craft-all"]').on('click', function () {
			if ($(this).hasClass('is-dis')) return;
			self.mDataSource.notifyBackendWXLibraryCraftAll(self.getEntityId(), function (_res) {
				self.handleBackendResponse(_res);
			});
		});

		this.mFilterBar.find('[data-lib="open-alc"]').on('click', function () {
			if (window.WX_OpenAlchemyCauldron && self.mDataSource && self.mDataSource.mSQHandle) {
				window.WX_OpenAlchemyCauldron(self.mDataSource.mSQHandle, self.mDataSource, null, self.getEntityId(), 'cauldron');
			}
		});

		this.mFilterBar.find('[data-lib="open-sects"]').on('click', function () {
			if (window.WX_OpenSectDirectory && self.mDataSource && self.mDataSource.mSQHandle) {
				window.WX_OpenSectDirectory(self.mDataSource.mSQHandle, self.mDataSource);
			}
		});
	};

	CharacterScreenWuxiaLibraryModule.prototype.syncFilterButtons = function () {
		var self = this;
		this.mFilterBar.find('[data-lib="flt-all"]').toggleClass('is-sel', this.mKindFilter === 'all' && !this.mCatFilter);
		this.mFilterBar.find('[data-lib="flt-page"]').toggleClass('is-sel', this.mKindFilter === 'page');
		this.mFilterBar.find('[data-lib="wpn-only"]').toggleClass('is-sel', this.mWeaponOnly);
		this.mFilterBar.find('[data-lib="unl-only"]').toggleClass('is-sel', this.mUnlearnedOnly);
		this.mFilterBar.find('[data-lib-cat]').each(function () {
			$(this).toggleClass('is-sel', $(this).attr('data-lib-cat') === self.mCatFilter);
		});
	};

	CharacterScreenWuxiaLibraryModule.prototype.getEntityId = function () {
		if (this.mCurrentEntityId !== null) return this.mCurrentEntityId;
		var sel = this.mDataSource ? this.mDataSource.getSelectedBrother() : null;
		if (sel && typeof sel.id !== 'undefined') {
			this.mCurrentEntityId = sel.id;
			return sel.id;
		}
		return 0;
	};

	CharacterScreenWuxiaLibraryModule.prototype.showToast = function (_msg, _isError) {
		if (!this.mToast || !_msg) return;
		var toast = this.mToast;
		if (this.mToastTimer) clearTimeout(this.mToastTimer);
		toast.removeClass('is-ok is-error').addClass(_isError ? 'is-error' : 'is-ok');
		toast.children('span').text(_msg);
		toast.stop(true, true).show();
		this.mToastTimer = setTimeout(function () {
			toast.fadeOut(200);
		}, 3200);
	};

	CharacterScreenWuxiaLibraryModule.prototype.openModal = function (_box) {
		wxOpenScreenModal(_box, this.mDataSource);
	};

	CharacterScreenWuxiaLibraryModule.prototype.closeModal = function () {
		wxCloseScreenModal();
	};

	CharacterScreenWuxiaLibraryModule.prototype.refreshFromBackend = function () {
		var self = this;
		var eid = this.getEntityId();
		this.mDataSource.notifyBackendWXGetState(eid, function (_res) {
			if (_res && _res.ok) {
				self.applyState(_res);
				if (_res.autoStoreNotice) {
					self.showToast(_res.autoStoreNotice, false);
				}
			}
		});
	};

	CharacterScreenWuxiaLibraryModule.prototype.handleBackendResponse = function (_res) {
		if (!_res) return;
		if (_res.ok) {
			this.mDataSource.wxApplyVanillaSync(_res);
			this.applyState(_res);
			if (_res.actionMessage) {
				this.showToast(_res.actionMessage, false);
			}
			if (this.mParent && this.mParent.mPerksModule && this.mParent.mPerksModule.wxSyncCachedState) {
				this.mParent.mPerksModule.wxSyncCachedState(_res);
			}
		} else if (_res.reason) {
			this.showToast(_res.reason, true);
		}
	};

	CharacterScreenWuxiaLibraryModule.prototype.applyState = function (_data) {
		this.mState = _data;
		if (this.mParent && this.mParent.mHeaderModule && this.mParent.mHeaderModule.wxUpdateTabLabels) {
			this.mParent.mHeaderModule.wxUpdateTabLabels(_data.brother, _data.library ? _data.library.summary : null);
		}
		this.syncFilterButtons();
		this.renderHeaderAndStrip();
		this.renderGrid();
	};

	CharacterScreenWuxiaLibraryModule.prototype.renderHeaderAndStrip = function () {
		var self = this;
		var lib = (this.mState && this.mState.library) ? this.mState.library : null;
		if (!lib) return;

		var sum = lib.summary || { totalManuals: 0, totalPages: 0, craftableCount: 0 };
		var craftBtn = this.mFilterBar.find('[data-lib="craft-all"]');
		if (sum.craftableCount > 0) {
			craftBtn.removeClass('is-dis').html('拼合<span class="wx-cnt">' + sum.craftableCount + '</span>');
		} else {
			craftBtn.addClass('is-dis').html('拼合');
		}

		var mov = lib.stashMovable || { slots: 0 };
		var storeCls = 'wx-vb wx-vb2' + (mov.slots > 0 ? '' : ' is-dis');
		var storeCnt = mov.slots > 0 ? ('<span class="wx-cnt">' + mov.slots + '</span>') : '';

		this.mStrip.html(
			'<span class="wx-vchk' + (lib.autoStore ? ' is-on' : '') + '" data-lib="toggle-auto" title="战利品与购入的秘籍、残页自动收入藏经阁"><i></i>自动入阁</span>' +
			'<span class="wx-r">' +
				'<span class="' + storeCls + '" data-lib="store-all" style="width:8.6rem;height:3.3rem;line-height:3.4rem;margin-right:1.2rem;">收纳' + storeCnt + '</span>' +
				'<img src="coui://gfx/ui/items/misc/wx_book_neigong_sect.png" alt=""/>' + sum.totalManuals + ' 册　' +
				'<img src="coui://gfx/ui/items/misc/wx_page_sect.png" alt=""/>' + sum.totalPages + ' 页' +
			'</span>'
		);

		this.mStrip.find('[data-lib="toggle-auto"]').on('click', function () {
			var cur = (self.mState && self.mState.library) ? self.mState.library.autoStore : true;
			self.mDataSource.notifyBackendWXLibrarySetAutoStore(self.getEntityId(), !cur, function (_res) {
				self.handleBackendResponse(_res);
			});
		});

		this.mStrip.find('[data-lib="store-all"]').on('click', function () {
			if ($(this).hasClass('is-dis')) return;
			self.mDataSource.notifyBackendWXLibraryStoreAll(self.getEntityId(), function (_res) {
				self.handleBackendResponse(_res);
			});
		});
	};

	CharacterScreenWuxiaLibraryModule.prototype.passesFilter = function (_it) {
		if (this.mKindFilter === 'page' && _it.itemKind !== 'page') return false;
		if (this.mCatFilter && _it.category !== this.mCatFilter) return false;
		if (this.mWeaponOnly && !_it.matchesWeapon) return false;
		if (this.mUnlearnedOnly && _it.alreadyLearned) return false;
		if (this.mSearchQuery && this.mSearchQuery.length > 0) {
			var hay = ((_it.name || '') + ' ' + (_it.description || '') + ' ' + (_it.categoryLabel || '') + ' ' + (_it.qualityLabel || '') + ' ' + (_it.weaponLabel || '')).toLowerCase();
			if (hay.indexOf(this.mSearchQuery) === -1) return false;
		}
		return true;
	};

	CharacterScreenWuxiaLibraryModule.prototype.renderGrid = function () {
		var body = this.mScrollArea.body;
		var items = (this.mState && this.mState.library && this.mState.library.items) ? this.mState.library.items : [];
		var shown = 0;
		var firstShown = null;
		var inspectedFound = null;
		var slotMap = {};
		var htmlParts = [];

		for (var i = 0; i < items.length; i++) {
			var it = items[i];
			if (!this.passesFilter(it)) continue;
			var key = it.itemKind + ':' + it.manualID;
			slotMap[key] = it;
			if (!firstShown) firstShown = it;
			if (this.mInspectedKey === key) inspectedFound = it;

			htmlParts.push(this.buildLibrarySlotHtml(it, key));
			shown++;
		}
		this.mVisibleSlotMap = slotMap;

		var toInspect = inspectedFound || firstShown;
		if (shown === 0) {
			body.html('<div class="wx-c-desc" style="padding:2.4rem 1.2rem;">没有符合筛选条件的秘籍或残页。</div>');
		} else {
			htmlParts.push('<div class="wx-clear"></div>');
			body.html(htmlParts.join(''));
			if (toInspect) {
				this.mInspectedKey = toInspect.itemKind + ':' + toInspect.manualID;
				body.find('[data-lib-key="' + this.mInspectedKey + '"]').append('<div class="wx-sring"></div>');
			}
		}

		this.mScrollArea.refresh();

		if (toInspect) {
			this.renderInspector(toInspect);
		} else {
			this.mInspBody.html('<div class="wx-c-desc" style="padding:1.6rem 0.4rem;">左键点击秘籍或残页查看详情；右键整本秘籍可直接传授当前侠客。</div>');
			this.mInspFoot.empty();
		}
	};

	CharacterScreenWuxiaLibraryModule.prototype.buildLibrarySlotHtml = function (_it, _key) {
		var isPage = (_it.itemKind === 'page');
		var dimCls = (!isPage && _it.alreadyLearned) ? ' is-dim' : '';
		var hlHtml = (isPage && _it.canCraft) ? '<div class="wx-hl"></div>' : '';
		var tagHtml = '';
		if (isPage && !_it.canCraft && _it.canWildcardCraft) {
			tagHtml = '<span class="wx-tag">补</span>';
		} else if (!isPage && !_it.alreadyLearned && _it.learnedIsFragment) {
			tagHtml = '<span class="wx-tag">补</span>';
		}
		var amtText = isPage ? (_it.count + '/' + _it.fragmentsNeeded) : String(_it.count);

		return (
			'<div class="wx-vslot' + dimCls + '" data-lib-key="' + _key + '">' +
				hlHtml +
				'<img class="wx-it" src="coui://gfx/' + _it.icon + '" alt=""/>' +
				tagHtml +
				'<span class="wx-amt">' + amtText + '</span>' +
			'</div>'
		);
	};

	CharacterScreenWuxiaLibraryModule.prototype.renderInspector = function (_it) {
		var self = this;
		var bro = (this.mState && this.mState.brother) ? this.mState.brother : null;
		var broName = bro ? bro.name : '当前侠客';
		var isPage = (_it.itemKind === 'page');

		var sub = wxEscapeHtml(_it.qualityLabel) + ' · ' + wxEscapeHtml(_it.categoryLabel) +
			(_it.weaponLabel ? (' · ' + wxEscapeHtml(_it.weaponLabel)) : '');

		var html =
			'<div class="wx-hd">' +
				'<img src="coui://gfx/' + _it.icon + '" alt=""/>' +
				'<div class="wx-t-title">《' + wxEscapeHtml(_it.name) + '》' + (isPage ? '残页' : '') + '</div>' +
				'<div class="wx-s">' + sub + '</div>' +
				'<div class="wx-s wx-c-desc">估价 ' + _it.basePrice + ' 两</div>' +
			'</div>';

		if (isPage) {
			html += '<div class="wx-ln"><span class="wx-c-label">残页　</span><span class="wx-c-title">' + _it.count + ' / ' + _it.fragmentsNeeded + '</span>' +
				(_it.canCraft ? '　<span class="wx-c-title">已凑齐可装帧</span>' : (_it.canWildcardCraft ? '　<span class="wx-c-desc">可 2:1 同阶补缺</span>' : '')) + '</div>';
		} else {
			html += '<div class="wx-ln"><span class="wx-c-label">馆藏　</span><span class="wx-c-title">' + _it.count + ' 册</span>' +
				'　<span class="wx-c-label">同袍已习　</span><span class="wx-c-title">' + (_it.learnedByCount > 0 ? (_it.learnedByCount + ' 人') : '无') + '</span></div>';
		}

		if (_it.weaponLabel && !_it.matchesWeapon) {
			html += '<div class="wx-ln wx-c-neg">当前主手非' + wxEscapeHtml(_it.weaponLabel) + '，外功暂不生效</div>';
		}

		html += '<div class="wx-desc">' + wxEscapeHtml(_it.description) + '</div>';

		var summaries = _it.levelSummaries || [];
		for (var i = 0; i < summaries.length; i++) {
			var lv = summaries[i];
			html += '<div class="wx-tl is-done"><b>' + wxEscapeHtml(lv.title) + '</b>' + wxEscapeHtml(lv.text) + '</div>';
		}

		if (_it.missingReqs && _it.missingReqs.length > 0) {
			html += '<div class="wx-ln"><span class="wx-c-label">大成门槛　</span><span class="wx-c-neg">' + wxEscapeHtml(_it.missingReqs.join('　')) + '</span></div>';
		}

		var foot = '';
		if (!isPage) {
			foot += '<span class="wx-vb wx-vb2" data-iact="withdraw" title="取出 1 册至战团仓库">取出</span>';
			if (_it.alreadyLearned) {
				foot += '<span class="wx-vb wx-vb2 is-dis">' + wxEscapeHtml(broName) + '已习</span>';
			} else {
				foot += '<span class="wx-vb wx-vb2" data-iact="learn">' + (_it.learnedIsFragment ? '补全' : '研习') + '</span>';
			}
		} else {
			foot += '<span class="wx-vb wx-vb2" data-iact="infuse" style="width:6.4rem;" title="消耗 1 张残页注入已装功法火候">化功</span>';
			if (_it.canCraft) {
				foot += '<span class="wx-vb wx-vb2" data-iact="craft" style="width:6.4rem;">装帧</span>';
			} else if (_it.canWildcardCraft) {
				foot += '<span class="wx-vb wx-vb2" data-iact="wild" style="width:6.4rem;">补缺</span>';
			} else if (_it.allowFragmentLearn && !_it.alreadyLearned && !_it.learnedIsFragment) {
				foot += '<span class="wx-vb wx-vb2" data-iact="frag-learn" style="width:6.4rem;">强修</span>';
			}
			foot += '<span class="wx-vb wx-vb2" data-iact="withdraw" style="width:6.4rem;">取出</span>';
		}

		this.mInspBody.html(html);
		this.mInspFoot.html(foot);
		this.mInspFoot.find('[data-iact]').on('click', function () {
			if ($(this).hasClass('is-dis')) return;
			self.executeCardAction(_it, $(this).attr('data-iact'));
		});
	};

	CharacterScreenWuxiaLibraryModule.prototype.executeCardAction = function (_it, _act) {
		var self = this;
		var eid = this.getEntityId();

		if (_act === 'learn') {
			this.mDataSource.notifyBackendWXLearnFromLibrary(eid, _it.manualID, false, false, function (_res) {
				self.handleBackendResponse(_res);
			});
		} else if (_act === 'frag-learn') {
			this.triggerFragmentLearn(_it);
		} else if (_act === 'withdraw') {
			this.mDataSource.notifyBackendWXLibraryWithdraw(eid, _it.manualID, _it.itemKind === 'page', function (_res) {
				self.handleBackendResponse(_res);
			});
		} else if (_act === 'craft') {
			this.mDataSource.notifyBackendWXLibraryCraft(eid, _it.manualID, false, false, function (_res) {
				self.handleBackendResponse(_res);
			});
		} else if (_act === 'wild') {
			this.triggerWildcardCraft(_it.manualID, false);
		} else if (_act === 'infuse') {
			this.openPageInfuseSlotModal(_it);
		}
	};

	CharacterScreenWuxiaLibraryModule.prototype.triggerFragmentLearn = function (_it) {
		var self = this;
		var eid = this.getEntityId();
		this.mDataSource.notifyBackendWXLearnFromLibrary(eid, _it.manualID, true, false, function (_res) {
			if (!_res) return;
			if (_res.needsConfirm) {
				var box = $(
					'<div class="wx-popup">' +
						'<div class="wx-ph wx-t-title">残本强修</div>' +
						'<div class="wx-pb">' +
							'<div class="wx-swap">' + wxSwapSlotHtml(_it.icon, false) + '</div>' +
							'消耗 1 张《' + wxEscapeHtml(_it.name) + '》残页强记残缺口诀。<br/>' +
							'<span class="wx-c-neg">最高止步一重，实战偶有行气不畅。</span><br/>' +
							'<span class="wx-c-desc">日后研读同名整本可无损补全。</span>' +
						'</div>' +
						'<div class="wx-pf">' +
							'<span class="wx-vb wx-vb1" data-m="yes">确定</span>' +
							'<span class="wx-vb wx-vb1" data-wx-close="1">取消</span>' +
						'</div>' +
					'</div>'
				);
				box.find('[data-m="yes"]').on('click', function () {
					self.closeModal();
					self.mDataSource.notifyBackendWXLearnFromLibrary(eid, _it.manualID, true, true, function (_res2) {
						self.handleBackendResponse(_res2);
					});
				});
				self.openModal(box);
			} else {
				self.handleBackendResponse(_res);
			}
		});
	};

	CharacterScreenWuxiaLibraryModule.prototype.triggerWildcardCraft = function (_manualID, _confirmed) {
		var self = this;
		var eid = this.getEntityId();
		this.mDataSource.notifyBackendWXLibraryCraft(eid, _manualID, true, _confirmed, function (_res) {
			if (!_res) return;
			if (_res.needsWildcardConfirm || _res.needsConfirm) {
				var pv = _res.preview || _res;
				var mName = pv.manualName || '';
				var missP = pv.missingPages || 0;
				var spareN = pv.spareNeeded || pv.wildcardBurned || 0;
				var donors = pv.sacrificedList || pv.donorSummary || [];
				var box = $(
					'<div class="wx-popup">' +
						'<div class="wx-ph wx-t-title">同阶补缺</div>' +
						'<div class="wx-pb">' +
							'为装帧完整《' + wxEscapeHtml(mName) + '》（差 ' + missP + ' 页），将消耗同阶闲置残页 <span class="wx-c-title">' + spareN + '</span> 张：<br/>' +
							'<span class="wx-c-desc">' + wxEscapeHtml(donors.join('、')) + '</span>' +
						'</div>' +
						'<div class="wx-pf">' +
							'<span class="wx-vb wx-vb1" data-m="yes">确定</span>' +
							'<span class="wx-vb wx-vb1" data-wx-close="1">取消</span>' +
						'</div>' +
					'</div>'
				);
				box.find('[data-m="yes"]').on('click', function () {
					self.closeModal();
					self.triggerWildcardCraft(_manualID, true);
				});
				self.openModal(box);
			} else {
				self.handleBackendResponse(_res);
			}
		});
	};

	CharacterScreenWuxiaLibraryModule.prototype.openPageInfuseSlotModal = function (_pageItem) {
		var self = this;
		var bro = (this.mState && this.mState.brother) ? this.mState.brother : null;
		if (!bro) return;

		var rowsHtml = '';
		var validCount = 0;
		for (var i = 0; i < bro.slots.length; i++) {
			var s = bro.slots[i];
			if (!s.unlocked || !s.manualID || s.isFragment || s.tier >= 3 || s.isSealed) continue;
			validCount++;
			var mult = 1.0;
			var tag = '';
			if (s.manualID === _pageItem.manualID) { mult = 1.5; tag = ' · 同名 +50%'; }
			else if (s.category === _pageItem.category) { mult = 1.25; tag = ' · 同脉 +25%'; }
			var gain = Math.max(1, Math.floor((_pageItem.infuseBaseExp || 40) * mult));

			rowsHtml +=
				'<div class="wx-pick" data-pick-slot="' + i + '">' +
					wxSwapSlotHtml(s.icon, true) +
					'<div class="wx-c-title">穴' + WX_CN_NUM[i + 1] + ' · 《' + wxEscapeHtml(s.rawName || s.name) + '》</div>' +
					'<div class="wx-c-desc">' + wxEscapeHtml(s.tierLabel) + ' · 火候 ' + s.exp + ' / ' + s.expNeeded + tag + '</div>' +
					'<span class="wx-g">+' + gain + ' 火候</span>' +
				'</div>';
		}

		if (validCount === 0) {
			this.showToast(bro.name + ' 当前没有未满重的已装功法可供化功。', true);
			return;
		}

		var box = $(
			'<div class="wx-popup">' +
				'<div class="wx-ph wx-t-title">残页化功 · 《' + wxEscapeHtml(_pageItem.name) + '》</div>' +
				'<div class="wx-pb">' + rowsHtml + '</div>' +
				'<div class="wx-pf"><span class="wx-vb wx-vb1" data-wx-close="1">关闭</span></div>' +
			'</div>'
		);

		box.find('[data-pick-slot]').on('click', function () {
			var sIdx = parseInt($(this).attr('data-pick-slot'), 10);
			self.closeModal();
			self.mDataSource.notifyBackendWXInfuseLibraryPage(self.getEntityId(), _pageItem.manualID, sIdx, function (_res) {
				self.handleBackendResponse(_res);
			});
		});

		this.openModal(box);
	};

	// ------------------------------------------------------------------------
	// 5. Wire 3rd Tab into CharacterScreenRightPanelModule
	// ------------------------------------------------------------------------
	if (typeof CharacterScreenRightPanelModule !== 'undefined') {
		var origRPRegisterModules = CharacterScreenRightPanelModule.prototype.registerModules;
		var origRPUnregisterModules = CharacterScreenRightPanelModule.prototype.unregisterModules;
		var origRPSetupEvents = CharacterScreenRightPanelModule.prototype.setupEventHandler;
		var origRPRemoveEvents = CharacterScreenRightPanelModule.prototype.removeEventHandler;
		var origRPSwitchInv = CharacterScreenRightPanelModule.prototype.switchToInventory;
		var origRPSwitchPerks = CharacterScreenRightPanelModule.prototype.switchToPerks;
		var origRPCreateDIV = CharacterScreenRightPanelModule.prototype.createDIV;

		CharacterScreenRightPanelModule.prototype.createDIV = function (_parentDiv) {
			origRPCreateDIV.call(this, _parentDiv);
			this.mWXLibraryModule = new CharacterScreenWuxiaLibraryModule(this, this.mDataSource);
			var rp = this;
			this.mDataSource.mWXOnExternalStateChanged = function () {
				if (rp.mPerksModule && rp.mPerksModule.isVisible()) {
					rp.mPerksModule.wxRefreshFromBackend();
				}
				if (rp.mWXLibraryModule && rp.mWXLibraryModule.isVisible()) {
					rp.mWXLibraryModule.refreshFromBackend();
				}
			};
		};

		CharacterScreenRightPanelModule.prototype.registerModules = function () {
			origRPRegisterModules.call(this);
			if (this.mWXLibraryModule) {
				this.mWXLibraryModule.register(this.mContainer);
			}
		};

		CharacterScreenRightPanelModule.prototype.unregisterModules = function () {
			if (this.mWXLibraryModule) {
				this.mWXLibraryModule.unregister();
			}
			origRPUnregisterModules.call(this);
		};

		CharacterScreenRightPanelModule.prototype.setupEventHandler = function () {
			origRPSetupEvents.call(this);
			if (this.mHeaderModule && this.mHeaderModule.setOnSwitchToWXLibraryCallback) {
				this.mHeaderModule.setOnSwitchToWXLibraryCallback(jQuery.proxy(this.switchToWXLibrary, this));
			}
		};

		CharacterScreenRightPanelModule.prototype.removeEventHandler = function () {
			if (this.mHeaderModule && this.mHeaderModule.setOnSwitchToWXLibraryCallback) {
				this.mHeaderModule.setOnSwitchToWXLibraryCallback(null);
			}
			origRPRemoveEvents.call(this);
		};

		CharacterScreenRightPanelModule.prototype.switchToInventory = function () {
			if (this.mWXLibraryModule) this.mWXLibraryModule.hide();
			origRPSwitchInv.call(this);
			if (this.mHeaderModule && this.mHeaderModule.wxSyncTabActive) {
				this.mHeaderModule.wxSyncTabActive('inv');
			}
		};

		CharacterScreenRightPanelModule.prototype.switchToPerks = function () {
			if (this.mWXLibraryModule) this.mWXLibraryModule.hide();
			origRPSwitchPerks.call(this);
			if (this.mHeaderModule && this.mHeaderModule.wxSyncTabActive) {
				this.mHeaderModule.wxSyncTabActive('perks');
			}
		};

		CharacterScreenRightPanelModule.prototype.switchToWXLibrary = function () {
			if (this.mWXSwitchingTab) return;
			this.mWXSwitchingTab = true;
			try {
				if (this.mInventoryModule) this.mInventoryModule.hide();
				if (this.mPerksModule) this.mPerksModule.hide();
				if (!this.mWXLibraryModule && this.mContainer) {
					this.mWXLibraryModule = new CharacterScreenWuxiaLibraryModule(this, this.mDataSource);
					this.mWXLibraryModule.register(this.mContainer);
				}
				if (this.mHeaderModule && this.mHeaderModule.selectWXLibraryPanel) {
					this.mHeaderModule.selectWXLibraryPanel();
				}
				if (this.mWXLibraryModule) this.mWXLibraryModule.show();
			} finally {
				this.mWXSwitchingTab = false;
			}
		};

		if (typeof Screens !== 'undefined' && Screens['CharacterScreen'] && Screens['CharacterScreen'].mRightPanelModule) {
			var liveRP = Screens['CharacterScreen'].mRightPanelModule;
			var liveHdr = liveRP.mHeaderModule;
			if (liveHdr && liveHdr.mContainer) {
				if (liveHdr.mSwitchToInventoryButton) liveHdr.mSwitchToInventoryButton.findButtonText().html('兵甲行囊');
				if (liveHdr.mSwitchToPerksButton) liveHdr.mSwitchToPerksButton.findButtonText().html('武学修为');
				if (!liveHdr.mSwitchToWXLibraryButton) {
					var liveMid = liveHdr.mContainer.find('.buttons-container.is-middle:first');
					if (liveMid.length) {
						var liveLayout = $('<div class="l-button is-wx-library"/>');
						liveMid.append(liveLayout);
						liveHdr.mSwitchToWXLibraryButton = liveLayout.createTabTextButton('藏经阁', function () {
							if (liveHdr.mOnSwitchToWXLibraryCallback !== null && jQuery.isFunction(liveHdr.mOnSwitchToWXLibraryCallback)) {
								liveHdr.mOnSwitchToWXLibraryCallback();
							} else if (liveHdr.mParent && typeof liveHdr.mParent.switchToWXLibrary === 'function') {
								liveHdr.mParent.switchToWXLibrary();
							}
						}, null, 'tab-button', 7);
					}
				}
				liveHdr.setOnSwitchToWXLibraryCallback(jQuery.proxy(liveRP.switchToWXLibrary, liveRP));
			}
			if (liveRP.mContainer && !liveRP.mWXLibraryModule) {
				liveRP.mWXLibraryModule = new CharacterScreenWuxiaLibraryModule(liveRP, liveRP.mDataSource);
				liveRP.mWXLibraryModule.register(liveRP.mContainer);
				if (liveRP.mDataSource) {
					liveRP.mDataSource.mWXOnExternalStateChanged = function () {
						if (liveRP.mPerksModule && liveRP.mPerksModule.isVisible()) {
							liveRP.mPerksModule.wxRefreshFromBackend();
						}
						if (liveRP.mWXLibraryModule && liveRP.mWXLibraryModule.isVisible()) {
							liveRP.mWXLibraryModule.refreshFromBackend();
						}
					};
				}
			}
		}
	}

	// ------------------------------------------------------------------------
	// 6. Tab 2 Module: CharacterScreenPerksModule (武学修为 — 原版天赋页同构)
	// ------------------------------------------------------------------------
	var origCreateDIV = CharacterScreenPerksModule.prototype.createDIV;
	var origDestroyDIV = CharacterScreenPerksModule.prototype.destroyDIV;
	var origLoadBrother = CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData;
	var origShow = CharacterScreenPerksModule.prototype.show;
	var origHide = CharacterScreenPerksModule.prototype.hide;

	function wxInspectorItemKey(_kind, _item) {
		if (_kind === 'move') return _item.id;
		if (_kind === 'vault') return _item.itemKind + ':' + _item.manualID;
		if (_kind === 'pill') return _item.stashIndex + ':' + _item.pillID;
		return _item.manualID;
	}

	function wxBindInspectorClick(_panel, _element, _kind, _item) {
		var key = wxInspectorItemKey(_kind, _item);
		var selected = _panel.mWXInspected;
		if (selected && selected.kind === _kind && selected.key === key) {
			_element.addClass('is-inspected');
		}
		_element.on('click', function () {
			_panel.mWXInspected = { kind: _kind, key: key };
			_panel.mWXRoot.find('.is-inspected').removeClass('is-inspected');
			_element.addClass('is-inspected');
			_panel.wxRefreshInspector();
		});
	}

	function wxCanLearnVaultItem(_it) {
		return !_it.alreadyLearned && (_it.itemKind === 'manual' ||
			(_it.itemKind === 'page' && _it.allowFragmentLearn && !_it.learnedIsFragment));
	}

	function wxCanInfuseSlot(_slot) {
		return !!(_slot && _slot.unlocked && _slot.manualID && !_slot.isFragment && _slot.tier < 3 && !_slot.isSealed && !_slot.blockedByReq);
	}

	CharacterScreenPerksModule.prototype.createDIV = function (_parentDiv) {
		origCreateDIV.call(this, _parentDiv);

		this.mContainer.addClass('no-pointer-events');
		if (this.mLeftColumn) {
			this.mLeftColumn.addClass('display-none');
		}

		this.mWXState = null;
		this.mWXCurrentEntityId = null;
		this.mWXSelectedSlotIdx = 0;
		this.mWXShelfMode = 'learned'; // 'learned' | 'vault' | 'pill'
		this.mWXCatFilter = null;      // null | 'neigong' | 'waigong' | 'qinggong' | 'henglian'
		this.mWXInspected = null;
		this.mWXDragPayload = null;
		this.mWXDragGhost = null;
		this.mWXAutoPickedModeForEntity = null;
		this.mWXWashState = {
			targetAttrIdx: -1,
			replaceAttrIdx: -1,
			useProtectPill: false,
			usePendingChance: false
		};

		this.wxBuildRootDOM(this.mContainer);
	};

	CharacterScreenPerksModule.prototype.destroyDIV = function () {
		this.wxCancelDrag();
		wxCloseScreenModal();
		if (this.mWXScrollArea && this.mWXScrollArea.isNativeList && this.mWXScrollArea.list) {
			this.mWXScrollArea.list.destroyList();
		}
		this.mWXScrollArea = null;
		if (this.mWXRoot) {
			this.mWXRoot.empty();
			this.mWXRoot.remove();
			this.mWXRoot = null;
		}
		origDestroyDIV.call(this);
	};

	CharacterScreenPerksModule.prototype.show = function () {
		this.mWXPanelShowing = true;
		origShow.call(this);
		this.mContainer.removeClass('no-pointer-events').addClass('is-top');
		this.wxRefreshFromBackend();
	};

	CharacterScreenPerksModule.prototype.hide = function () {
		this.mWXPanelShowing = false;
		this.wxCancelDrag();
		wxCloseScreenModal();
		origHide.call(this);
		this.mContainer.addClass('no-pointer-events');
	};

	CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData = function (_brother) {
		origLoadBrother.call(this, _brother);
		if (this.mLeftColumn) {
			this.mLeftColumn.addClass('display-none');
		}
		if (_brother) {
			var nextId = null;
			if (typeof CharacterScreenIdentifier !== 'undefined' && CharacterScreenIdentifier.Entity && (CharacterScreenIdentifier.Entity.Id in _brother)) {
				nextId = _brother[CharacterScreenIdentifier.Entity.Id];
			} else if (typeof _brother.id !== 'undefined') {
				nextId = _brother.id;
			}
			if (nextId !== null && nextId !== this.mWXCurrentEntityId) {
				this.mWXCurrentEntityId = nextId;
				this.mWXInspected = null;
			}
		}
		if (this.mWXPanelShowing || this.isVisible()) {
			this.wxRefreshFromBackend();
		}
	};

	CharacterScreenPerksModule.prototype.wxSyncCachedState = function (_data) {
		if (_data && _data.ok) {
			if (this.mWXCurrentEntityId !== null && _data.brother && _data.brother.entityId !== this.mWXCurrentEntityId) return;
			this.mWXState = _data;
			if (this.mWXPanelShowing || this.isVisible()) {
				this.wxRenderAll();
			}
		}
	};

	CharacterScreenPerksModule.prototype.wxBuildRootDOM = function (_host) {
		this.mWXRoot = $('<div class="wx-panel"></div>');
		_host.append(this.mWXRoot);

		this.mWXHeader = $('<div class="wx-head"></div>');
		this.mWXToast = $('<div class="wx-toast" style="display:none;"><span></span></div>');
		this.mWXMeridian = $('<div class="wx-meridian"></div>');
		this.mWXPassives = $('<div class="wx-pas"></div>');
		this.mWXShelfFilter = $('<div class="wx-shelf-f"></div>');
		var shelfGridHost = $('<div class="wx-shelf-g wx-scroll-host"></div>');
		this.mWXInspector = $(
			'<div class="wx-insp is-wx">' +
				'<div class="wx-insp-body" data-wx="insp-body"></div>' +
				'<div class="wx-insp-foot" data-wx="insp-foot"></div>' +
			'</div>'
		);
		this.mWXStrip = $('<div class="wx-strip"></div>');

		this.mWXRoot.append(this.mWXHeader);
		this.mWXRoot.append(this.mWXToast);
		this.mWXRoot.append(this.mWXMeridian);
		this.mWXRoot.append(this.mWXPassives);
		this.mWXRoot.append(this.mWXShelfFilter);
		this.mWXRoot.append(shelfGridHost);
		this.mWXRoot.append(this.mWXInspector);
		this.mWXRoot.append(this.mWXStrip);

		this.mWXScrollArea = wxCreateScrollArea(shelfGridHost);
		this.mWXInspBody = this.mWXInspector.find('[data-wx="insp-body"]');
		this.mWXInspFoot = this.mWXInspector.find('[data-wx="insp-foot"]');
	};

	CharacterScreenPerksModule.prototype.wxSetShelfMode = function (_mode) {
		var selected = this.mWXInspected;
		if (_mode === 'pill' && selected && selected.kind === 'learned') {
			var slots = this.mWXState.brother.slots;
			for (var i = 0; i < slots.length; i++) {
				if (slots[i].manualID === selected.key) {
					this.mWXSelectedSlotIdx = slots[i].slotIndex;
					this.wxRenderSlots();
					this.wxRenderStrip();
					break;
				}
			}
		}
		this.mWXShelfMode = _mode;
		this.wxRenderShelfFilter();
		this.wxRenderLearnedList();
	};

	CharacterScreenPerksModule.prototype.wxOpenModal = function (_box) {
		wxOpenScreenModal(_box, this.mDataSource, this.mWXRoot);
	};

	CharacterScreenPerksModule.prototype.wxCloseModal = function () {
		wxCloseScreenModal();
	};

	CharacterScreenPerksModule.prototype.wxShowToast = function (_msg, _isError) {
		if (!_msg) return;
		if (window.WX_Showcase && window.WX_Showcase.plaque) {
			window.WX_Showcase.plaque({
				title: _isError ? '武学提示' : '武学修为',
				message: _msg,
				icon: _isError ? 'ui/wx_icons/wx_seal_cinnabar.png' : 'ui/wx_icons/wx_icon_qi.png',
				isError: !!_isError
			});
			return;
		}
		if (!this.mWXToast) return;
		var toast = this.mWXToast;
		if (this.mWXToastTimer) clearTimeout(this.mWXToastTimer);
		toast.removeClass('is-error is-ok').addClass(_isError ? 'is-error' : 'is-ok');
		toast.children('span').text(_msg);
		toast.stop(true, true).show();
		this.mWXToastTimer = setTimeout(function () {
			toast.fadeOut(220);
		}, 3200);
	};

	// ES3 Mouse Drag & Drop onto 7 Acupoint Discs
	CharacterScreenPerksModule.prototype.wxBindSlotDrag = function (_el, _payload) {
		var self = this;
		var startX = 0;
		var startY = 0;
		var dragging = false;

		_el.on('mousedown', function (_e) {
			if (_e.which !== 1) return;
			startX = _e.clientX;
			startY = _e.clientY;
			dragging = false;

			$(document).on('mousemove.wxSlotDrag', function (_me) {
				var dx = _me.clientX - startX;
				var dy = _me.clientY - startY;
				if (!dragging && (dx * dx + dy * dy) > 36) {
					dragging = true;
					self.wxBeginDrag(_payload, _me.clientX, _me.clientY);
				} else if (dragging) {
					self.wxMoveDrag(_me.clientX, _me.clientY);
				}
			});

			$(document).on('mouseup.wxSlotDrag', function (_ue) {
				$(document).off('mousemove.wxSlotDrag mouseup.wxSlotDrag');
				if (dragging) {
					dragging = false;
					self.wxEndDrag(_ue.clientX, _ue.clientY);
				}
			});
		});
	};

	CharacterScreenPerksModule.prototype.wxCanPayloadDropOnSlot = function (_payload, _slot) {
		if (!_payload || !_slot || !_slot.unlocked) return false;
		if (_payload.kind === 'learned' || _payload.kind === 'vault_manual' || _payload.kind === 'vault_frag') {
			return this.wxCanCategoryFitSlot(_payload.category, _payload.equippedSlotIndex, _slot);
		}
		if (_payload.kind === 'pill_infuse') {
			return wxCanInfuseSlot(_slot);
		}
		return false;
	};

	CharacterScreenPerksModule.prototype.wxBeginDrag = function (_payload, _cx, _cy) {
		this.wxCancelDrag();
		this.mWXDragPayload = _payload;
		var ghost = $('<div class="wx-drag-ghost"><img src="coui://gfx/' + _payload.icon + '" alt=""/></div>');
		ghost.css({ left: _cx + 'px', top: _cy + 'px' });
		$(document.body).append(ghost);
		this.mWXDragGhost = ghost;

		var self = this;
		var bro = this.mWXState && this.mWXState.brother;
		if (bro && bro.slots) {
			this.mWXMeridian.find('.wx-mcol').each(function (_idx) {
				var sl = bro.slots[_idx];
				if (self.wxCanPayloadDropOnSlot(_payload, sl)) {
					$(this).addClass('is-drop-ok');
				} else {
					$(this).addClass('is-drop-no');
				}
			});
		}
	};

	CharacterScreenPerksModule.prototype.wxMoveDrag = function (_cx, _cy) {
		if (this.mWXDragGhost) {
			this.mWXDragGhost.css({ left: _cx + 'px', top: _cy + 'px' });
		}
	};

	CharacterScreenPerksModule.prototype.wxEndDrag = function (_cx, _cy) {
		var payload = this.mWXDragPayload;
		var hitSlotIdx = -1;
		this.mWXMeridian.find('.wx-mcol').each(function (_idx) {
			var rect = this.getBoundingClientRect();
			if (_cx >= rect.left && _cx <= rect.right && _cy >= rect.top && _cy <= rect.bottom) {
				hitSlotIdx = _idx;
			}
		});
		this.wxCancelDrag();

		if (hitSlotIdx < 0 || !payload || !this.mWXState || !this.mWXState.brother) return;
		var targetSlot = this.mWXState.brother.slots[hitSlotIdx];
		if (!this.wxCanPayloadDropOnSlot(payload, targetSlot)) {
			this.wxShowToast('该武学或灵丹无法装入此穴位。', true);
			return;
		}

		var self = this;
		if (payload.kind === 'learned') {
			this.wxSubmitEquipLearned(hitSlotIdx, payload.manualID, false);
		} else if (payload.kind === 'vault_manual') {
			this.wxSubmitLearnAndEquip(hitSlotIdx, payload.manualID, false, false);
		} else if (payload.kind === 'vault_frag') {
			this.wxSubmitLearnAndEquip(hitSlotIdx, payload.manualID, true, false);
		} else if (payload.kind === 'pill_infuse') {
			this.mDataSource.notifyBackendWXInfusePill(this.mWXCurrentEntityId, payload.stashIndex, hitSlotIdx, function (_res) {
				self.wxApplyBackendState(_res);
			});
		}
	};

	CharacterScreenPerksModule.prototype.wxCancelDrag = function () {
		this.mWXDragPayload = null;
		if (this.mWXDragGhost) {
			this.mWXDragGhost.remove();
			this.mWXDragGhost = null;
		}
		if (this.mWXMeridian) {
			this.mWXMeridian.find('.wx-mcol').removeClass('is-drop-ok is-drop-no');
		}
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
			if (_data && _data.ok && self.mWXCurrentEntityId === entityId) {
				self.mWXState = _data;
				if (self.mParent && self.mParent.mHeaderModule && self.mParent.mHeaderModule.wxUpdateTabLabels) {
					self.mParent.mHeaderModule.wxUpdateTabLabels(_data.brother, _data.library ? _data.library.summary : null);
				}
				if (self.mWXAutoPickedModeForEntity !== entityId && _data.brother) {
					self.mWXAutoPickedModeForEntity = entityId;
					var learned = _data.brother.learnedManuals || [];
					var vaultUnlearned = self.wxCountVaultUnlearned(_data);
					if (learned.length === 0 && vaultUnlearned > 0) {
						self.mWXShelfMode = 'vault';
					} else if (self.mWXShelfMode === 'vault' && vaultUnlearned === 0 && learned.length > 0) {
						self.mWXShelfMode = 'learned';
					}
				}
				self.wxRenderAll();
				if (_data.autoStoreNotice) {
					self.wxShowToast(_data.autoStoreNotice, false);
				}
			}
		});
	};

	CharacterScreenPerksModule.prototype.wxCountVaultUnlearned = function (_state) {
		var items = (_state && _state.library && _state.library.items) ? _state.library.items : [];
		var cnt = 0;
		for (var i = 0; i < items.length; i++) {
			if (wxCanLearnVaultItem(items[i])) cnt++;
		}
		return cnt;
	};

	CharacterScreenPerksModule.prototype.wxDispatchShowcase = function (_sc) {
		if (!_sc || !window.WX_Showcase) return false;
		var sqH = (this.mDataSource && this.mDataSource.mSQHandle) ? this.mDataSource.mSQHandle : null;
		var k = _sc.kind || '';

		if (k === 'infuse') {
			var targetCol = (this.mWXMeridian && typeof _sc.slotIndex === 'number')
				? this.mWXMeridian.find('[data-slot-idx="' + _sc.slotIndex + '"] .wx-disc')
				: null;
			var rawRes = _sc.resonance ? String(_sc.resonance) : '';
			if (rawRes.length >= 1 && (rawRes.charAt(0) === '（' || rawRes.charAt(0) === '(')) {
				rawRes = rawRes.substring(1);
			}
			if (rawRes.length >= 1 && (rawRes.charAt(rawRes.length - 1) === '）' || rawRes.charAt(rawRes.length - 1) === ')')) {
				rawRes = rawRes.substring(0, rawRes.length - 1);
			}
			var subChip = rawRes || (_sc.blockedByReq ? '火候已满 · 待破门槛' : '');
			if (targetCol && targetCol.length && window.WX_Showcase.infuseSlotFx) {
				window.WX_Showcase.infuseSlotFx(targetCol, {
					theme: 'gold',
					sourceIcon: _sc.sourceIcon || 'ui/wx_icons/wx_icon_qi.png',
					expAmount: _sc.expAmount || 0,
					floatText: '+' + (_sc.expAmount || 0) + ' 火候',
					subChip: subChip,
					sqHandle: sqH,
					soundCue: 'cultivate_infuse'
				});
			} else {
				window.WX_Showcase.plaque({
					title: '灌注火候 · 《' + (_sc.manualName || '武学') + '》',
					message: _sc.message || ('火候 +' + (_sc.expAmount || 0)),
					icon: _sc.sourceIcon || 'ui/wx_icons/wx_icon_qi.png',
					theme: 'gold'
				});
			}
			return true;
		}
		if (k === 'consume_pill') {
			var pillTarget = $('.character-screen-container .l-portrait-container:first');
			if (!pillTarget.length) pillTarget = this.mWXHeader || this.mWXRoot;
			var pillChips = ['服食「' + (_sc.pillName || '灵丹') + '」'];
			if (_sc.effectLabel) {
				pillChips.push(_sc.effectLabel);
			} else if (_sc.message) {
				var shortM = String(_sc.message);
				if (shortM.length > 26) shortM = shortM.substring(0, 25) + '…';
				pillChips.push(shortM);
			}
			if (window.WX_Showcase.flyPillToTarget) {
				window.WX_Showcase.flyPillToTarget(pillTarget, {
					theme: 'jade',
					pillIcon: _sc.pillIcon || 'ui/wx_icons/wx_asset_medicine.png',
					chips: pillChips,
					sqHandle: sqH,
					soundCue: 'pill_drink'
				});
			} else {
				window.WX_Showcase.pulseElement(pillTarget, {
					theme: 'jade',
					icon: _sc.pillIcon || 'ui/wx_icons/wx_asset_medicine.png',
					floatText: pillChips[0],
					sqHandle: sqH,
					soundCue: 'pill_drink'
				});
			}
			return true;
		}
		if (k === 'sweep_vault') {
			var vaultBtn = this.mWXRoot ? this.mWXRoot.find('[data-wx-act="store-all"], .wx-tab-btn.is-active').first() : this.mWXHeader;
			if (window.WX_Showcase.sweepFx) {
				window.WX_Showcase.sweepFx(vaultBtn && vaultBtn.length ? vaultBtn : (this.mWXHeader || this.mWXRoot), {
					theme: 'gold',
					icon: 'ui/items/misc/wx_book_waigong_sect.png',
					floatText: _sc.floatText || '典籍已归入藏经阁',
					sqHandle: sqH,
					soundCue: 'sweep_whoosh'
				});
				return true;
			}
			return false;
		}
		if (k === 'slot_change' || k === 'slot_unequip') {
			var isUn = (k === 'slot_unequip');
			var sDisc = (this.mWXMeridian && typeof _sc.slotIndex === 'number')
				? this.mWXMeridian.find('[data-slot-idx="' + _sc.slotIndex + '"] .wx-disc')
				: null;
			if (sDisc && sDisc.length && window.WX_Showcase.sweepFx) {
				window.WX_Showcase.sweepFx(sDisc, {
					theme: isUn ? 'crimson' : 'gold',
					icon: _sc.icon || 'ui/wx_icons/wx_icon_qi.png',
					floatText: isUn ? '卸功调息' : (_sc.isOverwrite ? '换功入槽' : '功法入槽'),
					sqHandle: sqH,
					soundCue: 'manual_learn'
				});
			} else {
				window.WX_Showcase.plaque({
					title: isUn ? '卸下武学' : '运转武学穴位',
					message: _sc.message || '',
					icon: _sc.icon || 'ui/wx_icons/wx_icon_qi.png',
					isError: isUn
				});
			}
			return true;
		}

		// Tier-1 Full Ritual & Item Reveal (`breakthrough`, `wash`, `craft_manual`, `learn_manual`, etc.)
		if (typeof _sc.slotIndex === 'number' && _sc.slotIndex >= 0 && this.mWXMeridian) {
			window.WX_Showcase.pulseElement(this.mWXMeridian.find('[data-slot-idx="' + _sc.slotIndex + '"] .wx-disc'), {
				theme: 'gold'
			});
		}
		return window.WX_Showcase.play(_sc, { sqHandle: sqH });
	};

	CharacterScreenPerksModule.prototype.wxApplyBackendState = function (_res) {
		if (!_res) return;
		if (_res.ok) {
			this.mDataSource.wxApplyVanillaSync(_res);
			if (_res.brother && _res.brother.entityId !== this.mWXCurrentEntityId) return;
			this.mWXState = _res;
			if (this.mParent && this.mParent.mHeaderModule && this.mParent.mHeaderModule.wxUpdateTabLabels) {
				this.mParent.mHeaderModule.wxUpdateTabLabels(_res.brother, _res.library ? _res.library.summary : null);
			}
			this.wxRenderAll();
			if (_res.wxShowcase && this.wxDispatchShowcase(_res.wxShowcase)) {
				return;
			}
			if (_res.actionMessage) {
				this.wxShowToast(_res.actionMessage, !!(_res.washResult && !_res.washResult.Succeeded));
			}
		} else if (_res.reason) {
			this.wxShowToast(_res.reason, true);
		}
	};

	CharacterScreenPerksModule.prototype.wxRenderAll = function () {
		if (!this.mWXState || !this.mWXState.brother) return;
		var bro = this.mWXState.brother;
		if (this.mWXSelectedSlotIdx < 0 || this.mWXSelectedSlotIdx >= bro.slots.length) {
			this.mWXSelectedSlotIdx = 0;
		}
		this.wxRenderHeader();
		this.wxRenderSlots();
		this.wxRenderMovesAndPassives();
		this.wxRenderShelfFilter();
		this.wxRenderLearnedList();
		this.wxRefreshInspector();
		this.wxRenderStrip();
	};

	CharacterScreenPerksModule.prototype.wxFindQuickHealPill = function (_preferKinds) {
		var items = (this.mWXState && this.mWXState.stashItems) ? this.mWXState.stashItems : [];
		for (var k = 0; k < _preferKinds.length; k++) {
			var targetKind = _preferKinds[k];
			for (var i = 0; i < items.length; i++) {
				if (items[i].itemKind === 'pill_consume' && items[i].pillKind === targetKind) {
					return items[i];
				}
			}
		}
		return null;
	};

	CharacterScreenPerksModule.prototype.wxRenderHeader = function () {
		var self = this;
		var bro = this.mWXState.brother;
		var totalWash = (this.mWXState.washPillCount || 0) + (bro.pendingWashChances || 0);

		var h = '<span class="wx-c-label">主修</span> <span class="wx-c-title">' + wxEscapeHtml(bro.mainElementLabel || '未修') + '</span>';
		h += '<span class="wx-sep">|</span>';
		if (bro.hasConflict) {
			h += '<span class="wx-c-neg">内息相克</span>';
		} else {
			h += '<span class="wx-c-title">内息调和</span>';
		}
		h += '<span class="wx-sep">|</span><span class="wx-c-label">行动力</span> <span class="wx-c-title">' + bro.actionPointsMax + '</span> <span class="wx-c-desc">/ 11</span>';

		if (bro.hasScatterWeakness || bro.internalSeverity > 0) {
			var intText = bro.internalSeverity >= 2 ? '经脉震荡' : (bro.internalSeverity === 1 ? '内伤' : ('散功 ' + (bro.scatterDays > 0 ? (bro.scatterDays + ' 天') : '')));
			h += '<span class="wx-sep">|</span><span class="wx-warn" data-wx="heal-int" title="点击服用护心丹化解">' + intText + '</span>';
		}
		if (bro.tempInjuryNames && bro.tempInjuryNames.length > 0) {
			h += '<span class="wx-sep">|</span><span class="wx-warn" data-wx="heal-ext" title="点击敷治金疮散">外伤×' + bro.tempInjuryNames.length + '</span>';
		}
		if (bro.permScars && bro.permScars > 0) {
			h += '<span class="wx-sep">|</span><span class="wx-c-neg">暗疾×' + bro.permScars + '</span>';
		}

		h += '<span class="wx-r">' +
				'<span class="wx-vb wx-vb2" data-wx="open-presets" style="width:5.4rem;margin-right:0.25rem;" title="保存或一键切换该侠客的三套武学配槽方案（常规 / 诛邪 / 猎妖）">配槽</span>' +
				'<span class="wx-vb wx-vb3" data-wx="open-alc" style="margin-right:0.22rem;" title="丹经与药柜录（随身翻阅；开炉炼丹、神兵重锻与存取奇材请赴城镇百工丹坊）"><img src="coui://gfx/ui/wx_icons/wx_glyph_herb_cabinet.png" alt=""/></span>' +
				'<span class="wx-vb wx-vb3" data-wx="open-sects" style="margin-right:0.22rem;" title="江湖宗门名刺录（随身翻阅；结交请教请赴迎客酒肆茶座或独立山门）"><img src="coui://gfx/ui/wx_icons/wx_glyph_sect_token.png" alt=""/></span>' +
				'<span class="wx-vb wx-vb3" data-wx="open-cfg" style="margin-right:0.26rem;" title="江湖机枢设置（开关气芒特效、武侠音效、特写演出、快速结算与动态江湖演进）"><img class="is-flat" src="coui://gfx/ui/icons/unlocked_small.png" alt=""/></span>' +
				'<span class="wx-vb wx-vb1" data-wx="open-wash">洗经伐髓' + (totalWash > 0 ? ('<span class="wx-cnt">' + totalWash + '</span>') : '') + '</span>' +
			'</span>';

		this.mWXHeader.html(h);

		this.mWXHeader.find('[data-wx="open-presets"]').on('click', function () {
			self.wxOpenPresetsModal();
		});

		this.mWXHeader.find('[data-wx="open-cfg"]').on('click', function () {
			if (window.WX_OpenModSettings && self.mDataSource && self.mDataSource.mSQHandle !== null) {
				window.WX_OpenModSettings(self.mDataSource.mSQHandle, self.mDataSource);
			}
		});

		this.mWXHeader.find('[data-wx="heal-int"]').on('click', function () {
			var huxin = self.wxFindQuickHealPill(['heal_internal']);
			if (huxin) self.wxTriggerUsePill(huxin);
			else {
				self.wxSetShelfMode('pill');
				self.wxShowToast('仓库暂无「护心丹」，可在城镇市集或百工丹坊获取。', true);
			}
		});

		this.mWXHeader.find('[data-wx="heal-ext"]').on('click', function () {
			var ext = self.wxFindQuickHealPill(['heal_external_plus', 'heal_external']);
			if (ext) self.wxTriggerUsePill(ext);
			else {
				self.wxSetShelfMode('pill');
				self.wxShowToast('仓库暂无「金疮散」。', true);
			}
		});

		this.mWXHeader.find('[data-wx="open-alc"]').on('click', function () {
			if (window.WX_OpenAlchemyCauldron && self.mDataSource && self.mDataSource.mSQHandle !== null) {
				window.WX_OpenAlchemyCauldron(self.mDataSource.mSQHandle, self.mDataSource, self, self.mWXCurrentEntityId, 'cauldron');
			}
		});

		this.mWXHeader.find('[data-wx="open-sects"]').on('click', function () {
			if (window.WX_OpenSectDirectory && self.mDataSource && self.mDataSource.mSQHandle !== null) {
				window.WX_OpenSectDirectory(self.mDataSource.mSQHandle, self.mDataSource);
			}
		});

		this.mWXHeader.find('[data-wx="open-wash"]').on('click', function () {
			self.wxOpenWashModal();
		});
	};

	CharacterScreenPerksModule.prototype.wxCanCategoryFitSlot = function (_category, _equippedSlotIdx, _slot) {
		if (!_category || !_slot || !_slot.unlocked) return false;
		var allowed = _slot.allowedCategories || [];
		var okCat = false;
		for (var i = 0; i < allowed.length; i++) {
			if (allowed[i] === _category) {
				okCat = true;
				break;
			}
		}
		if (!okCat) return false;
		if (typeof _equippedSlotIdx === 'number' && _equippedSlotIdx >= 0 && _equippedSlotIdx !== _slot.slotIndex) return false;

		if (_category === 'neigong' || _category === 'qinggong') {
			var bro = this.mWXState && this.mWXState.brother;
			var sameCnt = 0;
			if (bro && bro.slots) {
				for (var j = 0; j < bro.slots.length; j++) {
					if (j === _slot.slotIndex) continue;
					if (bro.slots[j].manualID && bro.slots[j].category === _category) sameCnt++;
				}
			}
			if (sameCnt >= 2) return false;
		}
		return true;
	};

	CharacterScreenPerksModule.prototype.wxCanLearnedFitSlot = function (_lm, _slot) {
		if (!_lm) return false;
		return this.wxCanCategoryFitSlot(_lm.category, _lm.equippedSlotIndex, _slot);
	};

	CharacterScreenPerksModule.prototype.wxHasAnyReadyLearnedForSlot = function (_slot) {
		if (!_slot || !_slot.unlocked || _slot.manualID) return false;
		var list = (this.mWXState && this.mWXState.brother && this.mWXState.brother.learnedManuals) ? this.mWXState.brother.learnedManuals : [];
		for (var i = 0; i < list.length; i++) {
			if (list[i].equippedSlotIndex < 0 && this.wxCanLearnedFitSlot(list[i], _slot)) {
				return true;
			}
		}
		var vItems = (this.mWXState && this.mWXState.library && this.mWXState.library.items) ? this.mWXState.library.items : [];
		for (var v = 0; v < vItems.length; v++) {
			var vit = vItems[v];
			if (vit.itemKind === 'manual' && !vit.alreadyLearned && this.wxCanCategoryFitSlot(vit.category, -1, _slot)) {
				return true;
			}
		}
		return false;
	};

	CharacterScreenPerksModule.prototype.wxRenderSlots = function () {
		var self = this;
		var bro = this.mWXState.brother;
		this.mWXMeridian.empty().append('<div class="wx-vline"></div>');

		var shortLabels = ['主修内功', '基础外功', '轻功身法', '横练杂学', '进阶专精', '自由穴', '宗师穴'];
		var colW = 9.4;
		var gap = (67.8 - 7 * colW) / 6.0;

		for (var i = 0; i < bro.slots.length; i++) {
			(function (_idx, _s) {
				var cls = 'wx-mcol';
				if (_idx === self.mWXSelectedSlotIdx) cls += ' is-sel';

				var discHtml = '<div class="wx-hl"></div>';
				var tierHtml = '&nbsp;';
				var xpHtml = '<div class="wx-vxp" style="visibility:hidden;"></div>';
				var nmText = '';

				if (!_s.unlocked) {
					cls += ' is-locked';
					discHtml += '<div class="wx-well"></div><div class="wx-ring"></div><img class="wx-lock" src="coui://gfx/ui/icons/icon_locked.png" alt=""/>';
					nmText = _s.unlockLevel + ' 级贯通';
				} else if (_s.manualID) {
					var wpnOff = (_s.weaponLabel && !_s.matchesWeapon);
					if (wpnOff || _s.isSealed) cls += ' is-off';
					discHtml += '<img class="wx-ic" src="coui://gfx/' + _s.icon + '" alt=""/><div class="wx-ring"></div>';
					tierHtml = (WX_TIER_SHORT[_s.tier] || _s.tierLabel) +
						(_s.isFragment ? ' · 残' : '') +
						(_s.isSealed ? ' · <span class="wx-c-neg">封</span>' : (wpnOff ? ' · <span class="wx-c-neg">换兵</span>' : ''));
					xpHtml = wxXpBarHtml(_s.exp, _s.expNeeded, _s.isFragment || _s.tier >= 3 || _s.expNeeded <= 0, 0);
					nmText = _s.rawName || _s.name;
				} else {
					var rd = self.wxHasAnyReadyLearnedForSlot(_s);
					cls += rd ? ' is-ready' : ' is-empty';
					discHtml += '<div class="wx-well"></div><div class="wx-ring"></div><img class="wx-plus" src="coui://gfx/ui/icons/plus.png" alt=""/>';
					nmText = rd ? '可配功' : '空穴';
				}

				var col = $(
					'<div class="' + cls + '" data-slot-idx="' + _idx + '" style="left:' + (_idx * (colW + gap)).toFixed(2) + 'rem;">' +
						'<div class="wx-role">' + (shortLabels[_idx] || _s.slotLabel) + '</div>' +
						'<div class="wx-disc">' + discHtml + '</div>' +
						'<div class="wx-tier">' + tierHtml + '</div>' +
						xpHtml +
						'<div class="wx-nm">' + wxEscapeHtml(nmText) + '</div>' +
					'</div>'
				);

				col.on('click', function () {
					self.mWXSelectedSlotIdx = _idx;
					self.mWXInspected = { kind: 'slot', slotIndex: _idx };
					self.mWXRoot.find('.is-inspected').removeClass('is-inspected');
					if (self.mWXShelfMode === 'pill') {
						self.mWXShelfMode = 'learned';
					}
					self.wxRenderSlots();
					self.wxRenderShelfFilter();
					self.wxRenderLearnedList();
					self.wxRefreshInspector();
					self.wxRenderStrip();
				});

				col.on('contextmenu', function (_e) {
					_e.preventDefault();
					_e.stopPropagation();
					if (_s.unlocked && _s.manualID) {
						self.wxSubmitUnequipSlot(_idx, false);
					}
					return false;
				});

				self.mWXMeridian.append(col);
			})(i, bro.slots[i]);
		}
	};

	CharacterScreenPerksModule.prototype.wxRenderMovesAndPassives = function () {
		var self = this;
		var bro = this.mWXState.brother;
		this.mWXPassives.empty();

		var moves = bro.activeMoves || [];
		if (moves.length > 0) {
			this.mWXPassives.append('<span class="wx-lab">招式</span>');
			for (var i = 0; i < moves.length; i++) {
				(function (_mv) {
					var mImg = $('<img class="wx-mv-ico' + (_mv.weaponOk ? '' : ' is-off') + '" src="coui://gfx/' + _mv.icon + '" alt="" title="' + wxEscapeHtml(_mv.name) + '"/>');
					wxBindInspectorClick(self, mImg, 'move', _mv);
					self.mWXPassives.append(mImg);
				})(moves[i]);
			}
			this.mWXPassives.append('<span class="wx-lab" style="margin-left:0.5rem;">常驻</span>');
		} else {
			this.mWXPassives.append('<span class="wx-lab">常驻</span>');
		}

		var pTags = bro.aggSummaryTags || [];
		if (pTags.length > 0) {
			for (var j = 0; j < pTags.length && j < 5; j++) {
				this.mWXPassives.append('<span class="wx-pit">' + wxEscapeHtml(pTags[j]) + '</span>');
			}
		} else {
			this.mWXPassives.append('<span class="wx-c-desc">同系被动只取最高一项</span>');
		}

		var diags = bro.buildDiagnostics || [];
		if (diags.length > 0) {
			for (var d = 0; d < diags.length && d < 3; d++) {
				var dg = diags[d];
				var dCls = (dg.level === 'warn') ? 'wx-diag-warn' : 'wx-diag-info';
				var dPrefix = (dg.level === 'warn') ? '【慎】' : '【注】';
				this.mWXPassives.append('<span class="' + dCls + '" title="' + wxEscapeHtml(dg.detail || '') + '">' + dPrefix + wxEscapeHtml(dg.short || '') + '</span>');
			}
		}
	};

	CharacterScreenPerksModule.prototype.wxRenderShelfFilter = function () {
		var self = this;
		var bro = this.mWXState.brother;
		var learnedCnt = (bro.learnedManuals || []).length;
		var vaultCnt = this.wxCountVaultUnlearned(this.mWXState);
		var pillCnt = (this.mWXState.stashItems || []).length;

		var shelves = [
			['learned', '已习', learnedCnt],
			['vault',   '阁藏', vaultCnt],
			['pill',    '灵丹', pillCnt]
		];

		var h = '';
		for (var i = 0; i < shelves.length; i++) {
			var s = shelves[i];
			var selCls = (this.mWXShelfMode === s[0]) ? ' is-sel' : '';
			var cntHtml = s[2] > 0 ? ('<span class="wx-cnt">' + s[2] + '</span>') : '';
			h += '<span class="wx-vb wx-vb2' + selCls + '" data-smode="' + s[0] + '">' + s[1] + cntHtml + '</span>';
		}

		if (this.mWXShelfMode !== 'pill') {
			h += '<span class="wx-r">';
			var cats = ['neigong', 'waigong', 'qinggong', 'henglian'];
			for (var c = 0; c < cats.length; c++) {
				var ck = cats[c];
				var cSel = (this.mWXCatFilter === ck) ? ' is-sel' : '';
				h += '<span class="wx-vb wx-vb3' + cSel + '" data-cflt="' + ck + '" title="' + WX_CAT_LABELS[ck] + '"><img src="coui://gfx/' + WX_CAT_EMBLEMS[ck] + '" alt=""/></span>';
			}
			h += '</span>';
		}

		this.mWXShelfFilter.html(h);

		this.mWXShelfFilter.find('[data-smode]').on('click', function () {
			self.wxSetShelfMode($(this).attr('data-smode'));
		});

		this.mWXShelfFilter.find('[data-cflt]').on('click', function () {
			var ck2 = $(this).attr('data-cflt');
			self.mWXCatFilter = (self.mWXCatFilter === ck2) ? null : ck2;
			self.wxRenderShelfFilter();
			self.wxRenderLearnedList();
		});
	};

	CharacterScreenPerksModule.prototype.wxRenderStrip = function () {
		var bro = this.mWXState && this.mWXState.brother;
		if (!bro || !bro.slots) return;
		var s = bro.slots[this.mWXSelectedSlotIdx] || bro.slots[0];
		if (!s) return;

		if (s.unlocked) {
			this.mWXStrip.html(
				'<span class="wx-c-label">选中</span> <span class="wx-c-title">穴' + WX_CN_NUM[s.slotIndex + 1] + ' · ' + wxEscapeHtml(s.slotLabel) + '</span>' +
				'<span class="wx-c-desc">　可装 ' + wxEscapeHtml(wxCatsLabel(s.allowedCategories)) + '，亮起的秘籍可直接右键或拖入</span>'
			);
		} else {
			this.mWXStrip.html(
				'<span class="wx-c-desc">穴' + WX_CN_NUM[s.slotIndex + 1] + '「' + wxEscapeHtml(s.slotLabel) + '」尚未贯通（' + s.unlockLevel + ' 级开启）</span>'
			);
		}
	};

	CharacterScreenPerksModule.prototype.wxFindBestSlotForCategory = function (_category, _equippedSlotIndex) {
		var bro = this.mWXState && this.mWXState.brother;
		if (!bro || !bro.slots) return -1;

		var selSlot = bro.slots[this.mWXSelectedSlotIdx];
		if (selSlot && selSlot.unlocked && !selSlot.manualID && this.wxCanCategoryFitSlot(_category, _equippedSlotIndex, selSlot)) {
			return selSlot.slotIndex;
		}
		for (var i = 0; i < bro.slots.length; i++) {
			if (bro.slots[i].unlocked && !bro.slots[i].manualID && this.wxCanCategoryFitSlot(_category, _equippedSlotIndex, bro.slots[i])) {
				return i;
			}
		}
		if (selSlot && selSlot.unlocked && this.wxCanCategoryFitSlot(_category, _equippedSlotIndex, selSlot)) {
			return selSlot.slotIndex;
		}
		for (var k = 0; k < bro.slots.length; k++) {
			if (bro.slots[k].unlocked && this.wxCanCategoryFitSlot(_category, _equippedSlotIndex, bro.slots[k])) {
				return k;
			}
		}
		return -1;
	};

	CharacterScreenPerksModule.prototype.wxFindBestSlotForLearned = function (_lm) {
		return this.wxFindBestSlotForCategory(_lm.category, _lm.equippedSlotIndex);
	};

	CharacterScreenPerksModule.prototype.wxRenderLearnedList = function () {
		var self = this;
		var body = this.mWXScrollArea.body;
		body.empty();

		var bro = this.mWXState.brother;
		var selSlot = bro.slots[this.mWXSelectedSlotIdx] || null;

		if (this.mWXShelfMode === 'pill') {
			this.wxRenderPillSlots(body);
			this.mWXScrollArea.refresh();
			return;
		}

		if (this.mWXShelfMode === 'vault') {
			this.wxRenderVaultDirectSlots(body, selSlot);
			this.mWXScrollArea.refresh();
			return;
		}

		var learned = bro.learnedManuals || [];
		var shown = 0;
		for (var i = 0; i < learned.length; i++) {
			var lm = learned[i];
			if (this.mWXCatFilter && lm.category !== this.mWXCatFilter) continue;
			body.append(this.wxCreateLearnedSlot(lm, selSlot));
			shown++;
		}
		body.append('<div class="wx-clear"></div>');

		if (shown === 0) {
			var vaultCnt = this.wxCountVaultUnlearned(this.mWXState);
			var emptyBox = $(
				'<div class="wx-c-desc" style="padding:1.6rem 0.8rem;">' +
					'<div>' + (learned.length === 0 ? (wxEscapeHtml(bro.name) + ' 尚未研习武学。') : '没有符合筛选的已习武学。') + '</div>' +
					(vaultCnt > 0 ? '<div style="margin-top:0.8rem;font-style:normal;"><span class="wx-vb wx-vb1" data-wx="switch-vault">阁藏直学<span class="wx-cnt">' + vaultCnt + '</span></span></div>' : '') +
				'</div>'
			);
			emptyBox.find('[data-wx="switch-vault"]').on('click', function () {
				self.wxSetShelfMode('vault');
			});
			body.html(emptyBox);
		}

		this.mWXScrollArea.refresh();
	};

	CharacterScreenPerksModule.prototype.wxCreateLearnedSlot = function (_lm, _selSlot) {
		var self = this;
		var isEquipped = (_lm.equippedSlotIndex >= 0);
		var unl = _selSlot ? _selSlot.unlocked : false;
		var fitsSel = (_selSlot && unl) ? this.wxCanLearnedFitSlot(_lm, _selSlot) : false;
		var dimCls = (!isEquipped && unl && !fitsSel) ? ' is-dim' : '';

		var hlHtml = (!isEquipped && unl && fitsSel) ? '<div class="wx-hl" style="opacity:0.58;"></div>' : '';
		var tagHtml = isEquipped
			? ('<span class="wx-tag">穴' + WX_CN_NUM[_lm.equippedSlotIndex + 1] + '</span>')
			: (_lm.isFragment ? '<span class="wx-tag">残</span>' : '');
		var amtText = WX_TIER_SHORT[_lm.tier] || _lm.tierLabel;

		var slot = $(
			'<div class="wx-vslot' + dimCls + '">' +
				hlHtml +
				'<img class="wx-it is-round" src="coui://gfx/' + _lm.icon + '" alt=""/>' +
				tagHtml +
				'<span class="wx-amt">' + amtText + '</span>' +
			'</div>'
		);

		wxBindInspectorClick(this, slot, 'learned', _lm);

		slot.on('contextmenu dblclick', function (_e) {
			_e.preventDefault();
			_e.stopPropagation();
			if (isEquipped) {
				self.wxSubmitUnequipSlot(_lm.equippedSlotIndex, false);
			} else {
				var target = fitsSel ? _selSlot.slotIndex : self.wxFindBestSlotForLearned(_lm);
				if (target >= 0) {
					self.wxSubmitEquipLearned(target, _lm.manualID, false);
				} else {
					self.wxShowToast('当前没有可装入此功法的穴位。', true);
				}
			}
			return false;
		});

		if (!isEquipped) {
			this.wxBindSlotDrag(slot, {
				kind: 'learned',
				manualID: _lm.manualID,
				category: _lm.category,
				equippedSlotIndex: _lm.equippedSlotIndex,
				icon: _lm.icon
			});
		}

		return slot;
	};

	CharacterScreenPerksModule.prototype.wxRenderVaultDirectSlots = function (_body, _selSlot) {
		var items = (this.mWXState && this.mWXState.library && this.mWXState.library.items) ? this.mWXState.library.items : [];
		var shown = 0;

		for (var i = 0; i < items.length; i++) {
			var it = items[i];
			if (!wxCanLearnVaultItem(it)) continue;
			if (this.mWXCatFilter && it.category !== this.mWXCatFilter) continue;

			_body.append(this.wxCreateVaultDirectSlot(it, _selSlot, it.itemKind === 'page'));
			shown++;
		}
		_body.append('<div class="wx-clear"></div>');

		if (shown === 0) {
			_body.html('<div class="wx-c-desc" style="padding:1.8rem 0.8rem;">藏经阁中没有本人未习的秘籍。</div>');
		}
	};

	CharacterScreenPerksModule.prototype.wxCreateVaultDirectSlot = function (_it, _selSlot, _isFrag) {
		var self = this;
		var unl = _selSlot ? _selSlot.unlocked : false;
		var fitsSel = (_selSlot && unl) ? this.wxCanCategoryFitSlot(_it.category, -1, _selSlot) : false;
		var bestIdx = this.wxFindBestSlotForCategory(_it.category, -1);
		var chosenIdx = fitsSel ? _selSlot.slotIndex : bestIdx;
		var dimCls = (unl && !fitsSel) ? ' is-dim' : '';

		var hlHtml = (unl && fitsSel) ? '<div class="wx-hl" style="opacity:0.55;"></div>' : '';
		var tagHtml = _isFrag ? '<span class="wx-tag">残</span>' : '';

		var slot = $(
			'<div class="wx-vslot' + dimCls + '">' +
				hlHtml +
				'<img class="wx-it" src="coui://gfx/' + _it.icon + '" alt=""/>' +
				tagHtml +
				'<span class="wx-amt">×' + _it.count + '</span>' +
			'</div>'
		);

		wxBindInspectorClick(this, slot, 'vault', _it);

		slot.on('contextmenu dblclick', function (_e) {
			_e.preventDefault();
			_e.stopPropagation();
			self.wxSubmitLearnAndEquip(chosenIdx >= 0 ? chosenIdx : -1, _it.manualID, _isFrag, false);
			return false;
		});

		this.wxBindSlotDrag(slot, {
			kind: _isFrag ? 'vault_frag' : 'vault_manual',
			manualID: _it.manualID,
			category: _it.category,
			equippedSlotIndex: -1,
			icon: _it.icon
		});

		return slot;
	};

	CharacterScreenPerksModule.prototype.wxRenderPillSlots = function (_body) {
		var self = this;
		var pills = (this.mWXState && this.mWXState.stashItems) ? this.mWXState.stashItems : [];
		if (pills.length === 0) {
			_body.html('<div class="wx-c-desc" style="padding:1.8rem 0.8rem;">战团仓库中当前没有灵丹或异兽内丹。</div>');
			return;
		}

		for (var i = 0; i < pills.length; i++) {
			(function (_p) {
				var amt = '';
				if (_p.itemKind === 'pill_infuse') amt = '+' + _p.expAmount;
				else if (_p.pillGrade && _p.pillGrade >= 2 && _p.potencyPct) amt = _p.potencyPct + '%';
				var slot = $(
					'<div class="wx-vslot">' +
						'<img class="wx-it" src="coui://gfx/' + _p.icon + '" alt=""/>' +
						(amt ? '<span class="wx-amt">' + amt + '</span>' : '') +
					'</div>'
				);

				wxBindInspectorClick(self, slot, 'pill', _p);

				slot.on('contextmenu dblclick', function (_e) {
					_e.preventDefault();
					_e.stopPropagation();
					if (_p.itemKind === 'pill_infuse') wxInfusePillToSelectedSlot(self, _p);
					else if (_p.itemKind === 'pill_wash') self.wxOpenWashModal(_p.pillID);
					else self.wxTriggerUsePill(_p);
					return false;
				});

				if (_p.itemKind === 'pill_infuse') {
					self.wxBindSlotDrag(slot, {
						kind: 'pill_infuse',
						stashIndex: _p.stashIndex,
						icon: _p.icon
					});
				}

				_body.append(slot);
			})(pills[i]);
		}
		_body.append('<div class="wx-clear"></div>');
	};

	function wxInfusePillToSelectedSlot(_panel, _pill) {
		var slot = _panel.mWXState.brother.slots[_panel.mWXSelectedSlotIdx];
		if (!wxCanInfuseSlot(slot)) {
			_panel.wxShowToast(slot && slot.blockedByReq ? '此功法火候已满，须先满足三重突破条件。' : '请先点击可灌注的功法。', true);
			return;
		}
		_panel.mDataSource.notifyBackendWXInfusePill(_panel.mWXCurrentEntityId, _pill.stashIndex, slot.slotIndex, function (_res) {
			_panel.wxApplyBackendState(_res);
		});
	}

	CharacterScreenPerksModule.prototype.wxTriggerUsePill = function (_pillItem) {
		var self = this;
		if (this.mWXCurrentEntityId === null || !this.mDataSource) return;
		this.mDataSource.notifyBackendWXUsePill(this.mWXCurrentEntityId, _pillItem.stashIndex, function (_res) {
			self.wxApplyBackendState(_res);
		});
	};

	CharacterScreenPerksModule.prototype.wxSubmitLearnAndEquip = function (_slotIndex, _manualID, _isFragment, _confirmed, _expectedManualID) {
		var self = this;
		var eid = this.mWXCurrentEntityId;
		var selected = this.mWXInspected;
		if (eid === null) return;

		this.mDataSource.notifyBackendWXLearnAndEquip(eid, _slotIndex, _manualID, _isFragment, _confirmed, function (_res) {
			if (!_res || self.mWXCurrentEntityId !== eid) return;
			if (_res.needsConfirm) {
				self.wxOpenSlotConfirmModal(_res, _slotIndex, _manualID, function () {
					if (self.mWXCurrentEntityId === eid) self.wxSubmitLearnAndEquip(_slotIndex, _manualID, _isFragment, true, _res.oldManualID);
				});
				return;
			}
			if (_res.ok && _slotIndex >= 0 && self.mWXInspected === selected) {
				self.mWXSelectedSlotIdx = _slotIndex;
				self.mWXInspected = { kind: 'slot', slotIndex: _slotIndex };
			}
			self.wxApplyBackendState(_res);
		}, _expectedManualID);
	};

	CharacterScreenPerksModule.prototype.wxSubmitEquipLearned = function (_slotIndex, _manualID, _confirmed, _expectedManualID) {
		var self = this;
		var eid = this.mWXCurrentEntityId;
		var selected = this.mWXInspected;
		if (eid === null) return;

		this.mDataSource.notifyBackendWXEquipLearned(eid, _slotIndex, _manualID, _confirmed, function (_res) {
			if (!_res || self.mWXCurrentEntityId !== eid) return;
			if (_res.needsConfirm) {
				self.wxOpenSlotConfirmModal(_res, _slotIndex, _manualID, function () {
					if (self.mWXCurrentEntityId === eid) self.wxSubmitEquipLearned(_slotIndex, _manualID, true, _res.oldManualID);
				});
				return;
			}
			if (_res.ok && self.mWXInspected === selected) {
				self.mWXSelectedSlotIdx = _slotIndex;
				self.mWXInspected = { kind: 'slot', slotIndex: _slotIndex };
			}
			self.wxApplyBackendState(_res);
		}, _expectedManualID);
	};

	CharacterScreenPerksModule.prototype.wxSubmitUnequipSlot = function (_slotIndex, _confirmed, _expectedManualID) {
		var self = this;
		var eid = this.mWXCurrentEntityId;
		if (eid === null) return;

		this.mDataSource.notifyBackendWXUnequipSlot(eid, _slotIndex, _confirmed, _expectedManualID, function (_res) {
			if (!_res || self.mWXCurrentEntityId !== eid) return;
			if (_res.needsConfirm) {
				self.wxOpenSlotConfirmModal(_res, _slotIndex, null, function () {
					if (self.mWXCurrentEntityId === eid) self.wxSubmitUnequipSlot(_slotIndex, true, _res.oldManualID);
				});
				return;
			}
			self.wxApplyBackendState(_res);
		});
	};

	CharacterScreenPerksModule.prototype.wxFindManualIconById = function (_manualID) {
		if (!_manualID || !this.mWXState) return '';
		var bro = this.mWXState.brother;
		if (bro) {
			var s = bro.slots || [];
			for (var i = 0; i < s.length; i++) {
				if (s[i].manualID === _manualID && s[i].icon) return s[i].icon;
			}
			var lm = bro.learnedManuals || [];
			for (var j = 0; j < lm.length; j++) {
				if (lm[j].manualID === _manualID && lm[j].icon) return lm[j].icon;
			}
		}
		var lib = (this.mWXState.library && this.mWXState.library.items) ? this.mWXState.library.items : [];
		for (var k = 0; k < lib.length; k++) {
			if (lib[k].manualID === _manualID && lib[k].icon) return lib[k].icon;
		}
		return '';
	};

	CharacterScreenPerksModule.prototype.wxOpenSlotConfirmModal = function (_info, _slotIndex, _newManualID, _onConfirm) {
		var self = this;
		var title = '换装调息';
		var bodyHtml = '';
		var bro = this.mWXState && this.mWXState.brother;
		var oldSlot = (bro && bro.slots && _slotIndex >= 0 && _slotIndex < bro.slots.length) ? bro.slots[_slotIndex] : null;
		var oldIcon = (oldSlot && oldSlot.icon) ? oldSlot.icon : this.wxFindManualIconById(_info.oldManualID);
		var newIcon = this.wxFindManualIconById(_newManualID || _info.newManualID);

		if (_info.confirmKind === 'unequip_slot') {
			title = '卸下功法';
			bodyHtml =
				(oldIcon ? ('<div class="wx-swap">' + wxSwapSlotHtml(oldIcon, true) + '</div>') : '') +
				'确定从穴位卸下《' + wxEscapeHtml(_info.oldManualName) + '》？<br/>' +
				'<span class="wx-c-neg">散功调息 ' + _info.penaltyDays + ' 天</span><br/>' +
				'<span class="wx-c-desc">已练重数与火候永久保留于已习武学中。</span>';
		} else if (_info.confirmKind === 'fragment_learn') {
			title = '残本强修';
			bodyHtml =
				(newIcon ? ('<div class="wx-swap">' + wxSwapSlotHtml(newIcon, false) + '</div>') : '') +
				'消耗 1 张《' + wxEscapeHtml(_info.newManualName) + '》残页强记口诀' + (_slotIndex >= 0 ? '并装入穴位' : '') + '。<br/>' +
				(_info.isOverwrite ? ('替换《' + wxEscapeHtml(_info.oldManualName) + '》，散功调息 ' + _info.penaltyDays + ' 天。<br/>') : '') +
				'<span class="wx-c-neg">最高止步一重，实战偶有行气不畅。</span><br/>' +
				'<span class="wx-c-desc">日后研读完整秘籍可无损补全。</span>';
		} else {
			var swapHtml = (oldIcon || newIcon)
				? ('<div class="wx-swap">' + wxSwapSlotHtml(oldIcon, true) + '<span class="wx-arr">➜</span>' + wxSwapSlotHtml(newIcon, true) + '</div>')
				: '';
			bodyHtml =
				swapHtml +
				'将以《' + wxEscapeHtml(_info.newManualName) + '》替换《' + wxEscapeHtml(_info.oldManualName) + '》。<br/>' +
				'<span class="wx-c-neg">散功调息 ' + _info.penaltyDays + ' 天</span><br/>' +
				'<span class="wx-c-desc">《' + wxEscapeHtml(_info.oldManualName) + '》的重数与火候会永久保留。</span>';
		}

		var box = $(
			'<div class="wx-popup">' +
				'<div class="wx-ph wx-t-title">' + title + '</div>' +
				'<div class="wx-pb">' + bodyHtml + '</div>' +
				'<div class="wx-pf">' +
					'<span class="wx-vb wx-vb1" data-wx="c-yes">确定</span>' +
					'<span class="wx-vb wx-vb1" data-wx-close="1">取消</span>' +
				'</div>' +
			'</div>'
		);

		box.find('[data-wx="c-yes"]').on('click', function () {
			self.wxCloseModal();
			_onConfirm();
		});
		this.wxOpenModal(box);
	};

	// ------------------------------------------------------------------------
	// 7. Right-Hand Leather Inspector (dialog_panel_01) & Infuse Modal
	// ------------------------------------------------------------------------
	CharacterScreenPerksModule.prototype.wxRefreshInspector = function () {
		var bro = this.mWXState && this.mWXState.brother;
		if (!bro) return;

		var slot = bro.slots[this.mWXSelectedSlotIdx] || bro.slots[0];
		var selected = this.mWXInspected;
		if (selected && selected.kind !== 'slot') {
			var lists = {
				learned: bro.learnedManuals,
				move: bro.activeMoves,
				vault: this.mWXState.library && this.mWXState.library.items,
				pill: this.mWXState.stashItems
			};
			var list = lists[selected.kind] || [];
			for (var i = 0; i < list.length; i++) {
				var item = list[i];
				if (wxInspectorItemKey(selected.kind, item) !== selected.key) continue;
				if (selected.kind === 'learned') this.wxRenderLearnedInspector(item);
				else if (selected.kind === 'move') this.wxRenderMoveInspector(item);
				else if (selected.kind === 'pill') this.wxRenderPillInspector(item);
				else {
					if (!wxCanLearnVaultItem(item)) continue;
					var target = this.wxCanCategoryFitSlot(item.category, -1, slot) ? slot.slotIndex : this.wxFindBestSlotForCategory(item.category, -1);
					this.wxRenderVaultItemInspector(item, target, item.itemKind === 'page');
				}
				return;
			}
			this.mWXInspected = null;
		}

		if (slot) {
			this.wxRenderSlotInspector(slot);
		}
	};

	CharacterScreenPerksModule.prototype.wxRenderMoveInspector = function (_mv) {
		var qiStr = (_mv.rawQi > _mv.qi)
			? (_mv.qi + ' 内息（原 ' + _mv.rawQi + '）')
			: (_mv.qi + ' 内息');
		var html =
			'<div class="wx-hd">' +
				'<img src="coui://gfx/' + _mv.icon + '" alt=""/>' +
				'<div class="wx-t-title">' + wxEscapeHtml(_mv.name) + '</div>' +
				'<div class="wx-s"><span class="wx-c-title">' + _mv.ap + ' AP</span> · <span class="wx-c-title">' + qiStr + '</span></div>' +
			'</div>';
		if (_mv.weaponReq && !_mv.weaponOk) {
			html += '<div class="wx-ln wx-c-neg">需持' + wxEscapeHtml(_mv.weaponReq) + '方可施展</div>';
		}
		html += '<div class="wx-desc">' + wxEscapeHtml(_mv.desc) + '</div>';
		this.mWXInspBody.html(html);
		this.mWXInspFoot.empty();
	};

	CharacterScreenPerksModule.prototype.wxRenderPillInspector = function (_p) {
		var self = this;
		var html =
			'<div class="wx-hd">' +
				'<img src="coui://gfx/' + _p.icon + '" alt=""/>' +
				'<div class="wx-t-title">' + wxEscapeHtml(_p.name) + '</div>' +
				'<div class="wx-s">' + wxEscapeHtml(_p.qualityLabel + ' · ' + _p.categoryLabel) + '</div>' +
			'</div>' +
			'<div class="wx-desc">' + wxEscapeHtml(_p.description) + '</div>';

		var foot = '';
		if (_p.itemKind === 'pill_infuse') {
			var slot = this.mWXState.brother.slots[this.mWXSelectedSlotIdx];
			foot = wxCanInfuseSlot(slot)
				? '<span class="wx-vb wx-vb1" data-pa="infuse">灌注穴' + WX_CN_NUM[slot.slotIndex + 1] + '</span>'
				: '<span class="wx-vb wx-vb1 is-dis">请先选择可灌注的功法</span>';
		} else if (_p.itemKind === 'pill_wash') {
			foot = '<span class="wx-vb wx-vb1" data-pa="wash">洗经伐髓</span>';
		} else {
			foot = '<span class="wx-vb wx-vb2" data-pa="consume">服用</span>';
		}

		this.mWXInspBody.html(html);
		this.mWXInspFoot.html(foot);
		this.mWXInspFoot.find('[data-pa]').on('click', function () {
			var pa = $(this).attr('data-pa');
			if (pa === 'infuse') wxInfusePillToSelectedSlot(self, _p);
			else if (pa === 'wash') self.wxOpenWashModal(_p.pillID);
			else self.wxTriggerUsePill(_p);
		});
	};

	CharacterScreenPerksModule.prototype.wxBuildManualInspectorBody = function (_m, _tier, _isFrag, _exp, _expNeeded, _statusSub, _roundIcon) {
		var sub = wxEscapeHtml(_m.qualityLabel || '') +
			(_m.categoryLabel ? (' · ' + wxEscapeHtml(_m.categoryLabel)) : '') +
			(_m.weaponLabel ? (' · ' + wxEscapeHtml(_m.weaponLabel)) : '');

		var html =
			'<div class="wx-hd">' +
				'<img' + (_roundIcon ? ' class="is-round"' : '') + ' src="coui://gfx/' + _m.icon + '" alt=""/>' +
				'<div class="wx-t-title">《' + wxEscapeHtml(_m.rawName || _m.name) + '》</div>' +
				'<div class="wx-s">' + sub + '</div>' +
				'<div class="wx-s wx-c-desc">' + _statusSub + '</div>' +
			'</div>';

		if (_m.weaponLabel && !_m.matchesWeapon) {
			html += '<div class="wx-ln wx-c-neg">当前主手非' + wxEscapeHtml(_m.weaponLabel) + '，外功暂不生效</div>';
		}
		if (_isFrag) {
			html += '<div class="wx-ln wx-c-neg">残本强修：最高止步一重（研读整本可补全）</div>';
		}

		html += '<div class="wx-desc">' + wxEscapeHtml(_m.description || '') + '</div>';

		var summaries = _m.levelSummaries || [];
		for (var i = 0; i < summaries.length; i++) {
			var lv = summaries[i];
			var lvTier = lv.tier || (i + 1);
			var cls = lvTier <= _tier ? 'is-done' : (_tier > 0 && lvTier === _tier + 1 ? 'is-next' : '');
			html += '<div class="wx-tl ' + cls + '"><b>' + wxEscapeHtml(lv.title) + '</b>' + wxEscapeHtml(lv.text);
			if (cls === 'is-next' && !_isFrag && _expNeeded > 0) {
				html += '<br/>' + wxXpBarHtml(_exp, _expNeeded, false, 13) + ' <span class="wx-c-desc">火候 ' + _exp + ' / ' + _expNeeded + '</span>';
			}
			html += '</div>';
		}

		if (_m.missingReqs && _m.missingReqs.length > 0) {
			html += '<div class="wx-ln"><span class="wx-c-label">大成门槛　</span><span class="wx-c-neg">' + wxEscapeHtml(_m.missingReqs.join('　')) + '</span></div>';
		}

		return html;
	};

	CharacterScreenPerksModule.prototype.wxRenderVaultItemInspector = function (_it, _chosenSlotIdx, _isFrag) {
		var self = this;
		var statusSub = '藏经阁 ×' + _it.count + (_isFrag ? ' · 残页强修' : ' · 未习');
		var html = this.wxBuildManualInspectorBody(_it, 0, _isFrag, 0, 0, statusSub, false);

		var foot = '<span class="wx-vb wx-vb2" data-viact="lo">' + (_isFrag ? '强修' : '研习') + '</span>';
		if (_chosenSlotIdx >= 0) {
			foot += '<span class="wx-vb wx-vb2" data-viact="le">' + (_isFrag ? '强修装' : '习并装') + '</span>';
		}

		this.mWXInspBody.html(html);
		this.mWXInspFoot.html(foot);
		this.mWXInspFoot.find('[data-viact="le"]').on('click', function () {
			self.wxSubmitLearnAndEquip(_chosenSlotIdx, _it.manualID, _isFrag, false);
		});
		this.mWXInspFoot.find('[data-viact="lo"]').on('click', function () {
			self.wxSubmitLearnAndEquip(-1, _it.manualID, _isFrag, false);
		});
	};

	CharacterScreenPerksModule.prototype.wxRenderSlotInspector = function (_s) {
		var self = this;
		var bro = this.mWXState.brother;

		if (!_s.unlocked || !_s.manualID) {
			var neigongCnt = 0;
			var qinggongCnt = 0;
			for (var k = 0; k < bro.slots.length; k++) {
				if (bro.slots[k].manualID && bro.slots[k].category === 'neigong') neigongCnt++;
				if (bro.slots[k].manualID && bro.slots[k].category === 'qinggong') qinggongCnt++;
			}

			var html =
				'<div class="wx-hd">' +
					'<img src="coui://gfx/ui/perks/selection_frame.png" alt=""/>' +
					'<div class="wx-t-title">' + wxEscapeHtml(_s.slotLabel) + '</div>' +
					'<div class="wx-s">' + (_s.unlocked ? '已贯通 · 空穴' : (_s.unlockLevel + ' 级贯通')) + '</div>' +
				'</div>' +
				'<div class="wx-ln"><span class="wx-c-label">可配　</span><span class="wx-c-title">' + wxEscapeHtml(wxCatsLabel(_s.allowedCategories)) + '</span></div>' +
				'<div class="wx-desc" style="margin-top:0.6rem;">空穴装入免费；换装或卸下会散功调息，已练重数永久保留。同系常驻加成只取最高一项。</div>' +
				'<div class="wx-ln"><span class="wx-c-label">全身内功　</span><span class="wx-c-title">' + neigongCnt + ' / 2</span>　<span class="wx-c-label">轻功　</span><span class="wx-c-title">' + qinggongCnt + ' / 2</span></div>';

			var vaultCnt = this.wxCountVaultUnlearned(this.mWXState);
			var foot = (_s.unlocked && vaultCnt > 0)
				? ('<span class="wx-vb wx-vb1" data-sact="show-vault">阁藏直学<span class="wx-cnt">' + vaultCnt + '</span></span>')
				: '';

			this.mWXInspBody.html(html);
			this.mWXInspFoot.html(foot);
			this.mWXInspFoot.find('[data-sact="show-vault"]').on('click', function () {
				self.wxSetShelfMode('vault');
			});
			return;
		}

		var statusSub = '装于穴' + WX_CN_NUM[_s.slotIndex + 1] + ' · ' + wxEscapeHtml(_s.tierLabel);
		var bodyHtml = this.wxBuildManualInspectorBody(_s, _s.tier, _s.isFragment, _s.exp, _s.expNeeded, statusSub, true);

		var footHtml = '';
		if (wxCanInfuseSlot(_s)) {
			footHtml += '<span class="wx-vb wx-vb2" data-sact="open-infuse">灌注</span>';
		}
		footHtml += '<span class="wx-vb wx-vb2" data-sact="unequip">卸下</span>';

		this.mWXInspBody.html(bodyHtml);
		this.mWXInspFoot.html(footHtml);
		this.mWXInspFoot.find('[data-sact="open-infuse"]').on('click', function () {
			self.wxOpenInfusePickerModal(_s);
		});
		this.mWXInspFoot.find('[data-sact="unequip"]').on('click', function () {
			self.wxSubmitUnequipSlot(_s.slotIndex, false);
		});
	};

	CharacterScreenPerksModule.prototype.wxRenderLearnedInspector = function (_lm) {
		var self = this;
		var slots = this.mWXState.brother.slots;
		var equipped = slots[_lm.equippedSlotIndex];
		if (equipped && equipped.manualID === _lm.manualID) {
			this.wxRenderSlotInspector(equipped);
			return;
		}
		var selSlot = slots[this.mWXSelectedSlotIdx];
		var statusSub = '已习 · ' + wxEscapeHtml(_lm.tierLabel);
		var bodyHtml = this.wxBuildManualInspectorBody(_lm, _lm.tier, _lm.isFragment, _lm.exp, _lm.expNeeded, statusSub, true);

		var footHtml = '';
		if (selSlot && this.wxCanLearnedFitSlot(_lm, selSlot)) {
			footHtml = '<span class="wx-vb wx-vb1" data-liact="equip-sel">装入穴' + WX_CN_NUM[selSlot.slotIndex + 1] + '</span>';
		} else {
			var bestIdx = this.wxFindBestSlotForLearned(_lm);
			if (bestIdx >= 0) {
				footHtml = '<span class="wx-vb wx-vb1" data-liact="equip-best">装入穴' + WX_CN_NUM[bestIdx + 1] + '</span>';
			} else {
				footHtml = '<span class="wx-vb wx-vb1 is-dis">无兼容穴位</span>';
			}
		}

		this.mWXInspBody.html(bodyHtml);
		this.mWXInspFoot.html(footHtml);
		this.mWXInspFoot.find('[data-liact]').on('click', function () {
			if ($(this).hasClass('is-dis')) return;
			var a = $(this).attr('data-liact');
			if (a === 'equip-sel' && selSlot) self.wxSubmitEquipLearned(selSlot.slotIndex, _lm.manualID, false);
			else if (a === 'equip-best') {
				var bi = self.wxFindBestSlotForLearned(_lm);
				if (bi >= 0) self.wxSubmitEquipLearned(bi, _lm.manualID, false);
			}
		});
	};

	CharacterScreenPerksModule.prototype.wxOpenInfusePickerModal = function (_slot) {
		var self = this;
		var entityId = this.mWXCurrentEntityId;
		var pills = (this.mWXState && this.mWXState.stashItems) ? this.mWXState.stashItems : [];
		var libItems = (this.mWXState && this.mWXState.library && this.mWXState.library.items) ? this.mWXState.library.items : [];

		var rowsHtml = '';
		var count = 0;

		for (var i = 0; i < pills.length; i++) {
			var p = pills[i];
			if (p.itemKind === 'pill_infuse') {
				count++;
				var expVal = p.expAmount;
				var pSub = (p.stashIndex <= -1000) ? '百草药柜藏品' : '战团仓库灵丹';
				if (p.pillKind === 'neidan' && _slot.manualID && _slot.manualID.indexOf('wx_manual_shanhai_') === 0) {
					expVal = 500;
					pSub += ' · 山海孤本共鸣';
				} else if (p.auxNature && _slot.category) {
					var auxHit =
						(p.auxNature === 'origin') ||
						(p.auxNature === 'yang' && _slot.category === 'external') ||
						(p.auxNature === 'yin' && _slot.category === 'lightness') ||
						(p.auxNature === 'vital' && _slot.category === 'hardening') ||
						(p.auxNature === 'spirit' && _slot.category === 'internal') ||
						(p.auxNature === 'venom' && (_slot.category === 'external' || _slot.category === 'hardening'));
					if (auxHit) {
						expVal = Math.floor(expVal * 1.15);
						pSub += ' · ' + (p.auxTitle || '药引丹韵') + '共鸣 +15%';
					}
				}
				rowsHtml +=
					'<div class="wx-pick" data-inf-pill="' + p.stashIndex + '">' +
						wxSwapSlotHtml(p.icon, false) +
						'<div class="wx-c-title">' + wxEscapeHtml(p.name) + '</div>' +
						'<div class="wx-c-desc">' + wxEscapeHtml(pSub) + '</div>' +
						'<span class="wx-g">+' + expVal + ' 火候</span>' +
					'</div>';
			}
		}

		for (var j = 0; j < libItems.length; j++) {
			var lb = libItems[j];
			if (lb.itemKind === 'page' && lb.count > 0) {
				count++;
				var mult = 1.0;
				var note = '';
				if (lb.manualID === _slot.manualID) { mult = 1.5; note = ' · 同名 +50%'; }
				else if (lb.category === _slot.category) { mult = 1.25; note = ' · 同脉 +25%'; }
				var gain = Math.max(1, Math.floor((lb.infuseBaseExp || 40) * mult));
				rowsHtml +=
					'<div class="wx-pick" data-inf-page="' + lb.manualID + '">' +
						wxSwapSlotHtml(lb.icon, false) +
						'<div class="wx-c-title">《' + wxEscapeHtml(lb.name) + '》残页</div>' +
						'<div class="wx-c-desc">藏经阁 ×' + lb.count + note + '</div>' +
						'<span class="wx-g">+' + gain + ' 火候</span>' +
					'</div>';
			}
		}

		if (count === 0) {
			this.wxShowToast('仓库没有凝神灵丹，藏经阁中也没有可供化功的残页。', true);
			return;
		}

		var box = $(
			'<div class="wx-popup">' +
				'<div class="wx-ph wx-t-title">灌注火候 · 《' + wxEscapeHtml(_slot.rawName || _slot.name) + '》</div>' +
				'<div class="wx-pb">' + rowsHtml + '</div>' +
				'<div class="wx-pf"><span class="wx-vb wx-vb1" data-wx-close="1">关闭</span></div>' +
			'</div>'
		);

		box.find('[data-inf-pill], [data-inf-page]').on('click', function () {
			self.wxCloseModal();
			var liveSlot = self.mWXState.brother.slots[_slot.slotIndex];
			if (entityId !== self.mWXCurrentEntityId || !wxCanInfuseSlot(liveSlot) || liveSlot.manualID !== _slot.manualID) {
				self.wxShowToast('功法已变动，请重新选择要灌注的功法。', true);
				return;
			}
			var pillIndex = $(this).attr('data-inf-pill');
			function onInfused(_res) { self.wxApplyBackendState(_res); }
			if (pillIndex !== undefined) {
				self.mDataSource.notifyBackendWXInfusePill(entityId, parseInt(pillIndex, 10), _slot.slotIndex, onInfused);
			} else {
				self.mDataSource.notifyBackendWXInfuseLibraryPage(entityId, $(this).attr('data-inf-page'), _slot.slotIndex, onInfused);
			}
		});

		this.wxOpenModal(box);
	};

	// ------------------------------------------------------------------------
	// 8. Marrow Wash (洗经伐髓) — Vanilla Level-Up Row Structure + Wood Popup
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

		var starredCount = 0;
		for (var sIdx = 0; sIdx < 8; sIdx++) {
			if (bro.talents[sIdx] > 0) starredCount++;
		}

		var sourceDesc = pendingChances > 0
			? ('消耗孤本大成洗髓契机（余 ' + pendingChances + ' 次）')
			: ('消耗洗髓丹（仓库余 ' + washPills + ' 颗）');

		var box = $(
			'<div class="wx-popup is-wash">' +
				'<div class="wx-ph wx-t-title">洗经伐髓</div>' +
				'<div class="wx-pb">' +
					'<div class="wx-c-desc" data-wx="wash-prompt" style="text-align:center;margin-bottom:0.7rem;">选择要冲击的属性（' + sourceDesc + '）</div>' +
					'<div data-wx="wash-rows"></div>' +
					'<div class="wx-odds">' +
						'<div data-wx="wash-preview"><span class="wx-c-desc">每人至多 3 项带星。冲星 30% / 15%，易筋换星 45%，筹备加成最多 +20%。</span></div>' +
						'<div style="margin-top:0.4rem;">' +
							'<span class="wx-vchk' + (protectPills <= 0 ? ' is-dis' : '') + '" data-wx="use-protect"><i></i>辅服护脉丹（余 ' + protectPills + '）：+5%，免暗疾</span>' +
						'</div>' +
					'</div>' +
				'</div>' +
				'<div class="wx-pf">' +
					'<span class="wx-vb wx-vb1 is-dis" data-wx="wash-exec">洗髓</span>' +
					'<span class="wx-vb wx-vb1" data-wx-close="1">取消</span>' +
				'</div>' +
			'</div>'
		);

		function renderAttrRows() {
			var st = self.mWXWashState;
			var needRep = (st.targetAttrIdx >= 0 && bro.talents[st.targetAttrIdx] === 0 && starredCount >= 3);
			var promptEl = box.find('[data-wx="wash-prompt"]');
			if (needRep && st.replaceAttrIdx < 0) {
				promptEl.html('<span class="wx-c-title">已有 3 项带星：请再点选一项带星属性洗去旧星（易筋换星）</span>');
			} else {
				promptEl.html('选择要冲击的属性（' + sourceDesc + '）');
			}

			var rowsHost = box.find('[data-wx="wash-rows"]').empty();
			for (var i = 0; i < 8; i++) {
				var t = bro.talents[i] || 0;
				var cls = 'wx-lvrow' + (i % 2 === 1 ? ' is-even' : '');
				if (t >= 3 && !needRep) cls += ' is-max';
				if (st.targetAttrIdx === i) cls += ' is-sel';
				if (needRep && st.replaceAttrIdx === i) cls += ' is-rep';

				var barPct = Math.min(100, Math.round((bro.baseStats[i] || 0) / 1.3));
				var talHtml = t > 0 ? ('<img class="wx-talent" src="coui://gfx/ui/icons/talent_' + t + '.png" alt=""/>') : '';

				var row = $(
					'<div class="' + cls + '" data-attr-idx="' + i + '">' +
						'<img class="wx-ico" src="coui://gfx/ui/icons/' + WX_STAT_ICONS[i] + '.png" alt=""/>' +
						talHtml +
						'<div class="wx-vbar"><div class="wx-f" style="width:' + barPct + '%;"></div><div class="wx-v">' + bro.baseStats[i] + '</div></div>' +
						'<span class="wx-nm">' + wxEscapeHtml(bro.attrLabels[i]) + '</span>' +
					'</div>'
				);

				(function (_attrIdx, _stars) {
					row.on('click', function () {
						var curNeedRep = (self.mWXWashState.targetAttrIdx >= 0 && bro.talents[self.mWXWashState.targetAttrIdx] === 0 && starredCount >= 3);
						if (curNeedRep && _stars > 0) {
							self.mWXWashState.replaceAttrIdx = _attrIdx;
							renderAttrRows();
							self.wxQueryWashPreview(box);
							return;
						}
						if (_stars >= 3) return;
						self.mWXWashState.targetAttrIdx = _attrIdx;
						self.mWXWashState.replaceAttrIdx = -1;
						renderAttrRows();
						self.wxQueryWashPreview(box);
					});
				})(i, t);

				rowsHost.append(row);
			}
			rowsHost.append('<div class="wx-clear"></div>');
		}

		renderAttrRows();

		box.find('[data-wx="use-protect"]').on('click', function () {
			if (protectPills <= 0) return;
			self.mWXWashState.useProtectPill = !self.mWXWashState.useProtectPill;
			$(this).toggleClass('is-on', self.mWXWashState.useProtectPill);
			self.wxQueryWashPreview(box);
		});

		box.find('[data-wx="wash-exec"]').on('click', function () {
			if ($(this).hasClass('is-dis')) return;
			self.mDataSource.notifyBackendWXExecuteWash(
				self.mWXCurrentEntityId,
				self.mWXWashState.targetAttrIdx,
				self.mWXWashState.replaceAttrIdx,
				self.mWXWashState.useProtectPill,
				self.mWXWashState.usePendingChance,
				function (_res) {
					self.wxCloseModal();
					if (_res && _res.ok) {
						self.mDataSource.wxApplyVanillaSync(_res);
						self.mWXState = _res;
						self.wxRenderAll();
						if (_res.wxShowcase && window.WX_Showcase) {
							window.WX_Showcase.play(_res.wxShowcase, { sqHandle: self.mDataSource.mSQHandle });
						} else {
							var okRoll = _res.washResult && _res.washResult.Succeeded;
							self.wxShowToast(_res.actionMessage, !okRoll);
						}
					} else {
						self.wxShowToast((_res && _res.reason) ? _res.reason : '洗经伐髓未能执行。', true);
					}
				}
			);
		});

		this.wxOpenModal(box);
	};

	CharacterScreenPerksModule.prototype.wxQueryWashPreview = function (_box) {
		var st = this.mWXWashState;
		var previewEl = _box.find('[data-wx="wash-preview"]');
		var execBtn = _box.find('[data-wx="wash-exec"]');
		var bro = this.mWXState.brother;
		var hasCost = ((this.mWXState.washPillCount || 0) > 0 || (bro.pendingWashChances || 0) > 0);

		if (st.targetAttrIdx < 0) {
			execBtn.addClass('is-dis');
			return;
		}

		this.mDataSource.notifyBackendWXGetWashPreview(
			this.mWXCurrentEntityId,
			st.targetAttrIdx,
			st.replaceAttrIdx,
			st.useProtectPill,
			function (_pv) {
				if (!_pv || !_pv.Ok) {
					previewEl.html('<span class="wx-c-desc">' + wxEscapeHtml((_pv && _pv.Reason) ? _pv.Reason : '暂不可洗髓。') + '</span>');
					execBtn.addClass('is-dis');
					return;
				}
				var modeText = _pv.IsReplaceMode
					? ('易筋换星：洗去「' + wxEscapeHtml(_pv.ReplaceAttrName) + '」→「' + wxEscapeHtml(_pv.TargetAttrName) + '」1★')
					: ('冲星：「' + wxEscapeHtml(_pv.TargetAttrName) + '」' + _pv.CurrentStar + '★ → ' + _pv.NextStar + '★');
				var riskText = _pv.PermInjuryRisk > 0
					? ('失败：经脉震荡，且 ' + _pv.PermInjuryRisk + '% 留下永久暗疾')
					: '失败：经脉震荡（无永久暗疾风险）';

				previewEl.html(
					'<span class="wx-c-label">' + modeText + '</span>　' +
					'<span class="wx-t-title" style="font-size:2.1rem;">' + _pv.FinalChance + '%</span>　' +
					'<span class="wx-c-desc">基础 ' + _pv.BaseChance + '% + 筹备 ' + _pv.PrepBonus + '%</span><br/>' +
					'<span class="wx-c-neg">' + riskText + (hasCost ? '' : '（当前缺少洗髓丹）') + '</span>'
				);
				execBtn.toggleClass('is-dis', !hasCost);
			}
		);
	};

	CharacterScreenPerksModule.prototype.wxOpenPresetsModal = function () {
		if (!this.mWXState || !this.mWXState.brother) return;
		var self = this;
		var bro = this.mWXState.brother;
		var presets = bro.loadoutPresets || [];
		var cnIdx = ['壹', '贰', '叁'];
		var hasGrace = !!bro.hasWangchenGrace;

		var rowsHtml = '';
		for (var i = 0; i < 3; i++) {
			var p = presets[i] || { index: i, label: '方案' + cnIdx[i], saved: false, count: 0, manualNames: [] };
			var summary = p.saved && p.manualNames && p.manualNames.length > 0
				? ('已存 ' + p.count + ' 门：《' + wxEscapeHtml(p.manualNames.join('》《')) + '》')
				: '尚未存入配槽记录（点击右侧「存入当前」即可记录 7 穴功法）';
			rowsHtml +=
				'<div class="wx-pick" style="height:auto;min-height:6.4rem;padding:0.85rem 16.2rem 0.85rem 1.4rem;cursor:default;">' +
					'<div style="color:#dda21f;font-size:1.55rem;">【方案' + cnIdx[i] + ' · ' + wxEscapeHtml(p.label) + '】</div>' +
					'<div style="color:#bd9d71;font-size:1.26rem;line-height:1.75rem;margin-top:0.2rem;">' + summary + '</div>' +
					'<div style="position:absolute;right:1.0rem;top:1.25rem;white-space:nowrap;">' +
						'<span class="wx-vb wx-vb2" data-preset-save="' + i + '" style="width:6.8rem;margin-right:0.3rem;">存入当前</span>' +
						'<span class="wx-vb wx-vb1' + (p.saved ? '' : ' is-dis') + '" data-preset-apply="' + i + '" style="width:6.8rem;">一键换装</span>' +
					'</div>' +
				'</div>';
		}

		var graceNote = hasGrace
			? '<div style="color:#66d6cc;font-size:1.28rem;margin-bottom:0.65rem;">✦ 当前身怀【归元护脉】药力，本次切换整套配槽可免除散功调息期！</div>'
			: '<div style="color:#a08860;font-size:1.25rem;margin-bottom:0.65rem;">提示：切换方案仅从角色「已习武学」库中调配，所有卸下功法的重数与火候 100% 保留；提前服食《忘尘归元散》可零虚弱换装。</div>';

		var box = $(
			'<div class="wx-popup" style="width:58.0rem;margin-top:13.5rem;">' +
				'<div class="wx-ph">武学配槽方案 · ' + wxEscapeHtml(bro.name) + '</div>' +
				'<div class="wx-pb">' + graceNote + rowsHtml + '<div data-wx="preset-confirm" style="margin-top:0.6rem;"></div></div>' +
				'<div class="wx-pf"><span class="wx-vb wx-vb2" data-wx-close="1" style="width:10.0rem;">关闭</span></div>' +
			'</div>'
		);

		box.find('[data-preset-save]').on('click', function () {
			var idx = parseInt($(this).attr('data-preset-save'), 10);
			self.mDataSource.notifyBackendWXSavePreset(self.mWXCurrentEntityId, idx, '', function (_res) {
				self.wxCloseModal();
				self.wxApplyBackendState(_res);
			});
		});

		box.find('[data-preset-apply]').on('click', function () {
			if ($(this).hasClass('is-dis')) return;
			var idx = parseInt($(this).attr('data-preset-apply'), 10);
			self.mDataSource.notifyBackendWXApplyPreset(self.mWXCurrentEntityId, idx, false, function (_res) {
				if (_res && _res.needsConfirm) {
					var cf = box.find('[data-wx="preset-confirm"]');
					cf.html(
						'<div style="padding:0.75rem 1.0rem;background:rgba(120,32,20,0.45);border:0.1rem solid #c9583b;">' +
							'切换至【' + wxEscapeHtml(_res.presetLabel) + '】将调整 ' + _res.changedCount + ' 处穴位，原功法重数完整保留，但角色将进入 <b style="color:#ffd08a;">' + _res.penaltyDays + ' 天</b>散功调息。是否确认？' +
							'<span class="wx-vb wx-vb1" data-preset-confirm-yes="' + idx + '" style="width:7.6rem;margin-left:0.8rem;">确认换装</span>' +
						'</div>'
					);
					cf.find('[data-preset-confirm-yes]').on('click', function () {
						self.mDataSource.notifyBackendWXApplyPreset(self.mWXCurrentEntityId, idx, true, function (_res2) {
							self.wxCloseModal();
							self.wxApplyBackendState(_res2);
						});
					});
					return;
				}
				self.wxCloseModal();
				self.wxApplyBackendState(_res);
			});
		});

		this.wxOpenModal(box);
	};
})();
