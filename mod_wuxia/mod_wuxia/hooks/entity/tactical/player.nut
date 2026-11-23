// Hook scripts/entity/tactical/player: ensure martial container exists & disable vanilla perk points

::Wuxia.HooksMod.hook("scripts/entity/tactical/player", function( q )
{
	q.WX_CompleteAttributeArrays <- function()
	{
		local count = ::Const.Attributes.COUNT;
		if (::Wuxia.hasMember(this.m, "Talents") && this.m.Talents.len() < count)
			this.m.Talents.resize(count, 0);
		if (::Wuxia.hasMember(this.m, "Attributes"))
			while (this.m.Attributes.len() < count)
				this.m.Attributes.push([2, 2, 2, 2, 2, 2, 2, 2, 2, 2]);
	};

	q.setStartValuesEx = @(__original) function( _backgrounds, _addTraits = true )
	{
		__original(_backgrounds, _addTraits);
		this.WX_CompleteAttributeArrays();
		// Adding a skill triggers an attribute update. Wait until the actor is initialized.
		::Wuxia.Slots.getContainer(this);
		if ("ShanHaiSets" in ::Wuxia) ::Wuxia.ShanHaiSets.ensureActorResonanceSkill(this);
		::Wuxia.Backgrounds.assignStarterManuals(this);
		::Wuxia.Appearance.syncHeroineNameIfNeeded(this);
		::Wuxia.Armory.syncActorHandheldAndArmor(this);
		this.m.PerkPoints = 0;
	};

	q.onDeserialize = @(__original) function( _in )
	{
		__original(_in);
		this.m.WX_HeroineNameChecked <- true;
		// The saved skill reads its data before the game binds it to the actor.
		::Wuxia.Slots.getContainer(this).syncGrantedSkills();
		if ("ShanHaiSets" in ::Wuxia) ::Wuxia.ShanHaiSets.ensureActorResonanceSkill(this);
		::Wuxia.Armory.syncActorHandheldAndArmor(this);
		this.m.PerkPoints = 0;
	};

	q.onSerialize = @(__original) function( _out )
	{
		this.WX_CompleteAttributeArrays();
		return __original(_out);
	};

	// The results roster contains participants. World cleanup calls onCombatFinished
	// again for the whole company, including the reserves.
	q.onBeforeCombatResult = @(__original) function()
	{
		if (this.getSkills() != null && this.getSkills().hasSkill("effects.trained"))
			this.m.WX_HadTrainedThisBattle <- true;
		__original();
		if (this.isAlive() && this.isPlayerControlled() && !this.isGuest())
		{
			::Wuxia.Mastery.awardPostBattleExp(this);
			this.m.WX_HadTrainedThisBattle <- false;
		}
	};

	q.onCombatStart = @(__original) function()
	{
		__original();
		this.m.WX_HadTrainedThisBattle <- (this.getSkills() != null && this.getSkills().hasSkill("effects.trained"));
		if ("Mastery" in ::Wuxia && "resetBattleSkillUses" in ::Wuxia.Mastery)
			::Wuxia.Mastery.resetBattleSkillUses(this);
		if ("World" in getroottable() && ::World != null && ("Flags" in ::World) && ::World.Flags != null && ::World.Flags.get("wx_last_battle_shanhai_boss"))
			::World.Flags.set("wx_last_battle_shanhai_boss", false);
	};

	q.updateLevel = @(__original) function()
	{
		__original();
		// Perk tree is completely replaced by 1/3/5/7/9/11 martial slots
		this.m.PerkPoints = 0;
	};
});

// Preserve 1-battle Town Training Hall (`effects.trained`) +45% martial mastery XP even when its last charge expires in `onBeforeCombatResult` / `onCombatFinished`!
foreach (_trainedPath in [
	"scripts/skills/effects_world/trained_effect",
	"scripts/skills/effects_world/new_trained_effect"
])
{
	::Wuxia.HooksMod.hook(_trainedPath, function( q )
	{
		foreach (_cbName in ["onBeforeCombatResult", "onCombatFinished"])
		{
			if (::Wuxia.qHas(q, _cbName))
			{
				local fnName = _cbName;
				q[fnName] = @(__original) function()
				{
					local c = this.getContainer();
					local actor = (c != null && ::Wuxia.hasMember(c, "getActor")) ? c.getActor() : null;
					if (actor != null)
						actor.m.WX_HadTrainedThisBattle <- true;
					return __original();
				};
			}
		}
	});
}
