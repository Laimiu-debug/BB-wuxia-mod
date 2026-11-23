// Active Move: 金顶绝命剑
this.wx_sword_miejian <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_miejian";
		this.m.Name = "金顶绝命剑";
		this.m.Description = "峨眉绝情凌厉杀剑：消耗 5 AP 与 22 内息，剑发金顶梵光直取眉心（命中 +10，击头率 +20%，穿甲 +12%）。";
		this.m.Icon = "skills/wx_sword_miejian.png";
		this.m.IconDisabled = "skills/wx_sword_miejian_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_miejian";
		this.m.WX_VfxBrush <- "wx_vfx_07";
		this.m.WX_AnimID <- "wx_anim_81";
		this.m.WX_AnimMode <- "sky_miejian";
		this.m.WX_ChoreoID <- "wx_sword_miejian";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.34;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; _properties.HitChance[::Const.BodyPart.Head] += 20; _properties.DamageDirectAdd += 0.12;
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
