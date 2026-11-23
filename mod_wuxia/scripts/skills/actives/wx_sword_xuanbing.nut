// Active Move: 昆仑玄霜剑
this.wx_sword_xuanbing <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_xuanbing";
		this.m.Name = "昆仑玄霜剑";
		this.m.Description = "西域昆仑极寒剑气：消耗 5 AP 与 22 内息，剑锋凝结玄霜刺骨（命中 +8，附加寒毒蚀脉并压制目标 12 点内息）。";
		this.m.Icon = "skills/wx_sword_xuanbing.png";
		this.m.IconDisabled = "skills/wx_sword_xuanbing_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_xuanbing";
		this.m.WX_VfxBrush <- "wx_vfx_10";
		this.m.WX_AnimID <- "wx_anim_80";
		this.m.WX_AnimMode <- "upcut_xuanbing";
		this.m.WX_ChoreoID <- "wx_sword_xuanbing";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
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
			_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) { target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 12)); this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart"); }
		}
		return hit;
	}
});
