# BB-wuxia-mod

《战场兄弟》（Battle Brothers）武侠 Mod。当前为基于 Modern Hooks 的 `v0.1.0` 开发版。

## 当前进度

- **M0 实机开局**。在 Windows 版 Battle Brothers 1.5.2.3 验证了冷启动和 24 项引擎内自测。「演武试剑台」与「初走江湖」均已通过引擎开局检查，正式开局生成 5 名带有起始武学的同伴。
- **M1 武学培养**。已通过游戏界面后端验证等级锁槽、散功覆盖、凝神丸升重、残本强修、残页拼合和洗髓扣药。退出游戏后重开读档，七槽与行囊正常渲染，槽位、火候、根骨、招式和散功状态可恢复。鼠标拖放和画面验收仍待实机操作。
- **M2–M3 战斗与江湖**。已有 24 本秘籍、5 种丹药、战斗效果、敌人武学与掉落、门派交情和事件代码。战斗和掉落闭环，以及 60–100 日正式开局试玩仍待验收。

## 本地构建

```bash
python tools/build_mod.py
```

脚本静态检查 Squirrel 和 JavaScript，并生成 `dist/mod_wuxia.zip`。安装时，将 MOD 放入已装 Modern Hooks 的游戏 `data/` 目录。

## 核心设计文档（单一真相源）

| 文件 | 说明 |
| --- | --- |
| [docs/system-design.md](docs/system-design.md) | **现行核心系统总设计**：以人物属性为底盘，自底向上构建「原版八维（内力=疲劳合一）+ 概率洗髓 → 全插槽武学秘籍（取消 Perk 树）→ 战斗兵甲与 12 人梯队 → 务实增强型江湖大世界」的四层自洽体系，含数值标尺、MVP 清单与图标化拖拽 UI 方案 |
| [docs/dev-roadmap.md](docs/dev-roadmap.md) | **精简开发路线与模块/数据表拆解**：Mod 目录架构、核心 Squirrel 数据表 Schema（存档/秘籍/敌方掉落/轻量门派）与 M0–M4 五阶段验收清单 |

## 历史设计归档与参考工具

以下文件为前期探索阶段留存的旧方案与交互推演，部分旧口径（如独立内力条、DPF 动态天赋树、架势条、后台自治药镖等）已由 [docs/system-design.md](docs/system-design.md) 取代，仅作灵感与技术资料参考：

### `docs/archive/`（历史文档归档）

| 文件 | 说明 |
| --- | --- |
| [docs/archive/wuxia-mod-design.md](docs/archive/wuxia-mod-design.md) | 早期技术调研与一代方案（含框架版本、美术规格、引擎限制等可复用参考资料） |
| [docs/archive/wuxia-outline-reconciliation.md](docs/archive/wuxia-outline-reconciliation.md) | 早期六模块大纲与一代方案对照 |
| [docs/archive/development-roadmap.md](docs/archive/development-roadmap.md) | 早期路线规划稿 |
| [docs/archive/development-todo.md](docs/archive/development-todo.md) | 早期待办清单稿 |
| [docs/archive/repo-review.md](docs/archive/repo-review.md) | 早期仓库评审 |
| [docs/archive/project-discussion-log.md](docs/archive/project-discussion-log.md) | 早期项目讨论纪要 |

### 根目录 HTML（早期设计浏览工具）

| 文件 | 说明 |
| --- | --- |
| `武侠百科.html` | 早期自包含武侠设计百科（原版 2063 条词条武侠命名映射库，仍可作中式命名词典参考） |
| `jianghu-systems.html` | 早期「一局江湖的系统关系」交互图 |
| `jianghu-lineups.html` | 早期「玩家眼里的江湖」互动分支草图 |
| `bbmod-wiki.html` | BBMOD 原版百科首页快照 |
