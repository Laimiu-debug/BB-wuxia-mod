// Loose-Coupled Cross-System Combat Bridge for Forge, Relics, Gadgets & Tactical Alchemy
// Bridges external item pillars with parallel-developed 64 Shan-Hai Multi-Part Bosses & Sect Martial Styles
// WITHOUT modifying Boss scripts (`wx_shanhai_boss_trait.nut`, `wx_boss_*.nut`) or Martial Base (`wx_move_base.nut`, `combat_rules.nut`).

::Wuxia.CraftBridge <- {
	MaxExtraArmorPen     = 0.25, // AGENTS.md hard ceiling: total extra armor pen <= +25%
	MinRegularDamageMult = 0.40, // AGENTS.md hard ceiling: total HP damage mitigation <= 60%
	MaxActiveHudSkills   = 9,    // AGENTS.md HUD skill bar guardrail: 6~9 active skills

	// Complete 64 Shan-Hai Boss -> 12 Anatomical Part-Break Essence Material (`wx_pmat_*`) Mapping
	BossPartEssenceMap = {
		// 1. 太古真龙逆鳞髓 (破腹逆鳞)
		yinglong     = { EssenceID = "wx_pmat_longni", PartLabel = "逆鳞腹甲", PartKey = "shell" },
		zhuyin       = { EssenceID = "wx_pmat_longni", PartLabel = "昼夜龙颔", PartKey = "head" },
		gonggong     = { EssenceID = "wx_pmat_longni", PartLabel = "黑水蛇鳞", PartKey = "shell" },
		bashe        = { EssenceID = "wx_pmat_longni", PartLabel = "吞象腹鳞", PartKey = "shell" },
		huashe       = { EssenceID = "wx_pmat_longni", PartLabel = "寒水翼鳞", PartKey = "wing" },
		bingyi       = { EssenceID = "wx_pmat_longni", PartLabel = "御龙寒鳞", PartKey = "core" },
		// 2. 九首凶妖再生毒腺 (断首封颈)
		xiangliuwang = { EssenceID = "wx_pmat_jiushou", PartLabel = "九首毒颈", PartKey = "head" },
		jiuying      = { EssenceID = "wx_pmat_jiushou", PartLabel = "水火蛇首", PartKey = "head" },
		jiufeng      = { EssenceID = "wx_pmat_jiushou", PartLabel = "泣血妖首", PartKey = "head" },
		feiyi        = { EssenceID = "wx_pmat_jiushou", PartLabel = "双身毒颈", PartKey = "head" },
		mingshe      = { EssenceID = "wx_pmat_jiushou", PartLabel = "磬音蛇首", PartKey = "head" },
		hujiao       = { EssenceID = "wx_pmat_jiushou", PartLabel = "虎斑毒颚", PartKey = "head" },
		// 3. 不坏玄甲镇海残片 (重锤破壳)
		xuangui      = { EssenceID = "wx_pmat_xuanjia", PartLabel = "六角玄壳", PartKey = "shell" },
		fangfeng     = { EssenceID = "wx_pmat_xuanjia", PartLabel = "专车骨盾", PartKey = "shell" },
		zaochi       = { EssenceID = "wx_pmat_xuanjia", PartLabel = "畴华戈盾", PartKey = "shell" },
		hundun       = { EssenceID = "wx_pmat_xuanjia", PartLabel = "浑沌黄囊", PartKey = "shell" },
		kaiming      = { EssenceID = "wx_pmat_xuanjia", PartLabel = "九首护甲", PartKey = "shell" },
		// 4. 十日扶桑真火金翎 (折翼拔翎)
		jinwu        = { EssenceID = "wx_pmat_jinwu_yu", PartLabel = "三足金翼", PartKey = "wing" },
		bifang       = { EssenceID = "wx_pmat_jinwu_yu", PartLabel = "独足赤翎", PartKey = "wing" },
		yuanchu      = { EssenceID = "wx_pmat_jinwu_yu", PartLabel = "丹穴火羽", PartKey = "wing" },
		huodou       = { EssenceID = "wx_pmat_jinwu_yu", PartLabel = "喷炎尾毫", PartKey = "tail" },
		nvchou       = { EssenceID = "wx_pmat_jinwu_yu", PartLabel = "赤旱青袂", PartKey = "core" },
		// 5. 裂空幻步天妖风翼 (斩翼断足)
		dijiang      = { EssenceID = "wx_pmat_fengyi", PartLabel = "六足四翼", PartKey = "wing" },
		feilian      = { EssenceID = "wx_pmat_fengyi", PartLabel = "风伯雀翼", PartKey = "wing" },
		qiongqi      = { EssenceID = "wx_pmat_fengyi", PartLabel = "裂风恶翼", PartKey = "wing" },
		tiangouwang  = { EssenceID = "wx_pmat_fengyi", PartLabel = "奔星前爪", PartKey = "tail" },
		shanhui      = { EssenceID = "wx_pmat_fengyi", PartLabel = "疾风犬足", PartKey = "tail" },
		mengji       = { EssenceID = "wx_pmat_fengyi", PartLabel = "隐猎豹足", PartKey = "tail" },
		// 6. 万古兵主裂岳凶角 (拔角碎额)
		chiyou       = { EssenceID = "wx_pmat_bingzhu_jiao", PartLabel = "铜头双角", PartKey = "horn" },
		bo           = { EssenceID = "wx_pmat_bingzhu_jiao", PartLabel = "食虎钢角", PartKey = "horn" },
		siwang       = { EssenceID = "wx_pmat_bingzhu_jiao", PartLabel = "苍兕犀角", PartKey = "horn" },
		zheng        = { EssenceID = "wx_pmat_bingzhu_jiao", PartLabel = "章峨独角", PartKey = "horn" },
		zhuhuai      = { EssenceID = "wx_pmat_bingzhu_jiao", PartLabel = "北岳四角", PartKey = "horn" },
		dangkang     = { EssenceID = "wx_pmat_bingzhu_jiao", PartLabel = "青玉獠牙", PartKey = "horn" },
		jiao         = { EssenceID = "wx_pmat_bingzhu_jiao", PartLabel = "玉山牛角", PartKey = "horn" },
		// 7. 流波紫电雷兽夔骨 (碎骨断足)
		kui          = { EssenceID = "wx_pmat_leigu", PartLabel = "独足雷骨", PartKey = "core" },
		zhuyan       = { EssenceID = "wx_pmat_leigu", PartLabel = "沸血猿臂", PartKey = "core" },
		taowu        = { EssenceID = "wx_pmat_leigu", PartLabel = "傲狠虎骨", PartKey = "core" },
		zhujian      = { EssenceID = "wx_pmat_leigu", PartLabel = "狂飙脊骨", PartKey = "core" },
		kuafu        = { EssenceID = "wx_pmat_leigu", PartLabel = "逐日神骸", PartKey = "core" },
		// 8. 通玄破妄灵兽神瞳 (碎阵破瞳)
		baize        = { EssenceID = "wx_pmat_baize_tong", PartLabel = "通玄神瞳", PartKey = "core" },
		jiuwei       = { EssenceID = "wx_pmat_baize_tong", PartLabel = "九尾阵眼", PartKey = "tail" },
		wuluo        = { EssenceID = "wx_pmat_baize_tong", PartLabel = "青要鸣环", PartKey = "core" },
		xingxing     = { EssenceID = "wx_pmat_baize_tong", PartLabel = "招摇慧耳", PartKey = "head" },
		boshi        = { EssenceID = "wx_pmat_baize_tong", PartLabel = "背生神目", PartKey = "core" },
		jingwei      = { EssenceID = "wx_pmat_baize_tong", PartLabel = "填海魂核", PartKey = "core" },
		// 9. 昆仑蜇石蚀骨尾针 (斩尾拔针)
		qinyuan      = { EssenceID = "wx_pmat_qinyuan_zhen", PartLabel = "蜇石尾针", PartKey = "tail" },
		fei          = { EssenceID = "wx_pmat_qinyuan_zhen", PartLabel = "白首疫尾", PartKey = "tail" },
		gudiaowang   = { EssenceID = "wx_pmat_qinyuan_zhen", PartLabel = "攒角尾刺", PartKey = "tail" },
		// 10. 吞天凶神噬元虎齿 (碎颚拔齿)
		taotie       = { EssenceID = "wx_pmat_taotie_chi", PartLabel = "吞天虎颚", PartKey = "head" },
		paoxiaowang  = { EssenceID = "wx_pmat_taotie_chi", PartLabel = "腋目齿颚", PartKey = "head" },
		yayu         = { EssenceID = "wx_pmat_taotie_chi", PartLabel = "龙首凶牙", PartKey = "head" },
		// 11. 常羊不灭战神刑髓 (碎阵断干)
		xingtian     = { EssenceID = "wx_pmat_xingtian_sui", PartLabel = "干戚战脐", PartKey = "core" },
		erfu         = { EssenceID = "wx_pmat_xingtian_sui", PartLabel = "疏属铁枷", PartKey = "core" },
		shebishi     = { EssenceID = "wx_pmat_xingtian_sui", PartLabel = "贯耳青蛇", PartKey = "head" },
		qiangliang   = { EssenceID = "wx_pmat_xingtian_sui", PartLabel = "衔蛇戈柄", PartKey = "core" },
		// 12. 都广建木万年灵脂 (伐枝取心)
		jumang       = { EssenceID = "wx_pmat_jianmu_zhi", PartLabel = "建木枝心", PartKey = "core" },
		yingzhao     = { EssenceID = "wx_pmat_jianmu_zhi", PartLabel = "司圃翼角", PartKey = "wing" },
		luwu         = { EssenceID = "wx_pmat_jianmu_zhi", PartLabel = "九尾虎须", PartKey = "tail" },
		zouyu        = { EssenceID = "wx_pmat_jianmu_zhi", PartLabel = "五采虎尾", PartKey = "tail" },
		fuzhu        = { EssenceID = "wx_pmat_jianmu_zhi", PartLabel = "四角霜茸", PartKey = "horn" },
		chenghuang   = { EssenceID = "wx_pmat_jianmu_zhi", PartLabel = "乘黄龙角", PartKey = "horn" },
		wuzhiqi      = { EssenceID = "wx_pmat_jianmu_zhi", PartLabel = "锁脉寒链", PartKey = "core" },
		changyou     = { EssenceID = "wx_pmat_jianmu_zhi", PartLabel = "四耳猿掌", PartKey = "core" }
	}
};

