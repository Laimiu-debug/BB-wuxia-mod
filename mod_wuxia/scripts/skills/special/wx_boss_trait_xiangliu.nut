// Bespoke Shan Hai Mythic Trait: 【共工凶臣·九首相柳皇】《九首食九山·所抵成苦泽》
//《海外北经》：“共工之臣曰相柳氏，九首，以食于九山。相柳之所抵，厥为泽溪。禹杀相柳，其血腥，不可以树五谷种。禹厥之，三仞三沮，乃以为众帝之台。”

this.wx_boss_trait_xiangliu <- this.inherit("scripts/skills/skill", {
	m = {
		WX_IsShanHaiBossTrait = true,
		BossKey               = "xiangliuwang",
		RegrowTicker          = 0,
		SeveredCount          = 0
	},

	function create()
	{
		this.m.ID = "special.wx_boss_trait_xiangliu";
		this.m.Name = "九首食九山·断颈化苦泽";
		this.m.Description = "《海外北经》共工凶臣九首相柳真相：盘环主躯周围探出【噬山、苦毒、惑心、生肌】四具独立凶首（共占 5 格）。斩断任意蛇首立即封印其对应凶招并反噬主躯；但若未以纯阳/烈火/火器灼封断口，腥血将把平地化为【苦毒腐泽】，且【生肌血首】存活时每 3 轮可汲干毒泽重长断首！";
		this.m.Icon = "skills/wx_neigong_wudu.png";
		this.m.IconMini = "status_effect_54_mini";
		this.m.Type = this.Const.SkillType.Special | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = false;
	}

	function getHeadSpecs()
	{
		return [
			{ Key = "crusher", Name = "相柳·噬山铁首", Hitpoints = 175, BodyArmor = 130, MeleeDef = 12, LockedSkillID = "actives.wx_boss_xiangliu_mire_ram",      Brush = "wx_part_xiangliu_iron",  RoleHint = "执掌冲抵塌陷凶招" },
			{ Key = "venom",   Name = "相柳·苦毒瘴首", Hitpoints = 155, BodyArmor = 95,  MeleeDef = 10, LockedSkillID = "actives.wx_boss_xiangliu_poison_deluge", Brush = "wx_part_xiangliu_mire",  RoleHint = "执掌全屏苦泉喷涌" },
			{ Key = "hex",     Name = "相柳·惑心妖首", Hitpoints = 145, BodyArmor = 85,  MeleeDef = 14, LockedSkillID = "actives.wx_boss_xiangliu_miasma_hex",    Brush = "wx_part_xiangliu_charm", RoleHint = "执掌腥风夺魄妖啸" },
			{ Key = "regen",   Name = "相柳·生肌血首", Hitpoints = 160, BodyArmor = 100, MeleeDef = 10, LockedSkillID = "",                                       Brush = "wx_part_xiangliu_blood", RoleHint = "维持主躯回血与断首再生" }
		];
	}

	function onCombatStarted()
	{
		this.m.RegrowTicker = 0;
		this.m.SeveredCount = 0;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null)
			::Wuxia.ShanHaiMultiBody.spawnSeverableAppendages(actor, this.getHeadSpecs());
	}

	function isRegenHeadAlive( _actor )
	{
		local rec = ::Wuxia.ShanHaiMultiBody.getRecord(_actor);
		if (rec == null) return true;
		if ("regen" in rec.SeveredParts) return false;
		if ("regen" in rec.Appendages)
		{
			local rh = rec.Appendages.regen;
			return rh != null && ::Wuxia.hasMember(rh, "isAlive") && rh.isAlive();
		}
		return true;
	}

	function onAppendageSevered( _partKey, _lockedSkillID, _cauterized, _tile )
	{
		this.m.SeveredCount += 1;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (_tile == null) return;

		if (_cauterized)
		{
			::Wuxia.TileField.setField(_tile, "drought_scorch", 3, null);
			return;
		}

		// Uncauterized neck spills foul blood (`其血腥，不可以树五谷种`), turning low ground into `bitter_mire`!
		::Wuxia.TileField.setField(_tile, "bitter_mire", 4, actor);
		if (::Wuxia.hasMember(_tile, "hasNextTile"))
		{
			local spilled = 0;
			for (local d = 0; d < 6 && spilled < 2; d = ++d)
			{
				if (!_tile.hasNextTile(d)) continue;
				local nt = _tile.getNextTile(d);
				if (nt != null && nt.Level <= _tile.Level)
				{
					::Wuxia.TileField.setField(nt, "bitter_mire", 4, actor);
					spilled += 1;
				}
			}
		}
	}

	function onTurnStart()
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		local rec = ::Wuxia.ShanHaiMultiBody.getRecord(actor);
		if (rec == null)
			rec = ::Wuxia.ShanHaiMultiBody.spawnSeverableAppendages(actor, this.getHeadSpecs());

		// Regeneration & 3-round uncauterized head regrowth if `生肌血首` survives!
		if (this.isRegenHeadAlive(actor))
		{
			local heal = 24;
			local sk = actor.getSkills();
			if (sk != null && (sk.hasSkill("effects.wx_status_poison_dart") || sk.hasSkill("effects.bleeding")))
				heal = 12;
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + heal));

			if (rec != null && rec.SeveredParts.len() > 0)
			{
				this.m.RegrowTicker += 1;
				if (this.m.RegrowTicker >= 3)
				{
					local mires = ::Wuxia.TileField.getFieldsByKind("bitter_mire");
					if (mires.len() > 0)
					{
						foreach (spec in this.getHeadSpecs())
						{
							if (::Wuxia.ShanHaiMultiBody.tryRegrowAppendage(actor, spec))
							{
								::Wuxia.TileField.removeField(mires[0].TileRef);
								this.m.RegrowTicker = 0;
								if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
									::Tactical.EventLog.log("[color=#c9382b]【汲泽生首】相柳生肌血首吸干一处苦毒腐泽，断颈处竟重新钻出一颗凶首！[/color]");
								break;
							}
						}
					}
				}
			}
		}
	}

	function onUpdate( _properties )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		local aliveHeads = actor != null ? ::Wuxia.ShanHaiMultiBody.getAliveAppendageCount(actor) : 4;
		_properties.MeleeDefense += aliveHeads * 3;
		_properties.RangedDefense += aliveHeads * 2;
		_properties.IsImmuneToDisarm = true;
	}

	function getTooltip()
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		local aliveHeads = actor != null ? ::Wuxia.ShanHaiMultiBody.getAliveAppendageCount(actor) : 4;
		local regenOk = actor != null ? this.isRegenHeadAlive(actor) : true;
		return [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 10, type = "text", icon = "ui/icons/melee_defense.png", text = "当前存活凶首：[color=#721010]" + aliveHeads + " / 4 具[/color]（护主近防 +" + (aliveHeads * 3) + "）" },
			{ id = 11, type = "text", icon = "ui/icons/health.png", text = "生肌血首状态：" + (regenOk ? "[color=#c9382b]存活（提供回血与汲泽生首）[/color]" : "[color=#166b2f]已斩灭（再生彻底断绝！）[/color]") },
			{ id = 12, type = "text", icon = "ui/icons/warning.png", text = "【破局要诀】优先集火斩断『生肌血首』与『苦毒瘴首』，以纯阳内劲/火焰刀/火器灼封断颈，抢占高台避苦泉漫灌！" }
		];
	}
});
