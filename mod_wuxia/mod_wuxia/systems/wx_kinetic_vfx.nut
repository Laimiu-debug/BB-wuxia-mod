// Next-Gen Wuxia Kinetic Combat Animation & 4-Beat Delayed-Impact Choreography Engine (Full 171-Skill Edition)
// Drives wx_kinetic_0 through wx_kinetic_6 (402 animation frames and 28 particles)
// + 16 Space-Making 60 FPS Actor Motions + 5 Hitstop Target Reactions + 22 Kinetic Archetypes
// + Non-Blocking 10-Theme CoherentUI Wuxia Combat Theater!
//
// `::Wuxia.KineticVFX.Profiles` (171 entries) is populated by `wx_kinetic_catalog.nut` right before this file.

if (!("KineticVFX" in ::Wuxia)) ::Wuxia.KineticVFX <- {};

// Bespoke Shan Hai Boss KineticVFX Profiles (kept in `BossProfiles` so `Profiles` stays pure 171/171 player moves!)
::Wuxia.KineticVFX.BossProfiles <- {
	wx_boss_zhuyin_winter_breath   = { title = "吹为冬·玄冥霜息", subtitle = "钟山烛阴·万里冰封", seal = "烛阴", arch = "frost_burst",    seq = "wx_kin_frost_burst",    seq2 = "wx_kin_snow_step",     motionKind = "kin_roar_pulse",    react = "kin_hit_frost",  theme = "frost",   tint = [195, 244, 255], kind = "melee",  isFootwork = false, isAoe = true,  ground = "frost",  impactMs = 360, releaseMs = 500, totalMs = 920, hits = [360], shakePow = 7 },
	wx_boss_zhuyin_summer_gale     = { title = "呼为夏·钟山炎风", subtitle = "赤昼开目·焚山煮雪", seal = "赤昼", arch = "dragon_surge",   seq = "wx_kin_dragon_surge",   seq2 = "wx_kin_flame_pillar",  motionKind = "kin_dragon_palm",   react = "kin_hit_launch", theme = "fire",    tint = [255, 175, 95],  kind = "melee",  isFootwork = false, isAoe = true,  ground = "scorch", impactMs = 390, releaseMs = 530, totalMs = 950, hits = [390], shakePow = 8 },
	wx_boss_zhuyin_coil_crush      = { title = "千里盘山绞",       subtitle = "赤鳞真躯·盘岳碎甲", seal = "盘龙", arch = "bamboo_bind",    seq = "wx_kin_bamboo_bind",    seq2 = "wx_kin_earth_shatter", motionKind = "kin_whirl_spin",    react = "kin_hit_heavy",  theme = "crimson", tint = [255, 130, 120], kind = "melee",  isFootwork = false, isAoe = false, ground = "scorch", impactMs = 365, releaseMs = 505, totalMs = 890, hits = [365], shakePow = 7 },
	wx_boss_zhuyin_primordial_wind = { title = "息为风·太古移岳", subtitle = "不饮不息·一吐移山", seal = "朔风", arch = "whirl_cyclone",  seq = "wx_kin_whirl_cyclone",  seq2 = "wx_kin_qinggong_gust", motionKind = "kin_roar_pulse",    react = "kin_hit_launch", theme = "cyan",    tint = [180, 245, 255], kind = "stance", isFootwork = false, isAoe = true,  ground = "",       impactMs = 330, releaseMs = 470, totalMs = 880, hits = [330], shakePow = 8 },
	wx_boss_xiangliu_nine_devour   = { title = "九首食于九山",     subtitle = "共工凶臣·群首争噬", seal = "相柳", arch = "venom_mire",     seq = "wx_kin_venom_mire",     seq2 = "wx_kin_claw_rend",     motionKind = "kin_dash_combo3",   react = "kin_hit_venom",  theme = "venom",   tint = [165, 255, 135], kind = "melee",  isFootwork = false, isAoe = true,  ground = "venom",  impactMs = 370, releaseMs = 515, totalMs = 920, hits = [220, 370], shakePow = 7 },
	wx_boss_xiangliu_mire_ram      = { title = "所抵成泽·噬山撞", subtitle = "铁首摧垣·地陷苦泽", seal = "噬山", arch = "earth_shatter",  seq = "wx_kin_earth_shatter",  seq2 = "wx_kin_venom_mire",    motionKind = "kin_heavy_chop",    react = "kin_hit_launch", theme = "venom",   tint = [175, 250, 140], kind = "melee",  isFootwork = false, isAoe = false, ground = "venom",  impactMs = 395, releaseMs = 540, totalMs = 940, hits = [395], shakePow = 8 },
	wx_boss_xiangliu_poison_deluge = { title = "禹厥三沮·苦泉涌", subtitle = "腥血化溪·万泽齐喷", seal = "苦泽", arch = "tidal_wave",     seq = "wx_kin_tidal_wave",     seq2 = "wx_kin_venom_mire",    motionKind = "kin_roar_pulse",    react = "kin_hit_venom",  theme = "venom",   tint = [150, 255, 128], kind = "stance", isFootwork = false, isAoe = true,  ground = "venom",  impactMs = 350, releaseMs = 490, totalMs = 900, hits = [350], shakePow = 8 },
	wx_boss_xiangliu_miasma_hex    = { title = "腥风夺魄·九首啸", subtitle = "苦瘴迷心·百谷不生", seal = "惑心", arch = "smoke_cloud",    seq = "wx_kin_smoke_cloud",    seq2 = "wx_kin_soul_vortex",   motionKind = "kin_roar_pulse",    react = "kin_hit_venom",  theme = "violet",  tint = [215, 165, 255], kind = "stance", isFootwork = false, isAoe = true,  ground = "",       impactMs = 320, releaseMs = 460, totalMs = 860, hits = [320], shakePow = 6 },
	wx_boss_nvchou_ten_suns_ray    = { title = "十日焦山·阳炎线", subtitle = "十日居上·交叉焚骨", seal = "十日", arch = "celestial_beam", seq = "wx_kin_celestial_beam", seq2 = "wx_kin_flame_pillar",  motionKind = "kin_celestial_beam",react = "kin_hit_launch", theme = "fire",    tint = [255, 210, 120], kind = "ranged", isFootwork = false, isAoe = true,  ground = "scorch", impactMs = 390, releaseMs = 535, totalMs = 940, hits = [390], shakePow = 8 },
	wx_boss_nvchou_sleeve_shift    = { title = "青袂障面·移日影", subtitle = "右手鄣面·化虹易位", seal = "青袂", arch = "warp_seal",      seq = "wx_kin_warp_seal",      seq2 = "wx_kin_smoke_cloud",   motionKind = "kin_qg_vault",      react = "kin_hit_heavy",  theme = "fire",    tint = [255, 195, 130], kind = "util",   isFootwork = false, isAoe = false, ground = "",       impactMs = 220, releaseMs = 390, totalMs = 780, hits = [220], shakePow = 4 },
	wx_boss_nvchou_scorch_apocalypse = { title = "十日同炙·千里旱", subtitle = "赤魃暴衣·万山俱焚", seal = "旱魃", arch = "cannon_blast", seq = "wx_kin_cannon_blast",   seq2 = "wx_kin_flame_pillar",  motionKind = "kin_roar_pulse",    react = "kin_hit_launch", theme = "gold",    tint = [255, 224, 145], kind = "stance", isFootwork = false, isAoe = true,  ground = "scorch", impactMs = 360, releaseMs = 510, totalMs = 960, hits = [360], shakePow = 9 }
};

::Wuxia.KineticVFX.getProfile <- function( _key )
{
	if (_key == null) return null;
	if ("Profiles" in ::Wuxia.KineticVFX && (_key in ::Wuxia.KineticVFX.Profiles))
		return ::Wuxia.KineticVFX.Profiles[_key];
	if ("BossProfiles" in ::Wuxia.KineticVFX && (_key in ::Wuxia.KineticVFX.BossProfiles))
		return ::Wuxia.KineticVFX.BossProfiles[_key];
	return null;
};

::Wuxia.KineticVFX.PendingCasts <- {};
::Wuxia.KineticVFX.SeqFrameCount <- {
	wx_kin_sword_slash    = 10,
	wx_kin_dragon_surge   = 12,
	wx_kin_flame_cleave   = 10,
	wx_kin_flame_pillar   = 10,
	wx_kin_thunder_bolt   = 10,
	wx_kin_celestial_beam = 10,
	wx_kin_blood_arc      = 10,
	wx_kin_spear_drill    = 10,
	wx_kin_whirl_cyclone  = 10,
	wx_kin_claw_rend      = 10,
	wx_kin_whip_lash      = 10,
	wx_kin_shadow_cross   = 10,
	wx_kin_buddha_palm    = 10,
	wx_kin_frost_burst    = 10,
	wx_kin_venom_mire     = 10,
	wx_kin_earth_shatter  = 10,
	wx_kin_arrow_barrage  = 10,
	wx_kin_sonic_wave     = 10,
	wx_kin_taiji_seal     = 10,
	wx_kin_golden_dome    = 10,
	wx_kin_qinggong_gust  = 10,
	wx_kin_soul_vortex    = 10,
	wx_kin_lotus_poke     = 10,
	wx_kin_fist_flurry    = 10,
	wx_kin_giant_axe      = 10,
	wx_kin_phoenix_spear  = 10,
	wx_kin_bamboo_bind    = 10,
	wx_kin_flying_knives  = 10,
	wx_kin_peacock_fan    = 10,
	wx_kin_cannon_blast   = 10,
	wx_kin_war_banner     = 10,
	wx_kin_xuanwu_aegis   = 10,
	wx_kin_tidal_wave     = 10,
	wx_kin_gold_needles   = 10,
	wx_kin_snow_step      = 10,
	wx_kin_warp_seal      = 10,
	wx_kin_smoke_cloud    = 10,
	wx_kin_prism_burst    = 10,
	wx_kin_sword_rain     = 10,
	wx_kin_moon_crescent  = 10
};

::Wuxia.KineticVFX.ThemeFx <- {
	cyan      = { ring = "wx_pt_ring_cyan",    sparks = ["wx_pt_spark_cyan", "wx_pt_ink_drop", "wx_pt_wind_wisp"],  tint = [110, 235, 255] },
	gold      = { ring = "wx_pt_ring_gold",    sparks = ["wx_pt_spark_gold", "wx_pt_ember", "wx_pt_glint_star"],    tint = [255, 214, 110] },
	fire      = { ring = "wx_pt_ring_fire",    sparks = ["wx_pt_spark_fire", "wx_pt_ember", "wx_pt_smoke"],         tint = [255, 138, 72]  },
	violet    = { ring = "wx_pt_ring_violet",  sparks = ["wx_pt_spark_violet", "wx_pt_glint_star", "wx_pt_ink_drop"], tint = [194, 148, 255] },
	celestial = { ring = "wx_pt_ring_gold",    sparks = ["wx_pt_spark_gold", "wx_pt_spark_cyan", "wx_pt_glint_star"], tint = [232, 246, 255] },
	crimson   = { ring = "wx_pt_ring_crimson", sparks = ["wx_pt_spark_crimson", "wx_pt_ink_drop", "wx_pt_ember"],   tint = [255, 110, 128] },
	jade      = { ring = "wx_pt_ring_jade",    sparks = ["wx_pt_spark_jade", "wx_pt_wind_wisp", "wx_pt_petal"],     tint = [132, 255, 206] },
	frost     = { ring = "wx_pt_ring_frost",   sparks = ["wx_pt_spark_frost", "wx_pt_ice_shard", "wx_pt_glint_star"], tint = [176, 238, 255] },
	venom     = { ring = "wx_pt_ring_venom",   sparks = ["wx_pt_spark_venom", "wx_pt_smoke", "wx_pt_ink_drop"],     tint = [152, 255, 140] },
	ink       = { ring = "wx_pt_ring_violet",  sparks = ["wx_pt_ink_drop", "wx_pt_wind_wisp", "wx_pt_spark_violet"], tint = [184, 194, 242] }
};

// ============================================================================
// Pure-Squirrel Geometry, Direction & Audio Utilities
// ============================================================================

::Wuxia.KineticVFX.atanApproxDeg <- function( _z )
{
	local az = _z < 0.0 ? -_z : _z;
	return _z * (45.0 - (az - 1.0) * (14.0 + 3.83 * az));
};

::Wuxia.KineticVFX.atan2Deg <- function( _dy, _dx )
{
	local x = _dx.tofloat();
	local y = _dy.tofloat();
	local ax = x < 0.0 ? -x : x;
	local ay = y < 0.0 ? -y : y;
	if (ax < 0.0001 && ay < 0.0001) return 0.0;

	if (ax >= ay)
	{
		local a = ::Wuxia.KineticVFX.atanApproxDeg(y / x);
		if (x < 0.0)
			return y >= 0.0 ? (180.0 + a) : (-180.0 + a);
		return a;
	}
	else
	{
		local a = ::Wuxia.KineticVFX.atanApproxDeg(x / y);
		return y >= 0.0 ? (90.0 - a) : (-90.0 - a);
	}
};

::Wuxia.KineticVFX.getBehindTile <- function( _originTile, _targetTile )
{
	if (_originTile == null || _targetTile == null || _originTile.ID == _targetTile.ID)
		return null;
	try
	{
		if (::Wuxia.hasMember(_originTile, "getDirectionTo") && ::Wuxia.hasMember(_targetTile, "hasNextTile"))
		{
			local d = _originTile.getDirectionTo(_targetTile);
			if (d >= 0 && _targetTile.hasNextTile(d))
				return _targetTile.getNextTile(d);
		}
	}
	catch (_e) {}
	return null;
};

