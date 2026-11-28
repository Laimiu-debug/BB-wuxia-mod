// Active Move: 伏虎罗汉拳
this.wx_fist_luohan <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_luohan";
		this.m.Name = "伏虎罗汉拳";
		this.m.Description = "少室护寺入门刚拳：消耗 4 AP 与 13 内息，沉肩出拳虎虎生风（命中 +8，总伤 +12%）。";
		this.m.Icon = "skills/wx_fist_luohan.png";
		this.m.IconDisabled = "skills/wx_fist_luohan_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_luohan";
		this.m.WX_VfxBrush <- "wx_vfx_09";
		this.m.WX_AnimID <- "wx_anim_109";
		this.m.WX_AnimMode <- "flurry_luohan";
		this.m.WX_ChoreoID <- "wx_fist_luohan";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 13;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.34;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive() && ("Streams" in ::Wuxia))
		{
			::Wuxia.Streams.applyHiddenForce(target, 1, _user);
		}
		return hit;
	}
});
