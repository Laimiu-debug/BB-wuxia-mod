// Taiji Stream Move #2: 两仪化劲剑 (Taiji Sword Circle + `太极听劲粘势` Deflection + `驻场气剑`!)

this.wx_sword_taiji <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_taiji";
		this.m.Name = "两仪化劲剑";
		this.m.Description = "太和玄门圆转借力剑诀：消耗 5 AP 与 19 内息，剑圈粘连化去来劲（命中 +10，致散劲虚弱），同时凝出一柄【驻场气剑】、展开【太极两仪域】并进入【太极听劲粘势】（化解近战并借力偏转轰击邻敌）！";
		this.m.Icon = "skills/wx_sword_taiji.png";
		this.m.IconDisabled = "skills/wx_sword_taiji_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_taiji";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_18";
		this.m.WX_AnimMode <- "taiji_field";
		this.m.WX_ChoreoID <- "wx_sword_taiji";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 19;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.28;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10;
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
			this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
			if ("Streams" in ::Wuxia)
				::Wuxia.Streams.spawnSwordNode(_user, _targetTile);
		}
		return hit;
	}
});
