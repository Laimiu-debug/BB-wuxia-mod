// Hook vanilla enemy archetypes to equip matching Wuxia loadouts, mount bespoke/1000-Faces busts & drop manuals/pages on death

local registerEnemyHook = function( _scriptPath, _archetypeKey )
{
	::Wuxia.HooksMod.hook(_scriptPath, function( q )
	{
		q.assignRandomEquipment = @(__original) function()
		{
			__original();
			local key = ("WX_SchoolRole" in this.m) ? this.m.WX_SchoolRole : _archetypeKey;
			local profile = (key in ::Wuxia.Config.Fighters)
				? ::Wuxia.Config.Fighters[key]
				: ((key in ::Wuxia.Loot.EnemyLoadouts) ? ::Wuxia.Loot.EnemyLoadouts[key] : null);

			this.m.WX_InBatchEquip <- true;
			try
			{
				if (key in ::Wuxia.Config.Fighters)
				{
					local fighter = ::Wuxia.Config.Fighters[key];
					local items = this.getItems();
					local old = items.getItemAtSlot(::Const.ItemSlot.Mainhand);
					if (old != null) items.unequip(old);
					local oldAmmo = items.getItemAtSlot(::Const.ItemSlot.Ammo);
					if (oldAmmo != null) items.unequip(oldAmmo);

					local w = ::new("scripts/items/weapons/" + fighter.Weapon);
					if (::Wuxia.hasMember(w, "getBlockedSlotType") && w.getBlockedSlotType() == ::Const.ItemSlot.Offhand)
					{
						local off = items.getItemAtSlot(::Const.ItemSlot.Offhand);
						if (off != null) items.unequip(off);
					}
					items.equip(w);

					if (fighter.Weapon.find("handgonne") != null)
						items.equip(::new("scripts/items/ammo/powder_bag"));
					else if (fighter.Weapon.find("crossbow") != null)
						items.equip(::new("scripts/items/ammo/quiver_of_bolts"));
					else if (fighter.Weapon.find("bow") != null)
						items.equip(::new("scripts/items/ammo/quiver_of_arrows"));

					this.setName(fighter.Name);
				}
			}
			catch (err)
			{
				this.m.WX_InBatchEquip <- false;
				throw err;
			}
			this.m.WX_InBatchEquip <- false;

			if (profile != null && ("CustomBust" in profile) && profile.CustomBust != null && profile.CustomBust != "")
			{
				::Wuxia.Appearance.applyCustomEnemyBust(this, profile.CustomBust);
			}
			::Wuxia.Armory.syncActorHandheldAndArmor(this);
			if (profile != null) ::Wuxia.Loot.applyLoadoutToEnemy(this, key);
		};

		q.onDeath = @(__original) function( _killer, _skill, _tile, _fatalityType )
		{
			local key = ("WX_SchoolRole" in this.m) ? this.m.WX_SchoolRole : _archetypeKey;
			local profile = (key in ::Wuxia.Config.Fighters)
				? ::Wuxia.Config.Fighters[key]
				: ((key in ::Wuxia.Loot.EnemyLoadouts) ? ::Wuxia.Loot.EnemyLoadouts[key] : null);
			local killedByPlayer = _killer != null && _killer.isPlayerControlled() && !this.isAlliedWith(_killer);
			local eligible = profile != null && _tile != null && killedByPlayer
				&& ("WX_LoadoutKey" in this.m) && this.m.WX_LoadoutKey == key;
			local pool = eligible ? ::Wuxia.Loot.getEquippedDropPool(this, profile) : null;
			local troop = killedByPlayer ? this.getWorldTroop() : null;
			local party = troop != null && "Party" in troop ? troop.Party : null;
			__original(_killer, _skill, _tile, _fatalityType);
			if (eligible) ::Wuxia.Loot.onEnemyKilledDrop(_tile, profile, pool);
			if (killedByPlayer && ("SectRelations" in ::Wuxia) && ("onCombatActorSlain" in ::Wuxia.SectRelations))
				::Wuxia.SectRelations.onCombatActorSlain(party, profile != null && profile.IsBoss);
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
foreach (extraSp in ["scripts/entity/tactical/enemies/skeleton_boss", "scripts/entity/tactical/enemies/zombie_betrayer"])
{
	if (!(extraSp in hookedScripts))
	{
		hookedScripts[extraSp] <- true;
		registerEnemyHook(extraSp, "");
	}
}
