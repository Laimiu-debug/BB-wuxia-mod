// Keep the native target selection, pathing and stamina evaluation for each behavior,
// while empowering Wuxia martial artists with non-full-AP follow-ups & 12-archetype combo/counter targeting!

::Wuxia.CombatRules.AcupointPoisonMoves <- {
	["actives.wx_acupoint_strike"] = true,
	["actives.wx_fist_acupoint"]   = true,
	["actives.wx_fist_nianhua"]    = true,
	["actives.wx_fist_yiyang"]     = true,
	["actives.wx_sword_canhe"]     = true,
	["actives.wx_dagger_fuxue"]    = true,
	["actives.wx_throw_duzhen"]    = true,
	["actives.wx_throw_kongque"]   = true,
	["actives.wx_fist_qianzhu"]    = true,
	["actives.wx_flail_jinshe"]    = true,
	["actives.wx_crossbow_liannu"] = true
};

// Evaluate tactical combo & counter synergy for `(attacker, target, skill)` inside AI `queryTargetValue` & `onEvaluate`
::Wuxia.CombatRules.evaluateAISkillTargetMult <- function( _entity, _target, _skill )
{
	if (_entity == null || _target == null || _skill == null) return 1.0;
	local sid = (::Wuxia.hasMember(_skill, "getID")) ? _skill.getID() : "";
	if (sid == null || sid.find("actives.wx_") != 0) return 1.0;

	local mult = 1.0;
	local tsk = (::Wuxia.hasMember(_target, "getSkills")) ? _target.getSkills() : null;

	// Avoid wasting Acupoint / Venom techniques against immune Tomb Automatons & Xiangxi Corpse Puppets!
	if ((sid in ::Wuxia.CombatRules.AcupointPoisonMoves) && ::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_target))
	{
		mult *= 0.62;
	}

	// Prioritize continuing active multi-stage Wuxia combos (`一式->二式->三式`) & Iaido flash draws!
	if ("Streams" in ::Wuxia)
	{
		if (::Wuxia.Streams.getComboStage(_entity, sid) > 0)
			mult *= 1.22;
		if (sid == "actives.wx_saber_xinyue" && ::Wuxia.Streams.isIaidoReady(_entity))
			mult *= 1.25;
	}

	local tag = (sid in ::Wuxia.CombatRules.SkillMechanics) ? ::Wuxia.CombatRules.SkillMechanics[sid] : "";
	if (tag == "") return mult;

	if (tag == "detonate_opening" && tsk != null && tsk.hasSkill("effects.wx_status_opening"))
	{
		mult *= 1.30;
	}
	else if (tag == "detonate_bleed" && tsk != null && tsk.hasSkill("effects.bleeding") && !::Wuxia.CombatRules.isUndeadOrConstruct(_target))
	{
		mult *= 1.28;
	}
	else if (tag == "concuss_armor" && ::Wuxia.hasMember(_target, "getArmor"))
	{
		local totalArm = _target.getArmor(::Const.BodyPart.Body) + _target.getArmor(::Const.BodyPart.Head);
		if (totalArm >= 220) mult *= 1.28;
		else if (totalArm >= 140) mult *= 1.18;
	}
	else if (tag == "shatter_shield" && ::Wuxia.hasMember(_target, "isArmedWithShield") && _target.isArmedWithShield())
	{
		mult *= 1.24;
	}
	else if (tag == "spread_venom" && tsk != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_target))
	{
		if (tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison"))
			mult *= 1.24;
	}
	else if (tag == "pierce_line" && ::Wuxia.isOnMap(_entity) && ::Wuxia.isOnMap(_target))
	{
		local uTile = _entity.getTile();
		local tTile = _target.getTile();
		if (uTile != null && tTile != null)
		{
			local dir = uTile.getDirectionTo(tTile);
			if (tTile.hasNextTile(dir))
			{
				local backTile = tTile.getNextTile(dir);
				if (backTile != null && backTile.IsOccupiedByActor && backTile.getEntity() != null && backTile.getEntity().isAlive() && !_entity.isAlliedWith(backTile.getEntity()))
					mult *= 1.25;
			}
		}
	}
	else if (tag == "high_ground" && ::Wuxia.isOnMap(_entity) && ::Wuxia.isOnMap(_target))
	{
		local diff = _entity.getTile().Level - _target.getTile().Level;
		if (diff > 0) mult *= (1.0 + ::Math.minf(0.24, diff * 0.12));
	}
	else if (tag == "pull_closer" && ::Wuxia.isOnMap(_entity) && ::Wuxia.isOnMap(_target))
	{
		if (_entity.getTile().getDistanceTo(_target.getTile()) == 2)
			mult *= 1.20;
	}
	else if (tag == "surround_scale" && ::Wuxia.isOnMap(_entity))
	{
		local adjFoes = 0;
		local myT = _entity.getTile();
		for (local d = 0; d < 6; d = ++d)
		{
			if (!myT.hasNextTile(d)) continue;
			local nt = myT.getNextTile(d);
			if (nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && !_entity.isAlliedWith(nt.getEntity()))
				adjFoes += 1;
		}
		if (adjFoes >= 2) mult *= (1.0 + ::Math.minf(0.24, (adjFoes - 1) * 0.10));
	}
	else if ((tag == "backstep" || tag == "step_through") && ::Wuxia.hasMember(_entity, "getHitpointsPct") && _entity.getHitpointsPct() < 0.65)
	{
		mult *= 1.15;
	}

	return ::Math.maxf(0.55, ::Math.minf(1.42, mult));
};

