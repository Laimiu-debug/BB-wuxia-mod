// M4.2 Ecology Runtime: EntityName remapping, Beast Trophy hooks, and Undead/Construct Meridian Immunity

::Wuxia.Ecology <- {
	MappedEntityCount = 0
};

::Wuxia.Ecology.applyEntityNames <- function()
{
	if (!("EntityType" in ::Const) || !("Strings" in ::Const) || !("EntityName" in ::Const.Strings))
		return 0;

	local count = 0;
	foreach (key, pair in ::Wuxia.Config.EntityNameMap)
	{
		if (key in ::Const.EntityType)
		{
			local idx = ::Const.EntityType[key];
			if (idx >= 0 && idx < ::Const.Strings.EntityName.len())
			{
				::Const.Strings.EntityName[idx] = pair[0];
				if ("EntityNamePlural" in ::Const.Strings && idx < ::Const.Strings.EntityNamePlural.len())
				{
					::Const.Strings.EntityNamePlural[idx] = pair[1];
				}
				count += 1;
			}
		}
	}
	::Wuxia.Ecology.MappedEntityCount = count;
	return count;
};

// Ancient Tomb Constructs & Xiangxi Undead Puppets have dead meridians: immune to Acupoint & Dart/Wudu Poison!
::Wuxia.CombatRules.isImmuneToMeridianAndPoison <- function( _target )
{
	if (_target == null) return true;
	if ("getFlags" in _target && _target.getFlags() != null && _target.getFlags().has("undead"))
		return true;
	if ("getCurrentProperties" in _target)
	{
		local p = _target.getCurrentProperties();
		if (p != null && (!p.IsAffectedByPoison || !p.IsAffectedByInjuries))
			return true;
	}
	return false;
};

::Wuxia.CombatRules.isUndeadOrConstruct <- function( _target )
{
	if (_target == null) return false;
	if ("getFlags" in _target && _target.getFlags() != null && _target.getFlags().has("undead"))
		return true;
	return false;
};

// Apply EntityName mappings immediately on load
::Wuxia.Ecology.applyEntityNames();

// Hook base item class non-destructively so Beast Trophies display Low-Magic Wuxia names & alchemy hints
::Wuxia.HooksMod.hook("scripts/items/item", function( q )
{
	q.WX_ApplyTrophyText <- function()
	{
		local id = this.getID();
		if (id in ::Wuxia.Config.TrophyMap)
		{
			local entry = ::Wuxia.Config.TrophyMap[id];
			this.m.Name = entry.Name;
			this.m.Description = entry.Desc;
		}
	};

	q.getName = @(__original) function()
	{
		this.WX_ApplyTrophyText();
		return __original();
	};

	q.getDescription = @(__original) function()
	{
		this.WX_ApplyTrophyText();
		return __original();
	};
});
