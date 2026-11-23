// Active Move: 冷月双飞剑
this.wx_sword_yunv <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_yunv";
		this.m.Name = "冷月双飞剑";
		this.m.Description = "终南古墓清冷快剑：消耗 4 AP 与 16 内息，剑走轻灵双刺咽喉（命中 +10，身法高于目标时额外穿甲 +12%）。";
		this.m.Icon = "skills/wx_sword_yunv.png";
		this.m.IconDisabled = "skills/wx_sword_yunv_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_yunv";
		this.m.WX_VfxBrush <- "wx_vfx_01";
		this.m.WX_AnimID <- "wx_anim_77";
		this.m.WX_AnimMode <- "flurry_yunv";
		this.m.WX_ChoreoID <- "wx_sword_yunv";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			local u = this.getContainer().getActor(); _properties.MeleeSkill += 10; if (u != null && _targetEntity != null && u.getInitiative() > _targetEntity.getInitiative()) _properties.DamageDirectAdd += 0.12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			
		}
		return hit;
	}
});
