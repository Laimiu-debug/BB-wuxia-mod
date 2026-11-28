// Active Move: 金蛇缠魂鞭
this.wx_flail_jinshe <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_flail_jinshe";
		this.m.Name = "金蛇缠魂鞭";
		this.m.Description = "五毒金蛇毒鞭秘录：消耗 4 AP 与 18 内息，两格软鞭如金蛇噬颈（绕盾命中 +8，附加奇毒蚀脉与封穴）。";
		this.m.Icon = "skills/wx_flail_jinshe.png";
		this.m.IconDisabled = "skills/wx_flail_jinshe_sw.png";
		this.m.Overlay = "wx_ov_wx_flail_jinshe";
		this.m.WX_VfxBrush <- "wx_vfx_28";
		this.m.WX_AnimID <- "wx_anim_135";
		this.m.WX_AnimMode <- "whip_jinshe";
		this.m.WX_ChoreoID <- "wx_flail_jinshe";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav", "sounds/combat/slash_hit_02.wav"];
		this.m.IsShieldRelevant = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.MaxLevelDifference = 2;
		this.m.RequiredWeaponTypes = ["Flail"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
			this.wxApplyStatusToTarget(target, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
			this.wxTryPullToAdjacent(_user, target);
		}
		return hit;
	}
});
