#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Expands mod_wuxia with:
1. Wuxia Active Skill VFX Engine (`mod_wuxia/systems/wx_vfx_system.nut`) + `WX_VfxBrush` bindings across all 72 Active Skills
2. +37 Brand-New Wuxia Active Skills (`35 -> 72` playable active skills in `scripts/skills/actives/*.nut`), wired into manuals, AI & SelfTest
3. +16 Brand-New Shan Hai Jing Mythical Apex Bosses (`48 -> 64` bosses, cores & lairs across《山海经》), wired into `wx_shanhai.nut`, `wx_encounters.nut` & SelfTest
"""

import glob
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOD = os.path.join(ROOT, "mod_wuxia")

# ==============================================================================
# 1. WUXIA VFX SYSTEM (`mod_wuxia/mod_wuxia/systems/wx_vfx_system.nut`)
# ==============================================================================
VFX_SYSTEM_NUT = """// Wuxia Tactical Skill Visual Effects (VFX) System
// Spawns custom compiled .brush Qi arcs, palm seals, frost/flame bursts & golden-bell auras on tactical tiles!

::Wuxia.VFX <- {
	Cache = {}
};

::Wuxia.VFX.buildAttackEffect <- function( _brushName )
{
	if (_brushName in ::Wuxia.VFX.Cache)
		return ::Wuxia.VFX.Cache[_brushName];

	if (!("Const" in getroottable()) || !("Tactical" in ::Const) || !("AttackEffectSlash" in ::Const.Tactical))
		return null;

	local srcEff = ::Const.Tactical.AttackEffectSlash;
	local custom = null;
	if (typeof srcEff == "array")
	{
		custom = [];
		foreach (elem in srcEff)
		{
			if (typeof elem == "table")
			{
				local c = clone elem;
				if ("Brush" in c) c.Brush = _brushName;
				custom.push(c);
			}
			else
			{
				custom.push(elem);
			}
		}
	}
	else if (typeof srcEff == "table")
	{
		custom = clone srcEff;
		if ("Brush" in custom) custom.Brush = _brushName;
	}
	::Wuxia.VFX.Cache[_brushName] <- custom;
	return custom;
};