local extendBehaviorSkillsOnly = function( _path, _moves )
{
	::Wuxia.HooksMod.hook("scripts/ai/tactical/behaviors/" + _path, function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			if (!(::Wuxia.hasMember(this.m, "PossibleSkills")) || this.m.PossibleSkills == null) return;
			this.m.PossibleSkills = clone this.m.PossibleSkills;
			foreach (id in _moves)
				if (this.m.PossibleSkills.find(id) == null) this.m.PossibleSkills.push(id);
		};
	});
};

local extendBehavior = function( _path, _moves )
{
	::Wuxia.HooksMod.hook("scripts/ai/tactical/behaviors/" + _path, function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			if (!(::Wuxia.hasMember(this.m, "PossibleSkills")) || this.m.PossibleSkills == null) return;
			this.m.PossibleSkills = clone this.m.PossibleSkills;
			foreach (id in _moves)
				if (this.m.PossibleSkills.find(id) == null) this.m.PossibleSkills.push(id);
		};

		q.onEvaluate = @(__original) function( _entity )
		{
			if (!(::Wuxia.hasMember(this.m, "PossibleSkills")) || this.m.PossibleSkills == null || _entity == null)
				return __original(_entity);

			local skCont = (::Wuxia.hasMember(_entity, "getSkills")) ? _entity.getSkills() : null;
			if (skCont != null && _entity.getActionPoints() >= 3)
			{
				local trained = [];
				foreach (id in _moves)
				{
					local skill = skCont.getSkillByID(id);
					if (skill != null && skill.isUsable() && skill.isAffordable()) trained.push(id);
				}
				if (trained.len() != 0)
				{
					local all = this.m.PossibleSkills, score = 0;
					this.m.PossibleSkills = trained;
					try { score = __original(_entity); }
					catch (error) { this.m.PossibleSkills = all; throw error; }
					this.m.PossibleSkills = all;
					if (typeof score == "generator") return score;
					if (score > 0)
					{
						local isBoss = ("m" in _entity) && ("WX_BossID" in _entity.m);
						local boost = isBoss ? 1.32 : ((_entity.getActionPoints() == _entity.getActionPointsMax()) ? 1.18 : 1.12);
						local chosenSk = (::Wuxia.hasMember(this.m, "Skill")) ? this.m.Skill : null;
						local chosenTile = (::Wuxia.hasMember(this.m, "TargetTile")) ? this.m.TargetTile : null;
						local chosenEnt = (chosenTile != null && chosenTile.IsOccupiedByActor) ? chosenTile.getEntity() : null;
						if (chosenSk != null && chosenEnt != null)
							boost *= ::Wuxia.CombatRules.evaluateAISkillTargetMult(_entity, chosenEnt, chosenSk);
						return score * ::Math.minf(1.48, boost);
					}
				}
			}
			return __original(_entity);
		};
	});
};

