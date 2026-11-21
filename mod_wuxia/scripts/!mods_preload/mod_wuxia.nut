::Wuxia <- {
	ID = "mod_wuxia",
	Name = "山海武侠 (BB Wuxia)",
	Version = "0.7.2",
	SchemaVersion = 1,
	Config = {},
	Text = {},
	Slots = {},
	Library = {},
	Mastery = {},
	MarrowWash = {},
	CombatRules = {},
	SectRelations = {},
	Loot = {},
	Debug = false,
	RunSelfTest = false
};

// Delegate-safe member lookup across Battle Brothers Squirrel inheritance chains (`SuperName` / `_delegate`)
::Wuxia.hasMember <- function( _obj, _key )
{
	if (_obj == null) return false;
	if (_key in _obj) return true;
	if (typeof _obj == "table")
	{
		local cur = _obj;
		while ("SuperName" in cur && (cur.SuperName in cur) && typeof cur[cur.SuperName] == "table")
		{
			cur = cur[cur.SuperName];
			if (_key in cur) return true;
		}
	}
	try { local _ = _obj[_key]; return true; } catch (_e) { return false; }
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
	::Hooks.registerCSS("ui/mods/mod_wuxia/wx_global_theme.css");
	::Hooks.registerCSS("ui/mods/mod_wuxia/wx_alchemy_ui.css");
	::Hooks.registerLateJS("ui/mods/mod_wuxia/wx_ui_global_overhaul.js");
	::Hooks.registerLateJS("ui/mods/mod_wuxia/screens_wuxia.js");
	::Hooks.registerLateJS("ui/mods/mod_wuxia/character_screen_wuxia_module.js");
	::Hooks.registerLateJS("ui/mods/mod_wuxia/wx_alchemy_ui.js");
	::Hooks.registerLateJS("ui/mods/mod_wuxia/tactical_hud_wuxia.js");

	// Load Core Framework Modules
	::include("mod_wuxia/load.nut");

	::logInfo("[mod_wuxia] Loaded v" + ::Wuxia.Version + " successfully (Pure Modern Hooks, Perkless 7-Slot Architecture).");
});

// Preload lazy-loaded base & tree-hooked classes while Modern Hooks' debughook is STILL active
// (before `scripts/~~modern_hooks.nut` calls `::setdebughook(null)` and `::Hooks.__finalizeHooks()`),
// so Modern Hooks hooks 100% of unbound class prototypes natively without touching instance `bindenv`!
if ("QueueBucket" in ::Hooks && "Last" in ::Hooks.QueueBucket)
{
	::Wuxia.HooksMod.queue(function()
	{
		if (!("BBClass" in ::Hooks)) return;
		local preloadSrc = function( _s )
		{
			if (_s == null || _s == "") return;
			if ((_s in ::Hooks.BBClass) && ::Hooks.BBClass[_s].Prototype != null) return;
			try { ::include(_s); } catch (_e) {}
		};

		local targets = [];
		foreach (srcPath, entry in ::Hooks.BBClass)
		{
			if (entry.Prototype == null)
				targets.push(srcPath);
		}
		foreach (s in targets)
			preloadSrc(s);

		foreach (dir in [
			"scripts/contracts/contracts",
			"scripts/ambitions/ambitions",
			"scripts/skills/backgrounds",
			"scripts/entity/world/settlements/buildings",
			"scripts/entity/world/attached_locations",
			"scripts/items/weapons",
			"scripts/items/weapons/named",
			"scripts/items/weapons/oriental",
			"scripts/items/weapons/greenskins",
			"scripts/items/weapons/ancient",
			"scripts/items/weapons/barbarians",
			"scripts/items/shields",
			"scripts/items/shields/named",
			"scripts/items/shields/oriental",
			"scripts/items/shields/ancient",
			"scripts/items/shields/greenskins",
			"scripts/items/armor",
			"scripts/items/armor/named",
			"scripts/items/armor/oriental",
			"scripts/items/armor/ancient",
			"scripts/items/armor/barbarians",
			"scripts/items/armor/greenskins",
			"scripts/items/helmets",
			"scripts/items/helmets/named",
			"scripts/items/helmets/oriental",
			"scripts/items/helmets/ancient",
			"scripts/items/helmets/barbarians",
			"scripts/items/helmets/greenskins",
			"scripts/items/armor_upgrades",
			"scripts/items/supplies",
			"scripts/items/misc",
			"scripts/items/ammo",
			"scripts/items/tools",
			"scripts/items/accessory",
			"scripts/items/loot"
		])
		{
			local files = ::IO.enumerateFiles(dir);
			if (files != null)
			{
				foreach (f in files)
					preloadSrc(f);
			}
		}
	}, ::Hooks.QueueBucket.Last);
}

