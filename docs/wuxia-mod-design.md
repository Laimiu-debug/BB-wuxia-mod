# 《战场兄弟》武侠 Mod 整体设计方案

核实日期：2026-11-17。本文只产出设计，不含代码仓库。

文中两种标记：

- **已核实**：我读过对应仓库的源码或官方文档（来源见文末）。
- **未核实**：来自经验或推断，动手前要对照反编译的原版脚本确认。

所有数值都是第一版，供试玩后调整。

---

## 0. 核实结论，以及和你假设不一致的地方

### 0.1 框架现状（已核实）

| 组件 | 当前版本 | 最近更新 | 说明 |
| --- | --- | --- | --- |
| 原版游戏 | 1.5.2.3 | 2026-06-24 | Legends、Reforged、Modular Vanilla 都已跟到 1.5.2.x |
| Modern Hooks | 0.7.0 | 2026-11-01 | 活跃。初始化期改类定义，子类自动继承，无运行时开销 |
| MSU | 1.9.0 | 2026-06 | 活跃。依赖 Modern Hooks，要求原版 ≥ 1.5.0-13 |
| Dynamic Perks Framework（DPF） | 0.5.1 | 2025-12-11 | Reforged 在用（要求 ≥ 0.5.0）。仍是 0.x |
| Nested Tooltips Framework | 0.5.5 | 2026-11-17 | 只在 GitHub Releases 发布 |
| Reforged | 0.9.3 | 2026-08-28 | DPF 最完整的使用范例 |
| Modular Vanilla | 0.9.1 | 2026-10 | 把原版攻击和受伤大函数拆成小函数。要求全部 5 个 DLC |
| BBBuilder | 1.5 | 2026-06 | Windows 工具，内含 Adam 的 mod kit（反编译、bbrusher） |

### 0.2 和你的假设不一致或需要补充的地方

| 你的假设 | 核实结果 | 影响 |
| --- | --- | --- |
| 依赖 Modern Hooks + MSU + DPF 即可 | **不够。** DPF 0.5.1 源码里写的是 `require(["mod_msu", "mod_nested_tooltips"])`，所以硬依赖是 4 个：Modern Hooks、MSU、Nested Tooltips、DPF。Nexus 页面没把 Nested Tooltips 列为前置，以源码为准 | 玩家要多装一个只在 GitHub 发布的包 |
| DPF 拿来就能用 | 能独立于 Reforged 使用，但它只是框架：单装 DPF 时所有背景仍返回原版 perk 树，perk 组、集合、背景蓝图全部要自己定义。官方 wiki 只有一页，用法要读源码和 Reforged | 第一阶段要预留读源码的工作 |
| （未提及）存档 | DPF 改了 `player` 的序列化（在原数据前写入 perk 层数和整棵树）。必须新开档，装上后的存档离不开 DPF | 写进发布说明 |
| （未提及）中文显示 | 原版引擎画大地图文字用位图字体，只有 Windows-1252 的 256 个字符，UTF-8 中文会成乱码。受影响的是城镇名、队伍名、据点名、区域名。HTML 界面（提示、事件、角色界面）不走这套字体 | 中文城镇名在纯原版引擎上不可行，对策见 1.4 |
| 改地图放后期 | 同意。另外原版引擎的世界地图上限是 140×170，超过会让世界生成崩溃（Modern Engine 文档的说法）；反编译脚本里的默认尺寸是 140×140 | "更大的地图"在原版引擎上做不了 |
| 内力做独立资源 | 可行。但 Reforged 加"攻击距离"这个新属性时，是**替换**了士气条，没有新增一条。说明战斗界面左下角的状态条位置很紧 | 内力条的界面方案要选，见第 2 节 |
| （未提及）炼丹复用原版工艺系统 | 原版 `crafting_manager.create()` 开头就判断 `Const.DLC.Unhold`，没有"野兽与探索"DLC 时工艺系统是空的 | DLC 要求要你定，见第 8 节 |

### 0.3 调研中发现、你没提到但会影响决策的东西

1. **Modern Engine（`bb`）**：Enduriel（Modern Hooks 作者）做的替代引擎，读你自己的游戏数据和 mod。仓库文档已写到 0.4.0，已打的发布标签到 v0.3.0；Modern Hooks 0.7.0 已为它加了支持。和本项目相关的三点：任意语言的地图文字（`::ModernEngine.registerFont`）、任意大小的世界地图、战斗内超过 64 个势力不出错。它很新，稳定性我没有实测，**不建议第一阶段依赖它**，但值得保持兼容。
2. **中文环境的现成方案**：汉化项目 Battle-Brothers-CN 用 `data_cn.zip` + `data_font.zip` 汉化界面，大地图中文靠配套的 bb-launcher 启动器。
3. **中文 mod 先例**：Nexus 上的 Chinese Addition Weapons（0.9.0，26 件中式武器、30 多个技能）直接以简体中文构建，只依赖 MSU 1.9.0。说明"mod 文本直接写中文"这条路有人走通了。
4. **World Parameters**（Enduriel，1.1.0）：可调城镇数量、势力数量、间距的世界生成 mod，是"改势力和城镇分布"的现成参考，它的更新日志记录了这条路上的坑（见第 5 节）。
5. **目前没有门派 + 内力为核心的 BB 武侠 mod**。最接近的是 Aura Power 和 JJKCE（咒术回战题材，有独立能量资源、突破事件，只依赖 Modern Hooks + MSU），可以参考它们的资源系统做法。

### 0.4 建议的依赖清单

| 类别 | 组件 | 理由 |
| --- | --- | --- |
| 必需 | Modern Hooks（用当前的 0.7.0）、MSU ≥ 1.9.0、Nested Tooltips ≥ 0.5.3、DPF ≥ 0.5.1 | 后三个是 DPF 及其传递依赖；版本下限取 Reforged 当前的要求 |
| 第一阶段不引入 | Modular Vanilla | 原版 `skill` 的 `onBeforeDamageReceived`、`onBeforeTargetHit`、`onAnySkillUsed` 等事件已够用。等护体、破防逻辑写不下去再评估，代价是强制全 DLC |
| 第一阶段不引入 | Stack Based Skills、Dynamic Spawns、Item Tables | 招式统一用 `wx_` 前缀自己管理，敌人数量少时直接写原版刷怪表 |
| 声明冲突 | `mod_legends`、`mod_reforged` | 三者都重做 perk 树和敌人，不可能共存 |

---

## 1. 模块划分、依赖关系和实现路径

### 1.1 分层

```
内容层   门派包(每派一个目录)   奇遇事件   丹药/神兵   起源
           │                      │          │         │
系统层   秘籍/拜师   声望恩怨   炼丹锻造   世界换皮/地图
           │            │          │
框架层   武学框架(招式基类、武器层、门派层、轻功)   perk 树(DPF 接入)   敌人与刷怪
           │                                          │
基础层   内力系统 ─────────────── 核心(注册、配置、存档、文本表、调试)
外部     Modern Hooks → MSU → Nested Tooltips → DPF
```

规则：

- 下层不知道上层存在。内力系统不引用任何门派。
- 系统层模块之间不直接互相调用，只通过核心提供的两样东西通信：`::World.Flags` 里的状态，和核心里的事件表（`::Wuxia.Events.fire("onSectKilled", {...})`）。这样任何一个系统模块都能单独关掉。
- 每个模块一个 MSU 设置开关，方便分模块排查问题。

### 1.2 模块依赖表

| 编号 | 模块 | 依赖 | 首次出现的阶段 |
| --- | --- | --- | --- |
| M0 | 核心 | 外部框架 | P0 |
| M1 | 内力 | M0 | P1 |
| M2 | 武学框架（含武器层） | M0、M1 | P1 |
| M3 | perk 树 | M0、DPF | P1 |
| M4 | 门派内容包 | M1、M2、M3、M5 | P1（第一个门派） |
| M5 | 敌人与刷怪 | M1、M2 | P1 |
| M6 | 轻功 | M1、M2 | P2 |
| M7 | 秘籍与拜师 | M1、M3、M4 | P3 |
| M8 | 修炼与丹药 | M1 | P3 |
| M9 | 奇遇事件 | M0（按需读 M7、M8 的状态） | P3 |
| M10 | 门派势力与声望恩怨 | M4、M5 | P4 |
| M11 | 锻造与神兵 | M2 | P5 |
| M12 | 世界换皮与地图 | M0（L2 起依赖 M10） | P4 起 |
| M13 | 起源 | M4 | P1（一个） |
| M14 | 美术资源包 | 无（单独的 zip） | P1 |

