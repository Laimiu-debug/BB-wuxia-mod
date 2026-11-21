// Hook scripts/entity/tactical/player: ensure martial container exists & disable vanilla perk points

::Wuxia.HooksMod.hook("scripts/entity/tactical/player", function( q )
{
	q.setStartValuesEx = @(__original) function( _backgrounds, _addTraits = true )
	{
		__original(_backgrounds, _addTraits);
		// Adding a skill triggers an attribute update. Wait until the actor is initialized.
		::Wuxia.Slots.getContainer(this);
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
		::Wuxia.Armory.syncActorHandheldAndArmor(this);
		this.m.PerkPoints = 0;
	};

	// The results roster contains participants. World cleanup calls onCombatFinished
	// again for the whole company, including the reserves.
	q.onBeforeCombatResult = @(__original) function()
	{
		__original();
		if (this.isAlive() && this.isPlayerControlled() && !this.isGuest())
			::Wuxia.Mastery.addExpToEquipped(this, 35);
	};

	q.updateLevel = @(__original) function()
	{
		__original();
		// Perk tree is completely replaced by 1/3/5/7/9/11 martial slots
		this.m.PerkPoints = 0;
	};
});
