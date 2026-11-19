// Hook vanilla tactical AI attack/riposte/ranged behaviors so enemy martial artists use Wuxia active moves

::Wuxia.HooksMod.hook("scripts/ai/tactical/behaviors/ai_attack_default", function( q )
{
	q.create = @(__original) function()
	{
		__original();
		if ("PossibleSkills" in this.m && typeof this.m.PossibleSkills == "array")
		{
			this.m.PossibleSkills.push("actives.wx_sword_combo");
			this.m.PossibleSkills.push("actives.wx_sword_tianwai");
			this.m.PossibleSkills.push("actives.wx_saber_cleave");
			this.m.PossibleSkills.push("actives.wx_saber_duanyue");
			this.m.PossibleSkills.push("actives.wx_spear_guard");
		}
	};
});

::Wuxia.HooksMod.hook("scripts/ai/tactical/behaviors/ai_attack_bow", function( q )
{
	q.create = @(__original) function()
	{
		__original();
		if ("PossibleSkills" in this.m && typeof this.m.PossibleSkills == "array")
		{
			this.m.PossibleSkills.push("actives.wx_throwing_rain");
		}
	};
});

::Wuxia.HooksMod.hook("scripts/ai/tactical/behaviors/ai_defend_riposte", function( q )
{
	q.create = @(__original) function()
	{
		__original();
		if ("PossibleSkills" in this.m && typeof this.m.PossibleSkills == "array")
		{
			this.m.PossibleSkills.push("actives.wx_sword_counter");
		}
	};
});
