// Active Move: 神机透甲矢
this.wx_crossbow_shenji <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_crossbow_shenji";
		this.m.Name = "神机透甲矢";
		this.m.Description = "官军神机劲弩攒射：消耗 5 AP 与 20 内息，铁矢贯透重铠护心镜（穿甲 +20%，破甲 +25%）。";
		this.m.Icon = "skills/wx_crossbow_shenji.png";
		this.m.IconDisabled = "skills/wx_crossbow_shenji_sw.png";
		this.m.Overlay = "wx_ov_wx_crossbow_shenji";
		this.m.WX_VfxBrush <- "wx_vfx_29";
		this.m.WX_AnimID <- "wx_anim_65";
		this.m.WX_AnimMode <- "heavy_bolt";
		this.m.WX_ChoreoID <- "wx_crossbow_shenji";
		this.m.SoundOnUse = ["sounds/combat/bolt_shot_01.wav", "sounds/combat/bolt_shot_02.wav"];
		this.m.SoundOnHit = ["sounds/combat/bolt_shot_hit_01.wav", "sounds/combat/bolt_shot_hit_02.wav"];
		this.m.SoundOnMiss = ["sounds/combat/bolt_shot_miss_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 2;
		this.m.MaxRange = 6;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Shenjishi;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.RequiredWeaponTypes = ["Crossbow", "Bow"];
		this.m.DirectDamageMult = 0.50;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 8; _properties.DamageDirectAdd += 0.20; _properties.DamageArmorMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.wxShootBowAt(_user, target);
		return hit;
	}
});
