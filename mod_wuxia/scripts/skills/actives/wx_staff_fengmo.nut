// Active Move: 紧那罗伏魔棍
this.wx_staff_fengmo <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_staff_fengmo";
		this.m.Name = "紧那罗伏魔棍";
		this.m.Description = "少室护法疯魔重棍：消耗 6 AP 与 25 内息，混铁棍挟烈火当头猛砸（总伤 +22%，破甲 +32%，震伤内腑）。";
		this.m.Icon = "skills/wx_staff_fengmo.png";
		this.m.IconDisabled = "skills/wx_staff_fengmo_sw.png";
		this.m.Overlay = "wx_ov_wx_staff_fengmo";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_118";
		this.m.WX_AnimMode <- "sky_fengmo";
		this.m.WX_ChoreoID <- "wx_staff_fengmo";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 25;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Staff"];
		this.m.DirectDamageMult = 0.35;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			local actor = this.getContainer().getActor();
			local st = (actor != null && "Streams" in ::Wuxia) ? ::Wuxia.Streams.getState(actor) : null;
			local fm = st != null ? st.m.FengmoStacks : 0;
			_properties.MeleeSkill += (8 + fm * 3);
			_properties.DamageTotalMult *= (1.22 + fm * 0.04);
			_properties.DamageArmorMult *= (1.32 + fm * 0.08);
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit)
		{
			if ("Streams" in ::Wuxia)
			{
				local st = ::Wuxia.Streams.getOrCreateState(_user);
				if (st != null) st.addFengmo(1);
				if (target != null && target.isAlive())
					::Wuxia.Streams.interruptEnemyCharge(_user, target, 2);
			}
			if (target != null && target.isAlive())
				this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
		}
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
