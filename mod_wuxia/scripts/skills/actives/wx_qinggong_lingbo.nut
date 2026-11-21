// Active Skill: 凌波腾挪步 (Qinggong Footwork disengage, 3 AP, 18 Qi)
this.wx_qinggong_lingbo <- this.inherit("scripts/skills/actives/footwork", {
	m = { WX_VfxBrush = "wx_vfx_25", WX_AnimID = "wx_anim_15", WX_AnimMode = "mirage_step" },
	function create()
	{
		this.footwork.create();
		this.m.ID = "actives.wx_qinggong_lingbo";
		this.m.Name = "凌波腾挪步";
		this.m.Description = "上乘轻功脱围身法：消耗 3 AP 与 18 内息，循八卦方位轻灵滑入相邻空位，完全无视敌军控制区截击！";
		this.m.Icon = "skills/wx_qinggong_lingbo.png";
		this.m.IconDisabled = "skills/wx_qinggong_lingbo_sw.png";
		this.m.Overlay = "wx_ov_wx_qinggong_lingbo";
		this.m.WX_AnimID <- "wx_anim_15";
		this.m.WX_AnimMode <- "mirage_step";
		this.m.WX_ChoreoID <- "wx_qinggong_lingbo";
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 18;
	}
	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		return this.footwork.onUse(_user, _targetTile);
	}
});
