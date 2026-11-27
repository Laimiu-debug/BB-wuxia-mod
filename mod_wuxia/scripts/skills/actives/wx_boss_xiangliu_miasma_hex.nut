// Shan Hai Boss Bespoke Active (`boss_xiangliuwang` #4): 腥风夺魄·九首妖啸 (3-Hex Soul Hex — Locked when `惑心妖首` is Severed!)

this.wx_boss_xiangliu_miasma_hex <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_30",
		WX_ChoreoID = "wx_boss_xiangliu_miasma_hex"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_xiangliu_miasma_hex";
		this.m.Name = "腥风夺魄·九首妖啸";
		this.m.Description = "催动【惑心妖首】吐出腥臭迷魂瘴雾：震慑 3 格内敌军定力（检定失败陷入动摇、散劲虚弱与破绽），并在外围布下迷障（斩断『惑心妖首』即可封印此招！）。";
		this.m.Icon = "skills/wx_smoke_cast.png";
		this.m.IconDisabled = "skills/wx_smoke_cast_sw.png";
		this.m.Overlay = "wx_ov_wx_smoke_cast";
		this.m.SoundOnUse = ["sounds/combat/bash_01.wav"];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.IsAOE = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 15;
	}

	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null && ::Wuxia.ShanHaiMultiBody.isSkillLocked(actor, this.m.ID))
			return false;
		return true;
	}

	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 3;
		if (!::Wuxia.isOnMap(_user)) return true;
		local myTile = _user.getTile();
		local actors = ::Tactical.Entities.getAllInstancesAsArray();
		foreach (ent in actors)
		{
			if (ent == null || !ent.isAlive() || !ent.isPlacedOnMap() || _user.isAlliedWith(ent)) continue;
			local d = myTile.getDistanceTo(ent.getTile());
			if (d > 3) continue;
			::Wuxia.TileField.setField(ent.getTile(), "mirage_mist", 2, _user);
			ent.checkMorale(-1, -12, ::Const.MoraleCheckType.MentalAttack);
			local sk = ent.getSkills();
			if (sk != null && ent.getCurrentProperties().Bravery < 72)
			{
				if (!sk.hasSkill("effects.wx_scatter_weakness"))
					sk.add(::new("scripts/skills/effects/wx_scatter_weakness"));
				if (!sk.hasSkill("effects.wx_status_opening"))
					sk.add(::new("scripts/skills/effects/wx_status_opening"));
			}
		}
		return true;
	}
});
