// Locked 7-slot blueprint & global numerical guardrails

::Wuxia.Config.Constants <- {
	BaseAP                 = 9,
	MaxPermanentAP         = 11,  // Hard cap: max +2 permanent AP from unique manuals
	MaxPermanentAPBonus    = 2,
	MaxStarAttributes      = 3,   // Same as vanilla: max 3 attributes can have stars
	MaxStarsPerAttribute   = 3,
	MaxManualTier          = 3,
	MaxFactionIDSafeLimit  = 64
};

// 7 Martial Slots: 5 specialized + 2 late-game free slots
// Unlock levels: 1, 1, 3, 5, 7, 9, 11
::Wuxia.Config.SlotLayout <- [
	{
		Index       = 0,
		SlotType    = "neigong_main",
		Label       = "主修内功",
		UnlockLevel = 1,
		AllowedCategories = ["neigong"]
	},
	{
		Index       = 1,
		SlotType    = "waigong",
		Label       = "基础外功",
		UnlockLevel = 1,
		AllowedCategories = ["waigong"]
	},
	{
		Index       = 2,
		SlotType    = "qinggong",
		Label       = "轻功身法",
		UnlockLevel = 3,
		AllowedCategories = ["qinggong"]
	},
	{
		Index       = 3,
		SlotType    = "henglian",
		Label       = "横练杂学",
		UnlockLevel = 5,
		AllowedCategories = ["henglian"]
	},
	{
		Index       = 4,
		SlotType    = "waigong",
		Label       = "第二外功",
		UnlockLevel = 7,
		AllowedCategories = ["waigong"]
	},
	{
		Index       = 5,
		SlotType    = "free",
		Label       = "自由槽(可辅内)",
		UnlockLevel = 9,
		AllowedCategories = ["neigong", "waigong", "qinggong", "henglian"]
	},
	{
		Index       = 6,
		SlotType    = "free",
		Label       = "宗师自由槽",
		UnlockLevel = 11,
		AllowedCategories = ["neigong", "waigong", "qinggong", "henglian"]
	}
];

::Wuxia.Config.ScatterPenaltyDays <- {
	common = 2,
	sect   = 4,
	secret = 6,
	unique = 7
};
