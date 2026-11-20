// Keep the native target selection, pathing and stamina evaluation for each behavior.
local extendBehavior = function( _path, _moves )
{
	::Wuxia.HooksMod.hook("scripts/ai/tactical/behaviors/" + _path, function( q )
	{
		q.create = @(__original) function()
		{
			__original();
			if (!("PossibleSkills" in this.m) || this.m.PossibleSkills == null) return;
			this.m.PossibleSkills = clone this.m.PossibleSkills;
			foreach (id in _moves)
				if (this.m.PossibleSkills.find(id) == null) this.m.PossibleSkills.push(id);
		};

		q.onEvaluate = @(__original) function( _entity )
		{
			if (!("PossibleSkills" in this.m) || this.m.PossibleSkills == null) return __original(_entity);
			// Give a rested martial artist's opening move a chance before the cheaper native attack.
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
	"actives.wx_sword_combo", "actives.wx_sword_tianwai", "actives.wx_saber_cleave",
	"actives.wx_saber_duanyue", "actives.wx_spear_guard", "actives.wx_acupoint_strike",
	"actives.wx_throwing_rain", "actives.wx_smoke_cast",
	"actives.wx_fist_jingang", "actives.wx_fist_acupoint", "actives.wx_fist_disarm"
]);
extendBehavior("ai_attack_bow", ["actives.wx_throwing_rain", "actives.wx_smoke_cast"]);
extendBehavior("ai_defend_riposte", ["actives.wx_sword_counter", "actives.wx_poise_charge"]);
extendBehavior("ai_rally", ["actives.wx_rally_command"]);
