// Active Move: 洞庭翻江斩
this.wx_saber_zhanlang <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_zhanlang";
		this.m.Name = "洞庭翻江斩";
		this.m.Description = "水寨惊涛阔刀猛斩：消耗 5 AP 与 20 内息，刀卷巨浪将敌手劈退一格并震至失衡（命中 +7，总伤 +14%）。";
		this.m.Icon = "skills/wx_saber_zhanlang.png";
		this.m.IconDisabled = "skills/wx_saber_zhanlang_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_zhanlang";
		this.m.WX_VfxBrush <- "wx_vfx_21";
		this.m.WX_AnimID <- "wx_anim_95";
		this.m.WX_AnimMode <- "upcut_zhanlang";
		this.m.WX_ChoreoID <- "wx_saber_zhanlang";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.28;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 7; _properties.DamageTotalMult *= 1.14;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxTryKnockback(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