::Wuxia.VFX.playSkillVfx <- function( _skill, _user, _targetTile, _brushName )
{
	if (_brushName == null || _brushName == "") return;
	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()) return;
	local tile = _targetTile != null ? _targetTile : (_user != null && _user.isPlacedOnMap() ? _user.getTile() : null);
	if (tile == null || !tile.IsVisibleForPlayer) return;

	try
	{
		if (_skill != null && ("spawnAttackEffect" in _skill))
		{
			local eff = ::Wuxia.VFX.buildAttackEffect(_brushName);
			if (eff != null)
			{
				_skill.spawnAttackEffect(tile, eff);
				return;
			}
		}
		if ("DustParticles" in ::Const.Tactical && ::Const.Tactical.DustParticles.len() > 0)
		{
			local st = clone ::Const.Tactical.DustParticles[0];
			st.Brushes <- [_brushName];
			::Tactical.spawnParticleEffect(false, [st], tile, 0, 1, 0, 1);
		}
	}
	catch (_err)
	{
	}
};
"""

# Map existing 35 active skills -> custom `wx_vfx_01..32` brushes!
EXISTING_SKILL_VFX = {
    "wx_sword_combo": "wx_vfx_01",
    "wx_sword_pierce": "wx_vfx_03",
    "wx_sword_counter": "wx_vfx_04",
    "wx_sword_tianwai": "wx_vfx_07",
    "wx_acupoint_strike": "wx_vfx_12",
    "wx_saber_cleave": "wx_vfx_02",
    "wx_saber_sweep": "wx_vfx_06",
    "wx_saber_duanyue": "wx_vfx_05",
    "wx_blood_burst": "wx_vfx_20",
    "wx_spear_guard": "wx_vfx_03",
    "wx_spear_thrust2": "wx_vfx_03",
    "wx_pole_sweep": "wx_vfx_06",
    "wx_staff_challenge": "wx_vfx_14",
    "wx_fist_jab": "wx_vfx_09",
    "wx_fist_shock": "wx_vfx_11",
    "wx_fist_jingang": "wx_vfx_09",
    "wx_fist_acupoint": "wx_vfx_16",
    "wx_fist_disarm": "wx_vfx_15",
    "wx_fist_grapple": "wx_vfx_15",
    "wx_hammer_shatter": "wx_vfx_14",
    "wx_hammer_quake": "wx_vfx_05",
    "wx_axe_split": "wx_vfx_02",
    "wx_axe_whirl": "wx_vfx_06",
    "wx_flail_lash": "wx_vfx_32",
    "wx_flail_entangle": "wx_vfx_31",
    "wx_dagger_vital": "wx_vfx_04",
    "wx_dagger_execute": "wx_vfx_07",
    "wx_shield_bash_qi": "wx_vfx_17",
    "wx_bow_snipe": "wx_vfx_03",
    "wx_throwing_rain": "wx_vfx_27",
    "wx_throw_fan": "wx_vfx_27",
    "wx_smoke_cast": "wx_vfx_25",
    "wx_meditate": "wx_vfx_18",
    "wx_poise_charge": "wx_vfx_22",
    "wx_rally_command": "wx_vfx_23",
}

# ==============================================================================
# 2. +37 NEW WUXIA ACTIVE SKILLS (`35 + 37 = 72` Active Skills!)
# ==============================================================================
# Weapon-based skills: (id, name, desc, ap, qi, min_r, max_r, weapons_list, direct_mult, vfx, extra_props_code, post_hit_code, custom_use_mode)
NEW_WEAPON_ACTIVES = [
    # --- 剑宗绝艺 (6) ---
    ("wx_sword_zhongjian", "重剑无锋劈", "大巧不工重剑式：消耗 6 AP 与 26 内息，以浑厚内劲运剑如锤重砸敌甲（破甲伤害 +40%，命中致目标失衡）。",
     6, 26, 1, 1, '["Sword"]', "0.25", "wx_vfx_05",
     "_properties.DamageArmorMult *= 1.40; _properties.DamageTotalMult *= 1.12;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");', "melee"),

    ("wx_sword_duoming", "夺命三仙剑", "西岳险峻奇快连环剑：消耗 5 AP 与 22 内息，剑光如电抢刺咽喉（命中 +10，暴击击头率 +15%）。",
     5, 22, 1, 1, '["Sword"]', "0.32", "wx_vfx_04",
     "_properties.MeleeSkill += 10; _properties.HitChance[::Const.BodyPart.Head] += 15; _properties.DamageTotalMult *= 1.10;",
     "", "melee"),

    ("wx_sword_cuixin", "松风摧心刺", "青城阴狠绝命快剑：消耗 4 AP 与 18 内息，专刺受伤残敌心脉（目标气血不满时总伤 +25%，并留流血破绽）。",
     4, 18, 1, 1, '["Sword"]', "0.35", "wx_vfx_01",
     "if (_targetEntity != null && _targetEntity.getHitpoints() < _targetEntity.getHitpointsMax()) _properties.DamageTotalMult *= 1.25;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");', "melee"),

    ("wx_sword_taiji", "两仪化劲剑", "玄门圆转借力剑诀：消耗 5 AP 与 20 内息，剑圈粘连化去来劲（命中 +8，震散对手锐气致其散劲虚弱）。",
     5, 20, 1, 1, '["Sword"]', "0.28", "wx_vfx_15",
     "_properties.MeleeSkill += 8;",
     'this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");', "melee"),

    ("wx_sword_feixian", "天河落星剑", "名门越步飞剑绝技：消耗 6 AP 与 28 内息，剑芒吞吐越过前排直刺 2 格之敌（命中 +8，穿甲 +15%）。",
     6, 28, 1, 2, '["Sword"]', "0.38", "wx_vfx_08",
     "_properties.MeleeSkill += 8; _properties.DamageDirectAdd += 0.15; _properties.DamageTotalMult *= 1.15;",
     "", "melee"),

    ("wx_sword_dugu", "破刃荡剑式", "专破天下兵刃守势之妙着：消耗 5 AP 与 24 内息，挑荡敌手兵刃架势（命中解除盾墙/枪阵/反击并留破绽）。",
     5, 24, 1, 1, '["Sword"]', "0.32", "wx_vfx_07",
     "_properties.MeleeSkill += 10;",
     'local tsk = target.getSkills(); if (tsk != null) { tsk.removeByID("effects.shieldwall"); tsk.removeByID("effects.spearwall"); tsk.removeByID("effects.riposte"); tsk.removeByID("effects.wx_status_counter_stance"); } this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");', "melee"),

    # --- 刀门霸斩 (5) ---
    ("wx_saber_kuangfeng", "狂风快刀斩", "大漠狂风骤雨刀路：消耗 4 AP 与 16 内息，顺风疾劈（命中 +6，伤血必令非尸傀目标割裂流血）。",
     4, 16, 1, 1, '["Cleaver", "Sword"]', "0.25", "wx_vfx_01",
     "_properties.MeleeSkill += 6;",
     'if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect");', "melee"),

    ("wx_saber_ranmu", "燃木烈阳劈", "禅门至阳刚猛刀罡：消耗 6 AP 与 26 内息，刀风炽烈如火焚木（破甲 +35%，命中震慑目标军心检定）。",
     6, 26, 1, 1, '["Cleaver", "Sword"]', "0.28", "wx_vfx_02",
     "_properties.DamageArmorMult *= 1.35; _properties.DamageTotalMult *= 1.15;",
     'if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -10);', "melee"),

    ("wx_saber_xuehai", "修罗饮血斩", "凶厉魔道血刀绝技：消耗 5 AP 与 22 内息，自身伤势愈重刀威愈盛，斩中血肉可汲取生机回复最多 12 点气血。",
     5, 22, 1, 1, '["Cleaver", "Sword"]', "0.32", "wx_vfx_06",
     'local actor = this.getContainer().getActor(); if (actor != null && actor.getHitpointsMax() > 0) { local lost = 1.0 - (actor.getHitpoints() / (actor.getHitpointsMax() * 1.0)); _properties.DamageTotalMult *= (1.05 + lost * 0.35); }',
     'if (!::Wuxia.CombatRules.isUndeadOrConstruct(target) && _user.isAlive()) _user.setHitpoints(::Math.min(_user.getHitpointsMax(), _user.getHitpoints() + 10));', "melee"),

    ("wx_saber_fanzhen", "两仪合璧斩", "正派双刀呼应阵斩：消耗 5 AP 与 20 内息，身旁有同袍并肩作战时命中 +12、额外穿甲 +15%。",
     5, 20, 1, 1, '["Cleaver", "Sword"]', "0.30", "wx_vfx_07",
     'local u = this.getContainer().getActor(); if (u != null && u.isPlacedOnMap() && u.getTile().hasNextTile(::Const.Direction.N)) { _properties.MeleeSkill += 10; _properties.DamageDirectAdd += 0.14; }',
     "", "melee"),

    ("wx_saber_modao", "陌刀碎骑斩", "唐宋军阵重型长刀绝杀：消耗 6 AP 与 28 内息，两格纵劈重创敌阵（总伤 +20%，并可将目标硬生生劈退一格）。",
     6, 28, 1, 2, '["Cleaver", "Sword"]', "0.30", "wx_vfx_05",
     "_properties.DamageTotalMult *= 1.20; _properties.DamageArmorMult *= 1.20;",
     "this.wxTryKnockback(_user, target);", "melee"),

    # --- 枪戟棍棒长兵 (5) ---
    ("wx_spear_liuhua", "梨花暴雨枪", "将门快枪攒刺绝艺：消耗 5 AP 与 22 内息，枪花如梨花瑞雪笼罩两格敌身（命中 +10，必留破绽）。",
     5, 22, 1, 2, '["Spear", "Polearm"]', "0.30", "wx_vfx_03",
     "_properties.MeleeSkill += 10; _properties.DamageTotalMult *= 1.10;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");', "melee"),

    ("wx_spear_bawang", "霸王挑山枪", "刚猛绝伦军阵霸枪：消耗 6 AP 与 26 内息，大枪自下而上猛挑两格敌手（总伤 +20%，击退目标并震至失衡）。",
     6, 26, 1, 2, '["Spear", "Polearm"]', "0.32", "wx_vfx_05",
     "_properties.DamageTotalMult *= 1.20; _properties.DamageArmorMult *= 1.20;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); this.wxTryKnockback(_user, target);', "melee"),

    ("wx_pole_fangtian", "画戟月牙斩", "方天长戟月牙钩劈：消耗 6 AP 与 28 内息，专破重甲头颈（两格射程，破甲 +30%，击头率 +12%）。",
     6, 28, 1, 2, '["Polearm", "Spear", "Axe"]', "0.32", "wx_vfx_02",
     "_properties.DamageArmorMult *= 1.30; _properties.HitChance[::Const.BodyPart.Head] += 12; _properties.DamageTotalMult *= 1.12;",
     "", "melee"),

    ("wx_pole_goulian", "钩镰锁足拽", "破骑钩镰长兵秘技：消耗 5 AP 与 20 内息，自两格外钩住敌腿硬拽至身前并令其失衡。",
     5, 20, 1, 2, '["Polearm", "Spear"]', "0.26", "wx_vfx_31",
     "_properties.MeleeSkill += 8;",
     'this.wxTryPullToAdjacent(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");', "melee"),

    ("wx_staff_dagou", "绊字缠足杖", "丐门竹棒三十六路精髓：消耗 4 AP 与 18 内息，棒影贴地横扫脚踝（命中 +12，令对手失衡并损内息）。",
     4, 18, 1, 2, '["Staff", "Mace", "Polearm"]', "0.28", "wx_vfx_15",
     "_properties.MeleeSkill += 12;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 10));', "melee"),

    # --- 拳掌指爪 (6, strictly Fist paired gauntlets!) ---
    ("wx_fist_xianglong", "亢龙有悔掌", "天下至刚阳掌绝诣：消耗 6 AP 与 28 内息，掌力吐出三分留七分，刚猛透甲（总伤 +25%，穿甲 +20%，并震退敌手）。",
     6, 28, 1, 1, '["Fist"]', "0.48", "wx_vfx_09",
     "_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.25; _properties.DamageDirectAdd += 0.20;",
     'this.wxTryKnockback(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");', "melee"),

    ("wx_fist_xuanming", "玄冥寒毒掌", "西域苦寒阴毒奇掌：消耗 5 AP 与 24 内息，掌风奇寒彻骨冻结真元（穿甲 +15%，追加寒毒蚀脉与内息凝滞）。",
     5, 24, 1, 1, '["Fist"]', "0.42", "wx_vfx_10",
     "_properties.MeleeSkill += 6; _properties.DamageDirectAdd += 0.15;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 14));', "melee"),

    ("wx_fist_yiyang", "一阳贯脉指", "南诏皇室纯阳点穴绝学：消耗 5 AP 与 24 内息，凝全身纯阳真气于食指隔空两格点穴（命中 +12，极高穿甲并封脉点穴）。",
     5, 24, 1, 2, '["Fist"]', "0.52", "wx_vfx_12",
     "_properties.MeleeSkill += 12; _properties.DamageDirectAdd += 0.20;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");', "melee"),

    ("wx_fist_jiuyin", "九阴摧心爪", "阴狠诡奇五指利爪：消耗 4 AP 与 20 内息，五指如钩直扣天灵与心口（击头率 +20%，伤血致深创流血）。",
     4, 20, 1, 1, '["Fist"]', "0.40", "wx_vfx_13",
     "_properties.MeleeSkill += 8; _properties.HitChance[::Const.BodyPart.Head] += 20; _properties.DamageTotalMult *= 1.12;",
     'if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect");', "melee"),

    ("wx_fist_qishang", "七伤总诀拳", "一拳既出七股刚柔暗劲齐发：消耗 5 AP 与 22 内息，自震 4 点气血催发霸拳（总伤 +30%，附内伤与破绽）。",
     5, 22, 1, 1, '["Fist"]', "0.45", "wx_vfx_11",
     "_properties.DamageTotalMult *= 1.30; _properties.DamageDirectAdd += 0.15;",
     'if (_user.getHitpoints() > 6) _user.setHitpoints(_user.getHitpoints() - 4); this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury"); this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");', "melee"),

    ("wx_fist_taiji", "揽雀借力掌", "四两拨千斤太极推手：消耗 4 AP 与 16 内息，圆转卸力推震来敌（命中 +12，震退目标并致散劲虚弱）。",
     4, 16, 1, 1, '["Fist"]', "0.35", "wx_vfx_15",
     "_properties.MeleeSkill += 12;",
     'this.wxTryKnockback(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");', "melee"),

    # --- 重兵奇门与盾卫 (5) ---
    ("wx_hammer_leiting", "雷霆碎岳锤", "万钧重兵破甲绝杀：消耗 6 AP 与 28 内息，挟风雷之威猛砸重铠（破甲伤害 +50%，并震荡目标内腑）。",
     6, 28, 1, 1, '["Hammer", "Mace"]', "0.38", "wx_vfx_14",
     "_properties.DamageArmorMult *= 1.50; _properties.DamageTotalMult *= 1.15;",
     'this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury"); this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");', "melee"),

    ("wx_axe_kaishan", "旋风开山斩", "绿林霸主巨斧劈山式：消耗 6 AP 与 26 内息，力劈华山无坚不摧（总伤 +22%，破甲 +25%）。",
     6, 26, 1, 1, '["Axe"]', "0.32", "wx_vfx_02",
     "_properties.DamageTotalMult *= 1.22; _properties.DamageArmorMult *= 1.25;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");', "melee"),

    ("wx_whip_suohou", "灵蛇锁喉鞭", "三格软鞭绕盾奇袭：消耗 5 AP 与 20 内息，鞭梢如毒蛇吐信绕过盾牌抽击咽喉（三格射程，击头率 +15%，附流血）。",
     5, 20, 1, 3, '["Flail", "Cleaver"]', "0.30", "wx_vfx_32",
     "_properties.MeleeSkill += 8; _properties.HitChance[::Const.BodyPart.Head] += 15;",
     'if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect");', "melee"),

    ("wx_dagger_fuxue", "透骨分筋刺", "贴身短匕认穴绝杀：消耗 4 AP 与 18 内息，对已露破绽、失衡或被封穴之敌命中 +18、穿甲 +22%。",
     4, 18, 1, 1, '["Dagger"]', "0.45", "wx_vfx_07",
     'if (_targetEntity != null) { local sk = _targetEntity.getSkills(); if (sk != null && (sk.hasSkill("effects.wx_status_opening") || sk.hasSkill("effects.wx_status_offbalance") || sk.hasSkill("effects.wx_status_acupoint") || sk.hasSkill("effects.stunned"))) { _properties.MeleeSkill += 18; _properties.DamageDirectAdd += 0.22; _properties.DamageTotalMult *= 1.20; } }',
     "", "melee"),

    # --- 弓弩火器与唐门暗器 (4) ---
    ("wx_bow_liuxing", "流星连珠箭", "塞外神射快箭绝技：消耗 4 AP 与 18 内息，搭箭如流星赶月疾射敌阵（远射命中 +8，射程 2 至 6 格）。",
     4, 18, 2, 6, '["Bow"]', "0.35", "wx_vfx_03",
     "_properties.RangedSkill += 8; _properties.DamageTotalMult *= 1.08;",
     "", "bow"),

    ("wx_crossbow_shenji", "神机透甲矢", "官军神机劲弩攒射：消耗 5 AP 与 20 内息，铁矢贯透重铠护心镜（穿甲 +20%，破甲 +25%）。",
     5, 20, 2, 6, '["Crossbow", "Bow"]', "0.50", "wx_vfx_29",
     "_properties.RangedSkill += 8; _properties.DamageDirectAdd += 0.20; _properties.DamageArmorMult *= 1.25;",
     "", "bow"),

    ("wx_throw_pilidan", "霹雳雷火弹", "蜀中唐门火器秘宝：消耗 5 AP 与 26 内息，掷出硫磺铁蒺藜雷火弹轰碎目标护甲并震慑定力。",
     5, 26, 2, 4, '["Throwing"]', "0.38", "wx_vfx_29",
     "_properties.RangedSkill += 10; _properties.DamageArmorMult *= 1.45; _properties.DamageTotalMult *= 1.20;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -12);', "throw"),

    ("wx_throw_duzhen", "五毒丧门钉", "南疆唐门喂毒暗器：消耗 4 AP 与 18 内息，悄无声息射出碧璘毒钉（命中 +12，令血肉之躯中奇毒蚀血损气）。",
     4, 18, 2, 4, '["Throwing"]', "0.42", "wx_vfx_28",
     "_properties.RangedSkill += 12;",
     'this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");', "throw"),
]

# 7 Non-weapon / Stance / Qinggong / Neigong / Tactics / Shield active skills!
SPECIAL_ACTIVES_FILES = {
    "wx_shield_tiebi": """// Active Skill: 不动明王盾架 (Shield Wall + Knockback Immunity, 4 AP, 18 Qi)
