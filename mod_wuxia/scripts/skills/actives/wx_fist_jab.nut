// Paired Fist Basic Move 1: 冲拳 (4 AP, 9 Qi, blunt strike)

this.wx_fist_jab <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_jab";
		this.m.Name = "冲拳";
		this.m.Description = "沉肩出拳直击中宫：轻快扎实的基础拳招，耗气低廉，造成钝劲外伤。";
		this.m.KilledString = "震碎心脉";
		this.m.Icon = "skills/active_08.png";
		this.m.IconDisabled = "skills/active_08_sw.png";
		this.m.Overlay = "active_08";
		this.m.SoundOnUse = [
			"sounds/combat/hand_01.wav",
			"sounds/combat/hand_02.wav",
			"sounds/combat/hand_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/hand_hit_01.wav",
			"sounds/combat/hand_hit_02.wav",
			"sounds/combat/hand_hit_03.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 9;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.35;
	}

	function onUse( _user, _targetTile )
	{
		return this.attackEntity(_user, _targetTile.getEntity());
	}
});
