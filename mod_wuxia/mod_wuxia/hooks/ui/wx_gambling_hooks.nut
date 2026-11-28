// Non-Destructive Modern Hooks for Wuxia Tavern Gambling (`迎客酒肆 · 长乐赌桌`) & Martial Arts Tournament (`武林大会 · 演武签表与下注`)

// 1. Arena Building (`红绸生死演武擂`): Dual-Gate Entrance (`红绸生死擂` vs `天下武林大会`)
::Wuxia.HooksMod.hook("scripts/entity/world/settlements/buildings/arena_building", function( q )
{
	q.m.WX_BypassGate <- false;

	q.WX_NativeArenaClick <- function( _screen )
	{
		this.m.WX_BypassGate = true;
		try
		{
			return this.onClicked(_screen);
		}
		catch (err)
		{
			this.m.WX_BypassGate = false;
			throw err;
		}
	};

	q.onClicked = @(__original) function( _screen )
	{
		if (this.m.WX_BypassGate)
		{
			this.m.WX_BypassGate = false;
			return __original(_screen);
		}
		if (!::Wuxia.Gambling.ensure() || ::Wuxia.Tournament.currentVenue() == null)
			return __original(_screen);
		if (_screen != null && _screen.getMainDialogModule() != null && _screen.getMainDialogModule().m.JSHandle != null)
		{
			_screen.getMainDialogModule().m.JSHandle.asyncCall("wxTournamentEntrance", null);
			return;
		}
		return __original(_screen);
	};
});

// 2. Town Screen & Town Main Dialog RPCs
::Wuxia.HooksMod.hook("scripts/ui/screens/world/world_town_screen", function( q )
{
	if (::Wuxia.qHas(q, "queryTownInformation"))
	{
		q.queryTownInformation = @(__original) function()
		{
			local data = __original();
			if (data != null && typeof data == "table" && this.m.Town != null)
			{
				data.rawset("WX_HasArenaBuilding", this.m.Town.hasBuilding("building.arena"));
				data.rawset("WX_IsTournamentHost", ::Wuxia.Tournament.isHostTown(this.m.Town));
				if (::Wuxia.Gambling.ensure())
					data.rawset("WX_PendingGamble", ::Wuxia.Gambling.State.game != null ? ::Wuxia.Gambling.State.game.kind : "");
			}
			return data;
		};
	}
});

::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_main_dialog_module", function( q )
{
	if (!::Wuxia.qHas(q, "onWXShowcaseSound"))
	{
		q.onWXShowcaseSound <- function( _cue )
		{
			local key = (typeof _cue == "array" && _cue.len() > 0) ? _cue[0] : _cue;
			::Wuxia.UI.playShowcaseSound(key);
			return { ok = true };
		};
	}

	q.onWXTournamentAction <- function( _data )
	{
		return ::Wuxia.Tournament.handleTournamentAction(this.m.Parent, _data);
	};

	q.onWXCasinoAction <- function( _data )
	{
		if (this.m.Parent == null || this.m.Parent.getTown() == null)
			return { ok = false, closed = true, message = "你已离开城镇。" };
		local res = ::Wuxia.Gambling.handleCasinoAction(_data, this.m.Parent.getTown());
		if (res != null && typeof res == "table" && !("closed" in res && res.closed))
			res.rawset("Assets", this.m.Parent.queryAssetsInformation());
		return res;
	};

	q.onWXGamblingSound <- function( _key )
	{
		return ::Wuxia.Gambling.playSound(_key);
	};
});

