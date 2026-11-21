// Sect Flail/Whip Move: 云梦绕盾抽 (4 AP, 16 Qi, ignores shield defense bonus, +15% head hit chance, inflicts off-balance)

this.wx_flail_lash <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_flail_lash";
		this.m.WX_VfxBrush <- "wx_vfx_32";
		this.m.WX_AnimID <- "wx_anim_63";
		this.m.WX_AnimMode <- "over_shield";
		this.m.WX_ChoreoID <- "wx_flail_lash";
		this.m.Name = "云梦绕盾抽";
		this.m.Description = "抖腕甩出软鞭连枷绕过盾牌死角：无视目标盾牌近防加值，击中头部几率额外 +15%，命中扰乱重心致「失衡」。";
		this.m.KilledString = "软鞭碎颅";
		this.m.Icon = "skills/wx_flail_lash.png";
		this.m.IconDisabled = "skills/wx_flail_lash_sw.png";
		this.m.Overlay = "wx_ov_wx_flail_lash";
		this.m.SoundOnUse = [
			"sounds/combat/flail_01.wav",
			"sounds/combat/flail_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/flail_hit_01.wav",
			"sounds/combat/flail_hit_02.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.IsShieldRelevant = false;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Flail"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.HitChance[this.Const.BodyPart.Head] += 15;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
