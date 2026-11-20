(function () {
	'use strict';

	if (typeof TacticalScreenTurnSequenceBarModule === 'undefined') return;
	var original = TacticalScreenTurnSequenceBarModule.prototype.updateStatsPanel;

	TacticalScreenTurnSequenceBarModule.prototype.updateStatsPanel = function (data) {
		if (!data || data.isEnemy) return original.call(this, data);
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
			display[keys.Fatigue] = data[keys.FatigueMax] - data[keys.Fatigue];
			display[keys.FatigueLabel] = '内息 ' + display[keys.Fatigue] + ' / ' + data[keys.FatigueMax];
		}
		if (keys.FatiguePreview in data && keys.FatigueMaxPreview in data) {
			display[keys.FatiguePreview] = data[keys.FatigueMaxPreview] - data[keys.FatiguePreview];
			display[keys.FatigueLabel] = '内息 ' + display[keys.FatiguePreview] + ' / ' + data[keys.FatigueMaxPreview];
		}
		original.call(this, display);
		if (!hasAP) return;

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
})();