local wxRangedMoves = [
	"actives.wx_bow_luori", "actives.wx_bow_snipe", "actives.wx_bow_jiuxing", "actives.wx_bow_yanxing", "actives.wx_bow_liuxing",
	"actives.wx_crossbow_shenji", "actives.wx_crossbow_liannu",
	"actives.wx_gun_huolong", "actives.wx_gun_leihuo",
	"actives.wx_throw_pilidan", "actives.wx_throw_duzhen", "actives.wx_throw_liuyedao", "actives.wx_throw_kongque",
	"actives.wx_throwing_rain", "actives.wx_throw_fan", "actives.wx_smoke_cast",
	"actives.wx_boss_nvchou_ten_suns_ray"
];

local wxBossMeleeMoves = [];
local wxBossSwingMoves = [];
local wxBossNonTargetedMoves = [];

if ("ShanHaiBossMoves" in ::Wuxia)
{
	foreach (mid, mSpec in ::Wuxia.ShanHaiBossMoves)
	{
		local fullID = "actives." + mid;
		local g = ("Geo" in mSpec) ? mSpec.Geo : "single";
		if (g == "ring_quake_6" || g == "field_detonate" || g == "totem_swap" || g == "telegraph_omen" || g == "sonic_roar")
		{
			wxBossNonTargetedMoves.push(fullID);
		}
		else if (g == "ranged_barrage" || g == "totem_ray" || g == "hex_curse")
		{
			wxRangedMoves.push(fullID);
			wxBossMeleeMoves.push(fullID);
		}
		else
		{
			wxBossMeleeMoves.push(fullID);
			if (g == "cone_3" || g == "tail_sweep_arc")
				wxBossSwingMoves.push(fullID);
		}
	}
}

local engageRangedMoves = [
	"actives.throw_javelin", "actives.throw_axe", "actives.throw_balls", "actives.throw_spear"
];
foreach (id in wxRangedMoves) engageRangedMoves.push(id);

