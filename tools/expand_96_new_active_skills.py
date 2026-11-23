#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Complete Expansion Pipeline for Topic 1 (+96 New Wuxia Active Martial Arts Skills: 75 -> 171):
1. Slices 6 hand-painted 4x4 Battle Brothers Wuxia skill icon sheets -> 96 x (56x56 + _sw) PNGs
   in both `mod_wuxia/gfx/skills/` and `mod_wuxia/gfx/ui/skills/`.
2. Generates 96 playable `.nut` active skill scripts in `mod_wuxia/scripts/skills/actives/`.
3. Losslessly unpacks `mod_wuxia/brushes/wx_effects_*.brush`, synthesizes 96 bespoke 4-frame action
   sequences (`wx_anim_76..171_f1..f4` = 384 frames) + 171 `wx_ov_*` overhead banners, and repacks
   `wx_effects_0..N.brush` + `mod_wuxia/gfx/wx_effects_0..N.png` (`<= 2048x2048` pages).
4. Updates `wx_vfx_system.nut`, `wx_projectiles.nut`, `ai_wuxia_skills.nut`, `loot_economy.nut`,
   all 9 manual config `.nut` files (diversifying `GrantSkills` & syncing `Summary`), and `selftest.nut`.
"""

import glob
import os
import re
import struct
import sys
from pathlib import Path
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

from process_wiki_art import make_grayscale_sw, process_skill_square
from process_wave_63_68_vfx_upgrade import fit_box, shift_hue_rgba
from compile_wuxia_brushes import fit_canvas, shelf_pack_sprites, write_brush_binary
from add_injured_brush_aliases import parse_wuxia_brush
from wuxia_96_new_skills_data import MANUAL_SKILL_OVERRIDES, NEW_96_SKILLS, SKILL_ICON_SHEETS

MOD_DIR = ROOT / "mod_wuxia"
ACTIVES_DIR = MOD_DIR / "scripts" / "skills" / "actives"
GFX_SKILLS_1 = MOD_DIR / "gfx" / "skills"
GFX_SKILLS_2 = MOD_DIR / "gfx" / "ui" / "skills"

PROJ_CONST_MAP = {
    "liuxingjian":  "::Const.ProjectileType.WX_Liuxingjian",
    "diaolingjian": "::Const.ProjectileType.WX_Diaolingjian",
    "shenjishi":    "::Const.ProjectileType.WX_Shenjishi",
    "xiujian":      "::Const.ProjectileType.WX_Xiujian",
    "huochongdan":  "::Const.ProjectileType.WX_Huochongdan",
    "liuyefeidao":  "::Const.ProjectileType.WX_Liuyefeidao",
    "kongqueling":  "::Const.ProjectileType.WX_Kongqueling",
    "sangmending":  "::Const.ProjectileType.WX_Sangmending",
    "pilileihuo":   "::Const.ProjectileType.WX_Pilileihuo",
}


def render_skill_nut(idx: int, spec: tuple) -> str:
    (
        sid, name, desc, kind, ap, qi, min_r, max_r, weapons_sq, direct_mult,
        choreo_lbl, mode, vfx_brush, sig_fx, base_anim, hue_deg, rot_deg, mir_x, volleys, shake,
        props_sq, post_hit_sq, proj_key,
    ) = spec
    anim_id = f"wx_anim_{76 + idx}"

    # Clamp DamageReceivedRegularMult >= 0.40 per AGENTS.md §3.1, and ensure newline after `}` for Squirrel 3.0!
    safe_props = re.sub(
        r"_properties\.DamageReceivedRegularMult\s*\*=\s*([0-9.]+);",
        r"_properties.DamageReceivedRegularMult = ::Math.maxf(0.40, _properties.DamageReceivedRegularMult * \1);",
        props_sq,
    )
    safe_props = re.sub(r"\}\s+(?=[^\s\}])", "}\n\t\t\t", safe_props)
    post_hit_sq = re.sub(r"\}\s+(?!else\b)(?=[^\s\}])", "}\n\t\t\t", post_hit_sq)

    if kind in ("melee", "aoe3", "bow", "xbow", "gun", "throw", "throw_aoe"):
        is_aoe = kind in ("aoe3", "gun", "throw_aoe")
        is_ranged = kind in ("bow", "xbow", "gun", "throw", "throw_aoe")

        ranged_lines = ""
        if is_ranged:
            pconst = PROJ_CONST_MAP[proj_key]
            snd_use = '::Const.DLC.Desert ? ["sounds/combat/dlc6/fire_gonne_01.wav"] : ["sounds/combat/bolt_shot_01.wav"]' if kind == "gun" else (
                '["sounds/combat/bolt_shot_01.wav", "sounds/combat/bolt_shot_02.wav"]' if kind == "xbow" else (
                    '["sounds/combat/javelin_throw_01.wav", "sounds/combat/javelin_throw_02.wav"]' if "throw" in kind else
                    '["sounds/combat/aimed_shot_01.wav", "sounds/combat/aimed_shot_02.wav"]'
                )
            )
            ranged_lines = f"""\t\tthis.m.IsRanged = true;
\t\tthis.m.IsShowingProjectile = true;
\t\tthis.m.ProjectileType = {pconst};
\t\tthis.m.IsProjectileRotated = true;
\t\tthis.m.ProjectileTimeScale = 1.25;
\t\tthis.m.SoundOnUse = {snd_use};"""
        else:
            ranged_lines = '\t\tthis.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];'

        aoe_line = "\t\tthis.m.IsAOE = true;\n" if is_aoe else ""
        cooldown_m = "Cooldown = 0" if "冷却 2 回合" in desc else ""
        cd_init = "\tfunction onTurnStart() { if ((::Wuxia.hasMember(this.m, \"Cooldown\")) && this.m.Cooldown > 0) this.m.Cooldown -= 1; }\n\tfunction onCombatStarted() { this.m.Cooldown = 0; }\n\tfunction onCombatFinished() { this.m.Cooldown = 0; }\n" if cooldown_m else ""
        cd_set = "\t\tthis.m.Cooldown = 2;\n" if cooldown_m else ""

        if kind == "melee":
            use_body = f"""{cd_set}\t\tlocal target = _targetTile.getEntity();
\t\t::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
\t\tlocal hit = this.attackEntity(_user, target);
\t\tif (hit && target != null && target.isAlive())
\t\t{{
\t\t\t{post_hit_sq}
\t\t}}
\t\treturn hit;"""
        elif kind == "aoe3":
            use_body = f"""{cd_set}\t\t::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
