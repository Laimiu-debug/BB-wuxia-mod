// Shan Hai Multi-Tile Boss Mode B Sub-Entity: Independent Severable Appendage / Head (`相柳四首` etc.)
// Slaying this appendage severs it from the Master Boss, permanently/cyclically locking out `WX_LockedSkillID`!

this.wx_boss_part_appendage <- this.inherit("scripts/entity/tactical/enemies/direwolf", {
	m = {
		WX_IsBossSubEntity = true,
		WX_PartRole        = "appendage",
		WX_Master          = null,
		WX_PartKey         = "head_1",
		WX_BaseBrush       = "wx_part_xiangliu_mire",
		WX_LockedSkillID   = "",
		WX_RoleHint        = ""
	},

	function onInit()
	{
		this.direwolf.onInit();
		this.m.XP = 0;
		local b = this.m.BaseProperties;
		b.ActionPoints = 5;
		b.Hitpoints = 155;
		b.Bravery = 180;
		b.MeleeSkill = 76;
		b.MeleeDefense = 12;
		b.RangedDefense = 10;
		b.Armor = [95, 75];
		b.ArmorMax = [95, 75];
		b.DamageRegularMin = 28;
		b.DamageRegularMax = 44;
		b.DamageArmorMult = 1.05;
		b.IsRooted = true;
		b.IsImmuneToKnockBackAndGrab = true;
		this.m.ActionPoints = b.ActionPoints;
		this.m.Hitpoints = b.Hitpoints;
		this.m.CurrentProperties = b.getClone();
	}

	function setupAppendage( _master, _spec )
	{
		this.m.WX_Master = _master;
		if ("Key" in _spec) this.m.WX_PartKey = _spec.Key;
		if ("Name" in _spec) this.setName(_spec.Name);
		if ("LockedSkillID" in _spec) this.m.WX_LockedSkillID = _spec.LockedSkillID;
		if ("RoleHint" in _spec) this.m.WX_RoleHint = _spec.RoleHint;

		local hp = ("Hitpoints" in _spec) ? _spec.Hitpoints : (("HP" in _spec) ? _spec.HP : 155);
		local bodyArm = ("BodyArmor" in _spec) ? _spec.BodyArmor : 95;
		local headArm = ("HeadArmor" in _spec) ? _spec.HeadArmor : ::Math.floor(bodyArm * 0.8);
		this.m.BaseProperties.Hitpoints = hp;
		this.m.BaseProperties.Armor = [bodyArm, headArm];
		this.m.BaseProperties.ArmorMax = [bodyArm, headArm];
		if ("MeleeDef" in _spec) this.m.BaseProperties.MeleeDefense = _spec.MeleeDef;
		this.m.Hitpoints = hp;

		local brush = ("Brush" in _spec && _spec.Brush != null) ? _spec.Brush : "wx_part_xiangliu_mire";
		this.m.WX_BaseBrush = brush;
		if ("Appearance" in ::Wuxia && ::Wuxia.Appearance.brushExists(brush))
			::Wuxia.Appearance.applyCustomEnemyBust(this, brush);
		if (this.getSkills() != null)
		{
			this.getSkills().removeByID("actives.werewolf_bite");
			if (!this.getSkills().hasSkill("actives.serpent_bite"))
			{
				try { this.getSkills().add(::new("scripts/skills/actives/serpent_bite_skill")); } catch (_e) {}
			}
			this.getSkills().update();
		}
	}

	function onDamageReceived( _attacker, _skill, _hitInfo )
	{
		local ret = this.direwolf.onDamageReceived(_attacker, _skill, _hitInfo);
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
		::Wuxia.ShanHaiMultiBody.onAppendageSevered(this, _killer, _skill, _tile);
		this.direwolf.onDeath(_killer, _skill, _tile, _fatalityType);
	}
});
