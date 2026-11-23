#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Synchronizes Shan-Hai Mythic Resonance Sets (`DB.equipmentSets`), per-item `setInfo` / `totemInfo`,
and the new `effects.wx_status_frost_chill` (`寒凝封穴`) combat status into `山海武侠.html`.
Reads directly from `mod_wuxia/mod_wuxia/config/wx_shanhai_sets.nut` as single source of truth!
"""

import base64
import io
import json
import re
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MOD_DIR = ROOT / "mod_wuxia"
WIKI_PATH = ROOT / "山海武侠.html"
SETS_NUT = MOD_DIR / "mod_wuxia/config/wx_shanhai_sets.nut"


def encode_webp_48(png_path: Path) -> str:
    im = Image.open(png_path).convert("RGBA").resize((48, 48), Image.Resampling.LANCZOS)
    buf = io.BytesIO()
    im.save(buf, format="WEBP", quality=92, method=6)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def parse_sets_nut(src: str):
    set_order = re.findall(r'"(wx_set_\w+)"', re.search(r"ShanHaiSetOrder\s*<-\s*\[(.*?)\]", src, re.S).group(1))
    totem_order = re.findall(r'"(\w+)"', re.search(r"ShanHaiTotemOrder\s*<-\s*\[(.*?)\]", src, re.S).group(1))

    sets_section = re.search(r"ShanHaiSets\s*<-\s*\{(.*?)\n\};\s*\n// 11 Same-Beast", src, re.S).group(1)
    totem_section = re.search(r"ShanHaiTotemPairs\s*<-\s*\{(.*?)\n\};\s*\n// Build fast", src, re.S).group(1)

    sets = {}
    sh_hdrs = list(re.finditer(r"(?<![A-Za-z0-9_])(wx_set_\w+)\s*=\s*\{", sets_section))
    for idx, m in enumerate(sh_hdrs):
        sid = m.group(1)
        body = sets_section[m.start(): sh_hdrs[idx + 1].start() if idx + 1 < len(sh_hdrs) else len(sets_section)]
        name = re.search(r'Name\s*=\s*"([^"]+)"', body).group(1)
        short = re.search(r'ShortName\s*=\s*"([^"]+)"', body).group(1)
        tier = re.search(r'Tier\s*=\s*"([^"]+)"', body).group(1)
        style_tag = re.search(r'StyleTag\s*=\s*"([^"]+)"', body).group(1)
        color = re.search(r'Color\s*=\s*"([^"]+)"', body).group(1)
        icon_rel = re.search(r'Icon\s*=\s*"([^"]+)"', body).group(1)
        lore = re.search(r'Lore\s*=\s*"([^"]+)"', body).group(1)
        pieces_raw = re.search(r"Pieces\s*=\s*\[(.*?)\]", body, re.S).group(1)
        pieces = re.findall(r'"([^"]+)"', pieces_raw)
        bonuses_raw = re.search(r"Bonuses\s*=\s*\[(.*?)\]\s*\n\t\}", body, re.S).group(1)
        bonuses = []
        for bm in re.finditer(r'Need\s*=\s*(\d+)\s*,\s*Title\s*=\s*"([^"]+)"\s*,\s*Text\s*=\s*"([^"]+)"', bonuses_raw):
            bonuses.append({"need": int(bm.group(1)), "title": bm.group(2), "text": bm.group(3)})
        sets[sid] = {
            "id": sid,
            "name": name,
            "shortName": short,
            "tier": tier,
            "styleTag": style_tag,
            "color": color,
            "iconRel": icon_rel,
            "lore": lore,
            "pieceIds": pieces,
            "bonuses": bonuses,
        }

    totems = {}
    tm_hdrs = list(re.finditer(r"\n\t([a-z0-9_]+)\s*=\s*\{", totem_section))
    for idx, m in enumerate(tm_hdrs):
        tid = m.group(1)
        body = totem_section[m.start(): tm_hdrs[idx + 1].start() if idx + 1 < len(tm_hdrs) else len(totem_section)]
        title = re.search(r'Title\s*=\s*"([^"]+)"', body).group(1)
        need = int(re.search(r"Need\s*=\s*(\d+)", body).group(1))
        pieces = re.findall(r'"([^"]+)"', re.search(r"Pieces\s*=\s*\[(.*?)\]", body, re.S).group(1))
        text = re.search(r'Text\s*=\s*"([^"]+)"', body).group(1)
        totems[tid] = {
            "id": tid,
            "title": title,
            "need": need,
            "pieceIds": pieces,
            "text": text,
        }

    return set_order, sets, totem_order, totems


def main():
    src = SETS_NUT.read_text(encoding="utf-8")
    set_order, sets, totem_order, totems = parse_sets_nut(src)

    html = WIKI_PATH.read_text(encoding="utf-8")
    m = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    assert m, "Could not find wx-bundle in 山海武侠.html"
    bundle = json.loads(m.group(2))
    icons = bundle["icons"]
    max_idx = max(int(k[1:]) for k in icons.keys() if k.startswith("i") and k[1:].isdigit())

    def alloc_icon(png_path: Path) -> str:
        nonlocal max_idx
        uri = encode_webp_48(png_path)
        for k, v in icons.items():
            if v == uri:
                return k
        max_idx += 1
        ik = f"i{max_idx}"
        icons[ik] = uri
        return ik

    eq_by_id = {eq["id"]: eq for eq in bundle["equipment"]}

    # Clear any old setInfo/totemInfo
    for eq in bundle["equipment"]:
        eq.pop("setInfo", None)
        eq.pop("totemInfo", None)

    totem_by_piece = {}
    for tid in totem_order:
        t = totems[tid]
        t["pieceNames"] = [eq_by_id[pid]["name"] for pid in t["pieceIds"] if pid in eq_by_id]
        for pid in t["pieceIds"]:
            totem_by_piece[pid] = {"id": tid, "title": t["title"], "text": t["text"]}

    out_sets = []
    mapped_pieces = 0
    for sid in set_order:
        sc = sets[sid]
        icon_file = MOD_DIR / "gfx" / sc["iconRel"]
        assert icon_file.exists(), f"Missing set icon {icon_file}"
        ik = alloc_icon(icon_file)

        piece_objs = []
        set_totem_ids = []
        for pid in sc["pieceIds"]:
            assert pid in eq_by_id, f"Set piece {pid} missing from DB.equipment!"
            eq = eq_by_id[pid]
            eq["setInfo"] = {"id": sid, "name": sc["name"], "shortName": sc["shortName"]}
            if pid in totem_by_piece:
                eq["totemInfo"] = totem_by_piece[pid]
                if totem_by_piece[pid]["id"] not in set_totem_ids:
                    set_totem_ids.append(totem_by_piece[pid]["id"])
            piece_objs.append({"id": pid, "name": eq["name"], "group": eq["group"]})
            mapped_pieces += 1

        out_sets.append({
            "id": sid,
            "name": sc["name"],
            "shortName": sc["shortName"],
            "tier": sc["tier"],
            "styleTag": sc["styleTag"],
            "color": sc["color"],
            "icon": ik,
            "lore": sc["lore"],
            "bonuses": sc["bonuses"],
            "pieces": piece_objs,
            "totems": [
                {"id": tid, "title": totems[tid]["title"], "text": totems[tid]["text"], "pieceNames": totems[tid]["pieceNames"]}
                for tid in set_totem_ids
            ],
        })

    bundle["equipmentSets"] = out_sets

    # Add `effects.wx_status_frost_chill` into DB.statuses if not yet present
    if not any(st["id"] == "effects.wx_status_frost_chill" for st in bundle["statuses"]):
        chill_icon = alloc_icon(MOD_DIR / "gfx/skills/wx_neigong_hanbing.png")
        bundle["statuses"].append({
            "id": "effects.wx_status_frost_chill",
            "name": "寒凝封穴",
            "desc": "【北溟寒渊套】3 件神通「弱水封穴」重击侵入奇经八脉的极寒弱水：受创者行动点 -2、身法 -25，持续 1 回合。",
            "effects": [
                "本回合最大可用行动点 -2（保底留 2 AP），提纵身法 -25。",
                "若穿戴【大荒金乌套】3 件（「十日焚邪」），每回合初可借大日阳炎自动驱散此状态。"
            ],
            "icon": chill_icon,
        })

    bundle["stats"]["statuses"] = len(bundle["statuses"])
    bundle["stats"]["equipmentSets"] = len(bundle["equipmentSets"])
    bundle["stats"]["icons"] = len(bundle["icons"])

    new_json = json.dumps(bundle, ensure_ascii=False, separators=(",", ":"))
    new_html = html[:m.start(2)] + new_json + html[m.end(2):]
    WIKI_PATH.write_text(new_html, encoding="utf-8")
    print(f"Synced {len(out_sets)} sets ({mapped_pieces} total pieces + {len(totems)} totem pairs) and {len(bundle['statuses'])} statuses into 山海武侠.html!")


if __name__ == "__main__":
    main()
