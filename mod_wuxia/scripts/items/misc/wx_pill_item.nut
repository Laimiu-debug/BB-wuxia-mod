// Generic Wuxia Pill Item (data-driven from ::Wuxia.Config.Pills; usable both in Inventory and Wuxia Panel)
// Supports 3 Alchemy Grades (`成丹 / 灵纹 / 丹霞`), Potency Scaling (`92%..155%`) & 6 Auxiliary Herb Nature Infusions (`药引丹韵`)
// with 100% backward-compatible single-string save serialization (`"PillID"` or `"PillID|Grade|PotencyPct|AuxNature"`)!

this.wx_pill_item <- this.inherit("scripts/items/item", {
	m = {
		PillID     = "wx_pill_huxin",
		PillGrade  = 1,
		PotencyPct = 100,
		AuxNature  = ""
	},

	function create()
	{
		this.item.create();
		this.m.ID = "misc.wx_pill_item";
		this.m.Name = "江湖丹药";
		this.m.Description = "武林丹药。";
		this.m.Icon = "consumables/wx_pill_huxin.png";
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsUsable = true;
		this.m.Value = 300;
	}

	function initPill( _pillID )
	{
		this.m.PillID = _pillID;
		this.m.PillGrade = 1;
		this.m.PotencyPct = 100;
		this.m.AuxNature = "";
		this.refreshFromConfig();
	}

	function initPillVariant( _pillID, _grade = 1, _potencyPct = 100, _auxNature = "" )
	{
		this.m.PillID = _pillID;
		this.m.PillGrade = ::Math.max(1, ::Math.min(3, _grade));
		this.m.PotencyPct = ::Math.max(80, ::Math.min(170, _potencyPct));
		this.m.AuxNature = (_auxNature != null) ? _auxNature : "";
		this.refreshFromConfig();
	}

	function getPillID()
	{
		return this.m.PillID;
	}

	function getPillGrade()
	{
		return this.m.PillGrade;
	}

	function getPotencyPct()
	{
		return this.m.PotencyPct;
	}

	function getAuxNature()
	{
		return this.m.AuxNature;
	}

	function getGradeSpec()
	{
		if ("Alchemy" in ::Wuxia.Config && "PillGrades" in ::Wuxia.Config.Alchemy && (this.m.PillGrade in ::Wuxia.Config.Alchemy.PillGrades))
			return ::Wuxia.Config.Alchemy.PillGrades[this.m.PillGrade];
		return { Grade = 1, Title = "成丹", Prefix = "", Color = "#d7b174", TooltipColor = "#3f362a", ValueMult = 1.0, WashBonus = 0, ProtectBonus = 0 };
	}

	function getAuxSpec()
	{
		if (this.m.AuxNature != "" && "Alchemy" in ::Wuxia.Config && "AuxInfusions" in ::Wuxia.Config.Alchemy && (this.m.AuxNature in ::Wuxia.Config.Alchemy.AuxInfusions))
			return ::Wuxia.Config.Alchemy.AuxInfusions[this.m.AuxNature];
		return null;
	}

	function getEffectiveExpAmount()
	{
		if (!(this.m.PillID in ::Wuxia.Config.Pills)) return 0;
		local def = ::Wuxia.Config.Pills[this.m.PillID];
		if (!("ExpAmount" in def)) return 0;
		return ::Math.max(10, ::Math.round(def.ExpAmount * this.m.PotencyPct / 100.0).tointeger());
	}

	function getWashGradeBonus()
	{
		return this.getGradeSpec().WashBonus;
	}

	function getProtectGradeBonus()
	{
		return this.getGradeSpec().ProtectBonus;
	}

	function checkAuxManualResonance( _manualDef )
	{
		if (_manualDef == null || this.m.AuxNature == "") return false;
		local an = this.m.AuxNature;
		if (an == "origin") return (_manualDef.Quality == "secret" || _manualDef.Quality == "unique");
		if (an == "vital")  return (_manualDef.Category == "henglian");
		if (an == "yang")   return (_manualDef.Category == "waigong" || (_manualDef.Category == "neigong" && _manualDef.Element == "yang"));
		if (an == "yin")    return (_manualDef.Category == "qinggong" || (_manualDef.Category == "neigong" && _manualDef.Element == "yin"));
		if (an == "spirit") return (_manualDef.Category == "henglian" || _manualDef.Category == "tactics" || (_manualDef.Category == "neigong" && (_manualDef.Element == "neutral" || _manualDef.Element == "harmony")));
		if (an == "venom")  return (_manualDef.Category == "henglian" || _manualDef.Category == "tactics" || (_manualDef.Category == "neigong" && _manualDef.Element == "evil"));
		return false;
	}

	function getInfuseExpForSlot( _actor, _slotIndex )
	{
		local baseAmt = this.getEffectiveExpAmount();
		local note = "";
		if (this.m.PillGrade >= 2)
			note = "（" + this.getGradeSpec().Title + "药效 " + this.m.PotencyPct + "%）";

		if (_actor != null && _actor.getSkills() != null && this.m.AuxNature != "")
		{
			local c = _actor.getSkills().getSkillByID("special.wx_martial_container");
			if (c != null && _slotIndex >= 0 && _slotIndex < c.m.Slots.len() && c.m.Slots[_slotIndex].ManualID != null)
			{
				local mdef = ::Wuxia.Slots.getManualDef(c.m.Slots[_slotIndex].ManualID);
				if (this.checkAuxManualResonance(mdef))
				{
					baseAmt = ::Math.round(baseAmt * 1.15).tointeger();
					local aux = this.getAuxSpec();
					note = "（" + this.getGradeSpec().Title + " " + this.m.PotencyPct + "% + " + (aux != null ? aux.Title : "药引") + "共鸣 +15%！）";
				}
			}
		}
		return { ExpAmount = baseAmt, Note = note };
	}

	function getAuxContextLine( _kind )
	{
		local aux = this.getAuxSpec();
		if (aux == null) return "";
		if (_kind == "infuse_exp") return aux.InfuseDesc;
		if (_kind != null && (_kind.find("buff_") == 0 || _kind == "heal_internal_plus")) return aux.PrepDesc;
		if (_kind != null && _kind.find("heal_") == 0) return aux.HealDesc;
		return aux.PrepDesc;
	}

	function getRichDescription()
	{
		if (!(this.m.PillID in ::Wuxia.Config.Pills)) return this.m.Description;
		local def = ::Wuxia.Config.Pills[this.m.PillID];
		local extra = [];
		if (this.m.PillGrade >= 2 || this.m.PotencyPct != 100)
		{
			local g = this.getGradeSpec();
			extra.push("【" + g.Title + " · 药效 " + this.m.PotencyPct + "%】");
		}
		local aux = this.getAuxSpec();
		if (aux != null)
		{
			extra.push("【" + aux.Title + "：" + this.getAuxContextLine(def.Kind) + "】");
		}
		if (extra.len() == 0) return def.Description;
		local prefix = extra[0] + (extra.len() > 1 ? (" " + extra[1]) : "") + " ";
		return prefix + def.Description;
	}

	function isDirectConsumeKind( _kind )
	{
		if (_kind == null) return false;
		return _kind.find("heal_") == 0 || _kind.find("buff_") == 0;
	}

	function refreshFromConfig()
	{
		if (!(this.m.PillID in ::Wuxia.Config.Pills)) return;
		local def = ::Wuxia.Config.Pills[this.m.PillID];
		local gSpec = this.getGradeSpec();
		this.m.Name = gSpec.Prefix + def.Name;
		this.m.Description = def.Description;
		this.m.Icon = def.Icon;
		local auxBonusMult = (this.m.AuxNature != "") ? 1.08 : 1.0;
		this.m.Value = ::Math.round(def.Value * gSpec.ValueMult * auxBonusMult).tointeger();
		this.m.IsUsable = this.isDirectConsumeKind(def.Kind);
	}

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		if (this.m.PillID in ::Wuxia.Config.Pills)
		{
			local def = ::Wuxia.Config.Pills[this.m.PillID];
			local qLabel = ("Quality" in def && def.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[def.Quality] : "丹药";
			local sub = ("SubLabel" in def) ? def.SubLabel : "江湖灵药";
			local gSpec = this.getGradeSpec();
			local isPreview = ("WX_IsBlueprintPreview" in this.m) && this.m.WX_IsBlueprintPreview;

			local gCol = ("TooltipColor" in gSpec) ? gSpec.TooltipColor : gSpec.Color;
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/special.png",
				text = "丹药品阶：【" + qLabel + " · " + sub + "】" +
					((!isPreview && (this.m.PillGrade >= 2 || this.m.PotencyPct != 100))
						? ("  [color=" + gCol + "]（" + gSpec.Title + " · 药效 " + this.m.PotencyPct + "%）[/color]")
						: "")
			});

			if (isPreview)
			{
				local rangeHint = "药效浮动 92% ~ 155%";
				if (def.Kind == "infuse_exp")
				{
					local loE = ::Math.round(def.ExpAmount * 0.92).tointeger();
					local hiE = ::Math.round(def.ExpAmount * 1.55).tointeger();
					rangeHint = "灌注火候区间 [color=#0a4213]+" + loE + " ~ +" + hiE + "[/color]";
				}
				else if (def.Kind != null && def.Kind.find("marrow_wash") == 0)
					rangeHint = "灵纹成功率额外 [color=#0a4213]+4%[/color]，丹霞极品额外 [color=#5e2c00]+8%[/color]";
				else if (def.Kind == "wash_protect")
					rangeHint = "灵纹护脉额外 [color=#0a4213]+2%[/color]，丹霞极品额外 [color=#5e2c00]+5%[/color] 且减轻震荡";
				else if (def.Kind != null && def.Kind.find("buff_") == 0)
					rangeHint = "备战主药效可提升至 [color=#5e2c00]155%[/color]，且【丹霞】极品免第 3 丹丹毒与内伤反噬";

				ret.push({
					id = 18,
					type = "text",
					icon = "ui/icons/xp_received.png",
					text = "[color=#533200]【开炉丹纹品相】[/color]随机凝出 成丹 / [color=#0a4213]灵纹[/color] / [color=#5e2c00]丹霞极品[/color]（" + rangeHint + "）"
				});
			}
			else
			{
				local aux = this.getAuxSpec();
				if (aux != null)
				{
					local auxCol = ("TooltipColor" in aux) ? aux.TooltipColor : aux.Color;
					ret.push({
						id = 18,
						type = "text",
						icon = "ui/icons/special.png",
						text = "[color=" + auxCol + "]【" + aux.Title + "】[/color]" + this.getAuxContextLine(def.Kind)
					});
				}
				if (this.m.PillGrade >= 3 && def.Kind != null && def.Kind.find("buff_") == 0)
				{
					ret.push({
						id = 19,
						type = "text",
						icon = "ui/icons/health.png",
						text = "[color=#5e2c00]【丹霞无瑕】[/color]药力纯粹圆融：作为第 3 枚备战丹服食不致「丹毒郁结」，且免除疯魔内伤反噬！"
					});
				}
				else if ((this.m.PillGrade >= 2) && (def.Kind != null && (def.Kind.find("marrow_wash") == 0 || def.Kind == "wash_protect")))
				{
					local wb = (def.Kind == "wash_protect") ? this.getProtectGradeBonus() : this.getWashGradeBonus();
					ret.push({
						id = 19,
						type = "text",
						icon = "ui/icons/bravery.png",
						text = "[color=" + gCol + "]【" + gSpec.Title + "神效】[/color]洗经伐髓启用此丹时，成功率额外再 [color=#0a4213]+" + wb + "%[/color]！"
					});
				}
			}

			if (def.Kind == "infuse_exp")
			{
				ret.push({
					id = 16,
					type = "text",
					icon = "ui/icons/xp_received.png",
					text = "修为灌注：拖入武学插槽立即增加 [color=" + ::Const.UI.Color.PositiveValue + "]+" + this.getEffectiveExpAmount() + "[/color] 火候"
				});
			}
			else if (this.isDirectConsumeKind(def.Kind))
			{
				ret.push({
					id = 16,
					type = "text",
					icon = "ui/icons/health.png",
					text = "用法：可在行囊右键直接给角色服药，或在「武学修为 → 灵丹」页点击一键服用"
				});
			}
			else if (def.Kind == "marrow_wash" || def.Kind == "wash_protect")
			{
				ret.push({
					id = 16,
					type = "text",
					icon = "ui/icons/bravery.png",
					text = "用法：在「武学修为」页点击「✦ 洗经伐髓」即可启用（优先消耗最高品相灵丹）"
				});
			}
		}
		return ret;
	}

	function applyAuxHealBonus( _actor, _skills )
	{
		local notes = [];
		local an = this.m.AuxNature;
		if (an == "") return "";
		local hpBonus = 0;
		if (an == "vital")  hpBonus = 20;
		else if (an == "origin") hpBonus = 30;
		else if (an == "yang" || an == "spirit") hpBonus = 15;

		if (hpBonus > 0 && _actor.getHitpoints() < _actor.getHitpointsMax())
		{
			local gain = ::Math.min(hpBonus, _actor.getHitpointsMax() - _actor.getHitpoints());
			_actor.setHitpoints(_actor.getHitpoints() + gain);
			notes.push("药引回血+" + gain);
		}
		if (an == "yin")
		{
			local sc = _skills.getSkillByID("effects.wx_scatter_weakness");
			if (sc != null && sc.m.DaysRemaining > 0)
			{
				sc.m.DaysRemaining -= 1;
				if (sc.m.DaysRemaining <= 0) _skills.removeByID("effects.wx_scatter_weakness");
				notes.push("玄阴减调息1日");
			}
			local inj = _skills.getSkillByID("effects.wx_internal_injury");
			if (inj != null && inj.m.DaysRemaining > 0)
			{
				inj.m.DaysRemaining -= 1;
				if (inj.m.DaysRemaining <= 0) inj.cureTemporary();
				notes.push("玄阴减内伤1日");
			}
		}
		if (an == "venom")
		{
			local extraWounds = _skills.getAllSkillsOfType(::Const.SkillType.TemporaryInjury);
			if (extraWounds.len() > 0)
			{
				extraWounds[0].removeSelf();
				notes.push("奇毒拔额外1处外伤");
			}
		}
		if (notes.len() == 0) return "";
		return "（" + notes[0] + (notes.len() > 1 ? ("、" + notes[1]) : "") + "）";
	}

	function applyToActorWithMessage( _actor )
	{
		if (_actor == null || !(this.m.PillID in ::Wuxia.Config.Pills))
			return { Ok = false, Reason = "无效的侠客或丹药配置。" };

		local def = ::Wuxia.Config.Pills[this.m.PillID];
		local skills = _actor.getSkills();
		if (skills == null)
			return { Ok = false, Reason = "无法读取角色状态。" };

		local pMult = this.m.PotencyPct / 100.0;

		if (def.Kind == "heal_internal")
		{
			local cured = [];
			if (skills.hasSkill("effects.wx_scatter_weakness"))
			{
				skills.removeByID("effects.wx_scatter_weakness");
				cured.push("散功虚弱");
			}
			local inj = skills.getSkillByID("effects.wx_internal_injury");
			if (inj != null && inj.m.Severity > 0)
			{
				cured.push(inj.m.Severity >= 2 ? "经脉震荡" : "内伤");
				inj.cureTemporary();
			}
			if (cured.len() == 0)
				return { Ok = false, Reason = _actor.getName() + " 当前并无散功虚弱或临时内伤，无需耗费护心丹。" };

			local gradeHeal = (this.m.PillGrade >= 3) ? 30 : ((this.m.PillGrade == 2) ? 16 : 0);
			if (gradeHeal > 0 && _actor.getHitpoints() < _actor.getHitpointsMax())
				_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + gradeHeal));
			local auxNote = this.applyAuxHealBonus(_actor, skills);
			skills.update();
			return {
				Ok = true,
				Message = _actor.getName() + " 服下「" + this.m.Name + "」，成功化解：" + cured[0] + (cured.len() > 1 ? ("、" + cured[1]) : "") +
					(gradeHeal > 0 ? ("，丹纹温养回血 +" + gradeHeal) : "") + auxNote + "！"
			};
		}

		if (def.Kind == "heal_internal_plus")
		{
			local cured2 = [];
			if (skills.hasSkill("effects.wx_scatter_weakness"))
			{
				skills.removeByID("effects.wx_scatter_weakness");
				cured2.push("散功虚弱");
			}
			local inj2 = skills.getSkillByID("effects.wx_internal_injury");
			if (inj2 != null && inj2.m.Severity > 0)
			{
				cured2.push(inj2.m.Severity >= 2 ? "经脉震荡" : "内伤");
				inj2.cureTemporary();
			}
			local buff = skills.getSkillByID("effects.wx_pill_battle_buff");
			local firstBattleEffect = buff == null;
			local alreadyBuff = (buff != null && buff.hasBuffKind("buff_bingxin"));
			if (cured2.len() == 0 && alreadyBuff)
				return { Ok = false, Reason = _actor.getName() + " 当前经脉清净且已有冰心药力护持。" };
			if (buff == null)
			{
				buff = ::new("scripts/skills/effects/wx_pill_battle_buff");
				skills.add(buff);
			}
			buff.addPillBuff("buff_bingxin");
			if ("applyPillPotencyAndAux" in buff)
				buff.applyPillPotencyAndAux(this.m.PotencyPct, this.m.AuxNature, false, firstBattleEffect);
			local auxNote2 = this.applyAuxHealBonus(_actor, skills);
			skills.update();
			return { Ok = true, Message = _actor.getName() + " 服下「" + this.m.Name + "」，涤清内患并获下场战斗冰心辟毒药力" + auxNote2 + "！" };
		}

		if (def.Kind == "heal_external")
		{
			local wounds = skills.getAllSkillsOfType(::Const.SkillType.TemporaryInjury);
			if (wounds.len() == 0)
				return { Ok = false, Reason = _actor.getName() + " 当前并无临时外伤，无需耗费金疮散。" };
			local maxCure = (this.m.PillGrade >= 3) ? 2 : 1;
			local curedNames = [];
			for (local wi = 0; wi < wounds.len() && curedNames.len() < maxCure; wi = ++wi)
			{
				curedNames.push(wounds[wi].getName());
				wounds[wi].removeSelf();
			}
			if (this.m.PillGrade >= 2 && _actor.getHitpoints() < _actor.getHitpointsMax())
				_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + (this.m.PillGrade >= 3 ? 25 : 12)));
			local auxNote3 = this.applyAuxHealBonus(_actor, skills);
			skills.update();
			return { Ok = true, Message = _actor.getName() + " 敷服「" + this.m.Name + "」，外伤「" + curedNames[0] + (curedNames.len() > 1 ? ("、" + curedNames[1]) : "") + "」当场痊愈" + auxNote3 + "！" };
		}

		if (def.Kind == "heal_external_plus" || def.Kind == "heal_all_wounds")
		{
			local wounds2 = skills.getAllSkillsOfType(::Const.SkillType.TemporaryInjury);
			local maxWounds = (def.Kind == "heal_all_wounds") ? 99 : (2 + (this.m.PillGrade - 1));
			local baseHeal  = (def.Kind == "heal_all_wounds") ? 65 : 35;
			local maxHeal   = ::Math.round(baseHeal * pMult).tointeger();
			local healedCnt = 0;
			for (local i = 0; i < wounds2.len() && healedCnt < maxWounds; i = ++i)
			{
				wounds2[i].removeSelf();
				healedCnt += 1;
			}
			local hpNeed = ::Math.max(0, _actor.getHitpointsMax() - _actor.getHitpoints());
			local hpGain = ::Math.min(maxHeal, hpNeed);
			if (healedCnt == 0 && hpGain <= 0)
				return { Ok = false, Reason = _actor.getName() + " 当前既无外伤且气血充盈，无需使用「" + this.m.Name + "」。" };
			if (hpGain > 0)
				_actor.setHitpoints(_actor.getHitpoints() + hpGain);
			local auxNote4 = this.applyAuxHealBonus(_actor, skills);
			skills.update();
			return {
				Ok = true,
				Message = _actor.getName() + " 敷用「" + this.m.Name + "」" +
					(healedCnt > 0 ? ("，解除 " + healedCnt + " 处外伤") : "") +
					(hpGain > 0 ? ("，恢复 " + hpGain + " 点气血") : "") + auxNote4 + "！"
			};
		}

		if (def.Kind == "heal_full_recovery")
		{
			local wounds3 = skills.getAllSkillsOfType(::Const.SkillType.TemporaryInjury);
			local wCnt = wounds3.len();
			foreach (w in wounds3) w.removeSelf();
			local curedIn = false;
			if (skills.hasSkill("effects.wx_scatter_weakness"))
			{
				skills.removeByID("effects.wx_scatter_weakness");
				curedIn = true;
			}
			local inj3 = skills.getSkillByID("effects.wx_internal_injury");
			if (inj3 != null && inj3.m.Severity > 0)
			{
				inj3.cureTemporary();
				curedIn = true;
			}
			local hpDiff = ::Math.max(0, _actor.getHitpointsMax() - _actor.getHitpoints());
			if (wCnt == 0 && !curedIn && hpDiff <= 0)
				return { Ok = false, Reason = _actor.getName() + " 当前气血完满、内外无伤，无需耗费神农百草返魂丹。" };
			_actor.setHitpoints(_actor.getHitpointsMax());
			skills.update();
			return { Ok = true, Message = _actor.getName() + " 服下「" + this.m.Name + "」，内外伤患一扫而空，气血彻底盈满！" };
		}

		if (def.Kind.find("buff_") == 0)
		{
			local buff2 = skills.getSkillByID("effects.wx_pill_battle_buff");
			local firstBattleEffect = buff2 == null;
			if (buff2 != null && buff2.hasBuffKind(def.Kind))
				return { Ok = false, Reason = _actor.getName() + " 体内已有「" + def.Name + "」药力流转，无需重复服食。" };
			if (buff2 == null)
			{
				buff2 = ::new("scripts/skills/effects/wx_pill_battle_buff");
				skills.add(buff2);
			}
			buff2.addPillBuff(def.Kind);
			if ("applyPillPotencyAndAux" in buff2)
			{
				local waiveFengmo = (def.Kind == "buff_fengmo" && this.m.PillGrade >= 3);
				buff2.applyPillPotencyAndAux(this.m.PotencyPct, this.m.AuxNature, waiveFengmo, firstBattleEffect);
			}
			if (this.m.AuxNature == "vital" && _actor.getHitpoints() < _actor.getHitpointsMax())
			{
				_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + 15));
			}
			if ((def.Kind == "buff_hugu" || def.Kind == "buff_zhuyu") && _actor.getHitpoints() < _actor.getHitpointsMax())
			{
				_actor.setHitpoints(_actor.getHitpointsMax());
			}
			else if (def.Kind == "buff_guiyuan")
			{
				skills.update();
				local healG = ::Math.round(40 * pMult).tointeger();
				_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + healG));
				return { Ok = true, Message = _actor.getName() + " 服下「" + this.m.Name + "」（药效 " + this.m.PotencyPct + "%），培元补血且下场战斗药力已就绪！" };
			}
			skills.update();
			local auxObj = this.getAuxSpec();
			local auxTail = (auxObj != null) ? ("（附带【" + auxObj.Title + "】）") : "";
			return { Ok = true, Message = _actor.getName() + " 服下「" + this.m.Name + "」（药效 " + this.m.PotencyPct + "%）" + auxTail + "，下场战斗药力已就绪！" };
		}

		return { Ok = false, Reason = "该丹药请通过插槽灌注或洗经伐髓使用。" };
	}

	function onUse( _actor, _item = null )
	{
		local res = this.applyToActorWithMessage(_actor);
		return res.Ok;
	}

	function onSerialize( _out )
	{
		this.item.onSerialize(_out);
		if (this.m.PillGrade == 1 && this.m.PotencyPct == 100 && this.m.AuxNature == "")
		{
			_out.writeString(this.m.PillID);
		}
		else
		{
			_out.writeString(this.m.PillID + "|" + this.m.PillGrade + "|" + this.m.PotencyPct + "|" + this.m.AuxNature);
		}
	}

	function onDeserialize( _in )
	{
		this.item.onDeserialize(_in);
		local raw = _in.readString();
		if (raw == null) raw = "wx_pill_huxin";
		if (raw.find("|") == null)
		{
			this.m.PillID = raw;
			this.m.PillGrade = 1;
			this.m.PotencyPct = 100;
			this.m.AuxNature = "";
		}
		else
		{
			local parts = split(raw, "|");
			this.m.PillID     = parts.len() >= 1 ? parts[0] : "wx_pill_huxin";
			this.m.PillGrade  = parts.len() >= 2 ? ::Math.max(1, ::Math.min(3, parts[1].tointeger())) : 1;
			this.m.PotencyPct = parts.len() >= 3 ? ::Math.max(80, ::Math.min(170, parts[2].tointeger())) : 100;
			this.m.AuxNature  = parts.len() >= 4 ? parts[3] : "";
			// Note: `split("id|2|120|", "|")` in Squirrel omits empty trailing token, so `parts.len() == 3` cleanly gives `""`!
		}
		this.refreshFromConfig();
	}
});
