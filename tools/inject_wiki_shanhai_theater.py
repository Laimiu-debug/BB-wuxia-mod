#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Unpacks all 139 Shan Hai Jing creature busts directly from `mod_wuxia/brushes/wx_beasts_0.brush`,
enriches every creature's skills in `山海武侠.html` (`DB.bestiary.creatures`) with the exact
20-mode combat choreography & in-game `wx_vfx_*` / `wx_fx_*` metadata from `shanhai_bestiary_data.py`
(matching `mod_wuxia/mod_wuxia/systems/wx_vfx_system.nut`), and injects:
  1) The collapsible 60fps《山海万妖 · 异兽技能动作演武台》at the top of the `bestiary` tab
  2) Live interactive 60fps skill-action preview canvas inside EVERY creature's detail modal
  3) Fixes stat field display (`mSkill`, `rSkill`, `mDef`, `rDef`, `fatigue`, `fatRec`, `resolve`)
     and clickable companion links in the bestiary cards & detail modal.

100% standalone single-file HTML output (zero `art/` path dependencies) and 100% idempotent.
"""

from __future__ import annotations
import base64
import io
import json
import re
import struct
import sys
from pathlib import Path
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parent.parent
MOD_DIR = ROOT / "mod_wuxia"
WIKI_PATH = ROOT / "山海武侠.html"

sys.path.insert(0, str(ROOT / "tools"))
import shanhai_bestiary_data as sbd  # noqa: E402

CSS_START = "/* === WX_SHANHAI_THEATER_CSS_START === */"
CSS_END = "/* === WX_SHANHAI_THEATER_CSS_END === */"
JS_START = "// === WX_SHANHAI_THEATER_JS_START ==="
JS_END = "// === WX_SHANHAI_THEATER_JS_END ==="
EVT_START = "// --- WX_SHANHAI_EVENTS_START ---"
EVT_END = "// --- WX_SHANHAI_EVENTS_END ---"

ANIM_MODE_LABELS = {
    "ape_titan_slam":       "碎岳跃砸 · 环形震地",
    "thunder_hoof_stomp":   "九天雷蹄 · 紫电崩甲",
    "feral_pounce":         "凶星疾扑 · 裂喉连咬",
    "horn_gore_charge":     "蛮角冲阵 · 破盾贯撞",
    "headless_waraxe":      "戮神旋斩 · 狂澜横劈",
    "multi_head_frenzy":    "多首狂袭 · 三段连噬",
    "sky_talon_dive":       "九霄俯冲 · 铁爪掀胄",
    "sun_crow_nova":        "大日火轮 · 阳炎爆耀",
    "abyss_tentacle_drag":  "深渊蛇触 · 缠拽拖噬",
    "shell_thorns_quake":   "玄甲盘岳 · 尖棘反震",
    "dream_shadow_ambush":  "诡影瞬闪 · 背后突袭",
    "coiled_crush":         "盘蟒绞骨 · 凶尾横扫",
    "corpse_chain_cleave":  "断枷玄索 · 隔格挥砸",
    "dragon_breath":        "太古龙息 · 毒火寒潮",
    "fox_charm_miasma":     "惑心妖瘴 · 摄魂迷阵",
    "venom_needle_barrage": "万蛊透针 · 飞刺缠网",
    "root_thorn_entangle":  "古木地刺 · 贯阵突岩",
    "sonic_dread_roar":     "摄魄凶啸 · 音波震胆",
    "boulder_hurl_smash":   "掷岳巨岩 · 凌空轰砸",
    "devour_blood_siphon":  "深渊血噬 · 汲元回血",
}

FX_TO_VFX_AURA = {
    "wx_fx_earth_fissure":  "wx_vfx_05",
    "wx_fx_dragon_head":    "wx_vfx_02",
    "wx_fx_claw_slash":     "wx_vfx_13",
    "wx_fx_blood_orb":      "wx_vfx_06",
    "wx_fx_lotus_seal":     "wx_vfx_16",
    "wx_fx_sword_phantom":  "wx_vfx_07",
    "wx_fx_thunder_bolt":   "wx_vfx_14",
    "wx_fx_ice_spikes":     "wx_vfx_10",
    "wx_fx_golden_bell":    "wx_vfx_17",
    "wx_fx_poison_skull":   "wx_vfx_28",
    "wx_fx_whip_arc":       "wx_vfx_31",
    "wx_fx_sonic_ring":     "wx_vfx_23",
    "wx_fx_gold_needle":    "wx_vfx_27",
    "wx_fx_bagua":          "wx_vfx_19",
}


def load_brush_sprites(brush_path: Path) -> dict[str, Image.Image]:
    data = brush_path.read_bytes()
    magic, _ver, gfx_len = struct.unpack_from("<IHH", data, 0)
    assert magic == 0xBAADFAAD, f"Invalid brush magic in {brush_path}"
    gfx_rel = data[8 : 8 + gfx_len].decode("ascii").replace("\\", "/")
    pos = 8 + gfx_len
    aw, ah = struct.unpack_from("<HH", data, pos)
    pos += 4 + 12
    rec_cnt, _, _ = struct.unpack_from("<IHI", data, pos)
    pos += 10

    atlas = Image.open(MOD_DIR / gfx_rel).convert("RGBA")
    sprites: dict[str, Image.Image] = {}
    for _ in range(rec_cnt):
        _, sid_len = struct.unpack_from("<QH", data, pos)
        pos += 10
        sid = data[pos : pos + sid_len].decode("ascii")
        pos += sid_len
        _, w, h, _ox, _oy = struct.unpack_from("<QIIhh", data, pos)
        pos += 20 + 25 + 4 + 4
        _f_cnt, src_len = struct.unpack_from("<HH", data, pos)
        pos += 4 + src_len
        u0, u1, v0, v1, fL, _fR, _fT, fB = struct.unpack_from("<8f", data, pos)
        pos += 32 + 3

        ax0 = int(round(u0 * aw))
        ax1 = int(round(u1 * aw))
        ay0 = int(round(v0 * ah))
        ay1 = int(round(v1 * ah))
        crop = ImageOps.flip(atlas.crop((ax0, ay0, ax1, ay1)))
        bx0 = int(round(fL + w / 2.0))
        by0 = int(round(h / 2.0 - fB))
        canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        canvas.paste(crop, (max(0, bx0), max(0, by0)))
        sprites[sid] = canvas
    return sprites


def to_webp_uri(im: Image.Image, quality: int = 74) -> str:
    buf = io.BytesIO()
    im.save(buf, format="WEBP", quality=quality, method=6)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def trim_and_fade_bust(im: Image.Image, target_size=(96, 124)) -> Image.Image:
    rs = im.convert("RGBA").resize(target_size, Image.Resampling.LANCZOS)
    w, h = rs.size
    px = rs.load()
    fade_start = int(h * 0.80)
    cut_y = int(h * 0.93)
    span = max(1, cut_y - fade_start)
    for y in range(fade_start, h):
        mult = 0.0 if y >= cut_y else max(0.0, 1.0 - (y - fade_start) / span)
        for x in range(w):
            r, g, b, a = px[x, y]
            if a:
                px[x, y] = (r, g, b, int(round(a * mult)))
    return rs


def enrich_bestiary_and_pack_busts(bundle: dict) -> dict:
    full_bestiary = sbd.build_all_bestiary_records()
    rich_by_id = {c["id"]: c for c in full_bestiary["creatures"]}
    skill_by_name = {v["name"]: v for v in sbd.MONSTER_SKILL_LIB.values()}

    beasts_brush = load_brush_sprites(MOD_DIR / "brushes" / "wx_beasts_0.brush")
    vfx_pool = set((bundle.get("vfxAssets") or {}).get("vfx", {}).keys())
    fx_pool = set((bundle.get("vfxAssets") or {}).get("fx", {}).keys())

    busts_uri: dict[str, str] = {}
    enriched_skills = 0
    missing_busts = []

    for c in bundle["bestiary"]["creatures"]:
        cid = c["id"]
        rc = rich_by_id.get(cid)
        if rc:
            c["socketTheme"] = rc.get("socketTheme", "wild_stone")
            c["archetype"] = rc.get("archetype", "")
            c["bodyLabel"] = rc.get("bodyLabel", "")
        else:
            c["socketTheme"] = "boss_crimson" if c.get("kind") == "boss" else "wild_stone"

        # Enrich skills with exact animMode, animColor, fx, vfx, effects, directPct, armorPct, cd
        rich_skills = (rc.get("skills") or []) if rc else []
        for idx, sk in enumerate(c.get("skills") or []):
            rsk = None
            if idx < len(rich_skills) and rich_skills[idx].get("name") == sk.get("name"):
                rsk = rich_skills[idx]
            else:
                rsk = skill_by_name.get(sk.get("name"))
                if rsk is None and idx < len(rich_skills):
                    rsk = rich_skills[idx]

            mode = (rsk.get("animMode") if rsk else None) or "feral_pounce"
            acol = (rsk.get("animColor") if rsk else None) or "#ff5a36"
            fx_key = (rsk.get("fx") if rsk else None) or "wx_fx_claw_slash"
            if fx_key not in fx_pool:
                fx_key = "wx_fx_claw_slash"
            vfx_key = FX_TO_VFX_AURA.get(fx_key, "wx_vfx_05")
            if vfx_key not in vfx_pool and vfx_pool:
                vfx_key = sorted(vfx_pool)[0]

            sk["animMode"] = mode
            sk["animColor"] = acol
            sk["animLabel"] = ANIM_MODE_LABELS.get(mode, "异兽妖技演武")
            sk["fx"] = fx_key
            sk["vfx"] = vfx_key
            if rsk:
                sk["effects"] = rsk.get("effects") or []
                sk["directPct"] = rsk.get("directPct", 0)
                sk["armorPct"] = rsk.get("armorPct", 0)
                sk["cd"] = rsk.get("cd", "无冷却")
            enriched_skills += 1

        # Pack bust sprite from wx_beasts_0.brush
        if cid in beasts_brush:
            busts_uri[cid] = to_webp_uri(trim_and_fade_bust(beasts_brush[cid], (96, 124)), quality=72)
        else:
            missing_busts.append(cid)

    assert not missing_busts, f"Missing {len(missing_busts)} creature busts in wx_beasts_0.brush: {missing_busts[:10]}"

    # Also refresh hero rigs & faction opponents in DB.vfxAssets from our newly scaled v0.8.8 128x164 brushes!
    busts_brush = load_brush_sprites(MOD_DIR / "brushes" / "wx_busts_0.brush")
    if "vfxAssets" in bundle and isinstance(bundle["vfxAssets"], dict):
        rig_specs = {
            "taoist":    ("wx_body_sect_02", "wx_head_09", "wx_hair_14", "wx_beard_21", "wx_hat_09"),
            "monk":      ("wx_body_sect_01", "wx_head_30", None,         None,          "wx_hat_21"),
            "scholar":   ("wx_body_sect_07", "wx_head_33", "wx_hair_12", None,          "wx_hat_12"),
            "beggar":    ("wx_body_sect_05", "wx_head_11", "wx_hair_08", "wx_beard_18", "wx_hat_13"),
            "assassin":  ("wx_body_sect_10", "wx_head_07", "wx_hair_02", None,          "wx_hat_08"),
            "tangmen":   ("wx_body_sect_06", "wx_head_13", "wx_hair_11", None,          "wx_hat_14"),
            "general":   ("wx_body_hvy_02",  "wx_head_15", "wx_hair_17", "wx_beard_01", "wx_hat_30"),
            "swordsman": ("wx_body_sect_03", "wx_head_01", "wx_hair_09", None,          None),
        }
        rigs = {}
        for rname, (body_k, head_k, hair_k, beard_k, hat_k) in rig_specs.items():
            bw, bh = busts_brush[body_k].size
            torso_raw = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
            if hat_k and f"{hat_k}_back" in busts_brush:
                torso_raw.alpha_composite(busts_brush[f"{hat_k}_back"])
            torso_raw.alpha_composite(busts_brush[body_k])
            head_raw = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
            for pk in (head_k, beard_k, hair_k, f"{hat_k}_front" if hat_k else None):
                if pk and pk in busts_brush:
                    head_raw.alpha_composite(busts_brush[pk])
            rigs[rname] = {
                "torso": to_webp_uri(trim_and_fade_bust(torso_raw, (96, 124)), quality=82),
                "head": to_webp_uri(head_raw.resize((96, 124), Image.Resampling.LANCZOS), quality=82),
            }
        bundle["vfxAssets"]["rigs"] = rigs

        enemy_specs = {
            "sword": "wx_enemy_dongchang_agent",
            "saber": "wx_enemy_liaodong_boss",
            "fist":  "wx_enemy_bronze_yaoren",
            "pole":  "wx_enemy_mobei_centurion",
            "heavy": "wx_enemy_tomb_general",
            "odd":   "wx_enemy_wudu_gushaman",
            "inner": "wx_enemy_xuesha_juggernaut",
        }
        enemies = {}
        for ek, bkey in enemy_specs.items():
            if bkey in beasts_brush:
                enemies[ek] = to_webp_uri(trim_and_fade_bust(beasts_brush[bkey], (96, 124)), quality=82)
        if enemies:
            bundle["vfxAssets"]["enemies"] = enemies

    return {
        "busts": busts_uri,
        "enrichedSkills": enriched_skills,
    }


SHANHAI_CSS = r"""
/* === WX_SHANHAI_THEATER_CSS_START === */
.wx-sh-theater {
  margin: 0 0 18px 0;
  background: linear-gradient(180deg, #1b1411 0%, #110d0b 100%);
  border: 1px solid #4e3429;
  border-radius: 10px;
  box-shadow: 0 10px 28px rgba(24, 12, 8, 0.28);
  color: #efe2ca;
  overflow: hidden;
}
.wx-sh-head {
  display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between;
  gap: 10px; padding: 12px 16px;
  background: linear-gradient(90deg, rgba(162, 52, 34, 0.26), rgba(92, 56, 30, 0.14));
  border-bottom: 1px solid rgba(210, 126, 86, 0.25);
}
.wx-sh-head h3 {
  margin: 0; font-size: 16px; color: #ffd9a0; letter-spacing: 0.5px;
  display: flex; align-items: center; gap: 8px;
}
.wx-sh-head p { margin: 2px 0 0 0; font-size: 12px; color: #ccb69a; }
.wx-sh-cats {
  display: flex; flex-wrap: wrap; gap: 6px; padding: 10px 14px;
  background: rgba(12, 9, 8, 0.56);
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}
.wx-sh-cat {
  border: 1px solid #4a342a; background: #211815; color: #dcc9af;
  font-size: 12px; padding: 4px 10px; border-radius: 16px; cursor: pointer;
  transition: all 0.15s;
}
.wx-sh-cat:hover { border-color: #d98252; color: #fff; }
.wx-sh-cat[aria-pressed="true"] {
  background: linear-gradient(180deg, #8e2d20, #5b1a12);
  border-color: #f2a266; color: #fff6e6; font-weight: 700;
}
.wx-sh-body {
  display: grid; grid-template-columns: 276px minmax(0, 1fr);
  min-height: 410px;
}
.wx-sh-roster {
  border-right: 1px solid rgba(255, 255, 255, 0.08);
  max-height: 470px; overflow-y: auto; padding: 8px;
  background: rgba(14, 10, 9, 0.68);
}
.wx-sh-pick {
  width: 100%; display: flex; align-items: center; gap: 8px; text-align: left;
  padding: 6px 8px; margin-bottom: 5px; border-radius: 6px;
  border: 1px solid transparent; background: rgba(255, 255, 255, 0.025);
  color: #eadcc4; cursor: pointer; transition: all 0.14s;
}
.wx-sh-pick:hover { background: rgba(224, 114, 72, 0.13); border-color: rgba(236, 134, 86, 0.34); }
.wx-sh-pick[aria-pressed="true"] {
  background: linear-gradient(90deg, rgba(168, 52, 34, 0.42), rgba(74, 38, 22, 0.22));
  border-color: #ef9c5e; color: #fff8ea;
}
.wx-sh-pick img {
  width: 34px; height: 34px; border-radius: 5px; object-fit: cover; flex-shrink: 0;
  border: 1px solid rgba(255, 214, 152, 0.34); background: #140f0c;
}
.wx-sh-pick-meta { min-width: 0; flex: 1; }
.wx-sh-pick-name { font-size: 13px; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.wx-sh-pick-sub { font-size: 11px; color: #bda78e; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.wx-sh-stage-col {
  padding: 14px 16px; display: flex; flex-direction: column; gap: 10px;
}
.wx-sh-stage-top {
  display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 8px;
}
.wx-sh-stage-title { font-size: 17px; font-weight: 700; color: #ffdfb0; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.wx-sh-pill {
  font-size: 11px; padding: 2px 8px; border-radius: 12px;
  background: rgba(242, 162, 102, 0.16); border: 1px solid rgba(242, 162, 102, 0.45);
  color: #ffd89b;
}
.wx-sh-skill-tabs {
  display: flex; flex-wrap: wrap; gap: 6px;
}
.wx-sh-sk-tab {
  border: 1px solid #563a2c; background: #231814; color: #e2cfb6;
  font-size: 12px; padding: 6px 11px; border-radius: 7px; cursor: pointer;
  display: inline-flex; align-items: center; gap: 6px; transition: all 0.14s;
}
.wx-sh-sk-tab:hover { border-color: #e89b5d; color: #fff; }
.wx-sh-sk-tab[aria-pressed="true"] {
  background: linear-gradient(180deg, #8b2f1f, #551b11);
  border-color: #ffbd7a; color: #fff9ee; font-weight: 700;
  box-shadow: 0 0 12px rgba(242, 128, 72, 0.30);
}
.wx-sh-canvas-wrap {
  position: relative; border-radius: 8px; overflow: hidden;
  border: 1px solid #4e372a; background: #0d0907;
  display: flex; justify-content: center; align-items: center;
}
.wx-sh-canvas-wrap canvas {
  display: block; width: 100%; max-width: 520px; height: auto; aspect-ratio: 460 / 254;
}
.wx-sh-ctrl-bar {
  display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 8px;
}
.wx-sh-btn {
  border: 1px solid #584130; background: #261b15; color: #eddcc0;
  font-size: 12px; padding: 5px 11px; border-radius: 6px; cursor: pointer;
}
.wx-sh-btn:hover { border-color: #e8a566; color: #fff; }
.wx-sh-btn[aria-pressed="true"] { background: #7f2d1d; border-color: #f4b26e; color: #fff; font-weight: 700; }
.wx-sh-info-box {
  background: rgba(255, 255, 255, 0.035); border: 1px solid rgba(255, 214, 152, 0.14);
  border-radius: 7px; padding: 9px 12px; font-size: 12.5px; line-height: 1.55; color: #e2d2ba;
}
.wx-sh-info-meta {
  display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 5px;
}
.wx-modal-sh-box {
  margin: 0 0 14px 0; padding: 12px; border-radius: 8px;
  background: linear-gradient(180deg, #1b1411, #110d0b);
  border: 1px solid #55392a; color: #efe2ca;
}
.wx-modal-sh-grid {
  display: grid; grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr); gap: 12px; align-items: start;
}
.wx-sh-sk-card-act {
  margin-left: auto; border: 1px solid #8a4326; background: #3b1c12; color: #ffdca8;
  font-size: 11px; padding: 3px 9px; border-radius: 12px; cursor: pointer;
}
.wx-sh-sk-card-act:hover { background: #6b2916; color: #fff; }
.wx-sh-sk-card-act[aria-pressed="true"] { background: #9c341d; border-color: #ffbe75; color: #fff; font-weight: 700; }
@media (max-width: 860px) {
  .wx-sh-body { grid-template-columns: 1fr; }
  .wx-sh-roster { max-height: 220px; border-right: none; border-bottom: 1px solid rgba(255, 255, 255, 0.08); }
  .wx-modal-sh-grid { grid-template-columns: 1fr; }
}
/* === WX_SHANHAI_THEATER_CSS_END === */
"""


SHANHAI_JS = r"""
// === WX_SHANHAI_THEATER_JS_START ===
  const SH_ASSETS = DB.bestiaryAssets || { busts: {} };
  const SH_FEATURED_IDS = [
    'wx_boss_taotie', 'wx_boss_qiongqi', 'wx_boss_hundun', 'wx_boss_taowu',
    'wx_boss_xingtian', 'wx_boss_chiyou', 'wx_boss_yinglong', 'wx_boss_zhuyin',
    'wx_boss_jinwu', 'wx_boss_kui', 'wx_boss_xiangliuwang', 'wx_boss_jiuwei',
    'wx_boss_xuangui', 'wx_boss_qinyuan', 'wx_boss_zhuyan', 'wx_beast_feiyi_wild'
  ];
  const SH_CAT_DEFS = [
    ['featured', '精选四凶神魔 (16)'],
    ['filtered', '当前筛选结果'],
    ['all', '全部异兽 (139)'],
    ['山海四凶', '山海四凶'],
    ['太古神魔', '太古神魔'],
    ['秘境妖皇', '秘境妖皇'],
    ['荒泽精英', '荒泽精英'],
    ['山海群妖', '山海群妖']
  ];

  const shState = {
    collapsed: false,
    cat: 'featured',
    creatureId: 'wx_boss_taotie',
    skillIdx: 0,
    speed: 1.0,
    modalCreatureId: '',
    modalSkillIdx: 0,
    modalSpeed: 1.0,
    stageRaf: 0,
    modalRaf: 0,
    lastFiltered: null
  };

  function stopShanHaiStage() {
    if (shState.stageRaf) {
      cancelAnimationFrame(shState.stageRaf);
      shState.stageRaf = 0;
    }
  }
  function stopShanHaiModal() {
    if (shState.modalRaf) {
      cancelAnimationFrame(shState.modalRaf);
      shState.modalRaf = 0;
    }
  }

  function shResolvePool(filteredCreatures) {
    const all = DB.bestiary.creatures || [];
    if (shState.cat === 'featured') {
      const f = SH_FEATURED_IDS.map(id => creatureById.get(id)).filter(Boolean);
      return f.length ? f : all.slice(0, 16);
    }
    if (shState.cat === 'filtered') {
      const src = filteredCreatures || shState.lastFiltered || all;
      return src.length ? src : all;
    }
    if (shState.cat === 'all') return all;
    const byRank = all.filter(c => c.rank === shState.cat);
    return byRank.length ? byRank : all;
  }

  function shDrawHexPoly(ctx, cx, cy, rx, ry, stroke, fill) {
    ctx.save();
    ctx.beginPath();
    for (let i = 0; i < 6; i++) {
      const a = (Math.PI / 3) * i;
      const x = cx + Math.cos(a) * rx;
      const y = cy + Math.sin(a) * ry;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.closePath();
    ctx.fillStyle = fill;
    ctx.fill();
    ctx.strokeStyle = stroke;
    ctx.lineWidth = 1.4;
    ctx.stroke();
    ctx.restore();
  }

  function shDrawSpeedLines(ctx, W, H, col, alpha) {
    if (alpha <= 0.02) return;
    ctx.save();
    ctx.globalAlpha = Math.min(0.45, alpha * 0.42);
    ctx.strokeStyle = col || '#ff8844';
    ctx.lineWidth = 1.6;
    for (let i = 0; i < 14; i++) {
      const y = ((i * 23) % (H - 30)) + 15;
      const len = 65 + (i % 4) * 38;
      const x0 = W - ((i * 53) % (W * 0.65));
      ctx.beginPath();
      ctx.moveTo(x0, y);
      ctx.lineTo(x0 - len, y + (i % 2 === 0 ? 3 : -3));
      ctx.stroke();
    }
    ctx.restore();
  }

  function shDrawSlashArc(ctx, cx, cy, rOuter, rInner, a0, a1, col, alpha) {
    if (alpha <= 0.02) return;
    ctx.save();
    ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    ctx.fillStyle = col;
    ctx.shadowColor = col;
    ctx.shadowBlur = 14;
    ctx.beginPath();
    ctx.arc(cx, cy, rOuter, a0, a1, false);
    ctx.arc(cx, cy, rInner, a1, a0, true);
    ctx.closePath();
    ctx.fill();
    ctx.restore();
  }

  function shDrawImgFit(ctx, im, cx, cy, w, h, rotRad, alpha, flipX) {
    if (!im || !im.complete || !im.naturalWidth || alpha <= 0.02) return;
    ctx.save();
    ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    ctx.translate(cx, cy);
    if (flipX) ctx.scale(-1, 1);
    if (rotRad) ctx.rotate(rotRad);
    ctx.drawImage(im, -w / 2, -h / 2, w, h);
    ctx.restore();
  }

  // === 60fps Offline Shan Hai Jing Creature Action Choreography Canvas (All 20 Modes!) ===
  function startShanHaiCanvas(canvasId, creature, skillIdx, isModal) {
    const cv = document.getElementById(canvasId);
    if (!cv || typeof cv.getContext !== 'function') return;
    const ctx = cv.getContext('2d');
    if (!ctx) return;

    if (isModal) stopShanHaiModal(); else stopShanHaiStage();

    const c = creature || creatureById.get('wx_boss_taotie') || (DB.bestiary.creatures || [])[0];
    if (!c) return;
    const skills = c.skills || [];
    const sk = skills[skillIdx] || skills[0];
    if (!sk) return;

    const beastUri = (SH_ASSETS.busts && SH_ASSETS.busts[c.id]) || (c.icon && DB.icons[c.icon]) || '';
    const beastIm = wxImg(beastUri);

    const rig = (VFX_ASSETS.rigs && (VFX_ASSETS.rigs.general || VFX_ASSETS.rigs.swordsman)) || {};
    const heroTorso = wxImg(rig.torso);
    const heroHead  = wxImg(rig.head);
    const heroWpn   = wxImg((VFX_ASSETS.weapons && VFX_ASSETS.weapons.minghong) || '');
    const heroShd   = wxImg((VFX_ASSETS.weapons && (VFX_ASSETS.weapons.shd_12 || VFX_ASSETS.weapons.shd_xuangui)) || '');

    const fxMap = VFX_ASSETS.fx || {};
    const vfxMap = VFX_ASSETS.vfx || {};
    const fxIm    = wxImg(fxMap[sk.fx] || fxMap.wx_fx_claw_slash);
    const auraIm  = wxImg(vfxMap[sk.vfx] || vfxMap.wx_vfx_05);
    const sonicIm = wxImg(fxMap.wx_fx_sonic_ring);
    const bloodIm = wxImg(fxMap.wx_fx_blood_orb);
    const earthIm = wxImg(fxMap.wx_fx_earth_fissure);
    const boltIm  = wxImg(fxMap.wx_fx_thunder_bolt);

    const mode = sk.animMode || 'feral_pounce';
    const col = sk.animColor || '#ff5a36';
    const isBoss = c.kind === 'boss';
    const cycleMs = 1960;
    let startTs = performance.now();

    function drawHeroDefender(cx, groundY, jumpZ, leanDeg, flash, wpnDeg) {
      ctx.save();
      const shS = Math.max(0.4, 1 - jumpZ / 130);
      ctx.fillStyle = 'rgba(0,0,0,' + (0.48 * shS).toFixed(2) + ')';
      ctx.beginPath(); ctx.ellipse(cx, groundY + 42, 34 * shS, 11 * shS, 0, 0, Math.PI * 2); ctx.fill();

      ctx.translate(cx, groundY - jumpZ);
      ctx.rotate((leanDeg * Math.PI) / 180);
      if (flash > 0.05) ctx.filter = 'brightness(' + (1 + flash * 1.55).toFixed(2) + ')';

      // Weapon held on LEFT side (character's right hand), Shield on RIGHT/FRONT facing the beast (v0.8.8 authentic!)
      if (heroWpn && heroWpn.complete && heroWpn.naturalWidth) {
        ctx.save();
        ctx.translate(-28, 4);
        ctx.rotate((((wpnDeg || -22) * Math.PI) / 180));
        ctx.drawImage(heroWpn, -18, -56, 36, 70);
        ctx.restore();
      }
      if (heroTorso && heroTorso.complete && heroTorso.naturalWidth) ctx.drawImage(heroTorso, -46, -64, 92, 126);
      if (heroHead && heroHead.complete && heroHead.naturalWidth) ctx.drawImage(heroHead, -46, -64, 92, 126);
      if (heroShd && heroShd.complete && heroShd.naturalWidth) {
        ctx.save();
        ctx.translate(22, 6);
        ctx.drawImage(heroShd, -22, -26, 44, 52);
        ctx.restore();
      }
      ctx.restore();
    }

    function drawBeastPawn(cx, groundY, jumpZ, leanDeg, sx, sy, alpha, faceRight) {
      ctx.save();
      const bw = isBoss ? 116 : 100;
      const bh = isBoss ? 150 : 128;
      const shS = Math.max(0.35, 1 - jumpZ / 150);
      ctx.fillStyle = 'rgba(0,0,0,' + (0.52 * shS * alpha).toFixed(2) + ')';
      ctx.beginPath(); ctx.ellipse(cx, groundY + 42, (isBoss ? 44 : 36) * shS, 13 * shS, 0, 0, Math.PI * 2); ctx.fill();

      ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
      ctx.translate(cx, groundY - jumpZ);
      // Compiled v0.8.8 wx_beasts_0.brush sprites natively face 3/4-RIGHT; flip to face LEFT toward hero!
      if (!faceRight) ctx.scale(-1, 1);
      ctx.rotate(((faceRight ? leanDeg : -leanDeg) * Math.PI) / 180);
      ctx.scale(sx, sy);
      if (beastIm && beastIm.complete && beastIm.naturalWidth) {
        ctx.drawImage(beastIm, -bw / 2, -bh * 0.56, bw, bh);
      }
      ctx.restore();
    }

    function step(now) {
      if (!document.getElementById(canvasId)) return;
      const W = cv.width, H = cv.height;
      const spd = isModal ? shState.modalSpeed : shState.speed;
      let rawP = ((now - startTs) * spd) / cycleMs;
      if (rawP >= 1.0) { startTs = now; rawP = rawP % 1.0; }

      // Crisp hit-stop (`顿帧`) at impact (`0.48..0.54`)
      let p = rawP;
      if (rawP > 0.48 && rawP < 0.54) p = 0.48 + (rawP - 0.48) * 0.20;
      else if (rawP >= 0.54) p = 0.492 + (rawP - 0.54) * (0.508 / 0.46);

      const easeOut = t => 1 - Math.pow(1 - Math.max(0, Math.min(1, t)), 3);
      const groundY = 154;
      const heroHomeX = 114, beastHomeX = 342;

      let hx = heroHomeX, hz = 0, hLean = 0, hFlash = 0, hWpnDeg = -22;
      let bx = beastHomeX, bz = 0, bLean = 0, bsx = 1, bsy = 1, bAlpha = 1, bFaceRight = false;
      let shakeX = 0, shakeY = 0, camZoom = 1.0;
      const clones = [], arcs = [], popups = [];

      // === All 20 Shan Hai Monster Combat Choreographies ===
      if (mode === 'ape_titan_slam' || mode === 'thunder_hoof_stomp') {
        if (p < 0.24) {
          const k = p / 0.24;
          bsy = 1 - 0.14 * k; bsx = 1 + 0.12 * k; bLean = 14 * k;
        } else if (p < 0.49) {
          const k = (p - 0.24) / 0.25;
          bx = beastHomeX - easeOut(k) * 168;
          bz = Math.sin(k * Math.PI) * 84;
          bLean = 14 - k * 36;
          clones.push({ x: bx + 26, z: Math.max(0, bz - 16), a: 0.30 });
        } else if (p < 0.82) {
          const k = (p - 0.49) / 0.33;
          bx = (beastHomeX - 168) + k * 18; bLean = -18 * (1 - k);
          hx = heroHomeX - Math.sin(k * Math.PI) * 28; hz = Math.sin(Math.min(1, k * 2) * Math.PI) * 22;
          hLean = -24 * (1 - k); hFlash = Math.max(0, 1 - k * 1.8);
          if (k < 0.55) { shakeX = (Math.random() - 0.5) * 14; shakeY = (Math.random() - 0.5) * 13; camZoom = 1.11; }
        } else {
          const k = (p - 0.82) / 0.18;
          bx = beastHomeX - (1 - easeOut(k)) * 150;
        }
      } else if (mode === 'feral_pounce' || mode === 'horn_gore_charge' || mode === 'headless_waraxe') {
        if (p < 0.22) {
          const k = p / 0.22;
          bx = beastHomeX + 14 * k; bsy = 1 - 0.10 * k; bsx = 1 + 0.08 * k; bLean = 12 * k;
        } else if (p < 0.49) {
          const k = easeOut((p - 0.22) / 0.27);
          bx = (beastHomeX + 14) - k * 186;
          bz = mode === 'feral_pounce' ? Math.sin(k * Math.PI) * 34 : 0;
          bLean = -22 * k;
          clones.push({ x: bx + 34, z: bz * 0.6, a: 0.36 }, { x: bx + 66, z: 0, a: 0.18 });
        } else if (p < 0.78) {
          const k = (p - 0.49) / 0.29;
          bx = (beastHomeX - 172) + k * 24;
          bLean = mode === 'headless_waraxe' ? Math.sin(k * Math.PI * 4) * 24 : -18 * (1 - k);
          hx = heroHomeX - Math.sin(k * Math.PI) * (mode === 'horn_gore_charge' ? 38 : 20);
          hLean = -22 * (1 - k); hFlash = Math.max(0, 1 - k * 1.9);
          arcs.push({ x: hx + 18, y: groundY - 12, rO: 84, rI: 50, a0: 1.9, a1: 4.3, a: Math.max(0, 1 - k * 1.8) });
          if (k < 0.5) { shakeX = (Math.random() - 0.5) * 11; shakeY = (Math.random() - 0.5) * 8; camZoom = 1.09; }
        } else {
          const k = (p - 0.78) / 0.22;
          bx = beastHomeX - (1 - easeOut(k)) * 148;
        }
      } else if (mode === 'multi_head_frenzy') {
        const hits = 3;
        if (p < 0.18) {
          bLean = 12 * (p / 0.18);
        } else if (p < 0.80) {
          const k = (p - 0.18) / 0.62;
          const sub = (k * hits) % 1;
          const idx = Math.floor(k * hits);
          bx = beastHomeX - 162 + (idx % 2 === 0 ? -8 : 8);
          bz = idx === 1 ? Math.sin(sub * Math.PI) * 28 : 0;
          bLean = -16 - Math.sin(sub * Math.PI) * 12;
          hx = heroHomeX - Math.sin(sub * Math.PI) * 15;
          hLean = -16 * Math.sin(sub * Math.PI); hFlash = Math.sin(sub * Math.PI) * 0.9;
          arcs.push({ x: hx + 12, y: groundY - 10, rO: 76, rI: 46, a0: 1.8 + idx * 0.6, a1: 4.1 + idx * 0.6, a: Math.sin(sub * Math.PI) });
          popups.push({ x: hx + (idx - 1) * 18, y: 54 - sub * 18, txt: '-' + (28 + idx * 11), a: Math.sin(sub * Math.PI), col });
          shakeX = (Math.random() - 0.5) * 8; camZoom = 1.08;
        } else {
          bx = beastHomeX - (1 - easeOut((p - 0.80) / 0.20)) * 162;
        }
      } else if (mode === 'sky_talon_dive' || mode === 'sun_crow_nova') {
        if (p < 0.28) {
          const k = easeOut(p / 0.28);
          bz = k * 92; bx = beastHomeX - k * 28; bLean = 10 * k;
        } else if (p < 0.52) {
          const k = easeOut((p - 0.28) / 0.24);
          if (mode === 'sun_crow_nova') {
            bx = beastHomeX - 28 - k * 82; bz = 92 - k * 18;
          } else {
            bx = beastHomeX - 28 - k * 154; bz = 92 * (1 - k); bLean = -26 * k;
            clones.push({ x: bx + 32, z: bz + 28, a: 0.35 });
          }
        } else if (p < 0.82) {
          const k = (p - 0.52) / 0.30;
          if (mode === 'sun_crow_nova') {
            bx = beastHomeX - 110 + k * 40; bz = 74 * (1 - k * 0.5);
          } else {
            bx = (beastHomeX - 182) + easeOut(k) * 80; bz = Math.sin(k * Math.PI) * 30;
          }
          hx = heroHomeX - Math.sin(k * Math.PI) * 20; hLean = -20 * (1 - k); hFlash = Math.max(0, 1 - k * 1.8);
          if (k < 0.5) { shakeX = (Math.random() - 0.5) * 11; shakeY = (Math.random() - 0.5) * 10; camZoom = 1.10; }
        } else {
          const k = (p - 0.82) / 0.18;
          bx = beastHomeX - (1 - k) * 70; bz = (1 - k) * 36;
        }
      } else if (mode === 'abyss_tentacle_drag') {
        if (p < 0.34) {
          const k = easeOut(p / 0.34);
          bx = beastHomeX - k * 24; bLean = -14 * k;
        } else if (p < 0.76) {
          const k = easeOut((p - 0.34) / 0.42);
          bx = beastHomeX - 24; bLean = 10;
          hx = heroHomeX + k * 144; hLean = 22 * (1 - k * 0.4); hFlash = Math.sin(k * Math.PI);
          shakeX = (Math.random() - 0.5) * 7;
        } else {
          const k = (p - 0.76) / 0.24;
          hx = (heroHomeX + 144) - easeOut(k) * 144; bx = beastHomeX - (1 - k) * 24;
        }
      } else if (mode === 'shell_thorns_quake') {
        if (p < 0.42) {
          const k = easeOut(p / 0.42);
          hx = heroHomeX + k * 154; hLean = 18 * k; hWpnDeg = -45 + k * 110;
          bsy = 1 - 0.08 * k; bsx = 1 + 0.08 * k;
        } else if (p < 0.78) {
          const k = (p - 0.42) / 0.36;
          hx = (heroHomeX + 154) - easeOut(k) * 158; hLean = -24 * Math.sin(k * Math.PI);
          hFlash = Math.max(0, 1 - k * 1.8);
          shakeX = (Math.random() - 0.5) * 10 * (1 - k);
        }
      } else if (mode === 'dream_shadow_ambush') {
        if (p < 0.24) {
          bAlpha = 1 - 0.85 * (p / 0.24);
        } else if (p < 0.76) {
          const k = (p - 0.24) / 0.52;
          bx = heroHomeX - 52; bFaceRight = true; bLean = 18;
          clones.push({ x: beastHomeX, z: 0, a: Math.max(0, 0.38 - k) });
          if (k > 0.30) {
            hFlash = Math.max(0, 1 - (k - 0.30) * 2.2); hx = heroHomeX + Math.sin((k - 0.30) * Math.PI) * 16;
            arcs.push({ x: heroHomeX, y: groundY - 12, rO: 76, rI: 50, a0: -1.1, a1: 1.2, a: Math.max(0, 1 - (k - 0.30) * 2) });
          }
        } else {
          const k = (p - 0.76) / 0.24;
          bx = (heroHomeX - 52) + easeOut(k) * (beastHomeX - (heroHomeX - 52));
        }
      } else if (mode === 'coiled_crush' || mode === 'corpse_chain_cleave') {
        if (p < 0.24) {
          const k = p / 0.24;
          bx = beastHomeX + Math.sin(k * Math.PI * 2) * 10; bLean = 14 * k;
        } else if (p < 0.52) {
          const k = easeOut((p - 0.24) / 0.28);
          bx = beastHomeX - k * 156; bLean = -20 * k;
        } else if (p < 0.82) {
          const k = (p - 0.52) / 0.30;
          bx = (beastHomeX - 156) + k * 28;
          hx = heroHomeX - Math.sin(k * Math.PI) * 22; hLean = -20 * (1 - k); hFlash = Math.max(0, 1 - k * 1.8);
          arcs.push({ x: hx + 24, y: groundY - 8, rO: 90, rI: 54, a0: 1.7, a1: 4.5, a: Math.max(0, 1 - k * 1.8) });
          if (k < 0.5) { shakeX = (Math.random() - 0.5) * 10; camZoom = 1.08; }
        } else {
          bx = beastHomeX - (1 - easeOut((p - 0.82) / 0.18)) * 128;
        }
      } else {
        // dragon_breath, fox_charm_miasma, venom_needle_barrage, root_thorn_entangle, sonic_dread_roar, boulder_hurl_smash, devour_blood_siphon
        if (p < 0.28) {
          const k = p / 0.28;
          bx = beastHomeX + 8 * k; bLean = 12 * k;
          if (mode === 'fox_charm_miasma') bz = Math.sin(k * Math.PI) * 18;
        } else if (p < 0.52) {
          const k = easeOut((p - 0.28) / 0.24);
          bx = (beastHomeX + 8) - k * (mode === 'devour_blood_siphon' ? 132 : 34);
          bLean = -16 * k;
        } else if (p < 0.84) {
          const k = (p - 0.52) / 0.32;
          bx = beastHomeX - (mode === 'devour_blood_siphon' ? 124 : 26) * (1 - k);
          bLean = -16 * (1 - k);
          hx = heroHomeX + (mode === 'devour_blood_siphon' ? Math.sin(k * Math.PI) * 24 : -Math.sin(k * Math.PI) * 20);
          hLean = mode === 'fox_charm_miasma' ? Math.sin(k * Math.PI * 4) * 12 : -18 * (1 - k);
          hFlash = Math.max(0, 1 - k * 1.8);
          if (k < 0.48) { shakeX = (Math.random() - 0.5) * 10; shakeY = (Math.random() - 0.5) * 7; camZoom = 1.09; }
        }
      }

      // === Render Arena Frame ===
      ctx.save();
      ctx.clearRect(0, 0, W, H);

      const isFrost = c.socketTheme === 'boss_frost';
      const isMire = c.socketTheme === 'boss_mire' || c.socketTheme === 'spawn_mire';
      const bg = ctx.createRadialGradient(W * 0.52, H * 0.56, 18, W * 0.5, H * 0.5, W * 0.82);
      bg.addColorStop(0, isFrost ? '#1a2c3b' : (isMire ? '#1d2d22' : '#36231a'));
      bg.addColorStop(1, '#0d0907');
      ctx.fillStyle = bg; ctx.fillRect(0, 0, W, H);

      ctx.translate(W * 0.5 + shakeX, H * 0.5 + shakeY);
      ctx.scale(camZoom, camZoom);
      ctx.translate(-W * 0.5, -H * 0.5);

      if (p > 0.25 && p < 0.68) {
        shDrawSpeedLines(ctx, W, H, col, Math.sin(((p - 0.25) / 0.43) * Math.PI));
      }

      [114, 190, 266, 342].forEach((cx, hi) => {
        const stroke = hi === 0 ? 'rgba(136,192,120,0.48)' : (hi === 3 ? 'rgba(225,86,68,0.58)' : 'rgba(154,126,88,0.25)');
        const fill = hi === 0 ? 'rgba(46,74,40,0.22)' : (hi === 3 ? 'rgba(104,32,24,0.26)' : 'rgba(38,29,20,0.20)');
        shDrawHexPoly(ctx, cx, groundY + 42, 47, 17, stroke, fill);
      });

      // Live in-game Qi-aura (`wx_vfx_*`) around casting Shan Hai Beast!
      if (auraIm && p > 0.08 && p < 0.62) {
        const ak = Math.sin(((p - 0.08) / 0.54) * Math.PI);
        shDrawImgFit(ctx, auraIm, bx, groundY - bz - 10, 134 + ak * 28, 134 + ak * 28, p * 1.4, ak * 0.72, false);
      }

      if ((mode === 'ape_titan_slam' || mode === 'thunder_hoof_stomp' || mode === 'root_thorn_entangle') && p >= 0.46 && earthIm) {
        const ek = Math.min(1, (p - 0.46) / 0.44);
        for (let gi = 0; gi < (mode === 'root_thorn_entangle' ? 3 : 1); gi++) {
          const gx = mode === 'root_thorn_entangle' ? (bx - 64 - gi * 62) : hx + 18;
          shDrawImgFit(ctx, earthIm, gx, groundY + 26, 120, 86, 0, Math.max(0, 1 - ek * 0.8), false);
        }
      }

      drawHeroDefender(hx, groundY, hz, hLean, hFlash, hWpnDeg);
      clones.forEach(cl => drawBeastPawn(cl.x, groundY, cl.z || 0, -14, 1, 1, cl.a, bFaceRight));
      drawBeastPawn(bx, groundY, bz, bLean, bsx, bsy, bAlpha, bFaceRight);

      arcs.forEach(sa => shDrawSlashArc(ctx, sa.x, sa.y, sa.rO, sa.rI, sa.a0, sa.a1, col, sa.a));

      // Mode-Specific Elemental Beams / Projectiles / Tentacles / Boulders / Bolts / Auras
      if (mode === 'dragon_breath' && p > 0.34 && p < 0.82) {
        const bk = Math.sin(((p - 0.34) / 0.48) * Math.PI);
        ctx.save();
        const grad = ctx.createLinearGradient(bx - 36, groundY - 18, hx - 20, groundY - 8);
        grad.addColorStop(0, '#ffffff');
        grad.addColorStop(0.28, col);
        grad.addColorStop(1, 'rgba(0,0,0,0)');
        ctx.globalAlpha = Math.min(0.92, bk * 1.25);
        ctx.fillStyle = grad;
        ctx.beginPath();
        ctx.moveTo(bx - 34, groundY - 26);
        ctx.lineTo(hx - 28, groundY - 56);
        ctx.lineTo(hx - 28, groundY + 26);
        ctx.lineTo(bx - 34, groundY - 8);
        ctx.closePath();
        ctx.fill();
        ctx.restore();
        if (fxIm) shDrawImgFit(ctx, fxIm, hx, groundY - 12, 118, 118, 0, bk, true);
      } else if (mode === 'sun_crow_nova' && p > 0.38 && p < 0.88) {
        const nk = (p - 0.38) / 0.50;
        ctx.save();
        const g = ctx.createRadialGradient(bx, groundY - bz, 8, bx, groundY - bz, 220 * nk + 24);
        g.addColorStop(0, 'rgba(255,250,210,' + (1 - nk).toFixed(2) + ')');
        g.addColorStop(0.45, 'rgba(255,112,24,' + (0.78 * (1 - nk)).toFixed(2) + ')');
        g.addColorStop(1, 'rgba(0,0,0,0)');
        ctx.fillStyle = g; ctx.beginPath(); ctx.arc(bx, groundY - bz, 230, 0, Math.PI * 2); ctx.fill();
        ctx.restore();
      } else if (mode === 'venom_needle_barrage' && p > 0.30 && p < 0.80) {
        const vk = (p - 0.30) / 0.50;
        for (let i = 0; i < 9; i++) {
          const tk = Math.max(0, Math.min(1, vk * 1.45 - (i % 3) * 0.09));
          if (tk <= 0 || tk >= 1) continue;
          const px = (bx - 38) - tk * (bx - hx - 32);
          const py = (groundY - 18) + (i - 4) * 8 * tk;
          ctx.save();
          ctx.strokeStyle = col; ctx.lineWidth = 3;
          ctx.beginPath(); ctx.moveTo(px + 22, py); ctx.lineTo(px - 8, py); ctx.stroke();
          ctx.restore();
        }
        if (vk > 0.45 && fxIm) shDrawImgFit(ctx, fxIm, hx, groundY - 18, 110, 110, 0, 1 - (vk - 0.45) * 1.5, false);
      } else if ((mode === 'abyss_tentacle_drag' || mode === 'corpse_chain_cleave') && p > 0.28 && p < 0.80) {
        const wk = Math.sin(((p - 0.28) / 0.52) * Math.PI);
        ctx.save();
        ctx.strokeStyle = col; ctx.shadowColor = col; ctx.shadowBlur = 12; ctx.lineWidth = 6;
        ctx.beginPath();
        for (let s = 0; s <= 20; s++) {
          const t = s / 20;
          const wx = (bx - 28) - t * (bx - hx - 24);
          const wy = (groundY - 12) + Math.sin(t * Math.PI * 3 + p * 18) * 16 * wk;
          if (s === 0) ctx.moveTo(wx, wy); else ctx.lineTo(wx, wy);
        }
        ctx.stroke();
        ctx.restore();
      } else if (mode === 'boulder_hurl_smash' && p > 0.24 && p < 0.84) {
        const bk = (p - 0.24) / 0.60;
        if (bk < 0.48) {
          const t = bk / 0.48;
          const rx = (bx - 24) - t * (bx - hx - 24);
          const ry = (groundY - 26) - Math.sin(t * Math.PI) * 88;
          ctx.save();
          ctx.translate(rx, ry); ctx.rotate(t * 9);
          ctx.fillStyle = '#5c4d3d'; ctx.strokeStyle = '#17120d'; ctx.lineWidth = 2.5;
          ctx.beginPath(); ctx.moveTo(-16, -10); ctx.lineTo(6, -16); ctx.lineTo(18, -2); ctx.lineTo(10, 15); ctx.lineTo(-14, 12); ctx.closePath();
          ctx.fill(); ctx.stroke();
          ctx.restore();
        } else if (earthIm) {
          const ex = (bk - 0.48) / 0.52;
          shDrawImgFit(ctx, earthIm, hx, groundY + 18, 128, 92, 0, 1 - ex, false);
        }
      } else if (mode === 'thunder_hoof_stomp' && p > 0.42 && p < 0.86 && boltIm) {
        shDrawImgFit(ctx, boltIm, hx, groundY - 46, 138, 178, 0, 1 - (p - 0.42) / 0.44, false);
      } else if ((mode === 'sonic_dread_roar' || mode === 'fox_charm_miasma') && p > 0.26 && p < 0.88) {
        const rk = (p - 0.26) / 0.62;
        for (let ri = 0; ri < 4; ri++) {
          const rt = rk * 1.4 - ri * 0.12;
          if (rt > 0 && rt < 1 && sonicIm) {
            shDrawImgFit(ctx, sonicIm, (bx - 34) - rt * 215, groundY - 14, 60 + rt * 92, 80 + rt * 80, 0, (1 - rt) * 0.85, true);
          }
        }
        if (mode === 'fox_charm_miasma' && fxIm && rk > 0.35) {
          shDrawImgFit(ctx, fxIm, hx, groundY - 22, 116, 116, rk * 2.5, Math.min(0.9, (1 - rk) * 2.2), false);
        }
      } else if (mode === 'devour_blood_siphon' && p > 0.44 && p < 0.92 && bloodIm) {
        const dk = (p - 0.44) / 0.48;
        for (let bi = 0; bi < 3; bi++) {
          const bt = Math.max(0, Math.min(1, dk * 1.35 - bi * 0.14));
          if (bt <= 0 || bt >= 1) continue;
          const ox = hx + bt * (bx - hx);
          const oy = groundY - 18 - Math.sin(bt * Math.PI) * 44;
          shDrawImgFit(ctx, bloodIm, ox, oy, 48, 48, bt * 6, Math.sin(bt * Math.PI), false);
        }
      }

      // Impact signature burst (`wx_fx_*`) + shockwave ring + floating damage callout
      if (p > 0.45 && p < 0.84) {
        const ik = (p - 0.45) / 0.39;
        const ia = Math.max(0, 1 - ik);
        if (fxIm && mode !== 'dragon_breath' && mode !== 'venom_needle_barrage') {
          shDrawImgFit(ctx, fxIm, hx + 4, groundY - 16, 108 + ik * 32, 108 + ik * 32, ik * 0.4, ia * 0.92, false);
        }
        ctx.save();
        ctx.strokeStyle = col;
        ctx.globalAlpha = ia * 0.72;
        ctx.lineWidth = 2.5;
        ctx.beginPath();
        ctx.ellipse(hx, groundY + 34, 24 + ik * 56, 9 + ik * 20, 0, 0, Math.PI * 2);
        ctx.stroke();
        ctx.restore();

        if (mode !== 'multi_head_frenzy') {
          const effTag = (sk.effects && sk.effects[0]) ? (' · ' + sk.effects[0]) : '';
          popups.push({ x: hx, y: 66 - ik * 26, txt: (sk.dmg || '命中') + effTag, a: Math.min(1, ia * 1.6), col });
        }
      }

      popups.forEach(pp => {
        if (pp.a <= 0.03) return;
        ctx.save();
        ctx.globalAlpha = pp.a;
        ctx.font = 'bold 13px "Microsoft YaHei", sans-serif';
        ctx.textAlign = 'center';
        ctx.strokeStyle = 'rgba(0,0,0,0.85)';
        ctx.lineWidth = 3.5;
        ctx.strokeText(pp.txt, pp.x, pp.y);
        ctx.fillStyle = pp.col || '#ffd890';
        ctx.fillText(pp.txt, pp.x, pp.y);
        ctx.restore();
      });

      ctx.restore();

      // HUD caption overlay (top-left skill tag + bottom-right speed/mode label)
      ctx.save();
      ctx.fillStyle = 'rgba(12,8,6,0.72)';
      ctx.fillRect(8, 8, 226, 24);
      ctx.strokeStyle = 'rgba(242,162,102,0.45)';
      ctx.strokeRect(8.5, 8.5, 225, 23);
      ctx.font = 'bold 12px "Microsoft YaHei", sans-serif';
      ctx.fillStyle = '#ffe0a8';
      ctx.fillText('⚡ ' + (sk.name || '妖技'), 16, 24);

      ctx.fillStyle = 'rgba(12,8,6,0.68)';
      ctx.fillRect(W - 180, H - 26, 172, 20);
      ctx.font = '11px "Microsoft YaHei", sans-serif';
      ctx.fillStyle = '#d8c2a4';
      ctx.textAlign = 'right';
      ctx.fillText((sk.animLabel || mode) + ' · ' + (spd < 0.8 ? '0.45x' : '1.0x'), W - 14, H - 12);
      ctx.restore();

      const rafId = requestAnimationFrame(step);
      if (isModal) shState.modalRaf = rafId; else shState.stageRaf = rafId;
    }

    const firstRaf = requestAnimationFrame(step);
    if (isModal) shState.modalRaf = firstRaf; else shState.stageRaf = firstRaf;
  }

  function renderShanHaiTheaterInner(filteredCreatures) {
    if (filteredCreatures) shState.lastFiltered = filteredCreatures;
    const pool = shResolvePool(filteredCreatures);
    let cur = creatureById.get(shState.creatureId);
    if (!cur || !pool.some(x => x.id === cur.id)) {
      cur = pool[0] || (DB.bestiary.creatures || [])[0];
      if (cur) { shState.creatureId = cur.id; shState.skillIdx = 0; }
    }
    if (!cur) return '';
    const skills = cur.skills || [];
    if (shState.skillIdx >= skills.length) shState.skillIdx = 0;
    const curSk = skills[shState.skillIdx] || skills[0] || {};

    return `
      <div class="wx-sh-head">
        <div>
          <h3>🐉 山海万妖 · 60fps 异兽技能动作演武台</h3>
          <p>覆盖全部 139 种山海神兽/秘境大妖/野生群妖与 20 套实装妖技动作，实时检视起手罡气、扑袭轨迹与打击特效</p>
        </div>
        <button type="button" class="wx-sh-btn" data-sh-toggle="1">${shState.collapsed ? '▼ 展开异兽演武台' : '▲ 收起演武台'}</button>
      </div>
      ${shState.collapsed ? '' : `
      <div class="wx-sh-cats">
        ${SH_CAT_DEFS.map(([cid, label]) => `
          <button type="button" class="wx-sh-cat" data-sh-cat="${esc(cid)}" aria-pressed="${shState.cat === cid}">${esc(label)}</button>`).join('')}
      </div>
      <div class="wx-sh-body">
        <div class="wx-sh-roster" id="wx-sh-roster-list">
          ${pool.map(c => {
            const thumb = (SH_ASSETS.busts && SH_ASSETS.busts[c.id]) || (c.icon && DB.icons[c.icon]) || '';
            return `
              <button type="button" class="wx-sh-pick" data-sh-pick="${esc(c.id)}" aria-pressed="${c.id === cur.id}">
                ${thumb ? `<img src="${thumb}" alt="" loading="lazy">` : ''}
                <div class="wx-sh-pick-meta">
                  <div class="wx-sh-pick-name">${esc(c.shortName || c.name)}</div>
                  <div class="wx-sh-pick-sub">${esc(c.rank)} · 《${esc(c.chapter)}》 · ${(c.skills || []).length}式妖技</div>
                </div>
              </button>`;
          }).join('')}
        </div>
        <div class="wx-sh-stage-col">
          <div class="wx-sh-stage-top">
            <div class="wx-sh-stage-title">
              <span>${esc(cur.name)}</span>
              <span class="wx-sh-pill">${esc(cur.rank)}</span>
              <span class="wx-sh-pill">《${esc(cur.chapter)}》</span>
            </div>
            <button type="button" class="wx-sh-btn" data-open="creature:${esc(cur.id)}">查看完整图鉴与克制 →</button>
          </div>
          <div class="wx-sh-skill-tabs">
            ${skills.map((sk, idx) => `
              <button type="button" class="wx-sh-sk-tab" data-sh-sk="${idx}" aria-pressed="${idx === shState.skillIdx}">
                <span>⚡ ${esc(sk.name)}</span>
                <span style="opacity:0.78;font-size:11px">${sk.ap}AP</span>
              </button>`).join('')}
          </div>
          <div class="wx-sh-canvas-wrap">
            <canvas id="wx-sh-stage-canvas" width="460" height="254"></canvas>
          </div>
          <div class="wx-sh-ctrl-bar">
            <div style="display:flex;gap:6px;flex-wrap:wrap">
              <button type="button" class="wx-sh-btn" data-sh-ctrl="replay">↺ 重放招式</button>
              <button type="button" class="wx-sh-btn" data-sh-ctrl="slow" aria-pressed="${shState.speed < 0.8}">🐢 0.45x 慢放拆解</button>
            </div>
            <div style="font-size:11.5px;color:#c9b296">实装动作：<code>${esc(curSk.animMode || '')}</code> · 罡气 <code>${esc(curSk.vfx || '')}</code> · 打击 <code>${esc(curSk.fx || '')}</code></div>
          </div>
          <div class="wx-sh-info-box">
            <div class="wx-sh-info-meta">
              <span class="badge b-dark">${curSk.ap || 0} AP · ${curSk.qi || 0} 内息</span>
              <span class="badge">${esc(curSk.range || '')}</span>
              ${curSk.dmg ? `<span class="badge b-gold">${esc(curSk.dmg)}</span>` : ''}
              ${curSk.animLabel ? `<span class="badge b-sect">${esc(curSk.animLabel)}</span>` : ''}
              ${(curSk.effects || []).map(ef => `<span class="badge b-unique">${esc(ef)}</span>`).join('')}
            </div>
            <div>${esc(curSk.desc || '')}</div>
          </div>
        </div>
      </div>`}`;
  }

  function refreshShanHaiTheaterDom(filteredCreatures) {
    const box = document.getElementById('wx-sh-theater-root');
    if (!box) return;
    const prevScroll = (document.getElementById('wx-sh-roster-list') || {}).scrollTop || 0;
    box.innerHTML = renderShanHaiTheaterInner(filteredCreatures);
    const nextList = document.getElementById('wx-sh-roster-list');
    if (nextList) nextList.scrollTop = prevScroll;
    if (shState.collapsed) {
      stopShanHaiStage();
    } else {
      const cur = creatureById.get(shState.creatureId);
      if (cur) requestAnimationFrame(() => startShanHaiCanvas('wx-sh-stage-canvas', cur, shState.skillIdx, false));
    }
  }

  function renderModalCreatureTheaterHtml(c) {
    if (!c || !c.skills || !c.skills.length) return '';
    const idx = (shState.modalCreatureId === c.id && shState.modalSkillIdx < c.skills.length) ? shState.modalSkillIdx : 0;
    const sk = c.skills[idx] || c.skills[0];
    return `
      <div class="wx-modal-sh-box" id="wx-modal-sh-box" data-creature-id="${esc(c.id)}">
        <div class="wx-modal-sh-grid">
          <div class="wx-sh-canvas-wrap">
            <canvas id="wx-modal-sh-canvas" width="460" height="254"></canvas>
          </div>
          <div style="display:flex;flex-direction:column;gap:8px">
            <div style="font-size:13.5px;color:#ffdfb0;font-weight:700">🐉 实战异兽技能动作预览 · ${esc(sk.animLabel || sk.name)}</div>
            <div class="wx-sh-skill-tabs">
              ${c.skills.map((s, si) => `
                <button type="button" class="wx-sh-sk-tab" data-msh-sk="${si}" aria-pressed="${si === idx}">
                  ⚡ ${esc(s.name)}
                </button>`).join('')}
            </div>
            <div style="font-size:12px;color:#d6c2a8;line-height:1.5">${esc(sk.desc || '')}</div>
            <div style="display:flex;flex-wrap:wrap;gap:5px">
              <span class="badge b-dark">${sk.ap} AP · ${sk.qi} 内息</span>
              <span class="badge">${esc(sk.range || '')}</span>
              ${sk.dmg ? `<span class="badge b-gold">${esc(sk.dmg)}</span>` : ''}
              ${(sk.effects || []).map(ef => `<span class="badge b-unique">${esc(ef)}</span>`).join('')}
            </div>
            <div style="display:flex;gap:6px;flex-wrap:wrap">
              <button type="button" class="wx-sh-btn" data-msh-ctrl="replay">↺ 重放</button>
              <button type="button" class="wx-sh-btn" data-msh-ctrl="slow" aria-pressed="${shState.modalSpeed < 0.8}">🐢 0.45x 慢放</button>
              <button type="button" class="wx-sh-btn" data-sh-goto="${esc(c.id)}">在主演武台打开 →</button>
            </div>
            <div style="font-size:11px;color:#bda78e">游戏内实装特效：<code>${esc(sk.vfx || '')}</code> + <code>${esc(sk.fx || '')}</code></div>
          </div>
        </div>
      </div>`;
  }
// === WX_SHANHAI_THEATER_JS_END ===
"""


def patch_html(html: str, bundle: dict) -> str:
    # 1. Replace wx-bundle JSON
    bundle_json = json.dumps(bundle, ensure_ascii=False, separators=(",", ":"))
    m = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    assert m, "Could not locate wx-bundle script tag"
    html = html[: m.start(2)] + bundle_json + html[m.end(2) :]

    # 2. Inject/Replace CSS right after WX_SKILL_VFX_CSS_END
    html = re.sub(
        re.escape(CSS_START) + r".*?" + re.escape(CSS_END),
        "",
        html,
        flags=re.S,
    )
    css_anchor = "/* === WX_SKILL_VFX_CSS_END === */"
    assert css_anchor in html, "Could not locate WX_SKILL_VFX_CSS_END"
    html = html.replace(css_anchor, css_anchor + "\n" + SHANHAI_CSS.strip(), 1)

    # 3. Inject/Replace JS right after WX_SKILL_VFX_JS_END
    html = re.sub(
        re.escape(JS_START) + r".*?" + re.escape(JS_END),
        "",
        html,
        flags=re.S,
    )
    js_anchor = "// === WX_SKILL_VFX_JS_END ==="
    assert js_anchor in html, "Could not locate WX_SKILL_VFX_JS_END"
    html = html.replace(js_anchor, js_anchor + "\n" + SHANHAI_JS.strip(), 1)

    # 4. Fix cardCreature `st.matk` -> `st.mSkill || st.matk || '?'`
    html = html.replace(
        "武艺 <strong>${st.matk || '?'}</strong>",
        "武艺 <strong>${st.mSkill || st.matk || '?'}</strong>",
    )

    # 5. Mount ShanHai Theater in renderWikiView() alongside showSkillTheater (100% idempotent)
    old_mount_pat = re.compile(
        r"const showSkillTheater = \(state\.wikiTab === 'skills' && \(state\.subTab \|\| 'actives'\) === 'actives'\);[\s\S]*?(?=\r?\n\s*\}\r?\n\r?\n\s*function renderGlobalSearchResults)",
    )
    new_mount = """const showSkillTheater = (state.wikiTab === 'skills' && (state.subTab || 'actives') === 'actives');
    const showShanHaiTheater = (state.wikiTab === 'bestiary');
    if (!showSkillTheater) stopStageVfx();
    if (!showShanHaiTheater) stopShanHaiStage();
    const theaterMount = showSkillTheater
      ? `<section class="wx-vfx-theater" id="wx-vfx-theater-root">${renderSkillTheaterInner(list)}</section>`
      : (showShanHaiTheater
        ? `<section class="wx-sh-theater" id="wx-sh-theater-root">${renderShanHaiTheaterInner(list)}</section>`
        : '');

    if (!slice.length) {
      contentSlot.innerHTML = `${theaterMount}<div class="empty-box">当前分卷筛选条件下未找到匹配项。${q && allHits > 0 ? '可点击上方「全书跨卷检索」查看其他分卷中的结果。' : ''}</div>`;
      if (showSkillTheater && !vfxState.collapsed) {
        const curSk = skillById.get(vfxState.skillId);
        if (curSk) requestAnimationFrame(() => startSkillVfxCanvas('wx-vfx-stage-canvas', curSk, false));
      }
      if (showShanHaiTheater && !shState.collapsed) {
        const curCr = creatureById.get(shState.creatureId);
        if (curCr) requestAnimationFrame(() => startShanHaiCanvas('wx-sh-stage-canvas', curCr, shState.skillIdx, false));
      }
      return;
    }

    contentSlot.innerHTML = `
      ${theaterMount}
      <div class="card-grid">${slice.map(renderCard).join('')}</div>
      ${totalPages > 1 ? `
        <div class="pager">
          <button type="button" data-page="${state.page - 1}" ${state.page <= 1 ? 'disabled' : ''}>← 上一页</button>
          <span>第 ${state.page} / ${totalPages} 页</span>
          <button type="button" data-page="${state.page + 1}" ${state.page >= totalPages ? 'disabled' : ''}>下一页 →</button>
        </div>` : ''}`;
    if (showSkillTheater && !vfxState.collapsed) {
      const curSk = skillById.get(vfxState.skillId);
      if (curSk) requestAnimationFrame(() => startSkillVfxCanvas('wx-vfx-stage-canvas', curSk, false));
    }
    if (showShanHaiTheater && !shState.collapsed) {
      const curCr = creatureById.get(shState.creatureId);
      if (curCr) requestAnimationFrame(() => startShanHaiCanvas('wx-sh-stage-canvas', curCr, shState.skillIdx, false));
    }"""
    assert old_mount_pat.search(html), "Could not locate showSkillTheater mount block in renderWikiView()"
    html = old_mount_pat.sub(lambda _: new_mount, html, count=1)

    # 6. Stop ShanHai stage on Global Search
    if "stopStageVfx();\n    stopShanHaiStage();" not in html:
        html = html.replace("stopStageVfx();", "stopStageVfx();\n    stopShanHaiStage();", 1)

    # 7. Stop ShanHai modal RAF on modal close
    if "modal.addEventListener('close', stopShanHaiModal);" not in html:
        html = html.replace(
            "modal.addEventListener('close', stopModalVfx);",
            "modal.addEventListener('close', stopModalVfx);\n  modal.addEventListener('close', stopShanHaiModal);",
            1,
        )

    # 8. Replace `else if (kind === 'creature')` modal block with live 60fps theater + fixed stat keys + clickable companions
    creature_modal_pat = re.compile(
        r"else if \(kind === 'creature'\) \{[\s\S]*?\n    \}\s*\n    else if \(kind === 'sect'\)",
    )
    new_creature_modal = """else if (kind === 'creature') {
      const c = creatureById.get(id);
      if (!c) return;
      shState.modalCreatureId = c.id;
      shState.modalSkillIdx = 0;
      const st = c.stats || {};
      const mSk = st.mSkill != null ? st.mSkill : (st.matk || 0);
      const rSk = st.rSkill != null ? st.rSkill : (st.ratk || 0);
      const mDf = st.mDef != null ? st.mDef : (st.mdef || 0);
      const rDf = st.rDef != null ? st.rDef : (st.rdef || 0);
      const fat = st.fatigue != null ? st.fatigue : (st.fat || 120);
      const frc = st.fatRec != null ? st.fatRec : (st.frec || 15);
      const res = st.resolve != null ? st.resolve : (st.res || 0);
      setHead(c.name, `<span class="badge b-unique">${esc(c.rank)}</span> <span class="badge">《${esc(c.chapter)}》</span>`, c.icon, '妖');
      bodyEl.innerHTML = `
        ${renderModalCreatureTheaterHtml(c)}
        ${c.classicQuote ? `<blockquote class="quote-block">${esc(c.classicQuote)}</blockquote>` : ''}
        <div class="tier-box t3">
          <strong>天生神通 · 【${esc(c.traitName)}】</strong>
          <div style="margin-top:4px">${esc(c.traitDesc)}</div>
        </div>
        ${c.counterplay ? `<div class="tier-box"><strong>讨伐克制对策：</strong>${esc(c.counterplay)}</div>` : ''}
        <div class="kv-grid">
          <div class="kv-cell"><small>气血 / 头身护甲</small><strong>${st.hp || '?'} 气血 · 头 ${st.headArmor || 0} / 身 ${st.bodyArmor || 0}</strong></div>
          <div class="kv-cell"><small>行动点 / 内息回气</small><strong>${st.ap || 9} AP · 内息 ${fat} (回${frc})</strong></div>
          <div class="kv-cell"><small>武艺 / 射艺</small><strong>武艺 ${mSk} · 射艺 ${rSk}</strong></div>
          <div class="kv-cell"><small>招架 / 避暗 / 身法 / 定力</small><strong>防 ${mDf}/${rDf} · 身 ${st.init || 0} · 定 ${res}</strong></div>
        </div>
        ${c.immunities && c.immunities.length ? `<p><strong>抗性与免疫：</strong>${c.immunities.map(im => `<span class="badge" style="margin-right:5px">${esc(im)}</span>`).join('')}</p>` : ''}
        <div class="modal-sec">
          <h3>专属凶兽招式 (${c.skills.length}) — 点击可切换上方 60fps 动作演示</h3>
          ${c.skills.map((s, si) => `
            <div class="tier-box">
              <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap">
                <strong>${esc(s.name)}</strong>
                <span class="badge b-dark">${s.ap} AP · ${s.qi} 内息</span>
                <span class="badge">${esc(s.range)}</span>
                ${s.dmg ? `<span class="badge b-gold">${esc(s.dmg)}</span>` : ''}
                ${s.animLabel ? `<span class="badge b-sect">${esc(s.animLabel)}</span>` : ''}
                <button type="button" class="wx-sh-sk-card-act" data-msh-sk="${si}" aria-pressed="${si === 0}">▶ 演示此招</button>
              </div>
              <div style="margin-top:4px">${esc(s.desc)}</div>
            </div>`).join('')}
        </div>
        ${(c.core || (c.companions && c.companions.length)) ? `
          <div class="modal-sec">
            <h3>秘境战利与伴生兽群</h3>
            ${c.core && c.core.id ? `<div class="link-pills"><button type="button" class="link-pill" data-open="core:${esc(c.core.id)}">必掉内丹：${esc(c.core.name)} →</button>${c.core.bonusMat ? `<span class="badge b-gold">必掉奇材：${esc(c.core.bonusMat)}</span>` : ''}</div>` : ''}
            ${c.companions && c.companions.length ? `<div class="link-pills" style="margin-top:8px"><strong style="margin-right:6px">秘境同阵护卫：</strong>${c.companions.map(cid => {
              const cc = creatureById.get(cid);
              return cc ? `<button type="button" class="link-pill" data-open="creature:${esc(cc.id)}">${esc(cc.shortName || cc.name)} →</button>` : `<span class="badge">${esc(cid)}</span>`;
            }).join('')}</div>` : ''}
          </div>` : ''}`;
      requestAnimationFrame(() => startShanHaiCanvas('wx-modal-sh-canvas', c, 0, true));
    }
    else if (kind === 'sect')"""
    assert creature_modal_pat.search(html), "Could not locate `else if (kind === 'creature')` in openModal()"
    html = creature_modal_pat.sub(lambda _: new_creature_modal, html, count=1)

    # 9. Add click event delegation for ShanHai theater & modal controls
    html = re.sub(
        r"\n    " + re.escape(EVT_START) + r".*?" + re.escape(EVT_END) + r"\n",
        "\n",
        html,
        flags=re.S,
    )
    sh_events = f"""
    {EVT_START}
    const shToggle = e.target.closest('[data-sh-toggle]');
    if (shToggle) {{
      shState.collapsed = !shState.collapsed;
      refreshShanHaiTheaterDom();
      return;
    }}
    const shCatBtn = e.target.closest('[data-sh-cat]');
    if (shCatBtn) {{
      shState.cat = shCatBtn.dataset.shCat;
      shState.skillIdx = 0;
      refreshShanHaiTheaterDom();
      return;
    }}
    const shPickBtn = e.target.closest('[data-sh-pick]');
    if (shPickBtn) {{
      shState.creatureId = shPickBtn.dataset.shPick;
      shState.skillIdx = 0;
      refreshShanHaiTheaterDom();
      return;
    }}
    const shSkBtn = e.target.closest('[data-sh-sk]');
    if (shSkBtn) {{
      shState.skillIdx = Number(shSkBtn.dataset.shSk) || 0;
      refreshShanHaiTheaterDom();
      return;
    }}
    const shCtrlBtn = e.target.closest('[data-sh-ctrl]');
    if (shCtrlBtn) {{
      const act = shCtrlBtn.dataset.shCtrl;
      if (act === 'slow') shState.speed = shState.speed < 0.8 ? 1.0 : 0.45;
      refreshShanHaiTheaterDom();
      return;
    }}
    const mshSkBtn = e.target.closest('[data-msh-sk]');
    if (mshSkBtn) {{
      const box = document.getElementById('wx-modal-sh-box');
      const cr = box ? creatureById.get(box.dataset.creatureId) : null;
      if (cr) {{
        shState.modalCreatureId = cr.id;
        shState.modalSkillIdx = Number(mshSkBtn.dataset.mshSk) || 0;
        box.outerHTML = renderModalCreatureTheaterHtml(cr);
        document.querySelectorAll('.wx-sh-sk-card-act[data-msh-sk]').forEach(btn => {{
          btn.setAttribute('aria-pressed', String(Number(btn.dataset.mshSk) === shState.modalSkillIdx));
        }});
        requestAnimationFrame(() => startShanHaiCanvas('wx-modal-sh-canvas', cr, shState.modalSkillIdx, true));
      }}
      return;
    }}
    const mshCtrlBtn = e.target.closest('[data-msh-ctrl]');
    if (mshCtrlBtn) {{
      const box = document.getElementById('wx-modal-sh-box');
      const cr = box ? creatureById.get(box.dataset.creatureId) : null;
      if (cr) {{
        const act = mshCtrlBtn.dataset.mshCtrl;
        if (act === 'slow') shState.modalSpeed = shState.modalSpeed < 0.8 ? 1.0 : 0.45;
        box.outerHTML = renderModalCreatureTheaterHtml(cr);
        requestAnimationFrame(() => startShanHaiCanvas('wx-modal-sh-canvas', cr, shState.modalSkillIdx, true));
      }}
      return;
    }}
    const shGotoBtn = e.target.closest('[data-sh-goto]');
    if (shGotoBtn) {{
      const targetId = shGotoBtn.dataset.shGoto;
      modal.close();
      state.mode = 'wiki';
      state.wikiTab = 'bestiary';
      state.subTab = '';
      shState.collapsed = false;
      shState.cat = 'all';
      shState.creatureId = targetId;
      shState.skillIdx = 0;
      render();
      requestAnimationFrame(() => {{
        const activeBtn = document.querySelector('#wx-sh-roster-list [aria-pressed="true"]');
        if (activeBtn) activeBtn.scrollIntoView({{ block: 'center' }});
        window.scrollTo({{ top: 120, behavior: 'smooth' }});
      }});
      return;
    }}
    {EVT_END}
"""
    evt_anchor = "// --- WX_VFX_EVENTS_END ---"
    assert evt_anchor in html, "Could not locate WX_VFX_EVENTS_END"
    html = html.replace(evt_anchor, evt_anchor + sh_events, 1)

    return html


def main():
    html = WIKI_PATH.read_text(encoding="utf-8")
    m = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    assert m, "Could not locate wx-bundle in 山海武侠.html"
    bundle = json.loads(m.group(2))

    packed = enrich_bestiary_and_pack_busts(bundle)
    bundle["bestiaryAssets"] = {"busts": packed["busts"]}

    out_html = patch_html(html, bundle)
    WIKI_PATH.write_text(out_html, encoding="utf-8")

    size_mb = WIKI_PATH.stat().st_size / (1024 * 1024)
    print(
        f"Injected Shan Hai 60fps Action Theater into {WIKI_PATH.name}: "
        f"{len(packed['busts'])} creature busts, {packed['enrichedSkills']} enriched monster skills -> {size_mb:.2f} MiB"
    )


if __name__ == "__main__":
    main()
