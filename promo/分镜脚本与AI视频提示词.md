# 《战场兄弟：武侠江湖》(BB Wuxia Mod) 官方概念宣传片分镜脚本与 AI 提示词手册

> **项目定位**：《战场兄弟》（Battle Brothers）大型暗黑低魔志怪武侠总改 Mod（`v0.6.1`）概念宣传预告片  
> **成片规格**：16:9 宽银幕 / 1080p HD / 约 35 秒（6 幕连贯剪辑，适配 B 站 / Steam / 贴吧 / 玩家群传播）  
> **视觉母题**：延续仓库内 787 件原创手绘美术资产的统一画风——**暗黑明末写实水墨厚涂 + 粗粝黑墨漫画勾边 + 旧羊皮纸暗金/青铜锈/朱砂血红/苍青玉色配色**，100% 保留《战场兄弟》的硬核铁人冷峻气质，绝不向廉价亮面仙侠妥协。

---

## 一、全片节奏总览（35 秒高燃 6 幕结构）

| 幕次 | 时间轴 | 时长 | 核心卖点（均核对自 Mod 实装代码） | 复用的仓库现有美术资产 | 情绪曲线 |
| --- | --- | --- | --- | --- | --- |
| **第一幕** | `00:00 – 00:06` | 6s | 暗黑明末江湖 · 12 人铁人战团 · 72 项武侠出身 · 44 大门派 | `art/busts/` 合成的 5 位实机侠客胸像 + `wx_crest_longhu.png` | 压抑肃杀、冷雨开局 |
| **第二幕** | `00:06 – 00:11` | 5s | 废除原版 Perk 树 · 独创「7 槽武学修为」· 272 本秘籍 · 洗经伐髓 | `wx_book_neigong_unique` / `wx_book_waigong_unique` / `wx_pill_xisui` / `wx_martial_container` / 四脉宗印 | 神秘蓄势、金光流转 |
| **第三幕** | `00:11 – 00:17` | 6s | 39 柄传世红武神兵 · 73 式主动绝学 · 轻重装双轨搏杀 · 64 帧气芒 | `wx_relic_taie` / `wx_relic_longyuan` / `wx_vfx_01` / `08` / `09` / `17` / `02` | 节奏提速、刀光爆发 |
| **第四幕** | `00:17 – 00:23` | 6s | 《山海经·五臧大荒万妖全卷》64 尊独立首领与动态秘境降世 | `wx_boss_xingtian` / `taotie` / `jiuwei` / `yinglong` / `xiangliuwang` / `chiyou` / `jinwu` | 压迫震撼、史诗反转 |
| **第五幕** | `00:23 – 00:30` | 7s | 十二人凡躯硬撼上古凶神 · 斩妖取丹炼化灌注 · 百工铸山海神甲 | 5 位战团侠客 + `wx_boss_xingtian` + 真龙掌/剑弧特效 + `wx_core_xingtian` | 最高燃点、爆裂冲击 |
| **第六幕** | `00:30 – 00:35` | 5s | 血月孤剑视觉图腾 + 水墨鎏金主标题落版 | `wx_crest_xuanniao` + `wx_relic_taie` | 骤停余韵、强力记忆 |

---

## 二、现有资产预处理参考板（`promo/assets/`）

为让 AI 图像/视频模型严格忠实于本 Mod 现有画风与造型，已通过脚本从仓库 `art/busts/` 与 `art/hd/` 自动拼接生成 5 张高分辨率参考拼板：

1. **`promo/assets/ref_01_heroes.png`**：基于 `art/busts/` 像素级合成的 5 位实机侠客胸像（清风剑派竹青剑衫少侠、藩镇山文重铠金龙帅胄悍将、烟雨蓑衣竹笠老镖头、太和紫霄八卦道长、血煞魔宗独眼悍匪）+ 威远龙虎镖旗徽。
2. **`promo/assets/ref_02_cultivation.png`**：孤本竹简内功、石刻血纹外功卷、紫檀匣龙纹洗髓丹、八卦武学修为总纲、内/剑/轻/横四脉圆印与凝神丸。
3. **`promo/assets/ref_03_weapons_vfx.png`**：太阿古剑、七星龙渊剑、传世长兵神兵 + 青霜快剑斩弧、天河落星飞剑雨、亢龙金罡真龙掌印、梵文护体金钟、烈阳霸刀火罡 + 穷奇宝甲。
4. **`promo/assets/ref_04_shanhai_bosses.png`**：刑天无首战魂、吞天饕餮王、青丘九尾天狐、折翼应龙战魂、九首相柳皇、蚩尤战魄、三足金乌皇、钟山烛九阴 + 刑天不灭战髓内丹。
5. **`promo/assets/ref_05_title_crest.png`**：血月孤剑黑燕盟徽（`wx_crest_xuanniao.png`）+ 太阿古剑 + 刑天内丹。

