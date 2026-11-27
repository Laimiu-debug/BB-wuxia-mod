// Active Move: 铁线破甲拳
this.wx_fist_tiegang <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_tiegang";
		this.m.Name = "铁线破甲拳";
		this.m.Description = "外家硬桥硬马重拳：消耗 4 AP 与 14 内息，桥手如铁正面轰击胸甲（破甲 +26%，穿甲 +10%）。";
		this.m.Icon = "skills/wx_fist_tiegang.png";
		this.m.IconDisabled = "skills/wx_fist_tiegang_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_tiegang";
		this.m.WX_VfxBrush <- "wx_vfx_14";
		this.m.WX_AnimID <- "wx_anim_107";
		this.m.WX_AnimMode <- "pierce_tiegang";
		this.m.WX_ChoreoID <- "wx_fist_tiegang";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 14;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.36;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			_properties.MeleeSkill += 6;
			_properties.DamageArmorMult *= 1.26;
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.addCappedPen(_properties, 0.10);
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive() && ("Streams" in ::Wuxia))
		{
			::Wuxia.Streams.applyHiddenForce(target, 1, _user);
		}
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
