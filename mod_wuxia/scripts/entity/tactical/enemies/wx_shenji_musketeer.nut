this.wx_shenji_musketeer <- this.inherit("scripts/entity/tactical/enemies/bandit_marksman", {
	m = { WX_SchoolRole = "shenji_musketeer" },

	function create()
	{
		this.bandit_marksman.create();
		this.m.AIAgent = this.new("scripts/ai/tactical/agents/military_gunner_agent");
		this.m.AIAgent.setActor(this);
	}
});
