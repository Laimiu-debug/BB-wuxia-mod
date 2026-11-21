// Declarative Expansion Registry: +32 Shan Hai Baigong Gear, +20 Shan Hai Divine Red Weapons, +32 Neidan Cores & 96-Core Resonance

// 1. Tag existing 2 Shan Hai Relics & register +20 new Shan Hai Divine Red Weapons (`39 -> 59` Relics, `2 -> 22` Shan Hai!)
if ("wx_relic_xingtianqi" in ::Wuxia.Config.RelicWeapons) ::Wuxia.Config.RelicWeapons.wx_relic_xingtianqi.IsShanHai <- true;
if ("wx_relic_qiongqizhao" in ::Wuxia.Config.RelicWeapons) ::Wuxia.Config.RelicWeapons.wx_relic_qiongqizhao.IsShanHai <- true;

::Wuxia.Config.RelicWeapons.wx_relic_yinglongjian <- {
	ID = "wx_relic_yinglongjian", Name = "应龙斩魔蓄水剑", Family = "Sword", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_yinglongjian", BaseNamedScript = "scripts/items/weapons/named/named_sword",
	MinValue = 8200, Categories = null,
	CustomIcon = "weapons/named/wx_relic_yinglongjian_70x70.png", CustomIconLarge = "weapons/named/wx_relic_yinglongjian.png", CustomArmamentIcon = null,
	Description = "《大荒东经》应龙逆鳞珠混百炼寒钢精铸的上古神剑，青铜龙翼护手吞吐沧海寒芒，削铁破甲如探囊取物。"
};
::Wuxia.Config.RelicWeapons.wx_relic_zhuyinjian <- {
	ID = "wx_relic_zhuyinjian", Name = "烛九阴寒暑两仪巨剑", Family = "Sword", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_zhuyinjian", BaseNamedScript = "scripts/items/weapons/named/named_greatsword",
	MinValue = 8600, Categories = null,
	CustomIcon = "weapons/named/wx_relic_zhuyinjian_70x70.png", CustomIconLarge = "weapons/named/wx_relic_zhuyinjian.png", CustomArmamentIcon = null,
	Description = "取钟山烛龙昼夜龙珠重铸的阴阳双色巨剑，左刃凝万载玄霜、右刃燃大日赤火，一剑横扫寒暑皆灭！"
};
::Wuxia.Config.RelicWeapons.wx_relic_jinwudao <- {
	ID = "wx_relic_jinwudao", Name = "汤谷金乌十日焚天刀", Family = "Saber", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_jinwudao", BaseNamedScript = "scripts/items/weapons/named/named_khopesh",
	MinValue = 8100, Categories = null,
	CustomIcon = "weapons/named/wx_relic_jinwudao_70x70.png", CustomIconLarge = "weapons/named/wx_relic_jinwudao.png", CustomArmamentIcon = null,
	Description = "扶桑三足金乌大日真丹入炉淬火的赤金弯刀，刀槽流淌熔金火纹，刀出如烈日灼空、割肉焚甲。"
};
::Wuxia.Config.RelicWeapons.wx_relic_taowudao <- {
	ID = "wx_relic_taowudao", Name = "荒中檮杌傲狠断岳刀", Family = "Cleaver", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_taowudao", BaseNamedScript = "scripts/items/weapons/named/named_crypt_cleaver",
	MinValue = 8500, Categories = null,
	CustomIcon = "weapons/named/wx_relic_taowudao_70x70.png", CustomIconLarge = "weapons/named/wx_relic_taowudao.png", CustomArmamentIcon = null,
	Description = "四大凶兽檮杌凶魂丹配脊骨重铁锻成的锯背狂刀，虎口吞刃凶戾绝伦，当者披靡。"
};
::Wuxia.Config.RelicWeapons.wx_relic_xiangliuqiang <- {
	ID = "wx_relic_xiangliuqiang", Name = "共工相柳九首蚀骨枪", Family = "Spear", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_xiangliuqiang", BaseNamedScript = "scripts/items/weapons/named/named_spear",
	MinValue = 8000, Categories = null,
	CustomIcon = "weapons/named/wx_relic_xiangliuqiang_70x70.png", CustomIconLarge = "weapons/named/wx_relic_xiangliuqiang.png", CustomArmamentIcon = null,
	Description = "九首相柳苦毒源珠镶嵌吞口的青铜九蛇盘首枪，螺旋暗刃专透重铠护心镜。"
};
::Wuxia.Config.RelicWeapons.wx_relic_gonggongshuo <- {
	ID = "wx_relic_gonggongshuo", Name = "不周共工怒触天倾槊", Family = "Spear", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_gonggongshuo", BaseNamedScript = "scripts/items/weapons/named/named_spetum",
	MinValue = 8500, Categories = null,
	CustomIcon = "weapons/named/wx_relic_gonggongshuo_70x70.png", CustomIconLarge = "weapons/named/wx_relic_gonggongshuo.png", CustomArmamentIcon = null,
	Description = "融不周山共工黑水珠与寒铁龙鳞杆锻就的破阵大槊，两格攒刺势若天柱倾塌！"
};
::Wuxia.Config.RelicWeapons.wx_relic_qiangliangge <- {
	ID = "wx_relic_qiangliangge", Name = "北山强良虎首衔蛇戈", Family = "Polearm", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_qiangliangge", BaseNamedScript = "scripts/items/weapons/named/named_billhook",
	MinValue = 8400, Categories = null,
	CustomIcon = "weapons/named/wx_relic_qiangliangge_70x70.png", CustomIconLarge = "weapons/named/wx_relic_qiangliangge.png", CustomArmamentIcon = null,
	Description = "仿《大荒北经》凶神强良法相精铸的虎首衔赤蛇青铜重戈戟，钩拉劈刺招招夺命。"
};
::Wuxia.Config.RelicWeapons.wx_relic_jiufengji <- {
	ID = "wx_relic_jiufengji", Name = "北极九凤泣血摄魂戟", Family = "Polearm", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_jiufengji", BaseNamedScript = "scripts/items/weapons/named/named_swordlance",
	MinValue = 8400, Categories = null,
	CustomIcon = "weapons/named/wx_relic_jiufengji_70x70.png", CustomIconLarge = "weapons/named/wx_relic_jiufengji.png", CustomArmamentIcon = null,
	Description = "大荒北极九首妖皇泣血珠祭炼的暗红羽翼眉尖大戟，扇面横扫血雾漫天。"
};
::Wuxia.Config.RelicWeapons.wx_relic_kuafuzhang <- {
	ID = "wx_relic_kuafuzhang", Name = "逐日夸父邓林盘桃杖", Family = "Staff", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_kuafuzhang", BaseNamedScript = "scripts/items/weapons/named/named_two_handed_mace",
	MinValue = 8300, Categories = "棍棒, 双手",
	CustomIcon = "weapons/named/wx_relic_kuafuzhang_70x70.png", CustomIconLarge = "weapons/named/wx_relic_kuafuzhang.png", CustomArmamentIcon = null,
	Description = "《海外北经》夸父弃杖化邓林之千年焦桃神木心重箍熟铜而成，重逾百斤，完美催动天下棍杖绝学！"
};
::Wuxia.Config.RelicWeapons.wx_relic_luwuzhao <- {
	ID = "wx_relic_luwuzhao", Name = "昆仑陆吾司天九尾爪", Family = "Fist", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_luwuzhao", BaseNamedScript = "scripts/items/weapons/named/wx_named_fist",
	MinValue = 8200, Categories = null,
	CustomIcon = "weapons/named/wx_relic_luwuzhao_70x70.png", CustomIconLarge = "weapons/named/wx_relic_luwuzhao.png", CustomArmamentIcon = null,
	Description = "昆仑镇神陆吾九部帝丹配白虎利爪精锻的成对护手（占双手槽，4 AP 疾攻），寸劲透甲裂骨碎脏！"
};
::Wuxia.Config.RelicWeapons.wx_relic_kuiguchui <- {
	ID = "wx_relic_kuiguchui", Name = "流波夔牛震天雷骨锤", Family = "Hammer", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_kuiguchui", BaseNamedScript = "scripts/items/weapons/named/named_two_handed_hammer",
	MinValue = 8600, Categories = null,
	CustomIcon = "weapons/named/wx_relic_kuiguchui_70x70.png", CustomIconLarge = "weapons/named/wx_relic_kuiguchui.png", CustomArmamentIcon = null,
	Description = "以流波山雷兽夔牛独足巨骨包紫电玄铜铸成的万钧战锤，轰落之际铁甲重盾尽化齑粉！"
};
::Wuxia.Config.RelicWeapons.wx_relic_bojian <- {
	ID = "wx_relic_bojian", Name = "中曲铁驳食虎独角锏", Family = "Hammer", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_bojian", BaseNamedScript = "scripts/items/weapons/named/named_warhammer",
	MinValue = 7900, Categories = null,
	CustomIcon = "weapons/named/wx_relic_bojian_70x70.png", CustomIconLarge = "weapons/named/wx_relic_bojian.png", CustomArmamentIcon = null,
	Description = "取《中山经》食虎豹猛兽铁驳之螺旋钢角配铁驳战丹打制的单手重锏，隔甲碎骨专克横练。"
};
::Wuxia.Config.RelicWeapons.wx_relic_chiyoufu <- {
	ID = "wx_relic_chiyoufu", Name = "凶黎蚩尤五兵裂天钺", Family = "Axe", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_chiyoufu", BaseNamedScript = "scripts/items/weapons/named/named_bardiche",
	MinValue = 8800, Categories = null,
	CustomIcon = "weapons/named/wx_relic_chiyoufu_70x70.png", CustomIconLarge = "weapons/named/wx_relic_chiyoufu.png", CustomArmamentIcon = null,
	Description = "万古兵主蚩尤铜头战魄亲铸制式的绿锈血纹青铜巨钺，开山断盾冠绝古今凶兵之首！"
};
::Wuxia.Config.RelicWeapons.wx_relic_mingshebian <- {
	ID = "wx_relic_mingshebian", Name = "鲜山鸣蛇四翼磬音鞭", Family = "Flail", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_mingshebian", BaseNamedScript = "scripts/items/weapons/named/named_battle_whip",
	MinValue = 7800, Categories = null,
	CustomIcon = "weapons/named/wx_relic_mingshebian_70x70.png", CustomIconLarge = "weapons/named/wx_relic_mingshebian.png", CustomArmamentIcon = null,
	Description = "鲜山四翼鸣蛇磬音胆与蛇脊乌钢编连的九节长鞭，挥动声如古磬，隔步抽面缴械无算。"
};
::Wuxia.Config.RelicWeapons.wx_relic_qinyuanbi <- {
	ID = "wx_relic_qinyuanbi", Name = "昆仑钦原蜇石蚀骨刺", Family = "Dagger", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_qinyuanbi", BaseNamedScript = "scripts/items/weapons/named/named_qatal_dagger",
	MinValue = 8000, Categories = null,
	CustomIcon = "weapons/named/wx_relic_qinyuanbi_70x70.png", CustomIconLarge = "weapons/named/wx_relic_qinyuanbi.png", CustomArmamentIcon = null,
	Description = "《西山经》蜇石则烂之昆仑毒皇钦原尾针配万蛊毒珠磨制的幽碧弯刺，专趁破绽失衡一刺穿心！"
};
::Wuxia.Config.RelicWeapons.wx_relic_hujiaobian <- {
	ID = "wx_relic_hujiaobian", Name = "玉山虎蛟裂甲铁链枷", Family = "Flail", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_hujiaobian", BaseNamedScript = "scripts/items/weapons/named/named_three_headed_flail",
	MinValue = 7900, Categories = null,
	CustomIcon = "weapons/named/wx_relic_hujiaobian_70x70.png", CustomIconLarge = "weapons/named/wx_relic_hujiaobian.png", CustomArmamentIcon = null,
	Description = "玉山虎蛟内丹配三枚蛟首毒牙钢锤扣连的奇门重连枷，越过铁盾直砸面门天灵。"
};
::Wuxia.Config.RelicWeapons.wx_relic_yingzhaogong <- {
	ID = "wx_relic_yingzhaogong", Name = "昆仑英招四海巡狩弓", Family = "Bow", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_yingzhaogong", BaseNamedScript = "scripts/items/weapons/named/named_warbow",
	MinValue = 8300, Categories = null,
	CustomIcon = "weapons/named/wx_relic_yingzhaogong_70x70.png", CustomIconLarge = "weapons/named/wx_relic_yingzhaogong.png", CustomArmamentIcon = null,
	Description = "天帝司圃神孽英招巡天金丹嵌弣、虎纹巨角合胎的九石神弓，一箭破云百步贯颅！"
};
::Wuxia.Config.RelicWeapons.wx_relic_gudiaonu <- {
	ID = "wx_relic_gudiaonu", Name = "鹿吴蛊雕裂颅重弩", Family = "Crossbow", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_gudiaonu", BaseNamedScript = "scripts/items/weapons/named/named_crossbow",
	MinValue = 8200, Categories = null,
	CustomIcon = "weapons/named/wx_relic_gudiaonu_70x70.png", CustomIconLarge = "weapons/named/wx_relic_gudiaonu.png", CustomArmamentIcon = null,
	Description = "鹿吴山攒角蛊雕王头骨与摄魂丹加持的乌钢踏张重弩，钢矢激射洞穿百炼重铠。"
};
::Wuxia.Config.RelicWeapons.wx_relic_huodouchong <- {
	ID = "wx_relic_huodouchong", Name = "厌火祸斗喷炎神铳", Family = "Firearm", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_huodouchong", BaseNamedScript = "scripts/items/weapons/named/named_handgonne",
	MinValue = 8400, Categories = null,
	CustomIcon = "weapons/named/wx_relic_huodouchong_70x70.png", CustomIconLarge = "weapons/named/wx_relic_huodouchong.png", CustomArmamentIcon = null,
	Description = "南荒厌火国食炭凶犬祸斗炎珠熔铸铳膛的兽口重火器，轰击之时烈焰铅砂吞没敌阵！"
};
::Wuxia.Config.RelicWeapons.wx_relic_tiangoubiao <- {
	ID = "wx_relic_tiangoubiao", Name = "阴山天狗坠星飞梭", Family = "Throwing", IsShanHai = true,
	Script = "scripts/items/weapons/named/wx_relic_tiangoubiao", BaseNamedScript = "scripts/items/weapons/named/named_javelin",
	MinValue = 7800, Categories = null,
	CustomIcon = "weapons/named/wx_relic_tiangoubiao_70x70.png", CustomIconLarge = "weapons/named/wx_relic_tiangoubiao.png", CustomArmamentIcon = null,
	Description = "阴山奔星天狗皇坠星核混天外白陨铁精锻的破盾重飞梭，出手如流星坠地、碎盾贯胸！"
};