::Wuxia.KineticVFX.pad2 <- function( _n )
{
	return _n < 10 ? ("0" + _n) : ("" + _n);
};

::Wuxia.KineticVFX.getThemeFx <- function( _theme )
{
	if (_theme != null && (_theme in ::Wuxia.KineticVFX.ThemeFx))
		return ::Wuxia.KineticVFX.ThemeFx[_theme];
	return ::Wuxia.KineticVFX.ThemeFx.cyan;
};

::Wuxia.KineticVFX.playSoundAt <- function( _delayMs, _paths, _vol = 0.85, _pitch = 1.0 )
{
	if (_paths == null || _paths.len() == 0) return;
	local pick = _paths[::Math.rand(0, _paths.len() - 1)];
	if (_delayMs <= 0)
	{
		try { ::Sound.play(pick, _vol); } catch (_e) {}
		return;
	}
	::Time.scheduleEvent(::TimeUnit.Virtual, _delayMs.tointeger(), function( _tag ) {
		if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
		try { ::Sound.play(_tag.p, _tag.v); } catch (_e2) {}
	}, { p = pick, v = _vol });
};

// ============================================================================
// Core OpenGL Kinetic Primitives
//   1. Non-overlapping Sequential Multi-Frame Flipbook (`playFlipbook`)
//   2. True Multi-Particle GPU Burst (`spawnBurst`)
//   3. Expanding / Contracting Isometric Shockwave Ring (`spawnShockwaveRing`)
//   4. Lingering Ground Aftermath Decals (`spawnGroundDecal`: scorch / frost / venom)
// ============================================================================

::Wuxia.KineticVFX.playFlipbook <- function(
	_tile, _prefix, _count, _startMs = 0, _frameMs = 38,
	_scaleStart = 1.15, _scaleEnd = 1.24, _rotDeg = 0.0, _flipX = false,
	_ox = 0.0, _oy = 0.0, _vx = 0.0, _vy = 0.0, _peakAlpha = 242,
	_tintR = 255, _tintG = 255, _tintB = 255
)
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (_tile == null || !_tile.IsVisibleForPlayer) return;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (!("spawnParticleEffect" in ::Tactical)) return;

	local vxF = _vx.tofloat();
	local vyF = _vy.tofloat();
	local speed = ::Wuxia.VFX.sqrt(vxF * vxF + vyF * vyF);
	local dirVec = (speed > 0.01) ? ::createVec(vxF / speed, vyF / speed) : ::Wuxia.VFX.getVecZero();
	local fZero = ::Wuxia.VFX.getVecZero();
	local frameSec = ::Math.maxf(0.024, _frameMs.tofloat() / 1000.0);
	local fadeIn   = ::Math.maxf(0.012, frameSec * 0.34);
	local holdSec  = ::Math.maxf(0.016, frameSec * 0.62);
	local fadeOut  = ::Math.maxf(0.018, frameSec * 0.56);

	local colZero = ::Wuxia.VFX.makeColorRGBA(_tintR, _tintG, _tintB, 0);
	local colPeak = ::Wuxia.VFX.makeColorRGBA(_tintR, _tintG, _tintB, _peakAlpha);
	local colMid  = ::Wuxia.VFX.makeColorRGBA(_tintR, _tintG, _tintB, ::Math.floor(_peakAlpha * 0.78));
	local rotF    = _rotDeg.tofloat();

	for (local i = 0; i < _count; i = ++i)
	{
		local bName = _prefix + ::Wuxia.KineticVFX.pad2(i);
		if ("doesBrushExist" in getroottable() && !::doesBrushExist(bName)) continue;
		local frac = (_count > 1) ? (i.tofloat() / (_count - 1).tofloat()) : 0.0;
		local sc = _scaleStart + (_scaleEnd - _scaleStart) * frac;
		local curOx = _ox + vxF * (i * frameSec * 0.55);
		local curOy = _oy + vyF * (i * frameSec * 0.55);
		local delay = ::Math.max(0, (_startMs + i * _frameMs).tointeger());

		local stages = [
			{
				LifeTimeMin    = fadeIn,
				LifeTimeMax    = fadeIn,
				ColorMin       = colZero,
				ColorMax       = colZero,
				ScaleMin       = sc * 0.96,
				ScaleMax       = sc * 0.96,
				RotationMin    = rotF,
				RotationMax    = rotF,
				TorqueMin      = 0.0,
				TorqueMax      = 0.0,
				VelocityMin    = speed * 0.45,
				VelocityMax    = speed * 0.45,
				DirectionMin   = dirVec,
				DirectionMax   = dirVec,
				SpawnOffsetMin = ::createVec(curOx, curOy),
				SpawnOffsetMax = ::createVec(curOx, curOy),
				ForceMin       = fZero,
				ForceMax       = fZero
			},
			{
				LifeTimeMin = holdSec,
				LifeTimeMax = holdSec,
				ColorMin    = colPeak,
				ColorMax    = colPeak,
				ScaleMin    = sc,
				ScaleMax    = sc,
				VelocityMin = speed * 0.35,
				VelocityMax = speed * 0.35,
				ForceMin    = fZero,
				ForceMax    = fZero
			},
			{
				LifeTimeMin = fadeOut,
				LifeTimeMax = fadeOut,
				ColorMin    = colMid,
				ColorMax    = colMid,
				ScaleMin    = sc * 1.03,
				ScaleMax    = sc * 1.03,
				VelocityMin = speed * 0.15,
				VelocityMax = speed * 0.15,
				ForceMin    = fZero,
				ForceMax    = fZero
			},
			{
				LifeTimeMin = 0.015,
				LifeTimeMax = 0.015,
				ColorMin    = colZero,
				ColorMax    = colZero,
				ScaleMin    = sc * 1.06,
				ScaleMax    = sc * 1.06,
				VelocityMin = 0.0,
				VelocityMax = 0.0,
				ForceMin    = fZero,
				ForceMax    = fZero
			}
		];

		::Tactical.spawnParticleEffect(false, [bName], _tile, delay, 1, 1, 1000, stages);
	}
};

::Wuxia.KineticVFX.spawnBurst <- function( _tile, _brushes, _cfg )
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (_tile == null || !_tile.IsVisibleForPlayer) return;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if (!("spawnParticleEffect" in ::Tactical)) return;
	local brushes = ::Wuxia.VFX.resolveParticleBrushes(_brushes);
	if (brushes == null) return;

	local delay    = ("delay" in _cfg)    ? ::Math.max(0, _cfg.delay.tointeger()) : 0;
	local qty      = ("qty" in _cfg)      ? ::Math.max(1, _cfg.qty.tointeger())   : 16;
	local rate     = ("rate" in _cfg)     ? _cfg.rate : 1000;
	local vMin     = ("vMin" in _cfg)     ? _cfg.vMin.tofloat() : 90.0;
	local vMax     = ("vMax" in _cfg)     ? _cfg.vMax.tofloat() : 240.0;
	local dirMinX  = ("dirMinX" in _cfg)  ? _cfg.dirMinX.tofloat() : -1.0;
	local dirMinY  = ("dirMinY" in _cfg)  ? _cfg.dirMinY.tofloat() : -1.0;
	local dirMaxX  = ("dirMaxX" in _cfg)  ? _cfg.dirMaxX.tofloat() :  1.0;
	local dirMaxY  = ("dirMaxY" in _cfg)  ? _cfg.dirMaxY.tofloat() :  1.0;
	local ox       = ("ox" in _cfg)       ? _cfg.ox.tofloat() : 0.0;
	local oy       = ("oy" in _cfg)       ? _cfg.oy.tofloat() : 0.0;
	local spreadX  = ("spreadX" in _cfg)  ? _cfg.spreadX.tofloat() : 16.0;
	local spreadY  = ("spreadY" in _cfg)  ? _cfg.spreadY.tofloat() : 14.0;
	local fx       = ("fx" in _cfg)       ? _cfg.fx.tofloat() : 0.0;
	local fy       = ("fy" in _cfg)       ? _cfg.fy.tofloat() : -120.0;
	local scMin    = ("scMin" in _cfg)    ? _cfg.scMin.tofloat() : 0.55;
	local scMax    = ("scMax" in _cfg)    ? _cfg.scMax.tofloat() : 1.15;
	local scEnd    = ("scEnd" in _cfg)    ? _cfg.scEnd.tofloat() : 0.12;
	local lifeMin  = ("lifeMin" in _cfg)  ? _cfg.lifeMin.tofloat() : 0.28;
	local lifeMax  = ("lifeMax" in _cfg)  ? _cfg.lifeMax.tofloat() : 0.55;
	local rotMin   = ("rotMin" in _cfg)   ? _cfg.rotMin.tofloat() : -180.0;
	local rotMax   = ("rotMax" in _cfg)   ? _cfg.rotMax.tofloat() :  180.0;
	local tqMin    = ("tqMin" in _cfg)    ? _cfg.tqMin.tofloat() : -280.0;
	local tqMax    = ("tqMax" in _cfg)    ? _cfg.tqMax.tofloat() :  280.0;
	local alpha    = ("alpha" in _cfg)    ? _cfg.alpha.tointeger() : 235;
	local r        = ("r" in _cfg)        ? _cfg.r.tointeger() : 255;
	local g        = ("g" in _cfg)        ? _cfg.g.tointeger() : 255;
	local b        = ("b" in _cfg)        ? _cfg.b.tointeger() : 255;

	local col0 = ::Wuxia.VFX.makeColorRGBA(r, g, b, 0);
	local col1 = ::Wuxia.VFX.makeColorRGBA(r, g, b, alpha);
	local col2 = ::Wuxia.VFX.makeColorRGBA(r, g, b, ::Math.floor(alpha * 0.65));
	local fVec = ::createVec(fx, fy);

	local stages = [
		{
			LifeTimeMin    = 0.03,
			LifeTimeMax    = 0.05,
			ColorMin       = col0,
			ColorMax       = col0,
			ScaleMin       = scMin * 0.7,
			ScaleMax       = scMax * 0.8,
			RotationMin    = rotMin,
			RotationMax    = rotMax,
			TorqueMin      = tqMin,
			TorqueMax      = tqMax,
			VelocityMin    = vMin,
			VelocityMax    = vMax,
			DirectionMin   = ::createVec(dirMinX, dirMinY),
			DirectionMax   = ::createVec(dirMaxX, dirMaxY),
			SpawnOffsetMin = ::createVec(ox - spreadX, oy - spreadY),
			SpawnOffsetMax = ::createVec(ox + spreadX, oy + spreadY),
			ForceMin       = fVec,
			ForceMax       = fVec
		},
		{
			LifeTimeMin = lifeMin * 0.45,
			LifeTimeMax = lifeMax * 0.48,
			ColorMin    = col1,
			ColorMax    = col1,
			ScaleMin    = scMin,
			ScaleMax    = scMax,
			VelocityMin = vMin * 0.72,
			VelocityMax = vMax * 0.72,
			ForceMin    = fVec,
			ForceMax    = fVec
		},
		{
			LifeTimeMin = lifeMin * 0.52,
			LifeTimeMax = lifeMax * 0.56,
			ColorMin    = col2,
			ColorMax    = col2,
			ScaleMin    = scMin * 0.55,
			ScaleMax    = scMax * 0.55,
			VelocityMin = vMin * 0.28,
			VelocityMax = vMax * 0.28,
			ForceMin    = fVec,
			ForceMax    = fVec
		},
		{
			LifeTimeMin = 0.04,
			LifeTimeMax = 0.06,
			ColorMin    = col0,
			ColorMax    = col0,
			ScaleMin    = scEnd,
			ScaleMax    = scEnd,
			VelocityMin = 0.0,
			VelocityMax = 0.0,
			ForceMin    = fVec,
			ForceMax    = fVec
		}
	];

	::Tactical.spawnParticleEffect(false, brushes, _tile, delay, qty, qty, rate, stages);
};

::Wuxia.KineticVFX.spawnShockwaveRing <- function( _tile, _ringBrush, _delayMs = 0, _sc0 = 0.26, _sc1 = 2.35, _durSec = 0.34, _oy = -10.0, _peakAlpha = 235 )
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (_tile == null || !_tile.IsVisibleForPlayer) return;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	if ("doesBrushExist" in getroottable() && !::doesBrushExist(_ringBrush)) return;

	local fZero = ::Wuxia.VFX.getVecZero();
	local col0 = ::Wuxia.VFX.makeColorRGBA(255, 255, 255, 0);
	local col1 = ::Wuxia.VFX.makeColorRGBA(255, 255, 255, _peakAlpha);
	local col2 = ::Wuxia.VFX.makeColorRGBA(255, 255, 255, ::Math.floor(_peakAlpha * 0.55));
	local scMid1 = _sc0 + (_sc1 - _sc0) * 0.45;
	local scMid2 = _sc0 + (_sc1 - _sc0) * 0.82;
	local t1 = ::Math.maxf(0.03, _durSec * 0.18);
	local t2 = ::Math.maxf(0.06, _durSec * 0.42);
	local t3 = ::Math.maxf(0.08, _durSec * 0.40);

	local stages = [
		{
			LifeTimeMin    = t1,
			LifeTimeMax    = t1,
			ColorMin       = col0,
			ColorMax       = col0,
			ScaleMin       = _sc0,
			ScaleMax       = _sc0,
			RotationMin    = 0.0,
			RotationMax    = 0.0,
			TorqueMin      = 0.0,
			TorqueMax      = 0.0,
			VelocityMin    = 0.0,
			VelocityMax    = 0.0,
			DirectionMin   = fZero,
			DirectionMax   = fZero,
			SpawnOffsetMin = ::createVec(0.0, _oy),
			SpawnOffsetMax = ::createVec(0.0, _oy),
			ForceMin       = fZero,
			ForceMax       = fZero
		},
		{
			LifeTimeMin = t2,
			LifeTimeMax = t2,
			ColorMin    = col1,
			ColorMax    = col1,
			ScaleMin    = scMid1,
			ScaleMax    = scMid1,
			VelocityMin = 0.0,
			VelocityMax = 0.0,
			ForceMin    = fZero,
			ForceMax    = fZero
		},
		{
			LifeTimeMin = t3,
			LifeTimeMax = t3,
			ColorMin    = col2,
			ColorMax    = col2,
			ScaleMin    = scMid2,
			ScaleMax    = scMid2,
			VelocityMin = 0.0,
			VelocityMax = 0.0,
			ForceMin    = fZero,
			ForceMax    = fZero
		},
		{
			LifeTimeMin = 0.03,
			LifeTimeMax = 0.03,
			ColorMin    = col0,
			ColorMax    = col0,
			ScaleMin    = _sc1,
			ScaleMax    = _sc1,
			VelocityMin = 0.0,
			VelocityMax = 0.0,
			ForceMin    = fZero,
			ForceMax    = fZero
		}
	];
	::Tactical.spawnParticleEffect(false, [_ringBrush], _tile, ::Math.max(0, _delayMs.tointeger()), 1, 1, 1000, stages);
};