this.wx_shield_tiebi <- this.inherit("scripts/skills/skill", {
	m = { ActiveGuard = false, UsedThisTurn = false, WX_VfxBrush = "wx_vfx_17" },
	function create()
	{
		this.m.ID = "actives.wx_shield_tiebi";
		this.m.Name = "不动明王盾";
		this.m.Description = "前排刀盾护卫守线绝技：消耗 4 AP 与 18 内息（需副手持藤牌或铁盾），沉肩立盾使近防 +15、远防 +15 且免疫击退抓取，持续至下回合开始。";
		this.m.Icon = "skills/wx_shield_tiebi.png";
		this.m.IconDisabled = "skills/wx_shield_tiebi_sw.png";
		this.m.Overlay = "active_14";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function hasShield()
	{
		local a = this.getContainer() == null ? null : this.getContainer().getActor();
		if (a == null || a.getItems() == null) return false;
		local off = a.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
		return off != null && off.isItemType(::Const.Items.ItemType.Shield);
	}
	function isHidden() { return this.skill.isHidden() || !this.hasShield(); }
	function isUsable() { return !this.m.UsedThisTurn && this.skill.isUsable() && this.hasShield(); }
	function onUpdate( _properties )
	{
		if (this.m.ActiveGuard)
		{
			_properties.MeleeDefense += 15;
			_properties.RangedDefense += 15;
			_properties.IsImmuneToKnockBackAndGrab = true;
		}
	}
	function onTurnStart() { this.m.ActiveGuard = false; this.m.UsedThisTurn = false; }
	function onCombatStarted() { this.m.ActiveGuard = false; this.m.UsedThisTurn = false; }
	function onCombatFinished() { this.m.ActiveGuard = false; this.m.UsedThisTurn = false; }
	function onUse( _user, _targetTile )
	{
		this.m.ActiveGuard = true;
		this.m.UsedThisTurn = true;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		this.getContainer().update();
		return true;
	}
});
""",
    "wx_qinggong_lingbo": """// Active Skill: 凌波腾挪步 (Qinggong Footwork disengage, 3 AP, 18 Qi)
this.wx_qinggong_lingbo <- this.inherit("scripts/skills/actives/footwork", {
	m = { WX_VfxBrush = "wx_vfx_25" },
	function create()
	{
		this.footwork.create();
		this.m.ID = "actives.wx_qinggong_lingbo";
		this.m.Name = "凌波腾挪步";
		this.m.Description = "上乘轻功脱围身法：消耗 3 AP 与 18 内息，循八卦方位轻灵滑入相邻空位，完全无视敌军控制区截击！";
		this.m.Icon = "skills/wx_qinggong_lingbo.png";
		this.m.IconDisabled = "skills/wx_qinggong_lingbo_sw.png";
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 18;
	}
	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		return this.footwork.onUse(_user, _targetTile);
	}
});
""",
    "wx_qinggong_zongyue": """// Active Skill: 梯云纵跃步 (Qinggong 2-tile tactical vault, 4 AP, 22 Qi, 2-turn cooldown)
this.wx_qinggong_zongyue <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_26" },
	function create()
	{
		this.m.ID = "actives.wx_qinggong_zongyue";
		this.m.Name = "梯云纵跃步";
		this.m.Description = "武林绝顶提纵轻功：消耗 4 AP 与 22 内息，拔地纵跃跨入 2 格内空地抢占高地或切入敌后（冷却 2 回合）。";
		this.m.Icon = "skills/wx_qinggong_zongyue.png";
		this.m.IconDisabled = "skills/wx_qinggong_zongyue_sw.png";
		this.m.Overlay = "active_25";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.MaxLevelDifference = 2;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local a = this.getContainer().getActor();
		return a != null && !a.getCurrentProperties().IsRooted;
	}
	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile)) return false;
		return _targetTile.IsEmpty && !_targetTile.IsOccupiedByActor && ::Math.abs(_originTile.Level - _targetTile.Level) <= 2;
	}
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		::Tactical.getNavigator().teleport(_user, _targetTile, null, null, false);
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		return true;
	}
});
""",
    "wx_neigong_jinzhong": """// Active Skill: 金钟护体罡 (Heavy HengLian / Yang Neigong Indomitable Bell, 4 AP, 24 Qi)
