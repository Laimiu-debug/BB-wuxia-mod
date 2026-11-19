// Hook vanilla enemy archetypes to equip matching Wuxia loadouts & drop matching manuals/pages on death

local registerEnemyHook = function( _scriptPath, _archetypeKey )
{
	::Wuxia.HooksMod.hook(_scriptPath, function( q )
	{
		q.assignRandomEquipment = @(__original) function()
		{
			__original();
			::Wuxia.Loot.applyLoadoutToEnemy(this, _archetypeKey);
		};

		q.onDeath = @(__original) function( _killer, _skill, _tile, _fatalityType )
		{
			__original(_killer, _skill, _tile, _fatalityType);
			if (_tile != null && _killer != null && _killer.isPlayerControlled())
			{
				::Wuxia.Loot.onEnemyKilledDrop(this, _tile);
			}
		};
	});
};

local enemyArchetypeList = [
	["scripts/entity/tactical/enemies/bandit_thug",     "bandit_thug"],
	["scripts/entity/tactical/enemies/bandit_raider",   "bandit_raider"],
	["scripts/entity/tactical/enemies/bandit_marksman", "bandit_marksman"],
	["scripts/entity/tactical/enemies/bandit_leader",   "bandit_leader"],
	["scripts/entity/tactical/humans/mercenary",        "mercenary"],
	["scripts/entity/tactical/humans/swordmaster",      "swordmaster"]
];

foreach (pair in enemyArchetypeList)
{
	registerEnemyHook(pair[0], pair[1]);
}