### 1.3 各模块实现路径

#### M0 核心

- `scripts/!mods_preload/mod_wuxia.nut`：只做注册、声明依赖和冲突、排队加载（已核实的写法）：

```squirrel
::Wuxia <- { ID = "mod_wuxia", Version = "0.1.0", Name = "武侠" };
::Wuxia.HooksMod <- ::Hooks.register(::Wuxia.ID, ::Wuxia.Version, ::Wuxia.Name);
::Wuxia.HooksMod.require([
	"vanilla >= 1.5.2-3",
	"mod_msu >= 1.9.0",
	"mod_nested_tooltips >= 0.5.3",
	"mod_dynamic_perks >= 0.5.1"
]);
::Wuxia.HooksMod.conflictWith(["mod_legends", "mod_reforged"]);

::Wuxia.HooksMod.queue(">mod_msu", ">mod_nested_tooltips", ">mod_dynamic_perks", function() {
	::Wuxia.Mod <- ::MSU.Class.Mod(::Wuxia.ID, ::Wuxia.Version, ::Wuxia.Name);
	::include("mod_wuxia/load.nut");	// 配置、perk 定义、所有 hook
});

::Wuxia.HooksMod.queue(">mod_dynamic_perks", function() {
	::include("mod_wuxia/register_perk_groups.nut");	// perk 组和集合
}, ::Hooks.QueueBucket.AfterHooks);
```

- 时序要点（已核实）：perk 定义要在普通阶段用 `::DynamicPerks.Perks.addPerks([...])` 加入，因为 DPF 在 VeryLate 阶段给所有 perk 定义初始化 `PerkGroupIDs`；perk 组和集合在 AfterHooks 阶段注册。Reforged 就是这个顺序。
- 目录约定（照 Reforged）：`mod_wuxia/hooks/` 镜像原版路径放 hook；`scripts/` 放新类；`ui/mods/mod_wuxia/` 放 JS 和 CSS；`unpacked_brushes/` 放待打包的 sprite；`gfx/` 放界面图片。
- 命名：所有 ID 和文件加 `wx_` 前缀（`actives.wx_*`、`perk.wx_*`、`effects.wx_*`、`pg.wx_*`、`pgc.wx_*`），加到原版类上的字段和函数加 `WX_` 前缀。
- 用到的 MSU 能力（已核实）：模组设置界面、更新检查、`Serialization.isSavedVersionAtLeast`（存档版本迁移）、`flagSerialize`（把表存进 flags）、自定义提示、`::MSU.Skills.addEvent`（给所有技能加新事件）。
- 文本：所有玩家可见的字符串集中到 `mod_wuxia/text/zh.nut`，代码里只引用键。以后要出英文版只需加一张表。
- 风险：低。唯一要注意的是游戏内是 Squirrel 3.0，界面 JS 按文档说只支持到 ES3，让 AI 写代码时要在提示里写明。BBBuilder 的 `-transpile` 可以把新语法转成 ES3。

#### M1 内力

设计见第 2 节。实现涉及：

| 位置 | 做什么 | 把握 |
| --- | --- | --- |
| `::Const.CharacterProperties` | 用 `::MSU.Table.merge` 加 `WX_QiMax`、`WX_QiMaxMult`、`WX_QiRegen`、`WX_QiCostMult`、`WX_QiStartPct`。Reforged 加 `Reach` 用的是同一写法 | 已核实 |
| 新技能 `special.wx_neigong` | 挂在每个有内力的角色上，保存当前内力、主修心法、层数、修炼度；用技能自带的 `onSerialize` / `onDeserialize` 存档；在 `onTurnStart`、`onCombatStarted` 里回气 | 已核实技能可以写自定义存档数据（DPF 自己就这么做） |
| hook `scripts/skills/skill` | 加 `m.WX_QiCost`；包装 `isAffordable`、`isAffordablePreview`、`getCostString`、`use` | 已核实这四个函数存在且签名如下文 |
| hook `scripts/ui/global/data_helper` 的 `addStatsToUIData` | 给角色界面传 `wx_qi`、`wx_qiMax` | 已核实 |
| hook `scripts/ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar` 的 `convertEntityToUIData` | 给战斗界面传内力数据 | 已核实 |
| JS：`CharacterScreenStatsModule`、`TacticalScreenTurnSequenceBarModule` | 画内力条 | 已核实 Reforged 改的就是这两个类的 `createDIV`、`setProgressbarValues` |
| hook `scripts/entity/tactical/actor` 的 `getTooltip` | 敌人提示里加一行内力进度条 | 已核实 Reforged 在此处改进度条 |

风险：中。集中在界面（多一条状态条的布局）和 MSU 的"消耗预览"功能（鼠标悬停时预览 AP 和疲劳）。第一版不做内力预览，只保证不报错。

#### M2 武学框架

- 招式基类 `scripts/skills/wuxia/wx_move.nut`，继承 `scripts/skills/skill`，统一处理：内力消耗、兵器类型要求、所属门派、所需心法层数、不满足条件时隐藏或置灰。
- **武器层不改任何原版武器脚本。** 基础招式由 perk 授予：perk 监听 MSU 的 `onEquip(_item)` / `onUnequip(_item)` 事件（已核实），当主手武器是对应类型时把招式加进技能栏，换掉武器就移除。武器类型用 MSU 的 `::Const.Items.WeaponType` 和 `weapon.isWeaponType()` 判断（已核实），所以对原版和其他 mod 的武器自动生效。
- 原版武器自带的技能（Slash、Thrust 等）保留，当作"不入流的招式"。
- 需要新的兵器类别（如"刀"独立于原版的砍刀类）时，用 `::Const.Items.addNewWeaponType("Saber", "刀")` 注册，再给相应的原版武器补类型标记（已核实有此接口）。
- 伤害相关的心法效果（护体、破防、气劲加成）写在技能事件里：`onAnySkillUsed(_skill, _targetEntity, _properties)`、`onBeforeTargetHit(_skill, _targetEntity, _hitInfo)`、`onBeforeDamageReceived(_attacker, _skill, _hitInfo, _properties)`、`onDamageReceived(...)`（已核实签名）。
- 敌人 AI：单体攻击类招式把技能 ID 推进原版行为的列表即可，Reforged 的写法是 `q.m.PossibleSkills.push("actives.rf_xxx")`（已核实），对应的原版行为有 `ai_attack_default`、`ai_attack_swing`、`ai_attack_split`、`ai_defend_riposte`、`ai_charge` 等（已核实文件存在）。原版没有对应行为的招式（多段位移、调息）要新写 `scripts/ai/tactical/behaviors/ai_wx_*.nut`，并通过 MSU 的 `skill.m.AIBehaviorID` 自动挂到拥有该技能的单位上（已核实）。
- 难点：AI 行为的评分函数。写得不好敌人会乱用或不用招式。每个新行为都从最接近的原版行为复制后改。
- 风险：中。工作量主要在招式数量 × AI 适配。

#### M3 perk 树

设计见第 3 节。实现：

- `scripts/mods/mod_wuxia/perk_groups/pg_wx_*.nut`，继承 `::DynamicPerks.Class.PerkGroup`。
- `scripts/mods/mod_wuxia/perk_group_collections/pgc_wx_*.nut`，继承 `::DynamicPerks.Class.PerkGroupCollection`。
- hook `scripts/skills/backgrounds/character_background`，把默认的 `createPerkTreeBlueprint()` 改成动态树；每个背景再覆盖自己的蓝图、`getPerkGroupCollectionMin`、`getPerkGroupMultiplier`。
- 原版 perk 不删，重新分配到我们的组里。
- 风险：中。DPF 是 0.x，升级可能要跟着改；文档少。把对 DPF 的调用收拢到 `mod_wuxia/dpf_adapter.nut` 一个文件里。

#### M4 门派内容包

每个门派一个目录，包含：心法数据、心法 perk 组、若干独门武学 perk 组、招式、背景、敌人单位、掉落、事件。第一个门派的完整内容见第 4 节。加新门派只新增文件，不改框架代码，这是验收框架是否合格的标准。

#### M5 敌人与刷怪

