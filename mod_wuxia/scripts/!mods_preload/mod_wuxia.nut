::Wuxia <- {
	ID = "mod_wuxia",
	Name = "武侠江湖 (BB Wuxia)",
	Version = "0.1.0",
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

::Wuxia.HooksMod.require([
	"vanilla >= 1.5.2-3",
	"mod_msu >= 1.9.0"
]);

::Wuxia.HooksMod.conflictWith([
	"mod_legends",
	"mod_reforged"
]);

::Wuxia.HooksMod.queue(">mod_msu", function()
{
	::Wuxia.Mod <- ::MSU.Class.Mod(::Wuxia.ID, ::Wuxia.Version, ::Wuxia.Name);

	// Mod Settings via MSU
	local page = ::Wuxia.Mod.ModSettings.addPage("WuxiaGeneral", "武侠江湖");
	page.addBooleanSetting("DebugLogging", true, "调试日志", "在 log.html 中输出武学插槽、洗髓与势力检查日志。");
	page.addBooleanSetting("WorldMapPinyinFallback", false, "大地图拼音兜底", "未启用中文大地图启动器时，使用拼音避免位图字体乱码。");

	// Register Frontend UI Assets (ES3 JS + CSS)
	::Hooks.registerCSS("ui/mods/mod_wuxia/mod_wuxia.css");
	::Hooks.registerJS("ui/mods/mod_wuxia/character_screen_wuxia_module.js");
	::Hooks.registerJS("ui/mods/mod_wuxia/tactical_hud_wuxia.js");

	// Load Core Framework Modules
	::include("mod_wuxia/load.nut");

	::logInfo("[mod_wuxia] Loaded v" + ::Wuxia.Version + " successfully (Modern Hooks + MSU, Perkless Slot Architecture).");
});
