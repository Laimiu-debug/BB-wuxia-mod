// Shan Hai Multi-Tile Boss Mode C Sub-Entity: Celestial / Elemental Domain Totem (`汤谷炙魂日冕` etc.)
// Projects battlefield domain laws for its Master Boss; destroying it weakens the Boss's barrier or interrupts cataclysms!

this.wx_boss_part_totem <- this.inherit("scripts/entity/tactical/enemies/ghost", {
	m = {
		WX_IsBossSubEntity = true,
		WX_PartRole        = "totem",
		WX_Master          = null,
		WX_PartKey         = "totem_1",
		WX_BaseBrush       = "wx_totem_sun_corona",
		WX_RoleHint        = ""
	},

	function onInit()
	{
		this.ghost.onInit();
		this.m.IsGenerateXP = false;
		local b = this.m.BaseProperties;
		b.ActionPoints = 0;
		b.Hitpoints = 85;
		b.Bravery = 200;
		b.MeleeSkill = 0;
		b.MeleeDefense = 8;
		b.RangedDefense = 4; // Tuned for "Houyi Shoots the Suns" ranged counterplay!
		b.IsRooted = true;
		b.IsImmuneToKnockBackAndGrab = true;
		b.IsImmuneToBleeding = true;
		b.IsImmuneToPoison = true;
		b.IsImmuneToStun = true;
		// Override ghost 90% physical immunity so archers & melee warriors can cleanly shatter totems!
		b.DamageReceivedRegularMult = 1.0;
		this.m.ActionPoints = 0;
		this.m.Hitpoints = b.Hitpoints;
		this.m.CurrentProperties = clone b;
	}

	function setupTotem( _master, _spec )
	{
		this.m.WX_Master = _master;
		if ("Key" in _spec) this.m.WX_PartKey = _spec.Key;
		if ("Name" in _spec) this.setName(_spec.Name);
		if ("RoleHint" in _spec) this.m.WX_RoleHint = _spec.RoleHint;
		local hp = ("Hitpoints" in _spec) ? _spec.Hitpoints : (("HP" in _spec) ? _spec.HP : 85);
		this.m.BaseProperties.Hitpoints = hp;
		this.m.Hitpoints = hp;
		if ("RangedDef" in _spec) this.m.BaseProperties.RangedDefense = _spec.RangedDef;
		if ("MeleeDef" in _spec) this.m.BaseProperties.MeleeDefense = _spec.MeleeDef;

		local brush = ("Brush" in _spec && _spec.Brush != null) ? _spec.Brush : "wx_totem_sun_corona";
		this.m.WX_BaseBrush = brush;
		if ("Appearance" in ::Wuxia && ::Wuxia.Appearance.brushExists(brush))
			::Wuxia.Appearance.applyCustomEnemyBust(this, brush);
		if (this.hasSprite("body") && ("TintHex" in _spec) && _spec.TintHex != null)
			this.getSprite("body").Color = ::createColor(_spec.TintHex);
		if (this.getSkills() != null)
		{
			// Remove vanilla ghost scream/touch skills so totems act purely as domain anchors
			this.getSkills().removeByID("actives.horrific_scream");
			this.getSkills().removeByID("actives.ghastly_touch");
			this.getSkills().update();
		}
	}

	function onDamageReceived( _attacker, _skill, _hitInfo )
	{
		local ret = this.ghost.onDamageReceived(_attacker, _skill, _hitInfo);
		if (this.isAlive() && this.getHitpointsPct() <= 0.55)
		{
			local injBrush = this.m.WX_BaseBrush + "_injured";
			if ("Appearance" in ::Wuxia && ::Wuxia.Appearance.brushExists(injBrush))
				::Wuxia.Appearance.applyCustomEnemyBust(this, injBrush);
		}
		return ret;
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.m.WX_DeathHandled <- true;
		::Wuxia.ShanHaiMultiBody.onTotemDestroyed(this, _killer, _skill, _tile);
		this.ghost.onDeath(_killer, _skill, _tile, _fatalityType);
	}
});
