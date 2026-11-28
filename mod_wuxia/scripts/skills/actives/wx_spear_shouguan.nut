// Active Move: 北岳守隘刺
this.wx_spear_shouguan <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_shouguan";
		this.m.Name = "北岳守隘刺";
		this.m.Description = "恒山边关拒马铁矛术：消耗 4 AP 与 16 内息，攒矛死守关隘反刺来敌（命中 +9，令目标散劲虚弱）。";
		this.m.Icon = "skills/wx_spear_shouguan.png";
		this.m.IconDisabled = "skills/wx_spear_shouguan_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_shouguan";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_113";
		this.m.WX_AnimMode <- "pierce_shouguan";
		this.m.WX_ChoreoID <- "wx_spear_shouguan";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.28;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 9; _properties.DamageArmorMult *= 1.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if ("Streams" in ::Wuxia) ::Wuxia.Streams.activateSpearWallStance(_user, 2);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		return hit;
	}
});
