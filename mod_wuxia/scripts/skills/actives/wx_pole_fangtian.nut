// Active Move: 画戟月牙斩
this.wx_pole_fangtian <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_pole_fangtian";
		this.m.Name = "画戟月牙斩";
		this.m.Description = "方天长戟月牙钩劈：消耗 6 AP 与 28 内息，专破重甲头颈（两格射程，破甲 +30%，击头率 +12%）。";
		this.m.Icon = "skills/wx_pole_fangtian.png";
		this.m.IconDisabled = "skills/wx_pole_fangtian_sw.png";
		this.m.Overlay = "wx_ov_wx_pole_fangtian";
		this.m.WX_VfxBrush <- "wx_vfx_07";
		this.m.WX_AnimID <- "wx_anim_26";
		this.m.WX_AnimMode <- "halberd_x";
		this.m.WX_ChoreoID <- "wx_pole_fangtian";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Polearm", "Spear", "Axe"];
		this.m.DirectDamageMult = 0.32;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageArmorMult *= 1.30; _properties.HitChance[::Const.BodyPart.Head] += 12; _properties.DamageTotalMult *= 1.12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		return hit;
	}
});
