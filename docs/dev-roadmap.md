# 《战场兄弟》武侠 Mod 精简开发路线与模块/数据表拆解

> **配套主文档**：[docs/system-design.md](system-design.md)（现行核心系统总设计）。  
> 本文档将定稿后的四层自洽设计拆解为可直接开工的 **Mod 目录结构、核心模块职责、Squirrel 数据表 Schema 与 M0–M4 五阶段施工清单**。

---

## 1. Mod 目录与模块拆解（基于 `Modern Hooks + MSU`）

因已取消传统 Perk 树，不再依赖 DPF 与 Nested Tooltips。所有新增数据、逻辑、UI 全部收口在 `mod_wuxia` 内，**新增秘籍、丹药、门派或敌人只需填配置表，不改框架代码**。

```text
mod_wuxia/
├─ scripts/
│  ├─ !mods_preload/
│  │  └─ mod_wuxia.nut                     # 注册 Mod、声明依赖(Modern Hooks + MSU)与冲突(Legends/Reforged)
│  ├─ skills/
│  │  ├─ special/
│  │  │  └─ wx_martial_container.nut       # 【核心】单人武学数据载体（7槽/重数/火候/洗髓/存档序列化）
│  │  ├─ actives/                          # 外功主动招式、调息、轻功位移、邪功燃血爆发
│  │  │  └─ wx_*.nut
│  │  └─ effects/                          # 战斗状态(破绽/失衡/点穴/反击/内伤)与大地图状态(散功虚弱/经脉震荡/走火入魔)
│  │     └─ wx_*.nut
│  ├─ items/misc/
│  │  ├─ wx_manual_item.nut                # 通用秘籍物品基类（由配置表 ID 驱动，不每本写一个类）
│  │  ├─ wx_page_item.nut                  # 通用残页物品基类（堆叠、拼合、残本强修）
│  │  └─ wx_pill_item.nut                  # 丹药消耗品基类（金疮散/护心丹/凝神丸/洗髓丹/护脉丹）
│  ├─ entity/tactical/enemies/
│  │  └─ wx_*.nut                          # 首批敌人（清风弃徒/剑客/剑首、黑风刀手/毒暗手/血煞头领）
│  ├─ scenarios/world/
│  │  ├─ wx_jianghu_start.nut              # 正式开局「初走江湖」
│  │  └─ wx_debug_arena.nut                # 调试开局「演武试剑台」
│  └─ events/events/
│     └─ wx_*.nut                          # 门派拜师换秘籍、拍卖会/鬼市、名医治内伤、门派寻仇
├─ mod_wuxia/
│  ├─ load.nut                             # 统一按序加载 config → systems → hooks
│  ├─ config/                              # 【纯数据配置层】
│  │  ├─ slots.nut                         # 7 槽结构与 1/3/5/7/9/11 级解锁规则
│  │  ├─ manuals.nut                       # 首批 24 本秘籍配置总表
│  │  ├─ consumables.nut                   # 丹药、残页合成与百工配方表
│  │  ├─ sects.nut                         # 威远/清风/黑风血煞配置、交情档位与兑换池
│  │  └─ text_zh.nut                       # 全局中文文本表（大地图名称附带拼音兜底列）
│  ├─ systems/                             # 【核心业务规则层】
│  │  ├─ slot_manager.nut                  # 装槽校验、散功覆盖代价、残本强修、内功相克判定
│  │  ├─ mastery_manager.nut               # 战后火候结算、凝神丸灌注、门槛检查、升重与孤本 AP/洗髓契机
│  │  ├─ marrow_wash.nut                   # 洗经伐髓（冲星/易筋换星、成功率计算、失败重内伤/暗疾）
│  │  ├─ combat_rules.nut                  # 四大内功回气、真气护体、轻装卸力/铁布衫、常驻 AP 封顶 11 校验
│  │  ├─ sect_relations.nut                # 门派轻量交情（存 World.Flags）与寻仇队伍触发
│  │  └─ loot_economy.nut                  # 敌我同源掉落（按敌方所装功法生成残页/整本）、书肆/拍卖投放
│  └─ hooks/                               # 【原版 Hook 接入层，绝不整文件覆盖原版】
│     ├─ entity/tactical/actor.nut         # 挂 wx_martial_container、读取动态 AP 上限(<=11)、护体与回气钩子
│     ├─ entity/tactical/player.nut        # 关闭原版 Perk 点升级分配，改为按等级解锁槽位并刷新 UI
│     ├─ skills/skill.nut                  # 外功兵器大类校验、内息消耗修正与提示追加
│     ├─ ui/global/data_helper.nut         # 透传 7 槽、AP、主修路数、行囊秘籍/残页/丹药给前端 JS
│     ├─ ui/screens/character/character_screen.nut  # 承接前端拖拽装槽、散功确认、灌注、拼合、洗髓回调
│     └─ ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar.nut  # 透传内息条与动态 AP 格
├─ ui/mods/mod_wuxia/                      # 【前端 UI 层，严格 ES3 兼容或经 BBBuilder -transpile】
│  ├─ character_screen_wuxia_module.js     # 原地替换原版 Perk 页：7 格图标槽 + 拖拽装配 + 散功/洗髓弹窗
│  ├─ tactical_hud_wuxia.js                # 内息条换皮 + AP 条 9/10/11 及金色爆发格自适应
│  └─ mod_wuxia.css                        # 品阶边框色、重数圆点、火候进度细条、残本裂纹角标
└─ gfx/ & unpacked_brushes/                # 图标与后期分批替换的美术素材
```

