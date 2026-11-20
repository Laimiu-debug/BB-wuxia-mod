::Wuxia <- {
	ID = "mod_wuxia",
	Name = "武侠江湖 (BB Wuxia)",
	Version = "0.4.0",
	SchemaVersion = 1,
	Config = {},
	Text = {},
	Slots = {},
	Mastery = {},
	MarrowWash = {},
	CombatRules = {},
	SectRelations = {},
	Loot = {},
	Debug = true
};

::Wuxia.HooksMod <- ::Hooks.register(::Wuxia.ID, ::Wuxia.Version, ::Wuxia.Name);

// Pure Modern Hooks + Vanilla (zero MSU / DPF hard dependency!)
::Wuxia.HooksMod.require([
	"vanilla >= 1.5.2-3"
]);

::Wuxia.HooksMod.conflictWith([
	"mod_legends",
	"mod_reforged"
]);

::Wuxia.HooksMod.queue(function()
{
	// Register Frontend UI Assets via Modern Hooks (registerLateJS runs AFTER vanilla UI modules!)
	::Hooks.registerCSS("ui/mods/mod_wuxia/mod_wuxia.css");
	::Hooks.registerLateJS("ui/mods/mod_wuxia/character_screen_wuxia_module.js");
	::Hooks.registerLateJS("ui/mods/mod_wuxia/tactical_hud_wuxia.js");

	// Load Core Framework Modules
	::include("mod_wuxia/load.nut");

	::logInfo("[mod_wuxia] Loaded v" + ::Wuxia.Version + " successfully (Pure Modern Hooks, Perkless 7-Slot Architecture).");
});

if ("QueueBucket" in ::Hooks && "AfterHooks" in ::Hooks.QueueBucket)
{
	::Wuxia.HooksMod.queue(function()
	{
		if (::Wuxia.Debug && "SelfTest" in ::Wuxia)
			::Wuxia.SelfTest.runAll();
	}, ::Hooks.QueueBucket.AfterHooks);
}
