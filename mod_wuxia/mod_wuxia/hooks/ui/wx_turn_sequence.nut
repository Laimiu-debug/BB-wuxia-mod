::Wuxia.HooksMod.hook("scripts/ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar", function( q )
{
	// A lethal wait or turn end may also remove other slots (e.g. a lindwurm's tail).
	// Hold the native removal lock until the callbacks have finished, then use the surviving queue.
	local finishAction = function( _bar, _actor, _wait )
	{
		_bar.m.IsLocked = true;
		try
		{
			if (_actor.isAlive() && _actor.isPlacedOnMap())
			{
				if (_wait) _actor.wait();
				else _actor.onTurnEnd();
			}
		}
		catch (err)
		{
			_bar.m.IsLocked = false;
			throw err;
		}
		_bar.m.IsLocked = false;
		if (_bar.m.IsBattleEnded) return;

		local queue = _bar.m.CurrentEntities;
		if (queue.len() > 0 && queue[0] != _actor) return;
		local resumeLater = _wait && _actor.isAlive() && _actor.isPlacedOnMap();
		if (queue.len() <= 1)
		{
			// initNextRound ends any remaining turns. Only a living waiter still owes one.
			if (queue.len() == 1 && !resumeLater) queue.remove(0);
			_bar.m.IsInitNextRound = true;
			_bar.m.CheckEnemyRetreat = true;
			return;
		}

		queue[1].onBeforeActivation();
		_bar.m.IsLocked = true;
		if (resumeLater) _bar.m.JSHandle.call("removeEntity", _actor.getID());
		else _bar.m.JSHandle.asyncCall("removeEntity", _actor.getID());
		queue.remove(0);
		++_bar.m.TurnPosition;
		if (resumeLater) queue.push(_actor);
		else _bar.m.IsLastEntityPlayerControlled = _actor.isPlayerControlled();

		if (resumeLater || queue.len() >= _bar.m.MaxVisibleEntities)
		{
			local lastVisible = ::Math.min(queue.len(), _bar.m.MaxVisibleEntities) - 1;
			_bar.m.JSHandle.asyncCall("addEntity", _bar.convertEntityToUIData(queue[lastVisible], lastVisible == queue.len() - 1));
		}
	};

	q.initNextTurn = @(__original) function( _force = false )
	{
		if (this.m.IsBattleEnded || this.m.IsLocked || this.m.IsInitNextRound) return;
		local actor = this.getActiveEntity();
		if (actor == null || this.isLastEntityActive()) return __original(_force);
		if (!_force && (this.Time.hasEventScheduled(this.TimeUnit.Virtual) || this.Tactical.State.isPaused())) return;
		if (this.m.OnNextTurnListener != null && !this.m.OnNextTurnListener()) return;
		finishAction(this, actor, false);
	};

	q.initNextTurnBecauseOfWait = @(__original) function()
	{
		if (this.m.IsBattleEnded || this.m.IsLocked || this.m.IsInitNextRound) return;
		local actor = this.getActiveEntity();
		if (actor == null || this.isLastEntityActive()) return __original();
		if (this.Time.hasEventScheduled(this.TimeUnit.Virtual) || this.Tactical.State.isPaused()) return;
		if (this.m.OnNextTurnListener != null && !this.m.OnNextTurnListener()) return;
		finishAction(this, actor, true);
	};
});