---

## 2. 核心数据表 Schema（编码前锁定字段）

### 2.1 单人存档数据（`special.wx_martial_container`）
每名角色（含玩家侠客与挂功法的敌方高手）挂载 1 个该隐藏技能对象，利用 BB 技能自带的 `onSerialize` / `onDeserialize` 自主存读档：

```squirrel
// 角色武学存档结构（概念 Schema）
{
    SchemaVersion = 1,            // 存档迁移版本号
    Slots = [
        // 索引 0..6 固定对应 7 个槽位
        {
            SlotIndex   = 0,              // 0..6
            SlotType    = "neigong_main", // neigong_main | waigong | qinggong | henglian | waigong | free | free
            UnlockLevel = 1,              // 1, 1, 3, 5, 7, 9, 11
            ManualID    = null,           // 已装秘籍 ID，如 "wx_manual_guiyuan"；空槽为 null
            Tier        = 0,              // 当前重数：0(空) / 1 / 2 / 3
            Exp         = 0,              // 当前重已积累火候
            IsFragment  = false           // true 表示残本强修（锁死 1 重 + 走火入魔判定）
        }
        // ...共 7 项
    ],
    PendingWashChances = 0,       // 来自孤本内功大成等尚未使用的洗髓契机次数
    UsedUniqueEffects  = {},      // 记录已触发过一次性大成奖励的秘籍 ID，防重复刷洗髓
    MarrowWashCount    = 0        // 历史洗髓次数统计（便于日志与成就/事件读取）
}
```

### 2.2 秘籍配置表（`mod_wuxia/config/manuals.nut`）
24 本 MVP 秘籍与未来上百本秘籍全部走同一套声明式数据表：

```squirrel
"wx_manual_taixu" = {
    ID              = "wx_manual_taixu",
    Name            = "太虚真经",
    Category        = "neigong",       // neigong | waigong | qinggong | henglian
    Quality         = "unique",        // common | sect | secret | unique
    Element         = "neutral",       // neutral | yang | yin | evil（内功相克用；非内功填 null）
    WeaponTypes     = [],              // 外功绑定的 MSU WeaponType 列表，如 [::Const.Items.WeaponType.Sword]
    Icon            = "ui/wuxia/manuals/taixu.png",
    BasePrice       = 12000,           // 基准售价/拍卖底价
    FragmentsNeeded = 5,               // 大路货 0 / 上乘 3 / 绝学与孤本 5
    AllowFragmentLearn = true,         // 是否允许残本强修（仅限 1 重 + 失控风险）
    Requirements    = {                // 突破三重大成的八维/根骨门槛（装入 1 重可适当放宽或直接校验）
        Resolve = 65,
        Stamina = 110,
        MinStarsOnAny = 2              // 可选根骨要求
    },
    Levels = [
        // Index 0 = 一重（装入即得）
        {
            ExpNeeded = 0,
            Stats = { Stamina = 15, Resolve = 5, FatigueRecoveryRate = 2 },
            GrantSkills = ["actives.wx_meditate_deep"],
            Flags = {}
        },
        // Index 1 = 二重（小成）
        {
            ExpNeeded = 300,
            Stats = { Stamina = 25, Resolve = 10, FatigueRecoveryRate = 4 },
            GrantSkills = ["actives.wx_meditate_deep"],
            Flags = { HarmonizeConflict = true } // 调和辅修内功相克
        },
        // Index 2 = 三重（大成）
        {
            ExpNeeded = 800,
            Stats = { Stamina = 40, Resolve = 15, FatigueRecoveryRate = 6 },
            GrantSkills = ["actives.wx_meditate_deep"],
            Flags = {
                HarmonizeConflict = true,
                PermanentAPBonus  = 1,           // 永久 +1 AP（受全局硬封顶 11 AP 约束）
                GrantWashChance   = 1            // 首次大成赠送 1 次洗经伐髓契机
            }
        }
    ]
}
```

