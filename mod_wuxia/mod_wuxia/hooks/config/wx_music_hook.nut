// Non-destructive hook: remap vanilla ::Const.Music track lists to BB Wuxia OST (wx_*.ogg)
// Automatically detects vanilla path prefix ("music/" vs bare filename) and supports both
// explicit key mapping and vanilla-filename inference so every DLC playlist is covered cleanly.

::Wuxia.Music <- {};

::Wuxia.Music.inferTrackKeysFromVanilla <- function( _val )
{
	local sample = "";
	if (typeof _val == "string")
		sample = _val.tolower();
	else if (typeof _val == "array")
	{
		foreach (item in _val)
		{
			if (typeof item == "string")
			{
				sample += " " + item.tolower();
			}
		}
	}
	else
	{
		return null;
	}

	if (sample.find(".ogg") == null)
		return null;

	// Keep credits and retirement tracks untouched
	if (sample.find("credits") != null || sample.find("retirement") != null)
		return null;

	if (sample.find("victory") != null)
		return ["Victory"];
	if (sample.find("defeat") != null)
		return ["Defeat"];
	if (sample.find("title") != null)
		return ["Title"];
	if (sample.find("worldmap") != null)
		return ["Worldmap1", "Worldmap2", "Worldmap3", "Worldmap4"];
	if (sample.find("city") != null || sample.find("village") != null || sample.find("stronghold") != null || sample.find("gilded") != null)
		return ["Settlement1", "Settlement2"];
	if (sample.find("bandit") != null || sample.find("civilian") != null)
		return ["Bandits1", "Bandits2"];
	if (sample.find("noble") != null)
		return ["Noble1", "Noble2"];
	if (sample.find("barbarian") != null || sample.find("orc") != null)
		return ["Barbarians"];
	if (sample.find("beast") != null || sample.find("goblin") != null)
		return ["Beasts"];
	if (sample.find("undead") != null)
		return ["Undead"];

	return null;
};

::Wuxia.Music.applyWuxiaOST <- function()
{
	if (!("Const" in getroottable()) || !("Music" in ::Const) || typeof ::Const.Music != "table")
	{
		::logWarning("[mod_wuxia] ::Const.Music not found; skipping Wuxia OST remap.");
		return 0;
	}

	local cfg = ::Wuxia.Config.Music;
	cfg.AppliedKeys = [];
	cfg.VanillaBackup = {};

	// 1. Detect vanilla path prefix ("music/" vs "")
	local prefix = "music/";
	local detected = false;
	foreach (k, v in ::Const.Music)
	{
		if (detected) break;
		if (typeof v == "string" && v.find(".ogg") != null)
		{
			prefix = (v.find("music/") == 0) ? "music/" : "";
			detected = true;
		}
		else if (typeof v == "array" && v.len() > 0 && typeof v[0] == "string" && v[0].find(".ogg") != null)
		{
			prefix = (v[0].find("music/") == 0) ? "music/" : "";
			detected = true;
		}
	}
	cfg.DetectedPrefix = prefix;

	// 2. Remap each matching ::Const.Music playlist non-destructively
	foreach (k, v in ::Const.Music)
	{
		if (typeof v != "array" && typeof v != "string")
			continue;

		local mappedKeys = null;
		if (k in cfg.PlaylistMap)
			mappedKeys = cfg.PlaylistMap[k];
		else
			mappedKeys = ::Wuxia.Music.inferTrackKeysFromVanilla(v);

		if (mappedKeys == null || mappedKeys.len() == 0)
			continue;

		// Backup original entry
		cfg.VanillaBackup[k] <- (typeof v == "array") ? clone v : v;

		if (typeof v == "string")
		{
			local tk = mappedKeys[0];
			if (tk in cfg.Tracks)
			{
				::Const.Music[k] = prefix + cfg.Tracks[tk];
				cfg.AppliedKeys.push(k);
			}
		}
		else
		{
			local nextList = [];
			foreach (tk in mappedKeys)
			{
				if (tk in cfg.Tracks)
					nextList.push(prefix + cfg.Tracks[tk]);
			}
			if (nextList.len() > 0)
			{
				// Mutate array in-place so nested references like ::Const.Music.BattleTracks update automatically!
				v.clear();
				foreach (trackPath in nextList)
					v.push(trackPath);
				cfg.AppliedKeys.push(k);
			}
		}
	}

	// 3. Also walk nested ::Const.Music.BattleTracks (some slots hold standalone arrays rather than shared refs)
	if ("BattleTracks" in ::Const.Music && typeof ::Const.Music.BattleTracks == "array")
	{
		for (local bi = 0; bi < ::Const.Music.BattleTracks.len(); bi++)
		{
			local entry = ::Const.Music.BattleTracks[bi];
			if (typeof entry != "array" || entry.len() == 0)
				continue;
			if (typeof entry[0] == "string" && entry[0].find("wx_") != null)
				continue;

			local inferred = ::Wuxia.Music.inferTrackKeysFromVanilla(entry);
			if (inferred == null || inferred.len() == 0)
				inferred = ["Bandits1", "Bandits2"];

			local nextList = [];
			foreach (tk in inferred)
			{
				if (tk in cfg.Tracks)
					nextList.push(prefix + cfg.Tracks[tk]);
			}
			if (nextList.len() > 0)
			{
				entry.clear();
				foreach (trackPath in nextList)
					entry.push(trackPath);
				cfg.AppliedKeys.push("BattleTracks[" + bi + "]");
			}
		}
	}

	::logInfo("[mod_wuxia] Applied Wuxia OST to " + cfg.AppliedKeys.len() + " ::Const.Music playlists (prefix='" + prefix + "').");
	return cfg.AppliedKeys.len();
};

// Apply immediately on mod load (vanilla config scripts have already executed)
::Wuxia.Music.applyWuxiaOST();
