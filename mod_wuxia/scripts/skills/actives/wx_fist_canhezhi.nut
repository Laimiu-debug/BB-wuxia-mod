// Active Move: 参合截脉指
this.wx_fist_canhezhi <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_canhezhi";
		this.m.Name = "参合截脉指";
		this.m.Description = "姑苏凌空指劲绝学：消耗 5 AP 与 20 内息，隔空两格弹出无形剑气指风（命中 +10，总伤 90%，穿甲 +12%，封穴截脉）。";
		this.m.Icon = "skills/wx_fist_canhezhi.png";
		this.m.IconDisabled = "skills/wx_fist_canhezhi_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_canhezhi";
		this.m.WX_VfxBrush <- "wx_vfx_12";
		this.m.WX_AnimID <- "wx_anim_105";
		this.m.WX_AnimMode <- "pierce_canhezhi";
		this.m.WX_ChoreoID <- "wx_fist_canhezhi";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.40;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			_properties.MeleeSkill += 10;
			_properties.DamageTotalMult *= 0.90;
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.addCappedPen(_properties, 0.12);
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.interruptEnemyCharge(_user, target, 2);
		}
		return hit;
	}
});