::Wuxia.KineticVFX.spawnGroundDecal <- function( _tile, _kind, _delayMs = 0, _scale = 1.28, _r = 255, _g = 255, _b = 255 )
{
	if (!::Wuxia.VFX.isVfxEnabled()) return;
	if (_tile == null || !_tile.IsVisibleForPlayer || _kind == null || _kind == "") return;
	local brush = "wx_pt_crater_scorch";
	if (_kind == "frost") brush = "wx_pt_frost_patch";
	else if (_kind == "venom") brush = "wx_pt_venom_pool";
	if ("doesBrushExist" in getroottable() && !::doesBrushExist(brush)) return;

	local fZero = ::Wuxia.VFX.getVecZero();
	local col0 = ::Wuxia.VFX.makeColorRGBA(_r, _g, _b, 0);
	local col1 = ::Wuxia.VFX.makeColorRGBA(_r, _g, _b, 232);
	local col2 = ::Wuxia.VFX.makeColorRGBA(_r, _g, _b, 170);
	local stages = [
		{
			LifeTimeMin    = 0.05,
			LifeTimeMax    = 0.05,
			ColorMin       = col0,
			ColorMax       = col0,
			ScaleMin       = _scale * 0.65,
			ScaleMax       = _scale * 0.65,
			RotationMin    = 0.0,
			RotationMax    = 0.0,
			TorqueMin      = 0.0,
			TorqueMax      = 0.0,
			VelocityMin    = 0.0,
			VelocityMax    = 0.0,
			DirectionMin   = fZero,
			DirectionMax   = fZero,
			SpawnOffsetMin = ::createVec(0.0, -14.0),
			SpawnOffsetMax = ::createVec(0.0, -14.0),
			ForceMin       = fZero,
			ForceMax       = fZero
		},
		{
			LifeTimeMin = 0.55,
			LifeTimeMax = 0.60,
			ColorMin    = col1,
			ColorMax    = col1,
			ScaleMin    = _scale,
			ScaleMax    = _scale,
			VelocityMin = 0.0,
			VelocityMax = 0.0,
			ForceMin    = fZero,
			ForceMax    = fZero
		},
		{
			LifeTimeMin = 0.65,
			LifeTimeMax = 0.72,
			ColorMin    = col2,
			ColorMax    = col2,
			ScaleMin    = _scale * 1.04,
			ScaleMax    = _scale * 1.04,
			VelocityMin = 0.0,
			VelocityMax = 0.0,
			ForceMin    = fZero,
			ForceMax    = fZero
		},
		{
			LifeTimeMin = 0.12,
			LifeTimeMax = 0.14,
			ColorMin    = col0,
			ColorMax    = col0,
			ScaleMin    = _scale * 1.06,
			ScaleMax    = _scale * 1.06,
			VelocityMin = 0.0,
			VelocityMax = 0.0,
			ForceMin    = fZero,
			ForceMax    = fZero
		}
	];
	::Tactical.spawnParticleEffect(false, [brush], _tile, ::Math.max(0, _delayMs.tointeger()), 1, 1, 1000, stages);
};

// Back-compat alias
::Wuxia.KineticVFX.spawnGroundScorch <- function( _tile, _delayMs = 0, _scale = 1.25, _r = 255, _g = 255, _b = 255 )
{
	::Wuxia.KineticVFX.spawnGroundDecal(_tile, "scorch", _delayMs, _scale, _r, _g, _b);
};

// ============================================================================
// Non-Blocking CoherentUI Combat Theater Bridge (`TacticalScreen.wxPlayCombatCue`)
// ============================================================================

::Wuxia.KineticVFX.pushCombatStageCue <- function( _profile, _user, _dir, _speedScale )
{
	if (!::Wuxia.VFX.isCutInEnabled()) return;
	try
	{
		if (!("Tactical" in getroottable()) || ::Tactical == null || !("State" in ::Tactical) || ::Tactical.State == null)
			return;
		local screen = ::Tactical.State.m.TacticalScreen;
		if (screen == null || !("m" in screen) || !("JSHandle" in screen.m) || screen.m.JSHandle == null)
			return;

		local hitsScaled = [];
		if ("hits" in _profile && _profile.hits != null)
		{
			foreach (hMs in _profile.hits)
				hitsScaled.push(::Math.round(hMs * _speedScale).tointeger());
		}

		local portraitPath = "";
		local casterName = "";
		if (_user != null)
		{
			if (::Wuxia.hasMember(_user, "getImagePath")) portraitPath = _user.getImagePath();
			if (::Wuxia.hasMember(_user, "getNameOnly")) casterName = _user.getNameOnly();
			else if (::Wuxia.hasMember(_user, "getName")) casterName = _user.getName();
		}

		screen.m.JSHandle.asyncCall("wxPlayCombatCue", {
			title        = _profile.title,
			subtitle     = _profile.subtitle,
			seal         = _profile.seal,
			theme        = _profile.theme,
			impactMs     = ::Math.round(_profile.impactMs * _speedScale).tointeger(),
			totalMs      = ::Math.round(_profile.totalMs * _speedScale).tointeger(),
			portraitPath = portraitPath,
			casterName   = casterName,
			dirX         = _dir.X,
			dirY         = _dir.Y,
			hits         = hitsScaled
		});
	}
	catch (_e) {}
};

// ============================================================================
// 16 Space-Making 60 FPS Actor Motions + 5 Hitstop Target Reactions!
// Evaluated directly inside `::Wuxia.VFX.tickActorMotion` via `actor.onRender`!
// ============================================================================

