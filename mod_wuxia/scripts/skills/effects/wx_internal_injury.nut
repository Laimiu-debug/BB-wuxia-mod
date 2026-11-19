// Status Effect: 内伤 / 经脉震荡 / 永久暗疾 (Separate from external wounds; healed by 护心丹 or famous physician)

this.wx_internal_injury <- this.inherit("scripts/skills/skill", {
	m = {
		Severity          = 1,     // 1 = 轻度内伤, 2 = 经脉震荡(重度内伤)
		DaysRemaining     = 3,
		PermanentScars    = 0      // 永久经脉暗疾层数（洗髓冲高星失败未服护脉丹所致）
	},

	function create()
	{
		this.m.ID = "effects.wx_internal_injury";
		this.m.Name = "内伤";
		this.m.Description = "真气受损或经脉震荡，普通金疮散难以奏效，须服护心丹或寻名医调理。";
		this.m.Icon = "ui/injury/injury_icon_15.png";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = true;
		this.m.IsRemovedAfterBattle = false;
	}

	function applySeverity( _severity, _days )
	{
		this.m.Severity = ::Math.max(this.m.Severity, _severity);
		this.m.DaysRemaining = ::Math.max(this.m.DaysRemaining, _days);
		this.updateLabel();
	}

	function addPermanentMeridianScar()
	{
		this.m.PermanentScars += 1;
		this.updateLabel();
	}

	function cureTemporary()
	{
		this.m.Severity = 0;
		this.m.DaysRemaining = 0;
		if (this.m.PermanentScars <= 0)
		{
			this.removeSelf();
		}
		else
		{
			this.updateLabel();
		}
	}

	function updateLabel()
	{
		if (this.m.Severity >= 2) this.m.Name = "经脉震荡";
		else if (this.m.Severity == 1) this.m.Name = "内伤";
		else if (this.m.PermanentScars > 0) this.m.Name = "经脉暗疾";
	}

	function getTooltip()
	{
		this.updateLabel();
		local ret = [
			{ id = 1, type = "title", text = this.m.Name + (this.m.DaysRemaining > 0 ? "（余 " + this.m.DaysRemaining + " 日）" : "") },
			{ id = 2, type = "description", text = this.getDescription() }
		];
		if (this.m.Severity >= 2)
		{
			ret.push({ id = 10, type = "text", icon = "ui/icons/fatigue.png", text = "[color=" + ::Const.UI.Color.NegativeValue + "]-30%[/color] 内息上限，每回合回气 [color=" + ::Const.UI.Color.NegativeValue + "]-4[/color]" });
			ret.push({ id = 11, type = "text", icon = "ui/icons/health.png", text = "[color=" + ::Const.UI.Color.NegativeValue + "]-15%[/color] 气血上限" });
		}
		else if (this.m.Severity == 1)
		{
			ret.push({ id = 10, type = "text", icon = "ui/icons/fatigue.png", text = "[color=" + ::Const.UI.Color.NegativeValue + "]-15%[/color] 内息上限，每回合回气 [color=" + ::Const.UI.Color.NegativeValue + "]-2[/color]" });
		}
		if (this.m.PermanentScars > 0)
		{
			ret.push({ id = 12, type = "text", icon = "ui/icons/fatigue.png", text = "永久暗疾（" + this.m.PermanentScars + " 处）：内息上限永久 [color=" + ::Const.UI.Color.NegativeValue + "]-" + (this.m.PermanentScars * 8) + "[/color]" });
		}
		return ret;
	}

	function onUpdate( _properties )
	{
		if (this.m.Severity >= 2)
		{
			_properties.StaminaMult *= 0.70;
			_properties.HitpointsMult *= 0.85;
			_properties.FatigueRecoveryRate -= 4;
		}
		else if (this.m.Severity == 1)
		{
			_properties.StaminaMult *= 0.85;
			_properties.FatigueRecoveryRate -= 2;
		}
		if (this.m.PermanentScars > 0)
		{
			_properties.Stamina -= (this.m.PermanentScars * 8);
		}
	}

	function onNewDay()
	{
		if (this.m.DaysRemaining > 0)
		{
			this.m.DaysRemaining -= 1;
			if (this.m.DaysRemaining <= 0)
			{
				this.m.Severity = 0;
				if (this.m.PermanentScars <= 0)
				{
					this.removeSelf();
					return;
				}
				this.updateLabel();
			}
		}
	}

	function onSerialize( _out )
	{
		this.skill.onSerialize(_out);
		_out.writeU8(this.m.Severity);
		_out.writeU8(this.m.DaysRemaining);
		_out.writeU8(this.m.PermanentScars);
	}

	function onDeserialize( _in )
	{
		this.skill.onDeserialize(_in);
		this.m.Severity = _in.readU8();
		this.m.DaysRemaining = _in.readU8();
		this.m.PermanentScars = _in.readU8();
		this.updateLabel();
	}
});