---

## 三、逐镜分镜脚本与 AI 生成提示词（可直接复用）

> **通用画风锚定词（Style Anchor）**：  
> `Gritty dark-fantasy Ming-dynasty Chinese wuxia tactical RPG key art, thick bold black ink linework, hand-painted gouache and ink-wash shading, weathered bronze, parchment gold, crimson, muted jade teal, and charcoal palette, dark atmospheric rain and mist, grimdark hand-illustrated aesthetic, no glossy 3D anime rendering, no clean plastic skin.`

---

### 第一幕｜暗黑明末江湖 · 十二人战团集结（`00:00 – 00:06`，6 秒）

- **参考素材**：`promo/assets/ref_01_heroes.png`
- **景别与运镜**：低角度中景广角，缓慢平稳推进（Slow Cinematic Push-In），冷雨斜落，镜头越过雨中石阶逼近五人战团。
- **旁白文案**：「乱世无主角，生死皆江湖。」
- **后期压字建议**：`《战场兄弟：武侠江湖》` / `72 项武侠出身 · 44 大地域门派 · 12 人硬核铁人战团`
- **声画节奏**：深沉尺八长鸣 + 冰冷暴雨声 + 镖旗在狂风中猎猎拍打 + 低音战鼓第一声闷响。

#### 关键帧提示词（Image Prompt / 图生图）
> **English Prompt** (Reference: `@heroes = ref_01_heroes.png`):  
> Widescreen 16:9 dark-fantasy Ming-dynasty Chinese wuxia tactical RPG key art matching the exact thick black ink outlines and hand-painted dark gouache art style of @heroes. On a rain-drenched muddy mountain courier road flanked by ruined stone watchtowers and misty dark bamboo silhouettes under a brooding storm sky with a faint crimson blood-moon behind clouds, a gritty five-warrior jianghu mercenary company stands shoulder to shoulder in battle formation, strictly preserving the exact faces, armor, and headwear from @heroes: in the center stands the imposing bearded veteran general wearing dark mountain-pattern iron lamellar armor and the gilded dragon helmet; to his left stands the young bamboo-green robed swordsman with high ponytail and blue jade headband resting his hand on a sword hilt; to his right stands the weathered older escort master in woven straw raincape and conical bamboo hat; beside them stand the white-bearded Taoist master in yin-yang crane robes with purple-gold bagua crown and the scarred one-eyed berserker in studded crimson-black leather armor. Behind them, a tattered dark war banner bearing the roaring golden tiger and azure dragon emblem from @heroes whips violently in the wind and rain. Dramatic side rim-lighting from distant lightning, rain streaking through cold mist, gritty battle-scarred atmosphere, no text, no UI.

#### 视频动态提示词（Video Prompt / 图生视频，6s）
> **English Motion Prompt**:  
> Slow cinematic low-angle push-in toward the five gritty Ming-dynasty wuxia warriors standing in pouring rain on a muddy mountain road. Heavy raindrops slash diagonally across the frame and glisten off weathered lamellar armor, bronze helmets, and woven straw raincapes. The tattered golden-tiger and azure-dragon war banner behind them whips violently in strong wind. Swirling cold mist drifts between dark bamboo silhouettes, distant lightning flickers softly behind blood-tinted storm clouds, the central armored general shifts his grip on his blade while the green-robed swordsman slightly draws his steel sword with a sharp metallic glint. Thick hand-painted ink-wash illustration brought smoothly to life, keeping all character designs locked and consistent. Audio: pouring rain, howling mountain wind, snapping cloth banner, distant thunder, solemn Chinese xiao flute and a deep war drum beat.

---

### 第二幕｜废除专长树 · 7 槽武学修为与洗经伐髓（`00:06 – 00:11`，5 秒）

