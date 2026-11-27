// Wuxia Ambition: Slay a ShanHai Mythic Beast Boss
this.wx_ambition_slay_shanhai <- this.inherit("scripts/ambitions/ambition", {
	m = {},
	function create()
	{
		this.ambition.create();
		this.m.ID = "ambition.wx_slay_shanhai";
		this.m.Duration = 99999.0 * this.World.getTime().SecondsPerDay;
		this.m.ButtonText = "大荒屠妖，斩灭一尊《山海经》凶兽首领";
		this.m.UIText = "在山海秘境巢穴斩杀至少 1 尊山海凶兽首领";
		this.m.SuccessText = "[img]gfx/ui/events/wx_ev_18.png[/img]血雾散尽、凶威归寂！这尊盘踞大荒、令方圆百里闻风丧胆的上古山海凶兽终伏诛于你们兵锋之下，异种内丹的炽热灵韵正昭示着一段不朽传奇！";
		this.m.SuccessButtonText = "好！壮哉我辈江湖儿女！";
		if ("ButtonTooltip" in this.m)
			this.m.ButtonTooltip = "备齐辟毒辟火丹药与破甲神兵，深入荒野【山海秘境巢穴】并亲手斩杀至少 1 尊《山海经》凶兽首领（野外寻常兽群不计）。";
		if ("TooltipText" in this.m)
			this.m.TooltipText = "在【山海秘境巢穴】中亲手斩杀至少 1 尊《山海经》凶兽首领（野外寻常兽群不计）。";
	}

	function onUpdateScore()
	{
		if (this.m.IsDone) return;
		if (this.World.Flags.getAsInt("wx_slain_shanhai_count") >= 1) return;
		if (this.World.getTime().Days < 20) return;
		this.m.Score = 3 + this.Math.rand(0, 5);
	}

	function onCheckSuccess()
	{
		return this.World.Flags.getAsInt("wx_slain_shanhai_count") >= 1;
	}

	function onReward()
	{
		this.World.Assets.addMoney(800);
		this.World.Assets.addBusinessReputation(150);
		this.m.SuccessList.push({
			id = 10,
			icon = "ui/icons/asset_money.png",
			text = "斩妖除害获九州赏银 800 两，额外江湖威名 +150"
		});
	}

	function onSerialize( _out )
	{
		this.ambition.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.ambition.onDeserialize(_in);
	}
});
