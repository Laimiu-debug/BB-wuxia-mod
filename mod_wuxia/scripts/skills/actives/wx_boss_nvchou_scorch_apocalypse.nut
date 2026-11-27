// Shan Hai Boss Bespoke Active (`boss_nvchou` #3): 十日同炙·赤地千里咒 (2-Beat Solar Cataclysm — Interrupted by Shooting Any Sun!)

this.wx_boss_nvchou_scorch_apocalypse <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_02",
		WX_ChoreoID = "wx_boss_nvchou_scorch_apocalypse"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_nvchou_scorch_apocalypse";
		this.m.Name = "十日同炙·赤地千里咒";
		this.m.Description = "《海外西经》生而十日炙杀之：首轮吟唱聚敛全场日冕真火（蓄咒期间我方只要射落任意 1 轮日冕即可当场破咒反噬女丑！）；次轮若未破咒则十日齐爆，焚灼全场护甲气血并化赤地千里！";
		this.m.Icon = "skills/wx_gun_huolong.png";
		this.m.IconDisabled = "skills/wx_gun_huolong_sw.png";
		this.m.Overlay = "wx_ov_wx_gun_huolong";
		this.m.SoundOnUse = ["sounds/combat/bash_02.wav"];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.IsAOE = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
	}

	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local cont = this.getContainer();
		local tr = cont != null ? cont.getSkillByID("special.wx_boss_trait_nvchou") : null;
		if (tr == null) return false;
		return tr.m.IsChargingApocalypse || tr.getAliveSunCount() > 0;
	}

	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function onUse( _user, _targetTile )
	{
		local cont = this.getContainer();
		local tr = cont != null ? cont.getSkillByID("special.wx_boss_trait_nvchou") : null;
		if (tr == null) return false;

		if (!tr.m.IsChargingApocalypse)
		{
			tr.m.IsChargingApocalypse = true;
			if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("[color=#c9382b]【十日聚火预警】女丑高举青袂引动天上日冕蓄咒——速在一回合内射落至少一轮日冕打断灭世大旱！[/color]");
			return true;
		}

		// Second beat: unleash Solar Apocalypse!
		tr.m.IsChargingApocalypse = false;
		this.m.Cooldown = 3;
		local suns = tr.getAliveSunCount();
		local hpBurn = 14 + suns * 9;
		local armBurn = 20 + suns * 6;

		if (::Wuxia.isOnMap(_user))
		{
			local actors = ::Tactical.Entities.getAllInstancesAsArray();
			foreach (ent in actors)
			{
				if (ent == null || !ent.isAlive() || !ent.isPlacedOnMap() || _user.isAlliedWith(ent)) continue;
				::Wuxia.TileField.setField(ent.getTile(), "drought_scorch", 3, _user);
				if (ent.getItems() != null)
				{
					local bArm = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (bArm != null && bArm.getArmor() > 0)
						bArm.setArmor(::Math.max(0, bArm.getArmor() - armBurn));
				}
				if (ent.getHitpoints() > hpBurn + 1) ent.setHitpoints(ent.getHitpoints() - hpBurn);
				else ent.setHitpoints(1);
			}
		}
		return true;
	}
});