::Wuxia.KineticVFX.evalActorMotion <- function( _actor, _mo, _p )
{
	local kind = _mo.kind;
	local dx = _mo.dx;
	local dy = _mo.dy;
	local px = _mo.px;
	local py = _mo.py;
	local bx = 0.0; local by = 0.0;
	local hx = 0.0; local hy = 0.0;
	local wx = 0.0; local wy = 0.0;
	local sx = 0.0; local sy = 0.0;
	local k  = 0.0;

	if (!("stepFlags" in _mo)) _mo.stepFlags <- {};

	if (kind == "kin_dash_combo3")
	{
		if (_p < 0.20)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.20);
			bx = -dx * 44.0 * k - px * 10.0 * k;
			by = -dy * 44.0 * k - py * 10.0 * k - 6.0 * k;
			wx = -dx * 16.0 * k; wy = 8.0 * k;
		}
		else if (_p < 0.38)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.20) / 0.18);
			bx = dx * (-44.0 + 78.0 * k) + px * (-10.0 + 38.0 * k);
			by = dy * (-44.0 + 78.0 * k) + py * (-10.0 + 38.0 * k) + 8.0 * ::Wuxia.VFX.arch01(k);
			hx = dx * 5.0 * k; wx = dx * 20.0 * k + px * 12.0 * k;
			if (!("a1" in _mo.stepFlags) && k > 0.30) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 22.0, by - dy * 22.0, 0, 155, 110, 235, 255); }
		}
		else if (_p < 0.52)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.38) / 0.14);
			bx = dx * (34.0 + 24.0 * k) + px * (28.0 - 58.0 * k);
			by = dy * (34.0 + 24.0 * k) + py * (28.0 - 58.0 * k) + 6.0 * ::Wuxia.VFX.arch01(k);
			hx = dx * 6.0; wx = dx * 22.0 - px * 14.0 * k;
			if (!("a2" in _mo.stepFlags) && k > 0.32) { _mo.stepFlags.a2 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx - px * 12.0, by - py * 12.0, 0, 150, 140, 245, 255); }
		}
		else if (_p < 0.64)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.52) / 0.12);
			bx = dx * (58.0 + 36.0 * k) + px * (-30.0 + 34.0 * k);
			by = dy * (58.0 + 36.0 * k) + py * (-30.0 + 34.0 * k) + 5.0 * k;
			hx = dx * 8.0; wx = dx * 26.0;
			if (!("a3" in _mo.stepFlags) && k > 0.25) { _mo.stepFlags.a3 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, dx * 48.0, dy * 48.0, 0, 145, 195, 252, 255); }
		}
		else if (_p < 0.76)
		{
			bx = dx * 94.0 + px * 4.0; by = dy * 94.0 + py * 4.0 + 5.0; hx = dx * 8.0; wx = dx * 26.0;
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.76) / 0.24);
			bx = dx * 94.0 * k + px * 4.0 * k; by = dy * 94.0 * k + py * 4.0 * k + 5.0 * k; hx = dx * 8.0 * k; wx = dx * 22.0 * k;
		}
	}
	else if (kind == "kin_dragon_palm")
	{
		if (_p < 0.34)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.34);
			local tremble = ::Wuxia.VFX.sinTurns(_p * 18.0) * 2.5 * k;
			bx = -dx * 42.0 * k + px * tremble; by = -dy * 42.0 * k - 12.0 * k + py * tremble;
			hx = -dx * 4.0 * k; hy = -4.0 * k; wx = -dx * 14.0 * k;
			if (!_mo.tintStarted && _p > 0.06) { _mo.tintStarted = true; ::Wuxia.VFX.beginActorTint(_actor, 255, 234, 168, 255, 160); }
		}
		else if (_p < 0.52)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.34) / 0.18);
			bx = dx * (-42.0 + 92.0 * k); by = dy * (-42.0 + 92.0 * k) - 12.0 * (1.0 - k) + 6.0 * ::Wuxia.VFX.arch01(k);
			hx = dx * 8.0 * k; wx = dx * 24.0 * k;
			if (!("a1" in _mo.stepFlags) && k > 0.25) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 24.0, by - dy * 24.0, 0, 155, 255, 206, 95); }
		}
		else if (_p < 0.66)
		{
			bx = dx * 50.0; by = dy * 50.0; hx = dx * 8.0; wx = dx * 24.0;
		}
		else
		{
			if (!_mo.tintEnded) { _mo.tintEnded = true; ::Wuxia.VFX.endActorTint(_actor, 180); }
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.66) / 0.34);
			bx = dx * 50.0 * k; by = dy * 50.0 * k; hx = dx * 6.0 * k; wx = dx * 18.0 * k;
		}
	}
	else if (kind == "kin_flame_leap")
	{
		if (_p < 0.14)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.14);
			bx = -dx * 24.0 * k; by = -dy * 24.0 * k - 14.0 * k; wy = -8.0 * k;
		}
		else if (_p < 0.38)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.14) / 0.24);
			bx = -dx * (24.0 - 16.0 * k); by = -dy * (24.0 - 16.0 * k) - 14.0 * (1.0 - k) + 78.0 * k;
			hy = 4.0 * k; wx = -dx * 10.0; wy = 22.0 * k;
			if (!_mo.tintStarted) { _mo.tintStarted = true; ::Wuxia.VFX.beginActorTint(_actor, 255, 204, 156, 255, 140); }
			if (!("a1" in _mo.stepFlags) && k > 0.45) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx, by - 20.0, 0, 145, 255, 130, 58); }
		}
		else if (_p < 0.50)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.38) / 0.12);
			bx = dx * (-8.0 + 54.0 * k); by = dy * (-8.0 + 54.0 * k) + 78.0 * (1.0 - k) - 6.0 * k;
			hx = dx * 7.0 * k; wx = dx * 22.0 * k; wy = 22.0 * (1.0 - k) - 14.0 * k;
			if (!("a2" in _mo.stepFlags) && k > 0.30) { _mo.stepFlags.a2 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 16.0, by + 26.0, 0, 145, 255, 175, 80); }
		}
		else if (_p < 0.64)
		{
			bx = dx * 46.0; by = dy * 46.0 - 6.0; hx = dx * 7.0; wx = dx * 22.0; wy = -12.0;
		}
		else
		{
			if (!_mo.tintEnded) { _mo.tintEnded = true; ::Wuxia.VFX.endActorTint(_actor, 180); }
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.64) / 0.36);
			bx = dx * 46.0 * k; by = dy * 46.0 * k - 6.0 * k; wx = dx * 16.0 * k;
		}
	}
	else if (kind == "kin_thunder_slam")
	{
		if (_p < 0.34)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.34);
			bx = -dx * 38.0 * k; by = -dy * 38.0 * k + 14.0 * k; hy = 4.0 * k; wx = -dx * 12.0 * k; wy = 28.0 * k;
			if (!_mo.tintStarted && _p > 0.08) { _mo.tintStarted = true; ::Wuxia.VFX.beginActorTint(_actor, 224, 206, 255, 255, 150); }
		}
		else if (_p < 0.48)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.34) / 0.14);
			bx = dx * (-38.0 + 84.0 * k); by = dy * (-38.0 + 84.0 * k) + 14.0 * (1.0 - k) - 8.0 * k;
			hx = dx * 8.0 * k; wx = dx * 22.0 * k; wy = 28.0 * (1.0 - k) - 14.0 * k;
			if (!("a1" in _mo.stepFlags) && k > 0.35) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 20.0, by + 10.0, 0, 145, 184, 142, 255); }
		}
		else if (_p < 0.64)
		{
			bx = dx * 46.0; by = dy * 46.0 - 8.0; hx = dx * 8.0; wx = dx * 22.0; wy = -14.0;
		}
		else
		{
			if (!_mo.tintEnded) { _mo.tintEnded = true; ::Wuxia.VFX.endActorTint(_actor, 190); }
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.64) / 0.36);
			bx = dx * 46.0 * k; by = dy * 46.0 * k - 8.0 * k; wx = dx * 16.0 * k;
		}
	}
	else if (kind == "kin_celestial_beam")
	{
		if (_p < 0.36)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.36);
			bx = -dx * 50.0 * k; by = -dy * 50.0 * k + 28.0 * k; wx = -dx * 10.0 * k; wy = 12.0 * k;
			if (!_mo.tintStarted && _p > 0.06) { _mo.tintStarted = true; ::Wuxia.VFX.beginActorTint(_actor, 232, 246, 255, 255, 160); }
			if (!("a1" in _mo.stepFlags) && k > 0.45) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx + dx * 16.0, by - 8.0, 0, 140, 210, 244, 255); }
		}
		else if (_p < 0.50)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.36) / 0.14);
			bx = dx * (-50.0 + 66.0 * k); by = dy * (-50.0 + 66.0 * k) + 28.0 - 4.0 * k;
			hx = dx * 6.0 * k; wx = dx * 28.0 * k; wy = 12.0 * (1.0 - k * 0.5);
		}
		else if (_p < 0.68)
		{
			bx = dx * 16.0; by = dy * 16.0 + 24.0; hx = dx * 6.0; wx = dx * 28.0; wy = 6.0;
		}
		else
		{
			if (!_mo.tintEnded) { _mo.tintEnded = true; ::Wuxia.VFX.endActorTint(_actor, 180); }
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.68) / 0.32);
			bx = dx * 16.0 * k; by = dy * 16.0 * k + 24.0 * k; wx = dx * 20.0 * k;
		}
	}
	else if (kind == "kin_spear_drill")
	{
		// Deep coiled pullback (-48px) -> explosive forward pierce (+72px) + hitstop!
		if (_p < 0.28)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.28);
			bx = -dx * 48.0 * k; by = -dy * 48.0 * k - 8.0 * k; wx = -dx * 22.0 * k;
		}
		else if (_p < 0.46)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.28) / 0.18);
			bx = dx * (-48.0 + 120.0 * k); by = dy * (-48.0 + 120.0 * k) + 6.0 * ::Wuxia.VFX.arch01(k);
			hx = dx * 8.0 * k; wx = dx * 32.0 * k;
			if (!("a1" in _mo.stepFlags) && k > 0.30) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 28.0, by - dy * 28.0, 0, 150, 120, 236, 255); }
		}
		else if (_p < 0.64)
		{
			bx = dx * 72.0; by = dy * 72.0; hx = dx * 8.0; wx = dx * 32.0;
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.64) / 0.36);
			bx = dx * 72.0 * k; by = dy * 72.0 * k; hx = dx * 8.0 * k; wx = dx * 24.0 * k;
		}
	}
	else if (kind == "kin_whirl_spin")
	{
		// Full 360° high-speed orbital sweep around origin hex + 3 afterimages!
		if (_p < 0.18)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.18);
			bx = -dx * 24.0 * k - px * 22.0 * k; by = -dy * 24.0 * k - py * 22.0 * k - 8.0 * k;
		}
		else if (_p < 0.68)
		{
			local sp = (_p - 0.18) / 0.50;
			local angT = sp * 1.35;
			local cA = ::Wuxia.VFX.cosTurns(angT);
			local sA = ::Wuxia.VFX.sinTurns(angT);
			local rad = 36.0 * ::Wuxia.VFX.arch01(sp) + 12.0;
			bx = dx * (16.0 + cA * rad) + px * (sA * rad);
			by = dy * (16.0 + cA * rad) + py * (sA * rad) + 14.0 * ::Wuxia.VFX.arch01(sp);
			wx = (cA * dx + sA * px) * 24.0;
			if (!("a1" in _mo.stepFlags) && sp > 0.22) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx, by, 0, 145, 160, 232, 255); }
			if (!("a2" in _mo.stepFlags) && sp > 0.56) { _mo.stepFlags.a2 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx, by, 0, 145, 190, 240, 255); }
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.68) / 0.32);
			bx = dx * 22.0 * k; by = dy * 22.0 * k;
		}
	}
	else if (kind == "kin_shadow_blink")
	{
		// Crouch fade -> instant dash-blink behind foe (+98px!) -> crisp hitstop -> blink return!
		if (_p < 0.22)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.22);
			bx = -dx * 34.0 * k; by = -dy * 34.0 * k - 12.0 * k;
			if (!_mo.tintStarted) { _mo.tintStarted = true; ::Wuxia.VFX.beginActorTint(_actor, 165, 145, 220, 235, 120); }
		}
		else if (_p < 0.44)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.22) / 0.22);
			bx = dx * (-34.0 + 132.0 * k) + px * (18.0 * ::Wuxia.VFX.arch01(k));
			by = dy * (-34.0 + 132.0 * k) + py * (18.0 * ::Wuxia.VFX.arch01(k)) + 8.0 * ::Wuxia.VFX.arch01(k);
			hx = dx * 8.0; wx = dx * 24.0;
			if (!("a1" in _mo.stepFlags) && k > 0.20) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, -dx * 22.0, -dy * 22.0, 0, 160, 140, 110, 215); }
			if (!("a2" in _mo.stepFlags) && k > 0.60) { _mo.stepFlags.a2 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, dx * 42.0, dy * 42.0, 0, 150, 175, 140, 245); }
		}
		else if (_p < 0.64)
		{
			bx = dx * 98.0; by = dy * 98.0; hx = dx * 8.0; wx = dx * 26.0;
		}
		else
		{
			if (!_mo.tintEnded) { _mo.tintEnded = true; ::Wuxia.VFX.endActorTint(_actor, 160); }
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.64) / 0.36);
			bx = dx * 98.0 * k; by = dy * 98.0 * k; wx = dx * 18.0 * k;
		}
	}
	else if (kind == "kin_heavy_chop")
	{
		if (_p < 0.32)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.32);
			bx = -dx * 36.0 * k; by = -dy * 36.0 * k + 18.0 * k; wx = -dx * 14.0 * k; wy = 24.0 * k;
		}
		else if (_p < 0.48)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.32) / 0.16);
			bx = dx * (-36.0 + 88.0 * k); by = dy * (-36.0 + 88.0 * k) + 18.0 * (1.0 - k) - 8.0 * k;
			hx = dx * 8.0 * k; wx = dx * 24.0 * k; wy = 24.0 * (1.0 - k) - 14.0 * k;
			if (!("a1" in _mo.stepFlags) && k > 0.32) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 22.0, by + 10.0, 0, 145, 255, 175, 120); }
		}
		else if (_p < 0.64)
		{
			bx = dx * 52.0; by = dy * 52.0 - 8.0; hx = dx * 8.0; wx = dx * 24.0; wy = -14.0;
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.64) / 0.36);
			bx = dx * 52.0 * k; by = dy * 52.0 * k - 8.0 * k; wx = dx * 16.0 * k;
		}
	}
	else if (kind == "kin_upcut_launch")
	{
		if (_p < 0.26)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.26);
			bx = -dx * 30.0 * k; by = -dy * 30.0 * k - 16.0 * k; wy = -12.0 * k;
		}
		else if (_p < 0.48)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.26) / 0.22);
			bx = dx * (-30.0 + 82.0 * k); by = dy * (-30.0 + 82.0 * k) - 16.0 * (1.0 - k) + 42.0 * k;
			hx = dx * 6.0 * k; wx = dx * 22.0 * k; wy = -12.0 + 36.0 * k;
			if (!("a1" in _mo.stepFlags) && k > 0.35) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 18.0, by - 14.0, 0, 145, 180, 240, 255); }
		}
		else if (_p < 0.64)
		{
			bx = dx * 52.0; by = dy * 52.0 + 42.0; hx = dx * 6.0; wx = dx * 22.0; wy = 24.0;
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.64) / 0.36);
			bx = dx * 52.0 * k; by = dy * 52.0 * k + 42.0 * k; wx = dx * 16.0 * k; wy = 24.0 * k;
		}
	}
	else if (kind == "kin_whip_snap")
	{
		if (_p < 0.30)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.30);
			bx = -dx * 44.0 * k; by = -dy * 44.0 * k + 8.0 * k; wx = -dx * 20.0 * k; wy = 14.0 * k;
		}
		else if (_p < 0.50)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.30) / 0.20);
			bx = dx * (-44.0 + 76.0 * k); by = dy * (-44.0 + 76.0 * k) + 8.0 * (1.0 - k);
			hx = dx * 6.0 * k; wx = dx * 28.0 * k; wy = 14.0 * (1.0 - k);
		}
		else if (_p < 0.64)
		{
			bx = dx * 32.0; by = dy * 32.0; hx = dx * 6.0; wx = dx * 28.0;
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.64) / 0.36);
			bx = dx * 32.0 * k; by = dy * 32.0 * k; wx = dx * 20.0 * k;
		}
	}
	else if (kind == "kin_bow_draw")
	{
		if (_p < 0.34)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.34);
			bx = -dx * 30.0 * k; by = -dy * 30.0 * k; wx = -dx * 14.0 * k; wy = 6.0 * k;
		}
		else if (_p < 0.52)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.34) / 0.18);
			bx = -dx * (30.0 + 10.0 * ::Wuxia.VFX.arch01(k)); by = -dy * (30.0 + 10.0 * ::Wuxia.VFX.arch01(k));
			wx = dx * 16.0 * k;
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.52) / 0.48);
			bx = -dx * 30.0 * k; by = -dy * 30.0 * k; wx = dx * 12.0 * k;
		}
	}
	else if (kind == "kin_throw_fan")
	{
		if (_p < 0.26)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.26);
			bx = -dx * 28.0 * k + px * 14.0 * k; by = -dy * 28.0 * k + py * 14.0 * k + 18.0 * k;
		}
		else if (_p < 0.48)
		{
			k = ::Wuxia.VFX.easeOut((_p - 0.26) / 0.22);
			bx = dx * (-28.0 + 58.0 * k) + px * (14.0 - 22.0 * k);
			by = dy * (-28.0 + 58.0 * k) + py * (14.0 - 22.0 * k) + 18.0 * (1.0 - k * 0.5);
			wx = dx * 22.0 * k;
			if (!("a1" in _mo.stepFlags) && k > 0.30) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, -dx * 16.0, 12.0, 0, 135, 160, 235, 255); }
		}
		else
		{
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.48) / 0.52);
			bx = dx * 30.0 * k; by = dy * 30.0 * k + 9.0 * k;
		}
	}
	else if (kind == "kin_stance_channel")
	{
		local arc = ::Wuxia.VFX.arch01(_p);
		by = 22.0 * arc;
		hy = 4.0 * arc;
		wy = 12.0 * arc;
		if (!_mo.tintStarted && _p > 0.06) { _mo.tintStarted = true; ::Wuxia.VFX.beginActorTint(_actor, 255, 240, 188, 255, 160); }
		if (!_mo.tintEnded && _p > 0.70) { _mo.tintEnded = true; ::Wuxia.VFX.endActorTint(_actor, 180); }
	}
	else if (kind == "kin_roar_pulse")
	{
		if (_p < 0.30)
		{
			k = ::Wuxia.VFX.easeOut(_p / 0.30);
			by = -14.0 * k; hy = -4.0 * k;
		}
		else if (_p < 0.62)
		{
			local sp = (_p - 0.30) / 0.32;
			local vib = ::Wuxia.VFX.sinTurns(sp * 10.0) * 5.0 * (1.0 - sp * 0.5);
			bx = px * vib; by = 22.0 * ::Wuxia.VFX.arch01(sp) + py * vib; hy = 6.0;
			if (!_mo.tintStarted) { _mo.tintStarted = true; ::Wuxia.VFX.beginActorTint(_actor, 255, 224, 150, 255, 120); }
		}
		else
		{
			if (!_mo.tintEnded) { _mo.tintEnded = true; ::Wuxia.VFX.endActorTint(_actor, 180); }
			k = 1.0 - ::Wuxia.VFX.easeInOut((_p - 0.62) / 0.38);
			by = 8.0 * k;
		}
	}
	else if (kind == "kin_qg_vault")
	{
		local arc = ::Wuxia.VFX.arch01(_p);
		by = 62.0 * arc;
		bx = dx * 16.0 * ::Wuxia.VFX.sinTurns(_p * 0.5);
		if (!("a1" in _mo.stepFlags) && _p > 0.22) { _mo.stepFlags.a1 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx - dx * 18.0, by - 14.0, 0, 145, 130, 245, 240); }
		if (!("a2" in _mo.stepFlags) && _p > 0.55) { _mo.stepFlags.a2 <- true; ::Wuxia.VFX.spawnAfterimage(_actor, bx, by + 8.0, 0, 135, 180, 255, 245); }
	}
	else if (kind == "kin_hit_heavy" || kind == "kin_hit_launch" || kind == "kin_hit_electro" || kind == "kin_hit_frost" || kind == "kin_hit_venom")
	{
		if (!_mo.tintStarted)
		{
			_mo.tintStarted = true;
			if (kind == "kin_hit_electro") ::Wuxia.VFX.beginActorTint(_actor, 232, 212, 255, 255, 50);
			else if (kind == "kin_hit_frost") ::Wuxia.VFX.beginActorTint(_actor, 165, 236, 255, 255, 60);
			else if (kind == "kin_hit_venom") ::Wuxia.VFX.beginActorTint(_actor, 175, 255, 152, 255, 60);
			else ::Wuxia.VFX.beginActorTint(_actor, 255, 246, 212, 255, 50);
		}
		if (!_mo.tintEnded && _p > 0.50)
		{
			_mo.tintEnded = true;
			::Wuxia.VFX.endActorTint(_actor, 150);
		}

		if (_p < 0.22)
		{
			local j = ::Wuxia.VFX.sinTurns(_p * 28.0) * 6.0;
			bx = dx * 10.0 + px * j; by = dy * 10.0 + py * j; hx = dx * 4.0;
		}
		else
		{
			local rP = (_p - 0.22) / 0.78;
			local arc = ::Wuxia.VFX.arch01(rP);
			if (kind == "kin_hit_launch")
			{
				bx = dx * 32.0 * arc; by = dy * 32.0 * arc + 44.0 * arc; hx = dx * 9.0 * arc; hy = 6.0 * arc;
			}
			else if (kind == "kin_hit_electro")
			{
				local zap = ::Wuxia.VFX.sinTurns(rP * 6.0) * 14.0 * arc;
				bx = dx * 18.0 * arc + px * zap; by = dy * 18.0 * arc + py * zap + 18.0 * arc; hx = px * zap * 0.6;
			}
			else if (kind == "kin_hit_frost")
			{
				local shiv = ::Wuxia.VFX.sinTurns(rP * 11.0) * 7.5 * arc;
				bx = dx * 20.0 * arc + px * shiv; by = dy * 20.0 * arc + 14.0 * arc; hx = px * shiv * 0.5;
			}
			else if (kind == "kin_hit_venom")
			{
				local hunch = ::Wuxia.VFX.sinTurns(rP * 5.0) * 9.0 * arc;
				bx = dx * 22.0 * arc + px * hunch; by = dy * 22.0 * arc - 10.0 * arc; hy = -8.0 * arc;
			}
			else
			{
				bx = dx * 34.0 * arc; by = dy * 34.0 * arc + 10.0 * arc; hx = dx * 8.0 * arc;
			}
		}
	}
	else
	{
		return false;
	}

	::Wuxia.VFX.applyActorArticulatedOffset(_actor, bx, by, hx, hy, wx, wy, sx, sy);
	return true;
};

