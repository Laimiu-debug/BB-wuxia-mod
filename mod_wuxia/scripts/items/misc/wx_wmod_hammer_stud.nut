this.wx_wmod_hammer_stud <- this.inherit("scripts/items/misc/wx_wmod_base", {
	m = {},
	function create()
	{
		this.wx_wmod_base.create();
		this.initWeaponMod("wx_wmod_hammer_stud");
	}
});