- 单位脚本放 `scripts/entity/tactical/enemies/wx_*.nut`，继承 `scripts/entity/tactical/human`。
- 新增实体类型照 Reforged 的 `::Reforged.Entities.addEntity`（已核实）：取 `::Const.EntityType` 里最大的 ID 加一，同步插入 `::Const.Strings.EntityName`、`EntityNamePlural`、`::Const.EntityIcon`，登记默认势力，并写 `::Const.World.Spawn.Troops`（字段：`ID`、`Variant`、`Strength`、`Cost`、`Row`、`Script`，已核实）和 `::Const.Tactical.Actor`（属性模板）。
- **新 ID 只往末尾追加**，不插到中间，避免动到存档里已有的数字。
- 刷怪：第一阶段把新单位加进强盗势力的队伍模板（`scripts/config/spawnlist_bandits.nut`，队伍条目里是 `Troops = [{ Type, Num }]`，已核实）。门派成为独立势力后（M10）再建自己的刷怪表。
- 风险：中。数值平衡（会武功的敌人在第几天出现、多强）需要大量试玩。

#### M6 轻功

- 位移类主动技能：原版 Footwork（步法）用的是 `this.Tactical.getNavigator().teleport(_user, _targetTile, null, null, false)`（已核实），纵跃、穿人、追击都基于它。
- 被动：原版 Pathfinder（寻路者）perk 是改 `actor.m.ActionPointCosts`、`FatigueCosts`、`LevelActionPointCost`（已核实），轻功的地形减耗同理。
- AI：参考 `ai_charge`、`ai_darkflight`、`ai_defend_rotation` 新写。
- 风险：中高。位移技能最容易出 bug（跳到非法格子、绕过控制区后的借机攻击、动画回调）。放 P2，不进最小核心。

#### M7 秘籍与拜师

- 秘籍是可使用的物品，`onUse(_actor, _item = null)`（已核实签名）。使用时检查条件，然后调用 `_actor.getPerkTree().addPerkGroup("pg.wx_xxx")`（已核实 DPF 支持运行时给单个角色的树加组，且树按角色存档）。
- 拜师第一版用事件实现：进入门派据点触发事件，选一名弟子，满足声望和资质条件后设置主修心法并加门派组。第二版再做城镇建筑和专门的对话框（参考原版 `training_hall_building` 和 `town_training_dialog_module`，已核实文件存在）。
- 约束：DPF 每行最多 13 个 perk，超出会被挤到相邻行（已核实），所以每人可学的门派组数量要设上限（见第 3 节）。
- 风险：低到中。

#### M8 修炼与丹药

- 修炼度写在 `special.wx_neigong` 里，来源：战斗中消耗内力、营地打坐事件、丹药、奇遇。
- 丹药是消耗品物品 + 效果技能。配方复用原版工艺蓝图：新文件放 `scripts/crafting/blueprints/wx_*.nut` 即可出现在制皮匠界面（Reforged 这么加药水，已核实）。**前提是玩家有"野兽与探索"DLC**（已核实）。
- 专门的"丹房"建筑和界面放到后面做，或者不要求该 DLC 时自己写一套简单的配方事件。
- 风险：低。

#### M9 奇遇事件

- 事件文件放 `scripts/events/events/wx/*.nut`，原版 `event_manager` 会枚举 `scripts/events/events/` 目录自动加载（已核实）。
- 事件链的进度存 `::World.Flags`。
- 风险：低。工作量在文本量，这部分最适合交给 AI 批量写再人工筛。

#### M10 门派势力与声望恩怨

- 大门派做成真正的势力：新类继承 `scripts/factions/faction`，在 `faction_manager.createFactions()` 的 hook 里创建（已核实该函数的调用链，Legends 在 `createAlliances` 之前插入自己的势力）。这样原版的关系界面、`PlayerRelation` 数值、契约发布机制都能复用。
- 小恩怨（杀了某派弟子、偷学武功）记在 `::World.Flags`，由势力行动（`scripts/factions/actions/`）定期检查并派出寻仇队伍。
- 击杀上报：每个门派敌人的 `onDeath` 里调用核心事件，声望模块订阅。
- **硬限制（已核实）**：原版引擎战斗内势力 ID 到 64 及以上会破坏控制区和视野。原版每个城镇各占一个势力，再加贵族、城邦、各类敌人，已经用掉不少。门派势力总数要控制，并在世界生成后打日志检查最大 ID（World Parameters 就是这么做的）。
- 风险：高。原版契约和事件里有很多对势力类型的假设。放 P4。

#### M11 锻造与神兵

- 神兵用原版命名武器体系（`scripts/items/weapons/named/`）。
- 重铸做成铁匠铺事件或对话框。Chinese Addition Weapons 有"武器组装和可选方向重铸"，可以参考它的交互。
- 风险：低到中。放 P5。

#### M12 世界换皮与地图

见第 5 节。

#### M13 起源

- 文件放 `scripts/scenarios/world/wx_*.nut`，原版自动枚举（已核实 Reforged 这么加起源）。
- 第一阶段做一个："镖局"或"落魄门派"开局，保证开局就有会武功的弟子。

#### M14 美术资源包

- 学 Reforged 拆成代码包和资源包两个 zip，BBBuilder 的 `-excludedfolders` / `-includedfolders` 支持这么打包（已核实）。
- 流程见第 6 节。

### 1.4 中文文本方案（跨模块的基础决定）

事实：

- 界面（HTML）里的中文：汉化包和 Chinese Addition Weapons 都证明可行。未装汉化字体包时是否能靠系统字体显示，**未核实**，P0 要测。
- 大地图上的中文：纯原版引擎不行（已核实）；bb-launcher 或 Modern Engine 可以。

建议：

1. 以"汉化包 + bb-launcher"为基准环境。目标玩家本来就在用，而且原版文本也是中文，风格统一。
2. 城镇、队伍、区域的名字表同时维护中文和拼音两列。加一个 MSU 设置"地图名称使用拼音"，给不用启动器的玩家兜底。
3. 检测到 Modern Engine 时调用 `::ModernEngine.registerFont(...)` 注册一款衬线中文字体，代码量很小。

---

## 2. 内力系统设计

### 2.1 定位

BB 原有两个战斗资源：行动点限制一回合能做多少事，疲劳限制一场战斗能打多久。内力是第三个，限制**爆发**：强力招式要花内力，内力回得慢，所以每场战斗只能放有限次数的大招。

三条原则：

- 没学内功的人没有内力条，玩法和原版一样。
- 基础招式不耗内力。只有门派武学和绝学耗。
- 内力招式的疲劳消耗比同档原版技能低，否则两个资源只是互相叠加。

### 2.2 数据

内力不进 perk 系统。每个有内力的角色挂一个 `special.wx_neigong` 技能，保存：

| 字段 | 含义 | 是否存档 |
| --- | --- | --- |
| `Qi` | 当前内力 | 否（战斗内） |
| `QiMaxBonus` | 永久加成（丹药、奇遇） | 是 |
| `XinfaID` | 主修心法 | 是 |
| `XinfaLevel` | 主修心法层数，1–5 | 是 |
| `XinfaExp` | 修炼度 | 是 |
| `Learned` | 学过的其他心法及层数 | 是 |

实际上限和回复在每次属性刷新时算出来，走 BB 自己的属性管线，这样 perk、状态、装备、伤病都能用 `onUpdate(_properties)` 改它：

```
内力上限 = (心法层数对应的基础上限 + QiMaxBonus + WX_QiMax) × WX_QiMaxMult
每回合回复 = 心法层数对应的回复 + WX_QiRegen
招式实际消耗 = 招式基础消耗 × WX_QiCostMult
```

### 2.3 数值基线

量级和疲劳对齐（疲劳上限约 90–130，技能消耗 10–30），玩家不用重新建立数感。

| 项目 | 数值 |
| --- | --- |
| 上限 | 入门 30，每层 +15 到 +20，5 层 100。丹药和奇遇永久加成合计封顶 +50 |
| 战斗开始时 | 上限的 50%，心法和 perk 可改 |
| 每回合回复 | 6–10，随心法层数 |
| 调息（所有内功者都有的主动技能） | 4 行动点、0 疲劳、0 内力，回复上限的 25%，到下回合开始前近战防御 −10 |
| 基础招式消耗 | 0 |
| 门派招式消耗 | 5–15 |
| 绝学消耗 | 20–35 |

按这组数字，3 层心法（上限 60）的角色开场 30 内力，每回合回 8，前三回合能放 2–3 次门派招式，之后要靠调息或心法的回气特性。

### 2.4 心法决定差异

心法是数据对象（`::Wuxia.Xinfa.<id>`），每一层给定上限、回复和一个特性。门派之间的差异主要靠回气方式拉开：

