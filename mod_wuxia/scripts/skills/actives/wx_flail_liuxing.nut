// Active Move: 三首流星砸
this.wx_flail_liuxing <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_flail_liuxing";
		this.m.Name = "三首流星砸";
		this.m.Description = "云梦三首连枷重抽：消耗 5 AP 与 20 内息，三颗铁流星轮番砸落（总伤 +18%，破甲 +22%，失衡）。";
		this.m.Icon = "skills/wx_flail_liuxing.png";
		this.m.IconDisabled = "skills/wx_flail_liuxing_sw.png";
		this.m.Overlay = "wx_ov_wx_flail_liuxing";
		this.m.WX_VfxBrush <- "wx_vfx_14";
		this.m.WX_AnimID <- "wx_anim_136";
		this.m.WX_AnimMode <- "flurry_liuxing";
		this.m.WX_ChoreoID <- "wx_flail_liuxing";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Flail"];
		this.m.DirectDamageMult = 0.32;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageTotalMult *= 1.18; _properties.DamageArmorMult *= 1.22; _properties.IsIgnoringShieldBonus = true;
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
