#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
人物界面底图 v2：原版面板 + 放大的武侠雕像（只露半边身体，与原版骑士/骷髅同尺度）

- 面板：取自本机游戏 data_001.dat 中的原版 background_inventory.png（不入库，运行时读取）
- 雕像：art/sheets/wx_ui_guardian_statues.jpg（左：明甲将军；右：持戟盘龙武僧，镜像朝内）
- 整尊雕像按原版雕像尺度摆放，身体中线压在面板边缘：外侧半边身体露出，内侧半边藏在面板后
- 精细去白边抠图：自动清除披风/靴子/戟杆/盘龙间的封闭白底洞，并沿外侧墨线做黑墨反预乘去白光晕处理

用法：
  python tools/build_wx_character_bg_v2.py            # 输出到 docs/ui-preview/_vanilla/（预览用）
  python tools/build_wx_character_bg_v2.py --mod      # 同步写入 mod_wuxia/gfx/ui/wx_skin/wx_background_inventory.png
"""

from collections import deque
import os
import sys
import zipfile
from io import BytesIO

from PIL import Image, ImageEnhance, ImageFilter, ImageOps

TOOLS = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(TOOLS)

GAME = r"F:\SteamLibrary\steamapps\common\Battle Brothers"
SHEET = os.path.join(ROOT, "art", "sheets", "wx_ui_guardian_statues.jpg")
OUT_PREVIEW = os.path.join(ROOT, "docs", "ui-preview", "_vanilla", "wx_background_inventory_v2.png")
OUT_MOD = os.path.join(ROOT, "mod_wuxia", "gfx", "ui", "wx_skin", "wx_background_inventory.png")

W, H = 1421, 906
BOARD = (208, 124, 1252, 906)  # 原版面板实测外框（含压边）

# 雕像摆放：整尊雕像（头到底座）按原版尺度缩放，身体中线对齐面板边缘 → 外侧半边露出、内侧半边藏在面板后
#   scale：相对原图（512x1024 单侧）的倍率；axis：身体中线在原图中的 x；head：头顶在原图中的 y
#   at：中线在底图中的 x（= 面板左 / 右边缘）；top：头顶在底图中的 y
LEFT = {"scale": 0.93, "axis": 254, "head": 66, "at": 209, "top": 24, "mirror": False}
RIGHT = {"scale": 0.93, "axis": 278, "head": 115, "at": 1251, "top": 50, "mirror": True}


def load_vanilla_bg(game_root):
    dat = os.path.join(game_root, "data", "data_001.dat")
    with zipfile.ZipFile(dat) as z:
        return Image.open(BytesIO(z.read("gfx/ui/skin/background_inventory.png"))).convert("RGBA")


def clean_statue_cutout(im_rgb):
    """
    针对白底手绘黑墨线石雕（JPEG）的高精度去白边抠图：
    1. 连通域识别外围白底与所有内嵌封闭白底洞（如左将军披风与战靴间隙、右武僧戟杆与盘龙间隙）；
    2. 从透明白底向内最多 4px 追踪单调变暗的「白底 -> 黑墨线」抗锯齿过渡带（遇到深墨核即止，绝不伤内部高光）；
    3. 按黑墨线真实覆盖率重算收边 Alpha，并对过渡带像素做反白底退染与深墨色钳制，彻底消除暗底白边。
    """
    rgba = im_rgb.convert("RGBA")
    w, h = rgba.size
    px = rgba.load()

    lum = [0] * (w * h)
    chroma = [0] * (w * h)
    for y in range(h):
        row = y * w
        for x in range(w):
            r, g, b, _ = px[x, y]
            lum[row + x] = (299 * r + 587 * g + 114 * b) // 1000
            chroma[row + x] = max(r, g, b) - min(r, g, b)

    # 1. 连通域搜索外围白底 + 内嵌封闭纯白空洞
    visited = bytearray(w * h)
    bg = bytearray(w * h)
    for y in range(h):
        for x in range(w):
            idx0 = y * w + x
            if visited[idx0]:
                continue
            r0, g0, b0, _ = px[x, y]
            if min(r0, g0, b0) < 225 or chroma[idx0] > 18:
                continue
            q = deque([(x, y)])
            visited[idx0] = 1
            pts = []
            touches_border = False
            while q:
                cx, cy = q.popleft()
                cidx = cy * w + cx
                pts.append(cidx)
                if cx == 0 or cy == 0 or cx == w - 1 or cy == h - 1:
                    touches_border = True
                for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                    if 0 <= nx < w and 0 <= ny < h:
                        nidx = ny * w + nx
                        if not visited[nidx]:
                            nr, ng, nb, _ = px[nx, ny]
                            if min(nr, ng, nb) >= 210 and chroma[nidx] <= 22:
                                visited[nidx] = 1
                                q.append((nx, ny))
            if touches_border or len(pts) >= 10:
                for p_idx in pts:
                    bg[p_idx] = 1

    # 2. 从白底向内追踪 1..4px 的「白底 -> 黑墨线」外侧抗锯齿斜坡（ramp: 1=白底, 2..5=外侧过渡带）
    ramp = bytearray(bg)
    neighbors8 = ((-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1))
    for step in range(1, 5):
        prev_val = step
        next_val = step + 1
        to_mark = []
        for y in range(h):
            row = y * w
            for x in range(w):
                idx = row + x
                if ramp[idx] != 0:
                    continue
                max_nb_lum = -1
                for dx, dy in neighbors8:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        nidx = ny * w + nx
                        if ramp[nidx] == prev_val and lum[nidx] > max_nb_lum:
                            max_nb_lum = lum[nidx]
                if max_nb_lum < 0:
                    continue
                cur_l = lum[idx]
                if step == 1:
                    if cur_l > 40:
                        to_mark.append(idx)
                else:
                    if cur_l > 46 and cur_l <= max_nb_lum + 6 and chroma[idx] <= 34:
                        to_mark.append(idx)
        for idx in to_mark:
            ramp[idx] = next_val

    # 3. 计算干净收边的 Alpha 并彻底剥离白色背景混色
    for y in range(h):
        row = y * w
        for x in range(w):
            idx = row + x
            rv = ramp[idx]
            if rv == 1:
                px[x, y] = (0, 0, 0, 0)
            elif rv >= 2:
                cur_l = lum[idx]
                # L >= 192 完全裁掉外圈灰白毛刺；L <= 46 进入实心深色墨线核
                t = (192.0 - cur_l) / (192.0 - 46.0)
                if t <= 0.0:
                    px[x, y] = (0, 0, 0, 0)
                    continue
                if t > 1.0:
                    t = 1.0
                na = int(round((t ** 1.22) * 255.0))
                if na < 16:
                    px[x, y] = (0, 0, 0, 0)
                    continue
                r, g, b, _ = px[x, y]
                a_raw = max(0.08, min(1.0, (255.0 - cur_l) / (255.0 - 22.0)))
                cr = max(0, int((r - (1.0 - a_raw) * 255.0) / a_raw))
                cg = max(0, int((g - (1.0 - a_raw) * 255.0) / a_raw))
                cb = max(0, int((b - (1.0 - a_raw) * 255.0) / a_raw))
                # 外轮廓过渡带本身是焦墨勾线，钳制上限防止任何灰白像素透出
                px[x, y] = (min(cr, 32), min(cg, 28), min(cb, 24), na)

    return rgba


def grade(im):
    """调成原版石像的中灰褐：略降亮度与饱和，保留一点铜金。"""
    a = im.getchannel("A")
    rgb = im.convert("RGB")
    rgb = ImageEnhance.Color(rgb).enhance(0.72)
    rgb = ImageEnhance.Brightness(rgb).enhance(0.76)
    rgb = ImageEnhance.Contrast(rgb).enhance(1.02)
    out = rgb.convert("RGBA")
    out.putalpha(a)
    return out


def place(canvas, statue, cfg):
    s = cfg["scale"]
    im = statue.resize((int(statue.width * s), int(statue.height * s)), Image.Resampling.BICUBIC)
    # 二次保护：消除缩放插值在半透明边缘可能产生的微量亮色振铃
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                px[x, y] = (0, 0, 0, 0)
            elif a < 215 and (r > 32 or g > 28 or b > 24):
                px[x, y] = (min(r, 28), min(g, 24), min(b, 20), a)

    ax = cfg["axis"]
    if cfg["mirror"]:
        im = ImageOps.mirror(im)
        ax = statue.width - 1 - ax
    ox = int(cfg["at"] - ax * s)
    oy = int(cfg["top"] - cfg["head"] * s)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    layer.paste(im, (ox, oy), im)
    canvas.alpha_composite(layer)


def main():
    to_mod = "--mod" in sys.argv
    game = next((a for a in sys.argv[1:] if not a.startswith("--")), GAME)

    vanilla = load_vanilla_bg(game)
    board = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    board.paste(vanilla.crop(BOARD), BOARD[:2])

    sheet = Image.open(SHEET).convert("RGB")
    mid = sheet.width // 2
    left = grade(clean_statue_cutout(sheet.crop((0, 0, mid, sheet.height))))
    right = grade(clean_statue_cutout(sheet.crop((mid, 0, sheet.width, sheet.height))))

    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    place(canvas, left, LEFT)
    place(canvas, right, RIGHT)

    # 自上而下的暗角：原版雕像越往下越隐入黑暗
    fade = Image.new("L", (1, H), 0)
    for y in range(H):
        t = max(0.0, (y - 420) / float(H - 420))
        fade.putpixel((0, y), int(255 * 0.40 * t))
    fade = fade.resize((W, H))
    dark = Image.new("RGBA", (W, H), (8, 5, 3, 0))
    dark.putalpha(Image.composite(fade, Image.new("L", (W, H), 0), canvas.getchannel("A")))
    canvas.alpha_composite(dark)

    # 面板投在雕像上的阴影（原版也有，让雕像"退"到面板后面）
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sh_core = Image.new("RGBA", (BOARD[2] - BOARD[0] + 24, BOARD[3] - BOARD[1] + 24), (0, 0, 0, 170))
    shadow.paste(sh_core, (BOARD[0] - 12, BOARD[1] - 10))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    sa = shadow.getchannel("A")
    ca = canvas.getchannel("A")
    shadow.putalpha(Image.composite(sa, Image.new("L", (W, H), 0), ca))  # 阴影只落在雕像上
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(board)

    os.makedirs(os.path.dirname(OUT_PREVIEW), exist_ok=True)
    canvas.save(OUT_PREVIEW)
    print("预览底图:", OUT_PREVIEW)
    if to_mod:
        os.makedirs(os.path.dirname(OUT_MOD), exist_ok=True)
        canvas.save(OUT_MOD)
        print("mod 底图:", OUT_MOD)


if __name__ == "__main__":
    main()