// 2. Register +32 Shan Hai Masterwork Armors, Helmets, Famed Shields & Talismans (`8 -> 40` ShanHaiGear!)
::Wuxia.Config.ShanHaiGear.wx_armor_xuangui <- {
	ID = "wx_armor_xuangui", Kind = "armor", Name = "山海·杻阳玄龟镇海重铠", Value = 8400,
	MinCondition = 350, MaxCondition = 0, MaxStamPen = -31, MinStamPen = 0,
	CustomIcon = "armor/wx_armor_xuangui_70x70.png", CustomIconLarge = "armor/wx_armor_xuangui.png",
	Description = "取《南山经》杻阳鸟首玄龟皇镇海元珠与六角古甲千锤百锻而成的至强镇线重铠，坚若磐岳，钝兵箭矢难损分毫。"
};
::Wuxia.Config.ShanHaiGear.wx_armor_yinglong <- {
	ID = "wx_armor_yinglong", Kind = "armor", Name = "山海·凶犁应龙逆鳞金甲", Value = 8600,
	MinCondition = 335, MaxCondition = 0, MaxStamPen = -27, MinStamPen = 0,
	CustomIcon = "armor/wx_armor_yinglong_70x70.png", CustomIconLarge = "armor/wx_armor_yinglong.png",
	Description = "融上古真龙应龙逆鳞宝珠与青铜鎏金龙鳞甲叶铸就的统帅神铠，兼具浩瀚护甲厚度与卓绝行气效率。"
};
::Wuxia.Config.ShanHaiGear.wx_armor_chiyou <- {
	ID = "wx_armor_chiyou", Kind = "armor", Name = "山海·凶黎蚩尤铜头战铠", Value = 8500,
	MinCondition = 342, MaxCondition = 0, MaxStamPen = -29, MinStamPen = 0,
	CustomIcon = "armor/wx_armor_chiyou_70x70.png", CustomIconLarge = "armor/wx_armor_chiyou.png",
	Description = "以万古兵主蚩尤战魄配古铜兽面吞肩锻成的霸道重铠，凶威凛冽，专为横练巨斧与重锤猛将量身打造。"
};
::Wuxia.Config.ShanHaiGear.wx_armor_kui <- {
	ID = "wx_armor_kui", Kind = "armor", Name = "山海·流波夔牛紫电革铠", Value = 7800,
	MinCondition = 275, MaxCondition = 0, MaxStamPen = -21, MinStamPen = 0,
	CustomIcon = "armor/wx_armor_kui_70x70.png", CustomIconLarge = "armor/wx_armor_kui.png",
	Description = "取东海流波山独足夔牛厚革与紫电雷核鞣制嵌铁而成，革韧如铁鼓而分量适中，攻守进退皆宜。"
};
::Wuxia.Config.ShanHaiGear.wx_armor_luwu <- {
	ID = "wx_armor_luwu", Kind = "armor", Name = "山海·昆仑陆吾九部虎贲甲", Value = 8000,
	MinCondition = 305, MaxCondition = 0, MaxStamPen = -24, MinStamPen = 0,
	CustomIcon = "armor/wx_armor_luwu_70x70.png", CustomIconLarge = "armor/wx_armor_luwu.png",
	Description = "肩披昆仑神兽陆吾雪白虎裘、胸覆错金虎纹钢札的镇山宝甲，威仪堂皇。"
};
::Wuxia.Config.ShanHaiGear.wx_armor_zhuyin <- {
	ID = "wx_armor_zhuyin", Kind = "armor", Name = "山海·钟山烛阴寒暑龙鳞袍", Value = 8200,
	MinCondition = 265, MaxCondition = 0, MaxStamPen = -19, MinStamPen = 0,
	CustomIcon = "armor/wx_armor_zhuyin_70x70.png", CustomIconLarge = "armor/wx_armor_zhuyin.png",
	Description = "以钟山烛九阴昼夜龙珠淬炼赤火与寒冰双色龙鳞编缀的奇门战袍，水火不侵且内息滞涩极轻。"
};
::Wuxia.Config.ShanHaiGear.wx_armor_feilian <- {
	ID = "wx_armor_feilian", Kind = "armor", Name = "山海·鹿台飞廉御风羽衣", Value = 7500,
	MinCondition = 172, MaxCondition = 188, MaxStamPen = -8, MinStamPen = -6,
	CustomIcon = "armor/wx_armor_feilian_70x70.png", CustomIconLarge = "armor/wx_armor_feilian.png",
	Description = "融风伯飞廉御风神丹与青翎熟革精裁的绝顶轻甲：负重仅寥寥数点（完美触发《金蝉卸力》），游侠刺客梦寐以求之羽衣！"
};
::Wuxia.Config.ShanHaiGear.wx_armor_bifang <- {
	ID = "wx_armor_bifang", Kind = "armor", Name = "山海·章莪毕方讹火赤翎衣", Value = 7400,
	MinCondition = 166, MaxCondition = 182, MaxStamPen = -7, MinStamPen = -6,
	CustomIcon = "armor/wx_armor_bifang_70x70.png", CustomIconLarge = "armor/wx_armor_bifang.png",
	Description = "取章莪毕方讹火翎丹配天韧蛛丝与赤羽织就的潇洒劲装，轻盈似火云，丝毫不碍提纵身法。"
};
::Wuxia.Config.ShanHaiGear.wx_armor_baize <- {
	ID = "wx_armor_baize", Kind = "armor", Name = "山海·东望白泽通玄雪裘甲", Value = 7700,
	MinCondition = 180, MaxCondition = 195, MaxStamPen = -9, MinStamPen = -7,
	CustomIcon = "armor/wx_armor_baize_70x70.png", CustomIconLarge = "armor/wx_armor_baize.png",
	Description = "以东望山瑞兽白泽宝丹与雪绒银鳞精制的宗师轻甲，防护冠绝同侪而仍契合轻装卸力门径。"
};
::Wuxia.Config.ShanHaiGear.wx_armor_xiangliu <- {
	ID = "wx_armor_xiangliu", Kind = "armor", Name = "山海·共工相柳九首毒鳞甲", Value = 7900,
	MinCondition = 288, MaxCondition = 0, MaxStamPen = -23, MinStamPen = 0,
	CustomIcon = "armor/wx_armor_xiangliu_70x70.png", CustomIconLarge = "armor/wx_armor_xiangliu.png",
	Description = "取共工台九首相柳苦毒源珠与翠紫蛇鳞密编而成的诡谲重鳞甲，滑溜卸刃、刀剑难入。"
};
::Wuxia.Config.ShanHaiGear.wx_helm_kaiming <- {
	ID = "wx_helm_kaiming", Kind = "helmet", Name = "山海·昆仑开明九首虎冕", Value = 6000,
	MinCondition = 315, MaxCondition = 0, MaxStamPen = -16, FixedVision = null,
	CustomIcon = "helmets/wx_helm_kaiming.png", CustomIconLarge = null,
	Description = "仿昆仑百神门主开明兽怒虎金颜精铸的重型战冕，护额坚厚无比，威慑四方宵小。"
};
::Wuxia.Config.ShanHaiGear.wx_helm_chiyou <- {
	ID = "wx_helm_chiyou", Kind = "helmet", Name = "山海·蚩尤铜头铁额魔鍪", Value = 6400,
	MinCondition = 338, MaxCondition = 0, MaxStamPen = -18, FixedVision = null,
	CustomIcon = "helmets/wx_helm_chiyou.png", CustomIconLarge = null,
	Description = "《大荒北经》载蚩尤铜头铁额！以蚩尤战魄熔古赤铜与寒铁重锻的双角霸胄，硬接重锤亦难伤天灵。"
};
::Wuxia.Config.ShanHaiGear.wx_helm_jinwu <- {
	ID = "wx_helm_jinwu", Kind = "helmet", Name = "山海·汤谷金乌大日火羽冠", Value = 5900,
	MinCondition = 175, MaxCondition = 192, MaxStamPen = -6, FixedVision = 0,
	CustomIcon = "helmets/wx_helm_jinwu.png", CustomIconLarge = null,
	Description = "嵌汤谷三足金乌真丹、两侧斜插赤金火翎的束发战冠：毫无视野遮蔽（0 视野惩罚），神射与剑侠绝配！"
};
::Wuxia.Config.ShanHaiGear.wx_helm_dijiang <- {
	ID = "wx_helm_dijiang", Kind = "helmet", Name = "山海·天山帝江幻空丹面", Value = 5700,
	MinCondition = 162, MaxCondition = 180, MaxStamPen = -5, FixedVision = 0,
	CustomIcon = "helmets/wx_helm_dijiang.png", CustomIconLarge = null,
	Description = "取天山六足四翼异神帝江幻空丹精制的丹漆金翼轻冠，轻若无物且耳目通明（0 视野惩罚）。"
};
::Wuxia.Config.ShanHaiGear.wx_helm_siwang <- {
	ID = "wx_helm_siwang", Kind = "helmet", Name = "山海·苍梧青兕独角重兜", Value = 5800,
	MinCondition = 290, MaxCondition = 0, MaxStamPen = -14, FixedVision = null,
	CustomIcon = "helmets/wx_helm_siwang.png", CustomIconLarge = null,
	Description = "以苍梧独角青兕王镇岳丹与巨犀铁角锻打的乌钢护颊重兜，顶撞格架稳如泰山。"
};
::Wuxia.Config.ShanHaiGear.wx_helm_bingyi <- {
	ID = "wx_helm_bingyi", Kind = "helmet", Name = "山海·从极冰夷御龙寒玉冠", Value = 6000,
	MinCondition = 225, MaxCondition = 245, MaxStamPen = -9, FixedVision = 0,
	CustomIcon = "helmets/wx_helm_bingyi.png", CustomIconLarge = null,
	Description = "从极渊冰夷寒髓配寒玉银钢雕琢的双龙盘首战冠，清凉醒神、不掩视野，兼顾中坚防护与灵便内息。"
};
::Wuxia.Config.ShanHaiGear.wx_shd_xuangui <- {
	ID = "wx_shd_xuangui", Kind = "shield", Name = "山海·杻阳玄龟不坏巨盾", Value = 6800,
	MinCondition = 96, BaseMDef = 22, BaseRDef = 26, MaxStamPen = -16,
	CustomIcon = "shields/wx_shd_xuangui_70x70.png", CustomIconLarge = "shields/wx_shd_xuangui.png",
	Description = "整副杻阳玄龟皇背甲镶熟铜重框制成的传世巨盾，耐久与防矢冠绝天下，可正面硬扛巨斧狂劈。"
};
::Wuxia.Config.ShanHaiGear.wx_shd_zaochi <- {
	ID = "wx_shd_zaochi", Kind = "shield", Name = "山海·畴华凿齿破军戈盾", Value = 6500,
	MinCondition = 82, BaseMDef = 25, BaseRDef = 18, MaxStamPen = -14,
	CustomIcon = "shields/wx_shd_zaochi_70x70.png", CustomIconLarge = "shields/wx_shd_zaochi.png",
	Description = "《海外南经》畴华凿齿王遗制精铁兽面圆盾，外圈密布六尺凶牙骨刺，近身格架密不透风。"
};
::Wuxia.Config.ShanHaiGear.wx_shd_kui <- {
	ID = "wx_shd_kui", Kind = "shield", Name = "山海·东海夔牛雷音皮盾", Value = 6200,
	MinCondition = 74, BaseMDef = 21, BaseRDef = 22, MaxStamPen = -10,
	CustomIcon = "shields/wx_shd_kui_70x70.png", CustomIconLarge = "shields/wx_shd_kui.png",
	Description = "蒙多层流波山夔牛苍革、正中嵌紫电雷铜盾鼻的团牌，敌刃砍中声若惊雷，轻韧耐用。"
};
::Wuxia.Config.ShanHaiGear.wx_shd_jumang <- {
	ID = "wx_shd_jumang", Kind = "shield", Name = "山海·都广建木盘根藤牌", Value = 6000,
	MinCondition = 68, BaseMDef = 20, BaseRDef = 23, MaxStamPen = -6,
	CustomIcon = "shields/wx_shd_jumang_70x70.png", CustomIconLarge = "shields/wx_shd_jumang.png",
	Description = "以都广建木生机神枝编盘并浸满琥珀灵脂的传世藤牌，内息负担极低，刀盾游侠守线神物。"
};
::Wuxia.Config.ShanHaiGear.wx_shd_fangfeng <- {
	ID = "wx_shd_fangfeng", Kind = "shield", Name = "山海·会稽防风专车骨橹", Value = 6700,
	MinCondition = 92, BaseMDef = 21, BaseRDef = 28, MaxStamPen = -17,
	CustomIcon = "shields/wx_shd_fangfeng_70x70.png", CustomIconLarge = "shields/wx_shd_fangfeng.png",
	Description = "取会稽古冢防风氏专车巨骨箍黑铁重带制成的立式巨盾，箭雨火铳皆难穿其壁垒。"
};
::Wuxia.Config.ShanHaiGear.wx_shd_yinglong <- {
	ID = "wx_shd_yinglong", Kind = "shield", Name = "山海·应龙蓄水逆鳞团牌", Value = 6900,
	MinCondition = 86, BaseMDef = 24, BaseRDef = 24, MaxStamPen = -12,
	CustomIcon = "shields/wx_shd_yinglong_70x70.png", CustomIconLarge = "shields/wx_shd_yinglong.png",
	Description = "覆凶犁应龙青金逆鳞的百炼圆盾，弧面旋水卸力，近远双防俱臻化境。"
};
::Wuxia.Config.ShanHaiGear.wx_acc_baize <- {
	ID = "wx_acc_baize", Kind = "accessory", Name = "山海·白泽达知万物图谱佩", Value = 5600,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { MeleeDefense = 4, RangedDefense = 4, Bravery = 8 },
	TooltipLines = [ { Icon = "ui/icons/melee_defense.png", Text = "达知万物招路：近防 [color=#135213]+4[/color]、远防 [color=#135213]+4[/color]" }, { Icon = "ui/icons/bravery.png", Text = "瑞兽镇心：定力 [color=#135213]+8[/color]" } ],
	CustomIcon = "accessory/wx_acc_baize.png", CustomIconLarge = null,
	Description = "以东望白泽通玄宝丹配迷榖灵木雕成的羊脂白玉兽佩。洞悉百鬼兵势，近远双防 +4、定力 +8。"
};
::Wuxia.Config.ShanHaiGear.wx_acc_hundun <- {
	ID = "wx_acc_hundun", Kind = "accessory", Name = "山海·浑沌无窍定岳黄囊", Value = 5800,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { Hitpoints = 10, ImmuneStun = true },
	TooltipLines = [ { Icon = "ui/icons/health.png", Text = "浑沌元胎：气血上限 [color=#135213]+10[/color]" }, { Icon = "ui/icons/special.png", Text = "七窍俱泯：彻底免疫棒槌震晕（Stun）" } ],
	CustomIcon = "accessory/wx_acc_hundun.png", CustomIconLarge = null,
	Description = "仿天山神魔浑沌黄囊丹火缝制的护身奇囊。佩之气血 +10，且周身混元无窍、免疫钝器击晕！"
};
::Wuxia.Config.ShanHaiGear.wx_acc_chenghuang <- {
	ID = "wx_acc_chenghuang", Kind = "accessory", Name = "山海·白民乘黄二千岁琥珀", Value = 5500,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { Hitpoints = 16, FatigueRecoveryRate = 2 },
	TooltipLines = [ { Icon = "ui/icons/health.png", Text = "乘黄寿元：气血上限 [color=#135213]+16[/color]" }, { Icon = "ui/icons/fatigue.png", Text = "生机绵长：每回合额外回气 [color=#135213]+2[/color]" } ],
	CustomIcon = "accessory/wx_acc_chenghuang.png", CustomIconLarge = null,
	Description = "封存海外白民国乘黄神狐寿元丹的千年血珀。佩于胸前气血上限 +16、每回合回气 +2。"
};
::Wuxia.Config.ShanHaiGear.wx_acc_fuzhu <- {
	ID = "wx_acc_fuzhu", Kind = "accessory", Name = "山海·敖岸夫诸四角凝霜佩", Value = 5300,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { Stamina = 12, FatigueRecoveryRate = 2 },
	TooltipLines = [ { Icon = "ui/icons/fatigue.png", Text = "寒溪清气：内息上限 [color=#135213]+12[/color]，每回合额外回气 [color=#135213]+2[/color]" } ],
	CustomIcon = "accessory/wx_acc_fuzhu.png", CustomIconLarge = null,
	Description = "敖岸山四角白鹿夫诸霜丹配冰魄草琢成的寒玉鹿佩，令丹田清凉不竭，内息上限 +12、回气 +2。"
};
::Wuxia.Config.ShanHaiGear.wx_acc_boshi <- {
	ID = "wx_acc_boshi", Kind = "accessory", Name = "山海·基山猼訑背目无畏佩", Value = 5600,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { MeleeDefense = 5, Bravery = 10, AntiFearBravery = 12 },
	TooltipLines = [ { Icon = "ui/icons/melee_defense.png", Text = "其目在背：近防 [color=#135213]+5[/color]" }, { Icon = "ui/icons/bravery.png", Text = "著之不畏：定力 [color=#135213]+10[/color]，抗惊骇检定额外 [color=#135213]+12[/color]" } ],
	CustomIcon = "accessory/wx_acc_boshi.png", CustomIconLarge = null,
	Description = "《南山经》载猼訑『其目在背，佩之不畏』：嵌背目无畏丹的乌铜兽瞳佩，近防 +5、定力 +10 且无惧鬼啸。"
};
::Wuxia.Config.ShanHaiGear.wx_acc_wuluo <- {
	ID = "wx_acc_wuluo", Kind = "accessory", Name = "山海·青要武罗穿耳鸣玉环", Value = 5400,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { Initiative = 15, RangedDefense = 5 },
	TooltipLines = [ { Icon = "ui/icons/initiative.png", Text = "鸣玉轻身：身法 [color=#135213]+15[/color]" }, { Icon = "ui/icons/ranged_defense.png", Text = "幻步拨矢：远防 [color=#135213]+5[/color]" } ],
	CustomIcon = "accessory/wx_acc_wuluo.png", CustomIconLarge = null,
	Description = "青要山神女武罗魅神珠炼制的双连豹纹翡翠鸣环，步履间清音流转，身法 +15、远防 +5。"
};
::Wuxia.Config.ShanHaiGear.wx_acc_xingxing <- {
	ID = "wx_acc_xingxing", Kind = "accessory", Name = "山海·招摇狌狌通晓往事佩", Value = 5200,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { Vision = 1, XPGainMult = 1.15 },
	TooltipLines = [ { Icon = "ui/icons/vision.png", Text = "慧目远眺：视野 [color=#135213]+1[/color]" }, { Icon = "ui/icons/xp_received.png", Text = "通晓往事：实战历练经验获取 [color=#135213]+15%[/color]" } ],
	CustomIcon = "accessory/wx_acc_xingxing.png", CustomIconLarge = null,
	Description = "招摇山白耳狌狌通明丹镶嵌的古龟甲玉牌，助新秀侠客融会战阵得失，视野 +1、人物经验获取 +15%！"
};
::Wuxia.Config.ShanHaiGear.wx_acc_jingwei <- {
	ID = "wx_acc_jingwei", Kind = "accessory", Name = "山海·发鸠精卫衔石不屈坠", Value = 5500,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { Bravery = 14, RangedReceivedMult = 0.90, ImmuneKnockback = true },
	TooltipLines = [ { Icon = "ui/icons/bravery.png", Text = "千载执念：定力 [color=#135213]+14[/color]" }, { Icon = "ui/icons/ranged_defense.png", Text = "衔石镇海：所受远程伤害减免 [color=#135213]10%[/color] 且免疫击退抓取" } ],
	CustomIcon = "accessory/wx_acc_jingwei.png", CustomIconLarge = null,
	Description = "发鸠精卫填海魂晶雕成的海蓝宝坠，千载波涛不能移其志，定力 +14、远伤减免 10% 且免疫击退抓取。"
};
::Wuxia.Config.ShanHaiGear.wx_acc_dangkang <- {
	ID = "wx_acc_dangkang", Kind = "accessory", Name = "山海·钦山当康丰穰青玉牙", Value = 5300,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { Hitpoints = 12, Stamina = 10 },
	TooltipLines = [ { Icon = "ui/icons/health.png", Text = "丰穰气血：气血上限 [color=#135213]+12[/color]" }, { Icon = "ui/icons/fatigue.png", Text = "巨牙壮力：内息上限 [color=#135213]+10[/color]" } ],
	CustomIcon = "accessory/wx_acc_dangkang.png", CustomIconLarge = null,
	Description = "钦山瑞凶巨兽当康丰穰髓包裹的错金青玉獠牙，气血上限 +12、内息上限 +10。"
};
::Wuxia.Config.ShanHaiGear.wx_acc_yayu <- {
	ID = "wx_acc_yayu", Kind = "accessory", Name = "山海·少咸猰貐贰负续命珏", Value = 5600,
	MinCondition = 0, MaxStamPen = 0,
	Bonuses = { Hitpoints = 15, MeleeDefense = 3, Bravery = 6 },
	TooltipLines = [ { Icon = "ui/icons/health.png", Text = "逆命血珀：气血上限 [color=#135213]+15[/color]" }, { Icon = "ui/icons/melee_defense.png", Text = "龙首凶威：近防 [color=#135213]+3[/color]、定力 [color=#135213]+6[/color]" } ],
	CustomIcon = "accessory/wx_acc_yayu.png", CustomIconLarge = null,
	Description = "少咸山龙首猰貐逆命血丹琢成的暗红龙纹玉玦，蕴藏凶神顽强生机，气血 +15、近防 +3、定力 +6。"
};

