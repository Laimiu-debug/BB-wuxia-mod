// Sect/Secret Sword Move: 穿云透甲刺 (4 AP, 16 Qi: +8 hit, +20% armor pen, +10% headshot)

this.wx_sword_pierce <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_pierce";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_09";
		this.m.WX_AnimMode <- "drill_lunge";
		this.m.WX_ChoreoID <- "wx_sword_pierce";
		this.m.Name = "穿云透甲刺";
		this.m.Description = "凝内劲于剑尖直取甲胄缝隙：命中 +8，穿甲伤害率提高 20%，击中头部几率额外 +10%。";
		this.m.KilledString = "一剑洞穿咽喉";
		this.m.Icon = "skills/wx_sword_pierce.png";
		this.m.IconDisabled = "skills/wx_sword_pierce_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_pierce";
		this.m.SoundOnUse = [
			"sounds/combat/thrust_01.wav",
			"sounds/combat/thrust_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/thrust_hit_01.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.PiercingBody;
		this.m.InjuriesOnHead = this.Const.Injury.PiercingHead;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8;
			_properties.DamageDirectAdd += 0.20;
			_properties.HitChance[this.Const.BodyPart.Head] += 10;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		return this.attackEntity(_user, _targetTile.getEntity());
	}
});