| 路数 | 回气方式 | 打法 |
| --- | --- | --- |
| 阳刚 | 命中敌人回气 | 抢攻 |
| 阴柔 | 敌人对自己的攻击落空时回气 | 闪避反击 |
| 中正 | 回合回复高，开场比例高 | 稳定 |
| 邪功 | 击杀大量回气，或用生命换内力 | 滚雪球，高风险 |

通用特性候选（由心法层数或 perk 解锁，不必都做）：

- 护体：受到生命伤害时用内力抵消一部分，每点内力抵 2 点伤害，单次最多抵 30%。在 `onBeforeDamageReceived` 里降低 `_properties.DamageReceivedRegularMult`，在 `onDamageReceived` 里扣内力。
- 气劲：招式伤害按当前内力比例加成。
- 内伤：被内力招式重创后获得"内息紊乱"状态，若干回合不回气。

### 2.5 成长：修炼度

- 每消耗 1 点内力得 1 点修炼度，每场战斗上限 60，防止刷。
- 其他来源：营地打坐事件、丹药、奇遇、师父指点。
- 修炼度够了自动升层。5 层的累计门槛建议 0 / 150 / 400 / 900 / 1800。
- 同时只能主修一门心法。改修时旧心法层数保留在 `Learned` 里，但只有主修的生效。是否允许多门内功并存、是否有正邪冲突，见第 8 节。

### 2.6 招式消耗的接入

统一在 `skill` 基类上做，任何技能只要设置 `WX_QiCost` 就自动生效：

```squirrel
::Wuxia.HooksMod.hook("scripts/skills/skill", function(q) {
	q.m.WX_QiCost <- 0;

	q.WX_getQiCost <- function()
	{
		if (this.m.WX_QiCost == 0) return 0;
		local p = this.getContainer().getActor().getCurrentProperties();
		return ::Math.max(1, ::Math.floor(this.m.WX_QiCost * p.WX_QiCostMult));
	}

	q.isAffordable = @(__original) function()
	{
		return __original() && ::Wuxia.Qi.get(this.getContainer().getActor()) >= this.WX_getQiCost();
	}

	q.use = @(__original) function( _targetTile, _forFree = false )
	{
		// 有的技能会在使用中移除自己，先把角色和消耗取出来
		local actor = this.getContainer().getActor();
		local cost = this.WX_getQiCost();
		local ret = __original(_targetTile, _forFree);
		if (ret && !_forFree && cost > 0) ::Wuxia.Qi.spend(actor, cost);
		return ret;
	}
});
```

`isAffordablePreview` 同样包装，`getCostString` 在原串后面追加"并消耗 N 内力"。敌人 AI 选技能时本来就会检查 `isUsable()` 和 `isAffordable()`，所以内力不足的招式 AI 自动不用。

### 2.7 界面

| 位置 | 方案 |
| --- | --- |
| 技能提示 | 消耗一行追加内力，不足时红字 |
| 角色界面属性面板 | 加一行内力（当前 / 上限），旁边显示心法名和层数 |
| 战斗界面左下角状态条 | 两个方案，见下 |
| 敌人提示 | 在生命、护甲、疲劳进度条后加一条内力 |
| 战斗日志 | 调息、内力耗尽、护体触发各一条 |

战斗界面状态条的两个方案：

- **方案 A：用内力条替换士气条。** Reforged 对"攻击距离"就是这么做的（已核实），代码量小，布局不动。代价是士气只能从单位头上的图标和提示里看。
- **方案 B：新增第七条。** 要改这个面板的 CSS 布局，工作量较大，而且以后原版更新界面时容易坏。

建议第一阶段用方案 A，且只对有内力的角色替换，没有内力的角色照旧显示士气。这需要在每次刷新数据时切换图标和样式，比 Reforged 的一次性替换多一点工作。方案 B 留到界面打磨阶段。这一点需要你确认（第 8 节）。

### 2.8 风险

- 存档：内力状态靠技能自己存档，技能类名一旦发布就不能改。
- 平衡：内力招式如果只是"更强的攻击"，会让所有人都必须学内功。靠 2.1 的三条原则和修炼度的时间成本来约束。
- MSU 消耗预览不包含内力，第一版接受。

---

## 3. perk 组划分方案

### 3.1 DPF 提供的积木（已核实）

| 概念 | 作用 |
| --- | --- |
| perk 组（PerkGroup） | 一组相关 perk，按 7 层排好。有名字和图标，会显示在角色界面 |
| 组集合（PerkGroupCollection） | 一类组的列表，带"每个角色至少抽几个"和抽取顺序 |
| 背景蓝图 | 背景的 `createPerkTreeBlueprint()` 返回 `DynamicMap`：每个集合里强制给哪些组，其余按权重随机补到最小数量 |
| 权重 | 背景、特质、装备、已有的组都可以通过 `getPerkGroupMultiplier(组ID, 树)` 调整某个组被抽中的权重；返回 0 表示不可能，返回 −1 表示必得 |
| 特殊组（SpecialPerkGroup） | 按百分比概率额外出现的组，适合做"天赋异禀" |
| 前置条件 | perk 定义里可以写 `verifyPrerequisites(_player, _tooltip)`，不满足时锁定并显示原因 |
| 运行时修改 | `getPerkTree().addPerkGroup(id)` / `removePerkGroup(id)`，树按角色存档 |
| 限制 | 每行最多 13 个 perk；解锁规则同原版（已花点数 + 1 = 可用层数） |

### 3.2 集合划分

| 集合 | 中文名 | 默认最少抽取 | 包含的组 |
| --- | --- | --- | --- |
| `pgc.wx_common` | 通用 | 1 | 一个固定组，人人都有（学徒、恢复等原版通用 perk） |
| `pgc.wx_weapon` | 外功·兵器 | 3 | 剑、刀、枪、棍、拳掌、短兵、长兵、重兵（斧锤）、软兵（连枷鞭）、暗器、弓弩 |
| `pgc.wx_body` | 外功·体魄 | 2 | 硬功、膂力、灵巧、坚忍、搏命（原版的体质、闪避、九命等分到这里） |
| `pgc.wx_internal` | 内功 | 0 或 1 | 阳刚、阴柔、中正、邪功四个通用内功组 |
| `pgc.wx_qinggong` | 轻功 | 0 或 1 | 提纵、迅捷、闪转 |
| `pgc.wx_sect` | 门派 | 0 | 每个门派一个心法组 + 若干独门武学组。不随机抽，只由背景强制或后天学到 |
| 特殊组 | 天赋 | 按概率 | 武学奇才、经脉异禀、天生神力等 |

兵器组对应 MSU 的武器类型（已核实类型表：Axe、Bow、Cleaver、Crossbow、Dagger、Firearm、Flail、Hammer、Mace、Polearm、Sling、Spear、Sword、Staff、Throwing、Musical）：剑=Sword，枪=Spear，棍=Staff + Mace，短兵=Dagger，长兵=Polearm，重兵=Axe / Hammer，软兵=Flail，暗器=Throwing，弓弩=Bow / Crossbow，拳掌=空手。原版的 Staff 类武器很少，棍组要等新增武器后才完整。"刀"第一阶段先对应 Cleaver，之后再用 MSU 注册独立的刀类型，把弯刀类归过来。

### 3.3 三层怎么叠成一棵树

```
一个角色的树 = 通用组
             + 兵器组 × 3（外功，基础招式，不耗内力）
             + 体魄组 × 2（外功，被动）
             + 内功组 × 0–1（通用内功被动）
             + 轻功组 × 0–1
             + 门派心法组 × 0–1  ┐
             + 门派武学组 × 0–2  ┘ 只来自背景或拜师、秘籍
             + 特殊组（小概率）
```

**门派和武器的组合规则：**

1. 每个门派有一个心法组（不绑兵器）和 1–3 个独门武学组，每个武学组绑定一种兵器类型。例如某派有"某某剑法（剑）"和"某某掌（拳掌）"。
2. 门派弟子背景的蓝图：强制心法组，从本派武学组里按权重选一个，并**强制对应的兵器组**。这保证弟子的基础招式和独门武学是同一种兵器。
3. 独门武学 perk 的前置条件：主修心法是本派心法，且层数达到要求。这样 perk 点买到的是"招式"，而招式的门槛是修炼出来的内功，两个系统各管各的。
4. 独门招式在没拿对应兵器时不出现在技能栏。
5. 背景通过权重排除不合理的组合，例如佛门弟子的邪功权重为 0。

**非门派背景**（镖师、捕快、猎户、乞丐、书生、山贼等）：没有门派组，内功集合最少抽取为 0 且权重低。他们靠兵器组和体魄组打架，之后可以通过拜师或秘籍获得门派组。