- **参考素材**：`promo/assets/ref_02_cultivation.png`
- **景别与运镜**：暗房木案俯仰 45° 近景，微距缓慢拉升并轻度环绕（Slow Overhead Pull-Back & Gentle Arc）。
- **旁白文案**：「废除死板天赋树，七槽秘籍随心悟，洗经伐髓破凡胎！」
- **后期压字建议**：`废除原版专长树 · 独创 7 槽拖拽武学修为` / `272 本独创秘籍 · 洗经伐髓冲星突破 11 AP`
- **声画节奏**：古卷竹简展开木质摩挲声 + 丹匣弹开清脆金玉声 + 古筝轮指由缓入急 + 真气嗡鸣。

#### 关键帧提示词（Image Prompt / 图生图）
> **English Prompt** (Reference: `@cultivation = ref_02_cultivation.png`):  
> Widescreen 16:9 dark-fantasy Ming-dynasty Chinese wuxia illustration matching the exact bold black ink linework and grimdark hand-painted gouache texture of @cultivation. Inside a shadowy candlelit martial arts library hall, a heavy weathered dark wood table holds an unfurled ancient bamboo-slip manual bound with twine beside a worn jade seal, and a cracked stone scroll etched with a crimson halberd diagram from @cultivation. At the center sits an open ornate dark-lacquer hexagonal box containing the glowing molten-gold dragon-carved Marrow-Wash Elixir pill from @cultivation, radiating warm amber light across scattered parchment fragments and three pearl-white focus pills in a brass tin. Hovering above the table in a majestic circular constellation are seven mystical martial-arts slot medallions derived directly from @cultivation — a central bronze taiji eight-trigram ring surrounded by glowing jade-black yin-yang lotus, crossed pine swords, wind swallow, and golden iron-bell medallions — linked by thin luminous golden qi meridian streams and swirling ink-smoke wisps. Rich chiaroscuro candlelight, ancient atmospheric dust motes, no modern UI text, no letters.

#### 视频动态提示词（Video Prompt / 图生视频，5s）
> **English Motion Prompt**:  
> Smooth cinematic slow pull-back and subtle orbital camera drift over the candlelit martial arts altar table. The seven floating bronze and jade martial-arts medallions slowly revolve clockwise in mid-air like a sacred constellation, pulsing one by one with golden and jade qi energy as luminous meridian threads link them together. The glowing dragon-carved elixir pill inside the open hexagonal box radiates warm golden embers upward, ancient bamboo slips and scroll edges gently flutter in a mystical draft, and dark ink-smoke curls around flickering warm candlelight. Maintain the exact hand-painted dark ink-line illustration style throughout. Audio: crisp unrolling bamboo scroll sound, crystalline chime as medallions ignite, rapid resonant guzheng plucks building tension, deep internal qi hum.

---

### 第三幕｜百兵神兵 · 轻重装双轨搏杀与 73 式实机气芒（`00:11 – 00:17`，6 秒）

- **参考素材**：`promo/assets/ref_01_heroes.png` + `promo/assets/ref_03_weapons_vfx.png`
- **景别与运镜**：中全景动态横移跟拍（Dynamic Action Tracking Shot + Micro Camera Shake on Impact），模拟《战场兄弟》雨夜古刹硬核群战瞬间。
- **旁白文案**：「三十九柄传世神兵，七十三式绝学气芒——轻装破阵，重甲擎天！」
- **后期压字建议**：`39 柄历史与山海神兵 · 73 式主动绝学 · 轻重装双轨平衡`
- **声画节奏**：利剑出鞘寒吟 + 刀剑硬碰金铁交鸣 + 金钟罩宏大洪钟闷响 + 龙啸掌风撕裂空气 + 急促战鼓连击。

#### 关键帧提示词（Image Prompt / 图生图）
> **English Prompt** (References: `@heroes = ref_01_heroes.png`, `@weapons = ref_03_weapons_vfx.png`):  
> Widescreen 16:9 explosive dark-fantasy Ming-dynasty Chinese wuxia battle illustration in the exact bold black ink-outline and hand-painted dark gouache style of @heroes and @weapons. On the rain-slicked courtyard flagstones of a ruined mountain temple at night lit by burning braziers, three martial arts masters clash amidst enemy bandits: on the left, the agile bamboo-green robed swordsman from @heroes leaps low through drifting cyan mist wielding the bronze-cloud-guard ancient Tai-E sword from @weapons, unleashing a razor-sharp crescent cyan frost sword-slash arc and five spectral jade flying swords streaking forward; in the center, the heavy lamellar-armored general from @heroes braces firmly inside a translucent glowing bronze Sanskrit-inscribed Golden Bell protective dome from @weapons as a roaring crescent of blazing crimson-gold saber fire from @weapons crashes violently against the dome in a shower of sparks; on the right, a fierce martial master drives a palm strike forward erupting into the coiled black-and-gold ink-wash Dragon Palm shockwave from @weapons. Gritty visceral impact, flying ink splatters, rain, embers, dramatic dark-gold lighting, no text, no UI.

