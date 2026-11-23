// Active Move: 太行碎星锤
this.wx_hammer_qianjun <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_hammer_qianjun";
		this.m.Name = "太行碎星锤";
		this.m.Description = "太行力士万钧重锤：消耗 6 AP 与 25 内息，崩山重砸隔甲碎骨（破甲 +45%，总伤 +16%，致敌失衡）。";
		this.m.Icon = "skills/wx_hammer_qianjun.png";
		this.m.IconDisabled = "skills/wx_hammer_qianjun_sw.png";
		this.m.Overlay = "wx_ov_wx_hammer_qianjun";
		this.m.WX_VfxBrush <- "wx_vfx_14";
		this.m.WX_AnimID <- "wx_anim_123";
		this.m.WX_AnimMode <- "earth_qianjun";
		this.m.WX_ChoreoID <- "wx_hammer_qianjun";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 25;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Hammer"];
		this.m.DirectDamageMult = 0.42;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageArmorMult *= 1.45; _properties.DamageTotalMult *= 1.16;
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