// 3. Town Tavern Dialog RPCs & Rumor Integration (`迎客酒肆`)
::Wuxia.HooksMod.hook("scripts/ui/screens/world/modules/world_town_screen/town_tavern_dialog_module", function( q )
{
	q.queryData = @(__original) function()
	{
		local res = __original();
		if (res != null && this.m.Tavern != null && ::Wuxia.Gambling.ensure())
		{
			local town = this.m.Tavern.getSettlement();
			res.rawset("WX_IsTournamentHost", ::Wuxia.Tournament.isHostTown(town));
			res.rawset("WX_PendingGamble", ::Wuxia.Gambling.State.game != null ? ::Wuxia.Gambling.State.game.kind : "");
			res.rawset("WX_TournamentGazette", ::Wuxia.Tournament.publicityGazette());
		}
		return res;
	};

	q.onWXCasinoAction <- function( _data )
	{
		if (this.m.Tavern == null)
			return { ok = false, closed = true, message = "你已离开迎客酒肆，入席再博罢。" };
		local res = ::Wuxia.Gambling.handleCasinoAction(_data, this.m.Tavern.getSettlement());
		if (res != null && typeof res == "table" && !("closed" in res && res.closed) && this.m.Parent != null)
			res.rawset("Assets", this.m.Parent.queryAssetsInformation());
		return res;
	};

	q.onWXTournamentAction <- function( _data )
	{
		return ::Wuxia.Tournament.handleTournamentAction(this.m.Parent, _data);
	};

	q.onWXGamblingSound <- function( _key )
	{
		return ::Wuxia.Gambling.playSound(_key);
	};
});

::Wuxia.HooksMod.hook("scripts/entity/world/settlements/buildings/tavern_building", function( q )
{
	if (::Wuxia.qHas(q, "getRumor"))
	{
		q.getRumor = @(__original) function( _paid = false )
		{
			local res = __original(_paid);
			if (!_paid || res == null || this.m.RumorsGiven > 3 || (this.m.RumorsGiven % 2 == 0) || !::Wuxia.Gambling.ensure())
				return res;
			local gazette = ::Wuxia.Tournament.publicityGazette();
			if (gazette.len() == 0) return res;
			local pick = gazette[(::Wuxia.Gambling.day() + this.m.RumorsGiven) % gazette.len()];
			local story = "酒保擦拭着青花酒坛，凑近低声笑道：「客官可曾听闻近日演武盛事？」\n\n" + pick.text;
			this.m.LastRumor = story;
			return story;
		};
	}
});