// -----------------------------------------------------------------------------
// 1. Global Anti-Inflation Multipliers & Adders
// -----------------------------------------------------------------------------
::Wuxia.CraftBridge.addCappedDirectDamage <- function( _properties, _bonus )
{
	if (_properties == null || _bonus <= 0.0) return 0.0;
	local curAdd = ("DamageDirectAdd" in _properties) ? _properties.DamageDirectAdd : 0.0;
	local cap = ::Wuxia.CraftBridge.MaxExtraArmorPen;
	local room = (cap > curAdd) ? (cap - curAdd) : 0.0;
	local applied = (_bonus < room) ? _bonus : room;
	if (applied > 0.0)
		_properties.DamageDirectAdd += applied;
	return applied;
};

::Wuxia.CraftBridge.multCappedRegularDamageReceived <- function( _properties, _mult )
{
	if (_properties == null || _mult >= 1.0) return;
	local floorMult = ::Wuxia.CraftBridge.MinRegularDamageMult;
	local nextMult = _properties.DamageReceivedRegularMult * _mult;
	_properties.DamageReceivedRegularMult = (nextMult < floorMult) ? floorMult : nextMult;
};

::Wuxia.CraftBridge.countActiveHudSkills <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null)
		return 0;
	local skCont = _actor.getSkills();
	local seen = {};
	local cnt = 0;
	local allSk = skCont.getAllSkillsOfType(::Const.SkillType.Active);
	if (allSk != null)
	{
		foreach (sk in allSk)
		{
			if (sk != null && !sk.isGarbage() && !sk.isHidden())
			{
				seen[sk.getID()] <- true;
				cnt += 1;
			}
		}
	}
	if (::Wuxia.hasMember(skCont, "m") && skCont.m != null && ("SkillsToAdd" in skCont.m) && skCont.m.SkillsToAdd != null)
	{
		foreach (psk in skCont.m.SkillsToAdd)
		{
			if (psk != null && !psk.isGarbage() && psk.isType(::Const.SkillType.Active) && !(psk.getID() in seen) && !psk.isHidden())
			{
				seen[psk.getID()] <- true;
				cnt += 1;
			}
		}
	}
	return cnt;
};

