// Hook vanilla enemy archetypes to equip matching Wuxia loadouts & drop matching manuals/pages on death

local registerEnemyHook = function( _scriptPath, _archetypeKey )
{
	::Wuxia.HooksMod.hook(_scriptPath, function( q )
	{
		q.assignRandomEquipment = @(__original) function()
		{
			__original();
			local key = "WX_SchoolRole" in this.m ? this.m.WX_SchoolRole : _archetypeKey;
			if (key in ::Wuxia.Config.Fighters)
			{
				local fighter = ::Wuxia.Config.Fighters[key];
				local items = this.getItems();
				local old = items.getItemAtSlot(::Const.ItemSlot.Mainhand);
				if (old != null) items.unequip(old);
				if (key == "dartist")
				{
					local quiver = items.getItemAtSlot(::Const.ItemSlot.Ammo);
					if (quiver != null) items.unequip(quiver);
				}
				local w = ::new("scripts/items/weapons/" + fighter.Weapon);
				if ("getBlockedSlotType" in w && w.getBlockedSlotType() == ::Const.ItemSlot.Offhand)
				{
					local off = items.getItemAtSlot(::Const.ItemSlot.Offhand);
					if (off != null) items.unequip(off);
				}
				items.equip(w);
				this.setName(fighter.Name);
			}
			::Wuxia.Loot.applyLoadoutToEnemy(this, key);
		};

		q.onDeath = @(__original) function( _killer, _skill, _tile, _fatalityType )
		{
			local key = "WX_SchoolRole" in this.m ? this.m.WX_SchoolRole : _archetypeKey;
			local profile = key in ::Wuxia.Config.Fighters ? ::Wuxia.Config.Fighters[key] : ::Wuxia.Loot.EnemyLoadouts[key];
			local eligible = _tile != null && _killer != null && _killer.isPlayerControlled() && !this.isAlliedWith(_killer)
				&& ("WX_LoadoutKey" in this.m) && this.m.WX_LoadoutKey == key;
			local pool = eligible ? ::Wuxia.Loot.getEquippedDropPool(this, profile) : null;
			__original(_killer, _skill, _tile, _fatalityType);
			if (eligible) ::Wuxia.Loot.onEnemyKilledDrop(_tile, profile, pool);
		};
	});
};

local hookedScripts = {};
foreach (key, profile in ::Wuxia.Loot.EnemyLoadouts)
{
	local sp = ::Wuxia.Loot.resolveEnemyScript(profile);
	if (sp != null && !(sp in hookedScripts))
	{
		hookedScripts[sp] <- true;
		registerEnemyHook(sp, key);
	}
}
