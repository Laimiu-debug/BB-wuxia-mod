// Active Move: 两仪合璧斩
this.wx_saber_fanzhen <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_fanzhen";
		this.m.Name = "两仪合璧斩";
		this.m.Description = "正派双刀呼应阵斩：消耗 5 AP 与 20 内息，身旁有同袍并肩作战时命中 +12、额外穿甲 +15%。";
		this.m.Icon = "skills/wx_saber_fanzhen.png";
		this.m.IconDisabled = "skills/wx_saber_fanzhen_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_fanzhen";
		this.m.WX_VfxBrush <- "wx_vfx_21";
		this.m.WX_AnimID <- "wx_anim_20";
		this.m.WX_AnimMode <- "twin_cross";
		this.m.WX_ChoreoID <- "wx_saber_fanzhen";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Sword"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			local u = this.getContainer().getActor(); if (u != null && u.isPlacedOnMap() && u.getTile().hasNextTile(::Const.Direction.N)) { _properties.MeleeSkill += 10; _properties.DamageDirectAdd += 0.14; }
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		return hit;
	}
});