// ============================================================================
// Universal 22-Archetype Multi-Frame Windup & Execution Choreography
// ============================================================================

::Wuxia.KineticVFX.playSeqAuto <- function( _tile, _seq, _startMs, _frameMs, _sc0, _sc1, _rot, _flipX, _ox, _oy, _vx, _vy, _alpha, _tint )
{
	if (_tile == null || _seq == null || _seq == "") return;
	local cnt = (_seq in ::Wuxia.KineticVFX.SeqFrameCount) ? ::Wuxia.KineticVFX.SeqFrameCount[_seq] : 10;
	local tr = (_tint != null && _tint.len() >= 3) ? _tint[0] : 255;
	local tg = (_tint != null && _tint.len() >= 3) ? _tint[1] : 255;
	local tb = (_tint != null && _tint.len() >= 3) ? _tint[2] : 255;
	local prefix = _seq + "_";
	if (_flipX && "doesBrushExist" in getroottable() && ::doesBrushExist(_seq + "_L_00"))
		prefix = _seq + "_L_";
	::Wuxia.KineticVFX.playFlipbook(_tile, prefix, cnt, _startMs, _frameMs, _sc0, _sc1, _rot, false, _ox, _oy, _vx, _vy, _alpha, tr, tg, tb);
};

::Wuxia.KineticVFX.resolveKineticProjectileBrush <- function( _skill, _prof )
{
	if (_skill != null && ("Projectiles" in ::Wuxia) && ("getVfxVolleySpec" in ::Wuxia.Projectiles))
	{
		try
		{
			local spec = ::Wuxia.Projectiles.getVfxVolleySpec(_skill);
			if (spec != null && ("Brush" in spec) && spec.Brush != null && spec.Brush != "")
				return spec.Brush;
		}
		catch (_e) {}
	}
	local arch = _prof != null ? _prof.arch : "";
	if (arch == "arrow_barrage") return "wx_proj_liuxingjian";
	if (arch == "flying_knives") return "wx_proj_liuyefeidao";
	if (arch == "peacock_fan")   return "wx_proj_kongqueling";
	if (arch == "cannon_blast")  return "wx_proj_pilileihuo";
	if (arch == "smoke_cloud" || arch == "venom_mire") return "wx_proj_wuduyan";
	return "wx_pt_sword_ray";
};