**后天学习的上限**（建议值）：每人最多一个主修门派（心法组 + 一个武学组），另外最多再学两个武学组（偷学或秘籍），且外来武学的心法前置减半但招式威力打折。上限的目的一是平衡，二是控制每行不超过 13 个。

### 3.4 树的规模估算

| 来源 | 组数 | 每组 perk 数 | 小计 |
| --- | --- | --- | --- |
| 通用 | 1 | 4 | 4 |
| 兵器 | 3 | 5 | 15 |
| 体魄 | 2 | 5 | 10 |
| 内功 | 1 | 5 | 5 |
| 轻功 | 1 | 4 | 4 |
| 门派心法 | 1 | 4 | 4 |
| 门派武学 | 1 | 6 | 6 |
| 合计 | | | 约 48 |

48 个 perk 分 7 行，平均每行 7 个，离 13 的上限有余量。原版角色到 11 级有 10 个 perk 点，所以每个角色只能点其中约五分之一，build 之间的差异足够。

### 3.5 代码形态（已核实的写法）

perk 组：

```squirrel
// scripts/mods/mod_wuxia/perk_groups/pg_wx_sword.nut
this.pg_wx_sword <- ::inherit(::DynamicPerks.Class.PerkGroup, {
	m = {},
	function create()
	{
		this.m.ID = "pg.wx_sword";
		this.m.Name = "剑";
		this.m.Icon = "ui/perk_groups/wx_sword.png";
		this.m.Tree = [
			["perk.wx_sword_basics"],
			["perk.wx_sword_parry"],
			["perk.wx_sword_chain"],
			["perk.mastery.sword"],		// 原版剑术精通
			["perk.wx_sword_step"],
			[],
			["perk.wx_sword_intent"]
		];
	}
});
```

门派弟子背景的蓝图：

```squirrel
function createPerkTreeBlueprint()
{
	return ::new(::DynamicPerks.Class.PerkTree).init({
		DynamicMap = {
			"pgc.wx_sect": ["pg.wx_huashan_xinfa", "pg.wx_huashan_sword"],
			"pgc.wx_weapon": ["pg.wx_sword"],	// 其余两个兵器组随机补足
			"pgc.wx_internal": ["pg.wx_qi_neutral"]
		}
	});
}

function getPerkGroupMultiplier( _groupID, _perkTree )
{
	switch (_groupID)
	{
		case "pg.wx_qi_evil": return 0;		// 不会抽到邪功
		case "pg.wx_agile": return 2;		// 更容易抽到灵巧
	}
}
```

没在 `DynamicMap` 里写的集合，会按该集合的最小数量随机抽。要让某个背景完全不抽某集合，让 `getPerkGroupCollectionMin` 对它返回 0。

### 3.6 风险

- DPF 的招募界面不显示 perk 组（那是 Reforged 自己加的功能）。玩家招人前看不到树，需要的话后面自己加。
- 原版 perk 的中文名来自玩家装的汉化包，我们新 perk 的术语要和汉化包用词对齐。

---

## 4. 第一个门派完整示例：华山派（占位名）

选纯剑门派做第一个，因为原版剑类武器最全、图标和 sprite 可以全部复用，能把精力放在验证框架上。门派名和招式名都是占位，招式名为原创，避开了小说里的专有名称（命名策略见第 8 节）。

### 4.1 心法：朝阳功

路数：中正偏阳。定位：稳定回气，靠出剑维持内力。

| 层 | 累计修炼度 | 内力上限 | 每回合回复 | 该层获得 |
| --- | --- | --- | --- | --- |
| 1 | 0 | 30 | 6 | 主动技能"调息" |
| 2 | 150 | 45 | 7 | 剑气相生：剑类招式命中后回复 3 内力，每回合最多 2 次 |
| 3 | 400 | 60 | 8 | 气贯剑身：剑类招式伤害 +（当前内力 ÷ 上限 × 10%） |
| 4 | 900 | 80 | 9 | — |
| 5 | 1800 | 100 | 10 | 朝阳护体：回合开始时内力不低于一半则本回合近战防御 +5 |

战斗开始时内力为上限的 50%。

### 4.2 招式表

**武器层：剑·基础**（`pg.wx_sword`，任何抽到剑组的人都能学，不耗内力）

| 层 | perk | 授予 | 行动点 | 疲劳 | 内力 | 效果 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 剑法入门 | 点刺 | 4 | 12 | 0 | 单体，命中 +10%，伤害 85%，额外无视 10% 护甲 |
| 2 | 格挡 | 拨挡 | 3 | 15 | 0 | 到下回合开始前近战防御 +10；这期间对自己近战攻击落空的敌人"失衡"一回合（近战防御 −10） |
| 3 | 连环 | 连环剑 | 6 | 20 | 0 | 对同一目标攻击两次，第二次命中 −15% |
| 4 | 剑术精通 | — | — | — | — | 原版 perk，原样使用 |
| 5 | 游身 | 回身剑 | 4 | 15 | 0 | 攻击后可免费移动一格且不触发借机攻击 |
| 7 | 剑意 | — | — | — | — | 被动：持剑击杀后，下一次剑类招式行动点 −1 |

**门派层：华山心法组**（`pg.wx_huashan_xinfa`，前置：主修朝阳功）

| 层 | perk | 效果 |
| --- | --- | --- |
| 1 | 吐纳 | 调息的回复量 +50% |
| 3 | 养气 | 战斗开始时内力比例 +20% |
| 5 | 气贯周天 | 内力上限 +20，每回合回复 +3 |
| 6 | 返照 | 每场战斗一次：生命首次降到 30% 以下时，回复 40% 内力并解除眩晕 |

**门派层：华山剑法**（`pg.wx_huashan_sword`，前置：持剑、主修朝阳功且达到指定层数）

| 层 | perk / 招式 | 心法要求 | 行动点 | 疲劳 | 内力 | 效果 |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 云起 | 1 层 | 4 | 10 | 6 | 单体，命中 +15%；命中则目标"破绽"一回合（下次受击伤害 +15%） |
| 3 | 回峰 | 2 层 | 3 | 10 | 8 | 架势：到下回合开始前，敌人近战攻击落空时自动反击，每次反击再耗 4 内力，内力不足即停 |
| 4 | 松涛 | 2 层 | 5 | 15 | 10 | 横扫面前三格，每个目标伤害 70%，命中的敌人近战命中 −10 一回合 |
| 5 | 以气驭剑 | 3 层 | — | — | — | 被动：剑类招式穿甲 +10%；内力不低于一半时再 +10% |
| 6 | 苍龙入海 | 4 层 | 6 | 20 | 15 | 直线突进最多两格并攻击，伤害 +25%；击杀则返还 5 内力 |
| 7 | 天外飞霞（绝学） | 5 层 | 9 | 30 | 35 | 对两格内最多三个不同目标各攻击一次，每次伤害 +20%；使用后"气竭"，下回合不回内力 |

对照原版：单手剑的 Slash（劈砍）是 4 行动点、10 疲劳的单体攻击（凭记忆，以反编译脚本为准）。"云起"在同样的行动点和疲劳下多了命中和破绽，代价是 6 内力，这就是内力招式的定价方式。

### 4.3 背景

| 背景 | 来源 | 特点 | 树 |
| --- | --- | --- | --- |
| 华山弟子 | 门派据点、少数大城 | 近战技能和主动值偏高，生命偏低；自带朝阳功 1 层；装备布衣和短剑；雇佣费高 | 强制：华山心法组、华山剑法、剑组、中正内功组 |
| 华山弃徒 | 普通城镇 | 属性略低，带一个负面特质；自带朝阳功 1 层；便宜 | 强制：华山心法组、剑组；华山剑法 50% 概率；邪功权重不为 0 |

装备全部用原版物品（亚麻衣、短剑、武装剑），第一阶段不需要画新装备。

### 4.4 敌人配置思路

目标是让玩家在第一阶段就能和"会武功的人"交手，同时不新建势力。做法是把本派的反面人物挂到原版强盗势力下。

