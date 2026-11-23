// Active Move: 牙旗破阵刺
this.wx_spear_yaqi <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_yaqi";
		this.m.Name = "牙旗破阵刺";
		this.m.Description = "中军掌旗战枪秘技：消耗 5 AP 与 20 内息，挥舞牙旗长枪贯阵（命中 +8，总伤 +14%，并振奋周身相邻同袍军心）。";
		this.m.Icon = "skills/wx_spear_yaqi.png";
		this.m.IconDisabled = "skills/wx_spear_yaqi_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_yaqi";
		this.m.WX_VfxBrush <- "wx_vfx_24";
		this.m.WX_AnimID <- "wx_anim_114";
		this.m.WX_AnimMode <- "aoe_yaqi";
		this.m.WX_ChoreoID <- "wx_spear_yaqi";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.14;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			local myT = _user.getTile(); for (local d = 0; d < ::Const.Direction.COUNT; d = ++d) { if (!myT.hasNextTile(d)) continue; local nt = myT.getNextTile(d); if (nt.IsOccupiedByActor && _user.isAlliedWith(nt.getEntity())) nt.getEntity().checkMorale(1, 10); }
		}
		return hit;
	}
});
