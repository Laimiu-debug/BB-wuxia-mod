// Active Move: 唐门连珠矢
this.wx_crossbow_liannu <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_crossbow_liannu";
		this.m.Name = "唐门连珠矢";
		this.m.Description = "蜀中机括快弩攒射：消耗 4 AP 与 16 内息，机簧连发喂毒铁矢（射程 2~6 格，射艺 +10，穿甲 +15%，附奇毒蚀脉）。";
		this.m.Icon = "skills/wx_crossbow_liannu.png";
		this.m.IconDisabled = "skills/wx_crossbow_liannu_sw.png";
		this.m.Overlay = "wx_ov_wx_crossbow_liannu";
		this.m.WX_VfxBrush <- "wx_vfx_28";
		this.m.WX_AnimID <- "wx_anim_140";
		this.m.WX_AnimMode <- "flurry_liannu";
		this.m.WX_ChoreoID <- "wx_crossbow_liannu";
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Xiujian;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.SoundOnUse = ["sounds/combat/bolt_shot_01.wav", "sounds/combat/bolt_shot_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 2;
		this.m.MaxRange = 6;
		this.m.RequiredWeaponTypes = ["Crossbow"];
		this.m.DirectDamageMult = 0.48;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 10; _properties.DamageDirectAdd += 0.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.wxShootBowAt(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
		}
		return hit;
	}
});
