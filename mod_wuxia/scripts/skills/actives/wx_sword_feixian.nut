// Active Move: 天河落星剑
this.wx_sword_feixian <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_feixian";
		this.m.Name = "天河落星剑";
		this.m.Description = "名门越步飞剑绝技：消耗 6 AP 与 28 内息，剑芒吞吐越过前排直刺 2 格之敌（命中 +8，穿甲 +15%）。";
		this.m.Icon = "skills/wx_sword_feixian.png";
		this.m.IconDisabled = "skills/wx_sword_feixian_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_feixian";
		this.m.WX_VfxBrush <- "wx_vfx_08";
		this.m.WX_AnimID <- "wx_anim_41";
		this.m.WX_AnimMode <- "star_rain";
		this.m.WX_ChoreoID <- "wx_sword_feixian";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.38;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageDirectAdd += 0.15; _properties.DamageTotalMult *= 1.15;
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