#### 视频动态提示词（Video Prompt / 图生视频，6s）
> **English Motion Prompt**:  
> Dynamic high-energy cinematic tracking shot sweeping across the rain-drenched ruined temple courtyard mid-clash. On the left, the green-robed swordsman dashes forward in a blur of mist, swinging his ancient sword to launch a blazing cyan crescent sword wave and spectral flying blades that slice through rain. At center, a fiery crimson saber arc slams hard against the armored general's glowing bronze Sanskrit Golden Bell shield, sending shockwaves and bright sparks bursting outward with a subtle camera impact shake. On the right, the golden ink-wash dragon coiled around a glowing palm print surges forward in an explosive burst of ink smoke and wind. Bold hand-painted ink-line martial arts aesthetic with crisp impactful timing. Audio: razor sword slashes, heavy metallic clang, resonant deep bronze temple bell tolling on impact, fierce dragon-roar palm blast, driving Chinese war drums and frantic pipa strings.

---

### 第四幕｜大荒异变 · 《山海经》六十四尊凶兽古神苏醒（`00:17 – 00:23`，6 秒）

- **参考素材**：`promo/assets/ref_04_shanhai_bosses.png`
- **景别与运镜**：极低机位仰拍缓慢仰推环绕（Monumental Low-Angle Reveal Tilt-Up & Push-In），突出上古山海凶神的压倒性体量与诡谲威压。
- **旁白文案**：「然而江湖深处，远不止人心险恶——大荒禁开，六十四尊山海凶神现世！」
- **后期压字建议**：`《山海经·五臧大荒万妖全卷》` / `64 尊独立凶兽古神首领 · 动态山海秘境`
- **声画节奏**：骤然低频轰鸣（Sub-bass Drop）+ 远古骨号角长啸 + 巨兽低沉咆哮 + 九尾诡异铃音 + 雷鸣滚滚。

#### 关键帧提示词（Image Prompt / 图生图）
> **English Prompt** (Reference: `@bosses = ref_04_shanhai_bosses.png`):  
> Widescreen 16:9 monumental dark-fantasy Chinese mythological key art in the exact bold black ink-outline and grimdark hand-painted gouache style of @bosses. Across a desolate volcanic wasteland and shattered ancient bronze sacrificial ruins beneath churning blood-red thunderclouds, colossal mythical monsters from the Classic of Mountains and Seas awaken from swirling ink-black miasma, strictly matching the exact creature designs of @bosses: towering dead-center out of the ash fog is the colossal headless bronze-armored war god Xingtian — eyes glaring from his scarred chest and a fanged roaring mouth gaping across his belly, gripping his massive notched battle-axe and weathered bronze shield; looming to the left on craggy cliffs is the tattered-winged teal-scaled Yinglong war dragon sparking with cold lightning beside the ram-horned blood-fanged Taotie beast exhaling dark crimson smoke; emerging from violet mist on the right are the sinister pale Nine-Tailed Fox Empress with purple-gray tails fanned wide and the nine-headed venomous turquoise Xiangliu serpent-god dripping green poison; high above, the flame-wreathed Three-Legged Golden Crow blazes across the crimson sky. Overwhelming dark-mythological scale, ash embers, dread and grandeur, no text.

#### 视频动态提示词（Video Prompt / 图生视频，6s）
> **English Motion Prompt**:  
> Monumental low-angle cinematic camera slowly tilting upward and pushing through dark ash fog as colossal ancient Chinese mythological monsters awaken beneath churning crimson thunderclouds. At center, the massive headless bronze-armored war god Xingtian steps heavily forward, his belly mouth opening in a terrifying primal roar while raising his colossal notched axe and shield. To the left, the tattered-winged teal dragon spreads its torn wings amidst flickering lightning as the horned Taotie beast exhales thick blood-red smoke. To the right, the pale nine-tailed fox's violet tails billow ominously while the nine turquoise hydra serpent heads of Xiangliu writhe and hiss in toxic mist. High overhead, the flaming three-legged crow soars through storm clouds showering embers. Gritty dark ink-and-gouache illustration style preserved rigidly. Audio: earth-shaking sub-bass rumble, ancient bronze war horn, monstrous echoing roar, crackling thunder, ominous eerie chimes.

