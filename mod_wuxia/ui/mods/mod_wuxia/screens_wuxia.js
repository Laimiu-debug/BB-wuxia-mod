/* ============================================================================
 * BB Wuxia Mod - Main Menu, Loading Scrolls, Epilogue & Campfire UI Hooks
 * Strictly ES3-compatible (no let/const/=>/template literals/class).
 * ============================================================================ */
(function () {
	'use strict';

	var wxMenuBgs = [
		'ui/screens/wx_menu_bg_01.jpg',
		'ui/screens/wx_menu_bg_02.jpg',
		'ui/screens/wx_menu_bg_03.jpg',
		'ui/screens/wx_menu_bg_04.jpg'
	];

	var wxLoadingBgs = [
		'ui/screens/wx_loading_01.jpg',
		'ui/screens/wx_loading_02.jpg',
		'ui/screens/wx_loading_03.jpg',
		'ui/screens/wx_loading_04.jpg',
		'ui/screens/wx_loading_05.jpg',
		'ui/screens/wx_loading_06.jpg',
		'ui/screens/wx_loading_07.jpg',
		'ui/screens/wx_loading_08.jpg',
		'ui/screens/wx_menu_bg_01.jpg',
		'ui/screens/wx_menu_bg_02.jpg',
		'ui/screens/wx_menu_bg_03.jpg',
		'ui/screens/wx_menu_bg_04.jpg'
	];

	var wxEpilogueMap = {
		'ui/screens/game_lost.jpg': 'ui/screens/wx_game_lost.jpg',
		'ui/screens/retirement_01.jpg': 'ui/screens/wx_retirement_01.jpg',
		'ui/screens/retirement_02.jpg': 'ui/screens/wx_retirement_02.jpg',
		'ui/screens/retirement_03.jpg': 'ui/screens/wx_retirement_03.jpg',
		'ui/screens/retirement_04.jpg': 'ui/screens/wx_retirement_04.jpg'
	};

	function wxMapCampfirePath(path) {
		if (!path || typeof path !== 'string') return path;
		if (path.indexOf('ui/campfire/wx_') === 0) return path;
		if (path.indexOf('ui/campfire/shield_') === 0) return path;
		if (path.indexOf('ui/campfire/') === 0) {
			return 'ui/campfire/wx_' + path.substring('ui/campfire/'.length);
		}
		return path;
	}

	// 1. Tavern Rumor & Drink Event Illustrations
	if (typeof Asset !== 'undefined') {
		Asset.IMAGE_TAVERN_RUMORS = 'ui/events/wx_ev_01.png';
		Asset.IMAGE_TAVERN_DRINK = 'ui/events/wx_ev_02.png';
	}

	// 2. Main Menu Rotating Wuxia Scrolls & Promo/DLC Link Removal
	function wxPurgeMainMenuPromos($root) {
		var $scope = ($root && $root.length) ? $root : $('.main-menu-screen');
		if (!$scope.length) return;
		$scope.find('.dlc-container, .marketing-container, .motd-container').off('click').empty().hide();
	}

	if (typeof MainMenuScreen !== 'undefined') {
		if (MainMenuScreen.prototype.show) {
			var origMenuShow = MainMenuScreen.prototype.show;
			MainMenuScreen.prototype.show = function (_animate) {
				origMenuShow.call(this, _animate);
				if (this.mBackgroundImage) {
					var pick = wxMenuBgs[Math.floor(Math.random() * wxMenuBgs.length)];
					this.mBackgroundImage.attr('src', Path.GFX + pick);
				}
				wxPurgeMainMenuPromos(this.mContainer);
			};
		}
		MainMenuScreen.prototype.addCrossMarketing = function () {
			wxPurgeMainMenuPromos(this.mContainer);
		};
		MainMenuScreen.prototype.setDLC = function () {
			wxPurgeMainMenuPromos(this.mContainer);
		};
		MainMenuScreen.prototype.setMOTD = function () {
			wxPurgeMainMenuPromos(this.mContainer);
		};
	}

	// 3. Main Menu Wuxia Title Crest
	if (typeof MainMenuModule !== 'undefined' && MainMenuModule.prototype.createDIV) {
		var origMenuCreateDIV = MainMenuModule.prototype.createDIV;
		MainMenuModule.prototype.createDIV = function (_parentDiv) {
			origMenuCreateDIV.call(this, _parentDiv);
			if (this.mContainer) {
				this.mContainer.find('.header img').attr('src', Path.GFX + 'ui/wx_skin/wx_main_menu_logo.png');
			}
		};
	}

	// 4. Loading Screen Wuxia Scrolls Fallback / Remap
	if (typeof LoadingScreen !== 'undefined' && LoadingScreen.prototype.show) {
		var origLoadingShow = LoadingScreen.prototype.show;
		LoadingScreen.prototype.show = function (_data) {
			if (_data && typeof LoadingScreenIdentifier !== 'undefined') {
				var key = LoadingScreenIdentifier.Data.ImagePath;
				if (key in _data && typeof _data[key] === 'string' && _data[key].indexOf('ui/screens/wx_') !== 0) {
					_data = $.extend({}, _data);
					_data[key] = wxLoadingBgs[Math.floor(Math.random() * wxLoadingBgs.length)];
				}
			}
			origLoadingShow.call(this, _data);
		};
	}

	// 5. Campaign Epilogue (Retirement & Game Lost) Scrolls
	if (typeof WorldGameFinishScreen !== 'undefined' && WorldGameFinishScreen.prototype.loadFromData) {
		var origFinishLoad = WorldGameFinishScreen.prototype.loadFromData;
		WorldGameFinishScreen.prototype.loadFromData = function (_data) {
			if (_data && _data.Image && (_data.Image in wxEpilogueMap)) {
				_data = $.extend({}, _data);
				_data.Image = wxEpilogueMap[_data.Image];
			}
			origFinishLoad.call(this, _data);
		};
	}

	// 6. Campfire & Retinue Main Screen Layers (Day/Night Backdrop, Tents, Fire, Escort Carts & Followers)
	if (typeof WorldCampfireScreenMainDialogModule !== 'undefined' && WorldCampfireScreenMainDialogModule.prototype.loadFromData) {
		var origCampLoad = WorldCampfireScreenMainDialogModule.prototype.loadFromData;
		WorldCampfireScreenMainDialogModule.prototype.loadFromData = function (_data) {
			if (_data) {
				var d = $.extend({}, _data);
				var isNight = (typeof d.Background === 'string' && d.Background.indexOf('night') !== -1);
				d.Background = isNight ? 'ui/campfire/wx_camp_bg_night.jpg' : 'ui/campfire/wx_camp_bg_day.jpg';
				if (typeof d.BackgroundLeft === 'string' && d.BackgroundLeft.indexOf('bg_houses_') !== -1) {
					d.BackgroundLeft = null;
				}
				if (typeof d.BackgroundRight === 'string' && d.BackgroundRight.indexOf('bg_houses_') !== -1) {
					d.BackgroundRight = null;
				}
				d.BackgroundCenter = 'ui/campfire/wx_campfire_tents_01.png';
				if (d.Fire) {
					d.Fire = 'ui/campfire/wx_fire_01.png';
				}
				if (d.Cart) {
					d.Cart = wxMapCampfirePath(d.Cart);
				}
				if (d.Slots && d.Slots.length) {
					var mappedSlots = [];
					for (var i = 0; i < d.Slots.length; i++) {
						var s = d.Slots[i];
						if (s && s.Image) {
							s = $.extend({}, s);
							s.Image = wxMapCampfirePath(s.Image);
						}
						mappedSlots.push(s);
					}
					d.Slots = mappedSlots;
				}
				_data = d;
			}
			origCampLoad.call(this, _data);
		};
	}

	// 7. Campfire Retinue Hire Dialog Portraits
	if (typeof WorldCampfireScreenHireDialogModule !== 'undefined' && WorldCampfireScreenHireDialogModule.prototype.addListEntry) {
		var origHireAdd = WorldCampfireScreenHireDialogModule.prototype.addListEntry;
		WorldCampfireScreenHireDialogModule.prototype.addListEntry = function (_data) {
			if (_data && _data.ImagePath) {
				_data.ImagePath = wxMapCampfirePath(_data.ImagePath);
			}
			origHireAdd.call(this, _data);
		};
	}

	// 8. Immediate Cold-Boot Application (MainMenuScreen mounts before registerLateJS runs)
	var bootPrefix = (typeof Path !== 'undefined' && Path.GFX) ? Path.GFX : 'coui://gfx/';
	var bootBg = $('.main-menu-screen > img:first');
	if (bootBg.length) {
		var bootPick = wxMenuBgs[Math.floor(Math.random() * wxMenuBgs.length)];
		bootBg.attr('src', bootPrefix + bootPick);
	}
	var bootLogo = $('.main-menu-module .header img');
	if (bootLogo.length) {
		bootLogo.attr('src', bootPrefix + 'ui/wx_skin/wx_main_menu_logo.png');
	}
	wxPurgeMainMenuPromos($('.main-menu-screen'));
})();
