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
		taxMod: null,
		entityId: null,
		data: null,
		mode: 'cauldron',       // 'cauldron' | 'reforge' | 'cabinet'
		formulaFilter: 'all',   // 'all' | 'ready' | 'heal' | 'prep' | 'cultivate'
		selectedFormulaId: 'free',
		slotKeys: ['', '', ''], // [junKey, aux1Key, aux2Key]
		activeSlotIdx: 0,       // 0 = Jun, 1 = Aux1, 2 = Aux2
		fireMode: 'balanced',   // 'gentle' | 'balanced' | 'fierce'
		reforgeFilter: 'all',   // 'all' | 'equipped' | 'stash' | 'upgradeable'
		selectedReforgeUid: null,
		confirmMasterworkUid: null,
		quenchId: 'none',       // 'none' | 'frost' | 'flame' | 'thunder' | 'blood'
		lockSlot: '',           // '' | 'f1' | 'f2'
		cabKindFilter: 'all',   // 'all' | 'herb' | 'core' | 'trophy'
		cabNatureFilter: 'all',
		cabSearch: '',
		bannerTimer: null,
		busy: false,
		taxNeedsRefresh: false
	};

	function wxIsWorkshopMode() {
		return !!(wxAlcState.data && wxAlcState.data.inWorkshop);
	}

	function wxFormatMoneyStr(_n) {
		var s = String(Math.max(0, parseInt(_n, 10) || 0));
		return s.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
	}

	function wxGetIngMap() {
		var map = {};
		var list = (wxAlcState.data && wxAlcState.data.ingredients) ? wxAlcState.data.ingredients : [];
		for (var i = 0; i < list.length; i++) {
			map[list[i].key] = list[i];
		}
		return map;
	}

	function wxFindFormulaObj(_id) {
		if (!_id || _id === 'free') return null;
		var list = (wxAlcState.data && wxAlcState.data.formulas) ? wxAlcState.data.formulas : [];
		for (var i = 0; i < list.length; i++) {
			if (list[i].id === _id) return list[i];
		}
		return null;
	}

	function wxResolveCoreImprint(_jun, _pillKind) {
		if (!_jun || _jun.kind !== 'core') return null;
		var cid = (_jun.key && _jun.key.indexOf('core:') === 0) ? _jun.key.slice(5) : (_jun.key || '');
		var cmap = (wxAlcState.data && wxAlcState.data.coreImprints) ? wxAlcState.data.coreImprints : null;
		if (cmap && (cid in cmap)) {
			var sp = cmap[cid];
			var d = sp.prepDesc || '山海大妖本命丹韵共振';
			if (_pillKind === 'infuse_exp') d = '大妖本命精魄灌顶：拖入武学插槽额外增幅 +15% 火候！';
			else if (_pillKind && _pillKind.indexOf('marrow_wash') === 0) d = '大妖本命精元固本：启用此丹洗经伐髓成功率额外再 +3%！';
			return { title: sp.title || (_jun.name + '本命韵'), color: sp.color || '#f0bc42', desc: d };
		}
		return { title: _jun.name + '本命韵', color: '#f0bc42', desc: '山海大妖内丹坐镇君药，额外铭刻本命丹韵催化四脉武学！' };
	}

	function wxGetFireSpec(_fmode) {
		var list = (wxAlcState.data && wxAlcState.data.fireModes) ? wxAlcState.data.fireModes : null;
		var want = _fmode || wxAlcState.fireMode || 'balanced';
		if (list && list.length) {
			for (var i = 0; i < list.length; i++) {
				if (list[i].id === want) return list[i];
			}
		}
		var fallbacks = {
			gentle: { id: 'gentle', title: '文火温养', short: '文火', color: '#7ee29a', costMult: 0.90, grade2Bonus: 8, grade3Bonus: -4, doubleBonus: -5, desc: '缓火守丹：灵纹率+8%、炭资九折、零丹劫风险' },
			balanced: { id: 'balanced', title: '中火守正', short: '中火', color: '#dda21f', costMult: 1.00, grade2Bonus: 0, grade3Bonus: 0, doubleBonus: 0, desc: '中正鼎火：品阶与双丹均衡稳妥' },
			fierce: { id: 'fierce', title: '武火催霞', short: '武火', color: '#ff8a5c', costMult: 1.20, grade2Bonus: -4, grade3Bonus: 18, doubleBonus: 15, desc: '猛火冲霞：丹霞极品率+18%、双丹率+15%，药性冲克时易发丹劫或逆炼奇丹' }
		};
		return fallbacks[want] || fallbacks.balanced;
	}

	function wxEvalClientMeridian(_jun, _auxObjs, _fireMode) {
		var genMap = { origin: 'vital', vital: 'yang', yang: 'spirit', spirit: 'yin', yin: 'venom', venom: 'origin' };
		var overMap = { yang: 'yin', yin: 'yang', vital: 'venom', venom: 'vital', spirit: 'origin', origin: 'spirit' };
		var genPairs = 0;
		var clashPairs = 0;
		var hasYang = (_jun && _jun.nature === 'yang');
		var hasYin = (_jun && _jun.nature === 'yin');
		var hasVital = (_jun && _jun.nature === 'vital');
		var hasVenom = (_jun && _jun.nature === 'venom');
		var hasSpirit = (_jun && _jun.nature === 'spirit');
		var hasCore = !!(_jun && _jun.kind === 'core');

		for (var i = 0; i < _auxObjs.length; i++) {
			var ax = _auxObjs[i];
			if (!ax) continue;
			var an = ax.nature || '';
			var jn = _jun ? (_jun.nature || '') : '';
			if (ax.kind === 'core') hasCore = true;
			if (an === 'yang') hasYang = true;
			if (an === 'yin') hasYin = true;
			if (an === 'vital') hasVital = true;
			if (an === 'venom') hasVenom = true;
			if (an === 'spirit') hasSpirit = true;
			if ((jn && genMap[jn] === an) || (an && genMap[an] === jn)) genPairs++;
			else if ((jn && overMap[jn] === an) || (an && overMap[an] === jn)) clashPairs++;
		}
		if (_auxObjs.length >= 2 && _auxObjs[0] && _auxObjs[1]) {
			var a0 = _auxObjs[0].nature || '';
			var a1 = _auxObjs[1].nature || '';
			if ((a0 && genMap[a0] === a1) || (a1 && genMap[a1] === a0)) genPairs++;
			else if ((a0 && overMap[a0] === a1) || (a1 && overMap[a1] === a0)) clashPairs++;
		}

		var mutName = '';
		if (hasCore && hasYang && hasYin) mutName = '《两仪逆命混元丹》';
		else if (hasCore && hasVital && hasVenom) mutName = '《枯荣生死涅槃丸》';
		else if (hasCore && hasSpirit && hasVenom) mutName = '《神魔一念辟邪丹》';
		var reverseReady = (mutName !== '');
		var mstBonus = (wxAlcState.data && wxAlcState.data.mastery) ? (wxAlcState.data.mastery.bonusDoublePct || 0) : 0;
		var tribPct = 0;
		if (_fireMode === 'fierce') {
			if (reverseReady) {
				tribPct = 0;
			} else {
				tribPct = 8 + clashPairs * 18 - genPairs * 6 - Math.floor(mstBonus * 0.5);
				if (tribPct < 0) tribPct = 0;
				if (tribPct > 48) tribPct = 48;
			}
		}

		var label = '';
		var color = '#bd9d71';
		if (reverseReady && _fireMode === 'fierce') {
			label = '✦ 阴阳逆命丹象已成：大妖内丹统御两极相克，武火催霞可逆炼失传奇药' + mutName + '！';
			color = '#ffe28a';
		} else if (reverseReady) {
			label = '✦ 鼎内已具【山海内丹 + 两极相克】逆命之基（切至【武火催霞】可逆炼' + mutName + '）';
			color = '#f0bc42';
		} else if (genPairs > 0 && clashPairs === 0) {
			label = '六脉相生 ×' + genPairs + '：鼎内药力额外 +' + genPairs + '，双丹与上品率稳步增益' + (tribPct > 0 ? ('（武火丹劫率 ' + tribPct + '%）') : '');
			color = '#7ee29a';
		} else if (clashPairs > 0) {
			label = '六脉冲克 ×' + clashPairs + (_fireMode === 'fierce' ? ('：武火激荡，有 ' + tribPct + '% 概率引动【丹劫】化为《丹劫暴烈奇毒散》！') : '：药性相激，双丹率微降（若以大妖内丹配水火再催武火可逆炼奇丹）');
			color = (_fireMode === 'fierce') ? '#ff8a5c' : '#e6a96b';
		} else if (tribPct > 0) {
			label = '六脉平顺 · 武火催霞丹劫异变率 ' + tribPct + '%（换文火可免丹劫，配相生辅药可压低丹劫）';
			color = '#d7b174';
		} else {
			label = '六脉调和 · 鼎火安稳无虞';
			color = '#bd9d71';
		}

		return {
			genPairs: genPairs,
			clashPairs: clashPairs,
			potencyBonus: genPairs,
			harmonyDelta: genPairs * 10 - clashPairs * 8,
			reverseReady: reverseReady,
			tribulationPct: tribPct,
			label: label,
			color: color
		};
	}

	function wxMatchFreeFormulaRule(_jun, _auxNatures, _totalPot, _costMult) {
		var rules = null;
		if (wxAlcState.data && wxAlcState.data.freeRules && wxAlcState.data.freeRules.length) {
			rules = wxAlcState.data.freeRules;
		} else if (wxAlcState.data && wxAlcState.data.formulas && wxAlcState.data.formulas.length) {
			rules = wxAlcState.data.formulas;
		}
		if (!rules || !_jun || !_auxNatures || _auxNatures.length < 1) return null;

		var bestF = null;
		var bestScore = -1;
		for (var i = 0; i < rules.length; i++) {
			var f = rules[i];
			if (f.isHiddenMutation) continue;
			if (!wxClientDoesJunMatch(_jun, f)) continue;
			if (_auxNatures.length < (f.minAuxCount || 1) || _totalPot < (f.targetPotency || 1)) continue;

			var isUndisc = (f.discovered === false);
			var coreBonus = (f.requiredCoreKey && f.requiredCoreKey === _jun.key) ? 50000 : 0;
			var score = (isUndisc ? 100000 : 0) + coreBonus + (f.targetPotency || 0) * 200 + (f.minJunPotency || 0) * 40 + (f.requireRareJun ? 25 : 0);
			var jn = f.junNatures || [];
			if (jn.length > 0 && jn[0] === _jun.nature) score += 30;
			var pref = f.preferredAuxNatures || [];
			for (var ai = 0; ai < _auxNatures.length; ai++) {
				var an = _auxNatures[ai];
				for (var pi = 0; pi < pref.length; pi++) {
					if (an === pref[pi]) { score += 45; break; }
				}
				for (var ji = 0; ji < jn.length; ji++) {
					if (an === jn[ji]) { score += 12; break; }
				}
			}
			if (score > bestScore) {
				bestScore = score;
				bestF = f;
			}
		}
		if (!bestF) return null;
		var fCost = (typeof bestF.silverCost === 'number')
			? bestF.silverCost
			: Math.max(50, Math.floor((bestF.SilverCost || 80) * _costMult));
		return { rule: bestF, silverCost: fCost };
	}

	function wxComputeFreePreview() {
		var ingMap = wxGetIngMap();
		var sk = wxAlcState.slotKeys;
		var fSpec = wxGetFireSpec(wxAlcState.fireMode);
		var costMult = (wxAlcState.data && typeof wxAlcState.data.costMult === 'number') ? wxAlcState.data.costMult : 1.0;
		var money = (wxAlcState.data && typeof wxAlcState.data.money === 'number') ? wxAlcState.data.money : 0;

		if (!sk[0] || !(sk[0] in ingMap)) {
			return {
				ok: false,
				reason: '请先在左侧【君药主引】鼎位投入 1 味奇草、大妖内丹或异兽奇材为主药。',
				curPot: 0,
				auxCnt: 0,
				fireSpec: fSpec,
				silverCost: Math.max(60, Math.floor(145 * costMult * fSpec.costMult))
			};
		}
		var jun = ingMap[sk[0]];
		var used = {};
		used[sk[0]] = 1;
		var auxCnt = 0;
		var auxNatures = [];
		var auxObjs = [];
		var totalPot = jun.potency;
		var bestAuxNat = '';
		var bestAuxPot = -1;

		for (var s = 1; s <= 2; s++) {
			var k = sk[s];
			if (!k) continue;
			if (!(k in ingMap)) {
				return { ok: false, reason: '所选辅药存量不足。', curPot: totalPot, auxCnt: auxCnt, fireSpec: fSpec, silverCost: 120 };
			}
			used[k] = (used[k] || 0) + 1;
			if (used[k] > ingMap[k].totalCount) {
				return { ok: false, reason: '「' + ingMap[k].name + '」持有数量不足以同炉重复投入。', curPot: totalPot, auxCnt: auxCnt, fireSpec: fSpec, silverCost: 120 };
			}
			var ax = ingMap[k];
			auxCnt++;
			auxObjs.push(ax);
			auxNatures.push(ax.nature || '');
			totalPot += ax.potency;
			if (ax.potency > bestAuxPot) {
				bestAuxPot = ax.potency;
				bestAuxNat = ax.nature || '';
			}
		}
		if (used[sk[0]] > jun.totalCount) {
			return { ok: false, reason: '「' + jun.name + '」存量不足。', curPot: totalPot, auxCnt: auxCnt, fireSpec: fSpec, silverCost: 120 };
		}
		var syn = wxEvalClientMeridian(jun, auxObjs, wxAlcState.fireMode);
		var effPot = totalPot + syn.potencyBonus;
		var matchedRule = (auxCnt >= 1) ? wxMatchFreeFormulaRule(jun, auxNatures, effPot, costMult) : null;
		var rawCost = (syn.reverseReady && wxAlcState.fireMode === 'fierce')
			? Math.floor(620 * costMult)
			: (matchedRule ? matchedRule.silverCost : Math.max(80, Math.floor((90 + effPot * 28) * costMult)));
		var estCost = Math.max(50, Math.floor(rawCost * fSpec.costMult));
		if (auxCnt < 1) {
			return {
				ok: false,
				reason: '已择君药「' + jun.name + '」(' + jun.natureShort + '·力' + jun.potency + ')，请至少再投入 1 味【臣佐辅药】调和鼎火。',
				curPot: effPot,
				auxCnt: 0,
				syn: syn,
				fireSpec: fSpec,
				silverCost: estCost
			};
		}

		var auxTitle = '';
		var auxColor = '#bd9d71';
		var auxMap = (wxAlcState.data && wxAlcState.data.auxInfusions) ? wxAlcState.data.auxInfusions : null;
		if (bestAuxNat && auxMap && (bestAuxNat in auxMap)) {
			auxTitle = auxMap[bestAuxNat].title || '';
			auxColor = auxMap[bestAuxNat].color || '#dda21f';
		}

		if (money < estCost) {
			return {
				ok: false,
				reason: '炉火炭资纹银不足（预估需 ' + estCost + ' 两，现存 ' + money + ' 两）。',
				curPot: effPot,
				auxCnt: auxCnt,
				syn: syn,
				fireSpec: fSpec,
				silverCost: estCost,
				junName: jun.name,
				junNat: jun.natureName,
				junColor: jun.natureColor,
				auxTitle: auxTitle,
				auxColor: auxColor
			};
		}
		var coreImpFree = wxResolveCoreImprint(jun, 'buff_');
		return {
			ok: true,
			reason: '',
			curPot: effPot,
			auxCnt: auxCnt,
			syn: syn,
			fireSpec: fSpec,
			silverCost: estCost,
			junName: jun.name,
			junNat: jun.natureName,
			junColor: jun.natureColor,
			auxTitle: auxTitle,
			auxColor: auxColor,
			coreImp: coreImpFree
		};
	}

	function wxShowAlcBanner(_msg, _isErr) {
		if (!_msg) return;
		if (window.WX_Showcase && window.WX_Showcase.plaque) {
			var tabIco = (wxAlcState.mode === 'reforge')
				? 'ui/wx_icons/wx_asset_supplies.png'
				: ((wxAlcState.mode === 'cabinet') ? 'ui/wx_icons/wx_glyph_herb_cabinet.png' : 'ui/wx_icons/wx_glyph_cauldron.png');
			var tabTitle = _isErr
				? '百工丹坊 · 提示'
				: ((wxAlcState.mode === 'reforge') ? '神兵重锻' : ((wxAlcState.mode === 'cabinet') ? '百草药柜' : '八卦丹炉'));
			window.WX_Showcase.plaque({
				title: tabTitle,
				message: _msg,
				icon: tabIco,
				isError: !!_isErr,
				theme: _isErr ? 'err' : 'gold'
			});
			return;
		}
		var el = $('.wx-alc-backdrop .wx-alc-banner');
		if (!el.length) return;
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

	function wxSyncHostFromAlchemyResponse(_res, _deferTaxRefresh) {
		if (!_res || typeof _res !== 'object') return;
		if (typeof _res.money === 'number') {
			$('.world-town-screen .asset-container.is-money .label, .world-screen .asset-container.is-money .label').text(wxFormatMoneyStr(_res.money));
		}
		if (wxAlcState.taxMod && wxAlcState.taxMod.mSQHandle && typeof wxAlcState.taxMod.loadFromData === 'function') {
			// Defer refreshing the hidden Taxidermist blueprint list until the Alchemy modal closes
			// so brewing/reforging never stalls on a 400-node background DOM rebuild!
			wxAlcState.taxNeedsRefresh = true;
			if (!_deferTaxRefresh) {
				wxFlushDeferredTaxRefresh();
			}
		}
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

	function wxFlushDeferredTaxRefresh() {
		if (!wxAlcState.taxNeedsRefresh) return;
		wxAlcState.taxNeedsRefresh = false;
		if (wxAlcState.taxMod && wxAlcState.taxMod.mSQHandle && typeof wxAlcState.taxMod.loadFromData === 'function') {
			var tm = wxAlcState.taxMod;
			SQ.call(tm.mSQHandle, 'queryBlueprints', null, function (_bpData) {
				if (_bpData && tm && tm.mDialogContainer) {
					delete _bpData.wxCraftBanner;
					delete _bpData.wxCraftShowcase;
					tm.loadFromData(_bpData);
				}
			});
		}
	}

	function wxCloseAlchemyModal() {
		wxAlcState.busy = false;
		var existing = $('.wx-alc-backdrop');
		if (existing.length) {
			existing.remove();
			$(document).off('keydown.wxAlcModal');
			if (wxAlcState.hostDS && wxAlcState.hostDS.notifyBackendPopupDialogIsVisible) {
				wxAlcState.hostDS.notifyBackendPopupDialogIsVisible(false);
			}
			wxFlushDeferredTaxRefresh();
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
		if (_f.requiredCoreKey && _f.requiredCoreKey !== '' && _ing.key !== _f.requiredCoreKey) return false;
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
		var fSpec = wxGetFireSpec(wxAlcState.fireMode);
		if (!_f) return { ok: false, reason: '未选择丹方。', curPot: 0, reqPot: 1, doubleChance: 0, fireSpec: fSpec };
		var effCost = Math.max(50, Math.floor((_f.silverCost || 80) * fSpec.costMult));
		if (!sk[0] || !(sk[0] in ingMap)) {
			return {
				ok: false,
				reason: '请先在左侧【君药主引】鼎位放入符合药性的奇草/内丹/药材（或点击「智能抓药」）。',
				curPot: 0,
				reqPot: _f.targetPotency,
				silverCost: effCost,
				fireSpec: fSpec,
				doubleChance: 0
			};
		}
		var jun = ingMap[sk[0]];
		if (!wxClientDoesJunMatch(jun, _f)) {
			var coreReqTxt = (_f.requiredCoreKey && _f.requiredCoreKey !== '') ? '，且限本命大妖内丹为主引' : (_f.requireRareJun ? '，限奇草/内丹/神木灵心' : '');
			return {
				ok: false,
				reason: '「' + jun.name + '」不符合本方君药要求（需 ' + _f.junNatureText + ' 药性且药力≥' + _f.minJunPotency + coreReqTxt + '）。',
				curPot: jun.potency,
				reqPot: _f.targetPotency,
				silverCost: effCost,
				fireSpec: fSpec,
				doubleChance: 0
			};
		}

		var used = {};
		used[sk[0]] = 1;
		var auxCnt = 0;
		var auxObjs = [];
		var totalPot = jun.potency;
		var harmony = 0;
		var bestAuxNat = '';
		var bestAuxPot = -1;
		for (var s = 1; s <= 2; s++) {
			var k = sk[s];
			if (!k) continue;
			if (!(k in ingMap)) {
				return { ok: false, reason: '所选辅药存量不足。', curPot: totalPot, reqPot: _f.targetPotency, silverCost: effCost, fireSpec: fSpec, doubleChance: 0 };
			}
			used[k] = (used[k] || 0) + 1;
			if (used[k] > ingMap[k].totalCount) {
				return { ok: false, reason: '「' + ingMap[k].name + '」持有数量不足以同炉重复置入。', curPot: totalPot, reqPot: _f.targetPotency, silverCost: effCost, fireSpec: fSpec, doubleChance: 0 };
			}
			var ax = ingMap[k];
			auxCnt++;
			auxObjs.push(ax);
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

		var syn = wxEvalClientMeridian(jun, auxObjs, wxAlcState.fireMode);
		var effPot = totalPot + syn.potencyBonus;
		harmony += syn.harmonyDelta;

		if (auxCnt < _f.minAuxCount) {
			return {
				ok: false,
				reason: '至少需放入 ' + _f.minAuxCount + ' 味【臣佐辅药】调和鼎火（当前已放 ' + auxCnt + ' 味）。',
				curPot: effPot,
				reqPot: _f.targetPotency,
				syn: syn,
				fireSpec: fSpec,
				silverCost: effCost,
				doubleChance: 0
			};
		}
		if (effPot < _f.targetPotency) {
			return {
				ok: false,
				reason: '鼎内总药力不足（当前 ' + effPot + ' / 需达 ' + _f.targetPotency + '），请补入第 2 味相生佐药或换高阶奇草/内丹。',
				curPot: effPot,
				reqPot: _f.targetPotency,
				syn: syn,
				fireSpec: fSpec,
				silverCost: effCost,
				doubleChance: 0
			};
		}
		var mstBonus = (wxAlcState.data && wxAlcState.data.mastery) ? (wxAlcState.data.mastery.bonusDoublePct || 0) : 0;
		var sur = effPot > _f.targetPotency ? (effPot - _f.targetPotency) : 0;
		var dbl = 12 + sur * 10 + harmony + mstBonus + (fSpec.doubleBonus || 0);
		if (dbl < 5) dbl = 5;
		if (dbl > 88) dbl = 88;

		var g3 = 8 + sur * 4 + Math.floor((harmony + mstBonus) * 0.40) + (fSpec.grade3Bonus || 0);
		if (g3 < 2) g3 = 2;
		if (g3 > 58) g3 = 58;
		var g2 = 30 + sur * 5 + Math.floor((harmony + mstBonus) * 0.35) + (fSpec.grade2Bonus || 0);
		if (g2 < 10) g2 = 10;
		if (g2 > 56) g2 = 56;
		if (g2 + g3 > 92) g2 = 92 - g3;
		var g1 = 100 - g2 - g3;
		if (g1 < 8) g1 = 8;

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
		if (money < effCost) {
			return {
				ok: false,
				reason: '炉火纹银不足（需 ' + effCost + ' 两，现存 ' + money + ' 两）。',
				curPot: effPot,
				reqPot: _f.targetPotency,
				syn: syn,
				fireSpec: fSpec,
				silverCost: effCost,
				doubleChance: dbl,
				gradeChances: [g1, g2, g3],
				auxTitle: auxTitle,
				auxColor: auxColor,
				auxDesc: auxDesc
			};
		}
		var coreImpObj = wxResolveCoreImprint(jun, _f.pillKind || 'buff_');
		return {
			ok: true,
			reason: '',
			curPot: effPot,
			reqPot: _f.targetPotency,
			syn: syn,
			fireSpec: fSpec,
			silverCost: effCost,
			doubleChance: dbl,
			gradeChances: [g1, g2, g3],
			auxTitle: auxTitle,
			auxColor: auxColor,
			auxDesc: auxDesc,
			coreImp: coreImpObj
		};
	}

	function wxIsFormulaReady(_formula, _inWorkshop) {
		return _inWorkshop ? _formula.canAutoBrew : _formula.hasAutoIngredients;
	}

	function wxRenderMetaAndTabs(_dlg) {
		var d = wxAlcState.data;
		if (!d) return;
		var inWs = wxIsWorkshopMode();
		var sum = d.summary || { cabinetHerbs: 0, cabinetCores: 0, cabinetTrophies: 0, cabinetTotal: 0, stashMovable: 0 };
		var mst = d.mastery || { masterLabel: '随军自炼', bonusDoublePct: 0, hasDiscount: false };
		var fg  = d.forge || { smithLabel: '随军炉火', bonusHighPct: 0, hasDiscount: false, items: [], catalystTotal: 0, pity: 0 };
		var rfgItems = fg.items || [];

		var metaHtml =
			(inWs ? '<span style="color:#7ee29a;">【城镇百工丹坊 · 可开炉重锻】</span>　' : '<span style="color:#ffe28a;">【随身手札 · 开炉重锻与存取请赴城镇百工丹坊】</span>　') +
			'纹银：<strong>' + d.money + ' 两</strong>　│　' +
			'掌炉：<strong>' + wxEsc(mst.masterLabel) + '</strong> · 掌锤：<strong>' + wxEsc(fg.smithLabel) + '</strong>　│　' +
			'药柜寄存：奇草 <strong>' + sum.cabinetHerbs + '</strong> · 内丹 <strong>' + sum.cabinetCores + '</strong> · 奇材 <strong>' + sum.cabinetTrophies + '</strong>' +
			(inWs && sum.stashMovable > 0 ? ('（行囊可入柜 ' + sum.stashMovable + '）') : '') + '　│　' +
			'行囊：<strong>' + d.stashSpaceUsed + '/' + d.stashSpaceMax + '</strong>';
		_dlg.find('[data-alc="meta"]').html(metaHtml);

		var readyCnt = 0;
		var flist = d.formulas || [];
		var discCnt = (typeof d.discoveredFormulaCount === 'number') ? d.discoveredFormulaCount : flist.length;
		var totalFCnt = (typeof d.totalFormulaCount === 'number') ? d.totalFormulaCount : 50;
		for (var i = 0; i < flist.length; i++) {
			if (wxIsFormulaReady(flist[i], inWs)) readyCnt++;
		}

		var allIngs = d.ingredients || [];
		var tab1Label = inWs ? ('八卦丹炉（丹谱 ' + discCnt + '/' + totalFCnt + '）') : ('丹经手札（已悟 ' + discCnt + '/' + totalFCnt + '）');
		var tab2Label = inWs ? ('神兵重锻（兵甲 ' + rfgItems.length + '）') : ('百工器谱（神兵 ' + rfgItems.length + '）');
		var tab3Label = inWs ? ('百草药柜（柜藏 ' + sum.cabinetTotal + '）') : ('药柜账册（奇材 ' + allIngs.length + ' 种）');

		var modes = [
			['cauldron', 'wx_icons/wx_glyph_cauldron.png', tab1Label],
			['reforge', 'icons/asset_supplies.png', tab2Label],
			['cabinet', 'wx_icons/wx_glyph_herb_cabinet.png', tab3Label]
		];
		var topHtml = '';
		for (var m = 0; m < modes.length; m++) {
			var mode = modes[m], selected = wxAlcState.mode === mode[0];
			topHtml += '<button type="button" class="wx-alc-mode-btn' + (selected ? ' is-active' : '') +
				'" data-amode="' + mode[0] + '" aria-pressed="' + selected + '"><img src="coui://gfx/ui/' +
				mode[1] + '" alt=""/>' + mode[2] + '</button>';
		}

		if (inWs) topHtml = '<div class="wx-alc-station-tabs">' + topHtml + '</div><div class="wx-alc-station-filters">';
		if (wxAlcState.mode === 'cauldron') {
			var cflts = [
				['all', inWs ? '全部丹方' : '全部已悟'],
				['ready', (inWs ? '可开炉 (' : '药材齐备 (') + readyCnt + ')'],
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
				['stash', (inWs ? '行囊待淬 (' : '行囊收藏 (') + stCnt + ')'],
				['upgradeable', '未臻神工 (' + upgCnt + ')']
			];
			for (var rf = 0; rf < rflts.length; rf++) {
				var ritem = rflts[rf];
				topHtml += '<span class="wx-alc-subflt' + (wxAlcState.reforgeFilter === ritem[0] ? ' is-active' : '') + '" data-rflt="' + ritem[0] + '">' + ritem[1] + '</span>';
			}
		} else {
			var codexArr = d.herbCodex || [];
			var kflts = [
				['all', '全部药材'],
				['herb', '天下奇草'],
				['core', '山海内丹'],
				['trophy', '异兽奇材'],
				['codex', '《山海本草》全谱 (' + codexArr.length + ')']
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
		topBar.html(inWs ? topHtml + '</div>' : topHtml);

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

	function wxRenderReadOnlyFormulaInspector(_wb, _f) {
		var d = wxAlcState.data || {};
		var discCnt = (typeof d.discoveredFormulaCount === 'number') ? d.discoveredFormulaCount : 0;
		var totalFCnt = (typeof d.totalFormulaCount === 'number') ? d.totalFormulaCount : 50;

		var auxRowsHtml = '';
		var nats = d.natures || [];
		var auxMap = d.auxInfusions || {};
		for (var i = 0; i < nats.length; i++) {
			var nd = nats[i];
			var ax = auxMap[nd.id];
			if (!ax) continue;
			var desc = ax.prepDesc || ax.infuseDesc || ax.healDesc || '';
			if (_f && _f.pillKind) {
				if (_f.pillKind === 'infuse_exp') desc = ax.infuseDesc || desc;
				else if (_f.pillKind.indexOf('heal_') === 0 && _f.pillKind !== 'heal_internal_plus') desc = ax.healDesc || desc;
			}
			auxRowsHtml +=
				'<div style="padding:0.24rem 0;border-bottom:1px solid rgba(90,67,37,0.32);font-size:1.22rem;">' +
					'<span style="color:' + (ax.color || nd.color) + ';display:inline-block;width:9.2rem;">【' + wxEsc(ax.title || nd.name) + '】</span>' +
					'<span style="color:#d7b174;">' + wxEsc(desc) + '</span>' +
				'</div>';
		}

		if (!_f) {
			_wb.html(
				'<div style="padding:2.2rem 1.4rem;color:#d7b174;line-height:2.05rem;">' +
					'<div style="font-size:1.75rem;color:#dda21f;margin-bottom:0.6rem;">《丹经手札》 · 随身丹谱（已悟 ' + discCnt + ' / ' + totalFCnt + ' 方）</div>' +
					'<div style="color:#bd9d71;margin-bottom:1.0rem;">行军途中无地火青铜丹鼎，此处仅可翻阅已参悟收录之古丹方、六脉药性法度与百草药柜账册。</div>' +
					'<div class="wx-alc-wb-req" style="margin-bottom:1.1rem;">' +
						'<div><strong>实地开炉指引：</strong></div>' +
						'<div>1. 亲赴任意州县城镇<strong>【百工丹坊】</strong>，点击上方<strong>【八卦丹炉】</strong>即可自由投入君臣药材「盲炉试丹」（首次炼成名丹即永久载入本手札），或按已悟丹方批量开炉。</div>' +
						'<div>2. 亦可步入城镇<strong>【迎客酒肆】</strong>向酒保打探，或登临各派<strong>【独立山门 · 丹房】</strong>求教失传丹诀。</div>' +
					'</div>' +
					(auxRowsHtml ? ('<div style="font-size:1.35rem;color:#dda21f;margin-bottom:0.35rem;">六脉臣佐药引 · 丹韵纪要</div><div style="padding:0.5rem 0.75rem;background:rgba(12,8,5,0.55);border:1px solid rgba(90,67,37,0.55);">' + auxRowsHtml + '</div>') : '') +
				'</div>'
			);
			return;
		}

		var yieldStr = _f.baseYield > 1 ? (' · 每炉成丹 ' + _f.baseYield + ' 枚') : '';
		var rareReqStr = _f.requireRareJun ? '限天下奇草 / 山海大妖内丹 / 万年灵心' : '任意匹配药性之奇草 / 内丹 / 异兽材';
		var stockBadge = _f.canAutoBrew
			? '<span style="color:#7ee29a;">药柜与行囊现存药材及炉资齐备（可赴百工丹坊开炉）</span>'
			: '<span style="color:#bd9d71;">' + (_f.hasAutoIngredients ? '药材齐备，炉资不足' : '当前药材不足') + '</span>';

		var html =
			'<div class="wx-alc-wb-hdr">' +
				'<img class="wx-alc-wb-hdr-icon" src="coui://gfx/' + _f.icon + '" alt=""/>' +
				'<div class="wx-alc-wb-title">' + wxEsc(_f.name) + ' <span style="font-size:1.3rem;color:#bd9d71;">[' + wxEsc(_f.qualityLabel) + ' · ' + wxEsc(_f.subLabel) + yieldStr + ']</span></div>' +
				'<div class="wx-alc-wb-desc">' + wxEsc(_f.description) + '</div>' +
			'</div>' +
			'<div class="wx-alc-wb-req" style="margin-bottom:0.75rem;">' +
				'<div><strong>丹诀要旨：</strong>' + wxEsc(_f.formulaNote) + '</div>' +
				'<div><strong>配伍法度：</strong>君药须属【' + wxEsc(_f.junNatureText) + '】（药力 ≥ ' + _f.minJunPotency + '，' + rareReqStr + '） + 至少 ' + _f.minAuxCount + ' 味臣佐辅药，鼎内总药力 ≥ ' + _f.targetPotency + '。</div>' +
				'<div><strong>百工炉资：</strong>' + _f.silverCost + ' 两纹银　│　<strong>行囊现存成丹：</strong>' + (_f.ownedCount || 0) + ' 枚</div>' +
				'<div><strong>备料核验：</strong>' + stockBadge + '</div>' +
			'</div>' +
			'<div class="wx-alc-preview-bar" style="margin-bottom:0.75rem;">' +
				'<div class="wx-alc-pv-line"><strong>三阶丹品法度：</strong>成丹（基准药效） · <span style="color:#5ec47a;">灵纹上品（药效 112%~128%）</span> · <span style="color:#f0bc42;">丹霞极品（药效 132%~155%，免除第 3 丹丹毒郁结与疯魔燃血战后反噬）</span></div>' +
			'</div>' +
			(auxRowsHtml ? ('<div style="font-size:1.32rem;color:#dda21f;margin-bottom:0.35rem;">本方臣佐辅药 · 丹韵变化参考</div><div style="padding:0.45rem 0.75rem;margin-bottom:0.8rem;background:rgba(12,8,5,0.55);border:1px solid rgba(90,67,37,0.55);">' + auxRowsHtml + '</div>') : '') +
			'<div class="wx-alc-ro-notice">随身《丹经手札》仅供翻阅 —— 欲开炉炼制此丹或盲投试丹参悟新方，请亲赴州县城镇<strong>【百工丹坊】</strong>。</div>';

		_wb.html(html);
	}

	function wxRenderCauldronView(_body, _dlg) {
		var d = wxAlcState.data;
		var inWs = wxIsWorkshopMode();
		var formulas = d.formulas || [];
		var discCnt = (typeof d.discoveredFormulaCount === 'number') ? d.discoveredFormulaCount : formulas.length;
		var totalFCnt = (typeof d.totalFormulaCount === 'number') ? d.totalFormulaCount : 50;
		var filtered = [];
		var isFreeMode = inWs && (!wxAlcState.selectedFormulaId || wxAlcState.selectedFormulaId === 'free');
		var selObj = null;

		for (var i = 0; i < formulas.length; i++) {
			var f = formulas[i];
			if (wxAlcState.formulaFilter === 'ready' && !wxIsFormulaReady(f, inWs)) continue;
			if (wxAlcState.formulaFilter !== 'all' && wxAlcState.formulaFilter !== 'ready' && f.category !== wxAlcState.formulaFilter) continue;
			filtered.push(f);
			if (!isFreeMode && f.id === wxAlcState.selectedFormulaId) selObj = f;
		}
		if (!inWs) {
			if (!selObj && filtered.length > 0) {
				selObj = filtered[0];
				wxAlcState.selectedFormulaId = selObj.id;
			}
		} else if (!isFreeMode && !selObj) {
			selObj = wxFindFormulaObj(wxAlcState.selectedFormulaId);
			if (!selObj) {
				isFreeMode = true;
				wxAlcState.selectedFormulaId = 'free';
			}
		}

		var leftHtml = '';
		if (inWs) {
			leftHtml +=
				'<div class="wx-alc-frow' + (isFreeMode ? ' is-selected' : '') + '" data-fid="free" style="border-color:#d49b2a;">' +
					'<img class="wx-alc-frow-icon" src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" alt=""/>' +
					'<div class="wx-alc-frow-top">' +
						'<span class="wx-alc-frow-name" style="color:#ffe28a;">✦ 自由投药 · 盲炉试丹</span>' +
						'<span class="wx-alc-frow-badge is-ready">参悟丹方</span>' +
						'<div class="clear-both"></div>' +
					'</div>' +
					'<div class="wx-alc-frow-sub">凭六大药性与药力自由投炉推演 · 炼成名丹即永久载入《丹经手札》</div>' +
				'</div>';
		}
		leftHtml +=
			'<div style="padding:0.45rem 0.7rem 0.25rem;font-size:1.22rem;color:#dda21f;border-bottom:1px solid rgba(212,155,42,0.25);">' +
				'《丹经手札》已录丹方（' + discCnt + ' / ' + totalFCnt + '）' +
			'</div>';

		if (filtered.length === 0) {
			leftHtml += '<div style="padding:2.2rem 1rem;color:#bd9d71;text-align:center;font-style:italic;line-height:1.9rem;">' +
				(discCnt === 0
					? (inWs
						? '《丹经手札》尚是一卷素帛。<br/>请在右侧自由投入【1 味君药 + 1~2 味辅药】开炉试丹，或赴城池酒肆、宗门山门寻访失传丹诀！'
						: '《丹经手札》尚是一卷素帛。<br/>请前往州县城镇【百工丹坊】自由投药盲炉试丹，或赴迎客酒肆、宗门丹房寻访失传古方！')
					: '当前分类筛选下暂无已收录丹方。') +
				'</div>';
		} else {
			for (var j = 0; j < filtered.length; j++) {
				var fj = filtered[j];
				var isSel = (!isFreeMode && selObj && fj.id === selObj.id);
				var badge = fj.canAutoBrew
					? ('<span class="wx-alc-frow-badge is-ready">' + (inWs ? '可按方炼' : '药材齐备') + '</span>')
					: '<span class="wx-alc-frow-badge is-short">' + (fj.hasAutoIngredients ? (inWs ? '缺炉资' : '药材齐备 · 缺炉资') : '缺药引') + '</span>';
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
		if (discCnt < totalFCnt) {
			leftHtml += '<div style="padding:0.8rem 0.8rem;color:#9e845c;font-size:1.18rem;text-align:center;font-style:italic;">尚有 ' + (totalFCnt - discCnt) + ' 道失传古丹方待赴百工丹坊试炼或江湖寻访参悟</div>';
		}

		_body.html(
			'<div class="wx-alc-left-col" data-alc="f-list">' + leftHtml + '</div>' +
			'<div class="wx-alc-right-col" data-alc="wb"></div>'
		);

		_body.find('[data-fid]').on('click', function () {
			var fid = $(this).attr('data-fid');
			if (fid === 'free' && inWs) {
				wxAlcState.selectedFormulaId = 'free';
				wxAlcState.slotKeys = ['', '', ''];
				wxAlcState.activeSlotIdx = 0;
				wxRenderCauldronView(_body, _dlg);
				return;
			}
			var found = wxFindFormulaObj(fid);
			if (found) {
				if (inWs) {
					wxSelectFormulaAndAutoFill(found);
				} else {
					wxAlcState.selectedFormulaId = found.id;
				}
				wxRenderCauldronView(_body, _dlg);
			}
		});

		if (!inWs) {
			wxRenderReadOnlyFormulaInspector(_body.find('[data-alc="wb"]'), selObj);
		} else {
			wxRenderWorkbench(_body.find('[data-alc="wb"]'), isFreeMode ? null : selObj, _dlg);
		}
	}

	function wxBuildSlotCardHtml(_slotIdx, _posCls, _roleTitle, _ingMap, _f) {
		var key = wxAlcState.slotKeys[_slotIdx] || '';
		var ing = key ? _ingMap[key] : null;
		var isAct = (wxAlcState.activeSlotIdx === _slotIdx);
		var isJun = (_slotIdx === 0);

		if (!ing) {
			var hint = '';
			if (!_f) {
				hint = isJun
					? '点击择入君药<br/>（定本炉主药性与品阶）'
					: (_slotIdx === 1 ? '点击择入臣药辅火<br/>（至少配 1 味辅药）' : '可选佐使调和<br/>（提升总药力冲高阶丹方）');
			} else {
				hint = isJun
					? ('点击择入君药<br/>（' + wxEsc(_f.junNatureText) + ' · 药力≥' + _f.minJunPotency + '）')
					: (_slotIdx === 1 ? '点击择入臣药辅火' : (_f.minAuxCount >= 2 ? '点击择入第2味佐药（必配）' : '可选佐使（冲高双丹率）'));
			}
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
		var isFree = !_f;
		var ingMap = wxGetIngMap();
		var pv = isFree ? wxComputeFreePreview() : wxComputeClientPreview(_f);

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
			if (!isFree && actIdx === 0 && !wxClientDoesJunMatch(ing, _f)) continue;

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
				(isFree
					? '当前百草药柜与行囊中暂无可用奇草、大妖内丹或异兽奇材。可通过讨伐山泽异兽、探索秘境或奇遇采药获取！'
					: (actIdx === 0
						? ('当前药柜与行囊中暂无符合本方君药要求（' + wxEsc(_f.junNatureText) + ' · 药力≥' + _f.minJunPotency + '）的药材。')
						: '当前药柜与行囊中暂无空闲辅材可添入此鼎位。')) +
				'</div>';
		} else {
			chipsHtml += '<div class="clear-both"></div>';
		}

		var pvHtml = '';
		var hdrHtml = '';
		var reqHtml = '';
		var actBtnsHtml = '';
		var slotLabelNames = ['【君药主引】', '【臣药辅火】', '【佐使调和】'];

		var fModes = (wxAlcState.data && wxAlcState.data.fireModes && wxAlcState.data.fireModes.length)
			? wxAlcState.data.fireModes
			: [wxGetFireSpec('gentle'), wxGetFireSpec('balanced'), wxGetFireSpec('fierce')];
		var activeFire = wxGetFireSpec(wxAlcState.fireMode);
		var fireBarHtml = '<div class="wx-alc-fire-bar"><strong style="color:#dda21f;margin-right:0.4rem;">文武控火：</strong>';
		for (var fi = 0; fi < fModes.length; fi++) {
			var fm = fModes[fi];
			var fAct = (fm.id === activeFire.id);
			fireBarHtml += '<span class="wx-alc-fire-btn' + (fAct ? ' is-active' : '') + '" data-fmode="' + wxEsc(fm.id) + '" style="color:' + (fAct ? fm.color : '#bd9d71') + ';">' + wxEsc(fm.title) + '</span>';
		}
		fireBarHtml += '<span style="font-size:1.16rem;color:' + activeFire.color + ';margin-left:0.25rem;">' + wxEsc(activeFire.desc) + '</span></div>';

		var synLineHtml = (pv.syn && pv.syn.label)
			? ('<div class="wx-alc-pv-line" style="color:' + pv.syn.color + ';">' + wxEsc(pv.syn.label) + '</div>')
			: '';

		if (isFree) {
			if (pv.ok) {
				pvHtml =
					'<div class="wx-alc-pv-line" style="color:#7ee29a;">鼎内药气已聚：君药 <strong style="color:' + pv.junColor + ';">' + wxEsc(pv.junName) + '（' + wxEsc(pv.junNat) + '）</strong> + 辅药 <strong>' + pv.auxCnt + ' 味</strong>　│　鼎内总药力：<strong>' + pv.curPot + '</strong>　│　试炉炭资：<strong>≤' + pv.silverCost + ' 两</strong></div>' +
					synLineHtml +
					'<div class="wx-alc-pv-line" style="color:#d7b174;">丹象未卜：若配伍契合失传古方或逆命丹象，成丹瞬间将自动铭刻入左侧《丹经手札》！' +
						(pv.auxTitle ? ('（当前辅药丹韵：<span style="color:' + pv.auxColor + ';">【' + wxEsc(pv.auxTitle) + '】</span>）') : '') +
						(pv.coreImp ? ('（本命妖丹：<span style="color:' + pv.coreImp.color + ';">【' + wxEsc(pv.coreImp.title) + '】</span>）') : '') +
					'</div>';
			} else {
				pvHtml = '<div style="color:#ff9482;">鼎内总药力：' + pv.curPot + ' —— ' + wxEsc(pv.reason) + '</div>' + synLineHtml;
			}

			hdrHtml =
				'<div class="wx-alc-wb-hdr">' +
					'<img class="wx-alc-wb-hdr-icon" src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" alt=""/>' +
					'<div class="wx-alc-wb-title">八卦丹炉 · 盲投试丹参悟 <span style="font-size:1.3rem;color:#ffe28a;">[文武控火 · 六脉生克 · 逆命录方]</span></div>' +
					'<div class="wx-alc-wb-desc">丹道无现成死方：观百草内丹之【生机 / 赤阳 / 玄阴 / 镇魂 / 奇毒 / 造化】六脉生克，自由择君臣药引并控文武炉火试炼！</div>' +
				'</div>';
			reqHtml =
				'<div class="wx-alc-wb-req">' +
					'<div><strong>六脉秘传：</strong>造化→生机→赤阳→镇魂→玄阴→奇毒循环相生（每对相生药力+1）；大妖内丹配齐【赤阳+玄阴】催动【武火催霞】可逆炼失传奇药《两仪逆命混元丹》！</div>' +
				'</div>';
			actBtnsHtml =
				'<span class="wx-alc-act-btn" data-wbact="clearall"><img src="coui://gfx/ui/wx_icons/wx_glyph_scale_mortar.png" style="width:1.9rem;height:1.9rem;vertical-align:middle;margin:-0.25rem 0.3rem 0 0;" alt=""/>清空鼎炉</span>' +
				'<span class="wx-alc-act-btn' + (pv.ok ? '' : ' is-disabled') + '" data-wbact="brew"><img src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" style="width:1.9rem;height:1.9rem;vertical-align:middle;margin:-0.25rem 0.3rem 0 0;" alt=""/>凝火试丹</span>';
		} else {
			var yieldStr = _f.baseYield > 1 ? ('（每炉成丹 ' + _f.baseYield + ' 枚）') : '';
			var rareReqStr = (_f.requiredCoreKey && _f.requiredCoreKey !== '')
				? '限本命山海大妖内丹为主引'
				: (_f.requireRareJun ? '奇草 / 大妖内丹 / 万年灵心' : '任意匹配奇草 / 内丹 / 异兽材');
			var showCost = pv.silverCost || _f.silverCost;
			if (pv.ok) {
				var gc = pv.gradeChances || [60, 30, 10];
				pvHtml =
					'<div class="wx-alc-pv-line" style="color:#7ee29a;">鼎火纯青：总药力 <strong>' + pv.curPot + ' / ' + pv.reqPot + '</strong>　│　炉资：<strong>' + showCost + ' 两</strong>　│　紫气双丹率：<strong style="color:#f0bc42;">' + pv.doubleChance + '%</strong></div>' +
					'<div class="wx-alc-pv-line">成丹品阶：成丹 <strong>' + gc[0] + '%</strong> · <span style="color:#5ec47a;">灵纹 <strong>' + gc[1] + '%</strong> (药效112%~128%)</span> · <span style="color:#f0bc42;">丹霞极品 <strong>' + gc[2] + '%</strong> (132%~155% · 免第3丹丹毒/疯魔反噬)</span></div>' +
					synLineHtml;
				if (pv.auxTitle && pv.auxDesc) {
					pvHtml +=
						'<div class="wx-alc-pv-aux"><span style="color:' + pv.auxColor + ';">【' + wxEsc(pv.auxTitle) + '】</span>' + wxEsc(pv.auxDesc) + ' <span style="color:#a98e67;">（更换右上/右下臣佐辅药药性即可定制成丹附带奇效！）</span></div>';
				}
				if (pv.coreImp && pv.coreImp.title) {
					pvHtml +=
						'<div class="wx-alc-pv-aux"><span style="color:' + pv.coreImp.color + ';">【本命丹韵 · ' + wxEsc(pv.coreImp.title) + '】</span>' + wxEsc(pv.coreImp.desc) + '</div>';
				}
			} else {
				pvHtml = '<div style="color:#ff9482;">鼎内状态：总药力 ' + pv.curPot + ' / ' + pv.reqPot + ' —— ' + wxEsc(pv.reason) + '</div>' + synLineHtml;
			}

			hdrHtml =
				'<div class="wx-alc-wb-hdr">' +
					'<img class="wx-alc-wb-hdr-icon" src="coui://gfx/' + _f.icon + '" alt=""/>' +
					'<div class="wx-alc-wb-title">' + wxEsc(_f.name) + ' <span style="font-size:1.3rem;color:#bd9d71;">[' + wxEsc(_f.qualityLabel) + ' · ' + wxEsc(_f.subLabel) + ']' + yieldStr + '</span></div>' +
					'<div class="wx-alc-wb-desc">' + wxEsc(_f.description) + '</div>' +
				'</div>';
			reqHtml =
				'<div class="wx-alc-wb-req">' +
					'<div><strong>丹诀要旨：</strong>' + wxEsc(_f.formulaNote) + '</div>' +
					'<div><strong>配伍法度：</strong>君药须属【' + wxEsc(_f.junNatureText) + '】（药力≥' + _f.minJunPotency + '，' + rareReqStr + '）+ 至少 ' + _f.minAuxCount + ' 味辅药，总药力 ≥ ' + _f.targetPotency + '。</div>' +
				'</div>';
			actBtnsHtml =
				'<span class="wx-alc-act-btn" data-wbact="autofill"><img src="coui://gfx/ui/wx_icons/wx_glyph_scale_mortar.png" style="width:1.9rem;height:1.9rem;vertical-align:middle;margin:-0.25rem 0.3rem 0 0;" alt=""/>按方抓药</span>' +
				'<span class="wx-alc-act-btn' + (pv.ok ? '' : ' is-disabled') + '" data-wbact="brew"><img src="coui://gfx/ui/wx_icons/wx_glyph_cauldron.png" style="width:1.9rem;height:1.9rem;vertical-align:middle;margin:-0.25rem 0.3rem 0 0;" alt=""/>起火开炉（' + showCost + '两）</span>';
		}

		var html =
			hdrHtml +
			reqHtml +
			'<div class="wx-alc-tripod-stage">' +
				wxBuildSlotCardHtml(0, 'pos-jun', '【君药主引】', ingMap, _f) +
				'<img class="wx-alc-furnace-art" src="coui://gfx/ui/wx_icons/wx_cauldron_furnace.png" alt=""/>' +
				wxBuildSlotCardHtml(1, 'pos-aux1', '【臣药辅火】', ingMap, _f) +
				wxBuildSlotCardHtml(2, 'pos-aux2', '【佐使调和】', ingMap, _f) +
			'</div>' +
			fireBarHtml +
			'<div class="wx-alc-preview-bar">' + pvHtml + '</div>' +
			'<div class="wx-alc-act-row">' + actBtnsHtml + '</div>' +
			'<div class="wx-alc-picker-title">正在为 ' + slotLabelNames[actIdx] + ' 拣选药材（点击下方药柜/行囊奇材即可置入鼎位）：</div>' +
			'<div class="wx-alc-picker-grid">' + chipsHtml + '</div>';

		_wb.html(html);

		_wb.find('[data-fmode]').on('click', function () {
			wxAlcState.fireMode = $(this).attr('data-fmode') || 'balanced';
			wxRenderWorkbench(_wb, _f, _dlg);
		});

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
			else if (wxAlcState.activeSlotIdx === 1 && !wxAlcState.slotKeys[2] && (isFree || _f.minAuxCount >= 2)) wxAlcState.activeSlotIdx = 2;
			wxRenderWorkbench(_wb, _f, _dlg);
		});

		_wb.find('[data-wbact="clearall"]').on('click', function () {
			wxAlcState.slotKeys = ['', '', ''];
			wxAlcState.activeSlotIdx = 0;
			wxRenderWorkbench(_wb, _f, _dlg);
		});

		_wb.find('[data-wbact="autofill"]').on('click', function () {
			if (_f) {
				wxSelectFormulaAndAutoFill(_f);
				wxRenderWorkbench(_wb, _f, _dlg);
			}
		});

		_wb.find('[data-wbact="brew"]').on('click', function () {
			if ($(this).hasClass('is-disabled') || !wxAlcState.sqHandle || wxAlcState.busy) return;
			wxAlcState.busy = true;
			var reqFormulaId = isFree ? 'free' : _f.id;

			// Launch cauldron animation at 0ms immediately on click while Squirrel brews in parallel!
			var curInputs = [];
			var curMap = wxGetIngMap();
			for (var ii = 0; ii < 3; ii++) {
				var kIn = wxAlcState.slotKeys[ii];
				if (kIn && (kIn in curMap)) {
					curInputs.push({ name: curMap[kIn].name, icon: curMap[kIn].icon });
				}
			}
			var startedPending = false;
			if (window.WX_Showcase && window.WX_Showcase.beginPending) {
				startedPending = window.WX_Showcase.beginPending(
					{ kind: 'alchemy', inputs: curInputs },
					{ sqHandle: wxAlcState.sqHandle }
				);
			}

			var brewArgs = [reqFormulaId, wxAlcState.slotKeys[0], wxAlcState.slotKeys[1], wxAlcState.slotKeys[2], wxAlcState.entityId, wxAlcState.fireMode];
			var brewSq = wxAlcState.sqHandle;
			// Yield 1 paint frame (20ms) so CoherentUI draws Frame 1 of the furnace BEFORE Squirrel executes!
			setTimeout(function () {
				SQ.call(
					brewSq,
					'onWXAlchemyBrew',
					brewArgs,
					function (_res) {
						wxAlcState.busy = false;
						if (_res && _res.ok) {
							wxSyncHostFromAlchemyResponse(_res, true);
							wxAlcState.data = _res;
							if (isFree) {
								var newMap = wxGetIngMap();
								var usedAfter = {};
								for (var sIdx = 0; sIdx < 3; sIdx++) {
									var sk = wxAlcState.slotKeys[sIdx];
									if (!sk) continue;
									usedAfter[sk] = (usedAfter[sk] || 0) + 1;
									if (!(sk in newMap) || newMap[sk].totalCount < usedAfter[sk]) {
										wxAlcState.slotKeys[sIdx] = '';
									}
								}
								if (!wxAlcState.slotKeys[0]) wxAlcState.activeSlotIdx = 0;
							} else {
								var updatedF = wxFindFormulaObj(_f.id);
								var checkPv = wxComputeClientPreview(updatedF);
								if (!checkPv.ok && updatedF) {
									wxSelectFormulaAndAutoFill(updatedF);
								}
							}
							if (_res.wxShowcase && window.WX_Showcase) {
								// Defer heavy workbench DOM rebuild until reveal closes so animation runs at 60fps!
								window.WX_Showcase.resolvePending(_res.wxShowcase, {
									sqHandle: brewSq,
									onClose: function () { wxRenderAll(_dlg); }
								});
							} else {
								if (startedPending && window.WX_Showcase) window.WX_Showcase.abortPending();
								wxRenderAll(_dlg);
								wxShowAlcBanner(_res.actionMessage || '开炉炼丹完成！', false);
							}
						} else {
							if (startedPending && window.WX_Showcase) window.WX_Showcase.abortPending();
							if (window.WX_Showcase) {
								window.WX_Showcase.pulseElement(_wb.find('.wx-alc-furnace-art').parent(), {
									theme: 'crimson',
									floatText: '未能成炉'
								});
							}
							wxShowAlcBanner((_res && _res.reason) ? _res.reason : '未能完成炼丹。', true);
						}
					}
				);
			}, startedPending ? 20 : 0);
		});
	}

	function wxRenderCabinetView(_body, _dlg) {
		var d = wxAlcState.data;
		var inWs = wxIsWorkshopMode();
		var allIngs = d.ingredients || [];
		var q = wxAlcState.cabSearch;

		var toolbarHtml = '';
		if (inWs) {
			toolbarHtml =
				'<div class="wx-alc-cab-toolbar">' +
					'<span class="wx-alc-mini-btn" data-cabact="sweep-rare">奇草/内丹一键入柜</span>' +
					'<span class="wx-alc-mini-btn" data-cabact="sweep-all">连同异兽奇材全部入柜</span>' +
					'<label class="wx-alc-cab-check"><input type="checkbox" data-cabchk="autostore"' + (d.autoStore ? ' checked="checked"' : '') + '/> 入坊自动入柜(奇草/内丹)</label>' +
					'<label class="wx-alc-cab-check"><input type="checkbox" data-cabchk="autotrophy"' + (d.autoTrophy ? ' checked="checked"' : '') + '/> 含异兽皮骨</label>' +
					'<input type="text" class="wx-alc-cab-search" data-cab="search" value="' + wxEsc(wxAlcState.cabSearch) + '" placeholder="搜奇草/内丹/药性..." />' +
				'</div>' +
				'<div class="wx-alc-cab-scroll" data-cab="grid"></div>';
		} else {
			toolbarHtml =
				'<div class="wx-alc-cab-toolbar">' +
					'<span style="font-size:1.26rem;color:#ffe28a;">百工总号【百草药柜】寄存与随军行囊奇材账册</span>' +
					'<span style="font-size:1.22rem;color:#bd9d71;margin-left:0.8rem;">—— 存取奇材或调整寄存规制请亲赴城镇【百工丹坊】</span>' +
					'<input type="text" class="wx-alc-cab-search" data-cab="search" value="' + wxEsc(wxAlcState.cabSearch) + '" placeholder="搜奇草/内丹/药性..." />' +
				'</div>' +
				'<div class="wx-alc-cab-scroll" data-cab="grid"></div>';
		}

		_body.html(toolbarHtml);

		var grid = _body.find('[data-cab="grid"]');
		var kindLabels = { herb: '天下奇草', core: '山海内丹', trophy: '异兽奇材' };
		var shown = 0;
		var cardsHtml = '';

		if (wxAlcState.cabKindFilter === 'codex') {
			var codex = d.herbCodex || [];
			var ownedCodexCnt = 0;
			for (var ci = 0; ci < codex.length; ci++) {
				if (codex[ci].totalCount > 0) ownedCodexCnt++;
			}
			cardsHtml +=
				'<div style="padding:0.5rem 0.9rem 0.75rem;color:#e6cfa3;font-size:1.22rem;border-bottom:1px solid rgba(188,150,92,0.22);margin-bottom:0.7rem;">' +
					'《山海本草》四十九味总谱（五藏山经 · 海外四经 · 海内五经 · 大荒四经）—— 当前现存品种：<strong style="color:#7ee29a;">' + ownedCodexCnt + ' / ' + codex.length + '</strong>' +
				'</div>';
			for (var hc = 0; hc < codex.length; hc++) {
				var hb = codex[hc];
				if (wxAlcState.cabNatureFilter !== 'all' && hb.nature !== wxAlcState.cabNatureFilter) continue;
				if (q) {
					var hHay = (hb.name + ' ' + hb.chapter + ' ' + hb.subLabel + ' ' + hb.qualityLabel + ' ' + hb.natureName + ' ' + hb.description).toLowerCase();
					if (hHay.indexOf(q) === -1) continue;
				}
				shown++;
				var hBtns = '';
				if (hb.totalCount > 0) {
					if (inWs && hb.cabinetCount > 0) {
						hBtns += '<span class="wx-alc-mini-btn" data-wkey="' + wxEsc(hb.key) + '" data-wqty="1">取出 ×1</span>';
						if (hb.cabinetCount >= 5) {
							hBtns += '<span class="wx-alc-mini-btn" data-wkey="' + wxEsc(hb.key) + '" data-wqty="5">取出 ×5</span>';
						}
					} else {
						var hLocs = [];
						if (hb.cabinetCount > 0) hLocs.push('药柜 ×' + hb.cabinetCount);
						if (hb.stashCount > 0) hLocs.push('行囊 ×' + hb.stashCount);
						hBtns = '<span style="font-size:1.15rem;color:#7ee29a;">现存：' + hLocs.join(' · ') + '</span>';
					}
				} else {
					hBtns = '<span style="font-size:1.14rem;color:#9e8560;font-style:italic;">暂未存货 · 山海秘境 / 巨兽 / 宗门药庐采买</span>';
				}
				var dimStyle = (hb.totalCount > 0) ? '' : ' style="opacity:0.84;"';
				cardsHtml +=
					'<div class="wx-alc-cab-card"' + dimStyle + ' title="' + wxEsc(hb.description) + '">' +
						'<img class="wx-cab-icon" src="coui://gfx/' + hb.icon + '" alt=""/>' +
						'<div class="wx-alc-cab-cname">' + wxEsc(hb.name) + '</div>' +
						'<div class="wx-alc-cab-cmeta">' +
							'《' + wxEsc(hb.chapter) + '》· ' + wxEsc(hb.qualityLabel) + ' · <span style="color:' + hb.natureColor + ';">' + wxEsc(hb.natureName) + ' · 药力' + hb.potency + '</span>' +
							(hb.totalCount > 0 ? (' · 现存 <strong style="color:#7ee29a;">' + hb.totalCount + '</strong>') : '') +
						'</div>' +
						'<div class="wx-alc-cab-cdesc">' + wxEsc(hb.description) + '</div>' +
						'<div class="wx-alc-cab-cbtns">' + hBtns + '</div>' +
					'</div>';
			}
		} else {
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
				if (inWs) {
					if (it.cabinetCount > 0) {
						withdrawBtns += '<span class="wx-alc-mini-btn" data-wkey="' + wxEsc(it.key) + '" data-wqty="1">取出 ×1</span>';
						if (it.cabinetCount >= 5) {
							withdrawBtns += '<span class="wx-alc-mini-btn" data-wkey="' + wxEsc(it.key) + '" data-wqty="5">取出 ×5</span>';
						}
					} else {
						withdrawBtns = '<span style="font-size:1.15rem;color:#bd9d71;font-style:italic;">现存随军行囊中（可点击上方一键入柜省空间）</span>';
					}
				} else {
					var locParts = [];
					if (it.cabinetCount > 0) locParts.push('百工药柜寄存 ×' + it.cabinetCount);
					if (it.stashCount > 0) locParts.push('随军行囊携行 ×' + it.stashCount);
					withdrawBtns = '<span style="font-size:1.16rem;color:#bd9d71;">' + locParts.join(' · ') + '</span>';
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
		}

		if (shown === 0) {
			grid.html('<div style="padding:4rem 2rem;color:#bd9d71;font-style:italic;text-align:center;">百草药柜与随军行囊中暂无符合筛选条件的奇草、大妖内丹或异兽奇材。<br/>讨伐山泽异兽、探秘山海凶兽秘境或奇遇采药后，可携赴城镇【百工丹坊】清点入柜！</div>');
		} else {
			grid.html(cardsHtml + '<div class="clear-both"></div>');
		}

		if (inWs) {
			_body.find('[data-cabact]').on('click', function () {
				if (!wxAlcState.sqHandle) return;
				var incTr = ($(this).attr('data-cabact') === 'sweep-all');
				SQ.call(wxAlcState.sqHandle, 'onWXAlchemySweep', [incTr, wxAlcState.entityId], function (_res) {
					if (_res && _res.ok) {
						wxSyncHostFromAlchemyResponse(_res);
						wxAlcState.data = _res;
						wxRenderAll(_dlg);
						if (_res.sweepSummary && window.WX_Showcase && window.WX_Showcase.sweepFx) {
							var cabBtn = _dlg.find('[data-amode="cabinet"]:first');
							window.WX_Showcase.sweepFx(cabBtn.length ? cabBtn : _dlg, {
								theme: 'jade',
								icon: 'ui/wx_icons/wx_glyph_herb_cabinet.png',
								floatText: _res.sweepSummary,
								sqHandle: wxAlcState.sqHandle,
								soundCue: 'sweep_whoosh'
							});
						} else {
							wxShowAlcBanner(_res.actionMessage, false);
						}
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
		}

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
		var inWs = wxIsWorkshopMode();
		var fg = (d && d.forge) ? d.forge : null;
		if (!_sel || !fg) {
			_wb.html(
				'<div style="padding:3.5rem 1.8rem;color:#bd9d71;text-align:center;line-height:2.1rem;">' +
					'<div style="font-size:1.55rem;color:#dda21f;margin-bottom:0.6rem;">' + (inWs ? '百工神兵重锻炉 · 免大妖内丹淬洗极品' : '《百工器谱》 · 神兵品相与词条手札') + '</div>' +
					'<div>当前战团尚无已铸造的【百工奇物 / 山海神装 / 传世名器】。</div>' +
					'<div>前往城镇【百工丹坊】打造兵甲后，即可在此查阅品相词条，并于百工丹坊内耗百工奇材重复淬洗极品！</div>' +
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
			statRowsHtml = '<div class="wx-rfg-stat-row"><span style="color:#bd9d71;">百工重锻可提升整体品相与神工灵韵共鸣。</span></div>';
		}

		var mwHtml = (_sel.grade >= 3)
			? ('<div class="wx-rfg-mw-note">✦ 此器已觉醒<strong>【神工共鸣】</strong>：若附带器魂灵韵，实战触发概率额外 +8%、灼烧/回血等数值 +2！' + (inWs ? '若仍欲追求更高完美度或更换淬火词条，连点两次下方按钮即可重洗。' : '') + '</div>')
			: '';

		var qList = (fg.quenchCatalysts && fg.quenchCatalysts.length)
			? fg.quenchCatalysts
			: [{ id: 'none', name: '凡水淬锋', short: '凡水', color: '#bd9d71', affixTitle: '', affixDesc: '不耗额外引子，均衡塑形', available: true, matName: '' }];
		var selQ = qList[0];
		for (var qi = 0; qi < qList.length; qi++) {
			if (qList[qi].id === wxAlcState.quenchId) { selQ = qList[qi]; break; }
		}
		var lockUse = (wxAlcState.lockSlot === 'f1' || wxAlcState.lockSlot === 'f2') ? wxAlcState.lockSlot : '';
		var needMats = lockUse ? 2 : 1;
		var effSilver = lockUse ? Math.max(100, Math.floor(_sel.silverCost * 1.50)) : _sel.silverCost;
		var money = (d && typeof d.money === 'number') ? d.money : 0;
		var matTotal = fg.catalystTotal || 0;
		var hasEnoughMats = fg.catalystFound && (matTotal >= needMats);
		var quenchOk = (selQ.id === 'none') || !!selQ.available;
		var canAfford = hasEnoughMats && quenchOk && (money >= effSilver);
		var lackNote = '';
		if (inWs) {
			if (!hasEnoughMats) {
				lackNote = '<div style="color:#ff8070;margin-top:0.2rem;">' + (needMats >= 2 ? ('开启【百炼锁词精铸】需消耗 2 份百工奇材（当前仅存 ' + matTotal + ' 份）。') : '缺少百工奇材辅料（需异兽奇材或大妖破部精粹任一 ×1）。') + '</div>';
			} else if (!quenchOk) {
				lackNote = '<div style="color:#ff8070;margin-top:0.2rem;">缺少【' + wxEsc(selQ.name) + '】所需引子药材或精粹（请改选「凡水淬锋」或已备齐的引子）。</div>';
			} else if (money < effSilver) {
				lackNote = '<div style="color:#ff8070;margin-top:0.2rem;">纹银不足（本次重锻需 ' + effSilver + ' 两，现存 ' + money + ' 两）。</div>';
			}
		}

		var ctrlHtml = '';
		if (inWs) {
			var qChips = '';
			for (var qj = 0; qj < qList.length; qj++) {
				var qc = qList[qj];
				var qAct = (qc.id === selQ.id);
				var qLack = (qc.id !== 'none' && !qc.available);
				var qSub = (qc.id === 'none') ? '' : (qc.available ? ' · 备妥' : ' · 缺引');
				qChips += '<span class="wx-rfg-opt-chip' + (qAct ? ' is-active' : '') + (qLack ? ' is-lacking' : '') + '" data-qid="' + wxEsc(qc.id) + '" style="color:' + (qAct ? qc.color : '#d7b174') + ';">' + wxEsc(qc.name) + qSub + '</span>';
			}
			var lockOpts = [
				['', '自由重铸（奇材×1）'],
				['f1', '锁主词条·伤/甲/近防（奇材×2 · 银×1.5）'],
				['f2', '锁副词条·破甲/轻盈/远防（奇材×2 · 银×1.5）']
			];
			var lChips = '';
			for (var li = 0; li < lockOpts.length; li++) {
				var lo = lockOpts[li];
				var lAct = (lockUse === lo[0]);
				lChips += '<span class="wx-rfg-opt-chip' + (lAct ? ' is-active' : '') + '" data-rlock="' + lo[0] + '">' + lo[1] + '</span>';
			}
			ctrlHtml =
				'<div class="wx-rfg-ctrl-bar">' +
					'<div class="wx-rfg-ctrl-row"><strong style="color:#dda21f;margin-right:0.35rem;">淬火塑形：</strong>' + qChips +
						'<div style="font-size:1.15rem;color:' + selQ.color + ';line-height:1.65rem;">' +
							(selQ.affixTitle ? ('【' + wxEsc(selQ.affixTitle) + '】') : '') + wxEsc(selQ.affixDesc || '') +
							(selQ.id !== 'none' && selQ.matName ? ('（将耗引子：' + wxEsc(selQ.matName) + ' ×1）') : '') +
						'</div>' +
					'</div>' +
					'<div class="wx-rfg-ctrl-row"><strong style="color:#dda21f;margin-right:0.35rem;">百炼锁词：</strong>' + lChips + '</div>' +
				'</div>';
		}

		var isConfirmingMw = (_sel.grade >= 3 && wxAlcState.confirmMasterworkUid === _sel.uid);
		var btnLabel = isConfirmingMw
			? ('⚠ 确认重洗神工（' + effSilver + '两）')
			: ((lockUse ? '锁词精铸' : '重锤淬炼') + '（' + effSilver + '两 + 奇材×' + needMats + (selQ.id !== 'none' ? ' + 引子' : '') + '）');

		var catStr = fg.catalystFound
			? ('百工重淬耗材：<strong style="color:#7ee29a;">' + wxEsc(fg.catalystName) + ' ×' + needMats + '</strong> + <strong>' + effSilver + ' 两纹银</strong>（药柜/行囊共余奇材 ' + matTotal + ' 份 · <strong>免耗山海大妖内丹</strong>）')
			: ('百工重淬耗材：任意百工奇材 ×' + needMats + ' + ' + effSilver + ' 两纹银（当前余 0 份）');

		var extraBadges = '';
		if (_sel.weaponModName) {
			extraBadges += '　│　<span style="color:#7ee29a;">【兵刃铭配：' + wxEsc(_sel.weaponModName) + '】</span>';
		}
		if (_sel.quenchTitle) {
			extraBadges += '　│　<span style="color:' + (_sel.quenchColor || '#ffe28a') + ';">【淬火：' + wxEsc(_sel.quenchTitle) + '】</span>';
		}

		var footerHtml = inWs
			? (
				'<div class="wx-alc-act-row">' +
					'<span class="wx-alc-act-btn' + (canAfford ? '' : ' is-disabled') + '" style="width:28.6rem;" data-rfg-exec="1">' +
						'<img src="coui://gfx/ui/icons/asset_supplies.png" style="width:1.9rem;height:1.9rem;vertical-align:middle;margin:-0.25rem 0.3rem 0 0;" alt=""/>' + btnLabel +
					'</span>' +
				'</div>'
			)
			: '<div class="wx-alc-ro-notice">随身《百工器谱》仅供检视品相与词条区间 —— 欲重锤淬洗神兵，请亲赴州县城镇<strong>【百工丹坊】</strong>操作。</div>';

		var html =
			'<div class="wx-alc-wb-hdr">' +
				'<img class="wx-alc-wb-hdr-icon" src="coui://gfx/' + _sel.icon + '" alt=""/>' +
				'<div class="wx-alc-wb-title">' + wxEsc(_sel.name) +
					' <span style="font-size:1.28rem;color:' + _sel.gradeColor + ';">【' + wxEsc(_sel.gradeTitle) + ' · 完美度 ' + _sel.perfectionPct + '%】</span>' +
				'</div>' +
				'<div class="wx-alc-wb-desc">归属：<strong>' + wxEsc(_sel.ownerLabel) + '</strong>' + extraBadges + '　│　' + wxEsc(_sel.description) + '</div>' +
			'</div>' +
			'<div class="wx-rfg-pity-box">' +
				'<div>掌锤匠师：<strong style="color:#dda21f;">' + wxEsc(fg.smithLabel) + '</strong>' +
					(fg.bonusHighPct > 0 ? ('（高品率 +' + fg.bonusHighPct + '%' + (fg.hasDiscount ? ' · 重锻八折' : '') + '）') : '') +
					'　│　品相率：凡锻 ' + ch[0] + '% · <span style="color:#5ec47a;">良工 ' + ch[1] + '%</span> · <span style="color:#b58ae6;">百炼 ' + ch[2] + '%</span> · <span style="color:#f0bc42;">神工 ' + ch[3] + '%</span>' +
				'</div>' +
				'<div>百炼炉温：' + pipsHtml + '<strong style="color:#f0bc42;">(' + pity + '/5)</strong> —— ' +
					(pity >= 5 ? '<strong style="color:#ffe28a;">炉火已满！下一锤必出【百炼】或【神工】！</strong>' : '连淬 5 锤未见百炼，下一锤必成【百炼/神工】（重锻顺带免费修满耐久）') +
				'</div>' +
				'<div>' + catStr + '</div>' +
				lackNote +
			'</div>' +
			ctrlHtml +
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
			footerHtml;

		_wb.html(html);

		if (inWs) {
			_wb.find('[data-qid]').on('click', function () {
				wxAlcState.quenchId = $(this).attr('data-qid') || 'none';
				wxAlcState.confirmMasterworkUid = null;
				wxRenderReforgeWorkbench(_wb, _sel, _dlg);
			});
			_wb.find('[data-rlock]').on('click', function () {
				wxAlcState.lockSlot = $(this).attr('data-rlock') || '';
				wxAlcState.confirmMasterworkUid = null;
				wxRenderReforgeWorkbench(_wb, _sel, _dlg);
			});
			_wb.find('[data-rfg-exec="1"]').on('click', function () {
				if ($(this).hasClass('is-disabled') || !wxAlcState.sqHandle || wxAlcState.busy) return;
				if (_sel.grade >= 3 && wxAlcState.confirmMasterworkUid !== _sel.uid) {
					wxAlcState.confirmMasterworkUid = _sel.uid;
					wxRenderReforgeWorkbench(_wb, _sel, _dlg);
					wxShowAlcBanner('该神兵已达【神工】品相！若确认仍要重洗词条，请再点击一次「确认重洗神工」。', false);
					return;
				}
				wxAlcState.confirmMasterworkUid = null;
				wxAlcState.busy = true;
				var startedPendingR = false;
				if (window.WX_Showcase && window.WX_Showcase.beginPending) {
					startedPendingR = window.WX_Showcase.beginPending(
						{ kind: 'reforge' },
						{ sqHandle: wxAlcState.sqHandle }
					);
				}
				var rfgSq = wxAlcState.sqHandle;
				var rfgArgs = [_sel.uid, wxAlcState.entityId, selQ.id, lockUse];
				setTimeout(function () {
					SQ.call(
						rfgSq,
						'onWXForgeReforge',
						rfgArgs,
						function (_res) {
							wxAlcState.busy = false;
							if (_res && _res.ok) {
								wxSyncHostFromAlchemyResponse(_res, true);
								wxAlcState.data = _res;
								if (_res.wxShowcase && window.WX_Showcase) {
									window.WX_Showcase.resolvePending(_res.wxShowcase, {
										sqHandle: rfgSq,
										onClose: function () { wxRenderAll(_dlg); }
									});
								} else {
									if (startedPendingR && window.WX_Showcase) window.WX_Showcase.abortPending();
									wxRenderAll(_dlg);
									wxShowAlcBanner(_res.actionMessage || '百工重锻完成！', false);
								}
							} else {
								if (startedPendingR && window.WX_Showcase) window.WX_Showcase.abortPending();
								wxShowAlcBanner((_res && _res.reason) ? _res.reason : '未能完成神兵重锻。', true);
							}
						}
					);
				}, startedPendingR ? 20 : 0);
			});
		}
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
		wxAlcState.busy = false;
		wxAlcState.taxNeedsRefresh = false;
		wxAlcState.data = _payload;
		var inWs = wxIsWorkshopMode();

		if (wxAlcState.hostDS && wxAlcState.hostDS.notifyBackendPopupDialogIsVisible) {
			wxAlcState.hostDS.notifyBackendPopupDialogIsVisible(true);
		}

		if (inWs) {
			if (wxAlcState.selectedFormulaId && wxAlcState.selectedFormulaId !== 'free') {
				var prevF = wxFindFormulaObj(wxAlcState.selectedFormulaId);
				if (prevF) {
					wxSelectFormulaAndAutoFill(prevF);
				} else {
					wxAlcState.selectedFormulaId = 'free';
					wxAlcState.slotKeys = ['', '', ''];
					wxAlcState.activeSlotIdx = 0;
				}
			} else {
				wxAlcState.selectedFormulaId = 'free';
				wxAlcState.slotKeys = ['', '', ''];
				wxAlcState.activeSlotIdx = 0;
			}
		} else {
			if (wxAlcState.selectedFormulaId === 'free') {
				var firstF = (_payload.formulas && _payload.formulas.length > 0) ? _payload.formulas[0] : null;
				wxAlcState.selectedFormulaId = firstF ? firstF.id : null;
			}
		}

		var host = $('.root-screen:first');
		if (!host.length) host = $(document.body);

		var hdrTitle = inWs
			? '百工丹坊'
			: '<img src="coui://gfx/ui/wx_icons/wx_glyph_herb_cabinet.png" alt=""/>丹经与药柜录 · 已悟丹方 · 百工器谱 · 奇材账册';

		var backdrop = $(
			'<div class="wx-alc-backdrop">' +
				'<div class="wx-alc-dialog' + (inWs ? ' wx-alc-workshop' : '') + '">' +
					'<div class="wx-alc-hdr">' +
						'<span class="wx-alc-title">' + hdrTitle + '</span>' +
						'<div class="wx-alc-hdr-close" data-alc-close="1" title="关闭 (ESC)">×</div>' +
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
			if ($('.wx-fx-backdrop').length > 0) return;
			if (_e.keyCode === 27) {
				wxCloseAlchemyModal();
				_e.stopPropagation();
				return false;
			}
		});

		wxRenderAll(backdrop.find('.wx-alc-dialog'));
	}

	// Public opener: Read-Only from `江湖录 (R)` / Character Screen; Full Interactive inside Town `百工丹坊`!
	window.WX_OpenAlchemyCauldron = function (_sqHandle, _hostDS, _perksMod, _entityId, _initialMode, _taxMod) {
		var sq = _sqHandle || (wxWorldTopbarModRef ? wxWorldTopbarModRef.mSQHandle : null);
		if (!sq) return;
		wxAlcState.sqHandle = sq;
		wxAlcState.hostDS   = _hostDS || null;
		wxAlcState.perksMod = _perksMod || null;
		wxAlcState.taxMod   = _taxMod || null;
		wxAlcState.entityId = _entityId || null;
		wxAlcState.mode     = _initialMode || 'cauldron';

		SQ.call(sq, 'onWXGetAlchemyState', _entityId ? [_entityId] : null, function (_res) {
			if (_res && _res.ok) {
				wxOpenAlchemyModalDOM(_res);
			}
		});
	};

	// ------------------------------------------------------------------------
	// 1. Capture World Topbar RPC Reference Only (NO floating world-map button!)
	// ------------------------------------------------------------------------
	if (typeof WorldScreenTopbarOptionsModule !== 'undefined') {
		var origTopbarCreate = WorldScreenTopbarOptionsModule.prototype.createDIV;
		WorldScreenTopbarOptionsModule.prototype.createDIV = function (_parentDiv) {
			wxWorldTopbarModRef = this;
			origTopbarCreate.call(this, _parentDiv);
		};
	}

	// ------------------------------------------------------------------------
	// 2. Town workshop stations and craft result banner
	// ------------------------------------------------------------------------
	if (typeof WorldTownScreenTaxidermistDialogModule !== 'undefined') {
		var origTaxCreate = WorldTownScreenTaxidermistDialogModule.prototype.createDIV;
		WorldTownScreenTaxidermistDialogModule.prototype.createDIV = function (_parentDiv) {
			var self = this;
			origTaxCreate.call(this, _parentDiv);
			var content = this.mDialogContainer.findDialogContentContainer();
			if (content.children('.wx-workshop-stations').length) return;
			var stations = [
				['cauldron', '八卦丹炉', '按方炼丹，自选药材试丹', 'wx_icons/wx_cauldron_furnace.png'],
				['reforge', '神兵重锻', '重淬兵甲的品相与词条', 'wx_icons/wx_asset_supplies.png'],
				['cabinet', '百草药柜', '存取药材、内丹与异兽奇材', 'wx_icons/wx_cabinet_chest.png']
			];
			var row = $('<div class="wx-workshop-stations"></div>');
			for (var i = 0; i < stations.length; i++) {
				var station = stations[i];
				row.append('<button type="button" class="wx-tax-station-btn is-' + station[0] + '" data-wx-station="' + station[0] + '">' +
					'<img src="coui://gfx/ui/' + station[3] + '" alt=""/><strong>' + station[1] + '</strong><small>' + station[2] + '</small></button>');
			}
			row.on('click', '[data-wx-station]', function () {
				if (self.mSQHandle != null) window.WX_OpenAlchemyCauldron(self.mSQHandle, null, null, null, $(this).attr('data-wx-station'), self);
			});
			content.addClass('wx-workshop-content').prepend(row);
		};

		var origTaxNotifyCraft = WorldTownScreenTaxidermistDialogModule.prototype.notifyBackendCraft;
		if (typeof origTaxNotifyCraft === 'function') {
			WorldTownScreenTaxidermistDialogModule.prototype.notifyBackendCraft = function (_blueprintID, _callback) {
				var self = this;
				if (self.mWXCraftBusy) return;
				self.mWXCraftBusy = true;
				var startedPendingC = false;
				if (window.WX_Showcase && window.WX_Showcase.beginPending) {
					var entry = (this.mSelectedEntry && this.mSelectedEntry.data) ? this.mSelectedEntry.data('entry') : null;
					var imgPath = (entry && entry.ImagePath) ? String(entry.ImagePath) : '';
					var bpName  = (entry && entry.Name) ? String(entry.Name) : '';
					var isPillBp = (imgPath.indexOf('consumables/') !== -1 || imgPath.indexOf('wx_pill_') !== -1 || bpName.indexOf('丹') !== -1 || bpName.indexOf('丸') !== -1 || bpName.indexOf('散') !== -1 || bpName.indexOf('膏') !== -1);
					var inpCards = [];
					if (entry && entry.Ingredients && entry.Ingredients.length) {
						for (var ci = 0; ci < entry.Ingredients.length && ci < 3; ci++) {
							var ig = entry.Ingredients[ci];
							if (ig && ig.ImagePath) {
								inpCards.push({ name: '', icon: 'ui/items/' + ig.ImagePath });
							}
						}
					}
					if (!entry || entry.IsCraftable !== false) {
						startedPendingC = window.WX_Showcase.beginPending(
							{ kind: isPillBp ? 'alchemy' : 'forge', inputs: inpCards },
							{ sqHandle: self.mSQHandle }
						);
					}
				}
				// Yield 1 paint frame (20ms) so CoherentUI draws Frame 1 of the anvil/furnace BEFORE Squirrel crafts!
				setTimeout(function () {
					origTaxNotifyCraft.call(self, _blueprintID, function (_result) {
						self.mWXCraftBusy = false;
						if (_result && _result.wxCraftShowcase && window.WX_Showcase) {
							// Sync topbar silver/assets immediately, and defer the heavy 400-node vanilla blueprint
							// list rebuild until the player dismisses the forged item reveal card!
							if (self.mAssets && _result.Assets) {
								try { self.mAssets.loadFromData(_result.Assets); } catch (_eAs) {}
							}
							window.WX_Showcase.resolvePending(_result.wxCraftShowcase, {
								sqHandle: self.mSQHandle,
								onClose: function () {
									if (!self.mDialogContainer) return;
									if (_callback) {
										var cleanRes = jQuery.extend({}, _result);
										delete cleanRes.wxCraftShowcase;
										delete cleanRes.wxCraftBanner;
										_callback(cleanRes);
									}
								}
							});
							return;
						}
						if (startedPendingC && window.WX_Showcase) {
							window.WX_Showcase.abortPending();
						}
						if (_callback) _callback(_result);
					});
				}, startedPendingC ? 20 : 0);
			};
		}

		var origTaxLoadCraftBanner = WorldTownScreenTaxidermistDialogModule.prototype.loadFromData;
		if (typeof origTaxLoadCraftBanner === 'function') {
			WorldTownScreenTaxidermistDialogModule.prototype.loadFromData = function (_data) {
				if (_data && _data.wxCraftShowcase && window.WX_Showcase) {
					var selfTax = this;
					window.WX_Showcase.play(_data.wxCraftShowcase, {
						sqHandle: this.mSQHandle,
						onClose: function () {
							var cleanD = jQuery.extend({}, _data);
							delete cleanD.wxCraftShowcase;
							delete cleanD.wxCraftBanner;
							origTaxLoadCraftBanner.call(selfTax, cleanD);
						}
					});
					return;
				}
				origTaxLoadCraftBanner.call(this, _data);
				if (_data && _data.wxCraftBanner && this.mDialogContainer) {
					if (window.WX_Showcase && window.WX_Showcase.plaque) {
						window.WX_Showcase.plaque({
							title: '百工丹坊',
							message: _data.wxCraftBanner,
							icon: 'ui/wx_icons/wx_glyph_cauldron.png',
							isError: (_data.wxCraftBanner.indexOf('不足') !== -1 || _data.wxCraftBanner.indexOf('找不到') !== -1)
						});
					} else {
						var oldB = this.mDialogContainer.find('.wx-screen-banner');
						if (oldB.length) oldB.remove();
						var bEl = $('<div class="wx-screen-banner">' + wxEsc(_data.wxCraftBanner) + '</div>');
						this.mDialogContainer.append(bEl);
						setTimeout(function () {
							bEl.fadeOut(260, function () { bEl.remove(); });
						}, 4200);
					}
				}
			};
		}
	}

	// ------------------------------------------------------------------------
	// 3. Character Screen Enhanced `洗经伐髓` Pill Picker (consumes finished Stash pills)
	// ------------------------------------------------------------------------
	if (typeof CharacterScreenPerksModule !== 'undefined') {
		var origRenderAll = CharacterScreenPerksModule.prototype.wxRenderAll;
		if (typeof origRenderAll === 'function') {
			CharacterScreenPerksModule.prototype.wxRenderAll = function () {
				origRenderAll.call(this);
				if (!this.mWXHeader || !this.mWXState) return;
				var bro = this.mWXState.brother;
				if (bro && bro.hasWangchenGrace && this.mWXHeader.html().indexOf('归元护脉') === -1) {
					var rSpan = this.mWXHeader.find('.wx-r:first');
					if (rSpan.length) {
						$('<span class="wx-sep">|</span><span class="wx-c-title" title="下一次换装或卸下武学免除全部散功调息">归元护脉</span>').insertBefore(rSpan);
					}
				}
			};
		}

		CharacterScreenPerksModule.prototype.wxOpenWashModal = function (_preferredSource) {
			var self = this;
			var state = this.mWXState;
			if (!state || !state.brother || !this.mDataSource || this.mDataSource.mSQHandle == null) return;
			var bro = state.brother, actorId = bro.entityId;
			var counts = state.washPills || { wx_pill_xisui: state.washPillCount };
			var protect = state.protectPillCount || 0;
			var sources = [
				['pending', '功成契机', 'wx_icons/wx_icon_ap.png', bro.pendingWashChances || 0],
				['wx_pill_zijin_xisui', '太乙紫金洗髓丹', 'items/consumables/wx_pill_zijin_xisui.png', counts.wx_pill_zijin_xisui || 0],
				['wx_pill_xisui', '洗髓丹', 'items/consumables/wx_pill_xisui.png', counts.wx_pill_xisui || 0],
				['wx_pill_yijin_wan', '易筋锻骨丸', 'items/consumables/wx_pill_yijin_wan.png', counts.wx_pill_yijin_wan || 0]
			];
			var source = null, sourceHtml = '', starred = 0;
			var target = -1, replace = -1, request = 0, submitting = false;
			for (var i = 0; i < sources.length; i++) {
				var opt = sources[i];
				if (opt[0] === 'pending' && !opt[3]) continue;
				if (opt[3] && (source === null || _preferredSource === opt[0])) source = opt[0];
				sourceHtml += '<button type="button" class="wx-wash-pill-opt" data-wsrc="' + opt[0] + '"' + (opt[3] ? '' : ' disabled="disabled"') + '>' +
					'<img src="coui://gfx/ui/' + opt[2] + '" alt=""/>' + opt[1] + ' ×' + opt[3] + '</button>';
			}
			function attrChoices(_replacement) {
				var html = '';
				for (var n = 0; n < bro.talents.length; n++) {
					var stars = bro.talents[n];
					if (_replacement && !stars) continue;
					html += '<button type="button" class="wx-wash-attr" data-attr="' + n + '"' +
						(!_replacement && stars >= 3 ? ' disabled="disabled"' : '') + '><span>' +
						wxEsc(bro.attrLabels[n]) + ' ' + wxEsc(bro.baseStats[n]) + '</span><small>' +
						(['无星', '★', '★★', '★★★'][stars] || '') + '</small></button>';
				}
				return html;
			}
			for (var n = 0; n < bro.talents.length; n++) if (bro.talents[n] > 0) starred++;
			var box = $(
				'<div class="wx-popup wx-wash-dialog">' +
					'<div class="wx-ph wx-t-title">洗经伐髓</div>' +
					'<div class="wx-pb">' +
						'<div class="wx-wash-section"><h3>洗髓用丹</h3>' + sourceHtml +
							(source === null ? '<div class="wx-wash-hint">当前没有可用灵丹或功成契机，可在城镇百工丹坊炼制洗髓丹。</div>' : '') + '</div>' +
						'<div class="wx-wash-section"><h3>目标属性 <small>已有 ' + starred + ' 项带星，上限 3 项</small></h3>' +
							'<div data-wx="wash-targets">' + attrChoices(false) + '</div></div>' +
						'<div class="wx-wash-section" data-wx="replace-wrap" style="display:none"><h3>洗去哪一项的星级</h3>' +
							'<div data-wx="wash-replaces">' + attrChoices(true) + '</div></div>' +
						'<div class="wx-wash-section"><label class="wx-wash-protect"><input type="checkbox" data-wx="use-protect"' +
							(protect ? '' : ' disabled="disabled"') + '/> 辅服护脉丹药（余 ' + protect + '）</label>' +
							'<div class="wx-wash-preview" data-wx="wash-preview">选择目标属性后可查看成功率和失败风险。</div></div>' +
					'</div><div class="wx-pf"><button type="button" class="wx-vb wx-vb1" data-wx="wash-exec" disabled="disabled">开始洗髓</button>' +
						'<button type="button" class="wx-vb wx-vb2" data-wx-close="1">返回</button></div></div>'
			);
			var preview = box.find('[data-wx="wash-preview"]'), exec = box.find('[data-wx="wash-exec"]');
			var guard = box.find('[data-wx="use-protect"]');
			function active() {
				return self.mWXCurrentEntityId === actorId && $.contains(document.documentElement, box[0]);
			}
			function refreshPreview() {
				var rev = ++request;
				exec.prop('disabled', true);
				var needReplace = target >= 0 && bro.talents[target] === 0 && starred >= 3;
				box.find('[data-wx="replace-wrap"]').toggle(needReplace);
				if (target < 0) return;
				if (needReplace && replace < 0) {
					preview.text('请选择一项原有带星属性。换星成功后，它的星级将移至目标属性。');
					return;
				}
				preview.text('正在计算成功率…');
				SQ.call(self.mDataSource.mSQHandle, 'onWXGetWashPreviewEx', [actorId, target, replace, guard.is(':checked'), source || 'wx_pill_xisui'], function (pv) {
					if (!active() || rev !== request || submitting) return;
					if (!pv || !pv.Ok) { preview.text(pv && pv.Reason || '暂时无法计算，请重新选择属性。'); return; }
					var change = pv.IsReplaceMode ? wxEsc(pv.ReplaceAttrName) + '洗去星级，' + wxEsc(pv.TargetAttrName) + '升至 1★' :
						wxEsc(pv.TargetAttrName) + '　' + pv.CurrentStar + '★ → ' + pv.NextStar + '★';
					var lightDays = (typeof pv.LightShockDays === 'number' && pv.LightShockDays > 0) ? pv.LightShockDays : 2;
					var risk = pv.AvoidAllShock ? '免除经脉震荡' : (pv.AvoidHeavyShock ? ('轻度调息 ' + lightDays + ' 日') : '经脉震荡');
					preview.html('<strong>' + change + '</strong><div>成功率 <b>' + pv.FinalChance + '%</b>　基础 ' + pv.BaseChance +
						'% · 筹备 +' + pv.PrepBonus + '% · 丹品 +' + (pv.PillBonus || 0) + '%</div><div>失败后' +
						risk + '，永久暗疾概率 ' + (pv.PermInjuryRisk || 0) + '%。</div>');
					exec.prop('disabled', !source);
				});
			}
			box.find('[data-wsrc="' + source + '"]').addClass('is-selected');
			box.on('click', '[data-wsrc]', function () {
				if (submitting || this.disabled) return;
				source = $(this).attr('data-wsrc');
				box.find('[data-wsrc]').removeClass('is-selected');
				$(this).addClass('is-selected');
				refreshPreview();
			});
			box.on('click', '[data-attr]', function () {
				if (submitting || this.disabled) return;
				var item = $(this), idx = parseInt(item.attr('data-attr'), 10);
				if (item.parent().attr('data-wx') === 'wash-targets') {
					target = idx; replace = -1;
					box.find('[data-attr]').removeClass('is-selected');
				} else {
					replace = idx;
					item.siblings().removeClass('is-selected');
				}
				item.addClass('is-selected');
				refreshPreview();
			});
			guard.on('change', refreshPreview);
			exec.on('click', function () {
				if (!active() || this.disabled || submitting) return;
				submitting = true;
				exec.prop('disabled', true);
				SQ.call(self.mDataSource.mSQHandle, 'onWXExecuteWashEx',
					[actorId, target, replace, guard.is(':checked'), source === 'pending', source === 'pending' ? 'wx_pill_xisui' : source],
					function (res) {
						var current = active();
						if (res && res.ok) {
							if (current) self.wxCloseModal();
							self.wxApplyBackendState(res);
						} else if (current) {
							submitting = false;
							preview.text(res && res.reason || '洗髓未能执行，请重新选择灵丹或属性。');
						}
					});
			});
			this.wxOpenModal(box);
		};
	}
})();