this.wx_neigong_jinzhong <- this.inherit("scripts/skills/skill", {
	m = { ActiveBell = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_17" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_jinzhong";
		this.m.Name = "金钟护体罡";
		this.m.Description = "阳刚横练沉岳绝技：消耗 4 AP 与 24 内息，周身鼓荡梵钟护体金罡，至下回合开始前所受气血与护甲伤害减免 35%，且免疫震晕与击退（冷却 2 回合）。";
		this.m.Icon = "skills/wx_neigong_jinzhong.png";
		this.m.IconDisabled = "skills/wx_neigong_jinzhong_sw.png";
		this.m.Overlay = "active_104";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 24;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable() { return this.m.Cooldown <= 0 && !this.m.ActiveBell && this.skill.isUsable(); }
	function onUpdate( _properties )
	{
		if (this.m.ActiveBell)
		{
			_properties.DamageReceivedRegularMult *= 0.65;
			_properties.DamageReceivedArmorMult *= 0.65;
			_properties.IsImmuneToStun = true;
			_properties.IsImmuneToKnockBackAndGrab = true;
		}
	}
	function onTurnStart() { this.m.ActiveBell = false; if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.ActiveBell = false; this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.ActiveBell = false; this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.ActiveBell = true;
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		this.getContainer().update();
		return true;
	}
});
""",
    "wx_neigong_xixing": """// Active Skill: 北冥噬气诀 (Evil/Harmony Qi Siphon Touch, 4 AP, 12 Qi, 2-turn cooldown)
this.wx_neigong_xixing <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_19" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_xixing";
		this.m.Name = "北冥噬气诀";
		this.m.Description = "奇门导气秘术：消耗 4 AP 与 12 内息，掌心吐纳气璇强行抽散近身活人目标 18 点内息并导引 14 点归入自身丹田（冷却 2 回合）。";
		this.m.Icon = "skills/wx_neigong_xixing.png";
		this.m.IconDisabled = "skills/wx_neigong_xixing_sw.png";
		this.m.Overlay = "active_103";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 12;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable() { return this.m.Cooldown <= 0 && this.skill.isUsable(); }
	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile)) return false;
		local t = _targetTile.getEntity();
		return t != null && !this.getContainer().getActor().isAlliedWith(t) && !::Wuxia.CombatRules.isUndeadOrConstruct(t);
	}
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		if (target == null) return false;
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 18));
		::Wuxia.CombatRules.restoreQi(_user, 14);
		return true;
	}
});
""",
    "wx_tactics_shihou": """// Active Skill: 金刚狮子吼 (2-tile AoE Sonic Morale Shock, 5 AP, 28 Qi, 2-turn cooldown)
this.wx_tactics_shihou <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_23" },
	function create()
	{
		this.m.ID = "actives.wx_tactics_shihou";
		this.m.Name = "金刚狮子吼";
		this.m.Description = "禅门无上音功：消耗 5 AP 与 28 内息，吐气发声如晴空霹雳，令周身 2 格内全体敌军承受战意动摇检定并陷入失衡（冷却 2 回合）。";
		this.m.Icon = "skills/wx_tactics_shihou.png";
		this.m.IconDisabled = "skills/wx_tactics_shihou_sw.png";
		this.m.Overlay = "active_49";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 28;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable() { return this.m.Cooldown <= 0 && this.skill.isUsable(); }
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local myTile = _user.getTile();
		::Wuxia.VFX.playSkillVfx(this, _user, myTile, this.m.WX_VfxBrush);
		local pen = -8 - ::Math.floor(_user.getBravery() * 0.12);
		foreach (ent in ::Tactical.Entities.getAllInstancesAsArray())
		{
			if (ent == null || !ent.isAlive() || !ent.isPlacedOnMap() || _user.isAlliedWith(ent)) continue;
			if (myTile.getDistanceTo(ent.getTile()) <= 2)
			{
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(ent)) ent.checkMorale(-1, pen);
				local sk = ent.getSkills();
				if (sk != null && !sk.hasSkill("effects.wx_status_offbalance"))
					sk.add(::new("scripts/skills/effects/wx_status_offbalance"));
			}
		}
		return true;
	}
});
""",
    "wx_tactics_jinzhen": """// Active Skill: 金针渡穴诀 (Medical Acupressure Stop-Bleed/Detox/Heal, 5 AP, 22 Qi, 2-turn cooldown)
