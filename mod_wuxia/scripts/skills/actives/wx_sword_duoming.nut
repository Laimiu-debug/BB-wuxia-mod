// Active Move: 夺命三仙剑
this.wx_sword_duoming <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_duoming";
		this.m.Name = "夺命三仙剑";
		this.m.Description = "西岳险峻奇快连环剑：消耗 5 AP 与 22 内息，剑光如电抢刺咽喉（命中 +10，暴击击头率 +15%）。";
		this.m.Icon = "skills/wx_sword_duoming.png";
		this.m.IconDisabled = "skills/wx_sword_duoming_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_duoming";
		this.m.WX_VfxBrush <- "wx_vfx_04";
		this.m.WX_AnimID <- "wx_anim_17";
		this.m.WX_AnimMode <- "clone3";
		this.m.WX_ChoreoID <- "wx_sword_duoming";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.32;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; _properties.HitChance[::Const.BodyPart.Head] += 15; _properties.DamageTotalMult *= 1.10;
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
