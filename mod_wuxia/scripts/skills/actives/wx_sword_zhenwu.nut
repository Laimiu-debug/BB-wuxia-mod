// Active Move: 真武七星剑
this.wx_sword_zhenwu <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_zhenwu";
		this.m.Name = "真武七星剑";
		this.m.Description = "太和镇山剑阵绝学：消耗 5 AP 与 22 内息，脚踏魁罡七星剑步斩邪破煞（命中 +10，对尸傀妖邪与失衡之敌总伤 +25%）。";
		this.m.Icon = "skills/wx_sword_zhenwu.png";
		this.m.IconDisabled = "skills/wx_sword_zhenwu_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_zhenwu";
		this.m.WX_VfxBrush <- "wx_vfx_12";
		this.m.WX_AnimID <- "wx_anim_83";
		this.m.WX_AnimMode <- "taiji_zhenwu";
		this.m.WX_ChoreoID <- "wx_sword_zhenwu";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.32;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; if (_targetEntity != null && (::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) || _targetEntity.getSkills().hasSkill("effects.wx_status_offbalance"))) _properties.DamageTotalMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		return hit;
	}
});
