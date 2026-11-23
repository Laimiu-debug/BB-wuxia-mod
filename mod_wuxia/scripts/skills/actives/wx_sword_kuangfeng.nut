// Active Move: 落英疾风剑
this.wx_sword_kuangfeng <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_kuangfeng";
		this.m.Name = "落英疾风剑";
		this.m.Description = "江湖快剑连环抢攻：消耗 4 AP 与 14 内息，剑光如落英缤纷疾削皮肉（命中 +8，伤血致敌流血）。";
		this.m.Icon = "skills/wx_sword_kuangfeng.png";
		this.m.IconDisabled = "skills/wx_sword_kuangfeng_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_kuangfeng";
		this.m.WX_VfxBrush <- "wx_vfx_26";
		this.m.WX_AnimID <- "wx_anim_85";
		this.m.WX_AnimMode <- "flurry_luoying";
		this.m.WX_ChoreoID <- "wx_sword_kuangfeng";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 14;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.26;
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
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) this.wxApplyStatusToTarget(target, "effects.bleeding", "scripts/skills/effects/bleeding_effect");
		}
		return hit;
	}
});
