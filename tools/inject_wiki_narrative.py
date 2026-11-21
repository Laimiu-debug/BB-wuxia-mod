#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Idempotently parse all 500 independent Wuxia character biographies (72 backgrounds),
Chinese Wuxia name/title pools, and all 66 Wuxia event scripts from mod_wuxia/,
and inject two interactive views into 武侠百科.html:
  - #v=bios   「人物列传 (500)」
  - #v=events 「江湖事件 (66)」
Without touching a single byte of <script id="book-data"> or <script id="art-data">.
"""

import json
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MOD_DIR = ROOT / "mod_wuxia"
WIKI_PATH = ROOT / "山海武侠.html"

BG_CFG = MOD_DIR / "mod_wuxia" / "config" / "wx_backgrounds.nut"
NAMES_CFG = MOD_DIR / "mod_wuxia" / "config" / "wx_names.nut"
BIOS_DIR = MOD_DIR / "mod_wuxia" / "config" / "bios"
EVENTS_DIR = MOD_DIR / "scripts" / "events" / "events"
PILLS_CFG = MOD_DIR / "mod_wuxia" / "config" / "consumables.nut"
SECTS_CFG = MOD_DIR / "mod_wuxia" / "config" / "sects.nut"


def unescape_sq(s: str) -> str:
    return s.replace("\\n", "\n").replace('\\"', '"').replace("\\'", "'").replace("\\\\", "\\")


def strip_bb_img(text: str) -> str:
    return re.sub(r"\[img\][^\[]*\[/img\]", "", text).strip()


def parse_pills() -> dict[str, str]:
    src = PILLS_CFG.read_text(encoding="utf-8")
    out = {}
    for m in re.finditer(r'ID\s*=\s*"(wx_pill_[a-z0-9_]+)"[\s\S]*?Name\s*=\s*"([^"]+)"', src):
        out[m.group(1)] = m.group(2)
    return out


def parse_sects() -> dict[str, str]:
    src = SECTS_CFG.read_text(encoding="utf-8")
    out = {}
    for m in re.finditer(r'ID\s*=\s*"([a-z0-9_]+)"\s*,\s*Name\s*=\s*"([^"]+)"', src):
        out[m.group(1)] = m.group(2)
    return out


def parse_backgrounds() -> dict[str, dict]:
    src = BG_CFG.read_text(encoding="utf-8")
    bgs = {}
    pat = re.compile(r'\["(background\.[a-z0-9_]+)"\]\s*=\s*\{\s*Tier\s*=\s*(\d+)\s*,\s*Name\s*=\s*"([^"]+)"\s*,\s*Desc\s*=\s*"([^"]+)"([^}]*)\}')
    for m in pat.finditer(src):
        bg_id, tier, name, desc, rest = m.group(1), int(m.group(2)), m.group(3), m.group(4), m.group(5)
        bgs[bg_id] = {
            "id": bg_id,
            "tier": tier,
            "name": name,
            "desc": desc,
            "grantWraps": "GrantWraps = true" in rest,
        }
    return bgs


def parse_names() -> tuple[dict[str, list[str]], dict[str, dict]]:
    src = NAMES_CFG.read_text(encoding="utf-8")
    pools = {}
    for m in re.finditer(r'^\t([a-z_]+)\s*=\s*\[([\s\S]*?)\]', src, re.M):
        key = m.group(1)
        items = re.findall(r'"([^"]+)"', m.group(2))
        if items:
            pools[key] = items
    bg_names = {}
    for m in re.finditer(r'\["(background\.[a-z0-9_]+)"\]\s*=\s*\{\s*Pool\s*=\s*"([^"]+)"\s*,\s*Titles\s*=\s*\[([^\]]*)\]\s*\}', src):
        bg_names[m.group(1)] = {
            "pool": m.group(2),
            "titles": re.findall(r'"([^"]+)"', m.group(3)),
        }
    return pools, bg_names


def parse_bios(bgs: dict[str, dict]) -> list[dict]:
    bios = []
    bg_block_re = re.compile(r'BackgroundBios\["(background\.[a-z0-9_]+)"\]\s*<-\s*\[([\s\S]*?)\];')
    entry_re = re.compile(r'\{\s*ID\s*=\s*"(wx_bio_\d+)"\s*,\s*Text\s*=\s*"((?:[^"\\]|\\.)*)"\s*\}')
    for bf in sorted(BIOS_DIR.glob("wx_bios_*.nut")):
        src = bf.read_text(encoding="utf-8")
        for m in bg_block_re.finditer(src):
            bg_id = m.group(1)
            bg_info = bgs.get(bg_id, {"tier": 0, "name": bg_id, "desc": ""})
            for bio_id, raw_txt in entry_re.findall(m.group(2)):
                bios.append({
                    "id": bio_id,
                    "bgId": bg_id,
                    "bgName": bg_info["name"],
                    "tier": bg_info["tier"],
                    "text": unescape_sq(raw_txt),
                })
    bios.sort(key=lambda x: x["id"])
    return bios


# =========================================================================
# Squirrel Event Expression Evaluator (Clean Readable Chinese Preview)
# =========================================================================

VAR_SAMPLE_MAP = [
    (r'sectA\.Name', '清风剑派'),
    (r'sectB\.Name', '黑风血煞宗'),
    (r'sect\.Description', '名门正派剑宗，精研阴柔内息、轻身快剑与反击拆招。'),
    (r'sect\.Name|s\.Name|sc\.Name|\bsName\b|\bhost\b', '威远总镖局'),
    (r'regionLabel|rName', '中原官道'),
    (r'clash', '《太和纯阳功》与《寒冰护脉诀》'),
    (r'\bmanA\b', '《清风剑法》'),
    (r'\bmanB\b|\bmanualB\b', '《五虎断门刀》'),
    (r'manualName|mName|bookName|def\.Name|\bmanName\b|\bneiName\b', '《松涛心法》'),
    (r'fragName', '《断岳狂刀》残篇'),
    (r'pillName|pdef\.Name', '护心丹'),
    (r'_event\.m\.ChampName', '沈寒江'),
    (r'_event\.m\.LotName', '镇派绝学《回风拂柳剑》'),
    (r'_event\.m\.BidPrice', '4800'),
    (r'_event\.m\.SquadScore|_event\.m\.WinChance', '76'),
    (r'offer\.MinRel', '25'),
    (r'offer\.Price', '2200'),
    (r'\bgain\b', '280'),
    (r'site\.getName\(\)', '【山海秘境】小次山血猿绝谷'),
    (r'\bdir\b', '东北'),
    (r'\bdist\b', '14'),
    (r'\brewardText\b', '赏银 4,500 两，江湖孤本与洗髓丹'),
    (r'\bbookDesc\b', '门派真传秘籍抄本数册'),
    (r'\brel\b', '25'),
    (r'\bmeds\b', '18'),
    (r'\bammo\b', '30'),
    (r'\btools\b', '24'),
    (r'\bfinderLead\b', '荒坡乱草间露出一截半埋的青石断碑'),
    (r'\bhealLabel\b', '伤势与内息'),
    (r'\bgiftDesc\b|\blootDesc\b', '一卷门派残页与百余两碎银'),
    (r'\bintro\b', '远方天际升起数股浓黑狼烟，江湖大势已然风云变色！邪派炼体药人、湘西尸傀、藩镇大军与南北群雄齐齐入局，各地关隘烽烟四起！'),
    (r'\b(expertLine|optLine|extraLine|giftTxt|giftLine|winTxt|loseTxt|buddyLine|spotterLine|bookLine|cureLine|docLine|extraText|pageLine|partnerLine|repText|spotHint|strainHint|strainText|watcherLine|worriedLine|chillText|spookText)\b', ''),
    (r'\b(healer|hl|doc|med|monk|nameMonk|hName|hShort|dName)\b', '「慧明」'),
    (r'\b(vet|master|mentor|champ|elder|vName|mShort|zName)\b', '「谢千山」'),
    (r'\b(rookie|jr|apprentice|student|shortN)\b', '「陈铁牛」'),
    (r'\b(nameA|shortA|aName|broA|sA|bA|nA|firstName|pName|tName|iName)\b', '「沈寒江」'),
    (r'\b(nameB|shortB|bName|broB|sB|bB|nB|secondName|bShort|nameV)\b', '「周大锤」'),
    (r'\b(nameC|shortC|cName|broC|sC|catcher|spotter|helper|mediator|negotiator|bluffer|judge|expert|sch|trk|sh|off|eName|wName|nameW)\b', '「陆青崖」'),
    (r'\b(name|short|broName|bn|sn|who|target|victim|cook|singer|drinker|fighter|gambler|thief|guard)\b', '「沈寒江」'),
]


def eval_sq_string_expr(expr: str) -> str:
    """Split a Squirrel string concatenation expression on top-level '+' and render readable Chinese."""
    tokens = []
    cur = []
    in_str = False
    depth = 0
    i = 0
    n = len(expr)
    while i < n:
        ch = expr[i]
        if in_str:
            cur.append(ch)
            if ch == "\\" and i + 1 < n:
                cur.append(expr[i + 1])
                i += 2
                continue
            if ch == '"':
                in_str = False
            i += 1
        else:
            if ch == '"':
                in_str = True
                cur.append(ch)
                i += 1
            elif ch in "([{":
                depth += 1
                cur.append(ch)
                i += 1
            elif ch in ")]}":
                depth = max(0, depth - 1)
                cur.append(ch)
                i += 1
            elif ch == "+" and depth == 0:
                tokens.append("".join(cur).strip())
                cur = []
                i += 1
            else:
                cur.append(ch)
                i += 1
    if cur:
        tokens.append("".join(cur).strip())

    parts = []
    for tok in tokens:
        if not tok:
            continue
        if tok.startswith('"') and tok.endswith('"') and len(tok) >= 2:
            parts.append(unescape_sq(tok[1:-1]))
            continue
        # Handle ::Wuxia.Events.fmtName(...) or shortName(...)
        m_fn = re.search(r'(?:fmtName|shortName)\(([^)]+)\)', tok)
        if m_fn:
            arg = m_fn.group(1)
            if re.search(r'BroB|B\b|B2|Rowdy|Peasant|Rookie|Victim|Drinker|Target|Second|Evil', arg, re.I):
                parts.append("[color=#bcad8c]周大锤[/color]" if "fmtName" in tok else "周大锤")
            elif re.search(r'Healer|Monk|Catcher|Spotter|Helper|Expert|Mediator|Official|Scholar|Tracker|Shooter|Bluffer|Inspector|Anat', arg, re.I):
                parts.append("[color=#bcad8c]陆青崖[/color]" if "fmtName" in tok else "陆青崖")
            else:
                parts.append("[color=#bcad8c]沈寒江[/color]" if "fmtName" in tok else "沈寒江")
            continue
        if "pickManualName" in tok:
            parts.append("《松涛心法》")
            continue
        if "getRegionLabel" in tok:
            parts.append("中原官道")
            continue
        if "getMoney" in tok:
            parts.append("1200")
            continue
        matched = False
        for pat, rep in VAR_SAMPLE_MAP:
            if re.search(pat, tok):
                parts.append(rep)
                matched = True
                break
        if not matched:
            # Check ternary with string literals: cond ? "A" : "B"
            m_tern = re.search(r'\?\s*"((?:[^"\\]|\\.)*)"\s*:\s*"((?:[^"\\]|\\.)*)"', tok)
            if m_tern:
                parts.append(unescape_sq(m_tern.group(1)))
            elif re.fullmatch(r'\d+', tok):
                parts.append(tok)
            else:
                parts.append("【同袍】")
    text = "".join(parts)
    text = strip_bb_img(text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text.strip()


def extract_balanced_block(src: str, start_brace_idx: int) -> tuple[str, int]:
    depth = 0
    in_str = False
    i = start_brace_idx
    n = len(src)
    while i < n:
        ch = src[i]
        if in_str:
            if ch == "\\" and i + 1 < n:
                i += 2
                continue
            if ch == '"':
                in_str = False
        else:
            if ch == '"':
                in_str = True
            elif ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    return src[start_brace_idx:i + 1], i + 1
        i += 1
    return src[start_brace_idx:], n


def extract_statement_rhs(src: str, eq_pos: int) -> str:
    """Read from after '=' until top-level ';' or ',' (respecting quotes and parens)."""
    in_str = False
    depth = 0
    i = eq_pos
    n = len(src)
    out = []
    while i < n:
        ch = src[i]
        if in_str:
            out.append(ch)
            if ch == "\\" and i + 1 < n:
                out.append(src[i + 1])
                i += 2
                continue
            if ch == '"':
                in_str = False
            i += 1
        else:
            if ch == '"':
                in_str = True
                out.append(ch)
                i += 1
            elif ch in "([{":
                depth += 1
                out.append(ch)
                i += 1
            elif ch in ")]}":
                if depth == 0:
                    break
                depth -= 1
                out.append(ch)
                i += 1
            elif ch in ";," and depth == 0:
                break
            else:
                out.append(ch)
                i += 1
    return "".join(out).strip()


def extract_screen_effects(block: str, pills: dict[str, str], sects: dict[str, str]) -> list[str]:
    effs = []
    for m in re.finditer(r'addMoney\(\s*(-?\d+)', block):
        v = int(m.group(1))
        effs.append(f"银两 {'+' if v > 0 else ''}{v}")
    for m in re.finditer(r'addCompanyMastery\(\s*(\d+)', block):
        effs.append(f"全队武学火候 +{m.group(1)}")
    for m in re.finditer(r'addMastery\(\s*[^,]+,\s*(\d+)', block):
        effs.append(f"武学火候 +{m.group(1)}")
    for m in re.finditer(r'addStat\([^,]+,\s*"[^"]+"\s*,\s*(-?\d+)\s*,\s*"([^"]+)"', block):
        v = int(m.group(1))
        effs.append(f"{m.group(2)} {'+' if v > 0 else ''}{v}")
    for m in re.finditer(r'givePill\(\s*"(wx_pill_[a-z0-9_]+)"', block):
        effs.append(f"灵药【{pills.get(m.group(1), m.group(1))}】")
    for m in re.finditer(r'givePage\(\s*"([^"]+)"\s*,\s*(\d+)', block):
        qmap = {"common": "大路货", "sect": "门派上乘", "secret": "绝学", "unique": "江湖孤本"}
        effs.append(f"{qmap.get(m.group(1), m.group(1))}残页 ×{m.group(2)}")
    for m in re.finditer(r'giveManual\(\s*"([^"]+)"', block):
        qmap = {"common": "大路货", "sect": "门派上乘", "secret": "绝学", "unique": "江湖孤本"}
        effs.append(f"完整{qmap.get(m.group(1), m.group(1))}秘籍")
    for m in re.finditer(r'addSectRel\(\s*([^,]+),\s*(-?\d+)', block):
        raw_s, v = m.group(1).strip(), int(m.group(2))
        s_m = re.match(r'^"([a-z0-9_]+)"$', raw_s)
        sname = sects.get(s_m.group(1), "当地门派") if s_m else "相关门派"
        effs.append(f"【{sname}】交情 {'+' if v > 0 else ''}{v}")
    for m in re.finditer(r'addSupplies\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)', block):
        t, md, am = int(m.group(1)), int(m.group(2)), int(m.group(3))
        if t: effs.append(f"修甲器械 {'+' if t > 0 else ''}{t}")
        if md: effs.append(f"伤药 {'+' if md > 0 else ''}{md}")
        if am: effs.append(f"箭矢弹药 {'+' if am > 0 else ''}{am}")
    for m in re.finditer(r'giveFood\([^,]+,\s*"([^"]+)"', block):
        effs.append(f"口粮：{m.group(1)}")
    for m in re.finditer(r'giveItem\(\s*"([^"]+)"', block):
        imap = {
            "wardog_item": "护院猎犬", "witch_hair_item": "青丘妖魅惑心发", "third_eye_item": "讹兽梦魇诡眼",
            "serpent_skin_item": "苍梧巴蛇青鳞皮", "glistening_scales_item": "巴蛇微光逆鳞",
            "unhold_hide_item": "朱厌白首厚革", "poison_gland_item": "异兽五毒腺囊",
            "shimmering_ashes_item": "幽冥剑魔灵烬",
        }
        key = m.group(1).split("/")[-1]
        if key in imap:
            effs.append(f"奇材/物品：{imap[key]}")
    if "cureInternalStrain(" in block or "cureTemporary()" in block:
        effs.append("化解内伤与散功虚弱")
    if "applyInternalStrain(" in block:
        effs.append("染上轻度内伤")
    if "applyLightHurt(" in block:
        effs.append("负伤损血")
    if "healBro(" in block:
        effs.append("恢复气血")
    for m in re.finditer(r'addCompanyMood\(\s*(-?[\d.]+)', block):
        effs.append("全队士气振奋" if float(m.group(1)) > 0 else "全队士气低落")
    for m in re.finditer(r'addMood\([^,]+,\s*(-?[\d.]+)', block):
        effs.append("心情提升" if float(m.group(1)) > 0 else "心情低落")
    for m in re.finditer(r'addReputation\(\s*(-?\d+)\s*,\s*(-?\d+)', block):
        b, mo = int(m.group(1)), int(m.group(2))
        if b: effs.append(f"江湖名望 {'+' if b > 0 else ''}{b}")
        if mo: effs.append("侠义声名上扬" if mo > 0 else "江湖恶名传开")
    # Deduplicate preserving order
    seen = set()
    uniq = []
    for e in effs:
        if e not in seen:
            seen.add(e)
            uniq.append(e)
    return uniq


def parse_event_category(stem: str) -> tuple[str, str]:
    if stem.startswith("wx_event_camp_"):
        return "camp", "营地百态与出身互动"
    if stem.startswith("wx_event_bg_"):
        return "bg", "市井行当与江湖奇遇"
    if stem.startswith("wx_event_martial_"):
        return "martial", "武学修炼与丹药秘籍"
    if stem.startswith("wx_event_sect_") and stem != "wx_event_sect_exchange":
        return "sect", "四十四大门派与恩怨"
    if stem.startswith("wx_event_weird_") or stem.startswith("wx_event_road_") or stem.startswith("wx_event_crisis_"):
        return "weird", "志怪山海与乱世风云"
    return "core", "核心城镇与终局事件"


def extract_triggers(src: str, bgs: dict[str, dict]) -> list[str]:
    m_sc = re.search(r'function\s+onUpdateScore\s*\(\s*\)\s*\{', src)
    if not m_sc:
        return ["大地图随机触发"]
    block, _ = extract_balanced_block(src, m_sc.end() - 1)
    tags = []
    bg_ids = re.findall(r'"(background\.[a-z0-9_]+)"', block)
    if bg_ids:
        names = []
        for bid in bg_ids:
            bn = bgs.get(bid, {}).get("name", bid)
            if bn not in names:
                names.append(bn)
        if len(names) <= 4:
            tags.append("出身：" + "/".join(names))
        else:
            tags.append("出身：" + "/".join(names[:3]) + f" 等{len(names)}类")
    if "findBroWithConflict" in block:
        tags.append("需：队员存在阴阳/正邪内功相克")
    if "findBroWithFragment" in block:
        tags.append("需：队员正在强修残本功法")
    if "findBroWithMarrowWash" in block:
        tags.append("需：队员曾经历洗经伐髓")
    if "findBroWithInternalStrain" in block or "wx_scatter_weakness" in block:
        tags.append("需：队内有内伤或散功虚弱")
    if 'findBroWithElement("evil"' in block:
        tags.append("需：修习邪功内功或秘教信徒")
    if "findBroWithManual" in block:
        tags.append("需：已装配武学秘籍")
    if "pickHostileSect" in block:
        tags.append("需：与至少一家门派交恶")
    if "isNearTown" in block or "isNearMarketTown" in block:
        tags.append("城镇周边")
    if "isNight" in block:
        tags.append("夜间触发")
    if "getActiveCrisis" in block:
        tags.append("武林大势危机 / 55日后")
    m_day = re.search(r'Days\s*<\s*(\d+)', block)
    if m_day:
        tags.append(f"第 {m_day.group(1)} 日后")
    if not tags:
        tags.append("行军大地图奇遇")
    return tags


def parse_event_file(ef: Path, bgs: dict[str, dict], pills: dict[str, str], sects: dict[str, str]) -> dict:
    src = ef.read_text(encoding="utf-8")
    stem = ef.stem
    cat, cat_label = parse_event_category(stem)
    m_id = re.search(r'this\.m\.ID\s*=\s*"([^"]+)"', src)
    m_title = re.search(r'this\.m\.Title\s*=\s*"([^"]+)"', src)
    m_cd = re.search(r'this\.m\.Cooldown\s*=\s*([\d.]+)', src)
    comment_line = src.splitlines()[0].lstrip("/ ").strip() if src.startswith("//") else ""

    screens = []
    pos = 0
    while True:
        m_push = re.search(r'this\.m\.Screens\.push\(\s*\{', src[pos:])
        if not m_push:
            break
        brace_idx = pos + m_push.end() - 1
        block, next_pos = extract_balanced_block(src, brace_idx)
        pos = next_pos

        m_sid = re.search(r'\bID\s*=\s*"([A-Za-z0-9_]+)"', block)
        if not m_sid:
            continue
        sid = m_sid.group(1)

        # Extract static Text = "..." and dynamic this.Text = ...
        text_val = ""
        m_dyn = re.search(r'this\.Text\s*=\s*', block)
        if m_dyn:
            rhs = extract_statement_rhs(block, m_dyn.end())
            text_val = eval_sq_string_expr(rhs)
        else:
            m_st = re.search(r'\bText\s*=\s*', block)
            if m_st:
                rhs = extract_statement_rhs(block, m_st.end())
                text_val = eval_sq_string_expr(rhs)

        # Special handling for wx_event_crisis_jianghu_omen intro branches
        if stem == "wx_event_crisis_jianghu_omen" and sid == "A":
            intros = re.findall(r'intro\s*=\s*"((?:[^"\\]|\\.)*)"', block)
            if intros:
                extra_variants = "\n".join("· " + unescape_sq(x) for x in intros[:4])
                text_val = text_val + "\n\n【随当前四大武林危机动态切换开场】\n" + extra_variants

        # Extract options (both static Options = [...] and dynamic this.Options.push({...}))
        options = []
        # Find option tables containing Text = ... and getResult
        opt_pos = 0
        while True:
            m_opt = re.search(r'\{\s*Text\s*=\s*', block[opt_pos:])
            if not m_opt:
                break
            ob_idx = opt_pos + m_opt.start()
            oblock, onext = extract_balanced_block(block, ob_idx)
            opt_pos = onext
            if "getResult" not in oblock:
                continue
            m_ot = re.search(r'\bText\s*=\s*', oblock)
            otxt = eval_sq_string_expr(extract_statement_rhs(oblock, m_ot.end())) if m_ot else ""
            targets = re.findall(r'\breturn\s+"([A-Za-z0-9_]+)"', oblock)
            # Filter out NoMoney / NoRoom / NoTools / NoMeds / NoAmmo / NoMedicine as primary preview target if another target exists
            non_err = [t for t in targets if not t.startswith("No")]
            primary_targets = non_err if non_err else targets
            is_close = (len(targets) == 0 and re.search(r'\breturn\s+0\b', oblock) is not None)
            # Detect if this option was inside an if (isAlive(...)) special branch
            pre_ctx = block[max(0, ob_idx - 220):ob_idx]
            is_special = bool(re.search(r'if\s*\([^\)]*isAlive', pre_ctx))
            options.append({
                "text": otxt,
                "targets": primary_targets,
                "allTargets": targets,
                "close": is_close,
                "special": is_special,
            })

        # Also catch dynamic Options[i].Text = ... overrides
        for m_ov in re.finditer(r'this\.Options\[(\d+)\]\.Text\s*=\s*', block):
            oi = int(m_ov.group(1))
            if oi < len(options):
                options[oi]["text"] = eval_sq_string_expr(extract_statement_rhs(block, m_ov.end()))

        effects = extract_screen_effects(block, pills, sects)
        screens.append({
            "id": sid,
            "text": text_val,
            "options": options,
            "effects": effects,
        })

    if "makeNoRoomScreen" in src:
        screens.append({
            "id": "NoRoom",
            "text": "行囊已满，放不下这件货物。你收起银两，辞别了对方。",
            "options": [{"text": "改日再来。", "targets": [], "allTargets": [], "close": True, "special": False}],
            "effects": [],
        })

    return {
        "id": m_id.group(1) if m_id else f"event.{stem}",
        "file": ef.name,
        "title": m_title.group(1) if m_title else stem,
        "note": comment_line,
        "category": cat,
        "categoryLabel": cat_label,
        "cooldownDays": int(float(m_cd.group(1))) if m_cd else 20,
        "triggers": extract_triggers(src, bgs),
        "screens": screens,
    }


NARRATIVE_CSS = """/* === NARRATIVE_WIKI_BEGIN === */
.nar-hero{margin:0 0 16px;padding:13px 15px;background:#f4f5ee;border:1px solid #b7bfa9;border-top:3px solid #204f4a;border-radius:3px}
.nar-hero-head{display:flex;align-items:baseline;justify-content:space-between;gap:10px;flex-wrap:wrap;margin-bottom:10px}
.nar-hero-head strong{font:700 18px/1.35 var(--serif);color:#1f3d37}
.nar-hero-head small{font-size:12.5px;color:var(--quiet)}
.nar-controls{display:flex;flex-wrap:wrap;gap:8px;align-items:center;margin-bottom:10px}
.nar-controls button,.nar-pill-btn{padding:5px 11px;border:1px solid #9eae9e;border-radius:3px;background:var(--sheet);color:#1f3d37;font-size:12.5px;cursor:pointer}
.nar-controls button:hover,.nar-pill-btn:hover{background:#e7eee7;border-color:#204f4a}
.nar-controls button.primary{background:var(--teal);border-color:var(--teal);color:#fff9e9;font-weight:600}
.nar-controls button.primary:hover{background:#183e3a}
.nar-controls input[type="text"],.nar-controls select{padding:5px 9px;border:1px solid #b5bfb2;border-radius:3px;background:var(--sheet);color:#1d2b27;font-size:12.5px}
.nar-spotlight{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,290px),1fr));gap:10px;margin-top:8px}
.nar-recruit-card{background:#1c1612;border:1px solid #634f38;border-top:3px solid #c69b54;border-radius:3px;padding:12px 14px;color:#eadec8;box-shadow:0 3px 10px rgba(0,0,0,.22)}
.nar-recruit-top{display:flex;align-items:baseline;justify-content:space-between;gap:8px;flex-wrap:wrap;border-bottom:1px solid #443526;padding-bottom:6px;margin-bottom:8px}
.nar-recruit-name{font:700 17px/1.25 var(--serif);color:#f9e8c3}
.nar-recruit-title{font-size:12px;color:#d6b06b;margin-left:6px}
.nar-recruit-meta{font-size:11.5px;color:#b8a589}
.nar-recruit-body{font-size:13.5px;line-height:1.78;color:#e8dcc6;margin:0}
.nar-recruit-note{margin-top:8px;padding-top:6px;border-top:1px dashed #4a3a29;font-size:11.5px;color:#d5b473}

.bio-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(min(100%,360px),1fr));gap:11px}
.bio-card{display:flex;flex-direction:column;background:var(--sheet);border:1px solid var(--rule);border-left:3px solid #69816f;border-radius:2px;padding:12px 14px;transition:border-color .15s,box-shadow .15s}
.bio-card:hover{border-color:#7d6845;box-shadow:0 3px 10px rgba(32,61,56,.08)}
.bio-card.tier-0{border-left-color:#7c8a7e}
.bio-card.tier-1{border-left-color:#2c665f}
.bio-card.tier-2{border-left-color:#a8792d}
.bio-card-head{display:flex;align-items:center;justify-content:space-between;gap:8px;margin-bottom:7px;flex-wrap:wrap}
.bio-card-who{font:700 15px/1.3 var(--serif);color:#1d3934}
.bio-card-who small{font:normal 12px/1 var(--sans);color:var(--quiet);margin-left:6px}
.bio-card-text{font-size:13.8px;line-height:1.82;color:#26312e;margin:0 0 8px;flex:1}
.bio-card-foot{display:flex;align-items:center;justify-content:space-between;gap:8px;padding-top:6px;border-top:1px solid #e6e8df;font-size:11.5px;color:var(--quiet)}
.bio-card-foot code{font-size:11px;color:#5a6862}

.ev-overview{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,170px),1fr));gap:8px;margin:0 0 14px}
.ev-cat-btn{display:block;width:100%;text-align:left;padding:10px 12px;background:var(--sheet);border:1px solid var(--rule);border-top:3px solid #7e9081;border-radius:3px;cursor:pointer}
.ev-cat-btn:hover{background:#f3f6ef;border-color:#5a7564}
.ev-cat-btn[aria-current="true"]{background:#eef3ec;border-color:var(--teal);border-top-color:#b8935f}
.ev-cat-btn strong{display:block;font:700 14.5px/1.3 var(--serif);color:#1f3d37}
.ev-cat-btn small{display:block;margin-top:2px;font-size:11.5px;color:var(--quiet)}

.ev-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(min(100%,355px),1fr));gap:12px}
.ev-card{display:flex;flex-direction:column;background:var(--sheet);border:1px solid var(--rule);border-top:3px solid #6b8170;border-radius:3px;padding:12px 14px;transition:border-color .15s,box-shadow .15s}
.ev-card:hover{border-color:#7d6845;box-shadow:0 3px 10px rgba(32,61,56,.08)}
.ev-card.cat-camp{border-top-color:#3a6b63}
.ev-card.cat-bg{border-top-color:#5c7a4e}
.ev-card.cat-martial{border-top-color:#9e6b23}
.ev-card.cat-sect{border-top-color:#3b5a7c}
.ev-card.cat-weird{border-top-color:#7a3833}
.ev-card.cat-core{border-top-color:#8a6a38}
.ev-card-head{display:flex;align-items:flex-start;justify-content:space-between;gap:8px;margin-bottom:5px}
.ev-card h3{margin:0;font:700 16.5px/1.32 var(--serif);color:#1c3732}
.ev-triggers{display:flex;flex-wrap:wrap;gap:4px;margin:4px 0 8px}
.ev-trig-pill{font-size:11px;padding:1px 6px;border-radius:2px;background:#ecefe6;border:1px solid #cdd5c8;color:#3c4d47}
.ev-excerpt{font-size:13.2px;line-height:1.72;color:#313d39;margin:0 0 10px;flex:1}
.ev-card-foot{display:flex;align-items:center;justify-content:space-between;gap:8px;padding-top:8px;border-top:1px solid #e6e8df;font-size:11.5px;color:var(--quiet)}
.ev-actions{display:flex;gap:6px;flex-wrap:wrap}

/* Interactive Event Player inside Dialog */
.ev-sim-stage{background:#1b1511;border:1px solid #5e4b35;border-top:3px solid #c69a50;border-radius:4px;padding:15px 17px;color:#eadec8;margin:6px 0 12px}
.ev-sim-bar{display:flex;align-items:center;justify-content:space-between;gap:8px;flex-wrap:wrap;padding-bottom:8px;margin-bottom:10px;border-bottom:1px solid #443527;font-size:12px;color:#c3ae8e}
.ev-sim-text{font-size:14.2px;line-height:1.86;color:#f1e5ce;white-space:pre-line;margin:0 0 12px}
.ev-sim-text .wx-hl{color:#e8c170;font-weight:600}
.ev-sim-effs{display:flex;flex-wrap:wrap;gap:5px;margin:0 0 12px}
.ev-eff-pill{font-size:11.5px;padding:2px 8px;border-radius:3px;background:#2b2219;border:1px solid #7c6343;color:#f3dca8}
.ev-sim-opts{display:grid;gap:7px}
.ev-opt-btn{display:flex;align-items:center;justify-content:space-between;gap:8px;width:100%;text-align:left;padding:9px 12px;background:#292018;border:1px solid #6e573d;border-radius:3px;color:#f5e7cb;font-size:13.2px;line-height:1.45;cursor:pointer}
.ev-opt-btn:hover{background:#3c2e21;border-color:#dfb56d;color:#fff8e6}
.ev-opt-btn.is-special{border-left:3px solid #dfb56d;background:#2e2418}
.ev-opt-tag{flex-shrink:0;font-size:11px;padding:1px 6px;border-radius:2px;background:#443422;color:#f0ca7d}
.ev-full-screen{border:1px solid var(--rule);border-left:3px solid #204f4a;background:#fafaf5;border-radius:3px;padding:11px 13px;margin:10px 0}
.ev-full-screen h4{margin:0 0 6px;font:700 14.5px/1.3 var(--serif);color:#1f3d37;display:flex;align-items:center;justify-content:space-between;gap:8px}
.ev-full-screen p{margin:0 0 8px;font-size:13.5px;line-height:1.8;color:#273330;white-space:pre-line}
.ev-full-opts{margin:6px 0 0;padding-left:18px;font-size:12.5px;color:#41524c;line-height:1.65}
.ev-full-effs{display:flex;flex-wrap:wrap;gap:4px;margin-top:6px}
.ev-full-eff{font-size:11.5px;padding:1px 7px;border-radius:2px;background:#e6efe9;border:1px solid #b8d2c3;color:#1d4c3e}
/* === NARRATIVE_WIKI_END === */"""


NARRATIVE_JS = r"""// === NARRATIVE_WIKI_BEGIN ===
const narrativeData = JSON.parse(document.getElementById('narrative-data').textContent);
const wxBios = narrativeData.bios || [];
const wxBackgrounds = narrativeData.backgrounds || [];
const wxBgById = new Map(wxBackgrounds.map(b => [b.id, b]));
const wxNamePools = narrativeData.namePools || {};
const wxBgNames = narrativeData.bgNames || {};
const wxEvents = narrativeData.events || [];
const wxEventById = new Map(wxEvents.map(e => [e.id, e]));
const wxEventCats = [
  { id: '', label: '全部江湖事件', desc: '全 66 份独立剧情脚本' },
  { id: 'camp', label: '营地百态与出身互动', desc: '12 份同袍斗嘴、拜师、赌局与夜话' },
  { id: 'bg', label: '市井行当与江湖奇遇', desc: '12 份医毒、打擂、扒手、官卡与秘闻' },
  { id: 'martial', label: '武学修炼与丹药秘籍', desc: '12 份走火入魔、残本心魔、洗髓与奇药' },
  { id: 'sect', label: '四十四大门派与恩怨', desc: '12 份地域门派、劫镖、寻仇调停与踢馆' },
  { id: 'weird', label: '志怪山海与乱世风云', desc: '12 份黑店赶尸、狐庙山海与四大危机' },
  { id: 'core', label: '核心城镇与终局事件', desc: '6 份书肆、名医、茶楼、鬼市与武林大会' }
];
const wxTierLabels = { 0: '零档·市井底层', 1: '一档·江湖行当', 2: '二档·成名高手' };
const wxTierManualNote = { 0: '入队 0 本预装武学（纯看根骨盲盒）', 1: '入队自带 1 本契合兵器的一重大路货', 2: '入队自带 1 本门派上乘 + 1 本大路货' };

const wxBioSearchMap = new Map(wxBios.map(b => [
  b.id,
  field(b.id, b.bgId, b.bgName, wxTierLabels[b.tier] || '', b.text)
]));
const wxEventSearchMap = new Map(wxEvents.map(e => [
  e.id,
  field(e.id, e.file, e.title, e.note, e.categoryLabel, (e.triggers || []).join(' '),
    (e.screens || []).map(s => s.text + ' ' + (s.options || []).map(o => o.text).join(' ')).join(' '))
]));

let wxBioCustomName = '';
let wxBioSpotlights = [];
let wxSimEventId = '';
let wxSimScreenId = 'A';
let wxSimHistory = [];

function wxHashStr(s) {
  let h = 2166136261;
  for (let i = 0; i < s.length; i++) { h ^= s.charCodeAt(i); h = Math.imul(h, 16777619); }
  return h >>> 0;
}

function wxPickSampleName(bgId, seedStr) {
  if (wxBioCustomName.trim()) return { name: wxBioCustomName.trim(), title: '' };
  const cfg = wxBgNames[bgId] || { pool: 'jianghu', titles: [] };
  const pool = wxNamePools[cfg.pool] || wxNamePools.jianghu || ['沈寒江'];
  const h = wxHashStr(seedStr || bgId);
  const name = pool[h % pool.length];
  const titles = cfg.titles || [];
  const title = (titles.length && (h % 3 === 0)) ? titles[(h >> 3) % titles.length] : '';
  return { name, title };
}

function wxRenderBioText(tpl, name) {
  return html(tpl).replace(/%name%/g, '<strong style="color:#1b4d3e">' + html(name) + '</strong>');
}

function wxRenderRichEventText(raw) {
  let safe = html(raw || '');
  safe = safe.replace(/\[color=([^\]]+)\]([\s\S]*?)\[\/color\]/g, '<span class="wx-hl">$2</span>');
  return safe;
}

function wxRollBioSpotlights(tierFilter, count) {
  const pool = wxBios.filter(b => tierFilter === '' || String(b.tier) === String(tierFilter));
  if (!pool.length) { wxBioSpotlights = []; return; }
  const picked = [];
  const used = new Set();
  for (let i = 0; i < count && used.size < pool.length; i++) {
    const idx = Math.floor(Math.random() * pool.length);
    const bio = pool[idx];
    if (used.has(bio.id)) { i--; continue; }
    used.add(bio.id);
    const cfg = wxBgNames[bio.bgId] || { pool: 'jianghu', titles: [] };
    const np = wxNamePools[cfg.pool] || wxNamePools.jianghu || ['沈寒江'];
    const name = wxBioCustomName.trim() || np[Math.floor(Math.random() * np.length)];
    const title = (cfg.titles && cfg.titles.length) ? cfg.titles[Math.floor(Math.random() * cfg.titles.length)] : '';
    picked.push({ bio, name, title });
  }
  wxBioSpotlights = picked;
}

function matchingBios(query) {
  return wxBios.filter(b =>
    (state.bt === '' || String(b.tier) === String(state.bt)) &&
    (!state.bg || b.bgId === state.bg) &&
    (!query || wxBioSearchMap.get(b.id).includes(query))
  );
}

function matchingEvents(query) {
  return wxEvents.filter(e =>
    (!state.ec || e.category === state.ec) &&
    (!query || wxEventSearchMap.get(e.id).includes(query))
  );
}

function drawNarrativeRail() {
  const nav = element('chapters');
  const sel = element('mobile-group');
  const railTitle = document.querySelector('.rail h2');
  if (state.v === 'bios') {
    if (railTitle) railTitle.textContent = '出身档次';
    const tiers = [
      { id: '', idx: '全', label: '全部人物列传 (' + wxBios.length + ')' },
      { id: '0', idx: '零', label: '零档·市井底层 (' + wxBios.filter(b => b.tier === 0).length + ')' },
      { id: '1', idx: '一', label: '一档·江湖行当 (' + wxBios.filter(b => b.tier === 1).length + ')' },
      { id: '2', idx: '二', label: '二档·成名高手 (' + wxBios.filter(b => b.tier === 2).length + ')' }
    ];
    nav.innerHTML = tiers.map(it =>
      '<button data-bio-tier="' + escapeAttr(it.id) + '" aria-current="' + String((state.bt || '') === it.id && !state.bg) + '">' +
      '<span class="idx">' + html(it.idx) + '</span>' + html(it.label) + '</button>'
    ).join('') + '<div style="margin:10px 0 4px;padding:6px 8px 2px;font-size:11.5px;color:var(--quiet);border-top:1px solid var(--rule)">72 种出身速查</div>' +
      wxBackgrounds.filter(bg => state.bt === '' || String(bg.tier) === String(state.bt)).map(bg => {
        const cnt = wxBios.filter(b => b.bgId === bg.id).length;
        return '<button data-bio-bg="' + escapeAttr(bg.id) + '" aria-current="' + String(state.bg === bg.id) + '">' +
          '<span class="idx">' + cnt + '</span>' + html(bg.name) + '</button>';
      }).join('');
    sel.innerHTML = tiers.map(it => '<option value="' + escapeAttr(it.id) + '">' + html(it.label) + '</option>').join('');
    sel.value = state.bt || '';
  } else if (state.v === 'events') {
    if (railTitle) railTitle.textContent = '事件分卷';
    nav.innerHTML = wxEventCats.map((cat, idx) => {
      const cnt = cat.id ? wxEvents.filter(e => e.category === cat.id).length : wxEvents.length;
      return '<button data-ev-cat="' + escapeAttr(cat.id) + '" aria-current="' + String((state.ec || '') === cat.id) + '">' +
        '<span class="idx">' + (idx === 0 ? '全' : String(idx).padStart(2, '0')) + '</span>' +
        html(cat.label) + ' (' + cnt + ')</button>';
    }).join('');
    sel.innerHTML = wxEventCats.map(cat => '<option value="' + escapeAttr(cat.id) + '">' + html(cat.label) + '</option>').join('');
    sel.value = state.ec || '';
  }
}

const _wxOrigDrawRailForView = drawRailForView;
drawRailForView = function() {
  if (state.v === 'bios' || state.v === 'events') {
    drawNarrativeRail();
    return;
  }
  _wxOrigDrawRailForView();
};

function renderBiosView(query) {
  if (!wxBioSpotlights.length) wxRollBioSpotlights('', 2);
  const found = matchingBios(query);
  const perPage = 30;
  const pages = Math.max(1, Math.ceil(found.length / perPage));
  state.p = Math.min(Math.max(1, state.p), pages);
  const slice = found.slice((state.p - 1) * perPage, state.p * perPage);

  const bgOpts = '<option value="">全部 72 种出身</option>' + wxBackgrounds
    .filter(bg => state.bt === '' || String(bg.tier) === String(state.bt))
    .map(bg => {
      const cnt = wxBios.filter(b => b.bgId === bg.id).length;
      return '<option value="' + escapeAttr(bg.id) + '"' + (state.bg === bg.id ? ' selected' : '') + '>' +
        html(bg.name + ' (' + cnt + '份 · ' + wxTierLabels[bg.tier] + ')') + '</option>';
    }).join('');

  const spotlightHtml = '<section class="nar-hero">' +
    '<div class="nar-hero-head"><strong>🎲 江湖点将台 · 500 份独立人物列传实机预览</strong>' +
    '<small>72 种出身零重复开头 · 自动分配中式姓名与江湖绰号 · 招募页与人物页原样呈现</small></div>' +
    '<div class="nar-controls">' +
    '<button class="primary" data-bio-roll="2">手气随机点将 (2位)</button>' +
    '<button data-bio-roll="0">抽市井底层</button>' +
    '<button data-bio-roll="1">抽江湖行当</button>' +
    '<button data-bio-roll="2t">抽成名高手</button>' +
    '<select id="wx-bio-bg-sel" aria-label="按出身筛选">' + bgOpts + '</select>' +
    '<input type="text" id="wx-bio-name-in" value="' + escapeAttr(wxBioCustomName) + '" placeholder="自定义代入人名（留空则自动配中式名）" style="min-width:220px">' +
    '</div>' +
    '<div class="nar-spotlight">' + wxBioSpotlights.map(item => {
      const bgInfo = wxBgById.get(item.bio.bgId);
      const rendered = html(item.bio.text).replace(/%name%/g, '<strong style="color:#f5cf7a">' + html(item.name) + '</strong>');
      return '<article class="nar-recruit-card">' +
        '<div class="nar-recruit-top"><div><span class="nar-recruit-name">' + html(item.name) + '</span>' +
        (item.title ? '<span class="nar-recruit-title">「' + html(item.title) + '」</span>' : '') +
        '</div><span class="nar-recruit-meta">' + html(item.bio.bgName + ' · ' + wxTierLabels[item.bio.tier]) + '</span></div>' +
        '<p class="nar-recruit-body">' + rendered + '</p>' +
        '<div class="nar-recruit-note">' + html(wxTierManualNote[item.bio.tier] || '') +
        (bgInfo ? ' ｜ 行业总述：' + html(bgInfo.desc) : '') + '</div></article>';
    }).join('') + '</div></section>';

  if (!slice.length) return spotlightHtml + emptyState(0);

  const bgOrder = [...new Set(slice.map(b => b.bgId))];
  const chapters = bgOrder.map(bgId => {
    const items = slice.filter(b => b.bgId === bgId);
    const info = wxBgById.get(bgId) || { name: bgId, tier: 0, desc: '' };
    return '<section class="chapter"><div class="ch-head"><h2>' + html(info.name) +
      ' <small style="font-weight:400;margin-left:6px">' + html(wxTierLabels[info.tier] || '') + '</small></h2>' +
      '<small>' + html(info.desc) + '</small></div>' +
      '<div class="bio-grid">' + items.map(b => {
        const sample = wxPickSampleName(b.bgId, b.id);
        return '<article class="bio-card tier-' + b.tier + '">' +
          '<div class="bio-card-head"><span class="bio-card-who">' + html(sample.name) +
          (sample.title ? '<small>「' + html(sample.title) + '」</small>' : '') +
          '</span>' + tag(b.bgName) + '</div>' +
          '<p class="bio-card-text">' + wxRenderBioText(b.text, sample.name) + '</p>' +
          '<div class="bio-card-foot"><code>' + html(b.id) + ' · ' + b.text.replace(/%name%/g, sample.name).length + '字</code>' +
          '<button class="linkbtn" data-bio-detail="' + escapeAttr(b.id) + '">大图阅览</button></div>' +
          '</article>';
      }).join('') + '</div></section>';
  }).join('');

  return spotlightHtml + chapters + pager(pages);
}

function showBioDetail(bio) {
  if (!bio) return;
  const info = wxBgById.get(bio.bgId) || { name: bio.bgName, tier: bio.tier, desc: '' };
  const sample = wxPickSampleName(bio.bgId, bio.id);
  const cfg = wxBgNames[bio.bgId] || { titles: [] };
  const rendered = html(bio.text).replace(/%name%/g, '<strong style="color:#f5cf7a">' + html(sample.name) + '</strong>');
  const card = '<div class="nar-recruit-card" style="margin:8px 0 12px">' +
    '<div class="nar-recruit-top"><div><span class="nar-recruit-name">' + html(sample.name) + '</span>' +
    (sample.title ? '<span class="nar-recruit-title">「' + html(sample.title) + '」</span>' : '') +
    '</div><span class="nar-recruit-meta">' + html(info.name + ' · ' + wxTierLabels[info.tier]) + '</span></div>' +
    '<p class="nar-recruit-body" style="font-size:15px">' + rendered + '</p>' +
    '<div class="nar-recruit-note">' + html(wxTierManualNote[info.tier] || '') + '</div></div>';
  const rows = [
    ['传记编号', '<code>' + html(bio.id) + '</code>'],
    ['对应出身', html(info.name) + ' (<code>' + html(bio.bgId) + '</code>)'],
    ['身价档位', html(wxTierLabels[info.tier] || '')],
    ['江湖绰号池', html((cfg.titles || []).map(t => '「' + t + '」').join(' '))],
    ['行业简述', html(info.desc)]
  ];
  openDialog(info.name + ' · ' + sample.name, rows, '#v=bios', card);
  const srcLink = element('detail-source');
  if (srcLink) srcLink.hidden = true;
}

function renderEventsView(query) {
  const found = matchingEvents(query);
  const perPage = 24;
  const pages = Math.max(1, Math.ceil(found.length / perPage));
  state.p = Math.min(Math.max(1, state.p), pages);
  const slice = found.slice((state.p - 1) * perPage, state.p * perPage);

  const catCards = '<div class="ev-overview">' + wxEventCats.map(cat => {
    const cnt = cat.id ? wxEvents.filter(e => e.category === cat.id).length : wxEvents.length;
    return '<button class="ev-cat-btn" data-ev-cat="' + escapeAttr(cat.id) + '" aria-current="' + String((state.ec || '') === cat.id) + '">' +
      '<strong>' + html(cat.label) + ' (' + cnt + ')</strong><small>' + html(cat.desc) + '</small></button>';
  }).join('') + '</div>';

  const heroBar = '<div class="nar-hero" style="padding:10px 14px">' +
    '<div class="nar-hero-head" style="margin-bottom:0"><strong>📜 江湖大地图与营地事件总览（共 ' + wxEvents.length + ' 份独立脚本）</strong>' +
    '<div class="nar-controls" style="margin-bottom:0">' +
    '<button class="primary" data-ev-random>🎲 随机沉浸试玩一条事件</button>' +
    '<small style="color:var(--quiet)">每条事件均支持交互试玩各分支选项，或展开阅读全剧本</small></div></div></div>';

  if (!slice.length) return catCards + heroBar + emptyState(0);

  const grid = '<div class="ev-grid">' + slice.map(ev => {
    const scrA = (ev.screens || []).find(s => s.id === 'A') || ev.screens[0] || { text: '', options: [] };
    const cleanExcerpt = (scrA.text || '').replace(/\[color=[^\]]+\]|\[\/color\]/g, '').replace(/\n+/g, ' ');
    const excerpt = cleanExcerpt.length > 108 ? cleanExcerpt.slice(0, 108) + '……' : cleanExcerpt;
    return '<article class="ev-card cat-' + escapeAttr(ev.category) + '">' +
      '<div class="ev-card-head"><h3>' + html(ev.title) + '</h3>' + tag(ev.categoryLabel.slice(0, 4)) + '</div>' +
      '<div class="ev-triggers">' + (ev.triggers || []).map(t => '<span class="ev-trig-pill">' + html(t) + '</span>').join('') + '</div>' +
      '<p class="ev-excerpt">' + html(excerpt) + '</p>' +
      '<div class="ev-card-foot"><span>' + ev.screens.length + ' 幕 · 冷却 ' + ev.cooldownDays + ' 日</span>' +
      '<div class="ev-actions">' +
      '<button class="nar-pill-btn" data-ev-play="' + escapeAttr(ev.id) + '">沉浸试玩</button>' +
      '<button class="linkbtn" data-ev-full="' + escapeAttr(ev.id) + '">全文本</button>' +
      '</div></div></article>';
  }).join('') + '</div>';

  return catCards + heroBar + grid + pager(pages);
}

function renderEventSimStage(ev, screenId) {
  const scr = (ev.screens || []).find(s => s.id === screenId) || ev.screens[0];
  if (!scr) return '';
  const effHtml = (scr.effects && scr.effects.length)
    ? '<div class="ev-sim-effs">' + scr.effects.map(ef => '<span class="ev-eff-pill">✦ ' + html(ef) + '</span>').join('') + '</div>'
    : '';
  const optsHtml = (scr.options || []).map((opt, idx) => {
    const nextList = opt.targets && opt.targets.length ? opt.targets : [];
    if (nextList.length > 1) {
      return nextList.map((tid, ti) =>
        '<button class="ev-opt-btn' + (opt.special ? ' is-special' : '') + '" data-ev-jump="' + escapeAttr(tid) + '">' +
        '<span>' + html(opt.text) + '</span>' +
        '<span class="ev-opt-tag">' + (ti === 0 ? '分支一：' : '分支二：') + html(tid) + '</span></button>'
      ).join('');
    }
    const target = nextList[0] || '__END__';
    const badge = opt.special ? '出身/专属分支' : (target === '__END__' ? '结束事件' : '进入结果 ▸');
    return '<button class="ev-opt-btn' + (opt.special ? ' is-special' : '') + '" data-ev-jump="' + escapeAttr(target) + '">' +
      '<span>' + html(opt.text) + '</span><span class="ev-opt-tag">' + badge + '</span></button>';
  }).join('');

  return '<div class="ev-sim-stage" id="wx-ev-sim-box">' +
    '<div class="ev-sim-bar"><span>当前幕次：<code>' + html(scr.id) + '</code>（共 ' + ev.screens.length + ' 幕）</span>' +
    '<span>' +
    (scr.id !== 'A' ? '<button class="nar-pill-btn" data-ev-jump="A" style="padding:2px 8px;font-size:11.5px">↺ 返回开场重选</button> ' : '') +
    '<button class="nar-pill-btn" data-ev-full="' + escapeAttr(ev.id) + '" style="padding:2px 8px;font-size:11.5px">展开全部剧情幕次</button>' +
    '</span></div>' +
    '<div class="ev-sim-text">' + wxRenderRichEventText(scr.text) + '</div>' +
    effHtml +
    '<div class="ev-sim-opts">' + (optsHtml || '<button class="ev-opt-btn" data-ev-jump="A"><span>返回开场重看其他选项</span><span class="ev-opt-tag">↺</span></button>') + '</div>' +
    '</div>';
}

function showEventPlay(ev, screenId) {
  if (!ev) return;
  wxSimEventId = ev.id;
  wxSimScreenId = screenId || 'A';
  const rows = [
    ['事件编号', '<code>' + html(ev.id) + '</code> · <code>' + html(ev.file) + '</code>'],
    ['所属分卷', html(ev.categoryLabel) + ' · 冷却 ' + ev.cooldownDays + ' 游戏日'],
    ['触发条件', html((ev.triggers || []).join(' ｜ '))]
  ];
  openDialog('【试玩】' + ev.title, rows, '#v=events', renderEventSimStage(ev, wxSimScreenId));
  const srcLink = element('detail-source');
  if (srcLink) srcLink.hidden = true;
}

function showEventFull(ev) {
  if (!ev) return;
  const rows = [
    ['事件编号', '<code>' + html(ev.id) + '</code> · <code>' + html(ev.file) + '</code>'],
    ['所属分卷', html(ev.categoryLabel) + ' · 冷却 ' + ev.cooldownDays + ' 游戏日'],
    ['触发条件', html((ev.triggers || []).join(' ｜ '))]
  ];
  const jumpBtn = '<div style="margin:6px 0 10px"><button class="nar-pill-btn" data-ev-play="' + escapeAttr(ev.id) + '">▶ 切换为交互试玩模式</button></div>';
  const body = jumpBtn + (ev.screens || []).map(scr => {
    const effs = (scr.effects && scr.effects.length)
      ? '<div class="ev-full-effs">' + scr.effects.map(ef => '<span class="ev-full-eff">' + html(ef) + '</span>').join('') + '</div>'
      : '';
    const opts = (scr.options && scr.options.length)
      ? '<ol class="ev-full-opts">' + scr.options.map(o =>
          '<li>' + (o.special ? '<strong>[专属]</strong> ' : '') + html(o.text) +
          (o.targets && o.targets.length ? ' → <code>' + html(o.targets.join(' / ')) + '</code>' : ' → <em>结束</em>') +
          '</li>').join('') + '</ol>'
      : '';
    return '<section class="ev-full-screen"><h4><span>幕次 ' + html(scr.id) + (scr.id === 'A' ? '（开场遭遇）' : '（结局分支）') + '</span></h4>' +
      '<p>' + wxRenderRichEventText(scr.text) + '</p>' + effs + opts + '</section>';
  }).join('');
  openDialog('【全剧本】' + ev.title, rows, '#v=events', body);
  const srcLink = element('detail-source');
  if (srcLink) srcLink.hidden = true;
}
// === NARRATIVE_WIKI_END ==="""


def main():
    pills = parse_pills()
    sects = parse_sects()
    bgs = parse_backgrounds()
    name_pools, bg_names = parse_names()
    bios = parse_bios(bgs)

    events = []
    for ef in sorted(EVENTS_DIR.glob("wx_event_*.nut")):
        events.append(parse_event_file(ef, bgs, pills, sects))

    bg_list = sorted(bgs.values(), key=lambda x: (x["tier"], x["id"]))
    payload = {
        "summary": {
            "bios": len(bios),
            "backgrounds": len(bg_list),
            "events": len(events),
        },
        "backgrounds": bg_list,
        "namePools": name_pools,
        "bgNames": bg_names,
        "bios": bios,
        "events": events,
    }
    payload_json = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
    print(f"Parsed {len(bios)} bios ({len(bg_list)} backgrounds) and {len(events)} events ({len(payload_json):,} bytes JSON)")

    html_txt = WIKI_PATH.read_text(encoding="utf-8")

    # 1. Inject / update CSS before </style>
    if "/* === NARRATIVE_WIKI_BEGIN === */" in html_txt:
        html_txt = re.sub(
            r"/\* === NARRATIVE_WIKI_BEGIN === \*/[\s\S]*?/\* === NARRATIVE_WIKI_END === \*/",
            lambda _m: NARRATIVE_CSS,
            html_txt,
            count=1,
        )
    else:
        html_txt = html_txt.replace("</style>", NARRATIVE_CSS + "\n</style>", 1)

    # 2. Update .stats header to include 500 bios & 66 events
    if "人物列传 <b>" not in html_txt:
        html_txt = html_txt.replace(
            "<span>原版索引 <b>2,063</b> 篇</span>",
            f"<span>人物列传 <b>{len(bios)}</b> 份 · 江湖事件 <b>{len(events)}</b> 份</span><span>原版索引 <b>2,063</b> 篇</span>",
            1,
        )
    else:
        html_txt = re.sub(
            r"<span>人物列传 <b>\d+</b> 份 · 江湖事件 <b>\d+</b> 份</span>",
            f"<span>人物列传 <b>{len(bios)}</b> 份 · 江湖事件 <b>{len(events)}</b> 份</span>",
            html_txt,
            count=1,
        )

    # 3. Add nav tabs for bios & events right after art tab
    nav_buttons = (
        f'<button data-view="art" aria-pressed="false">美术图鉴</button>'
        f'<button data-view="bios" aria-pressed="false">人物列传 ({len(bios)})</button>'
        f'<button data-view="events" aria-pressed="false">江湖事件 ({len(events)})</button>'
    )
    html_txt = re.sub(
        r'<button data-view="art"[^>]*>美术图鉴</button>(?:<button data-view="bios"[^>]*>[^<]*</button>)?(?:<button data-view="events"[^>]*>[^<]*</button>)?',
        nav_buttons,
        html_txt,
        count=1,
    )

    # 4. Inject / update <script type="application/json" id="narrative-data"> right after art-data
    data_tag = f'<script type="application/json" id="narrative-data">\n{payload_json}\n</script>'
    if 'id="narrative-data"' in html_txt:
        html_txt = re.sub(
            r'<script type="application/json" id="narrative-data">[\s\S]*?</script>',
            lambda _m: data_tag,
            html_txt,
            count=1,
        )
    else:
        html_txt = re.sub(
            r'(<script type="application/json" id="art-data">[\s\S]*?</script>)',
            lambda m: m.group(1) + "\n" + data_tag,
            html_txt,
            count=1,
        )

    # 5. Update blankState, views, readUrl
    html_txt = re.sub(
        r"const blankState = \(\) => \(\{[^}]+\}\);",
        "const blankState = () => ({v:'systems',g:0,q:'',r:'',k:'',t:'',a:'',c:'',as:'',ag:'',ast:'',bt:'',bg:'',ec:'',p:1});",
        html_txt,
        count=1,
    )
    html_txt = re.sub(
        r"const views=\[[^\]]+\];",
        "const views=['systems','entries','articles','additions','art','bios','events'];",
        html_txt,
        count=1,
    )
    if "const bt=p.get('bt')" not in html_txt:
        html_txt = html_txt.replace(
            "const as=p.get('as')||''; const ag=p.get('ag')||''; const ast=p.get('ast')||'';",
            "const as=p.get('as')||''; const ag=p.get('ag')||''; const ast=p.get('ast')||'';\n  const bt=p.get('bt')||''; const bg=p.get('bg')||''; const ec=p.get('ec')||'';",
            1,
        )
    if "bt:v==='bios'" not in html_txt:
        html_txt = html_txt.replace(
            "as:v==='art'?as:'',ag:v==='art'?ag:'',ast:v==='art'?ast:'',",
            "as:v==='art'?as:'',ag:v==='art'?ag:'',ast:v==='art'?ast:'',\n    bt:v==='bios'?bt:'',bg:v==='bios'?bg:'',ec:v==='events'?ec:'',",
            1,
        )

    # 6. Inject / update NARRATIVE_JS right after ART_STUDIO_END
    if "// === NARRATIVE_WIKI_BEGIN ===" in html_txt:
        html_txt = re.sub(
            r"// === NARRATIVE_WIKI_BEGIN ===[\s\S]*?// === NARRATIVE_WIKI_END ===",
            lambda _m: NARRATIVE_JS,
            html_txt,
            count=1,
        )
    else:
        html_txt = html_txt.replace(
            "// === ART_STUDIO_END ===",
            "// === ART_STUDIO_END ===\n\n" + NARRATIVE_JS,
            1,
        )

    # 7. Hook render() for bios & events views
    if "else if(state.v==='bios')" not in html_txt:
        html_txt = html_txt.replace(
            "  if(state.v!=='art') element('mobile-group').value=String(state.g);",
            "  if(state.v!=='art'&&state.v!=='bios'&&state.v!=='events') element('mobile-group').value=String(state.g);",
            1,
        )
        html_txt = html_txt.replace(
            "  } else if(state.v==='art') {\n"
            "    const found=matchingArtAssets(query);\n"
            "    const readyCnt=found.filter(a=>a.status!=='planned').length;\n"
            "    const stageObj=artStages.find(s=>s.id===state.as);\n"
            "    cnt.textContent=(stageObj?stageObj.name:'全部美术卷目')+(state.ag?' · '+state.ag:'')+' · 共 '+zhNum(found.length)+' 项（已创制 '+zhNum(readyCnt)+' 项）';\n"
            "    if(state.as||state.ag||state.ast) ctx.innerHTML='<button class=\"scope-clear\" data-art-reset>清除美术筛选</button>';\n"
            "    output=renderArtView(query);\n",
            "  } else if(state.v==='art') {\n"
            "    const found=matchingArtAssets(query);\n"
            "    const readyCnt=found.filter(a=>a.status!=='planned').length;\n"
            "    const stageObj=artStages.find(s=>s.id===state.as);\n"
            "    cnt.textContent=(stageObj?stageObj.name:'全部美术卷目')+(state.ag?' · '+state.ag:'')+' · 共 '+zhNum(found.length)+' 项（已创制 '+zhNum(readyCnt)+' 项）';\n"
            "    if(state.as||state.ag||state.ast) ctx.innerHTML='<button class=\"scope-clear\" data-art-reset>清除美术筛选</button>';\n"
            "    output=renderArtView(query);\n"
            "  } else if(state.v==='bios') {\n"
            "    const found=matchingBios(query);\n"
            "    const bgObj=wxBgById.get(state.bg);\n"
            "    cnt.textContent=(bgObj?bgObj.name:(state.bt!==''?wxTierLabels[state.bt]:'全部 72 种出身'))+' · 共 '+zhNum(found.length)+' 份独立人物列传';\n"
            "    if(state.bt!==''||state.bg) ctx.innerHTML='<button class=\"scope-clear\" data-bio-reset>清除出身筛选</button>';\n"
            "    output=renderBiosView(query);\n"
            "  } else if(state.v==='events') {\n"
            "    const found=matchingEvents(query);\n"
            "    const catObj=wxEventCats.find(c=>c.id===state.ec);\n"
            "    cnt.textContent=(catObj?catObj.label:'全部江湖事件')+' · 共 '+zhNum(found.length)+' 份独立事件脚本';\n"
            "    if(state.ec) ctx.innerHTML='<button class=\"scope-clear\" data-ev-reset>清除事件筛选</button>';\n"
            "    output=renderEventsView(query);\n",
            1,
        )

    # 8. Hook click & input/change listeners for bios & events
    narrative_clicks = (
        "  if(d.bioTier!==undefined) {change({v:'bios',bt:d.bioTier,bg:''});moveTop();return;}\n"
        "  if(d.bioBg!==undefined) {change({v:'bios',bg:d.bioBg});moveTop();return;}\n"
        "  if('bioReset' in d) {change({bt:'',bg:'',q:''});return;}\n"
        "  if(d.bioRoll) {wxRollBioSpotlights(d.bioRoll==='2'?state.bt:(d.bioRoll==='2t'?'2':d.bioRoll),2);render();return;}\n"
        "  if(d.bioDetail) {showBioDetail(wxBios.find(x=>x.id===d.bioDetail));return;}\n"
        "  if(d.evCat!==undefined) {change({v:'events',ec:d.evCat});moveTop();return;}\n"
        "  if('evReset' in d) {change({ec:'',q:''});return;}\n"
        "  if('evRandom' in d) {const pool=matchingEvents(field(state.q));if(pool.length)showEventPlay(pool[Math.floor(Math.random()*pool.length)],'A');return;}\n"
        "  if(d.evPlay) {showEventPlay(wxEventById.get(d.evPlay),'A');return;}\n"
        "  if(d.evFull) {showEventFull(wxEventById.get(d.evFull));return;}\n"
        "  if(d.evJump) {const ev=wxEventById.get(wxSimEventId);if(!ev)return;if(d.evJump==='__END__'){if(element('detail').open)element('detail').close();return;}showEventPlay(ev,d.evJump);return;}\n"
    )
    if "if(d.bioTier!==undefined)" not in html_txt:
        html_txt = html_txt.replace(
            "  if('artStage' in d) {change({v:'art',as:d.artStage,ag:''});moveTop();return;}",
            "  if('artStage' in d) {change({v:'art',as:d.artStage,ag:''});moveTop();return;}\n" + narrative_clicks,
            1,
        )

    if "if(e.target.id==='wx-bio-name-in')" not in html_txt:
        html_txt = html_txt.replace(
            "element('mobile-group').addEventListener('change',e=>state.v==='art'?change({as:e.target.value,ag:''}):change({g:Number(e.target.value),k:'',a:''}));",
            "element('mobile-group').addEventListener('change',e=>state.v==='art'?change({as:e.target.value,ag:''}):state.v==='bios'?change({bt:e.target.value,bg:''}):state.v==='events'?change({ec:e.target.value}):change({g:Number(e.target.value),k:'',a:''}));\n"
            "document.addEventListener('change',e=>{if(e.target&&e.target.id==='wx-bio-bg-sel'){change({v:'bios',bg:e.target.value});}});\n"
            "document.addEventListener('input',e=>{if(e.target&&e.target.id==='wx-bio-name-in'){wxBioCustomName=e.target.value;wxBioSpotlights.forEach(it=>{if(wxBioCustomName.trim())it.name=wxBioCustomName.trim();});const pos=e.target.selectionStart;render();const el=element('wx-bio-name-in');if(el){el.focus();try{el.setSelectionRange(pos,pos);}catch{}}}});",
            1,
        )

    # Update reset handler to support bios/events
    if "state.v==='bios'?{q:'',bt:'',bg:''}" not in html_txt:
        html_txt = html_txt.replace(
            "if('reset' in d){change(state.v==='art'?{q:'',as:'',ag:'',ast:''}:",
            "if('reset' in d){change(state.v==='art'?{q:'',as:'',ag:'',ast:''}:state.v==='bios'?{q:'',bt:'',bg:''}:state.v==='events'?{q:'',ec:''}:",
            1,
        )

    WIKI_PATH.write_text(html_txt, encoding="utf-8")
    print(f"SUCCESS: Injected {len(bios)} bios & {len(events)} events into {WIKI_PATH} ({len(html_txt):,} chars)")


if __name__ == "__main__":
    main()
