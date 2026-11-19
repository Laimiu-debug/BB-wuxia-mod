# 第三方前置框架整合目录 (`vendor/`)

《战场兄弟》引擎按 `data/` 目录中的独立 `.zip` 文件顺序加载前置框架。**不要**把 `Modern Hooks` 和 `MSU` 解压混进 `mod_wuxia.zip` 内部（否则与玩家已装的前置冲突，会直接触发 `Mod already registered` 崩溃）。

正确的一键整合发布做法是把官方前置包与 `mod_wuxia.zip` **并列打包**进同一份 `data/` 整合包：

1. 将官方下载的以下两个 `.zip` 文件放入本 `vendor/` 目录（文件名保持原样即可）：
   - `mod_modern_hooks*.zip`（来源：<https://github.com/MSUTeam/Modern-Hooks/releases>）
   - `mod_msu*.zip`（来源：<https://github.com/MSUTeam/MSU/releases>）
2. 在项目根目录运行：
   ```bash
   python tools/build_mod.py --bundle
   ```
3. 脚本会自动校验代码并输出：
   - `dist/mod_wuxia.zip`（独立 Mod 包）
   - `dist/BB_Wuxia_AllInOne_data.zip`（包含 `mod_modern_hooks` + `mod_msu` + `mod_wuxia` 的一键整合包，解压进游戏 `data/` 目录即开玩，零冲突！）
