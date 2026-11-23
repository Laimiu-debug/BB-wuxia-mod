// Active Move: 九节金龙抽
this.wx_flail_panlong <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_flail_panlong";
		this.m.Name = "九节金龙抽";
		this.m.Description = "九节软鞭镇派绝艺：消耗 5 AP 与 20 内息，金龙鞭越过盾牌重抽天灵（无视盾牌防御加成，击头率 +22%，破甲 +24%）。";
		this.m.Icon = "skills/wx_flail_panlong.png";
		this.m.IconDisabled = "skills/wx_flail_panlong_sw.png";
		this.m.Overlay = "wx_ov_wx_flail_panlong";
		this.m.WX_VfxBrush <- "wx_vfx_32";
		this.m.WX_AnimID <- "wx_anim_134";
		this.m.WX_AnimMode <- "whip_panlong";
		this.m.WX_ChoreoID <- "wx_flail_panlong";
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
			_properties.MeleeSkill += 8; _properties.HitChance[::Const.BodyPart.Head] += 22; _properties.DamageArmorMult *= 1.24; _properties.IsIgnoringShieldBonus = true;
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