::Wuxia.KineticVFX.playWindupAndExecution <- function( _profileID, _prof, _user, _originTile, _targetTile, _behindTile, _dir, _flipX, _angDeg, _spd, _skill = null )
{
	local ms = function( _raw ) { return ::Math.round(_raw * _spd).tointeger(); };
	// Right-facing sprites point along +X (0 deg); mirrored `_L_` sprites point along -X (+/-180 deg).
	// OpenGL 2D rotation is CCW(+), so NW (+150 deg) needs -30 deg CW from -X, and SW (-150 deg) needs +30 deg CCW from -X.
	local tilt = _flipX ? (_angDeg >= 0.0 ? (_angDeg - 180.0) : (_angDeg + 180.0)) : _angDeg;
	if (tilt > 65.0) tilt = 65.0;
	if (tilt < -65.0) tilt = -65.0;

	local arch  = _prof.arch;
	local seq   = _prof.seq;
	local seq2  = _prof.seq2;
	local tint  = _prof.tint;
	local tfx   = ::Wuxia.KineticVFX.getThemeFx(_prof.theme);
	local ringB = tfx.ring;
	local spkB  = tfx.sparks;
	local focusTile = (_prof.kind == "stance") ? _originTile : _targetTile;
	if (focusTile == null) focusTile = _originTile;
	if (focusTile == null) return false;

	local dist = (_originTile != null && _targetTile != null) ? _originTile.getDistanceTo(_targetTile) : 0;
	local isRemoteCast = (_originTile != null && _targetTile != null && _originTile.ID != _targetTile.ID)
		&& (_prof.kind == "ranged" || (dist >= 2 && _prof.kind != "stance" && _prof.kind != "qinggong"));
	local launchedProj = false;
	local rLag = isRemoteCast ? ms(::Math.min(180, 45 + dist * 24)) : 0;

	// Beat 1: Archetype-specific Windup Telegraph & Origin-Anchored Projectile Launch!
	if (_originTile != null)
	{
		if (isRemoteCast)
		{
			// 1A. Release flash & directional muzzle/bow-draw gust strictly at `_originTile` (the attacker!)
			::Wuxia.KineticVFX.spawnShockwaveRing(_originTile, ringB, 0, 0.35, 1.45, 0.20 * _spd, 6.0, 220);
			::Wuxia.KineticVFX.spawnBurst(_originTile, [spkB[0], spkB[1], "wx_pt_glint_star"], {
				delay = ms(15), qty = 12, vMin = 120, vMax = 260,
				dirMinX = _dir.X - 0.35, dirMaxX = _dir.X + 0.35, dirMinY = _dir.Y - 0.35, dirMaxY = _dir.Y + 0.35,
				scMin = 0.48, scMax = 0.92, lifeMin = 0.18, lifeMax = 0.32,
				ox = _dir.X * 22.0, oy = _dir.Y * 14.0 + 18.0, fy = 0
			});

			// 1B. Launch visible flying projectile(s) FROM attacker (`_originTile`) TO `_targetTile`!
			if ("spawnProjectileEffect" in ::Tactical)
			{
				local projBrush = ::Wuxia.KineticVFX.resolveKineticProjectileBrush(_skill, _prof);
				local pExists = !("doesBrushExist" in getroottable()) || ::doesBrushExist(projBrush);
				if (!pExists) projBrush = "wx_pt_sword_ray";
				local pSpeedScale = ::Math.maxf(0.85, 1.38 / ::Math.maxf(0.55, _spd));
				try
				{
					::Tactical.spawnProjectileEffect(projBrush, _originTile, _targetTile, 1.15, pSpeedScale, true, false);
					launchedProj = true;
				}
				catch (_ePr0) {}

				// Multi-shot fan / barrage volleys also originate from `_originTile`!
				if (arch == "arrow_barrage" || arch == "flying_knives" || arch == "peacock_fan" || arch == "cannon_blast")
				{
					local fanTargets = [_targetTile];
					if (_prof.isAoe)
					{
						for (local d = 0; d < 6; d = ++d)
						{
							if (!_targetTile.hasNextTile(d)) continue;
							local adjT = _targetTile.getNextTile(d);
							if (adjT != null && adjT.ID != _originTile.ID && fanTargets.len() < 3)
								fanTargets.push(adjT);
						}
					}
					for (local shotIdx = 1; shotIdx <= 2; shotIdx = ++shotIdx)
					{
						local subDst = fanTargets[shotIdx % fanTargets.len()];
						::Time.scheduleEvent(::TimeUnit.Virtual, ms(38 * shotIdx), function( _p )
						{
							if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
							try { ::Tactical.spawnProjectileEffect(_p.b, _p.o, _p.d, 1.05, _p.sc, true, false); } catch (_eSub) {}
						}, { b = projBrush, o = _originTile, d = subDst, sc = pSpeedScale * 1.08 });
					}
				}
			}

			local launchSnd = (arch == "cannon_blast")
				? (::Const.DLC.Desert ? ["sounds/combat/dlc6/fire_gonne_01.wav"] : ["sounds/combat/bolt_shot_01.wav"])
				: ((arch == "flying_knives" || arch == "peacock_fan")
					? ["sounds/combat/javelin_throw_01.wav", "sounds/combat/javelin_throw_02.wav"]
					: ["sounds/combat/aimed_shot_01.wav", "sounds/combat/bolt_shot_01.wav"]);
			::Wuxia.KineticVFX.playSoundAt(ms(15), launchSnd, 0.82);
		}
		else if (arch == "sword_combo3" || arch == "shadow_cross" || arch == "spear_drill")
		{
			::Wuxia.KineticVFX.spawnShockwaveRing(_originTile, ringB, 0, 1.45, 0.30, 0.17 * _spd, 4.0, 210);
			::Wuxia.KineticVFX.spawnBurst(_originTile, ["wx_pt_glint_star"], {
				delay = ms(20), qty = 1, vMin = 0, vMax = 10, scMin = 0.85, scMax = 0.98, scEnd = 0.1,
				lifeMin = 0.15, lifeMax = 0.19, ox = -_dir.X * 18.0, oy = 12.0, fx = 0, fy = 0, rotMin = 0, rotMax = 0, tqMin = 90, tqMax = 90
			});
			::Wuxia.KineticVFX.playSoundAt(0, ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_sword_qi_01.wav", "sounds/wx_combat/wx_sword_qi_02.wav"] : ["sounds/combat/riposte_01.wav", "sounds/combat/riposte_03.wav"], 0.72);
		}
		else if (arch == "dragon_surge" || arch == "buddha_palm" || arch == "sonic_wave")
		{
			::Wuxia.KineticVFX.spawnShockwaveRing(_originTile, ringB, 0, 1.80, 0.28, 0.25 * _spd, -6.0, 225);
			::Wuxia.KineticVFX.spawnShockwaveRing(_originTile, ringB, ms(85), 1.50, 0.24, 0.22 * _spd, 6.0, 230);
			::Wuxia.KineticVFX.spawnBurst(_originTile, spkB, {
				delay = ms(20), qty = 16, vMin = 45, vMax = 125, dirMinX = -0.8, dirMaxX = 0.8, dirMinY = 0.2, dirMaxY = 1.0,
				scMin = 0.45, scMax = 0.92, lifeMin = 0.25, lifeMax = 0.42, fy = 75, spreadX = 30, spreadY = 16
			});
			::Wuxia.KineticVFX.playSoundAt(0, ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_palm_dragon_01.wav", "sounds/wx_combat/wx_palm_dragon_02.wav"] : ["sounds/combat/shield_hit_metal_01.wav", "sounds/combat/shield_hit_metal_03.wav"], 0.74);
		}
		else if (arch == "flame_leap" || arch == "earth_shatter" || arch == "heavy_cleave" || arch == "blood_cleave")
		{
			::Wuxia.KineticVFX.spawnShockwaveRing(_originTile, ringB, ms(45), 0.34, 1.55, 0.24 * _spd, -14.0, 205);
			::Wuxia.KineticVFX.spawnBurst(_originTile, [spkB[0], "wx_pt_smoke"], {
				delay = ms(40), qty = 14, vMin = 60, vMax = 160, dirMinX = -0.75, dirMaxX = 0.75, dirMinY = 0.3, dirMaxY = 1.0,
				scMin = 0.50, scMax = 1.02, lifeMin = 0.26, lifeMax = 0.46, fy = 85, spreadX = 24, spreadY = 12
			});
			::Wuxia.KineticVFX.playSoundAt(ms(35), ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_saber_gale_01.wav", "sounds/wx_combat/wx_saber_gale_02.wav"] : ["sounds/combat/crush_armor_02.wav", "sounds/combat/crush_armor_03.wav"], 0.72);
		}
		else if (arch == "thunder_slam")
		{
			::Wuxia.KineticVFX.spawnShockwaveRing(focusTile, ringB, ms(25), 1.75, 0.32, 0.28 * _spd, -12.0, 220);
			::Wuxia.KineticVFX.spawnBurst(focusTile, ["wx_pt_spark_violet"], {
				delay = ms(35), qty = 14, vMin = 50, vMax = 140, dirMinX = -0.8, dirMaxX = 0.8, dirMinY = -0.4, dirMaxY = 1.0,
				scMin = 0.50, scMax = 0.95, lifeMin = 0.22, lifeMax = 0.36, fy = 40, spreadX = 34, spreadY = 30, oy = 48
			});
			::Wuxia.KineticVFX.playSoundAt(0, ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_thunder_quake_01.wav"] : ["sounds/combat/shatter_01.wav", "sounds/combat/shatter_03.wav"], 0.68);
		}
		else if (arch == "celestial_beam")
		{
			::Wuxia.KineticVFX.spawnShockwaveRing(_originTile, ringB, 0, 1.65, 0.28, 0.26 * _spd, 22.0, 220);
			::Wuxia.KineticVFX.spawnBurst(_originTile, ["wx_pt_glint_star"], {
				delay = ms(45), qty = 2, vMin = 0, vMax = 12, scMin = 1.05, scMax = 1.25, scEnd = 0.15,
				lifeMin = 0.22, lifeMax = 0.28, oy = 24.0, fx = 0, fy = 0, rotMin = 0, rotMax = 45, tqMin = 140, tqMax = 180
			});
			if ("spawnProjectileEffect" in ::Tactical && _targetTile != null && _originTile.ID != _targetTile.ID)
			{
				try { ::Tactical.spawnProjectileEffect("wx_pt_sword_ray", _originTile, _targetTile, 1.55, 1.08, true, false); } catch (_eP) {}
			}
			::Wuxia.KineticVFX.playSoundAt(0, ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_sword_qi_01.wav", "sounds/wx_combat/wx_sword_qi_02.wav"] : ["sounds/combat/riposte_01.wav", "sounds/combat/riposte_03.wav"], 0.76);
		}
		else if (arch == "qinggong_gust" || arch == "snow_step" || arch == "warp_seal")
		{
			::Wuxia.KineticVFX.spawnShockwaveRing(_originTile, ringB, 0, 0.35, 1.75, 0.24 * _spd, -12.0, 215);
			::Wuxia.KineticVFX.playSeqAuto(_originTile, seq, 0, ms(30), 1.05, 1.25, 0.0, _flipX, 0.0, 4.0, _dir.X * 36.0, 28.0, 235, tint);
			::Wuxia.KineticVFX.spawnBurst(_originTile, [spkB[0], "wx_pt_wind_wisp", "wx_pt_petal"], {
				delay = 0, qty = 16, vMin = 80, vMax = 200, dirMinX = -0.9, dirMaxX = 0.9, dirMinY = 0.1, dirMaxY = 1.0,
				scMin = 0.50, scMax = 0.95, lifeMin = 0.30, lifeMax = 0.52, fy = 45
			});
			::Wuxia.KineticVFX.playSoundAt(0, ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_qinggong_step_01.wav", "sounds/wx_combat/wx_qinggong_step_02.wav"] : ["sounds/cloth_01.wav"], 0.72);
			return;
		}
		else
		{
			::Wuxia.KineticVFX.spawnShockwaveRing(_originTile, ringB, 0, 1.48, 0.32, 0.22 * _spd, 0.0, 205);
			::Wuxia.KineticVFX.spawnBurst(_originTile, [spkB[0], spkB[1]], {
				delay = ms(20), qty = 10, vMin = 45, vMax = 120, dirMinX = -0.8, dirMaxX = 0.8, dirMinY = 0.1, dirMaxY = 1.0,
				scMin = 0.45, scMax = 0.85, lifeMin = 0.22, lifeMax = 0.38, fy = 40
			});
		}
	}

	// Beat 2: True Multi-Frame 10-12 Frame Kinetic Animation Sequence(s)!
	local dRot = tilt;
	if (arch == "sword_combo3")
	{
		local slash1Rot = _flipX ? (tilt - 28.0) : (tilt + 28.0);
		local slash2Rot = _flipX ? (tilt + 24.0) : (tilt - 24.0);
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(135), ms(32), 1.04, 1.16, slash1Rot, _flipX, -_dir.X * 12.0, 10.0, _dir.X * 22.0, _dir.Y * 22.0, 238, tint);
		::Wuxia.KineticVFX.playSoundAt(ms(160), ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_sword_qi_01.wav", "sounds/wx_combat/wx_sword_hit_01.wav"] : ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"], 0.80);
		::Wuxia.KineticVFX.spawnBurst(focusTile, [spkB[0], spkB[1]], {
			delay = ms(180), qty = 10, vMin = 110, vMax = 240, dirMinX = _dir.X - 0.65, dirMaxX = _dir.X + 0.65, dirMinY = _dir.Y - 0.5, dirMaxY = _dir.Y + 0.8,
			scMin = 0.45, scMax = 0.85, lifeMin = 0.22, lifeMax = 0.38, fy = -160
		});
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(248), ms(32), 1.12, 1.24, slash2Rot, _flipX, -_dir.X * 6.0, -4.0, _dir.X * 24.0, _dir.Y * 24.0, 240, tint);
		::Wuxia.KineticVFX.playSoundAt(ms(275), ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_sword_qi_02.wav", "sounds/wx_combat/wx_sword_hit_01.wav"] : ["sounds/combat/slash_02.wav", "sounds/combat/slash_03.wav"], 0.84);
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(360), ms(36), 1.28, 1.44, tilt, _flipX, _dir.X * 14.0, 4.0, _dir.X * 42.0, _dir.Y * 42.0, 248, tint);
	}
	else if (arch == "dragon_surge")
	{
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(230), ms(38), 1.28, 1.48, dRot, _flipX, -_dir.X * 28.0, -_dir.Y * 18.0 + 8.0, _dir.X * 95.0, _dir.Y * 95.0, 250, tint);
		::Wuxia.KineticVFX.playSoundAt(ms(260), ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_palm_dragon_01.wav", "sounds/wx_combat/wx_palm_dragon_02.wav"] : ["sounds/combat/bash_01.wav", "sounds/combat/bash_02.wav"], 0.86);
		if (_behindTile != null && _behindTile.IsVisibleForPlayer)
			::Wuxia.KineticVFX.spawnShockwaveRing(_behindTile, ringB, ms(440), 0.30, 2.05, 0.36 * _spd, -6.0, 210);
	}
	else if (arch == "flame_leap")
	{
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(265), ms(34), 1.24, 1.42, 0.0, _flipX, -_dir.X * 10.0, 24.0, _dir.X * 30.0, -40.0, 248, tint);
		::Wuxia.KineticVFX.playSoundAt(ms(290), ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_saber_gale_01.wav", "sounds/wx_combat/wx_saber_gale_02.wav"] : ["sounds/combat/cleave_01.wav", "sounds/combat/cleave_02.wav"], 0.86);
		if (seq2 != "")
			::Wuxia.KineticVFX.playSeqAuto(focusTile, seq2, ms(375), ms(42), 1.18, 1.38, 0.0, _flipX, 0.0, 0.0, 0.0, 24.0, 248, tint);
	}
	else if (arch == "thunder_slam")
	{
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(280), ms(42), 1.24, 1.36, 0.0, _flipX, 0.0, 0.0, 0.0, 0.0, 252, tint);
		::Wuxia.KineticVFX.playSoundAt(ms(335), ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_thunder_quake_01.wav"] : ["sounds/combat/shatter_hit_01.wav"], 0.88);
	}
	else if (arch == "celestial_beam")
	{
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(250), ms(40), 1.26, 1.44, dRot, _flipX, -_dir.X * 36.0, -_dir.Y * 24.0 + 12.0, _dir.X * 40.0, _dir.Y * 40.0, 252, tint);
		::Wuxia.KineticVFX.playSoundAt(ms(310), ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_sword_qi_02.wav", "sounds/wx_combat/wx_sword_hit_01.wav"] : ["sounds/combat/slash_03.wav"], 0.88);
		if (_behindTile != null && _behindTile.IsVisibleForPlayer)
		{
			::Wuxia.KineticVFX.spawnBurst(_behindTile, spkB, {
				delay = ms(425), qty = 14, vMin = 120, vMax = 280, dirMinX = _dir.X - 0.35, dirMaxX = _dir.X + 0.35, dirMinY = _dir.Y - 0.35, dirMaxY = _dir.Y + 0.35,
				scMin = 0.45, scMax = 0.95, lifeMin = 0.25, lifeMax = 0.45, fy = -40
			});
		}
	}
	else if (arch == "spear_drill" || arch == "whip_lash" || arch == "arrow_barrage" || arch == "phoenix_spear" || arch == "flying_knives" || arch == "peacock_fan" || arch == "fist_flurry" || arch == "tidal_wave")
	{
		local startD = ((arch == "arrow_barrage" || arch == "flying_knives" || arch == "peacock_fan") ? ms(195) : ms(225)) + rLag;
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, startD, ms(36), 1.22, 1.38, dRot, _flipX, -_dir.X * 26.0, -_dir.Y * 16.0 + 6.0, _dir.X * 48.0, _dir.Y * 48.0, 248, tint);
		local beat2Snd = ["sounds/combat/impale_01.wav", "sounds/combat/slash_02.wav"];
		if (::Wuxia.VFX.isSfxEnabled())
		{
			if (arch == "whip_lash") beat2Snd = ["sounds/wx_combat/wx_whip_crack_01.wav"];
			else if (arch == "arrow_barrage" || arch == "flying_knives" || arch == "peacock_fan") beat2Snd = ["sounds/wx_combat/wx_throwing_rain_01.wav"];
			else if (arch == "fist_flurry") beat2Snd = ["sounds/wx_combat/wx_palm_inch_01.wav"];
			else beat2Snd = ["sounds/wx_combat/wx_spear_phoenix_01.wav"];
		}
		::Wuxia.KineticVFX.playSoundAt(startD + ms(30), beat2Snd, 0.84);
	}
	else if (arch == "whirl_cyclone" || arch == "bamboo_bind")
	{
		local spinTile = (_prof.isAoe && _originTile != null) ? _originTile : focusTile;
		::Wuxia.KineticVFX.playSeqAuto(spinTile, seq, ms(195), ms(38), 1.32, 1.56, 0.0, _flipX, 0.0, 4.0, 0.0, 0.0, 246, tint);
		if (focusTile != spinTile)
			::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(250) + rLag, ms(36), 1.05, 1.22, 0.0, _flipX, 0.0, 6.0, 0.0, 0.0, 224, tint);
		::Wuxia.KineticVFX.playSoundAt(ms(215), ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_spear_phoenix_01.wav", "sounds/wx_combat/wx_saber_gale_01.wav"] : ["sounds/combat/swing_01.wav", "sounds/combat/swing_02.wav"], 0.86);
	}
	else if (arch == "blood_cleave" || arch == "heavy_cleave" || arch == "giant_axe" || arch == "moon_crescent")
	{
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(235) + rLag, ms(36), 1.24, 1.42, tilt * 0.4, _flipX, -_dir.X * 8.0, 14.0, _dir.X * 28.0, -24.0, 248, tint);
		::Wuxia.KineticVFX.playSoundAt(ms(265) + rLag, ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_saber_gale_01.wav", "sounds/wx_combat/wx_saber_gale_02.wav"] : ["sounds/combat/cleave_01.wav", "sounds/combat/slash_03.wav"], 0.86);
	}
	else if (arch == "claw_rend" || arch == "shadow_cross" || arch == "prism_burst")
	{
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(210) + rLag, ms(35), 1.18, 1.36, tilt * 0.35, _flipX, 0.0, 8.0, _dir.X * 20.0, _dir.Y * 20.0, 248, tint);
		::Wuxia.KineticVFX.playSoundAt(ms(230) + rLag, ::Wuxia.VFX.isSfxEnabled() ? ["sounds/wx_combat/wx_sword_qi_01.wav", "sounds/wx_combat/wx_palm_inch_01.wav"] : ["sounds/combat/slash_01.wav", "sounds/combat/puncture_01.wav"], 0.84);
	}
	else if (arch == "buddha_palm" || arch == "frost_burst" || arch == "venom_mire" || arch == "earth_shatter" || arch == "cannon_blast" || arch == "sword_rain" || arch == "smoke_cloud")
	{
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(245) + rLag, ms(38), 1.24, 1.42, 0.0, _flipX, 0.0, 0.0, 0.0, 0.0, 250, tint);
		local aoeSnd = ["sounds/combat/bash_01.wav", "sounds/combat/shatter_hit_01.wav"];
		if (::Wuxia.VFX.isSfxEnabled())
		{
			if (arch == "cannon_blast") aoeSnd = ["sounds/wx_combat/wx_firelance_boom_01.wav"];
			else if (arch == "sword_rain") aoeSnd = ["sounds/wx_combat/wx_sword_qi_01.wav", "sounds/wx_combat/wx_sword_qi_02.wav"];
			else if (arch == "buddha_palm") aoeSnd = ["sounds/wx_combat/wx_palm_dragon_01.wav", "sounds/wx_combat/wx_golden_bell_01.wav"];
			else if (arch == "smoke_cloud" || arch == "venom_mire") aoeSnd = ["sounds/wx_combat/wx_qinggong_step_02.wav"];
			else aoeSnd = ["sounds/wx_combat/wx_thunder_quake_01.wav"];
		}
		::Wuxia.KineticVFX.playSoundAt(ms(270) + rLag, aoeSnd, 0.85);
	}
	else
	{
		// sonic_wave, taiji_seal, golden_dome, soul_vortex, lotus_poke, war_banner, xuanwu_aegis, gold_needles
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq, ms(170) + rLag, ms(38), 1.18, 1.38, 0.0, _flipX, 0.0, 8.0, 0.0, 0.0, 246, tint);
		local utilSnd = ["sounds/combat/shieldwall_01.wav", "sounds/combat/shieldwall_02.wav", "sounds/combat/riposte_03.wav"];
		if (::Wuxia.VFX.isSfxEnabled())
		{
			if (seq == "wx_kin_golden_dome" || seq == "wx_kin_xuanwu_aegis") utilSnd = ["sounds/wx_combat/wx_golden_bell_01.wav"];
			else if (seq == "wx_kin_war_banner" || seq == "wx_kin_sonic_wave") utilSnd = ["sounds/wx_ritual/wx_war_horn.wav"];
			else if (seq == "wx_kin_lotus_poke" || seq == "wx_kin_gold_needles") utilSnd = ["sounds/wx_combat/wx_finger_acupoint_01.wav", "sounds/wx_combat/wx_finger_acupoint_02.wav"];
			else utilSnd = ["sounds/wx_ritual/wx_qi_meditate.wav"];
		}
		::Wuxia.KineticVFX.playSoundAt(ms(190) + rLag, utilSnd, 0.80);
	}

	// Optional Secondary Signature Sequence (`seq2`) — creates rich hybrid dual-element skills (e.g. Ice-Fire Cross, Wanjian, Kaitian)!
	if (seq2 != "" && arch != "flame_leap")
	{
		local s2Start = ms(_prof.impactMs - 45) + rLag;
		local s2Rot = 0.0;
		if (seq2 == "wx_kin_celestial_beam" || seq2 == "wx_kin_spear_drill" || seq2 == "wx_kin_dragon_surge"
			|| seq2 == "wx_kin_arrow_barrage" || seq2 == "wx_kin_phoenix_spear" || seq2 == "wx_kin_whip_lash"
			|| seq2 == "wx_kin_flying_knives" || seq2 == "wx_kin_peacock_fan" || seq2 == "wx_kin_fist_flurry"
			|| seq2 == "wx_kin_tidal_wave")
		{
			s2Rot = dRot;
		}
		else if (seq2 == "wx_kin_sword_slash" || seq2 == "wx_kin_flame_cleave" || seq2 == "wx_kin_blood_arc"
			|| seq2 == "wx_kin_giant_axe" || seq2 == "wx_kin_moon_crescent" || seq2 == "wx_kin_claw_rend"
			|| seq2 == "wx_kin_shadow_cross")
		{
			s2Rot = tilt * 0.4;
		}
		::Wuxia.KineticVFX.playSeqAuto(focusTile, seq2, s2Start, ms(38), 1.16, 1.34, s2Rot, _flipX, 0.0, 6.0, 0.0, 0.0, 236, tint);
	}
	return launchedProj;
};