if ("QueueBucket" in ::Hooks && "AfterHooks" in ::Hooks.QueueBucket)
{
	::Wuxia.HooksMod.queue(function()
	{
		if ("mods_addHook" in ::getroottable())
		{
			::mods_addHook("new", function( _scriptName, _obj )
			{
				if (_obj == null || typeof _obj != "table")
					return null;

				if (_scriptName.find("scripts/items/") == 0)
				{
					if ("Armory" in ::Wuxia && "ensureItemMapped" in ::Wuxia.Armory)
						::Wuxia.Armory.ensureItemMapped(_obj);
					if ("Purify" in ::Wuxia && "applyItemText" in ::Wuxia.Purify)
						::Wuxia.Purify.applyItemText(_obj, _scriptName);
					if ("BeastCraft" in ::Wuxia && "bindTraitMethods" in ::Wuxia.BeastCraft)
						::Wuxia.BeastCraft.bindTraitMethods(_obj);
				}
				else if (_scriptName.find("scripts/retinue/followers/") == 0 && ("Screens" in ::Wuxia) && ("applyFollowerVisuals" in ::Wuxia.Screens))
				{
					::Wuxia.Screens.applyFollowerVisuals(_obj);
				}
				else if (_scriptName.find("scripts/contracts/") == 0 && ("Contracts" in ::Wuxia) && ("applyContractMeta" in ::Wuxia.Contracts))
				{
					::Wuxia.Contracts.applyContractMeta(_obj, _scriptName);
				}
				else if (_scriptName.find("scripts/ambitions/") == 0 && ("Ambitions" in ::Wuxia) && ("applyAmbitionText" in ::Wuxia.Ambitions))
				{
					::Wuxia.Ambitions.applyAmbitionText(_obj, _scriptName);
				}
				else if (_scriptName.find("scripts/skills/backgrounds/") == 0 && ::Wuxia.hasMember(_obj, "WX_ApplyMapping"))
				{
					_obj.WX_ApplyMapping();
				}
				else if (_scriptName.find("scripts/crafting/blueprints/") == 0)
				{
					local bpId = _obj.getID();
					if (bpId != null && bpId.find("blueprint.wx_") == 0 && _obj.m.PreviewCraftable != null)
						_obj.m.PreviewCraftable.m.WX_IsBlueprintPreview <- true;
				}
				else if (_scriptName.find("tooltip_events") != null && ("UI" in ::Wuxia) && ("bindTooltipEventsInstance" in ::Wuxia.UI))
				{
					::Wuxia.UI.bindTooltipEventsInstance(_obj);
				}

				return null;
			});
		}

		if (("TooltipEvents" in ::getroottable()) && ::TooltipEvents != null && ("UI" in ::Wuxia) && ("bindTooltipEventsInstance" in ::Wuxia.UI))
			::Wuxia.UI.bindTooltipEventsInstance(::TooltipEvents);
		if ("Appearance" in ::Wuxia && "applyShanHaiEntityStrings" in ::Wuxia.Appearance)
			::Wuxia.Appearance.applyShanHaiEntityStrings();
		if ("Screens" in ::Wuxia && "applyScreensAndTips" in ::Wuxia.Screens)
			::Wuxia.Screens.applyScreensAndTips();
		if ((::Wuxia.Debug || ::Wuxia.RunSelfTest) && "SelfTest" in ::Wuxia)
			::Wuxia.SelfTest.runAll();
	}, ::Hooks.QueueBucket.AfterHooks);
}
