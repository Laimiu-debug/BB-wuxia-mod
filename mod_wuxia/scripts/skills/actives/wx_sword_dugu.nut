// Sword Stream Flagship Move #3: 破刃荡剑式 · 独孤六式识兵破招 (`破盾/破枪/破刀剑/破箭/破鞭掌/破气`)

this.wx_sword_dugu <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_dugu";
		this.m.Name = "破刃荡剑式";
		this.m.Description = "剑冢独孤遗脉『洞悉百兵』神技：消耗 5 AP 与 22 内息，出剑瞬间自动看破目标所持兵装与体态，化为【破盾/破枪/破刀剑/破箭/破鞭掌/破气】六式之一针对拆招！";
		this.m.Icon = "skills/wx_sword_dugu.png";
		this.m.IconDisabled = "skills/wx_sword_dugu_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_dugu";
		this.m.WX_VfxBrush <- "wx_vfx_07";
		this.m.WX_AnimID <- "wx_anim_40";
		this.m.WX_AnimMode <- "disarm_arc";
		this.m.WX_ChoreoID <- "wx_sword_dugu";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
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
			if (_targetEntity != null && ("Streams" in ::Wuxia))
			{
				local info = ::Wuxia.Streams.inspectDuguTarget(_targetEntity);
				_properties.MeleeSkill += info.HitBonus;
				if (info.PenBonus > 0.0)
				{
					// Respect AGENTS.md global +25% extra armor pen ceiling!
					local room = ::Math.maxf(0.0, 0.25 - _properties.DamageDirectAdd);
					_properties.DamageDirectAdd += ::Math.minf(room, info.PenBonus);
				}
			}
			else
			{
				_properties.MeleeSkill += 12;
			}
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		local info = ("Streams" in ::Wuxia) ? ::Wuxia.Streams.inspectDuguTarget(target) : null;
		local prevShieldRel = this.m.IsShieldRelevant;
		if (info != null && info.IgnoreShield)
			this.m.IsShieldRelevant = false;

		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = false;
		try { hit = this.attackEntity(_user, target); }
		catch (_e) { this.m.IsShieldRelevant = prevShieldRel; throw _e; }
		this.m.IsShieldRelevant = prevShieldRel;

		if (hit && target != null && target.isAlive() && info != null)
		{
			local tsk = target.getSkills();
			if (tsk != null)
			{
				tsk.removeByID("effects.shieldwall");
				tsk.removeByID("effects.spearwall");
				tsk.removeByID("effects.riposte");
				tsk.removeByID("effects.wx_status_counter_stance");
			}
			local fk = info.FormKey;
			if (fk == "shield")
			{
				if (target.getItems() != null)
				{
					local off = target.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
					if (off != null && ::Wuxia.hasMember(off, "isItemType") && off.isItemType(::Const.Items.ItemType.Shield))
						off.applyShieldDamage(35);
				}
				this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (fk == "polearm" || fk == "blade")
			{
				this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
				this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
			else if (fk == "ranged")
			{
				if (target.getItems() != null)
				{
					local mw = target.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
					if (mw != null && ::Wuxia.hasMember(mw, "setLoaded"))
						mw.setLoaded(false);
				}
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
					::Wuxia.CombatRules.spendQi(target, 14);
				this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			else if (fk == "whip_fist")
			{
				if (target.getItems() != null)
				{
					local bArm = target.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (bArm != null && bArm.getArmor() > 0)
						bArm.setArmor(::Math.max(0, bArm.getArmor() - 20));
				}
				this.wxApplyStatusToTarget(target, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
			}
			else // `qi_beast` (`破气式`)
			{
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
					::Wuxia.CombatRules.spendQi(target, 20);
				this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}

			if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("[color=#127896]【独孤·" + info.FormName + "】" + ::Const.UI.getColorizedEntityName(_user) + " 一剑看破 " + ::Const.UI.getColorizedEntityName(target) + " 招路破绽！[/color]");
		}
		return hit;
	}
});
