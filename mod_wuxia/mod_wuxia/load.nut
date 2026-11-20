// Ordered loader: Config -> Systems -> Hooks

// 1. Pure Data Configuration
::include("mod_wuxia/config/text_zh.nut");
::include("mod_wuxia/config/slots.nut");
::include("mod_wuxia/config/consumables.nut");
::include("mod_wuxia/config/manuals.nut");
::include("mod_wuxia/config/wx_m4_manuals.nut");
::include("mod_wuxia/config/manuals/wx_manuals_neigong.nut");
::include("mod_wuxia/config/manuals/wx_manuals_qinggong.nut");
::include("mod_wuxia/config/manuals/wx_manuals_henglian.nut");
::include("mod_wuxia/config/manuals/wx_manuals_sword_saber.nut");
::include("mod_wuxia/config/manuals/wx_manuals_pole_fist.nut");
::include("mod_wuxia/config/manuals/wx_manuals_heavy_odd_ranged.nut");
::include("mod_wuxia/config/manuals/wx_manuals_shanhai.nut");
::include("mod_wuxia/config/wx_relic_weapons.nut");
::include("mod_wuxia/config/wx_shanhai.nut");
::include("mod_wuxia/config/wx_backgrounds.nut");
::include("mod_wuxia/config/wx_ecology.nut");
::include("mod_wuxia/config/sects.nut");
::include("mod_wuxia/config/wx_encounters.nut");

// 2. Core Rule Systems
::include("mod_wuxia/systems/slot_manager.nut");
::include("mod_wuxia/systems/mastery_manager.nut");
::include("mod_wuxia/systems/marrow_wash.nut");
::include("mod_wuxia/systems/combat_rules.nut");
::include("mod_wuxia/systems/wx_relic_system.nut");
::include("mod_wuxia/systems/wx_shanhai_system.nut");
::include("mod_wuxia/systems/sect_relations.nut");
::include("mod_wuxia/systems/loot_economy.nut");
::include("mod_wuxia/systems/wx_world_encounters.nut");
::include("mod_wuxia/systems/wx_background_system.nut");
::include("mod_wuxia/systems/wx_ecology_system.nut");
::include("mod_wuxia/systems/scenario_start.nut");
::include("mod_wuxia/systems/selftest.nut");

// 3. Vanilla Engine Hooks (Non-destructive)
::include("mod_wuxia/hooks/entity/tactical/actor.nut");
::include("mod_wuxia/hooks/entity/tactical/player.nut");
::include("mod_wuxia/hooks/entity/tactical/enemy_wuxia_integration.nut");
::include("mod_wuxia/hooks/ai/tactical/behaviors/ai_wuxia_skills.nut");
::include("mod_wuxia/hooks/entity/world/settlement_shop.nut");
::include("mod_wuxia/hooks/factions/faction_manager.nut");
::include("mod_wuxia/hooks/ui/global/data_helper.nut");
::include("mod_wuxia/hooks/ui/screens/character/character_screen.nut");