// -----------------------------------------------------------------------------
// 2. Read-Only Martial Style & Neigong Profile Sniffing
// -----------------------------------------------------------------------------
::Wuxia.CraftBridge.getActorNeigongProfile <- function( _actor )
{
	local out = {
		HasContainer = false,
		MainElement  = "none",
		MainTier     = 0,
		SubElement   = "none",
		SubTier      = 0,
		HasConflict  = false
	};
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null)
		return out;
	local mc = _actor.getSkills().getSkillByID("special.wx_martial_container");
	if (mc == null || !("m" in mc) || !("Slots" in mc.m))
		return out;

	out.HasContainer = true;
	for (local i = 0; i < mc.m.Slots.len(); i = ++i)
	{
		local sl = mc.m.Slots[i];
		if (sl == null || sl.ManualID == null || sl.Tier <= 0) continue;
		local mdef = ::Wuxia.Slots.getManualDef(sl.ManualID);
		if (mdef == null || mdef.Category != "neigong") continue;
		local el = (mdef.Element != null) ? mdef.Element : "neutral";
		if (out.MainElement == "none")
		{
			out.MainElement = el;
			out.MainTier = sl.Tier;
		}
		else if (out.SubElement == "none")
		{
			out.SubElement = el;
			out.SubTier = sl.Tier;
		}
	}
	if ((out.MainElement == "yang" && out.SubElement == "yin")
		|| (out.MainElement == "yin" && out.SubElement == "yang")
		|| (out.MainElement == "yang" && out.SubElement == "evil")
		|| (out.MainElement == "evil" && out.SubElement == "yang"))
	{
		out.HasConflict = true;
	}
	return out;
};

::Wuxia.CraftBridge.getActorMartialProfile <- function( _actor )
{
	local ng = ::Wuxia.CraftBridge.getActorNeigongProfile(_actor);
	ng.HasWaigong  <- false;
	ng.HasQinggong <- false;
	ng.HasHenglian <- false;
	ng.HasTactics  <- false;
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null)
		return ng;
	local mc = _actor.getSkills().getSkillByID("special.wx_martial_container");
	if (mc == null || !("m" in mc) || !("Slots" in mc.m))
		return ng;
	for (local i = 0; i < mc.m.Slots.len(); i = ++i)
	{
		local sl = mc.m.Slots[i];
		if (sl == null || sl.ManualID == null || sl.Tier <= 0) continue;
		local mdef = ::Wuxia.Slots.getManualDef(sl.ManualID);
		if (mdef == null) continue;
		if (mdef.Category == "waigong") ng.HasWaigong = true;
		else if (mdef.Category == "qinggong") ng.HasQinggong = true;
		else if (mdef.Category == "henglian") ng.HasHenglian = true;
		else if (mdef.Category == "tactics") ng.HasTactics = true;
	}
	return ng;
};

::Wuxia.CraftBridge.isActorInMiasmaOrSwamp <- function( _actor )
{
	if (_actor == null) return false;
	if ("m" in _actor && _actor.m != null && ("WX_ForceMiasmaEnv" in _actor.m) && _actor.m.WX_ForceMiasmaEnv)
		return true;
	if (::Wuxia.hasMember(_actor, "getSkills") && _actor.getSkills() != null)
	{
		local sk = _actor.getSkills();
		if (sk.hasSkill("effects.miasma") || sk.hasSkill("effects.acid") || sk.hasSkill("effects.lindwurm_acid"))
			return true;
	}
	if (::Wuxia.hasMember(_actor, "isPlacedOnMap") && _actor.isPlacedOnMap() && _actor.getTile() != null)
	{
		local t = _actor.getTile();
		if ("TileField" in ::Wuxia && ::Wuxia.TileField.hasField(t, "bitter_mire"))
			return true;
		if ("Type" in t && "Const" in getroottable() && "Tactical" in ::Const && "TerrainType" in ::Const.Tactical
			&& ("Swamp" in ::Const.Tactical.TerrainType) && t.Type == ::Const.Tactical.TerrainType.Swamp)
			return true;
		if ("Properties" in t && t.Properties != null && ("Effect" in t.Properties) && t.Properties.Effect != null)
		{
			local eff = t.Properties.Effect;
			if (typeof eff == "table" && ("Type" in eff) && eff.Type != null
				&& (eff.Type == "miasma" || eff.Type.find("poison") != null || eff.Type.find("miasma") != null || eff.Type.find("bog") != null))
				return true;
		}
	}
	return false;
};

::Wuxia.CraftBridge.hasSkillMechanic <- function( _skill, _mechTag )
{
	if (_skill == null || _mechTag == null || _mechTag == "") return false;
	local sid = _skill.getID();
	if ("m" in _skill && _skill.m != null && ("WX_MechanicTags" in _skill.m) && _skill.m.WX_MechanicTags != null)
	{
		if (typeof _skill.m.WX_MechanicTags == "array")
		{
			foreach (t in _skill.m.WX_MechanicTags)
				if (t == _mechTag) return true;
		}
		else if (_skill.m.WX_MechanicTags == _mechTag)
			return true;
	}
	if ("CombatRules" in ::Wuxia && "SkillMechanics" in ::Wuxia.CombatRules && (sid in ::Wuxia.CombatRules.SkillMechanics))
	{
		local entry = ::Wuxia.CombatRules.SkillMechanics[sid];
		if (typeof entry == "string") return entry == _mechTag;
		if (typeof entry == "array")
		{
			foreach (mTag in entry)
				if (mTag == _mechTag) return true;
		}
		if (typeof entry == "table" && ("Type" in entry))
			return entry.Type == _mechTag;
	}
	return false;
};

// -----------------------------------------------------------------------------
// 3. Squad Relic Resonance & Battlefield Terrain/Weather Sniffing
// -----------------------------------------------------------------------------
::Wuxia.CraftBridge.getEquippedRelicID <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getItems") || _actor.getItems() == null)
		return "";
	local wpn = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
	if (wpn == null || !("m" in wpn) || wpn.m == null) return "";
	if ("WX_RelicID" in wpn.m && wpn.m.WX_RelicID != null)
		return wpn.m.WX_RelicID;
	local wid = wpn.getID();
	if (wid != null && wid.find("weapon.wx_relic_") == 0)
		return wid.slice(7);
	return "";
};

