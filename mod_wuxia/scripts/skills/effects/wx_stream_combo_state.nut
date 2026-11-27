// Per-Actor Ephemeral Martial Stream State (`effects.wx_stream_combo_state`)
// Drives same-slot multi-stage combo progression (`起->承->转合`), Dragon-Wave (`潜龙劲`), Qinggong Wind Momentum (`乘风势`),
// Iaido Sheathe-Draw (`纳刀藏锋`), Blood-Blade Fury (`血海刀煞`), Spearwall Intercepts (`铁枪拒马`),
// Shaolin Crazy-Staff (`疯魔劲`), and White-Camel Toad Force (`金蟾蓄劲`) without exceeding the 6~9 HUD skill cap!

this.wx_stream_combo_state <- this.inherit("scripts/skills/skill", {
	m = {
		ComboStages            = null,
		PersistStages          = null,
		DragonWaves            = 0,
		WindSteps              = 0,
		ReactionsUsed          = 0,
		IaidoSheathed          = false,
		IaidoRefreshedThisTurn = false,
		BloodBladeStacks       = 0,
		SpearWallCharges       = 0,
		FengmoStacks           = 0,
		ToadForceStacks        = 0
	},

	function create()
	{
		this.m.ID = "effects.wx_stream_combo_state";
		this.m.Name = "武道气机流转";
		this.m.Description = "门派真传气机连绵不绝：同槽招式随实战连段、居合纳刀、潜龙叠浪、血煞、疯魔劲与金蟾蓄劲动态升阶变招。";
		this.m.Icon = "skills/wx_sword_combo.png";
		this.m.IconMini = "status_effect_74_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.ComboStages = {};
		this.m.PersistStages = {};
	}

	function isHidden()
	{
		if (this.m.DragonWaves > 0 || this.m.WindSteps > 0 || this.m.IaidoSheathed
			|| this.m.BloodBladeStacks > 0 || this.m.SpearWallCharges > 0
			|| this.m.FengmoStacks > 0 || this.m.ToadForceStacks > 0)
			return false;
		foreach (_, v in this.m.ComboStages)
		{
			if (v > 0) return false;
		}
		return true;
	}

	function getStage( _skillID )
	{
		if (_skillID == null || this.m.ComboStages == null || !(_skillID in this.m.ComboStages)) return 0;
		return this.m.ComboStages[_skillID];
	}

	function setStage( _skillID, _stage, _persistTurn = false )
	{
		if (_skillID == null) return;
		if (this.m.ComboStages == null) this.m.ComboStages = {};
		if (this.m.PersistStages == null) this.m.PersistStages = {};
		this.m.ComboStages[_skillID] <- _stage;
		this.m.PersistStages[_skillID] <- _persistTurn;
	}

	function addDragonWave( _delta, _max = 2 )
	{
		this.m.DragonWaves = ::Math.max(0, ::Math.min(_max, this.m.DragonWaves + _delta));
	}

	function addWindSteps( _steps )
	{
		this.m.WindSteps = ::Math.max(0, ::Math.min(3, this.m.WindSteps + _steps));
	}

	function consumeWindSteps()
	{
		local cur = this.m.WindSteps;
		this.m.WindSteps = 0;
		return cur;
	}

	function addBloodBlade( _delta = 1 )
	{
		this.m.BloodBladeStacks = ::Math.max(0, ::Math.min(3, this.m.BloodBladeStacks + _delta));
	}

	function addFengmo( _delta = 1 )
	{
		this.m.FengmoStacks = ::Math.max(0, ::Math.min(3, this.m.FengmoStacks + _delta));
	}

	function addToadForce( _delta = 1 )
	{
		this.m.ToadForceStacks = ::Math.max(0, ::Math.min(3, this.m.ToadForceStacks + _delta));
	}

	function onUpdate( _properties )
	{
		// Blood-Blade Ward (`血海护体血罡`), strictly clamped to AGENTS.md `DamageReceivedRegularMult >= 0.40`!
		if (this.m.BloodBladeStacks > 0)
		{
			local mult = 1.0 - (this.m.BloodBladeStacks * 0.05);
			_properties.DamageReceivedRegularMult = ::Math.maxf(0.40, _properties.DamageReceivedRegularMult * mult);
		}
		// Spearwall Stance (`铁枪拒马`) grants +6 MDef while charges remain
		if (this.m.SpearWallCharges > 0)
		{
			_properties.MeleeDefense += 6;
		}
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		if ((_damageHitpoints + _damageArmor) <= 0) return;
		local cont = this.getContainer();
		if (cont != null && cont.hasSkill("actives.wx_hama_push"))
			this.addToadForce(1);
	}

	function onTurnStart()
	{
		this.m.ReactionsUsed = 0;
		this.m.IaidoRefreshedThisTurn = false;
		this.m.SpearWallCharges = 0;
	}

	function onTurnEnd()
	{
		this.m.WindSteps = 0;
		if (this.m.BloodBladeStacks > 0) this.m.BloodBladeStacks -= 1;
		if (this.m.ComboStages != null)
		{
			local resetList = [];
			foreach (sid, st in this.m.ComboStages)
			{
				local keep = (this.m.PersistStages != null && (sid in this.m.PersistStages) && this.m.PersistStages[sid]);
				if (!keep && st > 0) resetList.push(sid);
				else if (keep && this.m.PersistStages != null) this.m.PersistStages[sid] = false;
			}
			foreach (rs in resetList)
				this.m.ComboStages[rs] = 0;
		}
	}

	function getTooltip()
	{
		local ret = [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() }
		];
		if (this.m.DragonWaves > 0)
			ret.push({ id = 10, type = "text", icon = "ui/icons/special.png", text = "【潜龙叠浪】：" + this.m.DragonWaves + " / 2 层（满 2 层亢龙有悔升格为『三叠浪』！）" });
		if (this.m.IaidoSheathed)
			ret.push({ id = 11, type = "text", icon = "ui/icons/melee_skill.png", text = "【纳刀藏锋】：下一记刀招自动升格为『拔刀一闪』（穿甲+10%、破盾斩回势）！" });
		if (this.m.BloodBladeStacks > 0)
			ret.push({ id = 12, type = "text", icon = "ui/icons/regular_damage.png", text = "【血海刀煞】：" + this.m.BloodBladeStacks + " / 3 层（血刀增威并凝血罡护体）" });
		if (this.m.SpearWallCharges > 0)
			ret.push({ id = 13, type = "text", icon = "ui/icons/melee_defense.png", text = "【铁枪拒马】：本轮尚余 " + this.m.SpearWallCharges + " 次迎敌自动攒刺拦截" });
		if (this.m.ToadForceStacks > 0)
			ret.push({ id = 14, type = "text", icon = "ui/icons/armor_body.png", text = "【金蟾蓄劲】：" + this.m.ToadForceStacks + " / 3 层（施展金蟾推山扑爆发倍增！）" });
		if (this.m.FengmoStacks > 0)
			ret.push({ id = 15, type = "text", icon = "ui/icons/bravery.png", text = "【疯魔杖意】：" + this.m.FengmoStacks + " / 3 层（越战越勇，破甲与命中递进）" });
		if (this.m.WindSteps > 0)
			ret.push({ id = 16, type = "text", icon = "ui/icons/initiative.png", text = "【轻功乘风势】：本回合下一击命中 +" + (this.m.WindSteps * 3) });
		return ret;
	}
});
