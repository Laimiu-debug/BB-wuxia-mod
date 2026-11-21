// World, Town Shop, Relations, Post-Battle Loot & Attribute Tooltip Synchronization Hooks

::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/topbar/world_screen_topbar_options_module", function( q )
{
	::Wuxia.UI.attachSectTeaHouseRPCs(q);
});

::Wuxia.HooksMod.hook("scripts/ui/screens/world/world_relations_screen", function( q )
{
	::Wuxia.UI.attachSectTeaHouseRPCs(q);
});

// Town Shop: 1-click sweep into 藏经阁 + auto-sweep newly purchased manuals/pages on leaving shop (respecting WithdrawnForSale)
::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_shop_dialog_module", function( q )
{
	q.onWXSweepShopManuals <- function( _data = null )
	{
		if (!("World" in getroottable()) || ::World == null || ::World.Assets == null)
			return { ok = false, reason = "当前无法访问战团仓库。" };

		local stash = ::World.Assets.getStash();
		local moved = ::Wuxia.Library.storeAllFromStash(stash, true);
		local msg = "";
		if (moved.booksMoved > 0 || moved.pagesMoved > 0)
		{
			local parts = [];
			if (moved.booksMoved > 0) parts.push(moved.booksMoved + " 册秘籍");
			if (moved.pagesMoved > 0) parts.push(moved.pagesMoved + " 张残页");
			msg = "已将仓库内 " + parts[0] + (parts.len() > 1 ? ("、" + parts[1]) : "") + " 归入【藏经阁】，释放 " + moved.slotsCleared + " 格仓库空间！";
		}
		else
		{
			msg = "当前战团仓库中暂无可收纳的秘籍或残页。";
		}

		local stashUI = ::UIDataHelper.convertStashToUIData(false, this.m.InventoryFilter);
		return {
			ok             = true,
			movedCount     = moved.booksMoved + moved.pagesMoved,
			actionMessage  = msg,
			Stash          = stashUI,
			StashSpaceUsed = stash.getNumberOfFilledSlots(),
			StashSpaceMax  = stash.getCapacity()
		};
	};

	if ("onLeaveButtonPressed" in q)
	{
		q.onLeaveButtonPressed = @(__original) function()
		{
			if (::Wuxia.Library.isAutoStoreEnabled() && ("World" in getroottable()) && ::World != null && ::World.Assets != null)
			{
				local stash = ::World.Assets.getStash();
				if (stash != null)
					::Wuxia.Library.storeAllFromStash(stash, false);
			}
			__original();
		};
	}
});

