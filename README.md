# BB-wuxia-mod

《战场兄弟》（Battle Brothers）武侠 Mod 的设计仓库。当前处于**系统设计与规格细化阶段**，尚未开始正式 `.nut` 代码实现。

## 核心设计文档（单一真相源）

| 文件 | 说明 |
| --- | --- |
| [docs/system-design.md](docs/system-design.md) | **现行核心系统总设计**：以人物属性为底盘，自底向上构建「原版八维（内力=疲劳合一）+ 概率洗髓 → 全插槽武学秘籍（取消 Perk 树）→ 战斗兵甲与 12 人梯队 → 务实增强型江湖大世界」的四层自洽体系 |

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

## 下一步

基于 [docs/system-design.md](docs/system-design.md) 第 6 节，逐章细化插槽解锁节奏、功法重数、残页与洗髓数值、AP 突破边界及第一阶段最小可玩切片（MVP），定稿后即可基于 `Modern Hooks + MSU` 搭建 Mod 骨架进入开发。
