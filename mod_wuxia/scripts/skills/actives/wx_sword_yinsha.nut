// Active Move: 幽冥追魂剑
this.wx_sword_yinsha <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_yinsha";
		this.m.Name = "幽冥追魂剑";
		this.m.Description = "黑道诡剑夺命杀招：消耗 4 AP 与 18 内息，鬼影欺身专取受创伤敌性命（目标生命低于 65% 时总伤 +28%、命中 +10）。";
		this.m.Icon = "skills/wx_sword_yinsha.png";
		this.m.IconDisabled = "skills/wx_sword_yinsha_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_yinsha";
		this.m.WX_VfxBrush <- "wx_vfx_30";
		this.m.WX_AnimID <- "wx_anim_87";
		this.m.WX_AnimMode <- "shadow_yinsha";
		this.m.WX_ChoreoID <- "wx_sword_yinsha";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.34;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			if (_targetEntity != null && _targetEntity.getHitpointsMax() > 0 && (_targetEntity.getHitpoints() * 100) < (_targetEntity.getHitpointsMax() * 65)) { _properties.MeleeSkill += 10; _properties.DamageTotalMult *= 1.28; }
			else { _properties.MeleeSkill += 6; }
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