this.wx_tactics_jinzhen <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_22" },
	function create()
	{
		this.m.ID = "actives.wx_tactics_jinzhen";
		this.m.Name = "金针渡穴诀";
		this.m.Description = "杏林医家济世奇术：消耗 5 AP 与 22 内息，为自身或相邻同袍施针止血、拔除奇毒封穴，并稳固 14 点气血（冷却 2 回合）。";
		this.m.Icon = "skills/wx_tactics_jinzhen.png";
		this.m.IconDisabled = "skills/wx_tactics_jinzhen_sw.png";
		this.m.Overlay = "active_22";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 0;
		this.m.MaxRange = 1;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable() { return this.m.Cooldown <= 0 && this.skill.isUsable(); }
	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile)) return false;
		local t = _targetTile.getEntity();
		return t != null && this.getContainer().getActor().isAlliedWith(t) && !::Wuxia.CombatRules.isUndeadOrConstruct(t);
	}
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		if (target == null) return false;
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local sk = target.getSkills();
		if (sk != null)
		{
			sk.removeByID("effects.bleeding");
			sk.removeByID("effects.spider_poison");
			sk.removeByID("effects.goblin_poison");
			sk.removeByID("effects.wx_status_poison_dart");
			sk.removeByID("effects.wx_status_acupoint");
			local injury = sk.getSkillByID("effects.wx_internal_injury"); if (injury != null) injury.cureTemporary();
		}
		target.setHitpoints(::Math.min(target.getHitpointsMax(), target.getHitpoints() + 14));
		return true;
	}
});
"""
}

# ==============================================================================
# 3. +16 NEW SHAN HAI JING APEX BOSSES (`49..64` -> Total 64!)
# ==============================================================================
NEW_SHANHAI_16 = [
    ("kaiming", "海内西经", "【山海镇神】昆仑虚·九首开明兽", "Unhold", "Unhold", "scripts/entity/tactical/enemies/unhold_armored",
     1.50, 14, 14, 65, 58, "九首环伺·镇守帝门", "《海内西经》昆仑百神门主：身大类虎而九首人面，免疫爆头、眩晕与围攻近防惩罚，每回合自愈 20 气血且挥爪震退来敌！",
     "{ SteelBrow = true, Underdog = true, RegenHP = 20, BonusMSkill = 12, BonusMDef = 12, OnHitOffbalance = true }",
     "【山海内丹】昆仑开明九首虎魄丹", 2450, "流转昆仑金芒的九窍虎神宝丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】昆仑九井百神门", "上古昆仑虚东向石门遗迹，虎身九首人面的开明神兽矗立玉阶，百兵围攻亦难觅其死角！",
     "world_ancient_temple", "Beasts", '["boss_kaiming", "Unhold", "Unhold", "Direwolf", "Direwolf"]', "wx_manual_taixu", "wx_manual_xuanwu_budong"),

    ("jinwu", "大荒东经", "【山海神禽】汤谷扶桑·三足金乌皇", "Vampire", "Vampire", "scripts/entity/tactical/enemies/vampire",
     2.45, 16, 16, 70, 58, "十日耀天·大日焚甲罡", "《大荒东经》扶桑神木之主：三足金鸦浴火瞬移，周身 2 格大日真火每回合灼毁敌军 15 点身甲并蒸干 10 点内息！",
     "{ MinAP = 10, BonusInit = 32, BonusMDef = 16, BonusRDef = 22, AuraRadius = 2, AuraArmorDmg = 15, AuraFatigue = 10 }",
     "【山海内丹】汤谷三足金乌大日真丹", 2550, "炽白夺目如小太阳般滚烫的神鸦火丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】汤谷扶桑焦木坛", "黑齿国北沸水海谷，焦赤扶桑巨木之巅栖息三足金乌皇，酷烈阳火令重甲武士未战先竭！",
     "world_desert_ruins_02", "Undead", '["boss_jinwu", "Vampire", "Vampire", "Ghost", "Ghost"]', "wx_manual_dari_rulai", "wx_manual_jiuyang"),

    ("zouyu", "海内北经", "【山海仁瑞】林氏国·五采驺虞王", "Hyena", "Hyena", "scripts/entity/tactical/enemies/hyena_high",
     3.45, 18, 16, 65, 54, "日行千里·五采仁威", "《海内北经》尾长于身之五采神虎：常驻 11 AP、极速先手，每回合首杀回返 3 AP，利爪撕裂护甲并令恶徒动摇！",
     "{ MinAP = 11, BonusInit = 38, BonusMSkill = 14, BonusMDef = 14, KillRefundAP = 3, OnHitBleed = 10 }",
     "【山海内丹】林氏五采驺虞瑞虎丸", 2250, "五色祥光萦绕的灵虎内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】林氏五色竹海涧", "异竹丛生、云霞流转的幽深山涧，尾长于身的五采驺虞王瞬息千里试炼入山豪杰。",
     "world_cave_steppe_01", "Beasts", '["boss_zouyu", "Hyena", "Hyena", "Direwolf", "Direwolf"]', "wx_manual_shenxing_baibian", "wx_manual_taxue"),

    ("gonggong", "大荒西经", "【山海古神】不周山·共工怒涛水煞", "Lindwurm", "Unhold", "scripts/entity/tactical/enemies/lindwurm",
     1.45, 12, 10, 75, 66, "怒触不周·天倾黑水潮", "《大荒西经》赤发人面蛇身水神遗煞：免疫爆头与点穴，周身 2 格黑水寒潮每回合侵蚀 8 点气血并封锁敌军内息！",
     "{ SteelBrow = true, BonusMSkill = 12, BonusMDef = 10, AuraRadius = 2, AuraHpDmg = 8, AuraFatigue = 10, OnHitAcupoint = true }",
     "【山海内丹】不周共工天倾黑水珠", 2600, "沉重如万钧寒渊之水的赤纹玄珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】不周折柱寒潮渊", "天柱倾折、黑水倒灌的上古绝渊，赤发蛇身的共工水煞盘踞断崖掀起滔天寒浪！",
     "world_buried_castle", "Beasts", '["boss_gonggong", "Lindwurm", "UnholdBog", "Serpent", "Serpent"]', "wx_manual_beiming", "wx_manual_shanhai_zhuyin"),

    ("wuluo", "中山经", "【山海神女】青要山·豹纹武罗妖神", "Hexe", "Hexe", "scripts/entity/tactical/enemies/hexe",
     3.60, 14, 18, 65, 56, "穿耳金鐻·青要摄魂歌", "《中山经》帝之密都神女：人面豹纹小腰白齿，鸣玉环摄夺敌军心魄，高额身法避暗并魅惑前排猛士自相残杀！",
     "{ BonusInit = 26, BonusMDef = 20, BonusRDef = 30, RegularMult = 0.65, AuraRadius = 3, AuraResolveOffbalance = true }",
     "【山海内丹】青要武罗鸣玉魅神珠", 2200, "清脆铮鸣如佩环相击的斑斓宝珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】青要畛水女神祠", "水鸟百族栖息的青要秘谷古祠，豹纹神女武罗吟唱古歌，心志微摇者立堕幻境！",
     "world_ancient_statue", "Beasts", '["boss_wuluo", "Hexe", "Alp", "Alp", "Direwolf", "Direwolf"]', "wx_manual_lingbo", "wx_manual_jiuyin_baigu"),

    ("siwang", "海内南经", "【山海凶兽】苍梧野·独角青兕王", "Unhold", "Unhold", "scripts/entity/tactical/enemies/unhold_armored",
     1.55, 14, 10, 60, 58, "苍兕裂甲·重角破城冲", "《海内南经》苍黑一角重甲巨兽：铜头铁额减免远射伤害三成，重角顶撞直接碎裂护甲并震飞盾卫！",
     "{ SteelBrow = true, RangedMult = 0.70, BonusMSkill = 14, BonusMDef = 10, OnHitArmorBurn = 22, OnHitOffbalance = true }",
     "【山海内丹】苍梧独角青兕镇岳丹", 2300, "青黑厚重如古铁锭的巨兕内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】苍梧断盾铁角原", "古松折断、重铠凹陷的苍梧荒原，重逾千钧的独角青兕王低首蓄势，铁壁盾阵亦难正面撄锋！",
     "world_bandit_camp_03", "Orcs", '["boss_siwang", "OrcWarrior", "OrcWarrior", "OrcBerserker", "Unhold"]', "wx_manual_jinzhong", "wx_manual_jiuyao_pocheng"),

    ("jiufeng", "大荒北经", "【山海妖皇】大荒北极·九首鬼车九凤", "Vampire", "Vampire", "scripts/entity/tactical/enemies/vampire",
     2.50, 16, 16, 70, 58, "九首泣血·北极摄魂瘴", "《大荒北经》北极人面九首妖禽：夜影瞬移噬血回春，每次扑击吸取 30 点气血并散播泣血奇瘴动摇军心！",
     "{ MinAP = 10, BonusInit = 28, BonusMDef = 16, OnHitDrainHP = 30, OnHitBleed = 10, AuraRadius = 3, AuraResolveOffbalance = true }",
     "【山海内丹】北极九凤泣血妖皇珠", 2500, "九道赤黑血丝盘旋流转的妖皇内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】大荒鬼国九首栖魔崖", "阴风惨惨不见天日的北极绝壁，九首人面的九凤妖皇展翅遮月，滴血化作妖邪鬼影！",
     "world_crypt_02", "Undead", '["boss_jiufeng", "Vampire", "Vampire", "Alp", "Ghost"]', "wx_manual_xuedao_jing", "wx_manual_tianmo_jieti"),

    ("mingshe", "中山经", "【山海凶蟒】鲜山·四翼磐音鸣蛇", "Serpent", "Serpent", "scripts/entity/tactical/enemies/serpent",
     3.15, 15, 14, 60, 54, "其音如磬·四翼旱雷震", "《中山经》蛇身四翼奇蟒：翼振声如古磬震裂耳膜，周身 2 格散播燥热音障削耗内息，噬咬附剧毒与失衡！",
     "{ BonusInit = 28, BonusMSkill = 14, BonusMDef = 14, AuraRadius = 2, AuraFatigue = 9, AuraResolveOffbalance = true, OnHitPoison = true }",
     "【山海内丹】鲜山四翼鸣蛇磬音胆", 2150, "轻叩即发金石清磬之音的赤金蛇胆，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】鲜山金玉旱鸣窟", "草木枯焦而金玉裸露的鲜山石窟，生有四翼的鸣蛇盘旋洞顶，磬音未落毒牙已至！",
     "world_desert_ruins_01", "Beasts", '["boss_mingshe", "Serpent", "Serpent", "Serpent", "Lindwurm"]', "wx_manual_jinshe_jian", "wx_manual_chansi_bian"),

    ("huashe", "中山经", "【山海凶蛟】阳山·人面鸟翼化蛇", "Lindwurm", "Unhold", "scripts/entity/tactical/enemies/lindwurm",
     1.38, 12, 12, 60, 62, "见则大水·寒渊翼蛟噬", "《中山经》人面豺身鸟翼蛇行大妖：寒水鳞甲减免远射，挥尾横扫封锁经脉并抽取近身敌手 12 点内息！",
     "{ BonusMSkill = 12, BonusMDef = 12, BonusRDef = 18, RangedMult = 0.72, OnHitDrainQi = 12, OnHitAcupoint = true }",
     "【山海内丹】阳山鸟翼化蛇玄水珠", 2250, "幽蓝寒气凝聚不散的异蛟水丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】阳山浊水淹城墟", "洪水漫溢的古镇废墟，人面鸟翼的化蛇潜行断垣浊浪之间，专断渡水行旅生路！",
     "world_cave_01", "Beasts", '["boss_huashe", "Lindwurm", "UnholdBog", "Serpent", "Serpent"]', "wx_manual_xuanyin", "wx_manual_baishe_quan"),

    ("fuzhu", "中山经", "【山海异兽】敖岸山·四角白鹿夫诸", "UnholdFrost", "Unhold", "scripts/entity/tactical/enemies/unhold_frost",
     1.45, 14, 16, 60, 54, "四角凝霜·白鹿幻水障", "《中山经》状如白鹿而四角之灵异大妖：高闪避灵动腾跃，每回合自愈 22 气血，霜角挑刺直透重甲并封穴！",
     "{ RegenHP = 22, BonusInit = 25, BonusMSkill = 14, BonusMDef = 16, BonusRDef = 20, OnHitAcupoint = true }",
     "【山海内丹】敖岸四角夫诸霜鹿茸丹", 2150, "洁白莹润如万年寒玉的四角灵鹿内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】敖岸寒溪白鹿林", "白雾终年笼罩的寒溪古林，生有四只玉角的巨大白鹿夫诸踏水无痕，似瑞实凶！",
     "world_ancient_watchtower", "Beasts", '["boss_fuzhu", "UnholdFrost", "Direwolf", "Direwolf", "Alp"]', "wx_manual_taxue", "wx_manual_hanbing_zhenqi"),

    ("chenghuang", "海外西经", "【山海神兽】白民国·背角神狐乘黄", "Hyena", "Hyena", "scripts/entity/tactical/enemies/hyena_high",
     3.35, 16, 18, 65, 54, "寿逾二千·乘黄瑞角反噬", "《海外西经》背生龙角之长寿神狐：常驻 11 AP、极高双防与生机自愈，咬击汲血并令贪功冒进者露破绽！",
     "{ MinAP = 11, RegenHP = 18, BonusInit = 35, BonusMDef = 18, BonusRDef = 20, OnHitDrainHP = 20, OnHitOffbalance = true }",
     "【山海内丹】白民乘黄二千岁寿元丹", 2400, "琥珀金光流淌、馥郁延年的神狐内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】白民古丘乘黄坛", "白石堆砌的西荒古祭丘，背生双角的金色神狐乘黄卧于古柏之下，轻身功夫冠绝大荒。",
     "world_ancient_temple", "Beasts", '["boss_chenghuang", "Hyena", "Hyena", "Direwolf", "Unhold"]', "wx_manual_changsheng_jue", "wx_manual_lingbo"),

    ("dangkang", "东山经", "【山海瑞凶】钦山·巨牙当康兽王", "OrcBerserker", "OrcBerserker", "scripts/entity/tactical/enemies/orc_berserker",
     2.35, 16, 10, 65, 54, "其鸣自叫·巨牙破阵突", "《东山经》状如巨豚而獠牙如刀之猛兽：气血低于七成即狂暴增伤 30%、免疫眩晕，巨牙猛拱连破重甲与战意！",
     "{ SteelBrow = true, EnrageBelowPct = 0.70, EnrageMSkill = 12, EnrageDmgMult = 1.30, EnrageImmuneCC = true, OnHitArmorBurn = 20, OnHitBleed = 10 }",
     "【山海内丹】钦山巨牙当康丰穰髓", 2100, "蕴藏磅礴生机与蛮横气力的青玉兽髓，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】钦山裂岩野猪林", "古树尽被巨牙拱断的钦山密林，自呼其名的巨牙当康王咆哮冲阵，寻常步卒触之即溃！",
     "world_bandit_camp_03", "Orcs", '["boss_dangkang", "OrcBerserker", "OrcBerserker", "OrcWarrior", "Direwolf"]', "wx_manual_tiebushan", "wx_manual_pishan_fu"),

    ("boshi", "南山经", "【山海异兽】基山·背目九尾猼訑", "Unhold", "Unhold", "scripts/entity/tactical/enemies/unhold",
     1.48, 12, 18, 80, 54, "其目在背·著之不畏", "《南山经》九尾四耳背生神目之异兽：背后生眼令一切围攻夹击失效（免围攻惩罚、近防暴涨），且定力如山永不动摇！",
     "{ Underdog = true, SteelBrow = true, BonusMDef = 18, BonusRDef = 16, BonusBravery = 50, RegenHP = 18 }",
     "【山海内丹】基山背目猼訑无畏丹", 2150, "四窍九纹、佩之令人胆气豪壮的奇兽内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】基山奇岩九尾坡", "温玉散落的南山奇坡，九尾四耳、双目长在脊背上的猼訑王静立山巅，十面埋伏亦奈何不得！",
     "world_cave_steppe_01", "Beasts", '["boss_boshi", "Unhold", "Hyena", "Hyena", "Direwolf"]', "wx_manual_juyi_ling", "wx_manual_budong_mingwang"),

    ("jiao", "西山经", "【山海异兽】玉山·豹纹牛角神狡", "Direwolf", "Direwolf", "scripts/entity/tactical/enemies/direwolf_high",
     3.50, 18, 14, 60, 52, "豹文牛角·裂甲噬喉扑", "《西山经》王母玉山异兽：状如巨犬而豹纹牛角，兼具恶狼连扑与重角破甲之威，每击焚毁 16 点护甲并致深创流血！",
     "{ MinAP = 10, BonusInit = 30, BonusMSkill = 16, BonusMDef = 12, OnHitArmorBurn = 16, OnHitBleed = 12 }",
     "【山海内丹】玉山豹纹神狡破甲丸", 2150, "烙有金钱豹纹的赤金兽丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】玉山西王母猎兽谷", "毗邻西王母瑶池的险峻猎谷，生有牛角的豹纹巨犬神狡成群巡猎，专碎重甲护卫咽喉！",
     "world_goblin_camp_03", "Beasts", '["boss_jiao", "Direwolf", "Direwolf", "Direwolf", "Hyena", "Hyena"]', "wx_manual_kuangfeng_dao", "wx_manual_gu_feng"),

    ("bingyi", "海内北经", "【山海河伯】从极渊·御龙冰夷水君", "SkeletonBoss", "SkeletonHeavy", "scripts/entity/tactical/enemies/skeleton_boss",
     2.15, 14, 14, 99, 60, "乘两龙行·从极万古霜", "《海内北经》深渊三百仞河伯古神：免疫点穴奇毒与爆头，周身 2 格万古寒霜每回合冻结敌军 12 点内息并令其失衡！",
     "{ SteelBrow = true, ImmuneStun = true, BonusMSkill = 14, BonusMDef = 14, AuraRadius = 2, AuraFatigue = 12, AuraResolveOffbalance = true, OnHitAcupoint = true }",
     "【山海内丹】从极渊冰夷御龙寒髓", 2500, "冰封两条微缩龙影的万载玄冰神髓，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】从极三百仞冰河宫", "终年冰封千尺的大河深渊古殿，人面乘双龙的冰夷水君端坐玄冰王座，寒气冻彻骨髓！",
     "world_crypt_01", "Undead", '["boss_bingyi", "SkeletonHeavy", "SkeletonHeavy", "UnholdFrost", "Ghost"]', "wx_manual_hanbing_zhenqi", "wx_manual_xuanyin"),

    ("qiangliang", "大荒北经", "【山海尸神】大荒北山·虎首衔蛇强良", "OrcWarlord", "OrcWarlord", "scripts/entity/tactical/enemies/orc_warlord",
     1.85, 16, 12, 85, 62, "虎首衔蛇·北山戮神戈", "《大荒北经》虎首人身四蹄长肘凶神：口衔赤蛇、执掌重戈，半血狂暴总伤 +28%，击中同时注入赤蛇奇毒并每轮首杀返 3 AP！",
     "{ SteelBrow = true, Underdog = true, EnrageBelowPct = 0.55, EnrageDmgMult = 1.28, KillRefundAP = 3, OnHitPoison = true, OnHitBleed = 10 }",
     "【山海内丹】北山强良虎首衔蛇煞丹", 2550, "虎煞刀兵气与赤蛇毒火交织的霸道凶丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。",
     "【山海秘境】大荒北山衔蛇血祭坛", "赤蛇盘柱、巨戈林立的北荒古祭坛，虎首人身的凶神强良咆哮督战，霸烈无匹！",
     "world_fortress_ruins", "Orcs", '["boss_qiangliang", "OrcWarrior", "OrcWarrior", "OrcBerserker", "Serpent", "Serpent"]', "wx_manual_shanhai_chiyou", "wx_manual_bawang_qiang"),
]


def make_weapon_skill_nut(d):
    sid, nm, desc, ap, qi, minr, maxr, wpns, dmult, vfx, props_code, hit_code, mode = d
    props_block = ""
    if props_code:
        props_block = f"""
