// Sword Stream Flagship Move #1: 清风连环剑 (Same-Slot 3-Stage Dynamic Sword Progression + Field `气剑残影` Spawning!)
// Stage 0 (`一式·清风起剑`, 3 AP / 12 Qi): Swift opening slash (+10 Hit, applies `破绽`) -> flips slot to Stage 1
// Stage 1 (`二式·流云承影`, 4 AP / 14 Qi): Flowing follow-up (+12 Hit, plants a `驻场气剑残影` on battlefield) -> flips slot to Stage 2
// Stage 2 (`三式·惊鸿归风`, 4 AP / 15 Qi): Finisher (+14 Hit, +10% Pen, detonates `破绽` for +8 Qi & spawns a 2nd `气剑残影`) -> resets to Stage 0

this.wx_sword_combo <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_combo";
		this.m.WX_VfxBrush <- "wx_vfx_01";
		this.m.WX_AnimID <- "wx_anim_01";
		this.m.WX_AnimMode <- "combo3";
		this.m.WX_ChoreoID <- "wx_sword_combo";
		this.m.Name = "清风连环剑·一式起剑";
		this.m.Description = "剑宗同槽三叠连剑【一式·起手】：消耗 3 AP 与 12 内息，轻灵点刺（命中 +10）并挂【破绽】；出招后同一技能槽自动递进为【二式·流云承影】与【三式·惊鸿归风】并凝出驻场气剑！";
		this.m.Icon = "skills/wx_sword_combo.png";
		this.m.IconDisabled = "skills/wx_sword_combo_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_combo";
		this.m.SoundOnUse = [
			"sounds/combat/riposte_01.wav",
			"sounds/combat/riposte_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/slash_hit_01.wav",
			"sounds/combat/slash_hit_02.wav"
		];
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 12;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.IsDoingForwardMove = false;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.25;

		this.m.WX_ComboForms = [
			{
				Stage = 0, AP = 3, Fatigue = 12, HitAdd = 10, DmgMult = 0.92, PenAdd = 0.0,
				Name = "清风连环剑·一式起剑",
				Description = "剑宗同槽三叠连剑【一式·起手】：3 AP 轻快寻隙（命中 +10、总伤 92%），命中留【破绽】并将此槽翻转为【二式·流云承影】。"
			},
			{
				Stage = 1, AP = 4, Fatigue = 14, HitAdd = 12, DmgMult = 1.05, PenAdd = 0.05,
				Name = "清风连环剑·二式流云",
				Description = "剑宗同槽三叠连剑【二式·承接】：4 AP 随风递剑（命中 +12、总伤 +5%、穿甲 +5%），在目标身畔凝出一柄【驻场气剑残影】，并将此槽翻转为终结技【三式·惊鸿归风】！"
			},
			{
				Stage = 2, AP = 4, Fatigue = 15, HitAdd = 14, DmgMult = 1.16, PenAdd = 0.10,
				Name = "清风连环剑·三式归风",
				Description = "剑宗同槽三叠连剑【三式·终结】：4 AP 剑气贯虹（命中 +14、总伤 +16%、穿甲 +10%），引爆【破绽】回补 8 内息、再凝一柄【驻场气剑残影】，随后收剑归元！"
			}
		];
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			local cf = this.wxGetActiveComboForm();
			if (cf != null)
			{
				_properties.MeleeSkill += cf.HitAdd;
				_properties.DamageTotalMult *= cf.DmgMult;
				if (cf.PenAdd > 0.0) _properties.DamageDirectAdd += cf.PenAdd;
			}
			else
			{
				_properties.MeleeSkill += 10;
			}
		}
	}

	function onUse( _user, _targetTile )
	{
		local stage = ("Streams" in ::Wuxia) ? ::Wuxia.Streams.getComboStage(_user, this.m.ID) : 0;
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);

		if (hit && target != null && target.isAlive())
		{
			if (stage == 0)
			{
				this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
			else if (stage == 1)
			{
				::Wuxia.Streams.spawnSwordNode(_user, _targetTile);
			}
			else
			{
				::Wuxia.Streams.spawnSwordNode(_user, _targetTile);
				local tsk = target.getSkills();
				if (tsk != null && tsk.hasSkill("effects.wx_status_opening"))
				{
					tsk.removeByID("effects.wx_status_opening");
					::Wuxia.CombatRules.restoreQi(_user, 8);
				}
			}
		}

		if ("Streams" in ::Wuxia)
		{
			if (hit)
				::Wuxia.Streams.advanceComboStage(_user, this.m.ID, 3, false);
			else
				::Wuxia.Streams.resetComboStage(_user, this.m.ID);
		}
		return hit;
	}
});