| 单位 | 定位 | 属性模板 | 装备 | 心法 | 招式和 perk | AI |
| --- | --- | --- | --- | --- | --- | --- |
| 华山弃徒 | 杂兵 | 以原版强盗劫掠者为底，近战技能 +5，生命 −5 | 短剑或武装剑，皮甲 | 1 层（内力 30） | 点刺、云起 | `bandit_melee_agent`；两个招式推入 `ai_attack_default` |
| 华山剑客 | 精英 | 以原版雇佣兵为底，近战防御 +5 | 贵族剑，轻甲 | 3 层（60） | 点刺、连环剑、云起、回峰、松涛；闪避、剑术精通 | 同上；回峰接到 `ai_defend_riposte`，松涛接到 `ai_attack_swing`（这两个行为是否有 `PossibleSkills` 列表未核实，没有就复制一份改） |
| 华山叛逆（首领） | 小头目 | 以原版剑术大师为底，生命 +20 | 命名剑概率，轻甲 | 4 层（80） | 以上全部 + 苍龙入海、以气驭剑 | 苍龙入海参考 `ai_charge` 新写一个行为 |
| 剑魔（唯一头目） | 据点首领 | 首领级，独立数值 | 固定神兵 | 5 层（100） | 全套 + 天外飞霞 | 天外飞霞新写行为：周围两格内敌人不少于 2 个且内力够时使用 |

所有单位都新写一个共用的调息行为：内力不够放最便宜的招式、且身边没有敌人时使用。

**刷怪：**

- 在强盗的队伍模板里加三档新队伍："弃徒帮"（3–6 弃徒）、"剑客团"（弃徒 + 1–2 剑客）、"叛逆亲卫"（剑客 + 首领）。每个兵种的 `Cost` 比同属性的原版单位高 20%–30%，因为招式带来额外强度，这样它们自然出现得更晚。
- 加一个唯一据点"废弃道观"，驻守剑魔，作为第一阶段的终点目标。

**掉落：**

- 剑客和首领小概率掉"朝阳功残页"，集齐若干可合成秘籍。这是给 M7 留的接口，第一阶段只掉落不可用也行。
- 剑魔必掉一把命名剑。

**这个示例验证了什么：** 内力数据和界面、招式基类、武器层授予机制、心法前置、背景蓝图、新实体类型、AI 接入、刷怪表、掉落。全部走通后，加第二个门派就只是照着填表。

---

## 5. 地图改造的可行性分级

原版世界生成的入口和流程（已核实）：`world_state.startNewCampaign()` 取 `world.worldmap_generator`，按最小尺寸调整场景，然后 `fill()` 依次执行：

```
buildLandAndSea → isWorldAcceptable（不合格重来）→ buildElevation → defragmentTerrain
→ removeStraits → refineTerrain → buildSettlements → buildRoads → refineSettlements
→ guaranteeAllBuildingsInSettlements → buildAdditionalRoads → buildRoadSprites
→ buildLabels → buildAbandonedFortresses（有沙漠 DLC 时）
```

之后 `faction_manager.createFactions()` 依次创建：通用敌人、竞技场、城镇（每个城镇一个势力）、城邦并分配城镇、贵族家族并分配城镇、强盗、野蛮人、游牧民、兽人、地精、亡灵、僵尸、同盟关系。

### 5.1 三个级别

| 级别 | 内容 | 要动的地方 | 工作量 | 风险 |
| --- | --- | --- | --- | --- |
| **L1 换皮** | 名字、贴图、音乐。逻辑不动 | 见 5.2 | 文本：小。贴图：中到大，取决于换多少 | 低 |
| **L2 改势力和城镇分布** | 城镇数量和类型、新据点类型（门派山门）、贵族家族换成门派或官府、势力数量 | 见 5.3 | 中 | 中 |
| **L3 改世界生成** | 地形分布、固定的大区布局、固定地图、更大的地图 | 见 5.4 | 大 | 高 |

### 5.2 L1 换皮

| 项目 | 位置 | 备注 |
| --- | --- | --- |
| 城镇名 | 每个城镇类型脚本里的 `getRandomName([...])` 列表（约 50 个脚本，已核实） | 每类城镇的名字数量要足够，名字用尽会让世界生成卡死（World Parameters 修过这个问题） |
| 区域名、据点名 | `scripts/config/world_location_names.nut` | 已核实文件存在 |
| 贵族家族名 | `::Const.Strings.NobleHouseNames` | 已核实 |
| 人名 | `scripts/config/character_names.nut` | 已核实文件存在 |
| 地图上显示中文 | — | 受位图字体限制，见 1.4 |
| 大地图地形贴图 | `gfx/world_tiles.png`、`world_detail*.png`、`world_decals.png` 及对应 brush | 文件名已核实。六边形地块要无缝衔接，是美术里最难的一类 |
| 城镇和队伍的大地图形象 | `gfx/world_settlement.png`、`world_entity_0.png` | 文件名已核实 |
| 城镇界面背景、建筑图 | `gfx/ui/` 下的分层图片 | 具体路径未核实 |
| 旗帜 | `gfx/ui/banners/`，250×401 | 尺寸取自 Reforged |

覆盖原版 sprite 的方式有两种：在自己的 brush 里定义同名 sprite，或者整张替换原版的图集文件。前者是否稳定覆盖**未核实**，P0 时测；后者一定可行，但和其他换图 mod 冲突。

建议顺序：先换名字和旗帜（便宜、效果明显），再换城镇形象，地形贴图最后做或只做调色。

### 5.3 L2 改势力和城镇分布

可改的点：

- `::Const.World.Settlements.Master`：每类城镇的数量和候选列表（已核实，Legends 整个替换了它）。
- 每种城镇类型的 `isSuitable(_terrain)`：决定它能出现在什么地形。
- 新城镇类型：继承 `scripts/entity/world/settlement`。门派山门可以做成一种特殊城镇（能进去、有建筑、能接任务），也可以做成附属据点。
- `createNobleHouses` / `assignSettlementsToNobleHouses`、`createCityStates`：把贵族和城邦替换或改名成官府、世家、门派。

已知的坑（来自 World Parameters 的更新日志和 Modern Engine 文档，已核实）：

- 势力 ID 达到 64 会破坏战斗内的控制区。每多一个村子或家族都会抬高最大 ID。
- 某类城镇名字用尽，世界生成不结束。
- 城镇间距设得太大或强制沿海，开局卡在读条。要做"生成失败就回主菜单并提示"的兜底。
- 旧版 MSU 在城镇或家族增多时会让大地图上的自动战斗出错，要求 MSU ≥ 1.8.0。
- 改了数量后，同一种子要能生成同一张图，否则没法复现 bug。

另一类风险是原版内容里的地理假设。例如 `world_state` 里用"玩家纵坐标小于地图高度的 20%"来判断是否在南方（已核实）；很多契约假设至少有两个贵族家族、有三个城邦。动势力结构前要把这些假设列出来逐个处理。

### 5.4 L3 改世界生成

分四种目标，难度递增：

| 目标 | 做法 | 评价 |
| --- | --- | --- |
| (a) 调参数 | 陆海比例、各地形占比、城镇密度 | 风险低，可以和 L2 一起做 |
| (b) 固定大区布局，细节随机 | 重写 `buildLandAndSea`、`buildTerrain`、`refineTerrain`，让中原、江南、西域、塞北、蜀中大致在固定方位 | 可行。Legends 已经在这一层插入了自己的步骤（连接岛屿的陆桥）。工作量大，要反复生成几百张图检查连通性 |
| (c) 完全固定的手绘地图 | 自定义地图数据格式和加载器，按坐标写地块类型。Legends 的陆桥代码显示可以逐格 `tile.clear()` 后用地形模板 `fill` | 可行但投入最大，还要做编辑工具。每局地图相同，会损失 BB 的重玩性 |
| (d) 更大的地图 | — | **原版引擎做不到**（上限 140×170）。只有 Modern Engine 支持，而且大于原版上限的存档原版引擎读不了 |

建议：P4 做 L1；P5 做 L2 和 L3(a)；L3(b) 作为 P6 可选项；(c) 和 (d) 不进主线，除非你明确想要固定的"神州地图"（第 8 节）。

---

## 6. AI 美术流程建议

### 6.1 BB 的两类图片（已核实）

- **界面图片**：普通 PNG，放 `gfx/ui/`、`gfx/skills/`，脚本里直接写路径。
- **sprite**：战斗和大地图上的实体。多张小图打进一张图集，配一个 `.brush` 文件描述位置。开发时每张图单独放在 `unpacked_brushes/<图集名>/`，配一个 `metadata.xml`，BBBuilder 构建时自动调用 bbrusher 打包。文件夹名必须和 `metadata.xml` 里的 brush 名一致。

### 6.2 尺寸规格

以下尺寸量自 Reforged 仓库里的实际文件（已核实），原版同类资源应一致，开工前用 `bbbuilder extract-basegame` 解出原版再抽查。表里的"画布"指 `metadata.xml` 里的 `width` / `height`，实际图片裁掉透明边后更小。

