// Active Move: 韦陀杵碎颅
this.wx_staff_weituo <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_staff_weituo";
		this.m.Name = "韦陀杵碎颅";
		this.m.Description = "禅门金刚杵棍重击：消耗 5 AP 与 20 内息，高举齐眉杵棍劈砸天灵（破甲 +28%，击头率 +15%）。";
		this.m.Icon = "skills/wx_staff_weituo.png";
		this.m.IconDisabled = "skills/wx_staff_weituo_sw.png";
		this.m.Overlay = "wx_ov_wx_staff_weituo";
		this.m.WX_VfxBrush <- "wx_vfx_14";
		this.m.WX_AnimID <- "wx_anim_119";
		this.m.WX_AnimMode <- "sky_weituo";
		this.m.WX_ChoreoID <- "wx_staff_weituo";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Staff"];
		this.m.DirectDamageMult = 0.32;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageArmorMult *= 1.28; _properties.HitChance[::Const.BodyPart.Head] += 15;
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
