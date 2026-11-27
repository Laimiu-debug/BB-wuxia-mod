// Active Blade Coating Status Effect (`兵刃涂膏`)
// Supports multi-sect coatings (e.g.《钦原断续蚀壳膏》/《丹劫暴烈奇毒散》涂刃); new coating replaces old without stacking.

this.wx_status_blade_coating <- this.inherit("scripts/skills/skill", {
	m = {
		CoatingID   = "wx_tact_qinyuangao",
		HitsLeft    = 4,
		CoatingName = "钦原断续蚀壳膏"
	},

	function create()
	{
		this.m.ID = "effects.wx_status_blade_coating";
		this.m.Name = "兵刃淬膏";
		this.m.Description = "主手兵刃已涂抹奇门秘膏，命中敌手时激发独门破局药力。";
		this.m.Icon = "skills/wx_status_poison_dart.png";
		this.m.IconMini = "status_effect_54_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function applyCoating( _coatingID, _hits = 4, _name = "钦原断续蚀壳膏" )
	{
		this.m.CoatingID = _coatingID;
		this.m.HitsLeft = ::Math.max(1, _hits);
		this.m.CoatingName = _name;
		this.m.Name = "淬刃：" + _name + "（余" + this.m.HitsLeft + "击）";
	}

	function getTooltip()
	{
		local ret = [
			{ id = 1, type = "title", text = this.m.Name },
			{ id = 2, type = "description", text = this.getDescription() }
		];
		if (this.m.CoatingID == "wx_tact_qinyuangao")
		{
			ret.push({
				id = 10, type = "text", icon = "ui/icons/armor_damage.png",
				text = "攻击命中施加 2 回合【断续封生】（封死大妖气血再生与复生），并额外蚀损 [color=#0a4213]14[/color] 点身甲与 [color=#0a4213]1[/color] 层大妖玄壳（余 " + this.m.HitsLeft + " 击）"
			});
		}
		else if (this.m.CoatingID == "wx_tact_huaxuegao")
		{
			ret.push({
				id = 10, type = "text", icon = "ui/icons/health.png",
				text = "攻击流血/破绽/内伤目标引爆旧创追加 [color=#0a4213]8[/color] 点无视护甲实伤，并撕开深层流血（余 " + this.m.HitsLeft + " 击）"
			});
		}
		else if (this.m.CoatingID == "wx_tact_chunyangyou")
		{
			ret.push({
				id = 10, type = "text", icon = "ui/icons/armor_damage.png",
				text = "每击焚毁目标 [color=#0a4213]16[/color] 点身甲；迎战古墓机关与湘西尸傀时额外轰入 [color=#0a4213]14[/color] 点纯阳实伤并封断亡灵复生（余 " + this.m.HitsLeft + " 击）"
			});
		}
		else if (this.m.CoatingID == "wx_tact_zimuguzhi")
		{
			ret.push({
				id = 10, type = "text", icon = "ui/icons/special.png",
				text = "命中必种【暗器奇毒】与【子母蛊印】；宿主阵亡时子蛊跃向 2 格内至多 2 名敌军传染奇毒与破绽（余 " + this.m.HitsLeft + " 击）"
			});
		}
		else
		{
			ret.push({
				id = 10, type = "text", icon = "ui/icons/special.png",
				text = "攻击命中附带丹劫火毒灼毁 [color=#0a4213]12[/color] 点身甲并注入【暗器奇毒】（余 " + this.m.HitsLeft + " 击）"
			});
		}
		return ret;
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (_skill == null || !_skill.isAttack() || _targetEntity == null || !_targetEntity.isAlive())
			return;
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || actor.isAlliedWith(_targetEntity))
			return;

		local tsk = ::Wuxia.hasMember(_targetEntity, "getSkills") ? _targetEntity.getSkills() : null;
		local tItems = ::Wuxia.hasMember(_targetEntity, "getItems") ? _targetEntity.getItems() : null;

		if (this.m.CoatingID == "wx_tact_qinyuangao")
		{
			if (tItems != null)
			{
				local tBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
				if (tBody != null && ::Wuxia.hasMember(tBody, "getArmor") && tBody.getArmor() > 0)
					tBody.setArmor(::Math.max(0, tBody.getArmor() - 14));
			}
			::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, {
				SealRegenTurns = 2,
				CorrodeShell   = 1
			});
		}
		else if (this.m.CoatingID == "wx_tact_huaxuegao")
		{
			local hasWound = tsk != null && (tsk.hasSkill("effects.bleeding") || tsk.hasSkill("effects.wx_status_opening") || tsk.hasSkill("effects.wx_internal_injury"));
			if (hasWound && _targetEntity.getHitpoints() > 1)
				_targetEntity.setHitpoints(::Math.max(1, _targetEntity.getHitpoints() - 8));
			if (tsk != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				local bG = ::new("scripts/skills/effects/bleeding_effect");
				bG.setDamage(6);
				tsk.add(bG);
			}
		}
		else if (this.m.CoatingID == "wx_tact_chunyangyou")
		{
			if (tItems != null)
			{
				local cyBody = tItems.getItemAtSlot(::Const.ItemSlot.Body);
				if (cyBody != null && ::Wuxia.hasMember(cyBody, "getArmor") && cyBody.getArmor() > 0)
					cyBody.setArmor(::Math.max(0, cyBody.getArmor() - 16));
			}
			if (::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
			{
				if (_targetEntity.getHitpoints() > 1)
					_targetEntity.setHitpoints(::Math.max(1, _targetEntity.getHitpoints() - 14));
				if ("m" in _targetEntity && _targetEntity.m != null)
					_targetEntity.m.IsResurrectable = false;
				::Wuxia.CraftBridge.applyBossCounterHit(actor, _targetEntity, { SealRegenTurns = 2 });
			}
		}
		else if (this.m.CoatingID == "wx_tact_zimuguzhi")
		{
			if (tsk != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				local exP = tsk.getSkillByID("effects.wx_status_poison_dart");
				if (exP == null) tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
				else if (::Wuxia.hasMember(exP, "resetDuration")) exP.resetDuration();
			}
			if ("m" in _targetEntity && _targetEntity.m != null)
				_targetEntity.m.WX_GuHost <- true;
		}
		else
		{
			if (tItems != null)
			{
				local tBody2 = tItems.getItemAtSlot(::Const.ItemSlot.Body);
				if (tBody2 != null && ::Wuxia.hasMember(tBody2, "getArmor") && tBody2.getArmor() > 0)
					tBody2.setArmor(::Math.max(0, tBody2.getArmor() - 12));
			}
			if (!::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity) && tsk != null)
			{
				if (!tsk.hasSkill("effects.wx_status_poison_dart"))
					tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
			}
		}

		this.m.HitsLeft -= 1;
		if (this.m.HitsLeft <= 0)
		{
			this.removeSelf();
		}
		else
		{
			this.m.Name = "淬刃：" + this.m.CoatingName + "（余" + this.m.HitsLeft + "击）";
		}
	}
});
