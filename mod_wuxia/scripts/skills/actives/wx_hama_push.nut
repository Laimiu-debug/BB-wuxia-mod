// Active Move: 金蟾推山扑 (Toad-stance 1~2 tile pounce & internal-force shockwave, 5 AP, 25 Qi, 2-turn cooldown)
this.wx_hama_push <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {
		Cooldown = 0
	},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_hama_push";
		this.m.Name = "金蟾推山扑";
		this.m.Description = "白驼逆脉蓄劲绝招：消耗 5 AP 与 25 内息，俯身鼓腮蓄足奇门真气猛扑 1~2 格目标（若相隔两格且敌前有空地则飞身跃近），双掌排山倒海重创敌手（命中 +10，总伤 +30%，穿甲 +20%，震退敌手并施加内伤与失衡，自身凝结「蓄势」；冷却 2 回合）。";
		this.m.KilledString = "蛤蟆神功震毙";
		this.m.Icon = "skills/wx_hama_push.png";
		this.m.IconDisabled = "skills/wx_hama_push_sw.png";
		this.m.Overlay = "wx_ov_wx_hama_push";
		this.m.WX_VfxBrush <- "wx_vfx_28";
		this.m.WX_AnimID <- "wx_anim_75";
		this.m.WX_AnimMode <- "toad_leap_slam";
		this.m.WX_ChoreoID <- "wx_hama_push";
		this.m.SoundOnUse = [
			"sounds/combat/hand_01.wav",
			"sounds/combat/hand_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/bash_hit_01.wav",
			"sounds/combat/bash_hit_02.wav",
			"sounds/combat/bash_hit_03.wav"
		];
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 25;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Fist", "Staff", "Sword", "Cleaver", "Spear", "Polearm", "Hammer", "Axe", "Flail", "Dagger"];
		this.m.DirectDamageMult = 0.40;
		this.m.IsIgnoredAsAOO = true;
	}

	function wxFormatWeaponList()
	{
		return "拳掌护手 / 棍杖及任意近战兵刃";
	}

	function onTurnStart()
	{
		if (this.m.Cooldown > 0) this.m.Cooldown -= 1;
	}

	function onCombatStarted()
	{
		this.m.Cooldown = 0;
	}

	function onCombatFinished()
	{
		this.m.Cooldown = 0;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			local cont = this.getContainer();
			local actor = cont != null ? cont.getActor() : null;
			local tf = (actor != null && "Streams" in ::Wuxia) ? ::Wuxia.Streams.peekToadForce(actor) : 0;
			_properties.MeleeSkill += (10 + tf * 3);
			_properties.DamageTotalMult *= (1.30 + tf * 0.12);
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.addCappedPen(_properties, 0.20);
		}
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local target = _targetTile.getEntity();

		if (_user != null && _user.isPlacedOnMap() && !_user.getCurrentProperties().IsRooted && _user.getTile().getDistanceTo(_targetTile) == 2)
		{
			local uTile = _user.getTile();
			local dir = uTile.getDirectionTo(_targetTile);
			local leapTile = null;
			if (uTile.hasNextTile(dir))
			{
				local cand = uTile.getNextTile(dir);
				if (cand.IsEmpty && !cand.IsOccupiedByActor && cand.getDistanceTo(_targetTile) == 1 && ::Math.abs(cand.Level - uTile.Level) <= 2 && ::Math.abs(cand.Level - _targetTile.Level) <= 1)
					leapTile = cand;
			}
			if (leapTile == null)
			{
				for (local d = 0; d < ::Const.Direction.COUNT; d = ++d)
				{
					if (!uTile.hasNextTile(d)) continue;
					local cand2 = uTile.getNextTile(d);
					if (cand2.IsEmpty && !cand2.IsOccupiedByActor && cand2.getDistanceTo(_targetTile) == 1 && ::Math.abs(cand2.Level - uTile.Level) <= 2 && ::Math.abs(cand2.Level - _targetTile.Level) <= 1)
					{
						leapTile = cand2;
						break;
					}
				}
			}
			if (leapTile != null)
			{
				::Wuxia.VFX.playTriggerVfx(uTile, "wx_vfx_28", "wx_fx_sonic_ring", -45, 0, 1.05);
				::Tactical.getNavigator().teleport(_user, leapTile, null, null, false);
			}
		}

		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		local consumedTF = ("Streams" in ::Wuxia) ? ::Wuxia.Streams.consumeToadForce(_user) : 0;
		if (hit && target != null && target.isAlive())
		{
			this.wxTryKnockback(_user, target);
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
				this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		if (consumedTF > 0 && _targetTile != null && ::Wuxia.hasMember(_targetTile, "hasNextTile"))
		{
			local shock = consumedTF * 8;
			for (local d2 = 0; d2 < 6; d2 = ++d2)
			{
				if (!_targetTile.hasNextTile(d2)) continue;
				local adj = _targetTile.getNextTile(d2);
				if (adj != null && adj.IsOccupiedByActor && adj.getEntity() != null && adj.getEntity().isAlive() && !_user.isAlliedWith(adj.getEntity()))
				{
					local ae = adj.getEntity();
					if (ae.getHitpoints() > shock + 1) ae.setHitpoints(ae.getHitpoints() - shock);
					else ae.setHitpoints(1);
					this.wxApplyStatusToTarget(ae, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				}
			}
		}
		if (_user != null && _user.isAlive() && ::Wuxia.hasMember(_user, "getSkills") && _user.getSkills() != null)
		{
			local usk = _user.getSkills();
			if (!usk.hasSkill("effects.wx_status_poise_charge"))
				usk.add(::new("scripts/skills/effects/wx_status_poise_charge"));
		}
		return hit;
	}
});