// Post-Battle Combat Result Screen: Protect dropped manuals/pages from full-Stash loss by sweeping directly into 藏经阁!
::Wuxia.HooksMod.hook("scripts/ui/screens/tactical/tactical_combat_result_screen", function( q )
{
	q.WX_sweepLootAndStashToLibrary <- function( _includeWithdrawn = false )
	{
		local booksMoved = 0;
		local pagesMoved = 0;

		if ("Tactical" in getroottable() && ::Tactical != null && ("CombatResultLoot" in ::Tactical) && ::Tactical.CombatResultLoot != null)
		{
			local lootSweep = ::Wuxia.Library.storeAllFromStash(::Tactical.CombatResultLoot, true);
			booksMoved += lootSweep.booksMoved;
			pagesMoved += lootSweep.pagesMoved;
		}
		if ("World" in getroottable() && ::World != null && ::World.Assets != null && ::World.Assets.getStash() != null)
		{
			local stashSweep = ::Wuxia.Library.storeAllFromStash(::World.Assets.getStash(), _includeWithdrawn);
			booksMoved += stashSweep.booksMoved;
			pagesMoved += stashSweep.pagesMoved;
		}
		return {
			booksMoved = booksMoved,
			pagesMoved = pagesMoved
		};
	};

	q.onWXSweepCombatLootManuals <- function( _data = null )
	{
		local swept = this.WX_sweepLootAndStashToLibrary(true);
		local msg = "";
		if (swept.booksMoved > 0 || swept.pagesMoved > 0)
		{
			local parts = [];
			if (swept.booksMoved > 0) parts.push(swept.booksMoved + " 册秘籍");
			if (swept.pagesMoved > 0) parts.push(swept.pagesMoved + " 张残页");
			msg = "已将战利品与仓库中 " + parts[0] + (parts.len() > 1 ? ("、" + parts[1]) : "") + " 直接归入【藏经阁】（不占仓库格）！";
		}
		else
		{
			msg = "战利品与仓库中暂无可收纳的武学秘籍或残页。";
		}

		local res = {
			ok             = true,
			movedCount     = swept.booksMoved + swept.pagesMoved,
			wxSweepMessage = msg
		};
		if (::Wuxia.hasMember(this, "onQueryStashList"))
			res.stash <- this.onQueryStashList();
		else if ("World" in getroottable() && ::World != null && ::World.Assets != null)
			res.stash <- ::UIDataHelper.convertStashToUIData(false);

		if (::Wuxia.hasMember(this, "onQueryFoundLootList"))
			res.foundLoot <- this.onQueryFoundLootList();
		else if ("Tactical" in getroottable() && ::Tactical != null && ("CombatResultLoot" in ::Tactical) && ::Tactical.CombatResultLoot != null)
			res.foundLoot <- ::UIDataHelper.convertItemsToUIData(::Tactical.CombatResultLoot.getItems(), false, "tactical-combat-result-screen.found-loot");
		return res;
	};

	if ("onLootAllItemsButtonPressed" in q)
	{
		q.onLootAllItemsButtonPressed = @(__original) function()
		{
			local preSwept = { booksMoved = 0, pagesMoved = 0 };
			if (::Wuxia.Library.isAutoStoreEnabled())
			{
				preSwept = this.WX_sweepLootAndStashToLibrary(false);
			}
			local ret = __original();
			if (typeof ret == "table" && (preSwept.booksMoved > 0 || preSwept.pagesMoved > 0))
			{
				local parts = [];
				if (preSwept.booksMoved > 0) parts.push(preSwept.booksMoved + " 册秘籍");
				if (preSwept.pagesMoved > 0) parts.push(preSwept.pagesMoved + " 张残页");
				ret.wxSweepMessage <- "缴获的 " + parts[0] + (parts.len() > 1 ? ("、" + parts[1]) : "") + " 已自动归入【藏经阁】（不占仓库格）！";
			}
			return ret;
		};
	}
});

