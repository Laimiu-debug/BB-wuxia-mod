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
	var skillsPerPage = 9;
	function showSkillPage(bar, page) {
		var slots = bar.mSkillsContainer.children('.l-skill');
		var pages = Math.ceil(slots.length / skillsPerPage);
		var pager = bar.mSkillsContainer.children('.wx-skill-page');
		bar.mWXSkillPage = Math.max(0, Math.min(page, pages - 1));
		slots.each(function (i) {
			$(this).toggle(Math.floor(i / skillsPerPage) === bar.mWXSkillPage);
		});
		if (pages <= 1) {
			pager.remove();
			return;
		}
		if (!pager.length) {
			pager = $('<button type="button" class="wx-skill-page" title="切换招式页"></button>').appendTo(bar.mSkillsContainer);
			pager.on('click', function () { showSkillPage(bar, (bar.mWXSkillPage + 1) % pages); });
		}
		pager.text('换页 ' + (bar.mWXSkillPage + 1) + '/' + pages);
	}

	if (TacticalScreenTurnSequenceBarModule.prototype.addSkillToList) {
		var origAddSkill = TacticalScreenTurnSequenceBarModule.prototype.addSkillToList;
		TacticalScreenTurnSequenceBarModule.prototype.addSkillToList = function (_entity, _skill, _label) {
			origAddSkill.call(this, _entity, _skill, _label);
			if (!this.mSkillsContainer || !_skill) return;

			var skillLayout = this.mSkillsContainer.children('.l-skill:last');
			if (!skillLayout.length) return;
			if (this.mWXSkillEntity !== _entity.id) {
				this.mWXSkillEntity = _entity.id;
				this.mWXSkillPage = 0;
			}
			if (_label > skillsPerPage) {
				var pos = this.mSkillsContainer.children('.l-skill').eq((_label - 1) % skillsPerPage)[0].style;
				skillLayout.css({ left: pos.left, bottom: pos.bottom });
			}

			if (typeof _skill.wxAp === 'number' && _skill.wxAp > 0) {
				var skillBox = skillLayout.children('.skill:first');
				if (skillBox.length && !skillBox.children('.wx-tac-skill-cost').length) {
					skillBox.append('<div class="wx-tac-skill-cost">' + String(_skill.wxAp) + '</div>');
				}
			}
		};
	}

	var origShowSkills = TacticalScreenTurnSequenceBarModule.prototype.showEntitySkillbar;
	TacticalScreenTurnSequenceBarModule.prototype.showEntitySkillbar = function (show) {
		if (show && this.mSkillsContainer) showSkillPage(this, this.mWXSkillPage || 0);
		return origShowSkills.call(this, show);
	};

	var origSelectSkill = TacticalScreenTurnSequenceBarModule.prototype.selectSkill;
	TacticalScreenTurnSequenceBarModule.prototype.selectSkill = function (skill) {
		var result = origSelectSkill.call(this, skill);
		if (skill && skill.select && this.mSkillsContainer) {
			var selected = this.searchSkillDIV(skill);
			if (selected) showSkillPage(this, Math.floor(selected.index / skillsPerPage));
		}
		return result;
	};
})();
