#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Binds all 66 custom Wuxia events (`mod_wuxia/scripts/events/events/wx_*.nut`)
and both Wuxia scenarios (`wx_jianghu_start.nut`, `wx_debug_arena.nut`)
to the 32 custom hand-painted Wuxia event illustrations (`gfx/ui/events/wx_ev_01.png`..`wx_ev_32.png`).
"""

import glob
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOD_ROOT = os.path.join(ROOT, "mod_wuxia")

EVENT_TO_ART = {
    # 01 茶寮论剑
    "wx_event_sect_exchange": "wx_ev_01",
    # 02 酒肆拍刀
    "wx_event_sect_tavern_challenge": "wx_ev_02",
    "wx_event_bg_brawler_armwrestle": "wx_ev_02",
    # 03 市镇书肆
    "wx_event_bookshop": "wx_ev_03",
    "wx_event_martial_page_exchange": "wx_ev_03",
    "wx_event_martial_fake_manual": "wx_ev_03",
    # 04 无常鬼市
    "wx_event_ghost_auction": "wx_ev_04",
    # 05 武林大会
    "wx_event_grand_tournament": "wx_ev_05",
    # 06 威远走镖
    "wx_event_sect_escort_banquet": "wx_ev_06",
    # 07 洗髓脱胎
    "wx_event_martial_wash_afterglow": "wx_ev_07",
    # 08 走火心魔
    "wx_event_martial_conflict_crisis": "wx_ev_08",
    "wx_event_martial_fragment_demon": "wx_ev_08",
    # 09 寒夜吐纳
    "wx_event_martial_night_watch_breath": "wx_ev_09",
    "wx_event_martial_internal_meditation": "wx_ev_09",
    # 10 寒潭剑冢
    "wx_event_martial_waterfall_epiphany": "wx_ev_10",
    "wx_event_martial_broken_sword_grave": "wx_ev_10",
    # 11 月下拆招
    "wx_event_camp_swordmaster_lesson": "wx_ev_11",
    "wx_event_martial_sparring": "wx_ev_11",
    # 12 杏林丹炉
    "wx_event_famous_physician": "wx_ev_12",
    "wx_event_martial_herbalist_cauldron": "wx_ev_12",
    "wx_event_bg_anatomist_venom": "wx_ev_12",
    # 13 断桥寻仇
    "wx_event_sect_rival_clash": "wx_ev_13",
    "wx_event_sect_vendetta_broker": "wx_ev_13",
    "wx_event_bg_witchhunter_evil": "wx_ev_13",
    # 14 官道劫镖
    "wx_event_sect_outlaw_toll": "wx_ev_14",
    "wx_event_sect_escort_wreck": "wx_ev_14",
    "wx_event_sect_wounded_courier": "wx_ev_14",
    # 15 古刹奇丐
    "wx_event_sect_shaolin_alms": "wx_ev_15",
    "wx_event_martial_old_beggar": "wx_ev_15",
    "wx_event_camp_monk_brawl": "wx_ev_15",
    # 16 唐门苗毒
    "wx_event_sect_tangmen_peddler": "wx_ev_16",
    "wx_event_sect_wudu_barter": "wx_ev_16",
    "wx_event_sect_gaibang_tip": "wx_ev_16",
    # 17 古墓石门
    "wx_event_weird_ancient_tomb_door": "wx_ev_17",
    "wx_event_bg_mason_ruin": "wx_ev_17",
    # 18 湘西赶尸
    "wx_event_weird_xiangxi_corpses": "wx_ev_18",
    "wx_event_camp_gravedigger_omen": "wx_ev_18",
    # 19 青丘狐庙
    "wx_event_weird_fox_temple": "wx_ev_19",
    # 20 荒郊黑店
    "wx_event_weird_black_inn": "wx_ev_20",
    # 21 山海猎师
    "wx_event_shanhai_rumor": "wx_ev_21",
    # 22 朱厌巨迹
    "wx_event_weird_shanhai_zhuyan_tracks": "wx_ev_22",
    "wx_event_bg_lumberjack_ironwood": "wx_ev_22",
    # 23 肥遗蜕鳞
    "wx_event_weird_shanhai_feiyi_shed": "wx_ev_23",
    # 24 白泽幻雾
    "wx_event_weird_shanhai_baize_shrine": "wx_ev_24",
    "wx_event_weird_shanhai_mirage": "wx_ev_24",
    # 25 血月烽烟
    "wx_event_crisis_jianghu_omen": "wx_ev_25",
    # 26 官道苛税
    "wx_event_road_corrupt_taxman": "wx_ev_26",
    "wx_event_bg_deserter_patrol": "wx_ev_26",
    "wx_event_camp_noble_peasant": "wx_ev_26",
    # 27 瘟村流民
    "wx_event_road_plague_village": "wx_ev_27",
    "wx_event_road_starving_refugees": "wx_ev_27",
    # 28 深宅暗记
    "wx_event_bg_eunuch_rumor": "wx_ev_28",
    "wx_event_bg_messenger_shortcut": "wx_ev_28",
    "wx_event_bg_thief_pickpocket": "wx_ev_28",
    # 29 沉江残碑
    "wx_event_bg_fisher_chest": "wx_ev_29",
    "wx_event_camp_historian_stele": "wx_ev_29",
    # 30 营火百工
    "wx_event_camp_bowyer_string": "wx_ev_30",
    "wx_event_camp_tailor_lining": "wx_ev_30",
    "wx_event_bg_executioner_edge": "wx_ev_30",
    # 31 营火庖骰
    "wx_event_camp_butcher_feast": "wx_ev_31",
    "wx_event_camp_ratcatcher_stew": "wx_ev_31",
    "wx_event_camp_gambler_dice": "wx_ev_31",
    "wx_event_camp_minstrel_ballad": "wx_ev_31",
    # 32 残驿名宿
    "wx_event_sect_wandering_elder": "wx_ev_32",
    "wx_event_camp_houndmaster_stray": "wx_ev_32",
    "wx_event_bg_juggler_market": "wx_ev_32",
}

SCENARIO_TO_ART = {
    "wx_jianghu_start": "wx_ev_06",
    "wx_debug_arena": "wx_ev_05",
}


def main():
    pat = re.compile(r"gfx/ui/events/(?:event_\d+|wx_ev_\d+)\.png")
    updated_files = 0
    total_repls = 0

    event_files = sorted(glob.glob(os.path.join(MOD_ROOT, "scripts/events/events/*.nut")))
    for p in event_files:
        stem = os.path.splitext(os.path.basename(p))[0]
        if stem not in EVENT_TO_ART:
            raise KeyError(f"Unmapped event script: {stem}")
        art_id = EVENT_TO_ART[stem]
        orig = open(p, "r", encoding="utf-8").read()
        new_txt, n = pat.subn(f"gfx/ui/events/{art_id}.png", orig)
        if n == 0:
            raise RuntimeError(f"No event image tag found in {p}")
        total_repls += n
        if new_txt != orig:
            with open(p, "w", encoding="utf-8") as f:
                f.write(new_txt)
            updated_files += 1

    for sc_stem, art_id in SCENARIO_TO_ART.items():
        p = os.path.join(MOD_ROOT, f"scripts/scenarios/world/{sc_stem}.nut")
        orig = open(p, "r", encoding="utf-8").read()
        new_txt, n = pat.subn(f"gfx/ui/events/{art_id}.png", orig)
        total_repls += n
        if new_txt != orig:
            with open(p, "w", encoding="utf-8") as f:
                f.write(new_txt)
            updated_files += 1

    # Audit zero remaining vanilla event_XX.png across all mod_wuxia .nut files
    leftover = []
    for root_d, _, files in os.walk(MOD_ROOT):
        for fn in files:
            if fn.endswith(".nut") and fn != "selftest.nut":
                fp = os.path.join(root_d, fn)
                txt = open(fp, "r", encoding="utf-8").read()
                if "gfx/ui/events/event_" in txt:
                    leftover.append(os.path.relpath(fp, MOD_ROOT))

    if leftover:
        raise RuntimeError(f"Leftover vanilla event_XX.png found in: {leftover}")

    print(f"SUCCESS: Bound {len(event_files)} Wuxia events + 2 scenarios ({total_repls} [img] tags across {updated_files} updated files). Zero leftover vanilla event_XX.png!")


if __name__ == "__main__":
    main()