---

### 第五幕｜绝境血战 · 十二侠客硬撼刑天 · 斩妖取丹（`00:23 – 00:30`，7 秒）

- **参考素材**：`promo/assets/ref_01_heroes.png` + `promo/assets/ref_03_weapons_vfx.png` + `promo/assets/ref_04_shanhai_bosses.png`
- **景别与运镜**：高速低空突进接瞬间升格慢动作环绕（High-Speed Charge into Dramatic Slow-Motion Climax Impact），呈现终极 Boss 战高潮与「山海内丹」爆出瞬间。
- **旁白文案**：「以凡人之躯，斩上古凶神，夺山海内丹，铸传世兵甲！」
- **后期压字建议**：`高危铁人终局血战 · 斩妖取丹炼化 · 锻造山海传世宝甲`
- **声画节奏**：密集战鼓冲锋达到顶峰 → 刀斧硬撼惊天巨响（画面一帧微滞）→ 真龙剑芒轰然炸裂 → 炽红内丹共鸣清音。

#### 关键帧提示词（Image Prompt / 图生图）
> **English Prompt** (References: `@heroes = ref_01_heroes.png`, `@weapons = ref_03_weapons_vfx.png`, `@bosses = ref_04_shanhai_bosses.png`):  
> Widescreen 16:9 climactic dark-fantasy Ming-dynasty wuxia boss-battle illustration matching the exact bold black ink outlines and gritty hand-painted gouache texture of @heroes, @weapons, and @bosses. On a scorched storm-lashed mountain battlefield, the colossal headless bronze war god Xingtian from @bosses slams his giant rune-carved battle-axe downward in a shockwave of shattered rock and crimson-black miasma, confronted head-on by the tiny yet fearless five-warrior jianghu mercenary squad from @heroes: in front, the golden-dragon-helmet heavy armored general braces with sparks exploding off his armor as he deflects the titan's swing; leaping high through wind and rain on the left, the bamboo-green robed swordsman slashes with the ancient Tai-E sword carving a blinding cyan crescent sword wave across Xingtian's bronze pauldron; from the right, the straw-hat veteran and Taoist master channel a soaring black-and-gold ink-wash Dragon Palm blast straight into the monster's flank. Amidst the explosive clash of cyan sword qi, golden dragon aura, and crimson embers, a cracked glowing crimson-obsidian crystal core wrapped in ancient axe-etched bronze bands (the Shanhai Neidan from @bosses) gleams brilliantly in the shattered vortex. Visceral heroic desperation, dark ink splatters, storm lightning, no text.

#### 视频动态提示词（Video Prompt / 图生视频，7s）
> **English Motion Prompt**:  
> Intense fast-paced camera rush-in transitioning into dramatic heroic slow-motion at the moment of impact on the storm-lashed mountain battlefield. The colossal headless war god Xingtian swings his massive battle-axe downward in a violent arc, smashing the ground and sending jagged stones, dust, and dark crimson energy blasting outward. Defying the giant, the armored Ming general holds the line amidst blinding sparks while the green-robed swordsman vaults gracefully through the air, unleashing a sweeping cyan sword-qi crescent across Xingtian's chest armor, simultaneously struck from the right by a surging golden ink-wash dragon palm blast. Explosions of black ink, golden sparks, and blazing embers fill the frame as a radiant crimson crystal core bound in ancient bronze axe bands bursts free and hovers pulsing with power. Crisp hand-painted dark ink illustration consistency throughout. Audio: thunderous war-drum crescendo, colossal axe crash, furious sword-qi whistle, roaring dragon energy detonation, shimmering crystal chime.

---

### 第六幕｜血月孤剑 · 水墨鎏金片名终章定格（`00:30 – 00:35`，5 秒）

- **参考素材**：`promo/assets/ref_05_title_crest.png`
- **景别与运镜**：沉稳居中缓推定格（Steady Symmetrical Slow Push-In），余烬缓缓飘升，水墨留白质感。
- **旁白文案**：「《战场兄弟：武侠江湖》——踏入暗黑大荒，写下你的血色传奇。」
- **画面内嵌标题**：主标题鎏金狂草水墨字 **`战场兄弟：武侠江湖`**，副标题 **`BB WUXIA MOD · 暗黑志怪武侠总改`**
- **声画节奏**：所有激昂鼓点轰然收束为一记浑厚古钟/大鼓余震 + 一声清越收剑入鞘「铿——」+ 悠远孤寂尺八尾音淡出。

