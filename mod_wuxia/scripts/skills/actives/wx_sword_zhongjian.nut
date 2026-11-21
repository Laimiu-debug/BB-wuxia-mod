// Active Move: 重剑无锋劈
this.wx_sword_zhongjian <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_zhongjian";
		this.m.Name = "重剑无锋劈";
		this.m.Description = "大巧不工重剑式：消耗 6 AP 与 26 内息，以浑厚内劲运剑如锤重砸敌甲（破甲伤害 +40%，命中致目标失衡）。";
		this.m.Icon = "skills/wx_sword_zhongjian.png";
		this.m.IconDisabled = "skills/wx_sword_zhongjian_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_zhongjian";
		this.m.WX_VfxBrush <- "wx_vfx_05";
		this.m.WX_AnimID <- "wx_anim_19";
		this.m.WX_AnimMode <- "gravity_cut";
		this.m.WX_ChoreoID <- "wx_sword_zhongjian";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.25;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageArmorMult *= 1.40; _properties.DamageTotalMult *= 1.12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
