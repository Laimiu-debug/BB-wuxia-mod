/* ============================================================================
 * BB Wuxia Mod - Deepened Alchemy Cauldron & Zero-Slot Herb Cabinet UI (ES3)
 * - Dual-Mode Full-Screen Modal: [八卦丹炉 · 君臣配伍] & [百草药柜 · 零占格收纳]
 * - Accessible from World Topbar, Character Screen (武学修为) & Town 百工丹坊
 * - Enhances 洗经伐髓 Modal with 太乙紫金洗髓丹 & 易筋锻骨丸 pill selector
 * Strictly ES3-compliant: zero let / const / arrow / template-literals / class.
 * ============================================================================ */

(function () {
	'use strict';

	var wxWorldTopbarModRef = null;

	function wxEsc(_s) {
		if (_s === null || typeof _s === 'undefined') return '';
		return String(_s)
			.split('&').join('&amp;')
			.split('<').join('&lt;')
			.split('>').join('&gt;')
			.split('"').join('&quot;');
	}

	var wxAlcState = {
		sqHandle: null,
		hostDS: null,
		perksMod: null,
		entityId: null,
		data: null,
		mode: 'cauldron',       // 'cauldron' | 'reforge' | 'cabinet'
		formulaFilter: 'all',   // 'all' | 'ready' | 'heal' | 'prep' | 'cultivate'
		selectedFormulaId: null,
		slotKeys: ['', '', ''], // [junKey, aux1Key, aux2Key]
		activeSlotIdx: 0,       // 0 = Jun, 1 = Aux1, 2 = Aux2
		reforgeFilter: 'all',   // 'all' | 'equipped' | 'stash' | 'upgradeable'
		selectedReforgeUid: null,
		confirmMasterworkUid: null,
		cabKindFilter: 'all',   // 'all' | 'herb' | 'core' | 'trophy'
		cabNatureFilter: 'all',
		cabSearch: '',
		bannerTimer: null
	};

	function wxGetIngMap() {
		var map = {};
		var list = (wxAlcState.data && wxAlcState.data.ingredients) ? wxAlcState.data.ingredients : [];
		for (var i = 0; i < list.length; i++) {
			map[list[i].key] = list[i];
		}
		return map;
	}

	function wxFindFormulaObj(_id) {
		var list = (wxAlcState.data && wxAlcState.data.formulas) ? wxAlcState.data.formulas : [];
		for (var i = 0; i < list.length; i++) {
			if (list[i].id === _id) return list[i];
		}
		return list.length > 0 ? list[0] : null;
	}

	function wxShowAlcBanner(_msg, _isErr) {
		var el = $('.wx-alc-backdrop .wx-alc-banner');
		if (!el.length || !_msg) return;
		if (wxAlcState.bannerTimer !== null) {
			clearTimeout(wxAlcState.bannerTimer);
			wxAlcState.bannerTimer = null;
		}
		el.removeClass('is-err');
		if (_isErr) el.addClass('is-err');
		el.text(_msg).show();
		wxAlcState.bannerTimer = setTimeout(function () {
			el.fadeOut(220);
			wxAlcState.bannerTimer = null;
		}, 4200);
	}

	function wxSyncHostFromAlchemyResponse(_res) {
		if (!_res || typeof _res !== 'object') return;
		if (wxAlcState.hostDS && typeof wxAlcState.hostDS.wxApplyVanillaSync === 'function') {
			wxAlcState.hostDS.wxApplyVanillaSync(_res);
		}
		if (wxAlcState.perksMod && _res.wxCharState && _res.wxCharState.ok) {
			wxAlcState.perksMod.mWXState = _res.wxCharState;
			if (wxAlcState.perksMod.isVisible && wxAlcState.perksMod.isVisible()) {
				wxAlcState.perksMod.wxRenderAll();
			}
		}
	}

	function wxCloseAlchemyModal() {
		var existing = $('.wx-alc-backdrop');
		if (existing.length) {
			existing.remove();
			$(document).off('keydown.wxAlcModal');
			if (wxAlcState.hostDS && wxAlcState.hostDS.notifyBackendPopupDialogIsVisible) {
				wxAlcState.hostDS.notifyBackendPopupDialogIsVisible(false);
			}
		}
	}

	function wxSelectFormulaAndAutoFill(_formulaObj) {
		if (!_formulaObj) return;
		wxAlcState.selectedFormulaId = _formulaObj.id;
		var ap = _formulaObj.autoPick || ['', '', ''];
		wxAlcState.slotKeys = [ap[0] || '', ap[1] || '', ap[2] || ''];
		if (!wxAlcState.slotKeys[0]) wxAlcState.activeSlotIdx = 0;
		else if (!wxAlcState.slotKeys[1]) wxAlcState.activeSlotIdx = 1;
		else wxAlcState.activeSlotIdx = 0;
	}

	function wxClientDoesJunMatch(_ing, _f) {
		if (!_ing || !_f) return false;
		if (_ing.potency < _f.minJunPotency) return false;
		if (_f.requireRareJun && !_ing.isRare) return false;
		var jn = _f.junNatures || [];
		for (var i = 0; i < jn.length; i++) {
			if (jn[i] === _ing.nature) return true;
		}
		return false;
	}

	function wxComputeClientPreview(_f) {
		var ingMap = wxGetIngMap();
		var sk = wxAlcState.slotKeys;
		if (!_f) return { ok: false, reason: '未选择丹方。', curPot: 0, reqPot: 1, doubleChance: 0 };
		if (!sk[0] || !(sk[0] in ingMap)) {
			return {
				ok: false,
				reason: '请先在左侧【君药主引】鼎位放入符合药性的奇草/内丹/药材（或点击「智能抓药」）。',
				curPot: 0,
				reqPot: _f.targetPotency,
				doubleChance: 0
			};
		}
		var jun = ingMap[sk[0]];
		if (!wxClientDoesJunMatch(jun, _f)) {
			return {
				ok: false,
				reason: '「' + jun.name + '」不符合本方君药要求（需 ' + _f.junNatureText + ' 药性且药力≥' + _f.minJunPotency + (_f.requireRareJun ? '，限奇草/内丹/神木灵心' : '') + '）。',
				curPot: jun.potency,
				reqPot: _f.targetPotency,
				doubleChance: 0
			};
		}

		var used = {};
		used[sk[0]] = 1;
		var auxCnt = 0;
		var totalPot = jun.potency;
		var harmony = 0;
		var bestAuxNat = '';
		var bestAuxPot = -1;
		for (var s = 1; s <= 2; s++) {
			var k = sk[s];
			if (!k) continue;
			if (!(k in ingMap)) {
				return { ok: false, reason: '所选辅药存量不足。', curPot: totalPot, reqPot: _f.targetPotency, doubleChance: 0 };
			}
			used[k] = (used[k] || 0) + 1;
			if (used[k] > ingMap[k].totalCount) {
				return { ok: false, reason: '「' + ingMap[k].name + '」持有数量不足以同炉重复置入。', curPot: totalPot, reqPot: _f.targetPotency, doubleChance: 0 };
			}
			var ax = ingMap[k];
			auxCnt++;
			totalPot += ax.potency;
			if (ax.potency > bestAuxPot) {
				bestAuxPot = ax.potency;
				bestAuxNat = ax.nature || '';
			}
			var jnList = _f.junNatures || [];
			for (var j = 0; j < jnList.length; j++) {
				if (jnList[j] === ax.nature) { harmony += 8; break; }
			}
			if (ax.kind === 'herb') harmony += 6;
			else if (ax.kind === 'core') harmony += 10;
		}

		if (auxCnt < _f.minAuxCount) {
			return {
				ok: false,
				reason: '至少需放入 ' + _f.minAuxCount + ' 味【臣佐辅药】调和鼎火（当前已放 ' + auxCnt + ' 味）。',
				curPot: totalPot,
				reqPot: _f.targetPotency,
				doubleChance: 0
			};
		}
		if (totalPot < _f.targetPotency) {
			return {
				ok: false,
				reason: '鼎内总药力不足（当前 ' + totalPot + ' / 需达 ' + _f.targetPotency + '），请补入第 2 味佐药或换更高阶奇草/内丹。',
				curPot: totalPot,
				reqPot: _f.targetPotency,
				doubleChance: 0
			};
		}
		var mstBonus = (wxAlcState.data && wxAlcState.data.mastery) ? (wxAlcState.data.mastery.bonusDoublePct || 0) : 0;
		var sur = totalPot > _f.targetPotency ? (totalPot - _f.targetPotency) : 0;
		var dbl = 12 + sur * 10 + harmony + mstBonus;
		if (dbl > 85) dbl = 85;

		var g3 = 8 + sur * 4 + Math.floor((harmony + mstBonus) * 0.40);
		if (g3 > 42) g3 = 42;
		var g2 = 30 + sur * 5 + Math.floor((harmony + mstBonus) * 0.35);
		if (g2 > 48) g2 = 48;
		if (g2 + g3 > 90) g2 = 90 - g3;
		var g1 = 100 - g2 - g3;
		if (g1 < 10) g1 = 10;

		var auxTitle = '';
		var auxColor = '#bd9d71';
		var auxDesc = '';
		var auxMap = (wxAlcState.data && wxAlcState.data.auxInfusions) ? wxAlcState.data.auxInfusions : null;
		if (bestAuxNat && auxMap && (bestAuxNat in auxMap)) {
			var aSpec = auxMap[bestAuxNat];
			auxTitle = aSpec.title || '';
			auxColor = aSpec.color || '#dda21f';
			var pk = _f.pillKind || '';
			if (pk === 'infuse_exp') {
				auxDesc = aSpec.infuseDesc || '';
			} else if (pk.indexOf('heal_') === 0 && pk !== 'heal_internal_plus') {
				auxDesc = aSpec.healDesc || '';
			} else if (pk.indexOf('buff_') === 0 || pk === 'heal_internal_plus') {
				auxDesc = aSpec.prepDesc || '';
			} else if (pk.indexOf('marrow_wash') === 0) {
				auxDesc = '成丹品阶加成：灵纹洗髓成功率 +4% / 丹霞极品洗髓成功率 +8%！';
			} else if (pk === 'wash_protect') {
				auxDesc = '成丹品阶加成：灵纹护脉额外 +2% / 丹霞极品护脉额外 +5%！';
			} else if (pk === 'wangchen_grace') {
				auxDesc = '丹霞极品奇效：服下额外荡平身上 1 处轻度走火入魔内伤！';
			} else {
				auxDesc = '丹霞极品奇效：拔除沉疴暗疾之余额外大补气血与战意！';
			}
		}

		var money = (wxAlcState.data && typeof wxAlcState.data.money === 'number') ? wxAlcState.data.money : 0;
		if (money < _f.silverCost) {
			return {
				ok: false,
				reason: '炉火纹银不足（需 ' + _f.silverCost + ' 两，现存 ' + money + ' 两）。',
				curPot: totalPot,
				reqPot: _f.targetPotency,
				doubleChance: dbl,
				gradeChances: [g1, g2, g3],
				auxTitle: auxTitle,
				auxColor: auxColor,
				auxDesc: auxDesc
			};
		}
		return {
			ok: true,
			reason: '',
			curPot: totalPot,
			reqPot: _f.targetPotency,
			doubleChance: dbl,
			gradeChances: [g1, g2, g3],
			auxTitle: auxTitle,
			auxColor: auxColor,
			auxDesc: auxDesc
		};
	}

	function wxRenderMetaAndTabs(_dlg) {
		var d = wxAlcState.data;
		if (!d) return;
		var sum = d.summary || { cabinetHerbs: 0, cabinetCores: 0, cabinetTrophies: 0, cabinetTotal: 0, stashMovable: 0 };
		var mst = d.mastery || { masterLabel: '随军自炼', bonusDoublePct: 0, hasDiscount: false };
		var fg  = d.forge || { smithLabel: '随军炉火', bonusHighPct: 0, hasDiscount: false, items: [], catalystTotal: 0, pity: 0 };
		var rfgItems = fg.items || [];

		var metaHtml =
			'纹银：<strong>' + d.money + ' 两</strong>　│　' +
			'掌炉：<strong>' + wxEsc(mst.masterLabel) + '</strong> · 掌锤：<strong>' + wxEsc(fg.smithLabel) + '</strong>　│　' +
			'百草药柜（零占格）：奇草 <strong>' + sum.cabinetHerbs + '</strong> · 内丹 <strong>' + sum.cabinetCores + '</strong> · 奇材 <strong>' + sum.cabinetTrophies + '</strong>' +
			(sum.stashMovable > 0 ? ('（行囊可入柜 ' + sum.stashMovable + '）') : '') + '　│　' +
			'行囊：<strong>' + d.stashSpaceUsed + '/' + d.stashSpaceMax + '</strong>';
		_dlg.find('[data-alc="meta"]').html(metaHtml);

		var readyCnt = 0;
		var flist = d.formulas || [];
		for (var i = 0; i < flist.length; i++) {
			if (flist[i].canAutoBrew) readyCnt++;
		}

		var topHtml =
			'<span class="wx-alc-mode-btn' + (wxAlcState.mode === 'cauldron' ? ' is-active' : '') + '" data-amode="cauldron">' +
				'<img src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" alt=""/>八卦丹炉（可炼 ' + readyCnt + '）' +
			'</span>' +
			'<span class="wx-alc-mode-btn' + (wxAlcState.mode === 'reforge' ? ' is-active' : '') + '" data-amode="reforge">' +
				'<img src="coui://gfx/ui/icons/asset_supplies.png" alt=""/>神兵重锻（兵甲 ' + rfgItems.length + '）' +
			'</span>' +
			'<span class="wx-alc-mode-btn' + (wxAlcState.mode === 'cabinet' ? ' is-active' : '') + '" data-amode="cabinet">' +
				'<img src="coui://gfx/ui/wx_icons/wx_glyph_herb_cabinet.png" alt=""/>百草药柜（柜藏 ' + sum.cabinetTotal + '）' +
			'</span>';

		if (wxAlcState.mode === 'cauldron') {
			var cflts = [
				['all', '全部丹方'],
				['ready', '可开炉 (' + readyCnt + ')'],
				['heal', '疗伤续脉'],
				['prep', '备战对策'],
				['cultivate', '修为洗髓']
			];
			for (var c = 0; c < cflts.length; c++) {
				var cf = cflts[c];
				topHtml += '<span class="wx-alc-subflt' + (wxAlcState.formulaFilter === cf[0] ? ' is-active' : '') + '" data-fflt="' + cf[0] + '">' + cf[1] + '</span>';
			}
		} else if (wxAlcState.mode === 'reforge') {
			var eqCnt = 0;
			var stCnt = 0;
			var upgCnt = 0;
			for (var ri = 0; ri < rfgItems.length; ri++) {
				if (rfgItems[ri].isEquipped) eqCnt++;
				else stCnt++;
				if (rfgItems[ri].grade < 3) upgCnt++;
			}
			var rflts = [
				['all', '全部神兵 (' + rfgItems.length + ')'],
				['equipped', '身披在阵 (' + eqCnt + ')'],
				['stash', '行囊待淬 (' + stCnt + ')'],
				['upgradeable', '未臻神工 (' + upgCnt + ')']
			];
			for (var rf = 0; rf < rflts.length; rf++) {
				var ritem = rflts[rf];
				topHtml += '<span class="wx-alc-subflt' + (wxAlcState.reforgeFilter === ritem[0] ? ' is-active' : '') + '" data-rflt="' + ritem[0] + '">' + ritem[1] + '</span>';
			}
		} else {
			var kflts = [
				['all', '全部药材'],
				['herb', '天下奇草'],
				['core', '山海内丹'],
				['trophy', '异兽奇材']
			];
			for (var k = 0; k < kflts.length; k++) {
				var kf = kflts[k];
				topHtml += '<span class="wx-alc-subflt' + (wxAlcState.cabKindFilter === kf[0] ? ' is-active' : '') + '" data-kflt="' + kf[0] + '">' + kf[1] + '</span>';
			}
			var nats = d.natures || [];
			for (var n = 0; n < nats.length; n++) {
				var nd = nats[n];
				topHtml += '<span class="wx-alc-subflt' + (wxAlcState.cabNatureFilter === nd.id ? ' is-active' : '') + '" data-nflt="' + nd.id + '">' + wxEsc(nd.short) + '</span>';
			}
		}

		var topBar = _dlg.find('[data-alc="top-tabs"]');
		topBar.html(topHtml);

		topBar.find('[data-amode]').on('click', function () {
			wxAlcState.mode = $(this).attr('data-amode');
			wxAlcState.confirmMasterworkUid = null;
			wxRenderAll(_dlg);
		});
		topBar.find('[data-fflt]').on('click', function () {
			wxAlcState.formulaFilter = $(this).attr('data-fflt');
			wxRenderAll(_dlg);
		});
		topBar.find('[data-rflt]').on('click', function () {
			wxAlcState.reforgeFilter = $(this).attr('data-rflt');
			wxAlcState.confirmMasterworkUid = null;
			wxRenderAll(_dlg);
		});
		topBar.find('[data-kflt]').on('click', function () {
			wxAlcState.cabKindFilter = $(this).attr('data-kflt');
			wxRenderAll(_dlg);
		});
		topBar.find('[data-nflt]').on('click', function () {
			var clicked = $(this).attr('data-nflt');
			wxAlcState.cabNatureFilter = (wxAlcState.cabNatureFilter === clicked) ? 'all' : clicked;
			wxRenderAll(_dlg);
		});
	}

	function wxRenderCauldronView(_body, _dlg) {
		var d = wxAlcState.data;
		var formulas = d.formulas || [];
		var filtered = [];
		var selObj = null;

		for (var i = 0; i < formulas.length; i++) {
			var f = formulas[i];
			if (wxAlcState.formulaFilter === 'ready' && !f.canAutoBrew) continue;
			if (wxAlcState.formulaFilter !== 'all' && wxAlcState.formulaFilter !== 'ready' && f.category !== wxAlcState.formulaFilter) continue;
			filtered.push(f);
			if (f.id === wxAlcState.selectedFormulaId) selObj = f;
		}
		if (!selObj && filtered.length > 0) {
			selObj = filtered[0];
			wxSelectFormulaAndAutoFill(selObj);
		} else if (!selObj && formulas.length > 0) {
			selObj = wxFindFormulaObj(wxAlcState.selectedFormulaId);
		}

		var leftHtml = '';
		if (filtered.length === 0) {
			leftHtml = '<div style="padding:3rem 1rem;color:#bd9d71;text-align:center;font-style:italic;">当前筛选下暂无符合条件的丹方（可切至「全部丹方」查阅所需药性）。</div>';
		} else {
			for (var j = 0; j < filtered.length; j++) {
				var fj = filtered[j];
				var isSel = (selObj && fj.id === selObj.id);
				var badge = fj.canAutoBrew
					? '<span class="wx-alc-frow-badge is-ready">可开炉</span>'
					: '<span class="wx-alc-frow-badge is-short">缺药引</span>';
				var yieldTxt = fj.baseYield > 1 ? (' ×' + fj.baseYield) : '';
				var ownTxt = fj.ownedCount > 0 ? (' · 现存×' + fj.ownedCount) : '';

				leftHtml +=
					'<div class="wx-alc-frow' + (isSel ? ' is-selected' : '') + '" data-fid="' + fj.id + '">' +
						'<img class="wx-alc-frow-icon" src="coui://gfx/' + fj.icon + '" alt=""/>' +
						'<div class="wx-alc-frow-top">' +
							'<span class="wx-alc-frow-name">' + wxEsc(fj.name) + yieldTxt + '</span>' +
							badge +
							'<div class="clear-both"></div>' +
						'</div>' +
						'<div class="wx-alc-frow-sub">[' + wxEsc(fj.qualityLabel) + '·' + wxEsc(fj.subLabel) + '] 君药:' + wxEsc(fj.junNatureText) + '(≥' + fj.minJunPotency + ') · 需药力' + fj.targetPotency + ' · ' + fj.silverCost + '两' + ownTxt + '</div>' +
					'</div>';
			}
		}

		_body.html(
			'<div class="wx-alc-left-col" data-alc="f-list">' + leftHtml + '</div>' +
			'<div class="wx-alc-right-col" data-alc="wb"></div>'
		);

		_body.find('[data-fid]').on('click', function () {
			var fid = $(this).attr('data-fid');
			var found = wxFindFormulaObj(fid);
			if (found) {
				wxSelectFormulaAndAutoFill(found);
				wxRenderCauldronView(_body, _dlg);
			}
		});

		wxRenderWorkbench(_body.find('[data-alc="wb"]'), selObj, _dlg);
	}

	function wxBuildSlotCardHtml(_slotIdx, _posCls, _roleTitle, _ingMap, _f) {
		var key = wxAlcState.slotKeys[_slotIdx] || '';
		var ing = key ? _ingMap[key] : null;
		var isAct = (wxAlcState.activeSlotIdx === _slotIdx);
		var isJun = (_slotIdx === 0);

		if (!ing) {
			var hint = isJun
				? ('点击择入君药<br/>（' + wxEsc(_f.junNatureText) + ' · 药力≥' + _f.minJunPotency + '）')
				: (_slotIdx === 1 ? '点击择入臣药辅火' : (_f.minAuxCount >= 2 ? '点击择入第2味佐药（必配）' : '可选佐使（冲高双丹率）'));
			return (
				'<div class="wx-alc-slot-card ' + _posCls + (isAct ? ' is-active' : '') + '" data-tslot="' + _slotIdx + '">' +
					'<div class="wx-alc-slot-role">' + _roleTitle + '</div>' +
					'<div class="wx-alc-slot-ing-meta" style="margin-top:0.5rem;">' + hint + '</div>' +
				'</div>'
			);
		}

		if (isJun) {
			return (
				'<div class="wx-alc-slot-card ' + _posCls + (isAct ? ' is-active' : '') + '" data-tslot="0">' +
					'<span class="wx-alc-slot-clear" data-clear-slot="0" title="撤下此味药材">×</span>' +
					'<div class="wx-alc-slot-role">' + _roleTitle + '</div>' +
					'<img class="wx-alc-slot-jun-icon" src="coui://gfx/' + ing.icon + '" alt=""/>' +
					'<div class="wx-alc-slot-ing-name">' + wxEsc(ing.name) + '</div>' +
					'<div class="wx-alc-slot-ing-meta"><span style="color:' + ing.natureColor + ';">[' + wxEsc(ing.natureShort) + ']</span> 药力 ' + ing.potency + ' · 存 ' + ing.totalCount + '</div>' +
				'</div>'
			);
		}

		return (
			'<div class="wx-alc-slot-card ' + _posCls + (isAct ? ' is-active' : '') + '" data-tslot="' + _slotIdx + '">' +
				'<span class="wx-alc-slot-clear" data-clear-slot="' + _slotIdx + '" title="撤下此味药材">×</span>' +
				'<img class="wx-alc-slot-aux-icon" src="coui://gfx/' + ing.icon + '" alt=""/>' +
				'<div class="wx-alc-slot-role">' + _roleTitle + '</div>' +
				'<div class="wx-alc-slot-ing-name">' + wxEsc(ing.name) + '</div>' +
				'<div class="wx-alc-slot-ing-meta"><span style="color:' + ing.natureColor + ';">[' + wxEsc(ing.natureShort) + ']</span> 药力 ' + ing.potency + ' · 存 ' + ing.totalCount + '</div>' +
			'</div>'
		);
	}

	function wxRenderWorkbench(_wb, _f, _dlg) {
		if (!_f) {
			_wb.html('<div style="padding:3rem 1rem;color:#bd9d71;text-align:center;">请先在左侧选择一道丹方</div>');
			return;
		}
		var ingMap = wxGetIngMap();
		var pv = wxComputeClientPreview(_f);
		var yieldStr = _f.baseYield > 1 ? ('（每炉成丹 ' + _f.baseYield + ' 枚）') : '';
		var rareReqStr = _f.requireRareJun ? '奇草 / 大妖内丹 / 万年灵心' : '任意匹配奇草 / 内丹 / 异兽材';

		var usedCounts = {};
		for (var u = 0; u < 3; u++) {
			var uk = wxAlcState.slotKeys[u];
			if (uk) usedCounts[uk] = (usedCounts[uk] || 0) + 1;
		}

		// Build candidate chips for the currently active Tripod Slot (`activeSlotIdx`)
		var allIngs = (wxAlcState.data && wxAlcState.data.ingredients) ? wxAlcState.data.ingredients : [];
		var chipsHtml = '';
		var chipCnt = 0;
		var actIdx = wxAlcState.activeSlotIdx;

		for (var i = 0; i < allIngs.length; i++) {
			var ing = allIngs[i];
			var curSlotKey = wxAlcState.slotKeys[actIdx] || '';
			var usedByOthers = (usedCounts[ing.key] || 0) - (curSlotKey === ing.key ? 1 : 0);
			var availForSlot = ing.totalCount - usedByOthers;
			if (availForSlot <= 0) continue;
			if (actIdx === 0 && !wxClientDoesJunMatch(ing, _f)) continue;

			chipCnt++;
			var srcNote = ing.cabinetCount > 0 ? ('柜' + ing.cabinetCount + (ing.stashCount > 0 ? '+包' + ing.stashCount : '')) : ('包' + ing.stashCount);
			chipsHtml +=
				'<div class="wx-alc-pick-chip" data-pick-key="' + wxEsc(ing.key) + '" title="' + wxEsc(ing.description) + '">' +
					'<img src="coui://gfx/' + ing.icon + '" alt=""/>' +
					'<div class="wx-alc-pick-name">' + wxEsc(ing.name) + '</div>' +
					'<div class="wx-alc-pick-sub"><span style="color:' + ing.natureColor + ';">[' + wxEsc(ing.natureShort) + '·力' + ing.potency + ']</span> 余' + availForSlot + ' (' + srcNote + ')</div>' +
				'</div>';
		}
		if (chipCnt === 0) {
			chipsHtml = '<div style="padding:1.2rem;color:#bd9d71;font-style:italic;text-align:center;">' +
				(actIdx === 0
					? ('当前药柜与行囊中暂无符合本方君药要求（' + wxEsc(_f.junNatureText) + ' · 药力≥' + _f.minJunPotency + '）的药材。')
					: '当前药柜与行囊中暂无空闲辅材可添入此鼎位。') +
				'</div>';
		} else {
			chipsHtml += '<div class="clear-both"></div>';
		}

		var pvHtml = '';
		if (pv.ok) {
			var gc = pv.gradeChances || [60, 30, 10];
			pvHtml =
				'<div class="wx-alc-pv-line" style="color:#7ee29a;">鼎火纯青：总药力 <strong>' + pv.curPot + ' / ' + pv.reqPot + '</strong>　│　炉资：<strong>' + _f.silverCost + ' 两</strong>　│　紫气双丹率：<strong style="color:#f0bc42;">' + pv.doubleChance + '%</strong></div>' +
				'<div class="wx-alc-pv-line">成丹品阶：成丹 <strong>' + gc[0] + '%</strong> · <span style="color:#5ec47a;">灵纹 <strong>' + gc[1] + '%</strong> (药效112%~128%)</span> · <span style="color:#f0bc42;">丹霞极品 <strong>' + gc[2] + '%</strong> (132%~155% · 免第3丹丹毒/疯魔反噬)</span></div>';
			if (pv.auxTitle && pv.auxDesc) {
				pvHtml +=
					'<div class="wx-alc-pv-aux"><span style="color:' + pv.auxColor + ';">【' + wxEsc(pv.auxTitle) + '】</span>' + wxEsc(pv.auxDesc) + ' <span style="color:#a98e67;">（更换右上/右下臣佐辅药药性即可定制成丹附带奇效！）</span></div>';
			}
		} else {
			pvHtml = '<div style="color:#ff9482;">鼎内状态：总药力 ' + pv.curPot + ' / ' + pv.reqPot + ' —— ' + wxEsc(pv.reason) + '</div>';
		}

		var slotLabelNames = ['【君药主引】', '【臣药辅火】', '【佐使调和】'];

		var html =
			'<div class="wx-alc-wb-hdr">' +
				'<img class="wx-alc-wb-hdr-icon" src="coui://gfx/' + _f.icon + '" alt=""/>' +
				'<div class="wx-alc-wb-title">' + wxEsc(_f.name) + ' <span style="font-size:1.3rem;color:#bd9d71;">[' + wxEsc(_f.qualityLabel) + ' · ' + wxEsc(_f.subLabel) + ']' + yieldStr + '</span></div>' +
				'<div class="wx-alc-wb-desc">' + wxEsc(_f.description) + '</div>' +
			'</div>' +
			'<div class="wx-alc-wb-req">' +
				'<div><strong>丹诀要旨：</strong>' + wxEsc(_f.formulaNote) + '</div>' +
				'<div><strong>配伍法度：</strong>君药须属【' + wxEsc(_f.junNatureText) + '】（药力≥' + _f.minJunPotency + '，' + rareReqStr + '）+ 至少 ' + _f.minAuxCount + ' 味辅药，总药力 ≥ ' + _f.targetPotency + '。</div>' +
			'</div>' +
			'<div class="wx-alc-tripod-stage">' +
				wxBuildSlotCardHtml(0, 'pos-jun', '【君药主引】', ingMap, _f) +
				'<img class="wx-alc-furnace-art" src="coui://gfx/ui/wx_icons/wx_cauldron_furnace.png" alt=""/>' +
				wxBuildSlotCardHtml(1, 'pos-aux1', '【臣药辅火】', ingMap, _f) +
				wxBuildSlotCardHtml(2, 'pos-aux2', '【佐使调和】', ingMap, _f) +
			'</div>' +
			'<div class="wx-alc-preview-bar">' + pvHtml + '</div>' +
			'<div class="wx-alc-act-row">' +
				'<span class="wx-alc-act-btn" data-wbact="autofill"><img src="coui://gfx/ui/wx_icons/wx_glyph_scale_mortar.png" style="width:1.9rem;height:1.9rem;vertical-align:middle;margin:-0.25rem 0.3rem 0 0;" alt=""/>智能抓药</span>' +
				'<span class="wx-alc-act-btn' + (pv.ok ? '' : ' is-disabled') + '" data-wbact="brew"><img src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" style="width:1.9rem;height:1.9rem;vertical-align:middle;margin:-0.25rem 0.3rem 0 0;" alt=""/>起火开炉（' + _f.silverCost + '两）</span>' +
			'</div>' +
			'<div class="wx-alc-picker-title">正在为 ' + slotLabelNames[actIdx] + ' 拣选药材（点击下方药柜/行囊奇材即可置入鼎位）：</div>' +
			'<div class="wx-alc-picker-grid">' + chipsHtml + '</div>';

		_wb.html(html);

		_wb.find('[data-clear-slot]').on('click', function (_e) {
			_e.stopPropagation();
			var cIdx = parseInt($(this).attr('data-clear-slot'), 10);
			wxAlcState.slotKeys[cIdx] = '';
			wxAlcState.activeSlotIdx = cIdx;
			wxRenderWorkbench(_wb, _f, _dlg);
		});

		_wb.find('[data-tslot]').on('click', function () {
			wxAlcState.activeSlotIdx = parseInt($(this).attr('data-tslot'), 10);
			wxRenderWorkbench(_wb, _f, _dlg);
		});

		_wb.find('[data-pick-key]').on('click', function () {
			var k = $(this).attr('data-pick-key');
			wxAlcState.slotKeys[wxAlcState.activeSlotIdx] = k;
			// Advance active slot automatically to next empty slot for fast 1-2-3 clicking!
			if (wxAlcState.activeSlotIdx === 0 && !wxAlcState.slotKeys[1]) wxAlcState.activeSlotIdx = 1;
			else if (wxAlcState.activeSlotIdx === 1 && !wxAlcState.slotKeys[2] && _f.minAuxCount >= 2) wxAlcState.activeSlotIdx = 2;
			wxRenderWorkbench(_wb, _f, _dlg);
		});

		_wb.find('[data-wbact="autofill"]').on('click', function () {
			wxSelectFormulaAndAutoFill(_f);
			wxRenderWorkbench(_wb, _f, _dlg);
		});

		_wb.find('[data-wbact="brew"]').on('click', function () {
			if ($(this).hasClass('is-disabled') || !wxAlcState.sqHandle) return;
			SQ.call(
				wxAlcState.sqHandle,
				'onWXAlchemyBrew',
				[_f.id, wxAlcState.slotKeys[0], wxAlcState.slotKeys[1], wxAlcState.slotKeys[2], wxAlcState.entityId],
				function (_res) {
					if (_res && _res.ok) {
						wxSyncHostFromAlchemyResponse(_res);
						wxAlcState.data = _res;
						var updatedF = wxFindFormulaObj(_f.id);
						// Keep current slot selection if still stocked; otherwise smart-refill for consecutive brewing!
						var checkPv = wxComputeClientPreview(updatedF);
						if (!checkPv.ok && updatedF) {
							wxSelectFormulaAndAutoFill(updatedF);
						}
						wxRenderAll(_dlg);
						wxShowAlcBanner(_res.actionMessage || '开炉炼丹成功！', false);
					} else {
						wxShowAlcBanner((_res && _res.reason) ? _res.reason : '未能完成炼丹。', true);
					}
				}
			);
		});
	}

	function wxRenderCabinetView(_body, _dlg) {
		var d = wxAlcState.data;
		var allIngs = d.ingredients || [];
		var q = wxAlcState.cabSearch;

		var toolbarHtml =
			'<div class="wx-alc-cab-toolbar">' +
				'<span class="wx-alc-mini-btn" data-cabact="sweep-rare">奇草/内丹一键入柜</span>' +
				'<span class="wx-alc-mini-btn" data-cabact="sweep-all">连同异兽奇材全部入柜</span>' +
				'<label class="wx-alc-cab-check"><input type="checkbox" data-cabchk="autostore"' + (d.autoStore ? ' checked="checked"' : '') + '/> 自动入柜(奇草/内丹)</label>' +
				'<label class="wx-alc-cab-check"><input type="checkbox" data-cabchk="autotrophy"' + (d.autoTrophy ? ' checked="checked"' : '') + '/> 含异兽皮骨</label>' +
				'<input type="text" class="wx-alc-cab-search" data-cab="search" value="' + wxEsc(wxAlcState.cabSearch) + '" placeholder="搜奇草/内丹/药性..." />' +
			'</div>' +
			'<div class="wx-alc-cab-scroll" data-cab="grid"></div>';

		_body.html(toolbarHtml);

		var grid = _body.find('[data-cab="grid"]');
		var kindLabels = { herb: '天下奇草', core: '山海内丹', trophy: '异兽奇材' };
		var shown = 0;
		var cardsHtml = '';

		for (var i = 0; i < allIngs.length; i++) {
			var it = allIngs[i];
			if (wxAlcState.cabKindFilter !== 'all' && it.kind !== wxAlcState.cabKindFilter) continue;
			if (wxAlcState.cabNatureFilter !== 'all' && it.nature !== wxAlcState.cabNatureFilter) continue;
			if (q) {
				var hay = (it.name + ' ' + it.natureName + ' ' + it.description).toLowerCase();
				if (hay.indexOf(q) === -1) continue;
			}
			shown++;
			var kLbl = kindLabels[it.kind] || '奇材';
			var withdrawBtns = '';
			if (it.cabinetCount > 0) {
				withdrawBtns += '<span class="wx-alc-mini-btn" data-wkey="' + wxEsc(it.key) + '" data-wqty="1">取出 ×1</span>';
				if (it.cabinetCount >= 5) {
					withdrawBtns += '<span class="wx-alc-mini-btn" data-wkey="' + wxEsc(it.key) + '" data-wqty="5">取出 ×5</span>';
				}
			} else {
				withdrawBtns = '<span style="font-size:1.15rem;color:#bd9d71;font-style:italic;">现存行囊中（点击上方入柜可省空间）</span>';
			}

			cardsHtml +=
				'<div class="wx-alc-cab-card" title="' + wxEsc(it.description) + '">' +
					'<img class="wx-cab-icon" src="coui://gfx/' + it.icon + '" alt=""/>' +
					'<div class="wx-alc-cab-cname">' + wxEsc(it.name) + '</div>' +
					'<div class="wx-alc-cab-cmeta">' +
						'[' + kLbl + '] <span style="color:' + it.natureColor + ';">' + wxEsc(it.natureName) + ' · 药力' + it.potency + '</span> · 柜藏 <strong style="color:#7ee29a;">' + it.cabinetCount + '</strong>' +
						(it.stashCount > 0 ? (' / 行囊 ' + it.stashCount) : '') +
					'</div>' +
					'<div class="wx-alc-cab-cdesc">' + wxEsc(it.description) + '</div>' +
					'<div class="wx-alc-cab-cbtns">' + withdrawBtns + '</div>' +
				'</div>';
		}

		if (shown === 0) {
			grid.html('<div style="padding:4rem 2rem;color:#bd9d71;font-style:italic;text-align:center;">百草药柜与行囊中暂无符合筛选条件的奇草、大妖内丹或异兽奇材。<br/>探秘山海凶兽巢穴、奇遇采药或击败强敌即可收集入柜（零仓库占格）！</div>');
		} else {
			grid.html(cardsHtml + '<div class="clear-both"></div>');
		}

		_body.find('[data-cabact]').on('click', function () {
			if (!wxAlcState.sqHandle) return;
			var incTr = ($(this).attr('data-cabact') === 'sweep-all');
			SQ.call(wxAlcState.sqHandle, 'onWXAlchemySweep', [incTr, wxAlcState.entityId], function (_res) {
				if (_res && _res.ok) {
					wxSyncHostFromAlchemyResponse(_res);
					wxAlcState.data = _res;
					wxRenderAll(_dlg);
					wxShowAlcBanner(_res.actionMessage, false);
				} else {
					wxShowAlcBanner((_res && _res.reason) ? _res.reason : '收纳失败。', true);
				}
			});
		});

		_body.find('[data-cabchk]').on('change', function () {
			if (!wxAlcState.sqHandle) return;
			var m = $(this).attr('data-cabchk');
			var en = $(this).is(':checked');
			SQ.call(wxAlcState.sqHandle, 'onWXAlchemyToggleAuto', [m, en, wxAlcState.entityId], function (_res) {
				if (_res && _res.ok) {
					wxSyncHostFromAlchemyResponse(_res);
					wxAlcState.data = _res;
					wxRenderAll(_dlg);
					wxShowAlcBanner(_res.actionMessage, false);
				}
			});
		});

		grid.find('[data-wkey]').on('click', function () {
			if (!wxAlcState.sqHandle) return;
			var wk = $(this).attr('data-wkey');
			var wq = parseInt($(this).attr('data-wqty'), 10) || 1;
			SQ.call(wxAlcState.sqHandle, 'onWXAlchemyWithdraw', [wk, wq, wxAlcState.entityId], function (_res) {
				if (_res && _res.ok) {
					wxSyncHostFromAlchemyResponse(_res);
					wxAlcState.data = _res;
					wxRenderAll(_dlg);
					wxShowAlcBanner(_res.actionMessage, false);
				} else {
					wxShowAlcBanner((_res && _res.reason) ? _res.reason : '取出失败。', true);
				}
			});
		});

		var sInput = _body.find('[data-cab="search"]');
		sInput.on('keydown keyup keypress', function (_e) {
			if (_e.keyCode === 27) {
				wxCloseAlchemyModal();
				return false;
			}
			_e.stopPropagation();
		});
		sInput.on('keyup change', function () {
			var raw = $(this).val() || '';
			wxAlcState.cabSearch = raw.replace(/^\s+|\s+$/g, '').toLowerCase();
			wxRenderCabinetView(_body, _dlg);
		});
	}

	function wxFindReforgeObj(_uid) {
		var fg = (wxAlcState.data && wxAlcState.data.forge) ? wxAlcState.data.forge : null;
		var list = (fg && fg.items) ? fg.items : [];
		for (var i = 0; i < list.length; i++) {
			if (list[i].uid === _uid) return list[i];
		}
		return null;
	}

	function wxRenderReforgeWorkbench(_wb, _sel, _dlg) {
		var d = wxAlcState.data;
		var fg = (d && d.forge) ? d.forge : null;
		if (!_sel || !fg) {
			_wb.html(
				'<div style="padding:3.5rem 1.8rem;color:#bd9d71;text-align:center;line-height:2.1rem;">' +
					'<div style="font-size:1.55rem;color:#dda21f;margin-bottom:0.6rem;">百工神兵重锻炉 · 免大妖内丹淬洗极品</div>' +
					'<div>当前战团尚无已铸造的【百工奇物 / 山海神装 / 传世名器】。</div>' +
					'<div>前往城镇【百工丹坊】首次打造兵甲后，即可随时在此耗 1 份普通百工奇材重复淬洗更高品相与词条上下限！</div>' +
				'</div>'
			);
			return;
		}

		var ch = fg.chances || [35, 42, 18, 5];
		var pity = fg.pity || 0;
		var pipsHtml = '';
		for (var p = 0; p < 5; p++) {
			pipsHtml += '<span class="wx-rfg-pip' + (p < pity ? ' is-lit' : '') + '"></span>';
		}

		var rows = _sel.statRows || [];
		var statRowsHtml = '';
		for (var r = 0; r < rows.length; r++) {
			var sr = rows[r];
			statRowsHtml +=
				'<div class="wx-rfg-stat-row' + (r % 2 === 1 ? ' is-even' : '') + '">' +
					'<span class="wx-rfg-col-lbl">' + wxEsc(sr.label) + '</span>' +
					'<span class="wx-rfg-col-cur">当前：<strong style="color:' + _sel.gradeColor + ';">' + wxEsc(sr.cur) + '</strong></span>' +
					'<span class="wx-rfg-col-rng">区间：[' + wxEsc(sr.range) + ']</span>' +
					'<div class="clear-both"></div>' +
				'</div>';
		}
		if (!statRowsHtml) {
			statRowsHtml = '<div class="wx-rfg-stat-row"><span style="color:#bd9d71;">重锻可提升整体品相与神工灵韵共鸣。</span></div>';
		}

		var mwHtml = (_sel.grade >= 3)
			? '<div class="wx-rfg-mw-note">✦ 此器已觉醒<strong>【神工共鸣】</strong>：若附带器魂灵韵，实战触发概率额外 +8%、灼烧/回血等数值 +2！若仍欲追求更高完美度，连点两次下方按钮即可重洗。</div>'
			: '';

		var money = (d && typeof d.money === 'number') ? d.money : 0;
		var canAfford = fg.catalystFound && (money >= _sel.silverCost);
		var lackNote = '';
		if (!fg.catalystFound) {
			lackNote = '<div style="color:#ff8070;margin-top:0.2rem;">缺少百工奇材辅料（需赤炎翎 / 真龙逆鳞 / 太古凶角 / 战神煞骨 / 天妖蛟筋 / 蚀骨毒晶 任一 ×1）。</div>';
		} else if (money < _sel.silverCost) {
			lackNote = '<div style="color:#ff8070;margin-top:0.2rem;">纹银不足（需 ' + _sel.silverCost + ' 两，现存 ' + money + ' 两）。</div>';
		}

		var isConfirmingMw = (_sel.grade >= 3 && wxAlcState.confirmMasterworkUid === _sel.uid);
		var btnLabel = isConfirmingMw
			? ('⚠ 确认重洗神工（' + _sel.silverCost + '两）')
			: ('重锤淬炼（' + _sel.silverCost + '两 + 奇材×1）');

		var catStr = fg.catalystFound
			? ('下次消耗：<strong style="color:#7ee29a;">' + wxEsc(fg.catalystName) + ' ×1</strong>（药柜/行囊共余 ' + fg.catalystTotal + ' 份 · <strong>免耗山海大妖内丹！</strong>）')
			: '<span style="color:#ff8070;">当前无可用百工奇材（余 0 份）</span>';

		var html =
			'<div class="wx-alc-wb-hdr">' +
				'<img class="wx-alc-wb-hdr-icon" src="coui://gfx/' + _sel.icon + '" alt=""/>' +
				'<div class="wx-alc-wb-title">' + wxEsc(_sel.name) +
					' <span style="font-size:1.28rem;color:' + _sel.gradeColor + ';">【' + wxEsc(_sel.gradeTitle) + ' · 完美度 ' + _sel.perfectionPct + '%】</span>' +
				'</div>' +
				'<div class="wx-alc-wb-desc">归属：<strong>' + wxEsc(_sel.ownerLabel) + '</strong>　│　' + wxEsc(_sel.description) + '</div>' +
			'</div>' +
			'<div class="wx-rfg-pity-box">' +
				'<div>掌锤匠师：<strong style="color:#dda21f;">' + wxEsc(fg.smithLabel) + '</strong>' +
					(fg.bonusHighPct > 0 ? ('（高品率 +' + fg.bonusHighPct + '%' + (fg.hasDiscount ? ' · 重锻八折' : '') + '）') : '') +
					'　│　品相率：凡锻 ' + ch[0] + '% · <span style="color:#5ec47a;">良工 ' + ch[1] + '%</span> · <span style="color:#b58ae6;">百炼 ' + ch[2] + '%</span> · <span style="color:#f0bc42;">神工 ' + ch[3] + '%</span>' +
				'</div>' +
				'<div>百炼炉温：' + pipsHtml + '<strong style="color:#f0bc42;">(' + pity + '/5)</strong> —— ' +
					(pity >= 5 ? '<strong style="color:#ffe28a;">炉火已满！本锤必出【百炼】或【神工】！</strong>' : '连淬 5 锤未见百炼，下一锤必成【百炼/神工】（重锻顺带免费修满耐久）') +
				'</div>' +
				'<div>' + catStr + '</div>' +
				lackNote +
			'</div>' +
			mwHtml +
			'<div class="wx-rfg-stat-box">' +
				'<div class="wx-rfg-stat-hdr">' +
					'<span class="wx-rfg-col-lbl">锻造词条</span>' +
					'<span class="wx-rfg-col-cur">当前数值</span>' +
					'<span class="wx-rfg-col-rng">百工上下限范围</span>' +
					'<div class="clear-both"></div>' +
				'</div>' +
				statRowsHtml +
			'</div>' +
			'<div class="wx-alc-act-row">' +
				'<span class="wx-alc-act-btn' + (canAfford ? '' : ' is-disabled') + '" style="width:25.6rem;" data-rfg-exec="1">' +
					'<img src="coui://gfx/ui/icons/asset_supplies.png" style="width:1.9rem;height:1.9rem;vertical-align:middle;margin:-0.25rem 0.3rem 0 0;" alt=""/>' + btnLabel +
				'</span>' +
			'</div>';

		_wb.html(html);

		_wb.find('[data-rfg-exec="1"]').on('click', function () {
			if ($(this).hasClass('is-disabled') || !wxAlcState.sqHandle) return;
			if (_sel.grade >= 3 && wxAlcState.confirmMasterworkUid !== _sel.uid) {
				wxAlcState.confirmMasterworkUid = _sel.uid;
				wxRenderReforgeWorkbench(_wb, _sel, _dlg);
				wxShowAlcBanner('该神兵已达【神工】品相！若确认仍要重洗词条，请再点击一次「确认重洗神工」。', false);
				return;
			}
			wxAlcState.confirmMasterworkUid = null;
			SQ.call(
				wxAlcState.sqHandle,
				'onWXForgeReforge',
				[_sel.uid, wxAlcState.entityId],
				function (_res) {
					if (_res && _res.ok) {
						wxSyncHostFromAlchemyResponse(_res);
						wxAlcState.data = _res;
						wxRenderAll(_dlg);
						wxShowAlcBanner(_res.actionMessage || '百工重锻完成！', false);
					} else {
						wxShowAlcBanner((_res && _res.reason) ? _res.reason : '未能完成神兵重锻。', true);
					}
				}
			);
		});
	}

	function wxRenderReforgeView(_body, _dlg) {
		var d = wxAlcState.data;
		var fg = (d && d.forge) ? d.forge : null;
		var allItems = (fg && fg.items) ? fg.items : [];
		var filtered = [];
		var selObj = null;

		for (var i = 0; i < allItems.length; i++) {
			var it = allItems[i];
			if (wxAlcState.reforgeFilter === 'equipped' && !it.isEquipped) continue;
			if (wxAlcState.reforgeFilter === 'stash' && it.isEquipped) continue;
			if (wxAlcState.reforgeFilter === 'upgradeable' && it.grade >= 3) continue;
			filtered.push(it);
			if (it.uid === wxAlcState.selectedReforgeUid) selObj = it;
		}
		if (!selObj && filtered.length > 0) {
			selObj = filtered[0];
			wxAlcState.selectedReforgeUid = selObj.uid;
		} else if (!selObj && allItems.length > 0) {
			selObj = wxFindReforgeObj(wxAlcState.selectedReforgeUid);
		}

		var leftHtml = '';
		if (filtered.length === 0) {
			leftHtml = '<div style="padding:3rem 1rem;color:#bd9d71;text-align:center;font-style:italic;">当前筛选下暂无可重锻的武侠神装或百工奇物。</div>';
		} else {
			for (var j = 0; j < filtered.length; j++) {
				var rj = filtered[j];
				var isSel = (selObj && rj.uid === selObj.uid);
				leftHtml +=
					'<div class="wx-alc-frow' + (isSel ? ' is-selected' : '') + '" data-ruid="' + wxEsc(rj.uid) + '">' +
						'<img class="wx-alc-frow-icon" src="coui://gfx/' + rj.icon + '" alt=""/>' +
						'<div class="wx-alc-frow-top">' +
							'<span class="wx-alc-frow-name">' + wxEsc(rj.name) + '</span>' +
							'<span class="wx-rfg-badge" style="color:' + rj.gradeColor + ';">' + wxEsc(rj.gradeTitle) + ' · ' + rj.perfectionPct + '%</span>' +
							'<div class="clear-both"></div>' +
						'</div>' +
						'<div class="wx-alc-frow-sub">[' + wxEsc(rj.ownerLabel) + '] 重淬 ' + rj.silverCost + '两 · ' + wxEsc(rj.summaryStr || '百工秘宝') + '</div>' +
					'</div>';
			}
		}

		_body.html(
			'<div class="wx-alc-left-col" data-alc="rfg-list">' + leftHtml + '</div>' +
			'<div class="wx-alc-right-col" data-alc="rfg-wb"></div>'
		);

		_body.find('[data-ruid]').on('click', function () {
			wxAlcState.selectedReforgeUid = $(this).attr('data-ruid');
			wxAlcState.confirmMasterworkUid = null;
			wxRenderReforgeView(_body, _dlg);
		});

		wxRenderReforgeWorkbench(_body.find('[data-alc="rfg-wb"]'), selObj, _dlg);
	}

	function wxRenderAll(_dlg) {
		wxRenderMetaAndTabs(_dlg);
		var body = _dlg.find('[data-alc="body"]');
		if (wxAlcState.mode === 'cabinet') {
			wxRenderCabinetView(body, _dlg);
		} else if (wxAlcState.mode === 'reforge') {
			wxRenderReforgeView(body, _dlg);
		} else {
			wxRenderCauldronView(body, _dlg);
		}
	}

	function wxOpenAlchemyModalDOM(_payload) {
		wxCloseAlchemyModal();
		wxAlcState.data = _payload;

		if (wxAlcState.hostDS && wxAlcState.hostDS.notifyBackendPopupDialogIsVisible) {
			wxAlcState.hostDS.notifyBackendPopupDialogIsVisible(true);
		}

		// Pick initial formula (first ready formula, or first formula)
		var flist = _payload.formulas || [];
		var initF = null;
		if (wxAlcState.selectedFormulaId) {
			initF = wxFindFormulaObj(wxAlcState.selectedFormulaId);
		}
		if (!initF) {
			for (var i = 0; i < flist.length; i++) {
				if (flist[i].canAutoBrew) { initF = flist[i]; break; }
			}
			if (!initF && flist.length > 0) initF = flist[0];
		}
		if (initF) {
			wxSelectFormulaAndAutoFill(initF);
		}

		var host = $('.root-screen:first');
		if (!host.length) host = $(document.body);

		var backdrop = $(
			'<div class="wx-alc-backdrop">' +
				'<div class="wx-alc-dialog">' +
					'<div class="wx-alc-hdr">' +
						'<span class="wx-alc-title"><img src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" alt=""/>百草丹炉 · 八卦配伍炼丹 · 神兵重锻 · 药柜总览</span>' +
						'<div class="wx-alc-hdr-close" data-alc-close="1" title="关闭丹炉 (ESC)">×</div>' +
					'</div>' +
					'<div class="wx-alc-meta-bar" data-alc="meta"></div>' +
					'<div class="wx-alc-banner"></div>' +
					'<div class="wx-alc-top-tabs" data-alc="top-tabs"></div>' +
					'<div class="wx-alc-body" data-alc="body"></div>' +
				'</div>' +
			'</div>'
		);

		host.append(backdrop);

		backdrop.find('[data-alc-close="1"]').on('click', function () {
			wxCloseAlchemyModal();
		});
		backdrop.on('click', function (_e) {
			if ($(_e.target).hasClass('wx-alc-backdrop')) {
				wxCloseAlchemyModal();
			}
		});
		$(document).on('keydown.wxAlcModal', function (_e) {
			if (_e.keyCode === 27) {
				wxCloseAlchemyModal();
				_e.stopPropagation();
				return false;
			}
		});

		wxRenderAll(backdrop.find('.wx-alc-dialog'));
	}

	// Public opener callable from World Topbar, Character Screen, or Town Taxidermist!
	window.WX_OpenAlchemyCauldron = function (_sqHandle, _hostDS, _perksMod, _entityId, _initialMode) {
		var sq = _sqHandle || (wxWorldTopbarModRef ? wxWorldTopbarModRef.mSQHandle : null);
		if (!sq) return;
		wxAlcState.sqHandle = sq;
		wxAlcState.hostDS   = _hostDS || null;
		wxAlcState.perksMod = _perksMod || null;
		wxAlcState.entityId = _entityId || null;
		wxAlcState.mode     = _initialMode || 'cauldron';

		SQ.call(sq, 'onWXGetAlchemyState', _entityId ? [_entityId] : null, function (_res) {
			if (_res && _res.ok) {
				wxOpenAlchemyModalDOM(_res);
			}
		});
	};

	// ------------------------------------------------------------------------
	// 1. World Topbar Button (`百草丹炉`, right next to `江湖名刺`)
	// ------------------------------------------------------------------------
	if (typeof WorldScreenTopbarOptionsModule !== 'undefined') {
		var origTopbarCreate = WorldScreenTopbarOptionsModule.prototype.createDIV;
		WorldScreenTopbarOptionsModule.prototype.createDIV = function (_parentDiv) {
			var self = this;
			wxWorldTopbarModRef = this;
			origTopbarCreate.call(this, _parentDiv);

			if (this.mContainer && !this.mContainer.find('.wx-world-alc-btn').length) {
				var alcBtn = $(
					'<div class="wx-world-alc-btn" title="开启随军【八卦丹炉】炼制灵丹奇药，或查阅零占格【百草药柜】">' +
						'<img src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" alt=""/>百草丹炉' +
					'</div>'
				);
				alcBtn.on('click', function () {
					if (self.mSQHandle !== null) {
						window.WX_OpenAlchemyCauldron(self.mSQHandle, null, null, null, 'cauldron');
					}
				});
				this.mContainer.append(alcBtn);
			}
		};
	}

	// ------------------------------------------------------------------------
	// 2. Town `百工丹坊` (Taxidermist) Header Shortcuts (`丹炉·药柜` & `神兵重锻`) + Craft Roll Banner!
	// ------------------------------------------------------------------------
	if (typeof WorldTownScreenTaxidermistDialogModule !== 'undefined') {
		var origTaxCreate = WorldTownScreenTaxidermistDialogModule.prototype.createDIV;
		WorldTownScreenTaxidermistDialogModule.prototype.createDIV = function (_parentDiv) {
			var self = this;
			origTaxCreate.call(this, _parentDiv);
			var fBar = this.mContainer ? this.mContainer.find('.wx-craft-filter-bar:first') : null;
			if (fBar && fBar.length && !fBar.find('.wx-tax-alc-btn').length) {
				var cabBtn = $(
					'<span class="wx-tax-alc-btn" title="开启随身八卦丹炉配伍炼丹，或从零占格百草药柜中取放奇材">' +
						'<img src="coui://gfx/ui/wx_icons/wx_glyph_herb_cabinet.png" alt=""/>丹炉·药柜' +
					'</span>'
				);
				cabBtn.on('click', function () {
					window.WX_OpenAlchemyCauldron(self.mSQHandle, null, null, null, 'cauldron');
				});
				var rfgBtn = $(
					'<span class="wx-tax-reforge-btn" title="免耗大妖内丹，耗普通奇材重洗已打造兵甲的品相与属性范围">' +
						'<img src="coui://gfx/ui/icons/asset_supplies.png" alt=""/>神兵重锻' +
					'</span>'
				);
				rfgBtn.on('click', function () {
					window.WX_OpenAlchemyCauldron(self.mSQHandle, null, null, null, 'reforge');
				});
				fBar.append(cabBtn);
				fBar.append(rfgBtn);
			}
		};

		var origTaxLoadCraftBanner = WorldTownScreenTaxidermistDialogModule.prototype.loadFromData;
		if (typeof origTaxLoadCraftBanner === 'function') {
			WorldTownScreenTaxidermistDialogModule.prototype.loadFromData = function (_data) {
				origTaxLoadCraftBanner.call(this, _data);
				if (_data && _data.wxCraftBanner && this.mDialogContainer) {
					var oldB = this.mDialogContainer.find('.wx-screen-banner');
					if (oldB.length) oldB.remove();
					var bEl = $('<div class="wx-screen-banner">' + wxEsc(_data.wxCraftBanner) + '</div>');
					this.mDialogContainer.append(bEl);
					setTimeout(function () {
						bEl.fadeOut(260, function () { bEl.remove(); });
					}, 4200);
				}
			};
		}
	}

	// ------------------------------------------------------------------------
	// 3. Character Screen `[武学修为]` Header Button + Enhanced `洗经伐髓` Pill Picker
	// ------------------------------------------------------------------------
	if (typeof CharacterScreenPerksModule !== 'undefined') {
		var origBuildRoot = CharacterScreenPerksModule.prototype.wxBuildRootDOM;
		if (typeof origBuildRoot === 'function') {
			CharacterScreenPerksModule.prototype.wxBuildRootDOM = function (_host) {
				var self = this;
				origBuildRoot.call(this, _host);
				if (this.mWXHeader && !this.mWXHeader.find('[data-wx="open-alchemy"]').length) {
					var alcBtn = $(
						'<div class="wx-btn" data-wx="open-alchemy" title="开启八卦丹炉配伍炼丹，或打理零仓库占格的百草药柜">' +
							'<img src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" alt=""/>百草丹炉' +
						'</div>'
					);
					alcBtn.on('click', function () {
						if (self.mDataSource && self.mDataSource.mSQHandle !== null) {
							window.WX_OpenAlchemyCauldron(self.mDataSource.mSQHandle, self.mDataSource, self, self.mWXCurrentEntityId, 'cauldron');
						}
					});
					var washBtn = this.mWXHeader.find('[data-wx="open-wash"]');
					if (washBtn.length) {
						alcBtn.insertBefore(washBtn);
					} else {
						this.mWXHeader.find('.wx-header-right').prepend(alcBtn);
					}
				}
			};
		}

		var origRenderAll = CharacterScreenPerksModule.prototype.wxRenderAll;
		if (typeof origRenderAll === 'function') {
			CharacterScreenPerksModule.prototype.wxRenderAll = function () {
				origRenderAll.call(this);
				if (!this.mWXHeader || !this.mWXState) return;
				var alcBtn = this.mWXHeader.find('[data-wx="open-alchemy"]');
				if (alcBtn.length && this.mWXState.alchemySummary) {
					var cabCnt = this.mWXState.alchemySummary.cabinetTotal || 0;
					alcBtn.html('<img src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" alt=""/>丹炉' + (cabCnt > 0 ? ('(' + cabCnt + ')') : ''));
				}
				var bro = this.mWXState.brother;
				if (bro && bro.hasWangchenGrace) {
					var hb = this.mWXHeader.find('[data-wx="health-badges"]');
					if (hb.length && hb.html().indexOf('归元护脉') === -1) {
						hb.append('<span class="wx-tag wx-tag-harmony" title="下一次换装或卸下武学免除全部散功调息">归元护脉</span>');
					}
				}
			};
		}

		// Upgrade Marrow Wash Modal to let player pick between 功成契机 / 太乙紫金洗髓丹 / 易筋锻骨丸 / 洗髓丹!
		CharacterScreenPerksModule.prototype.wxOpenWashModal = function () {
			var self = this;
			if (!this.mWXState || !this.mWXState.brother) return;
			var bro = this.mWXState.brother;
			var wp = this.mWXState.washPills || {
				wx_pill_xisui: this.mWXState.washPillCount || 0,
				wx_pill_zijin_xisui: 0,
				wx_pill_yijin_wan: 0,
				wx_pill_humai: this.mWXState.protectPillCount || 0,
				totalMainWash: this.mWXState.washPillCount || 0
			};
			var protectPills = this.mWXState.protectPillCount || 0;
			var pendingChances = bro.pendingWashChances || 0;

			var defaultSource = 'wx_pill_xisui';
			if (pendingChances > 0) defaultSource = 'pending';
			else if (wp.wx_pill_zijin_xisui > 0) defaultSource = 'wx_pill_zijin_xisui';
			else if (wp.wx_pill_xisui > 0) defaultSource = 'wx_pill_xisui';
			else if (wp.wx_pill_yijin_wan > 0) defaultSource = 'wx_pill_yijin_wan';

			this.mWXWashState = {
				targetAttrIdx: -1,
				replaceAttrIdx: -1,
				useProtectPill: false,
				washSource: defaultSource
			};

			var attrHtml = '';
			for (var i = 0; i < 8; i++) {
				var stars = '';
				for (var st = 0; st < bro.talents[i]; st++) stars += '★';
				if (!stars) stars = '无星';
				attrHtml +=
					'<div class="wx-attr-btn' + (i % 2 === 1 ? ' is-even' : '') + '" data-attr-idx="' + i + '">' +
						'<span class="wx-attr-name">' + wxEsc(bro.attrLabels[i]) + ' (' + bro.baseStats[i] + ')</span>' +
						'<span class="wx-attr-stars">' + stars + '</span>' +
					'</div>';
			}
			attrHtml += '<div class="clear-both"></div>';

			var pillOpts = [
				{ id: 'pending',             cnt: pendingChances,         icon: 'wx_icons/wx_icon_ap.png',                    label: '孤本洗髓契机 (' + pendingChances + ')' },
				{ id: 'wx_pill_zijin_xisui', cnt: wp.wx_pill_zijin_xisui, icon: 'items/consumables/wx_pill_zijin_xisui.png', label: '太乙紫金洗髓丹 (' + wp.wx_pill_zijin_xisui + ' · +12%免重震)' },
				{ id: 'wx_pill_yijin_wan',   cnt: wp.wx_pill_yijin_wan,   icon: 'items/consumables/wx_pill_yijin_wan.png',   label: '易筋锻骨丸 (' + wp.wx_pill_yijin_wan + ' · 0★开星+20%)' },
				{ id: 'wx_pill_xisui',       cnt: wp.wx_pill_xisui,       icon: 'items/consumables/wx_pill_xisui.png',       label: '洗髓丹 (' + wp.wx_pill_xisui + ')' }
			];

			var sourceBarHtml = '<div class="wx-wash-pill-bar"><div style="font-size:1.24rem;color:#bd9d71;margin-bottom:0.25rem;">1. 选择本次洗经伐髓启用的灵丹或机缘：</div>';
			for (var p = 0; p < pillOpts.length; p++) {
				var po = pillOpts[p];
				if (po.id === 'pending' && po.cnt <= 0) continue;
				var selCls = (po.id === defaultSource && po.cnt > 0) ? ' is-selected' : '';
				var disCls = (po.cnt <= 0) ? ' is-disabled' : '';
				sourceBarHtml +=
					'<span class="wx-wash-pill-opt' + selCls + disCls + '" data-wsrc="' + po.id + '">' +
						'<img src="coui://gfx/ui/' + po.icon + '" alt=""/>' + po.label +
					'</span>';
			}
			sourceBarHtml += '</div>';

			var box = $(
				'<div class="wx-modal-box wx-modal-wash">' +
					'<div class="wx-modal-title">' +
						'<span>洗经伐髓 · 重塑先天根骨（每人至多 3 项属性带星）</span>' +
						'<div class="wx-cinnabar-close-btn wx-modal-hdr-close" data-wx-close="1"><img src="coui://gfx/ui/wx_skin/wx_seal_close.png" alt=""/>关闭</div>' +
						'<div class="clear-both"></div>' +
					'</div>' +
					'<div class="wx-modal-body">' +
						sourceBarHtml +
						'<div class="wx-wash-label">2. 选择要冲击升星 / 开星的目标属性：</div>' +
						'<div class="wx-attr-grid" data-wx="wash-targets">' + attrHtml + '</div>' +
						'<div data-wx="replace-wrap" style="display:none;">' +
							'<div class="wx-wash-label">3. 已有 3 项带星，请选择要洗去替换的旧带星属性（易筋换星）：</div>' +
							'<div class="wx-attr-grid" data-wx="wash-replaces"></div>' +
						'</div>' +
						'<label class="wx-protect-check">' +
							'<input type="checkbox" data-wx="use-protect"' + (protectPills <= 0 ? ' disabled="disabled"' : '') + ' />' +
							' 辅服「护脉丹」（余 ' + protectPills + ' 颗）：成功率 +5%，且免除失败永久暗疾风险' +
						'</label>' +
						'<div class="wx-wash-preview" data-wx="wash-preview">请点击上方目标属性查看实时成功率与风险明细。</div>' +
					'</div>' +
					'<div class="wx-modal-actions">' +
						'<div class="wx-btn wx-btn-danger is-disabled" data-wx="wash-exec">开始洗髓</div>' +
						'<div class="wx-btn" data-wx-close="1">关闭</div>' +
					'</div>' +
				'</div>'
			);

			function queryExPreview() {
				var st = self.mWXWashState;
				var previewEl = box.find('[data-wx="wash-preview"]');
				var execBtn = box.find('[data-wx="wash-exec"]');
				var availCnt = (st.washSource === 'pending') ? pendingChances : (wp[st.washSource] || 0);

				if (st.targetAttrIdx < 0 || !self.mDataSource || !self.mDataSource.mSQHandle) {
					execBtn.addClass('is-disabled');
					return;
				}
				SQ.call(
					self.mDataSource.mSQHandle,
					'onWXGetWashPreviewEx',
					[self.mWXCurrentEntityId, st.targetAttrIdx, st.replaceAttrIdx, st.useProtectPill, st.washSource],
					function (_pv) {
						if (!_pv || !_pv.Ok) {
							previewEl.html('<span style="color:#CD2626;font-weight:bold;">' + wxEsc((_pv && _pv.Reason) ? _pv.Reason : '暂不可洗髓。') + '</span>');
							execBtn.addClass('is-disabled');
							return;
						}
						var modeText = _pv.IsReplaceMode
							? ('易筋换星：洗去「' + wxEsc(_pv.ReplaceAttrName) + '」原有星级 → 「' + wxEsc(_pv.TargetAttrName) + '」升至 1★')
							: ('冲星升级：「' + wxEsc(_pv.TargetAttrName) + '」' + _pv.CurrentStar + '★ → ' + _pv.NextStar + '★');
						var pillExtra = (_pv.PillBonus && _pv.PillBonus > 0) ? (' + 丹品加成 +' + _pv.PillBonus + '%') : '';
						var failShock = _pv.AvoidHeavyShock ? '失败由紫金丹力护脉免重度震荡（仅 2 日轻调息）' : '失败触发重度内伤「经脉震荡」';
						var riskText = _pv.PermInjuryRisk > 0
							? (failShock + '，且有 ' + _pv.PermInjuryRisk + '% 概率留下永久暗疾（可用生生造化丹拔除）！')
							: (failShock + '（无永久暗疾风险）。');

						previewEl.html(
							'<div style="font-weight:bold;">' + modeText + '（选用：' + wxEsc(_pv.WashPillName || '洗髓丹') + '）</div>' +
							'<div class="wx-chance-line">最终成功率：<strong>' + _pv.FinalChance + '%</strong>（基础 ' + _pv.BaseChance + '% + 筹备 +' + _pv.PrepBonus + '%' + pillExtra + '）</div>' +
							'<div style="color:#CD2626;">' + riskText + '</div>' +
							(availCnt <= 0 ? '<div style="color:#CD2626;font-weight:bold;">当前缺少所选洗髓灵丹（可在【百草丹炉】中配伍炼制）。</div>' : '')
						);
						execBtn.toggleClass('is-disabled', availCnt <= 0);
					}
				);
			}

			box.find('[data-wsrc]').on('click', function () {
				if ($(this).hasClass('is-disabled')) return;
				self.mWXWashState.washSource = $(this).attr('data-wsrc');
				box.find('[data-wsrc]').removeClass('is-selected');
				$(this).addClass('is-selected');
				queryExPreview();
			});

			box.find('[data-wx="wash-targets"] .wx-attr-btn').on('click', function () {
				var idx = parseInt($(this).attr('data-attr-idx'), 10);
				self.mWXWashState.targetAttrIdx = idx;
				self.mWXWashState.replaceAttrIdx = -1;
				box.find('[data-wx="wash-targets"] .wx-attr-btn').removeClass('is-selected');
				$(this).addClass('is-selected');
				// Auto-select 易筋锻骨丸 if clicking a 0★ attribute and player owns 易筋锻骨丸!
				if (bro.talents[idx] === 0 && wp.wx_pill_yijin_wan > 0 && self.mWXWashState.washSource === 'wx_pill_xisui') {
					self.mWXWashState.washSource = 'wx_pill_yijin_wan';
					box.find('[data-wsrc]').removeClass('is-selected');
					box.find('[data-wsrc="wx_pill_yijin_wan"]').addClass('is-selected');
				}
				self.wxUpdateWashReplaceList(box);
				// Rebind replace list clicks so they call queryExPreview!
				box.find('[data-wx="wash-replaces"] .wx-attr-btn').off('click').on('click', function () {
					self.mWXWashState.replaceAttrIdx = parseInt($(this).attr('data-replace-idx'), 10);
					box.find('[data-wx="wash-replaces"] .wx-attr-btn').removeClass('is-selected');
					$(this).addClass('is-selected');
					queryExPreview();
				});
				queryExPreview();
			});

			box.find('[data-wx="use-protect"]').on('change', function () {
				self.mWXWashState.useProtectPill = $(this).is(':checked');
				queryExPreview();
			});

			box.find('[data-wx="wash-exec"]').on('click', function () {
				if ($(this).hasClass('is-disabled') || !self.mDataSource || !self.mDataSource.mSQHandle) return;
				var st = self.mWXWashState;
				var isPending = (st.washSource === 'pending');
				var pillID = isPending ? 'wx_pill_xisui' : st.washSource;
				SQ.call(
					self.mDataSource.mSQHandle,
					'onWXExecuteWashEx',
					[self.mWXCurrentEntityId, st.targetAttrIdx, st.replaceAttrIdx, st.useProtectPill, isPending, pillID],
					function (_res) {
						self.wxCloseModal();
						if (_res && _res.ok) {
							self.mDataSource.wxApplyVanillaSync(_res);
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

			this.wxOpenModal(box);
		};
	}
})();
