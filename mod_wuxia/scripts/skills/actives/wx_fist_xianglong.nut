// Beggar / Shaolin Stream Flagship Move #2: 亢龙有悔掌 ⇄ 亢龙有悔·三叠浪 (Same-Slot Dragon-Wave Upgrade + Hidden-Force Detonation!)

this.wx_fist_xianglong <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_xianglong";
		this.m.Name = "亢龙有悔掌";
		this.m.Description = "天下至刚阳掌绝诣：消耗 6 AP 与 28 内息，掌力吐三分留七分（命中 +8，总伤 +18%，穿甲 +12%，震退并引爆目标【寸劲伏脉】）；每掌积蓄 1 层【潜龙叠浪】，满 2 层时此槽自动升格为贯透直线 3 格的终结奥义【亢龙有悔·三叠浪】！";
		this.m.Icon = "skills/wx_fist_xianglong.png";
		this.m.IconDisabled = "skills/wx_fist_xianglong_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_xianglong";
		this.m.WX_VfxBrush <- "wx_vfx_09";
		this.m.WX_AnimID <- "wx_anim_05";
		this.m.WX_AnimMode <- "dragon_coil";
		this.m.WX_ChoreoID <- "wx_fist_xianglong";
		this.m.SoundOnUse = ["sounds/combat/bash_01.wav", "sounds/combat/bash_02.wav"];
		this.m.SoundOnHit = ["sounds/combat/bash_hit_01.wav", "sounds/combat/bash_hit_02.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.IsDoingForwardMove = false;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.42;
	}

	function wxHasTripleWave()
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		local st = (actor != null && ("Streams" in ::Wuxia)) ? ::Wuxia.Streams.getState(actor) : null;
		return st != null && st.m.DragonWaves >= 2;
	}

	function getName()
	{
		return this.wxHasTripleWave() ? "亢龙有悔·三叠浪" : this.m.Name;
	}

	function getDescription()
	{
		if (this.wxHasTripleWave())
			return "【潜龙圆满·同槽升阶终结式】三股至刚真龙掌浪排山倒海贯透直线 3 格（命中 +14、总伤 +28%、穿甲 +15%），当场引爆沿途所有敌军体内的【寸劲伏脉】并焚干毒泽冻土！";
		return this.m.Description;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			local triple = this.wxHasTripleWave();
			_properties.MeleeSkill += triple ? 14 : 8;
			_properties.DamageTotalMult *= triple ? 1.28 : 1.18;
			local room = ::Math.maxf(0.0, 0.25 - _properties.DamageDirectAdd);
			_properties.DamageDirectAdd += ::Math.minf(room, triple ? 0.15 : 0.12);
		}
	}

	function onUse( _user, _targetTile )
	{
		local triple = this.wxHasTripleWave();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);

		if (hit && target != null && target.isAlive())
		{
			local tsk = target.getSkills();
			local hf = tsk != null ? tsk.getSkillByID("effects.wx_status_hidden_force") : null;
			if (hf != null) hf.detonate(_user);
			else this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
			this.wxTryKnockback(_user, target);
		}

		// Triple Dragon Wave (`亢龙有悔·三叠浪`): surge 2 additional hexes down the attack line!
		if (triple && "Streams" in ::Wuxia)
		{
			local st = ::Wuxia.Streams.getState(_user);
			if (st != null) st.m.DragonWaves = 0;

			local uTile = ::Wuxia.hasMember(_user, "getTile") ? _user.getTile() : null;
			if (uTile != null && _targetTile != null && ::Wuxia.hasMember(uTile, "getDirectionTo") && ::Wuxia.hasMember(_targetTile, "hasNextTile"))
			{
				local dir = uTile.getDirectionTo(_targetTile);
				local cur = _targetTile;
				for (local w = 1; w <= 2; w = ++w)
				{
					if (cur == null || dir < 0 || !cur.hasNextTile(dir)) break;
					cur = cur.getNextTile(dir);
					if (cur == null) break;
					::Wuxia.TileField.setField(cur, "drought_scorch", 2, _user);
					if ("IsOccupiedByActor" in cur && cur.IsOccupiedByActor)
					{
						local lEnt = cur.getEntity();
						if (lEnt != null && lEnt.isAlive() && !_user.isAlliedWith(lEnt))
						{
							local waveHP = (w == 1) ? 24 : 18;
							if (lEnt.getHitpoints() > waveHP + 1) lEnt.setHitpoints(lEnt.getHitpoints() - waveHP);
							else lEnt.setHitpoints(1);
							local lsk = lEnt.getSkills();
							local lhf = lsk != null ? lsk.getSkillByID("effects.wx_status_hidden_force") : null;
							if (lhf != null) lhf.detonate(_user);
						}
					}
				}
			}
			if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("[color=#d9822b]【亢龙有悔·三叠浪】" + ::Const.UI.getColorizedEntityName(_user) + " 双掌齐推，三叠金色龙形气浪轰穿整条阵线！[/color]");
		}
		else if (hit && "Streams" in ::Wuxia)
		{
			local st2 = ::Wuxia.Streams.getOrCreateState(_user);
			if (st2 != null) st2.addDragonWave(1, 2);
		}
		return hit;
	}
});