// 4. Off-Map Dossier Guards (`stats_collector`, `serpent_racial`, `spider_racial`)
::Wuxia.HooksMod.hook("scripts/skills/special/stats_collector", function( q )
{
	if (::Wuxia.qHas(q, "onUpdate"))
	{
		q.onUpdate = @(__original) function( _properties )
		{
			if (!("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive() || (("State" in ::Tactical) && ::Tactical.State == ::Wuxia.Tournament.MemberWorldContext))
				return;
			return __original(_properties);
		};
	}
	if (::Wuxia.qHas(q, "onActorKilled"))
	{
		q.onActorKilled = @(__original) function( _actor, _tile, _skill )
		{
			if (_actor != null && ("Appearance" in ::Wuxia) && ("ensurePostDeathPortraitSprite" in ::Wuxia.Appearance))
				::Wuxia.Appearance.ensurePostDeathPortraitSprite(_actor);
			return __original(_actor, _tile, _skill);
		};
	}
});

::Wuxia.HooksMod.hook("scripts/skills/racial/serpent_racial", function( q )
{
	if (::Wuxia.qHas(q, "onUpdate"))
	{
		q.onUpdate = @(__original) function( _properties )
		{
			local c = this.getContainer();
			local actor = (c != null && ::Wuxia.hasMember(c, "getActor")) ? c.getActor() : null;
			local offMap = !("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()
				|| (("State" in ::Tactical) && ::Tactical.State == ::Wuxia.Tournament.MemberWorldContext)
				|| !::Wuxia.isOnMap(actor);
			if (offMap)
			{
				_properties.DamageReceivedFireMult *= 0.66;
				return;
			}
			return __original(_properties);
		};
	}
});

::Wuxia.HooksMod.hook("scripts/skills/racial/spider_racial", function( q )
{
	if (::Wuxia.qHas(q, "onUpdate"))
	{
		q.onUpdate = @(__original) function( _properties )
		{
			local c = this.getContainer();
			local actor = (c != null && ::Wuxia.hasMember(c, "getActor")) ? c.getActor() : null;
			local offMap = !("Tactical" in getroottable()) || ::Tactical == null || !::Tactical.isActive()
				|| (("State" in ::Tactical) && ::Tactical.State == ::Wuxia.Tournament.MemberWorldContext)
				|| !::Wuxia.isOnMap(actor);
			if (offMap)
			{
				if (actor != null)
				{
					local sz = actor.getFlags().getAsInt("WX_ArenaPackSize");
					if (sz > 1) _properties.Bravery += (sz - 1) * 3;
				}
				return;
			}
			return __original(_properties);
		};
	}
});

// 5. Non-Lethal Tournament Knockout & Appearance Restoration (`actor`, `human`, `asset_manager`, `tactical_entity_manager`)
::Wuxia.HooksMod.hook("scripts/entity/tactical/actor", function( q )
{
	if (::Wuxia.qHas(q, "onDeserialize"))
	{
		q.onDeserialize = @(__original) function( _in )
		{
			local res = __original(_in);
			::Wuxia.Tournament.restoreEmptyLayers(this);
			return res;
		};
	}
	if (::Wuxia.qHas(q, "kill"))
	{
		q.kill = @(__original) function( _killer = null, _skill = null, _fatality = 0, _silent = false )
		{
			if (::Wuxia.Tournament.arenaActive())
				return ::Wuxia.Tournament.arenaKnockout(this, _killer, _skill);
			return __original(_killer, _skill, _fatality, _silent);
		};
	}
	if (::Wuxia.qHas(q, "retreat"))
	{
		q.retreat = @(__original) function()
		{
			if (::Wuxia.Tournament.arenaActive())
				return ::Wuxia.Tournament.arenaKnockout(this, null, null);
			return __original();
		};
	}
});

::Wuxia.HooksMod.hook("scripts/entity/tactical/human", function( q )
{
	if (::Wuxia.qHas(q, "onDeserialize"))
	{
		q.onDeserialize = @(__original) function( _in )
		{
			local res = __original(_in);
			::Wuxia.Tournament.restoreEmptyLayers(this);
			return res;
		};
	}
});

::Wuxia.HooksMod.hook("scripts/states/world/asset_manager", function( q )
{
	if (::Wuxia.qHas(q, "updateFormation"))
	{
		q.updateFormation = @(__original) function( _consider = false )
		{
			if (::Wuxia.Tournament.arenaContext() != null) return;
			return __original(_consider);
		};
	}
	if (::Wuxia.qHas(q, "saveEquipment"))
	{
		q.saveEquipment = @(__original) function()
		{
			if (::Wuxia.Tournament.arenaContext() != null) return;
			return __original();
		};
	}
});

::Wuxia.HooksMod.hook("scripts/entity/tactical/tactical_entity_manager", function( q )
{
	if (::Wuxia.qHas(q, "setupEntity"))
	{
		q.setupEntity = @(__original) function( _actor, _troop )
		{
			local res = __original(_actor, _troop);
			::Wuxia.Tournament.applyOpponentOnSetup(_actor, _troop);
			return res;
		};
	}
});

// 6. Tactical State & Watch Bar Hooks (`tactical_state`, `tactical_screen`)
::Wuxia.HooksMod.hook("scripts/states/tactical_state", function( q )
{
	if (::Wuxia.qHas(q, "handleInvoluntaryMovement"))
	{
		q.handleInvoluntaryMovement = @(__original) function( _victim, _pusher, _origin, _dest, _skill, _dmgCb, _moveCb )
		{
			local ctx = ::Wuxia.Tournament.arenaContext();
			local cb = _moveCb;
			if (ctx != null && !ctx.ended && _pusher != null && _pusher.getFlags().has("WX_ArenaCopy")
				&& _skill != null && _skill.getID() == "actives.hook" && cb != null
				&& cb == _skill.onHookingComplete && cb.getinfos().parameters.len() == 3)
			{
				local completeFn = cb;
				cb = function( _tag ) { return completeFn.bindenv(this)(null, { Attacker = _tag.Actor }); };
			}
			return __original(_victim, _pusher, _origin, _dest, _skill, _dmgCb, cb);
		};
	}
	if (::Wuxia.qHas(q, "initMap"))
	{
		q.initMap = @(__original) function()
		{
			local res = __original();
			local ctx = ::Wuxia.Tournament.arenaContext();
			if (ctx != null && !ctx.ended) ::Wuxia.Tournament.trackCombat();
			return res;
		};
	}
	if (::Wuxia.qHas(q, "onUpdate"))
	{
		q.onUpdate = @(__original) function()
		{
			local res = __original();
			if (::Wuxia.Tournament.arenaContext() != null)
				::Wuxia.Tournament.watchTick(this);
			return res;
		};
	}
	if (::Wuxia.qHas(q, "setPause"))
	{
		q.setPause = @(__original) function( _val )
		{
			local res = __original(_val);
			local ctx = ::Wuxia.Tournament.arenaContext();
			if (!_val && ctx != null && !ctx.ended && !ctx.playerControlled)
				::Time.setVirtualSpeed(::Wuxia.Tournament.watchSpeed(ctx.watchMode));
			return res;
		};
	}
	if (::Wuxia.qHas(q, "onHide"))
	{
		q.onHide = @(__original) function()
		{
			if (::Wuxia.Tournament.arenaContext() != null)
				::Wuxia.Tournament.closeWatchUI();
			return __original();
		};
	}
	if (::Wuxia.qHas(q, "onBattleEnded"))
	{
		q.onBattleEnded = @(__original) function()
		{
			if (::Wuxia.Tournament.arenaContext() != null)
				return ::Wuxia.Tournament.endCombat(this);
			return __original();
		};
	}
});

::Wuxia.HooksMod.hook("scripts/ui/screens/tactical/tactical_screen", function( q )
{
	q.onWXTournamentWatch <- function( _mode )
	{
		return ::Wuxia.Tournament.watchRequest(_mode);
	};
});

// 7. World State Persistence & Seamless Tournament Return (`world_state`)
::Wuxia.HooksMod.hook("scripts/states/world_state", function( q )
{
	if (::Wuxia.qHas(q, "loadCampaign"))
	{
		q.loadCampaign = @(__original) function( _filename )
		{
			local owner = this;
			return ::Wuxia.Tournament.withMemberContext(function() { return __original.call(owner, _filename); });
		};
	}
	if (::Wuxia.qHas(q, "saveCampaign"))
	{
		q.saveCampaign = @(__original) function( _filename, _label = null )
		{
			if (::Wuxia.Gambling.State != null) ::Wuxia.Gambling.save();
			return __original(_filename, _label);
		};
	}
	if (::Wuxia.qHas(q, "onSerialize"))
	{
		q.onSerialize = @(__original) function( _out )
		{
			if (::Wuxia.Gambling.State != null) ::Wuxia.Gambling.save();
			return __original(_out);
		};
	}
	if (::Wuxia.qHas(q, "onDeserialize"))
	{
		q.onDeserialize = @(__original) function( _in )
		{
			::Wuxia.Gambling.State = null;
			::Wuxia.Gambling.Runtime.loadedFlags = null;
			::Wuxia.Gambling.Runtime.arenaCombat = null;
			::Wuxia.Gambling.Runtime.arenaReopen = 0;
			if (this.m.WorldTownScreen != null && this.m.WorldTownScreen.getMainDialogModule() != null
				&& this.m.WorldTownScreen.getMainDialogModule().m.JSHandle != null)
			{
				this.m.WorldTownScreen.getMainDialogModule().m.JSHandle.asyncCall("wxTournamentClose", null);
			}
			local res = __original(_in);
			try { ::World.deleteRoster(16999999); } catch (_e) {}
			::Wuxia.Gambling.ensure();
			return res;
		};
	}
	if (::Wuxia.qHas(q, "startNewCampaign"))
	{
		q.startNewCampaign = @(__original) function( ... )
		{
			::Wuxia.Gambling.State = null;
			::Wuxia.Gambling.Runtime.loadedFlags = null;
			::Wuxia.Gambling.Runtime.arenaCombat = null;
			::Wuxia.Gambling.Runtime.arenaReopen = 0;
			local callArgs = [this];
			for (local a = 0; a < vargv.len(); a = ++a)
				callArgs.push(vargv[a]);
			return __original.acall(callArgs);
		};
	}
	if (::Wuxia.qHas(q, "onHide"))
	{
		q.onHide = @(__original) function()
		{
			if (::Wuxia.Tournament.arenaContext() == null)
				return __original();
			// Keep town stack intact during non-lethal tournament match so supplies/ammo aren't drained
			this.m.WorldMenuScreen.hide();
			this.m.WorldScreen.hide();
			this.m.WorldTownScreen.hide();
			::World.setVisible(false);
		};
	}
	if (::Wuxia.qHas(q, "isUsingGuests"))
	{
		q.isUsingGuests = @(__original) function()
		{
			return ::Wuxia.Tournament.arenaContext() == null && __original();
		};
	}
	q.onFinish = @(__original) function()
	{
		if (::Wuxia.Tournament.arenaContext() != null)
		{
			// onHide keeps the town open for the return leg. When quitting instead,
			// run its normal leave callback while the world services still exist.
			this.m.MenuStack.popAll(true);
			::Wuxia.Gambling.Runtime.arenaCombat = null;
		}
		return __original();
	};
	if (::Wuxia.qHas(q, "onCombatFinished"))
	{
		q.onCombatFinished = @(__original) function()
		{
			if (::Wuxia.Tournament.arenaContext() != null)
				return ::Wuxia.Tournament.returnToTown(this);
			return __original();
		};
	}
	if (::Wuxia.qHas(q, "onUpdate"))
	{
		q.onUpdate = @(__original) function()
		{
			local res = __original();
			if (::Wuxia.Gambling.Runtime.arenaReopen > 0 && !(("Tactical" in getroottable()) && ("isActive" in ::Tactical) && ::Tactical.isActive()) && !this.isInLoadingScreen())
			{
				local evId = ::Wuxia.Gambling.Runtime.arenaReopen;
				local matchId = ::Wuxia.Gambling.Runtime.arenaReopenMatch;
				::Wuxia.Gambling.Runtime.arenaReopen = 0;
				::Wuxia.Gambling.Runtime.arenaReopenMatch = 0;

				local town = ::Wuxia.Tournament.currentVenue();
				if (town != null && this.m.WorldTownScreen != null)
				{
					this.m.WorldScreen.hide();
					this.m.WorldTownScreen.show();
					this.setAutoPause(true);
					::Music.setTrackList(town.getMusic(), ::Const.Music.CrossFadeTime);
					::Sound.setAmbience(0, this.getSurroundingAmbienceSounds(), ::Const.Sound.Volume.Ambience * ::Const.Sound.Volume.AmbienceTerrainInSettlement,
						::World.getTime().IsDaytime ? ::Const.Sound.AmbienceMinDelay : ::Const.Sound.AmbienceMinDelayAtNight);
					::Sound.setAmbience(1, town.getSounds(), ::Const.Sound.Volume.Ambience * ::Const.Sound.Volume.AmbienceInSettlement, ::Const.Sound.AmbienceOutsideDelay);
					if (this.m.WorldTownScreen.getMainDialogModule() != null && this.m.WorldTownScreen.getMainDialogModule().m.JSHandle != null)
						this.m.WorldTownScreen.getMainDialogModule().m.JSHandle.asyncCall("wxTournamentOpen", { event = evId, match = matchId });
				}
			}
			return res;
		};
	}
});
