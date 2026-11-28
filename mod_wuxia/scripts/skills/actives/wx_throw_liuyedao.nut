// Active Move: 寒星追命镖
this.wx_throw_liuyedao <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_throw_liuyedao";
		this.m.Name = "寒星追命镖";
		this.m.Description = "唐门子母柳叶飞刀绝技：消耗 4 AP 与 16 内息，甩手三把柳叶寒刃直取咽喉（射程 2~4 格，射艺 +12，击头率 +15%，流血）。";
		this.m.Icon = "skills/wx_throw_liuyedao.png";
		this.m.IconDisabled = "skills/wx_throw_liuyedao_sw.png";
		this.m.Overlay = "wx_ov_wx_throw_liuyedao";
		this.m.WX_VfxBrush <- "wx_vfx_27";
		this.m.WX_AnimID <- "wx_anim_169";
		this.m.WX_AnimMode <- "flurry_liuyedao";
		this.m.WX_ChoreoID <- "wx_throw_liuyedao";
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Liuyefeidao;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.SoundOnUse = ["sounds/combat/javelin_throw_01.wav", "sounds/combat/javelin_throw_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 2;
		this.m.MaxRange = 4;
		this.m.MaxLevelDifference = 4;
		this.m.RequiredWeaponTypes = ["Throwing"];
		this.m.DirectDamageMult = 0.42;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 12; _properties.HitChance[::Const.BodyPart.Head] += 15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.wxThrowAt(_user, target);
		if (hit)
		{
			if (target != null && target.isAlive() && !::Wuxia.CombatRules.isUndeadOrConstruct(target))
				this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect");
			if ("Streams" in ::Wuxia)
				::Wuxia.Streams.plantTangmenCaltrop(_user, _targetTile);
		}
		return hit;
	}
});