::Wuxia.CraftBridge.findSquadRelicPartner <- function( _actor, _partnerRelicID, _maxDist = 4 )
{
	if (_actor == null || _partnerRelicID == null || _partnerRelicID == "")
		return null;

	// Support headless unit tests / mock squad arrays without requiring live C++ Tactical singleton
	if ("m" in _actor && _actor.m != null && ("WX_MockSquadPartners" in _actor.m) && _actor.m.WX_MockSquadPartners != null)
	{
		foreach (p in _actor.m.WX_MockSquadPartners)
		{
			if (p != null && p.isAlive() && ::Wuxia.CraftBridge.getEquippedRelicID(p) == _partnerRelicID)
				return p;
		}
	}

	if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive())
		return null;
	if (!::Wuxia.hasMember(_actor, "isPlacedOnMap") || !_actor.isPlacedOnMap())
		return null;

	local myTile = _actor.getTile();
	if (myTile == null) return null;
	local units = ::Tactical.Entities.getAllInstancesAsArray();
	foreach (u in units)
	{
		if (u == null || !u.isAlive() || u.getID() == _actor.getID()) continue;
		if (!::Wuxia.hasMember(u, "isPlacedOnMap") || !u.isPlacedOnMap()) continue;
		if (!_actor.isAlliedWith(u)) continue;
		if (myTile.getDistanceTo(u.getTile()) > _maxDist) continue;
		if (::Wuxia.CraftBridge.getEquippedRelicID(u) == _partnerRelicID)
			return u;
	}
	return null;
};

::Wuxia.CraftBridge.isTileShadowOrSmoke <- function( _tile )
{
	if (_tile != null && ("TileField" in ::Wuxia))
	{
		if (::Wuxia.TileField.hasField(_tile, "mirage_mist") || ::Wuxia.TileField.getWeather().Kind == "zhuyin_night")
			return true;
	}
	if (_tile == null || !("Properties" in _tile) || _tile.Properties == null)
		return false;
	local eff = ("Effect" in _tile.Properties) ? _tile.Properties.Effect : null;
	if (eff != null && typeof eff == "table" && ("Type" in eff) && eff.Type != null)
	{
		local tp = eff.Type;
		if (tp == "smoke" || tp == "miasma" || tp.find("smoke") != null || tp.find("mirage") != null || tp.find("mist") != null)
			return true;
	}
	return false;
};

::Wuxia.CraftBridge.isShadowOrSmokeEnv <- function( _actor, _target = null )
{
	foreach (ent in [_actor, _target])
	{
		if (ent == null) continue;
		if (::Wuxia.hasMember(ent, "getSkills") && ent.getSkills() != null)
		{
			local sk = ent.getSkills();
			if (sk.hasSkill("effects.night") || sk.hasSkill("effects.smoke") || sk.hasSkill("effects.wx_status_smoke_screen") || sk.hasSkill("effects.miasma"))
				return true;
		}
		if ("m" in ent && ent.m != null && ("WX_ForceShadowEnv" in ent.m) && ent.m.WX_ForceShadowEnv)
			return true;
		if (::Wuxia.hasMember(ent, "isPlacedOnMap") && ent.isPlacedOnMap() && ::Wuxia.CraftBridge.isTileShadowOrSmoke(ent.getTile()))
			return true;
	}
	return false;
};

::Wuxia.CraftBridge.isWetOrConductiveEnv <- function( _actor, _target = null )
{
	foreach (ent in [_actor, _target])
	{
		if (ent == null) continue;
		if ("m" in ent && ent.m != null && ("WX_ForceWetEnv" in ent.m) && ent.m.WX_ForceWetEnv)
			return true;
		if (::Wuxia.hasMember(ent, "getSkills") && ent.getSkills() != null)
		{
			local sk = ent.getSkills();
			if (sk.hasSkill("effects.wx_status_frost_chill") || sk.hasSkill("effects.chilled"))
				return true;
		}
		if (::Wuxia.hasMember(ent, "isPlacedOnMap") && ent.isPlacedOnMap() && ent.getTile() != null)
		{
			local t = ent.getTile();
			if ("TileField" in ::Wuxia)
			{
				if (::Wuxia.TileField.hasField(t, "bitter_mire") || ::Wuxia.TileField.hasField(t, "abyss_frost") || ::Wuxia.TileField.hasField(t, "thunder_pool"))
					return true;
			}
			if ("Type" in t && "Const" in getroottable() && "Tactical" in ::Const && "TerrainType" in ::Const.Tactical)
			{
				local TT = ::Const.Tactical.TerrainType;
				if ((("Swamp" in TT) && t.Type == TT.Swamp)
					|| (("ShallowWater" in TT) && t.Type == TT.ShallowWater)
					|| (("Snow" in TT) && t.Type == TT.Snow))
					return true;
			}
			if ("Properties" in t && t.Properties != null)
			{
				if (("WX_PurifiedDew" in t.Properties) && t.Properties.WX_PurifiedDew)
					return true;
				local eff = ("Effect" in t.Properties) ? t.Properties.Effect : null;
				if (eff != null && typeof eff == "table" && ("Type" in eff) && eff.Type != null)
				{
					local et = eff.Type;
					if (et.find("water") != null || et.find("frost") != null || et.find("rain") != null || et.find("bog") != null)
						return true;
				}
			}
		}
	}
	return false;
};

// -----------------------------------------------------------------------------
// 4. Mid-Battle Hex-Tile Hazard Purification & Rewriting
// -----------------------------------------------------------------------------
::Wuxia.CraftBridge.isHazardousTileEffect <- function( _eff )
{
	if (_eff == null || typeof _eff != "table") return false;
	if (("IsPositive" in _eff) && _eff.IsPositive) return false;
	local tp = ("Type" in _eff && _eff.Type != null) ? _eff.Type : "";
	if (tp == "wx_purified_dew") return false;
	if (tp == "fire" || tp == "miasma" || tp == "smoke" || tp == "poison" || tp == "alp_shadow"
		|| tp.find("fire") != null || tp.find("scorched") != null || tp.find("bog") != null
		|| tp.find("miasma") != null || tp.find("mirage") != null || tp.find("poison") != null || tp.find("frost") != null)
		return true;
	return ("Timeout" in _eff) && _eff.Timeout > 0;
};

