// Shan Hai Boss Bespoke Active (`boss_nvchou` #2): 青袂障面·移日换影 (Swap Position with Surviving Sun Corona Totem!)

this.wx_boss_nvchou_sleeve_shift <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_25",
		WX_ChoreoID = "wx_boss_nvchou_sleeve_shift"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_nvchou_sleeve_shift";
		this.m.Name = "青袂障面·移日换影";
		this.m.Description = "女丑挥起青衣长袂掩面化虹，与场上距离最远的一轮【炙魂日冕】瞬间乾坤易位脱出重围，并在原处留下灼目热浪迷障！";
		this.m.Icon = "skills/wx_qinggong_meiying.png";
		this.m.IconDisabled = "skills/wx_qinggong_meiying_sw.png";
		this.m.Overlay = "wx_ov_wx_qinggong_meiying";
		this.m.SoundOnUse = ["sounds/combat/riposte_01.wav"];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 12;
	}

	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null) return false;
		return ::Wuxia.ShanHaiMultiBody.getAliveTotems(actor).len() > 0;
	}

	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		if (!::Wuxia.isOnMap(_user)) return false;
		local totems = ::Wuxia.ShanHaiMultiBody.getAliveTotems(_user);
		if (totems.len() == 0) return false;

		local uTile = _user.getTile();
		local bestTotem = null;
		local bestDist = -1;
		foreach (tot in totems)
		{
			if (!tot.isPlacedOnMap()) continue;
			local d = uTile.getDistanceTo(tot.getTile());
			if (d > bestDist) { bestDist = d; bestTotem = tot; }
		}
		if (bestTotem == null) return false;

		local tTile = bestTotem.getTile();
		local emptyNear = ::Wuxia.ShanHaiMultiBody.findNearbyEmptyTiles(tTile, 1, 1, 1);
		if (emptyNear.len() > 0)
		{
			::Wuxia.TileField.setField(uTile, "mirage_mist", 2, _user);
			::Tactical.getNavigator().teleport(_user, emptyNear[0], null, null, false);
			return true;
		}
		return false;
	}
});