| 资源 | 尺寸（像素） | 位置 | 备注 |
| --- | --- | --- | --- |
| 技能图标 | 56×56 | `gfx/skills/` | 每个要配一张 `_sw` 结尾的灰度版 |
| perk 图标 | 56×56 | `gfx/ui/perks/` | 同样要 `_sw` 版 |
| perk 组图标 | 56×56 | `gfx/ui/perk_groups/` | |
| 背景图标 | 56×56 | `gfx/ui/backgrounds/` | |
| 头顶状态小图标 | 20×20 | brush | |
| 物品图标 | 70×70，武器护甲另需 70×140 | `gfx/ui/items/<类别>/` | |
| 伤病图标 | 65×65 | `gfx/ui/injury/` | |
| 战斗方向标 | 46×46 | `gfx/ui/orientation/` + brush | 每种敌人一个 |
| 旗帜 | 250×401 | `gfx/ui/banners/` | |
| 事件插图 | Reforged 的两张是 210×210 | `gfx/ui/events/` | 原版大图尺寸未核实 |
| 战斗人物身体、衣甲 | 画布 104×142，`offsetY="35"` | brush | 每件要三个版本：正常、`_damaged`、`_dead`（倒地，画布更大，偏移不同） |
| 头盔、头饰 | 裁切后约 70×86 | brush | 同样三个版本 |
| 战斗内武器 | 画布 130×142（长兵 144–150 宽），`offsetY="35"` | brush | 另需 `_bloodied` 版 |
| 大地图队伍 | 画布 68×106，`offsetY="20"` | brush | |
| 大地图据点 | 约 170–280 宽 | brush | |

`metadata.xml` 每个 sprite 一行，关键属性：

- `id`：脚本里引用的名字。
- `img`：图片相对路径。
- `left` / `right` / `top` / `bottom`：图片相对画布中心的位置，差值必须等于图片实际宽高，否则 bbrusher 报错。
- `offsetX` / `offsetY`：整体偏移，照抄同类原版 sprite。
- `ic` 和其他属性含义不明，照抄同类原版 sprite。

定位工具：MSU 团队的网页版 paperdoll（<https://msuteam.github.io/paperdoll/>），把图拖进去对齐人物模板，直接得到四个位置值。

### 6.3 人物是分层拼出来的

战斗里的人物由身体、纹身、衣甲、头、胡须、头发、头盔、武器、盾牌等十几层叠成。武侠化不需要重画整个人，主要画三类：

1. 衣甲：道袍、劲装、僧衣、官服、夜行衣。
2. 头饰（占头盔位）：发髻、斗笠、方巾、头陀箍。
3. 中式兵器：第一阶段可以完全不画，直接用原版的剑和刀。

头和脸沿用原版。要不要换成东亚面孔是一笔不小的额外工作（每种脸要正常、受伤、死亡多个版本），见第 8 节。

### 6.4 分资源类型的生成方法

| 类型 | AI 适用度 | 方法 |
| --- | --- | --- |
| 事件插图 | 高 | 文生图。固定模型、固定风格 LoRA、固定提示词模板 |
| 技能、perk、物品图标 | 高 | 512 或 1024 生成，脚本统一裁切、加底板和边框、缩小、生成灰度版 |
| 衣甲、头饰 | 中 | 不能纯文生图，肩宽、领口位置必须和人物模板对齐。以原版同类 sprite 为底做图生图，或用线稿、深度控制。出图后人工抠透明、修边。受损版可以用脚本叠一层破损和血污；倒地版姿势完全不同，要单独生成或手工改，是最费工的部分 |
| 大地图地块 | 低 | 六边形无缝衔接和地形过渡很难靠生成解决。建议以原版为底调色重绘，放到最后 |

### 6.5 保持风格一致

BB 的画风：手绘厚涂、粗深色描边、低饱和、半身胸像（没有腿）、俯视约四分之三角度、光从左上来。

具体手段：

1. **一套固定的生成配置**：同一个底模、同一个风格 LoRA、同一个负面提示词，写进仓库。换配置就要全部重出。
2. **固定调色板**：从原版 sprite 提取 32–48 个主色，所有产出过一遍色彩匹配和量化脚本。这一步对一致性的贡献最大。
3. **统一后处理脚本**：描边粗细、透明边裁切、缩放算法全部脚本化，不手工处理单张图。
4. **按类别成批生成**：同一类资源（比如全部剑法图标）一次出完，不要今天两张明天两张。
5. **游戏内验收**：写一个脚本把新衣甲叠到人物模板上出预览图，再进游戏和原版单位站在一起截图比较。只看单张图看不出问题。
6. **验收清单**：尺寸、透明背景、描边、亮度范围、与模板对齐，逐项勾。

版权提示：用原版素材训练自用的风格 LoRA 属于灰色地带；直接以原版 sprite 为底改绘后再分发，风险更高。如果要公开发布，需要你决定接受到哪一步（第 8 节）。

### 6.6 流水线

```
art_src/（AI 出的大图，入库）
  → tools/process.py（抠图、色彩匹配、描边、缩放、生成 _sw / _damaged、
                      裁透明边并自动算出 left/right/top/bottom 写入 metadata.xml）
  → gfx/ 和 unpacked_brushes/
  → bbbuilder build（打包 brush，编译检查 .nut，生成 zip）
```

`process.py` 让 AI 编码助手写，一次投入，之后所有资源都走它。bbrusher 是 Windows 程序；GitHub 上有一个 Python 实现的 brush 读写器（p0ss/BattleBrushes，2026-04），声称匹配 bbrusher 的格式，我没有验证。

### 6.7 第一阶段的美术量

| 项目 | 数量 |
| --- | --- |
| 招式图标（含灰度版） | 约 12 |
| perk 图标（含灰度版） | 约 20 |
| perk 组图标 | 约 8 |
| 背景图标 | 2 |
| 敌人方向标 | 4 |
| 事件插图 | 3–5 |
| 衣甲 sprite | 0–2 套（可以先全用原版） |
| 内力条素材 | 1 套 |

第一阶段完全可以只做图标，不碰 sprite。

---

## 7. 分阶段里程碑

不给日历时间，用范围和验收标准界定。每个阶段结束都应该是一个能玩、能存档的版本。

### P0 技术验证

目的：把不确定的技术点各做一个最小原型，结果决定后面的方案。

| 验证项 | 通过标准 |
| --- | --- |
| 开发环境 | BBBuilder 能解包原版、新建 mod、构建并启动游戏 |
| 中文显示 | 在三种环境下各截图：纯原版、汉化包 + bb-launcher、Modern Engine。确认界面和地图上的中文表现 |
| DPF 最小树 | 一个自定义背景，两个自定义组，游戏里能看到并能点 perk，存读档正常 |
| 内力条原型 | 战斗界面和角色界面各显示一条假数据 |
| 自定义招式 + AI | 一个新主动技能，玩家能用，敌人也会用 |
| sprite 打包 | 一件自定义衣甲和一个图标进游戏显示正确 |
| 同名 sprite 覆盖 | 确认能否用自己的 brush 覆盖原版 sprite |

P0 同时把 AI 辅助开发的环境搭好，后面每个阶段都靠它：

- 把解包的原版脚本、Reforged、DPF、MSU 的源码放进 AI 的工作区，只读，供检索。原版是唯一可靠的 API 文档。
- 写一份约定文件给 AI：Squirrel 3.0 语法、界面 JS 只用 ES3、`wx_` 前缀、只用 Modern Hooks 的 `hook` 写法、不覆盖原版文件。
- 每次改动后跑 `bbbuilder build`，它会编译所有 `.nut` 报语法错误。
- 运行期错误看 `Documents\Battle Brothers\log.html`，把报错原文贴回给 AI。
- 做一个调试用起源：开局给满级弟子、全部秘籍和各档敌人的测试战斗，缩短验证一个改动要花的时间。

### P1 最小可玩核心

范围：

- 内力系统完整（数据、消耗、回复、调息、修炼度、存档、界面）。
- 武学框架和剑的武器层。
- perk 树：通用组、剑组、另外两个兵器组（只重新分配原版 perk）、两个体魄组、一个通用内功组。所有可招募背景都换成动态树。
- 第一个门派全部内容（第 4 节）。
- 四种敌人进强盗刷怪表，一个唯一据点。
- 一个起源。
- 中文文本，约 40 个图标。

验收：