### 2.3 敌方武学与“所见即所得”掉落表
敌方单位脚本中直接声明 `m.WX_LoadoutManuals`，初始化时自动通过 `slot_manager` 挂载对应重数的功法，击杀结算时 `loot_economy` 直接读取同一份列表按概率爆出对应残页或整本：

```squirrel
// 敌人模板片段（例：清风剑客）
m.WX_LoadoutManuals = [
    { ManualID = "wx_manual_songtao",    Tier = 2, DropWeight = 20 },
    { ManualID = "wx_manual_qingfeng",   Tier = 2, DropWeight = 35 },
    { ManualID = "wx_manual_taxue",      Tier = 2, DropWeight = 25 },
    { ManualID = "wx_manual_jinchan",    Tier = 1, DropWeight = 20 }
];
```

### 2.4 轻量门派配置与交情表（不占 Faction ID）
每个门派的交情数值（`-100 ~ +100`）统一序列化在 `::World.Flags`（键如 `wx_sect_rel_qingfeng`），与原版 64 势力 ID 红线彻底解耦：

```squirrel
"qingfeng" = {
    ID            = "qingfeng",
    Name          = "清风剑派",
    DefaultRel    = 0,
    ShopManuals   = [
        { ManualID = "wx_manual_songtao",  MinRel = 20, Price = 1800 },
        { ManualID = "wx_manual_qingfeng", MinRel = 35, Price = 2400 },
        { ManualID = "wx_manual_taxue",    MinRel = 50, Price = 2600 }
    ],
    VendettaRel   = -35,               // 低于此值定期在道路上触发剑派寻仇队
    VendettaParty = "wx_qingfeng_hunters"
}
```

---

## 3. 精简 5 阶段施工路线（M0 → M4）

每一阶段结束都必须产出**可进游戏实机验收、无 `log.html` 报错、可存读档**的版本。

### M0 · 环境打通与最小骨架（技术通车）
- [ ] **0.1** 确认 Windows 实机测试环境：原版游戏（全 5 DLC）、汉化包 + `bb-launcher`、`Modern Hooks`、`MSU` 与 `BBBuilder` 构建流。
- [ ] **0.2** 建立 `mod_wuxia` 最小目录与 `scripts/!mods_preload/mod_wuxia.nut`，打包进游戏冷启动，`log.html` 确认加载成功且无冲突。
- [ ] **0.3** 制作调试开局「演武试剑台」（`wx_debug_arena.nut`），验证能开新局、存读档、且中文 UI 与大地图名称显示正常。

> **M0 验收标准**：`bbbuilder build` 零语法错；游戏内选「演武试剑台」进入大地图，保存退出再载入正常。

---

### M1 · 人物插槽底座 + 图标化拖拽 UI（核心培养闭环）
- [ ] **1.1** 实现 `wx_martial_container.nut` 存档载体与 `slots.nut`（1/3/5/7/9/11 级共 7 槽），Hook `player.nut` 关闭原版 Perk 点分配。
- [ ] **1.2** 实现 `wx_manual_item.nut`、`wx_page_item.nut`、`wx_pill_item.nut` 物品基类及 `slot_manager.nut`（装槽校验、散功覆盖虚弱/内伤、3/5 张残页拼合、残本强修）。
- [ ] **1.3** 实现 `marrow_wash.nut`（严格维持最多 3 项带星：冲星 30%/15%、易筋换星 45%、定力/气血/护脉丹加成、失败经脉震荡/永久暗疾）。
- [ ] **1.4** 开发 `character_screen_wuxia_module.js` + `mod_wuxia.css`，**原地替换原版 Perk 页**：7 格图标化方形插槽、品阶边框、重数圆点与火候细条、底区秘籍/残页/丹药图标格网、**全拖拽与右键装配**（含拖拽「凝神丸」灌注火候）、散功二次确认弹窗与洗经伐髓透明概率弹窗。

> **M1 验收标准**：在「演武试剑台」里完成全流程实机操作——升级开槽、拖拽秘籍装入、拖拽覆盖触发散功虚弱、拖拽凝神丸涨火候升重、拼合残页、残本强修、洗髓冲星与易筋换星——保存重读后全部状态 100% 精准复原。

---