// Synchronize ALL UI Element Hover Tooltips (New Campaign, Character/Tactical Stats, Town Buildings, World Topbar) with Wuxia Lore & Mechanics!
::Wuxia.HooksMod.hook("scripts/ui/screens/tooltip/tooltip_events", function( q )
{
	local wxFullTooltips = {
		// 1. New Campaign Screen (`menu-screen.new-campaign.*`)
		["menu-screen.new-campaign.CompanyName"]              = ["义社名号", "立下你的江湖字号。此名号将书写于聚义竖幅大纛、官府文牒与九州茶肆评书之中。"],
		["menu-screen.new-campaign.StartingScenario"]         = ["江湖出身流派", "择定开山立社的出身来历——不同流派拥有截然不同的初始掌门侠客、独门功法、盘缠与江湖规矩。"],
		["menu-screen.new-campaign.Seed"]                     = ["山河气运种子", "决定九州山川城池、名山秘境与各路豪杰排布的舆图气运字符；输入相同种子即可重历同一片江湖。"],
		["menu-screen.new-campaign.EvilRandom"]               = ["天机莫测（随机大势）", "待义社威名渐盛之时，天下将随机掀起一场席卷九州的武林与朝堂大浩劫；平定首劫后，其余大势亦将陆续登场。"],
		["menu-screen.new-campaign.EvilWar"]                  = ["藩镇节度争霸", "各大地方藩镇节度使拥兵自重、撕破朝廷盟约，披甲长戟大军与神机火器营将在中原展开血腥攻城争霸。"],
		["menu-screen.new-campaign.EvilGreenskins"]           = ["南疆五毒与药人犯境", "南疆五毒奇门伏兵与关外邪派炼体药人合流北上，剧毒吹箭与狂暴巨刃大举席卷中原村镇。"],
		["menu-screen.new-campaign.EvilUndead"]               = ["前朝玄宫尸傀浩劫", "地脉阴煞暴涨，前朝古墓青铜机关兵俑与湘西控魂妖道驱使不惧生死的尸傀大军破土而出，祸乱苍生。"],
		["menu-screen.new-campaign.EvilCrusade"]              = ["西域都护与中原兵燹", "西域绿洲诸城邦与北方藩镇因圣物古迹与商路霸权兵戎相见，南北群豪皆被卷入万里烽烟。"],
		["menu-screen.new-campaign.EvilPermanentDestruction"] = ["兵燹焦土（城池可毁）", "乱世无情：在武林大势浩劫中被乱军、药人或尸傀攻破的村镇城池将化为永久断壁残垣，不再重建。"],
		["menu-screen.new-campaign.EasyDifficulty"]           = ["江湖凶险：初窥门径", "各路绿林匪类与邪派强敌人数较少、境界尚浅，适合初入武侠江湖熟悉七槽内功与外功连招。"],
		["menu-screen.new-campaign.NormalDifficulty"]         = ["江湖凶险：刀口舔血", "标准乱世险恶程度，强敌环伺、高手辈出，一步踏错便有折损同袍之虞。"],
		["menu-screen.new-campaign.HardDifficulty"]           = ["江湖凶险：九死一生", "匪寨重兵云集、成名高手与上古大妖层出不穷，唯有深谙轻重装武学搭配与阵法进退者方能立足。"],
		["menu-screen.new-campaign.EasyDifficultyEconomic"]   = ["行商生计：宽裕", "州府悬赏酬银丰厚，市集粮草与秘籍折价更优，易于养活麾下侠客。"],
		["menu-screen.new-campaign.NormalDifficultyEconomic"] = ["行商生计：常道", "乱世寻常物价与悬赏行情，需精打细算镖资、粮草与购置秘籍丹药之开销。"],
		["menu-screen.new-campaign.HardDifficultyEconomic"]   = ["行商生计：窘迫", "乱世米珠薪桂、委托酬银微薄，市集买卖差价严苛，每一两纹银皆需刀头换取。"],
		["menu-screen.new-campaign.EasyDifficultyBudget"]     = ["起家盘缠：丰厚", "初入江湖时行囊中备有充裕纹银、干粮与百工资材，可从容招揽好手。"],
		["menu-screen.new-campaign.NormalDifficultyBudget"]   = ["起家盘缠：寻常", "携适量盘缠与干粮踏入江湖，需尽早接取州县差事以充实库藏。"],
		["menu-screen.new-campaign.HardDifficultyBudget"]     = ["起家盘缠：囊中羞涩", "开局仅有微薄碎银与数日粗粮，全凭手中兵刃白手起家。"],
		["menu-screen.new-campaign.Ironman"]                  = ["生死无悔（铁人单档）", "江湖落子无悔：全程仅保留单一自动存档，不可手动回档重来，每一次生死抉择皆成定局。"],
		["menu-screen.new-campaign.Exploration"]              = ["迷雾山河（舆图未探）", "九州城池与道路初始隐没于云雾之中，需亲自策马探路寻访各州府重镇。"],

		// 2. Character & Tactical Attributes (`character-stats.*`)
		["character-stats.Hitpoints"]      = ["气血", "侠客肉身气血之本，归零即重伤倒地乃至殒命。轻装修《金蝉卸力》与真气护体可化劲减伤（总上限 60%）；重甲修《铁布衫》可获气血加持与铜头铁额免爆头重创。"],
		["character-stats.ActionPoints"]   = ["招式行动点 (AP)", "每回合走位腾挪与施展外功绝招可用的行动点。常人基准 9 AP，全局常驻硬封顶 11 AP（唯极少数孤本三重大成可破境）。"],
		["character-stats.Fatigue"]        = ["丹田内息", "施展外功招式、轻功身法及格挡受击皆会消耗内息。沉重甲胄与兵刃负重会折损可用内息上限（重甲硬功『披甲行气』可减免负重）；辅修第 2 门内功常驻内息与回气按 50% 折算。"],
		["character-stats.MaximumFatigue"] = ["内息上限", "丹田所能蓄纳的最大真气总量。沉重衣甲与兵刃会占用部分内息上限；主修内功心法决定回气路数（中正/阳刚/阴柔/邪功）与每轮调息回气效率。"],
		["character-stats.Bravery"]        = ["武道定力", "临阵不乱的心性与胆魄。定力不仅抵御战意动摇与邪祟惊魂，更直接提升『洗经伐髓』成功率、满足高阶秘籍突破门槛，并驱动《聚义令》四格稳军心光环。"],
		["character-stats.Initiative"]     = ["轻功身法", "决定每回合出手快慢先后；受当前已耗内息与衣甲负重影响。修习轻功后可将有效身法按比例（15%~20%）实时转化为近身招架与听风避暗。"],
		["character-stats.MeleeSkill"]     = ["近战武艺", "决定刀剑、拳掌、枪戟、锤斧等近身兵刃的命中机率（D100 线性检定，5%~95% 硬边界）。兼修多门外功时常驻武艺加成取最高值，主动招式池可合并。"],
		["character-stats.RangeSkill"]     = ["百步射艺", "决定良弓、强弩、甩手暗器与神机火铳的远距命中机率。配合弓术或唐门暗器谱可施展毒针封穴、流星追月等绝技。"],
		["character-stats.MeleeDefense"]   = ["近身招架", "拆解卸开敌方近身兵刃攻势之机率。由角色根骨、外功守势、手中藤牌铁盾与轻功身法转化共同构筑。"],
		["character-stats.RangeDefense"]   = ["听风避暗", "闪避拨落敌方箭矢、吹箭与飞镖暗器之机率。轻功身法与护身盾牌可大幅提升避暗造诣。"],
		["character-stats.Morale"]         = ["临阵战意", "侠客当下的斗志状态（自信昂扬 → 沉着 → 动摇 → 胆寒 → 溃逃）。战意高涨可获攻防精进，溃败则失魂落魄。"],
		["character-stats.ArmorHead"]      = ["头部护甲", "冠笠兜鍪可替天灵要穴承受兵刃劈刺；一旦护甲碎尽，头部受击将承受额外重创（修习『铜头铁额』可免疫爆头额外倍率）。"],
		["character-stats.ArmorBody"]      = ["身躯护甲", "战袍甲胄可吸收敌方实伤冲击；唯高穿甲内劲拳掌、透甲锥匕与重锤破甲劲力能隔甲伤及肺腑。"],
		["character-stats.RegularDamage"]  = ["兵刃气血伤害", "命中敌手时所造成的基础劈刺内劲伤害区间；若敌方有护甲，将按穿甲率直接透伤气血。"],
		["character-stats.CrushingDamage"] = ["破甲震击效能", "命中护甲时削损敌方甲胄耐久之倍率；锤锏大斧与阳刚重兵尤为擅长摧甲裂盾。"],
		["character-stats.ChanceToHitHead"]= ["取首命中率", "出招直击敌方天灵头部的机率；连枷软鞭与特定外功杀招更易越盾取首。"],
		["character-stats.SightDistance"]  = ["目力视野", "战场可洞察敌踪与施展远射的距离格数；黑夜、密林与覆面重盔会遮蔽目力。"],
		["character-stats.Talent"]         = ["武学根骨星级", "该项属性的天生经脉资质（1★~3★），升级加点时可获更高成长下限；亦可通过服用『洗髓丹』冲星或易筋换星（全身最多维持三项带星根骨）。"],

		// 3. Town Screen Buildings (`world-town-screen.main-dialog-module.*`)
		["world-town-screen.main-dialog-module.Crowd"]        = ["江湖招贤茶摊", "各路走镖趟子手、行脚武僧、退隐剑客与落魄武人在此歇脚寻东家；可查看身价、切磋看相并招揽入伙。"],
		["world-town-screen.main-dialog-module.Marketplace"]  = ["州县百货集市", "南北客商云集的繁华街市，可采买行军干粮、百工修甲资材、箭矢药材及寻常布衣兵刃，亦可售卖战利货物。"],
		["world-town-screen.main-dialog-module.Tavern"]       = ["迎风八方酒楼", "三教九流把酒高歌之地：可犒赏美酒提振同袍心情，亦可向酒保打听四方秘宝传闻、宗门动向与山海异兽踪迹。"],
		["world-town-screen.main-dialog-module.Temple"]       = ["古刹济世医馆", "名医高僧坐堂施诊，可耗费纹银为麾下侠客金针拔毒、正骨接筋，迅速治愈各类跌打刀伤与经脉内伤。"],
		["world-town-screen.main-dialog-module.Weaponsmith"]  = ["百炼神兵铁铺", "炉火纯青的刀剑名匠坐镇，专售百炼长剑、雁翎快刀、破甲重锤、成对拳掌护手及偶现人间的传世红武。"],
		["world-town-screen.main-dialog-module.Armorsmith"]   = ["精工玄甲坊", "裁缝劲装锦袍、锻造山文重甲、扎甲战笠与百炼铁盾的官督甲坊，偶有巧夺天工的名家宝甲压箱。"],
		["world-town-screen.main-dialog-module.Fletcher"]     = ["神机弓弩铺", "专制桑木角弓、踏张劲弩、诸葛连珠弩与满袋雕翎破甲箭矢的巧匠铺面。"],
		["world-town-screen.main-dialog-module.TrainingHall"] = ["讲武堂演武院", "前朝退隐教头开设的演武大院，可出资请名师指点麾下侠客拆招喂招，在数场实战中获得额外武学历练加成。"],
		["world-town-screen.main-dialog-module.Taxidermist"]  = ["百工猎妖炼丹房", "内设青铜八卦丹炉与百工案台，可将斩杀异兽大妖所得的山海内丹、奇骨毒腺炼制成『洗髓丹』『护脉丹』与传世神装。"],
		["world-town-screen.main-dialog-module.Alchemist"]    = ["西域火器奇珍局", "售卖霹雳雷火弹、唐门五云烟弹、蚀甲化骨毒瓶、神机手铳火药及西域秘制灵散的奇巧商局。"],
		["world-town-screen.main-dialog-module.Arena"]        = ["红绸生死演武擂", "每日开擂的三对三生死演武场，登台力挫群雄不仅可赢取丰厚彩头纹银，更能铸就不败擂主威名。"],
		["world-town-screen.main-dialog-module.Port"]         = ["漕运硬帆官渡口", "可支付船资雇请硬帆福船顺江海航道疾行千里，瞬息往返南北沿海港埠。"],
		["world-town-screen.main-dialog-module.Barber"]       = ["铜镜江湖易容铺", "可自由定制麾下侠客的面容相貌、发髻发色与胡须战痕。"],
		["world-town-screen.main-dialog-module.Kennel"]       = ["塞外猛獒驯犬坊", "售卖凶悍忠心的关外猛獒与护院猎犬，临阵放出可追剿残敌、牵制弓手。"],
		["world-town-screen.main-dialog-module.Contract"]     = ["官府与乡绅榜文委托", "点击接洽此项江湖差事，商议酬银并听取委托原委（骷髅数代表凶险品阶）。"],
		["world-town-screen.main-dialog-module.ContractNegotiated"] = ["已议定酬银之差事", "已与东家谈妥酬银条款，随时可拍板应承动身。"],
		["world-town-screen.main-dialog-module.ContractLocked"]     = ["威名未显 · 尚难接洽", "此乃地方藩镇或名门重托，需义社江湖声望更高或有随行说客引荐方肯委任。"],
		["world-town-screen.main-dialog-module.LeaveButton"]        = ["出城起行", "整顿人马离开此城，重返九州大地图。"],

		// 4. World Topbar Assets & Character Screen Buttons
		["assets.Money"]              = ["纹银盘缠", "行囊现存纹银两数，用于发放同袍每日月俸、采买粮草兵甲、请教门派秘籍与炼丹竞拍。"],
		["assets.DailyMoney"]         = ["每日月俸开销", "麾下全体侠客每日所需的饷银合计；银钱断绝将致人心思变、愤然离队。"],
		["assets.Food"]               = ["行军干粮", "随军携行的米面熏肉果脯总量；断粮挨饿将令同袍内息衰弱、怨声载道。"],
		["assets.DailyFood"]          = ["每日口粮消耗", "全队人马每日行军所需的口粮份额。"],
		["assets.Ammo"]               = ["箭矢与火药储备", "战后自动为弓弩、投掷暗器囊与神机火铳补充弹药的随军储备。"],
		["assets.Supplies"]           = ["百工修甲资材", "精铁甲片、熟革麻绳与磨刀石，行军与扎营时自动修复受损兵刃与护甲。"],
		["assets.Medicine"]           = ["金疮灵药储备", "三七金疮散、夹板与汤药，每日自动救治同袍身上的内外创伤与疾病。"],
		["assets.Brothers"]           = ["麾下同袍人数", "义社当前在册侠客人数与上阵/替补编制上限。"],
		["assets.BusinessReputation"] = ["江湖声望", "义社在九州黑白两道闯出的赫赫威名；声望越高，越能接取藩镇重托并在茶楼结交大派名宿。"],
		["assets.MoralReputation"]    = ["侠义风评", "义社行事守信抑或心狠手辣的江湖风评，影响部分正邪奇遇走向。"],
		["assets.Ambition"]           = ["当前江湖志向", "义社当下立誓达成的声望目标；功成之日将名动一方、振奋全军斗志。"],
		["character-screen.right-panel-header-module.InventoryButton"] = ["兵甲行囊", "查阅并调配全队公用仓库中的兵刃、甲胄、丹药与山海奇材。"],
		["character-screen.right-panel-header-module.PerksButton"]     = ["武学修为（七槽经脉）", "进入该侠客的七大武学插槽、个人已习武库与洗经伐髓修行界面。"],
		["character-screen.left-panel-header-module.Dismiss"]          = ["遣散归乡", "赠予路费或令该名侠客解甲归田、重返江湖人海。"],
		["world-screen.topbar.options-module.ActiveContractButton"]    = ["当前江湖委托卷宗", "展开或收起正在履行的差事榜文要略。"],
		["world-screen.topbar.options-module.RelationsButton"]         = ["朝堂藩镇与江湖宗门", "查阅各大地方藩镇、西域城邦交情，并可一键展开『九州四十四宗门名刺录』。"],
		["world-screen.topbar.options-module.CampButton"]              = ["安营扎寨调息", "就地驻马扎营，加快气血疗伤与兵甲修缮，并可打理随营幕僚奇人。"],
		["world-screen.topbar.options-module.ObituaryButton"]          = ["忠烈英魂录", "缅怀自开山立社以来血洒疆场、马革裹尸的逝去同袍。"],
		["world-screen.topbar.options-module.PerksButton"]             = ["随营幕僚与行营总览", "打开篝火行营界面，延请丹鼎方士、百炼随匠、杏林医官等十八路江湖奇人辅佐义社。"]
	};

	if (!("UI" in ::Wuxia)) ::Wuxia.UI <- {};
	::Wuxia.UI.FullTooltips <- wxFullTooltips;

	::Wuxia.UI.harmonizeTooltipArray <- function( _arr )
	{
		if (_arr == null || typeof _arr != "array") return _arr;
		if (!("Purify" in ::Wuxia) || !("rewriteCurrencyAndSupplyTerms" in ::Wuxia.Purify)) return _arr;
		for (local i = 0; i < _arr.len(); i = ++i)
		{
			local row = _arr[i];
			if (row != null && typeof row == "table")
			{
				if (("text" in row) && typeof row.text == "string")
					row.text = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(row.text);
				if (("label" in row) && typeof row.label == "string")
					row.label = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(row.label);
				if (("children" in row) && typeof row.children == "array")
					::Wuxia.UI.harmonizeTooltipArray(row.children);
			}
		}
		return _arr;
	};

	::Wuxia.UI.applyElementTooltip <- function( _elementId, _ret )
	{
		if (_elementId != null && ("FullTooltips" in ::Wuxia.UI) && (_elementId in ::Wuxia.UI.FullTooltips))
		{
			local spec = ::Wuxia.UI.FullTooltips[_elementId];
			if (_ret == null || typeof _ret != "array" || _ret.len() == 0)
			{
				return [
					{ id = 1, type = "title", text = spec[0] },
					{ id = 2, type = "description", text = spec[1] }
				];
			}
			local replacedTitle = false;
			local replacedDesc  = false;
			for (local i = 0; i < _ret.len(); i = ++i)
			{
				if (typeof _ret[i] == "table" && ("type" in _ret[i]))
				{
					if (_ret[i].type == "title" && !replacedTitle)
					{
						_ret[i].text = spec[0];
						replacedTitle = true;
					}
					else if (_ret[i].type == "description" && !replacedDesc)
					{
						_ret[i].text = spec[1];
						replacedDesc = true;
					}
				}
			}
			if (!replacedTitle)
				_ret.insert(0, { id = 1, type = "title", text = spec[0] });
			if (!replacedDesc)
				_ret.insert(1, { id = 2, type = "description", text = spec[1] });
		}
		return ::Wuxia.UI.harmonizeTooltipArray(_ret);
	};

	// Bind directly onto instantiated `tooltip_events` in `AfterHooks` so Wuxia stat/UI tooltips
	// always win even if `mod_bbmod_zhcn` wraps `tooltip_events` via `mods_hookNewObject`!
	::Wuxia.UI.bindTooltipEventsInstance <- function( _obj )
	{
		if (_obj == null || typeof _obj != "table") return;
		if ("WX_TooltipInstanceBound" in _obj && _obj.WX_TooltipInstanceBound) return;
		_obj.WX_TooltipInstanceBound <- true;

		foreach (elFn in ["general_queryUIElementTooltipData", "strategic_queryUIElementTooltipData", "tactical_queryUIElementTooltipData"])
		{
			if (::Wuxia.hasMember(_obj, elFn) && typeof _obj[elFn] == "function")
			{
				local origFn = _obj[elFn];
				_obj[elFn] <- (function( _entityId, _elementId, _elementOwner )
				{
					local ret = origFn.call(this, _entityId, _elementId, _elementOwner);
					return ::Wuxia.UI.applyElementTooltip(_elementId, ret);
				}).bindenv(_obj);
			}
		}

		foreach (arrFn in [
			"general_querySkillTooltipData",
			"general_queryStatusEffectTooltipData",
			"tactical_queryUIItemTooltipData",
			"strategic_queryUIItemTooltipData",
			"tactical_queryTileTooltipData"
		])
		{
			if (::Wuxia.hasMember(_obj, arrFn) && typeof _obj[arrFn] == "function")
			{
				local origArrFn = _obj[arrFn];
				_obj[arrFn] <- (function( ... )
				{
					local args = [this];
					for (local a = 0; a < vargv.len(); a = ++a)
						args.push(vargv[a]);
					local ret = origArrFn.acall(args);
					return ::Wuxia.UI.harmonizeTooltipArray(ret);
				}).bindenv(_obj);
			}
		}
	};

	foreach (elFnName in ["general_queryUIElementTooltipData", "strategic_queryUIElementTooltipData", "tactical_queryUIElementTooltipData"])
	{
		if (elFnName in q)
		{
			q[elFnName] = @(__original) function( _entityId, _elementId, _elementOwner )
			{
				local ret = __original(_entityId, _elementId, _elementOwner);
				return ::Wuxia.UI.applyElementTooltip(_elementId, ret);
			};
		}
	}
});

