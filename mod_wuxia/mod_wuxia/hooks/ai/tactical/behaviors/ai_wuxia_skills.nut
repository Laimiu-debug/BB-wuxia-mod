// Keep the native target selection, pathing and stamina evaluation for each behavior.
local extendBehavior = function( _path, _moves )
{
	::Wuxia.HooksMod.hook("scripts/ai/tactical/behaviors/" + _path, function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			if (!(::Wuxia.hasMember(this.m, "PossibleSkills")) || this.m.PossibleSkills == null) return;
			this.m.PossibleSkills = clone this.m.PossibleSkills;
			foreach (id in _moves)
				if (this.m.PossibleSkills.find(id) == null) this.m.PossibleSkills.push(id);
		};

		q.onEvaluate = @(__original) function( _entity )
		{
			if (!(::Wuxia.hasMember(this.m, "PossibleSkills")) || this.m.PossibleSkills == null) return __original(_entity);
			if (_entity.getActionPoints() == _entity.getActionPointsMax() && "WX_LoadoutKey" in _entity.m)
			{
				local trained = [];
				foreach (id in _moves)
				{
					local skill = _entity.getSkills().getSkillByID(id);
					if (skill != null && skill.isUsable() && skill.isAffordable()) trained.push(id);
				}
				if (trained.len() != 0)
				{
					local all = this.m.PossibleSkills, score = 0;
					this.m.PossibleSkills = trained;
					try { score = __original(_entity); }
					catch (error) { this.m.PossibleSkills = all; throw error; }
					this.m.PossibleSkills = all;
					if (score > 0) return score * 1.15;
				}
			}
			return __original(_entity);
		};
	});
};

