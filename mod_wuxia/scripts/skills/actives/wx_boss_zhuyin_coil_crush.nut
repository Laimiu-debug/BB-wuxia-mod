// Shan Hai Boss Bespoke Active (`boss_zhuyin` #3): 千里盘山绞 (Coiled Multi-Tile Constriction — Locked when `赤鳞龙躯` Armor Breaks!)

this.wx_boss_zhuyin_coil_crush <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_05",
		WX_ChoreoID = "wx_boss_zhuyin_coil_crush"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_zhuyin_coil_crush";
		this.m.Name = "千里盘山绞";
		this.m.Description = "烛阴催动千里赤鳞龙躯盘山绞杀：对贴身敌军施加高穿甲巨力绞碎（崩毁 20 护甲、震散 14 内息并挂失衡）；若我方重兵打碎【赤鳞龙躯】鳞甲则此凶招永久废除！";
		this.m.Icon = "skills/wx_fist_grapple.png";
		this.m.IconDisabled = "skills/wx_fist_grapple_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_grapple";
		this.m.SoundOnUse = ["sounds/combat/bash_hit_01.wav"];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsAttack = true;
		this.m.IsShieldRelevant = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 14;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.DirectDamageMult = 0.45;
	}

	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null && (::Wuxia.ShanHaiMultiBody.isSkillLocked(actor, this.m.ID) || ::Wuxia.ShanHaiMultiBody.isSegmentArmorBroken(actor, "body_seg")))
			return false;
		return true;
	}

	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 15;
			_properties.DamageRegularMin += 45;
			_properties.DamageRegularMax += 68;
			_properties.DamageDirectAdd += 0.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local target = _targetTile.getEntity();
		if (target == null || !target.isAlive()) return false;
		local hit = this.attackEntity(_user, target);
		if (hit && target.isAlive())
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
				::Wuxia.CombatRules.spendQi(target, 14);
			if (target.getItems() != null)
			{
				local bArm = target.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (bArm != null && bArm.getArmor() > 0)
					bArm.setArmor(::Math.max(0, bArm.getArmor() - 20));
			}
			local sk = target.getSkills();
			if (sk != null && !sk.hasSkill("effects.wx_status_offbalance"))
				sk.add(::new("scripts/skills/effects/wx_status_offbalance"));
		}
		return hit;
	}
});
