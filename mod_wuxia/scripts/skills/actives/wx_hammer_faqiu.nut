// Active Move: 发丘分金锤
this.wx_hammer_faqiu <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_hammer_faqiu";
		this.m.Name = "发丘分金锤";
		this.m.Description = "摸金校尉破棺绝技：消耗 4 AP 与 16 内息，专寻古墓铜俑与重甲铆钉痛击（破甲 +35%，对尸傀机关总伤 +25%）。";
		this.m.Icon = "skills/wx_hammer_faqiu.png";
		this.m.IconDisabled = "skills/wx_hammer_faqiu_sw.png";
		this.m.Overlay = "wx_ov_wx_hammer_faqiu";
		this.m.WX_VfxBrush <- "wx_vfx_05";
		this.m.WX_AnimID <- "wx_anim_126";
		this.m.WX_AnimMode <- "pierce_faqiu";
		this.m.WX_ChoreoID <- "wx_hammer_faqiu";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Hammer"];
		this.m.DirectDamageMult = 0.40;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageArmorMult *= 1.35; if (_targetEntity != null && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)) _properties.DamageTotalMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			
		}
		return hit;
	}
});
