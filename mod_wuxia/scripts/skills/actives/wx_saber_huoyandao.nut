// Active Move: 太原火焰斩 (1~2 tile blazing saber/palm qi slash, 5 AP, 24 Qi)
this.wx_saber_huoyandao <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_huoyandao";
		this.m.Name = "太原火焰斩";
		this.m.Description = "晋阳烈阳刀罡绝诣：消耗 5 AP 与 24 内息，运炽烈真气于刀脊或掌缘，隔步劈出一道灼热火焰刀气重斩 1~2 格目标（命中 +6，总伤 +15%，破甲 +25%，命中灼蚀身甲 10 点、留破绽并震慑战意）。";
		this.m.KilledString = "烈焰刀罡劈裂";
		this.m.Icon = "skills/wx_saber_huoyandao.png";
		this.m.IconDisabled = "skills/wx_saber_huoyandao_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_huoyandao";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_73";
		this.m.WX_AnimMode <- "taiyuan_flame";
		this.m.WX_ChoreoID <- "wx_saber_huoyandao";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 24;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Cleaver", "Fist"];
		this.m.DirectDamageMult = 0.32;
		this.m.IsIgnoredAsAOO = true;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6;
			_properties.DamageTotalMult *= 1.15;
			_properties.DamageArmorMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			if (::Wuxia.hasMember(target, "getItems") && target.getItems() != null)
			{
				local tBody = target.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (tBody != null && tBody.getArmor() > 0)
					tBody.setArmor(::Math.max(0, tBody.getArmor() - 10));
			}
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
				target.checkMorale(-1, -10);
		}
		return hit;
	}
});