- 新开档，招到门派弟子，练到 11 级，打过会武功的敌人和据点首领。
- 连续玩 100 个游戏日，`log.html` 无报错。
- 存档读档后内力、心法、perk 树都正确。
- 没有内力的角色，体验和原版一致。

主要风险：内力界面、AI 是否合理使用招式、数值。

### P2 横向扩展

- 武器层补齐：刀、枪、棍、拳掌、暗器。
- 新增两到三个门派，其中至少一个是拳掌门派（验证空手招式），一个是邪派（验证不同的回气方式）。
- 轻功模块。
- 敌人种类扩充，衣甲 sprite 开始替换。

验收：加一个新门派不需要修改框架代码。

### P3 养成

- 秘籍和拜师（事件版）。
- 打坐、丹药、复用原版工艺界面的配方。
- 第一批奇遇事件，20–30 个。
- 内功组补齐四个路数。

验收：一个非门派出身的角色能通过奇遇或拜师学到完整的门派武学。

### P4 江湖

- 门派成为独立势力，有据点、有关系值、有契约。
- 声望和恩怨：寻仇队伍、门派态度影响招募和商店。
- 世界换皮 L1：名字、旗帜、城镇形象。

验收：玩家和某个门派可以从友好走到敌对，并且两种状态下的游戏内容明显不同。

主要风险：势力数量上限、原版契约对势力类型的假设。

### P5 世界

- L2：城镇和势力分布，L3(a) 参数调整。
- 锻造和神兵。
- 后期危机的武侠版本（替换原版的后期危机，或与之并行）。
- 更多门派。

### P6 可选

- L3(b) 固定大区布局。
- 利用 Modern Engine 的特性（大地图）。
- 界面打磨（内力条方案 B、招募界面显示 perk 组）。
- 英文版。

---

## 8. 需要你拍板的开放问题

按对后续工作的影响排序。每条给出我的建议，你可以直接否决。

### 影响架构，P0 前要定

1. **原版内容的去留。** 是做成"武侠内容叠加在原版中世纪世界上"（兽人、亡灵、贵族都在），还是最终做成完全的武侠世界（原版敌人和势力全部替换或隐藏）？后者的工作量是前者的数倍，主要在敌人、契约、事件的替换。
   建议：P1–P3 按叠加做，P4 开始前再决定是否全面替换。

2. **运行环境和中文方案。** 以哪个环境为准：汉化包 + bb-launcher、Modern Engine，还是都不依赖（地图上用拼音）？
   建议：以汉化包 + bb-launcher 为准，提供拼音兜底开关，保持 Modern Engine 兼容。

3. **DLC 要求。** 是否要求玩家拥有全部 5 个 DLC？不要求的话，沙漠地区内容、工艺系统（需要"野兽与探索"）、部分武器类型都要做有无判断。
   建议：要求全部 DLC。Reforged 和 Legends 都这么做，能省掉大量分支。

4. **发布范围。** 自用、中文社区、还是 Nexus 国际发布？决定要不要英文文本，以及下面的命名和版权问题要多严格。
   建议：先面向中文社区，文本表从一开始就抽离，英文版留到 P6。

5. **开发机器。** 你有 Windows 开发环境吗？游戏本体、BBBuilder、bbrusher 都是 Windows 程序。

### 影响设计，P1 前要定

6. **内力是否跨战斗保留。** 方案一：每场战斗开始按比例重置（建议，节奏接近原版，不增加大地图上的操作）。方案二：像生命一样带到下一场，需要休息或打坐恢复（更有武侠味，但会鼓励打一场歇一天）。

7. **内力条的界面。** 接受第一阶段用内力条替换士气条（只对有内力的角色）吗？还是一开始就要新增一条？

8. **心法怎么成长。** 建议用独立的修炼度（第 2.5 节）。备选：消耗 perk 点，或跟随角色等级。

9. **一个人能学多少。** 是否允许同时主修多门内功？正邪或阴阳内功是否互斥？可否叛出师门改投？建议值见第 3.3 节。

10. **强度曲线。** 顶尖高手应该多强？BB 的基调是人人都会死，顶级角色也怕被围。武侠的基调是高手一人可敌数十。
    建议：保持 BB 基调，高手体现在单挑和小规模战斗里明显占优，被五六个人围住仍然危险。

11. **命名策略。** 三个选项：(a) 直接用金庸、古龙体系的门派和武功名，辨识度最高，公开发布有版权风险；(b) 用历史上真实存在的门派和地名（少林、武当、峨眉、华山），招式和心法名原创；(c) 全部原创。
    建议：(b)。本文第 4 节按 (b) 写。

12. **第一个门派选谁。** 文档里用华山剑派占位。如果你心里有更想先做的门派，告诉我；只要它是单一兵器的门派，第 4 节的结构都适用。

### 可以晚点定

13. **是否接受更多可选依赖。** Modular Vanilla（伤害管线更好改，但强制全 DLC 且多一层版本耦合）、Dynamic Spawns（敌人队伍配置更灵活）。建议等 P2 真正需要时再定。

14. **门派势力什么时候独立。** P2 做邪派时就做成独立势力，还是等 P4 统一做？建议等 P4。

15. **地图的最终目标。** 随机生成的武侠风世界，还是固定的"神州"地图？后者意味着 L3(c)，投入最大，而且要更大的地图就必须依赖 Modern Engine。

16. **美术边界。** 人物要不要换成东亚面孔和发型？是否接受以原版素材为底改绘再分发？AI 工具链用本地模型还是在线服务？

17. **和其他 mod 的兼容目标。** 建议明确声明与 Legends、Reforged 冲突，只保证与常见的界面和便利类 mod 共存。

---

## 附录 A：参考资料

框架和工具：

- Modern Hooks：<https://github.com/MSUTeam/Modern-Hooks>，<https://www.nexusmods.com/battlebrothers/mods/685>
- MSU 及 wiki：<https://github.com/MSUTeam/MSU>，<https://github.com/MSUTeam/MSU/wiki>
- Dynamic Perks Framework：<https://github.com/Battle-Modders/Dynamic-Perks-Framework>，<https://www.nexusmods.com/battlebrothers/mods/758>
- Nested Tooltips Framework：<https://github.com/MSUTeam/nested-tooltips>
- Reforged（DPF、新属性、新敌人、界面扩展的范例）：<https://github.com/Battle-Modders/mod-reforged>
- Modular Vanilla：<https://github.com/Battle-Modders/mod_modular_vanilla>
- BBBuilder：<https://github.com/TaroEld/BBbuilder>
- BB 模组开发文档（Modern Hooks、brush、界面）：<https://bbmodding.enduriel.com/docs/>
- Adam Milazzo 的 mod kit：<https://www.adammil.net/blog/v133_Battle_Brothers_mod_kit.html>
- paperdoll 定位工具：<https://msuteam.github.io/paperdoll/>

地图和引擎：

- Legends（世界生成和势力创建的 hook）：<https://github.com/Battle-Brothers-Legends/Legends-public>
- World Parameters：<https://github.com/Enduriel/BB-World-Parameters>
- Modern Engine：<https://github.com/Enduriel/modern-bb-engine>（`docs/modding.md`、`docs/differences.md`）

中文环境：

- Battle-Brothers-CN：<https://github.com/shabbywu/Battle-Brothers-CN>
- bb-launcher：<https://github.com/shabbywu/awesome-battle-brothers>

同类 mod：

- Chinese Addition Weapons：<https://www.nexusmods.com/battlebrothers/mods/1215>
- Aura Power：<https://www.nexusmods.com/battlebrothers/mods/1035>
- JJKCE：<https://www.nexusmods.com/battlebrothers/mods/1143>

原版脚本对照：开发时用 `bbbuilder extract-basegame` 解出自己游戏版本的脚本。本次核实原版函数名时参考了公开的反编译仓库 <https://github.com/ninkjin/Battle-Brothers-Scripts>，它的版本和完整度我没有确认，只用来核对函数名和流程。

## 附录 B：未核实事项清单（P0 时逐项确认）

1. 未装汉化字体包时，界面里的中文能否靠系统字体显示。
2. 战斗内由引擎直接绘制的文字（如果有）是否也受位图字体限制。
3. 自己的 brush 定义同名 sprite 能否稳定覆盖原版。
4. 原版事件大图的尺寸，城镇界面背景图的路径和分层方式。
5. 原版各技能的具体行动点和疲劳数值（文中引用的凭记忆）。
6. 强盗队伍模板的完整字段。
7. Modern Engine 在带大量 mod 的长战役下的稳定性。
8. p0ss/BattleBrushes 的 Python brush 写入器产出的文件能否被游戏正确读取。