// Replace medieval European loading tips with authentic Wuxia Jianghu & Tactical rules
if ("Const" in getroottable() && "TipOfTheDay" in ::Const)
{
	::Const.TipOfTheDay = [
		"内息与疲劳同源：沉重甲胄虽能抵御刀剑，却会大幅压制可用内息上限与身法；轻装侠客则宜修《金蝉卸力》与阴柔真气护体。",
		"角色在 1、3、5、7、9、11 级共解锁 7 大武学插槽，单人至多兼修 2 门内功与 2 门轻功，辅修第二门内功常驻内息与回气折半。",
		"所有武功秘籍与残页皆可归入『藏经阁』不占仓库格管理；角色研习领悟秘籍后永久记入个人武库，方可在『武学修为』页自由选装入槽。",
		"兼修多门外功或轻功时，主动绝招池可合并施展，但同系常驻攻防面板与穿甲、破甲、身法转防比例一律取最高值（不线性累加）。",
		"闲置残页无需压箱底：可在藏经阁一键拼合成书、2:1 同阶融会补缺，或直接对未满重武学槽『参悟化功』注入火候！",
		"洗经伐髓可助侠客冲星或易筋换星：提前调满气血、提升主修内功重数并辅服「护脉丹」，可显著提高胜算并免留永久暗疾。",
		"拳掌指爪护手成对占满主副手，出招仅耗 4 AP，专擅高穿甲内劲、封穴震慑与空手夺白刃，乃重甲硬功之克星。",
		"单手持刀剑而空出副手，既得双握增伤，配合杂学《孤锋诀》更可补足穿甲锋芒，潇洒破敌。",
		"统帅杂学《聚义令》将振奋军心号令解绑出战旗武器——掌门手持本命刀剑亦能稳住全队定力，力抗湘西尸傀与古墓邪祟。",
		"行经中原、名山、巴蜀、水泽、关外、大漠六大地域城镇茶肆时，可查阅『江湖名刺录』择席结交当地宗门、请教独门秘籍。"
	];
}
