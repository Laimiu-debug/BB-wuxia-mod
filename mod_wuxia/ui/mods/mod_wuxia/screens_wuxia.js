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

	// 6. Campfire & Retinue Main Screen Layers (Day/Night Backdrop, Tents, Fire, Escort Carts, Titles & Followers)
	function wxApplyCampfireMainLabels(_mod) {
		if (!_mod) return;
		if (_mod.mDialogContainer) {
			_mod.mDialogContainer.find('.header:first .title:first').text('行营篝火 · 江湖幕僚');
			_mod.mDialogContainer.find('.header:first .sub-title:first').text('延请十八路江湖奇人随军襄助 · 扩建义社重装镖车');
		}
	}

	if (typeof WorldCampfireScreenMainDialogModule !== 'undefined') {
		if (WorldCampfireScreenMainDialogModule.prototype.createDIV) {
			var origCampCreateDIV = WorldCampfireScreenMainDialogModule.prototype.createDIV;
			WorldCampfireScreenMainDialogModule.prototype.createDIV = function (_parentDiv) {
				origCampCreateDIV.call(this, _parentDiv);
				wxApplyCampfireMainLabels(this);
			};
		}
		if (WorldCampfireScreenMainDialogModule.prototype.loadFromData) {
			var origCampLoad = WorldCampfireScreenMainDialogModule.prototype.loadFromData;
			WorldCampfireScreenMainDialogModule.prototype.loadFromData = function (_data) {
				if (_data) {
					var d = $.extend({}, _data);
					d.Title = '行营篝火 · 江湖幕僚';
					d.SubTitle = '延请十八路江湖奇人随军襄助 · 扩建义社重装镖车';
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
				wxApplyCampfireMainLabels(this);
			};
		}
	}

	// 7. Campfire Retinue Hire Dialog Portraits, Titles & Buttons
	function wxApplyCampfireHireLabels(_mod) {
		if (!_mod) return;
		if (_mod.mDialogContainer) {
			_mod.mDialogContainer.find('.header:first .title:first').text('延揽江湖幕僚');
			_mod.mDialogContainer.find('.header:first .sub-title:first').text('奉银延请奇人异士入驻行营（江湖威名愈盛，幕僚席位愈多）');
		}
		if (_mod.mHireFollowerButton && _mod.mHireFollowerButton.findButtonText) {
			var btnTxt = _mod.mHireFollowerButton.findButtonText();
			if (btnTxt && btnTxt.length) {
				btnTxt.html('奉银延请');
			}
		}
	}

	if (typeof WorldCampfireScreenHireDialogModule !== 'undefined') {
		if (WorldCampfireScreenHireDialogModule.prototype.createDIV) {
			var origHireCreateDIV = WorldCampfireScreenHireDialogModule.prototype.createDIV;
			WorldCampfireScreenHireDialogModule.prototype.createDIV = function (_parentDiv) {
				origHireCreateDIV.call(this, _parentDiv);
				wxApplyCampfireHireLabels(this);
			};
		}
		if (WorldCampfireScreenHireDialogModule.prototype.loadFromData) {
			var origHireLoad = WorldCampfireScreenHireDialogModule.prototype.loadFromData;
			WorldCampfireScreenHireDialogModule.prototype.loadFromData = function (_data) {
				origHireLoad.call(this, _data);
				wxApplyCampfireHireLabels(this);
			};
		}
		if (WorldCampfireScreenHireDialogModule.prototype.addListEntry) {
			var origHireAdd = WorldCampfireScreenHireDialogModule.prototype.addListEntry;
			WorldCampfireScreenHireDialogModule.prototype.addListEntry = function (_data) {
				if (_data && _data.ImagePath) {
					_data.ImagePath = wxMapCampfirePath(_data.ImagePath);
				}
				origHireAdd.call(this, _data);
			};
		}
	}

	// 8. Save / Load Campaign Banner Normalization (prevents missing banner_63..66 IO errors from legacy saves)
	function wxNormalizeSaveBanner(banner) {
		if (!banner || typeof banner !== 'string' || banner.indexOf('banner_') !== 0) return banner;
		var n = parseInt(banner.substring(7), 10);
		if (isNaN(n) || n <= 0) return 'banner_51';
		if (n >= 51 && n <= 62) return banner;
		return 'banner_' + (51 + ((n - 1) % 12));
	}

	function wxWrapCampaignBannerList(ModuleCtor) {
		if (!ModuleCtor || !ModuleCtor.prototype || !ModuleCtor.prototype.addCampaignEntryToList) return;
		var origAddEntry = ModuleCtor.prototype.addCampaignEntryToList;
		ModuleCtor.prototype.addCampaignEntryToList = function (_data) {
			if (_data && typeof CampaignMenuModulesIdentifier !== 'undefined' && CampaignMenuModulesIdentifier.Campaign) {
				var imgKey = CampaignMenuModulesIdentifier.Campaign.Image;
				if (imgKey in _data && typeof _data[imgKey] === 'string') {
					_data = $.extend({}, _data);
					_data[imgKey] = wxNormalizeSaveBanner(_data[imgKey]);
				}
			}
			return origAddEntry.call(this, _data);
		};
	}

	if (typeof LoadCampaignMenuModule !== 'undefined') {
		wxWrapCampaignBannerList(LoadCampaignMenuModule);
	}
	if (typeof SaveCampaignMenuModule !== 'undefined') {
		wxWrapCampaignBannerList(SaveCampaignMenuModule);
	}
	if (typeof NewCampaignMenuModule !== 'undefined' && NewCampaignMenuModule.prototype.setBanners) {
		var origSetBanners = NewCampaignMenuModule.prototype.setBanners;
		NewCampaignMenuModule.prototype.setBanners = function (_data) {
			if (_data && _data.length) {
				var cleaned = [];
				var seen = {};
				for (var i = 0; i < _data.length; i++) {
					var norm = wxNormalizeSaveBanner(_data[i]);
					if (norm && !seen[norm]) {
						seen[norm] = true;
						cleaned.push(norm);
					}
				}
				if (cleaned.length > 0) _data = cleaned;
			}
			return origSetBanners.call(this, _data);
		};
	}

	// 9. Immediate Cold-Boot Application (MainMenuScreen mounts before registerLateJS runs)
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
