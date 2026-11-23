// Active Move: 黑水裂山爪
this.wx_fist_xiongzhao <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_xiongzhao";
		this.m.Name = "黑水裂山爪";
		this.m.Description = "塞北蛮荒搏熊霸爪：消耗 5 AP 与 21 内息，双爪撕天重创血肉（总伤 +22%，击头率 +15%，致敌流血）。";
		this.m.Icon = "skills/wx_fist_xiongzhao.png";
		this.m.IconDisabled = "skills/wx_fist_xiongzhao_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_xiongzhao";
		this.m.WX_VfxBrush <- "wx_vfx_11";
		this.m.WX_AnimID <- "wx_anim_104";
		this.m.WX_AnimMode <- "sky_xiongzhao";
		this.m.WX_ChoreoID <- "wx_fist_xiongzhao";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 21;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.38;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageTotalMult *= 1.22; _properties.HitChance[::Const.BodyPart.Head] += 15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect");
		}
		return hit;
	}
});
