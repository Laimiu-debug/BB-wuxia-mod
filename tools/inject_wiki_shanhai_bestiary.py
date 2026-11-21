#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Idempotently injects the complete interactive《山海经·万妖全志 (136)》(`#v=bestiary`)
and upgrades《美术图鉴 · 第四卷》pawn previews inside `武侠百科.html`:
  - 136 Distinct《山海经》Beasts (64 Apex Bosses + 72 Wild/Retinue Beasts) + 3 Spawn Tokens = 139 Tactical Pawns
  - 4-State In-Game Visuals for Every Creature:
      1. 208×284 Tactical Hex Battlefield Chess Pawn (with themed stone/crimson/bronze/frost socket + HP/Armor bars)
      2. 68×106 World-Map Marching Figurine Token
      3. 196×172 Isometric Fallen Corpse Decal (`*_dead`)
      4. 256×256 Hand-Painted HD Illustration
  - 60fps Monster Pawn Combat Action Theater supporting 20 Distinct Creature Choreographies across all 342 Monster Skills
  - 64 Shan Hai Lair Isometric Hex Formation Sandboxes
  - Complete Battle Brothers D100 8-Stat Panels, Innate Traits, Immunities, Counterplay Guides & Loot Links
"""

import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

from shanhai_bestiary_data import build_all_bestiary_records

WIKI_PATH = ROOT / "山海武侠.html" if (ROOT / "山海武侠.html").exists() else ROOT / "武侠百科.html"

SHANHAI_CSS = """/* === SHANHAI_BESTIARY_BEGIN === */
.badge[data-r="山海四凶"]{background:#3b1212;color:#ffd6cc;border:1px solid #a63a32;font-weight:700}
.badge[data-r="太古神魔"]{background:#362610;color:#ffe6ad;border:1px solid #b88b3b;font-weight:700}
.badge[data-r="秘境妖皇"]{background:#1f332e;color:#d6f5e8;border:1px solid #4d8a78;font-weight:650}
.badge[data-r="荒泽精英"]{background:#2c2638;color:#e6dafc;border:1px solid #76629e;font-weight:650}
.badge[data-r="山海群妖"]{background:#e6ece6;color:#23443c;border:1px solid #9cb5aa}
.badge[data-r="伴生衍生物"]{background:#efe6d8;color:#6b4c24;border:1px solid #c4a476}

.sh-hero-box{margin:0 0 16px;border:1px solid #b3bca7;border-top:3px solid #7a2e22;background:#f4f5ee;border-radius:3px;padding:12px 14px}
.sh-hero-tabs{display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;margin-bottom:10px;padding-bottom:8px;border-bottom:1px solid #d7ddd0}
.sh-hero-modes{display:flex;gap:7px;flex-wrap:wrap}
.sh-hero-modes button{padding:5px 12px;border-radius:3px;border:1px solid #9aa89b;background:var(--sheet);color:#233b35;font:650 13.5px/1.3 var(--serif)}
.sh-hero-modes button[aria-pressed="true"]{background:#6e261c;border-color:#6e261c;color:#fff7e8}
.sh-theater-grid{display:grid;grid-template-columns:460px minmax(0,1fr);gap:14px;align-items:start;padding:12px;background:radial-gradient(circle at 42% 52%,#2c2119,#110d0a 88%);border:1px solid #5c4732;border-radius:4px;color:#eadec8}
@media(max-width:920px){.sh-theater-grid{grid-template-columns:1fr}}
.sh-canvas-col{display:grid;gap:7px}
.sh-canvas-wrap{position:relative;width:100%;aspect-ratio:460/266;border:1px solid #6e5439;border-radius:3px;background:#0e0b08;overflow:hidden;box-shadow:0 3px 12px rgba(0,0,0,.5)}
.sh-canvas-wrap canvas{display:block;width:100%;height:100%}
.sh-skill-switcher{display:flex;flex-wrap:wrap;gap:6px}
.sh-sk-tab{flex:1 1 120px;display:flex;flex-direction:column;gap:1px;padding:5px 8px;background:#241b14;border:1px solid #5e4933;border-radius:3px;color:#eadac0;text-align:left;font-size:12px}
.sh-sk-tab:hover,.sh-sk-tab[aria-pressed="true"]{background:#3d2b1c;border-color:#e0b263;color:#fff7e4}
.sh-sk-tab b{font-size:12.5px;color:#ffdf9e}
.sh-sk-tab small{font-size:10.5px;color:#c2ad8c}
.sh-ctrl-row{display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:6px}
.sh-ctrl-row button{padding:3px 9px;font-size:11.5px;background:#2a2017;border:1px solid #6b543b;color:#f0e2c6;border-radius:2px}
.sh-ctrl-row button[aria-pressed="true"],.sh-ctrl-row button:hover{background:#4a3623;border-color:#deb368;color:#fff}

.sh-roster-col{display:grid;gap:8px}
.sh-live-skill-card{padding:9px 11px;background:#1d1610;border:1px solid #594530;border-left:3px solid #d99b43;border-radius:3px;font-size:12.5px;line-height:1.55}
.sh-live-skill-head{display:flex;align-items:baseline;justify-content:space-between;gap:8px;flex-wrap:wrap;margin-bottom:4px}
.sh-live-skill-head strong{font:700 15px/1.25 var(--serif);color:#ffe4ab}
.sh-live-metrics{display:flex;flex-wrap:wrap;gap:5px;margin:5px 0}
.sh-metric{padding:1px 6px;border-radius:2px;background:#2c2219;border:1px solid #634d35;color:#f2d8a7;font-size:11px}
.sh-pick-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(136px,1fr));gap:6px;max-height:224px;overflow-y:auto;padding-right:3px}
.sh-pick-btn{display:flex;align-items:center;gap:6px;padding:4px 6px;background:#231b14;border:1px solid #54422f;border-radius:3px;color:#eadcc3;text-align:left;font-size:11.5px}
.sh-pick-btn:hover,.sh-pick-btn[aria-pressed="true"]{background:#3b2c1e;border-color:#deb368;color:#fff8e6}
.sh-pick-btn img{width:34px;height:42px;object-fit:contain;flex-shrink:0}
.sh-pick-btn b{display:block;font-size:12px;line-height:1.2;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:86px}
.sh-pick-btn small{display:block;font-size:10px;color:#bfa988}

/* Lair Encounter Hex Sandbox */
.sh-lair-sandbox{display:grid;grid-template-columns:300px minmax(0,1fr);gap:14px;padding:12px;background:radial-gradient(circle at 55% 48%,#2b2219,#120e0a 88%);border:1px solid #5c4732;border-radius:4px;color:#eadec8}
@media(max-width:860px){.sh-lair-sandbox{grid-template-columns:1fr}}
.sh-lair-info{display:grid;gap:8px;align-content:start}
.sh-lair-select{width:100%;padding:6px 9px;background:#221a13;color:#f7ebd2;border:1px solid #755c3f;border-radius:3px;font-size:13px}
.sh-lair-card{padding:10px;background:#1a140f;border:1px solid #52402c;border-radius:3px;text-align:center}
.sh-lair-card img{width:148px;height:116px;object-fit:contain;display:block;margin:0 auto 6px}
.sh-hex-board{position:relative;min-height:276px;background:radial-gradient(circle at 50% 54%,#33281d,#14100c 85%);border:1px solid #574430;border-radius:3px;padding:14px;display:flex;flex-wrap:wrap;align-items:center;justify-content:center;gap:14px}
.sh-board-pawn{display:flex;flex-direction:column;align-items:center;gap:3px;padding:6px 8px;border-radius:4px;background:rgba(20,15,11,.68);border:1px solid #53402c;cursor:pointer;transition:transform .15s,border-color .15s;width:124px}
.sh-board-pawn.is-boss{width:148px;border-color:#b87d3b;background:rgba(40,24,16,.82);box-shadow:0 0 14px rgba(210,95,45,.25)}
.sh-board-pawn:hover{transform:translateY(-3px);border-color:#f0c475}
.sh-board-pawn img{height:112px;width:auto;object-fit:contain;pointer-events:none}
.sh-board-pawn.is-boss img{height:136px}
.sh-board-pawn strong{font-size:12px;color:#fff1d4;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%}

/* Mode & Rank Filter Bar */
.sh-modebar{display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;padding:9px 12px;margin:0 0 10px;background:#eef1e8;border:1px solid var(--rule);border-radius:3px;font-size:12.5px}
.sh-modes,.sh-ranks{display:flex;gap:5px;flex-wrap:wrap;align-items:center}
.sh-modes button,.sh-ranks button{padding:4px 9px;border:1px solid #b5bfb2;border-radius:3px;background:var(--sheet);color:var(--quiet);font-size:12px}
.sh-modes button[aria-pressed="true"],.sh-ranks button[aria-pressed="true"]{background:var(--teal);border-color:var(--teal);color:#fff9e9;font-weight:600}
.sh-ranks{margin-bottom:14px}

/* Bestiary Cards Grid */
.sh-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(min(100%,286px),1fr));gap:13px}
.sh-card{display:flex;flex-direction:column;border:1px solid var(--rule);border-top:3px solid #4d6b5d;background:var(--sheet);padding:11px 12px;border-radius:3px;transition:border-color .15s,box-shadow .15s}
.sh-card.rank-fiend{border-top-color:#9e2a22}
.sh-card.rank-god{border-top-color:#b8862d}
.sh-card.rank-king{border-top-color:#235c4f}
.sh-card:hover{border-color:#876d45;box-shadow:0 4px 12px rgba(32,61,56,.10)}

.sh-pawn-stage{position:relative;width:100%;height:178px;margin-bottom:9px;border-radius:3px;background:radial-gradient(circle at 50% 56%,#33271c,#14100c 84%);border:1px solid #4d3c2b;box-shadow:inset 0 2px 9px rgba(0,0,0,.65);display:grid;place-items:center;overflow:hidden;cursor:pointer}
.sh-pawn-stage.map-bg{background:radial-gradient(circle at 50% 58%,#dfd4b4,#a89872 86%);border-color:#8a7956}
.sh-hex-floor{position:absolute;bottom:14px;width:128px;height:40px;border-radius:50%;background:radial-gradient(ellipse at center,rgba(95,72,48,.52) 0%,rgba(28,20,14,.85) 72%,transparent 100%);border:1px solid rgba(186,148,96,.38);pointer-events:none}
.sh-pawn-stage.is-boss .sh-hex-floor{width:148px;height:46px;border-color:rgba(232,110,68,.55);background:radial-gradient(ellipse at center,rgba(135,45,32,.48) 0%,rgba(32,16,12,.88) 74%,transparent 100%)}
.sh-pawn-stage.map-bg .sh-hex-floor{background:radial-gradient(ellipse at center,rgba(92,118,68,.45) 0%,rgba(68,86,52,.15) 75%,transparent 100%);border-color:rgba(62,82,46,.45)}
.sh-pawn-img{position:relative;z-index:2;max-height:150px;max-width:92%;object-fit:contain;pointer-events:none;transition:transform .18s}
.sh-pawn-stage.is-boss .sh-pawn-img{max-height:162px}
.sh-pawn-img.world-fig{max-height:112px;image-rendering:auto}
.sh-pawn-img.corpse-img{max-height:126px;margin-top:18px}
.sh-pawn-img.flip-x{transform:scaleX(-1)}

/* Authentic Battle Brothers Overhead Tactical Armor & HP Bars */
.sh-bb-bars{position:absolute;left:10px;top:8px;z-index:4;width:74px;display:grid;gap:2px;padding:3px;background:rgba(12,9,7,.82);border:1px solid rgba(128,104,72,.55);border-radius:2px;pointer-events:none}
.sh-bar-track{height:4px;background:#261f1a;overflow:hidden;border-radius:1px}
.sh-bar-arm{display:block;height:100%;background:linear-gradient(90deg,#9aa5b1,#dce3ea)}
.sh-bar-hp{display:block;height:100%;background:linear-gradient(90deg,#9e241b,#e34a3b)}
.sh-stage-tag{position:absolute;right:7px;top:7px;z-index:4;font:600 10.5px/1.2 var(--sans);color:#f5e4c3;background:rgba(16,12,9,.82);padding:2px 6px;border-radius:2px;border:1px solid rgba(168,132,78,.45)}
.sh-stage-sub{position:absolute;right:7px;bottom:5px;z-index:4;font:10px/1.2 Consolas,monospace;color:#cbbba0;background:rgba(12,9,7,.75);padding:2px 5px;border-radius:2px}
.sh-map-Stage-sub{color:#2b2318;background:rgba(255,250,236,.82)}

.sh-card-head{display:flex;align-items:flex-start;justify-content:space-between;gap:6px;margin-bottom:4px}
.sh-card h3{margin:0;font:700 16.5px/1.28 var(--serif);color:#1e3833}
.sh-chap-line{font-size:11.5px;color:var(--quiet);margin-bottom:6px;display:flex;justify-content:space-between;gap:6px}
.sh-stat-strip{display:grid;grid-template-columns:repeat(4,1fr);gap:4px;padding:5px 6px;background:#f2f4ed;border:1px solid #dce1d5;border-radius:2px;margin-bottom:7px;text-align:center}
.sh-st-cell small{display:block;font-size:10px;color:#62706a;line-height:1.1}
.sh-st-cell b{display:block;font:700 12.5px/1.25 Consolas,monospace;color:#1d3631}
.sh-trait-box{font-size:12px;line-height:1.48;color:#2f3c38;background:#faf8f1;border-left:3px solid #9c7a44;padding:5px 8px;margin-bottom:7px;flex:1}
.sh-trait-box strong{color:#6e4314;display:block;margin-bottom:1px}
.sh-skill-chips{display:flex;flex-wrap:wrap;gap:4px;margin-bottom:7px}
.sh-sk-chip{padding:3px 7px;border-radius:2px;background:#231b14;border:1px solid #6b5339;color:#f5e4c4;font-size:11.5px;display:inline-flex;align-items:center;gap:4px}
.sh-sk-chip:hover{background:#3d2d1e;border-color:#dfb264;color:#fff}
.sh-sk-chip em{font-style:normal;font-size:10px;color:#d6b06b}
.sh-card-foot{display:flex;align-items:center;justify-content:space-between;gap:6px;padding-top:6px;border-top:1px solid #e5e8df;font-size:11.5px;color:var(--quiet)}

/* Modal 4-State Pawn Showcase + Full Stat & Skill Tables */
.sh-modal-pawns{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:8px;padding:12px;margin:6px 0 10px;background:radial-gradient(circle at 50% 45%,#2d231a,#130f0b 88%);border:1px solid #5c4832;border-radius:4px;text-align:center;color:#dfd0b6;font-size:11px}
@media(max-width:560px){.sh-modal-pawns{grid-template-columns:repeat(2,1fr)}}
.sh-mp-box{display:flex;flex-direction:column;align-items:center;justify-content:flex-end;gap:5px;padding:6px;background:rgba(16,12,9,.65);border:1px solid #4a3a28;border-radius:3px;min-height:142px}
.sh-mp-box.map-cell{background:radial-gradient(circle at 50% 55%,#dfd4b4,#9c8b65 90%);color:#2a2117}
.sh-mp-box img{max-height:112px;max-width:100%;object-fit:contain}
.sh-stat-grid8{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:6px 12px;padding:10px 12px;background:#f5f6f0;border:1px solid var(--rule);border-radius:3px;margin:10px 0}
.sh-bar-row{display:grid;grid-template-columns:4.8em 3.6em minmax(0,1fr);align-items:center;gap:6px;font-size:12.5px}
.sh-bar-row span{color:var(--quiet)}
.sh-bar-row b{font-family:Consolas,monospace;text-align:right;color:#1c3832}
.sh-mini-meter{height:6px;background:#dfe3d8;border-radius:3px;overflow:hidden}
.sh-mini-meter i{display:block;height:100%;background:linear-gradient(90deg,#204f4a,#b88c46)}
.sh-skill-detail-list{display:grid;gap:8px;margin:10px 0}
.sh-skill-detail-item{padding:9px 11px;border:1px solid #d5dacb;border-left:3px solid #7d4e24;background:#fffdf8;border-radius:3px}
.sh-skill-detail-top{display:flex;align-items:center;justify-content:space-between;gap:8px;flex-wrap:wrap;margin-bottom:4px}
.sh-skill-detail-top strong{font:700 15px/1.3 var(--serif);color:#203d38}
/* === SHANHAI_BESTIARY_END === */"""


SHANHAI_JS = r"""// === SHANHAI_BESTIARY_BEGIN ===
const shBestiaryData = JSON.parse(document.getElementById('shanhai-data').textContent);
const shAllCreatures = shBestiaryData.creatures || [];
const shSpecies136 = shAllCreatures.filter(c => c.kind !== 'spawn');
const shById = new Map(shAllCreatures.map(c => [c.id, c]));
const shBookGroups = shBestiaryData.bookGroups || [];
const shBosses64 = shAllCreatures.filter(c => c.kind === 'boss');

const shSearchMap = new Map(shAllCreatures.map(c => [
  c.id,
  field(
    c.id, c.name, c.shortName, c.rank, c.chapter, c.archetype, c.bodyLabel,
    c.classicQuote, c.traitName, c.traitDesc, c.counterplay, c.trophy || '',
    (c.tags || []).join(' '), (c.immunities || []).join(' '),
    (c.skills || []).map(s => s.name + ' ' + s.desc + ' ' + (s.effects || []).join(' ')).join(' '),
    c.core ? c.core.name : '', c.lair ? c.lair.name : ''
  )
]));

const shFeaturedIds = [
  'wx_boss_zhuyan', 'wx_boss_qiongqi', 'wx_boss_taotie', 'wx_boss_jiuwei',
  'wx_boss_xingtian', 'wx_boss_jinwu', 'wx_boss_kui', 'wx_boss_xiangliuwang',
  'wx_boss_hundun', 'wx_boss_zhuyin', 'wx_boss_xuangui', 'wx_boss_qinyuan',
  'wx_beast_luoshu', 'wx_beast_zhuniao', 'wx_beast_aohen', 'wx_beast_shirou'
];

let shHeroTab = 'arena';       // 'arena' | 'lairs'
let shDisplayMode = 'pawn';    // 'pawn' | 'world' | 'corpse' | 'hd'
let shFlipFacing = false;      // false = 3/4-left (enemy side), true = 3/4-right (ally side)
let shCurCreatureId = 'wx_boss_zhuyan';
let shCurSkillIdx = 0;
let shAnimSpeed = 1.0;
let shSelectedLairBossId = 'wx_boss_zhuyan';
let shRosterScope = 'featured'; // 'featured' | 'all'
let shMainRafId = 0;
let shModalRafId = 0;
let shModalCreatureId = '';
let shModalSkillIdx = 0;

function shPawnSrc(c, mode) {
  const m = mode || shDisplayMode;
  if (m === 'world') return 'art/world_entity/' + c.worldFigId + '.png';
  if (m === 'corpse') return 'art/busts/beasts_dead/' + c.id + '_dead.png';
  if (m === 'hd') return 'art/hd/' + c.id + '.png';
  return 'art/pawns/' + c.id + '.png';
}

function shMatchingCreatures(query) {
  const sec = state.shc || '';
  const rnk = state.shr || '';
  let pool = shSpecies136;
  if (sec === 'spawn') pool = shAllCreatures.filter(c => c.kind === 'spawn');
  else if (sec === 'boss') pool = shAllCreatures.filter(c => c.kind === 'boss');
  else if (sec === 'wild') pool = shAllCreatures.filter(c => c.kind === 'wild');
  else if (sec && sec !== 'lairs') pool = shSpecies136.filter(c => c.bookGroup === sec);
  if (rnk) pool = shAllCreatures.filter(c => c.rank === rnk);
  if (query) pool = pool.filter(c => shSearchMap.get(c.id).includes(query));
  return pool;
}

// === 60fps Tactical Hex Monster Pawn Combat Choreography Engine (20 Modes!) ===
function shStartMonsterCanvas(canvasId, creature, skillIdx, isModal) {
  const cv = document.getElementById(canvasId);
  if (!cv || typeof cv.getContext !== 'function') return;
  const ctx = cv.getContext('2d');
  if (!ctx) return;

  if (isModal && shModalRafId) cancelAnimationFrame(shModalRafId);
  if (!isModal && shMainRafId) cancelAnimationFrame(shMainRafId);

  const c = creature || shById.get('wx_boss_zhuyan');
  const sk = (c.skills && c.skills[skillIdx]) || (c.skills && c.skills[0]);
  if (!c || !sk) return;

  const beastBustIm = wxLoadImg('art/busts/beasts/' + c.id + '.png');
  const sockTheme = c.socketTheme || 'wild_stone';
  const sockBackIm = wxLoadImg('art/busts/sockets/pedestal_' + sockTheme + '_back.png');
  const sockFrontIm = wxLoadImg('art/busts/sockets/pedestal_' + sockTheme + '_front.png');

  // Opponent Wuxia Hero Pawn on Left Hex!
  const heroBodyIm = wxLoadImg('art/busts/body/wx_body_hvy_02.png');
  const heroHeadIm = wxLoadImg('art/busts/head/wx_head_15.png');
  const heroHairIm = wxLoadImg('art/busts/hair/wx_hair_17.png');
  const heroHatIm  = wxLoadImg('art/busts/hat_front/wx_hat_30.png');
  const heroWpnIm  = wxLoadImg('art/hd/wx_relic_minghong.png');
  const heroShdIm  = wxLoadImg('art/busts/shield/wx_shd_12.png');
  const heroSockB  = wxLoadImg('art/busts/pedestal_back.png');
  const heroSockF  = wxLoadImg('art/busts/pedestal_front.png');

  const fxIm = sk.fx ? wxLoadImg('art/fx_elements/' + sk.fx + '.png') : null;
  const sonicIm = wxLoadImg('art/fx_elements/wx_fx_sonic_ring.png');
  const bloodIm = wxLoadImg('art/fx_elements/wx_fx_blood_orb.png');
  const earthIm = wxLoadImg('art/fx_elements/wx_fx_earth_fissure.png');
  const boltIm  = wxLoadImg('art/fx_elements/wx_fx_thunder_bolt.png');
  const swordIm = wxLoadImg('art/fx_elements/wx_fx_sword_phantom.png');

  const mode = sk.animMode || 'feral_pounce';
  const col = sk.animColor || '#ff5a36';
  const isBoss = c.kind === 'boss';
  const cycleMs = 1920;
  let startTs = performance.now();

  function drawHeroChessPawn(cx, groundY, jumpZ, leanDeg, flash, showShield, wpnDeg) {
    ctx.save();
    const shS = Math.max(0.4, 1 - jumpZ / 130);
    ctx.fillStyle = 'rgba(0,0,0,' + (0.48 * shS).toFixed(2) + ')';
    ctx.beginPath(); ctx.ellipse(cx, groundY + 44, 34 * shS, 11 * shS, 0, 0, Math.PI * 2); ctx.fill();

    ctx.translate(cx, groundY - jumpZ);
    ctx.rotate((leanDeg * Math.PI) / 180);
    if (flash > 0.05) ctx.filter = 'brightness(' + (1 + flash * 1.55).toFixed(2) + ')';

    if (heroSockB && heroSockB.complete) ctx.drawImage(heroSockB, -46, -64, 92, 126);
    if (heroBodyIm && heroBodyIm.complete) ctx.drawImage(heroBodyIm, -46, -64, 92, 126);
    if (heroSockF && heroSockF.complete) ctx.drawImage(heroSockF, -46, -64, 92, 126);
    [heroHeadIm, heroHairIm, heroHatIm].forEach(im => {
      if (im && im.complete) ctx.drawImage(im, -46, -64, 92, 126);
    });
    if (showShield && heroShdIm && heroShdIm.complete) ctx.drawImage(heroShdIm, -48, -62, 92, 126);
    if (heroWpnIm && heroWpnIm.complete) {
      ctx.save();
      ctx.translate(16, 4);
      ctx.rotate(((wpnDeg || 25) * Math.PI) / 180);
      ctx.drawImage(heroWpnIm, -22, -72, 46, 88);
      ctx.restore();
    }
    ctx.restore();
  }

  function drawBeastChessPawn(cx, groundY, jumpZ, leanDeg, sx, sy, alpha, faceRight) {
    ctx.save();
    const bw = isBoss ? 120 : 104;
    const bh = isBoss ? 164 : 142;
    const shS = Math.max(0.35, 1 - jumpZ / 150);
    ctx.fillStyle = 'rgba(0,0,0,' + (0.52 * shS * alpha).toFixed(2) + ')';
    ctx.beginPath(); ctx.ellipse(cx, groundY + 44, (isBoss ? 44 : 36) * shS, 13 * shS, 0, 0, Math.PI * 2); ctx.fill();

    ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    // Keep stone socket anchored near ground when leaping small heights, or carry pawn socket cleanly!
    ctx.translate(cx, groundY - jumpZ);
    if (faceRight) ctx.scale(-1, 1);
    ctx.rotate((leanDeg * Math.PI) / 180);
    ctx.scale(sx, sy);

    if (sockBackIm && sockBackIm.complete) ctx.drawImage(sockBackIm, -bw / 2, -bh * 0.52, bw, bh);
    if (beastBustIm && beastBustIm.complete) ctx.drawImage(beastBustIm, -bw / 2, -bh * 0.52, bw, bh);
    if (sockFrontIm && sockFrontIm.complete) ctx.drawImage(sockFrontIm, -bw / 2, -bh * 0.52, bw, bh);
    ctx.restore();
  }

  function step(now) {
    if (!document.getElementById(canvasId)) return;
    const W = cv.width, H = cv.height;
    const spd = isModal ? 1.0 : shAnimSpeed;
    let rawP = ((now - startTs) * spd) / cycleMs;
    if (rawP >= 1.0) { startTs = now; rawP = rawP % 1.0; }

    // Crisp hit-stop (`顿帧`) at impact (`0.48..0.54`)
    let p = rawP;
    if (rawP > 0.48 && rawP < 0.54) p = 0.48 + (rawP - 0.48) * 0.20;
    else if (rawP >= 0.54) p = 0.492 + (rawP - 0.54) * (0.508 / 0.46);

    const easeOut = t => 1 - Math.pow(1 - Math.max(0, Math.min(1, t)), 3);
    const groundY = 154;
    const heroHomeX = 114, beastHomeX = 342;

    let hx = heroHomeX, hz = 0, hLean = 0, hFlash = 0, hWpnDeg = 24;
    let bx = beastHomeX, bz = 0, bLean = 0, bsx = 1, bsy = 1, bAlpha = 1, bFaceRight = false;
    let shakeX = 0, shakeY = 0, camZoom = 1.0;
    let clones = [], arcs = [], popups = [];

    const hitWin = p >= 0.47 && p <= 0.80;
    const hk = hitWin ? (p - 0.47) / 0.33 : 0;

    // === 20 Distinct Monster Combat Choreographies ===
    if (mode === 'ape_titan_slam' || mode === 'thunder_hoof_stomp') {
      if (p < 0.24) {
        const k = p / 0.24;
        bsy = 1 - 0.14 * k; bsx = 1 + 0.12 * k; bLean = 14 * k;
      } else if (p < 0.49) {
        const k = (p - 0.24) / 0.25;
        bx = beastHomeX - easeOut(k) * 168;
        bz = Math.sin(k * Math.PI) * 84;
        bLean = 14 - k * 36;
        clones.push({x: bx + 26, z: Math.max(0, bz - 16), a: 0.30});
      } else if (p < 0.82) {
        const k = (p - 0.49) / 0.33;
        bx = (beastHomeX - 168) + k * 18; bLean = -18 * (1 - k);
        hx = heroHomeX - Math.sin(k * Math.PI) * 28; hz = Math.sin(Math.min(1, k * 2) * Math.PI) * 22;
        hLean = -24 * (1 - k); hFlash = Math.max(0, 1 - k * 1.8);
        if (k < 0.55) { shakeX = (Math.random() - 0.5) * 15; shakeY = (Math.random() - 0.5) * 14; camZoom = 1.12; }
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
        clones.push({x: bx + 34, z: bz * 0.6, a: 0.36}, {x: bx + 66, z: 0, a: 0.18});
      } else if (p < 0.78) {
        const k = (p - 0.49) / 0.29;
        bx = (beastHomeX - 172) + k * 24;
        bLean = mode === 'headless_waraxe' ? Math.sin(k * Math.PI * 4) * 24 : -18 * (1 - k);
        hx = heroHomeX - Math.sin(k * Math.PI) * (mode === 'horn_gore_charge' ? 38 : 20);
        hLean = -22 * (1 - k); hFlash = Math.max(0, 1 - k * 1.9);
        arcs.push({x: hx + 18, y: groundY - 12, rO: 86, rI: 52, a0: 1.9, a1: 4.3, a: Math.max(0, 1 - k * 1.8)});
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
        arcs.push({x: hx + 12, y: groundY - 10, rO: 78, rI: 48, a0: 1.8 + idx * 0.6, a1: 4.1 + idx * 0.6, a: Math.sin(sub * Math.PI)});
        popups.push({x: hx + (idx - 1) * 18, y: 54 - sub * 18, txt: '-' + (26 + idx * 9), a: Math.sin(sub * Math.PI), col});
        shakeX = (Math.random() - 0.5) * 8; camZoom = 1.08;
      } else {
        bx = beastHomeX - (1 - easeOut((p - 0.80) / 0.20)) * 162;
      }
    } else if (mode === 'sky_talon_dive' || mode === 'sun_crow_nova') {
      if (p < 0.28) {
        const k = easeOut(p / 0.28);
        bz = k * 96; bx = beastHomeX - k * 28; bLean = 10 * k;
      } else if (p < 0.52) {
        const k = easeOut((p - 0.28) / 0.24);
        if (mode === 'sun_crow_nova') {
          bx = beastHomeX - 28 - k * 82; bz = 96 - k * 18;
        } else {
          bx = beastHomeX - 28 - k * 154; bz = 96 * (1 - k); bLean = -26 * k;
          clones.push({x: bx + 32, z: bz + 28, a: 0.35});
        }
      } else if (p < 0.82) {
        const k = (p - 0.52) / 0.30;
        if (mode === 'sun_crow_nova') {
          bx = beastHomeX - 110 + k * 40; bz = 78 * (1 - k * 0.5);
        } else {
          bx = (beastHomeX - 182) + easeOut(k) * 80; bz = Math.sin(k * Math.PI) * 32;
        }
        hx = heroHomeX - Math.sin(k * Math.PI) * 20; hLean = -20 * (1 - k); hFlash = Math.max(0, 1 - k * 1.8);
        if (k < 0.5) { shakeX = (Math.random() - 0.5) * 11; shakeY = (Math.random() - 0.5) * 10; camZoom = 1.10; }
      } else {
        const k = (p - 0.82) / 0.18;
        bx = beastHomeX - (1 - k) * 70; bz = (1 - k) * 38;
      }
    } else if (mode === 'abyss_tentacle_drag') {
      // Monster lashes across arena & YANKS Hero right up to its jaws!
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
      // Hero rushes in FIRST (`0..0.42`), strikes fortified shell, and gets violently recoiled by thorns!
      if (p < 0.42) {
        const k = easeOut(p / 0.42);
        hx = heroHomeX + k * 154; hLean = 18 * k; hWpnDeg = -45 + k * 125;
        bsy = 1 - 0.08 * k; bsx = 1 + 0.08 * k;
      } else if (p < 0.78) {
        const k = (p - 0.42) / 0.36;
        hx = (heroHomeX + 154) - easeOut(k) * 158; hLean = -24 * Math.sin(k * Math.PI);
        hFlash = Math.max(0, 1 - k * 1.8);
        shakeX = (Math.random() - 0.5) * 10 * (1 - k);
      }
    } else if (mode === 'dream_shadow_ambush') {
      // Fade into shadow -> Appear BEHIND Hero (`heroHomeX - 54`, facing RIGHT!) -> Ambush slash!
      if (p < 0.24) {
        bAlpha = 1 - 0.85 * (p / 0.24);
      } else if (p < 0.76) {
        const k = (p - 0.24) / 0.52;
        bx = heroHomeX - 52; bFaceRight = true; bLean = -18;
        clones.push({x: beastHomeX, z: 0, a: Math.max(0, 0.40 - k)});
        if (k > 0.30) {
          hFlash = Math.max(0, 1 - (k - 0.30) * 2.2); hx = heroHomeX + Math.sin((k - 0.30) * Math.PI) * 16;
          arcs.push({x: heroHomeX, y: groundY - 12, rO: 76, rI: 50, a0: -1.1, a1: 1.2, a: Math.max(0, 1 - (k - 0.30) * 2)});
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
        arcs.push({x: hx + 24, y: groundY - 8, rO: 92, rI: 56, a0: 1.7, a1: 4.5, a: Math.max(0, 1 - k * 1.8)});
        if (k < 0.5) { shakeX = (Math.random() - 0.5) * 10; camZoom = 1.08; }
      } else {
        bx = beastHomeX - (1 - easeOut((p - 0.82) / 0.18)) * 128;
      }
    } else {
      // Ranged / Breath / Roar / Needle / Charm / Root / Boulder / Blood-Devour (`dragon_breath`, `fox_charm_miasma`, `venom_needle_barrage`, `root_thorn_entangle`, `sonic_dread_roar`, `boulder_hurl_smash`, `devour_blood_siphon`)
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

    // === Render Battlefield Scene ===
    ctx.save();
    ctx.clearRect(0, 0, W, H);

    // Biome atmospheric backdrop
    const isFrost = c.socketTheme === 'boss_frost';
    const isMire  = c.socketTheme === 'boss_mire' || c.socketTheme === 'spawn_mire';
    const bg = ctx.createRadialGradient(W * 0.52, H * 0.56, 18, W * 0.5, H * 0.5, W * 0.80);
    bg.addColorStop(0, isFrost ? '#1a2c3b' : (isMire ? '#1d2d22' : '#36231a'));
    bg.addColorStop(1, '#0d0907');
    ctx.fillStyle = bg; ctx.fillRect(0, 0, W, H);

    ctx.translate(W * 0.5 + shakeX, H * 0.5 + shakeY);
    ctx.scale(camZoom, camZoom);
    ctx.translate(-W * 0.5, -H * 0.5);

    if (p > 0.25 && p < 0.68) {
      wxDrawSpeedLines(ctx, W, H, col, Math.sin(((p - 0.25) / 0.43) * Math.PI));
    }

    // 4-Hex Tactical Stone Floor (Hero Green Hex at 114, Monster Crimson Hex at 342)
    [114, 190, 266, 342].forEach((cx, hi) => {
      const stroke = hi === 0 ? 'rgba(136,192,120,0.48)' : (hi === 3 ? 'rgba(225,86,68,0.58)' : 'rgba(154,126,88,0.25)');
      const fill   = hi === 0 ? 'rgba(46,74,40,0.22)' : (hi === 3 ? 'rgba(104,32,24,0.26)' : 'rgba(38,29,20,0.20)');
      wxDrawHexPoly(ctx, cx, groundY + 44, 47, 17, stroke, fill);
    });

    // Ground fissure / root spikes under Hero
    if ((mode === 'ape_titan_slam' || mode === 'thunder_hoof_stomp' || mode === 'root_thorn_entangle') && p >= 0.46 && earthIm) {
      const ek = Math.min(1, (p - 0.46) / 0.44);
      for (let gi = 0; gi < (mode === 'root_thorn_entangle' ? 3 : 1); gi++) {
        const gx = mode === 'root_thorn_entangle' ? (bx - 64 - gi * 62) : hx + 18;
        wxDrawImgFit(ctx, earthIm, gx, groundY + 28, 122, 88, 0, Math.max(0, 1 - ek * 0.8), false);
      }
    }

    // Draw Wuxia Hero Pawn & Shan Hai Beast Pawn!
    drawHeroChessPawn(hx, groundY, hz, hLean, hFlash, true, hWpnDeg);
    clones.forEach(cl => drawBeastChessPawn(cl.x, groundY, cl.z || 0, -14, 1, 1, cl.a, bFaceRight));
    drawBeastChessPawn(bx, groundY, bz, bLean, bsx, bsy, bAlpha, bFaceRight);

    // Draw Claw / Fang / Weapon Smear Arcs
    arcs.forEach(sa => wxDrawSlashArc(ctx, sa.x, sa.y, sa.rO, sa.rI, sa.a0, sa.a1, col, sa.a));

    // Mode-Specific Elemental Beams, Projectiles, Tentacles, Boulders & Auras!
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
      if (fxIm) wxDrawImgFit(ctx, fxIm, hx, groundY - 12, 118, 118, 0, bk, true);
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
      if (vk > 0.45 && fxIm) wxDrawImgFit(ctx, fxIm, hx, groundY - 18, 110, 110, 0, 1 - (vk - 0.45) * 1.5, false);
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
        wxDrawImgFit(ctx, earthIm, hx, groundY + 18, 128, 92, 0, 1 - ex, false);
      }
    } else if (mode === 'thunder_hoof_stomp' && p > 0.42 && p < 0.86 && boltIm) {
      wxDrawImgFit(ctx, boltIm, hx, groundY - 46, 138, 178, 0, 1 - (p - 0.42) / 0.44, false);
    } else if ((mode === 'sonic_dread_roar' || mode === 'fox_charm_miasma') && p > 0.26 && p < 0.88) {
      const rk = (p - 0.26) / 0.62;
      for (let ri = 0; ri < 4; ri++) {
        const rt = rk * 1.4 - ri * 0.12;
        if (rt > 0 && rt < 1 && sonicIm) {
          wxDrawImgFit(ctx, sonicIm, (bx - 34) - rt * 215, groundY - 14, 60 + rt * 92, 80 + rt * 80, 0, (1 - rt) * 0.85, true);
        }
      }
      if (mode === 'fox_charm_miasma' && fxIm && rk > 0.35) {
        wxDrawImgFit(ctx, fxIm, hx, groundY - 22, 116, 116, rk * 2.5, Math.min(0.9, (1 - rk) * 2.2), false);
      }
    } else if (mode === 'devour_blood_siphon' && p > 0.44 && p < 0.92 && bloodIm) {
      const sk0 = (p - 0.44) / 0.48;
      for (let oi = 0; oi < 6; oi++) {
        const ot = sk0 * 1.45 - oi * 0.08;
        if (ot > 0 && ot < 1) {
          const ox = hx + easeOut(ot) * (bx - hx - 18);
          const oy = groundY - 16 - Math.sin(ot * Math.PI) * (32 - oi * 8);
          wxDrawImgFit(ctx, bloodIm, ox, oy, 34, 34, ot * 8, 0.92, false);
        }
      }
    } else if (hitWin && fxIm) {
      wxDrawImgFit(ctx, fxIm, mode === 'shell_thorns_quake' ? bx - 24 : hx + 8, groundY - 14, 118, 118, 0, Math.max(0, 1 - hk * 1.1), true);
    }

    // Disarm flying sword visual when `缴械夺兵` is in skill effects!
    if ((sk.effects || []).includes('缴械夺兵') && p > 0.48 && p < 0.92 && swordIm) {
      const dk = (p - 0.48) / 0.44;
      wxDrawImgFit(ctx, swordIm, hx - dk * 38, (groundY - 26) - Math.sin(dk * Math.PI) * 86, 66, 66, -dk * 14, 1 - dk * 0.4, false);
    }

    // Impact Sparks
    if (hitWin) {
      ctx.save();
      for (let sp = 0; sp < 18; sp++) {
        const ang = sp * 1.88;
        const spd0 = 26 + (sp % 5) * 18;
        const sx0 = hx + 6 + Math.cos(ang) * spd0 * hk;
        const sy0 = (groundY - 12) + Math.sin(ang) * spd0 * hk + hk * hk * 24;
        ctx.globalAlpha = Math.max(0, 1 - hk * 1.3);
        ctx.fillStyle = sp % 3 === 0 ? '#ffffff' : col;
        ctx.beginPath(); ctx.arc(sx0, sy0, 2.3 - hk * 1.2, 0, Math.PI * 2); ctx.fill();
      }
      ctx.restore();
    }

    // Overhead Monster Skill Banner + Floating Status/Damage Text
    ctx.save();
    ctx.font = 'bold 12.5px "Microsoft YaHei", sans-serif';
    const bannerTxt = '🐾 ' + c.shortName + ' · 施展【' + sk.name + '】';
    const tw = Math.min(W - 24, ctx.measureText(bannerTxt).width + 22);
    ctx.fillStyle = 'rgba(14,10,7,0.88)';
    ctx.fillRect(12, 10, tw, 23);
    ctx.strokeStyle = col; ctx.lineWidth = 1.3;
    ctx.strokeRect(12, 10, tw, 23);
    ctx.fillStyle = '#fff3d6'; ctx.textAlign = 'left';
    ctx.fillText(bannerTxt, 22, 25.5);
    ctx.restore();

    if (p >= 0.50 && p <= 0.93 && popups.length === 0) {
      const k = (p - 0.50) / 0.43;
      const effLabel = (sk.effects && sk.effects[0]) ? (' · ' + sk.effects[0]) : '';
      const numMatch = String(sk.dmg).match(/(\d+)\s*-\s*(\d+)/);
      const dmgVal = numMatch ? ('-' + Math.round((Number(numMatch[1]) + Number(numMatch[2])) * 0.52) + effLabel) : (sk.effects[0] || sk.name) + '!';
      const tx = mode === 'shell_thorns_quake' ? (hx + 30) : hx;
      const ty = 56 - k * 22;
      ctx.save();
      ctx.globalAlpha = Math.min(1, (1 - k) * 2.2);
      ctx.textAlign = 'center';
      ctx.font = 'bold 16.5px "Microsoft YaHei", Georgia, serif';
      ctx.strokeStyle = '#120b07'; ctx.lineWidth = 4;
      ctx.strokeText(dmgVal, tx, ty);
      ctx.fillStyle = col;
      ctx.fillText(dmgVal, tx, ty);
      ctx.restore();
    }
    popups.forEach(pp => {
      ctx.save();
      ctx.globalAlpha = Math.max(0, Math.min(1, pp.a));
      ctx.textAlign = 'center'; ctx.font = 'bold 15.5px Georgia, serif';
      ctx.strokeStyle = '#120b07'; ctx.lineWidth = 3.5;
      ctx.strokeText(pp.txt, pp.x, pp.y);
      ctx.fillStyle = pp.col || col;
      ctx.fillText(pp.txt, pp.x, pp.y);
      ctx.restore();
    });

    ctx.restore();
    const nextId = requestAnimationFrame(step);
    if (isModal) shModalRafId = nextId; else shMainRafId = nextId;
  }

  const initId = requestAnimationFrame(step);
  if (isModal) shModalRafId = initId; else shMainRafId = initId;
}

function renderShanHaiTopTheater() {
  const headerTabs = '<div class="sh-hero-tabs">' +
    '<div class="sh-hero-modes" role="tablist" aria-label="万妖沙盘切换">' +
      '<button type="button" data-sh-hero="arena" aria-pressed="' + String(shHeroTab === 'arena') + '">⚡ 60fps 异兽战棋技能动作实战演武台</button>' +
      '<button type="button" data-sh-hero="lairs" aria-pressed="' + String(shHeroTab === 'lairs') + '">🗺 六十四座山海秘境 · 遭遇战棋阵沙盘</button>' +
    '</div>' +
    '<small style="color:var(--quiet);font-size:12px">全 <b>136</b> 种山海异兽（+3 召唤衍生物）均已嵌合 <code>208×284</code> 实机战棋底座，支持 <b>342</b> 式专属动作实时演武</small>' +
  '</div>';

  if (shHeroTab === 'lairs') {
    const boss = shById.get(shSelectedLairBossId) || shBosses64[0];
    const lair = boss.lair || {name: '山海秘境', desc: '', img: 'art/hd/wx_shanhai_zhuyan.png'};
    const opts = shBosses64.map((b, idx) =>
      '<option value="' + escapeAttr(b.id) + '"' + (b.id === boss.id ? ' selected' : '') + '>' +
      String(idx + 1).padStart(2, '0') + '. ' + html((b.lair ? b.lair.name : b.name) + '（首领：' + b.shortName + '）') + '</option>'
    ).join('');

    const retinue = (boss.companions || []).map(cid => shById.get(cid)).filter(Boolean);
    const pawnUnitHtml = (u, isLead) =>
      '<button type="button" class="sh-board-pawn' + (isLead ? ' is-boss' : '') + '" data-sh-detail="' + escapeAttr(u.id) + '" title="点击查看 ' + escapeAttr(u.name) + ' 全息棋子属性与技能演武">' +
        '<span style="font-size:10px;color:' + (isLead ? '#ffcf7d' : '#b8a68a') + '">' + (isLead ? '👑 秘境首领 · ' + html(u.rank) : '🐾 伴生护法') + '</span>' +
        '<img src="art/pawns/' + escapeAttr(u.id) + '.png" alt="">' +
        '<strong>' + html(u.shortName) + '</strong>' +
        '<span style="font:10.5px/1.2 Consolas,monospace;color:#e6cfa8">血' + u.stats.hp + ' · 甲' + u.stats.bodyArmor + ' · ' + u.stats.ap + 'AP</span>' +
      '</button>';

    return '<section class="sh-hero-box">' + headerTabs +
      '<div class="sh-lair-sandbox">' +
        '<div class="sh-lair-info">' +
          '<select id="sh-lair-sel" class="sh-lair-select" aria-label="选择山海秘境">' + opts + '</select>' +
          '<div class="sh-lair-card">' +
            '<img src="' + escapeAttr(lair.img) + '" alt="">' +
            '<strong style="display:block;font:700 15px/1.3 var(--serif);color:#ffe4af">' + html(lair.name) + '</strong>' +
            '<p style="margin:5px 0;font-size:12px;color:#d6c6ac;line-height:1.5">' + html(lair.desc) + '</p>' +
            (boss.core ? '<div style="font-size:11.5px;color:#ffd078;border-top:1px dashed #4f3d29;padding-top:5px">必掉内丹：' + html(boss.core.name) + '</div>' : '') +
          '</div>' +
        '</div>' +
        '<div>' +
          '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;font-size:12px;color:#dfd0b5">' +
            '<span>⚔ 秘境驻军实机战棋编队（点击任一棋子打开详览与演武）：</span>' +
            '<button type="button" class="nar-pill-btn" data-sh-cast="' + escapeAttr(boss.id) + ':0" style="padding:2px 9px;font-size:11.5px">⚡ 演武首领绝技</button>' +
          '</div>' +
          '<div class="sh-hex-board">' +
            pawnUnitHtml(boss, true) +
            retinue.map(r => pawnUnitHtml(r, false)).join('') +
          '</div>' +
          '<div style="margin-top:8px;padding:7px 10px;background:#1c150f;border-left:3px solid #d49b42;font-size:12px;color:#ead8b8">💡 <b>破阵要诀</b>：' + html(boss.counterplay) + '</div>' +
        '</div>' +
      '</div></section>';
  }

  const cur = shById.get(shCurCreatureId) || shById.get('wx_boss_zhuyan');
  const skIdx = Math.min(shCurSkillIdx, (cur.skills || []).length - 1);
  const sk = cur.skills[skIdx];
  const rosterPool = shRosterScope === 'all' ? shAllCreatures : shFeaturedIds.map(id => shById.get(id)).filter(Boolean);

  const skTabs = (cur.skills || []).map((s, idx) =>
    '<button type="button" class="sh-sk-tab" data-sh-cast="' + escapeAttr(cur.id) + ':' + idx + '" aria-pressed="' + String(idx === skIdx) + '">' +
      '<b>' + (idx === 0 && cur.kind === 'boss' ? '🔥 ' : '⚔ ') + html(s.name) + '</b>' +
      '<small>' + s.ap + 'AP · ' + s.qi + '气 · ' + html(s.range) + '</small>' +
    '</button>'
  ).join('');

  const pickBtns = rosterPool.map(c =>
    '<button type="button" class="sh-pick-btn" data-sh-cast="' + escapeAttr(c.id) + ':0" aria-pressed="' + String(c.id === cur.id) + '">' +
      '<img loading="lazy" src="art/pawns/' + escapeAttr(c.id) + '.png" alt="">' +
      '<span><b>' + html(c.shortName) + '</b><small>' + html(c.chapter + ' · ' + c.rank) + '</small></span>' +
    '</button>'
  ).join('');

  setTimeout(() => shStartMonsterCanvas('wx-shanhai-main-canvas', cur, skIdx, false), 0);

  return '<section class="sh-hero-box">' + headerTabs +
    '<div class="sh-theater-grid">' +
      '<div class="sh-canvas-col">' +
        '<div class="sh-canvas-wrap"><canvas id="wx-shanhai-main-canvas" width="460" height="266"></canvas></div>' +
        '<div class="sh-skill-switcher" role="group" aria-label="切换当前异兽技能">' + skTabs + '</div>' +
        '<div class="sh-ctrl-row">' +
          '<div>' +
            '<button type="button" data-sh-speed="toggle" aria-pressed="' + String(shAnimSpeed < 0.8) + '">' + (shAnimSpeed < 0.8 ? '🐢 0.45× 慢镜拆招中' : '🐢 0.45× 慢镜拆招') + '</button> ' +
            '<button type="button" data-sh-rand="1">🎲 随机换妖演武</button> ' +
            '<button type="button" data-sh-detail="' + escapeAttr(cur.id) + '">📜 查看「' + html(cur.shortName) + '」全息属性卡</button>' +
          '</div>' +
          '<span style="font-size:11px;color:#d6be96">动作原型：<code>' + html(sk.animMode) + '</code></span>' +
        '</div>' +
      '</div>' +
      '<div class="sh-roster-col">' +
        '<div class="sh-live-skill-card">' +
          '<div class="sh-live-skill-head"><strong>' + html(cur.name) + ' · 【' + html(sk.name) + '】</strong><span style="color:#d6b26d;font-size:11.5px">' + html(sk.cd) + '</span></div>' +
          '<div class="sh-live-metrics">' +
            '<span class="sh-metric">消耗 ' + sk.ap + ' AP / ' + sk.qi + ' 内息</span>' +
            '<span class="sh-metric">射程：' + html(sk.range) + '</span>' +
            '<span class="sh-metric">威力：' + html(String(sk.dmg)) + '</span>' +
            (sk.directPct ? '<span class="sh-metric">穿甲 ' + sk.directPct + '%</span>' : '') +
            (sk.armorPct ? '<span class="sh-metric">破甲 ' + sk.armorPct + '%</span>' : '') +
            (sk.effects || []).map(ef => '<span class="sh-metric" style="border-color:#b8763e;color:#ffdca8">附加：' + html(ef) + '</span>').join('') +
          '</div>' +
          '<div style="color:#e7dac3">' + html(sk.desc) + '</div>' +
          '<div style="margin-top:4px;font-size:11.5px;color:#b8cbb8">本命异禀【' + html(cur.traitName) + '】：' + html(cur.traitDesc) + '</div>' +
        '</div>' +
        '<div style="display:flex;justify-content:space-between;align-items:center;font-size:12px;color:#d8c8ad">' +
          '<span>点选异兽切换上台演武：</span>' +
          '<div>' +
            '<button type="button" class="nar-pill-btn" data-sh-scope="featured" style="padding:2px 8px;font-size:11px;' + (shRosterScope === 'featured' ? 'background:#6e261c;color:#fff;border-color:#6e261c' : '') + '">代表16妖</button> ' +
            '<button type="button" class="nar-pill-btn" data-sh-scope="all" style="padding:2px 8px;font-size:11px;' + (shRosterScope === 'all' ? 'background:#6e261c;color:#fff;border-color:#6e261c' : '') + '">全部万妖 (' + shAllCreatures.length + ')</button>' +
          '</div>' +
        '</div>' +
        '<div class="sh-pick-grid">' + pickBtns + '</div>' +
      '</div>' +
    '</div></section>';
}

function renderBeastPawnWell(c) {
  const isMap = shDisplayMode === 'world';
  const isCorpse = shDisplayMode === 'corpse';
  const isHd = shDisplayMode === 'hd';
  const imgSrc = shPawnSrc(c, shDisplayMode);
  const hpPct = 100;
  const armPct = Math.min(100, Math.round((c.stats.bodyArmor / 400) * 100));

  const modeBadge = isMap ? '68×106 大地图游荡棋' :
                    (isCorpse ? '196×172 阵亡倒地尸骸' :
                    (isHd ? '256×256 手绘立绘原画' : '208×284 战场实机底座棋子'));

  return '<div class="sh-pawn-stage' + (c.kind === 'boss' ? ' is-boss' : '') + (isMap ? ' map-bg' : '') + '" data-sh-detail="' + escapeAttr(c.id) + '" title="点击检视四态实机棋子、完整八维面板与60fps技能动作">' +
    (!isHd ? '<span class="sh-hex-floor"></span>' : '') +
    (shDisplayMode === 'pawn' ? (
      '<span class="sh-bb-bars">' +
        '<span class="sh-bar-track"><span class="sh-bar-arm" style="width:' + Math.max(12, armPct) + '%"></span></span>' +
        '<span class="sh-bar-track"><span class="sh-bar-hp" style="width:' + hpPct + '%"></span></span>' +
      '</span>'
    ) : '') +
    '<span class="sh-stage-tag">' + (c.kind === 'boss' ? '👑 ' : '🐾 ') + html(c.bodyLabel) + '</span>' +
    '<img loading="lazy" class="sh-pawn-img' + (isMap ? ' world-fig' : '') + (isCorpse ? ' corpse-img' : '') + (shFlipFacing ? ' flip-x' : '') + '" src="' + escapeAttr(imgSrc) + '" alt="' + escapeAttr(c.name) + '">' +
    '<span class="sh-stage-sub' + (isMap ? ' sh-map-Stage-sub' : '') + '">' + html(modeBadge) + '</span>' +
  '</div>';
}

function renderShanHaiBestiaryView(query) {
  if (state.shc === 'lairs') {
    shHeroTab = 'lairs';
  }
  const topHtml = !query && state.p === 1 ? renderShanHaiTopTheater() : '';

  const modeBar = '<div class="sh-modebar">' +
    '<div class="sh-modes" role="group" aria-label="棋子形态切换">' +
      '<span>棋子实机形态：</span>' +
      '<button type="button" data-sh-mode="pawn" aria-pressed="' + String(shDisplayMode === 'pawn') + '">♟ 战场六角格底座棋子 (1:1)</button>' +
      '<button type="button" data-sh-mode="world" aria-pressed="' + String(shDisplayMode === 'world') + '">🗺 大地图游荡小棋子</button>' +
      '<button type="button" data-sh-mode="corpse" aria-pressed="' + String(shDisplayMode === 'corpse') + '">💀 阵亡倒地尸骸 (_dead)</button>' +
      '<button type="button" data-sh-mode="hd" aria-pressed="' + String(shDisplayMode === 'hd') + '">🖼 手绘原画图鉴</button>' +
      '<button type="button" data-sh-flip="1" aria-pressed="' + String(shFlipFacing) + '">' + (shFlipFacing ? '⇄ 当前朝右（友军位）' : '⇄ 当前朝左（敌军位）') + '</button>' +
    '</div>' +
    '<span style="color:var(--quiet);font-size:12px">点击卡片任意招式按钮可直接驱动上方 60fps 战棋演武台</span>' +
  '</div>';

  const ranks = [
    ['', '全部品阶 (136)'],
    ['山海四凶', '山海四凶 (4)'],
    ['太古神魔', '太古神魔 (20)'],
    ['秘境妖皇', '秘境妖皇 (40)'],
    ['荒泽精英', '荒泽精英 (28)'],
    ['山海群妖', '山海群妖 (44)'],
    ['伴生衍生物', '召唤衍生物 (+3)']
  ];
  const rankBar = '<div class="sh-ranks" role="group" aria-label="异兽品阶筛选">' +
    ranks.map(([rk, lbl]) =>
      '<button type="button" data-sh-rank="' + escapeAttr(rk) + '" aria-pressed="' + String((state.shr || '') === rk) + '">' + html(lbl) + '</button>'
    ).join('') + '</div>';

  const found = shMatchingCreatures(query);
  if (!found.length) {
    return topHtml + modeBar + rankBar + emptyState(0);
  }

  const pageSize = 36;
  const pages = Math.max(1, Math.ceil(found.length / pageSize));
  state.p = Math.min(Math.max(1, state.p), pages);
  const slice = found.slice((state.p - 1) * pageSize, state.p * pageSize);

  const cardsHtml = slice.map(c => {
    const rCls = c.rank === '山海四凶' ? ' rank-fiend' : (c.rank === '太古神魔' ? ' rank-god' : (c.rank === '秘境妖皇' ? ' rank-king' : ''));
    const st = c.stats;
    const skBtns = (c.skills || []).map((s, si) =>
      '<button type="button" class="sh-sk-chip" data-sh-cast="' + escapeAttr(c.id) + ':' + si + '" title="点击在演武台播放【' + escapeAttr(s.name) + '】：' + escapeAttr(s.desc) + '">' +
        '⚡ ' + html(s.name) + ' <em>' + s.ap + 'AP</em></button>'
    ).join('');

    return '<article class="sh-card' + rCls + '">' +
      renderBeastPawnWell(c) +
      '<div class="sh-card-head"><h3><button type="button" class="entry-btn" data-sh-detail="' + escapeAttr(c.id) + '">' + html(c.name) + '</button></h3>' +
        tag(c.rank) + '</div>' +
      '<div class="sh-chap-line"><span>典出《' + html(c.chapter) + '》· 原型 <code>' + html(c.archetype) + '</code></span><span>' + st.ap + ' AP</span></div>' +
      '<div class="sh-stat-strip">' +
        '<div class="sh-st-cell"><small>气血 HP</small><b>' + st.hp + '</b></div>' +
        '<div class="sh-st-cell"><small>头/身甲</small><b>' + st.headArmor + '/' + st.bodyArmor + '</b></div>' +
        '<div class="sh-st-cell"><small>武艺/招架</small><b>' + st.mSkill + '/' + st.mDef + '</b></div>' +
        '<div class="sh-st-cell"><small>身法/定力</small><b>' + st.init + '/' + st.resolve + '</b></div>' +
      '</div>' +
      '<div class="sh-trait-box"><strong>✦ 本命异禀 · ' + html(c.traitName) + '</strong>' + html(c.traitDesc) + '</div>' +
      '<div class="sh-skill-chips">' + skBtns + '</div>' +
      '<div class="sh-card-foot"><span>' + html(c.core ? c.core.name : ('奇材：' + (c.trophy || '山海兽革'))) + '</span>' +
        '<button type="button" class="linkbtn" data-sh-detail="' + escapeAttr(c.id) + '">全息棋子与面板 ▸</button></div>' +
    '</article>';
  }).join('');

  return topHtml + modeBar + rankBar + '<div class="sh-grid">' + cardsHtml + '</div>' + pager(pages);
}

function showShanHaiCreatureModal(c, initSkillIdx) {
  if (!c) return;
  shModalCreatureId = c.id;
  shModalSkillIdx = initSkillIdx || 0;
  const st = c.stats;
  const sk = c.skills[shModalSkillIdx] || c.skills[0];

  const fourStatesHtml = '<div class="sh-modal-pawns">' +
    '<div class="sh-mp-box"><img src="art/pawns/' + escapeAttr(c.id) + '.png" alt=""><span>① 战场六角格棋子 (208×284)</span></div>' +
    '<div class="sh-mp-box map-cell"><img src="art/world_entity/' + escapeAttr(c.worldFigId) + '.png" alt=""><span>② 大地图游荡小棋 (68×106)</span></div>' +
    '<div class="sh-mp-box"><img src="art/busts/beasts_dead/' + escapeAttr(c.id) + '_dead.png" alt=""><span>③ 阵亡倒地尸骸 (_dead)</span></div>' +
    '<div class="sh-mp-box"><img src="art/hd/' + escapeAttr(c.id) + '.png" alt=""><span>④ 手绘高清原画 (256px)</span></div>' +
  '</div>';

  const modalSkBtns = (c.skills || []).map((s, idx) =>
    '<button type="button" class="sh-sk-tab" data-sh-modal-sk="' + idx + '" aria-pressed="' + String(idx === shModalSkillIdx) + '">' +
      '<b>⚡ ' + html(s.name) + '</b><small>' + s.ap + 'AP · ' + html(s.range) + ' · ' + html(String(s.dmg)) + '</small></button>'
  ).join('');

  const animBoxHtml = '<div class="art-anim-dialog-box">' +
    '<div style="display:flex;justify-content:space-between;align-items:center;font-size:12px;color:#f0dec0">' +
      '<strong>⚡ 实机战棋技能动作演武：【' + html(sk.name) + '】</strong><span>点下方按钮切换不同招式轨迹</span></div>' +
    '<div class="sh-canvas-wrap"><canvas id="wx-shanhai-modal-canvas" width="460" height="256"></canvas></div>' +
    '<div class="sh-skill-switcher">' + modalSkBtns + '</div>' +
  '</div>';

  const meter = (lbl, val, maxV) =>
    '<div class="sh-bar-row"><span>' + html(lbl) + '</span><b>' + html(String(val)) + '</b>' +
    '<div class="sh-mini-meter"><i style="width:' + Math.min(100, Math.max(4, Math.round((Number(String(val).split('/')[0]) / maxV) * 100))) + '%"></i></div></div>';

  const statPanelHtml = '<div class="detail-article"><h3>一、D100 战场八维与护甲面板</h3>' +
    '<div class="sh-stat-grid8">' +
      meter('气血上限', st.hp, 850) +
      meter('行动点 AP', st.ap, 12) +
      meter('头部护甲', st.headArmor, 320) +
      meter('身躯护甲', st.bodyArmor, 420) +
      meter('武艺命中', st.mSkill, 100) +
      meter('射艺/吐息', st.rSkill, 95) +
      meter('近身招架', st.mDef, 42) +
      meter('远射避暗', st.rDef, 42) +
      meter('先攻身法', st.init, 155) +
      meter('心志定力', st.resolve, 160) +
      meter('内息容量', st.fatigue, 300) +
      meter('讨伐阅历', st.xp, 1000) +
    '</div></div>';

  const traitHtml = '<div class="detail-article"><h3>二、本命山海异禀与抗性克制</h3>' +
    '<p><strong>【' + html(c.traitName) + '】</strong>：' + html(c.traitDesc) + '</p>' +
    '<p><strong>躯体抗性</strong>：' + (c.immunities || []).map(x => '<code style="margin-right:5px">' + html(x) + '</code>').join('') + '</p>' +
    '<p><strong>讨伐破局要诀</strong>：' + html(c.counterplay) + '</p></div>';

  const skillsListHtml = '<div class="detail-article"><h3>三、专属主动技能与动作明细（共 ' + c.skills.length + ' 式）</h3>' +
    '<div class="sh-skill-detail-list">' + (c.skills || []).map(s =>
      '<div class="sh-skill-detail-item">' +
        '<div class="sh-skill-detail-top"><strong>' + html(s.name) + '</strong>' +
        '<span style="font-size:11.5px;color:#6e4611"><code>' + s.ap + ' AP</code> · <code>' + s.qi + ' 内息</code> · <code>' + html(s.range) + '</code> · <code>' + html(s.cd) + '</code></span></div>' +
        '<div style="font-size:12px;color:#4a5852;margin-bottom:4px">伤害/效果：<b>' + html(String(s.dmg)) + '</b>' +
          (s.directPct ? ' ｜ 穿甲率 <b>' + s.directPct + '%</b>' : '') +
          (s.armorPct ? ' ｜ 破甲率 <b>' + s.armorPct + '%</b>' : '') +
          ((s.effects && s.effects.length) ? ' ｜ 状态：<b>' + html(s.effects.join('、')) + '</b>' : '') +
        '</div>' +
        '<p style="margin:0;font-size:13px;color:#26322f">' + html(s.desc) + '</p>' +
      '</div>'
    ).join('') + '</div></div>';

  const loreLootHtml = '<div class="detail-article"><h3>四、《山海经》典籍考据与秘境掉落</h3>' +
    '<p>' + html(c.classicQuote) + '</p>' +
    (c.core ? '<p><strong>专属山海内丹</strong>：【' + html(c.core.name) + '】（价值 ' + c.core.value + ' 两）—— ' + html(c.core.desc) + '</p>' : '') +
    (c.lair ? '<p><strong>盘踞山海秘境</strong>：【' + html(c.lair.name) + '】—— ' + html(c.lair.desc) + '</p>' : '') +
    (c.trophy ? '<p><strong>百工猎妖异材</strong>：【' + html(c.trophy) + '】（可入城镇百工猎妖炼丹房炼丹制甲）</p>' : '') +
  '</div>';

  const rows = [
    ['异兽编号', '<code>' + html(c.id) + '</code> · 大地图棋子 <code>' + html(c.worldFigId) + '</code>'],
    ['品阶篇章', tag(c.rank) + ' · 《山海经·' + html(c.chapter) + '》 · ' + html(c.bodyLabel) + ' (<code>' + html(c.archetype) + '</code>)'],
  ];

  openDialog(c.name, rows, 'art/pawns/' + c.id + '.png', fourStatesHtml + animBoxHtml + statPanelHtml + traitHtml + skillsListHtml + loreLootHtml);
  const dEl = element('detail');
  if (dEl) dEl.style.width = 'min(740px, calc(100vw - 24px))';
  setTimeout(() => shStartMonsterCanvas('wx-shanhai-modal-canvas', c, shModalSkillIdx, true), 0);
}

// Wrap `drawRailForView` & `showArtDetail` non-destructively!
const _shPrevDrawRail = drawRailForView;
drawRailForView = function() {
  if (state.v === 'bestiary') {
    const nav = element('chapters');
    const sel = element('mobile-group');
    const railTitle = document.querySelector('.rail h2');
    if (railTitle) railTitle.textContent = '山海万妖卷目';
    const items = [
      {id: '',      idx: '全', label: '全部山海万妖 (' + shSpecies136.length + ')'},
      {id: 'boss',  idx: '首', label: '六十四大妖首领 (64)'},
      {id: 'wild',  idx: '野', label: '七十二伴生异兽 (72)'},
      ...shBookGroups.map(g => ({
        id: g.id,
        idx: g.idx,
        label: g.name + ' (' + shSpecies136.filter(c => c.bookGroup === g.id).length + ')'
      })),
      {id: 'spawn', idx: '衍', label: '伴生召唤衍生物 (+3)'},
      {id: 'lairs', idx: '境', label: '六十四秘境战阵 (64)'}
    ];
    nav.innerHTML = items.map(it =>
      '<button data-sh-chap="' + escapeAttr(it.id) + '" aria-current="' + String((state.shc || '') === it.id) + '">' +
      '<span class="idx">' + html(it.idx) + '</span>' + html(it.label) + '</button>'
    ).join('');
    sel.innerHTML = items.map(it => '<option value="' + escapeAttr(it.id) + '">' + html(it.label) + '</option>').join('');
    sel.value = state.shc || '';
    return;
  }
  _shPrevDrawRail();
};

const _shPrevShowArtDetail = showArtDetail;
showArtDetail = function(a) {
  if (a && shById.has(a.id)) {
    showShanHaiCreatureModal(shById.get(a.id), 0);
    return;
  }
  _shPrevShowArtDetail(a);
};
// === SHANHAI_BESTIARY_END ==="""


def patch_art_studio_script():
    """Also upgrade `tools/inject_wiki_art_studio.py` so `4_beasts` in Art Studio supports Pawn Base preview (`♟ 战棋底座`)!"""
    studio_p = ROOT / "tools" / "inject_wiki_art_studio.py"
    txt = studio_p.read_text(encoding="utf-8")

    # 1. Add `pawn` mode button in `renderArtView`
    if 'data-art-mode="pawn"' not in txt:
        txt = txt.replace(
            '\'<button data-art-mode="slot" aria-pressed="\' + String(artPreviewMode === \'slot\') + \'">原版暗槽 (1:1)</button>\' +',
            '\'<button data-art-mode="slot" aria-pressed="\' + String(artPreviewMode === \'slot\') + \'">原版暗槽 (1:1)</button>\' +\n'
            '    \'<button data-art-mode="pawn" aria-pressed="\' + String(artPreviewMode === \'pawn\') + \'">♟ 战棋底座棋子</button>\' +',
            1,
        )
    # 2. Render `a.pawnPath` when `a.pawnPath` exists and mode is `slot` or `pawn`!
    old_src_line = "  const imgSrc = useHd ? a.hdPath : (useSw ? a.swPath : a.previewPath);"
    new_src_line = "  const usePawn = !!a.pawnPath && (artPreviewMode === 'pawn' || artPreviewMode === 'slot');\n  const imgSrc = useHd ? a.hdPath : (useSw ? a.swPath : (usePawn ? a.pawnPath : a.previewPath));"
    if "const usePawn =" not in txt and old_src_line in txt:
        txt = txt.replace(old_src_line, new_src_line, 1)
        txt = txt.replace(
            "a.slotKind === 'boss' ? '104×142 胸像贴图' :",
            "a.slotKind === 'boss' ? (usePawn ? '208×284 实机战棋底座' : '104×142 胸像贴图') :",
            1,
        )

    # 3. Update header stats line in `inject_wiki_art_studio.py` to reflect 136 Shan Hai Beasts
    txt = re.sub(
        r"山海大妖 <b>\d+</b>",
        "山海万妖 <b>136</b>",
        txt,
    )
    studio_p.write_text(txt, encoding="utf-8")


def main():
    patch_art_studio_script()
    # Run `inject_wiki_art_studio.py` first so `art-data` has all 136 `4_beasts` & `pawnPath` fields!
    import inject_wiki_art_studio
    inject_wiki_art_studio.main()

    # Re-run `inject_wiki_narrative.py` so `bios` & `events` stay synced cleanly!
    import inject_wiki_narrative
    inject_wiki_narrative.main()

    bestiary_payload = build_all_bestiary_records()
    bestiary_json = json.dumps(bestiary_payload, ensure_ascii=False, separators=(",", ":"))
    html_txt = WIKI_PATH.read_text(encoding="utf-8")

    # 1. Inject / update SHANHAI_CSS before </style>
    if "/* === SHANHAI_BESTIARY_BEGIN === */" in html_txt:
        html_txt = re.sub(
            r"/\* === SHANHAI_BESTIARY_BEGIN === \*/[\s\S]*?/\* === SHANHAI_BESTIARY_END === \*/",
            lambda _m: SHANHAI_CSS,
            html_txt,
            count=1,
        )
    else:
        html_txt = html_txt.replace("</style>", SHANHAI_CSS + "\n</style>", 1)

    # 2. Add `山海万妖志 (136)` top navigation tab right after `美术图鉴`!
    html_txt = re.sub(
        r'<button data-view="bestiary"[^>]*>[^<]*</button>',
        "",
        html_txt,
    )
    html_txt = html_txt.replace(
        '<button data-view="art" aria-pressed="false">美术图鉴</button>',
        '<button data-view="bestiary" aria-pressed="false">山海万妖志 (136)</button>'
        '<button data-view="art" aria-pressed="false">美术图鉴</button>',
        1,
    )

    # 3. Inject `<script type="application/json" id="shanhai-data">`
    data_tag = f'<script type="application/json" id="shanhai-data">\n{bestiary_json}\n</script>'
    if 'id="shanhai-data"' in html_txt:
        html_txt = re.sub(
            r'<script type="application/json" id="shanhai-data">[\s\S]*?</script>',
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

    # 4. Extend `blankState`, `views`, and `readUrl` for `v='bestiary'`, `shc`, `shr`!
    html_txt = re.sub(
        r"const blankState = \(\) => \(\{[^}]+\}\);",
        "const blankState = () => ({v:'systems',g:0,q:'',r:'',k:'',t:'',a:'',c:'',as:'',ag:'',ast:'',bt:'',bg:'',ec:'',shc:'',shr:'',p:1});",
        html_txt,
        count=1,
    )
    html_txt = re.sub(
        r"const views=\[[^\]]+\];",
        "const views=['systems','entries','articles','additions','bestiary','art','bios','events'];",
        html_txt,
        count=1,
    )
    if "const shc=p.get('shc')" not in html_txt:
        html_txt = html_txt.replace(
            "const bt=p.get('bt')||''; const bg=p.get('bg')||''; const ec=p.get('ec')||'';",
            "const bt=p.get('bt')||''; const bg=p.get('bg')||''; const ec=p.get('ec')||'';\n  const shc=p.get('shc')||''; const shr=p.get('shr')||'';",
            1,
        )
    if "shc:v==='bestiary'" not in html_txt:
        html_txt = html_txt.replace(
            "bt:v==='bios'?bt:'',bg:v==='bios'?bg:'',ec:v==='events'?ec:'',",
            "bt:v==='bios'?bt:'',bg:v==='bios'?bg:'',ec:v==='events'?ec:'',\n    shc:v==='bestiary'?shc:'',shr:v==='bestiary'?shr:'',",
            1,
        )

    # 5. Inject `SHANHAI_JS` right after `// === NARRATIVE_WIKI_END ===`
    if "// === SHANHAI_BESTIARY_BEGIN ===" in html_txt:
        html_txt = re.sub(
            r"// === SHANHAI_BESTIARY_BEGIN ===[\s\S]*?// === SHANHAI_BESTIARY_END ===",
            lambda _m: SHANHAI_JS,
            html_txt,
            count=1,
        )
    else:
        html_txt = html_txt.replace(
            "// === NARRATIVE_WIKI_END ===",
            "// === NARRATIVE_WIKI_END ===\n\n" + SHANHAI_JS,
            1,
        )

    # 6. Hook `render()` for `state.v === 'bestiary'`
    if "else if(state.v==='bestiary')" not in html_txt:
        html_txt = html_txt.replace(
            "if(state.v!=='art'&&state.v!=='bios'&&state.v!=='events') element('mobile-group').value=String(state.g);",
            "if(state.v!=='art'&&state.v!=='bios'&&state.v!=='events'&&state.v!=='bestiary') element('mobile-group').value=String(state.g);",
            1,
        )
        html_txt = html_txt.replace(
            "  } else if(state.v==='art') {",
            "  } else if(state.v==='bestiary') {\n"
            "    const found=shMatchingCreatures(query);\n"
            "    cnt.textContent='《山海经·万妖全志》 · 当前显示 '+zhNum(found.length)+' 尊异兽战棋（全卷 136 物种 + 3 召唤衍生物 · 342 式专属动作）';\n"
            "    if(state.shc||state.shr) ctx.innerHTML='<button class=\"scope-clear\" data-sh-reset>清除万妖筛选</button>';\n"
            "    output=renderShanHaiBestiaryView(query);\n"
            "  } else if(state.v==='art') {",
            1,
        )

    # 7. Hook click & change listeners for `bestiary`
    sh_clicks = (
        "  if(d.shChap!==undefined) {if(d.shChap==='lairs')shHeroTab='lairs';change({v:'bestiary',shc:d.shChap});moveTop();return;}\n"
        "  if(d.shRank!==undefined) {change({v:'bestiary',shr:d.shRank,shc:d.shRank==='伴生衍生物'?'spawn':state.shc});return;}\n"
        "  if('shReset' in d) {change({shc:'',shr:'',q:''});return;}\n"
        "  if(d.shHero) {shHeroTab=d.shHero;render();return;}\n"
        "  if(d.shMode) {shDisplayMode=d.shMode;render();return;}\n"
        "  if(d.shFlip) {shFlipFacing=!shFlipFacing;render();return;}\n"
        "  if(d.shSpeed) {shAnimSpeed=(shAnimSpeed<0.8?1.0:0.45);render();return;}\n"
        "  if(d.shScope) {shRosterScope=d.shScope;render();return;}\n"
        "  if(d.shRand) {const r=shAllCreatures[Math.floor(Math.random()*shAllCreatures.length)];shCurCreatureId=r.id;shCurSkillIdx=0;shHeroTab='arena';render();return;}\n"
        "  if(d.shCast) {const pts=d.shCast.split(':');shCurCreatureId=pts[0];shCurSkillIdx=Number(pts[1])||0;shHeroTab='arena';render();moveTop();return;}\n"
        "  if(d.shDetail) {showShanHaiCreatureModal(shById.get(d.shDetail),0);return;}\n"
        "  if(d.shModalSk!==undefined) {showShanHaiCreatureModal(shById.get(shModalCreatureId),Number(d.shModalSk));return;}\n"
    )
    if "if(d.shChap!==undefined)" not in html_txt:
        html_txt = html_txt.replace(
            "  if('artStage' in d) {change({v:'art',as:d.artStage,ag:''});moveTop();return;}",
            "  if('artStage' in d) {change({v:'art',as:d.artStage,ag:''});moveTop();return;}\n" + sh_clicks,
            1,
        )

    if "e.target.id==='sh-lair-sel'" not in html_txt:
        html_txt = html_txt.replace(
            "element('mobile-group').addEventListener('change',e=>state.v==='art'?change({as:e.target.value,ag:''}):state.v==='bios'?change({bt:e.target.value,bg:''}):state.v==='events'?change({ec:e.target.value}):change({g:Number(e.target.value),k:'',a:''}));",
            "element('mobile-group').addEventListener('change',e=>state.v==='art'?change({as:e.target.value,ag:''}):state.v==='bestiary'?change({shc:e.target.value}):state.v==='bios'?change({bt:e.target.value,bg:''}):state.v==='events'?change({ec:e.target.value}):change({g:Number(e.target.value),k:'',a:''}));\n"
            "document.addEventListener('change',e=>{if(e.target&&e.target.id==='sh-lair-sel'){shSelectedLairBossId=e.target.value;shHeroTab='lairs';render();}});",
            1,
        )

    if "state.v==='bestiary'?{q:'',shc:'',shr:''}" not in html_txt:
        html_txt = html_txt.replace(
            "if('reset' in d){change(state.v==='art'?{q:'',as:'',ag:'',ast:''}:",
            "if('reset' in d){change(state.v==='art'?{q:'',as:'',ag:'',ast:''}:state.v==='bestiary'?{q:'',shc:'',shr:''}:",
            1,
        )

    WIKI_PATH.write_text(html_txt, encoding="utf-8")
    print(f"SUCCESS: Injected《山海万妖志 (136)》+ 60fps Monster Action Animator + 4-State Pawns into {WIKI_PATH} ({len(html_txt):,} chars)!")


if __name__ == "__main__":
    main()
