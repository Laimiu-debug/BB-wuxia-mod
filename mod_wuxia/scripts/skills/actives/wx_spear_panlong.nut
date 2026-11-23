// Active Move: 长风追魂枪
this.wx_spear_panlong <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_panlong";
		this.m.Name = "长风追魂枪";
		this.m.Description = "洛阳镖局八步赶蝉快枪：消耗 5 AP 与 20 内息，枪走游龙直取两格敌喉（命中 +10，击头率 +14%）。";
		this.m.Icon = "skills/wx_spear_panlong.png";
		this.m.IconDisabled = "skills/wx_spear_panlong_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_panlong";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_110";
		this.m.WX_AnimMode <- "pierce_panlong";
		this.m.WX_ChoreoID <- "wx_spear_panlong";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; _properties.HitChance[::Const.BodyPart.Head] += 14; _properties.DamageTotalMult *= 1.10;
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
