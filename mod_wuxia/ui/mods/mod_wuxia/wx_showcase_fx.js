/* ============================================================================
 * BB Wuxia Mod — Unified Visual Ritual, Item Reveal & Cultivation FX Engine
 * Strictly ES3-compliant (var / function only) for CoherentUI WebKit!
 *
 * Exposes `window.WX_Showcase`:
 *   - play(_spec, _opts)        : Two-phase animated ritual -> tactile item/result reveal
 *   - pulseElement(_$el, _opts) : Lightweight in-place Qi/medicinal aura surge + float badge
 *   - plaque(_opts)             : Upgraded animated Wuxia visual plaque (replaces flat toasts)
 *   - close()                   : Dismiss active showcase overlay cleanly
 * ============================================================================ */
(function () {
	'use strict';

	var state = {
		fastMode: false,
		timers: [],
		plaqueTimer: null,
		activeSpec: null,
		phase: 'idle',
		onDone: null,
		pending: false,
		pendingReady: false,
		pendingSkip: false,
		pendingSpec: null,
		pendingHandle: null,
		pendingEnterReveal: null,
		pendingBackdrop: null
	};

	// Pre-warm centerpiece ritual sprites into CoherentUI texture cache on load (0ms first-paint decode)
	var preloadedImgs = [];
	(function preloadRitualSprites() {
		var srcs = [
			'coui://gfx/ui/wx_icons/wx_cauldron_furnace.png',
			'coui://gfx/ui/wx_icons/wx_forge_anvil.png',
			'coui://gfx/ui/wx_icons/wx_cultivation_mandala.png'
		];
		for (var pi = 0; pi < srcs.length; pi++) {
			try {
				var im = new Image();
				im.src = srcs[pi];
				preloadedImgs.push(im);
			} catch (_ePre) {}
		}
	})();

	try {
		if (window.localStorage && window.localStorage.getItem('wx_showcase_fast') === '1') {
			state.fastMode = true;
		}
	} catch (_eLs) {}

	function wxEsc(_s) {
		return String(_s == null ? '' : _s)
			.replace(/&/g, '&amp;')
			.replace(/</g, '&lt;')
			.replace(/>/g, '&gt;')
			.replace(/"/g, '&quot;');
	}

	function toGfxUrl(_path, _fallback) {
		var p = (_path && typeof _path === 'string') ? _path : (_fallback || 'ui/wx_icons/wx_glyph_cauldron.png');
		if (p.indexOf('coui://') === 0) return p;
		if (p.indexOf('gfx/') === 0) return 'coui://' + p;
		return 'coui://gfx/' + p;
	}

	function clearTimers() {
		for (var i = 0; i < state.timers.length; i++) {
			clearTimeout(state.timers[i]);
		}
		state.timers = [];
	}

	function pushTimer(_fn, _ms) {
		var id = setTimeout(_fn, _ms);
		state.timers.push(id);
		return id;
	}

	function playSound(_sqHandle, _cue) {
		if (!_cue) return;
		var h = _sqHandle || window.WX_SectRPCHandle;
		if (!h || typeof SQ === 'undefined' || !SQ.call) return;
		try {
			SQ.call(h, 'onWXShowcaseSound', [_cue]);
		} catch (_eSnd) {}
	}

	function buildParticlesHtml(_mode) {
		var html = '<div class="wx-fx-particle-layer">';
		var count = (_mode === 'smoke') ? 8 : 12;
		var cls = (_mode === 'forge') ? ' is-forge' : ((_mode === 'qi') ? ' is-qi' : ((_mode === 'jade') ? ' is-jade' : ((_mode === 'smoke') ? ' is-smoke' : '')));
		for (var i = 0; i < count; i++) {
			var leftPct = 18 + Math.round((i / count) * 64) + ((i % 3) * 3 - 3);
			var topPct  = 52 + ((i * 17) % 28);
			var delay   = ((i * 0.09) % 0.72).toFixed(2);
			var dur     = (_mode === 'smoke' ? (0.95 + (i % 3) * 0.16) : (0.62 + (i % 4) * 0.14)).toFixed(2);
			html += '<span class="wx-fx-spark' + cls + '" style="left:' + leftPct + '%;top:' + topPct + '%;' +
				'-webkit-animation-delay:' + delay + 's;animation-delay:' + delay + 's;' +
				'-webkit-animation-duration:' + dur + 's;animation-duration:' + dur + 's;"></span>';
		}
		html += '</div>';
		return html;
	}

	function buildRitualPhaseHtml(_spec) {
		var kind = _spec.kind || 'alchemy';
		var isTrial = (_spec.outcome === 'trial');
		var inputs = _spec.inputs || [];
		var flyHtml = '';
		var i;

		if (kind === 'alchemy' || kind === 'forge') {
			for (i = 0; i < inputs.length && i < 3; i++) {
				var inp = inputs[i];
				if (!inp || !inp.icon) continue;
				flyHtml += '<div class="wx-fx-fly-in pos-' + i + '"><img src="' + wxEsc(toGfxUrl(inp.icon)) + '" alt=""/></div>';
			}
		} else if (kind === 'wash' && _spec.pillIcon) {
			flyHtml += '<div class="wx-fx-fly-in pos-0"><img src="' + wxEsc(toGfxUrl(_spec.pillIcon)) + '" alt=""/></div>';
		} else if ((kind === 'breakthrough' || kind === 'empower') && _spec.sourceIcon) {
			flyHtml += '<div class="wx-fx-fly-in pos-0"><img src="' + wxEsc(toGfxUrl(_spec.sourceIcon)) + '" alt=""/></div>';
		}

		var centerImg = 'ui/wx_icons/wx_cauldron_furnace.png';
		var centerCls = 'is-cauldron';
		var auraCls   = isTrial ? ' is-trial' : '';
		var ringCls   = '';
		var partMode  = isTrial ? 'smoke' : 'fire';
		var caption   = _spec.ritualCaption || (isTrial ? '盲炉试火 · 推演丹变……' : '地火催鼎 · 凝炼灵丹……');
		var mandalaFast = '';

		if (kind === 'forge' || kind === 'reforge') {
			centerImg = 'ui/wx_icons/wx_forge_anvil.png';
			centerCls = 'is-anvil';
			auraCls   = ' is-forge';
			ringCls   = ' is-anvil';
			partMode  = 'forge';
			caption   = _spec.ritualCaption || ((kind === 'reforge') ? '重锤淬锋 · 炉火重铸……' : '百工铸炼 · 锤打淬火……');
		} else if (kind === 'wash') {
			centerImg   = _spec.targetAttrIcon || 'ui/wx_icons/wx_icon_qi.png';
			centerCls   = 'is-medallion';
			auraCls     = ' is-wash';
			partMode    = 'qi';
			mandalaFast = ' is-fast';
			caption     = _spec.ritualCaption || ('药力贯脉 · 冲击「' + wxEsc(_spec.targetAttrName || '根骨') + '」关窍……');
		} else if (kind === 'breakthrough' || kind === 'empower') {
			var firstItem = (_spec.items && _spec.items.length > 0) ? _spec.items[0] : null;
			centerImg   = (firstItem && (firstItem.overlayIcon || firstItem.icon)) || 'ui/wx_icons/wx_icon_qi.png';
			centerCls   = 'is-medallion';
			auraCls     = '';
			partMode    = 'qi';
			mandalaFast = ' is-fast';
			caption     = _spec.ritualCaption || ((kind === 'empower') ? '宿老灌顶 · 真气贯通百会……' : '周天运转 · 贯通武学关窍……');
		} else if (kind === 'sect_heal') {
			centerImg   = 'ui/wx_icons/wx_icon_health.png';
			centerCls   = 'is-medallion';
			auraCls     = ' is-jade';
			ringCls     = ' is-jade';
			partMode    = 'jade';
			mandalaFast = ' is-fast';
			caption     = _spec.ritualCaption || '真元涤脉 · 拔除沉疴内伤……';
		} else if (kind === 'spar') {
			centerImg   = 'ui/wx_icons/wx_icon_melee_skill.png';
			centerCls   = 'is-medallion';
			auraCls     = ' is-forge';
			ringCls     = ' is-anvil';
			partMode    = 'forge';
			mandalaFast = ' is-fast';
			caption     = _spec.ritualCaption || '演武拆招 · 剑气印证……';
		} else if (kind === 'disguise') {
			centerImg   = 'ui/wx_icons/wx_glyph_mirror.png';
			centerCls   = 'is-medallion';
			auraCls     = ' is-trial';
			ringCls     = ' is-jade';
			partMode    = 'smoke';
			mandalaFast = ' is-fast';
			caption     = _spec.ritualCaption || '铜镜烟岚 · 千面敛息……';
		} else if (kind === 'sect_relation') {
			var isOff = (_spec.outcome === 'fail');
			centerImg   = isOff ? 'ui/wx_icons/wx_seal_cinnabar.png' : (_spec.bannerImg || 'ui/wx_icons/wx_glyph_sect_token.png');
			centerCls   = 'is-medallion';
			auraCls     = isOff ? ' is-crimson' : '';
			ringCls     = isOff ? ' is-crimson' : '';
			partMode    = isOff ? 'smoke' : 'fire';
			mandalaFast = ' is-fast';
			caption     = _spec.ritualCaption || (isOff ? '拂袖断交 · 剑劈牌匾……' : '递帖奉茗 · 礼敬宗门……');
		} else if (kind === 'quest_reward') {
			centerImg   = _spec.bannerImg || 'ui/wx_icons/wx_glyph_sect_token.png';
			centerCls   = 'is-medallion';
			auraCls     = '';
			partMode    = 'fire';
			mandalaFast = ' is-fast';
			caption     = _spec.ritualCaption || '法帖缴令 · 宗门验功封赏……';
		} else if (kind === 'rumor_sect') {
			centerImg   = _spec.bannerImg || 'ui/wx_icons/wx_glyph_sect_token.png';
			centerCls   = 'is-medallion';
			auraCls     = '';
			partMode    = 'qi';
			mandalaFast = ' is-fast';
			caption     = _spec.ritualCaption || '茶肆暗访 · 舆图寻踪觅迹……';
		} else if (kind === 'tourney_payout') {
			centerImg   = 'ui/wx_icons/wx_asset_money.png';
			centerCls   = 'is-medallion';
			auraCls     = '';
			partMode    = 'fire';
			mandalaFast = ' is-fast';
			caption     = _spec.ritualCaption || '大庄家验票 · 核对朱印红盘……';
		} else if (kind === 'craft_manual' || kind === 'learn_manual' || kind === 'formula_unlock' || kind === 'herbs_gain' || kind === 'recruit') {
			var f0 = (_spec.items && _spec.items.length > 0) ? _spec.items[0] : null;
			centerImg   = (kind === 'recruit' && _spec.bannerImg)
				? _spec.bannerImg
				: ((f0 && f0.icon) || 'ui/wx_icons/wx_glyph_sect_token.png');
			centerCls   = 'is-medallion';
			partMode    = 'qi';
			mandalaFast = ' is-fast';
			if (kind === 'craft_manual') caption = '残页归序 · 装帧成册……';
			else if (kind === 'formula_unlock') caption = '展卷授诀 · 参悟丹方……';
			else if (kind === 'herbs_gain') caption = '药圃采撷 · 灵草入柜……';
			else if (kind === 'recruit') caption = '拜别师门 · 真传下山……';
			else caption = '展卷研习 · 领悟武学……';
		}

		return (
			'<div class="wx-fx-ritual-wrap">' +
				'<div class="wx-fx-ritual-core">' +
					'<img class="wx-fx-mandala-bg' + mandalaFast + '" src="coui://gfx/ui/wx_icons/wx_cultivation_mandala.png" alt=""/>' +
					'<div class="wx-fx-aura-glow' + auraCls + '"></div>' +
					'<div class="wx-fx-ring-wave' + ringCls + '"></div>' +
					'<img class="wx-fx-centerpiece ' + centerCls + '" src="' + wxEsc(toGfxUrl(centerImg)) + '" alt=""/>' +
					flyHtml +
				'</div>' +
				buildParticlesHtml(partMode) +
				'<div class="wx-fx-ritual-caption">' + caption + '</div>' +
				'<div class="wx-fx-ritual-skip-hint">点击任意处或按空格键立即亮宝</div>' +
			'</div>'
		);
	}

	function buildStarString(_count) {
		var c = parseInt(_count || 0, 10);
		if (c <= 0) return '无星';
		var s = '';
		for (var i = 0; i < c; i++) s += '★';
		return s;
	}

	function buildItemCardHtml(_item, _idx, _totalCount) {
		var singleCls = (_totalCount === 1) ? ' is-single' : '';
		var gradeNum  = (typeof _item.grade === 'number') ? _item.grade : 1;
		var gradeCls  = gradeNum >= 3 ? ' is-grade-3' : (gradeNum === 2 ? ' is-grade-2' : '');
		var bonusCls  = _item.isBonus ? ' is-bonus' : '';
		var delayAttr = (_idx > 0) ? (' style="-webkit-animation-delay:' + (_idx * 0.11).toFixed(2) + 's;animation-delay:' + (_idx * 0.11).toFixed(2) + 's;"') : '';

		var stampHtml = '';
		if (_item.gradeTitle) {
			var stCol = _item.gradeColor || '#d7b174';
			stampHtml = '<span class="wx-fx-card-stamp" style="color:' + wxEsc(stCol) + ';border-color:' + wxEsc(stCol) + ';">' + wxEsc(_item.gradeTitle) + '</span>';
		}

		var bonusHtml = _item.isBonus
			? '<span class="wx-fx-card-bonus-tag">紫气双丹</span>'
			: '';

		var subIcoHtml = _item.overlayIcon
			? ('<img class="wx-fx-medallion-sub" src="' + wxEsc(toGfxUrl(_item.overlayIcon)) + '" alt=""/>')
			: '';

		var subLine = '';
		if (_item.subLabel) {
			subLine = '<div class="wx-fx-card-sub">' + wxEsc(_item.subLabel) + '</div>';
		} else if (_item.auxTitle) {
			subLine = '<div class="wx-fx-card-sub" style="color:' + wxEsc(_item.auxColor || '#dda21f') + ';">丹韵药引：' + wxEsc(_item.auxTitle) + '</div>';
		}

		// Potency / Perfection Gauge
		var gaugeHtml = '';
		if (_item.isPill && typeof _item.potencyPct === 'number' && _item.potencyPct > 0) {
			var potPct = Math.max(12, Math.min(100, Math.round((_item.potencyPct - 70) * 1.15)));
			gaugeHtml =
				'<div class="wx-fx-gauge-wrap">' +
					'<div class="wx-fx-gauge-lbl">灵丹药效：<strong style="color:' + wxEsc(_item.gradeColor || '#ffe28a') + ';">' + _item.potencyPct + '%</strong></div>' +
					'<div class="wx-fx-gauge-track"><div class="wx-fx-gauge-fill" style="width:' + potPct + '%;background:' + wxEsc(_item.gradeColor || '#f0bc42') + ';"></div></div>' +
				'</div>';
		} else if (!_item.isPill && typeof _item.perfectionPct === 'number' && _item.perfectionPct >= 0) {
			var perfW = Math.max(6, Math.min(100, _item.perfectionPct));
			gaugeHtml =
				'<div class="wx-fx-gauge-wrap">' +
					'<div class="wx-fx-gauge-lbl">百工完美度：<strong style="color:' + wxEsc(_item.gradeColor || '#ffe28a') + ';">' + _item.perfectionPct + '%</strong></div>' +
					'<div class="wx-fx-gauge-track"><div class="wx-fx-gauge-fill" style="width:' + perfW + '%;background:' + wxEsc(_item.gradeColor || '#f0bc42') + ';"></div></div>' +
				'</div>';
		}

		// Rolled Equipment Stats Table
		var statsHtml = '';
		if (_item.statRows && _item.statRows.length > 0) {
			statsHtml += '<div class="wx-fx-stat-grid">';
			var maxRows = (_totalCount === 1) ? 6 : 4;
			for (var r = 0; r < _item.statRows.length && r < maxRows; r++) {
				var sr = _item.statRows[r];
				statsHtml +=
					'<div class="wx-fx-stat-row">' +
						'<span class="wx-fx-stat-k">' + wxEsc(sr.label) + '</span>' +
						(sr.range ? ('<span class="wx-fx-stat-r">(' + wxEsc(sr.range) + ')</span>') : '') +
						'<span class="wx-fx-stat-v">' + wxEsc(sr.cur) + '</span>' +
						'<div class="clear-both"></div>' +
					'</div>';
			}
			statsHtml += '</div>';
		}

		var descHtml = _item.description
			? ('<div class="wx-fx-card-desc">' + wxEsc(_item.description) + '</div>')
			: '';

		return (
			'<div class="wx-fx-item-card' + singleCls + gradeCls + bonusCls + '"' + delayAttr + '>' +
				bonusHtml +
				stampHtml +
				'<div class="wx-fx-medallion">' +
					'<img class="wx-fx-medallion-img" src="' + wxEsc(toGfxUrl(_item.icon)) + '" alt=""/>' +
					subIcoHtml +
				'</div>' +
				'<div class="wx-fx-card-name">' + wxEsc(_item.name) + '</div>' +
				subLine +
				gaugeHtml +
				statsHtml +
				descHtml +
			'</div>'
		);
	}

	function buildWashRevealHtml(_spec) {
		var ok = (_spec.outcome === 'success');
		var warded = (_spec.outcome === 'warded');
		var oldStr = buildStarString(_spec.oldStars);
		var newStr = ok ? buildStarString(_spec.newStars) : oldStr;
		var transHtml = ok
			? ('<span class="wx-fx-stars-old">' + wxEsc(oldStr) + '</span>' +
			   '<span class="wx-fx-delta-arrow">➔</span>' +
			   '<span class="wx-fx-stars-new">' + wxEsc(newStr) + '</span>')
			: (warded
				? '<span style="color:#8af0a8;font-size:2.0rem;">【造化护脉 · 奇经八脉完好无损】</span>'
				: ('<span style="color:#ff8a7c;font-size:2.0rem;">' + (_spec.gotPerm ? '【真气逆冲 · 遗留永久经脉暗疾】' : '【冲关受阻 · 经脉震荡】') + '</span>'));
		var repNote = (ok && _spec.isReplaceMode && _spec.replaceAttrName)
			? ('<div style="color:#d4b482;font-size:1.3rem;margin-top:0.35rem;">易筋移星：已洗去「' + wxEsc(_spec.replaceAttrName) + '」原有星级</div>')
			: '';

		return (
			'<div class="wx-fx-wash-box">' +
				'<div class="wx-fx-wash-attr-row">' +
					'<img class="wx-fx-wash-attr-ico" src="' + wxEsc(toGfxUrl(_spec.targetAttrIcon, 'ui/wx_icons/wx_icon_qi.png')) + '" alt=""/>' +
					'<span class="wx-fx-wash-attr-name">' + wxEsc(_spec.targetAttrName || '根骨') + '</span>' +
				'</div>' +
				'<div class="wx-fx-stars-transition">' + transHtml + '</div>' +
				repNote +
				'<div class="wx-fx-wash-status">' + wxEsc(_spec.message || '') + '</div>' +
			'</div>'
		);
	}

	function buildCustomRevealHtml(_spec) {
		var kind = _spec.kind || '';
		if (kind === 'sect_heal') {
			var hList = _spec.healedList || [];
			var rowsH = '';
			for (var hi = 0; hi < hList.length && hi < 8; hi++) {
				var hb = hList[hi];
				rowsH +=
					'<div class="wx-fx-ledger-row">' +
						'<span class="wx-fx-ledger-name">' + wxEsc(hb.name || '侠客') + '</span>' +
						'<span class="wx-fx-ledger-tag is-jade">' + wxEsc(hb.tags || '经脉尽复 · 气血回满') + '</span>' +
						'<div class="clear-both"></div>' +
					'</div>';
			}
			return (
				'<div class="wx-fx-custom-box is-jade">' +
					'<div class="wx-fx-custom-medallion is-jade"><img src="' + wxEsc(toGfxUrl('ui/wx_icons/wx_icon_health.png')) + '" alt=""/></div>' +
					'<div class="wx-fx-ledger-list">' + (rowsH || '<div class="wx-fx-ledger-row">全队伤势尽数涤清！</div>') + '</div>' +
					'<div class="wx-fx-wash-status">' + wxEsc(_spec.message || '') + '</div>' +
				'</div>'
			);
		}
		if (kind === 'spar') {
			var pUrl = '';
			if (_spec.broImagePath) {
				var pfx = (typeof Path !== 'undefined' && Path.PROCEDURAL) ? Path.PROCEDURAL : 'coui://';
				pUrl = (_spec.broImagePath.indexOf('coui://') === 0 || _spec.broImagePath.indexOf('procedural://') === 0) ? _spec.broImagePath : (pfx + _spec.broImagePath);
			}
			var bustHtml = pUrl
				? ('<div class="wx-fx-custom-medallion is-portrait"><img src="' + wxEsc(pUrl) + '" alt=""/></div>')
				: ('<div class="wx-fx-custom-medallion"><img src="' + wxEsc(toGfxUrl('ui/wx_icons/wx_icon_melee_skill.png')) + '" alt=""/></div>');
			var verdict = _spec.verdict || '点到为止 · 互有启发';
			var badgesS = '';
			if (typeof _spec.relGain === 'number') {
				badgesS += '<span class="wx-fx-reward-pill is-gold">宗门交情 +' + _spec.relGain + '（→ ' + (_spec.newRel || 0) + '）</span>';
			}
			if (typeof _spec.expGain === 'number' && _spec.expGain > 0) {
				badgesS += '<span class="wx-fx-reward-pill is-jade">全槽功法火候 +' + _spec.expGain + '</span>';
			}
			return (
				'<div class="wx-fx-custom-box">' +
					'<span class="wx-fx-slam-badge' + (_spec.strongWin ? ' is-gold' : '') + '">' + wxEsc(verdict) + '</span>' +
					bustHtml +
					'<div class="wx-fx-card-name">' + wxEsc(_spec.broName || '登台侠客') + '</div>' +
					'<div class="wx-fx-reward-pills">' + badgesS + '</div>' +
					'<div class="wx-fx-wash-status">' + wxEsc(_spec.message || '') + '</div>' +
				'</div>'
			);
		}
		if (kind === 'rumor_sect') {
			var bUrl = toGfxUrl(_spec.bannerImg || 'ui/wx_icons/wx_glyph_sect_token.png');
			return (
				'<div class="wx-fx-custom-box">' +
					'<span class="wx-fx-slam-badge is-gold">舆图落印</span>' +
					'<div class="wx-fx-custom-medallion"><img src="' + wxEsc(bUrl) + '" alt=""/></div>' +
					'<div class="wx-fx-card-name">' + wxEsc(_spec.sanctumName || _spec.sectName || '隐世山门') + '</div>' +
					'<div class="wx-fx-reward-pills">' +
						(_spec.regionName ? ('<span class="wx-fx-reward-pill is-gold">' + wxEsc(_spec.regionName) + '</span>') : '') +
						(_spec.dirNote ? ('<span class="wx-fx-reward-pill is-jade">' + wxEsc(_spec.dirNote) + '</span>') : '') +
					'</div>' +
					'<div class="wx-fx-wash-status">' + wxEsc(_spec.message || '') + '</div>' +
				'</div>'
			);
		}
		if (kind === 'sect_relation') {
			var isNeg = (_spec.outcome === 'fail' || (_spec.delta || 0) < 0);
			var signStr = (_spec.delta || 0) >= 0 ? ('+' + (_spec.delta || 0)) : String(_spec.delta || 0);
			var bIco = isNeg ? 'ui/wx_icons/wx_seal_cinnabar.png' : (_spec.bannerImg || 'ui/wx_icons/wx_glyph_sect_token.png');
			var stampTxt = _spec.stampText || (isNeg ? '结下梁子' : '交情大涨');
			return (
				'<div class="wx-fx-custom-box' + (isNeg ? ' is-crimson' : '') + '">' +
					'<span class="wx-fx-slam-badge' + (isNeg ? ' is-crimson' : ' is-gold') + '">' + wxEsc(stampTxt) + '</span>' +
					'<div class="wx-fx-custom-medallion' + (isNeg ? ' is-crimson' : '') + '"><img src="' + wxEsc(toGfxUrl(bIco)) + '" alt=""/></div>' +
					'<div class="wx-fx-card-name">' + wxEsc(_spec.sectName || '江湖宗门') + '</div>' +
					'<div class="wx-fx-delta-bar">' +
						'<span style="color:#b79c73;">原交情 ' + (_spec.oldRel || 0) + '</span>' +
						'<span class="wx-fx-delta-arrow">➔</span>' +
						'<span style="color:' + (isNeg ? '#ff8e80' : '#7ee29a') + ';">' + (_spec.newRel || 0) + '（' + signStr + '）</span>' +
					'</div>' +
					'<div class="wx-fx-wash-status">' + wxEsc(_spec.message || '') + '</div>' +
				'</div>'
			);
		}
		if (kind === 'disguise') {
			var dList = _spec.deltas || [];
			var rowsD = '';
			for (var di = 0; di < dList.length; di++) {
				var de = dList[di];
				rowsD +=
					'<div class="wx-fx-ledger-row">' +
						'<span class="wx-fx-ledger-name">' + wxEsc(de.name || '') + '</span>' +
						'<span class="wx-fx-ledger-tag is-jade">' + de.oldRel + ' ➔ ' + de.newRel + (de.tag ? (' · ' + wxEsc(de.tag)) : '') + '</span>' +
						'<div class="clear-both"></div>' +
					'</div>';
			}
			var huntBadge = (_spec.despawnedHunt && _spec.despawnedHunt > 0)
				? '<span class="wx-fx-slam-badge is-jade">已甩脱城外追杀执事队</span>'
				: '<span class="wx-fx-slam-badge is-gold">' + wxEsc(_spec.stampText || '千面敛息') + '</span>';
			return (
				'<div class="wx-fx-custom-box is-jade">' +
					huntBadge +
					'<div class="wx-fx-custom-medallion is-jade"><img src="' + wxEsc(toGfxUrl('ui/wx_icons/wx_glyph_mirror.png')) + '" alt=""/></div>' +
					'<div class="wx-fx-ledger-list">' + rowsD + '</div>' +
					'<div class="wx-fx-wash-status">' + wxEsc(_spec.message || '') + '</div>' +
				'</div>'
			);
		}
		if (kind === 'tourney_payout') {
			var amtStr = String(Math.max(0, parseInt(_spec.amount || 0, 10))).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
			return (
				'<div class="wx-fx-custom-box">' +
					'<span class="wx-fx-slam-badge is-gold">朱印红盘</span>' +
					'<div class="wx-fx-custom-medallion"><img src="' + wxEsc(toGfxUrl('ui/wx_icons/wx_asset_money.png')) + '" alt=""/></div>' +
					'<div class="wx-fx-payout-amt">+' + amtStr + ' 两</div>' +
					'<div class="wx-fx-card-sub">足色纹银（含本金）已尽数点入义社盘缠</div>' +
					'<div class="wx-fx-wash-status">' + wxEsc(_spec.message || '') + '</div>' +
				'</div>'
			);
		}
		return '';
	}

	function resolveConfirmLabel(_spec) {
		var kind = _spec.kind || 'alchemy';
		if (kind === 'alchemy') return '收入行囊';
		if (kind === 'forge') return '收下兵甲';
		if (kind === 'reforge') return '收起神兵';
		if (kind === 'wash') return '运功收势';
		if (kind === 'breakthrough' || kind === 'empower') return '纳气归元';
		if (kind === 'craft_manual') return '收入藏经阁';
		if (kind === 'learn_manual') return '谨记于心';
		if (kind === 'formula_unlock') return '载入丹经';
		if (kind === 'herbs_gain') return '纳入药柜';
		if (kind === 'recruit') return '迎入义社';
		if (kind === 'quest_reward') return '拜谢领赏';
		if (kind === 'sect_heal') return '谢过医者';
		if (kind === 'spar') return '抱拳承让';
		if (kind === 'rumor_sect') return '铭记方位';
		if (kind === 'sect_relation') return (_spec.outcome === 'fail') ? '拂袖而去' : '抱拳告辞';
		if (kind === 'disguise') return '敛息离去';
		if (kind === 'tourney_payout') return '收入囊中';
		return '知晓';
	}

	function buildRevealPhaseHtml(_spec) {
		var kind = _spec.kind || 'alchemy';
		var items = _spec.items || [];
		var bodyHtml = '';

		if (kind === 'reforge') {
			var pityHtml = _spec.usedPity ? '<span class="wx-fx-pity-pill">五锤保底激发</span>' : '';
			bodyHtml +=
				'<div class="wx-fx-delta-bar">' +
					'<span style="color:' + wxEsc(_spec.oldGradeColor || '#5ec47a') + ';">' + wxEsc(_spec.oldGradeTitle || '良工') + ' ' + (_spec.oldPerfectionPct || 0) + '%</span>' +
					'<span class="wx-fx-delta-arrow">➔</span>' +
					'<span style="color:' + wxEsc(_spec.newGradeColor || '#f0bc42') + ';">' + wxEsc(_spec.newGradeTitle || '百炼') + ' ' + (_spec.newPerfectionPct || 0) + '%</span>' +
					pityHtml +
				'</div>';
		}

		if (kind === 'quest_reward' && _spec.rewards) {
			var rw = _spec.rewards;
			bodyHtml += '<div class="wx-fx-reward-pills">';
			if (rw.silver) bodyHtml += '<span class="wx-fx-reward-pill is-gold">纹银 +' + rw.silver + ' 两</span>';
			if (rw.renown) bodyHtml += '<span class="wx-fx-reward-pill is-purple">江湖威名 +' + rw.renown + '</span>';
			if (rw.rel)    bodyHtml += '<span class="wx-fx-reward-pill is-jade">宗门交情 +' + rw.rel + (typeof rw.newRel === 'number' ? ('（→ ' + rw.newRel + '）') : '') + '</span>';
			bodyHtml += '</div>';
		}

		if (kind === 'wash') {
			bodyHtml += buildWashRevealHtml(_spec);
		} else if (kind === 'sect_heal' || kind === 'spar' || kind === 'rumor_sect' || kind === 'sect_relation' || kind === 'disguise' || kind === 'tourney_payout') {
			bodyHtml += buildCustomRevealHtml(_spec);
		} else if (items.length > 0) {
			var showCount = Math.min(items.length, 3);
			bodyHtml += '<div class="wx-fx-cards-row">';
			for (var i = 0; i < items.length && i < 6; i++) {
				bodyHtml += buildItemCardHtml(items[i], i, showCount);
			}
			bodyHtml += '</div>';
		} else if (_spec.message) {
			bodyHtml += '<div class="wx-fx-insight-box" style="text-align:center;">' + wxEsc(_spec.message) + '</div>';
		}

		if (_spec.discoveredFormulaName) {
			bodyHtml += '<div class="wx-fx-discovery-ribbon">【新悟古方】《' + wxEsc(_spec.discoveredFormulaName) + '》配伍法度已永久载入《丹经手札》！</div>';
		}
		if (_spec.insight) {
			bodyHtml += '<div class="wx-fx-insight-box">' + wxEsc(_spec.insight) + '</div>';
		}

		var confirmText = resolveConfirmLabel(_spec);
		var fastChk = state.fastMode ? ' checked="checked"' : '';

		return (
			'<div class="wx-fx-reveal-wrap">' +
				'<img class="wx-fx-reveal-halo" src="coui://gfx/ui/wx_icons/wx_cultivation_mandala.png" alt=""/>' +
				'<div class="wx-fx-reveal-hdr">' +
					'<div class="wx-fx-reveal-title">' + wxEsc(_spec.title || '功成出炉') + '</div>' +
					(_spec.subtitle ? ('<div class="wx-fx-reveal-sub">' + wxEsc(_spec.subtitle) + '</div>') : '') +
				'</div>' +
				'<div class="wx-fx-divider"></div>' +
				bodyHtml +
				'<div class="wx-fx-foot">' +
					'<span class="wx-fx-confirm-btn" data-fx-act="close">' + wxEsc(confirmText) + '</span>' +
					'<label class="wx-fx-fast-toggle" title="勾选后将略过起火与锻打蓄力，直接呈现成丹与成器亮宝"><input type="checkbox" data-fx-fast="1"' + fastChk + '/>快速亮宝</label>' +
				'</div>' +
			'</div>'
		);
	}

	function closeShowcase(_suppressOnDone) {
		clearTimers();
		$('.wx-fx-backdrop').remove();
		$(document).off('keydown.wxShowcase');
		var done = _suppressOnDone ? null : state.onDone;
		state.activeSpec = null;
		state.phase = 'idle';
		state.onDone = null;
		state.pending = false;
		state.pendingReady = false;
		state.pendingSkip = false;
		state.pendingSpec = null;
		state.pendingHandle = null;
		state.pendingEnterReveal = null;
		state.pendingBackdrop = null;
		if (typeof done === 'function') {
			try { done(); } catch (_eCb) {}
		}
	}

	function fireRevealSound(_sqHandle, _spec) {
		var kind = _spec.kind || 'alchemy';
		var outc = _spec.outcome || 'success';
		if (kind === 'alchemy') {
			if (outc === 'trial') playSound(_sqHandle, 'alchemy_trial');
			else if (outc === 'crit') playSound(_sqHandle, 'alchemy_crit');
			else playSound(_sqHandle, 'alchemy_success');
		} else if (kind === 'forge' || kind === 'reforge') {
			if (outc === 'crit' || outc === 'great') playSound(_sqHandle, 'forge_masterwork');
			else playSound(_sqHandle, 'forge_quench');
		} else if (kind === 'wash') {
			playSound(_sqHandle, outc === 'success' ? 'wash_success' : 'wash_fail');
		} else if (kind === 'breakthrough' || kind === 'empower' || kind === 'formula_unlock' || kind === 'recruit') {
			playSound(_sqHandle, 'cultivate_breakthrough');
		} else if (kind === 'sect_heal') {
			playSound(_sqHandle, 'heal_chime');
		} else if (kind === 'spar') {
			playSound(_sqHandle, _spec.strongWin ? 'cultivate_breakthrough' : 'spar_clash');
		} else if (kind === 'disguise') {
			playSound(_sqHandle, 'disguise_smoke');
		} else if (kind === 'sect_relation') {
			playSound(_sqHandle, outc === 'fail' ? 'offend_crack' : 'sect_gain');
		} else if (kind === 'quest_reward' || kind === 'tourney_payout') {
			playSound(_sqHandle, 'sect_gain');
		} else if (kind === 'rumor_sect') {
			playSound(_sqHandle, 'manual_learn');
		} else if (kind === 'craft_manual') {
			playSound(_sqHandle, 'manual_craft');
		} else {
			playSound(_sqHandle, 'manual_learn');
		}
	}

	function fireBuildupSounds(_sqHandle, _spec) {
		var kind = _spec.kind || 'alchemy';
		if (kind === 'alchemy') {
			playSound(_sqHandle, 'alchemy_start');
		} else if (kind === 'forge' || kind === 'reforge') {
			playSound(_sqHandle, 'forge_hammer');
			pushTimer(function () { playSound(_sqHandle, 'forge_hammer'); }, 300);
			pushTimer(function () { playSound(_sqHandle, 'forge_quench'); }, 600);
		} else if (kind === 'wash') {
			playSound(_sqHandle, 'wash_start');
		} else if (kind === 'breakthrough' || kind === 'empower') {
			playSound(_sqHandle, 'cultivate_infuse');
		} else if (kind === 'spar') {
			playSound(_sqHandle, 'spar_clash');
			pushTimer(function () { playSound(_sqHandle, 'spar_clash'); }, 280);
		} else if (kind === 'sect_heal') {
			playSound(_sqHandle, 'wash_start');
		} else if (kind === 'disguise') {
			playSound(_sqHandle, 'disguise_smoke');
		} else if (kind === 'sect_relation') {
			playSound(_sqHandle, (_spec.outcome === 'fail') ? 'offend_crack' : 'sweep_whoosh');
		} else if (kind === 'craft_manual') {
			playSound(_sqHandle, 'manual_craft');
		} else {
			playSound(_sqHandle, 'sect_gain');
		}
	}

	function playShowcase(_spec, _opts) {
		if (!_spec || typeof _spec !== 'object') return false;
		var opts = _opts || {};
		var sqHandle = opts.sqHandle || window.WX_SectRPCHandle || null;

		closeShowcase();
		state.activeSpec = _spec;
		state.onDone = opts.onClose || null;

		var host = $('.root-screen:first');
		if (!host.length) host = $(document.body);

		var outcome = _spec.outcome || 'success';
		var backdrop = $(
			'<div class="wx-fx-backdrop ui-control">' +
				'<div class="wx-fx-stage is-outcome-' + wxEsc(outcome) + '">' +
					'<div class="wx-fx-corner is-tl"></div>' +
					'<div class="wx-fx-corner is-tr"></div>' +
					'<div class="wx-fx-corner is-bl"></div>' +
					'<div class="wx-fx-corner is-br"></div>' +
					'<div class="wx-fx-flash"></div>' +
					'<div class="wx-fx-stage-body"></div>' +
				'</div>' +
			'</div>'
		);
		host.append(backdrop);

		var stageBody = backdrop.find('.wx-fx-stage-body');
		var flashEl   = backdrop.find('.wx-fx-flash');

		function enterReveal() {
			clearTimers();
			state.phase = 'reveal';
			var fCls = 'is-fire';
			if (_spec.kind === 'forge' || _spec.kind === 'reforge') fCls = 'is-quench';
			else if (_spec.kind === 'sect_heal') fCls = 'is-jade';
			else if (_spec.kind === 'disguise') fCls = 'is-smoke';
			else if (outcome === 'fail') fCls = 'is-fail';
			else if (outcome === 'trial') fCls = 'is-smoke';

			flashEl.removeClass('is-fire is-quench is-fail is-smoke is-jade');
			if (flashEl[0]) { var _rf = flashEl[0].offsetWidth; }
			flashEl.addClass(fCls);

			stageBody.html(buildRevealPhaseHtml(_spec));
			fireRevealSound(sqHandle, _spec);

			stageBody.find('[data-fx-act="close"]').on('click', function (_e) {
				_e.stopPropagation();
				closeShowcase();
			});
			stageBody.find('[data-fx-fast="1"]').on('click', function (_e) {
				_e.stopPropagation();
			}).on('change', function () {
				state.fastMode = $(this).is(':checked');
				try {
					if (window.localStorage) {
						window.localStorage.setItem('wx_showcase_fast', state.fastMode ? '1' : '0');
					}
				} catch (_eLs2) {}
			});
		}

		// Backdrop click: skip buildup immediately if in ritual phase; dismiss if already revealed
		backdrop.on('click', function (_e) {
			if ($(_e.target).closest('[data-fx-fast="1"], .wx-fx-fast-toggle').length) return;
			if (state.phase === 'ritual') {
				enterReveal();
			} else {
				closeShowcase();
			}
		});

		$(document).on('keydown.wxShowcase', function (_e) {
			if (_e.keyCode === 27 || _e.keyCode === 32 || _e.keyCode === 13) {
				if (state.phase === 'ritual') {
					enterReveal();
				} else {
					closeShowcase();
				}
				_e.stopPropagation();
				return false;
			}
		});

		if (state.fastMode) {
			enterReveal();
		} else {
			state.phase = 'ritual';
			stageBody.html(buildRitualPhaseHtml(_spec));
			fireBuildupSounds(sqHandle, _spec);
			var kind = _spec.kind || 'alchemy';
			var durMs = 820;
			if (kind === 'forge' || kind === 'reforge') durMs = 860;
			else if (kind === 'wash') durMs = 860;
			else if (kind === 'spar' || kind === 'disguise' || kind === 'sect_heal') durMs = 660;
			else if (kind === 'craft_manual' || kind === 'learn_manual' || kind === 'formula_unlock' || kind === 'herbs_gain' || kind === 'recruit' || kind === 'quest_reward' || kind === 'rumor_sect' || kind === 'sect_relation' || kind === 'tourney_payout') durMs = 540;
			pushTimer(enterReveal, durMs);
		}
		return true;
	}

	// Tier-2 In-place Qi / Medicinal Pulse on a specific DOM card (slot or panel)
	function pulseElement(_$el, _opts) {
		var opts = _opts || {};
		if (opts.sqHandle && opts.soundCue) {
			playSound(opts.sqHandle, opts.soundCue);
		}
		if (!_$el || !_$el.length) return;
		var theme = opts.theme || 'gold';
		var tCls = (theme === 'jade') ? ' is-jade' : ((theme === 'crimson') ? ' is-crimson' : '');

		var curPos = _$el.css('position');
		if (!curPos || curPos === 'static') {
			_$el.css('position', 'relative');
		}

		var surge = $('<div class="wx-fx-slot-surge' + tCls + '"></div>');
		_$el.append(surge);
		setTimeout(function () { surge.remove(); }, 950);

		if (opts.floatText) {
			var icoHtml = opts.icon ? ('<img src="' + wxEsc(toGfxUrl(opts.icon)) + '" alt=""/>') : '';
			var chip = $('<div class="wx-fx-float-chip' + tCls + '">' + icoHtml + wxEsc(opts.floatText) + '</div>');
			_$el.append(chip);
			setTimeout(function () { chip.remove(); }, 1420);
		}
	}

	// Tier-2 In-Place Pill Absorption FX (pill orb arcs into brother portrait/header + bursts effect chips)
	function flyPillToTarget(_$target, _opts) {
		var opts = _opts || {};
		if (opts.sqHandle) {
			playSound(opts.sqHandle, opts.soundCue || 'pill_drink');
		}
		var $t = (_$target && _$target.length) ? _$target : $('.root-screen:first');
		if (!$t || !$t.length) return;
		var curPos = $t.css('position');
		if (!curPos || curPos === 'static') $t.css('position', 'relative');

		var theme = opts.theme || 'jade';
		var tCls = (theme === 'gold') ? '' : ((theme === 'crimson') ? ' is-crimson' : ' is-jade');
		var orbUrl = toGfxUrl(opts.pillIcon || 'ui/wx_icons/wx_asset_medicine.png');
		var orb = $('<div class="wx-fx-pill-orb' + tCls + '"><img src="' + wxEsc(orbUrl) + '" alt=""/></div>');
		$t.append(orb);
		setTimeout(function () { orb.remove(); }, 680);

		setTimeout(function () {
			var surge = $('<div class="wx-fx-slot-surge' + tCls + '"></div>');
			$t.append(surge);
			setTimeout(function () { surge.remove(); }, 920);

			var chips = opts.chips || [];
			if (!chips.length && opts.floatText) chips = [opts.floatText];
			for (var ci = 0; ci < chips.length && ci < 3; ci++) {
				(function (_idx, _txt) {
					setTimeout(function () {
						var icoHtml = (_idx === 0 && opts.pillIcon) ? ('<img src="' + wxEsc(orbUrl) + '" alt=""/>') : '';
						var topOff = 10 + _idx * 22;
						var chip = $('<div class="wx-fx-float-chip' + tCls + '" style="top:' + topOff + '%;">' + icoHtml + wxEsc(_txt) + '</div>');
						$t.append(chip);
						setTimeout(function () { chip.remove(); }, 1460);
					}, _idx * 170);
				})(ci, chips[ci]);
			}
		}, 240);
	}

	// Tier-2 In-Place Meridian Slot Infuse FX (source orb spirals in + golden charge bar sweep + floating exp chip)
	function infuseSlotFx(_$slotEl, _opts) {
		var opts = _opts || {};
		if (opts.sqHandle) {
			playSound(opts.sqHandle, opts.soundCue || 'cultivate_infuse');
		}
		if (!_$slotEl || !_$slotEl.length) return;
		var curPos = _$slotEl.css('position');
		if (!curPos || curPos === 'static') _$slotEl.css('position', 'relative');

		if (opts.sourceIcon) {
			var sOrb = $('<div class="wx-fx-infuse-orb"><img src="' + wxEsc(toGfxUrl(opts.sourceIcon)) + '" alt=""/></div>');
			_$slotEl.append(sOrb);
			setTimeout(function () { sOrb.remove(); }, 620);
		}
		var sweep = $('<div class="wx-fx-bar-sweep"></div>');
		_$slotEl.append(sweep);
		setTimeout(function () { sweep.remove(); }, 760);

		pulseElement(_$slotEl, {
			theme: opts.theme || 'gold',
			icon: opts.sourceIcon || 'ui/wx_icons/wx_icon_qi.png',
			floatText: opts.floatText || ('+' + (opts.expAmount || 0) + ' 火候')
		});

		if (opts.subChip) {
			setTimeout(function () {
				var sc = $('<div class="wx-fx-float-chip is-jade" style="top:34%;">' + wxEsc(opts.subChip) + '</div>');
				_$slotEl.append(sc);
				setTimeout(function () { sc.remove(); }, 1380);
			}, 190);
		}
	}

	// Tier-2 In-Place Sweep / Rename Shimmer FX (non-blocking gold/jade pulse + floating summary chip + whoosh cue)
	function sweepFx(_$target, _opts) {
		var opts = _opts || {};
		if (opts.sqHandle) {
			playSound(opts.sqHandle, opts.soundCue || 'sweep_whoosh');
		}
		var $t = (_$target && _$target.length) ? _$target : $('.root-screen:first');
		if (!$t || !$t.length) return;
		var curPos = $t.css('position');
		if (!curPos || curPos === 'static') $t.css('position', 'relative');

		var sh = $('<div class="wx-fx-bar-sweep"></div>');
		$t.append(sh);
		setTimeout(function () { sh.remove(); }, 740);

		pulseElement($t, {
			theme: opts.theme || 'gold',
			icon: opts.icon || 'ui/wx_icons/wx_glyph_herb_cabinet.png',
			floatText: opts.floatText || ''
		});
	}

	// Upgraded Animated Wuxia Result Plaque (replaces flat static text toasts!)
	function showPlaque(_opts) {
		var opts = _opts || {};
		var msg = opts.message || '';
		if (!msg) return;

		if (state.plaqueTimer !== null) {
			clearTimeout(state.plaqueTimer);
			state.plaqueTimer = null;
		}
		$('.wx-fx-plaque').remove();

		if (opts.sqHandle && opts.soundCue) {
			playSound(opts.sqHandle, opts.soundCue);
		}

		var host = $('.root-screen:first');
		if (!host.length) host = $(document.body);

		var themeCls = opts.isError ? ' is-err' : (opts.theme === 'jade' ? ' is-jade' : '');
		var icoUrl = toGfxUrl(opts.icon || (opts.isError ? 'ui/wx_icons/wx_seal_cinnabar.png' : 'ui/wx_icons/wx_glyph_sect_token.png'));
		var titleTxt = opts.title || (opts.isError ? '未能成行' : '江湖传讯');

		var el = $(
			'<div class="wx-fx-plaque' + themeCls + '">' +
				'<div class="wx-fx-plaque-ico"><img src="' + wxEsc(icoUrl) + '" alt=""/></div>' +
				'<div class="wx-fx-plaque-body">' +
					'<div class="wx-fx-plaque-title">' + wxEsc(titleTxt) + '</div>' +
					'<div class="wx-fx-plaque-msg">' + wxEsc(msg) + '</div>' +
				'</div>' +
				'<div class="clear-both"></div>' +
			'</div>'
		);
		host.append(el);

		var holdMs = opts.durationMs || 4200;
		state.plaqueTimer = setTimeout(function () {
			el.fadeOut(280, function () { el.remove(); });
			state.plaqueTimer = null;
		}, holdMs);
	}

	// 0ms Instant-Launch Pending Ritual: starts furnace/anvil animation on the exact frame of user click
	// while the Squirrel RPC executes in parallel, then smoothly reveals when resolvePending() arrives!
	function beginPending(_previewSpec, _opts) {
		var spec = _previewSpec || { kind: 'alchemy' };
		var opts = _opts || {};
		var sqHandle = opts.sqHandle || window.WX_SectRPCHandle || null;

		closeShowcase(true);
		state.activeSpec = spec;
		state.onDone = opts.onClose || null;
		state.pending = true;
		state.pendingReady = !!state.fastMode;
		state.pendingSkip = false;
		state.pendingSpec = null;
		state.pendingHandle = sqHandle;

		var host = $('.root-screen:first');
		if (!host.length) host = $(document.body);

		var backdrop = $(
			'<div class="wx-fx-backdrop ui-control">' +
				'<div class="wx-fx-stage is-outcome-success">' +
					'<div class="wx-fx-corner is-tl"></div>' +
					'<div class="wx-fx-corner is-tr"></div>' +
					'<div class="wx-fx-corner is-bl"></div>' +
					'<div class="wx-fx-corner is-br"></div>' +
					'<div class="wx-fx-flash"></div>' +
					'<div class="wx-fx-stage-body"></div>' +
				'</div>' +
			'</div>'
		);
		host.append(backdrop);
		state.pendingBackdrop = backdrop;

		var stageEl   = backdrop.find('.wx-fx-stage:first');
		var stageBody = backdrop.find('.wx-fx-stage-body');
		var flashEl   = backdrop.find('.wx-fx-flash');

		function enterResolvedReveal(_finalSpec) {
			if (!state.pending && state.phase === 'reveal') return;
			clearTimers();
			state.pending = false;
			state.phase = 'reveal';
			state.activeSpec = _finalSpec;

			var outcome = _finalSpec.outcome || 'success';
			stageEl.removeClass('is-outcome-success is-outcome-crit is-outcome-great is-outcome-trial is-outcome-fail is-outcome-warded')
				.addClass('is-outcome-' + wxEsc(outcome));

			var fCls = 'is-fire';
			if (_finalSpec.kind === 'forge' || _finalSpec.kind === 'reforge') fCls = 'is-quench';
			else if (_finalSpec.kind === 'sect_heal') fCls = 'is-jade';
			else if (_finalSpec.kind === 'disguise') fCls = 'is-smoke';
			else if (outcome === 'fail') fCls = 'is-fail';
			else if (outcome === 'trial') fCls = 'is-smoke';

			flashEl.removeClass('is-fire is-quench is-fail is-smoke is-jade');
			if (flashEl[0]) { var _rf = flashEl[0].offsetWidth; }
			flashEl.addClass(fCls);

			stageBody.html(buildRevealPhaseHtml(_finalSpec));
			fireRevealSound(state.pendingHandle || sqHandle, _finalSpec);

			stageBody.find('[data-fx-act="close"]').on('click', function (_e) {
				_e.stopPropagation();
				closeShowcase(false);
			});
			stageBody.find('[data-fx-fast="1"]').on('click', function (_e) {
				_e.stopPropagation();
			}).on('change', function () {
				state.fastMode = $(this).is(':checked');
				try {
					if (window.localStorage) {
						window.localStorage.setItem('wx_showcase_fast', state.fastMode ? '1' : '0');
					}
				} catch (_eLsP) {}
			});
		}

		state.pendingEnterReveal = enterResolvedReveal;

		backdrop.on('click', function (_e) {
			if ($(_e.target).closest('[data-fx-fast="1"], .wx-fx-fast-toggle').length) return;
			if (state.phase === 'ritual') {
				state.pendingSkip = true;
				if (state.pendingSpec) {
					enterResolvedReveal(state.pendingSpec);
				}
			} else if (state.phase === 'reveal') {
				closeShowcase(false);
			}
		});

		$(document).on('keydown.wxShowcase', function (_e) {
			if (_e.keyCode === 27 || _e.keyCode === 32 || _e.keyCode === 13) {
				if (state.phase === 'ritual') {
					state.pendingSkip = true;
					if (state.pendingSpec) {
						enterResolvedReveal(state.pendingSpec);
					}
				} else if (state.phase === 'reveal') {
					closeShowcase(false);
				}
				_e.stopPropagation();
				return false;
			}
		});

		state.phase = 'ritual';
		stageBody.html(buildRitualPhaseHtml(spec));
		if (!state.fastMode) {
			fireBuildupSounds(sqHandle, spec);
			var kind = spec.kind || 'alchemy';
			var durMs = (kind === 'forge' || kind === 'reforge' || kind === 'wash') ? 820 : 780;
			pushTimer(function () {
				state.pendingReady = true;
				if (state.pendingSpec && state.pendingEnterReveal) {
					state.pendingEnterReveal(state.pendingSpec);
				}
			}, durMs);
		}
		return true;
	}

	function resolvePending(_finalSpec, _opts) {
		if (!_finalSpec || typeof _finalSpec !== 'object') {
			abortPending();
			return false;
		}
		var opts = _opts || {};
		if (!state.pending || !state.pendingEnterReveal || !$('.wx-fx-backdrop').length) {
			return playShowcase(_finalSpec, opts);
		}
		if (opts.sqHandle) state.pendingHandle = opts.sqHandle;
		if (opts.onClose) state.onDone = opts.onClose;
		state.pendingSpec = _finalSpec;
		if (state.pendingReady || state.pendingSkip || state.fastMode) {
			state.pendingEnterReveal(_finalSpec);
		}
		return true;
	}

	function abortPending() {
		if (state.pending) {
			closeShowcase(true);
		}
	}

	window.WX_Showcase = {
		play: playShowcase,
		beginPending: beginPending,
		resolvePending: resolvePending,
		abortPending: abortPending,
		pulseElement: pulseElement,
		flyPillToTarget: flyPillToTarget,
		infuseSlotFx: infuseSlotFx,
		sweepFx: sweepFx,
		plaque: showPlaque,
		close: closeShowcase,
		isFastMode: function () { return !!state.fastMode; },
		setFastMode: function (_v) {
			state.fastMode = !!_v;
			try {
				if (window.localStorage) window.localStorage.setItem('wx_showcase_fast', state.fastMode ? '1' : '0');
			} catch (_eLs3) {}
		}
	};
})();
