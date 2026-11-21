/* ============================================================================
 * BB Wuxia Mod - Tactical Combat HUD Synchronization (v2 Vanilla-Isomorphic)
 * Dynamic AP Cells (9/10/11 + Gold Burst), Positive Qi Conversion on Vanilla
 * Fatigue Bar, and Clean AP Cost Micro-Label on Tactical Skill Slots.
 * Strictly ES3-compatible (no let/const/=>/template literals/class).
 * ============================================================================ */
(function () {
	'use strict';

	if (typeof TacticalScreenTurnSequenceBarModule === 'undefined') return;

	// 1. Dynamic AP Bar Marks & Positive Internal Qi Conversion
	var origUpdateStats = TacticalScreenTurnSequenceBarModule.prototype.updateStatsPanel;
	TacticalScreenTurnSequenceBarModule.prototype.updateStatsPanel = function (data) {
		if (!data || data.isEnemy) return origUpdateStats.call(this, data);
		var display = $.extend({}, data);
		var keys = ProgressbarValueIdentifier;
		var previewAP = keys.ActionPointsPreview in data && keys.ActionPointsMaxPreview in data;
		if (keys.ActionPoints in data && keys.ActionPointsMax in data) {
			this.mWXPermanentAP = 'wxPermanentAP' in data ? data.wxPermanentAP : data[keys.ActionPointsMax];
			this.mWXCurrentAP = data[keys.ActionPoints];
		}

		var current = previewAP ? data[keys.ActionPointsPreview] : this.mWXCurrentAP;
		var permanent = this.mWXPermanentAP;
		var cells = Math.max(permanent, this.mWXCurrentAP, current);
		var hasAP = (keys.ActionPoints in data || previewAP) && cells > 0;
		if (hasAP) {
			if (keys.ActionPointsMax in data) display[keys.ActionPointsMax] = cells;
			if (previewAP) display[keys.ActionPointsMaxPreview] = cells;
			display[keys.ActionPointsLabel] = current + ' / ' + permanent;
		}

		if (keys.Fatigue in data && keys.FatigueMax in data) {
			display[keys.Fatigue] = Math.max(0, data[keys.FatigueMax] - data[keys.Fatigue]);
			display[keys.FatigueLabel] = '内息 ' + display[keys.Fatigue] + ' / ' + data[keys.FatigueMax];
		}
		if (keys.FatiguePreview in data && keys.FatigueMaxPreview in data) {
			display[keys.FatiguePreview] = Math.max(0, data[keys.FatigueMaxPreview] - data[keys.FatiguePreview]);
			display[keys.FatigueLabel] = '内息 ' + display[keys.FatiguePreview] + ' / ' + data[keys.FatigueMaxPreview];
		}
		origUpdateStats.call(this, display);
		if (!hasAP || !this.mLeftStatsRows || !this.mLeftStatsRows.ActionPoints) return;

		var parent = this.mLeftStatsRows.ActionPoints.Progressbar.parent();
		var marks = parent.children('.wx-ap-marks');
		if (!marks.length) marks = $('<div class="wx-ap-marks"></div>').appendTo(parent);
		if (marks.children().length !== cells) {
			marks.empty();
			for (var i = 0; i < cells; i++) {
				$('<span></span>').css({ left: (i * 100 / cells) + '%', width: (100 / cells) + '%' }).appendTo(marks);
			}
		}
		marks.children().each(function (index) {
			$(this).toggleClass('wx-ap-burst', index >= permanent && index < current);
		});
	};

	// 2. Clean AP Micro-Label on Tactical Skill Slots (Qi cost & lineage shown in tooltip)
	if (TacticalScreenTurnSequenceBarModule.prototype.addSkillToList) {
		var origAddSkill = TacticalScreenTurnSequenceBarModule.prototype.addSkillToList;
		TacticalScreenTurnSequenceBarModule.prototype.addSkillToList = function (_entity, _skill, _label) {
			origAddSkill.call(this, _entity, _skill, _label);
			if (!this.mSkillsContainer || !_skill) return;

			var skillLayout = this.mSkillsContainer.children('.l-skill:last');
			if (!skillLayout.length) return;

			if (typeof _skill.wxAp === 'number' && _skill.wxAp > 0) {
				var skillBox = skillLayout.children('.skill:first');
				if (skillBox.length && !skillBox.children('.wx-tac-skill-cost').length) {
					skillBox.append('<div class="wx-tac-skill-cost">' + String(_skill.wxAp) + '</div>');
				}
			}
		};
	}
})();
