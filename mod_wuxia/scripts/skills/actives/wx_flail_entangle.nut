// Secret Flail/Whip Move: 锁喉缠丝劲 (4 AP, 18 Qi, range 1-2: +8 hit, bypasses shield, seals acupoints)

this.wx_flail_entangle <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_flail_entangle";
		this.m.WX_VfxBrush <- "wx_vfx_31";
		this.m.WX_AnimID <- "wx_anim_64";
		this.m.WX_AnimMode <- "neck_coil";
		this.m.WX_ChoreoID <- "wx_flail_entangle";
		this.m.Name = "锁喉缠丝劲";
		this.m.Description = "抖出九节软鞭或流星链索缠绕颈腕要穴（1~2 格）：无视盾牌防御补正、命中 +8，击中生人敌军附加「封穴」截断回气！";
		this.m.KilledString = "软鞭绞断咽喉";
		this.m.Icon = "skills/wx_flail_entangle.png";
		this.m.IconDisabled = "skills/wx_flail_entangle_sw.png";
		this.m.Overlay = "wx_ov_wx_flail_entangle";
		this.m.SoundOnUse = [
			"sounds/combat/slash_01.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/slash_hit_01.wav"
		];
		this.m.IsShieldRelevant = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.MaxLevelDifference = 2;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Flail"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8;
			_properties.DamageTotalMult *= 0.85;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
		}
		return hit;
	}
});
