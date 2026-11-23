// Active Move: 八棱金瓜砸
this.wx_hammer_jingua <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_hammer_jingua";
		this.m.Name = "八棱金瓜砸";
		this.m.Description = "朔方将校破胄金锤：消耗 4 AP 与 17 内息，金瓜锤专敲头盔护肩（命中 +7，破甲 +30%，击头率 +12%）。";
		this.m.Icon = "skills/wx_hammer_jingua.png";
		this.m.IconDisabled = "skills/wx_hammer_jingua_sw.png";
		this.m.Overlay = "wx_ov_wx_hammer_jingua";
		this.m.WX_VfxBrush <- "wx_vfx_14";
		this.m.WX_AnimID <- "wx_anim_124";
		this.m.WX_AnimMode <- "sky_jingua";
		this.m.WX_ChoreoID <- "wx_hammer_jingua";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 17;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Hammer"];
		this.m.DirectDamageMult = 0.38;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 7; _properties.DamageArmorMult *= 1.30; _properties.HitChance[::Const.BodyPart.Head] += 12;
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