extendBehavior("ai_attack_default", [
	"actives.wx_sword_combo", "actives.wx_sword_pierce", "actives.wx_sword_tianwai",
	"actives.wx_saber_cleave", "actives.wx_saber_sweep", "actives.wx_saber_duanyue",
	"actives.wx_spear_guard", "actives.wx_spear_thrust2", "actives.wx_pole_sweep",
	"actives.wx_acupoint_strike", "actives.wx_throwing_rain", "actives.wx_throw_fan", "actives.wx_smoke_cast",
	"actives.wx_fist_jab", "actives.wx_fist_shock", "actives.wx_fist_jingang", "actives.wx_fist_acupoint", "actives.wx_fist_disarm", "actives.wx_fist_grapple",
	"actives.wx_hammer_shatter", "actives.wx_hammer_quake",
	"actives.wx_axe_split", "actives.wx_axe_whirl",
	"actives.wx_flail_lash", "actives.wx_flail_entangle",
	"actives.wx_dagger_vital", "actives.wx_dagger_execute",
	"actives.wx_shield_bash_qi", "actives.wx_neigong_xixing",
	"actives.wx_sword_zhongjian", "actives.wx_sword_duoming", "actives.wx_sword_cuixin", "actives.wx_sword_taiji", "actives.wx_sword_feixian", "actives.wx_sword_dugu", "actives.wx_saber_kuangfeng", "actives.wx_saber_ranmu", "actives.wx_saber_xuehai", "actives.wx_saber_fanzhen", "actives.wx_saber_modao", "actives.wx_saber_huoyandao", "actives.wx_spear_liuhua", "actives.wx_spear_bawang", "actives.wx_spear_liangyin", "actives.wx_pole_fangtian", "actives.wx_pole_goulian", "actives.wx_staff_dagou", "actives.wx_fist_xianglong", "actives.wx_fist_xuanming", "actives.wx_fist_yiyang", "actives.wx_fist_jiuyin", "actives.wx_fist_qishang", "actives.wx_fist_taiji", "actives.wx_hama_push", "actives.wx_hammer_leiting", "actives.wx_axe_kaishan", "actives.wx_whip_suohou", "actives.wx_dagger_fuxue",
	"actives.wx_sword_wanjian", "actives.wx_sword_yunv", "actives.wx_sword_canhe", "actives.wx_sword_bixue", "actives.wx_sword_xuanbing", "actives.wx_sword_miejian", "actives.wx_sword_zixia", "actives.wx_sword_zhenwu", "actives.wx_sword_huifeng", "actives.wx_sword_kuangfeng", "actives.wx_sword_qinggang", "actives.wx_sword_yinsha", "actives.wx_saber_abi", "actives.wx_saber_xinyue", "actives.wx_saber_shishen", "actives.wx_saber_podao", "actives.wx_saber_kuanglan", "actives.wx_saber_bagua", "actives.wx_saber_tuxiong", "actives.wx_saber_zhanlang", "actives.wx_saber_baji", "actives.wx_saber_lingnan", "actives.wx_saber_chiyou", "actives.wx_fist_rulai", "actives.wx_fist_nuchao", "actives.wx_fist_qianzhu", "actives.wx_fist_piaoxue", "actives.wx_fist_longzhao", "actives.wx_fist_xiongzhao", "actives.wx_fist_canhezhi", "actives.wx_fist_nianhua", "actives.wx_fist_tiegang", "actives.wx_fist_heisha", "actives.wx_fist_luohan", "actives.wx_spear_panlong", "actives.wx_spear_xuelong", "actives.wx_spear_zhenbiao", "actives.wx_spear_shouguan", "actives.wx_spear_yaqi", "actives.wx_pole_pojun", "actives.wx_pole_fenjiang", "actives.wx_staff_qingou", "actives.wx_staff_fengmo", "actives.wx_staff_weituo", "actives.wx_staff_lianhua", "actives.wx_staff_zhenjiang", "actives.wx_hammer_pocheng", "actives.wx_hammer_qianjun", "actives.wx_hammer_jingua", "actives.wx_hammer_polu", "actives.wx_hammer_faqiu", "actives.wx_axe_kaitian", "actives.wx_axe_xueming", "actives.wx_axe_poche", "actives.wx_dagger_jingke", "actives.wx_dagger_zhuanzhu", "actives.wx_dagger_yingci", "actives.wx_dagger_shenghuo", "actives.wx_flail_panlong", "actives.wx_flail_jinshe", "actives.wx_flail_liuxing", "actives.wx_henglian_tongtou", "actives.wx_throw_liuyedao", "actives.wx_throw_kongque", "actives.wx_whip_xiangxi"
]);
extendBehavior("ai_attack_bow", ["actives.wx_throwing_rain", "actives.wx_throw_fan", "actives.wx_bow_snipe", "actives.wx_smoke_cast", "actives.wx_bow_liuxing", "actives.wx_crossbow_shenji", "actives.wx_throw_pilidan", "actives.wx_throw_duzhen", "actives.wx_bow_luori", "actives.wx_bow_jiuxing", "actives.wx_bow_yanxing", "actives.wx_crossbow_liannu", "actives.wx_gun_leihuo", "actives.wx_gun_huolong", "actives.wx_throw_liuyedao", "actives.wx_throw_kongque"]);
extendBehavior("ai_attack_swing", ["actives.wx_saber_sweep", "actives.wx_pole_sweep", "actives.wx_axe_whirl", "actives.wx_sword_wanjian", "actives.wx_saber_abi", "actives.wx_saber_kuanglan", "actives.wx_fist_rulai", "actives.wx_pole_pojun", "actives.wx_staff_qingou", "actives.wx_hammer_pocheng"]);
extendBehavior("ai_attack_splitshield", ["actives.wx_axe_split"]);
extendBehavior("ai_defend_knock_back", ["actives.wx_shield_bash_qi"]);
extendBehavior("ai_defend_riposte", ["actives.wx_sword_counter", "actives.wx_poise_charge"]);
extendBehavior("ai_defend_shieldwall", ["actives.wx_shield_tiebi", "actives.wx_neigong_jinzhong", "actives.wx_shield_xuanwu"]);
extendBehavior("ai_indomitable", ["actives.wx_neigong_jinzhong", "actives.wx_shield_tiebi", "actives.wx_neigong_yijin", "actives.wx_neigong_hanbing", "actives.wx_neigong_douzhuan", "actives.wx_neigong_wudu", "actives.wx_neigong_taotie", "actives.wx_neigong_junwu", "actives.wx_henglian_tiebushan", "actives.wx_henglian_jinchan", "actives.wx_henglian_panshi", "actives.wx_shield_xuanwu", "actives.wx_tactics_qimen"]);
extendBehavior("ai_recover", ["actives.wx_meditate", "actives.wx_neigong_zixia", "actives.wx_neigong_guiyuan", "actives.wx_neigong_chaoxi"]);
extendBehavior("ai_adrenaline", ["actives.wx_blood_burst"]);
extendBehavior("ai_disengage", ["actives.wx_qinggong_lingbo", "actives.wx_qinggong_zongyue", "actives.wx_qinggong_yanxing", "actives.wx_qinggong_shuishang", "actives.wx_qinggong_feiyan", "actives.wx_qinggong_meiying", "actives.wx_qinggong_shenxing", "actives.wx_qinggong_xuelian", "actives.wx_qinggong_chanchu", "actives.wx_qinggong_suodi"]);
extendBehavior("ai_warcry", ["actives.wx_tactics_shihou", "actives.wx_tactics_kuiniu"]);
extendBehavior("ai_rally", ["actives.wx_rally_command", "actives.wx_tactics_guigu", "actives.wx_tactics_bamen"]);

::Wuxia.HooksMod.hook("scripts/ai/tactical/agent", function( q )
{
	if (::Wuxia.qHas(q, "finalizeBehaviors"))
	{
		q.finalizeBehaviors = @(__original) function()
		{
			if (this.getBehavior(::Const.AI.Behavior.ID.EngageRanged) != null)
			{
				if (("AttackHandgonne" in ::Const.AI.Behavior.ID) && this.getBehavior(::Const.AI.Behavior.ID.AttackHandgonne) == null)
					this.addBehavior(::new("scripts/ai/tactical/behaviors/ai_attack_handgonne"));
				if (("AttackBow" in ::Const.AI.Behavior.ID) && this.getBehavior(::Const.AI.Behavior.ID.AttackBow) == null)
					this.addBehavior(::new("scripts/ai/tactical/behaviors/ai_attack_bow"));
			}
			return __original();
		};
	}
});