::Wuxia.CraftBridge.purifySingleTile <- function( _tile, _caster = null )
{
	if (_tile == null) return { ClearedTile = false, CleansedAlly = false };
	local cleared = false;
	if ("TileField" in ::Wuxia)
	{
		local tf = ::Wuxia.TileField.getField(_tile);
		if (tf != null && (tf.Kind == "drought_scorch" || tf.Kind == "bitter_mire" || tf.Kind == "abyss_frost" || tf.Kind == "mirage_mist" || tf.Kind == "blood_pool" || tf.Kind == "thunder_pool"))
		{
			::Wuxia.TileField.removeField(_tile);
			cleared = true;
		}
	}
	if ("Properties" in _tile && _tile.Properties != null)
	{
		local eff = ("Effect" in _tile.Properties) ? _tile.Properties.Effect : null;
		if (::Wuxia.CraftBridge.isHazardousTileEffect(eff))
		{
			if (("Tactical" in getroottable()) && ::Tactical != null && ("Entities" in ::Tactical) && ::Tactical.Entities != null && ("removeTileEffect" in ::Tactical.Entities))
			{
				try { ::Tactical.Entities.removeTileEffect(_tile); } catch (_e) { _tile.Properties.Effect = null; }
			}
			else
			{
				_tile.Properties.Effect = null;
			}
			cleared = true;
		}
		_tile.Properties.WX_PurifiedDew <- true;
	}

	local cleansedAlly = false;
	local ent = (::Wuxia.isTileOccupiedByActor(_tile) && ::Wuxia.hasMember(_tile, "getEntity")) ? _tile.getEntity() : null;
	if (ent != null && ent.isAlive() && (_caster == null || _caster.isAlliedWith(ent)))
	{
		if (::Wuxia.hasMember(ent, "getSkills") && ent.getSkills() != null)
		{
			local sk = ent.getSkills();
			foreach (badID in [
				"effects.wx_status_poison_dart",
				"effects.spider_poison",
				"effects.goblin_poison",
				"effects.acid",
				"effects.lindwurm_acid",
				"effects.Alp_nightmare"
			])
			{
				if (sk.hasSkill(badID))
				{
					sk.removeByID(badID);
					cleansedAlly = true;
				}
			}
		}
		if (::Wuxia.hasMember(ent, "getItems") && ent.getItems() != null)
		{
			local body = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (body != null && ::Wuxia.hasMember(body, "getArmor") && body.getArmor() < body.getArmorMax())
				body.setArmor(::Math.min(body.getArmorMax(), body.getArmor() + 6));
		}
	}
	return { ClearedTile = cleared, CleansedAlly = cleansedAlly };
};

::Wuxia.CraftBridge.purifyHazardousTiles <- function( _centerTile, _caster = null, _radius = 1 )
{
	local res = { ClearedTiles = 0, CleansedAllies = 0 };
	if (_centerTile == null) return res;

	local c0 = ::Wuxia.CraftBridge.purifySingleTile(_centerTile, _caster);
	if (c0.ClearedTile) res.ClearedTiles += 1;
	if (c0.CleansedAlly) res.CleansedAllies += 1;

	if (_radius >= 1 && ::Wuxia.hasMember(_centerTile, "hasNextTile"))
	{
		for (local d = 0; d < 6; d = ++d)
		{
			if (!_centerTile.hasNextTile(d)) continue;
			local adj = _centerTile.getNextTile(d);
			local ca = ::Wuxia.CraftBridge.purifySingleTile(adj, _caster);
			if (ca.ClearedTile) res.ClearedTiles += 1;
			if (ca.CleansedAlly) res.CleansedAllies += 1;
		}
	}
	return res;
};

::Wuxia.CraftBridge.getCurrentRound <- function()
{
	if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive()
		&& ("TurnSequenceBar" in ::Tactical) && ::Tactical.TurnSequenceBar != null)
	{
		return ::Tactical.TurnSequenceBar.getCurrentRound();
	}
	return 1;
};

::Wuxia.CraftBridge.purifyMindAndMirageTiles <- function( _centerTile, _caster )
{
	local out = { ClearedTiles = 0, RalliedAllies = 0 };
	local tiles = [];
	if (_centerTile != null)
	{
		tiles.push(_centerTile);
		if (::Wuxia.hasMember(_centerTile, "hasNextTile"))
		{
			for (local d = 0; d < 6; d = ++d)
			{
				if (_centerTile.hasNextTile(d))
					tiles.push(_centerTile.getNextTile(d));
			}
		}
	}

	local cleanseActor = function( _ent )
	{
		if (_ent == null || !_ent.isAlive()) return false;
		local changed = false;
		if (::Wuxia.hasMember(_ent, "getSkills") && _ent.getSkills() != null)
		{
			local sk = _ent.getSkills();
			foreach (mID in ["effects.charmed", "effects.sleeping", "effects.alp_nightmare", "effects.dazed", "effects.horrified", "effects.staggered"])
			{
				if (sk.hasSkill(mID))
				{
					sk.removeByID(mID);
					changed = true;
				}
			}
		}
		if (::Wuxia.hasMember(_ent, "getMoraleState") && ::Wuxia.hasMember(_ent, "setMoraleState"))
		{
			local ms = _ent.getMoraleState();
			if (ms == ::Const.MoraleState.Breaking)
			{
				_ent.setMoraleState(::Const.MoraleState.Wavering);
				changed = true;
			}
			else if (ms == ::Const.MoraleState.Wavering)
			{
				_ent.setMoraleState(::Const.MoraleState.Steady);
				changed = true;
			}
		}
		return changed;
	};

	if (_caster != null && cleanseActor(_caster))
		out.RalliedAllies += 1;

	foreach (tl in tiles)
	{
		if (tl == null) continue;
		if ("TileField" in ::Wuxia)
		{
			local tf = ::Wuxia.TileField.getField(tl);
			if (tf != null && tf.Kind == "mirage_mist")
			{
				::Wuxia.TileField.removeField(tl);
				out.ClearedTiles += 1;
			}
		}
		if ("Properties" in tl && tl.Properties != null && ("Effect" in tl.Properties) && tl.Properties.Effect != null)
		{
			local tp = ("Type" in tl.Properties.Effect && tl.Properties.Effect.Type != null) ? tl.Properties.Effect.Type : "";
			if (tp == "alp_shadow" || tp.find("mirage") != null || tp == "smoke")
			{
				tl.Properties.Effect = null;
				out.ClearedTiles += 1;
			}
		}
		local occ = (::Wuxia.isTileOccupiedByActor(tl) && ::Wuxia.hasMember(tl, "getEntity")) ? tl.getEntity() : null;
		if (occ != null && (_caster == null || occ.getID() != _caster.getID()) && (_caster == null || _caster.isAlliedWith(occ)))
		{
			if (cleanseActor(occ))
				out.RalliedAllies += 1;
		}
	}
	return out;
};

