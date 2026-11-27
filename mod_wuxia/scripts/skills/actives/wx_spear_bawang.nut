// Active Move: 霸王挑山枪
this.wx_spear_bawang <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_bawang";
		this.m.Name = "霸王挑山枪";
		this.m.Description = "刚猛绝伦军阵霸枪：消耗 6 AP 与 26 内息，贴身命中且自身背后为空地时触发【挑飞过肩换位】将敌军挑摔至身后合围圈；两格命中则破蓄势震退并挂失衡（总伤 +20%、破甲 +20%）。";
		this.m.Icon = "skills/wx_spear_bawang.png";
		this.m.IconDisabled = "skills/wx_spear_bawang_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_bawang";
		this.m.WX_VfxBrush <- "wx_vfx_05";
		this.m.WX_AnimID <- "wx_anim_55";
		this.m.WX_AnimMode <- "dragon_up";
		this.m.WX_ChoreoID <- "wx_spear_bawang";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.32;
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
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			local flipped = ("Streams" in ::Wuxia) && ::Wuxia.Streams.vaultFlipOverShoulder(_user, target);
			if (!flipped)
				this.wxTryKnockback(_user, target);
		}
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
