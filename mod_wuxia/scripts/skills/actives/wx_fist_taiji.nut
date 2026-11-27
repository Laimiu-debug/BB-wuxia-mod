// Taiji Stream Move #1: 揽雀借力掌 (Taiji Push + Enters `太极听劲粘势` Adjacent-Enemy Deflection + `太极两仪域`!)

this.wx_fist_taiji <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_taiji";
		this.m.Name = "揽雀借力掌";
		this.m.Description = "太和山四两拨千斤绝技：消耗 4 AP 与 16 内息，圆转云手震退来敌致其散劲虚弱；同时在脚下布开【太极两仪域】并进入【太极听劲粘势】——下回合前敌方近战落空时将其力道 85% 借力偏转轰击相邻另一名敌军！";
		this.m.Icon = "skills/wx_fist_taiji.png";
		this.m.IconDisabled = "skills/wx_fist_taiji_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_taiji";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_52";
		this.m.WX_AnimMode <- "taiji_orb";
		this.m.WX_ChoreoID <- "wx_fist_taiji";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.35;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		if (::Wuxia.hasMember(_user, "getTile") && _user.getTile() != null && ("TileField" in ::Wuxia))
			::Wuxia.TileField.setField(_user.getTile(), "ancient_ward", 2, _user, "taiji_domain");

		local usk = _user.getSkills();
		if (usk != null)
		{
			if (usk.hasSkill("effects.riposte")) usk.removeByID("effects.riposte");
			local cs = usk.getSkillByID("effects.wx_status_counter_stance");
			if (cs == null)
			{
				cs = ::new("scripts/skills/effects/wx_status_counter_stance");
				cs.setTaijiMode(true);
				usk.add(cs);
			}
			else cs.setTaijiMode(true);
		}

		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			// If another enemy stands next to `target`, immediately bounce kinetic shock into them too!
			if ("Streams" in ::Wuxia)
				::Wuxia.Streams.tryDeflectMeleeAttack(_user, target, false);
			else
				this.wxTryKnockback(_user, target);
			this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		return hit;
	}
});
