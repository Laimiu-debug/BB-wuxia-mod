// Active Move: 佛光绵骨掌
this.wx_fist_piaoxue <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_piaoxue";
		this.m.Name = "佛光绵骨掌";
		this.m.Description = "峨眉柔中带刚绝掌：消耗 4 AP 与 16 内息，掌影飘忽无声透衣伤腑（命中 +10，穿甲 +15%，附加散劲虚弱）。";
		this.m.Icon = "skills/wx_fist_piaoxue.png";
		this.m.IconDisabled = "skills/wx_fist_piaoxue_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_piaoxue";
		this.m.WX_VfxBrush <- "wx_vfx_16";
		this.m.WX_AnimID <- "wx_anim_102";
		this.m.WX_AnimMode <- "taiji_piaoxue";
		this.m.WX_ChoreoID <- "wx_fist_piaoxue";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.40;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; _properties.DamageDirectAdd += 0.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		return hit;
	}
});
