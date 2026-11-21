#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Idempotently install or update the interactive 「美术图鉴 & 原版级千人千面胸像工坊 & 72招独立演武剧场」 (#v=art)
inside 武侠百科.html without altering a single byte of <script id="book-data">.
"""

import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WIKI_PATH = os.path.join(ROOT, "山海武侠.html")
MANIFEST_PATH = os.path.join(ROOT, "art", "manifest.json")

ART_CSS = """/* === 美术图鉴工坊 (Art Studio) === */
.badge[data-r="百科已创制"]{background:#dfeee6;color:#1b4d3e;border:1px solid #a8cbb9;font-weight:650}
.badge[data-r="已实装入游戏"]{background:#f6ead0;color:#6e4611;border:1px solid #d8ba7c;font-weight:650}
.badge[data-r="待创制·已立项"]{background:#ecebe4;color:#59635e;border:1px solid #cfd4c8}
.art-overview{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,182px),1fr));gap:9px;margin:14px 0 16px}
.art-stage-btn{display:block;width:100%;text-align:left;padding:11px 13px;background:var(--sheet);border:1px solid var(--rule);border-top:3px solid #8a9b8c;border-radius:3px;transition:border-color .15s,background .15s}
.art-stage-btn:hover{background:#f3f6ef;border-color:#69816f}
.art-stage-btn[aria-current="true"]{border-color:var(--teal);border-top-color:#b8935f;background:#eef3ec}
.art-stage-btn strong{display:block;font:700 16px/1.3 var(--serif);color:#203d38}
.art-stage-btn small{display:block;margin-top:3px;color:var(--quiet);font-size:12px;line-height:1.45}
.art-stage-bar{height:5px;background:#e3e6dc;border-radius:3px;overflow:hidden;margin-top:7px}
.art-stage-bar span{display:block;height:100%;background:linear-gradient(90deg,#204f4a,#b8935f)}
.art-modebar{display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;padding:9px 12px;margin:0 0 14px;background:#eef1e8;border:1px solid var(--rule);border-radius:3px;font-size:13px}
.art-modes{display:flex;gap:6px;flex-wrap:wrap;align-items:center}
.art-modes button,.pd-presets button{padding:4px 10px;border:1px solid #b5bfb2;border-radius:3px;background:var(--sheet);color:var(--quiet);font-size:12.5px}
.art-modes button[aria-pressed="true"],.pd-presets button[aria-pressed="true"]{background:var(--teal);border-color:var(--teal);color:#fff9e9;font-weight:600}
.art-pipeline-tip{color:var(--quiet);font-size:12px}
.art-pipeline-tip code{background:#e2e6dc;padding:2px 6px;border-radius:3px;color:#223a35;font-size:11.5px}

/* === 千人千面 · 104×142 原版级像素锁合胸像工坊 === */
.pd-workshop{margin:0 0 18px;border:1px solid #b7bfa9;border-top:3px solid #204f4a;background:#f4f5ee;border-radius:3px;padding:12px 14px}
.pd-workshop>summary{cursor:pointer;display:flex;align-items:baseline;justify-content:space-between;gap:10px;flex-wrap:wrap;font:700 18px/1.35 var(--serif);color:#1f3d37;list-style:none}
.pd-workshop>summary::-webkit-details-marker{display:none}
.pd-workshop>summary small{font:normal 12.5px/1.4 var(--sans);color:var(--quiet)}
.pd-controls{display:flex;align-items:center;justify-content:space-between;gap:8px;flex-wrap:wrap;margin:10px 0 12px;padding-top:9px;border-top:1px solid #d7dcd0}
.pd-presets{display:flex;gap:6px;flex-wrap:wrap;align-items:center}
.pd-formula{font-size:12px;color:#465650}
.pd-formula b{color:#204f4a}
.pd-roster{display:grid;grid-template-columns:repeat(auto-fill,minmax(min(100%,196px),1fr));gap:10px}
.pd-card{background:#1c1612;border:1px solid #5a4733;border-top:2px solid #9d7b4c;border-radius:3px;padding:8px 9px;color:#e7dcc6;display:flex;flex-direction:column;box-shadow:0 2px 7px rgba(0,0,0,.25)}
.pd-card-top{display:flex;align-items:center;justify-content:space-between;gap:4px;margin-bottom:5px}
.pd-who{min-width:0}
.pd-who strong{display:block;font:700 14.5px/1.2 var(--serif);color:#f7ebd2;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.pd-who span{display:block;font-size:11px;color:#b8a589}
.pd-card-btns{display:flex;gap:3px;flex-shrink:0}
.pd-reroll-one{padding:2px 6px;border:1px solid #6e583f;border-radius:2px;background:#2a2119;color:#dfd0b4;font-size:11px}
.pd-reroll-one:hover{background:#3c2f23;border-color:#b8935f}
.pd-canvas{position:relative;width:100%;aspect-ratio:208/250;background:radial-gradient(circle at 50% 48%,#33281e,#14100c 84%);border:1px solid #463626;border-radius:2px;overflow:hidden;margin-bottom:6px;display:grid;place-items:center}
.pd-bust-frame{position:relative;height:94%;aspect-ratio:208/284}
.pd-bust-img{position:absolute;inset:0;width:100%;height:100%;object-fit:contain;pointer-events:none;user-select:none}
.pd-layer-shield{z-index:7}
.pd-layer-weapon{z-index:8}
.pd-tone-brown{filter:sepia(.42) saturate(1.25) contrast(1.06)}
.pd-tone-grey{filter:grayscale(1) contrast(1.18) brightness(1.22)}
.pd-tone-white{filter:grayscale(1) contrast(1.26) brightness(1.38)}
.pd-equip-dock{position:absolute;left:5px;right:5px;bottom:4px;display:flex;justify-content:space-between;pointer-events:none;z-index:12}
.pd-mini-slot{pointer-events:auto;width:34px;height:48px;background:rgba(14,11,8,.84);border:1px solid #68533b;border-radius:2px;display:grid;place-items:center;padding:2px;box-shadow:inset 0 0 4px #000}
.pd-mini-slot.sq{height:34px;align-self:flex-end}
.pd-mini-slot:hover{border-color:#d2ab6e}
.pd-mini-slot img{max-width:100%;max-height:100%;object-fit:contain}
.pd-parts{display:flex;flex-wrap:wrap;gap:3px;margin-top:auto}
.pd-chip{padding:1px 5px;border:1px solid #4d3d2c;border-radius:2px;background:#251d16;color:#cbbba0;font-size:10.5px;line-height:1.35;max-width:100%;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.pd-chip:hover{border-color:#b8935f;color:#fff4dc;background:#35291e}

/* === 单人捏脸换装器 (Character Customizer Dialog) === */
.pd-editor-wrap{display:grid;grid-template-columns:190px minmax(0,1fr);gap:14px;align-items:center;padding:12px;background:radial-gradient(circle at 30% 45%,#2c2219,#15100c 88%);border:1px solid #594732;border-radius:4px;margin:8px 0 12px;color:#eadec8}
@media(max-width:560px){.pd-editor-wrap{grid-template-columns:1fr}}
.pd-editor-stage{width:176px;aspect-ratio:208/284;margin:auto;position:relative}
.pd-editor-rows{display:grid;gap:6px}
.pd-step-row{display:grid;grid-template-columns:4.5em 28px minmax(0,1fr) 28px;gap:5px;align-items:center;font-size:12.5px}
.pd-step-row span.lbl{color:#bfa988;font-size:12px}
.pd-step-row strong{text-align:center;font-weight:600;color:#f7ebd2;background:#221b14;border:1px solid #4a3a29;padding:3px 6px;border-radius:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.pd-step-btn{height:26px;background:#2e241b;border:1px solid #6e583f;color:#f3e5c8;border-radius:2px;font-size:12px}
.pd-step-btn:hover{background:#433427;border-color:#cfa86b}

/* === 72招独立武学招式动作引擎 · 60fps 演武剧场 (Articulated Martial Combat Animator v2) === */
.vfx-arena{margin:0 0 18px;border:1px solid #b7bfa9;border-top:3px solid #8c5a2b;background:#f4f5ee;border-radius:3px;padding:12px 14px}
.vfx-arena-head{display:flex;align-items:baseline;justify-content:space-between;gap:10px;flex-wrap:wrap;margin-bottom:8px}
.vfx-arena-head strong{font:700 18px/1.35 var(--serif);color:#1f3d37}
.vfx-arena-head small{color:var(--quiet);font-size:12.5px}
.vfx-cat-tabs{display:flex;flex-wrap:wrap;gap:5px;margin-bottom:10px}
.vfx-cat-tabs button{padding:3px 9px;font-size:12px;border-radius:999px;background:#e5e8df;border:1px solid #b8c1b5;color:#273833}
.vfx-cat-tabs button[aria-pressed="true"]{background:#21413a;border-color:#21413a;color:#fff}
.vfx-stage-box{display:grid;grid-template-columns:440px minmax(0,1fr);gap:14px;align-items:start;padding:12px;background:radial-gradient(circle at 38% 52%,#2d231a,#120e0a 86%);border:1px solid #594732;border-radius:4px;color:#eadec8}
@media(max-width:860px){.vfx-stage-box{grid-template-columns:1fr}}
.vfx-left-col{display:grid;gap:7px}
.vfx-canvas-wrap{position:relative;width:100%;aspect-ratio:440/252;border:1px solid #6b5338;border-radius:3px;background:#100c09;overflow:hidden;box-shadow:0 3px 12px rgba(0,0,0,.45)}
.vfx-canvas-wrap canvas{display:block;width:100%;height:100%}
.vfx-ctrl-bar{display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:5px}
.vfx-ctrl-bar button{padding:3px 8px;font-size:11.5px;background:#292018;border:1px solid #6b543b;color:#f0e2c6;border-radius:2px}
.vfx-ctrl-bar button[aria-pressed="true"],.vfx-ctrl-bar button:hover{background:#463524;border-color:#d4ab6a;color:#fff7e4}
.vfx-strip-row{display:grid;grid-template-columns:repeat(4,1fr);gap:5px}
.vfx-frame-cell{display:grid;justify-items:center;gap:2px;padding:4px;background:#1c1611;border:1px solid #4d3d2b;border-radius:3px;color:#cbbba0;font-size:10.5px;cursor:pointer}
.vfx-frame-cell:hover,.vfx-frame-cell[aria-pressed="true"]{border-color:#e0b66b;background:#302419;color:#fff2d6}
.vfx-frame-cell img{width:54px;height:54px;object-fit:contain;pointer-events:none}
.vfx-skill-btns{display:grid;grid-template-columns:repeat(auto-fill,minmax(148px,1fr));gap:6px;max-height:336px;overflow-y:auto;padding-right:3px}
.vfx-cast-btn{display:flex;align-items:center;gap:7px;padding:5px 7px;background:#241c15;border:1px solid #574531;border-radius:3px;color:#eadcc3;font-size:12px;text-align:left}
.vfx-cast-btn:hover,.vfx-cast-btn[aria-pressed="true"]{background:#382b1f;border-color:#d4ab6a;color:#fff6e2}
.vfx-cast-btn img{width:28px;height:28px;flex-shrink:0;border:1px solid #6b553c}
.vfx-cast-meta b{display:block;font-size:12.5px;line-height:1.2}
.vfx-cast-meta small{display:block;font-size:10.5px;color:#d6b884}
.art-anim-dialog-box{margin:8px 0 12px;padding:12px;background:radial-gradient(circle at 40% 50%,#2b2118,#120e0b 88%);border:1px solid #5c4832;border-radius:4px;color:#eadec8;display:grid;gap:8px}

.art-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(min(100%,215px),1fr));gap:12px}
.art-grid.hd-mode{grid-template-columns:repeat(auto-fill,minmax(min(100%,265px),1fr))}
.art-card{display:flex;flex-direction:column;border:1px solid var(--rule);border-top:2px solid #69816f;background:var(--sheet);padding:11px 12px;border-radius:2px;transition:border-color .15s,box-shadow .15s}
.art-card:hover{border-color:#7d6845;box-shadow:0 3px 10px rgba(32,61,56,.08)}
.art-card.planned-card{border-top-color:#aeb7ad;background:#faf8f2}
.art-stage-well{width:100%;display:grid;place-items:center;min-height:106px;padding:12px;margin-bottom:9px;border-radius:3px;background:radial-gradient(circle at 50% 42%,#282019,#15110d 82%);border:1px solid #4a3b2a;box-shadow:inset 0 2px 8px rgba(0,0,0,.65);cursor:pointer;position:relative}
.art-grid.hd-mode .art-stage-well{min-height:196px}
.art-stage-well.checker-bg{background:repeating-conic-gradient(#342d27 0% 25%,#231e19 0% 50%) 50% / 14px 14px}
.bb-slot{display:grid;place-items:center;background:#120e0b;border:1px solid #5e4b35;box-shadow:inset 0 0 6px rgba(0,0,0,.85),0 1px 0 rgba(255,235,190,.08)}
.bb-slot-70{width:74px;height:74px}
.bb-slot-56{width:62px;height:62px}
.bb-slot-140{width:76px;height:146px}
.bb-slot-boss{width:118px;height:118px}
.bb-slot-pawn{width:112px;height:152px;background:transparent;border:0;box-shadow:none}
.bb-slot-pawn img{width:108px;height:148px;object-fit:contain}
.bb-slot-event{width:146px;height:146px;background:transparent;border:0;box-shadow:none}
.bb-slot-wide{width:100%;max-width:214px;aspect-ratio:16/9}
.bb-slot-wide-lg{width:352px;max-width:100%;aspect-ratio:16/9}
.bb-slot-camp{width:128px;height:128px}
.bb-slot-hd{width:176px;height:176px;background:transparent;border:0;box-shadow:none}
.bb-slot img{display:block;image-rendering:auto;max-width:100%;max-height:100%;object-fit:contain}
.bb-slot-70 img{width:70px;height:70px}
.bb-slot-56 img{width:56px;height:56px}
.bb-slot-140 img{width:70px;height:140px}
.bb-slot-boss img{width:112px;height:112px}
.bb-slot-event img{width:144px;height:144px}
.bb-slot-wide img,.bb-slot-wide-lg img{width:100%;height:100%;object-fit:cover}
.bb-slot-camp img{max-width:122px;max-height:122px}
.bb-slot-hd img{max-width:172px;max-height:172px}
.art-spec-tag{position:absolute;right:6px;bottom:5px;font:10.5px/1.2 Consolas,monospace;color:#b8a68a;background:rgba(12,9,7,.72);padding:2px 5px;border-radius:2px;border:1px solid rgba(130,106,74,.35)}
.art-placeholder-box{display:grid;place-items:center;text-align:center;width:100%;min-height:78px;border:1px dashed #6b5842;border-radius:2px;color:#bca98c;padding:8px;font-size:12px;line-height:1.45}
.art-placeholder-box strong{display:block;font-family:var(--serif);font-size:15px;color:#dfd0b6;margin-bottom:2px}
.art-card-head{display:flex;align-items:flex-start;justify-content:space-between;gap:6px;margin-bottom:3px}
.art-card h3{font-size:16.5px;margin:0;line-height:1.3}
.art-card .art-sub{font-size:12px;color:var(--quiet);margin-bottom:5px}
.art-card .art-brief{font-size:12.5px;color:#3d4945;line-height:1.5;margin:4px 0 8px;flex:1}
.art-card-foot{display:flex;align-items:center;justify-content:space-between;gap:6px;padding-top:6px;border-top:1px solid #e5e7de;font-size:11.5px;color:var(--quiet)}
.art-card-foot code{font-size:11px;color:#4a5852;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:135px}
.art-dialog-showcase{display:flex;gap:14px;flex-wrap:wrap;align-items:center;justify-content:center;padding:16px;margin:8px 0 14px;background:radial-gradient(circle at 50% 40%,#2a211a,#14100c 85%);border:1px solid #594732;border-radius:4px}
.art-showcase-col{display:grid;justify-items:center;gap:6px;color:#d6c7ae;font-size:11.5px}
.art-cmd-box{display:flex;align-items:center;justify-content:space-between;gap:8px;margin-top:12px;padding:8px 10px;background:#eef1e8;border:1px solid var(--rule);border-radius:3px;font-size:12px}
.art-cmd-box code{overflow-wrap:anywhere;color:#1f3d37}
"""

ART_JS = """// === ART_STUDIO_BEGIN ===
const artManifest = JSON.parse(document.getElementById('art-data').textContent);
const artAssets = artManifest.assets || [];
const artById = new Map(artAssets.map(a => [a.id, a]));
const artStages = artManifest.stages || [];
const artSearchMap = new Map(artAssets.map(a => [
  a.id,
  field(a.id, a.name, a.sub, a.group, a.spec, a.brief, a.choreoLabel || '', a.choreoDesc || '', a.gameTarget, a.codeRef, a.vanillaFallback)
]));
let artPreviewMode = 'slot';

// === 千人千面 · 104×142 原版级像素锁合胸像生成器（含手持兵盾层） ===
const pdPools = {
  face: artAssets.filter(a => a.pdRole === 'face' && a.bustPath),
  faceMale: artAssets.filter(a => a.pdRole === 'face' && a.bustPath && a.pdGender !== 'f'),
  faceFem: artAssets.filter(a => a.pdRole === 'face' && a.bustPath && a.pdGender === 'f'),
  hair: artAssets.filter(a => a.pdRole === 'hair' && a.bustPath),
  beard: artAssets.filter(a => a.pdRole === 'beard' && a.bustPath),
  scar: artAssets.filter(a => a.pdRole === 'scar' && a.bustPath),
  hat: artAssets.filter(a => a.pdRole === 'hat' && a.bustPath),
  torso: artAssets.filter(a => a.pdRole === 'torso' && a.bustPath),
  weapon: artAssets.filter(a => a.pdRole === 'weapon'),
  shield: artAssets.filter(a => a.pdRole === 'shield')
};
const pdHairTones = [
  {id: 'black', label: '乌墨黑', cls: ''},
  {id: 'brown', label: '风霜褐', cls: ' pd-tone-brown'},
  {id: 'grey',  label: '两鬓霜灰', cls: ' pd-tone-grey'},
  {id: 'white', label: '鹤发银白', cls: ' pd-tone-white'}
];
const pdFullMaskHats = new Set(['wx_hat_08', 'wx_hat_17', 'wx_hat_18', 'wx_hat_23', 'wx_hat_29']);
const pdTrueFullVisorHats = new Set(['wx_hat_18', 'wx_hat_23', 'wx_hat_29']);
const pdOpenCrownHats = new Set(['wx_hat_01', 'wx_hat_09', 'wx_hat_10', 'wx_hat_12', 'wx_hat_13', 'wx_hat_14', 'wx_hat_15', 'wx_hat_16', 'wx_hat_17', 'wx_hat_21', 'wx_hat_22']);
const pdHideHairHats = new Set(['wx_hat_18', 'wx_hat_23', 'wx_hat_29', 'wx_hat_32', 'wx_helm_taotie', 'wx_helm_chiyou']);
const pdHairHasBuiltInCap = new Set(['wx_hair_04', 'wx_hair_07', 'wx_hair_08', 'wx_hair_15', 'wx_hair_16', 'wx_hair_21', 'wx_hair_24']);
const pdTwoHandKeywords = ['双手', '长兵', '长枪', '长槊', '马槊', '画戟', '大刀', '陌刀', '重宝刀', '长斧', '重钺', '巨斧', '大板斧', '长棍', '包头棍', '少林棍', '拐杖', '三节棍', '方便杖', '金锡杖', '重杖', '绿玉竹杖', '混铁盘龙棍', '大铁锤', '重锤', '巨锤', '破城锤', '金锤', '扫子枷', '成对', '拳', '爪', '缠手', '指虎', '护腕', '护手', '弓', '弩', '铳', '竹矛', '草叉', '朴刀', '方便铲', '两刃刀', '长戟', '狼牙槊', '大剑', '重铁剑', '斩蛇长剑', '苗刀'];

const pdSurnames = ['沈', '陆', '裴', '顾', '燕', '秦', '韩', '萧', '赵', '林', '石', '雷', '孟', '白', '崔', '霍', '唐', '罗', '铁', '冷', '柳', '谢', '严', '胡', '苏', '叶', '温', '花'];
const pdGivenM = ['断山', '青锋', '惊鸿', '铁牛', '慎之', '无忌', '长风', '千山', '不平', '重楼', '九斤', '破虏', '云舟', '寒星', '十三', '沧海', '敬塘', '七郎', '玄礼', '去疾', '追风', '守义', '知秋', '万里'];
const pdGivenF = ['青霜', '惊鸿', '灵素', '凝雪', '红药', '听雨', '拂衣', '晚晴', '若水', '绛雪', '凌波', '月华', '无双', '飞燕', '芷若', '玉衡'];
const pdBackgrounds = {
  civ: ['庄稼把式', '锻炉铁匠', '市井屠户', '渡口渔夫', '深山猎户', '悬壶游医', '码头脚夫', '落第寒儒', '关外马夫', '江湖武生'],
  sect: ['少室护院僧', '太和清修道', '清风门少侠', '华岳剑宗徒', '丐帮污衣弟子', '蜀中唐门客', '峨眉俗家徒', '昆仑试剑客', '药王谷采药人', '天机阁门人'],
  heroine: ['峨眉执剑女侠', '威远女少镖头', '塞外神射女骑', '龙门客栈掌柜', '药王谷灵医女', '无常夜行女刺', '南疆五毒圣女', '六扇门女铁捕', '昆仑雪山剑女', '梨园刀马武旦', '沧溟水寨女魁', '天机奇门才女'],
  army: ['披甲悍将', '走镖总镖头', '藩镇退伍都头', '边关夜不收', '神机营老卒', '殿前宿卫校尉'],
  outlaw: ['绿林悔过客', '塞外响马客', '无常鬼市暗桩', '云梦泽水客', '五毒试蛊人', '独行快刀客']
};

let pdPreset = 'mixed';
let pdShowHelmets = false;
let pdShowWeapons = true;
let pdSquad = [];
let pdWorkshopOpen = true;
let pdEditingIdx = -1;

function pdShuffle(arr) {
  const copy = arr.slice();
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    const tmp = copy[i]; copy[i] = copy[j]; copy[j] = tmp;
  }
  return copy;
}

function pdCanUseShield(wpn) {
  if (!wpn) return false;
  const txt = wpn.name + ' ' + wpn.sub;
  return !pdTwoHandKeywords.some(kw => txt.includes(kw));
}

function pdFilterByPreset(preset) {
  let faces = pdPools.faceMale;
  let torsos = pdPools.torso;
  let hats = pdPools.hat;
  let wpns = pdPools.weapon;
  let bgList = [...pdBackgrounds.civ, ...pdBackgrounds.sect, ...pdBackgrounds.army, ...pdBackgrounds.outlaw];

  if (preset === 'mixed') {
    faces = pdShuffle([...pdShuffle(pdPools.faceMale).slice(0, 10), ...pdShuffle(pdPools.faceFem).slice(0, 2)]);
    hats = pdPools.hat.filter(a => !pdTrueFullVisorHats.has(a.id));
  } else if (preset === 'civ') {
    torsos = pdPools.torso.filter(a => a.id.startsWith('wx_body_civ_') || a.id === 'wx_body_arm_01');
    hats = pdPools.hat.filter(a => /^wx_hat_0[1-7]$/.test(a.id));
    wpns = pdPools.weapon.filter(a => /T0|T1|T2|基础/.test(a.sub));
    bgList = pdBackgrounds.civ;
  } else if (preset === 'sect') {
    faces = pdShuffle([...pdShuffle(pdPools.faceMale).slice(0, 9), ...pdShuffle(pdPools.faceFem).slice(0, 3)]);
    torsos = pdPools.torso.filter(a => a.id.startsWith('wx_body_sect_'));
    hats = pdPools.hat.filter(a => /^wx_hat_(0[89]|1[0-6])$/.test(a.id));
    wpns = pdPools.weapon.filter(a => /T2|T3|T4|传世|进阶|重型/.test(a.sub));
    bgList = pdBackgrounds.sect;
  } else if (preset === 'heroine') {
    faces = pdPools.faceFem;
    torsos = pdPools.torso.filter(a => /^wx_body_(sect_0[234678]|sect_1[01356]|civ_06|civ_1[12]|arm_0[159]|arm_10)$/.test(a.id));
    hats = pdPools.hat.filter(a => /^wx_hat_(07|1[12456])$/.test(a.id));
    wpns = pdPools.weapon.filter(a => /剑|刀|刺|匕|鞭|弓|弩|分水|鹰爪|竹杖/.test(a.name + a.sub));
    bgList = pdBackgrounds.heroine;
  } else if (preset === 'army') {
    torsos = pdPools.torso.filter(a => a.id.startsWith('wx_body_hvy_') || a.id.startsWith('wx_armor_') || /^wx_body_arm_0[4678]$/.test(a.id));
    hats = pdPools.hat.filter(a => a.id.startsWith('wx_helm_') || /^wx_hat_(2[0356789]|3[012])$/.test(a.id));
    wpns = pdPools.weapon.filter(a => /T2|T3|T4|传世/.test(a.sub));
    bgList = pdBackgrounds.army;
  } else if (preset === 'outlaw') {
    torsos = pdPools.torso.filter(a => /^wx_body_(sect_0[569]|sect_1[012]|arm_0[235]|hvy_09|civ_0[389])$/.test(a.id));
    hats = pdPools.hat.filter(a => /^wx_hat_(0[78]|1[345789]|2[124])$/.test(a.id));
    wpns = pdPools.weapon;
    bgList = pdBackgrounds.outlaw;
  }
  return {
    faces: faces.length >= 12 ? faces : pdPools.face,
    torsos: torsos.length >= 12 ? torsos : pdPools.torso,
    hats: hats.length >= 8 ? hats : pdPools.hat,
    wpns: wpns.length >= 12 ? wpns : pdPools.weapon,
    bgList
  };
}

function generatePdSquad(preset) {
  pdPreset = preset || pdPreset || 'mixed';
  const cfg = pdFilterByPreset(pdPreset);
  const faces = pdShuffle(cfg.faces).slice(0, 12);
  const torsos = pdShuffle(cfg.torsos).slice(0, 12);
  const hairs = pdShuffle(pdPools.hair);
  const beards = pdShuffle(pdPools.beard);
  const scars = pdShuffle(pdPools.scar);
  const hats = pdShuffle(cfg.hats);
  const wpns = pdShuffle(cfg.wpns).slice(0, 12);
  const shields = pdShuffle(pdPools.shield);
  const surs = pdShuffle(pdSurnames);
  const givM = pdShuffle(pdGivenM);
  const givF = pdShuffle(pdGivenF);
  const bgs = pdShuffle(cfg.bgList);

  let shdIdx = 0;
  pdSquad = faces.map((face, i) => {
    const isFem = face.pdGender === 'f';
    const torso = torsos[i];
    const wpn = wpns[i];
    const wearHat = pdShowHelmets || (pdPreset === 'army' && i % 3 !== 2);
    const hat = wearHat ? hats[i % hats.length] : null;

    let hair = (!hat || !pdHideHairHats.has(hat.id)) ? hairs[i % hairs.length] : null;
    if (isFem && hair && hair.id === 'wx_hair_13') {
      hair = hairs[(i + 12) % hairs.length];
    }
    if (hat && hat.id === 'wx_hat_14' && (!hair || pdHairHasBuiltInCap.has(hair.id) || hair.id === 'wx_hair_13')) {
      hair = hairs.find(h => !pdHairHasBuiltInCap.has(h.id) && h.id !== 'wx_hair_13') || hairs[0];
    }
    const toneIdx = (face.id === 'wx_head_04' || face.id === 'wx_head_08' || face.id === 'wx_head_09' || face.id === 'wx_head_40') ? 2 :
                    (i % 7 === 5 ? 1 : (i % 11 === 9 ? 3 : 0));

    let beard = null;
    if (!isFem && (!hat || !pdFullMaskHats.has(hat.id)) && (i % 4 !== 1)) {
      beard = beards[i % beards.length];
    }

    let scar = null;
    if ((!hat || !pdFullMaskHats.has(hat.id)) && (i % 3 === 1)) {
      scar = scars[i % scars.length];
    }

    let shield = null;
    if (pdCanUseShield(wpn) && shdIdx < shields.length && (pdPreset === 'army' || i % 2 === 1)) {
      shield = shields[shdIdx++];
    }
    return {
      name: surs[i % surs.length] + (isFem ? givF[i % givF.length] : givM[i % givM.length]),
      bg: isFem && pdPreset !== 'heroine' ? pdBackgrounds.heroine[i % pdBackgrounds.heroine.length] : bgs[i % bgs.length],
      face, torso, hair, hairTone: toneIdx, beard, scar, hat, wpn, shield
    };
  });
}

function rerollSingleBrother(idx) {
  if (!pdSquad.length) generatePdSquad(pdPreset);
  const usedFaces = new Set(pdSquad.filter((_, i) => i !== idx).map(b => b.face.id));
  const usedTorsos = new Set(pdSquad.filter((_, i) => i !== idx).map(b => b.torso.id));
  const usedHairs = new Set(pdSquad.filter((b, i) => i !== idx && b.hair).map(b => b.hair.id));
  const usedBeards = new Set(pdSquad.filter((b, i) => i !== idx && b.beard).map(b => b.beard.id));
  const usedWpns = new Set(pdSquad.filter((_, i) => i !== idx).map(b => b.wpn.id));

  const cfg = pdFilterByPreset(pdPreset);
  const face = pdShuffle(cfg.faces.filter(a => !usedFaces.has(a.id)))[0] || pdShuffle(pdPools.face)[0];
  const isFem = face.pdGender === 'f';
  const torso = pdShuffle(cfg.torsos.filter(a => !usedTorsos.has(a.id)))[0] || pdShuffle(pdPools.torso)[0];
  const wpn = pdShuffle(cfg.wpns.filter(a => !usedWpns.has(a.id)))[0] || pdShuffle(pdPools.weapon)[0];
  const hat = pdShowHelmets ? pdShuffle(cfg.hats)[0] : null;
  const availHairs = pdShuffle(pdPools.hair.filter(a => !usedHairs.has(a.id) && (!isFem || a.id !== 'wx_hair_13')));
  const hair = (!hat || !pdTrueFullVisorHats.has(hat.id)) ? (availHairs[0] || pdShuffle(pdPools.hair)[0]) : null;
  const availBeards = pdShuffle(pdPools.beard.filter(a => !usedBeards.has(a.id)));
  const beard = (!isFem && (!hat || !pdFullMaskHats.has(hat.id)) && Math.random() < 0.75) ? (availBeards[0] || pdShuffle(pdPools.beard)[0]) : null;
  const scar = (!hat || !pdFullMaskHats.has(hat.id)) && Math.random() < 0.35 ? pdShuffle(pdPools.scar)[0] : null;
  const shield = pdCanUseShield(wpn) && Math.random() < 0.45 ? pdShuffle(pdPools.shield)[0] : null;
  const sur = pdShuffle(pdSurnames)[0];
  const giv = isFem ? pdShuffle(pdGivenF)[0] : pdShuffle(pdGivenM)[0];
  const bg = isFem ? pdShuffle(pdBackgrounds.heroine)[0] : pdShuffle(cfg.bgList)[0];

  pdSquad[idx] = {name: sur + giv, bg, face, torso, hair, hairTone: Math.random() < 0.72 ? 0 : Math.floor(Math.random() * 4), beard, scar, hat, wpn, shield};
}

function renderBustStackHtml(b, clsPrefix, forceWeapons) {
  const toneCls = pdHairTones[b.hairTone || 0]?.cls || '';
  const showW = forceWeapons !== undefined ? forceWeapons : pdShowWeapons;
  let hairImgHtml = '';
  if (b.hair && (!b.hat || !pdHideHairHats.has(b.hat.id))) {
    const useFullHair = !b.hat || (pdOpenCrownHats.has(b.hat.id) && !pdHairHasBuiltInCap.has(b.hair.id));
    const hSrc = useFullHair ? b.hair.bustPath : (b.hair.bustTuckedPath || b.hair.bustPath);
    hairImgHtml = '<img class="pd-bust-img pd-layer-hair' + toneCls + '" src="' + escapeAttr(hSrc) + '" alt="">';
  }
  return '<div class="' + clsPrefix + '">' +
    '<img class="pd-bust-img" src="art/busts/pedestal_back.png" alt="">' +
    '<img class="pd-bust-img pd-layer-torso" src="' + escapeAttr(b.torso.bustPath) + '" alt="">' +
    '<img class="pd-bust-img" src="art/busts/pedestal_front.png" alt="">' +
    (b.hat && b.hat.bustBackPath ? '<img class="pd-bust-img pd-layer-hat-back" src="' + escapeAttr(b.hat.bustBackPath) + '" alt="">' : '') +
    '<img class="pd-bust-img pd-layer-face" src="' + escapeAttr(b.face.bustPath) + '" alt="">' +
    (b.scar ? '<img class="pd-bust-img pd-layer-scar" src="' + escapeAttr(b.scar.bustPath) + '" alt="">' : '') +
    (b.beard && (!b.hat || !pdFullMaskHats.has(b.hat.id)) ? '<img class="pd-bust-img pd-layer-beard" src="' + escapeAttr(b.beard.bustPath) + '" alt="">' : '') +
    hairImgHtml +
    (b.hat ? '<img class="pd-bust-img pd-layer-hat" src="' + escapeAttr(b.hat.bustFrontPath || b.hat.bustPath) + '" alt="">' : '') +
    (showW && b.shield && b.shield.bustPath ? '<img class="pd-bust-img pd-layer-shield" src="' + escapeAttr(b.shield.bustPath) + '" alt="">' : '') +
    (showW && b.wpn && b.wpn.bustPath ? '<img class="pd-bust-img pd-layer-weapon" src="' + escapeAttr(b.wpn.bustPath) + '" alt="">' : '') +
  '</div>';
}

function stepPoolItem(pool, cur, dir, allowNull) {
  const list = allowNull ? [null, ...pool] : pool;
  const curIdx = cur ? list.findIndex(x => x && x.id === cur.id) : 0;
  const nextIdx = (curIdx + dir + list.length) % list.length;
  return list[nextIdx];
}

function openBrotherEditor(idx) {
  if (!pdSquad.length) generatePdSquad(pdPreset);
  pdEditingIdx = idx;
  const b = pdSquad[idx];
  if (!b) return;

  const stepRow = (key, lbl, valText) =>
    '<div class="pd-step-row"><span class="lbl">' + html(lbl) + '</span>' +
    '<button type="button" class="pd-step-btn" data-pd-step="' + key + ':-1" aria-label="上一款' + escapeAttr(lbl) + '">◀</button>' +
    '<strong>' + html(valText) + '</strong>' +
    '<button type="button" class="pd-step-btn" data-pd-step="' + key + ':1" aria-label="下一款' + escapeAttr(lbl) + '">▶</button></div>';

  const bodyHtml = '<div class="pd-editor-wrap">' +
    renderBustStackHtml(b, 'pd-editor-stage', true) +
    '<div class="pd-editor-rows">' +
      stepRow('face', '面孔 (48)', b.face.name) +
      stepRow('hair', '发式 (25)', b.hair ? (b.hat && !pdOpenCrownHats.has(b.hat.id) ? b.hair.name + ' (布尔收鬓)' : b.hair.name) : '剃度光头（无发）') +
      stepRow('tone', '发色 (4)', pdHairTones[b.hairTone || 0].label) +
      stepRow('beard', '胡须 (25)', b.beard ? b.beard.name : '净面无须') +
      stepRow('scar', '战痕 (13)', b.scar ? b.scar.name : '面容完好（无疤）') +
      stepRow('hat', '冠胄 (' + (pdPools.hat.length + 1) + ')', b.hat ? b.hat.name : '免冠露发') +
      stepRow('torso', '衣甲 (' + pdPools.torso.length + ')', b.torso.name) +
      stepRow('wpn', '主兵 (' + pdPools.weapon.length + ')', b.wpn.name) +
      stepRow('shd', '副盾 (' + (pdPools.shield.length + 1) + ')', b.shield ? b.shield.name : (pdCanUseShield(b.wpn) ? '空副手（孤锋诀）' : '双手占用副手')) +
    '</div></div>';

  const rows = [
    ['侠客姓名', html(b.name + ' · ' + b.bg)],
    ['主副兵装', html(b.wpn.name + (b.shield ? ' + ' + b.shield.name : '（空副手/双手）'))],
    ['底层规格', '<code>104×142</code> 人物胸像 <code>wx_busts_0.brush</code> + 手持兵盾层 <code>wx_weapons_0.brush</code>']
  ];
  openDialog('千人千面 · 捏脸与纸娃娃披挂台', rows, '#v=art', bodyHtml);
  const srcLink = element('detail-source');
  if (srcLink) srcLink.hidden = true;
}

function handlePdStep(spec) {
  const b = pdSquad[pdEditingIdx];
  if (!b) return;
  const parts = spec.split(':');
  const key = parts[0];
  const dir = Number(parts[1]) || 1;
  if (key === 'face') b.face = stepPoolItem(pdPools.face, b.face, dir, false);
  else if (key === 'hair') b.hair = stepPoolItem(pdPools.hair, b.hair, dir, true);
  else if (key === 'tone') b.hairTone = ((b.hairTone || 0) + dir + pdHairTones.length) % pdHairTones.length;
  else if (key === 'beard') b.beard = stepPoolItem(pdPools.beard, b.beard, dir, true);
  else if (key === 'scar') b.scar = stepPoolItem(pdPools.scar, b.scar, dir, true);
  else if (key === 'hat') b.hat = stepPoolItem(pdPools.hat, b.hat, dir, true);
  else if (key === 'torso') b.torso = stepPoolItem(pdPools.torso, b.torso, dir, false);
  else if (key === 'wpn') {
    b.wpn = stepPoolItem(pdPools.weapon, b.wpn, dir, false);
    if (!pdCanUseShield(b.wpn)) b.shield = null;
  } else if (key === 'shd') {
    if (pdCanUseShield(b.wpn)) b.shield = stepPoolItem(pdPools.shield, b.shield, dir, true);
  }
  render();
  openBrotherEditor(pdEditingIdx);
}

function renderPaperdollWorkshop() {
  if (!pdPools.face.length || !pdPools.torso.length) return '';
  if (!pdSquad.length) generatePdSquad(pdPreset);

  const headOnlyCombos = pdPools.face.length * (pdPools.hair.length * pdHairTones.length + 1) *
    (pdPools.beard.length + 1) * (pdPools.scar.length + 1);

  const cardsHtml = pdSquad.map((b, idx) => {
    const chips = [
      '<button type="button" class="pd-chip" data-art-detail="' + escapeAttr(b.face.id) + '" title="面孔：' + escapeAttr(b.face.name) + '">面·' + html(b.face.name.slice(0, 5)) + '</button>',
      b.hair ? '<button type="button" class="pd-chip" data-art-detail="' + escapeAttr(b.hair.id) + '" title="发式：' + escapeAttr(b.hair.name) + '">发·' + html(b.hair.name.slice(0, 5)) + '</button>' : '',
      b.beard ? '<button type="button" class="pd-chip" data-art-detail="' + escapeAttr(b.beard.id) + '" title="胡须：' + escapeAttr(b.beard.name) + '">须·' + html(b.beard.name.slice(0, 5)) + '</button>' : '',
      b.scar ? '<button type="button" class="pd-chip" data-art-detail="' + escapeAttr(b.scar.id) + '" title="战痕：' + escapeAttr(b.scar.name) + '">痕·' + html(b.scar.name.slice(0, 4)) + '</button>' : '',
      b.hat ? '<button type="button" class="pd-chip" data-art-detail="' + escapeAttr(b.hat.id) + '" title="冠胄：' + escapeAttr(b.hat.name) + '">冠·' + html(b.hat.name.slice(0, 5)) + '</button>' : '',
      '<button type="button" class="pd-chip" data-art-detail="' + escapeAttr(b.torso.id) + '" title="衣甲：' + escapeAttr(b.torso.name) + '">衣·' + html(b.torso.name.slice(0, 5)) + '</button>',
      '<button type="button" class="pd-chip" data-art-detail="' + escapeAttr(b.wpn.id) + '" title="兵刃：' + escapeAttr(b.wpn.name) + '">兵·' + html(b.wpn.name.slice(0, 5)) + '</button>'
    ].filter(Boolean).join('');

    return '<div class="pd-card">' +
      '<div class="pd-card-top"><div class="pd-who"><strong>' + html(b.name) + '</strong><span>' + html(b.bg) + '</span></div>' +
      '<div class="pd-card-btns">' +
        '<button type="button" class="pd-reroll-one" data-pd-edit="' + idx + '" title="自由微调此侠客的面孔、发式、胡须、战痕、衣甲与手持兵盾">✎ 捏脸</button>' +
        '<button type="button" class="pd-reroll-one" data-pd-one="' + idx + '" title="单独重随此侠客（与其余11人零撞脸）">↻</button>' +
      '</div></div>' +
      '<div class="pd-canvas">' +
        renderBustStackHtml(b, 'pd-bust-frame') +
        '<div class="pd-equip-dock">' +
          '<button type="button" class="pd-mini-slot" data-art-detail="' + escapeAttr(b.wpn.id) + '" title="主手兵刃：' + escapeAttr(b.wpn.name) + '">' +
            '<img loading="lazy" src="' + escapeAttr(b.wpn.previewPath) + '" alt="">' +
          '</button>' +
          (b.shield ? '<button type="button" class="pd-mini-slot sq" data-art-detail="' + escapeAttr(b.shield.id) + '" title="副手盾具：' + escapeAttr(b.shield.name) + '"><img loading="lazy" src="' + escapeAttr(b.shield.smallPath || b.shield.previewPath) + '" alt=""></button>' : '') +
        '</div>' +
      '</div>' +
      '<div class="pd-parts">' + chips + '</div>' +
      '</div>';
  }).join('');

  return '<details class="pd-workshop" id="pd-workshop"' + (pdWorkshopOpen ? ' open' : '') + '>' +
    '<summary><span>🎲 千人千面 & 纸娃娃手持兵盾 · 104×142 实机规格胸像台</span>' +
    '<small>48面孔 × 24发式 × 24胡须 × 12战痕 × 62衣甲 × 126手持兵刃 × 12盾具 · 全部编译入 <code>wx_busts_0.brush</code> & <code>wx_weapons_0.brush</code></small></summary>' +
    '<div class="pd-controls">' +
      '<div class="pd-presets" role="group" aria-label="队伍衣冠流派预设">' +
        '<button type="button" data-pd-preset="mixed" aria-pressed="' + String(pdPreset === 'mixed') + '">🎲 混编十二侠</button>' +
        '<button type="button" data-pd-preset="civ" aria-pressed="' + String(pdPreset === 'civ') + '">🌾 市井草莽</button>' +
        '<button type="button" data-pd-preset="sect" aria-pressed="' + String(pdPreset === 'sect') + '">☯ 名门奇派</button>' +
        '<button type="button" data-pd-preset="heroine" aria-pressed="' + String(pdPreset === 'heroine') + '">🌸 江湖女侠</button>' +
        '<button type="button" data-pd-preset="army" aria-pressed="' + String(pdPreset === 'army') + '">🛡 藩镇重甲</button>' +
        '<button type="button" data-pd-preset="outlaw" aria-pressed="' + String(pdPreset === 'outlaw') + '">☠ 塞外绿林</button>' +
        '<button type="button" data-pd-helms="toggle" aria-pressed="' + String(pdShowHelmets) + '">' + (pdShowHelmets ? '🪖 已戴冠胄（点此免冠）' : '👁 免冠露发（点此戴盔）') + '</button>' +
        '<button type="button" data-pd-wpns="toggle" aria-pressed="' + String(pdShowWeapons) + '">' + (pdShowWeapons ? '⚔ 已持兵盾（点此收兵）' : '🤲 空手验衣（点此持兵）') + '</button>' +
      '</div>' +
      '<div class="pd-formula">仅头部素颜组合：<b>' + pdPools.face.length + '</b>面孔 × <b>' + pdPools.hair.length + '</b>发式(4色) × <b>' + pdPools.beard.length + '</b>胡须 × <b>' + pdPools.scar.length + '</b>战痕 = <b>' + headOnlyCombos.toLocaleString('zh-CN') + '</b> 种不重样头相</div>' +
    '</div>' +
    '<div class="pd-roster">' + cardsHtml + '</div>' +
    '</details>';
}

function artStatusLabel(st) {
  if (st === 'in_game') return '已实装入游戏';
  if (st === 'wiki_ready') return '百科已创制';
  return '待创制·已立项';
}

function updateArtHeaderCounts() {
  const readyEl = element('art-ready-count');
  const totalEl = element('art-total-count');
  if (readyEl) readyEl.textContent = zhNum(artAssets.filter(a => a.status !== 'planned').length);
  if (totalEl) totalEl.textContent = zhNum(artAssets.length);
}

function drawRailForView() {
  const nav = element('chapters');
  const sel = element('mobile-group');
  const railTitle = document.querySelector('.rail h2');
  if (state.v === 'art') {
    if (railTitle) railTitle.textContent = '美术卷目';
    const items = [{id: '', idx: '全', label: '全部美术资产 (' + artAssets.length + ')'}];
    artStages.forEach((st, idx) => {
      const cnt = artAssets.filter(a => a.stage === st.id).length;
      items.push({id: st.id, idx: String(idx + 1).padStart(2, '0'), label: st.name.replace(/^第.卷\\s*·\\s*/, '') + ' (' + cnt + ')'});
    });
    nav.innerHTML = items.map(it =>
      '<button data-art-stage="' + escapeAttr(it.id) + '" aria-current="' + String((state.as || '') === it.id) + '">' +
      '<span class="idx">' + html(it.idx) + '</span>' + html(it.label) + '</button>'
    ).join('');
    sel.innerHTML = items.map(it => '<option value="' + escapeAttr(it.id) + '">' + html(it.label) + '</option>').join('');
    sel.value = state.as || '';
  } else {
    if (railTitle) railTitle.textContent = '章节目录';
    const choices = [{id:0,new:'全部章节'},...book.groups];
    nav.innerHTML = choices.map(g=>'<button data-group="'+g.id+'"'+(g.id===9?' class="appendix"':'')+' aria-current="'+String(g.id===state.g)+'"><span class="idx">'+(g.id===0?'全':g.id===9?'附':String(g.id).padStart(2,'0'))+'</span>'+html(g.new)+'</button>').join('');
    sel.innerHTML = choices.map(g=>'<option value="'+g.id+'">'+html(g.new)+'</option>').join('');
    sel.value = String(state.g);
  }
}

function matchingArtAssets(query) {
  return artAssets.filter(a =>
    (!state.as || a.stage === state.as) &&
    (!state.ag || a.group === state.ag) &&
    (!state.ast || a.status === state.ast) &&
    (!query || artSearchMap.get(a.id).includes(query))
  );
}

function renderArtPreviewWell(a) {
  if (a.status === 'planned' || !a.previewPath) {
    const dimHint = a.slotKind === 'weapon140' ? '70×140 立绘 + 70×70' :
                    a.slotKind === 'armor140' ? '104×142 纸娃娃三态' : '战场 .brush 立绘';
    return '<button type="button" class="art-stage-well" data-art-detail="' + escapeAttr(a.id) + '">' +
      '<span class="art-placeholder-box"><span><strong>待创制图谱</strong><span>' + html(dimHint) + '</span></span></span>' +
      '<span class="art-spec-tag">占位: ' + html(a.vanillaFallback) + '</span></button>';
  }
  const useSw = artPreviewMode === 'sw' && a.swPath;
  const useHd = artPreviewMode === 'hd' && a.hdPath;
  const usePawn = !!a.pawnPath && (artPreviewMode === 'pawn' || artPreviewMode === 'slot');
  const imgSrc = useHd ? a.hdPath : (useSw ? a.swPath : (usePawn ? a.pawnPath : a.previewPath));
  const slotCls = useHd ? 'bb-slot bb-slot-hd' :
    (a.slotKind === 'weapon140' || a.slotKind === 'armor140' ? 'bb-slot bb-slot-140' :
     a.slotKind === 'event210' ? 'bb-slot bb-slot-event' :
     a.slotKind === 'screen16x9' ? 'bb-slot bb-slot-wide' :
     a.slotKind === 'camp' ? 'bb-slot bb-slot-camp' :
     a.slotKind === 'boss' ? (usePawn ? 'bb-slot bb-slot-pawn' : 'bb-slot bb-slot-boss') :
     a.slotKind === 'item70' ? 'bb-slot bb-slot-70' : 'bb-slot bb-slot-56');
  const wellCls = 'art-stage-well' + (artPreviewMode === 'checker' ? ' checker-bg' : '');
  const badgeSpec = useHd ? '高清原画' : (useSw ? '56×56 _sw 置灰' :
    (a.slotKind === 'weapon140' || a.slotKind === 'armor140' ? '70×140 装备大格' :
     a.slotKind === 'event210' ? '210×210 奇遇插画' :
     a.slotKind === 'screen16x9' ? '全屏/横卷画幅' :
     a.slotKind === 'camp' ? '营地/门楣图层' :
     a.slotKind === 'boss' ? (usePawn ? '208×284 实机战棋底座' : '104×142 胸像贴图') :
     a.slotKind === 'item70' ? '70×70 背包格' : '56×56 技能/圆章'));
  return '<button type="button" class="' + wellCls + '" data-art-detail="' + escapeAttr(a.id) + '" title="点击查看高清三联实机对比与挂载路径">' +
    '<span class="' + slotCls + '"><img loading="lazy" src="' + escapeAttr(imgSrc) + '" alt="' + escapeAttr(a.name) + '"></span>' +
    '<span class="art-spec-tag">' + html(badgeSpec) + '</span></button>';
}

// === 72 招零重复 · 多关节动力学 + 刀光气芒 + 顿帧震屏 60fps 实战演武引擎 v2.0 ===
const vfxFeatured16Ids = [
  'wx_fist_xianglong', 'wx_sword_tianwai', 'wx_sword_feixian', 'wx_sword_taiji',
  'wx_sword_duoming',  'wx_saber_kuangfeng','wx_saber_ranmu',   'wx_saber_xuehai',
  'wx_fist_jingang',   'wx_fist_yiyang',    'wx_fist_xuanming', 'wx_spear_thrust2',
  'wx_hammer_leiting', 'wx_dagger_execute', 'wx_tactics_shihou','wx_neigong_jinzhong'
];

const all72SkillDemos = artAssets.filter(a => a.animId && a.stage === '1_icons').map(a => {
  const animObj = artById.get(a.animId);
  const fam = (a.id.includes('sword') || a.id === 'wx_acupoint_strike') ? 'sword' :
              (a.id.includes('saber') || a.id === 'wx_poise_charge') ? 'saber' :
              a.id.includes('fist') ? 'fist' :
              (a.id.includes('spear') || a.id.includes('pole') || a.id.includes('staff')) ? 'pole' :
              (a.id.includes('hammer') || a.id.includes('axe') || a.id.includes('shield')) ? 'heavy' :
              (a.id.includes('bow') || a.id.includes('crossbow') || a.id.includes('throw') || a.id.includes('smoke') || a.id.includes('dagger') || a.id.includes('flail') || a.id.includes('whip')) ? 'odd' : 'inner';
  return {
    skill: a.id,
    anim: a.animId,
    vfx: a.vfxBrush || '',
    sig: a.sigFx || '',
    mode: a.animMode || 'crescent',
    color: a.choreoColor || '#ffd070',
    desc: a.choreoDesc || '',
    fam,
    tag: a.choreoLabel || (animObj ? animObj.name : '独立实战动作')
  };
});
const vfxShowcaseDemos = vfxFeatured16Ids.map(id => all72SkillDemos.find(d => d.skill === id)).filter(Boolean);

let curVfxCat = 'featured';
let curVfxSkillId = 'wx_fist_xianglong';
let curVfxDemoIdx = 0;
let curVfxSpeed = 1.0;
let curVfxLoop = true;
let curVfxLockFrame = -1;
let curVfxReplayTick = 1;
let wxAnimRafId = 0;
let wxDialogRafId = 0;
const wxImgCache = new Map();

function wxLoadImg(src) {
  if (!src) return null;
  if (wxImgCache.has(src)) return wxImgCache.get(src);
  if (typeof Image === 'undefined') return null;
  const im = new Image();
  im.src = src;
  wxImgCache.set(src, im);
  return im;
}

function wxCasterRigForSkill(skillId) {
  const s = (skillId || '').toLowerCase();
  if (s.includes('taiji') || s === 'wx_meditate' || s === 'wx_qinggong_zongyue') {
    return {body: 'wx_body_sect_02', head: 'wx_head_09', hair: 'wx_hair_14', beard: 'wx_beard_21', hat: 'wx_hat_09'};
  }
  if (s === 'wx_fist_jingang' || s === 'wx_fist_jab' || s === 'wx_fist_acupoint' || s === 'wx_neigong_jinzhong' || s === 'wx_tactics_shihou' || s === 'wx_saber_ranmu') {
    return {body: 'wx_body_sect_01', head: 'wx_head_30', hair: null, beard: null, hat: 'wx_hat_21'};
  }
  if (s === 'wx_acupoint_strike' || s === 'wx_sword_duoming' || s === 'wx_qinggong_lingbo' || s === 'wx_tactics_jinzhen') {
    return {body: 'wx_body_sect_07', head: 'wx_head_33', hair: 'wx_hair_12', beard: null, hat: 'wx_hat_12'};
  }
  if (s.includes('xianglong') || s.includes('dagou') || s === 'wx_staff_challenge') {
    return {body: 'wx_body_sect_05', head: 'wx_head_11', hair: 'wx_hair_08', beard: 'wx_beard_18', hat: 'wx_hat_13'};
  }
  if (s.includes('dagger') || s.includes('jiuyin') || s.includes('xuanming') || s.includes('xuehai') || s === 'wx_blood_burst' || s === 'wx_neigong_xixing') {
    return {body: 'wx_body_sect_10', head: 'wx_head_07', hair: 'wx_hair_02', beard: null, hat: 'wx_hat_08'};
  }
  if (s.includes('throw') || s.includes('smoke') || s.includes('crossbow') || s.includes('whip') || s.includes('flail')) {
    return {body: 'wx_body_sect_06', head: 'wx_head_13', hair: 'wx_hair_11', beard: null, hat: 'wx_hat_14'};
  }
  if (s.includes('hammer') || s.includes('axe') || s.includes('shield') || s === 'wx_saber_modao' || s === 'wx_pole_fangtian' || s === 'wx_rally_command') {
    return {body: 'wx_body_hvy_02', head: 'wx_head_15', hair: 'wx_hair_17', beard: 'wx_beard_01', hat: 'wx_hat_30'};
  }
  return {body: 'wx_body_sect_03', head: 'wx_head_01', hair: 'wx_hair_09', beard: null, hat: null};
}

function wxWeaponSpecForSkill(skillId) {
  const s = (skillId || '').toLowerCase();
  if (s === 'wx_sword_zhongjian') return {src: 'art/hd/wx_relic_juque.png', w: 58, h: 108, kind: 'blade'};
  if (s === 'wx_sword_taiji') return {src: 'art/hd/wx_wpn_sword_05.png', w: 48, h: 96, kind: 'blade'};
  if (s.includes('sword') || s === 'wx_acupoint_strike') return {src: 'art/hd/wx_relic_chengying.png', w: 48, h: 96, kind: 'blade'};
  if (s === 'wx_saber_modao') return {src: 'art/hd/wx_relic_modao.png', w: 62, h: 118, kind: 'pole'};
  if (s === 'wx_saber_fanzhen') return {src: 'art/hd/wx_relic_xiuchun.png', w: 48, h: 94, kind: 'blade'};
  if (s.includes('saber') || s === 'wx_poise_charge') return {src: 'art/hd/wx_relic_minghong.png', w: 52, h: 98, kind: 'blade'};
  if (s === 'wx_fist_jiuyin' || s === 'wx_fist_grapple' || s === 'wx_fist_disarm') return {src: 'art/hd/wx_relic_qiongqizhao.png', w: 40, h: 42, kind: 'fist'};
  if (s.includes('fist')) return {src: 'art/hd/wx_relic_jingangwan.png', w: 38, h: 38, kind: 'fist'};
  if (s === 'wx_pole_fangtian') return {src: 'art/hd/wx_relic_huaji.png', w: 62, h: 122, kind: 'pole'};
  if (s === 'wx_pole_goulian') return {src: 'art/hd/wx_relic_goulianqiang.png', w: 58, h: 116, kind: 'pole'};
  if (s === 'wx_staff_dagou') return {src: 'art/hd/wx_relic_lvzhuzhang.png', w: 54, h: 112, kind: 'pole'};
  if (s.includes('staff')) return {src: 'art/hd/wx_relic_huntiegun.png', w: 56, h: 114, kind: 'pole'};
  if (s.includes('spear') || s.includes('pole')) return {src: 'art/hd/wx_relic_bawangqiang.png', w: 60, h: 118, kind: 'pole'};
  if (s.includes('hammer')) return {src: 'art/hd/wx_relic_wengjinchui.png', w: 56, h: 98, kind: 'heavy'};
  if (s.includes('axe')) return {src: 'art/hd/wx_relic_xuanhuafu.png', w: 58, h: 106, kind: 'heavy'};
  if (s.includes('shield')) return {src: 'art/hd/wx_shd_12.png', w: 54, h: 66, kind: 'shield'};
  if (s.includes('dagger')) return {src: 'art/hd/wx_relic_yuchang.png', w: 38, h: 68, kind: 'dagger'};
  if (s.includes('whip') || s.includes('flail')) return {src: 'art/hd/wx_wpn_whip_03.png', w: 48, h: 78, kind: 'whip'};
  if (s.includes('crossbow')) return {src: 'art/hd/wx_relic_shenbinu.png', w: 56, h: 72, kind: 'bow'};
  if (s.includes('bow')) return {src: 'art/hd/wx_relic_zhentiangong.png', w: 52, h: 92, kind: 'bow'};
  if (s.includes('throw') || s.includes('smoke')) return {src: 'art/hd/wx_wpn_dagger_04.png', w: 34, h: 58, kind: 'throw'};
  if (s === 'wx_rally_command') return {src: 'art/fx_elements/wx_fx_banner_crest.png', w: 68, h: 86, kind: 'banner'};
  return {src: null, w: 0, h: 0, kind: 'inner'};
}

function wxOpponentForSkill(fam) {
  if (fam === 'sword') return 'art/hd/wx_enemy_dongchang_agent.png';
  if (fam === 'saber') return 'art/hd/wx_enemy_liaodong_boss.png';
  if (fam === 'fist')  return 'art/hd/wx_enemy_bronze_yaoren.png';
  if (fam === 'pole')  return 'art/hd/wx_enemy_mobei_centurion.png';
  if (fam === 'heavy') return 'art/hd/wx_enemy_tomb_general.png';
  if (fam === 'odd')   return 'art/hd/wx_enemy_wudu_gushaman.png';
  return 'art/hd/wx_enemy_xuesha_juggernaut.png';
}

function wxDrawHexPoly(ctx, cx, cy, rx, ry, stroke, fill) {
  ctx.beginPath();
  for (let i = 0; i < 6; i++) {
    const ang = (Math.PI / 3) * i + Math.PI / 6;
    const x = cx + Math.cos(ang) * rx;
    const y = cy + Math.sin(ang) * ry;
    if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
  }
  ctx.closePath();
  if (fill) { ctx.fillStyle = fill; ctx.fill(); }
  if (stroke) { ctx.strokeStyle = stroke; ctx.lineWidth = 1.6; ctx.stroke(); }
}

function wxDrawImgFit(ctx, im, cx, cy, w, h, rotRad, alpha, flipX) {
  if (!im || !im.complete || !im.naturalWidth) return;
  ctx.save();
  ctx.globalAlpha = alpha === undefined ? 1 : Math.max(0, Math.min(1, alpha));
  ctx.translate(cx, cy);
  if (rotRad) ctx.rotate(rotRad);
  if (flipX) ctx.scale(-1, 1);
  ctx.drawImage(im, -w / 2, -h / 2, w, h);
  ctx.restore();
}

// High-impact procedural tapered Wuxia sword/blade Qi crescent ribbon!
function wxDrawSlashArc(ctx, cx, cy, rOuter, rInner, a0, a1, colorHex, alpha) {
  if (alpha <= 0.01) return;
  ctx.save();
  ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
  ctx.beginPath();
  const steps = 22;
  for (let i = 0; i <= steps; i++) {
    const t = i / steps;
    const a = a0 + (a1 - a0) * t;
    const ro = rOuter * (0.90 + Math.sin(t * Math.PI) * 0.14);
    const x = cx + Math.cos(a) * ro;
    const y = cy + Math.sin(a) * ro;
    if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
  }
  for (let i = steps; i >= 0; i--) {
    const t = i / steps;
    const a = a0 + (a1 - a0) * t;
    const tap = Math.sin(t * Math.PI);
    const ri = rOuter - (rOuter - rInner) * tap;
    ctx.lineTo(cx + Math.cos(a) * ri, cy + Math.sin(a) * ri);
  }
  ctx.closePath();
  ctx.fillStyle = colorHex;
  ctx.shadowColor = colorHex;
  ctx.shadowBlur = 16;
  ctx.fill();
  // White-hot outer cutting edge
  ctx.beginPath();
  ctx.arc(cx, cy, rOuter * 0.98, Math.min(a0, a1), Math.max(a0, a1));
  ctx.strokeStyle = '#ffffff';
  ctx.lineWidth = 2.6;
  ctx.stroke();
  ctx.restore();
}

function wxDrawSpeedLines(ctx, W, H, colorHex, intensity) {
  if (intensity <= 0.02) return;
  ctx.save();
  ctx.globalAlpha = intensity * 0.36;
  ctx.strokeStyle = colorHex;
  for (let i = 0; i < 14; i++) {
    const y = 18 + ((i * 37) % (H - 36));
    const len = 55 + ((i * 29) % 110);
    const x0 = ((i * 83) % (W - 60));
    ctx.lineWidth = (i % 3 === 0) ? 2.2 : 1.1;
    ctx.beginPath();
    ctx.moveTo(x0, y);
    ctx.lineTo(x0 + len, y);
    ctx.stroke();
  }
  ctx.restore();
}

function wxStartMartialCanvas(canvasId, demoSpec, isDialog) {
  const cv = document.getElementById(canvasId);
  if (!cv || typeof cv.getContext !== 'function') return;
  const ctx = cv.getContext('2d');
  if (!ctx) return;

  if (isDialog && wxDialogRafId) cancelAnimationFrame(wxDialogRafId);
  if (!isDialog && wxAnimRafId) cancelAnimationFrame(wxAnimRafId);

  const animObj = artById.get(demoSpec.anim) || artById.get('wx_anim_05');
  const skObj = artById.get(demoSpec.skill);
  const vfxIm = demoSpec.vfx ? wxLoadImg('art/hd/' + demoSpec.vfx + '.png') : null;
  const frames = (animObj && animObj.animFrames ? animObj.animFrames : []).map(wxLoadImg);
  const rig = wxCasterRigForSkill(demoSpec.skill);
  const bodyIm = wxLoadImg('art/busts/body/' + rig.body + '.png');
  const headIm = wxLoadImg('art/busts/head/' + rig.head + '.png');
  const hairIm = rig.hair ? wxLoadImg('art/busts/hair/' + rig.hair + '.png') : null;
  const beardIm = rig.beard ? wxLoadImg('art/busts/beard/' + rig.beard + '.png') : null;
  const hatIm = rig.hat ? wxLoadImg('art/busts/hat_front/' + rig.hat + '.png') : null;
  const wSpec = wxWeaponSpecForSkill(demoSpec.skill);
  const wpnIm = wSpec.src ? wxLoadImg(wSpec.src) : null;
  const shdIm = demoSpec.skill.includes('shield') ? wxLoadImg('art/busts/shield/wx_shd_12.png') : null;
  const oppIm = wxLoadImg(wxOpponentForSkill(demoSpec.fam || 'fist'));

  // Preload bespoke FX sprites
  const fxImgs = {
    bagua: wxLoadImg('art/fx_elements/wx_fx_bagua.png'),
    bell: wxLoadImg('art/fx_elements/wx_fx_golden_bell.png'),
    dragon: wxLoadImg('art/fx_elements/wx_fx_dragon_head.png'),
    sword: wxLoadImg('art/fx_elements/wx_fx_sword_phantom.png'),
    ice: wxLoadImg('art/fx_elements/wx_fx_ice_spikes.png'),
    blood: wxLoadImg('art/fx_elements/wx_fx_blood_orb.png'),
    sonic: wxLoadImg('art/fx_elements/wx_fx_sonic_ring.png'),
    needle: wxLoadImg('art/fx_elements/wx_fx_gold_needle.png'),
    whip: wxLoadImg('art/fx_elements/wx_fx_whip_arc.png'),
    thunder: wxLoadImg('art/fx_elements/wx_fx_thunder_bolt.png'),
    earth: wxLoadImg('art/fx_elements/wx_fx_earth_fissure.png'),
    banner: wxLoadImg('art/fx_elements/wx_fx_banner_crest.png'),
    poison: wxLoadImg('art/fx_elements/wx_fx_poison_skull.png'),
    lotus: wxLoadImg('art/fx_elements/wx_fx_lotus_seal.png'),
    palm: wxLoadImg('art/fx_elements/wx_fx_buddha_palm.png'),
    claw: wxLoadImg('art/fx_elements/wx_fx_claw_slash.png')
  };

  const mode = demoSpec.mode || 'crescent';
  const col = demoSpec.color || '#ffd070';
  const cycleMs = 1780;
  let startTs = performance.now();

  // Articulated 5-part martial hero renderer (NO stone pedestal!)
  function drawArticulatedHero(cx, groundY, jumpZ, leanDeg, sx, sy, wpnDeg, armExt, alpha, flipX) {
    ctx.save();
    // 1. Dynamic ground shadow anchored on floor!
    const shScale = Math.max(0.35, 1 - jumpZ / 130);
    ctx.fillStyle = 'rgba(0,0,0,' + (0.46 * shScale * alpha).toFixed(2) + ')';
    ctx.beginPath();
    ctx.ellipse(cx, groundY + 42, 34 * shScale, 11 * shScale, 0, 0, Math.PI * 2);
    ctx.fill();

    ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    ctx.translate(cx, groundY - jumpZ);
    if (flipX) ctx.scale(-1, 1);

    // Clip out bottom pedestal region (`y > 44` in bust coords) cleanly
    ctx.save();
    ctx.rotate((leanDeg * Math.PI) / 180);
    ctx.scale(sx, sy);

    // Torso
    ctx.save();
    ctx.beginPath(); ctx.rect(-56, -78, 112, 122); ctx.clip();
    if (bodyIm && bodyIm.complete && bodyIm.naturalWidth) ctx.drawImage(bodyIm, -48, -68, 96, 132);
    ctx.restore();

    // Counter-tilted Head + Beard + Hair + Hat (keeps gaze locked on enemy!)
    ctx.save();
    ctx.translate(3, -18);
    ctx.rotate((-leanDeg * 0.42 * Math.PI) / 180);
    ctx.translate(-3, 18);
    [headIm, beardIm, hairIm, hatIm].forEach(im => {
      if (im && im.complete && im.naturalWidth) ctx.drawImage(im, -48, -68, 96, 132);
    });
    ctx.restore();

    if (shdIm && shdIm.complete && shdIm.naturalWidth) {
      ctx.drawImage(shdIm, -54 + armExt * 0.4, -64, 96, 132);
    }

    // Articulated Weapon Shoulder -> Wrist Pivot
    if (wpnIm && wpnIm.complete && wpnIm.naturalWidth && wSpec.kind !== 'throw') {
      ctx.save();
      ctx.translate(18 + armExt, 6);
      ctx.rotate((wpnDeg * Math.PI) / 180);
      const anchorY = (wSpec.kind === 'fist' || wSpec.kind === 'shield' || wSpec.kind === 'bow') ? -wSpec.h * 0.5 : -wSpec.h * 0.78;
      ctx.drawImage(wpnIm, -wSpec.w * 0.46, anchorY, wSpec.w, wSpec.h);
      ctx.restore();
    }
    ctx.restore();
    ctx.restore();
  }

  function step(now) {
    if (!document.getElementById(canvasId)) return;
    const W = cv.width, H = cv.height;
    let rawP = ((now - startTs) * (isDialog ? 1.0 : curVfxSpeed)) / cycleMs;
    if (!isDialog && curVfxLockFrame >= 0) {
      rawP = [0.14, 0.40, 0.58, 0.84][curVfxLockFrame];
    } else if (rawP >= 1.0) {
      if (isDialog || curVfxLoop) { startTs = now; rawP = rawP % 1.0; }
      else rawP = 0.999;
    }

    // Action-RPG Hit-Stop (`顿帧` around p = 0.50..0.55) for crisp martial impact!
    let p = rawP;
    const isSelfOrMove = ['lotus_breath','blood_flame','golden_bell','cloud_jump','mirage_step','war_banner','heal_needles','poise_draw','hex_fortress','smoke_screen'].includes(mode);
    if (!isSelfOrMove && curVfxLockFrame < 0) {
      if (rawP > 0.49 && rawP < 0.55) p = 0.49 + (rawP - 0.49) * 0.18;
      else if (rawP >= 0.55) p = 0.5008 + (rawP - 0.55) * (0.4992 / 0.45);
    }

    const groundY = 148;
    const homeX = 104, foeHomeX = 332;
    let hx = homeX, hz = 0, lean = 0, sx = 1, sy = 1, wpnDeg = -22, armExt = 0, heroFlip = false;
    let bx = foeHomeX, bz = 0, bLean = 0, bFlash = 0, shakeX = 0, shakeY = 0, camZoom = 1.0;
    let clones = [], slashArcs = [], popups = [];

    const easeOut = t => 1 - Math.pow(1 - Math.max(0, Math.min(1, t)), 3);
    const hitWindow = (p >= 0.48 && p <= 0.78);
    const hk = hitWindow ? (p - 0.48) / 0.30 : 0;

    // === Compute Unique Kinematics Across All 72 Modes ===
    if (mode === 'counter') {
      // Enemy lunges FIRST (`0.08..0.38`), Hero parries with sparks (`0.38`) & counter-slashes (`0.48..0.72`)!
      if (p < 0.38) {
        const k = easeOut(p / 0.38);
        bx = foeHomeX - k * 156; bLean = -14 * k;
        hx = homeX + k * 14; wpnDeg = -22 - k * 35;
      } else if (p < 0.68) {
        const k = (p - 0.38) / 0.30;
        bx = (foeHomeX - 156) + easeOut(k) * 168; bLean = 18 * Math.sin(k * Math.PI); bFlash = Math.max(0, 1 - k * 1.8);
        hx = homeX + 14 + Math.sin(k * Math.PI) * 34; lean = 16; wpnDeg = -57 + easeOut(k) * 155; armExt = 18;
        slashArcs.push({x: hx + 28, y: groundY - 8, rO: 82, rI: 52, a0: -1.3, a1: 1.2, a: 1 - k});
        shakeX = (Math.random() - 0.5) * 8 * (1 - k);
      } else {
        const k = (p - 0.68) / 0.32;
        hx = homeX + (1 - k) * 14; wpnDeg = 98 - k * 120;
      }
    } else if (mode === 'backstab') {
      // Fade into ink shadow -> Appear BEHIND enemy (`bx + 58`, facing left!) -> Reverse throat slash!
      if (p < 0.24) {
        lean = 14 * (p / 0.24); sy = 1 - 0.1 * (p / 0.24);
      } else if (p < 0.74) {
        const k = (p - 0.24) / 0.50;
        hx = foeHomeX + 56; heroFlip = true; lean = 18;
        wpnDeg = -75 + easeOut(Math.min(1, k * 2.2)) * 165; armExt = 20;
        clones.push({x: homeX, z: 0, a: Math.max(0, 0.45 - k)});
        if (k > 0.32) {
          bFlash = Math.max(0, 1 - (k - 0.32) * 2.2); bx = foeHomeX - Math.sin((k - 0.32) * Math.PI) * 18;
          slashArcs.push({x: foeHomeX, y: groundY - 12, rO: 78, rI: 54, a0: 2.1, a1: 4.3, a: Math.max(0, 1 - (k - 0.32) * 2)});
        }
      } else {
        const k = (p - 0.74) / 0.26;
        hx = (foeHomeX + 56) - easeOut(k) * (foeHomeX + 56 - homeX);
      }
    } else if (mode === 'clone3') {
      // Split into 3 simultaneous phantom sword-clones converging from front, sky, and behind!
      if (p < 0.24) {
        lean = -10 * (p / 0.24); wpnDeg = -55;
      } else if (p < 0.76) {
        const k = (p - 0.24) / 0.52;
        const e = easeOut(Math.min(1, k * 1.8));
        hx = homeX + e * 168; lean = 20; wpnDeg = -60 + e * 150; armExt = 18;
        clones.push(
          {x: homeX + e * 195, z: 68 * Math.sin(e * Math.PI * 0.8), a: 0.72, deg: 115, flip: false},
          {x: foeHomeX + 58 - e * 12, z: 8, a: 0.72, deg: 85, flip: true}
        );
        if (k > 0.35) {
          bFlash = Math.max(0, 1 - (k - 0.35) * 2.2); bx = foeHomeX + (Math.random() - 0.5) * 14;
          shakeX = (Math.random() - 0.5) * 9; camZoom = 1.09;
        }
      } else {
        hx = homeX + (1 - (p - 0.76) / 0.24) * 168;
      }
    } else if (mode === 'combo3' || mode === 'omnislash6' || mode === 'rapid_jab' || mode === 'prism5_hit') {
      // Multi-hit rapid blitz with distinct per-hit slashes & combo popups!
      const hits = (mode === 'omnislash6') ? 6 : (mode === 'prism5_hit' ? 5 : (mode === 'rapid_jab' ? 2 : 3));
      if (p < 0.18) {
        lean = -12 * (p / 0.18); hx = homeX - 8 * (p / 0.18); wpnDeg = -65;
      } else if (p < 0.78) {
        const k = (p - 0.18) / 0.60;
        const sub = (k * hits) % 1;
        const stepIdx = Math.floor(k * hits);
        hx = homeX + 148 + (stepIdx % 2 === 0 ? 12 : -6);
        lean = 18 + (stepIdx % 2 === 0 ? 6 : -4);
        armExt = 14 + Math.sin(sub * Math.PI) * 18;
        wpnDeg = (stepIdx % 2 === 0) ? (-75 + sub * 165) : (95 - sub * 165);
        bx = foeHomeX + Math.sin(sub * Math.PI) * 14;
        bLean = 14 * Math.sin(sub * Math.PI);
        bFlash = Math.sin(sub * Math.PI) * 0.9;
        const arcCols = mode === 'prism5_hit' ? ['#ff4545','#ffd24c','#52f296','#4dc8ff','#d45cff'] : [col];
        const cPick = arcCols[stepIdx % arcCols.length];
        if (wSpec.kind !== 'fist') {
          slashArcs.push({x: bx - 18, y: groundY - 12, rO: 84, rI: 56, a0: -1.4 + stepIdx * 0.7, a1: 1.3 + stepIdx * 0.7, col: cPick, a: Math.sin(sub * Math.PI)});
        }
        popups.push({x: bx + (stepIdx - 1) * 16, y: 54 - sub * 18, txt: '-' + (31 + stepIdx * 7), a: Math.sin(sub * Math.PI), col: cPick});
        shakeX = (Math.random() - 0.5) * 7; shakeY = (Math.random() - 0.5) * 5; camZoom = 1.08;
      } else {
        const k = (p - 0.78) / 0.22;
        hx = homeX + (1 - easeOut(k)) * 148;
      }
    } else if (['leap_cleave','gravity_cut','earth_wave','sky_thunder','buddha_palm','giant_axe','shield_split'].includes(mode)) {
      // High-altitude heroic leap & earth-shattering slam!
      if (p < 0.22) {
        const k = p / 0.22;
        sy = 1 - 0.14 * k; sx = 1 + 0.10 * k; lean = -14 * k; wpnDeg = -95 * k;
      } else if (p < 0.50) {
        const k = (p - 0.22) / 0.28;
        hx = homeX + easeOut(k) * 162;
        hz = Math.sin(k * Math.PI) * 74;
        lean = -14 + k * 42;
        wpnDeg = -105 + Math.pow(k, 2.2) * 210;
        clones.push({x: hx - 22, z: Math.max(0, hz - 12), a: 0.28, deg: wpnDeg - 25});
      } else if (p < 0.80) {
        const k = (p - 0.50) / 0.30;
        hx = homeX + 162 - k * 14; lean = 24 - k * 12; wpnDeg = 105 - k * 18; armExt = 20;
        bx = foeHomeX + Math.sin(k * Math.PI) * 24; bz = Math.sin(Math.min(1, k * 2) * Math.PI) * 18;
        bLean = 24 * (1 - k); bFlash = Math.max(0, 1 - k * 1.9);
        slashArcs.push({x: hx + 36, y: groundY - 18, rO: 106, rI: 64, a0: -1.65, a1: 0.85, a: Math.max(0, 1 - k * 1.8)});
        if (k < 0.55) { shakeX = (Math.random() - 0.5) * 14; shakeY = (Math.random() - 0.5) * 14; camZoom = 1.14; }
      } else {
        const k = (p - 0.80) / 0.20;
        hx = homeX + (1 - easeOut(k)) * 148; wpnDeg = 87 - k * 109;
      }
    } else if (['vacuum_pull','hook_pull'].includes(mode)) {
      // Reach / Hook across the arena and YANK the enemy right into the hero!
      if (p < 0.36) {
        const k = easeOut(p / 0.36);
        hx = homeX + k * 26; lean = 16 * k; armExt = k * 26; wpnDeg = 68;
      } else if (p < 0.76) {
        const k = easeOut((p - 0.36) / 0.40);
        hx = homeX + 26; lean = -10; armExt = 26 * (1 - k); wpnDeg = 68 - k * 75;
        bx = foeHomeX - k * 142; bLean = -22 * (1 - k * 0.5); bFlash = Math.sin(k * Math.PI);
        shakeX = (Math.random() - 0.5) * 7;
      } else {
        const k = (p - 0.76) / 0.24;
        bx = (foeHomeX - 142) + easeOut(k) * 142; hx = homeX + (1 - k) * 26;
      }
    } else if (['dragon_coil','sun_laser','flying_虹','star_rain','sonic_arrow','triple_arc','heavy_bolt','needle24','fan_knives7','venom_spikes','bomb_arc','black_hole','over_shield','neck_coil','viper_whip'].includes(mode)) {
      // Ranged / Sword-Qi / Dragon / Whip / Black-Hole Choreographies
      if (p < 0.26) {
        const k = p / 0.26;
        hx = homeX - k * 8; lean = -10 * k; wpnDeg = -48 * k;
        if (mode === 'star_rain') { hz = easeOut(k) * 62; }
      } else if (p < 0.56) {
        const k = (p - 0.26) / 0.30;
        hx = homeX + easeOut(k) * 22; lean = 16; armExt = 22; wpnDeg = 58;
        if (mode === 'star_rain') hz = 62 * (1 - k * 0.4);
      } else if (p < 0.84) {
        const k = (p - 0.56) / 0.28;
        hx = homeX + 22 * (1 - k); lean = 16 * (1 - k); armExt = 22 * (1 - k); wpnDeg = 58 - k * 80;
        bx = foeHomeX + (mode === 'black_hole' ? -Math.sin(k * Math.PI) * 32 : Math.sin(k * Math.PI) * 22);
        bLean = mode === 'black_hole' ? -18 : 20 * (1 - k);
        bFlash = Math.max(0, 1 - k * 1.8);
        if (k < 0.5) { shakeX = (Math.random() - 0.5) * 10; shakeY = (Math.random() - 0.5) * 8; camZoom = 1.10; }
      }
    } else if (['tidal_sweep','cyclone_pole','berserk_spin'].includes(mode)) {
      // 360-degree high-speed spinning cyclone rush!
      if (p < 0.18) {
        lean = -14 * (p / 0.18);
      } else if (p < 0.76) {
        const k = (p - 0.18) / 0.58;
        hx = homeX + Math.sin(k * Math.PI * 0.85) * 176;
        heroFlip = (Math.floor(k * 6) % 2 === 1);
        lean = 18; wpnDeg = k * 1080; armExt = 20;
        slashArcs.push({x: hx, y: groundY - 4, rO: 92, rI: 52, a0: k * 16, a1: k * 16 + 4.4, a: 0.88});
        if (k > 0.32) {
          bx = foeHomeX + Math.sin(k * Math.PI * 4) * 16; bFlash = 0.75; bLean = 18;
          shakeX = (Math.random() - 0.5) * 8;
        }
      } else {
        hx = homeX + (1 - (p - 0.76) / 0.24) * 90;
      }
    } else if (mode === 'spear_wall') {
      // Planted pike bastion: Hero braces spear low while enemy charges into the spearpoint & gets repelled!
      if (p < 0.36) {
        const k = easeOut(p / 0.36);
        hx = homeX + 10 * k; lean = 10 * k; wpnDeg = 56; armExt = 22 * k;
        bx = foeHomeX - k * 146; bLean = -16 * k;
      } else if (p < 0.72) {
        const k = (p - 0.36) / 0.36;
        hx = homeX + 10 + Math.sin(k * Math.PI) * 18; lean = 18; wpnDeg = 64; armExt = 28;
        bx = (foeHomeX - 146) + easeOut(k) * 162; bLean = 22 * Math.sin(k * Math.PI); bFlash = Math.max(0, 1 - k * 1.8);
        shakeX = (Math.random() - 0.5) * 9 * (1 - k);
        popups.push({x: bx, y: 48 - k * 14, txt: '拒马截击!', a: 1 - k, col: '#9ad8ff'});
      } else {
        const k = (p - 0.72) / 0.28;
        hx = homeX + 10 * (1 - k); wpnDeg = 64 - k * 86; armExt = 22 * (1 - k);
      }
    } else if (['twin_cross','halberd_x','twin_fang'].includes(mode)) {
      // Twin diagonal X-shear slashes (Ice-Fire Saber-Sword / Fangtian Twin-Moon Halberd / Twin-Fang Daggers)
      if (p < 0.20) {
        lean = -14 * (p / 0.20); wpnDeg = -82 * (p / 0.20);
      } else if (p < 0.78) {
        const k = (p - 0.20) / 0.58;
        const firstHalf = k < 0.5;
        const sub = (k * 2) % 1;
        hx = homeX + easeOut(Math.min(1, k * 2.2)) * 164;
        hz = mode === 'halberd_x' ? Math.sin(k * Math.PI) * 34 : 0;
        lean = firstHalf ? 20 : 12; armExt = 22;
        wpnDeg = firstHalf ? (-82 + sub * 175) : (98 - sub * 175);
        bx = foeHomeX + Math.sin(sub * Math.PI) * 18; bFlash = Math.sin(sub * Math.PI);
        const c2 = mode === 'twin_cross' ? (firstHalf ? '#ff6a33' : '#5ce6ff') : col;
        slashArcs.push({x: bx - 14, y: groundY - 14, rO: 92, rI: 56, a0: firstHalf ? -1.55 : 1.55, a1: firstHalf ? 1.15 : -1.15, col: c2, a: Math.sin(sub * Math.PI)});
        if (k > 0.45) { shakeX = (Math.random() - 0.5) * 11; shakeY = (Math.random() - 0.5) * 9; camZoom = 1.11; }
      } else {
        hx = homeX + (1 - easeOut((p - 0.78) / 0.22)) * 164;
      }
    } else if (['drill_lunge','spiral_stab'].includes(mode)) {
      // High-velocity corkscrew sonic spear/sword pierce!
      if (p < 0.24) {
        const k = p / 0.24;
        hx = homeX - k * 18; sy = 1 - 0.12 * k; lean = 16 * k; wpnDeg = 68;
      } else if (p < 0.68) {
        const k = easeOut((p - 0.24) / 0.44);
        hx = (homeX - 18) + k * 206; lean = 26; armExt = 28; wpnDeg = 68 + Math.sin(k * Math.PI * 6) * 8;
        clones.push({x: hx - 38, z: 0, a: 0.42, deg: 68}, {x: hx - 76, z: 0, a: 0.22, deg: 68});
        if (k > 0.42) {
          bx = foeHomeX + Math.sin((k - 0.42) * Math.PI) * 26; bFlash = 1 - (k - 0.42) * 1.6;
          shakeX = (Math.random() - 0.5) * 10; camZoom = 1.10;
        }
      } else {
        hx = homeX + (1 - easeOut((p - 0.68) / 0.32)) * 188;
      }
    } else if (['inch_pulse','shield_ram'].includes(mode)) {
      // Close-quarters explosive shoulder/shield/one-inch punch shockwave!
      if (p < 0.24) {
        const k = p / 0.24;
        hx = homeX + easeOut(k) * 144; lean = -8 * k;
      } else if (p < 0.44) {
        const k = (p - 0.24) / 0.20;
        hx = homeX + 144 - k * 10; sy = 1 - 0.10 * k; sx = 1 + 0.08 * k; wpnDeg = -35;
      } else if (p < 0.82) {
        const k = easeOut((p - 0.44) / 0.38);
        hx = homeX + 134 + (1 - k) * 28; lean = 24 * (1 - k * 0.6); armExt = 26 * (1 - k * 0.5); wpnDeg = 72;
        bx = foeHomeX + k * 42 * Math.sin(k * Math.PI); bLean = 26 * (1 - k); bFlash = Math.max(0, 1 - k * 2.0);
        if (k < 0.45) { shakeX = (Math.random() - 0.5) * 13; camZoom = 1.12; }
      } else {
        hx = homeX + (1 - easeOut((p - 0.82) / 0.18)) * 134;
      }
    } else if (['taiji_field','taiji_orb'].includes(mode)) {
      // Circular Yin-Yang Taiji draw-in & elastic four-liang-deflects-thousand-jin pushback!
      if (p < 0.42) {
        const k = p / 0.42;
        hx = homeX + Math.sin(k * Math.PI) * 32; wpnDeg = -20 + k * 180;
        bx = foeHomeX - easeOut(k) * 138; bLean = -14 * k;
      } else if (p < 0.82) {
        const k = easeOut((p - 0.42) / 0.40);
        hx = homeX + 28 * (1 - k); lean = 16 * (1 - k); armExt = 24 * (1 - k); wpnDeg = 160 + k * 140;
        bx = (foeHomeX - 138) + k * 168; bz = Math.sin(k * Math.PI) * 26; bLean = 24 * (1 - k); bFlash = Math.max(0, 1 - k * 2);
      }
    } else if (isSelfOrMove) {
      // Qinggong Cloud-Vault / Lingbo Mirage / Golden Bell / Banner / Acupuncture / Poise Draw
      if (mode === 'cloud_jump') {
        if (p > 0.16 && p < 0.82) {
          const k = (p - 0.16) / 0.66;
          hx = homeX + Math.sin(k * Math.PI) * 195;
          hz = Math.sin(k * Math.PI) * 86 + Math.abs(Math.sin(k * Math.PI * 2)) * 22;
          lean = 14 * Math.cos(k * Math.PI);
          clones.push({x: hx - 26, z: Math.max(0, hz - 16), a: 0.35, deg: -20});
        }
      } else if (mode === 'mirage_step') {
        const k = Math.sin(p * Math.PI);
        hx = homeX + Math.sin(p * Math.PI * 2) * 58;
        clones.push(
          {x: homeX - 24, z: 4, a: 0.44 * k, deg: -15},
          {x: homeX + 42, z: 8, a: 0.38 * k, deg: 12},
          {x: homeX + 94, z: 2, a: 0.30 * k, deg: -28}
        );
        if (p > 0.30 && p < 0.68) { bx = foeHomeX - Math.sin(((p - 0.30) / 0.38) * Math.PI) * 165; bLean = -18; }
      } else if (mode === 'poise_draw') {
        const k = Math.sin(p * Math.PI);
        sy = 1 - 0.10 * k; sx = 1 + 0.06 * k; lean = 8 * k; wpnDeg = -52 - 18 * k;
      } else {
        hz = Math.sin(p * Math.PI) * 10;
        wpnDeg = -22 - Math.sin(p * Math.PI) * 32;
      }
    } else {
      // Bespoke Heavy Crescent / Upward Modao & Bawang Launch / Ghost Claw / Frost Tomb / Fire Pillar / Blood Siphon / Disarm / Lion Roar
      if (p < 0.22) {
        const k = p / 0.22;
        hx = homeX - k * 12; lean = -12 * k; sy = 1 - 0.08 * k; wpnDeg = -68 * k;
      } else if (p < 0.50) {
        const k = easeOut((p - 0.22) / 0.28);
        hx = (homeX - 12) + k * (mode === 'lion_roar' || mode === 'taunt_slam' ? 38 : 174);
        lean = 22 * k; armExt = 24 * k;
        wpnDeg = (mode === 'modao_upcut' || mode === 'dragon_up') ? (115 - k * 165) : (-68 + k * 158);
        clones.push({x: hx - 32, z: 0, a: 0.34, deg: wpnDeg - 18}, {x: hx - 62, z: 0, a: 0.16, deg: wpnDeg - 32});
      } else if (p < 0.80) {
        const k = (p - 0.50) / 0.30;
        hx = (mode === 'lion_roar' || mode === 'taunt_slam' ? homeX + 26 : homeX + 162) - k * 18;
        lean = 20 * (1 - k); armExt = 22 * (1 - k);
        wpnDeg = (mode === 'modao_upcut' || mode === 'dragon_up') ? (-50 + k * 28) : (90 - k * 45);
        bx = foeHomeX + Math.sin(k * Math.PI) * 24;
        if (mode === 'modao_upcut' || mode === 'dragon_up') bz = Math.sin(k * Math.PI) * 48;
        bLean = 22 * (1 - k); bFlash = Math.max(0, 1 - k * 1.9);
        if (wSpec.kind === 'blade' || wSpec.kind === 'pole' || wSpec.kind === 'heavy' || wSpec.kind === 'dagger') {
          const up = (mode === 'modao_upcut' || mode === 'dragon_up');
          slashArcs.push({x: bx - 16, y: groundY - 14, rO: 94, rI: 58, a0: up ? 1.3 : -1.45, a1: up ? -1.4 : 1.15, a: Math.max(0, 1 - k * 1.9)});
        }
        if (k < 0.5) { shakeX = (Math.random() - 0.5) * 10; shakeY = (Math.random() - 0.5) * 8; camZoom = 1.11; }
      } else {
        const k = (p - 0.80) / 0.20;
        hx = homeX + (1 - easeOut(k)) * (mode === 'lion_roar' || mode === 'taunt_slam' ? 8 : 144);
        wpnDeg = 45 - k * 67;
      }
    }

    // === Render Scene ===
    ctx.save();
    ctx.clearRect(0, 0, W, H);

    // 1. Atmospheric Dojo / Night-Domain Backdrop
    const isNight = (mode === 'night_exec' || mode === 'star_rain' || mode === 'black_hole');
    const bg = ctx.createRadialGradient(W * 0.52, H * 0.58, 16, W * 0.5, H * 0.5, W * 0.78);
    bg.addColorStop(0, isNight ? '#1b142e' : '#38291d');
    bg.addColorStop(1, isNight ? '#07050d' : '#100c08');
    ctx.fillStyle = bg;
    ctx.fillRect(0, 0, W, H);

    // Camera Zoom + Impact Shake
    ctx.translate(W * 0.5 + shakeX, H * 0.5 + shakeY);
    ctx.scale(camZoom, camZoom);
    ctx.translate(-W * 0.5, -H * 0.5);

    if (p > 0.26 && p < 0.66 && !isSelfOrMove) {
      wxDrawSpeedLines(ctx, W, H, col, Math.sin(((p - 0.26) / 0.40) * Math.PI));
    }

    // 2. Tactical 4-Hex Stone Battlefield Floor
    [104, 180, 256, 332].forEach((cx, hi) => {
      const stroke = hi === 0 ? 'rgba(136,192,120,0.46)' : (hi === 3 ? 'rgba(214,92,72,0.50)' : 'rgba(154,126,88,0.25)');
      const fill = hi === 0 ? 'rgba(48,74,42,0.22)' : (hi === 3 ? 'rgba(94,34,26,0.22)' : 'rgba(38,29,20,0.20)');
      wxDrawHexPoly(ctx, cx, groundY + 42, 46, 17, stroke, fill);
    });

    // 3. Ground Arrays BEFORE Characters (`taiji_field`, `taiji_orb`, `mirage_step`, `lotus_breath`, `earth_wave`, `gravity_cut`)
    if ((mode === 'taiji_field' || mode === 'taiji_orb' || mode === 'mirage_step') && fxImgs.bagua) {
      ctx.save();
      ctx.translate(mode === 'taiji_field' ? (hx + bx) * 0.5 : hx + 18, groundY + 38);
      ctx.scale(1.35, 0.48);
      wxDrawImgFit(ctx, fxImgs.bagua, 0, 0, 148, 148, p * Math.PI * 3, 0.85, false);
      ctx.restore();
    }
    if ((mode === 'earth_wave' || mode === 'gravity_cut' || mode === 'leap_cleave') && p >= 0.48 && fxImgs.earth) {
      const ek = Math.min(1, (p - 0.48) / 0.42);
      for (let gi = 0; gi < (mode === 'earth_wave' ? 3 : 1); gi++) {
        if (ek > gi * 0.16) {
          wxDrawImgFit(ctx, fxImgs.earth, bx - 48 + gi * 44, groundY + 28, 118, 86, 0, Math.max(0, 1 - ek * 0.85), false);
        }
      }
    }

    // 4. Draw Opponent (with hit flash, lean, launch height & disarm flying weapon!)
    if (oppIm && oppIm.complete && oppIm.naturalWidth) {
      const shS = Math.max(0.35, 1 - bz / 120);
      ctx.fillStyle = 'rgba(0,0,0,' + (0.45 * shS).toFixed(2) + ')';
      ctx.beginPath(); ctx.ellipse(bx, groundY + 42, 36 * shS, 11 * shS, 0, 0, Math.PI * 2); ctx.fill();
      ctx.save();
      ctx.translate(bx, groundY - bz);
      ctx.rotate((bLean * Math.PI) / 180);
      if (bFlash > 0.05) ctx.filter = 'brightness(' + (1 + bFlash * 1.6).toFixed(2) + ')';
      ctx.scale(-1, 1); // Face left toward our hero!
      ctx.drawImage(oppIm, -56, -68, 112, 128);
      ctx.restore();
    }

    // 5. Draw Hero Phantom Clones + Articulated Hero!
    clones.forEach(c => {
      drawArticulatedHero(c.x, groundY, c.z || 0, 16, 1, 1, c.deg !== undefined ? c.deg : wpnDeg, 12, c.a, !!c.flip);
    });
    drawArticulatedHero(hx, groundY, hz, lean, sx, sy, wpnDeg, armExt, 1.0, heroFlip);

    // 6. Draw Tapered Blade-Qi Smear Arcs
    slashArcs.forEach(sa => {
      wxDrawSlashArc(ctx, sa.x, sa.y, sa.rO, sa.rI, sa.a0, sa.a1, sa.col || col, sa.a);
    });

    // 7. Smooth Cross-Faded 4-Frame Hand-Painted Sequence (`frames[0..3]`) + Hand-Painted `wx_vfx_01..32` Qi-Aura!
    if (frames.length === 4) {
      const fPos = p * 3.5;
      const idx0 = Math.min(3, Math.floor(fPos));
      const idx1 = Math.min(3, idx0 + 1);
      const frac = fPos - idx0;
      const fxX = isSelfOrMove ? hx : (p < 0.34 ? hx + 32 : (p < 0.48 ? (hx + bx) * 0.5 : bx));
      const fxY = groundY - (isSelfOrMove ? hz + 6 : bz + 8);
      const sz = hitWindow ? 144 : 116;
      if (p > 0.08 && p < 0.92) {
        wxDrawImgFit(ctx, frames[idx0], fxX, fxY, sz, sz, 0, (1 - frac) * 0.82, false);
        if (idx1 !== idx0) wxDrawImgFit(ctx, frames[idx1], fxX, fxY, sz * 1.05, sz * 1.05, 0, frac * 0.82, false);
      }
    }
    if (vfxIm && p > 0.38 && p < 0.86) {
      const vk = Math.sin(((p - 0.38) / 0.48) * Math.PI);
      const vx = isSelfOrMove ? hx : bx;
      const vy = groundY - (isSelfOrMove ? hz + 8 : bz + 10);
      wxDrawImgFit(ctx, vfxIm, vx, vy, 128 + vk * 22, 128 + vk * 22, 0, vk * 0.78, false);
    }

    // 8. === BESPOKE SIGNATURE OVERLAYS FOR ALL 72 SKILLS ===
    if (mode === 'dragon_coil' && p > 0.22 && p < 0.88) {
      // Full sinuous 18-segment coiling Golden Qi Dragon + Roaring Dragon Head!
      const dk = (p - 0.22) / 0.66;
      const headX = homeX + 28 + easeOut(Math.min(1, dk * 1.45)) * (bx - homeX + 10);
      ctx.save();
      for (let si = 16; si >= 0; si--) {
        const st = Math.max(0, dk - si * 0.026);
        const sx0 = homeX + 24 + easeOut(Math.min(1, st * 1.45)) * (bx - homeX + 10);
        const sy0 = groundY - 12 + Math.sin(st * 13 + si * 0.55) * 24;
        const rad = (18 - si * 0.75) * (dk > 0.75 ? (1 - (dk - 0.75) * 3.5) : 1);
        if (rad > 1) {
          ctx.fillStyle = si % 2 === 0 ? 'rgba(255,212,68,0.78)' : 'rgba(255,148,32,0.68)';
          ctx.beginPath(); ctx.arc(sx0, sy0, rad, 0, Math.PI * 2); ctx.fill();
        }
      }
      ctx.restore();
      const headY = groundY - 12 + Math.sin(dk * 13) * 20;
      wxDrawImgFit(ctx, fxImgs.dragon, headX, headY, 96, 96, Math.cos(dk * 13) * 0.25, Math.min(1, (1 - dk) * 3.2), false);
    } else if (mode === 'sun_laser' && p > 0.36 && p < 0.78) {
      // Instantaneous imperial sun-gold meridian laser beam!
      const lk = 1 - Math.abs(((p - 0.36) / 0.42) - 0.35) * 1.5;
      ctx.save();
      ctx.globalAlpha = Math.max(0, Math.min(1, lk));
      ctx.strokeStyle = '#ffe45c'; ctx.shadowColor = '#ffae00'; ctx.shadowBlur = 18;
      ctx.lineWidth = 14 * lk; ctx.beginPath(); ctx.moveTo(hx + 28, groundY - 16); ctx.lineTo(W - 14, groundY - 16); ctx.stroke();
      ctx.strokeStyle = '#ffffff'; ctx.lineWidth = 4.5; ctx.stroke();
      ctx.restore();
    } else if (mode === 'flying_虹' && p > 0.20 && p < 0.86) {
      const fk = (p - 0.20) / 0.66;
      const sx0 = fk < 0.35 ? (hx + 34) : (hx + 34 + easeOut((fk - 0.35) / 0.45) * 285);
      const sy0 = groundY - 38 + Math.sin(fk * Math.PI * 2) * 8;
      ctx.save();
      ctx.strokeStyle = '#fff3a1'; ctx.shadowColor = '#ffd042'; ctx.shadowBlur = 16; ctx.lineWidth = 6;
      ctx.beginPath(); ctx.moveTo(Math.max(hx + 24, sx0 - 110), sy0); ctx.lineTo(sx0, sy0); ctx.stroke();
      ctx.restore();
      wxDrawImgFit(ctx, fxImgs.sword, sx0, sy0, 108, 72, 0, 1, false);
    } else if (mode === 'star_rain' && p > 0.28 && p < 0.86) {
      const rk = (p - 0.28) / 0.58;
      for (let si = 0; si < 7; si++) {
        const sk = (rk * 1.6 - si * 0.09);
        if (sk > 0 && sk < 1) {
          const x = bx - 54 + si * 18 - (1 - sk) * 70;
          const y = -20 + sk * (groundY + 42);
          wxDrawImgFit(ctx, fxImgs.sword, x, y, 78, 52, 1.05, Math.min(1, (1 - sk) * 2.5), false);
        }
      }
    } else if ((mode === 'needle24' || mode === 'fan_knives7' || mode === 'triple_arc' || mode === 'sonic_arrow' || mode === 'heavy_bolt' || mode === 'venom_spikes') && p > 0.32 && p < 0.80) {
      const vk = (p - 0.32) / 0.48;
      const cnt = mode === 'needle24' ? 14 : (mode === 'fan_knives7' ? 7 : (mode === 'triple_arc' || mode === 'venom_spikes' ? 3 : 1));
      for (let i = 0; i < cnt; i++) {
        const tk = Math.max(0, Math.min(1, vk * 1.4 - (i % 4) * 0.08));
        if (tk <= 0 || tk >= 1) continue;
        const spread = (i - (cnt - 1) / 2) * (mode === 'fan_knives7' ? 11 : 6);
        const px = (hx + 34) + tk * (bx - hx - 30);
        const py = (groundY - 16) + spread * tk - (mode === 'triple_arc' ? Math.sin(tk * Math.PI) * (36 + i * 14) : 0);
        ctx.save();
        ctx.strokeStyle = col; ctx.lineWidth = cnt === 1 ? 5 : 2.6;
        ctx.beginPath(); ctx.moveTo(px - 28, py); ctx.lineTo(px + 10, py); ctx.stroke();
        ctx.restore();
        if (mode === 'fan_knives7' && wpnIm) wxDrawImgFit(ctx, wpnIm, px, py, 34, 34, tk * 14, 1, false);
      }
      if (mode === 'venom_spikes' && vk > 0.45) wxDrawImgFit(ctx, fxImgs.poison, bx, groundY - 22 - (vk - 0.45) * 36, 118, 118, 0, 1 - (vk - 0.45) * 1.5, false);
    } else if ((mode === 'over_shield' || mode === 'neck_coil' || mode === 'viper_whip' || mode === 'bamboo_bind') && p > 0.28 && p < 0.82) {
      const wk = Math.sin(((p - 0.28) / 0.54) * Math.PI);
      ctx.save();
      ctx.strokeStyle = col; ctx.shadowColor = col; ctx.shadowBlur = 10; ctx.lineWidth = 4.5;
      ctx.beginPath();
      for (let s = 0; s <= 24; s++) {
        const t = s / 24;
        const wx = (hx + 24) + t * (bx - hx - 16);
        const arcLift = mode === 'over_shield' ? -Math.sin(t * Math.PI) * 68 : Math.sin(t * Math.PI * 3 + p * 18) * (mode === 'bamboo_bind' ? 12 : 22);
        const wy = (mode === 'bamboo_bind' ? groundY + 26 : groundY - 16) + arcLift * wk;
        if (s === 0) ctx.moveTo(wx, wy); else ctx.lineTo(wx, wy);
      }
      ctx.stroke();
      if (mode === 'neck_coil' || mode === 'bamboo_bind') {
        const ry = mode === 'bamboo_bind' ? groundY + 22 : groundY - 24;
        for (let r = 0; r < 3; r++) {
          ctx.beginPath(); ctx.ellipse(bx, ry + r * 7, 26, 8, 0, 0, Math.PI * 2); ctx.stroke();
        }
      }
      ctx.restore();
    } else if (mode === 'sky_thunder' && p > 0.42 && p < 0.84) {
      const tk = 1 - (p - 0.42) / 0.42;
      wxDrawImgFit(ctx, fxImgs.thunder, bx, groundY - 46, 136, 176, 0, tk, false);
    } else if (mode === 'buddha_palm' && p > 0.34 && p < 0.86) {
      const pk = Math.min(1, (p - 0.34) / 0.22);
      wxDrawImgFit(ctx, fxImgs.palm, bx - (1 - pk) * 40, groundY - 18 - (1 - pk) * 75, 138, 138, 0.25, Math.min(1, (0.86 - p) * 3.5), false);
    } else if (mode === 'ghost_claw' && hitWindow) {
      wxDrawImgFit(ctx, fxImgs.claw, bx, groundY - 12, 138, 138, 0, 1 - hk * 0.8, false);
    } else if (mode === 'frost_tomb' && p > 0.46 && p < 0.90) {
      const ik = Math.min(1, (p - 0.46) / 0.18);
      wxDrawImgFit(ctx, fxImgs.ice, bx, groundY + 2 - (1 - ik) * 24, 136, 136 * ik, 0, Math.min(1, (0.90 - p) * 3), false);
    } else if ((mode === 'blood_siphon' || mode === 'black_hole') && p > 0.45 && p < 0.92) {
      const sk = (p - 0.45) / 0.47;
      for (let oi = 0; oi < 6; oi++) {
        const ot = (sk * 1.4 - oi * 0.08);
        if (ot > 0 && ot < 1) {
          const ox = bx - easeOut(ot) * (bx - hx - 12);
          const oy = groundY - 16 - Math.sin(ot * Math.PI) * (28 - oi * 8);
          wxDrawImgFit(ctx, mode === 'black_hole' ? fxImgs.bagua : fxImgs.blood, ox, oy, 36, 36, ot * 8, 0.9, false);
        }
      }
    } else if ((mode === 'disarm_arc' || mode === 'disarm_grab') && p > 0.48 && p < 0.92) {
      // Enemy weapon knocked spinning high into the air!
      const dk = (p - 0.48) / 0.44;
      wxDrawImgFit(ctx, fxImgs.sword, bx + dk * 42, (groundY - 24) - Math.sin(dk * Math.PI) * 92, 68, 68, dk * 15, 1 - dk * 0.5, false);
      popups.push({x: bx, y: 46, txt: '缴械夺兵!', a: 1 - dk, col: '#ffe27a'});
    } else if ((mode === 'acupoint' || mode === 'lotus_poke') && hitWindow) {
      wxDrawImgFit(ctx, fxImgs.lotus, bx, groundY - 14, 124, 124, hk * 1.2, 1 - hk * 0.7, false);
    } else if (mode === 'golden_bell' && p > 0.14 && p < 0.92) {
      const bk = Math.min(1, (p - 0.14) / 0.20);
      wxDrawImgFit(ctx, fxImgs.bell, hx, groundY - 8 - (1 - bk) * 48, 148, 156, 0, Math.min(0.92, (0.92 - p) * 3.2), false);
    } else if (mode === 'hex_fortress' && p > 0.14 && p < 0.92) {
      for (let hi = -1; hi <= 1; hi++) {
        wxDrawHexPoly(ctx, hx + 32 + hi * 14, groundY - 10 + hi * 18, 26, 26, '#ffd65c', 'rgba(255,208,72,0.18)');
      }
    } else if ((mode === 'lion_roar' || mode === 'taunt_slam') && p > 0.28 && p < 0.88) {
      const rk = (p - 0.28) / 0.60;
      for (let ri = 0; ri < 4; ri++) {
        const rt = rk * 1.4 - ri * 0.12;
        if (rt > 0 && rt < 1) {
          wxDrawImgFit(ctx, fxImgs.sonic, hx + 38 + rt * (mode === 'lion_roar' ? 220 : 90), groundY - 12, 64 + rt * 96, 84 + rt * 86, 0, 1 - rt, false);
        }
      }
    } else if (mode === 'war_banner' && p > 0.12 && p < 0.92) {
      wxDrawImgFit(ctx, fxImgs.banner, hx + 18, groundY - 38, 112, 126, Math.sin(p * 12) * 0.08, 0.95, false);
      wxDrawImgFit(ctx, fxImgs.sonic, hx, groundY + 24, 160 * p, 64 * p, 0, 1 - p, false);
    } else if (mode === 'heal_needles' && p > 0.15 && p < 0.90) {
      const nk = (p - 0.15) / 0.75;
      for (let ni = 0; ni < 5; ni++) {
        const ang = -2.4 + ni * 0.45;
        const dist = nk < 0.45 ? 64 : 64 * (1 - easeOut((nk - 0.45) / 0.55));
        wxDrawImgFit(ctx, fxImgs.needle, hx + Math.cos(ang) * dist, (groundY - 18) + Math.sin(ang) * dist, 48, 48, ang + Math.PI, 0.95, false);
      }
    } else if ((mode === 'phoenix9' || mode === 'petal_storm') && p > 0.34 && p < 0.80) {
      const pk = (p - 0.34) / 0.46;
      for (let pi = 0; pi < 9; pi++) {
        const ang = -0.55 + pi * 0.14;
        const r = 45 + easeOut(Math.min(1, pk * 1.6)) * 115;
        wxDrawImgFit(ctx, fxImgs.sword, hx + 30 + Math.cos(ang) * r, (groundY - 14) + Math.sin(ang) * r, 76, 36, ang, 1 - pk * 0.85, false);
      }
    } else if (mode === 'night_exec' && p > 0.44 && p < 0.84) {
      const ek = 1 - (p - 0.44) / 0.40;
      ctx.save();
      ctx.strokeStyle = '#ff3870'; ctx.shadowColor = '#d44dff'; ctx.shadowBlur = 20; ctx.lineWidth = 5 * ek;
      ctx.beginPath(); ctx.moveTo(40, groundY + 18); ctx.lineTo(W - 24, groundY - 48); ctx.stroke();
      ctx.restore();
    } else if (mode === 'bomb_arc' && p > 0.24 && p < 0.88) {
      const bk = (p - 0.24) / 0.64;
      if (bk < 0.45) {
        const t = bk / 0.45;
        const px = (hx + 24) + t * (bx - hx - 24);
        const py = (groundY - 18) - Math.sin(t * Math.PI) * 82;
        ctx.fillStyle = '#2a2421'; ctx.beginPath(); ctx.arc(px, py, 9, 0, Math.PI * 2); ctx.fill();
      } else {
        const ex = (bk - 0.45) / 0.55;
        ctx.save();
        const g = ctx.createRadialGradient(bx, groundY - 14, 6, bx, groundY - 14, 96 * ex + 18);
        g.addColorStop(0, 'rgba(255,252,220,' + (1 - ex).toFixed(2) + ')');
        g.addColorStop(0.45, 'rgba(255,96,24,' + (0.85 * (1 - ex)).toFixed(2) + ')');
        g.addColorStop(1, 'rgba(40,20,12,0)');
        ctx.fillStyle = g; ctx.beginPath(); ctx.arc(bx, groundY - 14, 110, 0, Math.PI * 2); ctx.fill();
        ctx.restore();
      }
    } else if (mode === 'smoke_screen' && p > 0.26 && p < 0.94) {
      const sk = (p - 0.26) / 0.68;
      ctx.save();
      for (let ci = 0; ci < 7; ci++) {
        const r = 24 + sk * 46 + (ci % 3) * 12;
        ctx.fillStyle = 'rgba(148,162,175,' + (0.42 * (1 - sk * 0.6)).toFixed(2) + ')';
        ctx.beginPath(); ctx.arc(bx - 50 + ci * 22, groundY + 6 - (ci % 2) * 18 - sk * 18, r, 0, Math.PI * 2); ctx.fill();
      }
      ctx.restore();
    } else if ((mode === 'fire_pillar' || mode === 'blood_flame' || mode === 'lotus_breath' || mode === 'poise_draw') && p > 0.22 && p < 0.90) {
      const fk = Math.sin(((p - 0.22) / 0.68) * Math.PI);
      const px = mode === 'fire_pillar' ? bx : hx;
      ctx.save();
      const grad = ctx.createLinearGradient(px, groundY + 38, px, groundY - 118);
      grad.addColorStop(0, col);
      grad.addColorStop(1, 'rgba(255,255,255,0)');
      ctx.globalAlpha = fk * 0.65;
      ctx.fillStyle = grad;
      ctx.fillRect(px - 36, groundY - 116, 72, 154);
      ctx.restore();
    }

    // 9. Physics Impact Sparks Burst (`24` directional sparks on hit!)
    if (hitWindow && !isSelfOrMove) {
      ctx.save();
      for (let sp = 0; sp < 20; sp++) {
        const ang = (sp * 1.93) + (demoSpec.skill.length * 0.3);
        const spd = 28 + (sp % 5) * 19;
        const sx0 = bx - 8 + Math.cos(ang) * spd * hk;
        const sy0 = (groundY - 14) + Math.sin(ang) * spd * hk + hk * hk * 26;
        ctx.globalAlpha = Math.max(0, 1 - hk * 1.25);
        ctx.fillStyle = sp % 3 === 0 ? '#ffffff' : col;
        ctx.beginPath(); ctx.arc(sx0, sy0, 2.4 - hk * 1.4, 0, Math.PI * 2); ctx.fill();
      }
      ctx.restore();
    }

    // 10. Skill Overhead Banner + Unique Choreography Subtitle + Impact Number
    if (skObj && p > 0.05 && p < 0.94) {
      ctx.save();
      ctx.font = 'bold 12.5px "Microsoft YaHei", sans-serif';
      const titleTxt = '⚡ ' + skObj.name + ' · ' + (demoSpec.tag || '');
      const tw = Math.min(W - 24, ctx.measureText(titleTxt).width + 22);
      ctx.fillStyle = 'rgba(14,10,7,0.86)';
      ctx.fillRect(12, 10, tw, 22);
      ctx.strokeStyle = col; ctx.lineWidth = 1.2;
      ctx.strokeRect(12, 10, tw, 22);
      ctx.fillStyle = '#fff2d2'; ctx.textAlign = 'left';
      ctx.fillText(titleTxt, 22, 25);
      ctx.restore();
    }

    if (p >= 0.50 && p <= 0.92 && popups.length === 0) {
      const k = (p - 0.50) / 0.42;
      const fx = isSelfOrMove ? hx : bx;
      const fy = 56 - k * 22;
      const mainTxt = mode === 'mirage_step' ? 'MISS · 残影闪避!' :
                      mode === 'cloud_jump' ? '梯云越阵!' :
                      isSelfOrMove ? (skObj ? skObj.name + '!' : '+真罡!') :
                      ('-' + (64 + (demoSpec.skill.length * 7) % 35));
      ctx.save();
      ctx.globalAlpha = Math.min(1, (1 - k) * 2.2);
      ctx.textAlign = 'center';
      ctx.font = 'bold 18px Georgia, serif';
      ctx.strokeStyle = '#120b07'; ctx.lineWidth = 4;
      ctx.strokeText(mainTxt, fx, fy);
      ctx.fillStyle = isSelfOrMove ? '#9ef5c8' : col;
      ctx.fillText(mainTxt, fx, fy);
      ctx.restore();
    }
    popups.forEach(pp => {
      ctx.save();
      ctx.globalAlpha = Math.max(0, Math.min(1, pp.a));
      ctx.textAlign = 'center'; ctx.font = 'bold 16px Georgia, serif';
      ctx.strokeStyle = '#120b07'; ctx.lineWidth = 3.5;
      ctx.strokeText(pp.txt, pp.x, pp.y);
      ctx.fillStyle = pp.col || col;
      ctx.fillText(pp.txt, pp.x, pp.y);
      ctx.restore();
    });

    ctx.restore();

    const id = requestAnimationFrame(step);
    if (isDialog) wxDialogRafId = id; else wxAnimRafId = id;
  }

  const initId = requestAnimationFrame(step);
  if (isDialog) wxDialogRafId = initId; else wxAnimRafId = initId;
}

function getFilteredVfxDemos() {
  if (curVfxCat === 'featured') return vfxShowcaseDemos;
  if (curVfxCat === 'all') return all72SkillDemos;
  return all72SkillDemos.filter(d => d.fam === curVfxCat);
}

function renderVfxArena() {
  const list = getFilteredVfxDemos();
  const cur = list.find(d => d.skill === curVfxSkillId) || list[0] || vfxShowcaseDemos[0];
  if (!cur) return '';
  curVfxSkillId = cur.skill;
  const skObj = artById.get(cur.skill);
  const animObj = artById.get(cur.anim);
  const frameList = (animObj && animObj.animFrames) ? animObj.animFrames : [];
  const fNames = ['F1 蓄势起手', 'F2 身兵合一', 'F3 真罡破敌', 'F4 收势回气'];

  const catTabs = [
    ['featured', '镇派16绝技'],
    ['all', '全部72招零重复 (' + all72SkillDemos.length + ')'],
    ['sword', '剑法 (11)'],
    ['saber', '刀法 (9)'],
    ['fist', '拳掌指爪 (12)'],
    ['pole', '枪戟棍杖 (9)'],
    ['heavy', '锤斧重盾 (8)'],
    ['odd', '刺鞭暗器弓铳 (14)'],
    ['inner', '内功轻功奇术 (9)']
  ].map(([cid, lbl]) =>
    '<button type="button" data-vfx-cat="' + cid + '" aria-pressed="' + String(curVfxCat === cid) + '">' + html(lbl) + '</button>'
  ).join('');

  const stripHtml = frameList.map((fp, fi) =>
    '<button type="button" class="vfx-frame-cell" data-vfx-frame="' + fi + '" aria-pressed="' + String(curVfxLockFrame === fi) + '" title="点击定格检视第 ' + (fi + 1) + ' 阶段分解">' +
    '<img src="' + escapeAttr(fp) + '" alt=""><span>' + fNames[fi] + '</span></button>'
  ).join('');

  const btns = list.map((d, idx) => {
    const sk = artById.get(d.skill);
    if (!sk) return '';
    return '<button type="button" class="vfx-cast-btn" data-vfx-demo="' + idx + '" data-vfx-skill="' + escapeAttr(d.skill) + '" aria-pressed="' + String(d.skill === cur.skill) + '">' +
      '<img loading="lazy" src="' + escapeAttr(sk.previewPath) + '" alt="">' +
      '<span class="vfx-cast-meta"><b>' + html(sk.name) + '</b><small>' + html(d.tag) + '</small></span></button>';
  }).join('');

  setTimeout(() => wxStartMartialCanvas('wx-vfx-main-canvas', cur, false), 0);

  return '<section class="vfx-arena">' +
    '<div class="vfx-arena-head"><strong>⚡ 72 招零重复四帧序列与气芒 · 多关节动力学 60fps 实战演武剧场</strong>' +
    '<small>72套288帧全独立招式动作序列 + 32款手绘招式气芒 + 16款法相阵印 · 全量实装入 <code>wx_effects_0 / wx_effects_1.brush</code>（408枚战斗精灵）</small></div>' +
    '<div class="vfx-cat-tabs" role="group" aria-label="招式流派筛选">' + catTabs + '</div>' +
    '<div class="vfx-stage-box" data-active-anim="' + escapeAttr(cur.anim) + '" data-active-mode="' + escapeAttr(cur.mode) + '">' +
      '<div class="vfx-left-col">' +
        '<div class="vfx-canvas-wrap"><canvas id="wx-vfx-main-canvas" width="440" height="252"></canvas></div>' +
        '<div class="vfx-ctrl-bar">' +
          '<button type="button" data-vfx-ctrl="play" aria-pressed="' + String(curVfxLockFrame < 0) + '">▶ 连续演武</button>' +
          '<button type="button" data-vfx-ctrl="slow" aria-pressed="' + String(curVfxSpeed < 0.8) + '">' + (curVfxSpeed < 0.8 ? '🐢 0.45× 慢镜中' : '🐢 0.45× 慢镜拆招') + '</button>' +
          '<span style="font-size:11px;color:#e6cfa3">' + html(cur.desc || ((skObj ? skObj.name : '') + ' · ' + cur.tag)) + '</span>' +
        '</div>' +
        '<div class="vfx-strip-row">' + stripHtml + '</div>' +
      '</div>' +
      '<div class="vfx-skill-btns">' + btns + '</div>' +
    '</div></section>';
}

function renderArtView(query) {
  const stageCards = artStages.map(st => {
    const allInStage = artAssets.filter(a => a.stage === st.id);
    const doneInStage = allInStage.filter(a => a.status !== 'planned').length;
    const pct = allInStage.length ? Math.round((doneInStage * 100) / allInStage.length) : 0;
    const active = state.as === st.id;
    return '<button class="art-stage-btn" data-art-stage="' + escapeAttr(active ? '' : st.id) + '" aria-current="' + String(active) + '">' +
      '<strong>' + html(st.name) + '</strong>' +
      '<small>已实装 ' + doneInStage + ' / ' + allInStage.length + ' 项 (' + pct + '%)</small>' +
      '<div class="art-stage-bar"><span style="width:' + pct + '%"></span></div></button>';
  }).join('');

  const modeBar = '<div class="art-modebar">' +
    '<div class="art-modes" role="group" aria-label="图标实机预览模式">' +
    '<span>实机验看：</span>' +
    '<button data-art-mode="slot" aria-pressed="' + String(artPreviewMode === 'slot') + '">原版暗槽 (1:1)</button>' +
    '<button data-art-mode="pawn" aria-pressed="' + String(artPreviewMode === 'pawn') + '">♟ 战棋底座棋子</button>' +
    '<button data-art-mode="sw" aria-pressed="' + String(artPreviewMode === 'sw') + '">气竭置灰 (_sw)</button>' +
    '<button data-art-mode="hd" aria-pressed="' + String(artPreviewMode === 'hd') + '">高清手绘 (256px)</button>' +
    '<button data-art-mode="checker" aria-pressed="' + String(artPreviewMode === 'checker') + '">透明棋盘验边</button>' +
    '</div>' +
    '<div class="art-pipeline-tip">11 套二进制图集已编译入包：<code>wx_effects_0..1 / wx_projectiles_0 / wx_beasts_0 / wx_world_0 / wx_busts_0 / wx_weapons_0 / wx_corpses_0.brush</code></div>' +
    '</div>';

  const found = matchingArtAssets(query);
  if (!found.length) {
    return '<div class="art-overview">' + stageCards + '</div>' + modeBar + emptyState(0);
  }

  const artPageSize = 48;
  const pages = Math.max(1, Math.ceil(found.length / artPageSize));
  state.p = Math.min(Math.max(1, state.p), pages);
  const visible = found.slice((state.p - 1) * artPageSize, state.p * artPageSize);

  const showPd = !query && state.as === '3_characters' && !state.ag && state.p === 1;
  const showSh = !query && state.as === '4_beasts' && !state.ag && state.p === 1 && typeof renderShanHaiTopTheater === 'function';
  const showVfx = !query && ((state.as === '5_vfx' && !state.ag && state.p === 1) || (state.as === '1_icons' && state.ag && state.ag.includes('武学招式') && state.p === 1));
  const topWorkshopHtml = showPd ? renderPaperdollWorkshop() : (showSh ? renderShanHaiTopTheater() : (showVfx ? renderVfxArena() : ''));

  const groupsInSlice = [...new Set(visible.map(a => a.group))];
  const gridCls = 'art-grid' + (artPreviewMode === 'hd' ? ' hd-mode' : '');
  const sections = groupsInSlice.map(grp => {
    const items = visible.filter(a => a.group === grp);
    return '<section class="chapter"><div class="ch-head"><h2>' + html(grp) + '</h2><small>本页显示 ' + items.length + ' 项</small></div>' +
      '<div class="' + gridCls + '">' + items.map(a => {
        const stLabel = artStatusLabel(a.status);
        return '<article class="art-card' + (a.status === 'planned' ? ' planned-card' : '') + '">' +
          renderArtPreviewWell(a) +
          '<div class="art-card-head"><h3><button class="entry-btn" data-art-detail="' + escapeAttr(a.id) + '">' + html(a.name) + '</button></h3>' +
          tag(stLabel) + '</div>' +
          '<div class="art-sub">' + html(a.choreoLabel ? (a.sub + ' · ' + a.choreoLabel) : a.sub) + '</div>' +
          '<p class="art-brief">' + html(a.brief) + '</p>' +
          '<div class="art-card-foot"><code title="' + escapeAttr(a.id) + '">' + html(a.id) + '</code>' +
          '<button class="linkbtn" data-art-detail="' + escapeAttr(a.id) + '">规格与演武</button></div>' +
          '</article>';
      }).join('') + '</div></section>';
  }).join('');

  return '<div class="art-overview">' + stageCards + '</div>' + topWorkshopHtml + modeBar + sections + pager(pages);
}

function showArtDetail(a) {
  if (!a) return;
  let showcase = '';
  let animDialogHtml = '';
  if (a.animId || a.animFrames) {
    const animObj = a.animFrames ? a : artById.get(a.animId);
    const matchedDemo = all72SkillDemos.find(d => d.skill === a.id) || all72SkillDemos.find(d => d.anim === a.id) || vfxShowcaseDemos[0];
    const fImgs = (animObj && animObj.animFrames ? animObj.animFrames : []).map((fp, idx) =>
      '<div class="vfx-frame-cell"><img src="' + escapeAttr(fp) + '" alt=""><span>F' + (idx + 1) + ' 序列帧</span></div>'
    ).join('');
    animDialogHtml = '<div class="art-anim-dialog-box">' +
      '<div style="display:flex;justify-content:space-between;align-items:center;font-size:12px;color:#e8d7b9">' +
      '<strong>⚡ ' + html(matchedDemo.tag || '实机招式动作实时演武') + '</strong><span><code>' + html(matchedDemo.skill) + '</code> · 零重复独立轨迹</span></div>' +
      '<div class="vfx-canvas-wrap"><canvas id="wx-dialog-anim-canvas" width="440" height="246"></canvas></div>' +
      '<div class="vfx-strip-row">' + fImgs + '</div></div>';
    setTimeout(() => wxStartMartialCanvas('wx-dialog-anim-canvas', matchedDemo, true), 0);
  }

  let paperdollModelHtml = '';
  if (a.bustPath && (a.pdRole === 'weapon' || a.pdRole === 'shield' || a.pdRole === 'torso' || a.pdRole === 'hat')) {
    const demoBro = {
      face: artById.get('wx_head_01') || pdPools.face[0],
      hair: artById.get('wx_hair_09') || pdPools.hair[0],
      hairTone: 0,
      beard: null,
      scar: null,
      hat: a.pdRole === 'hat' ? a : null,
      torso: a.pdRole === 'torso' ? a : (artById.get('wx_body_arm_07') || pdPools.torso[0]),
      wpn: a.pdRole === 'weapon' ? a : (artById.get('wx_wpn_sword_04') || pdPools.weapon[0]),
      shield: a.pdRole === 'shield' ? a : null
    };
    paperdollModelHtml = '<div class="art-showcase-col"><div class="pd-editor-stage" style="width:112px">' +
      renderBustStackHtml(demoBro, 'pd-bust-frame', true) + '</div><span>实机持握/披挂胸像</span></div>';
  }

  if (a.status !== 'planned' && a.previewPath) {
    const slotCls = (a.slotKind === 'weapon140' || a.slotKind === 'armor140') ? 'bb-slot bb-slot-140' :
                    (a.slotKind === 'event210' ? 'bb-slot bb-slot-event' :
                    (a.slotKind === 'screen16x9' ? 'bb-slot bb-slot-wide-lg' :
                    (a.slotKind === 'camp' ? 'bb-slot bb-slot-camp' :
                    (a.slotKind === 'boss' ? 'bb-slot bb-slot-boss' :
                    (a.slotKind === 'item70' ? 'bb-slot bb-slot-70' : 'bb-slot bb-slot-56')))));
    const showSeparateHd = a.hdPath && a.slotKind !== 'screen16x9';
    showcase = animDialogHtml + '<div class="art-dialog-showcase">' +
      (showSeparateHd ? '<div class="art-showcase-col"><div class="bb-slot bb-slot-hd"><img src="' + escapeAttr(a.hdPath) + '" alt=""></div><span>手绘高清原图</span></div>' : '') +
      paperdollModelHtml +
      (a.bustPath ? '<div class="art-showcase-col"><div class="bb-slot bb-slot-140"><img src="' + escapeAttr(a.bustPath) + '" alt=""></div><span>104×142 独立锁合层</span></div>' : '') +
      '<div class="art-showcase-col"><div class="' + slotCls + '"><img src="' + escapeAttr(a.previewPath) + '" alt=""></div><span>' + (a.smallPath ? '70×140 装备大格' : '1:1 游戏实机图') + '</span></div>' +
      (a.hoverPath ? '<div class="art-showcase-col"><div class="bb-slot bb-slot-camp"><img src="' + escapeAttr(a.hoverPath) + '" alt=""></div><span>悬停金辉态 (_b)</span></div>' : '') +
      (a.smallPath ? '<div class="art-showcase-col"><div class="bb-slot bb-slot-70"><img src="' + escapeAttr(a.smallPath) + '" alt=""></div><span>70×70 行囊小格</span></div>' : '') +
      (a.swPath ? '<div class="art-showcase-col"><div class="bb-slot bb-slot-56"><img src="' + escapeAttr(a.swPath) + '" alt=""></div><span>56×56 置灰态 (_sw)</span></div>' : '') +
      '</div>';
  }
  const cmd = 'python tools/sync_art_to_mod.py --apply --id ' + a.id;
  const rows = [
    ['资产编号', '<code>' + html(a.id) + '</code>'],
    ['当前状态', tag(artStatusLabel(a.status))],
    ['所属分卷', html(a.group + ' · ' + a.sub)],
    ['引擎规格', html(a.spec)],
    ...(a.choreoLabel ? [['专属动作', html(a.choreoLabel + ' —— ' + (a.choreoDesc || ''))]] : []),
    ['目标路径', '<code>mod_wuxia/' + html(a.gameTarget) + '</code>'],
    ['原版占位', '<code>' + html(a.vanillaFallback) + '</code>'],
    ['绑定脚本', '<code>mod_wuxia/' + html(a.codeRef) + '</code>'],
  ];
  const extra = showcase +
    detailArticle('美术设定与材质考据', a.brief) +
    '<div class="art-cmd-box"><code id="art-sync-cmd">' + html(cmd) + '</code>' +
    '<button class="plain" data-copy-cmd="' + escapeAttr(cmd) + '">复制实装命令</button></div>';

  openDialog(a.name, rows, a.hdPath || a.previewPath || '#v=art', extra);
  const srcLink = element('detail-source');
  if (srcLink) {
    if (a.hdPath) {
      srcLink.textContent = '单独打开高清原图 ↗';
      srcLink.hidden = false;
    } else {
      srcLink.hidden = true;
    }
  }
}
// === ART_STUDIO_END ==="""


def main():
    manifest = json.load(open(MANIFEST_PATH, "r", encoding="utf-8"))
    html_txt = open(WIKI_PATH, "r", encoding="utf-8").read()
    total_cnt = manifest["summary"]["total"]
    ready_cnt = manifest["summary"]["wiki_ready"] + manifest["summary"]["in_game"]

    # 1. Update ART_CSS
    html_txt = re.sub(
        r"/\* === 美术图鉴工坊 \(Art Studio\) === \*/[\s\S]*?</style>",
        lambda _m: ART_CSS + "\n</style>",
        html_txt,
        count=1,
    )

    # 2. Update .stats header counts
    html_txt = re.sub(
        r'<div class="stats">[\s\S]*?</div>',
        (
            '<div class="stats">'
            '<span><b id="article-count"></b> 篇武侠词条</span>'
            f'<span>美术图鉴 <b id="art-ready-count">{ready_cnt}</b> / <b id="art-total-count">{total_cnt}</b> 项已实装</span>'
            '<span>72招独立演武 · 山海万妖 <b>136</b> · 江湖劲敌 <b>48</b> · 面孔发须 <b>96</b> · 手持兵盾 <b>138</b></span>'
            '<span>原版索引 <b>2,063</b> 篇</span>'
            '</div>'
        ),
        html_txt,
        count=1,
    )

    # 3. Update <script type="application/json" id="art-data">
    art_json_str = json.dumps(manifest, ensure_ascii=False, separators=(",", ":"))
    html_txt = re.sub(
        r'<script type="application/json" id="art-data">[\s\S]*?</script>',
        lambda _m: f'<script type="application/json" id="art-data">\n{art_json_str}\n</script>',
        html_txt,
        count=1,
    )

    # 4. Update ART_JS
    html_txt = re.sub(
        r"// === ART_STUDIO_BEGIN ===[\s\S]*?// === ART_STUDIO_END ===",
        lambda _m: ART_JS,
        html_txt,
        count=1,
    )

    # 5. Update click handlers for customizer, helmet/weapon toggles & 60fps animation controls
    html_txt = re.sub(
        r"  if\((?:d\.vfxCat|d\.vfxDemo!==undefined|d\.pdPreset)\)[\s\S]*?rerollSingleBrother\(Number\(d\.pdOne\)\);render\(\);return;\}",
        (
            "  if(d.vfxCat) {curVfxCat=d.vfxCat;curVfxLockFrame=-1;const l=getFilteredVfxDemos();if(l[0])curVfxSkillId=l[0].skill;render();return;}\n"
            "  if(d.vfxCtrl==='play') {curVfxLockFrame=-1;render();return;}\n"
            "  if(d.vfxCtrl==='slow') {curVfxSpeed=(curVfxSpeed<0.8?1.0:0.45);curVfxLockFrame=-1;render();return;}\n"
            "  if(d.vfxFrame!==undefined) {const fi=Number(d.vfxFrame);curVfxLockFrame=(curVfxLockFrame===fi?-1:fi);render();return;}\n"
            "  if(d.vfxDemo!==undefined) {const l=getFilteredVfxDemos();const idx=Number(d.vfxDemo);curVfxDemoIdx=idx;if(d.vfxSkill)curVfxSkillId=d.vfxSkill;else if(l[idx])curVfxSkillId=l[idx].skill;curVfxLockFrame=-1;curVfxReplayTick++;render();return;}\n"
            "  if(d.pdPreset) {pdWorkshopOpen=true;pdShowHelmets=(d.pdPreset==='army');generatePdSquad(d.pdPreset);render();return;}\n"
            "  if(d.pdHelms) {pdWorkshopOpen=true;pdShowHelmets=!pdShowHelmets;generatePdSquad(pdPreset);render();return;}\n"
            "  if(d.pdWpns) {pdWorkshopOpen=true;pdShowWeapons=!pdShowWeapons;render();return;}\n"
            "  if(d.pdEdit!==undefined) {openBrotherEditor(Number(d.pdEdit));return;}\n"
            "  if(d.pdStep) {handlePdStep(d.pdStep);return;}\n"
            "  if(d.pdOne!==undefined) {pdWorkshopOpen=true;rerollSingleBrother(Number(d.pdOne));render();return;}"
        ),
        html_txt,
        count=1,
    )

    with open(WIKI_PATH, "w", encoding="utf-8") as f:
        f.write(html_txt)
    print(f"SUCCESS: Updated {WIKI_PATH} with {total_cnt} assets, 138 Handheld Weapons/Shields & 72-Skill Combat Animator v2 ({len(html_txt)} chars)")


if __name__ == "__main__":
    main()