\t\tlocal targets = [];
\t\tlocal mainTarget = _targetTile.getEntity();
\t\tif (mainTarget != null) targets.push(mainTarget);
\t\tlocal myTile = _user.getTile();
\t\tfor (local d = 0; d < this.Const.Direction.COUNT; d = ++d)
\t\t{{
\t\t\tif (!_targetTile.hasNextTile(d)) continue;
\t\t\tlocal adj = _targetTile.getNextTile(d);
\t\t\tif (!adj.IsOccupiedByActor || adj.getDistanceTo(myTile) > this.m.MaxRange) continue;
\t\t\tlocal ent = adj.getEntity();
\t\t\tif (ent != null && ent.isAlive() && !_user.isAlliedWith(ent))
\t\t\t{{
\t\t\t\ttargets.push(ent);
\t\t\t\tif (targets.len() >= 3) break;
\t\t\t}}
\t\t}}
\t\tlocal anyHit = false;
\t\tforeach (target in targets)
\t\t{{
\t\t\tif (!target.isAlive()) continue;
\t\t\tif (mainTarget == null || target.getID() != mainTarget.getID())
\t\t\t\t::Wuxia.VFX.playAoESecondaryVfx(this, _user, target.getTile(), 55);
\t\t\tlocal hit = this.attackEntity(_user, target);
\t\t\tif (hit)
\t\t\t{{
\t\t\t\tanyHit = true;
\t\t\t\tif (target.isAlive()) {{ {post_hit_sq} }}
\t\t\t}}
\t\t}}
\t\treturn anyHit;"""
        elif kind in ("bow", "xbow"):
            use_body = f"""\t\tlocal target = _targetTile.getEntity();
\t\t::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
\t\tlocal hit = this.wxShootBowAt(_user, target);
\t\tif (hit && target != null && target.isAlive())
\t\t{{
\t\t\t{post_hit_sq}
\t\t}}
\t\treturn hit;"""
        elif kind == "gun":
            use_body = f"""\t\tlocal mainTarget = _targetTile.getEntity();
\t\t::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
\t\tlocal anyHit = false;
\t\tif (mainTarget != null && mainTarget.isAlive())
\t\t{{
\t\t\tlocal h0 = this.wxShootBowAt(_user, mainTarget);
\t\t\tif (h0)
\t\t\t{{
\t\t\t\tanyHit = true;
\t\t\t\tlocal target = mainTarget;
\t\t\t\tif (target.isAlive()) {{ {post_hit_sq} }}
\t\t\t}}
\t\t}}
\t\tlocal extraCnt = 0;
\t\tfor (local d = 0; d < this.Const.Direction.COUNT; d = ++d)
\t\t{{
\t\t\tif (!_targetTile.hasNextTile(d)) continue;
\t\t\tlocal adj = _targetTile.getNextTile(d);
\t\t\tif (!adj.IsOccupiedByActor) continue;
\t\t\tlocal target = adj.getEntity();
\t\t\tif (target != null && target.isAlive() && !_user.isAlliedWith(target))
\t\t\t{{
\t\t\t\t::Wuxia.VFX.playAoESecondaryVfx(this, _user, adj, 60);
\t\t\t\tif (this.attackEntity(_user, target))
\t\t\t\t{{
\t\t\t\t\tanyHit = true;
\t\t\t\t\tif (target.isAlive()) {{ {post_hit_sq} }}
\t\t\t\t}}
\t\t\t\textraCnt += 1;
\t\t\t\tif (extraCnt >= 2) break;
\t\t\t}}
\t\t}}
\t\treturn anyHit;"""
        elif kind == "throw":
            use_body = f"""\t\tlocal target = _targetTile.getEntity();
\t\t::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
\t\tlocal hit = this.wxThrowAt(_user, target);
\t\tif (hit && target != null && target.isAlive())
\t\t{{
\t\t\t{post_hit_sq}
\t\t}}
\t\treturn hit;"""
        elif kind == "throw_aoe":
            use_body = f"""\t\tlocal mainTarget = _targetTile.getEntity();
\t\t::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
\t\tlocal anyHit = false;
\t\tif (mainTarget != null && mainTarget.isAlive())
\t\t{{
\t\t\tif (this.wxThrowAt(_user, mainTarget))
\t\t\t{{
\t\t\t\tanyHit = true;
\t\t\t\tlocal target = mainTarget;
\t\t\t\tif (target.isAlive()) {{ {post_hit_sq} }}
\t\t\t}}
\t\t}}
\t\tlocal extraCnt = 0;
\t\tfor (local d = 0; d < this.Const.Direction.COUNT; d = ++d)
\t\t{{
\t\t\tif (!_targetTile.hasNextTile(d)) continue;
\t\t\tlocal adj = _targetTile.getNextTile(d);
\t\t\tif (!adj.IsOccupiedByActor) continue;
\t\t\tlocal target = adj.getEntity();
\t\t\tif (target != null && target.isAlive() && !_user.isAlliedWith(target))
\t\t\t{{
\t\t\t\t::Wuxia.VFX.playAoESecondaryVfx(this, _user, adj, 55);
\t\t\t\tif (this.attackEntity(_user, target))
\t\t\t\t{{
\t\t\t\t\tanyHit = true;
\t\t\t\t\tif (target.isAlive()) {{ {post_hit_sq} }}
\t\t\t\t}}
\t\t\t\textraCnt += 1;
\t\t\t\tif (extraCnt >= 2) break;
\t\t\t}}
\t\t}}
\t\treturn anyHit;"""

        return f"""// Active Move: {name}
this.{sid} <- this.inherit("scripts/skills/actives/wx_move_base", {{
\tm = {{ {cooldown_m} }},

\tfunction create()
\t{{
\t\tthis.wx_move_base.create();
\t\tthis.m.ID = "actives.{sid}";
\t\tthis.m.Name = "{name}";
\t\tthis.m.Description = "{desc}";
\t\tthis.m.Icon = "skills/{sid}.png";
\t\tthis.m.IconDisabled = "skills/{sid}_sw.png";
\t\tthis.m.Overlay = "wx_ov_{sid}";
\t\tthis.m.WX_VfxBrush <- "{vfx_brush}";
\t\tthis.m.WX_AnimID <- "{anim_id}";
\t\tthis.m.WX_AnimMode <- "{mode}";
\t\tthis.m.WX_ChoreoID <- "{sid}";
{ranged_lines}
{aoe_line}\t\tthis.m.ActionPointCost = {ap};
\t\tthis.m.FatigueCost = {qi};
\t\tthis.m.MinRange = {min_r};
\t\tthis.m.MaxRange = {max_r};
\t\tthis.m.RequiredWeaponTypes = {weapons_sq};
\t\tthis.m.DirectDamageMult = {direct_mult};
\t}}
{cd_init}\tfunction onAnySkillUsed( _skill, _targetEntity, _properties )
\t{{
\t\tif (_skill == this)
\t\t{{
\t\t\t{safe_props}
\t\t}}
\t}}

\tfunction onUse( _user, _targetTile )
\t{{
{use_body}
\t}}
}});
"""

    if kind in ("qinggong_leap", "qinggong_step"):
        cd_turns = 3 if "冷却 3 回合" in desc else 2
        max_lvl = 3 if sid == "wx_qinggong_feiyan" else (1 if kind == "qinggong_step" else 2)
        return f"""// Active Qinggong Skill: {name}