::Wuxia.CraftBridge.triggerChildGuContagion <- function( _deadHost, _tile )
{
	if (_deadHost == null || _tile == null) return 0;
	local spreadCnt = 0;
	local cands = [];
	if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive() && ("Entities" in ::Tactical) && ::Tactical.Entities != null)
	{
		local allActors = ::Tactical.Entities.getAllInstancesAsArray();
		foreach (act in allActors)
		{
			if (act == null || act.getID() == _deadHost.getID() || !act.isAlive() || !act.isPlacedOnMap() || act.getTile() == null) continue;
			if (!act.isAlliedWith(_deadHost)) continue;
			if (_tile.getDistanceTo(act.getTile()) <= 2)
				cands.push(act);
		}
	}
	else if (::Wuxia.hasMember(_tile, "hasNextTile"))
	{
		for (local d = 0; d < 6; d = ++d)
		{
			if (!_tile.hasNextTile(d)) continue;
			local nt = _tile.getNextTile(d);
			if (nt != null && ::Wuxia.isTileOccupiedByActor(nt) && nt.getEntity() != null)
			{
				local ent = nt.getEntity();
				if (ent.isAlive() && ent.isAlliedWith(_deadHost))
					cands.push(ent);
			}
		}
	}

	for (local i = 0; i < cands.len() && spreadCnt < 2; i = ++i)
	{
		local vic = cands[i];
		local vsk = ::Wuxia.hasMember(vic, "getSkills") ? vic.getSkills() : null;
		if (vsk == null) continue;
		if (!::Wuxia.CombatRules.isImmuneToMeridianAndPoison(vic) && !vsk.hasSkill("effects.wx_status_poison_dart"))
			vsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
		if (!vsk.hasSkill("effects.wx_status_opening"))
			vsk.add(::new("scripts/skills/effects/wx_status_opening"));
		spreadCnt += 1;
	}
	return spreadCnt;
};

// -----------------------------------------------------------------------------
// 5. Boss Counter-Play & Multi-Part Destruction Sniffing
// -----------------------------------------------------------------------------
::Wuxia.CraftBridge.markBossPartBroken <- function( _bossActor, _partKey )
{
	if (_bossActor == null || _partKey == null || _partKey == "") return;
	if (::Wuxia.hasMember(_bossActor, "getFlags") && _bossActor.getFlags() != null)
		_bossActor.getFlags().set("wx_part_broken_" + _partKey, true);
	if ("m" in _bossActor && _bossActor.m != null)
		_bossActor.m["WX_PartBroken_" + _partKey] <- true;
};