#### 关键帧提示词（Image Prompt / 图生图，带精准中文书法片名）
> **English Prompt** (Reference: `@crest = ref_05_title_crest.png`):  
> Widescreen 16:9 dark-fantasy Chinese wuxia game title screen key art strictly based on @crest, in bold black ink outlines and hand-painted ink-wash dark gouache style. Centered against a pitch-black stormy ink-wash night sky above jagged misty dark mountain peaks hangs a massive textured deep crimson blood-moon; standing vertically dead-center across the blood-moon is the dark forged-iron ancient Tai-E sword with antique bronze cloud-scroll crossguard from @crest, with a sleek black swallow silhouette in mid-flight crossing left of the blade exactly echoing the emblem in @crest. Glowing crimson-gold embers and drifting black ink mist swirl gently around the lower mountain silhouettes. Across the lower-center foreground, bold, authoritative, crisp traditional Chinese calligraphy brush lettering in hammered antique gold with subtle crimson rim glow reads exactly: "战场兄弟：武侠江湖" — clean, legible, perfectly formed Chinese characters. Directly underneath in smaller neat pale-gold serif lettering reads: "BB WUXIA MOD". Cinematic game trailer end-card, crisp balanced composition, atmospheric dark negative space.

#### 视频动态提示词（Video Prompt / 图生视频，5s）
> **English Motion Prompt**:  
> Steady, majestic slow cinematic zoom-in on the dark ink-wash game title screen. Keep the central ancient sword, the glowing crimson blood-moon, and all gold Chinese calligraphy title text "战场兄弟：武侠江湖" and "BB WUXIA MOD" completely sharp, stable, and legible without morphing. Subtle atmospheric life animates the frame: the black swallow silhouette glides gently forward across the crimson moon, wisps of dark ink-smoke drift lazily across the jagged mountain peaks, glowing crimson-gold embers rise slowly upward, and a single crisp metallic gleam glides down the vertical sword blade. Audio: one final resonant massive war-drum boom fading into echo, the crisp metallic ring of a sword sliding back into its scabbard, and a haunting, lingering Chinese xiao flute note fading into silence.

---

## 四、独立配乐与旁白生成提示词（剪映 / PR 二次精剪可用）

### 1. 定制主题配乐 Prompt（38 秒完整版，适配 Lyria / Eleven Music / Suno）
> **Music Prompt**:  
> Epic dark Chinese wuxia tactical RPG trailer score, 38 seconds, instrumental only, no vocals. Opens (0-6s) with a solitary haunting Chinese bamboo xiao flute over distant dark rain ambience and slow deep tension war drums. Builds (6-16s) with urgent plucked guzheng arpeggios, sharp pipa tremolos, and driving taiko-style Chinese battle drums as steel blades clash. Drops into dark mythological dread (16-22s) with massive low brass, ancient bronze horn blasts, and mournful bowed erhu swells. Erupts into a heroic high-octane climax (22-30s) combining thunderous Chinese war drums, soaring erhu melody, rapid guzheng runs, and dramatic orchestral percussion hits. Ends (30-35s) with a sudden massive gong and war drum finale decaying into a solitary lingering xiao flute and bronze bell echo. Grimdark, atmospheric, raw, Ming-dynasty martial arts tone.

### 2. 中文配音旁白脚本（沉稳沧桑江湖说书人 / 铁血掌门男低音）
```text
[00:00 - 00:05] 乱世无主角，生死皆江湖。
[00:06 - 00:11] 废除死板天赋树，七槽秘籍随心悟，洗经伐髓破凡胎！
[00:11 - 00:16] 三十九柄传世神兵，七十三式绝学气芒——轻装破阵，重甲擎天！
[00:17 - 00:22] 然而江湖深处，远不止人心险恶——大荒禁开，六十四尊山海凶神现世！
[00:23 - 00:29] 以凡人之躯，斩上古凶神，夺山海内丹，铸传世兵甲！
[00:30 - 00:35] 《战场兄弟：武侠江湖》——踏入暗黑大荒，写下你的血色传奇。
```