local wxDefaultAttackMoves = [
	"actives.wx_sword_combo", "actives.wx_sword_pierce", "actives.wx_sword_tianwai",
	"actives.wx_saber_cleave", "actives.wx_saber_sweep", "actives.wx_saber_duanyue",
	"actives.wx_spear_guard", "actives.wx_spear_thrust2", "actives.wx_pole_sweep",
	"actives.wx_acupoint_strike", "actives.wx_throwing_rain", "actives.wx_throw_fan", "actives.wx_smoke_cast",
	"actives.wx_fist_jab", "actives.wx_fist_shock", "actives.wx_fist_jingang", "actives.wx_fist_acupoint", "actives.wx_fist_disarm", "actives.wx_fist_grapple",
	"actives.wx_hammer_shatter", "actives.wx_hammer_quake",
	"actives.wx_axe_split", "actives.wx_axe_whirl",
	"actives.wx_flail_lash", "actives.wx_flail_entangle",
	"actives.wx_dagger_vital", "actives.wx_dagger_execute",
	"actives.wx_shield_bash_qi", "actives.wx_neigong_xixing",
	"actives.wx_boss_zhuyin_winter_breath", "actives.wx_boss_zhuyin_summer_gale", "actives.wx_boss_zhuyin_coil_crush",
	"actives.wx_boss_xiangliu_nine_devour", "actives.wx_boss_xiangliu_mire_ram", "actives.wx_boss_nvchou_ten_suns_ray",
	"actives.wx_sword_zhongjian", "actives.wx_sword_duoming", "actives.wx_sword_cuixin", "actives.wx_sword_taiji", "actives.wx_sword_feixian", "actives.wx_sword_dugu", "actives.wx_saber_kuangfeng", "actives.wx_saber_ranmu", "actives.wx_saber_xuehai", "actives.wx_saber_fanzhen", "actives.wx_saber_modao", "actives.wx_saber_huoyandao", "actives.wx_spear_liuhua", "actives.wx_spear_bawang", "actives.wx_spear_liangyin", "actives.wx_pole_fangtian", "actives.wx_pole_goulian", "actives.wx_staff_dagou", "actives.wx_fist_xianglong", "actives.wx_fist_xuanming", "actives.wx_fist_yiyang", "actives.wx_fist_jiuyin", "actives.wx_fist_qishang", "actives.wx_fist_taiji", "actives.wx_hama_push", "actives.wx_hammer_leiting", "actives.wx_axe_kaishan", "actives.wx_whip_suohou", "actives.wx_dagger_fuxue",
	"actives.wx_sword_wanjian", "actives.wx_sword_yunv", "actives.wx_sword_canhe", "actives.wx_sword_bixue", "actives.wx_sword_xuanbing", "actives.wx_sword_miejian", "actives.wx_sword_zixia", "actives.wx_sword_zhenwu", "actives.wx_sword_huifeng", "actives.wx_sword_kuangfeng", "actives.wx_sword_qinggang", "actives.wx_sword_yinsha", "actives.wx_saber_abi", "actives.wx_saber_xinyue", "actives.wx_saber_shishen", "actives.wx_saber_podao", "actives.wx_saber_kuanglan", "actives.wx_saber_bagua", "actives.wx_saber_tuxiong", "actives.wx_saber_zhanlang", "actives.wx_saber_baji", "actives.wx_saber_lingnan", "actives.wx_saber_chiyou", "actives.wx_fist_rulai", "actives.wx_fist_nuchao", "actives.wx_fist_qianzhu", "actives.wx_fist_piaoxue", "actives.wx_fist_longzhao", "actives.wx_fist_xiongzhao", "actives.wx_fist_canhezhi", "actives.wx_fist_nianhua", "actives.wx_fist_tiegang", "actives.wx_fist_heisha", "actives.wx_fist_luohan", "actives.wx_spear_panlong", "actives.wx_spear_xuelong", "actives.wx_spear_zhenbiao", "actives.wx_spear_shouguan", "actives.wx_spear_yaqi", "actives.wx_pole_pojun", "actives.wx_pole_fenjiang", "actives.wx_staff_qingou", "actives.wx_staff_fengmo", "actives.wx_staff_weituo", "actives.wx_staff_lianhua", "actives.wx_staff_zhenjiang", "actives.wx_hammer_pocheng", "actives.wx_hammer_qianjun", "actives.wx_hammer_jingua", "actives.wx_hammer_polu", "actives.wx_hammer_faqiu", "actives.wx_axe_kaitian", "actives.wx_axe_xueming", "actives.wx_axe_poche", "actives.wx_dagger_jingke", "actives.wx_dagger_zhuanzhu", "actives.wx_dagger_yingci", "actives.wx_dagger_shenghuo", "actives.wx_flail_panlong", "actives.wx_flail_jinshe", "actives.wx_flail_liuxing", "actives.wx_henglian_tongtou", "actives.wx_throw_liuyedao", "actives.wx_throw_kongque", "actives.wx_whip_xiangxi"
];
foreach (bm in wxBossMeleeMoves) wxDefaultAttackMoves.push(bm);

local wxSwingMoves = ["actives.wx_saber_sweep", "actives.wx_pole_sweep", "actives.wx_axe_whirl", "actives.wx_sword_wanjian", "actives.wx_saber_abi", "actives.wx_saber_kuanglan", "actives.wx_fist_rulai", "actives.wx_pole_pojun", "actives.wx_staff_qingou", "actives.wx_hammer_pocheng"];
foreach (bs in wxBossSwingMoves) wxSwingMoves.push(bs);

local wxIndomitableMoves = ["actives.wx_neigong_jinzhong", "actives.wx_shield_tiebi", "actives.wx_neigong_yijin", "actives.wx_neigong_hanbing", "actives.wx_neigong_douzhuan", "actives.wx_neigong_wudu", "actives.wx_neigong_taotie", "actives.wx_neigong_junwu", "actives.wx_henglian_tiebushan", "actives.wx_henglian_jinchan", "actives.wx_henglian_panshi", "actives.wx_shield_xuanwu", "actives.wx_tactics_qimen", "actives.wx_boss_cataclysm", "actives.wx_boss_zhuyin_primordial_wind", "actives.wx_boss_xiangliu_poison_deluge", "actives.wx_boss_nvchou_scorch_apocalypse", "actives.wx_boss_nvchou_sleeve_shift"];
foreach (bn in wxBossNonTargetedMoves) wxIndomitableMoves.push(bn);

