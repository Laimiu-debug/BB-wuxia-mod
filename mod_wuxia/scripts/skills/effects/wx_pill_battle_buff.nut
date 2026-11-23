// Single-Battle Temporary Alchemy Pill & Raw Herb Buff
// Expires automatically after 1 battle; zero permanent stat inflation; backward-compatible 1/2-byte U8 save stream!

this.wx_pill_battle_buff <- this.inherit("scripts/skills/skill", {
	m = {
		HasQingxin   = false, // 清心解毒丹: Poison immunity
		HasHugu      = false, // 虎骨壮气丸: +12 Stamina, +2 FatigueRecoveryRate
		HasDingshen  = false, // 明目定神散: +10 Bravery, Night immunity
		HasZhuyu     = false, // 祝余辟谷丹: +16 Stamina, +3 FatigueRecoveryRate
		HasDuheng    = false, // 杜衡追风丸: +18 Initiative, +5 RangedDefense
		HasDixiu     = false, // 帝休定岳丹: +14 Bravery, Stun immunity
		HasBingxin   = false, // 天山雪莲冰心丹: Poison immunity & Night immunity
		HasGuiyuan   = false, // 首乌归元培气丸: +18 Hitpoints, +2 FatigueRecoveryRate
		HasBaishe    = false, // 五毒百草辟瘴丸: Poison immunity, +4 MeleeDef, +4 RangedDef
		HasJinzun    = false, // 金刚铁骨护体丸: -12% HP & Armor damage taken, Knockback immunity
		HasHerbSwift = false, // 生嚼杜衡草: +10 Initiative
		HasHerbCalm  = false, // 生服迷榖/帝休/植楮: Bravery & Night immunity
		HerbCalmBravery = 6
	},

	function create()
	{
		this.m.ID = "effects.wx_pill_battle_buff";
		this.m.Name = "丹药行气";
		this.m.Description = "战前服食灵丹或山海奇草，药力正于奇经八脉间温养流转，经历一场实战后自然消散。";
		this.m.Icon = "skills/wx_status_poise_charge.png";
		this.m.IconMini = "status_effect_74_mini";
		this.m.Type = this.Const.SkillType.StatusEffect | this.Const.SkillType.DrugEffect;
		this.m.Order = this.Const.SkillOrder.Perk;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = true;
		this.m.IsRemovedAfterBattle = true;
	}

	function addPillBuff( _kind, _herbCalmBravery = 6 )
	{
		if (_kind == "buff_qingxin") this.m.HasQingxin = true;
		else if (_kind == "buff_hugu") this.m.HasHugu = true;
		else if (_kind == "buff_dingshen") this.m.HasDingshen = true;
		else if (_kind == "buff_zhuyu") this.m.HasZhuyu = true;
		else if (_kind == "buff_duheng") this.m.HasDuheng = true;
		else if (_kind == "buff_dixiu") this.m.HasDixiu = true;
		else if (_kind == "buff_bingxin") this.m.HasBingxin = true;
		else if (_kind == "buff_guiyuan") this.m.HasGuiyuan = true;
		else if (_kind == "buff_baishe") this.m.HasBaishe = true;
		else if (_kind == "buff_jinzun") this.m.HasJinzun = true;
		else if (_kind == "herb_swift") this.m.HasHerbSwift = true;
		else if (_kind == "herb_calm")
		{
			this.m.HasHerbCalm = true;
			this.m.HerbCalmBravery = _herbCalmBravery;
		}
		this.updateLabel();
	}

	function hasBuffKind( _kind )
	{
		if (_kind == "buff_qingxin") return this.m.HasQingxin;
		if (_kind == "buff_hugu") return this.m.HasHugu;
		if (_kind == "buff_dingshen") return this.m.HasDingshen;
		if (_kind == "buff_zhuyu") return this.m.HasZhuyu;
		if (_kind == "buff_duheng") return this.m.HasDuheng;
		if (_kind == "buff_dixiu") return this.m.HasDixiu;
		if (_kind == "buff_bingxin") return this.m.HasBingxin;
		if (_kind == "buff_guiyuan") return this.m.HasGuiyuan;
		if (_kind == "buff_baishe") return this.m.HasBaishe;
		if (_kind == "buff_jinzun") return this.m.HasJinzun;
		if (_kind == "herb_swift") return this.m.HasHerbSwift;
		if (_kind == "herb_calm") return this.m.HasHerbCalm;
		return false;
	}

	function updateLabel()
	{
		local parts = [];
		if (this.m.HasQingxin) parts.push("清心");
		if (this.m.HasHugu) parts.push("壮气");
		if (this.m.HasDingshen) parts.push("定神");
		if (this.m.HasZhuyu) parts.push("祝余");
		if (this.m.HasDuheng) parts.push("追风");
		if (this.m.HasDixiu) parts.push("定岳");
		if (this.m.HasBingxin) parts.push("冰心");
		if (this.m.HasGuiyuan) parts.push("归元");
		if (this.m.HasBaishe) parts.push("辟瘴");
		if (this.m.HasJinzun) parts.push("铁骨");
		if (this.m.HasHerbSwift) parts.push("善走");
		if (this.m.HasHerbCalm) parts.push("醒神");
		this.m.Name = parts.len() > 0 ? ("丹力：" + this.wxJoin(parts, "·")) : "丹药行气";
	}

	function wxJoin( _arr, _sep )
	{
		local s = "";
		for (local i = 0; i < _arr.len(); i = ++i)
		{
			if (i > 0) s += _sep;
			s += _arr[i];
		}
		return s;
	}

	function getSummaryLabels()
	{
		local list = [];
		if (this.m.HasQingxin) list.push("清心免毒");
		if (this.m.HasHugu) list.push("虎骨壮气(+12气)");
		if (this.m.HasDingshen) list.push("明目定神(+10定)");
		if (this.m.HasZhuyu) list.push("祝余辟谷(+16气/+3回)");
		if (this.m.HasDuheng) list.push("杜衡追风(+18身)");
		if (this.m.HasDixiu) list.push("帝休定岳(+14定/免晕)");
		if (this.m.HasBingxin) list.push("雪莲冰心(免毒免夜)");
		if (this.m.HasGuiyuan) list.push("首乌归元(+18血)");
		if (this.m.HasBaishe) list.push("百草辟瘴(免毒+4防)");
		if (this.m.HasJinzun) list.push("金刚护体(减伤12%)");
		if (this.m.HasHerbSwift) list.push("奇草善走(+10身)");
		if (this.m.HasHerbCalm) list.push("奇草醒神(+" + this.m.HerbCalmBravery + "定)");
		return list;
	}

	function getTooltip()
	{
		this.updateLabel();
		local pos = ::Const.UI.Color.PositiveValue;
		local ret = [
			{ id = 1, type = "title", text = this.m.Name + "（下场战斗生效）" },
			{ id = 2, type = "description", text = this.getDescription() }
		];
		if (this.m.HasQingxin)
			ret.push({ id = 10, type = "text", icon = "ui/icons/special.png", text = "【清心解毒丹】免疫吹箭奇毒与蛛蝎毒素侵害" });
		if (this.m.HasHugu)
			ret.push({ id = 11, type = "text", icon = "ui/icons/fatigue.png", text = "【虎骨壮气丸】内息上限 [color=" + pos + "]+12[/color]，每回合回气 [color=" + pos + "]+2[/color]" });
		if (this.m.HasDingshen)
			ret.push({ id = 12, type = "text", icon = "ui/icons/bravery.png", text = "【明目定神散】定力 [color=" + pos + "]+10[/color]，夜战免除视野与射艺惩罚" });
		if (this.m.HasZhuyu)
			ret.push({ id = 13, type = "text", icon = "ui/icons/fatigue.png", text = "【祝余辟谷丹】内息上限 [color=" + pos + "]+16[/color]，每回合回气 [color=" + pos + "]+3[/color]" });
		if (this.m.HasDuheng)
			ret.push({ id = 14, type = "text", icon = "ui/icons/initiative.png", text = "【杜衡追风丸】身法 [color=" + pos + "]+18[/color]，远防 [color=" + pos + "]+5[/color]" });
		if (this.m.HasDixiu)
			ret.push({ id = 15, type = "text", icon = "ui/icons/bravery.png", text = "【帝休定岳丹】定力 [color=" + pos + "]+14[/color]，且免疫震晕击晕" });
		if (this.m.HasBingxin)
			ret.push({ id = 16, type = "text", icon = "ui/icons/special.png", text = "【天山雪莲冰心丹】全程免疫奇毒侵害且免除夜战视野惩罚" });
		if (this.m.HasGuiyuan)
			ret.push({ id = 17, type = "text", icon = "ui/icons/health.png", text = "【首乌归元培气丸】气血上限 [color=" + pos + "]+18[/color]，每回合回气 [color=" + pos + "]+2[/color]" });
		if (this.m.HasBaishe)
			ret.push({ id = 18, type = "text", icon = "ui/icons/melee_defense.png", text = "【五毒百草辟瘴丸】免疫奇毒，且近防 [color=" + pos + "]+4[/color]、远防 [color=" + pos + "]+4[/color]" });
		if (this.m.HasJinzun)
			ret.push({ id = 19, type = "text", icon = "ui/icons/armor_body.png", text = "【金刚铁骨护体丸】所受气血与护甲伤害减免 [color=" + pos + "]12%[/color]，且免疫击退抓取" });
		if (this.m.HasHerbSwift)
			ret.push({ id = 20, type = "text", icon = "ui/icons/initiative.png", text = "【杜衡奇草】身法临时 [color=" + pos + "]+10[/color]" });
		if (this.m.HasHerbCalm)
			ret.push({ id = 21, type = "text", icon = "ui/icons/bravery.png", text = "【山海灵枝】定力临时 [color=" + pos + "]+" + this.m.HerbCalmBravery + "[/color] 且免除夜盲" });
		return ret;
	}

	function onUpdate( _properties )
	{
		if (this.m.HasQingxin || this.m.HasBingxin || this.m.HasBaishe)
			_properties.IsImmuneToPoison = true;

		// Use Math.max across same-stat battle pills to prevent stacking abuse!
		local stamAdd = ::Math.max(this.m.HasHugu ? 12 : 0, this.m.HasZhuyu ? 16 : 0);
		local recAdd  = ::Math.max(this.m.HasZhuyu ? 3 : 0, (this.m.HasHugu || this.m.HasGuiyuan) ? 2 : 0);
		local bravAdd = ::Math.max(this.m.HasDixiu ? 14 : 0, ::Math.max(this.m.HasDingshen ? 10 : 0, this.m.HasHerbCalm ? this.m.HerbCalmBravery : 0));
		local initAdd = ::Math.max(this.m.HasDuheng ? 18 : 0, this.m.HasHerbSwift ? 10 : 0);

		if (stamAdd > 0) _properties.Stamina += stamAdd;
		if (recAdd > 0)  _properties.FatigueRecoveryRate += recAdd;
		if (bravAdd > 0) _properties.Bravery += bravAdd;
		if (initAdd > 0) _properties.Initiative += initAdd;

		if (this.m.HasDuheng)
			_properties.RangedDefense += 5;
		if (this.m.HasDixiu)
			_properties.IsImmuneToStun = true;
		if (this.m.HasDingshen || this.m.HasBingxin || this.m.HasHerbCalm)
			_properties.IsAffectedByNight = false;
		if (this.m.HasGuiyuan)
			_properties.Hitpoints += 18;
		if (this.m.HasBaishe)
		{
			_properties.MeleeDefense += 4;
			_properties.RangedDefense += 4;
		}
		if (this.m.HasJinzun)
		{
			_properties.DamageReceivedRegularMult *= 0.88;
			_properties.DamageReceivedArmorMult *= 0.88;
			_properties.IsImmuneToKnockBackAndGrab = true;
		}
	}

	function onCombatFinished()
	{
		this.removeSelf();
	}

	function onSerialize( _out )
	{
		this.skill.onSerialize(_out);
		local mask1 = (this.m.HasQingxin ? 1 : 0)
			| (this.m.HasHugu ? 2 : 0)
			| (this.m.HasDingshen ? 4 : 0)
			| (this.m.HasZhuyu ? 8 : 0)
			| (this.m.HasDuheng ? 16 : 0)
			| (this.m.HasDixiu ? 32 : 0)
			| (this.m.HasBingxin ? 64 : 0);
		local mask2 = (this.m.HasGuiyuan ? 1 : 0)
			| (this.m.HasBaishe ? 2 : 0)
			| (this.m.HasJinzun ? 4 : 0)
			| (this.m.HasHerbSwift ? 8 : 0)
			| (this.m.HasHerbCalm ? 16 : 0);
		if (mask2 != 0)
		{
			_out.writeU8(mask1 | 128);
			_out.writeU8(mask2);
		}
		else
		{
			_out.writeU8(mask1);
		}
	}

	function onDeserialize( _in )
	{
		this.skill.onDeserialize(_in);
		local mask1 = _in.readU8();
		local mask2 = ((mask1 & 128) != 0) ? _in.readU8() : 0;
		this.m.HasQingxin   = (mask1 & 1) != 0;
		this.m.HasHugu      = (mask1 & 2) != 0;
		this.m.HasDingshen  = (mask1 & 4) != 0;
		this.m.HasZhuyu     = (mask1 & 8) != 0;
		this.m.HasDuheng    = (mask1 & 16) != 0;
		this.m.HasDixiu     = (mask1 & 32) != 0;
		this.m.HasBingxin   = (mask1 & 64) != 0;
		this.m.HasGuiyuan   = (mask2 & 1) != 0;
		this.m.HasBaishe    = (mask2 & 2) != 0;
		this.m.HasJinzun    = (mask2 & 4) != 0;
		this.m.HasHerbSwift = (mask2 & 8) != 0;
		this.m.HasHerbCalm  = (mask2 & 16) != 0;
		this.updateLabel();
	}
});