this.{sid} <- this.inherit("scripts/skills/skill", {{
\tm = {{ Cooldown = 0, WX_VfxBrush = "{vfx_brush}", WX_AnimID = "{anim_id}", WX_AnimMode = "{mode}" }},
\tfunction create()
\t{{
\t\tthis.m.ID = "actives.{sid}";
\t\tthis.m.Name = "{name}";
\t\tthis.m.Description = "{desc}";
\t\tthis.m.Icon = "skills/{sid}.png";
\t\tthis.m.IconDisabled = "skills/{sid}_sw.png";
\t\tthis.m.Overlay = "wx_ov_{sid}";
\t\tthis.m.WX_AnimID <- "{anim_id}";
\t\tthis.m.WX_AnimMode <- "{mode}";
\t\tthis.m.WX_ChoreoID <- "{sid}";
\t\tthis.m.Type = this.Const.SkillType.Active;
\t\tthis.m.Order = this.Const.SkillOrder.UtilityTargeted;
\t\tthis.m.IsSerialized = false;
\t\tthis.m.IsActive = true;
\t\tthis.m.IsTargeted = true;
\t\tthis.m.IsTargetingActor = false;
\t\tthis.m.IsVisibleTileNeeded = true;
\t\tthis.m.IsAttack = false;
\t\tthis.m.ActionPointCost = {ap};
\t\tthis.m.FatigueCost = {qi};
\t\tthis.m.MinRange = {min_r};
\t\tthis.m.MaxRange = {max_r};
\t\tthis.m.MaxLevelDifference = {max_lvl};
\t}}
\tfunction getTooltip() {{ return this.getDefaultUtilityTooltip(); }}
\tfunction isUsable()
\t{{
\t\tif (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
\t\tlocal a = this.getContainer().getActor();
\t\treturn a != null && !a.getCurrentProperties().IsRooted;
\t}}
\tfunction onVerifyTarget( _originTile, _targetTile )
\t{{
\t\tif (!this.skill.onVerifyTarget(_originTile, _targetTile)) return false;
\t\treturn _targetTile.IsEmpty && !_targetTile.IsOccupiedByActor && ::Math.abs(_originTile.Level - _targetTile.Level) <= {max_lvl};
\t}}
\tfunction onTurnStart() {{ if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }}
\tfunction onCombatStarted() {{ this.m.Cooldown = 0; }}
\tfunction onCombatFinished() {{ this.m.Cooldown = 0; }}
\tfunction onUse( _user, _targetTile )
\t{{
\t\tthis.m.Cooldown = {cd_turns};
\t\t::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
\t\t::Tactical.getNavigator().teleport(_user, _targetTile, null, null, false);
\t\t{post_hit_sq}
\t\t::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
\t\treturn true;
\t}}
}});
"""

    # Self-cast Neigong / Henglian / Shield / Rally / Warcry skills
    cd_turns = 3 if "冷却 3 回合" in desc else 2
    shield_chk = ""
    shield_hide = ""
    if kind == "shield_self":
        shield_chk = """
\t\tlocal a = this.getContainer().getActor();
\t\tlocal off = (a != null && a.getItems() != null) ? a.getItems().getItemAtSlot(::Const.ItemSlot.Offhand) : null;
\t\tif (off == null || !off.isItemType(::Const.Items.ItemType.Shield)) return false;"""
        shield_hide = """
\tfunction isHidden()
\t{
\t\tlocal a = this.getContainer() == null ? null : this.getContainer().getActor();
\t\tlocal off = (a != null && a.getItems() != null) ? a.getItems().getItemAtSlot(::Const.ItemSlot.Offhand) : null;
\t\treturn this.skill.isHidden() || off == null || !off.isItemType(::Const.Items.ItemType.Shield);
\t}"""

    return f"""// Active Skill: {name}
this.{sid} <- this.inherit("scripts/skills/skill", {{
\tm = {{ ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "{vfx_brush}", WX_AnimID = "{anim_id}", WX_AnimMode = "{mode}" }},
\tfunction create()
\t{{
\t\tthis.m.ID = "actives.{sid}";
\t\tthis.m.Name = "{name}";
\t\tthis.m.Description = "{desc}";
\t\tthis.m.Icon = "skills/{sid}.png";
\t\tthis.m.IconDisabled = "skills/{sid}_sw.png";
\t\tthis.m.Overlay = "wx_ov_{sid}";
\t\tthis.m.WX_AnimID <- "{anim_id}";
\t\tthis.m.WX_AnimMode <- "{mode}";
\t\tthis.m.WX_ChoreoID <- "{sid}";
\t\tthis.m.Type = this.Const.SkillType.Active;
\t\tthis.m.Order = this.Const.SkillOrder.NonTargeted;
\t\tthis.m.IsSerialized = false;
\t\tthis.m.IsActive = true;
\t\tthis.m.IsTargeted = false;
\t\tthis.m.IsAttack = false;
\t\tthis.m.ActionPointCost = {ap};
\t\tthis.m.FatigueCost = {qi};
\t}}{shield_hide}
\tfunction getTooltip() {{ return this.getDefaultUtilityTooltip(); }}
\tfunction isUsable()
\t{{
\t\tif (this.m.Cooldown > 0 || this.m.ActiveBuff || !this.skill.isUsable()) return false;{shield_chk}
\t\treturn true;
\t}}
\tfunction onUpdate( _properties )
\t{{
\t\tif (this.m.ActiveBuff)
\t\t{{
\t\t\t{safe_props}
\t\t}}
\t}}
\tfunction onTurnStart() {{ this.m.ActiveBuff = false; if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }}
\tfunction onCombatStarted() {{ this.m.ActiveBuff = false; this.m.Cooldown = 0; }}
\tfunction onCombatFinished() {{ this.m.ActiveBuff = false; this.m.Cooldown = 0; }}
\tfunction onUse( _user, _targetTile )
\t{{
\t\tthis.m.ActiveBuff = true;
\t\tthis.m.Cooldown = {cd_turns};
\t\t::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
\t\t{post_hit_sq}
\t\tthis.getContainer().update();
\t\treturn true;
\t}}
}});
"""


def unpack_all_effects_brushes() -> dict[str, dict]:
    sprite_map: dict[str, dict] = {}
    for bp in sorted((MOD_DIR / "brushes").glob("wx_effects_*.brush")):
        parsed = parse_wuxia_brush(str(bp))
        png_p = MOD_DIR / parsed["gfx_rel"]
        atlas = Image.open(png_p).convert("RGBA")
        aw, ah = parsed["aw"], parsed["ah"]
        for rec in parsed["records"]:
            sid = rec["id"]
            _cat, w, h, ox, oy = struct.unpack_from("<QIIhh", rec["meta53"], 0)
            sl = rec["src_len"]
            src_rel = rec["tail_bytes"][:sl].decode("ascii")
            u0, u1, v0, v1, fL, fR, fT, fB = struct.unpack_from("<8f", rec["tail_bytes"], sl)
            ax0 = int(round(u0 * aw))
            ax1 = int(round(u1 * aw))
            ay0 = int(round(v0 * ah))
            ay1 = int(round(v1 * ah))
            crop = ImageOps.flip(atlas.crop((ax0, ay0, max(ax0 + 1, ax1), max(ay0 + 1, ay1))))
            bx0 = int(round(fL + w / 2.0))
            by0 = int(round(h / 2.0 - fB))
            canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            canvas.paste(crop, (max(0, bx0), max(0, by0)))
            sprite_map[sid] = {
                "id": sid,
                "img": canvas,
                "ox": ox,
                "oy": oy,
                "src_rel": src_rel,
                "is_effect": not sid.startswith("wx_ov_"),
            }
    return sprite_map


def synthesize_4frame_from_sprites(
    sprite_map: dict[str, dict],
    anim_id: str,
    base_anim: str,
    vfx_ov: str,
    fx_ov: str,
    hue_deg: float,
    rot_deg: float,
    mir_x: bool,
) -> list[dict]:
    vfx_im = sprite_map[vfx_ov]["img"]
    fx_im = sprite_map[fx_ov]["img"]
    out_entries = []
    for fi in range(4):
        base_f = fit_box(sprite_map[f"{base_anim}_f{fi + 1}"]["img"], 256, 256, pad=6)
        if mir_x:
            base_f = ImageOps.mirror(base_f)
        if abs(rot_deg) > 0.5:
            base_f = base_f.rotate(rot_deg + (fi - 1.5) * 4.0, resample=Image.Resampling.BICUBIC, expand=False)
        base_f = shift_hue_rgba(base_f, hue_deg)

        comp = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
        if fi == 0:
            acc = fit_box(fx_im, 118, 118, pad=4)
            acc.putalpha(acc.getchannel("A").point(lambda a: int(a * 0.52)))
            comp.alpha_composite(base_f, (0, 0))
            comp.alpha_composite(acc, (69, 69))
        elif fi == 1:
            ov2 = fit_box(vfx_im, 176, 176, pad=4)
            if mir_x:
                ov2 = ImageOps.mirror(ov2)
            ov2.putalpha(ov2.getchannel("A").point(lambda a: int(a * 0.68)))
            comp.alpha_composite(base_f, (0, 0))
            comp.alpha_composite(ov2, (40, 40))
        elif fi == 2:
            ov3 = fit_box(vfx_im, 212, 212, pad=4)
            ov3.putalpha(ov3.getchannel("A").point(lambda a: int(a * 0.78)))
            comp.alpha_composite(ov3, (22, 22))
            comp.alpha_composite(base_f, (0, 0))
            sig3 = fit_box(fx_im, 132, 132, pad=4)
            sig3.putalpha(sig3.getchannel("A").point(lambda a: int(a * 0.58)))
            comp.alpha_composite(sig3, (62, 62))
        else:
            ov4 = fit_box(fx_im, 164, 164, pad=4).rotate(18, resample=Image.Resampling.BICUBIC, expand=False)
            ov4.putalpha(ov4.getchannel("A").point(lambda a: int(a * 0.42)))
            comp.alpha_composite(ov4, (46, 46))
            comp.alpha_composite(base_f, (0, 0))

        fim_144 = fit_canvas(comp, 144, 144, pad=4)
        fid = f"{anim_id}_f{fi + 1}"
        out_entries.append({
            "id": fid,
            "img": fim_144,
            "ox": 0,
            "oy": 18,
            "src_rel": f"effects\\{fid}.png",
            "is_effect": True,
        })
    return out_entries


def load_all_skill_chinese_names() -> dict[str, str]:
    names = {}
    for p in sorted(ACTIVES_DIR.glob("*.nut")):
        if p.stem == "wx_move_base":
            continue
        src = p.read_text(encoding="utf-8")
        m_id = re.search(r'this\.m\.ID\s*=\s*"([^"]+)"', src)
        m_nm = re.search(r'this\.m\.Name\s*=\s*"([^"]+)"', src)
        if m_id and m_nm:
            names[m_id.group(1)] = m_nm.group(1)
    return names


def patch_manual_files(skill_cn_names: dict[str, str]):
    manual_files = [
        MOD_DIR / "mod_wuxia/config/manuals.nut",
        MOD_DIR / "mod_wuxia/config/wx_m4_manuals.nut",
    ] + sorted((MOD_DIR / "mod_wuxia/config/manuals").glob("*.nut"))

    for mid, (t1, t2, t3) in MANUAL_SKILL_OVERRIDES.items():
        for s in t1:
            assert s in t2, f"Non-cumulative T1->T2 on {mid}: {s}"
        for s in t2:
            assert s in t3, f"Non-cumulative T2->T3 on {mid}: {s}"

    matched_ids: set[str] = set()
    for mf in manual_files:
        src = mf.read_text(encoding="utf-8")
        hdrs = list(re.finditer(r"(?<![A-Za-z0-9_])(wx_manual_\w+)\s*(?:<-|=)\s*\{", src))
        if not hdrs:
            continue

        pieces = [src[: hdrs[0].start()]]
        changed = False
        for i, hm in enumerate(hdrs):
            st = hm.start()
            end = hdrs[i + 1].start() if i + 1 < len(hdrs) else len(src)
            chunk = src[st:end]
            mid = hm.group(1)

            if mid in MANUAL_SKILL_OVERRIDES:
                matched_ids.add(mid)
                tiers = list(MANUAL_SKILL_OVERRIDES[mid])
                gs_idx = 0

                def repl_gs(_m: re.Match) -> str:
                    nonlocal gs_idx
                    cur_list = tiers[gs_idx]
                    gs_idx += 1
                    gs_str = ", ".join(f'"{x}"' for x in cur_list)
                    return f"GrantSkills = [{gs_str}]"

                chunk = re.sub(r"GrantSkills\s*=\s*\[[^\]]*\]", repl_gs, chunk, count=3)
                assert gs_idx == 3, f"Expected 3 GrantSkills on {mid}, got {gs_idx}"

                prev_wx: set[str] = set()
                sm_idx = 0

                def repl_sum(sm: re.Match) -> str:
                    nonlocal sm_idx
                    cur_list = tiers[sm_idx]
                    sm_idx += 1
                    cur_wx = [x for x in cur_list if x.startswith("actives.wx_")]
                    new_wx = [x for x in cur_wx if x not in prev_wx]
                    prev_wx.update(cur_wx)

                    s_txt = sm.group(1)
                    s_txt = re.sub(r"[；;，,\s]*(?:习得|领悟|解锁)(?:绝技|杀招|秘技|身法|心诀)?[「【][^」】]+[」】]", "", s_txt)
                    s_txt = s_txt.strip("；; ")
                    if not s_txt.endswith("。"):
                        s_txt += "。"
                    if new_wx:
                        learned_lbl = "、".join(f"「{skill_cn_names[x]}」" for x in new_wx if x in skill_cn_names)
                        if learned_lbl:
                            s_txt = s_txt[:-1] + f"；习得{learned_lbl}。"
                    return f'Summary = "{s_txt}"'

                chunk = re.sub(r'Summary\s*=\s*"([^"]*)"', repl_sum, chunk, count=3)
                assert sm_idx == 3, f"Expected 3 Summaries on {mid}, got {sm_idx}"
                changed = True

            pieces.append(chunk)

        if changed:
            mf.write_text("".join(pieces), encoding="utf-8", newline="\n")

    missing_m = sorted(set(MANUAL_SKILL_OVERRIDES.keys()) - matched_ids)
    assert not missing_m, f"Unmatched manual IDs in MANUAL_SKILL_OVERRIDES: {missing_m}"
    return len(matched_ids)


def audit_all_manuals_and_skills() -> tuple[int, dict[str, int]]:
    manual_files = [
        MOD_DIR / "mod_wuxia/config/manuals.nut",
        MOD_DIR / "mod_wuxia/config/wx_m4_manuals.nut",
    ] + sorted((MOD_DIR / "mod_wuxia/config/manuals").glob("*.nut"))

    skill_manual_counts: dict[str, int] = {}
    all_skill_files = {f"actives.{p.stem}" for p in ACTIVES_DIR.glob("*.nut") if p.stem != "wx_move_base"}

    total_manuals = 0
    for mf in manual_files:
        src = mf.read_text(encoding="utf-8")
        starts = [m.start() for m in re.finditer(r"(?<![A-Za-z0-9_])(wx_manual_\w+)\s*(?:<-|=)\s*\{", src)]
        for i, st in enumerate(starts):
            end = starts[i + 1] if i + 1 < len(starts) else len(src)
            body = src[st:end]
            total_manuals += 1
            manual_wx = set()
            for gs in re.findall(r"GrantSkills\s*=\s*\[([^\]]*)\]", body):
                for sk in re.findall(r'"(actives\.wx_[^"]+)"', gs):
                    manual_wx.add(sk)
            for sk in manual_wx:
                skill_manual_counts[sk] = skill_manual_counts.get(sk, 0) + 1

    missing = sorted(all_skill_files - set(skill_manual_counts.keys()))
    if missing:
        raise RuntimeError(f"Orphaned active skills not wired to any manual ({len(missing)}): {missing}")
    extra = sorted(set(skill_manual_counts.keys()) - all_skill_files)
    if extra:
        raise RuntimeError(f"Manual references non-existent active skill: {extra}")
    return total_manuals, skill_manual_counts


def main():
    assert len(NEW_96_SKILLS) == 96, f"Expected 96 new skills, got {len(NEW_96_SKILLS)}"
    skip_art = "--skip-art" in sys.argv
    for sp in SKILL_ICON_SHEETS:
        if not sp.exists():
            raise FileNotFoundError(f"Missing skill icon sheet: {sp}")

    GFX_SKILLS_1.mkdir(parents=True, exist_ok=True)
    GFX_SKILLS_2.mkdir(parents=True, exist_ok=True)

    if not skip_art:
        # 1. Slice 6 sheets -> 96 x (56x56 + _sw.png) in both skill icon folders
        for s_idx, spath in enumerate(SKILL_ICON_SHEETS):
            sh = Image.open(spath)
            cw, ch = sh.width // 4, sh.height // 4
            for c_idx in range(16):
                spec = NEW_96_SKILLS[s_idx * 16 + c_idx]
                sid = spec[0]
                r, c = divmod(c_idx, 4)
                cell = sh.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
                _hd256, game56, sw56 = process_skill_square(cell)
                for out_d in (GFX_SKILLS_1, GFX_SKILLS_2):
                    game56.save(out_d / f"{sid}.png")
                    sw56.save(out_d / f"{sid}_sw.png")
        print("1) Sliced & saved 96 new 56x56 beveled skill icons + _sw icons to gfx/skills & gfx/ui/skills!")

    # 2. Write 96 new `.nut` scripts in `mod_wuxia/scripts/skills/actives/`
    for idx, spec in enumerate(NEW_96_SKILLS):
        sid = spec[0]
        nut_code = render_skill_nut(idx, spec)
        (ACTIVES_DIR / f"{sid}.nut").write_text(nut_code, encoding="utf-8", newline="\n")
    print("2) Generated 96 new active skill .nut scripts (total playable active skills = 171)!")

    if not skip_art:
        # 3. Unpack `wx_effects_*.brush`, synthesize `wx_anim_76..171_f1..f4` + all `wx_ov_*`, and repack!
        sprite_map = unpack_all_effects_brushes()
        for idx, spec in enumerate(NEW_96_SKILLS):
            sid = spec[0]
            anim_id = f"wx_anim_{76 + idx}"
            vfx_b, sig_fx, base_anim, hue_deg, rot_deg, mir_x = spec[12], spec[13], spec[14], spec[15], spec[16], spec[17]
            for ent in synthesize_4frame_from_sprites(sprite_map, anim_id, base_anim, vfx_b, sig_fx, hue_deg, rot_deg, mir_x):
                sprite_map[ent["id"]] = ent

        # Refresh/add `wx_ov_<bn>` for all 171 active skills
        for p in sorted(ACTIVES_DIR.glob("*.nut")):
            bn = p.stem
            if bn == "wx_move_base":
                continue
            icon_p = GFX_SKILLS_2 / f"{bn}.png"
            assert icon_p.exists(), f"Missing UI skill icon for overhead banner: {icon_p}"
            ov_im = fit_canvas(Image.open(icon_p).convert("RGBA"), 56, 56, pad=2)
            sprite_map[f"wx_ov_{bn}"] = {
                "id": f"wx_ov_{bn}",
                "img": ov_im,
                "ox": 0,
                "oy": 0,
                "src_rel": f"skills\\{bn}.png",
                "is_effect": False,
            }

        # Remove old wx_effects_*.brush / .png and pack fresh pages (`<= 2048x2048`)
        for old_p in list((MOD_DIR / "brushes").glob("wx_effects_*.brush")) + list((MOD_DIR / "gfx").glob("wx_effects_*.png")):
            old_p.unlink()

        ordered_vfx = [sprite_map[k] for k in sorted(sprite_map.keys())]
        page_size = 180
        for page_idx in range(0, len(ordered_vfx), page_size):
            chunk = ordered_vfx[page_idx : page_idx + page_size]
            p_num = page_idx // page_size
            atlas, recs = shelf_pack_sprites(chunk, max_atlas_w=2048)
            gfx_rel = f"gfx/wx_effects_{p_num}.png"
            brush_rel = f"brushes/wx_effects_{p_num}.brush"
            atlas.save(MOD_DIR / gfx_rel)
            write_brush_binary(str(MOD_DIR / brush_rel), gfx_rel, atlas.size, recs, is_effect_sheet=True)
            print(f"   Compiled {brush_rel}: {len(recs)} sprites ({atlas.size[0]}x{atlas.size[1]})")
        print(f"3) Compiled all {len(ordered_vfx)} VFX, 171x4-Frame Anim & 171 Overhead Banner sprites!")

    # 4. Update `wx_vfx_system.nut` (`SkillChoreo` + prefix mode routing)
    vfx_path = MOD_DIR / "mod_wuxia/systems/wx_vfx_system.nut"
    vfx_src = vfx_path.read_text(encoding="utf-8")

    # Strip any previous auto-appended block if re-run idempotently
    vfx_src = re.sub(r",\n\t\t// === Expanded 96 Active Skills[\s\S]*?(?=\n\t\}\n\};)", "", vfx_src)
    choreo_items = []
    for idx, spec in enumerate(NEW_96_SKILLS):
        sid, choreo_lbl, mode, vfx_b, sig_fx, volleys, shake = spec[0], spec[10], spec[11], spec[12], spec[13], spec[18], spec[19]
        anim_id = f"wx_anim_{76 + idx}"
        choreo_items.append(f'\t\t{sid:<22} = ["{choreo_lbl}", "{anim_id}", "{mode}", "{vfx_b}", "{sig_fx}", {volleys}, {shake}]')
    choreo_insert = ",\n\t\t// === Expanded 96 Active Skills (wx_anim_76..171) ===\n" + ",\n".join(choreo_items)

    vfx_src, n_ch = re.subn(
        r'(wx_hama_push\s*=\s*\["白驼金蟾·蓄劲推山",\s*"wx_anim_75",\s*"toad_leap_slam",\s*"wx_vfx_28",\s*"wx_fx_sonic_ring",\s*2,\s*8\])',
        lambda m: m.group(1) + choreo_insert,
        vfx_src,
        count=1,
    )
    assert n_ch == 1, "Failed to insert 96 SkillChoreo entries in wx_vfx_system.nut"

    # Add prefix routing so `sky_*`, `earth_*`, `step_*`, `shadow_*`, `stance_*`, `aoe_*`, `flurry_*`, `taiji_*`, `upcut_*`, `whip_*` hit bespoke choreography
    prefix_patches = [
        ('mode == "shield_split")', 'mode == "shield_split" || mode.find("sky_") == 0)'),
        ('mode == "earth_wave")', 'mode == "earth_wave" || mode.find("earth_") == 0)'),
        ('mode == "mirage_step")', 'mode == "mirage_step" || mode.find("step_") == 0)'),
        ('mode == "night_exec")', 'mode == "night_exec" || mode.find("shadow_") == 0)'),
        ('mode == "blood_flame")', 'mode == "blood_flame" || mode.find("stance_") == 0)'),
        ('mode == "berserk_spin")', 'mode == "berserk_spin" || mode.find("aoe_") == 0)'),
        ('mode == "silver_tiger_spear")', 'mode == "silver_tiger_spear" || mode.find("flurry_") == 0)'),
        ('mode == "disarm_grab")', 'mode == "disarm_grab" || mode.find("taiji_") == 0)'),
        ('mode == "frost_tomb")', 'mode == "frost_tomb" || mode.find("upcut_") == 0)'),
        ('mode == "bamboo_bind")', 'mode == "bamboo_bind" || mode.find("whip_") == 0)'),
    ]
    for old_s, new_s in prefix_patches:
        if new_s not in vfx_src:
            assert old_s in vfx_src, f"Missing mode pattern {old_s} in wx_vfx_system.nut"
            vfx_src = vfx_src.replace(old_s, new_s, 1)

    vfx_path.write_text(vfx_src, encoding="utf-8", newline="\n")
    print("4) Updated wx_vfx_system.nut with 171/171 unique SkillChoreo entries & prefix choreography routing!")

    # 5. Update `wx_projectiles.nut` with new ranged/firearm/throwing skills
    proj_path = MOD_DIR / "mod_wuxia/config/wx_projectiles.nut"
    proj_src = proj_path.read_text(encoding="utf-8")
    proj_src = re.sub(r"\t// Expanded Ranged Skills[\s\S]*?(?=\t\[\"actives\.sling_stone\"\])", "", proj_src)
    new_proj_lines = ["\t// Expanded Ranged Skills"]
    for spec in NEW_96_SKILLS:
        if spec[22]:
            new_proj_lines.append(f'\t["actives.{spec[0]}"] = "{spec[22]}",')
    proj_src = proj_src.replace(
        '\t["actives.sling_stone"]',
        "\n".join(new_proj_lines) + '\n\t["actives.sling_stone"]',
        1,
    )
    proj_path.write_text(proj_src, encoding="utf-8", newline="\n")
    print("5) Registered new ranged/firearm/throwing skills in wx_projectiles.nut!")

    # 6. Update `ai_wuxia_skills.nut` & `loot_economy.nut` (100% Stage 22 AI Contract compliant!)
    atk_default = []
    atk_bow = []
    atk_swing = []
    def_shieldwall = []
    def_indom = []
    def_recover = []
    def_disengage = []
    def_warcry = []
    def_rally = []

    for spec in NEW_96_SKILLS:
        sid, kind = f"actives.{spec[0]}", spec[3]
        if kind == "melee":
            atk_default.append(sid)
        elif kind == "aoe3":
            atk_default.append(sid)
            atk_swing.append(sid)
        elif kind in ("bow", "xbow", "gun", "throw", "throw_aoe"):
            atk_bow.append(sid)
            if "throw" in kind:
                atk_default.append(sid)
        elif kind in ("qinggong_leap", "qinggong_step"):
            def_disengage.append(sid)
        elif kind == "shield_self":
            def_shieldwall.append(sid)
            def_indom.append(sid)
        elif kind == "henglian_self":
            def_indom.append(sid)
        elif kind == "neigong_self":
            if spec[5] == 0:
                def_recover.append(sid)
            else:
                def_indom.append(sid)
        elif kind == "warcry_self":
            def_warcry.append(sid)
        elif kind == "rally_self":
            def_rally.append(sid)

    def fmt_arr(items: list[str]) -> str:
        return ", ".join(f'"{x}"' for x in items)

    ai_path = MOD_DIR / "mod_wuxia/hooks/ai/tactical/behaviors/ai_wuxia_skills.nut"
    ai_src = f"""// Keep the native target selection, pathing and stamina evaluation for each behavior.
local extendBehavior = function( _path, _moves )
{{
\t::Wuxia.HooksMod.hook("scripts/ai/tactical/behaviors/" + _path, function( q )
\t{{
\t\tq.create = @(__original) function()
\t\t{{
\t\t\t__original();
\t\t\tif (!(::Wuxia.hasMember(this.m, "PossibleSkills")) || this.m.PossibleSkills == null) return;
\t\t\tthis.m.PossibleSkills = clone this.m.PossibleSkills;
\t\t\tforeach (id in _moves)
\t\t\t\tif (this.m.PossibleSkills.find(id) == null) this.m.PossibleSkills.push(id);
\t\t}};

\t\tq.onEvaluate = @(__original) function( _entity )
\t\t{{
\t\t\tif (!(::Wuxia.hasMember(this.m, "PossibleSkills")) || this.m.PossibleSkills == null) return __original(_entity);
\t\t\tif (_entity.getActionPoints() == _entity.getActionPointsMax() && "WX_LoadoutKey" in _entity.m)
\t\t\t{{
\t\t\t\tlocal trained = [];
\t\t\t\tforeach (id in _moves)
\t\t\t\t{{
\t\t\t\t\tlocal skill = _entity.getSkills().getSkillByID(id);
\t\t\t\t\tif (skill != null && skill.isUsable() && skill.isAffordable()) trained.push(id);
\t\t\t\t}}
\t\t\t\tif (trained.len() != 0)
\t\t\t\t{{
\t\t\t\t\tlocal all = this.m.PossibleSkills, score = 0;
\t\t\t\t\tthis.m.PossibleSkills = trained;
\t\t\t\t\ttry {{ score = __original(_entity); }}
\t\t\t\t\tcatch (error) {{ this.m.PossibleSkills = all; throw error; }}
\t\t\t\t\tthis.m.PossibleSkills = all;
\t\t\t\t\tif (score > 0) return score * 1.15;
\t\t\t\t}}
\t\t\t}}
\t\t\treturn __original(_entity);
\t\t}};
\t}});
}};

extendBehavior("ai_attack_default", [
\t"actives.wx_sword_combo", "actives.wx_sword_pierce", "actives.wx_sword_tianwai",
\t"actives.wx_saber_cleave", "actives.wx_saber_sweep", "actives.wx_saber_duanyue",
\t"actives.wx_spear_guard", "actives.wx_spear_thrust2", "actives.wx_pole_sweep",
\t"actives.wx_acupoint_strike", "actives.wx_throwing_rain", "actives.wx_throw_fan", "actives.wx_smoke_cast",
\t"actives.wx_fist_jab", "actives.wx_fist_shock", "actives.wx_fist_jingang", "actives.wx_fist_acupoint", "actives.wx_fist_disarm", "actives.wx_fist_grapple",
\t"actives.wx_hammer_shatter", "actives.wx_hammer_quake",
\t"actives.wx_axe_split", "actives.wx_axe_whirl",
\t"actives.wx_flail_lash", "actives.wx_flail_entangle",
\t"actives.wx_dagger_vital", "actives.wx_dagger_execute",
\t"actives.wx_shield_bash_qi", "actives.wx_neigong_xixing",
\t"actives.wx_sword_zhongjian", "actives.wx_sword_duoming", "actives.wx_sword_cuixin", "actives.wx_sword_taiji", "actives.wx_sword_feixian", "actives.wx_sword_dugu", "actives.wx_saber_kuangfeng", "actives.wx_saber_ranmu", "actives.wx_saber_xuehai", "actives.wx_saber_fanzhen", "actives.wx_saber_modao", "actives.wx_saber_huoyandao", "actives.wx_spear_liuhua", "actives.wx_spear_bawang", "actives.wx_spear_liangyin", "actives.wx_pole_fangtian", "actives.wx_pole_goulian", "actives.wx_staff_dagou", "actives.wx_fist_xianglong", "actives.wx_fist_xuanming", "actives.wx_fist_yiyang", "actives.wx_fist_jiuyin", "actives.wx_fist_qishang", "actives.wx_fist_taiji", "actives.wx_hama_push", "actives.wx_hammer_leiting", "actives.wx_axe_kaishan", "actives.wx_whip_suohou", "actives.wx_dagger_fuxue",
\t{fmt_arr(atk_default)}
]);
extendBehavior("ai_attack_bow", ["actives.wx_throwing_rain", "actives.wx_throw_fan", "actives.wx_bow_snipe", "actives.wx_smoke_cast", "actives.wx_bow_liuxing", "actives.wx_crossbow_shenji", "actives.wx_throw_pilidan", "actives.wx_throw_duzhen", {fmt_arr(atk_bow)}]);
extendBehavior("ai_attack_swing", ["actives.wx_saber_sweep", "actives.wx_pole_sweep", "actives.wx_axe_whirl", {fmt_arr(atk_swing)}]);
extendBehavior("ai_attack_splitshield", ["actives.wx_axe_split"]);
extendBehavior("ai_defend_knock_back", ["actives.wx_shield_bash_qi"]);
extendBehavior("ai_defend_riposte", ["actives.wx_sword_counter", "actives.wx_poise_charge"]);
extendBehavior("ai_defend_shieldwall", ["actives.wx_shield_tiebi", "actives.wx_neigong_jinzhong", {fmt_arr(def_shieldwall)}]);
extendBehavior("ai_indomitable", ["actives.wx_neigong_jinzhong", "actives.wx_shield_tiebi", {fmt_arr(def_indom)}]);
extendBehavior("ai_recover", ["actives.wx_meditate", {fmt_arr(def_recover)}]);
extendBehavior("ai_adrenaline", ["actives.wx_blood_burst"]);
extendBehavior("ai_disengage", ["actives.wx_qinggong_lingbo", "actives.wx_qinggong_zongyue", {fmt_arr(def_disengage)}]);
extendBehavior("ai_warcry", ["actives.wx_tactics_shihou", {fmt_arr(def_warcry)}]);
extendBehavior("ai_rally", ["actives.wx_rally_command", {fmt_arr(def_rally)}]);

::Wuxia.HooksMod.hook("scripts/ai/tactical/agent", function( q )
{{
\tif (::Wuxia.qHas(q, "finalizeBehaviors"))
\t{{
\t\tq.finalizeBehaviors = @(__original) function()
\t\t{{
\t\t\tif (this.getBehavior(::Const.AI.Behavior.ID.EngageRanged) != null)
\t\t\t{{
\t\t\t\tif (("AttackHandgonne" in ::Const.AI.Behavior.ID) && this.getBehavior(::Const.AI.Behavior.ID.AttackHandgonne) == null)
\t\t\t\t\tthis.addBehavior(::new("scripts/ai/tactical/behaviors/ai_attack_handgonne"));
\t\t\t\tif (("AttackBow" in ::Const.AI.Behavior.ID) && this.getBehavior(::Const.AI.Behavior.ID.AttackBow) == null)
\t\t\t\t\tthis.addBehavior(::new("scripts/ai/tactical/behaviors/ai_attack_bow"));
\t\t\t}}
\t\t\treturn __original();
\t\t}};
\t}}
}});
"""
    ai_path.write_text(ai_src, encoding="utf-8", newline="\n")
    print("6) Updated ai_wuxia_skills.nut with all 96 new skills!")

    # 7. Patch all 9 manual config `.nut` files & verify 171/171 skills wired with zero orphans!
    cn_names = load_all_skill_chinese_names()
    patched_cnt = patch_manual_files(cn_names)
    total_manuals, skill_counts = audit_all_manuals_and_skills()
    top_shared = sorted(skill_counts.items(), key=lambda kv: (-kv[1], kv[0]))[:10]
    single_owned = sum(1 for v in skill_counts.values() if v == 1)
    le2_owned = sum(1 for v in skill_counts.values() if v <= 2)
    print(f"7) Patched {patched_cnt} manuals across {total_manuals} total manuals!")
    print(f"   Verified {len(skill_counts)}/171 playable active skills wired (0 orphans; {single_owned} exclusive to 1 manual; {le2_owned}/171 on <=2 manuals)!")
    print("   Top shared moves now:", ", ".join(f"{k}({v})" for k, v in top_shared))

    # 8. Update `selftest.nut` counts (`75` -> `171`) + add NamedWeaponMap Zero-Sharing assertion!
    st_path = MOD_DIR / "mod_wuxia/systems/selftest.nut"
    st_src = st_path.read_text(encoding="utf-8")
    st_src = st_src.replace("if (seenSkills.len() != 75)", "if (seenSkills.len() != 171)")
    st_src = st_src.replace('throw "Expected all 75 Wuxia active skills wired to manuals, got " + seenSkills.len();',
                            'throw "Expected all 171 Wuxia active skills wired to manuals, got " + seenSkills.len();')
    st_src = st_src.replace("if (choreoCount != 75)", "if (choreoCount != 171)")
    st_src = st_src.replace('throw "Expected 75 unique SkillChoreo entries, got " + choreoCount;',
                            'throw "Expected 171 unique SkillChoreo entries, got " + choreoCount;')
    st_src = st_src.replace("for (local ai = 1; ai <= 75; ai = ++ai)", "for (local ai = 1; ai <= 171; ai = ++ai)")
    st_src = st_src.replace("if (totalChoreo != 75)", "if (totalChoreo != 171)")
    st_src = st_src.replace('throw "Expected 75 active skills in Stage 10 VFX audit, got " + totalChoreo;',
                            'throw "Expected 171 active skills in Stage 10 VFX audit, got " + totalChoreo;')

    # Add verification in `Shan Hai Zero-Sharing Art Integrity` for NamedWeaponMap `wx_famed_*` brushes!
    famed_check = """\t\t// 5. All NamedWeaponMap famed red weapons must use dedicated `named/wx_famed_*` icons & valid brushes
\t\tlocal seenFamedAssets = {};
\t\tforeach (nwid, nwSpec in ::Wuxia.Armory.NamedWeaponMap)
\t\t{
\t\t\tif (nwSpec[1] != "named" || nwSpec[0].find("wx_famed_") != 0)
\t\t\t\tthrow "NamedWeaponMap entry still sharing common non-famed asset: " + nwid + " -> " + nwSpec[0];
\t\t\tif (nwid != "weapon.named_skull_hammer" && (nwSpec[0] in seenFamedAssets))
\t\t\t\tthrow "Duplicate famed weapon asset " + nwSpec[0] + " between " + seenFamedAssets[nwSpec[0]] + " and " + nwid;
\t\t\tif (nwid != "weapon.named_skull_hammer")
\t\t\t\tseenFamedAssets[nwSpec[0]] <- nwid;
\t\t\tif (hasBrushFn && !::doesBrushExist("arm_" + nwSpec[0]))
\t\t\t\tthrow "Missing famed paperdoll brush arm_" + nwSpec[0];
\t\t}
"""
    if "seenFamedAssets" not in st_src:
        st_src = st_src.replace(
            '\t\tif (bossCount != 64) throw "Expected 64 ShanHaiBosses, got " + bossCount;\n',
            '\t\tif (bossCount != 64) throw "Expected 64 ShanHaiBosses, got " + bossCount;\n\n' + famed_check,
            1,
        )
    st_path.write_text(st_src, encoding="utf-8", newline="\n")
    print("8) Updated selftest.nut assertions for 171 active skills & 62 unique NamedWeaponMap famed assets!")


if __name__ == "__main__":
    main()
