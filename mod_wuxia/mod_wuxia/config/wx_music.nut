// BB Wuxia Mod - 100% Pure Instrumental Authentic Wuxia OST Catalog (18 Tracks)
// Non-destructive: stores wx_*.ogg under mod_wuxia/music/ and remaps ::Const.Music at load time.

::Wuxia.Config.Music <- {
	// Relative filenames inside music/ (strictly instrumental, zero vocals)
	Tracks = {
		Title = "wx_title_01.ogg",

		// 6 AAA Symphonic Wuxia Worldmap Epics (Google Flow Music / Lyria 3.5)
		Worldmap1 = "wx_worldmap_01.ogg", // 山河万里行 (Iron March)
		Worldmap2 = "wx_worldmap_02.ogg", // 孤鸿泣霜雪 (Dying Dynasty Elegy)
		Worldmap3 = "wx_worldmap_03.ogg", // 边关风起时 (Winds Over The Frontier)
		Worldmap4 = "wx_worldmap_04.ogg", // 残阳照古关 (Sunset Over Ancient Pass)
		Worldmap5 = "wx_worldmap_05.ogg", // 山雨欲来·雷霆篇 (Gathering Storm Crisis A)
		Worldmap6 = "wx_worldmap_06.ogg", // 山雨欲来·古关篇 (Gathering Storm Crisis B)

		Settlement1 = "wx_settlement_01.ogg",
		Settlement2 = "wx_settlement_02.ogg",

		Bandits1 = "wx_bandits_01.ogg",
		Bandits2 = "wx_bandits_02.ogg",

		Noble1 = "wx_noble_01.ogg",
		Noble2 = "wx_noble_02.ogg",

		Barbarians = "wx_barbarians_02.ogg",
		Beasts = "wx_beasts_02.ogg",
		Undead = "wx_undead_02.ogg",

		Victory = "wx_victory_01.ogg",
		Defeat = "wx_defeat_01.ogg"
	},

	// Maps vanilla ::Const.Music array keys to rotating pure-instrumental Wuxia playlists
	PlaylistMap = {
		// Title / Menu
		IntroTracks = ["Title"],
		SouthernIntroTracks = ["Title"],
		TitleTracks = ["Title"],
		MenuTracks = ["Title"],

		// Worldmap / Overworld (6 AAA Symphonic Wuxia Epics grouped by region & crisis)
		WorldmapTracks = ["Worldmap1", "Worldmap2", "Worldmap3", "Worldmap4"],
		WorldmapTracksSouth = ["Worldmap4", "Worldmap3", "Worldmap1", "Worldmap2"],
		WorldmapTracksGreaterEvil = ["Worldmap5", "Worldmap6", "Worldmap2", "Worldmap1"],
		WorldmapTracksGreaterEvilSouth = ["Worldmap6", "Worldmap5", "Worldmap4", "Worldmap3"],
		OverworldTracks = ["Worldmap1", "Worldmap2", "Worldmap3", "Worldmap4"],

		// Settlements / Cities / Villages / Strongholds / Inns (2 rotating folk-wuxia themes)
		CityStateTracks = ["Settlement1", "Settlement2"],
		OrientalCityStateTracks = ["Settlement2", "Settlement1"],
		SettlementTracks = ["Settlement1", "Settlement2"],
		CityTracks = ["Settlement1", "Settlement2"],
		VillageTracks = ["Settlement2", "Settlement1"],
		StrongholdTracks = ["Settlement1", "Settlement2"],
		TownTracks = ["Settlement1", "Settlement2"],
		GildedTracks = ["Settlement2", "Settlement1"],

		// Combat: Greenwood Bandits / Outlaws / Nomads / Civilians / Arena
		BanditTracks = ["Bandits1", "Bandits2"],
		BanditsTracks = ["Bandits1", "Bandits2"],
		OrientalBanditTracks = ["Bandits2", "Bandits1"],
		BrigandTracks = ["Bandits1", "Bandits2"],
		CiviliansTracks = ["Bandits1", "Bandits2"],
		CivilianTracks = ["Bandits1", "Bandits2"],
		ArenaTracks = ["Bandits2", "Barbarians", "Bandits1"],

		// Combat: Provincial Warlords / Imperial Heavy Phalanx
		NobleTracks = ["Noble1", "Noble2"],
		NoblesTracks = ["Noble1", "Noble2"],
		OrientalTracks = ["Noble2", "Noble1"],

		// Combat: Northern Frontier Cavalry / Alchemical Hulks (pure instrumental)
		BarbarianTracks = ["Barbarians"],
		BarbariansTracks = ["Barbarians"],
		OrcsTracks = ["Barbarians"],
		OrcTracks = ["Barbarians"],

		// Combat: Five Poisons Cult / Shanhai Mythic Beasts (pure instrumental)
		BeastsTracks = ["Beasts"],
		BeastsTracksSouth = ["Beasts"],
		BeastTracks = ["Beasts"],
		GoblinsTracks = ["Beasts"],
		GoblinTracks = ["Beasts"],

		// Combat: Xiangxi Corpse Puppets / Ancient Tomb Automatons (pure instrumental)
		UndeadTracks = ["Undead"],
		AncientDeadTracks = ["Undead"],

		// Battle Outcome Stings (pure instrumental)
		VictoryTracks = ["Victory"],
		DefeatTracks = ["Defeat"]
	},

	// Runtime diagnostics filled by wx_music_hook.nut
	AppliedKeys = [],
	VanillaBackup = {},
	DetectedPrefix = "music/"
};