### M2 · 内息/AP 规则 + 首批 24 本秘籍与战斗 HUD（核心战斗闭环）
- [ ] **2.1** 实现 `combat_rules.nut`：八维中文换名（内息=疲劳合一）、四大内功路数回气、大小调息、真气护体（1:2 抵伤）、轻装卸力（≤15 负重减伤）vs 铁布衫硬功、轻功移耗与身法转招架、**常驻 AP 硬封顶 11** 与条件/燃血临时爆发 AP。
- [ ] **2.2** 填完 `manuals.nut` 首批 **24 本秘籍**（8 大路货 + 8 上乘 + 5 绝学 + 3 孤本）对应的主动招式、被动效果与 **8 种核心战斗状态**（破绽、失衡、点穴封气、反击架势、蓄势、内伤、中毒、烟幕），并配齐基础 AI 行为接入。
- [ ] **2.3** 实现 `mastery_manager.nut`（战后参战自动结算火候、门槛校验、突破三重解锁大招/AP/洗髓契机）与内功相克实战逆冲判定。
- [ ] **2.4** 开发 `tactical_hud_wuxia.js`：战斗左下角内息条换皮 + **动态 AP 格自适应显示（9/10/11 格 + 金色爆发格）** + 招式 Tooltip 补充内息/状态说明。

> **M2 验收标准**：在调试开局中分别组建“轻装 10~11 AP 剑客”“铁布衫重刀手”“邪功击杀返 AP 狂刀”“长枪控场 + 暗器毒烟”等不同大哥打实战，验证 AP 上限不越红线、护体防轻装暴毙、战后火候正确结算、AI 正常释放武学招式。

---

### M3 · 3 原型势力、敌我同源掉落、经济拍卖与正式开局（MVP 完整可玩版）
- [ ] **3.1** 实装 3 个原型势力（威远镖局、清风剑派、黑风寨/血煞帮）与对应 6 档敌人模板，挂装 `WX_LoadoutManuals` 并接通 `loot_economy.nut`（击败敌人按其所装武学爆残页/整本）。
- [ ] **3.2** 实装 5 种核心丹药与**双线伤养**（外伤金疮散/常规医馆；内伤/走火入魔/经脉震荡须用护心丹或名医事件调养）+ 百工残页拼合/洗髓丹炼制配方。
- [ ] **3.3** 接通大世界分层投放：城镇书肆常卖大路货、门派交情兑换上乘与交恶触发寻仇队、城中拍卖会/无常鬼市事件竞拍绝学与压轴孤本、血煞总寨与叛门剑首 Boss 据点。
- [ ] **3.4** 完成正式开局「初走江湖」（5 名不同出身初始侠客，12 人上场/20 人花名册，无固定领队绑定），跑通 60~100 游戏日完整实机试玩与数值微调。

> **M3 验收标准**：从「初走江湖」第 1 天开打，连续玩通 60~100 游戏日：组建 12 人江湖梯队（核心大哥吃绝学孤本与洗髓、中坚配门派上乘、外围用大路货）、体验书肆/门派/拍卖/据点四层获取、清剿终极据点 Boss，全程 `log.html` 零报错。

---

### M4 · 内容横扩、全面换皮与分批美术替换（正式版演进）
- [ ] **4.1 兵器与门派横扩**：按配置表补齐棍、拳掌、弓弩、火器与后续门派（禅宗、道门、暗器世家、毒派、丐帮、魔教等），验证“加新门派只填表、不动框架”。
- [ ] **4.2 全面武侠化替换与后期内容**：全面替换原版兽人/亡灵/地精生态，接入 4 大**武林大势**（正邪大战、世家纷争、山寨/边地联军、古墓异变）与多处**武林禁地 / 天下武林大会（终极擂台）**，每次世界生成校验真势力最大 ID < 64。
- [ ] **4.3 分批替换美术与体验打磨**：按“武学/丹药图标 → 中式衣甲/斗笠/兵器 sprite → 城镇/战场/旗帜与事件插画”顺序分批替换占位素材，视反馈将高阶事件（拍卖行/门派武馆）升级为独立精美 UI。

---

## 4. 开发期工程红线（编码自检清单）

1. **脚本语言规范**：后端逻辑为 **Squirrel 3.0**；前端 `ui/mods/mod_wuxia/*.js` 严守 **ES3 语法**（或统一经 `BBBuilder -transpile` 编译），避免游戏内嵌 Chromium 报语法错。
2. **命名与隔离**：所有新文件、ID 加 `wx_` 前缀，扩展到原版类上的字段/方法加 `WX_` 前缀；绝不整文件覆盖原版脚本，全部使用 `Modern Hooks`。
3. **存档向后兼容**：所有秘籍、敌人、状态 ID 一旦发布只往尾部追加、不改名；`wx_martial_container` 携带 `SchemaVersion`，字段变动时通过 MSU 存档版本迁移平滑升级。
4. **64 势力 ID 护栏**：在 `faction_manager.createFactions()` 末尾打印最大势力 ID 日志，确保绝不触及原版 64 硬上限。