::Wuxia.CraftBridge.applyBossCounterHit <- function( _attacker, _target, _opts )
{
	local out = { BrokeCharge = false, CrackedShell = false, SealedRegen = false };
	if (_target == null || !_target.isAlive() || _opts == null) return out;
	local tsk = (::Wuxia.hasMember(_target, "getSkills")) ? _target.getSkills() : null;
	if (tsk == null) return out;

	local shTrait = tsk.getSkillByID("special.wx_shanhai_boss_trait");

	// 1. Seal Boss HP regeneration & Blood Pact / Revive
	if (("SealRegenTurns" in _opts) && _opts.SealRegenTurns > 0)
	{
		local seal = tsk.getSkillByID("effects.wx_status_regen_seal");
		if (seal == null)
		{
			seal = ::new("scripts/skills/effects/wx_status_regen_seal");
			seal.setTurns(_opts.SealRegenTurns);
			tsk.add(seal);
		}
		else
		{
			seal.resetDuration(_opts.SealRegenTurns);
			seal.lockCurrentHP();
		}
		if (shTrait != null && ("m" in shTrait))
		{
			shTrait.m.ReviveUsed = true;
			if (shTrait.m.BloodPactActive)
			{
				local pd = tsk.getSkillByID("effects.wx_status_poison_dart");
				if (pd == null) tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
			}
		}
		::Wuxia.CraftBridge.markBossPartBroken(_target, "head");
		out.SealedRegen = true;
	}

	if (shTrait != null && ("m" in shTrait))
	{
		// 2. Corrode Bastion Shell Stacks
		if (("CorrodeShell" in _opts) && _opts.CorrodeShell > 0 && shTrait.m.ShellStacks > 0)
		{
			shTrait.m.ShellStacks = ::Math.max(0, shTrait.m.ShellStacks - _opts.CorrodeShell);
			::Wuxia.CraftBridge.markBossPartBroken(_target, "shell");
			out.CrackedShell = true;
			if (shTrait.m.ShellStacks == 0)
			{
				shTrait.m.ShellBrokenLeft = 2;
				local crackDmg = ::Math.max(12, ::Math.round(_target.getHitpointsMax() * 0.05));
				if (_target.getHitpoints() > crackDmg + 1)
					_target.setHitpoints(_target.getHitpoints() - crackDmg);
			}
		}

		// 3. Inject Stagger-Break Progress into Boss Cataclysm Charge
		local brkPts = ("BreakPts" in _opts) ? _opts.BreakPts : (("BreakProgress" in _opts) ? _opts.BreakProgress : 0);
		if (brkPts > 0 && ("IsCharging" in shTrait.m) && shTrait.m.IsCharging)
		{
			shTrait.m.BreakProgress += brkPts;
			::Wuxia.CraftBridge.markBossPartBroken(_target, "core");
			if (shTrait.m.BreakProgress >= 3 && ::Wuxia.hasMember(shTrait, "triggerChargeBreak"))
			{
				shTrait.triggerChargeBreak(_target);
				out.BrokeCharge = true;
			}
		}
	}

	// Also support all 64 Bespoke Shan-Hai Boss Traits (`烛九阴` / `女丑` / 61 `wx_shanhai_bespoke_trait_base` Omen & Shell & Nirvana laws)
	local bspTrait = ("ShanHai" in ::Wuxia && "findBossTrait" in ::Wuxia.ShanHai) ? ::Wuxia.ShanHai.findBossTrait(tsk) : null;
	if (bspTrait != null && bspTrait != shTrait && ("m" in bspTrait))
	{
		if (("SealRegenTurns" in _opts) && _opts.SealRegenTurns > 0 && ("NirvanaUsed" in bspTrait.m))
			bspTrait.m.NirvanaUsed = true;
		if (("CorrodeShell" in _opts) && _opts.CorrodeShell > 0 && ("BrokenPartsMap" in bspTrait.m) && bspTrait.m.BrokenPartsMap != null)
		{
			bspTrait.m.BrokenPartsMap["shell"] <- true;
			::Wuxia.CraftBridge.markBossPartBroken(_target, "shell");
			out.CrackedShell = true;
		}
	}
	local bspBrk = ("BreakPts" in _opts) ? _opts.BreakPts : (("BreakProgress" in _opts) ? _opts.BreakProgress : 0);
	if (bspTrait != null && bspTrait != shTrait && ("m" in bspTrait) && bspBrk > 0)
	{
		if (("IsInhalingWind" in bspTrait.m) && bspTrait.m.IsInhalingWind)
		{
			bspTrait.m.WindBreakProgress += bspBrk;
			::Wuxia.CraftBridge.markBossPartBroken(_target, "head");
			if (bspTrait.m.WindBreakProgress >= 3)
			{
				bspTrait.m.IsInhalingWind = false;
				bspTrait.m.WindCharged = false;
				out.BrokeCharge = true;
			}
		}
		if (("IsChargingApocalypse" in bspTrait.m) && bspTrait.m.IsChargingApocalypse)
		{
			bspTrait.m.IsChargingApocalypse = false;
			::Wuxia.CraftBridge.markBossPartBroken(_target, "core");
			out.BrokeCharge = true;
		}
		if (("IsChargingOmen" in bspTrait.m) && bspTrait.m.IsChargingOmen)
		{
			bspTrait.m.OmenBreakPts += bspBrk;
			::Wuxia.CraftBridge.markBossPartBroken(_target, "core");
			local needed = ("OmenBreakNeeded" in bspTrait.m) ? bspTrait.m.OmenBreakNeeded : 3;
			if (bspTrait.m.OmenBreakPts >= needed)
			{
				bspTrait.m.IsChargingOmen = false;
				bspTrait.m.OmenBreakPts = 0;
				out.BrokeCharge = true;
			}
		}
	}

	if (("ExposeOpening" in _opts) && _opts.ExposeOpening)
	{
		if (!tsk.hasSkill("effects.wx_status_opening"))
			tsk.add(::new("scripts/skills/effects/wx_status_opening"));
	}
	return out;
};

::Wuxia.CraftBridge.resolveBossPartEssenceSpec <- function( _bossKey )
{
	if (_bossKey == null || _bossKey == "") return null;
	local plain = (_bossKey.find("boss_") == 0) ? _bossKey.slice(5) : _bossKey;
	if (plain in ::Wuxia.CraftBridge.BossPartEssenceMap)
		return ::Wuxia.CraftBridge.BossPartEssenceMap[plain];
	return { EssenceID = "wx_pmat_leigu", PartLabel = "凶骸阵核", PartKey = "core" };
};

::Wuxia.CraftBridge.detectBrokenBossParts <- function( _bossActor, _fatalityType = 0 )
{
	local parts = [];
	if (_bossActor == null) return { Broken = false, Parts = parts };

	local flags = (::Wuxia.hasMember(_bossActor, "getFlags")) ? _bossActor.getFlags() : null;
	foreach (pk in ["head", "tail", "shell", "wing", "horn", "core"])
	{
		local hitFlag = (flags != null && flags.get("wx_part_broken_" + pk))
			|| (::Wuxia.hasMember(_bossActor, "m") && _bossActor.m != null && (("WX_PartBroken_" + pk) in _bossActor.m) && _bossActor.m["WX_PartBroken_" + pk]);
		if (hitFlag) parts.push(pk);
	}

	local sk = (::Wuxia.hasMember(_bossActor, "getSkills")) ? _bossActor.getSkills() : null;
	if (sk != null)
	{
		local shTrait = sk.getSkillByID("special.wx_shanhai_boss_trait");
		if (shTrait != null && ("m" in shTrait))
		{
			if (shTrait.m.ShellBrokenLeft > 0 && parts.find("shell") == null) parts.push("shell");
			if (shTrait.m.BacklashLeft > 0 && parts.find("core") == null) parts.push("core");
		}
		local bspT = ("ShanHai" in ::Wuxia && "findBossTrait" in ::Wuxia.ShanHai) ? ::Wuxia.ShanHai.findBossTrait(sk) : null;
		if (bspT != null && bspT != shTrait && ("m" in bspT) && ("BrokenPartsMap" in bspT.m) && bspT.m.BrokenPartsMap != null)
		{
			foreach (bpk, isBrk in bspT.m.BrokenPartsMap)
			{
				if (isBrk && parts.find(bpk) == null) parts.push(bpk);
			}
		}
		if (sk.hasSkill("effects.wx_status_regen_seal") && parts.find("head") == null)
			parts.push("head");
	}

	if ("Const" in getroottable() && "FatalityType" in ::Const && _fatalityType > 0)
	{
		local FT = ::Const.FatalityType;
		if ((("Decapitated" in FT) && _fatalityType == FT.Decapitated) || (("Smashed" in FT) && _fatalityType == FT.Smashed))
		{
			if (parts.find("head") == null) parts.push("head");
			if (parts.find("horn") == null) parts.push("horn");
		}
	}

	return {
		Broken = (parts.len() > 0),
		Parts  = parts
	};
};