\tfunction onAnySkillUsed( _skill, _targetEntity, _properties )
\t{{
\t\tif (_skill == this)
\t\t{{
\t\t\t{props_code}
\t\t}}
\t}}
"""
    if mode == "bow":
        atk_line = "local hit = this.wxShootBowAt(_user, target);"
        ranged_setup = "\t\tthis.m.IsRanged = true;\n\t\tthis.m.IsShowingProjectile = true;\n"
    elif mode == "throw":
        atk_line = "local hit = this.wxThrowAt(_user, target);"
        ranged_setup = "\t\tthis.m.IsRanged = true;\n\t\tthis.m.IsShowingProjectile = true;\n"
    else:
        atk_line = "local hit = this.attackEntity(_user, target);"
        ranged_setup = ""

    post_block = ""
    if hit_code:
        post_block = f"""\t\tif (hit && target != null && target.isAlive())
\t\t{{
\t\t\t{hit_code}
\t\t}}
"""
    return f"""// Active Move: {nm}
this.{sid} <- this.inherit("scripts/skills/actives/wx_move_base", {{
\tm = {{}},

\tfunction create()
\t{{
\t\tthis.wx_move_base.create();
\t\tthis.m.ID = "actives.{sid}";
\t\tthis.m.Name = "{nm}";
\t\tthis.m.Description = "{desc}";
\t\tthis.m.Icon = "skills/{sid}.png";
\t\tthis.m.IconDisabled = "skills/{sid}_sw.png";
\t\tthis.m.Overlay = "active_01";
\t\tthis.m.WX_VfxBrush = "{vfx}";
\t\tthis.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
\t\tthis.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
\t\tthis.m.ActionPointCost = {ap};
\t\tthis.m.FatigueCost = {qi};
\t\tthis.m.MinRange = {minr};
\t\tthis.m.MaxRange = {maxr};
{ranged_setup}\t\tthis.m.RequiredWeaponTypes = {wpns};
\t\tthis.m.DirectDamageMult = {dmult};
\t}}
{props_block}
\tfunction onUse( _user, _targetTile )
\t{{
\t\tlocal target = _targetTile.getEntity();
\t\t::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
\t\t{atk_line}
{post_block}\t\treturn hit;
\t}}
}});
"""


def main():
    # 1. Write `wx_vfx_system.nut` & include in `load.nut`
    vfx_sys_path = os.path.join(MOD, "mod_wuxia/systems/wx_vfx_system.nut")
    with open(vfx_sys_path, "w", encoding="utf-8") as f:
        f.write(VFX_SYSTEM_NUT)

    load_p = os.path.join(MOD, "mod_wuxia/load.nut")
    load_txt = open(load_p, "r", encoding="utf-8").read()
    if "wx_vfx_system.nut" not in load_txt:
        load_txt = load_txt.replace(
            '::include("mod_wuxia/systems/combat_rules.nut");',
            '::include("mod_wuxia/systems/combat_rules.nut");\n::include("mod_wuxia/systems/wx_vfx_system.nut");',
            1,
        )
        open(load_p, "w", encoding="utf-8").write(load_txt)

    # 2. Add `WX_VfxBrush = null` to `wx_move_base.nut` & wire existing 35 active skills
    mb_p = os.path.join(MOD, "scripts/skills/actives/wx_move_base.nut")
    mb_txt = open(mb_p, "r", encoding="utf-8").read()
    if "WX_VfxBrush" not in mb_txt:
        mb_txt = mb_txt.replace("InflictChancePct    = 100", "InflictChancePct    = 100,\n\t\tWX_VfxBrush         = null", 1)
        open(mb_p, "w", encoding="utf-8").write(mb_txt)

    for sid, vfx_id in EXISTING_SKILL_VFX.items():
        sp = os.path.join(MOD, f"scripts/skills/actives/{sid}.nut")
        if os.path.exists(sp):
            stxt = open(sp, "r", encoding="utf-8").read()
            if "WX_VfxBrush" not in stxt:
                stxt = re.sub(
                    r'(this\.m\.ID\s*=\s*"actives\.' + sid + r'";)',
                    rf'\1\n\t\tthis.m.WX_VfxBrush = "{vfx_id}";',
                    stxt, count=1
                )
                stxt = re.sub(
                    r'(function onUse\s*\(\s*_user\s*,\s*_targetTile\s*\)\s*\{)',
                    r'\1\n\t\t::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, ("WX_VfxBrush" in this.m) ? this.m.WX_VfxBrush : null);',
                    stxt, count=1
                )
                open(sp, "w", encoding="utf-8").write(stxt)

    # 3. Write all 37 NEW Active Skills!
    all_new_sids = []
    for d in NEW_WEAPON_ACTIVES:
        sid = d[0]
        all_new_sids.append(sid)
        with open(os.path.join(MOD, f"scripts/skills/actives/{sid}.nut"), "w", encoding="utf-8") as f:
            f.write(make_weapon_skill_nut(d))
    for sid, code in SPECIAL_ACTIVES_FILES.items():
        all_new_sids.append(sid)
        with open(os.path.join(MOD, f"scripts/skills/actives/{sid}.nut"), "w", encoding="utf-8") as f:
            f.write(code)

    # 4. Wire new signature moves into matching manuals so manuals have rich unique moves!
    manual_skill_upgrades = [
        ("mod_wuxia/config/manuals/wx_manuals_sword_saber.nut", [
            ("wx_manual_songyang_zhongjian", "actives.wx_sword_pierce", "actives.wx_sword_zhongjian"),
            ("wx_manual_huashan_duoming", "actives.wx_sword_pierce", "actives.wx_sword_duoming"),
            ("wx_manual_qingcheng_songfeng", "actives.wx_sword_pierce", "actives.wx_sword_cuixin"),
            ("wx_manual_taihe_liangyi", "actives.wx_sword_counter", "actives.wx_sword_taiji"),
            ("wx_manual_kunlun_feixian", "actives.wx_sword_pierce", "actives.wx_sword_feixian"),
            ("wx_manual_dugu_jiujian", "actives.wx_sword_pierce", "actives.wx_sword_dugu"),
            ("wx_manual_kuangfeng_dao", "actives.wx_saber_cleave", "actives.wx_saber_kuangfeng"),
            ("wx_manual_ranmu_daofa", "actives.wx_saber_cleave", "actives.wx_saber_ranmu"),
            ("wx_manual_xuedao_jing", "actives.wx_saber_cleave", "actives.wx_saber_xuehai"),
            ("wx_manual_fanliangyi_dao", "actives.wx_saber_cleave", "actives.wx_saber_fanzhen"),
            ("wx_manual_tangjun_modao", "actives.wx_saber_sweep", "actives.wx_saber_modao"),
        ]),
        ("mod_wuxia/config/manuals/wx_manuals_pole_fist.nut", [
            ("wx_manual_yangjia_liuhua", "actives.wx_spear_thrust2", "actives.wx_spear_liuhua"),
            ("wx_manual_bawang_qiang", "actives.wx_spear_thrust2", "actives.wx_spear_bawang"),
            ("wx_manual_fangtian_ji", "actives.wx_pole_sweep", "actives.wx_pole_fangtian"),
            ("wx_manual_goulian_qiang", "actives.wx_pole_sweep", "actives.wx_pole_goulian"),
            ("wx_manual_dagou_bang", "actives.wx_staff_challenge", "actives.wx_staff_dagou"),
            ("wx_manual_xianglong_zhang", "actives.wx_fist_jingang", "actives.wx_fist_xianglong"),
            ("wx_manual_xuanming_shenzhang", "actives.wx_fist_shock", "actives.wx_fist_xuanming"),
            ("wx_manual_yiyang_zhi", "actives.wx_fist_acupoint", "actives.wx_fist_yiyang"),
            ("wx_manual_jiuyin_baigu", "actives.wx_fist_jab", "actives.wx_fist_jiuyin"),
            ("wx_manual_qishang_quan", "actives.wx_fist_shock", "actives.wx_fist_qishang"),
            ("wx_manual_taiji_quan", "actives.wx_fist_disarm", "actives.wx_fist_taiji"),
        ]),
        ("mod_wuxia/config/manuals/wx_manuals_heavy_odd_ranged.nut", [
            ("wx_manual_jiuyao_pocheng", "actives.wx_hammer_shatter", "actives.wx_hammer_leiting"),
            ("wx_manual_pangu_kaitian", "actives.wx_axe_split", "actives.wx_axe_kaishan"),
            ("wx_manual_chansi_bian", "actives.wx_flail_lash", "actives.wx_whip_suohou"),
            ("wx_manual_fuxue_ci", "actives.wx_dagger_vital", "actives.wx_dagger_fuxue"),
            ("wx_manual_liuxing_jian", "actives.wx_bow_snipe", "actives.wx_bow_liuxing"),
            ("wx_manual_shenji_nu", "actives.wx_bow_snipe", "actives.wx_crossbow_shenji"),
            ("wx_manual_pili_tangmen", "actives.wx_throwing_rain", "actives.wx_throw_pilidan"),
            ("wx_manual_wudu_tougu", "actives.wx_throw_fan", "actives.wx_throw_duzhen"),
        ]),
    ]
    for rel_m, swaps in manual_skill_upgrades:
        mp = os.path.join(MOD, rel_m)
        if os.path.exists(mp):
            mtxt = open(mp, "r", encoding="utf-8").read()
            for mid, old_s, new_s in swaps:
                pat = re.compile(rf'(Manuals\.{mid}\s*<-\s*\{{[\s\S]*?\n\}};\s*)')
                m = pat.search(mtxt)
                if m:
                    blk = m.group(1).replace(f'"{old_s}"', f'"{new_s}"')
                    mtxt = mtxt[:m.start(1)] + blk + mtxt[m.end(1):]
            open(mp, "w", encoding="utf-8").write(mtxt)

    # Also grant Qinggong / Neigong / Tactics signature actives on top manuals where empty or fitting!
    for rel_m, mid, new_act in [
        ("mod_wuxia/config/manuals.nut", "wx_manual_lingbo", "actives.wx_qinggong_lingbo"),
        ("mod_wuxia/config/manuals/wx_manuals_qinggong.nut", "wx_manual_tiyun_zong", "actives.wx_qinggong_zongyue"),
        ("mod_wuxia/config/manuals.nut", "wx_manual_jinzhong", "actives.wx_neigong_jinzhong"),
        ("mod_wuxia/config/manuals.nut", "wx_manual_beiming", "actives.wx_neigong_xixing"),
        ("mod_wuxia/config/manuals/wx_manuals_henglian.nut", "wx_manual_shizi_hou", "actives.wx_tactics_shihou"),
        ("mod_wuxia/config/manuals/wx_manuals_henglian.nut", "wx_manual_qingnang_yishu", "actives.wx_tactics_jinzhen"),
        ("mod_wuxia/config/manuals/wx_manuals_henglian.nut", "wx_manual_budong_mingwang", "actives.wx_shield_tiebi"),
    ]:
        mp = os.path.join(MOD, rel_m)
        if os.path.exists(mp):
            mtxt = open(mp, "r", encoding="utf-8").read()
            pat = re.compile(rf'(Manuals\.{mid}\s*=\s*\{{[\s\S]*?\n\t\}},|Manuals\.{mid}\s*<-\s*\{{[\s\S]*?\n\}};)')
            m = pat.search(mtxt)
            if m and new_act not in m.group(1):
                # Add to Tier 2 & Tier 3 GrantSkills = []
                blk = m.group(1)
                blk = re.sub(r'(ExpNeeded\s*=\s*(?:1[4-9]0|[2-9]\d0)[^\n]*?GrantSkills\s*=\s*\[)\]', rf'\1"{new_act}"]', blk)
                mtxt = mtxt[:m.start(1)] + blk + mtxt[m.end(1):]
                open(mp, "w", encoding="utf-8").write(mtxt)

    # 5. Extend AI behaviors (`ai_wuxia_skills.nut`) for new melee/ranged moves
    ai_p = os.path.join(MOD, "mod_wuxia/hooks/ai/tactical/behaviors/ai_wuxia_skills.nut")
    ai_txt = open(ai_p, "r", encoding="utf-8").read()
    if "wx_sword_zhongjian" not in ai_txt:
        melee_add = ', '.join(f'"actives.{d[0]}"' for d in NEW_WEAPON_ACTIVES if d[12] == "melee")
        ranged_add = ', '.join(f'"actives.{d[0]}"' for d in NEW_WEAPON_ACTIVES if d[12] in ("bow", "throw"))
        ai_txt = ai_txt.replace('"actives.wx_shield_bash_qi"', f'"actives.wx_shield_bash_qi",\n\t{melee_add}', 1)
        ai_txt = ai_txt.replace('"actives.wx_smoke_cast"]', f'"actives.wx_smoke_cast", {ranged_add}]', 1)
        open(ai_p, "w", encoding="utf-8").write(ai_txt)

    # 6. Add +16 Shan Hai Jing Apex Bosses (`48 -> 64`)!
    sh_p = os.path.join(MOD, "mod_wuxia/config/wx_shanhai.nut")
    sh_txt = open(sh_p, "r", encoding="utf-8").read()
    enc_p = os.path.join(MOD, "mod_wuxia/config/wx_encounters.nut")
    enc_txt = open(enc_p, "r", encoding="utf-8").read()

    boss_entries = []
    core_entries = []
    lair_entries = []
    for (key, chap, bname, etype, btroop, pscript, hpm, msk, mdf, brv, strg,
         tname, tdesc, mech, cname, cval, cdesc, lname, ldesc, lbrush, ftype, troops, rman, eman) in NEW_SHANHAI_16:
        if f"boss_{key}" not in sh_txt:
            boss_entries.append(f"""\tboss_{key} = {{
\t\tKey = "{key}", BossID = "boss_{key}", Chapter = "{chap}", Name = "{bname}",
\t\tEntityType = "{etype}", BaseTroop = "{btroop}",
\t\tScript = "scripts/entity/tactical/enemies/wx_boss_{key}", ParentScript = "{pscript}",
\t\tHpMult = {hpm:.2f}, MeleeSkillBonus = {msk}, MeleeDefBonus = {mdf}, BraveryBonus = {brv}, Strength = {strg},
\t\tTraitName = "{tname}", TraitDesc = "{tdesc}",
\t\tMechanics = {mech},
\t\tCoreID = "wx_core_{key}", LairID = "shanhai_{key}",
\t\tCustomBodySprite = null, CustomHeadSprite = null
\t}},""")
            core_entries.append(f"""\twx_core_{key} = {{
\t\tID = "wx_core_{key}", Chapter = "{chap}", Name = "{cname}", Value = {cval}, ExpAmount = 350,
\t\tIcon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
\t\tDescription = "{cdesc}"
\t}},""")
        if f"shanhai_{key}" not in enc_txt:
            lair_entries.append(f"""\tshanhai_{key} = {{
\t\tName = "{lname}", Chapter = "{chap}", Description = "{ldesc}",
\t\tBrush = "{lbrush}", Fortified = false, FactionType = "{ftype}",
\t\tTroops = {troops},
\t\tRewardManual = "{rman}", ExtraManual = "{eman}", GivesHerb = true, IsShanHai = true
\t}},""")

        # Entity script
        p_cls = pscript.split("/")[-1]
        with open(os.path.join(MOD, f"scripts/entity/tactical/enemies/wx_boss_{key}.nut"), "w", encoding="utf-8") as f:
            f.write(f"""// Shan Hai Jing Apex Boss Entity ({chap}): {bname}
