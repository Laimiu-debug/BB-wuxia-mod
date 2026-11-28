/* ============================================================================
 * BB Wuxia Mod — Non-Blocking 60fps Tactical Combat Theater Overlay
 * Provides radial spotlight vignette, sleek Wuxia calligraphy cut-in ribbon,
 * and impact-synced HTML5 Canvas speed-lines / lightning / Issen screen accents.
 * Strictly ES3-compliant (var / function only) for CoherentUI WebKit!
 * ============================================================================ */
(function () {
	'use strict';

	var THEMES = {
		cyan:      { stroke: 'rgba(110, 236, 255, ', flash: 'rgba(180, 248, 255, ', accent: 'rgba(20, 140, 185, ' },
		gold:      { stroke: 'rgba(255, 210, 88, ',  flash: 'rgba(255, 238, 165, ', accent: 'rgba(235, 140, 24, ' },
		fire:      { stroke: 'rgba(255, 118, 42, ',  flash: 'rgba(255, 185, 96, ',  accent: 'rgba(218, 42, 16, '  },
		violet:    { stroke: 'rgba(182, 128, 255, ', flash: 'rgba(232, 212, 255, ', accent: 'rgba(116, 52, 235, ' },
		celestial: { stroke: 'rgba(255, 234, 142, ', flash: 'rgba(240, 250, 255, ', accent: 'rgba(108, 216, 255, '},
		crimson:   { stroke: 'rgba(255, 68, 86, ',   flash: 'rgba(255, 198, 206, ', accent: 'rgba(196, 18, 38, '  },
		jade:      { stroke: 'rgba(56, 236, 164, ',  flash: 'rgba(208, 255, 236, ', accent: 'rgba(18, 166, 112, ' },
		frost:     { stroke: 'rgba(108, 224, 255, ', flash: 'rgba(226, 250, 255, ', accent: 'rgba(34, 144, 216, ' },
		venom:     { stroke: 'rgba(92, 236, 72, ',   flash: 'rgba(214, 255, 188, ', accent: 'rgba(104, 42, 188, ' },
		ink:       { stroke: 'rgba(168, 182, 236, ', flash: 'rgba(232, 238, 255, ', accent: 'rgba(68, 76, 118, '  }
	};

	var ALL_THEME_CLASSES = 'is-on is-theme-cyan is-theme-gold is-theme-fire is-theme-violet is-theme-celestial is-theme-crimson is-theme-jade is-theme-frost is-theme-venom is-theme-ink';

	var state = {
		root: null,
		vignette: null,
		canvas: null,
		ctx: null,
		viewWidth: 0,
		viewHeight: 0,
		banner: null,
		drawTimer: null,
		timers: [],
		cue: null,
		particles: []
	};

	function wxEsc(_s) {
		return String(_s == null ? '' : _s)
			.replace(/&/g, '&amp;')
			.replace(/</g, '&lt;')
			.replace(/>/g, '&gt;')
			.split('"').join('&quot;');
	}

	function resolvePortraitUrl(_p) {
		if (!_p || typeof _p !== 'string') return '';
		if (_p.indexOf('coui://') === 0 || _p.indexOf('procedural://') === 0) return _p;
		if (typeof Path !== 'undefined' && Path.PROCEDURAL) return Path.PROCEDURAL + _p;
		return 'coui://' + _p;
	}

	function clearTimers() {
		for (var i = 0; i < state.timers.length; i++) {
			clearTimeout(state.timers[i]);
		}
		state.timers = [];
	}

	function stopLoop() {
		if (state.drawTimer !== null) {
			clearTimeout(state.drawTimer);
			state.drawTimer = null;
		}
	}

	function ensureStageDom() {
		if (state.root && state.root.length && document.body.contains(state.root[0])) {
			return state.root;
		}
		var root = $(
			'<div class="wx-cvfx-root">' +
				'<div class="wx-cvfx-vignette"></div>' +
				'<canvas class="wx-cvfx-canvas"></canvas>' +
			'</div>'
		);
		$(document.body).append(root);
		state.root = root;
		state.vignette = root.find('.wx-cvfx-vignette');
		state.canvas = root.find('.wx-cvfx-canvas')[0];
		state.ctx = state.canvas ? state.canvas.getContext('2d') : null;
		return root;
	}

	function destroyStageDom() {
		clearTimers();
		stopLoop();
		state.cue = null;
		state.particles = [];
		if (state.root) {
			state.root.remove();
		}
		state.root = null;
		state.vignette = null;
		state.canvas = null;
		state.ctx = null;
		state.viewWidth = 0;
		state.viewHeight = 0;
		state.banner = null;
	}

	function resizeCanvas() {
		if (!state.ctx) return;
		var w = window.innerWidth || 1280;
		var h = window.innerHeight || 720;
		if (state.viewWidth === w && state.viewHeight === h) return;
		// Only the transparent effects layer is scaled. Keep the HUD and calligraphy at native resolution.
		var scale = Math.min(1, 854 / w, 480 / h);
		state.canvas.width = Math.max(1, Math.round(w * scale));
		state.canvas.height = Math.max(1, Math.round(h * scale));
		state.ctx.scale(state.canvas.width / w, state.canvas.height / h);
		state.viewWidth = w;
		state.viewHeight = h;
	}

	function seedEdgeParticles(_themeKey, _w, _h) {
		var list = [];
		var count = (_themeKey === 'fire' || _themeKey === 'gold') ? 26 : 20;
		for (var i = 0; i < count; i++) {
			var ang = (i / count) * Math.PI * 2.0 + ((i % 3) * 0.19);
			list.push({
				ang: ang,
				len: 0.14 + (i % 5) * 0.045,
				w: 1.2 + (i % 4) * 0.9,
				spd: 0.7 + (i % 5) * 0.25,
				x: ((i * 73) % 100) / 100.0 * _w,
				y: _h * (0.55 + ((i * 37) % 45) / 100.0),
				vy: -90 - (i % 5) * 55,
				vx: ((i % 7) - 3) * 28,
				sz: 2.2 + (i % 4) * 1.4
			});
		}
		return list;
	}

	function renderFrame() {
		state.drawTimer = null;
		var cue = state.cue;
		if (!cue || !state.ctx || !state.canvas) return;

		var now = (new Date()).getTime();
		var elapsed = now - cue.startTime;
		if (elapsed >= cue.totalMs) {
			state.ctx.clearRect(0, 0, state.viewWidth, state.viewHeight);
			if (state.vignette) state.vignette.removeClass('is-on');
			state.cue = null;
			return;
		}

		resizeCanvas();
		var ctx = state.ctx;
		var w = state.viewWidth;
		var h = state.viewHeight;
		var cx = w * 0.5;
		var cy = h * 0.5;
		var maxR = Math.sqrt(cx * cx + cy * cy);
		var th = THEMES[cue.theme] || THEMES.cyan;
		var imp = cue.impactMs;

		ctx.clearRect(0, 0, w, h);

		// A. Windup subtle converging outer-border speedlines (0 .. impactMs)
		if (elapsed < imp) {
			var wp = elapsed / Math.max(1, imp);
			var wAlpha = Math.sin(wp * Math.PI) * 0.24;
			ctx.save();
			ctx.lineCap = 'round';
			for (var i = 0; i < state.particles.length; i++) {
				var p = state.particles[i];
				var rOuter = maxR * (1.02 - wp * 0.14 * p.spd);
				var rInner = rOuter - maxR * p.len * (0.5 + 0.5 * wp);
				ctx.strokeStyle = th.stroke + (wAlpha * (0.65 + (i % 3) * 0.16)).toFixed(3) + ')';
				ctx.lineWidth = p.w;
				ctx.beginPath();
				ctx.moveTo(cx + Math.cos(p.ang) * rOuter, cy + Math.sin(p.ang) * rOuter);
				ctx.lineTo(cx + Math.cos(p.ang) * rInner, cy + Math.sin(p.ang) * rInner);
				ctx.stroke();
			}
			ctx.restore();
		}

		// B. Multi-hit crisp corner slash glint (for rapid combo skills)
		if (cue.hits && cue.hits.length > 0) {
			for (var hi = 0; hi < cue.hits.length; hi++) {
				var dtH = elapsed - cue.hits[hi];
				if (dtH >= 0 && dtH < 130) {
					var hp = 1.0 - (dtH / 130.0);
					ctx.save();
					ctx.strokeStyle = th.flash + (hp * 0.42).toFixed(3) + ')';
					ctx.lineWidth = 3.0 * hp;
					var dirSign = (hi % 2 === 0) ? 1 : -1;
					var xStart = (cue.dirX < 0) ? w * (0.88 - hi * 0.04) : w * (0.12 + hi * 0.04);
					var xEnd   = (cue.dirX < 0) ? w * (0.12 + hi * 0.04) : w * (0.88 - hi * 0.04);
					ctx.beginPath();
					ctx.moveTo(xStart, h * (dirSign > 0 ? 0.14 : 0.86));
					ctx.lineTo(xEnd, h * (dirSign > 0 ? 0.86 : 0.14));
					ctx.stroke();
					ctx.restore();
				}
			}
		}

		// C. Exact-Impact Climax Atmospheric Pulse (impactMs .. impactMs + 340ms)
		var dtImp = elapsed - imp;
		if (dtImp >= 0 && dtImp < 360) {
			var ip = dtImp / 360.0;
			var inv = 1.0 - ip;

			// 1. Screen-edge elemental impact illumination (brighter for Thunder / Celestial / Heavy)
			if (dtImp < 165) {
				var fAlpha = (1.0 - dtImp / 165.0) * (cue.theme === 'violet' ? 0.34 : (cue.theme === 'celestial' ? 0.30 : 0.22));
				// CoherentUI supports solid canvas strokes on the game's renderer.
				// Build the edge glow outwards so the targeted hex stays visible.
				var bands = 10;
				var bandWidth = maxR * 0.78 / bands;
				ctx.save();
				if (cue.theme === 'violet') {
					ctx.fillStyle = th.flash + (fAlpha * 0.20).toFixed(3) + ')';
					ctx.fillRect(0, 0, w, h);
				}
				ctx.lineWidth = bandWidth + 0.5;
				for (var band = 0; band < bands; band++) {
					var strength = (band + 0.5) / bands;
					ctx.strokeStyle = th.accent + (fAlpha * strength).toFixed(3) + ')';
					ctx.beginPath();
					ctx.arc(cx, cy, maxR * 0.22 + bandWidth * (band + 0.5), 0, Math.PI * 2);
					ctx.stroke();
				}
				ctx.restore();
			}

			// 2. Outward radial kinetic impact speed-lines on screen periphery
			var sAlpha = inv * inv * 0.48;
			ctx.save();
			ctx.lineCap = 'round';
			for (var j = 0; j < state.particles.length; j++) {
				var q = state.particles[j];
				var r0 = maxR * (0.64 + ip * 0.28 * q.spd);
				var r1 = r0 + maxR * q.len * 1.25 * inv;
				ctx.strokeStyle = (j % 3 === 0 ? th.flash : th.stroke) + sAlpha.toFixed(3) + ')';
				ctx.lineWidth = q.w * (0.8 + inv);
				ctx.beginPath();
				ctx.moveTo(cx + Math.cos(q.ang) * r0, cy + Math.sin(q.ang) * r0);
				ctx.lineTo(cx + Math.cos(q.ang) * r1, cy + Math.sin(q.ang) * r1);
				ctx.stroke();
			}
			ctx.restore();

			// 3. Signature Celestial Issen (一闪) blinding razor horizon flash!
			if (cue.theme === 'celestial' && dtImp < 210) {
				var cp = 1.0 - (dtImp / 210.0);
				var angB = Math.atan2(-(cue.dirY || 0), cue.dirX || 1);
				ctx.save();
				ctx.translate(cx, cy);
				ctx.rotate(angB);
				ctx.strokeStyle = 'rgba(255, 250, 224, ' + (cp * 0.72).toFixed(3) + ')';
				ctx.lineWidth = Math.max(1.5, 10.0 * cp * cp);
				ctx.beginPath();
				ctx.moveTo(-maxR * 0.9, 0);
				ctx.lineTo(maxR * 0.9, 0);
				ctx.stroke();
				ctx.restore();
			}
		}

		// D. Rising atmospheric embers / frost snow / crimson sparks / petals after impact
		if ((cue.theme === 'fire' || cue.theme === 'gold' || cue.theme === 'crimson' || cue.theme === 'frost' || cue.theme === 'venom' || cue.theme === 'jade') && dtImp >= 0) {
			var sec = dtImp / 1000.0;
			var eAlpha = Math.max(0.0, 1.0 - (dtImp / Math.max(1, cue.totalMs - imp)));
			ctx.save();
			for (var k = 0; k < state.particles.length; k++) {
				var ep = state.particles[k];
				var ex = ep.x + ep.vx * sec;
				var ey = ep.y + (cue.theme === 'frost' ? -ep.vy * 0.45 : ep.vy) * sec;
				ctx.fillStyle = (k % 2 === 0 ? th.flash : th.stroke) + (eAlpha * 0.68).toFixed(3) + ')';
				ctx.beginPath();
				ctx.arc(ex, ey, ep.sz * (0.5 + 0.5 * eAlpha), 0, Math.PI * 2.0);
				ctx.fill();
			}
			ctx.restore();
		}

		state.drawTimer = setTimeout(renderFrame, 33);
	}

	function playCombatCue(_data) {
		if (!_data || typeof _data !== 'object') return;
		ensureStageDom();
		resizeCanvas();
		clearTimers();
		stopLoop();

		var theme = _data.theme || 'cyan';
		var totalMs = Math.max(550, Math.min(1400, parseInt(_data.totalMs || 920, 10)));
		var impactMs = Math.max(120, Math.min(totalMs - 140, parseInt(_data.impactMs || 380, 10)));

		// 1. Spotlight Vignette
		if (state.vignette) {
			state.vignette
				.removeClass(ALL_THEME_CLASSES)
				.addClass('is-theme-' + theme);
			if (state.vignette[0]) { var _rf = state.vignette[0].offsetWidth; }
			state.vignette.addClass('is-on');
			state.timers.push(setTimeout(function () {
				if (state.vignette) state.vignette.removeClass('is-on');
			}, Math.max(260, totalMs - 180)));
		}

		// 2. Sleek Upper-Left Calligraphy Cut-In Ribbon
		if (state.banner) {
			state.banner.remove();
			state.banner = null;
		}
		if (_data.title) {
			var pUrl = resolvePortraitUrl(_data.portraitPath || '');
			var portHtml = pUrl
				? ('<div class="wx-cvfx-portrait-box"><img src="' + wxEsc(pUrl) + '" alt=""/></div>')
				: '';
			var sealHtml = _data.seal
				? ('<span class="wx-cvfx-seal">' + wxEsc(_data.seal) + '</span>')
				: '';
			var subTxt = (_data.casterName ? (_data.casterName + ' · ') : '') + (_data.subtitle || '');
			var b = $(
				'<div class="wx-cvfx-banner is-theme-' + wxEsc(theme) + '">' +
					'<div class="wx-cvfx-banner-inner">' +
						portHtml +
						'<div class="wx-cvfx-text-col">' +
							'<div class="wx-cvfx-title">' + wxEsc(_data.title) + '</div>' +
							'<div class="wx-cvfx-sub">' + wxEsc(subTxt) + '</div>' +
						'</div>' +
						sealHtml +
					'</div>' +
				'</div>'
			);
			state.root.append(b);
			state.banner = b;
			b.addClass('is-in');

			state.timers.push(setTimeout(function () {
				if (state.banner === b) {
					b.removeClass('is-in').addClass('is-out');
				}
			}, Math.max(380, totalMs - 240)));

			state.timers.push(setTimeout(function () {
				b.remove();
				if (state.banner === b) state.banner = null;
			}, totalMs + 80));
		}

		state.particles = seedEdgeParticles(theme, state.viewWidth, state.viewHeight);
		state.cue = {
			theme: theme,
			startTime: (new Date()).getTime(),
			impactMs: impactMs,
			totalMs: totalMs,
			dirX: typeof _data.dirX === 'number' ? _data.dirX : 1.0,
			dirY: typeof _data.dirY === 'number' ? _data.dirY : 0.0,
			hits: (_data.hits && _data.hits.length) ? _data.hits : []
		};
		renderFrame();
	}

	window.WX_CombatStage = {
		play: playCombatCue,
		close: destroyStageDom
	};

	if (typeof TacticalScreen !== 'undefined') {
		var tacProto = TacticalScreen.prototype;
		var origTacDisc = tacProto.onDisconnection;

		tacProto.wxPlayCombatCue = function (_data) {
			playCombatCue(_data);
		};

		tacProto.wxCloseCombatCue = function () {
			destroyStageDom();
		};

		if (origTacDisc) {
			tacProto.onDisconnection = function () {
				destroyStageDom();
				return origTacDisc.apply(this, arguments);
			};
		}

		if (typeof Screens !== 'undefined' && Screens['TacticalScreen']) {
			Screens['TacticalScreen'].wxPlayCombatCue = tacProto.wxPlayCombatCue;
			Screens['TacticalScreen'].wxCloseCombatCue = tacProto.wxCloseCombatCue;
		}
	}
})();