// -----------------------------------------------------------------------------
// 6. Single-Battle Shared Dan-Toxin Counter (Pre-Battle Pills + Mid-Battle Oral Powders)
// -----------------------------------------------------------------------------
::Wuxia.CraftBridge.getBattleOralDoseCount <- function( _actor, _buff )
{
	local data = _actor.m;
	local midBattle = ("WX_MidBattleOralDoses" in data) ? data.WX_MidBattleOralDoses : 0;
	return midBattle + (_buff != null ? _buff.countActiveBuffs() : 0);
};

::Wuxia.CraftBridge.tryConsumeBattleOralDose <- function( _actor, _oralKey )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null)
		return { Ok = false, Reason = "无法读取角色经脉状态。" };

	local skills = _actor.getSkills();
	local buff = skills.getSkillByID("effects.wx_pill_battle_buff");
	local totalDoses = ::Wuxia.CraftBridge.getBattleOralDoseCount(_actor, buff);

	if (totalDoses >= 3)
	{
		return {
			Ok = false,
			Reason = _actor.getName() + " 本场战斗体内丹药药力已满 3 道极限，无法继续内服救急灵散！"
		};
	}

	local data = _actor.m;
	data.WX_MidBattleOralDoses <- ("WX_MidBattleOralDoses" in data) ? data.WX_MidBattleOralDoses + 1 : 1;

	local triggeredToxin = false;
	local toxinMsg = "";
	if (totalDoses == 2)
	{
		if (buff == null)
		{
			buff = ::new("scripts/skills/effects/wx_pill_battle_buff");
			skills.add(buff);
		}
		if (::Wuxia.hasMember(buff, "applyDanToxinOverload"))
		{
			toxinMsg = buff.applyDanToxinOverload();
			triggeredToxin = true;
		}
	}
	if (::Wuxia.hasMember(_actor, "setCurrentProperties"))
		skills.update();
	return {
		Ok             = true,
		TotalDoses     = totalDoses + 1,
		TriggeredToxin = triggeredToxin,
		ToxinNote      = toxinMsg
	};
};

// -----------------------------------------------------------------------------
// 7. HUD-Safe Unified Bag Tactical Skill Convergence (Strictly <= 9 Active HUD Icons!)
// -----------------------------------------------------------------------------
::Wuxia.CraftBridge.findActiveBagItem <- function( _actor, _domain )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getItems") || _actor.getItems() == null)
		return null;
	local bagItems = _actor.getItems().getAllItemsAtSlot(::Const.ItemSlot.Bag);
	if (bagItems == null) return null;
	foreach (it in bagItems)
	{
		if (it == null || !("m" in it) || it.m == null) continue;
		if (_domain == "gadget" && ::Wuxia.hasMember(it.m, "WX_IsBagGadget") && it.m.WX_IsBagGadget && it.getCharges() > 0)
			return it;
		if (_domain == "powder" && ::Wuxia.hasMember(it.m, "WX_IsTacticalConsumable") && it.m.WX_IsTacticalConsumable && it.getCharges() > 0)
			return it;
	}
	return null;
};

::Wuxia.CraftBridge.syncBagTacticalSkills <- function( _actor )
{
	if (_actor == null || !::Wuxia.hasMember(_actor, "getSkills") || _actor.getSkills() == null)
		return;
	local skills = _actor.getSkills();

	local firstGadget = ::Wuxia.CraftBridge.findActiveBagItem(_actor, "gadget");
	local gadgetSk = skills.getSkillByID("actives.wx_item_bag_gadget");
	if (firstGadget != null)
	{
		if (gadgetSk == null)
		{
			if (::Wuxia.CraftBridge.countActiveHudSkills(_actor) < ::Wuxia.CraftBridge.MaxActiveHudSkills)
			{
				gadgetSk = ::new("scripts/skills/actives/wx_item_bag_gadget");
				skills.add(gadgetSk);
			}
		}
		if (gadgetSk != null && ::Wuxia.hasMember(gadgetSk, "syncWithBag"))
			gadgetSk.syncWithBag(_actor);
	}
	else if (gadgetSk != null)
	{
		skills.removeByID("actives.wx_item_bag_gadget");
	}

	local firstPowder = ::Wuxia.CraftBridge.findActiveBagItem(_actor, "powder");
	local powderSk = skills.getSkillByID("actives.wx_item_tactical_powder");
	if (firstPowder != null)
	{
		if (powderSk == null)
		{
			if (::Wuxia.CraftBridge.countActiveHudSkills(_actor) < ::Wuxia.CraftBridge.MaxActiveHudSkills)
			{
				powderSk = ::new("scripts/skills/actives/wx_item_tactical_powder");
				skills.add(powderSk);
			}
		}
		if (powderSk != null && ::Wuxia.hasMember(powderSk, "syncWithBag"))
			powderSk.syncWithBag(_actor);
	}
	else if (powderSk != null)
	{
		skills.removeByID("actives.wx_item_tactical_powder");
	}
};

// Non-destructive hook on `wx_meditate` so Dan-Wu pills (`祝余辟谷丹`) & Shan-Hai Talismans (`夫诸凝霜佩`) amplify Qi meditation!
if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	::Wuxia.HooksMod.hook("scripts/skills/actives/wx_meditate", function( q )
	{
		q.onUse = @(__original) function( _user, _targetTile )
		{
			local ok = __original(_user, _targetTile);
			if (ok && _user != null && _user.isAlive() && ::Wuxia.hasMember(_user, "getSkills") && _user.getSkills() != null)
			{
				local extraQi = 0;
				local pBuff = _user.getSkills().getSkillByID("effects.wx_pill_battle_buff");
				if (pBuff != null && ("HasZhuyu" in pBuff.m) && pBuff.m.HasZhuyu)
					extraQi += 8;
				if (::Wuxia.hasMember(_user, "getItems") && _user.getItems() != null)
				{
					local acc = _user.getItems().getItemAtSlot(::Const.ItemSlot.Accessory);
					if (acc != null && ("m" in acc) && ("WX_GearTraitID" in acc.m) && acc.m.WX_GearTraitID == "shanhai_acc_fuzhu")
						extraQi += 6;
				}
				if (extraQi > 0)
					::Wuxia.CombatRules.restoreQi(_user, extraQi);
			}
			return ok;
		};
	});
}