---

## 五、后期精剪与社区发布建议（如导入剪映 / Premiere）

1. **成片即用**：已将 6 镜 AI 视频通过 `0.35s` 平滑叠化拼接成一条 **约 23.5 秒完整带原生音效概念预告片**（`promo/BB_Wuxia_Mod_Promo_Trailer.mp4`，`1280×720` / 24fps），可直接预览或发布；
2. **二次加料提质感（进阶剪辑包已备齐）**：若想进一步升级为 35~38 秒完整配乐旁白字幕版，可将 `promo/clips/` 中 6 段独立动态镜头、`promo/keyframes/` 中 6 张 2K 关键帧原图、`promo/audio/trailer_bgm_38s.mp3`（38 秒定制国风暗黑战鼓配乐）与 `promo/audio/trailer_vo_zh.mp3`（36.6 秒中文低沉旁白）拖入剪映：
   - 保留原视频 `35%~40%` 环境打击音效（雨声、剑鸣、金钟、咆哮），叠入定制配乐 `85%` 音量与中文旁白 `100%` 音量（对局部镜头略作 0.7x 升格慢放即可与 36.6 秒旁白精准卡点）；
   - 在每幕切换处叠加极简**鎏金宣纸黑底字幕条**（如 `272 本秘籍` / `7 槽武学修为` / `64 尊山海首领`），再穿插 2~3 秒**实机战斗 / 7 槽拖拽 UI 录屏**作为实机演示彩蛋。

---

## 六、本次实作交付物清单（全部保存在 `promo/`）

- **1080p 纯本地 ComfyUI 升级完整版（强烈推荐 · 0 积分全离线自产）**：`promo/BB_Wuxia_Mod_Local_ComfyUI_1080p.mp4`（`1920×1080` / 24fps / 38.0 秒 / H.264 + 192kbps AAC 立体声；由本机 `RTX 4070 Ti SUPER` 驱动 `MiniMax H3 FL2VA 8步 Turbo` 生成 6 幕带原生音效镜头 + 38 件实机 Mod 资产动效插切 + 三轨自动闪避混音与书法字幕合成）
- **本机 ComfyUI 全自动批量出镜脚本（0 积分无限跑）**：`promo/comfy_local_pipeline.py`（自动探测 Comfy Desktop 端口 `8000/8188`，批量调用 `MiniMax H3` 并将带原生音效成片保存至 `promo/clips_local/`）
- **1080p 导演剪辑完整版（初版云端底片）**：`promo/BB_Wuxia_Mod_DirectorCut_1080p.mp4`（`1920×1080` / 24fps / 38.0 秒）
- **本地离线重剪源码（0 积分可无限修改字幕/配乐/素材再渲染）**：`promo/render_director_cut.py`
- **精简纯画面带原生音效版**：`promo/BB_Wuxia_Mod_Promo_Trailer.mp4`（`1280×720` / 24fps / 23.5 秒 / 6 幕平滑叠化拼接）
- **6 段独立分镜视频**（`promo/clips/`）：
  - `shot_01_heroes.mp4`（4s · 暗黑明末雨夜战团）
  - `shot_02_cultivation.mp4`（4s · 7 槽武学修为与洗髓丹）
  - `shot_03_combat_vfx.mp4`（4s · 百兵神兵与 73 式实机气芒激战）
  - `shot_04_shanhai_bosses.mp4`（4s · 山海经六十四尊凶兽古神苏醒）
  - `shot_05_xingtian_clash.mp4`（5s · 十二侠客绝境硬撼刑天 & 山海内丹）
  - `shot_06_title_card.mp4`（4s · 血月孤剑《战场兄弟：武侠江湖》片名定格）
- **6 张 2K 宽银幕关键帧**（`promo/keyframes/`，`2752×1536` / `2560×1440`，也可直接用作 B 站封面 / Steam 宣传头图 / 帖子配图）
- **独立配乐与配音音轨**（`promo/audio/`）：
  - `trailer_bgm_38s.mp3`（38.0 秒定制纯器乐暗黑国风战鼓/古筝/尺八/二胡预告片配乐）
  - `trailer_vo_zh.mp3`（36.6 秒低沉中文叙事旁白）
- **实机资产合成参考板**（`promo/assets/`）：由仓库 `art/busts/` 像素级拼装的 5 位实机侠客胸像及 5 张分幕参考拼板（`ref_01` ~ `ref_05`）