// Exact-Frame Impact Particle Explosion + Target Hitstop Reaction!
::Wuxia.KineticVFX.playImpactClimax <- function( _profileID, _prof, _originTile, _targetTile, _targetEntity, _dir, _hit, _spd, _flipX = null )
{
	local focusTile = (_prof.kind == "stance") ? _originTile : _targetTile;
	if (focusTile == null) return;
	local tfx   = ::Wuxia.KineticVFX.getThemeFx(_prof.theme);
	local ringB = tfx.ring;
	local spkB  = tfx.sparks;

	// 1. Target Kinetic Hitstop + Recoil / Launch / Electro / Frost / Venom Reaction
	if (_prof.kind != "stance" && _prof.kind != "qinggong" && _targetEntity != null && _targetEntity.isAlive() && ::Wuxia.isOnMap(_targetEntity) && _targetEntity != null)
	{
		if (::Wuxia.VFX.isMotionEnabled())
		{
			if (!_hit && _prof.kind != "util")
				::Wuxia.VFX.startActorMotion(_targetEntity, "dodge_sway", _dir, 0.34, 0.0, _profileID);
			else
				::Wuxia.VFX.startActorMotion(_targetEntity, _prof.react, _dir, 0.45, 0.0, _profileID);
		}
		else if (_hit && _originTile != null)
		{
			::Wuxia.VFX.shakeEntityFrom(_targetEntity, _originTile, _prof.shakePow);
		}
	}

	if (!::Wuxia.VFX.isVfxEnabled() || !focusTile.IsVisibleForPlayer) return;

	// Miss glancing wind burst
	if (!_hit && (_prof.kind == "melee" || _prof.kind == "ranged"))
	{
		::Wuxia.KineticVFX.spawnBurst(focusTile, ["wx_pt_wind_wisp", "wx_pt_smoke"], {
			delay = 0, qty = 8, vMin = 95, vMax = 190,
			dirMinX = _dir.X - 0.5, dirMaxX = _dir.X + 0.5, dirMinY = _dir.Y - 0.4, dirMaxY = _dir.Y + 0.6,
			scMin = 0.45, scMax = 0.85, lifeMin = 0.22, lifeMax = 0.36, fy = 20, alpha = 165
		});
		return;
	}

	// 2. Qinggong Arrival Kinetic Burst on Target Landing Hex!
	if (_prof.kind == "qinggong")
	{
		local qFlip = (_flipX != null) ? _flipX : ::Wuxia.VFX.shouldFlipLeft(_dir);
		if (_prof.ground != "")
			::Wuxia.KineticVFX.spawnGroundDecal(focusTile, _prof.ground, 0, 1.20, _prof.tint[0], _prof.tint[1], _prof.tint[2]);
		::Wuxia.KineticVFX.spawnShockwaveRing(focusTile, ringB, 0, 0.28, 2.05, 0.32 * _spd, -12.0, 235);
		::Wuxia.KineticVFX.playSeqAuto(focusTile, _prof.seq, 0, ::Math.round(32 * _spd).tointeger(), 1.10, 1.32, 0.0, qFlip, 0.0, 4.0, 0.0, 22.0, 240, _prof.tint);
		if (_prof.seq2 != "")
			::Wuxia.KineticVFX.playSeqAuto(focusTile, _prof.seq2, 20, ::Math.round(34 * _spd).tointeger(), 1.05, 1.24, 0.0, qFlip, 0.0, 4.0, 0.0, 0.0, 220, _prof.tint);
		::Wuxia.KineticVFX.spawnBurst(focusTile, spkB, {
			delay = 0, qty = 22, vMin = 100, vMax = 240, dirMinX = -1.0, dirMaxX = 1.0, dirMinY = 0.0, dirMaxY = 1.0,
			scMin = 0.50, scMax = 1.05, lifeMin = 0.32, lifeMax = 0.58, fy = 40
		});
		return;
	}

	// 3. Lingering Ground Aftermath (Scorched Crater / Frozen Rime / Bubbling Venom Pool)
	if (_prof.ground != "")
	{
		::Wuxia.KineticVFX.spawnGroundDecal(focusTile, _prof.ground, 0, 1.38, _prof.tint[0], _prof.tint[1], _prof.tint[2]);
	}

	// 4. Dual Expanding Isometric Shockwave Rings + 26..34 GPU Physics Particles!
	local ringMax = (_prof.shakePow >= 8) ? 2.55 : 2.15;
	::Wuxia.KineticVFX.spawnShockwaveRing(focusTile, ringB, 0, 0.26, ringMax, 0.36 * _spd, -8.0, 245);
	if (_prof.shakePow >= 7 || _prof.isAoe || _prof.arch == "celestial_beam")
	{
		local r2 = (_prof.theme == "celestial") ? "wx_pt_ring_cyan" : ringB;
		::Wuxia.KineticVFX.spawnShockwaveRing(focusTile, r2, 70, 0.30, ringMax * 0.82, 0.32 * _spd, 8.0, 215);
	}

	local gravY = (_prof.theme == "fire" || _prof.kind == "stance") ? 75 : ((_prof.arch == "thunder_slam" || _prof.arch == "earth_shatter") ? -240 : -130);
	local qty = (_prof.shakePow >= 8) ? 32 : 24;
	::Wuxia.KineticVFX.spawnBurst(focusTile, spkB, {
		delay = 0, qty = qty, vMin = 130, vMax = 340,
		dirMinX = (_prof.kind == "stance" ? -1.0 : _dir.X - 0.70), dirMaxX = (_prof.kind == "stance" ? 1.0 : _dir.X + 0.70),
		dirMinY = -0.35, dirMaxY = 1.0,
		scMin = 0.55, scMax = 1.22, lifeMin = 0.32, lifeMax = 0.64, fy = gravY
	});

	// Rock / Smoke / Ice / Glint Secondary Climax Layer
	if (_prof.arch == "thunder_slam" || _prof.arch == "earth_shatter" || _prof.arch == "dragon_surge" || _prof.arch == "buddha_palm")
	{
		::Wuxia.KineticVFX.spawnBurst(focusTile, ["wx_pt_rock", "wx_pt_smoke"], {
			delay = 15, qty = 14, vMin = 110, vMax = 260, dirMinX = -0.95, dirMaxX = 0.95, dirMinY = 0.25, dirMaxY = 1.0,
			scMin = 0.55, scMax = 1.12, lifeMin = 0.40, lifeMax = 0.70, fy = -310, alpha = 205
		});
	}
	else if (_prof.theme == "frost")
	{
		::Wuxia.KineticVFX.spawnBurst(focusTile, ["wx_pt_ice_shard", "wx_pt_glint_star"], {
			delay = 0, qty = 16, vMin = 120, vMax = 280, dirMinX = -1.0, dirMaxX = 1.0, dirMinY = 0.1, dirMaxY = 1.0,
			scMin = 0.55, scMax = 1.15, lifeMin = 0.34, lifeMax = 0.62, fy = -180
		});
	}
	else if (_prof.arch == "celestial_beam" || _prof.arch == "shadow_cross")
	{
		::Wuxia.KineticVFX.spawnBurst(focusTile, ["wx_pt_glint_star"], {
			delay = 0, qty = 3, vMin = 10, vMax = 45, scMin = 1.15, scMax = 1.55, scEnd = 0.15,
			lifeMin = 0.24, lifeMax = 0.36, fy = 0, rotMin = 0, rotMax = 45, tqMin = 90, tqMax = 160
		});
	}
};

// Per-target kinetic hit reaction for multi-target AoE & multi-hit strikes during `WX_KineticSuppressLegacy`!
::Wuxia.KineticVFX.onKineticAttackResult <- function( _skill, _user, _hitTile, _targetEntity, _hit )
{
	if (_skill == null || _hitTile == null) return;
	if (!("WX_KineticActiveCtx" in _skill.m) || _skill.m.WX_KineticActiveCtx == null) return;
	local ctx = _skill.m.WX_KineticActiveCtx;
	if (_hit) ctx.anyHit = true;

	// Avoid duplicating primary target climax (handled by `playImpactClimax`); give every SECONDARY AoE target its own burst!
	if (ctx.targetTile != null && _hitTile.ID == ctx.targetTile.ID) return;

	local dir = ::Wuxia.VFX.getDirVec(ctx.originTile, _hitTile);
	if (_targetEntity != null && _targetEntity.isAlive() && ::Wuxia.isOnMap(_targetEntity) && ::Wuxia.VFX.isMotionEnabled())
	{
		if (!_hit)
			::Wuxia.VFX.startActorMotion(_targetEntity, "dodge_sway", dir, 0.32, 0.0, ctx.profileID);
		else
			::Wuxia.VFX.startActorMotion(_targetEntity, ctx.prof.react, dir, 0.42, 0.0, ctx.profileID);
	}
	if (_hit && ::Wuxia.VFX.isVfxEnabled() && _hitTile.IsVisibleForPlayer)
	{
		local tfx = ::Wuxia.KineticVFX.getThemeFx(ctx.prof.theme);
		::Wuxia.KineticVFX.spawnShockwaveRing(_hitTile, tfx.ring, 0, 0.26, 1.75, 0.28 * ctx.spd, -6.0, 220);
		::Wuxia.KineticVFX.spawnBurst(_hitTile, tfx.sparks, {
			delay = 0, qty = 14, vMin = 110, vMax = 250, dirMinX = dir.X - 0.6, dirMaxX = dir.X + 0.6, dirMinY = -0.3, dirMaxY = 0.9,
			scMin = 0.50, scMax = 1.05, lifeMin = 0.26, lifeMax = 0.48, fy = -140
		});
	}
};

// ============================================================================
// Bulletproof Busy-State Management & 4-Beat Delayed Execution Pipeline
// ============================================================================

::Wuxia.KineticVFX.releaseCast <- function( _cast )
{
	if (!(_cast in ::Wuxia.KineticVFX.PendingCasts)) return;
	delete ::Wuxia.KineticVFX.PendingCasts[_cast];
};

::Wuxia.KineticVFX.isCasting <- function( _actor )
{
	if (_actor == null) return false;
	local id = _actor.getID();
	foreach (cast, _ in ::Wuxia.KineticVFX.PendingCasts)
		if (cast.actorID == id) return true;
	return false;
};

::Wuxia.KineticVFX.releaseActorBusy <- function( _actor = null )
{
	local casts = [];
	foreach (cast, _ in ::Wuxia.KineticVFX.PendingCasts)
		if (_actor == null || cast.actorID == _actor.getID()) casts.push(cast);
	foreach (cast in casts) ::Wuxia.KineticVFX.releaseCast(cast);
};

