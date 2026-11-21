# UI 预览（不进游戏）

## 首次使用
预览依赖原版 UI 贴图，需要先从本机游戏提取（输出到 `_vanilla/`，已加入 .gitignore，**原版美术不得提交**）：

```
python tools/extract_vanilla_ui_ref.py "F:\SteamLibrary\steamapps\common\Battle Brothers"
python tools/build_wx_character_bg_v2.py     # 生成「原版面板 + 半身武侠雕像」新底图（加 --mod 同时写入 mod 贴图目录）
```

## 文件
| 文件 | 内容 |
| --- | --- |
| `character_screen.html` | **v2 · 原版同构**：人物界面三页签。外壳全部用原版贴图 / 字色 / 字号，武侠味只放在内容上 |
| `design_tokens.html` | **v2** 设计令牌：v1 为何突兀的逐项对照、原版色板、字体字号、贴图组件清单、全局落点、现有 mod 改动清单 |
| `wx_vanilla_kit.css` | v2 共用组件（按钮 / 页签 / 格位 / 属性条 / 勾选 / 输入 / 提示框 / 弹窗），游戏内把 `_vanilla/gfx/` 换成 `coui://gfx/` |
| `character_screen_v1.html` · `design_tokens_v1.html` · `wx_tokens.css` | v1（乌木鎏金方案），仅留作对比 |

`character_screen.html#...` 参数：`tab=inv|wx|lib`、`bg=statue|vanilla|wx`（新雕像底 / 原版底 / 旧 mod 乌木底）、`modal=wash|swap`、`grid`、`notes`、`selftest`。
