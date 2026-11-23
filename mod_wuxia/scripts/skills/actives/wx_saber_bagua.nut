// Active Move: 玄虚八卦刀
this.wx_saber_bagua <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_bagua";
		this.m.Name = "玄虚八卦刀";
		this.m.Description = "太和八卦游身刀法：消耗 4 AP 与 17 内息，踏八卦步绕盾斜劈（命中 +12，令目标散劲虚弱）。";
		this.m.Icon = "skills/wx_saber_bagua.png";
		this.m.IconDisabled = "skills/wx_saber_bagua_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_bagua";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_93";
		this.m.WX_AnimMode <- "taiji_baguadao";
		this.m.WX_ChoreoID <- "wx_saber_bagua";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 17;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.28;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12;
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