::Wuxia.KineticVFX.clearAll <- function()
{
	::Wuxia.KineticVFX.releaseActorBusy();
	try
	{
		if (("Tactical" in getroottable()) && ::Tactical != null && ("State" in ::Tactical) && ::Tactical.State != null)
		{
			local sc = ::Tactical.State.m.TacticalScreen;
			if (sc != null && ("m" in sc) && ("JSHandle" in sc.m) && sc.m.JSHandle != null)
				sc.m.JSHandle.asyncCall("wxCloseCombatCue", null);
		}
	}
	catch (_e2) {}
};

// Master Entry Point for ALL 171 Active Skills!
::Wuxia.KineticVFX.executeSkill <- function( _skill, _user, _targetTile, _profileID, _onImpactFn )
{
	if (_skill == null || _user == null || _onImpactFn == null)
		return false;

	local prof = ::Wuxia.KineticVFX.getProfile(_profileID);
	local originTile = ::Wuxia.isOnMap(_user) ? _user.getTile() : null;
	local targetTile = (_targetTile != null) ? _targetTile : originTile;
	if (targetTile == null) return _onImpactFn(_user, _targetTile);

	local isVisible = (targetTile.IsVisibleForPlayer || (originTile != null && originTile.IsVisibleForPlayer));
	local vSpeed = 1.0;
	try { if ("Time" in getroottable() && ::Time != null && ("getVirtualSpeed" in ::Time)) vSpeed = ::Time.getVirtualSpeed(); } catch (_eS) {}

	// Instant synchronous fallback when VFX disabled, off-screen, or fast-simulating (>2.5x)
	if (prof == null || !::Wuxia.VFX.isVfxEnabled() || !isVisible || vSpeed > 2.5
		|| !("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive())
	{
		return _onImpactFn(_user, _targetTile);
	}

	// Reinforcements and equipment changes can introduce a sequence after deployment.
	if (::Wuxia.VFX.queueKineticProfile(prof)) ::Wuxia.VFX.warmBattleTextures();

	local spd        = ::Wuxia.VFX.getMotionSpeedScale(_user);
	local dir        = ::Wuxia.VFX.getDirVec(originTile, targetTile, _user);
	local flipX      = ::Wuxia.VFX.shouldFlipLeft(dir, _user);
	local angDeg     = ::Wuxia.KineticVFX.atan2Deg(dir.Y, dir.X);
	local behindTile = ::Wuxia.KineticVFX.getBehindTile(originTile, targetTile);

	// Special zero-conflict path for vanilla `footwork` subclass (`wx_qinggong_lingbo`):
	// run vanilla travel synchronously while layering our kinetic departure/arrival gust + cut-in!
	if (prof.isFootwork)
	{
		::Wuxia.KineticVFX.pushCombatStageCue(prof, _user, dir, spd);
		try { ::Wuxia.KineticVFX.playWindupAndExecution(_profileID, prof, _user, originTile, targetTile, behindTile, dir, flipX, angDeg, spd); } catch (_eF) {}
		_skill.m.WX_KineticSuppressLegacy <- true;
		local fOk = false;
		try { fOk = _onImpactFn(_user, _targetTile); }
		catch (err)
		{
			_skill.m.WX_KineticSuppressLegacy = false;
			throw err;
		}
		_skill.m.WX_KineticSuppressLegacy <- false;
		if (!fOk) return fOk;
		::Time.scheduleEvent(::TimeUnit.Virtual, ::Math.round(160 * spd).tointeger(), function( _t ) {
			if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
			try { ::Wuxia.KineticVFX.playImpactClimax(_t.pid, _t.prof, _t.o, _t.d, null, _t.dir, true, _t.spd, _t.flipX); } catch (_eF3) {}
		}, { pid = _profileID, prof = prof, o = originTile, d = targetTile, dir = dir, spd = spd, flipX = flipX });
		return fOk;
	}

	local hexDist    = (originTile != null && targetTile != null) ? originTile.getDistanceTo(targetTile) : 0;
	local remoteLag  = ((originTile != null && targetTile != null && originTile.ID != targetTile.ID)
		&& (prof.kind == "ranged" || (hexDist >= 2 && prof.kind != "stance" && prof.kind != "qinggong")))
		? ::Math.min(180, 45 + hexDist * 24) : 0;
	local impactMs   = ::Math.max(110, ::Math.round((prof.impactMs + remoteLag) * spd).tointeger());
	local releaseMs  = ::Math.max(impactMs + 95, ::Math.round((prof.releaseMs + remoteLag) * spd).tointeger());
	local totalSec   = ::Math.maxf(0.42, ((prof.totalMs + remoteLag).tofloat() / 1000.0));

	// 2. Push Non-Blocking CoherentUI Wuxia Combat Theater Cue (vignette + calligraphy cut-in + impact canvas!)
	::Wuxia.KineticVFX.pushCombatStageCue(prof, _user, dir, spd);

	// 3. Kick off 60 FPS Space-Making Caster Motion (Pullback / Aerial Leap / Dash-Through / Spin + Hitstop!)
	if (::Wuxia.VFX.isMotionEnabled())
	{
		::Wuxia.VFX.startActorMotion(_user, prof.motionKind, dir, totalSec, 0.0, _profileID);
		if (("getShaker" in ::Tactical) && ::Tactical.getShaker() != null && ("cancel" in ::Tactical.getShaker()))
		{
			try { ::Tactical.getShaker().cancel(_user); } catch (_eSh) {}
		}
	}

	// 4. Spawn Windup + Origin Projectile + True Multi-Frame Kinetic Animation + Layered Audio!
	local launchedKineticProj = false;
	try
	{
		launchedKineticProj = ::Wuxia.KineticVFX.playWindupAndExecution(_profileID, prof, _user, originTile, targetTile, behindTile, dir, flipX, angDeg, spd, _skill) == true;
	}
	catch (_eVfx)
	{
		::Wuxia.VFX.logOnce("KineticVFX.windup:" + _profileID, _eVfx);
	}

	// 5. Schedule EXACT-FRAME IMPACT (Damage, Status, Knockback, Teleport, Stance Buff, Hitstop & Climax Burst!)
	local ctx = {
		skill               = _skill,
		user                = _user,
		actorID             = _user.getID(),
		originTile          = originTile,
		targetTile          = targetTile,
		rawTarget           = _targetTile,
		targetEnt           = (targetTile != null && ::Wuxia.hasMember(targetTile, "IsOccupiedByActor") && targetTile.IsOccupiedByActor && prof.kind != "stance" && prof.kind != "qinggong") ? targetTile.getEntity() : null,
		profileID           = _profileID,
		prof                = prof,
		dir                 = dir,
		flipX               = flipX,
		spd                 = spd,
		anyHit              = false,
		launchedKineticProj = launchedKineticProj,
		onImpact            = _onImpactFn
	};

	::Wuxia.KineticVFX.PendingCasts[ctx] <- true;
	::Time.scheduleEvent(::TimeUnit.Virtual, impactMs, function( _tag )
	{
		if (!(_tag in ::Wuxia.KineticVFX.PendingCasts)) return;
		if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()
			|| _tag.user == null || !_tag.user.isAlive() || !::Wuxia.isOnMap(_tag.user))
		{
			::Wuxia.KineticVFX.releaseCast(_tag);
			return;
		}

		local needsAliveTarget = ((_tag.prof.kind == "melee" || _tag.prof.kind == "ranged") && !_tag.prof.isAoe);
		if (needsAliveTarget && (_tag.targetEnt == null || !_tag.targetEnt.isAlive()
			|| !::Wuxia.hasMember(_tag.targetTile, "IsOccupiedByActor") || !_tag.targetTile.IsOccupiedByActor || _tag.targetTile.getEntity().getID() != _tag.targetEnt.getID())) return;
		if (_tag.skill.isTargeted() && !_tag.skill.onVerifyTarget(_tag.user.getTile(), _tag.targetTile)) return;

		_tag.skill.m.WX_KineticSuppressLegacy <- true;
		_tag.skill.m.WX_KineticActiveCtx <- _tag;
		local origShowProj = ("IsShowingProjectile" in _tag.skill.m) ? _tag.skill.m.IsShowingProjectile : false;
		if (_tag.launchedKineticProj && ("IsShowingProjectile" in _tag.skill.m))
			_tag.skill.m.IsShowingProjectile = false;
		local retHit = false;
		try
		{
			retHit = _tag.onImpact(_tag.user, _tag.rawTarget);
		}
		catch (_err)
		{
			::Wuxia.VFX.logOnce("KineticVFX.impact:" + _tag.profileID, _err);
		}
		if ("IsShowingProjectile" in _tag.skill.m)
			_tag.skill.m.IsShowingProjectile = origShowProj;
		_tag.skill.m.WX_KineticSuppressLegacy <- false;
		_tag.skill.m.WX_KineticActiveCtx <- null;

		if (("getShaker" in ::Tactical) && ::Tactical.getShaker() != null && ("cancel" in ::Tactical.getShaker()))
		{
			try { ::Tactical.getShaker().cancel(_tag.user); } catch (_eC) {}
		}

		local liveEnt = _tag.targetEnt;
		if (liveEnt == null && _tag.targetTile != null && ::Wuxia.hasMember(_tag.targetTile, "IsOccupiedByActor") && _tag.targetTile.IsOccupiedByActor && _tag.prof.kind != "stance" && _tag.prof.kind != "qinggong")
			liveEnt = _tag.targetTile.getEntity();
		local didHit = (retHit == true || _tag.anyHit || _tag.prof.kind == "stance" || _tag.prof.kind == "qinggong" || _tag.prof.kind == "util");

		try
		{
			::Wuxia.KineticVFX.playImpactClimax(_tag.profileID, _tag.prof, _tag.originTile, _tag.targetTile, liveEnt, _tag.dir, didHit, _tag.spd, _tag.flipX);
		}
		catch (_eCl)
		{
			::Wuxia.VFX.logOnce("KineticVFX.climax:" + _tag.profileID, _eCl);
		}
	}, ctx);

	// 6. Schedule Snappy Busy Unlock right after hitstop!
	::Time.scheduleEvent(::TimeUnit.Virtual, releaseMs, function( _tag )
	{
		::Wuxia.KineticVFX.releaseCast(_tag);
	}, ctx);

	return true;
};

// ============================================================================
// Universal Non-Destructive HookTree Wiring for ALL 171 Active Wuxia Skills!
// ============================================================================

if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	// The native container resets its BusyStack on turn, movement and roster events.
	// Keep pending casts independent so their timers cannot decrement a newer action's lock.
	::Wuxia.HooksMod.hook("scripts/skills/skill_container", function( q )
	{
		q.isBusy = @(__original) function()
		{
			return __original() || (::Wuxia.KineticVFX.PendingCasts.len() > 0 && ::Wuxia.KineticVFX.isCasting(this.getActor()));
		};
	});

	::Wuxia.HooksMod.hook("scripts/states/tactical_state", function( q )
	{
		q.isInputLocked = @(__original) function()
		{
			if (__original()) return true;
			return ::Wuxia.KineticVFX.PendingCasts.len() > 0 && ::Tactical.TurnSequenceBar != null
				&& ::Wuxia.KineticVFX.isCasting(::Tactical.TurnSequenceBar.getActiveEntity());
		};
	});

	::Wuxia.HooksMod.hookTree("scripts/skills/skill", function( q )
	{
		if (::Wuxia.qHas(q, "create", false))
		{
			q.create = @(__original) function()
			{
				__original();
				if (this.m.ID != null && this.m.ID.find("actives.wx_") == 0)
					this.m.IsDoingForwardMove = false;
			};
		}

		if (::Wuxia.qHas(q, "onUse", false))
		{
			q.onUse = @(__original) function( _user, _targetTile )
			{
				if (this.m.ID == null || this.m.ID.find("actives.wx_") != 0 || (("WX_InKineticExec" in this.m) && this.m.WX_InKineticExec))
					return __original(_user, _targetTile);

				local runWithMechanics = function( _self, _u, _tTile )
				{
					local origUTile = ::Wuxia.isOnMap(_u) ? _u.getTile() : null;
					local preEnt = ::Wuxia.isTileOccupiedByActor(_tTile) ? _tTile.getEntity() : null;
					local rHit = __original.call(_self, _u, _tTile);
					if (::Wuxia.hasMember(_self, "wxTriggerTagPostMechanic"))
					{
						try { _self.wxTriggerTagPostMechanic(_u, preEnt, _tTile, rHit == true); } catch (_eM) {}
					}
					else if (rHit && _self.m.ID.find("actives.wx_qinggong_") == 0 && ("CombatRules" in ::Wuxia) && ("triggerQinggongDistinctiveEffect" in ::Wuxia.CombatRules))
					{
						try { ::Wuxia.CombatRules.triggerQinggongDistinctiveEffect(_self.m.ID, _u, origUTile, _tTile); } catch (_eQ) {}
					}
					return rHit;
				};

				local self = this;
				local doImpact = function( _u, _tTile )
				{
					self.m.WX_InKineticExec <- true;
					local res = false;
					try
					{
						res = runWithMechanics(self, _u, _tTile);
					}
					catch (_e)
					{
						self.m.WX_InKineticExec <- false;
						throw _e;
					}
					self.m.WX_InKineticExec <- false;
					return res;
				};

				local key = this.m.ID.slice(8);
				if (::Wuxia.KineticVFX.getProfile(key) == null) return doImpact(_user, _targetTile);
				return ::Wuxia.KineticVFX.executeSkill(this, _user, _targetTile, key, doImpact);
			};
		}
	});
}
