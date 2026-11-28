// Active Move: 修罗饮血斩
this.wx_saber_xuehai <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_xuehai";
		this.m.Name = "修罗饮血斩";
		this.m.Description = "凶厉魔道血刀绝技：消耗 5 AP 与 22 内息，自身伤势愈重刀威愈盛，斩中血肉可汲取生机回复最多 12 点气血。";
		this.m.Icon = "skills/wx_saber_xuehai.png";
		this.m.IconDisabled = "skills/wx_saber_xuehai_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_xuehai";
		this.m.WX_VfxBrush <- "wx_vfx_06";
		this.m.WX_AnimID <- "wx_anim_04";
		this.m.WX_AnimMode <- "blood_siphon";
		this.m.WX_ChoreoID <- "wx_saber_xuehai";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Sword"];
		this.m.DirectDamageMult = 0.32;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			local actor = this.getContainer().getActor();
			if (actor != null && actor.getHitpointsMax() > 0)
			{
				local lost = 1.0 - (actor.getHitpoints() / (actor.getHitpointsMax() * 1.0));
				local st = ("Streams" in ::Wuxia) ? ::Wuxia.Streams.getState(actor) : null;
				local bbBonus = st != null ? (st.m.BloodBladeStacks * 0.05) : 0.0;
				_properties.DamageTotalMult *= (1.05 + lost * 0.35 + bbBonus);
			}
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && ("Streams" in ::Wuxia))
		{
			::Wuxia.Streams.triggerBloodBlade(_user, target);
		}
		return hit;
	}
});
