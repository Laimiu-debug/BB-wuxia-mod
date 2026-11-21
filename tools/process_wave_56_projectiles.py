#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Processes Sheet 56: 16 Standalone Wuxia Flying Projectiles & Trajectory Sprites (`wx_projectiles_0.brush`).
Uses Two-Zone Exact Un-Premultiplied VFX Alpha Matting:
  - Zone 1 (Solid Weapon Core enclosed by dark ink outlines / hot saturated core): 100% crisp opaque alpha
  - Zone 2 (Border-connected outer motion-blur, wind wakes, emerald plumes & smoke fringes):
    Exact un-premultiplication from `#FFFFFF` so translucent wakes & glows blend seamlessly over dark battlefields!
"""

from collections import deque
import json
import math
import os
import shutil
import sys
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import build_wuxia_bust_system as bsys
from compile_wuxia_brushes import compile_all
from sync_art_to_mod import refresh_wiki_embedded_manifest

ART_DIR = os.path.join(ROOT, "art")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
PROJ_DIR = os.path.join(ART_DIR, "projectiles")
BRAIN_DIR = r"C:\Users\25647\.gemini\antigravity\brain\08580b6e-5dd3-4db1-9cac-7ea146bea6cf"
RAW_SHEET_56 = os.path.join(BRAIN_DIR, "wuxia_projectiles_4x4_sheet_fixed_1795186826538.jpg")

# `(row, col, id, cn_name, sub, (w, h), vanilla_fallback, allow_holes, brief)`
PROJECTILE_DEFS = [
    # Row 0: Core 5 Requested Projectiles (飞蝗石、柳叶飞刀、孔雀翎、神机火铳弹丸)
    (0, 0, "wx_proj_feihuangshi",  "飞蝗铁胆石",      "暗器投石 · 走镖飞蝗鹅卵石袋",    (56, 80),  "projectile_07", False, "棱角分明的生铁鹅卵飞蝗石破空急坠，前端激起灰白半月气浪，尾后拖曳劲急破风残影。"),
    (0, 1, "wx_proj_liuyefeidao",  "寒星柳叶飞刀",    "名门飞刀 · 百炼寒星柳叶飞刀",    (42, 96),  "projectile_02", True,  "薄刃修长的寒星陨铁柳叶飞刀直指敌喉，刀环红穗猎猎飞扬，锋尖划破银青寒芒气流。"),
    (0, 2, "wx_proj_kongqueling",  "唐门孔雀翎",      "绝世机括 · 七曜金翠孔雀翎针",    (64, 96),  "projectile_01", False, "蜀中唐家堡至高机括暗器，七枚金铜翎针簇拥孔雀蓝翠流光齐射而出，绚烂夺命。"),
    (0, 3, "wx_proj_huochongdan",  "神机火铳赤焰弹丸","神机火器 · 三眼铳与五雷连铳",    (60, 98),  "projectile_08", False, "明军神机营赤红灼热铅铁弹丸破膛轰出，裹挟刺目赤金膛火、飞溅火星与滚滚黑硝烟尾迹。"),

    # Row 1: 袖箭飞行轨迹 + 重弩与名弓箭矢
    (1, 0, "wx_proj_xiujian",      "机簧玄铁袖箭",    "隐杀机括 · 袖箭与诸葛连珠弩",    (44, 84),  "projectile_01", False, "短小精悍的乌钢三棱破甲袖箭，黄铜尾翼激起凌厉青白螺旋破风轨迹，十步暗算防不胜防。"),
    (1, 1, "wx_proj_shenjishi",    "神臂破甲重弩矢",  "军镇劲弩 · 踏张铁弩与克敌神臂",  (48, 92),  "projectile_01", False, "乌钢四棱重型透甲弩矢贯破白色音障气环，精铁尾翼稳如泰山，专穿百炼重铠护心镜。"),
    (1, 2, "wx_proj_diaolingjian", "边关雕翎铁胎箭",  "塞外强弓 · 桑木猎弓与铁胎战弓",  (38, 90),  "projectile_01", False, "三棱百炼透甲钢镞配朱丝缠杆与苍鹰斑斓雕翎，裹挟破风气浪疾射百步。"),
    (1, 3, "wx_proj_liuxingjian",  "震天金翎追月箭",  "神射绝学 · 震天神弓与流星追月",  (50, 98),  "projectile_01", False, "金星璀璨的破甲神箭连破两重鎏金破音风环，尾后拖曳炽盛金凰流火羽芒。"),

    # Row 2: 五毒吹箭、唐门丧门钉、暴雨梨花针、破盾短梭
    (2, 0, "wx_proj_chuijian",     "五毒乌竹吹箭毒针","南疆奇门 · 密林吹箭与毒矢短弓",  (36, 86),  "projectile_01", False, "细长无声的焦黑乌竹吹箭，针尖凝结幽森碧磷剧毒，黑绒尾端飘散诡异绿瘴毒烟。"),
    (2, 1, "wx_proj_sangmending",  "五毒倒刺丧门钉",  "阴毒暗器 · 五毒丧门钉与毒蒺藜",  (48, 90),  "projectile_01", False, "生满狰狞倒刺的黑铁丧门毒钉破空攒刺，周身缭绕紫绿交织的蚀骨尸毒瘴气。"),
    (2, 2, "wx_proj_lihuazhen",    "暴雨梨花千枚银针","唐门绝学 · 暴雨暗器谱杀招",      (62, 94),  "projectile_01", True,  "七枚细若牛毛的寒芒银针呈雁阵密集攒射，针尾拖出冰银微紫的破空流光。"),
    (2, 3, "wx_proj_touzhisuo",    "破盾透甲投掷短梭","重型投矛 · 破盾透甲投掷短梭",    (44, 102), "projectile_02", False, "四棱倒刺精钢重型破盾短标梭，缠绳铁杆沉猛绝伦，挟撕裂空气的白浪轰向坚盾。"),

    # Row 3: 绿林旋风铁镖、甩手金钱梭镖、缠丝飞石索、蜀中霹雳雷火弹
    (3, 0, "wx_proj_xuanfengbiao", "绿林旋风十字铁镖","江湖飞镖 · 绿林旋风飞蝗铁镖",    (72, 72),  "projectile_04", True,  "四刃弯钩乌钢铁镖于半空极速回旋，带起三百六十度银白割裂刀风残影。"),
    (3, 1, "wx_proj_jinqianbiao",  "走镖甩手金钱梭镖","镖局绝活 · 甩手金钱镖谱",        (64, 86),  "projectile_01", True,  "外圆内方开刃打磨的古铜金钱镖前后叠影疾飞，带起道道金铜破风锐芒。"),
    (3, 2, "wx_proj_feishisuo",    "南疆绊马缠丝飞石索","奇门困敌 · 南疆绊马缠丝飞石索",(74, 74),  "projectile_03", True,  "浸油韧牛筋系三枚青铜棱球高速盘旋呼啸，专缠敌军双腿与坐骑马蹄。"),
    (3, 3, "wx_proj_pilileihuo",   "蜀中霹雳雷火弹",  "火器秘宝 · 霹雳雷火弹与奇门烟弹",(74, 74),  "projectile_08", False, "浑身铁刺的生铁雷火弹引信爆亮赤金火星，拖曳滚滚浓黑硫磺硝烟呼啸砸落。"),
]


def extract_projectile_vfx(cell_img: Image.Image, allow_holes: bool) -> Image.Image:
    """
    Two-zone alpha extraction tailored for projectiles with glowing wakes, wind streaks & smoke trails:
      1. Flood-fill from borders through any pixel that isn't a solid dark outline / saturated core
         (`min(r,g,b) > 105`), marking the outer translucent glow/wake/background region (`ext = 1`).
      2. Inside enclosed solid weapon bodies (`ext == 0`), keep 100% crisp opaque RGB (unless `allow_holes`
         punches true pure-white geometric holes like coin square holes or ring pommels).
      3. In `ext == 1` (outer aura, motion-blur streaks, smoke edges & white background), recover exact
         un-premultiplied color & smooth alpha from `#FFFFFF` so wakes look natural on dark battlefields!
    """
    rgb = cell_img.convert("RGB")
    cw, ch = rgb.size
    px = rgb.load()

    def is_solid_barrier(r, g, b):
        mn = min(r, g, b)
        mx = max(r, g, b)
        # Dark ink/iron/wood outlines OR deeply saturated crimson/fire/emerald cores block outer flood
        if mn <= 98:
            return True
        if (mx - mn) >= 115 and mn <= 150:
            return True
        return False

    ext = bytearray(cw * ch)
    q = deque()
    for x in range(cw):
        for sy in (0, ch - 1):
            r, g, b = px[x, sy]
            if not is_solid_barrier(r, g, b):
                ext[sy * cw + x] = 1
                q.append((x, sy))
    for y in range(ch):
        for sx in (0, cw - 1):
            idx = y * cw + sx
            if not ext[idx]:
                r, g, b = px[sx, y]
                if not is_solid_barrier(r, g, b):
                    ext[idx] = 1
                    q.append((sx, y))

    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < cw and 0 <= ny < ch:
                nidx = ny * cw + nx
                if not ext[nidx]:
                    r, g, b = px[nx, ny]
                    if not is_solid_barrier(r, g, b):
                        ext[nidx] = 1
                        q.append((nx, ny))

    out = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    opx = out.load()

    for y in range(ch):
        row = y * cw
        for x in range(cw):
            r, g, b = px[x, y]
            if not ext[row + x]:
                opx[x, y] = (r, g, b, 255)
            else:
                mn = min(r, g, b)
                mx = max(r, g, b)
                # Pure white background (`mn >= 246` and neutral) -> alpha 0
                raw_a = (250.0 - mn) / 165.0
                # Boost colored glows (peacock emerald, golden trails, green poison wisps, orange fire)
                chroma = (mx - mn) / 255.0
                a_f = max(0.0, min(1.0, raw_a + chroma * 0.45))
                if a_f <= 0.03:
                    opx[x, y] = (0, 0, 0, 0)
                else:
                    # Un-premultiply white (`I = a*C + (1-a)*255`) so pale halos become pure colored/smoke alpha!
                    denom = max(0.18, a_f)
                    ur = int(round(max(0.0, min(255.0, (r - (1.0 - a_f) * 255.0) / denom))))
                    ug = int(round(max(0.0, min(255.0, (g - (1.0 - a_f) * 255.0) / denom))))
                    ub = int(round(max(0.0, min(255.0, (b - (1.0 - a_f) * 255.0) / denom))))
                    opx[x, y] = (ur, ug, ub, int(round(a_f * 255.0)))

    # Optional: punch clean geometric interior holes (square coin holes, shuriken center ring, bola center)
    if allow_holes:
        hvis = bytearray(cw * ch)
        for y in range(2, ch - 2):
            for x in range(2, cw - 2):
                idx = y * cw + x
                if not ext[idx] and not hvis[idx]:
                    r0, g0, b0 = px[x, y]
                    if min(r0, g0, b0) >= 242 and (max(r0, g0, b0) - min(r0, g0, b0)) <= 10:
                        hvis[idx] = 1
                        hq = deque([(x, y)])
                        pts = [(x, y)]
                        while hq:
                            hx, hy = hq.popleft()
                            for nx, ny in ((hx - 1, hy), (hx + 1, hy), (hx, hy - 1), (hx, hy + 1)):
                                if 0 <= nx < cw and 0 <= ny < ch:
                                    nidx = ny * cw + nx
                                    if not ext[nidx] and not hvis[nidx]:
                                        nr, ng, nb = px[nx, ny]
                                        if min(nr, ng, nb) >= 226 and (max(nr, ng, nb) - min(nr, ng, nb)) <= 14:
                                            hvis[nidx] = 1
                                            hq.append((nx, ny))
                                            pts.append((nx, ny))
                        # Only punch genuine geometric holes (size >= 18 pixels) surrounded by dark ink
                        if len(pts) >= 18:
                            for px_x, px_y in pts:
                                opx[px_x, px_y] = (0, 0, 0, 0)

    # Smoothly taper alpha near outer cell borders (22px margin) so smoke tails dissolve with zero flat cutoffs
    margin = 24
    for y in range(ch):
        dy = min(y, ch - 1 - y)
        fy = 1.0 if dy >= margin else 0.5 * (1.0 - math.cos(math.pi * dy / float(margin)))
        for x in range(cw):
            dx = min(x, cw - 1 - x)
            if dy >= margin and dx >= margin:
                continue
            fx = 1.0 if dx >= margin else 0.5 * (1.0 - math.cos(math.pi * dx / float(margin)))
            r, g, b, a = opx[x, y]
            if a > 0:
                opx[x, y] = (r, g, b, int(round(a * min(fx, fy))))

    return out


def fit_box(rgba: Image.Image, w: int, h: int, pad: int = 8) -> Image.Image:
    bbox = rgba.getchannel("A").point(lambda a: 255 if a > 10 else 0).getbbox()
    tc = rgba.crop(bbox) if bbox else rgba
    mw, mh = max(1, w - 2 * pad), max(1, h - 2 * pad)
    s = min(mw / float(tc.width), mh / float(tc.height))
    nw, nh = max(1, int(round(tc.width * s))), max(1, int(round(tc.height * s)))
    im = tc.resize((nw, nh), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.alpha_composite(im, ((w - nw) // 2, (h - nh) // 2))
    return out


def main():
    os.makedirs(SHEETS_DIR, exist_ok=True)
    os.makedirs(PROJ_DIR, exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, "hd"), exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, "game", "effects"), exist_ok=True)

    dst_sheet = os.path.join(SHEETS_DIR, "sheet_56.jpg")
    if os.path.exists(RAW_SHEET_56):
        shutil.copy2(RAW_SHEET_56, dst_sheet)
    if not os.path.exists(dst_sheet):
        raise FileNotFoundError(f"Missing {dst_sheet}")

    sh = Image.open(dst_sheet)
    cw, ch = sh.width // 4, sh.height // 4

    new_manifest_assets = []
    qa_board = Image.new("RGBA", (1024, 1024), (36, 33, 28, 255))
    qd = ImageDraw.Draw(qa_board)

    for (r, c, pid, name_cn, sub_cn, (gw, gh), fallback, allow_holes, brief_cn) in PROJECTILE_DEFS:
        cell = sh.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
        rgba = extract_projectile_vfx(cell, allow_holes=allow_holes)

        hd_im = fit_box(rgba, 256, 256, pad=10)
        prev_im = fit_box(rgba, 128, 128, pad=6)

        proj_p = os.path.join(PROJ_DIR, f"{pid}.png")
        hd_rel = f"art/hd/{pid}.png"
        prev_rel = f"art/game/effects/{pid}.png"

        hd_im.save(proj_p)
        hd_im.save(os.path.join(ROOT, hd_rel))
        prev_im.save(os.path.join(ROOT, prev_rel))

        # Paste onto dark tactical QA board (upright on left + simulated 60° diagonal flight on right)
        qx, qy = c * 256, r * 256
        qd.rectangle([qx + 2, qy + 2, qx + 253, qy + 253], outline=(78, 70, 56, 255), width=1)
        up_prev = fit_box(rgba, 118, 184, pad=4)
        qa_board.alpha_composite(up_prev, (qx + 10, qy + 34))
        rot_im = fit_box(rgba, gw * 2, gh * 2, pad=4).rotate(-58, resample=Image.Resampling.BICUBIC, expand=True)
        rot_fit = fit_box(rot_im, 118, 118, pad=2)
        qa_board.alpha_composite(rot_fit, (qx + 130, qy + 68))

        new_manifest_assets.append({
            "id": pid,
            "stage": "5_vfx",
            "group": "飞行投射物独立贴图（16款 · wx_projectiles_0.brush）",
            "name": name_cn,
            "sub": sub_cn,
            "spec": f"{gw}×{gh} 飞行投射物独立贴图 (wx_projectiles_0.brush)",
            "slotKind": "boss",
            "status": "in_game",
            "hdPath": hd_rel,
            "previewPath": prev_rel,
            "swPath": "",
            "smallPath": "",
            "gameTarget": f"brushes/wx_projectiles_0.brush#{pid}",
            "vanillaFallback": fallback,
            "codeRef": "mod_wuxia/systems/wx_projectile_system.nut",
            "brief": brief_cn,
        })

    qa_out = os.path.join(BRAIN_DIR, "scratch", "qa_wx_projectiles_16.png")
    os.makedirs(os.path.dirname(qa_out), exist_ok=True)
    qa_board.convert("RGB").save(qa_out, quality=95)

    manifest_path = os.path.join(ART_DIR, "manifest.json")
    manifest = json.load(open(manifest_path, "r", encoding="utf-8"))
    new_ids = {a["id"] for a in new_manifest_assets}
    kept = [a for a in manifest["assets"] if a["id"] not in new_ids]
    kept.extend(new_manifest_assets)

    for st in manifest["stages"]:
        if st["id"] == "5_vfx":
            st["desc"] = "32款刀剑气芒/拳掌内劲/护体金钟特效、16套64帧连续演武序列帧 + 16款飞行投射物独立贴图（飞蝗石/柳叶飞刀/孔雀翎/火铳弹丸/袖箭等）"

    total_pngs = sum(len(files) for _, _, files in os.walk(ART_DIR) if any(f.endswith(".png") for f in files))
    manifest["version"] = "0.9.1-standalone-projectiles-835"
    manifest["assets"] = kept
    manifest["summary"]["total"] = len(kept)
    manifest["summary"]["in_game"] = sum(1 for x in kept if x["status"] == "in_game")
    manifest["summary"]["wiki_ready"] = sum(1 for x in kept if x["status"] == "wiki_ready")
    manifest["summary"]["planned"] = sum(1 for x in kept if x["status"] == "planned")
    manifest["summary"]["png_files_generated"] = total_pngs

    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    refresh_wiki_embedded_manifest(manifest)
    compile_all()
    print(f"SUCCESS: Two-zone VFX alpha matting complete! {len(kept)} total assets, wx_projectiles_0.brush compiled.")


if __name__ == "__main__":
    main()