// 3. Assign Martial Affinity Resonance to all 64 existing Boss Cores + register +32 Wild & Sovereign Cores (`64 -> 96`!)
if ("wx_core_zhuyan" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_zhuyan.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_zhuyan.TierGroup <- "boss"; }
if ("wx_core_feiyi" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_feiyi.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_feiyi.TierGroup <- "boss"; }
if ("wx_core_qiongqi" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_qiongqi.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_qiongqi.TierGroup <- "boss"; }
if ("wx_core_taotie" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_taotie.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_taotie.TierGroup <- "boss"; }
if ("wx_core_jiuwei" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_jiuwei.Affinity <- "tactics"; ::Wuxia.Config.ShanHaiCores.wx_core_jiuwei.TierGroup <- "boss"; }
if ("wx_core_bashe" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_bashe.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_bashe.TierGroup <- "boss"; }
if ("wx_core_jumang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_jumang.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_jumang.TierGroup <- "boss"; }
if ("wx_core_wuzhiqi" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_wuzhiqi.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_wuzhiqi.TierGroup <- "boss"; }
if ("wx_core_xingtian" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_xingtian.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_xingtian.TierGroup <- "boss"; }
if ("wx_core_bifang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_bifang.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_bifang.TierGroup <- "boss"; }
if ("wx_core_gudiaowang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_gudiaowang.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_gudiaowang.TierGroup <- "boss"; }
if ("wx_core_xingxing" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_xingxing.Affinity <- "tactics"; ::Wuxia.Config.ShanHaiCores.wx_core_xingxing.TierGroup <- "boss"; }
if ("wx_core_zhujian" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_zhujian.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_zhujian.TierGroup <- "boss"; }
if ("wx_core_xuangui" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_xuangui.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_xuangui.TierGroup <- "boss"; }
if ("wx_core_yuanchu" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_yuanchu.Affinity <- "neigong_yang"; ::Wuxia.Config.ShanHaiCores.wx_core_yuanchu.TierGroup <- "boss"; }
if ("wx_core_yingzhao" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_yingzhao.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_yingzhao.TierGroup <- "boss"; }
if ("wx_core_luwu" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_luwu.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_luwu.TierGroup <- "boss"; }
if ("wx_core_qinyuan" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_qinyuan.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_qinyuan.TierGroup <- "boss"; }
if ("wx_core_tiangouwang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_tiangouwang.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_tiangouwang.TierGroup <- "boss"; }
if ("wx_core_zheng" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_zheng.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_zheng.TierGroup <- "boss"; }
if ("wx_core_hundun" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_hundun.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_hundun.TierGroup <- "boss"; }
if ("wx_core_yayu" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_yayu.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_yayu.TierGroup <- "boss"; }
if ("wx_core_zhuyin" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_zhuyin.Affinity <- "neigong_yang"; ::Wuxia.Config.ShanHaiCores.wx_core_zhuyin.TierGroup <- "boss"; }
if ("wx_core_dijiang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_dijiang.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_dijiang.TierGroup <- "boss"; }
if ("wx_core_paoxiaowang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_paoxiaowang.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_paoxiaowang.TierGroup <- "boss"; }
if ("wx_core_changyou" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_changyou.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_changyou.TierGroup <- "boss"; }
if ("wx_core_mengji" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_mengji.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_mengji.TierGroup <- "boss"; }
if ("wx_core_kui" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_kui.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_kui.TierGroup <- "boss"; }
if ("wx_core_fei" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_fei.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_fei.TierGroup <- "boss"; }
if ("wx_core_yinglong" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_yinglong.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_yinglong.TierGroup <- "boss"; }
if ("wx_core_taowu" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_taowu.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_taowu.TierGroup <- "boss"; }
if ("wx_core_hujiao" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_hujiao.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_hujiao.TierGroup <- "boss"; }
if ("wx_core_zhuhuai" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_zhuhuai.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_zhuhuai.TierGroup <- "boss"; }
if ("wx_core_shebishi" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_shebishi.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_shebishi.TierGroup <- "boss"; }
if ("wx_core_jingwei" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_jingwei.Affinity <- "tactics"; ::Wuxia.Config.ShanHaiCores.wx_core_jingwei.TierGroup <- "boss"; }
if ("wx_core_jiuying" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_jiuying.Affinity <- "neigong_yang"; ::Wuxia.Config.ShanHaiCores.wx_core_jiuying.TierGroup <- "boss"; }
if ("wx_core_feilian" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_feilian.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_feilian.TierGroup <- "boss"; }
if ("wx_core_baize" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_baize.Affinity <- "tactics"; ::Wuxia.Config.ShanHaiCores.wx_core_baize.TierGroup <- "boss"; }
if ("wx_core_shanhui" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_shanhui.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_shanhui.TierGroup <- "boss"; }
if ("wx_core_bo" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_bo.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_bo.TierGroup <- "boss"; }
if ("wx_core_huodou" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_huodou.Affinity <- "neigong_yang"; ::Wuxia.Config.ShanHaiCores.wx_core_huodou.TierGroup <- "boss"; }
if ("wx_core_xiangliuwang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_xiangliuwang.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_xiangliuwang.TierGroup <- "boss"; }
if ("wx_core_kuafu" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_kuafu.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_kuafu.TierGroup <- "boss"; }
if ("wx_core_chiyou" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_chiyou.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_chiyou.TierGroup <- "boss"; }
if ("wx_core_zaochi" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_zaochi.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_zaochi.TierGroup <- "boss"; }
if ("wx_core_erfu" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_erfu.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_erfu.TierGroup <- "boss"; }
if ("wx_core_nvchou" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_nvchou.Affinity <- "neigong_yang"; ::Wuxia.Config.ShanHaiCores.wx_core_nvchou.TierGroup <- "boss"; }
if ("wx_core_fangfeng" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_fangfeng.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_fangfeng.TierGroup <- "boss"; }
if ("wx_core_kaiming" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_kaiming.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_kaiming.TierGroup <- "boss"; }
if ("wx_core_jinwu" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_jinwu.Affinity <- "neigong_yang"; ::Wuxia.Config.ShanHaiCores.wx_core_jinwu.TierGroup <- "boss"; }
if ("wx_core_zouyu" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_zouyu.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_zouyu.TierGroup <- "boss"; }
if ("wx_core_gonggong" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_gonggong.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_gonggong.TierGroup <- "boss"; }
if ("wx_core_wuluo" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_wuluo.Affinity <- "qinggong"; ::Wuxia.Config.ShanHaiCores.wx_core_wuluo.TierGroup <- "boss"; }
if ("wx_core_siwang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_siwang.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_siwang.TierGroup <- "boss"; }
if ("wx_core_jiufeng" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_jiufeng.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_jiufeng.TierGroup <- "boss"; }
if ("wx_core_mingshe" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_mingshe.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_mingshe.TierGroup <- "boss"; }
if ("wx_core_huashe" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_huashe.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_huashe.TierGroup <- "boss"; }
if ("wx_core_fuzhu" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_fuzhu.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_fuzhu.TierGroup <- "boss"; }
if ("wx_core_chenghuang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_chenghuang.Affinity <- "neigong_yang"; ::Wuxia.Config.ShanHaiCores.wx_core_chenghuang.TierGroup <- "boss"; }
if ("wx_core_dangkang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_dangkang.Affinity <- "henglian"; ::Wuxia.Config.ShanHaiCores.wx_core_dangkang.TierGroup <- "boss"; }
if ("wx_core_boshi" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_boshi.Affinity <- "tactics"; ::Wuxia.Config.ShanHaiCores.wx_core_boshi.TierGroup <- "boss"; }
if ("wx_core_jiao" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_jiao.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_jiao.TierGroup <- "boss"; }
if ("wx_core_bingyi" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_bingyi.Affinity <- "neigong_yin"; ::Wuxia.Config.ShanHaiCores.wx_core_bingyi.TierGroup <- "boss"; }
if ("wx_core_qiangliang" in ::Wuxia.Config.ShanHaiCores) { ::Wuxia.Config.ShanHaiCores.wx_core_qiangliang.Affinity <- "waigong"; ::Wuxia.Config.ShanHaiCores.wx_core_qiangliang.TierGroup <- "boss"; }
::Wuxia.Config.ShanHaiCores.wx_core_esha <- {
	ID = "wx_core_esha", Chapter = "西山经", Name = "【山泽妖丹】幽谷讹兽梦魇幻丹", Value = 1450, ExpAmount = 260,
	TierGroup = "wild", Affinity = "tactics",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_esha.png",
	Description = "幽谷梦魇讹兽眉心凝结的紫雾幻丹：可在百工坊合炼「明目定神散」或灌注武学火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_chizhu <- {
	ID = "wx_core_chizhu", Chapter = "南山经", Name = "【山泽妖丹】毒谷赤蛛万丝毒丹", Value = 1350, ExpAmount = 240,
	TierGroup = "wild", Affinity = "neigong_yin",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_chizhu.png",
	Description = "毒谷鬼面赤蛛母腹内银丝缠裹的碧血毒珠：可在百工坊合炼「五毒百草辟瘴丸」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_canglang <- {
	ID = "wx_core_canglang", Chapter = "西山经", Name = "【山泽妖丹】阴山苍狼啸月寒丹", Value = 1400, ExpAmount = 250,
	TierGroup = "wild", Affinity = "qinggong",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_canglang.png",
	Description = "阴山异种苍狼王吞吐月华凝成的银铁寒丹：可在百工坊合炼「杜衡追风丸」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_shuiyuan <- {
	ID = "wx_core_shuiyuan", Chapter = "中山经", Name = "【山泽妖丹】云梦水猿寒瘴水丹", Value = 1550, ExpAmount = 280,
	TierGroup = "wild", Affinity = "neigong_yin",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_shuiyuan.png",
	Description = "云梦毒泽老水猿丹田漩流不息的深青水珠：可在百工坊合炼「护脉丹」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_shujing <- {
	ID = "wx_core_shujing", Chapter = "海内经", Name = "【山泽妖丹】都广树精盘根苍木丹", Value = 1600, ExpAmount = 290,
	TierGroup = "wild", Affinity = "henglian",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_shujing.png",
	Description = "都广建木树精核心盘结的琥珀苍木灵核：可在百工坊合炼「金刚铁骨护体丸」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_yaomei <- {
	ID = "wx_core_yaomei", Chapter = "南山经", Name = "【山泽妖丹】青丘妖魅惑心香丹", Value = 1600, ExpAmount = 290,
	TierGroup = "wild", Affinity = "tactics",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_yaomei.png",
	Description = "青丘惑心妖魅体内流转霞光的胭脂玉丹：可在百工坊合炼「九花玉露丸」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_paoxiao <- {
	ID = "wx_core_paoxiao", Chapter = "北山经", Name = "【山泽妖丹】北山狍鸮裂骨贪食丹", Value = 1450, ExpAmount = 260,
	TierGroup = "wild", Affinity = "henglian",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_paoxiao.png",
	Description = "北山食人狍鸮老兽胃囊凝出的骨齿血丹：可在百工坊合炼「虎骨壮气丸」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_gudiao <- {
	ID = "wx_core_gudiao", Chapter = "南山经", Name = "【山泽妖丹】西山蛊雕裂风斑丹", Value = 1450, ExpAmount = 260,
	TierGroup = "wild", Affinity = "waigong",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_gudiao.png",
	Description = "西山蛊雕猛兽体内风刃割裂纹路的豹斑内丹：可在百工坊合炼「凝神丸」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_mangshe <- {
	ID = "wx_core_mangshe", Chapter = "海内南经", Name = "【山泽妖丹】苍梧巨蟒蜕骨碧丹", Value = 1500, ExpAmount = 270,
	TierGroup = "wild", Affinity = "neigong_yin",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_mangshe.png",
	Description = "苍梧吞鹿巴蛇百年蜕骨所结深碧蛇胆内丹：可在百工坊合炼「首乌归元培气丸」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_jianmo <- {
	ID = "wx_core_jianmo", Chapter = "古墓秘录", Name = "【山泽妖丹】古墓剑魔血影煞丹", Value = 1650, ExpAmount = 300,
	TierGroup = "wild", Affinity = "waigong",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jianmo.png",
	Description = "前朝古墓血影剑魔溃散所遗剑痕黑曜血丹：最契合刀剑外功参悟，亦可入炉合炼「九转大还丹」。"
};
::Wuxia.Config.ShanHaiCores.wx_core_shiwang <- {
	ID = "wx_core_shiwang", Chapter = "湘西异闻", Name = "【山泽妖丹】湘西尸王不化骨丹", Value = 1700, ExpAmount = 310,
	TierGroup = "wild", Affinity = "henglian",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_shiwang.png",
	Description = "湘西千年尸王胸骨淬炼幽绿尸火的不化铜骨丹：可在百工坊合炼「血竭续骨圣膏」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_yuanling <- {
	ID = "wx_core_yuanling", Chapter = "荒冢志怪", Name = "【山泽妖丹】荒冢怨灵凝魄寒珠", Value = 1500, ExpAmount = 270,
	TierGroup = "wild", Affinity = "qinggong",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_yuanling.png",
	Description = "夺魄怨灵消散凝成的冰蓝多面魂晶：可在百工坊合炼「天山雪莲冰心丹」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_zelong <- {
	ID = "wx_core_zelong", Chapter = "海外北经", Name = "【山海巨妖】大泽九首毒触妖丹", Value = 2400, ExpAmount = 380,
	TierGroup = "wild", Affinity = "neigong_yin",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_zelong.png",
	Description = "盘踞绝命毒泽的九首相柳巨妖本命内丹：可在百工坊直接炼制「洗髓丹」或「太虚紫金大丹」！"
};
::Wuxia.Config.ShanHaiCores.wx_core_shenlu <- {
	ID = "wx_core_shenlu", Chapter = "海外西经", Name = "【山海瑞灵】昆仑神鹿幻彩灵丹", Value = 2400, ExpAmount = 380,
	TierGroup = "wild", Affinity = "neigong_yang",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_shenlu.png",
	Description = "林海幻境昆仑神鹿遗留的金角青玉圣丹：可在百工坊直接炼制「洗髓丹」或「神农百草返魂丹」！"
};
::Wuxia.Config.ShanHaiCores.wx_core_yaoren <- {
	ID = "wx_core_yaoren", Chapter = "邪派秘录", Name = "【魔窟炉鼎】炼体药人炉鼎血髓丹", Value = 1700, ExpAmount = 310,
	TierGroup = "wild", Affinity = "neigong_yang",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_yaoren.png",
	Description = "邪派炼体总瓢把子以百草炉火锁入铁链的赤铜血髓丹：可在百工坊合炼「祝余辟谷丹」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_jiguanyong <- {
	ID = "wx_core_jiguanyong", Chapter = "墨家玄宫", Name = "【前朝枢机】玄宫镇陵墨家机括核", Value = 1750, ExpAmount = 320,
	TierGroup = "wild", Affinity = "tactics",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jiguanyong.png",
	Description = "前朝镇陵霸主体内咬合水银光球的青铜机关核心：可在百工坊合炼「帝休定岳丹」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_qilin <- {
	ID = "wx_core_qilin", Chapter = "海内经", Name = "【太古圣丹】昆仑仁兽麒麟瑞丹", Value = 2900, ExpAmount = 420,
	TierGroup = "sovereign", Affinity = "neigong_yang",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_qilin.png",
	Description = "集五方祥瑞之气的五彩龙鳞玉丹：可在百工坊主炼「山海造化护脉金丹」与「洗髓丹」，灌顶火候浩瀚！"
};
::Wuxia.Config.ShanHaiCores.wx_core_fenghuang <- {
	ID = "wx_core_fenghuang", Chapter = "南山经", Name = "【太古圣丹】丹穴五采凤凰涅槃丹", Value = 3000, ExpAmount = 440,
	TierGroup = "sovereign", Affinity = "neigong_yang",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_fenghuang.png",
	Description = "《南山经》丹穴之山五采神鸟浴火真丹：可在百工坊主炼「神农百草返魂丹」与「太虚紫金大丹」！"
};
::Wuxia.Config.ShanHaiCores.wx_core_xuanwu <- {
	ID = "wx_core_xuanwu", Chapter = "北山经", Name = "【太古圣丹】北冥玄武龟蛇冥丹", Value = 2950, ExpAmount = 430,
	TierGroup = "sovereign", Affinity = "henglian",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_xuanwu.png",
	Description = "龟甲玄冥与寒蛇缠绕的太古水德神丹：最契合横练硬功大成突破，亦可入炉炼制「洗髓丹」！"
};
::Wuxia.Config.ShanHaiCores.wx_core_baihu <- {
	ID = "wx_core_baihu", Chapter = "西山经", Name = "【太古圣丹】西极庚金白虎杀伐丹", Value = 2950, ExpAmount = 430,
	TierGroup = "sovereign", Affinity = "waigong",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_baihu.png",
	Description = "锋锐庚金杀气凝聚的白金虎纹圣丹：天下刀剑枪戟外功灌顶至宝，亦可入炉合炼仙丹！"
};
::Wuxia.Config.ShanHaiCores.wx_core_qinglong <- {
	ID = "wx_core_qinglong", Chapter = "东山经", Name = "【太古圣丹】东极苍龙岁星木灵丹", Value = 2950, ExpAmount = 430,
	TierGroup = "sovereign", Affinity = "neigong_yang",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_qinglong.png",
	Description = "雷木春生之气奔涌的苍翠龙鳞圣丹：最契合正宗内家心法，亦可入炉合炼「洗髓丹」！"
};
::Wuxia.Config.ShanHaiCores.wx_core_suanyu <- {
	ID = "wx_core_suanyu", Chapter = "北山经", Name = "【山海异丹】景山酸与四翼惊魂丹", Value = 2250, ExpAmount = 360,
	TierGroup = "sovereign", Affinity = "tactics",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_suanyu.png",
	Description = "景山四翼六目奇鸟酸与内丹，见则邑有恐：可在百工坊合炼「太虚紫金大丹」或灌注奇门杂学。"
};
::Wuxia.Config.ShanHaiCores.wx_core_feifei <- {
	ID = "wx_core_feifei", Chapter = "中山经", Name = "【山海瑞丹】霍山腓腓忘忧灵丹", Value = 2300, ExpAmount = 360,
	TierGroup = "sovereign", Affinity = "tactics",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_feifei.png",
	Description = "霍山白尾狸身奇兽腓腓灵珠，蓄之可以解忧：可在百工坊合炼「山海造化护脉金丹」或灌注火候。"
};
::Wuxia.Config.ShanHaiCores.wx_core_tianma <- {
	ID = "wx_core_tianma", Chapter = "北山经", Name = "【山海瑞丹】马成山天马飞雪丹", Value = 2400, ExpAmount = 380,
	TierGroup = "sovereign", Affinity = "qinggong",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_tianma.png",
	Description = "马成山白身黑尾飞天骏兽内丹：天下轻功身法共鸣至宝，亦可入炉合炼「太虚紫金大丹」！"
};
::Wuxia.Config.ShanHaiCores.wx_core_shuhu <- {
	ID = "wx_core_shuhu", Chapter = "西山经", Name = "【山海异丹】崦嵫孰湖人面翼马丹", Value = 2350, ExpAmount = 370,
	TierGroup = "sovereign", Affinity = "qinggong",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_shuhu.png",
	Description = "崦嵫落日神山马身鸟翼蛇尾异兽内丹：契合轻功提纵，亦可入炉合炼高阶灵丹。"
};
::Wuxia.Config.ShanHaiCores.wx_core_xiezhi <- {
	ID = "wx_core_xiezhi", Chapter = "东山经", Name = "【山海瑞丹】东望獬豸明断独角丹", Value = 2500, ExpAmount = 390,
	TierGroup = "sovereign", Affinity = "waigong",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_xiezhi.png",
	Description = "触不直者之独角神兽獬豸宝丹，刚正破邪：契合外功兵道，亦可入炉合炼「山海造化护脉金丹」。"
};
::Wuxia.Config.ShanHaiCores.wx_core_bixi <- {
	ID = "wx_core_bixi", Chapter = "东海经", Name = "【山海神丹】沧海赑屃负岳龙龟丹", Value = 2600, ExpAmount = 400,
	TierGroup = "sovereign", Affinity = "henglian",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_bixi.png",
	Description = "好负重三山五岳之龙子赑屃石纹金丹：契合重甲横练突破，亦可入炉炼制「洗髓丹」。"
};
::Wuxia.Config.ShanHaiCores.wx_core_jiaolong <- {
	ID = "wx_core_jiaolong", Chapter = "中山经", Name = "【山海神丹】洞庭走蛟化龙雷珠", Value = 2650, ExpAmount = 400,
	TierGroup = "sovereign", Affinity = "waigong",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jiaolong.png",
	Description = "五百年寒蛟借暴雨走江化龙时凝结的银蓝雷珠：契合枪棒刀剑外功，亦可入炉合炼仙丹。"
};
::Wuxia.Config.ShanHaiCores.wx_core_chimi <- {
	ID = "wx_core_chimi", Chapter = "大荒南经", Name = "【山海异丹】南荒魑魅山精古丹", Value = 2250, ExpAmount = 360,
	TierGroup = "sovereign", Affinity = "neigong_yin",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_chimi.png",
	Description = "深山古瘴木石感千年日月精气所化碧火妖丹：契合阴柔奇门内功，亦可入炉炼丹。"
};
::Wuxia.Config.ShanHaiCores.wx_core_guiche <- {
	ID = "wx_core_guiche", Chapter = "大荒北经", Name = "【山海凶丹】荆楚鬼车十首滴血丹", Value = 2550, ExpAmount = 390,
	TierGroup = "sovereign", Affinity = "neigong_yin",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_guiche.png",
	Description = "晦夜掠空滴血成灾的十首妖禽暗红血玉丹：契合魔道阴柔内功，亦可入炉合炼「太虚紫金大丹」。"
};
::Wuxia.Config.ShanHaiCores.wx_core_yingyu <- {
	ID = "wx_core_yingyu", Chapter = "西山经", Name = "【山海异丹】东海赢鱼赤翼洪涛丹", Value = 2300, ExpAmount = 360,
	TierGroup = "sovereign", Affinity = "neigong_yin",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_yingyu.png",
	Description = "鱼身鸟翼音如鸳鸯、见则大水之赢鱼海蓝宝珠：契合绵长内息心法，亦可入炉炼丹。"
};
::Wuxia.Config.ShanHaiCores.wx_core_zhulong <- {
	ID = "wx_core_zhulong", Chapter = "海外北经", Name = "【创世圣珠】钟山太古烛龙创世珠", Value = 3500, ExpAmount = 480,
	TierGroup = "sovereign", Affinity = "neigong_yang",
	Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_zhulong.png",
	Description = "视为昼、瞑为夜、吹为冬、呼为夏之钟山创世古神真珠：山海万丹之冠，可主炼「洗髓丹」与「太虚紫金大丹」！"
};
