/* ============================================================================
 * BB Wuxia Mod - Tactical HUD Adaptations (Strict ES3)
 * Highlights AP exceeding vanilla 9 AP (up to 11 permanent + golden burst pips)
 * ============================================================================ */

(function () {
	'use strict';

	if (typeof TacticalScreenTurnSequenceBarModule === 'undefined') {
		return;
	}

	var origSetProgressbarValues = TacticalScreenTurnSequenceBarModule.prototype.setProgressbarValues;
	if (typeof origSetProgressbarValues === 'function') {
		TacticalScreenTurnSequenceBarModule.prototype.setProgressbarValues = function (_entityData) {
			origSetProgressbarValues.call(this, _entityData);

			if (!_entityData || !this.mStatsPanel) return;

			// Mark AP bar with a subtle master glow whenever actor breaks past vanilla 9 AP
			if (typeof _entityData.actionPointsMax !== 'undefined' && _entityData.actionPointsMax > 9) {
				this.mStatsPanel.addClass('wx-ap-transcended');
			} else {
				this.mStatsPanel.removeClass('wx-ap-transcended');
			}

			// Mark burst AP (current AP exceeding permanent max) with gold highlight
			if (typeof _entityData.actionPoints !== 'undefined' && typeof _entityData.actionPointsMax !== 'undefined' && _entityData.actionPoints > _entityData.actionPointsMax) {
				this.mStatsPanel.addClass('wx-ap-burst');
			} else {
				this.mStatsPanel.removeClass('wx-ap-burst');
			}
		};
	}
})();
