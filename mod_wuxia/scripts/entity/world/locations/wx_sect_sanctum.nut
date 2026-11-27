// Independent World-Map Wuxia Sect Mountain Gate / Manor / Stronghold (`location.wx_sect_sanctum`)
// Consumes ZERO Faction IDs (strictly preserves < 64 Faction ID engine limit) and uses pure `Flags` serialization.

this.wx_sect_sanctum <- this.inherit("scripts/entity/world/location", {
	m = {
		WX_SectID           = "",
		WX_AllowCombatEnter = false,
		WX_BattleMode       = ""
	},

	function create()
	{
		this.location.create();
		this.m.TypeID = "location.wx_sect_sanctum";
		this.m.Name = "武林宗门山门";
		this.m.Description = "名震一方的武林宗门开山立院之地，寻常官兵匪寇皆不敢擅闯山门。";
		this.m.LocationType = this.Const.World.LocationType.Unique | this.Const.World.LocationType.Passive;
		this.m.IsSpawningDefenders = false;
		this.m.IsDespawningDefenders = false;
		this.m.IsScalingDefenders = false;
		this.m.IsAttackableByAI = false;
		this.m.IsShowingDefenders = false;
		this.m.IsShowingBanner = true;
		this.m.Resources = 0;
		this.m.VisibilityMult = 1.15;
	}

	function setSectID( _sectID )
	{
		if (_sectID == null || _sectID == "" || !(_sectID in ::Wuxia.Config.Sects))
			return;
		this.m.WX_SectID = _sectID;
		this.getFlags().set("wx_sect_id", _sectID);
		this.WX_RefreshSanctumVisuals();
	}

	function getSectID()
	{
		if (this.m.WX_SectID != null && this.m.WX_SectID != "")
			return this.m.WX_SectID;
		local f = this.getFlags().get("wx_sect_id");
		if (f != null && typeof f == "string" && f != "")
		{
			this.m.WX_SectID = f;
			return f;
		}
		return "";
	}

	function WX_RefreshSanctumVisuals()
	{
		local sid = this.getSectID();
		if (sid == "" || !(sid in ::Wuxia.Config.Sects))
			return;

		local spec = ::Wuxia.SectRelations.getSanctumVisualSpec(sid);
		this.m.Name = spec.FullName;
		this.m.Description = spec.Description;

		try
		{
			if (this.hasSprite("body"))
			{
				local bBrush = spec.WorldBrush;
				if (!::Wuxia.Appearance.brushExists(bBrush))
					bBrush = "wx_set_sect_mountain";
				this.getSprite("body").setBrush(bBrush);
			}
			if (this.hasSprite("lighting"))
			{
				local lBrush = spec.WorldBrush + "_light";
				if (::Wuxia.Appearance.brushExists(lBrush))
					this.getSprite("lighting").setBrush(lBrush);
			}
			if (this.hasSprite("location_banner") && spec.BannerBrush != "" && ::Wuxia.Appearance.brushExists(spec.BannerBrush))
			{
				local ban = this.getSprite("location_banner");
				ban.setBrush(spec.BannerBrush);
				ban.Visible = true;
			}
			if (this.hasLabel("name"))
			{
				local lbl = this.getLabel("name");
				lbl.Visible = true;
				lbl.Text = this.m.Name;
			}
		}
		catch (_e) {}
	}

	function getDescription()
	{
		return this.m.Description;
	}

	function onEnter()
	{
		local combat = this.m.WX_AllowCombatEnter;
		this.m.WX_AllowCombatEnter = false;
		if (!this.location.onEnter()) return false;
		if (combat) return true;

		local sid = this.getSectID();
		if (!(sid in ::Wuxia.Config.Sects)) return false;
		if (this.getFaction() != 0) this.WX_ResetPeacefulState();
		local screen = this.World.State.getWorldScreen();
		::Wuxia.SectRelations.discoverSect(sid);
		this.World.Flags.set("wx_visited_sanctum", true);
		this.World.Flags.set("wx_active_sanctum_sect", sid);
		this.World.State.setPause(true);
		screen.m.JSHandle.asyncCall("wxOpenSanctumModal", ::Wuxia.UI.buildSectRelationsDirectory(false, true));
		return false;
	}

	function onInit()
	{
		this.location.onInit();
		local body = this.hasSprite("body") ? this.getSprite("body") : this.addSprite("body");
		body.setBrush("wx_set_sect_mountain");

		if (!this.hasSprite("lighting"))
		{
			local lit = this.addSprite("lighting");
			if (lit != null) lit.IgnoreAmbientColor = true;
		}
		if (this.hasSprite("location_banner"))
		{
			this.getSprite("location_banner").setOffset(::createVec(0, 26));
		}
		if (this.hasLabel("name"))
		{
			local lbl = this.getLabel("name");
			lbl.Visible = true;
			lbl.Offset = ::createVec(0, 36);
		}
		this.WX_RefreshSanctumVisuals();
	}

	function WX_GetBattleMode()
	{
		return this.m.WX_BattleMode;
	}

	function WX_ResetPeacefulState()
	{
		this.m.WX_AllowCombatEnter = false;
		this.m.WX_BattleMode = "";
		this.clearTroops();
		this.getLoot().clear();
		try { this.setFaction(0); } catch (_e) {}
		this.m.LocationType = this.Const.World.LocationType.Unique | this.Const.World.LocationType.Passive;
		this.m.IsShowingDefenders = false;
		this.WX_RefreshSanctumVisuals();
	}

	function onDropLootForPlayer( _lootTable )
	{
		this.location.onDropLootForPlayer(_lootTable);
		this.m.Loot.clear();
	}

	function onCombatLost()
	{
		local sid = this.getSectID();
		local mode = this.WX_GetBattleMode();

		if (mode != "" && ::Wuxia.hasWorldField("Flags") && (sid in ::Wuxia.Config.Sects))
		{
			local day = ::World.getTime().Days;
			if (mode == "raid")
			{
				::Wuxia.SectRelations.addRelation(sid, -65);
				::World.Flags.set("wx_sanctum_sealed_" + sid, day);
				::World.Flags.set("wx_tea_raid_" + sid, day);
				::World.Flags.set("wx_raid_vault_looted_" + sid, true);
				::World.Flags.set("wx_blood_feud_" + sid, day);
				if (::World.Assets != null)
					::World.Assets.addBusinessReputation(110);
			}
			else
			{
				::Wuxia.SectRelations.addRelation(sid, 18);
				::World.Flags.set("wx_tea_trial_" + sid, day);
				if (::World.Assets != null)
					::World.Assets.addBusinessReputation(65);
			}
		}

		// Preserve the Mountain Gate permanently on the World Map (never call `this.location.onCombatLost()`)!
		this.WX_ResetPeacefulState();
	}

	function onDiscovered()
	{
		this.location.onDiscovered();
		local sid = this.getSectID();
		if (sid != "" && ("SectRelations" in ::Wuxia) && ("discoverSect" in ::Wuxia.SectRelations))
			::Wuxia.SectRelations.discoverSect(sid);
	}

	function getTooltip()
	{
		local ret = this.location.getTooltip();
		local sid = this.getSectID();
		if (ret != null && typeof ret == "array" && sid != "" && (sid in ::Wuxia.Config.Sects))
		{
			local sDef = ::Wuxia.Config.Sects[sid];
			local rel = ::Wuxia.SectRelations.getRelation(sid);
			local relStr = rel > 0 ? ("+" + rel) : ("" + rel);
			local vWarn = ::Wuxia.SectRelations.isVendettaActive(sid) ? " [color=#721010]（结仇追缉中）[/color]" : "";
			local sealDays = ("getTeaCooldownLeft" in ::Wuxia.SectRelations) ? ::Wuxia.SectRelations.getSanctumSealLeft(sid) : 0;
			if (sealDays > 0)
				vWarn += " [color=#6c1f04]（重创封山余 " + sealDays + " 日）[/color]";
			ret.push({
				id   = 76,
				type = "text",
				icon = "ui/wx_icons/wx_glyph_sect_token.png",
				text = "开山宗门：[color=#5e2c00]【" + sDef.Name + "】[/color]（当前交情 " + relStr + "）" + vWarn
			});
			ret.push({
				id   = 77,
				type = "hint",
				icon = "ui/icons/mouse_right_button.png",
				text = "踏入山门可：接领宗门法帖、闯护山大阵、延请真传弟子、长老灌顶疗内伤、购本门灵草或生死踢馆"
			});
		}
		return ret;
	}

	function onDeserialize( _in )
	{
		this.location.onDeserialize(_in);
		this.WX_ResetPeacefulState();
	}
});
