// Active Skill: 斗转星移诀
this.wx_neigong_douzhuan <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_19", WX_AnimID = "wx_anim_146", WX_AnimMode = "stance_douzhuan" },
	function create()
	{
		this.m.ID = "actives.wx_neigong_douzhuan";
		this.m.Name = "斗转星移诀";
		this.m.Description = "姑苏借力返照奇功：消耗 4 AP 与 22 内息，布下星璇卸劲气场，本回合近防 +8、远防 +8 并开启借力反击架势（最多借力反击 2 次且次击衰减，与普通格反互斥，冷却 3 回合）。";
		this.m.Icon = "skills/wx_neigong_douzhuan.png";
		this.m.IconDisabled = "skills/wx_neigong_douzhuan_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_douzhuan";
		this.m.WX_AnimID <- "wx_anim_146";
		this.m.WX_AnimMode <- "stance_douzhuan";
		this.m.WX_ChoreoID <- "wx_neigong_douzhuan";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 22;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable()
	{
		if (this.m.Cooldown > 0 || this.m.ActiveBuff || !this.skill.isUsable()) return false;
		if (this.getContainer() != null && (this.getContainer().hasSkill("effects.wx_status_counter_stance") || this.getContainer().hasSkill("effects.riposte")))
			return false;
		return true;
	}
	function onUpdate( _properties )
	{
		if (this.m.ActiveBuff)
		{
			_properties.MeleeDefense += 8; _properties.RangedDefense += 8;
		}
	}
	function onTurnStart() { this.m.ActiveBuff = false; if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.ActiveBuff = true;
		this.m.Cooldown = 3;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		local sk = _user.getSkills();
		if (sk != null)
		{
			if (sk.hasSkill("effects.riposte")) sk.removeByID("effects.riposte");
			local cs = sk.getSkillByID("effects.wx_status_counter_stance");
			if (cs == null)
			{
				cs = ::new("scripts/skills/effects/wx_status_counter_stance");
				cs.setDouzhuanMode(true);
				sk.add(cs);
			}
			else
			{
				cs.setDouzhuanMode(true);
			}
		}
		this.getContainer().update();
		return true;
	}
});