local wxWarcryMoves = ["actives.wx_tactics_shihou", "actives.wx_tactics_kuiniu", "actives.wx_boss_cataclysm", "actives.wx_boss_zhuyin_primordial_wind", "actives.wx_boss_xiangliu_poison_deluge", "actives.wx_boss_xiangliu_miasma_hex", "actives.wx_boss_nvchou_scorch_apocalypse"];
foreach (bn2 in wxBossNonTargetedMoves) wxWarcryMoves.push(bn2);

extendBehavior("ai_attack_default", wxDefaultAttackMoves);
extendBehavior("ai_attack_bow", wxRangedMoves);
// `ai_engage_ranged` and `ai_defend_knock_back` use Squirrel coroutine generators in `onEvaluate`:
// extend `PossibleSkills` in `create()` ONLY so throwing & Wuxia ranged units position cleanly without wrapping generators.
extendBehaviorSkillsOnly("ai_engage_ranged", engageRangedMoves);
extendBehavior("ai_attack_swing", wxSwingMoves);
extendBehavior("ai_attack_splitshield", ["actives.wx_axe_split"]);
extendBehaviorSkillsOnly("ai_defend_knock_back", ["actives.wx_shield_bash_qi"]);
extendBehavior("ai_defend_riposte", ["actives.wx_sword_counter", "actives.wx_poise_charge"]);
extendBehavior("ai_defend_shieldwall", ["actives.wx_shield_tiebi", "actives.wx_neigong_jinzhong", "actives.wx_shield_xuanwu"]);
extendBehavior("ai_indomitable", wxIndomitableMoves);
extendBehavior("ai_recover", ["actives.wx_meditate", "actives.wx_neigong_zixia", "actives.wx_neigong_guiyuan", "actives.wx_neigong_chaoxi"]);
extendBehavior("ai_adrenaline", ["actives.wx_blood_burst", "actives.wx_boss_nvchou_sleeve_shift"]);
extendBehavior("ai_disengage", ["actives.wx_qinggong_lingbo", "actives.wx_qinggong_zongyue", "actives.wx_qinggong_yanxing", "actives.wx_qinggong_shuishang", "actives.wx_qinggong_feiyan", "actives.wx_qinggong_meiying", "actives.wx_qinggong_shenxing", "actives.wx_qinggong_xuelian", "actives.wx_qinggong_chanchu", "actives.wx_qinggong_suodi"]);
extendBehavior("ai_warcry", wxWarcryMoves);
extendBehavior("ai_rally", ["actives.wx_rally_command", "actives.wx_tactics_guigu", "actives.wx_tactics_bamen"]);

::Wuxia.HooksMod.hook("scripts/ai/tactical/behavior", function( q )
{
	if (::Wuxia.qHas(q, "queryTargetValue"))
	{
		q.queryTargetValue = @(__original) function( _entity, _target, _skill = null )
		{
			local val = __original(_entity, _target, _skill);
			if (val > 0 && _skill != null && _target != null && ("CombatRules" in ::Wuxia) && ("evaluateAISkillTargetMult" in ::Wuxia.CombatRules))
			{
				val *= ::Wuxia.CombatRules.evaluateAISkillTargetMult(_entity, _target, _skill);
			}
			return val;
		};
	}
});

::Wuxia.HooksMod.hook("scripts/ai/tactical/agent", function( q )
{
	if (::Wuxia.qHas(q, "finalizeBehaviors"))
	{
		q.finalizeBehaviors = @(__original) function()
		{
			if (this.getBehavior(::Const.AI.Behavior.ID.EngageRanged) != null)
			{
				if (("AttackHandgonne" in ::Const.AI.Behavior.ID) && this.getBehavior(::Const.AI.Behavior.ID.AttackHandgonne) == null)
					this.addBehavior(::new("scripts/ai/tactical/behaviors/ai_attack_handgonne"));
				if (("AttackBow" in ::Const.AI.Behavior.ID) && this.getBehavior(::Const.AI.Behavior.ID.AttackBow) == null)
					this.addBehavior(::new("scripts/ai/tactical/behaviors/ai_attack_bow"));
			}
			return __original();
		};
	}
});