this.wx_boss_{key} <- this.inherit("{pscript}", {{
\tm = {{}},
\tfunction onInit()
\t{{
\t\tthis.{p_cls}.onInit();
\t\t::Wuxia.ShanHai.initBossEntity(this, "boss_{key}");
\t}}
\tfunction onDeath( _killer, _skill, _tile, _fatalityType )
\t{{
\t\tthis.{p_cls}.onDeath(_killer, _skill, _tile, _fatalityType);
\t\t::Wuxia.ShanHai.dropBossCore("boss_{key}", _tile, this, _killer, _fatalityType);
\t}}
}});
""")
        # Core item script
        with open(os.path.join(MOD, f"scripts/items/misc/wx_core_{key}.nut"), "w", encoding="utf-8") as f:
            f.write(f"""this.wx_core_{key} <- this.inherit("scripts/items/misc/wx_shanhai_core_base", {{
\tm = {{}},
\tfunction create()
\t{{
\t\tthis.wx_shanhai_core_base.create();
\t\tthis.initCore("wx_core_{key}");
\t}}
}});
""")
        # World Lair location script
        with open(os.path.join(MOD, f"scripts/entity/world/locations/wx_shanhai_{key}.nut"), "w", encoding="utf-8") as f:
            f.write(f"""this.wx_shanhai_{key} <- this.inherit("scripts/entity/world/locations/wx_stronghold", {{
\tm = {{ WX_Site = "shanhai_{key}" }}
}});
""")

    if boss_entries:
        sh_txt = sh_txt.replace("\n};\n\n::Wuxia.Config.ShanHaiCores", "\n" + "\n".join(boss_entries) + "\n};\n\n::Wuxia.Config.ShanHaiCores", 1)
    if core_entries:
        sh_txt = sh_txt.replace("\n};\n\n::Wuxia.Config.ShanHaiGear", "\n" + "\n".join(core_entries) + "\n};\n\n::Wuxia.Config.ShanHaiGear", 1)
    open(sh_p, "w", encoding="utf-8").write(sh_txt)

    if lair_entries:
        enc_txt = re.sub(r'\n\};\s*$', "\n" + "\n".join(lair_entries) + "\n};\n", enc_txt)
        open(enc_p, "w", encoding="utf-8").write(enc_txt)

    # 7. Upgrade `wx_shanhai_system.nut` so custom boss `.brush` hides vanilla conflicting sub-sprites cleanly!
    sh_sys_p = os.path.join(MOD, "mod_wuxia/systems/wx_shanhai_system.nut")
    sh_sys_txt = open(sh_sys_p, "r", encoding="utf-8").read()
    if "helmet_damage" not in sh_sys_txt:
        sh_sys_txt = sh_sys_txt.replace(
            'if (cfg.CustomBodySprite != null && _actor.hasSprite("body"))\n\t\t_actor.getSprite("body").setBrush(cfg.CustomBodySprite);',
            'if (cfg.CustomBodySprite != null && _actor.hasSprite("body"))\n\t{\n\t\t_actor.getSprite("body").setBrush(cfg.CustomBodySprite);\n\t\tif (cfg.CustomHeadSprite == null)\n\t\t{\n\t\t\tforeach (sub in ["head", "helmet", "helmet_damage", "armor", "hair", "beard", "beard_top", "wings", "tattoo_body", "tattoo_head"])\n\t\t\t\tif (_actor.hasSprite(sub)) _actor.getSprite(sub).Visible = false;\n\t\t}\n\t}'
        )
        open(sh_sys_p, "w", encoding="utf-8").write(sh_sys_txt)

    # 8. Update `selftest.nut` to test ALL 72 Active Skills + ALL 64 Shan Hai Bosses + VFX System!
    st_p = os.path.join(MOD, "mod_wuxia/systems/selftest.nut")
    st_txt = open(st_p, "r", encoding="utf-8").read()
    for sid in all_new_sids:
        sp_str = f'"scripts/skills/actives/{sid}"'
        if sp_str not in st_txt:
            st_txt = st_txt.replace('"scripts/skills/actives/wx_shield_bash_qi"', f'"scripts/skills/actives/wx_shield_bash_qi",\n\t\t{sp_str}', 1)
    st_txt = st_txt.replace("if (bossCount != 48) throw \"Expected 48 Shan Hai Apex Bosses", "if (bossCount != 64) throw \"Expected 64 Shan Hai Apex Bosses")
    st_txt = st_txt.replace("48 Apex Bosses, 48 Neidan Cores", "64 Apex Bosses, 64 Neidan Cores")
    st_txt = st_txt.replace("Verified 48 Shan Hai Apex Bosses, 48 Cores", "Verified 64 Shan Hai Apex Bosses, 64 Cores")
    open(st_p, "w", encoding="utf-8").write(st_txt)

    total_act = len(glob.glob(os.path.join(MOD, "scripts/skills/actives/*.nut"))) - 1  # minus wx_move_base
    print(f"SUCCESS: Expanded Active Skills to {total_act} (+ wx_move_base), Shan Hai Bosses to 64, and created wx_vfx_system.nut!")


if __name__ == "__main__":
    main()
