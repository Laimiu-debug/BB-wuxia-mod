/* ============================================================================
 * BB Wuxia Mod - Tavern Gambling (`长乐赌桌`) & Martial Arts Tournament (`武林大会`) UI
 * Strictly ES3-compliant (zero let/const/arrow/template-literals/class).
 * 100% Unified with BB Wuxia Vanilla-Isomorphic Leather/Gold/Cinnabar Theme.
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

	function wxFmtSilver(_n) {
		var num = Math.floor(Number(_n) || 0);
		var sign = num < 0 ? '-' : '';
		var str = String(Math.abs(num));
		var out = '';
		while (str.length > 3) {
			out = ',' + str.substring(str.length - 3) + out;
			str = str.substring(0, str.length - 3);
		}
		return sign + str + out;
	}

	function wxGetHostRoot() {
		var r = $('.root-screen:first');
		return r.length ? r : $(document.body);
	}

	function wxPlaySound(_sqHandle, _key) {
		if (_sqHandle && typeof SQ !== 'undefined' && _key) {
			SQ.call(_sqHandle, 'onWXGamblingSound', _key, function () {});
		}
	}

	function wxSyncTopbarAssets(_ownerMod, _assets) {
		if (!_assets) return;
		if (_ownerMod && _ownerMod.mAssets && _ownerMod.mAssets.loadFromData) {
			_ownerMod.mAssets.loadFromData(_assets);
		} else if (typeof Screens !== 'undefined' && Screens['WorldTownScreen'] && Screens['WorldTownScreen'].mAssetValues) {
			Screens['WorldTownScreen'].mAssetValues = _assets;
		}
	}

	// ------------------------------------------------------------------------
	// Shared Wuxia Totem & Card Suit SVG Paths (6 Jianghu Totems)
	// 1=名剑, 2=藤盾, 3=镖旗, 4=斗笠, 5=酒坛, 6=鬼首
	// ------------------------------------------------------------------------
	var WX_TOTEM_LABELS = ['', '名剑', '藤盾', '镖旗', '斗笠', '酒坛', '鬼首'];
	var WX_TOTEM_PATHS = [
		'',
		'M50 10 L58 54 L54 61 L54 73 L68 73 L68 79 L54 79 L54 90 L46 90 L46 79 L32 79 L32 73 L46 73 L46 61 L42 54 Z',
		'M50 14 L78 26 L75 59 Q69 78 50 89 Q31 78 25 59 L22 26 Z M50 23 V78 M29 44 H71',
		'M28 90 V14 M29 16 H78 L64 33 L78 50 H29',
		'M12 62 L50 24 L88 62 Z M26 62 Q50 76 74 62',
		'M36 22 H64 L60 32 Q76 42 74 66 Q72 86 50 86 Q28 86 26 66 Q24 42 40 32 Z M34 22 H66',
		'M30 62 Q18 46 26 30 Q34 16 50 16 Q66 16 74 30 Q82 46 70 62 L65 82 H35 Z M34 42 L44 48 L34 52 Z M66 42 L56 48 L66 52 Z M44 70 V82 M56 70 V82'
	];

	function wxTotemSvg(_idx, _strokeColor) {
		var col = _strokeColor || '#dda21f';
		var p = WX_TOTEM_PATHS[_idx] || WX_TOTEM_PATHS[1];
		return '<svg viewBox="0 0 100 100"><path d="' + p + '" fill="none" stroke="' + col + '" stroke-width="5.5" stroke-linejoin="round" stroke-linecap="round"/></svg>';
	}

	// Traditional Chinese Bone Die (`唐赐绯红一四点牛骨骰`: 1 & 4 are cinnabar red, others deep ink!)
	var WX_DIE_PIPS = {
		1: [[50, 50]],
		2: [[27, 27], [73, 73]],
		3: [[25, 25], [50, 50], [75, 75]],
		4: [[28, 28], [72, 28], [28, 72], [72, 72]],
		5: [[25, 25], [75, 25], [50, 50], [25, 75], [75, 75]],
		6: [[28, 23], [72, 23], [28, 50], [72, 50], [28, 77], [72, 77]]
	};

	function wxRenderBoneDie(_face, _idx, _isTotemMode, _rollingMap, _landedIdx) {
		var isRolling = !!(_rollingMap && _rollingMap[_idx]);
		var isLanded = (_landedIdx === _idx);
		if (!_face && !isRolling) {
			return '<div class="wx-cas-die-covered">&middot;</div>';
		}
		var n = isRolling ? ((_idx % 6) + 1) : _face;
		var cls = 'wx-cas-die' + (isRolling ? ' is-rolling' : (isLanded ? ' is-landed' : ''));
		var inner = '';
		if (_isTotemMode) {
			var tCol = (n === 1 || n === 3) ? '#9e241c' : '#2d1e12';
			inner = '<path d="' + WX_TOTEM_PATHS[n] + '" fill="none" stroke="' + tCol + '" stroke-width="6" stroke-linejoin="round"/>';
		} else {
			var pts = WX_DIE_PIPS[n] || WX_DIE_PIPS[1];
			var pipColor = (n === 1 || n === 4) ? '#b5241c' : '#2a1b10';
			var rad = (n === 1) ? 10.5 : 6.8;
			for (var i = 0; i < pts.length; i++) {
				inner += '<circle cx="' + pts[i][0] + '" cy="' + pts[i][1] + '" r="' + rad + '" fill="' + pipColor + '"/>';
			}
		}
		return (
			'<div class="' + cls + '">' +
				'<svg viewBox="0 0 100 100">' +
					'<rect x="3" y="3" width="94" height="94" rx="14" fill="#dfd0ae" stroke="#8a6c40" stroke-width="5"/>' +
					'<rect x="9" y="9" width="82" height="82" rx="9" fill="none" stroke="#c3ae84" stroke-width="1.5"/>' +
					inner +
				'</svg>' +
			'</div>'
		);
	}

	// Ming Ma-Diao Leaf Cards (`明制马吊叶子牌`)
	var WX_CARD_RANKS = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
	var WX_CARD_CN    = ['天罡', '二', '三', '四', '五', '六', '七', '八', '九', '十', '少侠', '掌门', '宗师'];
	var WX_SUIT_TOTEM = [1, 2, 3, 5]; // 青锋剑, 玄铁盾, 聚义旗, 紫金爵
	var WX_SUIT_NAMES = ['青锋', '玄盾', '镖旗', '金爵'];

	function wxCardTotal(_hand) {
		var sum = 0;
		var aces = 0;
		if (!_hand) return 0;
		for (var i = 0; i < _hand.length; i++) {
			var r = (_hand[i] % 13) + 1;
			if (r === 1) {
				sum += 11;
				aces += 1;
			} else {
				sum += Math.min(10, r);
			}
		}
		while (sum > 21 && aces > 0) {
			sum -= 10;
			aces -= 1;
		}
		return sum;
	}

	function wxRenderLeafCards(_hand, _hasBackCard, _prefix, _animMap) {
		var html = '';
		var arr = _hand || [];
		for (var i = 0; i < arr.length; i++) {
			var val = arr[i];
			var rIdx = val % 13;
			var sIdx = Math.floor(val / 13);
			var isRed = (sIdx === 0 || sIdx === 2);
			var key = _prefix + i;
			var anim = (_animMap && _animMap[key]) ? (_animMap[key] === 'flip' ? ' is-flip' : ' is-deal') : '';
			var stroke = isRed ? '#9e241c' : '#2c1d11';
			var faceTitle = (rIdx === 0 || rIdx >= 10) ? WX_CARD_CN[rIdx] : WX_SUIT_NAMES[sIdx];
			html +=
				'<div class="wx-cas-card' + (isRed ? ' is-red' : '') + anim + '">' +
					'<div class="wx-cas-card-inner">' +
						'<span class="wx-cas-card-rank">' + WX_CARD_RANKS[rIdx] + '</span>' +
						'<span class="wx-cas-card-cn">' + WX_CARD_CN[rIdx] + '</span>' +
						wxTotemSvg(WX_SUIT_TOTEM[sIdx], stroke) +
						'<span class="wx-cas-card-lbl">' + faceTitle + '</span>' +
					'</div>' +
				'</div>';
		}
		if (_hasBackCard) {
			var backAnim = (_animMap && _animMap[_prefix + '1']) ? ' is-deal' : '';
			html +=
				'<div class="wx-cas-card is-back' + backAnim + '">' +
					'<div class="wx-cas-card-inner">' +
						'<span class="wx-cas-card-seal">暗</span>' +
						'<span class="wx-cas-card-lbl" style="margin-top:0.8rem;color:#bd9d71;">庄家暗叶</span>' +
					'</div>' +
				'</div>';
		}
		return html;
	}

	// ========================================================================
	// PART A: TAVERN GAMBLING MODAL (`迎客酒肆 · 长乐赌桌`)
	// ========================================================================
	var wxCasino = {
		owner: null,
		sqHandle: null,
		backdrop: null,
		state: null,
		kind: 'size',
		stakeText: '50',
		pokerText: '200',
		pick: 0,
		showRules: false,
		busy: false,
		session: 0,
		timers: [],
		motion: null
	};

	function wxClearCasinoTimers() {
		for (var i = 0; i < wxCasino.timers.length; i++) {
			clearTimeout(wxCasino.timers[i]);
		}
		wxCasino.timers = [];
	}

	function wxCasinoLater(_fn, _delay) {
		var tok = wxCasino.session;
		var tid = setTimeout(function () {
			if (wxCasino.backdrop && wxCasino.session === tok) {
				_fn();
			}
		}, _delay);
		wxCasino.timers.push(tid);
	}

	function wxCloseCasinoModal() {
		wxCasino.session += 1;
		wxClearCasinoTimers();
		wxCasino.motion = null;
		wxCasino.busy = false;
		$(document).off('keydown.wxCasinoModal');
		if (wxCasino.backdrop) {
			wxCasino.backdrop.remove();
			wxCasino.backdrop = null;
		}
		wxCasino.owner = null;
	}

	function wxGetCurrentTableDef(_id) {
		if (!wxCasino.state || !wxCasino.state.tables) return null;
		for (var i = 0; i < wxCasino.state.tables.length; i++) {
			if (wxCasino.state.tables[i].ID === _id) return wxCasino.state.tables[i];
		}
		return null;
	}

	function wxGetDraftStake() {
		return wxCasino.kind === 'holdem' ? wxCasino.pokerText : wxCasino.stakeText;
	}

	function wxSetDraftStake(_valStr) {
		if (wxCasino.kind === 'holdem') wxCasino.pokerText = String(_valStr);
		else wxCasino.stakeText = String(_valStr);
	}

	function wxGetMaxAllowedStake() {
		var money = (wxCasino.state && typeof wxCasino.state.money === 'number') ? Math.max(0, Math.floor(wxCasino.state.money)) : 0;
		var lim = (wxCasino.state && wxCasino.state.limits) ? wxCasino.state.limits : null;
		if (!lim) return money;
		var maxS = money;
		if (typeof lim.maximum === 'number') maxS = Math.min(maxS, Math.max(0, Math.floor(lim.maximum)));
		if (typeof lim.tableCap === 'number') maxS = Math.min(maxS, Math.max(0, Math.floor(lim.tableCap)));
		if (typeof lim.dailyCapLeft === 'number') maxS = Math.min(maxS, Math.max(0, Math.floor(lim.dailyCapLeft)));
		return maxS;
	}

	function wxValidateStake() {
		var raw = wxGetDraftStake();
		var n = /^[0-9]+$/.test(raw) ? parseInt(raw, 10) : NaN;
		var money = (wxCasino.state && typeof wxCasino.state.money === 'number') ? Math.floor(wxCasino.state.money) : 0;
		var lim = (wxCasino.state && wxCasino.state.limits) ? wxCasino.state.limits : null;
		if (lim && typeof lim.dailyCapLeft === 'number' && lim.dailyCapLeft <= 0) {
			return { amount: isNaN(n) ? 0 : n, error: '今日长乐赌桌庄家已挂免战牌封盘（每日净赢上限 2,500 两），请明日再来。' };
		}
		if (isNaN(n) || n < 1) {
			return { amount: 0, error: '至少须押下 1 两整纹银。' };
		}
		if (n > money) {
			return { amount: n, error: '行囊现银仅有 ' + wxFmtSilver(money) + ' 两。' };
		}
		var maxAllow = wxGetMaxAllowedStake();
		if (lim && n > maxAllow) {
			return { amount: n, error: '超出本桌当前限红上限（当前最高可押 ' + wxFmtSilver(maxAllow) + ' 两）。' };
		}
		return { amount: n, error: '' };
	}

	function wxBuildHoldemFeltHtml(_hand) {
		if (!_hand) {
			return (
				'<div style="padding:4.5rem 2rem;color:#d7b174;">' +
					'<div style="font-size:2.0rem;color:#dda21f;margin-bottom:0.8rem;">四张条凳 · 一副明制马吊叶牌</div>' +
					'<p style="line-height:2.1rem;">独耳老刀客让出主位，断指老江湖将银袋往前一推，丝路豪商正哗啦啦洗着叶子牌。<br/>先在下方定好本手带入桌面的纹银两数，入席即发暗叶！</p>' +
				'</div>'
			);
		}

		var m = wxCasino.motion;
		var boardCnt = m ? m.boardCount : _hand.board.length;
		var dealtCnt = m ? m.handCards : 2;

		function buildSeat(_s, _idx, _extraCls) {
			var hideCards = _s.hidden || (m && _idx !== 0);
			var isTurn = (_hand.turn === _idx && !m && !_hand.done);
			var cls = 'wx-cas-poker-seat' + (_extraCls ? (' ' + _extraCls) : '') + (_s.folded ? ' is-folded' : '') + (isTurn ? ' is-turn' : '');
			var cardsHtml = '';
			if (hideCards) {
				for (var c = 0; c < dealtCnt; c++) {
					var k = 's' + _idx + '_' + c;
					var dCls = (m && m.cards && m.cards[k]) ? ' is-deal' : '';
					cardsHtml +=
						'<div class="wx-cas-card is-back' + dCls + '">' +
							'<div class="wx-cas-card-inner"><span class="wx-cas-card-seal">暗</span></div>' +
						'</div>';
				}
			} else {
				cardsHtml = wxRenderLeafCards(_s.cards.slice(0, dealtCnt), false, 's' + _idx + '_', m ? m.cards : null);
			}
			var actTxt = _s.rankName ? ('【' + _s.rankName + '】') : (_s.action || '静候发话');
			return (
				'<div class="' + cls + '">' +
					'<h4>' + wxEsc(_s.name) + (_hand.button === _idx ? '<span class="wx-cas-dealer-btn">庄</span>' : '') + '</h4>' +
					'<div class="wx-cas-poker-meta">案前余银 ' + _s.stack + ' · 已投 ' + _s.total + ' 两</div>' +
					'<div>' + cardsHtml + '</div>' +
					'<div class="wx-cas-poker-act">' + wxEsc(actTxt) + '</div>' +
				'</div>'
			);
		}

		var html = '<div class="wx-cas-poker-opps">';
		for (var i = 1; i < 4; i++) {
			html += buildSeat(_hand.seats[i], i, '');
		}
		html += '</div>';

		var boardHtml = wxRenderLeafCards(_hand.board.slice(0, boardCnt), false, 'b', m ? m.cards : null);
		for (var j = boardCnt; j < 5; j++) {
			boardHtml +=
				'<div class="wx-cas-card is-back" style="opacity:0.32;">' +
					'<div class="wx-cas-card-inner"><span class="wx-cas-card-seal">&middot;</span></div>' +
				'</div>';
		}

		var streetNames = ['首轮暗叶博弈', '三叶翻开（翻牌圈）', '四叶转势（转牌圈）', '五叶定鼎（河牌圈）'];
		var stageText = m ? m.phrase : (streetNames[_hand.street] || '');

		html +=
			'<div class="wx-cas-poker-mid">' +
				'<div class="wx-cas-poker-pot">总银池：' + wxFmtSilver(_hand.pot) + ' 两纹银 · 盲注 ' + _hand.smallBlind + ' / ' + _hand.bigBlind + ' 两</div>' +
				'<div>' + boardHtml + '</div>' +
				'<div style="font-size:1.25rem;color:#bd9d71;margin-top:0.2rem;">' + wxEsc(stageText) + '</div>' +
			'</div>';

		html += buildSeat(_hand.seats[0], 0, 'wx-cas-poker-self');

		if (!m && _hand.done && _hand.pots && _hand.pots.length) {
			var potNotes = [];
			for (var p = 0; p < _hand.pots.length; p++) {
				var pt = _hand.pots[p];
				var wNames = [];
				for (var w = 0; w < pt.winners.length; w++) {
					var wSeat = _hand.seats[pt.winners[w]];
					if (wSeat) wNames.push(wSeat.name);
				}
				potNotes.push((p === 0 ? '主银池 ' : ('边池' + p + ' ')) + pt.amount + '两 → ' + wNames.join('、'));
			}
			html += '<div style="margin-top:0.35rem;font-size:1.24rem;color:#5ec47a;">' + wxEsc(potNotes.join('　|　')) + '</div>';
		}
		return html;
	}

	function wxBuildFeltContent() {
		var st = wxCasino.state;
		var kind = wxCasino.kind;
		var pending = st.game;
		var result = (!pending && st.lastGamble && st.lastGamble.kind === kind) ? st.lastGamble : null;
		var m = wxCasino.motion;

		if (kind === 'holdem') {
			return wxBuildHoldemFeltHtml(pending || result);
		}

		var dealerPhrase = m
			? m.phrase
			: (pending
				? '庄家按盅静候你的决断……'
				: (result
					? (result.net > 0 ? '彩头落袋！这锭雪花纹银归你了！' : (result.net < 0 ? '庄家笑吟吟拢走了案上纹银。' : '点数持平，原银完璧归赵。'))
					: '买定离手！摆好纹银，庄家随时开局。'));

		var html = '<div class="wx-cas-dealer-line">' + wxEsc(dealerPhrase) + '</div>';

		if (kind === 'blackjack') {
			var hand = m ? m.hand : (pending || result);
			var hideDlr = m ? m.hidden : !!pending;
			var dlrPts = (hand && !hideDlr && hand.dealer && hand.dealer.length) ? (' · ' + wxCardTotal(hand.dealer) + ' 点') : '';
			var ownPts = (hand && hand.player && hand.player.length) ? (' · ' + wxCardTotal(hand.player) + ' 点') : '';
			var dblTag = (hand && hand.doubled) ? ' · 【孤注双倍】' : '';

			html += '<div class="wx-cas-hand-hdr">庄家叶牌' + dlrPts + '</div>';
			html += '<div class="wx-cas-cards-row">' +
				(hand ? wxRenderLeafCards(hand.dealer, hideDlr, 'd', m ? m.cards : null) : '<div class="wx-cas-card is-back"><div class="wx-cas-card-inner"><span class="wx-cas-card-seal">待</span></div></div>') +
			'</div>';

			html += '<div class="wx-cas-hand-hdr">少侠手牌' + ownPts + dblTag + '</div>';
			html += '<div class="wx-cas-cards-row">' +
				(hand ? wxRenderLeafCards(hand.player, false, 'p', m ? m.cards : null) : '<div class="wx-cas-card is-back"><div class="wx-cas-card-inner"><span class="wx-cas-card-seal">待</span></div></div>') +
			'</div>';
			return html;
		}

		// Dice games (`size`, `symbols`, `riffa`, `hazard`, `raid`)
		var diceArr = m ? m.dice : (pending ? pending.dice : (result ? result.dice : []));
		var curStake = wxValidateStake().amount || parseInt(wxGetDraftStake(), 10) || 0;

		if (kind === 'riffa') {
			var sides = [1, 0];
			for (var s = 0; s < sides.length; s++) {
				var sd = sides[s];
				var sdLbl = sd ? '庄家双鲤骨骰' : '少侠双鲤骨骰';
				var sdTot = (result && !m) ? (' · 共 ' + (sd ? result.dealerTotal : result.playerTotal) + ' 点') : '';
				html += '<div class="wx-cas-hand-hdr">' + sdLbl + sdTot + '</div><div class="wx-cas-riffa-row">';
				for (var j = 0; j < 3; j++) {
					html += wxRenderBoneDie(diceArr[sd * 3 + j], sd * 3 + j, false, m ? m.turns : null, m ? m.landed : -1);
				}
				html += '</div>';
			}
			return html;
		}

		var dieCnt = (kind === 'raid') ? 4 : (kind === 'hazard' ? 2 : 3);
		html += '<div class="wx-cas-dice-row">';
		for (var d = 0; d < dieCnt; d++) {
			html += wxRenderBoneDie(diceArr[d], d, kind === 'symbols', m ? m.turns : null, m ? m.landed : -1);
		}
		html += '</div>';

		if (kind === 'size') {
			html +=
				'<div class="wx-cas-size-spots">' +
					'<div class="wx-cas-spot-btn' + (wxCasino.pick === 0 ? ' is-selected' : '') + '" data-cas-pick="0">' +
						'<span class="wx-cas-spot-big">小</span>' +
						'<span class="wx-cas-spot-sub">4 至 10 点（三同豹子通杀）</span>' +
						(wxCasino.pick === 0 ? '<span class="wx-cas-chip">押 ' + wxFmtSilver(curStake) + ' 两</span>' : '') +
					'</div>' +
					'<div class="wx-cas-spot-btn' + (wxCasino.pick === 1 ? ' is-selected' : '') + '" data-cas-pick="1">' +
						'<span class="wx-cas-spot-big">大</span>' +
						'<span class="wx-cas-spot-sub">11 至 17 点（三同豹子通杀）</span>' +
						(wxCasino.pick === 1 ? '<span class="wx-cas-chip">押 ' + wxFmtSilver(curStake) + ' 两</span>' : '') +
					'</div>' +
				'</div>';
		} else if (kind === 'symbols') {
			html += '<div class="wx-cas-totem-grid">';
			for (var t = 1; t <= 6; t++) {
				var isSel = (wxCasino.pick === t);
				html +=
					'<div class="wx-cas-totem-btn' + (isSel ? ' is-selected' : '') + '" data-cas-pick="' + t + '">' +
						wxTotemSvg(t, isSel ? '#ffe28a' : '#d7b174') +
						'<div style="font-size:1.38rem;">' + WX_TOTEM_LABELS[t] + '</div>' +
						(isSel ? '<span class="wx-cas-chip">' + wxFmtSilver(curStake) + ' 两</span>' : '<span style="font-size:1.1rem;color:#bd9d71;">1/2/3枚→2/3/12倍</span>') +
					'</div>';
			}
			html += '</div>';
		} else if (kind === 'hazard') {
			var shownGame = m ? m.beforeGame : (pending || result);
			var mainPt = shownGame ? shownGame.main : wxCasino.pick;
			var chancePt = shownGame ? shownGame.chance : 0;
			html += '<div style="margin-top:0.4rem;">';
			html += '<div style="font-size:1.65rem;color:#dda21f;">天门主点：' + mainPt + (chancePt ? ('　·　追击机缘点：【' + chancePt + '】') : '') + '</div>';
			html += '<div class="wx-cas-hazard-picks">';
			for (var hp = 5; hp <= 9; hp++) {
				var hpCls = 'wx-gmb-btn' + (mainPt === hp ? ' is-active' : '') + ((pending || wxCasino.busy) ? ' is-disabled' : '');
				html += '<span class="' + hpCls + '" data-cas-pick="' + hp + '">天门 ' + hp + ' 点</span>';
			}
			html += '</div>';
			html += '<div style="font-size:1.26rem;color:#bd9d71;">' +
				(chancePt ? ('续摇双骰：先出机缘点【' + chancePt + '】立赢双倍，先撞主点【' + mainPt + '】落败。') : '先从 5 至 9 点挑定天门主点，再押银开盅。') +
			'</div></div>';
		} else if (kind === 'raid') {
			var passes = [
				{ title: '第一关 · 黑风山口', rate: '连本返 1.15 倍' },
				{ title: '第二关 · 迷雾苦竹林', rate: '连本返 1.38 倍' },
				{ title: '第三关 · 断魂一线天', rate: '连本返 1.65 倍' },
				{ title: '第四关 · 满载入州城', rate: '连本返 1.98 倍' }
			];
			html += '<div class="wx-cas-route-bar">';
			for (var r = 0; r < 4; r++) {
				var rollVal = diceArr[r];
				var rCls = (rollVal === 1) ? ' is-ambush' : (rollVal ? ' is-passed' : '');
				html +=
					'<div class="wx-cas-route-node' + rCls + '">' +
						'<strong>' + passes[r].title + '</strong>' +
						'<span>' + passes[r].rate + '</span>' +
					'</div>';
			}
			html += '</div>';
			html += '<div style="font-size:1.25rem;color:#bd9d71;">掷出 2~6 点过关（随时可收缰落袋），掷出红 1 点遇响马劫道失本！</div>';
		}
		return html;
	}

	function wxPaintFeltOnly() {
		if (!wxCasino.backdrop) return;
		var felt = wxCasino.backdrop.find('[data-cas="felt"]');
		if (felt.length) {
			felt.html(wxBuildFeltContent());
			if (wxCasino.motion) wxCasino.motion.cards = {};
		}
	}

	function wxRenderCasinoModal() {
		if (!wxCasino.backdrop || !wxCasino.state) return;
		var st = wxCasino.state;
		var pending = st.game;
		var kind = wxCasino.kind;
		var m = wxCasino.motion;
		var shownMoney = m ? m.money : st.money;
		var netAll = (st.metrics && typeof st.metrics.casinoNet === 'number') ? st.metrics.casinoNet : 0;
		var netColor = netAll > 0 ? '#5ec47a' : (netAll < 0 ? '#ff8070' : '#bd9d71');
		var netStr = (netAll >= 0 ? ('+' + wxFmtSilver(netAll)) : wxFmtSilver(netAll)) + ' 两';

		var patron = st.patron || { Name: '江湖豪客', Asking: '叶子牌讲心算，牛骨骰凭气运。' };
		var tDef = wxGetCurrentTableDef(kind);

		var tabsHtml = '';
		var tables = st.tables || [];
		for (var i = 0; i < tables.length; i++) {
			var tb = tables[i];
			var tCls = 'wx-cas-tab' + (tb.ID === kind ? ' is-active' : '') + ((pending || wxCasino.busy) ? ' is-disabled' : '');
			tabsHtml += '<span class="' + tCls + '" data-cas-tab="' + tb.ID + '">' + wxEsc(tb.Short || tb.Name) + '</span>';
		}

		var rulesHtml = (wxCasino.showRules && tDef)
			? ('<div class="wx-cas-rules-box">' + wxEsc(tDef.Rule) + '</div>')
			: '';

		var tourneyHopBtn = st.isHostTown
			? '<span class="wx-gmb-btn is-sm" data-cas-act="goto_tourney" title="前往本城演武总坛查看武林大会签表与外围盘口">演武红盘下注</span>'
			: '';

		var valInfo = wxValidateStake();
		var disInput = (pending || wxCasino.busy) ? ' disabled="disabled"' : '';
		var stakeVal = pending ? String(pending.stake) : wxGetDraftStake();

		var quickBtnsHtml = '';
		if (!pending) {
			quickBtnsHtml =
				'<span class="wx-gmb-btn is-sm' + (wxCasino.busy ? ' is-disabled' : '') + '" data-cas-chip="10">+10</span>' +
				'<span class="wx-gmb-btn is-sm' + (wxCasino.busy ? ' is-disabled' : '') + '" data-cas-chip="50">+50</span>' +
				'<span class="wx-gmb-btn is-sm' + (wxCasino.busy ? ' is-disabled' : '') + '" data-cas-chip="200">+200</span>' +
				'<span class="wx-gmb-btn is-sm' + (wxCasino.busy ? ' is-disabled' : '') + '" data-cas-chip="half">半袋</span>' +
				'<span class="wx-gmb-btn is-sm' + (wxCasino.busy ? ' is-disabled' : '') + '" data-cas-chip="all">倾囊全押</span>';
		}

		var ctrlHtml = '';
		var bDis = wxCasino.busy ? ' is-disabled' : '';
		if (pending && kind === 'holdem') {
			var canR = pending.canRaise && pending.minTo <= pending.maxTo;
			var canAllIn = pending.canRaise || pending.maxTo <= pending.currentBet;
			ctrlHtml =
				'<span class="wx-gmb-btn' + bDis + '" data-cas-act="holdem_fold">扣牌弃局</span>' +
				'<span class="wx-gmb-btn' + bDis + '" data-cas-act="holdem_call">' + (pending.toCall > 0 ? ('跟注 ' + pending.toCall + ' 两') : '观望过牌') + '</span>' +
				'<span style="margin:0 0.4rem;">加注至 <input type="text" class="wx-gmb-input" data-cas-inp="raise" maxlength="9" value="' + Math.min(pending.minTo, pending.maxTo) + '"' + ((!canR || wxCasino.busy) ? ' disabled="disabled"' : '') + ' /> 两</span>' +
				'<span class="wx-gmb-btn' + ((!canR || wxCasino.busy) ? ' is-disabled' : '') + '" data-cas-act="holdem_raise">落银加注</span>' +
				'<span class="wx-gmb-btn' + ((!canAllIn || wxCasino.busy || pending.seats[0].stack <= 0) ? ' is-disabled' : '') + '" data-cas-act="holdem_allin">全押 ' + pending.seats[0].stack + ' 两</span>';
		} else if (pending && kind === 'blackjack') {
			ctrlHtml =
				'<span class="wx-gmb-btn is-lg' + bDis + '" data-cas-act="bj_hit">再摸一叶</span>' +
				'<span class="wx-gmb-btn is-lg' + bDis + '" data-cas-act="bj_stand">封牌定输赢</span>' +
				'<span class="wx-gmb-btn is-lg' + ((!pending.canDouble || wxCasino.busy) ? ' is-disabled' : '') + '" data-cas-act="bj_double">孤注加倍（仅补一叶）</span>';
		} else if (pending && kind === 'hazard') {
			ctrlHtml = '<span class="wx-gmb-btn is-lg' + bDis + '" data-cas-act="hazard_next">续摇紫铜骰盅</span>';
		} else if (pending && kind === 'raid') {
			ctrlHtml =
				'<span class="wx-gmb-btn is-lg' + bDis + '" data-cas-act="raid_stop">收缰结账 · 拿回 ' + wxFmtSilver(pending.payout) + ' 两</span>' +
				'<span class="wx-gmb-btn is-lg' + bDis + '" data-cas-act="raid_next">催马再闯下一关</span>';
		} else {
			var startLbl = (kind === 'holdem') ? '携银入席 · 四家发叶'
				: (kind === 'blackjack' ? '押下纹银 · 起手发叶'
				: (kind === 'raid' ? '押下镖银 · 勇闯首关' : '买定离手 · 摇盅开骰'));
			var canStart = !wxCasino.busy && !valInfo.error && st.money >= 1;
			ctrlHtml = '<span class="wx-gmb-btn is-lg' + (canStart ? '' : ' is-disabled') + '" data-cas-act="gamble" data-cas-go="1">' + startLbl + '</span>';
		}

		var msgTxt = m ? '' : (valInfo.error && !pending ? valInfo.error : (st.message || ''));
		var msgErr = (!st.ok || (valInfo.error && !pending)) ? ' is-err' : '';

		var dialog = wxCasino.backdrop.find('.wx-gmb-dialog:first');
		dialog.html(
			'<div class="wx-gmb-hdr">' +
				'<img class="wx-gmb-hdr-art" src="coui://gfx/ui/events/wx_ev_31.png" alt="" />' +
				'<div class="wx-gmb-hdr-title">【' + wxEsc(st.townName) + ' · 迎客酒肆】长乐赌桌 · ' + wxEsc(tDef ? tDef.Name : '江湖博戏') + '</div>' +
				'<div class="wx-gmb-hdr-silver">' +
					'<img src="coui://gfx/ui/wx_icons/wx_asset_money.png" alt="" />现银：<strong>' + wxFmtSilver(shownMoney) + '</strong> 两' +
					'　<span style="font-size:1.22rem;color:' + netColor + ';">(累计净盈亏 ' + netStr + ')</span>' +
				'</div>' +
				'<div class="wx-gmb-hdr-close" data-cas-act="close" title="离桌起身"><img src="coui://gfx/ui/skin/icon_cross.png" alt="" /></div>' +
			'</div>' +
			'<div class="wx-gmb-gold-line"></div>' +
			'<div class="wx-cas-patron-bar">' +
				'<div class="wx-cas-patron-tools">' +
					tourneyHopBtn +
					'<span class="wx-gmb-btn is-sm" data-cas-act="rules">' + (wxCasino.showRules ? '收起赌例' : '问明本桌赌例') + '</span>' +
				'</div>' +
				'<span class="wx-cas-patron-name">【同桌豪客 · ' + wxEsc(patron.Name) + '】</span>' +
				'<span>' + wxEsc(pending ? '「上把银子还押在案心，咱们先把这局分出高下！」' : '「叶子牌斗心眼，牛骨骰拼气运——东家尽管落银！」') + '</span>' +
				'<div class="clear-both"></div>' +
			'</div>' +
			'<div class="wx-cas-tabs">' + tabsHtml + '</div>' +
			rulesHtml +
			'<div class="wx-cas-felt wx-gmb-scroll" data-cas="felt">' + wxBuildFeltContent() + '</div>' +
			'<div class="wx-cas-wager-bar">' +
				'<img src="coui://gfx/ui/wx_icons/wx_icon_money.png" style="width:2.0rem;height:2.0rem;vertical-align:middle;margin-top:-0.25rem;" alt="" /> ' +
				'<span>' + (kind === 'holdem' ? '本手带入纹银：' : (pending ? '案心已押纹银：' : '本局押注纹银：')) + '</span>' +
				'<input type="text" class="wx-gmb-input" data-cas-inp="stake" maxlength="9" value="' + wxEsc(stakeVal) + '"' + disInput + ' />' +
				'<span>两　</span>' +
				quickBtnsHtml +
			'</div>' +
			'<div class="wx-cas-ctrl-bar">' + ctrlHtml + '</div>' +
			'<div class="wx-cas-msg-bar wx-gmb-scroll' + msgErr + '" data-cas="msg">' + wxEsc(msgTxt) + '</div>'
		);

		dialog.find('input').on('keydown keypress keyup', function (_e) {
			if (_e.keyCode !== 27) _e.stopPropagation();
		});

		dialog.find('[data-cas-inp="stake"]').on('input change keyup', function () {
			if (wxCasino.busy || (wxCasino.state && wxCasino.state.game)) return;
			wxSetDraftStake($(this).val() || '');
			var v = wxValidateStake();
			var goBtn = dialog.find('[data-cas-go="1"]');
			goBtn.toggleClass('is-disabled', !!v.error || wxCasino.state.money < 1);
			dialog.find('.wx-cas-chip').text('押 ' + wxFmtSilver(v.amount || 0) + ' 两');
			if (v.error) {
				dialog.find('[data-cas="msg"]').addClass('is-err').text(v.error);
			} else {
				dialog.find('[data-cas="msg"]').removeClass('is-err').text(wxCasino.state.message || '');
			}
		});

		dialog.find('[data-cas-chip]').on('click', function () {
			if (wxCasino.busy || (wxCasino.state && wxCasino.state.game)) return;
			var mode = $(this).attr('data-cas-chip');
			var maxM = wxGetMaxAllowedStake();
			var cur = parseInt(wxGetDraftStake(), 10) || 0;
			var next = cur;
			if (mode === 'all') next = maxM;
			else if (mode === 'half') next = (maxM >= 1) ? Math.max(1, Math.floor(maxM / 2)) : 0;
			else next = Math.min(maxM, cur + (parseInt(mode, 10) || 0));
			if (next < 1 && maxM >= 1) next = 1;
			wxSetDraftStake(String(next));
			wxRenderCasinoModal();
		});

		dialog.find('[data-cas-tab]').on('click', function () {
			if (wxCasino.busy || (wxCasino.state && wxCasino.state.game)) return;
			var nxt = $(this).attr('data-cas-tab');
			if (nxt && nxt !== wxCasino.kind) {
				wxCasino.kind = nxt;
				wxCasino.showRules = false;
				wxCasino.pick = (nxt === 'hazard') ? 7 : (nxt === 'symbols' ? 1 : 0);
				wxCasino.state.message = '';
				wxRenderCasinoModal();
			}
		});

		dialog.find('[data-cas-pick]').on('click', function () {
			if (wxCasino.busy || (wxCasino.state && wxCasino.state.game)) return;
			wxCasino.pick = parseInt($(this).attr('data-cas-pick'), 10) || 0;
			wxRenderCasinoModal();
		});

		dialog.find('[data-cas-act]').on('click', function () {
			if ($(this).hasClass('is-disabled')) return;
			var act = $(this).attr('data-cas-act');
			if (act === 'close') {
				wxCloseCasinoModal();
				return;
			}
			if (act === 'goto_tourney') {
				var ownerRef = wxCasino.owner;
				var hRef = wxCasino.sqHandle;
				wxCloseCasinoModal();
				window.WX_OpenTournamentModal(ownerRef, hRef, 0, false);
				return;
			}
			if (wxCasino.busy) return;
			if (act === 'rules') {
				wxCasino.showRules = !wxCasino.showRules;
				wxRenderCasinoModal();
				return;
			}
			if (act === 'gamble') {
				var inpVal = dialog.find('[data-cas-inp="stake"]').val() || '';
				wxSetDraftStake(inpVal);
				var check = wxValidateStake();
				if (check.error) {
					wxRenderCasinoModal();
					return;
				}
				wxSendCasinoAction('gamble', check.amount, wxCasino.pick);
				return;
			}
			if (act === 'holdem_raise') {
				var rRaw = dialog.find('[data-cas-inp="raise"]').val() || '';
				var rVal = /^[0-9]+$/.test(rRaw) ? parseInt(rRaw, 10) : NaN;
				if (isNaN(rVal) || rVal < pending.minTo || rVal > pending.maxTo) {
					dialog.find('[data-cas="msg"]').addClass('is-err').text('加注总额须在 ' + pending.minTo + ' ~ ' + pending.maxTo + ' 两纹银之间。');
					return;
				}
				wxSendCasinoAction('holdem_raise', rVal, 0);
				return;
			}
			wxSendCasinoAction(act, 0, 0);
		});
	}

	function wxAnimateCasinoReveal(_beforeState, _action) {
		var st = wxCasino.state;
		var kind = wxCasino.kind;
		var hand = st.game || st.lastGamble;
		if (!hand) {
			wxCasino.busy = false;
			wxRenderCasinoModal();
			return;
		}

		if (kind === 'holdem') {
			var oldH = (_beforeState && _beforeState.game && _beforeState.game.kind === 'holdem') ? _beforeState.game : null;
			var lastSeq = (oldH && oldH.events && oldH.events.length) ? oldH.events[oldH.events.length - 1].seq : -1;
			var newEvs = [];
			for (var e = 0; e < (hand.events || []).length; e++) {
				if (hand.events[e].seq > lastSeq) newEvs.push(hand.events[e]);
			}
			if (newEvs.length > 14) newEvs = newEvs.slice(newEvs.length - 14);

			var hDelay = 80;
			wxCasino.motion = {
				money: _beforeState ? _beforeState.money : st.money,
				handCards: (_action === 'gamble' ? 0 : 2),
				boardCount: oldH ? oldH.board.length : 0,
				cards: {},
				phrase: (_action === 'gamble' ? '荷官洗匀马吊叶牌，四家落盲注底银……' : '银锭推入银池……')
			};
			wxRenderCasinoModal();
			wxPlaySound(wxCasino.sqHandle, _action === 'gamble' ? 'cards' : 'stake');

			if (_action === 'gamble') {
				for (var cRound = 0; cRound < 2; cRound++) {
					(function (_n) {
						wxCasinoLater(function () {
							wxCasino.motion.handCards = _n + 1;
							for (var s = 0; s < 4; s++) wxCasino.motion.cards['s' + s + '_' + _n] = 'deal';
							wxPaintFeltOnly();
							wxPlaySound(wxCasino.sqHandle, 'cards');
						}, 180 + _n * 240);
					})(cRound);
				}
				hDelay = 660;
			}

			for (var evIdx = 0; evIdx < newEvs.length; evIdx++) {
				(function (_ev) {
					hDelay += (_ev.type === 'deal' ? 320 : 220);
					wxCasinoLater(function () {
						for (var b = wxCasino.motion.boardCount; b < _ev.boardCount; b++) {
							wxCasino.motion.cards['b' + b] = 'deal';
						}
						wxCasino.motion.boardCount = _ev.boardCount;
						wxCasino.motion.phrase = _ev.text;
						wxPaintFeltOnly();
						wxPlaySound(wxCasino.sqHandle, _ev.type === 'deal' ? 'cards' : 'stake');
					}, hDelay);
				})(newEvs[evIdx]);
			}

			wxCasinoLater(function () {
				wxCasino.motion = null;
				wxCasino.busy = false;
				wxRenderCasinoModal();
				if (!st.game) {
					wxPlaySound(wxCasino.sqHandle, hand.net > 0 ? 'win' : (hand.net < 0 ? 'lose' : 'stake'));
				}
			}, hDelay + 260);
			return;
		}

		var oldG = (_action === 'gamble' || !_beforeState) ? null : _beforeState.game;
		var delay = (_action === 'gamble' || _action === 'bj_double') ? 140 : 80;
		wxCasino.motion = {
			money: _beforeState ? _beforeState.money : st.money,
			hand: {
				player: (oldG && oldG.player) ? oldG.player.slice(0) : [],
				dealer: (oldG && oldG.dealer) ? oldG.dealer.slice(0) : [],
				doubled: !!hand.doubled
			},
			hidden: !!(oldG && oldG.dealerHidden),
			dice: [],
			turns: {},
			landed: -1,
			cards: {},
			beforeGame: oldG,
			phrase: (kind === 'blackjack' ? '庄家正在派发马吊叶牌……' : '紫铜骰盅急摇落案，买定离手！')
		};
		wxRenderCasinoModal();
		if (_action === 'gamble' || _action === 'bj_double') {
			wxPlaySound(wxCasino.sqHandle, 'stake');
		}

		if (kind === 'blackjack') {
			var scheduleCard = function (_side, _idx, _isBack) {
				delay += 240;
				wxCasinoLater(function () {
					wxPlaySound(wxCasino.sqHandle, 'cards');
					var prefix = _side.charAt(0) + _idx;
					wxCasino.motion.cards[prefix] = (_side === 'dealer' && _idx === 1 && !_isBack) ? 'flip' : 'deal';
					if (_isBack) {
						wxCasino.motion.hidden = true;
					} else {
						wxCasino.motion.hand[_side].push(hand[_side][_idx]);
						if (_side === 'dealer' && _idx === 1) wxCasino.motion.hidden = false;
					}
					wxPaintFeltOnly();
				}, delay);
			};

			if (_action === 'gamble') {
				scheduleCard('player', 0, false);
				scheduleCard('dealer', 0, false);
				scheduleCard('player', 1, false);
				scheduleCard('dealer', 1, true);
			} else {
				for (var p = wxCasino.motion.hand.player.length; p < hand.player.length; p++) {
					scheduleCard('player', p, false);
				}
			}
			if (!st.game && hand.dealer) {
				for (var d = 1; d < hand.dealer.length; d++) {
					scheduleCard('dealer', d, false);
				}
			}
		} else if (_action !== 'raid_stop') {
			var diceList = hand.dice || [];
			var startIdx = (kind === 'raid' && oldG && oldG.dice) ? oldG.dice.length : 0;
			for (var a = 0; a < startIdx; a++) wxCasino.motion.dice[a] = diceList[a];
			for (var b = startIdx; b < diceList.length; b++) wxCasino.motion.turns[b] = true;
			wxPaintFeltOnly();
			wxPlaySound(wxCasino.sqHandle, 'dice');

			for (var k = startIdx; k < diceList.length; k++) {
				(function (_dieIdx) {
					var landDelay = 420 + (_dieIdx - startIdx) * 120;
					if (landDelay > delay) delay = landDelay;
					wxCasinoLater(function () {
						wxCasino.motion.turns[_dieIdx] = false;
						wxCasino.motion.dice[_dieIdx] = diceList[_dieIdx];
						wxCasino.motion.landed = _dieIdx;
						wxPaintFeltOnly();
					}, landDelay);
				})(k);
			}
		} else {
			wxCasino.motion.dice = (hand.dice || []).slice(0);
			wxCasino.motion.phrase = '勒马收缰回城，庄家当面清点镖银……';
			wxPaintFeltOnly();
			delay = 150;
		}

		wxCasinoLater(function () {
			wxCasino.motion = null;
			wxCasino.busy = false;
			wxRenderCasinoModal();
			if (!st.game && st.lastGamble) {
				wxPlaySound(wxCasino.sqHandle, st.lastGamble.net > 0 ? 'win' : (st.lastGamble.net < 0 ? 'lose' : 'stake'));
			}
		}, delay + 240);
	}

	function wxSendCasinoAction(_action, _stakeOrRaise, _pickVal) {
		if (wxCasino.busy || !wxCasino.sqHandle) return;
		wxClearCasinoTimers();
		wxCasino.busy = true;
		var tok = wxCasino.session;
		var beforeState = wxCasino.state;
		var rev = beforeState ? beforeState.revision : 0;
		var arg1 = (_action === 'gamble') ? wxCasino.kind : 0;

		SQ.call(wxCasino.sqHandle, 'onWXCasinoAction', [_action, arg1, _stakeOrRaise || 0, _pickVal || 0, rev], function (_res) {
			if (!wxCasino.backdrop || wxCasino.session !== tok) return;
			if (!_res || _res.closed) {
				wxCloseCasinoModal();
				return;
			}
			wxCasino.state = _res;
			if (_res.Assets) wxSyncTopbarAssets(wxCasino.owner, _res.Assets);

			// Update Tavern button pending dot if Tavern is open underneath
			if (wxCasino.owner && wxCasino.owner.mDialogContainer) {
				var casBtn = wxCasino.owner.mDialogContainer.find('.wx-tavern-casino-btn');
				if (casBtn.length) {
					casBtn.find('.wx-pending-dot').remove();
					if (_res.game) casBtn.append('<span class="wx-pending-dot" title="有未完赌局"></span>');
				}
			}

			if (_res.game && _res.game.kind) {
				wxCasino.kind = _res.game.kind;
				if (wxCasino.kind === 'hazard' && _res.game.main) wxCasino.pick = _res.game.main;
			}

			if (_res.ok && _action !== 'refresh') {
				wxAnimateCasinoReveal(beforeState, _action);
				return;
			}
			wxCasino.busy = false;
			wxRenderCasinoModal();
		});
	}

	window.WX_OpenCasinoModal = function (_ownerMod, _sqHandle, _initialKind) {
		var h = _sqHandle || (_ownerMod ? _ownerMod.mSQHandle : null);
		if (!h) return;
		wxCloseTournamentModal();
		wxCloseCasinoModal();

		wxCasino.owner = _ownerMod || null;
		wxCasino.sqHandle = h;
		wxCasino.state = null;
		wxCasino.showRules = false;
		if (_initialKind) {
			wxCasino.kind = _initialKind;
			wxCasino.pick = (_initialKind === 'hazard') ? 7 : (_initialKind === 'symbols' ? 1 : 0);
		}

		var backdrop = $(
			'<div class="wx-gmb-backdrop">' +
				'<div class="wx-gmb-dialog">' +
					'<div style="padding:28rem 2rem;text-align:center;font-size:1.6rem;color:#dda21f;">庄家正在拭净榆木牌案、摆设紫铜骰盅……</div>' +
				'</div>' +
			'</div>'
		);
		wxGetHostRoot().append(backdrop);
		wxCasino.backdrop = backdrop;

		backdrop.on('click', function (_e) {
			if ($(_e.target).hasClass('wx-gmb-backdrop')) {
				wxCloseCasinoModal();
			}
		});
		$(document).on('keydown.wxCasinoModal', function (_e) {
			if (_e.keyCode === 27) {
				_e.preventDefault();
				_e.stopImmediatePropagation();
				wxCloseCasinoModal();
				return false;
			}
		});

		wxSendCasinoAction('refresh', 0, 0);
	};

	// ========================================================================
	// PART B: MARTIAL ARTS TOURNAMENT & BETTING MODAL (`天下武林大会 · 外围红盘`)
	// ========================================================================
	var wxTourney = {
		owner: null,
		sqHandle: null,
		backdrop: null,
		state: null,
		epoch: 0,
		busy: false,
		entranceMode: false,
		page: 'bracket', // 'bracket' | 'lineup' | 'gazette'
		eventId: 0,
		selectedMatch: 0,
		regionIdx: 0,
		picks: [],
		brothers: [],
		stakeText: '100',
		message: '',
		isErr: false,
		inspections: {},
		chosenFighter: { left: 0, right: 0 },
		treeScrollTop: 0,
		treeScrollLeft: 0,
		sideScrollTop: 0
	};

	function wxCloseTournamentModal() {
		wxTourney.epoch += 1;
		wxTourney.busy = false;
		$(document).off('keydown.wxTourneyModal');
		if (wxTourney.backdrop) {
			wxTourney.backdrop.remove();
			wxTourney.backdrop = null;
		}
		wxTourney.owner = null;
	}

	function wxFindTeam(_id) {
		var ev = wxTourney.state && wxTourney.state.event;
		if (!ev || !ev.teams || !_id) return null;
		return ev.teams[_id - 1] || null;
	}

	function wxTeamName(_id) {
		var t = wxFindTeam(_id);
		return t ? t.name : '待定晋级';
	}

	function wxHeadcountStr(_t) {
		if (!_t) return '';
		var cnt = (typeof _t.count === 'number') ? _t.count : 5;
		return cnt + (_t.unit || '人') + (_t.solo ? ' · 独身闯擂' : '');
	}

	function wxRoundName(_size, _r) {
		var n = _size / Math.pow(2, _r);
		if (n === 2) return _size === 64 ? '武林盟主总决赛' : '魁首总决赛';
		if (n === 4) return '四强半决赛';
		if (n === 8) return '八强论剑';
		if (n === 16) return '十六强争锋';
		if (n === 32) return '三十二强会武';
		return '六十四强初赛';
	}

	function wxRenderCrest(_t) {
		if (_t && _t.banner && /^banner_[0-9]+$/.test(_t.banner)) {
			return '<img class="wx-trn-crest" src="coui://gfx/ui/banners/' + wxEsc(_t.banner) + '.png" alt="" />';
		}
		return '<svg class="wx-trn-crest" viewBox="0 0 40 48"><path d="M4 4 H36 V26 L20 44 L4 26 Z" fill="#3a2717" stroke="#c8a464" stroke-width="2.5"/><path d="M12 13 L28 29 M28 13 L12 29" stroke="#ffe28a" stroke-width="2.5"/></svg>';
	}

	function wxRenderBust(_imgPath, _cls) {
		if (!_imgPath) return '';
		var prefix = (typeof Path !== 'undefined' && Path.PROCEDURAL) ? Path.PROCEDURAL : 'coui://';
		var src = (_imgPath.indexOf('coui://') === 0 || _imgPath.indexOf('procedural://') === 0) ? _imgPath : (prefix + _imgPath);
		return '<img class="' + (_cls || 'wx-trn-bust') + '" src="' + wxEsc(src) + '" alt="" />';
	}

	function wxRenderFighterDossier(_u, _hideHeaderName) {
		if (!_u) return '';
		var b = _u.basics || {};
		var gearHtml = '<div class="wx-trn-gear-row">';
		var gArr = _u.gear || [];
		var itemPrefix = (typeof Path !== 'undefined' && Path.ITEMS) ? Path.ITEMS : 'coui://gfx/ui/items/';
		for (var g = 0; g < gArr.length; g++) {
			if (gArr[g].icon) {
				gearHtml += '<img src="' + wxEsc(itemPrefix + gArr[g].icon) + '" title="' + wxEsc(gArr[g].name) + '" alt="" />';
			}
		}
		gearHtml += '</div>';

		var manHtml = '';
		var mArr = _u.manuals || [];
		if (mArr.length > 0) {
			manHtml = '<div class="wx-trn-manual-bar">';
			for (var m = 0; m < mArr.length; m++) {
				manHtml += '<span class="wx-trn-manual-pill">' + wxEsc(mArr[m]) + '</span>';
			}
			manHtml += '</div>';
		}

		var rows = [
			['气血', (b.hp || 0) + ' / ' + (b.hpMax || 0)],
			['行动力', (b.ap || 9) + ' AP'],
			['头甲 / 身甲', (b.head || 0) + ' / ' + (b.body || 0)],
			['武艺 / 射艺', (b.melee || 0) + ' / ' + (b.ranged || 0)],
			['招架 / 避暗', (b.meleeDefense || 0) + ' / ' + (b.rangedDefense || 0)]
		];
		var stHtml = '';
		for (var r = 0; r < rows.length; r++) {
			stHtml += '<div class="wx-trn-stat-row"><span>' + rows[r][0] + '</span><b>' + wxEsc(rows[r][1]) + '</b><div class="clear-both"></div></div>';
		}

		var nameLine = _hideHeaderName
			? ''
			: ('<div class="wx-trn-dossier-nm">' + wxEsc(_u.name) + '</div>');

		return (
			'<div class="wx-trn-dossier-wrap">' +
				'<div class="wx-trn-dossier">' +
					'<div class="wx-trn-dossier-fig">' +
						'<div class="wx-trn-dossier-img-box">' + wxRenderBust(_u.image, 'wx-trn-dossier-img') + '</div>' +
						nameLine +
						gearHtml +
					'</div>' +
					'<div class="wx-trn-dossier-stats">' +
						stHtml +
					'</div>' +
				'</div>' +
				manHtml +
			'</div>'
		);
	}

	function wxCalcTicketPreview() {
		var st = wxTourney.state;
		var lim = (st && st.limits) ? st.limits : { minimum: 10, maximum: 5000, payout: 1000000 };
		var n = /^[0-9]+$/.test(wxTourney.stakeText) ? parseInt(wxTourney.stakeText, 10) : NaN;
		var mult = 1.0;
		var ev = st && st.event;
		if (ev && ev.matches) {
			for (var i = 0; i < wxTourney.picks.length; i++) {
				var pk = wxTourney.picks[i];
				var m = ev.matches[pk[0] - 1];
				if (m) {
					mult *= ((pk[1] === m.left ? m.oddsLeft : m.oddsRight) / 100.0);
				}
			}
		}
		var err = '';
		if (isNaN(n) || n < lim.minimum || n > lim.maximum) {
			err = '每张银票限押 ' + lim.minimum + ' ~ ' + wxFmtSilver(lim.maximum) + ' 两纹银。';
		} else if (st && n > st.money) {
			err = '行囊现银仅有 ' + wxFmtSilver(st.money) + ' 两。';
		} else if (wxTourney.picks.length && (n * mult) > lim.payout) {
			err = '此票总赔付逾百万两上限，请减注或少串一场。';
		}
		return {
			amount: n || 0,
			mult: mult,
			payout: (!err && wxTourney.picks.length) ? Math.floor(n * mult) : 0,
			error: err
		};
	}

	function wxBuildRegistrationHtml(_ev) {
		var cands = wxTourney.state.candidates || [];
		var pickedCnt = wxTourney.brothers.length;
		var bDis = wxTourney.busy ? ' is-disabled' : '';
		var fee = (_ev && _ev.size === 64) ? 800 : 300;

		var html =
			'<div class="wx-trn-reg-wrap">' +
				'<div class="wx-trn-card-box">' +
					'<h3>英雄帖点将 · 报名登台或直接封签开盘</h3>' +
					'<p style="margin:0.3rem 0 0.7rem 0;line-height:1.9rem;color:#d7b174;">' +
						'监擂长老抚须朗声道：「本擂一战定晋级，点到为止绝不伤及性命！各派皆遣五名好手（或山海异兽、独行巨凶）登台演武。掌门可从麾下点选 5 位侠客递交英雄帖争魁夺彩（投名彩礼 ' + fee + ' 两，封签时划扣），亦可不派人登台，直接点击【封签开盘】审阅各派签表、买外围银票观战！」' +
					'</p>' +
					'<div>' +
						'<span class="wx-gmb-btn' + ((pickedCnt !== 5 || wxTourney.busy) ? ' is-disabled' : '') + '" data-trn-act="register">递交五人英雄帖 (' + pickedCnt + '/5 · ' + fee + '两)</span>' +
						'<span class="wx-gmb-btn' + ((!_ev.selected || !_ev.selected.length || wxTourney.busy) ? ' is-disabled' : '') + '" data-trn-act="withdraw">撤回本方报名</span>' +
						'<span class="wx-gmb-btn is-active' + bDis + '" data-trn-act="seal">' + (_ev.selected && _ev.selected.length === 5 ? '封签鸣锣 · 携队开赛！' : '直接封签开盘（纯观赛押注）') + '</span>' +
						'<span style="margin-left:0.8rem;color:#ffe28a;">' + (_ev.selected && _ev.selected.length === 5 ? '【义社五人名帖已入册】' : '当前未报名（可直接封签押注）') + '</span>' +
					'</div>' +
				'</div>' +
				'<div>';

		for (var i = 0; i < cands.length; i++) {
			var u = cands[i];
			var isPicked = false;
			for (var p = 0; p < wxTourney.brothers.length; p++) {
				if (wxTourney.brothers[p] === u.id) { isPicked = true; break; }
			}
			html +=
				'<div class="wx-trn-cand-card' + (isPicked ? ' is-picked' : '') + '" data-trn-bro="' + u.id + '">' +
					'<div class="wx-trn-cand-hdr">' +
						'<span class="wx-trn-cand-nm">' + wxEsc(u.name) + '</span>' +
						'<span class="wx-trn-cand-chk">' + (isPicked ? '已点将' : '点选登台') + '</span>' +
						'<div class="clear-both"></div>' +
					'</div>' +
					wxRenderFighterDossier(u, true) +
				'</div>';
		}
		html += '</div></div>';
		return html;
	}

	function wxBuildBracketCanvasHtml(_ev) {
		var regTabsHtml = '';
		var is64 = (_ev.size === 64);
		if (is64) {
			var regNames = wxTourney.state.regions64 || ['东岳青龙榜', '南疆朱雀榜', '西塞白虎榜', '北境玄武榜', '盟主决战坛'];
			regTabsHtml = '<div class="wx-trn-regions">';
			for (var rg = 0; rg < regNames.length; rg++) {
				regTabsHtml += '<span class="wx-gmb-btn is-sm' + (wxTourney.regionIdx === rg ? ' is-active' : '') + '" data-trn-reg="' + rg + '">' + wxEsc(regNames[rg]) + '</span>';
			}
			regTabsHtml += '</div>';
		}

		var rounds = (is64 && wxTourney.regionIdx < 4) ? [0, 1, 2, 3] : (is64 ? [4, 5] : [0, 1, 2, 3]);
		var baseRows = (is64 && wxTourney.regionIdx === 4) ? 2 : 8;
		var treeH = baseRows * 148 + 52;
		var treeW = rounds.length * 256 + 20;
		var posMap = {};
		var nodesHtml = '';
		var linesHtml = '';

		function renderSlot(_teamId, _fallbackTxt, _isWin) {
			var tm = wxFindTeam(_teamId);
			if (!tm) {
				return (
					'<div class="wx-trn-slot" style="opacity:0.65;">' +
						'<span class="wx-trn-empty-seal">待</span>' +
						'<span class="wx-trn-slot-nm">' + wxEsc(_fallbackTxt) + '</span>' +
					'</div>'
				);
			}
			return (
				'<div class="wx-trn-slot' + (_isWin ? ' is-win' : '') + '" title="' + wxEsc(tm.name + ' · ' + wxHeadcountStr(tm)) + '">' +
					wxRenderCrest(tm) +
					wxRenderBust(tm.image, 'wx-trn-bust') +
					'<span class="wx-trn-slot-nm">' + (_isWin ? '◆ ' : '') + wxEsc(tm.name) + '</span>' +
					'<span class="wx-trn-slot-sub">' + wxEsc(wxHeadcountStr(tm)) + '</span>' +
				'</div>'
			);
		}

		for (var col = 0; col < rounds.length; col++) {
			var r = rounds[col];
			nodesHtml += '<h4 style="left:' + (col * 256 + 12) + 'px;width:232px;">' + wxEsc(wxRoundName(_ev.size, r)) + '</h4>';
			for (var mi = 0; mi < _ev.matches.length; mi++) {
				var m = _ev.matches[mi];
				if (m.round !== r) continue;
				var perReg = Math.pow(2, 3 - r);
				var startIdx = (is64 && wxTourney.regionIdx < 4) ? (wxTourney.regionIdx * perReg) : 0;
				if (is64 && wxTourney.regionIdx < 4 && (m.index < startIdx || m.index >= startIdx + perReg)) continue;

				var localIdx = m.index - startIdx;
				var scale = Math.pow(2, col);
				var x = col * 256 + 12;
				var y = Math.round(44 + (localIdx + 0.5) * 148 * scale - 63);
				posMap[m.id] = { x: x, y: y + 63 };

				var stTxt = (m.status === 'done') ? '战罢分胜负'
					: (m.status === 'running' ? '正在交锋'
					: (m.status === 'interrupted' ? '待鸣锣重赛'
					: (m.status === 'open' ? ('开盘 ' + (m.oddsLeft / 100).toFixed(2) + ' / ' + (m.oddsRight / 100).toFixed(2)) : '静候上轮')));

				var mCls = 'wx-trn-match' + (m.id === wxTourney.selectedMatch ? ' is-selected' : '') + (m.status === 'done' ? ' is-done' : '');
				nodesHtml +=
					'<div class="' + mCls + '" data-trn-match="' + m.id + '" style="left:' + x + 'px;top:' + y + 'px;">' +
						'<span class="wx-trn-match-hdr">第 ' + m.id + ' 场 · ' + wxEsc(stTxt) + '</span>' +
						renderSlot(m.left, '第 ' + m.fromLeft + ' 场胜者', m.winner > 0 && m.winner === m.left) +
						renderSlot(m.right, '第 ' + m.fromRight + ' 场胜者', m.winner > 0 && m.winner === m.right) +
					'</div>';
			}
		}

		for (var li = 0; li < _ev.matches.length; li++) {
			var curM = _ev.matches[li];
			var destP = posMap[curM.id];
			if (!destP) continue;
			var srcIds = [curM.fromLeft, curM.fromRight];
			for (var s = 0; s < 2; s++) {
				var fid = srcIds[s];
				var srcP = posMap[fid];
				if (srcP) {
					var hasWin = _ev.matches[fid - 1] && _ev.matches[fid - 1].winner > 0;
					linesHtml += '<path class="' + (hasWin ? 'is-adv' : '') + '" d="M ' + (srcP.x + 232) + ' ' + srcP.y + ' H ' + (destP.x - 12) + ' V ' + destP.y + ' H ' + destP.x + '"/>';
				}
			}
		}

		return (
			regTabsHtml +
			'<div class="wx-trn-tree-scroll wx-gmb-scroll' + (is64 ? ' wx-trn-tree-ScrollWithReg' : '') + '" data-trn="tree-scroll">' +
				'<div class="wx-trn-tree" style="width:' + treeW + 'px;height:' + treeH + 'px;">' +
					'<svg class="wx-trn-lines" width="' + treeW + '" height="' + treeH + '">' + linesHtml + '</svg>' +
					nodesHtml +
				'</div>' +
			'</div>'
		);
	}

	function wxBuildWatchBtns(_ev, _m) {
		var isOwn = (_ev.player > 0 && (_m.left === _ev.player || _m.right === _ev.player));
		var bDis = wxTourney.busy ? ' is-disabled' : '';
		if (isOwn) {
			return '<span class="wx-gmb-btn is-active' + bDis + '" data-trn-act="start:' + _m.id + '">率领同袍登台出战！</span>';
		}
		return (
			'<span class="wx-gmb-btn' + bDis + '" data-trn-act="start:' + _m.id + '">入席慢品观战</span>' +
			'<span class="wx-gmb-btn is-sm' + bDis + '" data-trn-act="fast:' + _m.id + '">疾风快进(4x)</span>' +
			'<span class="wx-gmb-btn is-sm' + bDis + '" data-trn-act="report:' + _m.id + '">幕后听锣(12x)</span>'
		);
	}

	function wxBuildLineupHtml(_ev) {
		var m = wxTourney.selectedMatch ? _ev.matches[wxTourney.selectedMatch - 1] : null;
		if (!m) {
			return '<div style="padding:4rem;text-align:center;">请先在签表上点选一场对阵。</div>';
		}
		var insp = wxTourney.inspections[m.id] || null;
		var html =
			'<div class="wx-trn-lineup-wrap">' +
				'<div class="wx-trn-lineup-nav">' +
					'<span class="wx-gmb-btn is-sm" style="float:left;" data-trn-act="back_bracket">&lsaquo; 返回演武签表</span>' +
					'<span class="wx-gmb-btn is-sm' + (m.id <= 1 ? ' is-disabled' : '') + '" data-trn-act="match:' + Math.max(1, m.id - 1) + '">上一场</span>' +
					'<strong style="margin:0 1.2rem;font-size:1.5rem;color:#dda21f;font-weight:normal;">第 ' + m.id + ' 场 · ' + wxEsc(wxRoundName(_ev.size, m.round)) + '</strong>' +
					'<span class="wx-gmb-btn is-sm' + (m.id >= _ev.matches.length ? ' is-disabled' : '') + '" data-trn-act="match:' + Math.min(_ev.matches.length, m.id + 1) + '">下一场</span>' +
					'<div class="clear-both"></div>' +
				'</div>' +
				'<div class="wx-trn-duel-tbl">';

		var sides = ['left', 'right'];
		for (var s = 0; s < 2; s++) {
			var sd = sides[s];
			var tm = wxFindTeam(m[sd]);
			var units = (insp && insp[sd]) ? insp[sd] : [];
			var curU = null;
			for (var ui = 0; ui < units.length; ui++) {
				if (units[ui].id === wxTourney.chosenFighter[sd]) curU = units[ui];
			}
			if (!curU && units.length > 0) {
				curU = units[0];
				wxTourney.chosenFighter[sd] = curU.id;
			}

			html += '<div class="wx-trn-team-col">';
			html += '<div style="position:relative;padding-left:3.4rem;min-height:4.2rem;border-bottom:1px solid rgba(120,91,53,0.5);">' +
				wxRenderCrest(tm) +
				'<div style="font-size:1.55rem;color:#dda21f;">' + wxEsc(tm ? tm.name : '尚待上轮决出') + '</div>' +
				'<div style="font-size:1.2rem;color:#bd9d71;">' + wxEsc(tm ? (tm.faction + ' · ' + wxHeadcountStr(tm)) : ('等候第 ' + m[sd === 'left' ? 'fromLeft' : 'fromRight'] + ' 场胜者')) + '</div>' +
			'</div>';

			if (tm && tm.story) {
				html += '<div style="font-size:1.22rem;line-height:1.7rem;color:#bd9d71;margin:0.45rem 0;">' + wxEsc(tm.story) + '</div>';
			}

			if (units.length > 0) {
				html += '<div>';
				for (var j = 0; j < units.length; j++) {
					var v = units[j];
					var isSel = (curU && curU.id === v.id);
					html +=
						'<div class="wx-trn-strip-btn' + (isSel ? ' is-sel' : '') + '" data-trn-fighter="' + sd + ':' + v.id + '">' +
							wxRenderBust(v.image, '') +
							'<span class="wx-trn-strip-nm">' + wxEsc(v.name) + '</span>' +
						'</div>';
				}
				html += '</div>';
				html += wxRenderFighterDossier(curU);
			} else {
				html += '<div style="padding:3rem 1rem;text-align:center;color:#bd9d71;">' + (tm ? '正在调阅登台武人卷宗……' : '待上一轮胜者出炉后揭晓阵容。') + '</div>';
			}

			if (m.status === 'done' && m.winner === m[sd]) {
				html += '<div style="margin-top:0.5rem;text-align:center;color:#5ec47a;font-size:1.45rem;">★ 本场获胜晋级 ★</div>';
			} else if (m.status === 'open' && tm) {
				var oddsVal = ((sd === 'left' ? m.oddsLeft : m.oddsRight) / 100.0).toFixed(2);
				var forbidSelfLoss = (_ev.player > 0 && (m.left === _ev.player || m.right === _ev.player) && tm.id !== _ev.player);
				html += '<div style="margin-top:0.55rem;text-align:center;">' +
					'<span class="wx-gmb-btn' + ((forbidSelfLoss || wxTourney.busy) ? ' is-disabled' : '') + '" data-trn-act="pick:' + m.id + ':' + tm.id + '">' +
						'押【' + wxEsc(tm.name) + '】胜 · ' + oddsVal + ' 倍' +
					'</span>' +
				'</div>';
			}
			html += '</div>';
		}
		html += '</div>';

		if (m.report && m.report.text) {
			html += '<div class="wx-trn-card-box" style="margin-top:0.7rem;"><h3>监擂朱批战报 · ' + wxEsc(m.report.title || '演武纪实') + '</h3><div style="line-height:1.9rem;">' + wxEsc(m.report.text) + '</div></div>';
		}
		if (m.status === 'open' || m.status === 'interrupted') {
			html += '<div style="margin-top:0.65rem;text-align:center;">' + wxBuildWatchBtns(_ev, m) + '</div>';
		}
		html += '</div>';
		return html;
	}

	function wxBuildSidebarHtml(_ev) {
		var html = '';
		var m = wxTourney.selectedMatch ? _ev.matches[wxTourney.selectedMatch - 1] : null;

		// 1. Selected Match Quick Card
		html += '<div class="wx-trn-card-box"><h3>对阵盘口详情</h3>';
		if (!m) {
			html += '<div style="color:#bd9d71;line-height:1.85rem;">点选左侧签表上的任意场次，即可审阅双方门派五人武学阵容、买红盘银票或鸣锣开赛！</div>';
		} else {
			html += '<div style="font-size:1.38rem;color:#ffe28a;margin-bottom:0.35rem;">第 ' + m.id + ' 场 · ' + wxEsc(wxRoundName(_ev.size, m.round)) + '</div>';
			html += '<div style="margin-bottom:0.45rem;color:#d7b174;">' + wxEsc(wxTeamName(m.left)) + ' <span style="color:#dda21f;">对决</span> ' + wxEsc(wxTeamName(m.right)) + '</div>';
			if (m.left > 0 && m.right > 0 && wxTourney.page !== 'lineup') {
				html += '<div><span class="wx-gmb-btn is-sm" style="width:94%;" data-trn-act="inspect:' + m.id + '">审阅双方武学与兵甲阵容</span></div>';
			}
			if (m.status === 'open') {
				var fLeft = (_ev.player > 0 && (m.left === _ev.player || m.right === _ev.player) && m.left !== _ev.player);
				var fRight = (_ev.player > 0 && (m.left === _ev.player || m.right === _ev.player) && m.right !== _ev.player);
				html += '<div style="margin-top:0.4rem;">' +
					'<span class="wx-gmb-btn is-sm' + (fLeft ? ' is-disabled' : '') + '" style="width:94%;" data-trn-act="pick:' + m.id + ':' + m.left + '">加入银票：' + wxEsc(wxTeamName(m.left)) + ' (' + (m.oddsLeft / 100).toFixed(2) + '倍)</span>' +
					'<span class="wx-gmb-btn is-sm' + (fRight ? ' is-disabled' : '') + '" style="width:94%;" data-trn-act="pick:' + m.id + ':' + m.right + '">加入银票：' + wxEsc(wxTeamName(m.right)) + ' (' + (m.oddsRight / 100).toFixed(2) + '倍)</span>' +
				'</div>';
			} else if (m.status === 'done') {
				html += '<div style="margin-top:0.35rem;color:#5ec47a;">胜方：' + wxEsc(wxTeamName(m.winner)) + '</div>';
				if (m.report && m.report.text) {
					html += '<div style="margin-top:0.3rem;font-size:1.2rem;line-height:1.65rem;color:#bd9d71;">' + wxEsc(m.report.text) + '</div>';
				}
			}
			if (m.status === 'open' || m.status === 'interrupted') {
				html += '<div style="margin-top:0.5rem;text-align:center;">' + wxBuildWatchBtns(_ev, m) + '</div>';
			}
		}
		html += '</div>';

		// 2. Betting Slip (`外围红盘银票签发台`)
		var betPrev = wxCalcTicketPreview();
		html += '<div class="wx-trn-card-box"><h3>签发红盘银票' + (wxTourney.picks.length > 1 ? (' · ' + wxTourney.picks.length + '场连环串票') : '') + '</h3>';
		if (!wxTourney.picks.length) {
			html += '<div style="color:#bd9d71;font-size:1.22rem;margin-bottom:0.45rem;">尚未勾选场次（可押单场，亦可将同轮最多 6 场串成一张高倍连环票！）</div>';
		} else {
			for (var pi = 0; pi < wxTourney.picks.length; pi++) {
				var pk = wxTourney.picks[pi];
				var pm = _ev.matches[pk[0] - 1];
				var pOdds = pm ? ((pk[1] === pm.left ? pm.oddsLeft : pm.oddsRight) / 100.0).toFixed(2) : '1.00';
				html +=
					'<div class="wx-trn-leg-row">' +
						'<span class="wx-trn-leg-del" data-trn-rmpick="' + pi + '" title="移出银票">&times;</span>' +
						'第 ' + pk[0] + ' 场 · <span style="color:#ffe28a;">' + wxEsc(wxTeamName(pk[1])) + '</span> (' + pOdds + '倍)' +
					'</div>';
			}
			html += '<div style="font-size:1.24rem;color:#dda21f;margin:0.3rem 0;">综合赔率：' + betPrev.mult.toFixed(2) + ' 倍</div>';
		}

		html +=
			'<div style="margin:0.4rem 0;">押银 <input type="text" class="wx-gmb-input" style="width:9.2rem;font-size:1.4rem;" data-trn-inp="stake" maxlength="8" value="' + wxEsc(wxTourney.stakeText) + '" /> 两纹银</div>' +
			'<div style="margin-bottom:0.4rem;">' +
				'<span class="wx-gmb-btn is-sm" data-trn-chip="50">50</span>' +
				'<span class="wx-gmb-btn is-sm" data-trn-chip="200">200</span>' +
				'<span class="wx-gmb-btn is-sm" data-trn-chip="500">500</span>' +
				'<span class="wx-gmb-btn is-sm" data-trn-chip="1000">1千</span>' +
				'<span class="wx-gmb-btn is-sm" data-trn-chip="5000">5千</span>' +
			'</div>' +
			(betPrev.error ? '<div style="color:#ff8070;font-size:1.2rem;margin-bottom:0.3rem;" data-trn="bet-err">' + wxEsc(betPrev.error) + '</div>' : '<div style="color:#5ec47a;font-size:1.26rem;margin-bottom:0.3rem;" data-trn="bet-pay">全中可兑：' + wxFmtSilver(betPrev.payout) + ' 两纹银（含本金）</div>') +
			'<div><span class="wx-gmb-btn' + ((!wxTourney.picks.length || !!betPrev.error || wxTourney.busy) ? ' is-disabled' : '') + '" style="width:94%;" data-trn-act="bet" data-trn="bet-btn">朱笔交银开票</span></div>' +
		'</div>';

		// 3. My Tickets (`我的红盘银票匣`)
		var tks = _ev.tickets || [];
		html += '<div class="wx-trn-card-box"><h3>我的银票匣 (' + tks.length + ')</h3>';
		if (!tks.length) {
			html += '<div style="color:#bd9d71;font-size:1.22rem;">本届大会尚未购入红盘银票。</div>';
		} else {
			for (var ti = tks.length - 1; ti >= 0; ti--) {
				var tk = tks[ti];
				var stMap = { waiting: '候锣待战', lost: '惜未押中', won: '★ 押中红盘！', void: '退还本银' };
				var stColor = tk.paid ? '#bd9d71' : (tk.value.status === 'won' ? '#5ec47a' : (tk.value.status === 'lost' ? '#ff8070' : '#ffe28a'));
				html += '<div class="wx-trn-receipt">';
				html += '<div><strong style="color:#dda21f;font-weight:normal;">第 ' + tk.id + ' 号银票 · 本银 ' + wxFmtSilver(tk.stake) + ' 两</strong></div>';
				for (var lg = 0; lg < tk.legs.length; lg++) {
					var leg = tk.legs[lg];
					html += '<div style="color:#bd9d71;font-size:1.18rem;">· 第 ' + leg.match + ' 场 ' + wxEsc(wxTeamName(leg.team)) + ' (' + (leg.odds / 100).toFixed(2) + '倍)</div>';
				}
				html += '<div style="margin-top:0.2rem;color:' + stColor + ';">' +
					(tk.paid ? ('已兑讫 · 实领 ' + wxFmtSilver(tk.receipt) + ' 两') : (stMap[tk.value.status] || tk.value.status)) +
				'</div>';
				if (!tk.paid && tk.value.status !== 'waiting') {
					html += '<div style="margin-top:0.25rem;"><span class="wx-gmb-btn is-sm" style="width:92%;" data-trn-act="claim:' + tk.id + '">' +
						(tk.value.amount > 0 ? ('凭票兑付 ' + wxFmtSilver(tk.value.amount) + ' 两纹银') : '核销未中银票') +
					'</span></div>';
				}
				html += '</div>';
			}
		}
		html += '</div>';
		return html;
	}

	function wxBuildGazetteHtml() {
		var rows = (wxTourney.state && wxTourney.state.gazette) ? wxTourney.state.gazette : [];
		if (!rows.length) {
			return '<div style="padding:5rem;text-align:center;color:#bd9d71;">九州各州府演武英雄帖尚在筹备之中。</div>';
		}
		var phaseLbl = { registration: '广收英雄帖', open: '火热开擂收注', finished: '桂冠已定' };
		var html = '<div style="padding:0.8rem 0.6rem;">';
		for (var i = 0; i < rows.length; i++) {
			var r = rows[i];
			html +=
				'<div class="wx-trn-gazette-item">' +
					'<div class="wx-trn-gazette-hdr">【' + wxEsc(r.town) + '】第 ' + r.edition + ' 届《' + wxEsc(r.title) + '》(' + r.size + '强 · ' + wxEsc(phaseLbl[r.phase] || r.phase) + ')　<span style="float:right;font-size:1.22rem;color:#bd9d71;">第 ' + r.day + ' 日邸报</span></div>' +
					'<div style="line-height:1.9rem;color:#d7b174;">' + wxEsc(r.text) + '</div>' +
				'</div>';
		}
		html += '</div>';
		return html;
	}

	function wxRenderTournamentModal() {
		if (!wxTourney.backdrop) return;
		var st = wxTourney.state;
		var dialog = wxTourney.backdrop.find('.wx-gmb-dialog:first');

		var oldTree = dialog.find('[data-trn="tree-scroll"]');
		if (oldTree.length) {
			wxTourney.treeScrollTop = oldTree.scrollTop() || 0;
			wxTourney.treeScrollLeft = oldTree.scrollLeft() || 0;
		}
		var oldSide = dialog.find('.wx-trn-side-pane');
		if (oldSide.length) {
			wxTourney.sideScrollTop = oldSide.scrollTop() || 0;
		}

		if (!st) {
			dialog.removeClass('is-gate').html('<div style="padding:28rem 2rem;text-align:center;font-size:1.6rem;color:#dda21f;">知客执事正在展阅英雄签表与外围银册……</div>');
			return;
		}

		// Dual-Gate Entrance (`红绸生死演武擂`)
		if (wxTourney.entranceMode && st.hasNativeArena) {
			dialog.addClass('is-gate').html(
				'<div class="wx-gmb-hdr">' +
					'<img class="wx-gmb-hdr-art" src="coui://gfx/ui/events/wx_ev_05.png" alt="" />' +
					'<div class="wx-gmb-hdr-title">【' + wxEsc(st.town) + '】演武门楼 · 生死擂与武林大会</div>' +
					'<div class="wx-gmb-hdr-close" data-trn-act="close"><img src="coui://gfx/ui/skin/icon_cross.png" alt="" /></div>' +
				'</div>' +
				'<div class="wx-gmb-gold-line"></div>' +
				'<div style="padding:0.4rem 0.6rem;color:#bd9d71;font-size:1.34rem;">守门老武师抱拳一揖，伸手指引左右两道门楼：「左门签生死状搏西域血赏，右门赴武林大会夺盟主桂冠、押外围红盘——掌门请择道而入！」</div>' +
				'<div class="wx-trn-gate-grid">' +
					'<div class="wx-trn-gate-card">' +
						'<h3>红绸生死擂（原版赏金死斗）</h3>' +
						'<img class="wx-trn-gate-art" src="coui://gfx/ui/events/wx_ev_02.png" alt="" />' +
						'<p>坊主手握带血契书，黄沙死斗场内呐喊震天。接下三对三生死斗技契约，遣麾下好手真刀真枪搏命厮杀，赢取丰厚赏银与斗士荣耀。</p>' +
						'<div style="text-align:center;margin-top:0.8rem;"><span class="wx-gmb-btn is-lg" data-trn-act="native">寻坊主签生死状</span></div>' +
					'</div>' +
					'<div class="wx-trn-gate-card">' +
						'<h3>天下武林大会（演武夺魁 · 外围红盘）</h3>' +
						'<img class="wx-trn-gate-art" src="coui://gfx/ui/events/wx_ev_05.png" alt="" />' +
						'<p>九州四十四派精锐与山海奇兽齐聚高台，监擂长老护持点到为止不伤性命！可报名五人争魁赢盟主彩头，更可审阅对阵、买单场或连环红盘银票入席观战！</p>' +
						'<div style="text-align:center;margin-top:0.8rem;"><span class="wx-gmb-btn is-lg is-active" data-trn-act="enter_tourney">展阅大会签表与红盘</span></div>' +
					'</div>' +
				'</div>' +
				(wxTourney.message ? '<div class="wx-trn-feedback' + (wxTourney.isErr ? ' is-err' : '') + '" style="margin-top:1.0rem;">' + wxEsc(wxTourney.message) + '</div>' : '')
			);
			wxBindTournamentEvents(dialog);
			return;
		}

		dialog.removeClass('is-gate');
		var ev = st.event;
		var evBtnsHtml = '';
		if (st.isHostTown && st.events) {
			for (var i = 0; i < st.events.length; i++) {
				var item = st.events[i];
				var isCur = (wxTourney.page !== 'gazette' && ev && item.id === ev.id);
				evBtnsHtml += '<span class="wx-gmb-btn' + (isCur ? ' is-active' : '') + '" data-trn-act="event:' + item.id + '">《' + wxEsc(item.title) + '》' + item.size + '强 · 第' + item.edition + '届' +
					(item.awaitingPayout ? '（待兑银票）' : '') + '</span>';
			}
		}
		evBtnsHtml += '<span class="wx-gmb-btn' + (wxTourney.page === 'gazette' || !st.isHostTown ? ' is-active' : '') + '" data-trn-act="show_gazette">九州演武英雄榜 (' + (st.gazette ? st.gazette.length : 0) + ')</span>';
		if (st.hasNativeArena) {
			evBtnsHtml += '<span class="wx-gmb-btn is-sm" style="float:right;" data-trn-act="gate_back">返回演武门楼</span>';
		}

		var hdrTitle = (!st.isHostTown || wxTourney.page === 'gazette')
			? '九州演武英雄榜 · 武林大会邸报总览'
			: (ev ? ('【' + wxEsc(st.town) + '】第 ' + ev.edition + ' 届《' + wxEsc(ev.title) + '》') : '武林大会');

		var champNote = (ev && ev.champion)
			? ('　<span style="color:#5ec47a;">★ 本届魁首：' + wxEsc(wxTeamName(ev.champion)) + ' ★</span>')
			: '';

		var bodyHtml = '';
		if (!st.isHostTown || wxTourney.page === 'gazette' || !ev) {
			bodyHtml =
				'<div class="wx-trn-body">' +
					'<div class="wx-trn-main-pane wx-gmb-scroll" style="right:0;">' + wxBuildGazetteHtml() + '</div>' +
				'</div>';
		} else if (ev.phase === 'registration') {
			bodyHtml =
				'<div class="wx-trn-body">' +
					'<div class="wx-trn-main-pane wx-gmb-scroll" style="right:0;">' + wxBuildRegistrationHtml(ev) + '</div>' +
				'</div>';
		} else {
			bodyHtml =
				'<div class="wx-trn-body">' +
					'<div class="wx-trn-main-pane wx-gmb-scroll">' +
						(wxTourney.page === 'lineup' ? wxBuildLineupHtml(ev) : wxBuildBracketCanvasHtml(ev)) +
					'</div>' +
					'<div class="wx-trn-side-pane wx-gmb-scroll">' + wxBuildSidebarHtml(ev) + '</div>' +
				'</div>';
		}

		dialog.html(
			'<div class="wx-gmb-hdr">' +
				'<img class="wx-gmb-hdr-art" src="coui://gfx/ui/events/wx_ev_05.png" alt="" />' +
				'<div class="wx-gmb-hdr-title">' + hdrTitle + '</div>' +
				'<div class="wx-gmb-hdr-silver">' +
					'<img src="coui://gfx/ui/wx_icons/wx_asset_money.png" alt="" />现银：<strong>' + wxFmtSilver(st.money) + '</strong> 两' +
				'</div>' +
				'<div class="wx-gmb-hdr-close" data-trn-act="close" title="离开柜台"><img src="coui://gfx/ui/skin/icon_cross.png" alt="" /></div>' +
			'</div>' +
			'<div class="wx-gmb-gold-line"></div>' +
			'<div class="wx-trn-top-bar">' + evBtnsHtml + '<div class="clear-both"></div></div>' +
			'<div class="wx-trn-feedback' + (wxTourney.isErr ? ' is-err' : '') + '">' +
				(wxTourney.message ? wxEsc(wxTourney.message) : ('主会场：' + wxEsc(st.town) + ' · 外围红盘单张可押 10 ~ 5,000 两纹银（支持 6 场连环串关）')) +
				champNote +
			'</div>' +
			bodyHtml
		);

		wxBindTournamentEvents(dialog);

		var newTree = dialog.find('[data-trn="tree-scroll"]');
		if (newTree.length) {
			newTree.scrollTop(wxTourney.treeScrollTop);
			newTree.scrollLeft(wxTourney.treeScrollLeft);
		}
		var newSide = dialog.find('.wx-trn-side-pane');
		if (newSide.length) {
			newSide.scrollTop(wxTourney.sideScrollTop);
		}
	}

	function wxBindTournamentEvents(_dialog) {
		_dialog.find('input').on('keydown keypress keyup', function (_e) {
			if (_e.keyCode !== 27) _e.stopPropagation();
		});

		_dialog.find('[data-trn-inp="stake"]').on('input change keyup', function () {
			wxTourney.stakeText = $(this).val() || '';
			var prev = wxCalcTicketPreview();
			var payNode = _dialog.find('[data-trn="bet-pay"]');
			var errNode = _dialog.find('[data-trn="bet-err"]');
			if (prev.error) {
				if (payNode.length) payNode.css('color', '#ff8070').text(prev.error);
				if (errNode.length) errNode.text(prev.error);
			} else {
				var txt = '全中可兑：' + wxFmtSilver(prev.payout) + ' 两纹银（含本金）';
				if (payNode.length) payNode.css('color', '#5ec47a').text(txt);
				if (errNode.length) errNode.css('color', '#5ec47a').text(txt);
			}
			_dialog.find('[data-trn="bet-btn"]').toggleClass('is-disabled', !wxTourney.picks.length || !!prev.error || wxTourney.busy);
		});

		_dialog.find('[data-trn-chip]').on('click', function () {
			if (wxTourney.busy) return;
			wxTourney.stakeText = String($(this).attr('data-trn-chip') || '100');
			wxRenderTournamentModal();
		});

		_dialog.find('[data-trn-rmpick]').on('click', function () {
			if (wxTourney.busy) return;
			var idx = parseInt($(this).attr('data-trn-rmpick'), 10);
			if (!isNaN(idx)) {
				wxTourney.picks.splice(idx, 1);
				wxRenderTournamentModal();
			}
		});

		_dialog.find('[data-trn-reg]').on('click', function () {
			if (wxTourney.busy) return;
			wxTourney.regionIdx = parseInt($(this).attr('data-trn-reg'), 10) || 0;
			wxTourney.treeScrollTop = 0;
			wxTourney.treeScrollLeft = 0;
			wxRenderTournamentModal();
		});

		_dialog.find('[data-trn-match]').on('click', function () {
			if (wxTourney.busy) return;
			var mid = parseInt($(this).attr('data-trn-match'), 10) || 0;
			if (!mid) return;
			if (wxTourney.selectedMatch === mid) {
				wxTourney.page = 'lineup';
				wxTourney.chosenFighter = { left: 0, right: 0 };
				wxSendTournamentRequest('inspect', mid, 0);
			} else {
				wxTourney.selectedMatch = mid;
				wxRenderTournamentModal();
			}
		});

		_dialog.find('[data-trn-fighter]').on('click', function () {
			if (wxTourney.busy) return;
			var parts = String($(this).attr('data-trn-fighter') || '').split(':');
			if (parts.length === 2) {
				wxTourney.chosenFighter[parts[0]] = parseInt(parts[1], 10) || 0;
				wxRenderTournamentModal();
			}
		});

		_dialog.find('[data-trn-bro]').on('click', function () {
			if (wxTourney.busy) return;
			var bid = parseInt($(this).attr('data-trn-bro'), 10) || 0;
			if (!bid) return;
			var nextBros = [];
			var existed = false;
			for (var i = 0; i < wxTourney.brothers.length; i++) {
				if (wxTourney.brothers[i] === bid) existed = true;
				else nextBros.push(wxTourney.brothers[i]);
			}
			if (!existed) {
				if (nextBros.length >= 5) {
					wxTourney.message = '每届大会至多点选 5 位侠客联袂登台（可先取消一人再换将）。';
					wxTourney.isErr = true;
					wxRenderTournamentModal();
					return;
				}
				nextBros.push(bid);
			}
			wxTourney.brothers = nextBros;
			wxTourney.message = '';
			wxTourney.isErr = false;
			wxRenderTournamentModal();
		});

		_dialog.find('[data-trn-act]').on('click', function () {
			if ($(this).hasClass('is-disabled')) return;
			var raw = String($(this).attr('data-trn-act') || '');
			var parts = raw.split(':');
			var act = parts[0];

			if (act === 'close') {
				wxCloseTournamentModal();
				return;
			}
			if (wxTourney.busy) return;

			if (act === 'gate_back') {
				wxTourney.entranceMode = true;
				wxRenderTournamentModal();
			} else if (act === 'enter_tourney') {
				wxTourney.entranceMode = false;
				wxTourney.page = 'bracket';
				wxRenderTournamentModal();
			} else if (act === 'show_gazette') {
				wxTourney.page = 'gazette';
				wxRenderTournamentModal();
			} else if (act === 'back_bracket') {
				wxTourney.page = 'bracket';
				wxRenderTournamentModal();
			} else if (act === 'event') {
				wxTourney.eventId = parseInt(parts[1], 10) || 0;
				wxTourney.selectedMatch = 0;
				wxTourney.regionIdx = 0;
				wxTourney.picks = [];
				wxTourney.brothers = [];
				wxTourney.inspections = {};
				wxTourney.page = 'bracket';
				wxTourney.treeScrollTop = 0;
				wxTourney.treeScrollLeft = 0;
				wxSendTournamentRequest('view', 0, 0);
			} else if (act === 'match' || act === 'inspect') {
				var mid = parseInt(parts[1], 10) || 0;
				wxTourney.selectedMatch = mid;
				wxTourney.page = 'lineup';
				wxTourney.chosenFighter = { left: 0, right: 0 };
				wxSendTournamentRequest('inspect', mid, 0);
			} else if (act === 'register') {
				wxSendTournamentRequest('register', wxTourney.brothers, 0);
			} else if (act === 'withdraw' || act === 'seal' || act === 'native') {
				wxSendTournamentRequest(act, 0, 0);
			} else if (act === 'pick') {
				var pMid = parseInt(parts[1], 10) || 0;
				var pTid = parseInt(parts[2], 10) || 0;
				var filtered = [];
				for (var i = 0; i < wxTourney.picks.length; i++) {
					if (wxTourney.picks[i][0] !== pMid) filtered.push(wxTourney.picks[i]);
				}
				if (filtered.length >= 6) {
					wxTourney.message = '单张连环红盘银票最多串押 6 场对阵。';
					wxTourney.isErr = true;
					wxRenderTournamentModal();
					return;
				}
				filtered.push([pMid, pTid]);
				wxTourney.picks = filtered;
				wxTourney.message = '已将第 ' + pMid + ' 场【' + wxTeamName(pTid) + '】加入右侧红盘银票！';
				wxTourney.isErr = false;
				wxPlaySound(wxTourney.sqHandle, 'stake');
				wxRenderTournamentModal();
			} else if (act === 'bet') {
				var bInfo = wxCalcTicketPreview();
				if (!bInfo.error && wxTourney.picks.length) {
					wxSendTournamentRequest('bet', wxTourney.picks, bInfo.amount);
				}
			} else if (act === 'start' || act === 'fast' || act === 'report' || act === 'claim') {
				wxSendTournamentRequest(act, parseInt(parts[1], 10) || 0, 0);
			}
		});
	}

	function wxSendTournamentRequest(_action, _param, _amount) {
		if (wxTourney.busy || !wxTourney.sqHandle) return;
		wxTourney.busy = true;
		var tok = wxTourney.epoch;
		var rev = wxTourney.state ? wxTourney.state.revision : 0;

		SQ.call(wxTourney.sqHandle, 'onWXTournamentAction', [_action, wxTourney.eventId, _param || 0, _amount || 0, rev], function (_res) {
			if (!wxTourney.backdrop || wxTourney.epoch !== tok) return;
			wxTourney.busy = false;
			if (!_res) {
				wxTourney.message = '知客执事暂未回话，请稍候再试。';
				wxTourney.isErr = true;
				wxRenderTournamentModal();
				return;
			}
			if (_res.closed) {
				wxCloseTournamentModal();
				return;
			}
			if (_res.arena) {
				wxTourney.state = _res.arena;
				if (_res.arena.event) {
					var eventChanged = wxTourney.eventId !== _res.arena.event.id;
					if (eventChanged) {
						wxTourney.selectedMatch = 0;
						wxTourney.inspections = {};
						wxTourney.picks = [];
						if (wxTourney.page !== 'gazette') wxTourney.page = 'bracket';
					}
					wxTourney.eventId = _res.arena.event.id;
					if ((eventChanged || _action === 'view' || _action === 'register' || _action === 'withdraw') && _res.arena.event.selected) {
						wxTourney.brothers = _res.arena.event.selected.slice(0);
					}
					if (!wxTourney.selectedMatch && _res.arena.event.matches && _res.arena.event.matches.length) {
						for (var i = 0; i < _res.arena.event.matches.length; i++) {
							if (_res.arena.event.matches[i].round === _res.arena.event.round) {
								wxTourney.selectedMatch = _res.arena.event.matches[i].id;
								break;
							}
						}
					}
				}
				if (_res.arena.inspection) {
					wxTourney.inspections[_res.arena.inspection.match] = _res.arena.inspection;
				}
			}
			if (_res.Assets) wxSyncTopbarAssets(wxTourney.owner, _res.Assets);
			wxTourney.message = _res.message || '';
			wxTourney.isErr = !_res.ok;
			if (_res.ok && _action === 'bet') {
				wxTourney.picks = [];
			}
			wxRenderTournamentModal();
			if (_res.ok && _res.wxShowcase && window.WX_Showcase) {
				window.WX_Showcase.play(_res.wxShowcase, { sqHandle: wxTourney.sqHandle });
			}
		});
	}

	window.WX_OpenTournamentModal = function (_ownerMod, _sqHandle, _targetInfo, _atEntrance) {
		var h = _sqHandle || (_ownerMod ? _ownerMod.mSQHandle : null);
		if (!h) return;
		wxCloseCasinoModal();
		wxCloseTournamentModal();

		wxTourney.owner = _ownerMod || null;
		wxTourney.sqHandle = h;
		wxTourney.state = null;
		wxTourney.entranceMode = !!_atEntrance;
		wxTourney.eventId = (_targetInfo && typeof _targetInfo === 'object') ? (Number(_targetInfo.event) || 0) : (Number(_targetInfo) || 0);
		wxTourney.selectedMatch = (_targetInfo && typeof _targetInfo === 'object') ? (Number(_targetInfo.match) || 0) : 0;
		wxTourney.regionIdx = 0;
		wxTourney.picks = [];
		wxTourney.brothers = [];
		wxTourney.message = '';
		wxTourney.isErr = false;
		wxTourney.inspections = {};
		wxTourney.page = wxTourney.selectedMatch ? 'lineup' : 'bracket';
		wxTourney.treeScrollTop = 0;
		wxTourney.treeScrollLeft = 0;
		wxTourney.sideScrollTop = 0;

		var backdrop = $('<div class="wx-gmb-backdrop"><div class="wx-gmb-dialog"></div></div>');
		wxGetHostRoot().append(backdrop);
		wxTourney.backdrop = backdrop;

		backdrop.on('click', function (_e) {
			if ($(_e.target).hasClass('wx-gmb-backdrop')) {
				wxCloseTournamentModal();
			}
		});
		$(document).on('keydown.wxTourneyModal', function (_e) {
			if (_e.keyCode === 27) {
				_e.preventDefault();
				_e.stopImmediatePropagation();
				if (!wxTourney.entranceMode && wxTourney.page === 'lineup') {
					wxTourney.page = 'bracket';
					wxRenderTournamentModal();
				} else {
					wxCloseTournamentModal();
				}
				return false;
			}
		});

		wxRenderTournamentModal();
		wxSendTournamentRequest(wxTourney.selectedMatch ? 'inspect' : 'view', wxTourney.selectedMatch, 0);
	};

	// ========================================================================
	// PART C: TAVERN, TOWN SCREEN & TACTICAL WATCH BAR HOOKS
	// ========================================================================
	if (typeof WorldTownScreenTavernDialogModule !== 'undefined') {
		var tavProto = WorldTownScreenTavernDialogModule.prototype;
		var origTavCreate = tavProto.createDIV;
		var origTavLoad = tavProto.loadFromData;
		var origTavHide = tavProto.hide;
		var origTavDestroy = tavProto.destroyDIV;

		var wxEnsureTavernSections = function (_mod) {
			var content = _mod.mDialogContainer.findDialogContentContainer();
			if (content.find('.wx-tavern-sections').length) return;
			content.addClass('wx-tavern-content');
			var entries = [
				['casino', 'wx_icon_money', '长乐赌桌', '马吊、叶子戏与骨骰'],
				['teahouse', 'wx_glyph_sect_token', '江湖茶座', '会见各派门人，打探山门'],
				['tourney', 'wx_icon_ambition', '演武英雄榜', '查看大会风声与对阵']
			];
			var sections = $('<div class="wx-tavern-sections"></div>');
			for (var i = 0; i < entries.length; i++) {
				var e = entries[i];
				sections.append('<button type="button" class="wx-tavern-entry wx-tavern-' + e[0] + '-btn" data-entry="' + e[0] + '">' +
					'<img src="coui://gfx/ui/wx_icons/' + e[1] + '.png" alt=""/><strong>' + e[2] +
					'</strong><small>' + e[3] + '</small></button>');
			}
			sections.on('click', '[data-entry]', function () {
				var key = $(this).attr('data-entry');
				if (_mod.mSQHandle == null) return;
				if (key === 'teahouse') window.WX_OpenSectDirectory(_mod.mSQHandle, null, 'teahouse');
				else if (key === 'casino') window.WX_OpenCasinoModal(_mod, _mod.mSQHandle, null);
				else window.WX_OpenTournamentModal(_mod, _mod.mSQHandle, 0, false);
			});
			content.append(sections);
		};

		if (origTavCreate) {
			tavProto.createDIV = function (_parentDiv) {
				origTavCreate.call(this, _parentDiv);
				wxEnsureTavernSections(this);
			};
		}

		if (origTavLoad) {
			tavProto.loadFromData = function (_data) {
				origTavLoad.call(this, _data);
				if (this.mDialogContainer && _data) {
					wxEnsureTavernSections(this);
					var casBtn = this.mDialogContainer.find('.wx-tavern-casino-btn');
					if (casBtn.length) {
						casBtn.find('.wx-pending-dot').remove();
						if (_data.WX_PendingGamble) {
							casBtn.append('<span class="wx-pending-dot" title="有未完赌局"></span>');
						}
					}
					var tourney = this.mDialogContainer.find('.wx-tavern-tourney-btn');
					tourney.find('strong').text(_data.WX_IsTournamentHost ? '演武总坛' : '演武英雄榜');
					tourney.find('small').text(_data.WX_IsTournamentHost ? '查看签表，报名或下注' : '查看大会风声与对阵');
				}
			};
		}

		if (origTavHide) {
			tavProto.hide = function () {
				if (wxCasino.owner === this) wxCloseCasinoModal();
				if (wxTourney.owner === this) wxCloseTournamentModal();
				return origTavHide.apply(this, arguments);
			};
		}

		if (origTavDestroy) {
			tavProto.destroyDIV = function () {
				if (wxCasino.owner === this) wxCloseCasinoModal();
				if (wxTourney.owner === this) wxCloseTournamentModal();
				return origTavDestroy.apply(this, arguments);
			};
		}

		if (typeof Screens !== 'undefined' && Screens['WorldTownScreen'] && Screens['WorldTownScreen'].mTavernDialogModule) {
			var liveTav = Screens['WorldTownScreen'].mTavernDialogModule;
			liveTav.createDIV = tavProto.createDIV;
			liveTav.loadFromData = tavProto.loadFromData;
			liveTav.hide = tavProto.hide;
			liveTav.destroyDIV = tavProto.destroyDIV;
		}
	}

	if (typeof WorldTownScreen !== 'undefined') {
		var townScreenProto = WorldTownScreen.prototype;
		var origTownDisconnect = townScreenProto.onDisconnection;
		townScreenProto.onDisconnection = function () {
			// Quitting a match can leave the town fade queued while its dialog is destroyed.
			if (this.mContainer) this.mContainer.velocity('stop', true);
			return origTownDisconnect.apply(this, arguments);
		};
		if (typeof Screens !== 'undefined' && Screens['WorldTownScreen']) {
			Screens['WorldTownScreen'].onDisconnection = townScreenProto.onDisconnection;
		}
	}

	if (typeof WorldTownScreenMainDialogModule !== 'undefined') {
		var townProto = WorldTownScreenMainDialogModule.prototype;
		var origTownLoad = townProto.loadFromData;
		var origTownHide = townProto.hide;
		var origTownDestroy = townProto.destroyDIV;

		townProto.wxTournamentOpen = function (_info) {
			window.WX_OpenTournamentModal(this, this.mSQHandle, _info, false);
		};
		townProto.wxTournamentEntrance = function () {
			window.WX_OpenTournamentModal(this, this.mSQHandle, 0, true);
		};
		townProto.wxTournamentClose = function () {
			if (wxTourney.owner === this) wxCloseTournamentModal();
		};

		if (origTownLoad) {
			townProto.loadFromData = function (_data) {
				var self = this;
				origTownLoad.call(this, _data);
				if (!this.mDialogContainer) return;
				this.mDialogContainer.find('.wx-town-tourney-btn').remove();
				if (_data && _data.WX_IsTournamentHost && !_data.WX_HasArenaBuilding) {
					var btn = $(
						'<div class="wx-town-tourney-btn" title="本州府正设演武高台举办《天下武林大会》与《群英演武擂》：可点将登台争魁，或在外围银庄押注观战！">' +
							'<img src="coui://gfx/ui/wx_icons/wx_icon_ambition.png" alt="" />演武校场 · 武林大会' +
						'</div>'
					);
					btn.on('click', function () {
						if (self.mSQHandle) window.WX_OpenTournamentModal(self, self.mSQHandle, 0, false);
					});
					this.mDialogContainer.append(btn);
				}
			};
		}

		if (origTownHide) {
			townProto.hide = function () {
				if (wxTourney.owner === this) wxCloseTournamentModal();
				if (wxCasino.owner === this) wxCloseCasinoModal();
				return origTownHide.apply(this, arguments);
			};
		}

		if (origTownDestroy) {
			townProto.destroyDIV = function () {
				if (wxTourney.owner === this) wxCloseTournamentModal();
				if (wxCasino.owner === this) wxCloseCasinoModal();
				return origTownDestroy.apply(this, arguments);
			};
		}

		if (typeof Screens !== 'undefined' && Screens['WorldTownScreen'] && Screens['WorldTownScreen'].mMainDialogModule) {
			var liveTownMain = Screens['WorldTownScreen'].mMainDialogModule;
			liveTownMain.wxTournamentOpen = townProto.wxTournamentOpen;
			liveTownMain.wxTournamentEntrance = townProto.wxTournamentEntrance;
			liveTownMain.wxTournamentClose = townProto.wxTournamentClose;
			liveTownMain.loadFromData = townProto.loadFromData;
			liveTownMain.hide = townProto.hide;
			liveTownMain.destroyDIV = townProto.destroyDIV;
		}
	}

	if (typeof TacticalScreen !== 'undefined') {
		var tacProto = TacticalScreen.prototype;
		var origTacDisc = tacProto.onDisconnection;

		tacProto.wxTournamentWatchUpdate = function (_data) {
			if (!_data) return;
			var screen = this;
			var bar = $('.wx-watch-bar');
			var cover = $('.wx-watch-cover');
			if (!bar.length) {
				cover = $('<div class="wx-watch-cover"><div class="wx-watch-story"></div></div>').appendTo('body');
				bar = $(
					'<div class="wx-watch-bar">' +
						'<div class="wx-watch-score"></div>' +
						'<div>' +
							'<span class="wx-gmb-btn is-sm" data-wx-watch="watch">慢品拆招 (1x)</span>' +
							'<span class="wx-gmb-btn is-sm" data-wx-watch="fast">疾风快进 (4x)</span>' +
							'<span class="wx-gmb-btn is-sm" data-wx-watch="report">幕后听锣 (12x)</span>' +
						'</div>' +
						'<div class="wx-watch-msg" style="font-size:1.2rem;color:#ff8070;margin-top:0.2rem;"></div>' +
					'</div>'
				).appendTo('body');

				bar.on('click', '[data-wx-watch]', function (_e) {
					_e.stopPropagation();
					if ($(this).hasClass('is-active')) return;
					var mode = $(this).attr('data-wx-watch');
					if (screen.mSQHandle) {
						SQ.call(screen.mSQHandle, 'onWXTournamentWatch', mode, function (_r) {
							if (_r && !_r.ok) bar.find('.wx-watch-msg').text(_r.message || '');
						});
					}
				});
			}

			bar.find('[data-wx-watch]').removeClass('is-active');
			bar.find('[data-wx-watch="' + _data.mode + '"]').addClass('is-active');
			bar.find('.wx-watch-score').text(
				'【' + _data.left + '】 ' + _data.leftCount + '  对  ' + _data.rightCount + ' 【' + _data.right + '】 · 第 ' + _data.round + ' 合'
			);

			if (_data.mode === 'report') {
				cover.show();
				cover.find('.wx-watch-story').html(
					'<b>《' + wxEsc(_data.title) + '》演武进行中</b>' +
					'你于看台茶棚之下品茗静候佳音。<br/>台内刀光剑影、真气激荡，监擂长老正在主持比武高下。<br/>待终场金锣敲响，执事即刻呈上朱批赛报！'
				);
			} else {
				cover.hide();
			}
		};

		tacProto.wxTournamentWatchClose = function () {
			$('.wx-watch-bar, .wx-watch-cover').remove();
		};

		if (origTacDisc) {
			tacProto.onDisconnection = function () {
				this.wxTournamentWatchClose();
				return origTacDisc.apply(this, arguments);
			};
		}

		if (typeof Screens !== 'undefined' && Screens['TacticalScreen']) {
			Screens['TacticalScreen'].wxTournamentWatchUpdate = tacProto.wxTournamentWatchUpdate;
			Screens['TacticalScreen'].wxTournamentWatchClose = tacProto.wxTournamentWatchClose;
		}
	}
})();
