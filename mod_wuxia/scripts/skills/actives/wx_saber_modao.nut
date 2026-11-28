// Active Move: 陌刀碎骑斩
this.wx_saber_modao <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_modao";
		this.m.Name = "陌刀碎骑斩";
		this.m.Description = "唐宋军阵重型长刀绝杀：消耗 6 AP 与 28 内息，两格纵劈重创敌阵（总伤 +20%、破甲 +20%，强行劈断敌方蓄势/山海凶兆并击退一格）。";
		this.m.Icon = "skills/wx_saber_modao.png";
		this.m.IconDisabled = "skills/wx_saber_modao_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_modao";
		this.m.WX_VfxBrush <- "wx_vfx_05";
		this.m.WX_AnimID <- "wx_anim_47";
		this.m.WX_AnimMode <- "modao_upcut";
		this.m.WX_ChoreoID <- "wx_saber_modao";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Cleaver", "Sword"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageTotalMult *= 1.20; _properties.DamageArmorMult *= 1.20;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.interruptEnemyCharge(_user, target, 2);
			this.wxTryKnockback(_user, target);
		}
		return hit;
	}
});
