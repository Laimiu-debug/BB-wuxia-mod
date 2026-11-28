// Shan Hai Multi-Tile Boss Mode A Sub-Entity: Coiled Linked Body/Tail Segment (`赤鳞龙躯 / 盘山龙尾`)
// Independent scale armor; breaking armor cripples corresponding Boss constriction/sweep; post-armor HP damage transfers 75% to Master!

this.wx_boss_part_segment <- this.inherit("scripts/entity/tactical/enemies/unhold", {
	m = {
		WX_IsBossSubEntity = true,
		WX_PartRole        = "segment",
		WX_Master          = null,
		WX_PartKey         = "body_seg",
		WX_BaseBrush       = "wx_tail_zhuyin",
		WX_ArmorBrokenSent = false
	},

	function onInit()
	{
		this.unhold.onInit();
		this.m.XP = 0;
		local b = this.m.BaseProperties;
		b.ActionPoints = 0;
		b.Hitpoints = 2500;
		b.Bravery = 200;
		b.MeleeSkill = 75;
		b.MeleeDefense = 10;
		b.RangedDefense = 8;
		b.Armor = [240, 180];
		b.ArmorMax = [240, 180];
		b.IsRooted = true;
		b.IsImmuneToKnockBackAndGrab = true;
		b.IsImmuneToStun = true;
		b.IsImmuneToDisarm = true;
		this.m.ActionPoints = 0;
		this.m.Hitpoints = b.Hitpoints;
		this.m.CurrentProperties = b.getClone();
	}

	function setupSegment( _master, _spec )
	{
		this.m.WX_Master = _master;
		if ("Key" in _spec) this.m.WX_PartKey = _spec.Key;
		if ("Name" in _spec) this.setName(_spec.Name);
		local bodyArm = ("BodyArmor" in _spec) ? _spec.BodyArmor : 240;
		local headArm = ("HeadArmor" in _spec) ? _spec.HeadArmor : 180;
		this.m.BaseProperties.Armor = [bodyArm, headArm];
		this.m.BaseProperties.ArmorMax = [bodyArm, headArm];
		if ("MeleeDef" in _spec) this.m.BaseProperties.MeleeDefense = _spec.MeleeDef;

		local brush = ("Brush" in _spec && _spec.Brush != null) ? _spec.Brush : "wx_tail_zhuyin";
		this.m.WX_BaseBrush = brush;
		if ("Appearance" in ::Wuxia && ::Wuxia.Appearance.brushExists(brush))
			::Wuxia.Appearance.applyCustomEnemyBust(this, brush);
		if (this.getSkills() != null)
		{
			if (!this.getSkills().hasSkill("perk.steel_brow"))
				this.getSkills().add(::new("scripts/skills/perks/perk_steel_brow"));
			this.getSkills().update();
		}
	}

	function onDamageReceived( _attacker, _skill, _hitInfo )
	{
		local ret = this.unhold.onDamageReceived(_attacker, _skill, _hitInfo);
		local master = this.m.WX_Master;
		if (master != null && master.isAlive())
		{
			if (!this.m.WX_ArmorBrokenSent && this.getArmor(::Const.BodyPart.Body) <= 0)
			{
				this.m.WX_ArmorBrokenSent = true;
				local injBrush = this.m.WX_BaseBrush + "_injured";
				if ("Appearance" in ::Wuxia && ::Wuxia.Appearance.brushExists(injBrush))
					::Wuxia.Appearance.applyCustomEnemyBust(this, injBrush);
				::Wuxia.ShanHaiMultiBody.onSegmentArmorBroken(master, this.m.WX_PartKey, this.getName());
			}
			// Forward post-armor vitality shock to Master Boss (`同命真龙躯`)
			if (_hitInfo != null && ("DamageRegular" in _hitInfo) && _hitInfo.DamageRegular > 0 && this.getArmor(::Const.BodyPart.Body) <= 40)
			{
				local xfer = ::Math.max(4, ::Math.floor(_hitInfo.DamageRegular * 0.75));
				if (master.getHitpoints() > xfer + 1)
					master.setHitpoints(master.getHitpoints() - xfer);
				else
					master.setHitpoints(1);
			}
			// Prevent segment itself from dying before Master
			if (this.m.Hitpoints < 500) this.m.Hitpoints = 500;
		}
		return ret;
	}
});
