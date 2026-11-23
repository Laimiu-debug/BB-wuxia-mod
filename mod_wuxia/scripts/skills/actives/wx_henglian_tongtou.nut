// Active Move: 铜头撞山劲
this.wx_henglian_tongtou <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = { Cooldown = 0 },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_henglian_tongtou";
		this.m.Name = "铜头撞山劲";
		this.m.Description = "外家铁头功近身奇招：消耗 4 AP 与 18 内息，无视主手兵刃限制以精铜铁额猛撞相邻敌军，致其失衡并震退一格（冷却 2 回合）。";
		this.m.Icon = "skills/wx_henglian_tongtou.png";
		this.m.IconDisabled = "skills/wx_henglian_tongtou_sw.png";
		this.m.Overlay = "wx_ov_wx_henglian_tongtou";
		this.m.WX_VfxBrush <- "wx_vfx_17";
		this.m.WX_AnimID <- "wx_anim_162";
		this.m.WX_AnimMode <- "pierce_tongtou";
		this.m.WX_ChoreoID <- "wx_henglian_tongtou";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword", "Saber", "Cleaver", "Spear", "Polearm", "Staff", "Fist", "Hammer", "Axe", "Flail", "Dagger"];
		this.m.DirectDamageMult = 0.40;
	}
	function onTurnStart() { if ((::Wuxia.hasMember(this.m, "Cooldown")) && this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; _properties.HitChance[::Const.BodyPart.Head] += 25;
		}
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxTryKnockback(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
