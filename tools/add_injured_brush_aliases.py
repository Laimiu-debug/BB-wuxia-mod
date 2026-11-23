#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Idempotently adds zero-VRAM `<brush>_injured` aliases to Wuxia `.brush` sheets
(`wx_busts_0.brush`, `wx_weapons_0.brush`, `wx_beasts_0.brush`) so Battle Brothers C++
`SceneManager` never logs `Unknown Brush requested: wx_*_injured` when injured characters
load from saves or fight in tactical battles.
"""

import os
import struct

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BRUSH_DIR = os.path.join(ROOT, "mod_wuxia", "brushes")
BRUSH_MAGIC = 0xBAADFAAD


def sdbm64(s: str) -> int:
    h = 0
    for ch in s:
        h = (h * 65599 + ord(ch)) & 0xFFFFFFFFFFFFFFFF
    return h


def parse_wuxia_brush(path: str):
    data = open(path, "rb").read()
    magic, ver, gfx_len = struct.unpack_from("<IHH", data, 0)
    assert magic == BRUSH_MAGIC, f"Invalid brush magic in {path}"
    pos = 8
    gfx_rel = data[pos : pos + gfx_len].decode("ascii")
    pos += gfx_len

    aw, ah = struct.unpack_from("<HH", data, pos)
    pos += 4
    flag12 = data[pos : pos + 12]
    pos += 12
    count, unk_h, unk_i = struct.unpack_from("<IHI", data, pos)
    pos += 10

    records = []
    for _ in range(count):
        rec_start = pos
        _hash, id_len = struct.unpack_from("<QH", data, pos)
        pos += 10
        sid = data[pos : pos + id_len].decode("ascii")
        pos += id_len
        # cat_hash(8) + w(4) + h(4) + ox(2) + oy(2) + mid_prefix25(25) + rgba(4) + scale4(4) = 53 bytes
        meta53 = data[pos : pos + 53]
        pos += 53
        frame_cnt, src_len = struct.unpack_from("<HH", data, pos)
        assert frame_cnt == 1, f"Expected single-frame sprite in {path} ({sid}), got {frame_cnt}"
        pos += 4
        tail_len = src_len + 32 + 3  # src_b + 8 floats (32B) + 3 pad bytes
        tail_bytes = data[pos : pos + tail_len]
        pos += tail_len
        records.append({
            "id": sid,
            "meta53": meta53,
            "src_len": src_len,
            "tail_bytes": tail_bytes,
        })

    assert pos == len(data), f"Unparsed trailing bytes in {path}: {pos} != {len(data)}"
    return {
        "ver": ver,
        "gfx_rel": gfx_rel,
        "aw": aw,
        "ah": ah,
        "flag12": flag12,
        "unk_h": unk_h,
        "unk_i": unk_i,
        "records": records,
    }


def save_wuxia_brush(path: str, parsed: dict):
    gfx_b = parsed["gfx_rel"].encode("ascii")
    recs = parsed["records"]
    buf = bytearray()
    buf += struct.pack("<IHH", BRUSH_MAGIC, parsed["ver"], len(gfx_b))
    buf += gfx_b
    buf += struct.pack("<HH", parsed["aw"], parsed["ah"])
    buf += parsed["flag12"]
    buf += struct.pack("<IHI", len(recs), parsed["unk_h"], parsed["unk_i"])
    for r in recs:
        sid_b = r["id"].encode("ascii")
        buf += struct.pack("<QH", sdbm64(r["id"]), len(sid_b))
        buf += sid_b
        buf += r["meta53"]
        buf += struct.pack("<HH", 1, r["src_len"])
        buf += r["tail_bytes"]
    with open(path, "wb") as f:
        f.write(buf)


def needs_injured_alias(sid: str) -> bool:
    if sid.endswith("_injured") or sid.endswith("_dead") or sid.endswith("_damaged"):
        return False
    prefixes = (
        "wx_body_",
        "wx_char_",
        "wx_armor_",
        "wx_sh_body_",
        "wx_beast_armor_",
        "wx_head_",
        "wx_enemy_",
        "wx_beast_",
        "wx_boss_",
        "wx_tail_",
    )
    return sid.startswith(prefixes)


def main():
    total_added = 0
    for fname in ["wx_busts_0.brush", "wx_weapons_0.brush", "wx_beasts_0.brush"]:
        fpath = os.path.join(BRUSH_DIR, fname)
        if not os.path.exists(fpath):
            continue
        parsed = parse_wuxia_brush(fpath)
        existing = {r["id"] for r in parsed["records"]}
        added = 0
        for r in list(parsed["records"]):
            sid = r["id"]
            if needs_injured_alias(sid):
                inj_id = sid + "_injured"
                if inj_id not in existing:
                    parsed["records"].append({
                        "id": inj_id,
                        "meta53": r["meta53"],
                        "src_len": r["src_len"],
                        "tail_bytes": r["tail_bytes"],
                    })
                    existing.add(inj_id)
                    added += 1
        if added > 0:
            save_wuxia_brush(fpath, parsed)
            total_added += added
        print(f"[{fname}] existing={len(parsed['records']) - added}, added_injured={added}, total={len(parsed['records'])}")
    print(f"Done. Total _injured brush aliases added: {total_added}")


if __name__ == "__main__":
    main()
