/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  Style,
  BaseStyle,
  TextStyle,
  ImageStyle,
  ContainerStyle,
  DividerStyle,
  TextInputStyle,
  GroupStyle,
  SubHeaderStyle,
  PageStyle,
  ButtonStyle,
  LoadingProgressStyle,
  PageHeaderStyle,
  SelectStyle,
  SymbolGlyphStyle,
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  BaseHeaderPageData,
  BaseSubHeaderSectionData,
  BaseDialogPageData,
  BaseSwitchMenuData,
  BaseEntryMenuData,
  BaseNavigatorEntryMenuData,
  BaseNavigationEntryMenuData,
  BaseStateMenuData,
  BaseImageMenuData,
  BaseSliderMenuData,
  BaseButtonMenuData,
  BaseTextInputMenuData,
  BaseLoadingSubHeaderSectionData,
  WindowBaseButtonMenu,
  BaseCanvasMenu,
  BaseCanvasMenuData,
  CanvasMenuStyle,
  BaseBrowserRadioMenu,
  SwiperMenu,
  WallpaperPreviewMenu,
  ThemeEditorMenu,
  BaseSecondMenu,
  MultiCheckboxMenuData,
  CheckboxMenuStyle,
  SelectImageMenuStyle,
  BaseIconRadioMenu,
  BaseEmailRadioMenu,
  BaseCheckboxOptionMenu,
  BaseCheckboxOptionMenuData,
  BaseCheckboxOptionStyle,
  SwitchMenuStyle,
  BaseSwitchMenu,
  EntryMenuStyle,
  BaseEntryMenu,
  BaseCheckboxMenu,
  BaseCheckboxMenuData,
  BaseNavigatorEntryMenu,
  BaseNavigationEntryMenu,
  BaseStateMenu,
  ImageMenuStyle,
  BaseImageMenu,
  BaseRingtoneImage,
  SliderMenuStyle,
  BaseSliderMenu,
  ButtonMenuStyle,
  BaseButtonMenu,
  BaseLoadingMenu,
  BaseLoadingMenuData,
  TextInputMenuStyle,
  BaseTextInputMenu,
  LoadingMenuStyle,
  PasswordCircleBaseMenu,
  PasswordCircleBaseMenuData,
  UnderLineTextInputBaseMenu,
  UnderLineTextInputBaseMenuData,
  BaseLoadingSubHeaderSection,
  HeaderPageStyle,
  BaseHeaderPage,
  SelectEntryMenuStyle,
  BaseSelectEntryMenu,
  BaseSelectEntryMenuData,
  BaseButtonWithVariableTitleMenu,
  BaseButtonWithVariableTitleMenuData,
  BaseCardRadioMenu,
  BaseCardRadioMenuData,
  BaseRadioMenuData,
  BaseRadioMenu,
  CardRadioMenuStyle,
  BaseSubHeaderSection,
  BaseDialogPage,
  BaseSubHeaderMenu,
  BaseSubHeaderMenuData,
  BasePairEntryMenuData,
  BasePairEntryMenu
} from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { CanvasStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  SettingsBaseMenuData,
  MenuGroupData,
  MenuSectionData,
  SettingsBaseMenu,
  MenuGroup,
  MenuSection
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import display from '@ohos.display';
import { MenuPageType, MenuType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  LoadingMenuController,
  MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

/* instrument ignore file */
export const DEFAULT_PADDING_START: Length = $r('sys.float.ohos_id_default_padding_start');

export const DEFAULT_PADDING_END: Length = $r('sys.float.ohos_id_default_padding_end');

export const MAX_PADDING_START: Length = $r('sys.float.ohos_id_max_padding_start');

export const MAX_PADDING_END: Length = $r('sys.float.ohos_id_max_padding_end');

export const TEXT_MARGIN_HORIZONTAL: Length = $r('sys.float.ohos_id_text_margin_horizontal');

export const NO_PADDING: Padding = { left: 0, top: 0, right: 0, bottom: 0 };

export const NO_MARGIN: Margin = { left: 0, top: 0, right: 0, bottom: 0 };

export const PROXY_EXCLUSION_MAX_LENGTH: number = 10240;

const MARGIN_TOP_66: number = 66;
const MARGIN_BOTTOM_8: number = 8;
const MARGIN_12: number = 12;
const MAX_LINES_10: number = 10;
const MAX_LINES_19: number = 19;
const MAX_LINES_1: number = 1;
const MAX_LINES_6: number = 6;
const START_FLEX_SHRINK_0: number = 0;
const START_FLEX_SHRINK_1: number = 1;
const END_FLEX_SHRINK_0: number = 0;
const END_FLEX_SHRINK_1: number = 1;
const END_FLEX_SHRINK_3: number = 3;
const SPACE_LENGTH_16: number = 16;
const SPACE_LENGTH_30: number = 30;
const LAYOUT_WEIGHT_1: number = 1;
const GRID_SPAN_4: number = 4;
const GRID_OFFSET_2: number = 2;
const GRID_OFFSET_0: number = 0;
const GRID_OFFSET_4: number = 4;
const GRID_OFFSET_6: number = 6;
const GRID_COLUMNS_12: number = 12;
const MAX_LENGTH_128: number = 128;
const MAX_LENGTH_64: number = 64;

const WIDTH_100_PERCENT: string = '100%';
const MAX_HEIGHT_90_PERCENT: string = '90%';
const MAX_WIDTH_60_PERCENT: string = '60%';
const MIN_WIDTH_40_PERCENT: string = '40%';
const WIDTH_50_PERCENT: string = '50%';
const DEVICE_TYPE_PHONE: string = 'phone';
const DEVICE_TYPE_PC: string = '2in1';

/**
 * wifi list item title max width
 */
const WIFI_LIST_ITEM_MAX_WIDTH: string = 'calc(100% - 64vp)';

/**
 * 菜单标题样式
 *
 * @since 2022-03-21
 */
export class TitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Medium,
  };
}

export class HomeTitleTextStyle extends TitleTextStyle {
  constructor(font?: Font, lineHeight?: number, margin?: Margin) {
    super();
    if (font) {
      this.font = font;
    }
    if (lineHeight) {
      this.lineHeight = lineHeight;
    }
    if (margin) {
      this.margin = margin;
    } else {
      this.margin = {
        left: $r('app.float.margin_8'),
      };
    }
  }
}

export class HotspotTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_tertiary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Medium,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines: number = MAX_LINES_10;
}

let homeTitleTextStyle = new HomeTitleTextStyle();

let titleTextStyle = new TitleTextStyle();

/**
 * 菜单标题样式
 *
 * @since 2022-03-21
 */
export class NavigationTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Medium,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines: number = MARGIN_TOP_66;
}

/**
 * 最近位置访问列表title样式
 */
export class LocationTitleTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body2'),
    weight: FontWeight.Regular,
  };
}

/**
 * 菜单辅助文本样式
 *
 * @since 2022-03-21
 */
export class SummaryTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');

  constructor(font?: Font, lineHeight?: number, margin?: Margin) {
    super();
    if (font) {
      this.font = font;
    } else {
      this.font = {
        size: '14fp',
        weight: FontWeight.Medium,
      };
    }
    if (lineHeight) {
      this.lineHeight = lineHeight;
    }
    if (margin) {
      this.margin = margin;
    } else {
      this.margin = {
        top: '2vp',
      };
    }
  }
}

let summaryTextStyle = new SummaryTextStyle();

export class HomeSummaryTextStyle extends SummaryTextStyle {
  public margin: Margin = {
    left: $r('app.float.margin_8'),
    top: $r('app.float.margin_2')
  }
}

let homeSummaryTextStyle = new HomeSummaryTextStyle();

/**
 * 开关外边距样式
 *
 * @since 2022-03-21
 */
export class SwitchToggleStyle extends BaseStyle {
  public margin: Margin = {
    left: TEXT_MARGIN_HORIZONTAL,
    right: $r('app.float.margin_0'),
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
  public padding: Padding = {
    left: '6vp',
    right: '6vp',
  };
  public size: SizeOptions = {
    height: '48vp',
    width: '48vp',
  };
}

export class BluetoothSwitchToggleStyle extends SwitchToggleStyle {
  public selectedColor: Resource = $r('sys.color.ohos_id_color_emphasize');
}

class ProfileSwitchToggleStyle extends SwitchToggleStyle {
  public selectedColor: Resource = $r('sys.color.ohos_id_color_emphasize');
  public padding: Padding = {
    left: '6vp',
  };
}

class WindowsSwitchToggleStyle extends SwitchToggleStyle {
  public selectedColor: Resource = $r('sys.color.ohos_id_color_emphasize');
}

export let windowsSwitchToggleStyle = new WindowsSwitchToggleStyle();

let switchToggleStyle = new SwitchToggleStyle();

let profileSwitchToggleStyle = new ProfileSwitchToggleStyle();

export class SwitchContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: '12vp',
    top: FontScaleUtils.getCurrentTopPadding(),
    bottom: FontScaleUtils.getCurrentTopPadding(),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public space: Length = 0;
}

export class ProfileSwitchContainerStyle extends SwitchContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_64'),
  };
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: GRID_OFFSET_6,
  };
}

export class VolumeSwitchContainerStyle extends SwitchContainerStyle {
  public borderRadius = '20vp';
}

export class ProfileOneLineSwitchContainerStyle extends SwitchContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_48'),
  };
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: GRID_OFFSET_6,
  };
}

let switchContainerStyle = new SwitchContainerStyle();

class SummarySwitchContainerStyle extends SwitchContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '64vp',
  };
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_START,
    top: FontScaleUtils.getCurrentTopPadding(),
    bottom: FontScaleUtils.getCurrentTopPadding(),
  };
  public summary: TextStyle = summaryTextStyle;
}

class MultilineSummarySwitchContainerStyle extends SwitchContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: '12vp',
    top: '14vp',
    bottom: '14vp'
  };
}

/**
 * 开关菜单样式
 *
 * @since 2022-03-21
 */
export class DefaultSwitchMenuStyle extends SwitchMenuStyle {
  public rootContainer: ContainerStyle = new SwitchContainerStyle();
  public title: TextStyle = titleTextStyle;
  public summary: TextStyle = summaryTextStyle;
  public toggleStyle: BaseStyle = switchToggleStyle;
}

export class DefaultProfileSwitchMenuStyle extends SwitchMenuStyle {
  public rootContainer: ContainerStyle = new SwitchContainerStyle();
  public title: TextStyle = new TitleTextStyle();
  public summary: TextStyle = new SummaryTextStyle();
  public toggleStyle: BaseStyle = new SwitchToggleStyle();
}

export class BluetoothSwitchMenuStyle extends DefaultSwitchMenuStyle {
  public toggleStyle = new BluetoothSwitchToggleStyle();
}

export class HotspotSwitchMenuStyle extends DefaultSwitchMenuStyle {
  public title: TextStyle = new HotspotTitleTextStyle();
}

export class ProfileSwitchMenuStyle extends DefaultProfileSwitchMenuStyle {
  public rootContainer: ContainerStyle = new ProfileSwitchContainerStyle();
  public toggleStyle = new BluetoothSwitchToggleStyle();
}

export class ProfileOneLineSwitchMenuStyle extends DefaultProfileSwitchMenuStyle {
  public rootContainer: ContainerStyle = new ProfileOneLineSwitchContainerStyle();
  public toggleStyle = new BluetoothSwitchToggleStyle();
}

export class SummarySwitchMenuStyle extends DefaultSwitchMenuStyle {
  public rootContainer: ContainerStyle = new SummarySwitchContainerStyle();
}

export class MultilineSummarySwitchMenuStyle extends DefaultSwitchMenuStyle {
  public rootContainer: ContainerStyle = new MultilineSummarySwitchContainerStyle();
}

export let hotspotSwitchMenuStyle = new HotspotSwitchMenuStyle();

export let defaultSwitchMenuStyle = new DefaultSwitchMenuStyle();

export let bluetoothSwitchMenuStyle = new BluetoothSwitchMenuStyle();

export let a2dpProfileSwitchMenuStyle = new ProfileSwitchMenuStyle();

export let hidProfileSwitchMenuStyle = new ProfileSwitchMenuStyle();

export let hfpProfileSwitchMenuStyle = new ProfileSwitchMenuStyle();

export let a2dpProfileOneLineSwitchMenuStyle = new ProfileOneLineSwitchMenuStyle();

export let hidProfileOneLineSwitchMenuStyle = new ProfileOneLineSwitchMenuStyle();

export let hfpProfileOneLineSwitchMenuStyle = new ProfileOneLineSwitchMenuStyle();

export interface SwitchMenuData extends BaseSwitchMenuData {}

/**
 * 开关菜单数据类
 *
 * @since 2022-03-21
 */
export class SwitchMenu extends BaseSwitchMenu implements SwitchMenuData {
  constructor(menu: Partial<SwitchMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = FontScaleUtils.getCurrentTopPadding() === navigationEntryMenuStyle.rootContainer.padding?.top ?
        defaultSwitchMenuStyle : new DefaultSwitchMenuStyle();
    }
  }
}

export interface HotSportQrCodeMenuData extends SettingsBaseMenuData {}

/**
 * 个人热点二维码菜单类
 *
 * @since 2024-04-07
 */
export class HotSportQrCodeMenu extends SettingsBaseMenu {
  constructor(menu: Partial<HotSportQrCodeMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.QRCODE;
    }
  }
}

/**
 * MpChart数据类
 *
 * @since 2024-03-09
 */
export class BatteryMpChart extends BaseEntryMenu implements BaseEntryMenuData {
  constructor(menu: Partial<BaseNavigatorEntryMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.BATTERY_MP_CHART_COMPONENT;
    }
  }
}

export class PhoneUsbDebugStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  }
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_6'),
    bottom: $r('app.float.margin_0'),
    left: $r('app.float.margin_0'),
    right: $r('app.float.margin_0'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public space: Length = '16vp';
}

/**
 * 菜单跟布局样式
 *
 * @since 2022-03-21
 */
export class RootContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%'
  }
  public padding: Padding = {
    left: $r('app.float.padding_8'),
    right: $r('app.float.padding_8'),
    top: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() : $r('app.float.margin_0'),
    bottom: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() : $r('app.float.margin_0'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
    left: $r('app.float.margin_0'),
    right: $r('app.float.margin_0'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp'
  };
  public space: Length = '0';
}



export class RootContainerConnectStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  }
  public padding: Padding = {
    left: $r('app.float.padding_8'),
    right: $r('app.float.padding_8'),
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
    left: $r('app.float.margin_0'),
    right: $r('app.float.margin_0'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '64vp',
  };
  public space: Length = '16vp';
}

/**
 * 控制中心蓝牙菜单跟布局样式
 *
 * @since 2023-12-30
 */
export class WindowsBluetoothRootContainerStyle extends RootContainerStyle {
  public padding: Padding = {
    left: $r('app.float.padding_8'),
    right: '40',
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
}


export class UsuallyMessageRootContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '346vp',
  }
  public horizontalAlign = HorizontalAlign.Start;
}

let rootContainerStyle = new RootContainerStyle();

let phoneUsbDebug = new RootContainerStyle();

/**
 * 菜单图标样式
 *
 * @since 2022-03-21
 */
export class IconImageStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '32vp',
    height: '32vp',
  };
  public margin: Margin = {
    right: '8vp',
  };
}

let iconImageStyle = new IconImageStyle();

/**
 * 新信息提示样式
 *
 * @since 2022-09-26
 */
export class NewInfoImageStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '6vp',
    height: '6vp',
  };
  public margin: Margin = {
    left: '8vp',
  };
}

let newInfoImageStyle = new NewInfoImageStyle();

export class Icon24ImageStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public margin: Margin = {
    right: '16vp',
  };
  public borderRadius = '0vp';
}

export class StateIconStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '12vp',
    height: '24vp',
  };
  public margin: Margin = {
    left: '4vp',
  };
  public fillColor: ResourceColor = $r('sys.color.ohos_id_color_fourth');
}

export class SymbolIconStyle extends SymbolGlyphStyle {
  public margin: Margin = {
    left: '4vp',
  };
}

export class StateIconWifiStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public fillColor: ResourceColor = $r('sys.color.ohos_id_color_fourth');
}

let stateIconStyle = new StateIconStyle();

let symbolIconStyle = new SymbolIconStyle();

let stateIconWifiStyle = new StateIconWifiStyle();

export class UserStateIconStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '42vp',
    height: '42vp',
  };
  public margin: Margin = {
    right: '19vp',
  };
}

export class APUserStateIconStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '20vp',
    height: '20vp',
  };
  public margin: Margin = {
    right: '15vp',
  };
}

export class StateTextStyle extends SummaryTextStyle {
  constructor(font?: Font, margin?: Margin, lineHeight?: number) {
    super();
    if (font) {
      this.font = font;
    } else {
      this.font = {
        size: $r('sys.float.ohos_id_text_size_sub_title3'),
      };
    }
    if (margin) {
      this.margin = margin;
    } else {
      this.margin = {};
    }
    if (lineHeight) {
      this.lineHeight = lineHeight;
    }
  }
}

let stateTextStyle = new StateTextStyle();

/**
 * 默认入口菜单样式
 *
 * @since 2022-03-21
 */
export class DefaultEntryMenuStyle extends EntryMenuStyle {
  public rootContainer: ContainerStyle = FontScaleUtils.getCurrentTopPadding() === rootContainerStyle.padding.top ?
    rootContainerStyle : new RootContainerStyle();
  public iconImage: ImageStyle = iconImageStyle;
  public title: TextStyle = titleTextStyle;
  public summary: TextStyle = summaryTextStyle;
  public state: TextStyle = stateTextStyle;
  public stateIcon: ImageStyle = stateIconStyle;
  public newInfoImage: ImageStyle = newInfoImageStyle;
  public startFlexShrink: number = START_FLEX_SHRINK_1;
  public endFlexShrink: number = END_FLEX_SHRINK_0;
  public isTextHotspot: boolean = false;
  public symbolIcon?: SymbolGlyphStyle = symbolIconStyle;
}

export class PhoneUsbDebugStyleEntryMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new PhoneUsbDebugStyle();
}

export let defaultEntryMenuStyle = new DefaultEntryMenuStyle();

/**
 * 默认入口菜单样式
 *
 * @since 2022-03-21
 */
export class NavigationEntryMenuStyle extends EntryMenuStyle {
  public rootContainer: ContainerStyle = FontScaleUtils.getCurrentTopPadding() === rootContainerStyle.padding.top ?
    rootContainerStyle : new RootContainerStyle();
  public iconImage: ImageStyle = iconImageStyle;
  public title: TextStyle = new NavigationTitleTextStyle();
  public summary: TextStyle = summaryTextStyle;
  public state: TextStyle = stateTextStyle;
  public stateIcon: ImageStyle = stateIconStyle;
  public newInfoImage: ImageStyle = newInfoImageStyle;
  public startFlexShrink: number = START_FLEX_SHRINK_1;
  public endFlexShrink: number = END_FLEX_SHRINK_0;
  public symbolIcon: SymbolGlyphStyle = symbolIconStyle;
}

export let navigationEntryMenuStyle = new NavigationEntryMenuStyle();

//whitch attributes are defined in Procut.
interface PCHomeMenuStyleData {
  marginStatus: Margin,
  homeSpacing: Length,
}

export class HomeEntryMenuStyle extends DefaultEntryMenuStyle implements PCHomeMenuStyleData {
  public title: TextStyle = homeTitleTextStyle;
  public summary: TextStyle = homeSummaryTextStyle;
  public marginStatus: Margin = {};
  public homeSpacing: Length = '';
}

export interface EntryMenuData extends BaseEntryMenuData {}

/**
 * 入口菜单数据类
 *
 * @since 2022-03-21
 */
export class EntryMenu extends BaseEntryMenu implements EntryMenuData {
  constructor(menu: Partial<EntryMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style =
        FontScaleUtils.getCurrentTopPadding() === rootContainerStyle.padding.top ? defaultEntryMenuStyle :
          new DefaultEntryMenuStyle();
    }
  }
}

/**
 * 半模态菜单数据类
 *
 * @since 2024-03-21
 */
export class SheetMenu extends BaseEntryMenu implements EntryMenuData {
  public sheetDescription: string | Resource = '';

  constructor(menu: Partial<EntryMenuData>) {
    super(menu);
    this.menuType = MenuType.SHEET;
    if (!menu.style) {
      this.style = defaultEntryMenuStyle;
      (this.style as DefaultEntryMenuStyle).state.constraintSize = {
        maxWidth: 'calc(100% - 80vp)'
      };
    }
  }
}

/**
 * 单选菜单数据类
 *
 * @since 2024-03-21
 */
export class SingleChooseMenu extends BaseEntryMenu implements EntryMenuData {
  constructor(menu: Partial<EntryMenuData>) {
    super(menu);
    this.menuType = MenuType.SINGLE_CHOOSE;
    if (!menu.style) {
      this.style = defaultEntryMenuStyle;
    }
  }
}

export interface NavigationEntryData extends BaseEntryMenuData {}

export class NavigationEntry extends BaseEntryMenu implements NavigationEntryData {
  constructor(menu: Partial<NavigationEntryData>) {
    super(menu);
    if (!menu.style) {
      this.style = FontScaleUtils.getCurrentTopPadding() === navigationEntryMenuStyle.rootContainer.padding?.top ?
        navigationEntryMenuStyle : new NavigationEntryMenuStyle();
    }
    if (!menu?.menuType) {
      this.menuType = MenuType.NAVIGATION_ENTRY;
    }
  }
}

export class NavigationPairEntry extends BasePairEntryMenu implements BasePairEntryMenuData {
  constructor(menu: BasePairEntryMenuData) {
    super(menu);
    this.menuType = MenuType.NAVIGATION_PAIR_ENTRY;
  }
}

export class NavigationCheckboxEntry extends BaseCheckboxMenu implements BaseCheckboxMenuData {
  constructor(menu: Partial<BaseCheckboxMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = FontScaleUtils.getCurrentTopPadding() === navigationEntryMenuStyle.rootContainer.padding?.top ?
        navigationEntryMenuStyle : new NavigationEntryMenuStyle();
    }
    if (!menu?.menuType) {
      this.menuType = MenuType.NAVIGATION_CHECKBOX_MENU;
    }
  }
}

export class NavigationInfoEntry extends BaseEntryMenu implements NavigationEntryData {
  constructor(menu: Partial<NavigationEntryData>) {
    super(menu);
    if (!menu.style) {
      this.style = FontScaleUtils.getCurrentTopPadding() === navigationEntryMenuStyle.rootContainer.padding?.top ?
        navigationEntryMenuStyle : new NavigationEntryMenuStyle();
    }
    if (!menu?.menuType) {
      this.menuType = MenuType.NAVIGATION_INFO_ENTRY;
    }
  }
}

export interface CircleMenuData extends SettingsBaseMenuData {}

export class CircleMenu extends SettingsBaseMenu implements SettingsBaseMenuData {
  constructor(menu: Partial<CircleMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.CIRCLE;
    }
  }
}

export interface DataPanelCircleMenuData extends SettingsBaseMenuData {}

export class DataPanelCircleMenu extends SettingsBaseMenu implements SettingsBaseMenuData {
  constructor(menu: Partial<DataPanelCircleMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.DATA_PANEL_CIRCLE;
    }
  }
}

export interface NavigatorEntryMenuData extends BaseNavigatorEntryMenuData {}

/**
 * 导航入口菜单数据类
 *
 * @since 2022-03-21
 */
export class NavigatorEntryMenu extends BaseNavigatorEntryMenu implements NavigatorEntryMenuData {
  constructor(menu: Partial<NavigatorEntryMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultEntryMenuStyle;
    }
  }
}

export interface NavigationEntryMenuData extends BaseNavigationEntryMenuData {}

export class NavigationEntryMenu extends BaseNavigationEntryMenu implements NavigationEntryMenuData {
  constructor(menu: Partial<NavigationEntryMenuData>) { // any类型涉及源代码适配，后续需求SR000IAJ8T中会统一整改
    super(menu);
    if (!menu?.style) {
      this.style = defaultEntryMenuStyle;
    }
  }
}

/**
 * 默认状态展示菜单样式类
 *
 * @since 2022-06-10
 */
export class DefaultStateMenuStyle extends DefaultEntryMenuStyle {
  public startFlexShrink: number = START_FLEX_SHRINK_1;
  public endFlexShrink: number = END_FLEX_SHRINK_3;
  public fullOpacity: boolean = true;
}

export class DefaultStatesMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new RootsContainerStyle();
  public startFlexShrink: number = START_FLEX_SHRINK_1;
  public endFlexShrink: number = END_FLEX_SHRINK_3;
  public fullOpacity: boolean = true;
}

export class EdmPasswordStateMenuStyle extends DefaultStateMenuStyle {
  public rootContainer: ContainerStyle = new EdmPasswordStateRootsContainerStyle();
}

export class RootsContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  }
  public padding: Padding = {
    left: $r('app.float.padding_0'),
    right: $r('app.float.padding_0'),
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
    left: $r('app.float.margin_0'),
    right: $r('app.float.margin_0'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public space: Length = '16vp';
}

export class EdmPasswordStateRootsContainerStyle extends RootsContainerStyle {
  public constraintSize: ConstraintSizeOptions = {};
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_8'),
    left: $r('app.float.margin_0'),
    right: $r('app.float.margin_0'),
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
}

let defaultStateMenuStyle = new DefaultStateMenuStyle();

export interface StateMenuData extends BaseStateMenuData {}

/**
 * 状态菜单数据类
 *
 * @since 2022-03-21
 */
export class StateMenu extends BaseStateMenu implements StateMenuData {
  constructor(menu: Partial<StateMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultStateMenuStyle;
    }
    this.updateEntry();
  }

  updateEntry(): void {
    this.timestamp = new Date().getTime();
  }
}

export class SecondMenu extends BaseSecondMenu implements StateMenuData {
  constructor(menu: Partial<StateMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultStateMenuStyle;
    }
    this.updateEntry();
  }

  updateEntry(): void {
    this.timestamp = new Date().getTime();
  }
}

/**
 * 可编辑菜单状态文本样式
 *
 * @since 2022-05-21
 */
export class EditStateIconStyle extends StateIconStyle {
  public size: SizeOptions = {
    width: $r('app.float.width_24'),
    height: $r('app.float.height_24'),
  };
  public margin: Margin = {
    left: $r('app.float.margin_0'),
  };
  public imageFit = ImageFit.Contain;
}

/**
 * 可编辑菜单输入框样式
 *
 * @since 2022-05-21
 */
export class EditTextStyle extends TextInputStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_list_card_bg');
  public inputType = InputType.Normal;
  public placeholderColor = $r('sys.color.ohos_id_color_foreground_contrary');
  public caretColor: ResourceColor = $r('app.color.color_0A59F7_blue');
  public size: SizeOptions = {
    height: $r('app.float.height_40'),
  };
  public padding: Padding = { right: $r('app.float.padding_4') };
  public maxLength: number = SPACE_LENGTH_30;
  public textAlign: TextAlign = TextAlign.End;
  public fontColor: ResourceStr = $r('sys.color.ohos_id_color_foreground');
  public fontSize: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
    weight: FontWeight.Regular,
  };
}

/**
 * 可编辑菜单跟布局样式
 *
 * @since 2022-05-21
 */
export class EditRootContainerStyle extends RootContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
  };
}


/**
 * 可编辑菜单编辑框容器样式
 *
 * @since 2022-05-21
 */
export class EditContainerStyle extends ContainerStyle {
  public borderRadius?: Length = 0;
  public borderColor?: ResourceColor = '#00FFFFFF';
  public borderWidth?: Length = 0;
  public margin: Margin = {
    top: 0,
    bottom: 0,
    right: $r('app.float.margin_12'),
  };
  public layoutWeight = 8;
  public size: SizeOptions = {};
}

export class EditSecondStatTextStyle extends StateTextStyle {
  public size: SizeOptions = {
    height: $r('app.float.height_40'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minWidth: $r('app.float.width_40'),
  };
  public textAlign: TextAlign = TextAlign.End;
}

/**
 * 可编辑菜单样式
 *
 * @since 2022-05-21
 */
export class EditMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new EditRootContainerStyle();
  public iconImage: ImageStyle = iconImageStyle;
  public title: TextStyle = titleTextStyle;
  public summary: TextStyle = summaryTextStyle;
  public stateContainer: ContainerStyle = new EditContainerStyle();
  public secondState = new EditSecondStatTextStyle();
  public stateIcon: ImageStyle = new EditStateIconStyle();
  public textInputStyle = new EditTextStyle();
}

export interface EditMenuData extends BaseEntryMenuData {}

/**
 * 可编辑菜单
 *
 * @since 2022-05-21
 */
export class EditMenu extends BaseEntryMenu implements EditMenuData {
  constructor(menu: Partial<EditMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.EDIT;
    }
    if (!menu.style) {
      this.style = new EditMenuStyle();
    }
  }
}

export class ImageMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '50%',
  };
  public clip = true;
  public borderRadius = $r('app.float.length_16');
  public backgroundColor = $r('sys.color.ohos_id_color_sub_background');
}

class ColorImageMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_134'),
  };
  public clip = true;
  public borderRadius = $r('app.float.length_16');
  public backgroundColor = $r('sys.color.ohos_id_color_foreground_contrary');
}

class UsbTipsColorImageMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_162'),
  };
  public borderRadius = $r('app.float.length_16');
}

class CanvasMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public clip = true;
  public borderRadius = $r('app.float.length_16');
  public backgroundColor = $r('sys.color.ohos_id_color_foreground_contrary');
}

class ImageMenuImageStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public imageFit = ImageFit.Cover;
}

class ColorImageMenuStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_134'),
  };
  public imageFit = ImageFit.Fill;
}

class CanvasMenuCanvasStyle extends CanvasStyle {
}

class ImageMenuStateIconStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public imageFit = ImageFit.Cover;
}

/**
 * 默认菜单样式
 *
 * @since 2022-03-21
 */
export class DefaultImageMenuStyle extends ImageMenuStyle {
  public rootContainer: ContainerStyle = new ImageMenuContainerStyle();
  public iconImage: ImageStyle = new ImageMenuImageStyle();
  public stateIcon: ImageStyle = new ImageMenuStateIconStyle();
}

export class ColorMenuStyle extends ImageMenuStyle {
  public rootContainer: ContainerStyle = new ColorImageMenuContainerStyle();
  public iconImage: ImageStyle = new ColorImageMenuStyle();
}

export class UsbTipsColorMenuStyle extends ImageMenuStyle {
  public rootContainer: ContainerStyle = new UsbTipsColorImageMenuContainerStyle();
  public iconImage: ImageStyle = new ImageMenuImageStyle();
}

export let defaultImageMenuStyle = new DefaultImageMenuStyle();

export let colorMenuStyle = new ColorMenuStyle();


export class DefaultCanvasMenuStyle extends CanvasMenuStyle {
  public rootContainer: ContainerStyle = new CanvasMenuContainerStyle();
  public canvas: CanvasStyle = new CanvasMenuCanvasStyle();
}

export let defaultCanvasMenuStyle = new DefaultCanvasMenuStyle();

export interface ImageMenuData extends BaseImageMenuData {}

export interface CanvasMenuData extends BaseCanvasMenuData {}

/**
 * 图片菜单数据类
 *
 * @since 2022-03-21
 */
export class ImageMenu extends BaseImageMenu implements ImageMenuData {
  constructor(menu: Partial<ImageMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultImageMenuStyle;
    }
  }
}

// 铃声主题卡片
export class RingtoneImage extends BaseRingtoneImage implements ImageMenuData {
  constructor(menu: Partial<ImageMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultImageMenuStyle;
    }
  }
}

// 色彩图片样式
export class ColorImageMenu extends BaseImageMenu implements ImageMenuData {
  constructor(menu: Partial<ImageMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = colorMenuStyle;
    }
  }
}

export class CanvasMenu extends BaseCanvasMenu implements CanvasMenuData {
  constructor(menu: Partial<CanvasMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultCanvasMenuStyle;
    }
  }
}

export class StartImageStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public imageFit = ImageFit.Contain;
}

let startImageStyle = new StartImageStyle();
let topImageStyle = startImageStyle;
let endImageStyle = startImageStyle;

export class RootContainerStyle56 extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '56vp',
  };

  constructor(padding?: Padding, margin?: Margin) {
    super();
    if (padding) {
      this.padding = padding;
    }
    if (margin) {
      this.margin = margin;
    }
  }
}

export class AccountContainerStyle96 extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '96vp',
  };
}

export class OtherAccountContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '64vp',
  };
}

export class RootContainerStyle72 extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '72vp',
  };

  constructor(padding?: Padding) {
    super();
    if (padding) {
      this.padding = padding;
    } else {
      this.padding = {
        left: $r('app.float.padding_8'),
        right: $r('app.float.padding_8'),
        top: $r('app.float.margin_0'),
        bottom: $r('app.float.margin_0'),
      };
    }
  }
}

export class SliderTitleTextStyle extends TitleTextStyle {
  public padding: Padding = { left: '12vp', right: '12vp', top: 0, bottom: 0 }
}

export class DefaultSliderMenuStyle extends SliderMenuStyle {
  public rootContainer?: ContainerStyle = new RootContainerStyle56();
  public topImage?: ImageStyle = topImageStyle;
  public startImage?: ImageStyle = startImageStyle;
  public endImage?: ImageStyle = endImageStyle;
  public sliderStyle: SliderStyle = SliderStyle.InSet;
  public title?: TextStyle = new SliderTitleTextStyle();
  public horizontalAlign: HorizontalAlign = HorizontalAlign.Start;
  public verticalAlign: VerticalAlign = VerticalAlign.Center;
}

export let defaultSliderMenuStyle = new DefaultSliderMenuStyle();

export class IntentSliderImageStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '22vp',
    height: '22vp',
  };
  public margin: Margin = {
    right: '8vp',
    left: '3vp',
  };
  public imageFit = ImageFit.Contain;
}

export class IntentSliderEndImageStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '28vp',
    height: '28vp',
  };
  public margin: Margin = {
    left: '8vp',
  };
  public imageFit = ImageFit.Contain;
}

class IntentTitleTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Regular,
    family: 'HarmonyHeiTi',
  };
}

class IntentStateTitleTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body3'),
    weight: FontWeight.Medium,
    family: 'HarmonyHeiTi',
  };
  public padding: Padding = { left: '8vp', right: 0, top: 0, bottom: 0 };
}

class IntentRootContainerStyle extends RootContainerStyle {
  public padding: Padding = { left: '12vp', right: '12vp', top: '4vp', bottom: 0 };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '20vp',
  };
}

class IntentRootTitleContainerStyle extends RootContainerStyle {
  public padding: Padding = { left: '12vp', right: '12vp', top: '12vp', bottom: '8vp' };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '21vp',
  };
}

class IntentSliderRootContainerStyle extends RootContainerStyle {
  public padding: Padding = {
    left: '12vp',
    right: DEFAULT_PADDING_END,
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_8'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '40vp',
  };
}

class IntentImageStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '21vp',
    height: '21vp',
  };
  public imageFit = ImageFit.Contain;
}

export class IntentSliderMenuStyle extends SliderMenuStyle {
  public rootContainer?: ContainerStyle = new IntentSliderRootContainerStyle();
  public startImage?: ImageStyle = new IntentSliderImageStyle();
  public endImage?: ImageStyle = new IntentSliderEndImageStyle();
  public sliderStyle: SliderStyle = SliderStyle.InSet;
  public horizontalAlign: HorizontalAlign = HorizontalAlign.Start;
}

export class IntentStateMenuStyle extends SliderMenuStyle {
  public iconImage?: ImageStyle = new IntentImageStyle();
  public title?: TextStyle = new IntentStateTitleTextStyle();
  public rootContainer?: ContainerStyle = new IntentRootContainerStyle();
}

export class IntentStateTitleMenuStyle extends SliderMenuStyle {
  public title?: TextStyle = new IntentTitleTextStyle();
  public rootContainer?: ContainerStyle = new IntentRootTitleContainerStyle();
}

export class StepSliderMenuStyle extends DefaultSliderMenuStyle {
  public showSteps: boolean = false;
  public selectedColor: ResourceColor = $r('sys.color.ohos_id_color_emphasize');
}

export interface SliderMenuData extends BaseSliderMenuData {}

export interface SwiperMenuData extends SettingsBaseMenuData {}

export interface WallpaperPreviewMenuData extends SettingsBaseMenuData {}

/**
 * 滑动条菜单数据类
 *
 * @since 2022-03-21
 */
export class SliderMenu extends BaseSliderMenu implements SliderMenuData {
  constructor(menu: Partial<SliderMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultSliderMenuStyle;
    }
  }
}

export class Swiper extends SwiperMenu implements SwiperMenuData {
  constructor(menu: Partial<SettingsBaseMenuData>) {
    super(menu);
  }
}

/**
 * 桌面和个性化主题壁纸、熄屏风格、字体样式、图标模块数据
 *
 * @since 2023-11-03
 */
export class WallpaperPreviewStyle extends GroupStyle {
  public size: SizeOptions = {
    width: display.isFoldable() ? '156vp' : '171vp',
    height: display.isFoldable() ? '118vp' : '130vp',
  }
  public borderRadius: Length = '16vp'
  public margin: Margin = {
    top: '12vp'
  }
}

/**
 * 桌面和个性化主题壁纸、熄屏风格、字体样式、图标模块
 *
 * @since 2023-10-30
 */

export class WallpaperPreview extends WallpaperPreviewMenu implements WallpaperPreviewMenuData {
  constructor(menu: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = new WallpaperPreviewStyle();
    }
  }
}

/**
 * 桌面和个性化合一编辑器模块数据
 *
 * @since 2024-04-11
 */
export class ThemeEditorStyle extends GroupStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '345vp'
  }
}

/**
 * 桌面和个性化合一编辑器模块
 *
 * @since 2024-04-11
 */

export class ThemeEditor extends ThemeEditorMenu implements WallpaperPreviewMenuData {
  constructor(menu: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = new ThemeEditorStyle();
    }
  }
}

/**
 * 桌面和个性化合一编辑器图标模块
 *
 * @since 2024-04-11
 */
export class ThemeEditorIcon extends ThemeEditorMenu implements WallpaperPreviewMenuData {
  constructor(menu: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = FontScaleUtils.getCurrentTopPadding() === navigationEntryMenuStyle.rootContainer.padding?.top ?
        navigationEntryMenuStyle : new NavigationEntryMenuStyle();
    }
    if (!menu?.menuType) {
      this.menuType = MenuType.THEME_EDITOR_ICON_STYLE_MENU;
    }
  }

  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end')
  };
}

/**
 * 桌面和个性化合一编辑器图标大小模块
 *
 * @since 2025-08-05
 */
export class ThemeEditorIconSize extends SettingsBaseMenu {
  constructor(menu?: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.THEME_EDITOR_ICON_SIZE_MENU;
    }
  }

  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end')
  };
}

/**
 * 桌面和个性化合一编辑器字体模块
 *
 * @since 2024-05-31
 */
export class ThemeEditorFont extends ThemeEditorMenu implements WallpaperPreviewMenuData {
  constructor(menu: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = FontScaleUtils.getCurrentTopPadding() === navigationEntryMenuStyle.rootContainer.padding?.top ?
        navigationEntryMenuStyle : new NavigationEntryMenuStyle();
    }
    if (!menu?.menuType) {
      this.menuType = MenuType.THEME_EDITOR_FONT_STYLE_MENU;
    }
  }

  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end')
  };
}

export class ThemeEditorDockColorStyle extends SettingsBaseMenu {
  constructor(menu?: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.THEME_EDITOR_DOCK_COLOR_STYLE_MENU;
    }
  }

  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end')
  };
}

export class ThemeEditorDockAutoHideStyle extends SettingsBaseMenu {
  constructor(menu?: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.THEME_EDITOR_DOCK_AUTO_HIDE_STYLE_MENU;
    }
  }

  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end')
  };
}

export class ThemeEditorWindowStyle extends SettingsBaseMenu {
  constructor(menu?: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.THEME_EDITOR_WINDOW_STYLE_MENU;
    }
  }

  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end')
  };
}

export class ThemeEditorDesktopStyle extends SettingsBaseMenu {
  constructor(menu?: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.THEME_EDITOR_DESKTOP_STYLE_MENU;
    }
  }

  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end')
  };
}

export class ButtonMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public gridGutter: Length = '16vp';
  public gridMargin: Length = '4vp'; // 该值主要在弹框中使用，12+4=16vp
}

export class AddWifiButtonMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public gridGutter: Length = '12vp';
  public gridMargin: Length = '0vp';
}

export class PcSingleButtonMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_64'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_16'),
  };
  public gridMargin: Length = $r('app.float.margin_72');
}

export class PcDoubleButtonMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_64'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_0'),
  };
  public gridGutter: Length = $r('app.float.gridGutter_16');
  public gridMargin: Length = $r('app.float.length_2'); // 该值主要在弹框中使用，12+4=16vp
}


export class TransParentWithVerticalDividerButtonMenuContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '56vp'
  };
  public margin: Margin = {
    top: $r('app.float.margin_8'),
    bottom: FontScaleUtils.isExtraLargeFontMode() ? '0' : '16vp'
  };
  public gridGutter: Length = $r('app.float.length_8');
  public gridMargin: Length = $r('app.float.length_4'); // 该值主要在弹框中使用，12+4=16vp
}

// 此处原来是 backgroundColor = DeviceUtil.isDevicePc() ? '#0A59F7' : '#0C000000';
export class EmphasizeButtonStyle extends ButtonStyle {
  public backgroundColor: ResourceColor | Color | Resource = DeviceUtil.isDevicePc() ?
  $r('sys.color.ohos_id_color_component_activated') : $r('sys.color.ohos_id_color_button_normal');
  public fontColor: ResourceColor | Color = DeviceUtil.isDevicePc() ? '0xFFFFFF' :
  $r('sys.color.ohos_id_color_emphasize');
  public size: SizeOptions = DeviceUtil.isDevicePc() ? { width: '100%', height: '40vp' } :
    { width: '100%', height: 'auto' };
  public constraintSize? : ConstraintSizeOptions | undefined = {
    minHeight: '40vp',
  };
  public margin: Margin = {
    top: $r('app.float.margin_16'),
    bottom: $r('app.float.margin_24'),
  };
}

export class PasswordEmphasizeButtonStyle extends EmphasizeButtonStyle {
  public type: ButtonType = ButtonType.Normal;
  public borderRadius: Length = $r('app.float.radius_8');
  public margin: Margin = {
    top: $r('app.float.margin_16'),
    bottom: $r('app.float.margin_16'),
  };
}

export class EmphasizeNetButtonStyle extends ButtonStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '40vp',
  };
  public margin: Margin = {
    top: $r('app.float.margin_16'),
    bottom: $r('app.float.margin_24'),
  };
}

export class BluetoothSingleEmphasizeButtonStyle extends ButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor = $r('sys.color.ohos_id_color_emphasize');
  public size: SizeOptions = {
    width: $r('app.float.width_250'),
    height: $r('app.float.width_40'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_16'),
    bottom: $r('app.float.margin_24'),
  };
}

export class BluetoothEmphasizeButtonStyle extends ButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor = $r('sys.color.ohos_id_color_emphasize');
  public size: SizeOptions = {
    width: $r('app.float.width_173'),
    height: $r('app.float.width_40'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_16'),
    bottom: $r('app.float.margin_24'),
  };
}

export class ProfileEmphasizeButtonStyle extends ButtonStyle {
  public backgroundColor: ResourceColor | Color = $r('sys.color.ohos_id_color_emphasize');
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '40vp',
  };
  public margin: Margin = {
    top: $r('app.float.margin_16'),
    bottom: $r('app.float.margin_24'),
  };
}

export class PcEmphasizeButtonStyle extends ButtonStyle {
  public backgroundColor: ResourceColor | Color = $r('sys.color.ohos_id_color_floating_button_bg_normal');
  public size: SizeOptions = {
    width: $r('app.float.width_173'),
    height: $r('app.float.height_40'),
  }
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_24'),
  };
}

export class PcSingleButtonStyle extends ButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor = $r('sys.color.ohos_id_color_component_activated');
  public size: SizeOptions = {
    width: $r('app.float.width_250'),
    height: $r('app.float.height_40'),
  }
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    left: $r('app.float.margin_60'),
    right: $r('app.float.margin_60'),
  };
}

export class PcSingleBlueButtonStyle extends ButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_icon_color_active');
  public fontColor = $r('sys.color.ohos_fa_text_contrary');
  public size: SizeOptions = {
    width: $r('app.float.width_176'),
    height: $r('app.float.height_40'),
  }
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    left: $r('app.float.margin_60'),
    right: $r('app.float.margin_60'),
    bottom: $r('app.float.margin_0'),
  };
}

// 此处原来是backgroundColor = '#0C000000';
export class DefaultButtonStyle extends EmphasizeButtonStyle {
  public backgroundColor: ResourceColor | Color | Resource = $r('sys.color.ohos_id_color_button_normal');
  public fontColor: ResourceColor | Color = $r('sys.color.ohos_id_color_text_primary_activated');
}

export class DefaultPasswordButtonStyle extends DefaultButtonStyle {
  public borderRadius: Length = $r('app.float.radius_8');
  public margin: Margin = {
    top: $r('app.float.margin_16'),
    bottom: $r('app.float.margin_16'),
  };
}

export class DefaultRedButtonStyle extends EmphasizeNetButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor = $r('app.color.font_color_error');
}

export class DefaultDisableOldPasswordButtonStyle extends EmphasizeButtonStyle {
  public backgroundColor: ResourceColor | Color | Resource = $r('sys.color.ohos_id_color_button_normal');
  public fontColor: ResourceColor | Color = $r('sys.color.ohos_id_color_warning');
  public borderRadius: Length = $r('app.float.radius_8');
  public margin: Margin = {
    top: $r('app.float.margin_16'),
    bottom: $r('app.float.margin_16'),
  };
}

export class DefaultSuccessButtonStyle extends EmphasizeNetButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor = $r('sys.color.ohos_id_color_emphasize');
  public size: SizeOptions = {
    width: $r('app.float.width_200'),
    height: $r('app.float.height_40'),
  }
}

export class BluetoothSingleButtonStyle extends BluetoothSingleEmphasizeButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor = $r('sys.color.ohos_id_color_emphasize');
}

export class BluetoothButtonStyle extends BluetoothEmphasizeButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor = $r('sys.color.ohos_id_color_emphasize');
}

export class PcDefaultButtonStyle extends PcEmphasizeButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor: ResourceColor | Color = $r('sys.color.ohos_id_color_text_primary_activated');
}

/**
 * 警告按钮样式数据类
 *
 * @since 2022-06-10
 */
export class WarningButtonStyle extends DefaultButtonStyle {
  public fontColor: ResourceColor | Color = $r('sys.color.ohos_id_color_text_primary_activated');
}

export class DefaultButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new ButtonMenuContainerStyle();
  public buttonStyle1 = new DefaultButtonStyle();
  public buttonStyle2 = new DefaultButtonStyle();
  public buttonStyle3 = new EmphasizeButtonStyle();
}

export class AddWifiButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new AddWifiButtonMenuContainerStyle();
  public buttonStyle1 = new DefaultButtonStyle();
  public buttonStyle2 = new DefaultButtonStyle();
  public buttonStyle3 = new EmphasizeButtonStyle();
}

export class DefaultNetButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new ButtonMenuContainerStyle();
  public buttonStyle1 = new DefaultButtonStyle();
  public buttonStyle2 = new DefaultRedButtonStyle();
  public buttonStyle3 = new EmphasizeButtonStyle();
}

export class DefaultSuccessButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new ButtonMenuContainerStyle();
  public buttonStyle1 = new DefaultSuccessButtonStyle();
}

export class BluetoothSingleButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new ButtonMenuContainerStyle();
  public buttonStyle1 = new BluetoothSingleButtonStyle();
}

export class BluetoothButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new ButtonMenuContainerStyle();
  public buttonStyle1 = new BluetoothButtonStyle();
  public buttonStyle3 = new BluetoothEmphasizeButtonStyle();
}

// PC端的双个按钮 top = 8vp
export class PcDoubleButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new PcDoubleButtonMenuContainerStyle();
  public buttonStyle1 = new PcDefaultButtonStyle();
  public buttonStyle2 = new PcDefaultButtonStyle();
  public buttonStyle3 = new PcEmphasizeButtonStyle();
}

// Phone端的双个按钮
export class TransParentWithVerticalDividerDefaultButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new TransParentWithVerticalDividerButtonMenuContainerStyle();
  public buttonStyle1 = new TransParentWithVerticalDividerButtonStyle();
  public buttonStyle2 = new TransParentWithVerticalDividerButtonStyle();
  public buttonStyle3 = new TransParentWithVerticalDividerButtonStyle();
}


export class TransParentWithVerticalDividerButtonStyle extends DefaultButtonStyle {
  public backgroundColor = $r('app.color.transparent');
  public fontColor = $r('sys.color.ohos_id_color_text_primary_activated');
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_40'),
  }
  public margin: Margin = {
    top: $r('app.float.margin_0'),
  };
}

export class PcSingleButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new PcSingleButtonMenuContainerStyle();
  public buttonStyle1 = new PcSingleButtonStyle();
}

export class UsbTipsPcSingleButtonMenuStyle extends ButtonMenuStyle {
  public buttonStyle1 = new PcSingleBlueButtonStyle();
}

export class TransparentButtonStyle extends DefaultButtonStyle {
  public backgroundColor = $r('app.color.transparent');
  public margin: Margin = {
    top: $r('app.float.margin_8'),
    bottom: $r('app.float.margin_16'),
  };
}

export class ClosePasswordButtonStyle extends DefaultButtonStyle {
  public backgroundColor = $r('app.color.transparent');
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize? : ConstraintSizeOptions | undefined = {
    minHeight: $r('app.float.height_40'),
  }
  public margin: Margin = {
    bottom: $r('app.float.margin_16'),
  };
}

export class ClosePasswordConfirmButtonStyle extends ClosePasswordButtonStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_warning');
}

export class TransparentButtonMenuStyle extends DefaultButtonMenuStyle {
  public buttonStyle1 = new ClosePasswordButtonStyle();
  public buttonStyle2 = new ClosePasswordButtonStyle();
}

export class SafeTipsButtonStyle extends DefaultButtonStyle {
  public fontColor = $r('sys.color.ohos_id_color_text_primary_activated');
  public backgroundColor = $r('app.color.transparent');
}

export class EdmTipsButtonStyle extends DefaultButtonStyle {
  public fontColor = $r('sys.color.font_emphasize');
  public backgroundColor = $r('app.color.transparent');
  public margin: Margin = {
    top: 0,
    bottom: 0,
  };
}

export class PolicyPasswordTipsButtonStyle extends DefaultButtonStyle {
  public fontColor = $r('sys.color.font_emphasize');
  public backgroundColor = $r('app.color.transparent');
  public font: Font = {
    family: 'HarmonyHeiTi',
    size: $r('sys.float.Body_L'),
  }
}

// ResourceUtil.getStringSync按钮样式
export class BlueButtonStyle extends DefaultButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_activated');
  public fontColor = $r('sys.color.ohos_id_color_foreground_contrary');
}

export class DefaultDialogButtonContainerStyle extends ButtonMenuContainerStyle {
  public margin: Margin = {
    bottom: $r('app.float.margin_16'),
  };
}

export class SafeTipsButtonMenuStyle extends DefaultButtonMenuStyle {
  public buttonStyle1 = new SafeTipsButtonStyle();
  public buttonStyle2 = new BlueButtonStyle();
  public rootContainer = new DefaultDialogButtonContainerStyle();
}

export class EdmTipsButtonMenuStyle extends DefaultButtonMenuStyle {
  public buttonStyle1 = new EdmTipsButtonStyle();
  public rootContainer = new DefaultDialogButtonContainerStyle();
}

export class DivideButtonDialogStyle extends DefaultButtonMenuStyle {
  public buttonStyle1 = new SafeTipsButtonStyle();
  public buttonStyle2 = new BlueButtonStyle();
  public rootContainer = new DefaultDialogButtonContainerStyle();
}

/**
 * 警告按钮组菜单样式数据类
 *
 * @since 2022-06-10
 */
export class WarningButtonMenuStyle extends DefaultButtonMenuStyle {
  public rootContainer = new ButtonMenuContainerStyle();
  public buttonStyle1 = new DefaultButtonStyle();
  public buttonStyle2 = new DefaultButtonStyle();
  public buttonStyle3 = new WarningButtonStyle();
}

export let defaultButtonMenuStyle = new DefaultButtonMenuStyle();

export let defaultButtonNetMenuStyle = new DefaultNetButtonMenuStyle();

export let defaultSuccessButtonNetMenuStyle = new DefaultSuccessButtonMenuStyle();


/**
 * 单按钮菜单跟布局样式
 *
 * @since 2022-05-21
 */
export class SingleButtonMenuContainerStyle extends ButtonMenuContainerStyle {
  public gridMargin: Length = '72vp';
}

/**
 * 单按钮菜单样式
 *
 * @since 2022-05-21
 */
export class SingleButtonMenuStyle extends DefaultButtonMenuStyle {
  public rootContainer = new SingleButtonMenuContainerStyle();
}

export class SingleTransparentButtonMenuStyle extends DefaultButtonMenuStyle {
  public rootContainer = new SingleButtonMenuContainerStyle();
  public buttonStyle1 = new TransparentButtonStyle();
}

export class PCBluetoothSingleButtonMenuStyle extends BluetoothSingleButtonMenuStyle {
  public rootContainer = new SingleButtonMenuContainerStyle();
}

export let singleButtonMenuStyle = new SingleButtonMenuStyle();

export let singleTransparentButtonMenuStyle = new SingleTransparentButtonMenuStyle();

export interface ButtonMenuData extends BaseButtonMenuData {}

/**
 * 按钮菜单数据类
 *
 * @since 2022-03-21
 */
export class ButtonMenu extends BaseButtonMenu implements ButtonMenuData {
  constructor(menu: Partial<ButtonMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultButtonMenuStyle;
    }
  }
}

export class ConnectButtonMenu extends BaseButtonMenu implements ButtonMenuData {
  constructor(menu: Partial<ButtonMenuData>) {
    super(menu);
    this.menuType = MenuType.CONNECT_BUTTON;
    if (!menu.style) {
      this.style = defaultButtonMenuStyle;
    }
  }
}

export class WindowButtonMenu extends WindowBaseButtonMenu implements ButtonMenuData {
  constructor(menu: Partial<ButtonMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultButtonMenuStyle;
    }
  }
}

let transParentWithVerticalDividerDefaultButtonMenuStyle = new TransParentWithVerticalDividerDefaultButtonMenuStyle();

export interface TransparentButtonMenuData extends BaseButtonMenuData {}

export class TransparentButtonMenu extends BaseButtonMenu implements TransparentButtonMenuData {
  constructor(menu: Partial<TransparentButtonMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = transParentWithVerticalDividerDefaultButtonMenuStyle;
    }
    if (!menu.menuType) {
      this.menuType = MenuType.TRANSPARENT_BUTTON;
    }
  }
}

export class DoubleButtonMenuContainerStyle extends ButtonMenuContainerStyle {
  public gridGutter: Length = '24vp';
  public gridMargin: Length = '24vp';
}

export class DoubleEmphasizeButtonStyle extends EmphasizeButtonStyle {
  public gridSpan = 4;
  public gridOffset = 6;
  public margin: Margin = {
    top: '24vp',
    bottom: '24vp',
  };
}

export class DoubleDefaultButton1Style extends DoubleEmphasizeButtonStyle {
  public gridSpan = GRID_SPAN_4;
  public gridOffset = GRID_OFFSET_2;
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor: ResourceColor | Color = $r('sys.color.ohos_id_color_text_primary_activated');
}

export class DoubleDefaultButton2Style extends DoubleEmphasizeButtonStyle {
  public gridSpan = GRID_SPAN_4;
  public gridOffset = GRID_OFFSET_6;
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor: ResourceColor | Color = $r('sys.color.ohos_id_color_text_primary_activated');
}

export class DoubleDefaultButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new DoubleButtonMenuContainerStyle();
  public buttonStyle1 = new DoubleDefaultButton1Style();
  public buttonStyle2 = new DoubleDefaultButton2Style();
  public buttonStyle3 = new DoubleEmphasizeButtonStyle();
}

export let doubleDefaultButtonMenuStyle = new DoubleDefaultButtonMenuStyle();

export class VerticalButtonMenuContainerStyle extends ButtonMenuContainerStyle {
  public gridGutter: Length = '12vp';
  public gridMargin: Length = '0vp';
  public gridColumns: number = GRID_COLUMNS_12;
}

export class VerticalEmphasizeButtonStyle extends EmphasizeButtonStyle {
  public gridSpan = DeviceUtil.isDevicePc() ? GRID_SPAN_4 : GRID_COLUMNS_12;
  public gridOffset = DeviceUtil.isDevicePc() ? GRID_OFFSET_4 : GRID_OFFSET_0;
  public margin: Margin = {
    top: $r('app.float.margin_24'),
    bottom: DeviceUtil.isDevicePc() ? $r('app.float.margin_56') : $r('app.float.margin_48'),
  };
}

export class VerticalProfileEmphasizeButtonStyle extends ProfileEmphasizeButtonStyle {
  public gridSpan = GRID_COLUMNS_12;
  public gridOffset = GRID_OFFSET_0;
  public margin: Margin = {
    top: $r('app.float.margin_24'),
    bottom: $r('app.float.margin_48'),
  };
}

export class VerticalDefaultButtonStyle extends VerticalEmphasizeButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor: ResourceColor | Color = $r('sys.color.ohos_id_color_text_primary_activated');
}

export class VerticalProfileDefaultButtonStyle extends VerticalProfileEmphasizeButtonStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_button_normal');
  public fontColor: ResourceColor | Color = $r('sys.color.ohos_id_color_text_primary_activated');
}

export class VerticalDefaultButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new VerticalButtonMenuContainerStyle();
  public buttonStyle1 = new VerticalDefaultButtonStyle();
  public buttonStyle2 = new VerticalDefaultButtonStyle();
  public buttonStyle3 = new VerticalEmphasizeButtonStyle();
}

export class VerticalProfileDefaultButtonMenuStyle extends VerticalDefaultButtonMenuStyle {
  public buttonStyle1 = new VerticalProfileDefaultButtonStyle();
}

export let verticalDefaultButtonMenuStyle = new VerticalDefaultButtonMenuStyle();

export let verticalProfileDefaultButtonMenuStyle = new VerticalProfileDefaultButtonMenuStyle();

export interface VerticalButtonMenuData extends BaseButtonMenuData {}

/**
 * 竖向排列按钮菜单数据类
 *
 * @since 2022-03-21
 */
export class VerticalButtonMenu extends BaseButtonMenu implements VerticalButtonMenuData {
  constructor(menu: Partial<VerticalButtonMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.VERTICAL_BUTTON;
    }
    if (!menu.style) {
      this.style = verticalDefaultButtonMenuStyle;
    }
  }
}

export class PageTitleContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '56vp',
  };
  public margin: Margin = {
    top: $r('app.float.length_0'),
  };
  public maxLines = 2;
  public overflow: TextOverflow = TextOverflow.Ellipsis;
}

export class EditPCPageTitleContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: $r('app.float.length_21'),
  };
  public size: SizeOptions = {
    height: $r('app.float.height_56'),
    width: '100%',
  };
  public margin: Margin = {
    top: $r('app.float.margin_6')
  };
}

export class LocationTitleContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public size: SizeOptions = {
    height: $r('app.float.height_56'),
    width: '100%',
  };
}

export class ProfilePageTitleContainerStyle extends PageTitleContainerStyle {
  public padding: Padding = {
    left: $r('app.float.margin_0'),
    right: $r('app.float.margin_0'),
  };
}

export class NavPageTitleContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  }
  public margin: Margin = {
    top: $r('app.float.length_12'),
    bottom: $r('app.float.length_4'),
  };
}

export class PCHomeNavPageContainerStyle extends NavPageTitleContainerStyle {
  public size: SizeOptions = {
    height: $r('app.float.length_8'),
    width: '100%',
  };
}

export interface FontI extends Font {
  weight?: FontWeight | number | string;
  minFontSize?: ResourceStr,
  maxFontSize?: ResourceStr,
  heightAdaptivePolicy?: TextHeightAdaptivePolicy
}

export class PageTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: FontI = {
    size: $r('sys.float.ohos_id_text_size_dialog_tittle'),
    weight: FontWeight.Bold,
  };
  public overflow: TextOverflow = TextOverflow.None;
}

export class NavPageTitleTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: $r('app.float.length_20'),
    weight: FontWeight.Bold,
  };
}

export class PCNavPageTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('app.float.length_24'),
    weight: FontWeight.Bold,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines = MAX_LINES_1;
  public margin: Margin = { top: $r('app.float.length_7_5'), bottom: $r('app.float.length_7_5') };
}

export class EditPCPageTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('app.float.length_20'),
    weight: FontWeight.Bold,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines = MAX_LINES_1;
  public margin: Margin = { top: $r('app.float.margin_8'), bottom: $r('app.float.length_7_5') };
}

export class LocationServiceTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('app.float.length_20'),
    weight: FontWeight.Medium,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines = MAX_LINES_1;
}

export class DefaultPageHeaderStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new PageTitleContainerStyle();
  public title?: TextStyle = new PageTitleTextStyle();
}

export class ProfilePageHeaderStyle extends DefaultPageHeaderStyle {
  public rootContainer?: ContainerStyle = new ProfilePageTitleContainerStyle();
}

export class DefaultNavPageHeaderStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new PageTitleContainerStyle();
  public title?: TextStyle = new NavPageTitleTextStyle();
}

export class PCDefaultNavPageHeaderStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new PageTitleContainerStyle();
  public title?: TextStyle = new PCNavPageTitleTextStyle();
}

export class PCHomeNavPageHeaderStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new PCHomeNavPageContainerStyle();
  public title?: TextStyle = new NavPageTitleTextStyle();
}

export class PCEditLaPageHeaderStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new EditPCPageTitleContainerStyle();
  public title?: TextStyle = new EditPCPageTitleTextStyle();
}

export class ReplaceDialogTitleTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_dialog_tittle'),
    weight: FontWeight.Bold,
    family: 'HarmonyHeiTi',
  };
  public margin: Margin = {
    top: $r('app.float.length_15'),
    bottom: $r('app.float.length_15'),
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
}

export class PCLocationHeaderStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new PageTitleContainerStyle();
  public title?: TextStyle = new NavPageTitleTextStyle();
}

export let defaultNavPageHeaderStyle = new DefaultNavPageHeaderStyle();

export let pcDefaultNavPageHeaderStyle = new PCDefaultNavPageHeaderStyle();

export let pcHomeNavPageHeaderStyle = new PCHomeNavPageHeaderStyle();

export let pcEditLaPageHeaderStyle = new PCEditLaPageHeaderStyle();

export let pcLocationHeaderStyle = new PCLocationHeaderStyle();

export let defaultPageHeaderStyle = new DefaultPageHeaderStyle();

export let profilePageHeaderStyle = new ProfilePageHeaderStyle();

export interface PageTitleMenuData extends SettingsBaseMenuData {}

export class PageTitleMenu extends SettingsBaseMenu implements PageTitleMenuData {
  constructor(menu: Partial<PageTitleMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.PAGE_TITLE;
    }
    if (!menu.style) {
      this.style = defaultPageHeaderStyle;
    }
  }
}

class DialogTitleTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: $r('sys.float.Title_S'),
    weight: FontWeight.Bold,
  };
  public margin: Margin = DeviceUtil.isDevicePc() ?
    { top: $r('app.float.length_16'), bottom: $r('app.float.length_16') } :
    { top: $r('app.float.length_16'), bottom: $r('app.float.length_16') };
  public justifyContent: FlexAlign = FlexAlign.Center;
}

class WifiDialogTitleTextStyle extends PageTitleTextStyle {
  public font: FontI = {
    size: $r('sys.float.Title_S'),
    weight: FontWeight.Bold,
    maxFontSize: $r('sys.float.Title_S'),
    minFontSize: $r('sys.float.ohos_id_text_size_sub_title2'),
    heightAdaptivePolicy: TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST
  };
  public margin: Margin = DeviceUtil.isDevicePc() ?
    { top: $r('app.float.length_16'), bottom: $r('app.float.length_16') } :
    { top: $r('app.float.length_16'), bottom: $r('app.float.length_16') };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines: number = 2;
  public justifyContent: FlexAlign = DeviceUtil.isDevicePc() ? FlexAlign.Center : FlexAlign.Start;
}

class ClosePasswordDialogTitleContainerStyle extends PageTitleContainerStyle {
  public margin: Margin = {
    top: $r('app.float.length_0'),
  };
  public padding: Padding = {
    left: $r('app.float.length_0'),
    right: $r('app.float.length_0'),
  };
}

export class ClosePasswordDialogTitleTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: $r('sys.float.Title_S'),
    weight: FontWeight.Bold,
  };
  public margin: Margin = {
    top: $r('app.float.length_0'),
    bottom: $r('app.float.length_0'),
  };
}

export class ClosePasswordDialogTitleMenuStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new ClosePasswordDialogTitleContainerStyle();
  public title?: TextStyle = new ClosePasswordDialogTitleTextStyle();
}

class PcDialogTitleTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: $r('app.float.font_20_vp'),
    weight: FontWeight.Medium,
    family: 'HarmonyHeiTi',
  };
  public margin: Margin = {
    top: $r('app.float.length_15'),
    bottom: $r('app.float.length_15'),
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
}

class PhoneDialogTitleTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_dialog_tittle'),
    weight: FontWeight.Bold,
    family: 'HarmonyHeiTi',
  };
  public margin: Margin = {
    top: $r('app.float.length_16'),
    bottom: $r('app.float.length_16'),
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '27vp',
  }
  public maxLines = 4;
  public overflow: TextOverflow = TextOverflow.Ellipsis;
}

class DialogTitleContainerStyle extends PageTitleContainerStyle {
  public margin: Margin = {
    top: '0',
  };
  public font: Font = {
    size: '20vp',
    weight: FontWeight.Bold,
    family: 'HarmonyHeiTi',
  };
}

class AlignStartDialogTitleContainerStyle extends DialogTitleContainerStyle {
  public padding: Padding = {
    left: '0',
    right: DEFAULT_PADDING_END,
  };
}

class WifiDialogTitleContainerStyle extends PageTitleContainerStyle {
  public margin: Margin = {
    top: '0',
  };
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_dialog_tittle'),
    weight: FontWeight.Bold,
    family: 'HarmonyHeiTi',
  };
}

class BluetoothDialogTitleContainerStyle extends PageTitleContainerStyle {
  public margin: Margin = {
    top: $r('app.float.length_0'),
  };
  public padding: Padding = {
    left: $r('app.float.length_0'),
    right: $r('app.float.length_0'),
  };
  public font: Font = {
    size: '20vp',
    weight: FontWeight.Bold,
    family: 'HarmonyHeiTi',
  };
}

export class DialogTitleMenuStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new DialogTitleContainerStyle();
  public title?: TextStyle = new DialogTitleTextStyle();
}

export class WifiDialogTitleMenuStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new WifiDialogTitleContainerStyle();
  public title?: TextStyle = new WifiDialogTitleTextStyle();
}

export class BluetoothDialogTitleMenuStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new BluetoothDialogTitleContainerStyle();
  public title?: TextStyle = new DialogTitleTextStyle();
}

export class PcDialogTitleMenuStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new DialogTitleContainerStyle();
  public title?: TextStyle = new PcDialogTitleTextStyle();
}

export class ReplaceDialogTitleMenuStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new BluetoothDialogTitleContainerStyle();
  public title?: TextStyle = new ReplaceDialogTitleTextStyle();
}

export class PhoneDialogTitleMenuStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new BluetoothDialogTitleContainerStyle();
  public title?: TextStyle = new PhoneDialogTitleTextStyle();
}

export let dialogTitleMenuStyle = new DialogTitleMenuStyle();

export class RadioListDialogTitleContainerStyle extends DialogTitleContainerStyle {
  public margin: Margin = {
    top: '0',
    left: $r('sys.float.ohos_id_card_margin_start'),
    right: $r('sys.float.ohos_id_card_margin_end'),
  };
}

export class RadioListDialogTitleMenuStyle extends DialogTitleMenuStyle {
  public rootContainer?: ContainerStyle = new RadioListDialogTitleContainerStyle();
  public title?: TextStyle = new DialogTitleTextStyle();
}

export let radioListDialogTitleMenuStyle = new RadioListDialogTitleMenuStyle();

export interface DialogTitleMenuData extends PageTitleMenuData {}

export class DialogTitleMenu extends PageTitleMenu implements DialogTitleMenuData {
  constructor(menu: Partial<DialogTitleMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = dialogTitleMenuStyle;
    }
  }
}

export class DialogMessageContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    right: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    top: '24vp',
  };
  public justifyContent = FlexAlign.Center;
}

export class DialogMessageContainerLabelStyle extends ContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    right: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    top: '0',
  };
  public justifyContent = FlexAlign.Center;
}

export class UsbTipsDialogMessageContainerLabelStyle extends ContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    right: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    top: $r('app.float.padding_18'),
    bottom: $r('app.float.padding_19'),
  };
  public justifyContent = FlexAlign.Center;
}

export class BlueToothDialogMessageContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    right: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
  };
}

export class ToPairWithTheFollowingDialogMessageContainerStyle extends ContainerStyle {
}

export class UsuallyMessagePinMessageContainerStyle extends ToPairWithTheFollowingDialogMessageContainerStyle {
  public size: SizeOptions = {
    width: $r('app.float.size_346'),
    height: $r('app.float.height_48'),
  };
  public margin: Margin = {
    left: $r('app.float.margin_12'),
    right: $r('app.float.margin_12'),
  };
}

export class DeviceNameDialogMessageContainerStyle extends ContainerStyle {
}

export class PhoneDeviceNamePinMessageContainerStyle extends DeviceNameDialogMessageContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    right: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public justifyContent = FlexAlign.Center;
}

export class PcDeviceNamePinMessageContainerStyle extends DeviceNameDialogMessageContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public size: SizeOptions = {
    width: '100%',
  };
}

export class ToPairWithTheFollowingPinMessageContainerStyle extends ToPairWithTheFollowingDialogMessageContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    right: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
  };
  public justifyContent = FlexAlign.Center;
}

export class PcToPairWithTheFollowingPinMessageContainerStyle
  extends ToPairWithTheFollowingDialogMessageContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public margin: Margin = {
    bottom: $r('app.float.margin_0'),
    top: $r('app.float.margin_8'),
  };
  public justifyContent = FlexAlign.Center;
}

export class PcDialogToPairMessageContainerStyle extends ToPairWithTheFollowingDialogMessageContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public margin: Margin = {
    bottom: $r('app.float.margin_0'),
    top: $r('app.float.margin_0')
  };
  public justifyContent = FlexAlign.Center;
}

export class PcToPairDialogMessageContainerStyle extends ToPairWithTheFollowingDialogMessageContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public margin: Margin = {
    bottom: $r('app.float.margin_0'),
    top: $r('app.float.margin_16'),
  };
  public justifyContent = FlexAlign.Center;
}

export class DialogMessageTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines = 10;
}

export class DisableDialogMessageTextStyle extends DialogMessageTextStyle {
  public align?: Alignment = Alignment.Center;
  public font: Font = {
    size: $r('sys.float.Body_L'),
    weight: FontWeight.Medium,
    family: 'HarmonyHeiTi'
  };
}

export class PinCodeMessageTextStyle extends DialogMessageTextStyle {
  public font: Font = {
    size: $r('app.float.length_32'),
    weight: FontWeight.Medium,
    family: 'HarmonyHeiTi',
  };
}

export class UsuallyMessageDialogMessageTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: '16vp',
    family: 'HarmonyHeiTi',
    weight: FontWeight.Regular,
  };
  public size: SizeOptions = {
    width: '346vp',
  };
  public margin: Margin = {
    left: '0vp',
    right: '0vp'
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines = 10;
  public lineHeight = '19vp';
}

export class DialogMessageStyle implements Style {
  public rootContainer?: ContainerStyle = new DialogMessageContainerStyle();
  public title?: TextStyle = new DialogMessageTextStyle();
}

export class DialogMessageLabelStyle implements Style {
  public rootContainer?: ContainerStyle = new DialogMessageContainerLabelStyle();
  public title?: TextStyle = new DialogMessageTextStyle();
}

export class UsbTipsMessageLabelStyle implements Style {
  public rootContainer?: ContainerStyle = new UsbTipsDialogMessageContainerLabelStyle();
  public title?: TextStyle = new DialogMessageTextStyle();
}

export class BluetoothDialogMessageStyle implements Style {
  public rootContainer?: ContainerStyle = new BlueToothDialogMessageContainerStyle();
  public title?: TextStyle = new DialogMessageTextStyle();
}

let dialogMessageStyle = new DialogMessageStyle();

export let blueDialogMessageStyle = new BluetoothDialogMessageStyle();

/**
 * 居中对齐弹框消息容器样式
 *
 */
export class AlignCenterDialogMessageStyle extends DialogMessageStyle {
  constructor() {
    super();
    if (this.rootContainer) {
      if (!this.rootContainer.size) {
        this.rootContainer.size = {};
      }
      this.rootContainer.size.width = '100%';
      this.rootContainer.align = Alignment.Center;
    }
  }
}

export class UsbTipsDialogMessageStyle extends UsbTipsMessageLabelStyle {
  constructor() {
    super();
    if (this.rootContainer) {
      if (!this.rootContainer.size) {
        this.rootContainer.size = {};
      }
      this.rootContainer.size.width = '100%';
      this.rootContainer.align = Alignment.Center;
    }
  }
}

/**
 * 左对齐弹框消息容器样式
 *
 * @since 2022-05-21
 */
export class AlignStartDialogMessageContainerStyle extends DialogMessageContainerStyle {
  public padding: Padding = {
    left: $r('app.float.margin_0'),
    right: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_8'),
  };
  public justifyContent = FlexAlign.Start;
}

export class PcAlignStartDialogMessageContainerStyle extends DialogMessageContainerStyle {
  public padding: Padding = {
    left: $r('app.float.margin_12'),
    right: $r('app.float.margin_12'),
    bottom: $r('app.float.margin_0'),
  };
  public justifyContent = FlexAlign.Start;
}

export class ClosePasswordDialogMessageContainerStyle extends DialogMessageContainerStyle {
  public padding: Padding = {
    left: $r('app.float.margin_12'),
    right: $r('app.float.margin_12'),
    bottom: $r('app.float.margin_8'),
  };
  public justifyContent = FlexAlign.Start;
}

export class DisableOldPasswordDialogMessageContainerStyle extends DialogMessageContainerStyle {
  public padding: Padding = {
    left: $r('app.float.padding_16'),
    right: $r('app.float.padding_16'),
    bottom: $r('app.float.border_radius_0'),
  };
  public justifyContent = FlexAlign.Center;
}

/**
 * 左对齐弹框消息菜单样式
 *
 * @since 2022-05-21
 */
export class AlignStartDialogMessageStyle extends DialogMessageStyle {
  public rootContainer?: ContainerStyle = new AlignStartDialogMessageContainerStyle();
}

/**
 * 左对齐弹框标题菜单样式
 *
 * @since 2024-03-13
 */
export class PcAlignStartDialogTitleStyle extends DialogTitleMenuStyle {
  public rootContainer?: ContainerStyle = new AlignStartDialogTitleContainerStyle();
}

export class PhoneBtMessageTextStyle extends DialogMessageTextStyle {
  public size: SizeOptions = {
    width: '100%',
  };
}

export class PhoneAlignStartDialogMessageStyle extends DialogMessageStyle {
  public rootContainer?: ContainerStyle = new AlignStartDialogMessageContainerStyle();
  public title: TextStyle = new PhoneBtMessageTextStyle();
}

export class PcAlignStartDialogMessageStyle extends DialogMessageStyle {
  public rootContainer?: ContainerStyle = new PcAlignStartDialogMessageContainerStyle();
}

export class ClosePasswordDialogMessageStyle extends DialogMessageStyle {
  public rootContainer?: ContainerStyle = new ClosePasswordDialogMessageContainerStyle();
}

export class DisableOldPasswordDialogMessageStyle extends DialogMessageStyle {
  public rootContainer?: ContainerStyle = new DisableOldPasswordDialogMessageContainerStyle();
  public title?: TextStyle = new DisableDialogMessageTextStyle();
}

export let replaceDialogTitleMenuStyle = new ReplaceDialogTitleMenuStyle();

export let alignStartDialogMessageStyle = new AlignStartDialogMessageStyle();

export let pcAlignStartDialogTitleStyle = new PcAlignStartDialogTitleStyle();

export let pcAlignStartDialogMessageStyle = new PcAlignStartDialogMessageStyle();

export let closePasswordDialogMessageStyle = new ClosePasswordDialogMessageStyle();

export let disableOldPasswordDialogMessageStyle = new DisableOldPasswordDialogMessageStyle();

export interface DialogMessageMenuData extends SettingsBaseMenuData {}

export interface DialogListMessageMenuData extends SettingsBaseMenuData {
  textSiblings?: DialogListMessageMenuData[];
}

export class DialogMessageMenu extends SettingsBaseMenu {
  constructor(menu: Partial<DialogMessageMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.TEXT;
    }
    if (!menu.style) {
      this.style = dialogMessageStyle;
    }
  }
}

export class DialogListMessageMenu extends DialogMessageMenu {
  public textSiblings?: DialogListMessageMenuData[];
  constructor(menu: Partial<DialogListMessageMenuData>) {
    super(menu);
    this.menuType = MenuType.TEXT_LIST;
    this.textSiblings = menu.textSiblings ?? [];
  }
}

export interface AlignStartDialogMessageMenuData extends DialogMessageMenuData {}

export class AlignStartDialogMessageMenu extends DialogMessageMenu implements AlignStartDialogMessageMenuData {
  constructor(menu: Partial<AlignStartDialogMessageMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = alignStartDialogMessageStyle;
    }
  }
}

/**
 * 开关卡片外辅助文本容器样式
 *
 * @since 2022-05-21
 */
export class SwitchOutSummaryContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
    top: '8vp',
    bottom: '0vp',
  };
}

export class BTSwitchOutSummaryContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
    top: '8vp',
    bottom: '12vp',
  };
}

/*
 * 时区自动开关定位菜单
 * */
export class DateZoneMenu extends SettingsBaseMenu {
  constructor(menu: Partial<HotspotSummaryMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.DATE_ZONE;
    }
  }
}

export class WifiPrecisionMenuStyle extends BaseStyle {
  public margin: Padding = {
    top: '12vp',
    bottom: '0vp'
  };
}

/*
 * 提高精确度文本  打开提高精确度页面
 * */
export class WifiPrecisionMenu extends SettingsBaseMenu {
  constructor(menu: Partial<HotspotSummaryMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.WIFI_PRECISION;
    }
    if (menu.style) {
      this.style = menu.style;
    }
  }
}

/*
 * 跳转到陌生号码识别文本
 * */
export class ElderCarePrecisionMenu extends SettingsBaseMenu {
  constructor(menu: Partial<HotspotSummaryMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.ELDER_CARE_TELEPHONY;
    }
    if (menu.style) {
      this.style = menu.style;
    }
  }
}

/**
 * 开关卡片外辅助文本样式
 *
 * @since 2022-05-21
 */
export class SwitchOutSummaryTextStyle extends SummaryTextStyle {
  public margin: Margin = {};
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body2'),
    weight: FontWeight.Regular,
  };
}

/**
 * 开关卡片外辅助文本菜单样式
 *
 * @since 2022-05-21
 */
export class SwitchOutSummaryStyle implements Style {
  public rootContainer?: ContainerStyle = new SwitchOutSummaryContainerStyle();
  public title?: TextStyle = new SwitchOutSummaryTextStyle();
}

let switchOutSummaryStyle = new SwitchOutSummaryStyle();

/**
 * CA证书辅助文本样式
 */
export class RedSummaryContainerStyle extends SwitchOutSummaryContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
    top: '8vp',
    bottom: '4vp',
  };
}

/**
 * CA证书辅助文本样式
 */
export class RedSummaryTextStyle extends SwitchOutSummaryTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_warning');
  public font: Font = {
    size: $r('app.float.wh_value_12'),
    weight: FontWeight.Regular,
  };
}

/**
 * CA证书辅助文本菜单样式
 */
export class RedOutSummaryStyle implements Style {
  public rootContainer?: ContainerStyle = new RedSummaryContainerStyle();
  public title?: TextStyle = new RedSummaryTextStyle();
}

export interface SwitchOutSummaryMenuData extends SettingsBaseMenuData {}

/**
 * 开关卡片外辅助文本菜单数据
 *
 * @since 2022-05-21
 */
export class SwitchOutSummaryMenu extends SettingsBaseMenu implements SwitchOutSummaryMenuData {
  constructor(menu: Partial<SwitchOutSummaryMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.TEXT;
    }
    if (!menu.style) {
      this.style = switchOutSummaryStyle;
    }
  }
}

/**
 * 个人热点辅助文本容器样式
 *
 * @since 2023-09-02
 */
export class HotspotSummaryContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
    bottom: $r('app.float.length_8'),
  };
}

/**
 * 个人热点辅助文本样式
 *
 * @since 2023-09-02
 */
export class HotspotSummaryTextStyle extends SummaryTextStyle {
  public font: Font = {
    size: $r('app.float.font_14'),
  };
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_hint');
  public maxLines: number = MARGIN_TOP_66;
}

/**
 * 个人热点辅助文本菜单样式
 *
 * @since 2023-09-02
 */
export class HotspotSummaryStyle implements Style {
  public rootContainer?: ContainerStyle = new HotspotSummaryContainerStyle();
  public title?: TextStyle = new HotspotSummaryTextStyle();
}

let hotspotSummaryStyle = new HotspotSummaryStyle();

export interface HotspotSummaryMenuData extends SettingsBaseMenuData {}

/**
 * 个人热点辅助文本菜单数据
 *
 * @since 2023-09-02
 */
export class HotspotSummaryMenu extends SettingsBaseMenu implements HotspotSummaryMenuData {
  constructor(menu: Partial<HotspotSummaryMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.TEXT;
    }
    if (!menu.style) {
      this.style = hotspotSummaryStyle;
    }
  }
}

/**
 * 电池菜单文本数据
 *
 * @since 2023-11-02
 */
export class BatterySummaryMenu extends SettingsBaseMenu implements HotspotSummaryMenuData {
  constructor(menu: Partial<HotspotSummaryMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.ROW_TEXT;
    }
    if (!menu.style) {
      this.style = hotspotSummaryStyle;
    }
  }
}

export class LoadingContainerStyle extends ContainerStyle {
  public margin: Margin = {
    top: '24vp',
    right: '12vp',
    bottom: '24vp',
    left: '12vp',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public verticalAlign = VerticalAlign.Center;
  public horizontalAlign = HorizontalAlign.Center;
  public justifyContent = FlexAlign.Center;
}

export class DefaultLoadingProgressStyle extends LoadingProgressStyle {
  public size: SizeOptions = {
    width: '36vp',
    height: '36vp',
  };
  public margin: Margin = {
    left: '16vp',
  };
}

let defaultLoadingProgressStyle = new DefaultLoadingProgressStyle();

export class LoadingTitleTextStyle extends TitleTextStyle {
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Regular,
  };
}

export class DefaultLoadingMenuStyle extends LoadingMenuStyle {
  public rootContainer = new LoadingContainerStyle;
  public title = new LoadingTitleTextStyle();
  public summary = summaryTextStyle;
  public loadingProgressStyle = defaultLoadingProgressStyle;
}

let defaultLoadingMenuStyle = new DefaultLoadingMenuStyle;

/**
 * 加载菜单数据类
 *
 * @since 2022-03-21
 */
export class LoadingMenu extends BaseLoadingMenu implements BaseLoadingMenuData {
  constructor(menu: Partial<BaseLoadingMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultLoadingMenuStyle;
    }
  }
}

export class TextInputContainerStyle extends RootContainerStyle {
  public horizontalAlign = HorizontalAlign.Start;
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '40vp',
  };
  public size: SizeOptions = {
    width: '100%',
  };
}

/**
 * 菜单辅助文本样式
 *
 * @since 2022-03-21
 */
export class InputTextSummaryStyle extends TitleTextStyle {
  public padding: Padding = {
    top: '24vp',
    bottom: '4vp',
  };
}

export class DefaultTextInputMenuStyle extends TextInputMenuStyle {
  public rootContainer = new TextInputContainerStyle
  public summaryStyle = new InputTextSummaryStyle
  public stateStyle = new TitleTextStyle
}

export class UsuallyMessageTextInputMenuStyle extends TextInputMenuStyle {
  public rootContainer = new TextInputContainerStyle();
  public textInputStyle = new UsuallyMessageTextInputStyle();
}

let defaultTextInputMenuStyle = new DefaultTextInputMenuStyle;

export interface TextInputMenuData extends BaseTextInputMenuData {}

export class TextInputMenu extends BaseTextInputMenu implements TextInputMenuData {
  constructor(menu: Partial<TextInputMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultTextInputMenuStyle;
    }
  }
}

export interface ChainedTextInputMenuData extends BaseTextInputMenuData {}

export class ChainedTextInputMenu extends BaseTextInputMenu implements ChainedTextInputMenuData {
  constructor(menu: Partial<ChainedTextInputMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultTextInputMenuStyle;
    }
    if (!menu?.menuType) {
      this.menuType = MenuType.CHAINED_TEXT_INPUT;
    }
  }
}

export class UsuallyMessageTextInputStyle extends TextInputStyle {
  public placeholderColor = $r('sys.color.ohos_id_color_text_hint');
  public placeholderFont: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Regular,
    family: 'HarmonyHeiTi',
  };
  public margin: Margin = {
    top: 0,
    bottom: 0,
  };
  public borderRadius = 20;
}

export class UsuallyMessageContainerStyle extends RootContainerStyle {
}

export class PasswordInputContainerStyle extends RootContainerStyle {
}

export class PasswordInputStyle extends TextInputStyle {
  public inputType = InputType.Password;
  public placeholderColor = $r('sys.color.ohos_id_color_text_hint');
  public placeholderFont: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Regular,
    family: 'sans-serif',
    style: FontStyle.Normal,
  };
  public backgroundColor: ResourceColor | Color = $r('app.color.bg_color_input_box_sub_bg');
  public caretColor: ResourceColor = Color.Blue;
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '56vp',
  };
  public maxLength = 64;
}

export class PasswordInputMenuStyle extends TextInputMenuStyle {
  public rootContainer = new PasswordInputContainerStyle();
  public textInputStyle = new PasswordInputStyle();
}

let passwordInputMenuStyle = new PasswordInputMenuStyle();

export interface PasswordInputMenuData extends TextInputMenuData {}

/**
 * 密码输入菜单数据类
 *
 * @since 2022-03-21
 */
export class PasswordInputMenu extends TextInputMenu implements PasswordInputMenuData {
  constructor(menu: Partial<PasswordInputMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = passwordInputMenuStyle;
    }
  }
}

export class PasswordCircleContainerStyle extends RootContainerStyle {
  public size: SizeOptions = {
    height: '32vp',
    width: '100%',
  };
  public margin: Margin = {
    top: MARGIN_TOP_66,
    bottom: MARGIN_12,
    left: $r('app.float.margin_0'),
    right: $r('app.float.margin_0'),
  };
}

export class PasswordCircleInputStyle extends TextInputStyle {
  public inputType = InputType.NUMBER_PASSWORD;
  public size: SizeOptions = {
    height: '36vp',
    width: '192vp',
  };
  public backgroundColor = 'rgba(0,0,0,0)';
  public caretColor = 'rgba(0,0,0,0)';
  public maxLength: number = MAX_LINES_6;
  public margin: Margin = {
    bottom: MARGIN_BOTTOM_8,
  };
}

export class PasswordCircleMenuStyle extends TextInputMenuStyle {
  public rootContainer = new PasswordCircleContainerStyle();
  public textInputStyle = new PasswordCircleInputStyle();
}

let passwordCircleMenuStyle = new PasswordCircleMenuStyle();

/**
 * 密码圆圈菜单数据类
 *
 * @since 2023-01-17
 */
export class PasswordCircleMenu extends PasswordCircleBaseMenu implements PasswordCircleBaseMenuData {
  constructor(menu: Partial<PasswordCircleBaseMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = passwordCircleMenuStyle;
    }
  }
}

export class UnderLineTextInputContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '36vp',
  };
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
    left: $r('app.float.margin_24'),
    right: $r('app.float.margin_24'),
  };
}

export class PcUnderLineTextInputContainerStyle extends RootContainerStyle {
  public horizontalAlign = HorizontalAlign.Start;
}

export class UnderLineTextInputStyle extends TextInputStyle {
  public size: SizeOptions = {
  };
  public backgroundColor = Color.Transparent;
  public borderRadius = 0;
  public layoutWeight: number = LAYOUT_WEIGHT_1;
  public placeholderColor = $r('sys.color.ohos_id_color_text_hint');
  public placeholderFont: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    family: 'sans-serif',
    weight: FontWeight.Regular,
    style: FontStyle.Normal,
  };
  public caretColor = Color.Blue;
  public padding: Padding = {
    left: '0vp',
  };
}

export class PcUnderLineTextInputStyle extends TextInputStyle {
  public size: SizeOptions = {
    height: $r('app.float.height_36'),
  };
  public backgroundColor = Color.Transparent;
  public borderRadius = 0;
  public layoutWeight: number = LAYOUT_WEIGHT_1;
  public placeholderColor = $r('sys.color.ohos_id_color_text_hint');
  public placeholderFont: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Regular,
    family: 'HarmonyHeiTi',
    style: FontStyle.Normal,
  };
  public caretColor = $r('sys.color.ohos_id_color_text_primary_activated');
  public padding: Padding = {
    left: $r('app.float.margin_0'),
  };
  public margin: Margin = {
    top: $r('app.float.length_13'),
    bottom: $r('app.float.length_13'),
  };
}

export class PcUnderLineTextInputMenuStyle extends TextInputMenuStyle {
  public rootContainer = new PcUnderLineTextInputContainerStyle();
  public textInputStyle = new PcUnderLineTextInputStyle();
}

export class UnderLineTextInputMenuStyle extends TextInputMenuStyle {
  public rootContainer = new UnderLineTextInputContainerStyle();
  public textInputStyle = new UnderLineTextInputStyle();
}

let underLineTextInputMenuStyle = new UnderLineTextInputMenuStyle();

/**
 * 下划线输入菜单数据类
 *
 * @since 2023-01-18
 */
export class UnderLineTextInputMenu extends UnderLineTextInputBaseMenu implements UnderLineTextInputBaseMenuData {
  constructor(menu: Partial<UnderLineTextInputBaseMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = underLineTextInputMenuStyle;
    }
  }
}

export class PasswordUnderLineTextInputMenu extends UnderLineTextInputBaseMenu
implements UnderLineTextInputBaseMenuData {
  constructor(menu: Partial<UnderLineTextInputBaseMenuData>) {
    super(menu);
    this.menuType = MenuType.PSD_UNDERLINE_TEXT_INPUT;
    if (!menu.style) {
      this.style = underLineTextInputMenuStyle;
    }
  }
}

export class PasswordTipTextMenu extends SettingsBaseMenu implements SettingsBaseMenuData {
  constructor(menu: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = 'Text';
    }
  }
}

export class SuHeaderContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    top: '0vp',
    bottom: '0vp',
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '20vp',
  };
  public space: Length = '16vp';
  public verticalAlign = VerticalAlign.Bottom;
}

let suHeaderContainerStyle = new SuHeaderContainerStyle();

export class SuHeaderTitleStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
    weight: FontWeight.Medium,
  }
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public margin: Margin = {
    top: $r('sys.float.ohos_id_text_paragraph_margin_s'),
    bottom: $r('sys.float.ohos_id_text_paragraph_margin_s'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.length_20')
  }
  public maxLines: number = MAX_LINES_6;
}

let suHeaderTitleStyle = new SuHeaderTitleStyle();

export class DefaultSubHeaderStyle extends SubHeaderStyle {
  public rootContainer: ContainerStyle = suHeaderContainerStyle;
  public title: TextStyle = suHeaderTitleStyle;
}

export let defaultSubHeaderStyle = new DefaultSubHeaderStyle();

export class GroupDividerStyle extends DividerStyle {
  public strokeWidth: Length = '1px';
  public color = $r('sys.color.ohos_id_color_list_separator');
  public startMargin: Length = '12vp';
  public endMargin: Length = '12vp';
}

export class GroupSpecifyDividerStyle extends GroupDividerStyle {
  constructor(startMargin?: Length, endMargin?: Length) {
    super();
    this.startMargin = startMargin ?? '12vp';
    this.endMargin = endMargin ?? '12vp';
  }
}

export let groupDividerStyle = new GroupDividerStyle();

export let groupSpecifyDividerStyle = new GroupSpecifyDividerStyle();

export class DividerGroupStyle extends GroupStyle {
  public divider?: GroupDividerStyle = groupDividerStyle;
}

export class DividersGroupStyle extends GroupStyle {
  public divider?: GroupDividerStyle = new GroupDividersStyle();
}

export class GroupDividersStyle extends DividerStyle {
  public strokeWidth: Length = '1px';
  public color = $r('sys.color.ohos_id_color_list_separator');
  public startMargin: Length = '0vp';
  public endMargin: Length = '0vp';
}

export let dividerGroupStyle = new DividerGroupStyle();

let radioListDialogGroupDividerStyle: GroupSpecifyDividerStyle = new GroupSpecifyDividerStyle('24vp', '24vp');

export class RadioListDialogDividerGroupStyle extends GroupStyle {
  public divider = radioListDialogGroupDividerStyle;
  public margin: Margin = {
    bottom: $r('app.float.length_0'),
  };
}

export let radioListDialogDividerGroupStyle: RadioListDialogDividerGroupStyle = new RadioListDialogDividerGroupStyle();

export interface DividerMenuGroupData extends MenuGroupData {}

export class DividerMenuGroup extends MenuGroup {
  constructor(params?: Partial<DividerMenuGroupData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.style) {
      this.style = dividerGroupStyle
    }
  }
}

/**
 * 网格菜单样式数据类
 *
 * @since 2022-06-09
 */
export class GridGroupStyle extends GroupStyle {
  // 默认水平12格
  public columnsTemplate: string = '1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr';
  // 默认垂直1格
  public rowsTemplate: string = '1fr';
}

export class WallpaperGridGroupStyle extends GroupStyle {
  // 默认水平3格
  public columnsTemplate: string = '1fr 1fr 1fr';
  // 默认垂直1格
  public rowsTemplate: string = '1fr';
}

export class ThemeGridGroupStyle extends WallpaperGridGroupStyle {
  // 水平2格
  public columnsTemplate: string = '1fr 1fr';
  // 垂直2格
  public rowsTemplate: string = '1fr 1fr';

  public padding: Padding = {
    top: '0vp',
    bottom: '0vp',
    left: '0vp',
    right: '0vp',
  };
  public size: SizeOptions = {
    width: '100%',
    height: display.isFoldable() ? '335vp' : '345vp',
  };
}

export let gridGroupStyle = new GridGroupStyle();

export interface GridMenuGroupData extends MenuGroupData {}

/**
 * 网格菜单数据类
 *
 * @since 2022-06-09
 */
export class GridMenuGroup extends MenuGroup {
  constructor(params?: Partial<GridMenuGroupData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.style) {
      this.style = gridGroupStyle;
    }
  }
}

export class SpaceHeaderStyle implements Style {
  public space: Length = $r('app.float.length_12');
  public firstVisibleSpace: Length = DeviceUtil.isDevicePc() ? $r('app.float.padding_8') : $r('app.float.padding_16');
}

export class WifiSpaceHeaderStyle implements Style {
  public space: Length = $r('app.float.length_8');
  public firstVisibleSpace: Length = $r('app.float.padding_8');
}

export let wifiSpaceHeaderStyle = new WifiSpaceHeaderStyle();

export let spaceHeaderStyle = new SpaceHeaderStyle();

export interface SpaceMenuData extends SettingsBaseMenuData {}

/**
 * 间距菜单数据类
 *
 * @since 2022-03-21
 */
export class SpaceMenu extends SettingsBaseMenu {
  constructor(menu: Partial<SpaceMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.SPACE;
    }
  }
}

export interface DividerMenuData extends SettingsBaseMenuData {}

/**
 * 分隔器组件数据类
 *
 * @since 2023-06-21
 */
export class DividerMenu extends SettingsBaseMenu implements DividerMenuData {
  constructor(menu?: Partial<DividerMenuData>) {
    super(menu);
    if (menu && !menu.menuType) {
      this.menuType = MenuType.DIVIDER;
    }
  }
}

export interface SpaceHeaderMenuSectionData extends MenuSectionData {
  isNeedSpace: boolean;
}

/**
 * 带间距的菜单段数据类
 *
 * @since 2022-03-21
 */
export class SpaceHeaderMenuSection extends MenuSection {
  public static readonly HEADER_GROUP_KEY_PREFIX: string = '#space_header_group#-';
  public static readonly HEADER_SPACE_KEY_PREFIX: string = '#space_header_space#-';
  public isNeedSpace: boolean = true;

  constructor(params?: Partial<SpaceHeaderMenuSectionData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);

    if (params?.isNeedSpace != undefined && params?.isNeedSpace != null) {
      this.isNeedSpace = params.isNeedSpace;
    }

    let header = new MenuGroup({
      key: SpaceHeaderMenuSection.HEADER_GROUP_KEY_PREFIX + params?.key,
    }, []);
    if (this.isNeedSpace) {
      let spaceMenu = new SpaceMenu({
        key: SpaceHeaderMenuSection.HEADER_SPACE_KEY_PREFIX + params?.key,
        style: (params?.style as CardSectionStyle)?.spaceHeader ?? spaceHeaderStyle,
        controller: {
          createControllerConstructorInter: MenuController.CreateMenuController,
        },
      });
      header.addMenu(spaceMenu);
    }
    this.setHeader(header);
  }
}

export class CardSectionListStyle extends DividerGroupStyle {
  public padding: Padding = {
    top: '4vp',
    bottom: '4vp',
  };
  public clip = true;
  public borderRadius = $r('app.float.menu_group_radius');
  public backgroundColor: ResourceColor = $r('sys.color.comp_background_list_card');
}

export class CardDialogListStyle extends DividerGroupStyle {
  public padding: Padding = {
    top: '4vp',
    bottom: '4vp',
  };
  public margin: Margin = {
    right: $r('sys.float.padding_level10'),
    left: $r('sys.float.padding_level10'),
  };
  public clip = true;
  public borderRadius = $r('sys.float.ohos_id_corner_radius_text_field');
  public backgroundColor: ResourceColor = $r('sys.color.ohos_id_color_card_bg');
}

export class BtCardSectionListStyle extends DividerGroupStyle {
  public padding: Padding = {
    top: '4vp',
    bottom: '4vp',
  };
  public clip = true;
  public borderRadius = '20vp';
  public backgroundColor: ResourceColor = $r('sys.color.ohos_id_color_list_card_bg');
}

export class PaddingCardSectionListStyle extends CardSectionListStyle {
  public padding: Padding = {
    top: $r('app.float.margin_4'),
    bottom: $r('app.float.margin_4'),
    left: $r('app.float.margin_12'),
    right: $r('app.float.margin_12'),
  };
}

export class PaddingImageCardStyle extends CardSectionListStyle {
  public padding: Padding = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
}

export class CardSectionListSpecifyDividerStyle extends CardSectionListStyle {
  constructor(startMargin?: Length, endMargin?: Length) {
    super();
    if (startMargin && endMargin) {
      this.divider = new GroupSpecifyDividerStyle(startMargin, endMargin);
    } else {
      this.divider = groupSpecifyDividerStyle;
    }
  }
}

export class RadioCardSectionListStyle extends DividerGroupStyle {
  public padding: Padding = {
    top: '8vp',
    bottom: '8vp',
  };
  public clip = true;
  public borderRadius = '20vp';
  public backgroundColor: ResourceColor = $r('sys.color.ohos_id_color_foreground_contrary');
}

export let paddingImageCardStyle = new PaddingImageCardStyle();

export let cardSectionListStyle = new CardSectionListStyle();

export let cardDialogListStyle = new CardDialogListStyle();

export let btCardSectionListStyle = new BtCardSectionListStyle();

export let cardSectionListSpecifyDividerStyle = new CardSectionListSpecifyDividerStyle();

export let radioCardSectionListStyle = new RadioCardSectionListStyle();

interface hoverIconSizeData {
  width: string,
  height: string
}

// DialogCardStyle
export class DialogCardStyle extends DividerGroupStyle {
  public listStyle: GroupStyle = cardDialogListStyle;
  public spaceHeader?: SpaceHeaderStyle = spaceHeaderStyle;
  public hoverIconOffset?: Position = {
    x: 0,
    y: -24,
  };
  public hoverIconSize?: hoverIconSizeData = {
    width: '48vp',
    height: '48vp',
  };
  public listSize?: ConstraintSizeOptions
}

export class CardSectionStyle extends DividerGroupStyle {
  public listStyle: GroupStyle = cardSectionListStyle;
  public spaceHeader?: SpaceHeaderStyle = spaceHeaderStyle;
  public hoverIconOffset?: Position = {
    x: 0,
    y: -24,
  };
  public hoverIconSize?: hoverIconSizeData = {
    width: '48vp',
    height: '48vp',
  };
  public listSize?: ConstraintSizeOptions
}
/**
 * 置灰菜单样式
 *
 * @since 2025-08-02
 */
export class ColorGrayMenuGroupStyle extends  CardSectionStyle {
  public backgroundColor?: ResourceColor | Color | Resource = Color.Yellow;
  public padding: Padding = {
    top: '4vp',
    bottom: '4vp',
  }
}

export class ThemeCardSectionStyle extends CardSectionStyle {
  public padding: Padding = {
    top: '0vp',
    bottom: '0vp',
    left: DeviceUtil.isDevicePad() ? $r('app.float.padding_24') : $r('app.float.padding_16'),
    right: DeviceUtil.isDevicePad() ? $r('app.float.padding_24') : $r('app.float.padding_16'),
  };
}

export class WifiCardSectionStyle extends CardSectionStyle {
  public spaceHeader?: SpaceHeaderStyle = wifiSpaceHeaderStyle;
}

export class BtCardSectionStyle extends CardSectionStyle {
  public listStyle: GroupStyle = btCardSectionListStyle;
}

export class ImageCardStyle extends DividerGroupStyle {
  public listStyle: GroupStyle = paddingImageCardStyle;
  public spaceHeader?: SpaceHeaderStyle = spaceHeaderStyle;
}

class NewGroupDividerStyle extends GroupDividerStyle {
  public color = $r('app.color.color_0D000000_grey');
}

class NewCardSectionListStyle extends CardSectionListStyle {
  public divider = new NewGroupDividerStyle();
}

export class NewCardSectionStyle extends GroupStyle {
  public listStyle = new NewCardSectionListStyle();
  public spaceHeader = spaceHeaderStyle;
}

export class CardSectionSpecifyDividerStyle extends CardSectionStyle {
  constructor(startMargin?: Length, endMargin?: Length) {
    super();
    if (startMargin && endMargin) {
      this.listStyle = new CardSectionListSpecifyDividerStyle(startMargin, endMargin);
    } else {
      this.listStyle = cardSectionListSpecifyDividerStyle;
    }
  }
}

export class FirstCardSectionHomeStyle extends CardSectionSpecifyDividerStyle {
  public margin: Margin = {
    top: $r('app.float.length_8'),
    bottom: $r('app.float.length_12'),
  }

  constructor(startMargin?: Length, endMargin?: Length) {
    super(startMargin, endMargin);
  }
}

export class OtherCardSectionHomeStyle extends CardSectionSpecifyDividerStyle {
  public margin: Margin = {
    bottom: $r('app.float.length_12'),
  }

  constructor(startMargin?: Length, endMargin?: Length) {
    super(startMargin, endMargin);
  }
}

export class VolumeCardSectionHomeStyle implements Style {
  public margin: Margin = {
    top: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
    bottom: $r('sys.float.ohos_id_card_margin_middle'),
  };
}

export class TouchCardSectionHomeStyle extends CardSectionStyle {
  public margin: Margin = {
    top: $r('sys.float.ohos_id_card_margin_middle'),
  }
}

export class RadioCardSectionStyle extends DividerGroupStyle {
  public listStyle: GroupStyle = radioCardSectionListStyle;
  public spaceHeader = spaceHeaderStyle;
}

export let cardSectionStyle = new CardSectionStyle();

//  wifi弹框
export let newAddWifiStyle = new DialogCardStyle();

export let btCardSectionStyle = new BtCardSectionStyle();

export let imageCardStyle = new ImageCardStyle();

export interface CardMenuSectionData extends SpaceHeaderMenuSectionData {}

/**
 * 卡片类型的菜单段数据类
 *
 * @since 2022-03-21
 */
export class CardMenuSection extends SpaceHeaderMenuSection {
  constructor(params?: Partial<CardMenuSectionData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (params && !params.style) {
      this.style = cardSectionStyle;
    } else if (params && params?.style) {
      this.style = params?.style
    }
  }
}

export interface PermissionBaseEntryMenuData extends BaseEntryMenuData {
  appIndex?: number;
}

export interface PermissionEntryMenuData extends PermissionBaseEntryMenuData {
  isEnableValid?: boolean;
}

export class PermissionMenu extends SettingsBaseMenu implements PermissionBaseEntryMenuData {
  public appIndex: number = 0;
  public isEnableValid: boolean = true;

  constructor(menu?: Partial<PermissionEntryMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.PERMISSION;
    }
    this.appIndex = menu?.appIndex ?? 0;
    this.isEnableValid = menu?.isEnableValid ?? true;
  }
}

export class ImageCardMenu extends SpaceHeaderMenuSection {
  constructor(params?: Partial<CardMenuSectionData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (params && !params.style) {
      this.style = imageCardStyle;
    }
  }
}

/**
 * 热点二维码数据类
 *
 * @since 2024-03-09
 */
export class QRCodeMenu extends SettingsBaseMenu implements BaseEntryMenuData {
  constructor(menu: Partial<BaseNavigatorEntryMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.WLAN_QRCODE_COMPONENT;
    }
  }
}

export class GroupSuHeaderContainerStyle extends SuHeaderContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    top: FontScaleUtils.isExtraLargeFontMode() ? '16vp' : '0vp',
    bottom: FontScaleUtils.isExtraLargeFontMode() ? '8vp' : '0vp',
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: DeviceUtil.isDevicePc() ? '44vp' : $r('app.float.height_56'),
  };
  public space: Length = '16vp';
  public verticalAlign = VerticalAlign.Bottom;
}

let groupSuHeaderContainerStyle = new GroupSuHeaderContainerStyle();

export class GroupSubHeaderStyle extends DefaultSubHeaderStyle {
  public rootContainer: ContainerStyle = groupSuHeaderContainerStyle;
}

let defaultGroupSubHeaderStyle = new GroupSubHeaderStyle();

export class SubHeaderSectionStyle extends CardSectionStyle {
  public subHeaderStyle?: GroupSubHeaderStyle = defaultGroupSubHeaderStyle;
}

export let subHeaderSectionStyle = new SubHeaderSectionStyle();

export class HeaderSectionStyle extends GroupSubHeaderStyle {
  constructor() {
    super();
    this.title = new SuHeaderTitleStyle();
    this.title.font = {
      size: $r('sys.float.Subtitle_L'),
      weight: FontWeight.Bold,
    }
    this.title.fontColor = $r('sys.color.font_primary');
    this.rootContainer = new GroupSuHeaderContainerStyle();
    this.rootContainer.padding = {
      top: FontScaleUtils.isExtraLargeFontMode() ? '16vp' : '0vp',
      bottom: FontScaleUtils.isExtraLargeFontMode() ? '8vp' : '0vp',
      left: 0,
      right: 0,
    };
  }
}

/**
 * 子标题菜单数据类
 *
 * @since 2022-03-21
 */
export class SubHeaderMenu extends BaseSubHeaderMenu implements BaseSubHeaderMenuData {
  constructor(menu: Partial<BaseSubHeaderMenuData>) {
    super(menu);
  }
}

export class SubHeaderSpaceStyle extends SpaceHeaderStyle {
  public space = $r('app.float.border_radius_0');
  public firstVisibleSpace = $r('app.float.border_radius_0');
}

let subHeaderSpaceStyle = new SubHeaderSpaceStyle();

export interface SubHeaderSectionData extends BaseSubHeaderSectionData {
  spaceStyle: Style;
  subHeaderStyle: Style;
}

/**
 * 带子标题的菜单段数据类
 *
 * @since 2022-03-21
 */
export class SubHeaderSection extends BaseSubHeaderSection {
  public static readonly HEADER_GROUP_KEY_PREFIX: string = '#sub_header_group#-';
  public static readonly HEADER_SPACE_KEY_PREFIX: string = '#sub_header_space#-';
  public static readonly FOOTER_GROUP_KEY_PREFIX: string = '#sub_footer_group#-';
  public static readonly HEADER_SUB_KEY_PREFIX: string = '#sub_header#-';

  constructor(params?: Partial<SubHeaderSectionData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.style) {
      this.style = subHeaderSectionStyle;
    } else {
      this.style = params.style;
    }
    this.setHeader(new MenuGroup({
      key: SubHeaderSection.HEADER_GROUP_KEY_PREFIX + params?.key,
    },
      [
        new SpaceMenu({
          key: SubHeaderSection.HEADER_SPACE_KEY_PREFIX + params?.key,
          style: params?.spaceStyle ?? subHeaderSpaceStyle,
          controller: {
            createControllerConstructorInter: MenuController.CreateMenuController,
          },
        }),
        new SubHeaderMenu({
          key: SubHeaderSection.HEADER_SUB_KEY_PREFIX + params?.key,
          title: params?.title,
          style: params?.subHeaderStyle ?? defaultGroupSubHeaderStyle,
          accessibilityDescription: ResourceUtil.getStringSync($r('app.string.title'))
        })
      ]));
  }
}

export class NoDividerCardSectionListStyle extends CardSectionListStyle {
  public divider = undefined;
}

export let noDividerCardSectionListStyle = new NoDividerCardSectionListStyle();

export class NoDividerSubHeaderSectionStyle extends SubHeaderSectionStyle {
  public listStyle = noDividerCardSectionListStyle;
}

export let noDividerSubHeaderSectionStyle = new NoDividerSubHeaderSectionStyle();

export interface NoDividerSubHeaderSectionData extends SubHeaderSectionData {}

/**
 * 无分割线带子标题的菜单段数据类
 *
 * @since 2022-09-21
 */
export class NoDividerSubHeaderSection extends SubHeaderSection {
  constructor(params?: Partial<NoDividerSubHeaderSectionData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.style) {
      this.style = noDividerSubHeaderSectionStyle;
    }
  }
}

export class SubHeaderLoadingProgressStyle extends LoadingProgressStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public margin: Margin = {
    bottom: '8vp',
  };
}

export class SubHeaderLoadingMenuStyle extends LoadingMenuStyle {
  public rootContainer: ContainerStyle = groupSuHeaderContainerStyle;
  public title: TextStyle = suHeaderTitleStyle;
  public loadingProgressStyle: LoadingProgressStyle = new SubHeaderLoadingProgressStyle();
}

export let subHeaderLoadingMenuStyle = new SubHeaderLoadingMenuStyle();

export interface SubHeaderLoadingMenuData extends BaseLoadingMenuData {
  listenKey?: string;
}

/**
 * 加载子标题菜单数据类
 *
 * @since 2022-03-21
 */
export class SubHeaderLoadingMenu extends LoadingMenu implements SubHeaderLoadingMenuData {
  public listenKey: string;

  constructor(menu: Partial<SubHeaderLoadingMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = subHeaderLoadingMenuStyle;
    }
    this.listenKey = menu.listenKey as string;
  }
}

class SubHeaderLoadingMenuController extends LoadingMenuController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateSubHeaderLoadingMenuController(menu: SettingsBaseMenu): Controller {
    return new SubHeaderLoadingMenuController(menu);
  }

  protected registerDataChange(): void {
    if (this.menu instanceof SubHeaderLoadingMenu) {
      this.registerControllerDataChange(this.menu.listenKey);
    }
  }

  protected unRegisterDataChange(): void {
    if (this.menu instanceof SubHeaderLoadingMenu) {
      this.unRegisterControllerDataChange(this.menu.listenKey);
    }
  }
}

export class LoadingSubHeaderSectionStyle extends CardSectionStyle {
}

export let loadingSubHeaderSectionStyle = new LoadingSubHeaderSectionStyle();

export interface LoadingSubHeaderSectionData extends BaseLoadingSubHeaderSectionData {}

/**
 * 带加载子标题的菜单段数据类
 *
 * @since 2022-03-21
 */
export class LoadingSubHeaderSection extends BaseLoadingSubHeaderSection {
  public static readonly LOADING_HEADER_GROUP_KEY_PREFIX: string = '#loading_sub_header_group#-';
  public static readonly LOADING_HEADER_SPACE_KEY_PREFIX: string = '#loading_sub_header_space#-';
  public static readonly LOADING_HEADER_SUB_KEY_PREFIX: string = '#loading_sub_header#-';

  constructor(params?: Partial<LoadingSubHeaderSectionData>, menus?: Array<SettingsBaseMenu>,
              spaceStyle?: Style, subHeaderLoadingStyle?: Style) {
    super(params, menus);
    if (!params?.style) {
      this.style = loadingSubHeaderSectionStyle;
    }
    this.setHeader(new MenuGroup({
      key: LoadingSubHeaderSection.LOADING_HEADER_GROUP_KEY_PREFIX + params?.key,
    },
      [
        new SpaceMenu({
          key: LoadingSubHeaderSection.LOADING_HEADER_SPACE_KEY_PREFIX + params?.key,
          style: spaceStyle ?? subHeaderSpaceStyle,
          controller: {
            createControllerConstructorInter: MenuController.CreateMenuController,
          },
          menuType: MenuType.SIMPLE_SPACE,
        }),
        new SubHeaderLoadingMenu({
          key: LoadingSubHeaderSection.LOADING_HEADER_SUB_KEY_PREFIX + params?.key,
          title: params?.title,
          style: subHeaderLoadingStyle,
          controller: {
            createControllerConstructorInter: SubHeaderLoadingMenuController.CreateSubHeaderLoadingMenuController,
          },
          listenKey: params?.key,
          menuType: params?.key === 'bluetooth_list_group' ? MenuType.BT_LOADING : undefined,
        })
      ]));
  }
}

export interface WifiSubHeaderSectionData extends SubHeaderSectionData {}

/**
 * Wifi界面带子标题的菜单段数据类
 *
 * @since 2023-08-14
 */
export class WifiSubHeaderSection extends SubHeaderSection {
  constructor(params?: Partial<WifiSubHeaderSectionData>, menus?: Array<SettingsBaseMenu>,
              subHeaderLoadingStyle?: Style) {
    super(params, menus);
    this.setHeader(new MenuGroup({
      key: SubHeaderSection.HEADER_GROUP_KEY_PREFIX + params?.key,
    },
      [
        new SubHeaderMenu({
          key: SubHeaderSection.HEADER_SUB_KEY_PREFIX + params?.key,
          title: params?.title,
          style: params?.subHeaderStyle ?? defaultGroupSubHeaderStyle,
        })
      ]));
    this.setFooter(new MenuGroup({
      key: SubHeaderSection.FOOTER_GROUP_KEY_PREFIX + params?.key,
    },
      [
        new SpaceMenu({
          key: SubHeaderSection.HEADER_SPACE_KEY_PREFIX + params?.key,
          style: params?.spaceStyle ?? subHeaderSpaceStyle,
          controller: {
            createControllerConstructorInter: MenuController.CreateMenuController,
          },
        }),

      ]));
  }
}

export interface WifiLoadingSubHeaderSectionData extends LoadingSubHeaderSectionData {}

/**
 * Wifi界面带加载子标题的菜单段数据类
 *
 * @since 2023-08-14
 */
export class WifiLoadingSubHeaderSection extends LoadingSubHeaderSection {
  constructor(params?: Partial<WifiLoadingSubHeaderSectionData>, menus?: Array<SettingsBaseMenu>,
              subHeaderLoadingStyle?: Style) {
    super(params, menus);
    this.setHeader(new MenuGroup({
      key: LoadingSubHeaderSection.LOADING_HEADER_GROUP_KEY_PREFIX + params?.key,
    },
      [
        new SubHeaderLoadingMenu({
          key: LoadingSubHeaderSection.LOADING_HEADER_SUB_KEY_PREFIX + params?.key,
          title: params?.title,
          style: subHeaderLoadingStyle,
          controller: {
            createControllerConstructorInter: SubHeaderLoadingMenuController.CreateSubHeaderLoadingMenuController,
          },
          listenKey: params?.key,
        })
      ]));
  }
}

export class DefaultListStyle extends GroupStyle {
  public clip = true;
  public borderRadius = $r('sys.float.ohos_id_corner_radius_button');
  public lanes = MAX_LINES_1;
}

export class BlueToothPairDialogListStyle extends GroupStyle {
  public lip = true;
  public borderRadius = '0vp';
  public lanes = MAX_LINES_1;
}

export let defaultListStyle = new DefaultListStyle();

export class DefaultHeaderPageStyle extends HeaderPageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public padding: Padding = {
    top: '0',
    bottom: '0',
    left: DeviceUtil.isDevicePad() ? $r('app.float.padding_24') : $r('app.float.padding_16'),
    right: DeviceUtil.isDevicePad() ? $r('app.float.padding_24') : $r('app.float.padding_16'),
  };
  public backgroundColor = $r('sys.color.ohos_id_color_sub_background');
  public listStyle = defaultListStyle;
  public space = '12vp';
  public pageHeaderStyle = defaultPageHeaderStyle;
}

export class HeaderPageWithoutPaddingStyle extends HeaderPageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public backgroundColor = $r('sys.color.ohos_id_color_sub_background');
  public listStyle = defaultListStyle;
  public space = '12vp';
  public pageHeaderStyle = defaultPageHeaderStyle;
}

export class ProfileHeaderPageStyle extends HeaderPageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public padding: Padding = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_START,
  };
  public backgroundColor = $r('app.color.profile_back_color');
  public listStyle = defaultListStyle;
  public space = $r('app.float.length_12');
  public pageHeaderStyle = defaultPageHeaderStyle;
}

export let defaultHeaderPageStyle = new DefaultHeaderPageStyle();

export let profileHeaderPageStyle = new ProfileHeaderPageStyle();

export class DefaultNavHeaderPageStyle extends HeaderPageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public padding: Padding = {
    top: '0',
    bottom: '0',
    left: DeviceUtil.isDevicePad() ? $r('app.float.padding_24') : $r('app.float.padding_16'),
    right: DeviceUtil.isDevicePad() ? $r('app.float.padding_24') : $r('app.float.padding_16'),
  };
  public backgroundColor = '#F1F3F5';
  public listStyle = defaultListStyle;
  public space = '12vp';
  public pageHeaderStyle = defaultNavPageHeaderStyle;
}

export class PCDefaultNavHeaderPageStyle extends DefaultNavHeaderPageStyle {
  public pageHeaderStyle = pcDefaultNavPageHeaderStyle;
}

export class PCLocationHeaderPageStyle extends DefaultNavHeaderPageStyle {
  public pageHeaderStyle = pcLocationHeaderStyle;
}

export class PCHomeNavHeaderStyle extends DefaultNavHeaderPageStyle {
  public pageHeaderStyle = pcHomeNavPageHeaderStyle;
}

export let defaultNavHeaderPageStyle = new DefaultNavHeaderPageStyle();

export let pcDefaultNavHeaderPageStyle = new PCDefaultNavHeaderPageStyle();

export let pcLocationHeaderPageStyle = new PCLocationHeaderPageStyle();

export interface HeaderPageData extends BaseHeaderPageData {}

/**
 * 带标题的页数据类
 *
 * @since 2022-03-21
 */
export class HeaderPage extends BaseHeaderPage {
  constructor(params?: Partial<HeaderPageData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.style) {
      this.style = defaultHeaderPageStyle;
    }
    if (!params?.navHeaderStyle) {
      this.navHeaderStyle = defaultNavHeaderPageStyle;
    }
  }
}

export interface PCHeaderPageData extends HeaderPageData {}

export class PCHeaderPage extends HeaderPage {
  constructor(params?: Partial<PCHeaderPageData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.navHeaderStyle) {
      this.navHeaderStyle = pcDefaultNavHeaderPageStyle;
    }
    if (!params?.menuType) {
      this.menuType = MenuPageType.PC_HEADER_PAGE;
    }
  }
}

export class DefaultDialogPageStyle extends PageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public padding: Padding = {
    top: '0',
    bottom: '0',
    left: $r('sys.float.ohos_id_card_margin_start'),
    right: $r('sys.float.ohos_id_card_margin_end'),
  };
  public backgroundColor: ResourceColor = $r('sys.color.ohos_id_color_panel_bg');
  public listStyle = defaultListStyle;
  public space = '12vp';
}

/**
 * 无边距弹窗样式：弹窗根组件不设置padding/margin，子组件需自行添加padding/margin
 */
export class DefaultDialogPageNoMarginStyle extends DefaultDialogPageStyle {
  public padding: Padding = NO_PADDING;
  public margin: Margin = NO_MARGIN;
}

export const defaultDialogPageNoMarginStyle = new DefaultDialogPageNoMarginStyle();

export class DefaultPhoneDialogPageStyle extends PageStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public padding: Padding = {
    top: '0',
    bottom: '0',
    left: $r('sys.float.ohos_id_card_margin_start'),
    right: $r('sys.float.ohos_id_card_margin_end'),
  };
  public backgroundColor: ResourceColor = $r('app.color.profile_back_color');
  public listStyle = new BlueToothPairDialogListStyle();
  public space = '12vp';
}

export class PhoneBluetoothDialogPageStyle extends DefaultPhoneDialogPageStyle {
  public rootContainer = new PhoneBluetoothDiaLogContainerStyle();
  public backgroundColor: ResourceColor = $r('app.color.color_bluetooth_dialog');
}

class PhoneBluetoothDiaLogContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_card_margin_start'),
    right: $r('sys.float.ohos_id_card_margin_end'),
  };
  public margin: Margin = {
    bottom: '16vp',
  };
  public backgroundColor: ResourceColor = ('rgba(241,243,245,0.9)'); //弹框颜色
}

class BluetoothDialogRootContainer extends ContainerStyle {
  public size: SizeOptions = {
    width: $r('app.float.length_394'),
  };
}

export class BluetoothDialogPageStyle extends PageStyle {
  public rootContainer = new BluetoothDialogRootContainer();
}

export class PcBluetoothDialogPageStyle extends DefaultDialogPageStyle {
  public rootContainer = new PcBluetoothDiaLogContainerStyle();
  public backgroundColor: ResourceColor = $r('app.color.color_bluetooth_dialog');
  public padding: Padding = {
    top: $r('app.float.length_0'),
    bottom: $r('app.float.length_0'),
    left: $r('app.float.margin_6'),
    right: $r('app.float.margin_6'),
  };
}

class PcBluetoothDiaLogContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '394vp',
  };
}

export class DiaLogContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '394vp',
  };
}

export class DialogPageStyle extends PageStyle {
  public rootContainer = new DiaLogContainerStyle();
}

export let defaultDialogPageStyle = new DefaultDialogPageStyle();

export class RadioListDialogPageStyle extends DefaultDialogPageStyle {
  public padding: Padding = {
    top: '0',
    bottom: '0',
    left: '0',
    right: '0',
  };
}

export let radioListDialogPageStyle: Style = new RadioListDialogPageStyle();

export class USBTipsDialogPageStyle extends PageStyle {
  public padding: Padding = {
    top: $r('app.float.padding_12'),
    bottom: $r('app.float.padding_8'),
    left: $r('app.float.padding_16'),
    right: $r('app.float.padding_16'),
  };

  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public listStyle = defaultListStyle;
}

export let usbTipsDialogPageStyle = new USBTipsDialogPageStyle();

export class ConnectedAPDialogPageStyle extends DefaultDialogPageStyle {
  public padding: Padding = {
    top: $r('app.float.padding_0'),
    bottom: $r('app.float.padding_0'),
    left: $r('app.float.margin_4'),
    right: $r('app.float.margin_4'),
  };
}

export let connectedAPDialogPageStyle: Style = new ConnectedAPDialogPageStyle();

export class ReverseChargeDialogPageStyle extends DefaultDialogPageStyle {
  public padding: Padding = {
    top: $r('app.float.padding_0'),
    bottom: $r('app.float.padding_0'),
    left: $r('app.float.padding_8'),
    right: $r('app.float.padding_8'),
  };
}

export let reverseChargeDialogPageStyle: Style = new ReverseChargeDialogPageStyle();

export interface DialogPageData extends BaseDialogPageData {}

/**
 * 弹框页数据类
 *
 * @since 2022-03-21
 */
export class DialogPage extends BaseDialogPage {
  constructor(params?: Partial<DialogPageData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.style) {
      this.style = defaultDialogPageStyle;
    }
  }

  public setPageStyle(pageStyle: PageStyle): void {
    if (pageStyle) {
      this.pageStyle = pageStyle;
    }
  }
}

export class PcWifiDialogPage extends DialogPage {
  constructor(params?: Partial<DialogPageData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
  }
}

class CardRadioContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '18vp',
    height: '18vp',
  };
  public margin: Margin = {
    right: '16vp',
  };
}

let cardRadioContainerStyle = new CardRadioContainerStyle();

export class RadioTextStyle extends TextStyle {
  public padding: Padding = {
    top: $r('app.float.length_8'),
    bottom: $r('app.float.length_8'),
    left: $r('app.float.length_12'),
    right: $r('app.float.length_0'),
  };
  public fontSize = $r('sys.float.ohos_id_text_size_body1');
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');
}

let radioTextStyle = new RadioTextStyle();

export class DefaultCardRadioMenuStyle extends CardRadioMenuStyle {
  public rootContainer: ContainerStyle = cardRadioContainerStyle;
  public summary: TextStyle = summaryTextStyle;
  public title: TextStyle = radioTextStyle;
  public borderRadius = $r('sys.float.ohos_id_corner_radius_menu');
  public spaceWidth = $r('app.float.length_32');
  public size: SizeOptions = {
    width: WIDTH_50_PERCENT,
    height: $r('app.float.length_120'),
  };
}

export class DefaultDialogCardRadioMenuStyle extends CardRadioMenuStyle {
  public rootContainer: ContainerStyle = cardRadioContainerStyle;
  public summary: TextStyle = summaryTextStyle;
  public title: TextStyle = radioTextStyle;
  public backgroundColor = $r('sys.color.ohos_id_color_background'); //radioMenuItem底色
  public borderRadius = $r('sys.float.ohos_id_corner_radius_menu');
  public spaceWidth = $r('app.float.length_32');
  public size: SizeOptions = {
    width: WIDTH_50_PERCENT,
    height: $r('app.float.length_120'),
  };
}


class RadioContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '20vp',
    height: '20vp',
  };
  // 统一设置radio的右侧外边距为12vp
  public margin: Margin = {
    right: '12vp',
  };
}

let radioContainerStyle = new RadioContainerStyle();

export class DefaultRadioMenuStyle extends DefaultCardRadioMenuStyle {
  public rootContainer: ContainerStyle = radioContainerStyle;
  public summary: TextStyle = summaryTextStyle;
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
}

export let defaultCardRadioMenuStyle = new DefaultCardRadioMenuStyle();

export let defaultRadioMenuStyle = new DefaultRadioMenuStyle();

class CheckboxContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public margin: Margin = {
    right: '12vp',
  };
}

export class CheckboxTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Medium,
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public margin: Margin = {};
  public textAlign?: TextAlign = TextAlign.Start;
}

export class DefaultCheckboxMenuStyle extends CheckboxMenuStyle {
  public rootContainer: ContainerStyle = new CheckboxContainerStyle();
  public summary: TextStyle = summaryTextStyle;
  public title: TextStyle = new CheckboxTextStyle();
  public backgroundColor = $r('sys.color.ohos_id_color_background');
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
    height: $r('app.float.length_48'),
  };
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
  };
  public menuContainerPadding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end'),
  }
}

export let defaultCheckboxMenuStyle = new DefaultCheckboxMenuStyle();

class ImageIconStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public margin: Margin = {
    left: $r('sys.float.ohos_id_text_margin_horizontal'),
  };
  public imageColor: ResourceColor = $r('sys.color.ohos_id_color_emphasize');
}

export class DefaultSelectImageMenuStyle extends SelectImageMenuStyle {
  public imageIcon: ImageStyle = new ImageIconStyle();
  public summary: TextStyle = summaryTextStyle;
  public title: TextStyle = new CheckboxTextStyle();
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end')
  };
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
  };
  public menuContainerPadding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end'),
  }
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
}

export let defaultSelectImageMenuStyle = new DefaultSelectImageMenuStyle();

/**
 * 单选卡片数据类
 *
 * @since 2022-05-25
 */
export class CardRadioMenu extends BaseCardRadioMenu implements BaseCardRadioMenuData {
  constructor(menu: Partial<BaseCardRadioMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultCardRadioMenuStyle;
    }
  }
}

export class EmailRadioMenu extends BaseEmailRadioMenu implements BaseRadioMenuData {
  constructor(menu: Partial<BaseRadioMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = newDefaultRadioMenuStyle;
    }
  }
}

export class IconRadioMenu extends BaseIconRadioMenu implements BaseRadioMenuData {
  constructor(menu: Partial<BaseRadioMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = newDefaultRadioMenuStyle;
    }
  }
}

export class BrowserRadioMenu extends BaseBrowserRadioMenu implements BaseCardRadioMenuData {
  constructor(menu: Partial<BaseCardRadioMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultCardRadioMenuStyle;
    }
  }
}

export class RadioMenu extends BaseRadioMenu implements BaseRadioMenuData {
  constructor(menu: Partial<BaseRadioMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = newDefaultRadioMenuStyle;
    }
  }
}

export class NewSelectStyle extends SelectStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body2'),
  };
  public selectedOptionFont: Font = {
    size: $r('sys.float.ohos_id_text_size_body2'),
  };
  public optionFont: Font = {
    size: $r('sys.float.ohos_id_text_size_body2'),
  };
}

let newSelectStyle = new NewSelectStyle();

/**
 * 默认下拉选择框入口菜单样式
 *
 * @since 2023-02-07
 */
export class DefaultSelectEntryMenuStyle extends SelectEntryMenuStyle {
  public rootContainer: ContainerStyle = FontScaleUtils.getCurrentTopPadding() === rootContainerStyle.padding.top ?
    rootContainerStyle : new RootContainerStyle();
  public iconImage: ImageStyle = iconImageStyle;
  public title: TextStyle = titleTextStyle;
  public summary: TextStyle = summaryTextStyle;
  public state: TextStyle = stateTextStyle;
  public stateIcon: ImageStyle = stateIconStyle;
  public newInfoImage: ImageStyle = newInfoImageStyle;
  public selectStyle: SelectStyle = newSelectStyle;
  public startFlexShrink: number = START_FLEX_SHRINK_0;
  public endFlexShrink: number = END_FLEX_SHRINK_1;
}

let defaultSelectEntryMenuStyle = new DefaultSelectEntryMenuStyle();

/**
 * 下拉选择框入口菜单数据类
 *
 * @since 2023-02-07
 */
export class SelectEntryMenu extends BaseSelectEntryMenu implements BaseSelectEntryMenuData {
  constructor(menu: Partial<BaseSelectEntryMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = defaultSelectEntryMenuStyle;
    }
  }
}

class DefaultCheckboxOptionStyle extends BaseCheckboxOptionStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_48'),
  };
  public margin: Margin = {
    left: $r('app.float.margin_4'),
    right: $r('app.float.margin_4'),
  };
  public padding: Padding = {
    left: $r('app.float.margin_4'),
    right: $r('app.float.margin_4'),
  }
  public borderRadius = $r('sys.float.corner_radius_level6');
  public titleStyle: TextStyle = titleTextStyle;
  public summaryStyle: TextStyle = summaryTextStyle;
}

export class CheckboxOptionMenu extends BaseCheckboxOptionMenu {
  constructor(menu: Partial<BaseCheckboxOptionMenuData>) {
    super(menu);
    if (!this.style) {
      this.style = new DefaultCheckboxOptionStyle();
    }
  }
}

/**
 * 多选框列表菜单数据类
 */
export class SelectImageMenu extends BaseCheckboxMenu implements BaseCheckboxMenuData {
  constructor(menu: Partial<MultiCheckboxMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = new DefaultSelectImageMenuStyle();
    }
    if (!menu?.menuType) {
      this.menuType = MenuType.SELECT_IMAGE;
    }
  }
}

/**
 * 多选框菜单数据类
 */
export class CheckboxMenu extends BaseCheckboxMenu implements BaseCheckboxMenuData {
  constructor(menu: Partial<BaseCheckboxMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = new DefaultEntryMenuStyle();
    }
  }
}

/**
 * Pc弹窗多选框菜单数据类
 */
export class PcCheckboxDialogMenu extends BaseCheckboxMenu implements BaseCheckboxMenuData {
  constructor(menu: Partial<BaseCheckboxMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = new DefaultEntryMenuStyle();
    }
    if (!menu?.menuType) {
      this.menuType = MenuType.CHECKBOX_DIALOG_PC;
    }
  }
}

/**
 * Phone弹窗多选框菜单数据类
 */
export class PhoneCheckboxDialogMenu extends BaseCheckboxMenu implements BaseCheckboxMenuData {
  constructor(menu: Partial<BaseCheckboxMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = new DefaultEntryMenuStyle();
    }
    if (!menu?.menuType) {
      this.menuType = MenuType.CHECKBOX_DIALOG_PHONE;
    }
  }
}


/**
 * 带时间的按钮菜单数据类
 */
export class ButtonWithTimeMenu extends BaseButtonWithVariableTitleMenu
implements BaseButtonWithVariableTitleMenuData {
  constructor(menu: Partial<BaseButtonWithVariableTitleMenuData>) {
    super(menu);
    if (!menu.style) {
      this.style = new DefaultEntryMenuStyle();
    }
  }
}

/**
 * underLine textInput style
 */
export class UnderLineEditTextInputStyle extends TextInputStyle {
  public fontColor = $r('sys.color.ohos_id_color_text_primary');
  public fontSize: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Regular,
  };
  public backgroundColor = Color.Transparent;
  public borderRadius = $r('app.float.border_radius_0');
  public padding: Padding = {
    left: $r('app.float.padding_16'),
    right: $r('app.float.padding_0'), // 需要显式设置为0，否则会和left同值
    bottom: $r('app.float.padding_0'),
    top: $r('app.float.padding_0')
  };
  public margin: Margin = {
    left: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
  public textAlign = TextAlign.End;
  public constraintSize: ConstraintSizeOptions = {
    maxWidth: MAX_WIDTH_60_PERCENT,
  };
  public maxLength = MAX_LENGTH_128;
}

/**
 * underline password textinput style
 */
export class UnderLinePasswordEditTextInputStyle extends UnderLineEditTextInputStyle {
  public inputType = InputType.Password;
}

/**
 * underline textinput summary style
 */
export class UnderLineEditSummaryStyle extends TitleTextStyle {
  public padding: Padding = {
    top: $r('app.float.length_14'),
    bottom: $r('app.float.length_13'),
  };
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Medium,
  };
  public constraintSize: ConstraintSizeOptions = {
    maxWidth: MIN_WIDTH_40_PERCENT,
  };
  public overflow = TextOverflow.Ellipsis;
  public maxLength = MAX_LENGTH_128;
}

let underLineEditSummaryStyle: UnderLineEditSummaryStyle = new UnderLineEditSummaryStyle();

let newDefaultTextInputRootContainer: TextInputContainerStyle = new TextInputContainerStyle();

/**
 * underline input box style
 */
export class UnderLineEditMenuStyle extends TextInputMenuStyle {
  public rootContainer = new TextInputContainerStyle();
  public summaryStyle = underLineEditSummaryStyle;
  public textInputStyle = new UnderLineEditTextInputStyle();
}

let underLineEditMenuStyle: UnderLineEditMenuStyle = new UnderLineEditMenuStyle();

/**
 * pc underline textInput style
 */
export class PCUnderLineEditTextInputStyle extends UnderLineEditTextInputStyle {
  public maxLength = 10240;
}

/**
 * pc underline input box style
 */
export class PCUnderLineEditMenuStyle extends TextInputMenuStyle {
  public rootContainer = newDefaultTextInputRootContainer;
  public summaryStyle = underLineEditSummaryStyle;
  public textInputStyle = new PCUnderLineEditTextInputStyle();
}

/**
 * phone underline textInput style
 */
export class PhoneUnderLineEditTextInputStyle extends UnderLineEditTextInputStyle {
  public fontSize: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
    weight: FontWeight.Regular,
  };
  public placeholderFont: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
    weight: FontWeight.Regular,
  };
  public maxLength = 10240;
}

/**
 * phone underline input box style
 */
export class PhoneUnderLineEditMenuStyle extends TextInputMenuStyle {
  public rootContainer = newDefaultTextInputRootContainer;
  public summaryStyle = underLineEditSummaryStyle;
  public textInputStyle = new PhoneUnderLineEditTextInputStyle();
}

/**
 * underLine password textInput menu style
 */
export class UnderLinePasswordEditMenuStyle extends TextInputMenuStyle {
  public rootContainer = newDefaultTextInputRootContainer;
  public summaryStyle = underLineEditSummaryStyle;
  public textInputStyle = new UnderLinePasswordEditTextInputStyle();
}

/**
 * underline password textinput style
 */
class UnderLineNumEditTextInputStyle extends UnderLineEditTextInputStyle {
  public inputType = InputType.Number;
}

/**
 * underline textinput num style
 */
export class UnderLineNumEditMenuStyle extends TextInputMenuStyle {
  public rootContainer = new TextInputContainerStyle();
  public summaryStyle = underLineEditSummaryStyle;
  public textInputStyle = new UnderLineNumEditTextInputStyle();
}

export let underLineNumEditMenuStyle: UnderLineNumEditMenuStyle = new UnderLineNumEditMenuStyle();

export interface UnderLineEditMenuData extends BaseTextInputMenuData {}

/**
 * underline textInput menu initial
 */
export class UnderLineEditMenu extends BaseTextInputMenu implements UnderLineEditMenuData {
  constructor(menu: Partial<UnderLineEditMenuData>) {
    super(menu);
    if (!menu.menuType) {
      this.menuType = MenuType.UNDERLINE_EDIT;
    }

    if (!menu.style) {
      this.style = underLineEditMenuStyle;
    }
  }
}

export class UnderLineEditMenuEx extends UnderLineEditMenu {
  constructor(menu: Partial<UnderLineEditMenuData>) {
    super(menu);
    if (!menu.style) {
      let customStyle: UnderLineEditMenuStyle = new UnderLineEditMenuStyle();
      customStyle.rootContainer.constraintSize.minHeight = $r('app.float.height_48');
      customStyle.textInputStyle.placeholderColor = $r('sys.color.font_tertiary');
      this.style = customStyle;
    }
  }
}

/**
 * 新菜单辅助文本样式
 *
 */
export class NewInputTextSummaryStyle extends TitleTextStyle {
  public padding: Padding = {
    top: $r('app.float.length_24'),
    bottom: $r('app.float.length_4'),
  };
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Regular,
  };
}

let newDefaultTextInputSummaryStyle: NewInputTextSummaryStyle = new NewInputTextSummaryStyle();

/**
 * 菜单标题样式
 *
 */
export class NewTextInputStyle extends TextInputStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public fontSize: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
    weight: FontWeight.Regular,
  };
  public backgroundColor = Color.Transparent;
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '56vp',
  };
  public borderRadius?: Length | undefined = 0;
  public maxLength = MAX_LENGTH_128;
  public padding: Padding = {
    left: $r('app.float.padding_0'),
  };
  public margin: Margin = {
    left: $r('app.float.margin_0'),
  };
}

export class DevicesNameTextInputStyle extends NewTextInputStyle {
  public maxLength = SPACE_LENGTH_30;
}

let newDefaultTextInputStyle: NewTextInputStyle = new NewTextInputStyle();

/**
 * 分割线样式
 */
export class TextDividerStyle extends BaseStyle {
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
    height: $r('app.float.length_1'),
  };
  public backgroundColor = $r('sys.color.ohos_id_color_subheading_separator');
}

let newDefaultTextInputDividerStyle: TextDividerStyle = new TextDividerStyle();

export class NewDefaultTextInputMenuStyle extends TextInputMenuStyle {
  public rootContainer = newDefaultTextInputRootContainer;
  public summaryStyle = newDefaultTextInputSummaryStyle;
  public textInputStyle = newDefaultTextInputStyle;
  public stateStyle = titleTextStyle;
  public dividerStyle = newDefaultTextInputDividerStyle;
}

export class DevicesNameTextInputMenuStyle extends NewDefaultTextInputMenuStyle {
  public textInputStyle = new DevicesNameTextInputStyle();
}

export let newDefaultTextInputMenuStyle: NewDefaultTextInputMenuStyle = new NewDefaultTextInputMenuStyle();

export let devicesNameTextInputMenuStyle: DevicesNameTextInputMenuStyle = new DevicesNameTextInputMenuStyle();

export class NewNumTextInputStyle extends NewTextInputStyle {
  public inputType = InputType.Number;
}

let newNumTextInputStyle: NewNumTextInputStyle = new NewNumTextInputStyle();

export class NewNumDefaultTextInputMenuStyle extends NewDefaultTextInputMenuStyle {
  public textInputStyle = newNumTextInputStyle;
}

export let newNumDefaultTextInputMenuStyle: NewNumDefaultTextInputMenuStyle = new NewNumDefaultTextInputMenuStyle();

/**
 * password textInput style
 */
export class NewPasswordInputStyle extends PasswordInputStyle {
  public backgroundColor: ResourceColor | Color = Color.Transparent;
  public padding: Padding = {
    left: $r('app.float.padding_0'),
  };
  public margin: Margin = {
    left: $r('app.float.margin_0'),
  };
}
export class WifiPasswordInputContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_56')
  };
  public margin: Margin = {
    top: $r('sys.float.padding_level0'),
    bottom: $r('sys.float.padding_level0'),
    left: $r('sys.float.padding_level6'),
    right: $r('sys.float.padding_level6'),
  };
}

export class BiometricsInputContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_56')
  };
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
    left: $r('app.float.margin_8'),
    right: $r('app.float.margin_8'),
  };
}

export class BiometricsPasswordInputStyle extends PasswordInputStyle {
  public backgroundColor: ResourceColor | Color = Color.Transparent;
  public padding: Padding = {
    left: $r('app.float.padding_4'),
  };
  public margin: Margin = {
    left: $r('app.float.margin_0'),
    top: $r('app.float.margin_4')
  };
  public caretColor = $r('sys.color.font_emphasize');
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_48')
  };
  public enableAutoFill: boolean = false;
}

export class NewPasswordInputMenuStyle extends PasswordInputMenuStyle {
  public rootContainer = new PasswordInputContainerStyle();
  public textInputStyle = new NewPasswordInputStyle();
}

export class NewPasswordTextInputStyle extends PasswordInputMenuStyle {
  public textInputStyle = new NewPasswordInputStyle();
  public dividerStyle = newDefaultTextInputDividerStyle;
}

export class BiometricsPasswordTextInputStyle extends PasswordInputMenuStyle {
  public textInputStyle = new BiometricsPasswordInputStyle();
  public dividerStyle = newDefaultTextInputDividerStyle;
  public rootContainer = new BiometricsInputContainerStyle();
}

/**
 * new subHeader title style
 */
export class NewSubHeaderTitleStyle extends SuHeaderTitleStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
    weight: FontWeight.Medium,
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public padding: Padding = {
    top: $r('app.float.length_19_5'),
    bottom: $r('app.float.length_9'),
  };
  public margin: Margin = {
    bottom: $r('app.float.margin_0'),
  };
}

let newSubHeaderTitleStyle: NewSubHeaderTitleStyle = new NewSubHeaderTitleStyle();

export class NewDefaultSubHeaderStyle extends SubHeaderStyle {
  public rootContainer: ContainerStyle = suHeaderContainerStyle;
  public title: TextStyle = newSubHeaderTitleStyle;
}

/**
 * new subHeader title style
 */
export class PcSubHeaderTitleStyle extends NewSubHeaderTitleStyle {
  public padding: Padding = {
    bottom: $r('app.float.length_8'),
    top: $r('app.float.length_19'),
  };
}

export class PCNewDefaultSubHeaderStyle extends SubHeaderStyle {
  public rootContainer: ContainerStyle = suHeaderContainerStyle;
  public title: TextStyle = new PcSubHeaderTitleStyle();
}

/**
 * new subHeader space style
 */
export class NewSubHeaderSpaceStyle extends SpaceHeaderStyle {
  public space = $r('app.float.length_0');
  public firstVisibleSpace = $r('app.float.length_0');
}

export class DefaultSelectStyle extends SelectStyle {
  public selectedOptionBgColor = Color.Transparent;
  public optionBgColor = Color.Transparent;
  public selectedOptionFontColor = $r('sys.color.ohos_id_color_text_primary');
  public align = Alignment.End;
  public margin: Padding = {
    left: 0,
    right: '-8vp' // 抵消select默认内padding.
  };
  public padding: Padding = {
    left: 0,
    right: 0
  };
  public borderRadius = $r('sys.float.ohos_id_corner_radius_notification');
}

let defaultSelectStyle: DefaultSelectStyle = new DefaultSelectStyle();

export class NewSelectEntryMenuStyle extends DefaultSelectEntryMenuStyle {
  public selectStyle: SelectStyle = defaultSelectStyle;
}

export let newSelectEntryMenuStyle: NewSelectEntryMenuStyle = new NewSelectEntryMenuStyle();

/**
 * wifi connected menu rootContainer style
 */
class ConnectedMenuRootContainer extends ContainerStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_list_card_bg');
  public size: SizeOptions = {
    width: $r('app.float.width_394'),
  };
  public borderRadius = $r('sys.float.ohos_id_corner_radius_dialog');
  public constraintSize: ConstraintSizeOptions = {
    maxHeight: MAX_HEIGHT_90_PERCENT,
  };
}

class BrowserDialogRootContainer extends ContainerStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_list_card_bg');
  public size: SizeOptions = {
    width: $r('app.float.width_400'),
  };
  public borderRadius = $r('app.float.border_radius_32');
  public constraintSize: ConstraintSizeOptions = {
    maxHeight: MAX_HEIGHT_90_PERCENT,
  };
}

/**
 * wifi connect menu rootContainer style
 */
class ConnectMenuRootContainer extends ContainerStyle {
  public size: SizeOptions = {
    width: $r('app.float.width_400'),
  };
  public borderRadius = $r('app.float.border_radius_16');
}

/**
 * wifi connect menu pageList style
 */
class ConnectMenuPageListStyle extends GroupStyle {
  public divider = groupDividerStyle;
  public padding: Padding = {
    top: $r('app.float.padding_0'),
    bottom: $r('app.float.padding_0'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
}

let connectMenuRootContainer: ConnectMenuRootContainer = new ConnectMenuRootContainer();

let connectedMenuRootContainer: ConnectedMenuRootContainer = new ConnectedMenuRootContainer();

let browserDialogRootContainer: BrowserDialogRootContainer = new BrowserDialogRootContainer();


class ConnectMenuPageStyle extends PageStyle {
  public rootContainer = connectMenuRootContainer;
  public listStyle = new ConnectMenuPageListStyle();
}

class ConnectedMenuPageStyle extends PageStyle {
  public rootContainer = connectedMenuRootContainer;
  public listStyle = new ConnectMenuPageListStyle();
}

class BrowserDialogPageStyle extends PageStyle {
  public rootContainer = browserDialogRootContainer;
}

class BioPasswordMenuPageStyle extends PageStyle {
  public rootContainer = connectedMenuRootContainer;
}

export let connectMenuPageStyle: ConnectMenuPageStyle = new ConnectMenuPageStyle();

export let connectedMenuPageStyle: ConnectedMenuPageStyle = new ConnectedMenuPageStyle();

export let browserDialogPageStyle: BrowserDialogPageStyle = new BrowserDialogPageStyle();

export let bioPasswordMenuPageStyle: BioPasswordMenuPageStyle = new BioPasswordMenuPageStyle();

export class NewDefaultButtonMenuRootContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
  };
  public gridGutter = $r('sys.float.padding_level8');
  public gridMargin = $r('sys.float.padding_level6');
}

export class ConnectedButtonMenuRootContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
  };
  public gridGutter = $r('sys.float.padding_level8');
  public gridMargin = $r('sys.float.padding_level6');
}

export class BrowserButtonMenuRootContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
  };
  public gridGutter = $r('app.float.length_16');
  public gridMargin = $r('app.float.length_16');
}

export class BrowserButtonMenuRootContainerPadding extends ContainerStyle {
  public padding: Padding = {
    left: $r('app.float.length_16'),
    right: $r('app.float.length_16'),
  };
}

/**
 * new default button style
 */
export class NewDefaultButtonMenuStyle implements Style {
  public rootContainer: ContainerStyle = new NewDefaultButtonMenuRootContainerStyle();
  public buttonStyle1 = new DefaultButtonStyle();
  public buttonStyle2 = new DefaultButtonStyle();
  public buttonStyle3 = new EmphasizeButtonStyle();
}

export let newDefaultButtonMenuStyle: NewDefaultButtonMenuStyle = new NewDefaultButtonMenuStyle();

/**
 * new connected AP button style
 */
export class ConnectedButtonMenuStyle implements Style {
  public rootContainer: ContainerStyle = new ConnectedButtonMenuRootContainerStyle();
  public buttonStyle1 = new DefaultPasswordButtonStyle();
  public buttonStyle2 = new DefaultPasswordButtonStyle();
  public buttonStyle3 = new PasswordEmphasizeButtonStyle();
}

export class BrowserButtonMenuStyle implements Style {
  public rootContainer: ContainerStyle = new BrowserButtonMenuRootContainerStyle();
  public menuContainerPadding: ContainerStyle = new BrowserButtonMenuRootContainerPadding();
  public buttonStyle1 = new DefaultButtonStyle();
  public buttonStyle2 = new DefaultButtonStyle();
  public buttonStyle3 = new EmphasizeButtonStyle();
}

export class PasswordButtonMenuRootContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
  };
  public gridGutter = $r('app.float.length_16');
  public gridMargin = $r('app.float.length_9');
}

export class PasswordButtonMenuStyle implements Style {
  public rootContainer: ContainerStyle = new PasswordButtonMenuRootContainerStyle();
  public buttonStyle1 = new DefaultPasswordButtonStyle();
  public buttonStyle2 = new DefaultPasswordButtonStyle();
  public buttonStyle3 = new PasswordEmphasizeButtonStyle();
}

export class DisableOldPasswordButtonMenuStyle implements Style {
  public rootContainer: ContainerStyle = new PasswordButtonMenuRootContainerStyle();
  public buttonStyle1 = new DefaultPasswordButtonStyle();
  public buttonStyle2 = new DefaultPasswordButtonStyle();
  public buttonStyle3 = new DefaultDisableOldPasswordButtonStyle();
}

export let passwordButtonMenuStyle: PasswordButtonMenuStyle = new PasswordButtonMenuStyle();

export let disableOldPasswordButtonMenuStyle: DisableOldPasswordButtonMenuStyle =
  new DisableOldPasswordButtonMenuStyle();

export let connectedButtonMenuStyle: ConnectedButtonMenuStyle = new ConnectedButtonMenuStyle();

export let browserButtonMenuStyle: BrowserButtonMenuStyle = new BrowserButtonMenuStyle();

class NewTransparentButtonStyle extends TransparentButtonStyle {
  public backgroundColor = $r('app.color.transparent');
  public fontColor = $r('sys.color.ohos_id_color_text_primary_activated');
  public margin: Margin = {
    top: $r('app.float.margin_8'),
    bottom: $r('app.float.margin_16'),
  };
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
    height: $r('app.float.height_40'),
  };
}

class NewTransparentButtonMenuStyle extends DefaultButtonMenuStyle {
  public buttonStyle1 = new NewTransparentButtonStyle();
}

export let newTransparentButtonMenuStyle: NewTransparentButtonMenuStyle = new NewTransparentButtonMenuStyle();

class TransparentButtonMenuForRadioListDialogStyle extends NewTransparentButtonMenuStyle {
  public menuContainerPadding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end'),
  };
}

export let transparentButtonMenuForRadioListDialogStyle:
  TransparentButtonMenuForRadioListDialogStyle = new TransparentButtonMenuForRadioListDialogStyle;

/**
 * 菜单标题样式
 */
export class CenterTitleTextStyle extends TitleTextStyle {
  public textAlign = TextAlign.Center;
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Regular,
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.length_21'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_24'),
    bottom: $r('app.float.margin_0'),
  }
}

export class NewDefaultStatContainerStyle extends ContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.length_48'),
  };
  public verticalAlign = VerticalAlign.Center;
  public horizontalAlign = HorizontalAlign.Center;
  public justifyContent = FlexAlign.Center;
}

/**
 * 默认状态展示菜单样式类
 *
 */
export class NewDefaultStateMenuStyle extends DefaultStateMenuStyle {
  public title = new CenterTitleTextStyle();
  public rootContainer = new NewDefaultStatContainerStyle();
}

export let newDefaultStateMenuStyle: NewDefaultStateMenuStyle = new NewDefaultStateMenuStyle();

export let newPasswordTextInputStyle: BiometricsPasswordTextInputStyle = new BiometricsPasswordTextInputStyle();

/**
 * 分割线样式
 */
export class EditTextDividerStyle extends TextDividerStyle {
  public backgroundColor = $r('sys.color.ohos_id_color_focused_content_primary');
}

export class FocusDefaultTextInputMenuStyle extends NewDefaultTextInputMenuStyle {
  public dividerStyle = new EditTextDividerStyle();
}

export let focusDefaultTextInputMenuStyle: FocusDefaultTextInputMenuStyle = new FocusDefaultTextInputMenuStyle();

export class RadioTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Medium
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines: number = MAX_LINES_10;
}

export class RadioSummaryTextStyle extends SummaryTextStyle {
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
    weight: FontWeight.Regular
  };
}

export class SummaryRadioStyle extends CardRadioMenuStyle {
  public rootContainer: ContainerStyle = new RadioContainerStyle();
  public title: TextStyle = new TitleTextStyle();
  public summary: TextStyle = new RadioSummaryTextStyle();
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
    height: $r('app.float.height_64'),
  };
}

class AppDividerStyle extends GroupDividerStyle {
  public startMargin: Length = $r('app.float.length_68');
}

export class AppCardSectionListStyle extends CardSectionListStyle {
  public divider = new AppDividerStyle();
  public padding: Padding = {
    top: '4vp',
    bottom: '4vp',
  };
}

export class AppCardSectionStyle extends CardSectionStyle {
  public listStyle = new AppCardSectionListStyle();
}

export let appCardSectionStyle: AppCardSectionStyle = new AppCardSectionStyle();

export let appCardSectionListStyle: AppCardSectionListStyle = new AppCardSectionListStyle();

export class EapPasswordInputStyle extends PasswordInputStyle {
  public backgroundColor: ResourceColor | Color = Color.Transparent;
  public padding: Padding = {
    left: $r('app.float.padding_4'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public margin: Margin = {
    // 负边距让眼睛图标跟下划线保持一致
    right: -12,
    top: $r('app.float.margin_8'),
  };
  public enableAutoFill: boolean = false;
}

export class EapPasswordTextDividerStyle extends BaseStyle {
  public size: SizeOptions = {
    width: 'calc(100% - 10vp)',
    height: $r('app.float.length_1'),
  };
  public backgroundColor = $r('sys.color.ohos_id_color_subheading_separator');
}

export class EapPasswordTextInputStyle extends PasswordInputMenuStyle {
  public textInputStyle = new EapPasswordInputStyle();
  public dividerStyle = new EapPasswordTextDividerStyle();
  public rootContainer = new WifiPasswordInputContainerStyle();
}

export let eapPasswordTextInputStyle: EapPasswordTextInputStyle = new EapPasswordTextInputStyle();

export class NoTitleSuHeaderContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
  };
  public padding: Padding = {
    top: $r('app.float.padding_0'),
    bottom: $r('app.float.padding_0'),
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.length_12'),
  };
}

export class NoTitleSubHeaderStyle extends SubHeaderStyle {
  public rootContainer: ContainerStyle = new NoTitleSuHeaderContainerStyle();
}

export let noTitleSubHeaderStyle: NoTitleSubHeaderStyle = new NoTitleSubHeaderStyle();

export let underLinePasswordEditMenuStyle: UnderLinePasswordEditMenuStyle = new UnderLinePasswordEditMenuStyle();

export class NotClickableSelectStyle extends DefaultSelectStyle {
  public fontColor = $r('sys.color.ohos_id_color_text_tertiary');
  public enabled = false;
}

export class NewRadioTextStyle extends TextStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public font: Font = {
    weight: FontWeight.Medium,
    size: $r('sys.float.ohos_id_text_size_sub_title2'),
  };
  public fontColor = $r('sys.color.ohos_id_color_text_primary');
  public padding: Padding = {
    top: $r('app.float.length_13'),
    bottom: $r('app.float.length_14'),
    left: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    right: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
  };
}

class NewRadioContainerStyle extends ContainerStyle {
  public size: SizeOptions = (DeviceUtil.isDevicePhone()) ?
    { width: $r('app.float.length_20'), height: $r('app.float.length_20') } :
    { width: $r('app.float.length_24'), height: $r('app.float.length_24') };
}

export class NewDefaultRadioMenuStyle extends DefaultRadioMenuStyle {
  public title: TextStyle = new NewRadioTextStyle();
  public rootContainer: ContainerStyle = new NewRadioContainerStyle();
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
}

export let newDefaultRadioMenuStyle: NewDefaultRadioMenuStyle = new NewDefaultRadioMenuStyle();

// DialogRadio样式
export class DefaultDialogRadioMenuStyle extends DefaultDialogCardRadioMenuStyle {
  public rootContainer: ContainerStyle = radioContainerStyle;
  public summary: TextStyle = summaryTextStyle;
  public size: SizeOptions = {
    width: WIDTH_100_PERCENT,
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
}

export class NewDialogDefaultRadioMenuStyle extends DefaultDialogRadioMenuStyle {
  public title: TextStyle = new NewRadioTextStyle();
  public rootContainer: ContainerStyle = new NewRadioContainerStyle();
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
}

export class DialogRadioMenuStyle extends NewDialogDefaultRadioMenuStyle {
  public menuContainerPadding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end'),
  };
}

export let dialogRadioMenuStyle: DialogRadioMenuStyle = new DialogRadioMenuStyle();

export class RadioMenuGroupDividerStyle extends GroupDividerStyle {
  public strokeWidth: Length = $r('app.float.length_1');
}

export class RadioMenuDividerGroupStyle extends GroupStyle {
  public divider = new RadioMenuGroupDividerStyle();
}

export let radioMenuDividerGroupStyle: RadioMenuDividerGroupStyle = new RadioMenuDividerGroupStyle();

export class NewTitleTextStyle extends TitleTextStyle {
  public wordBreak: WordBreak = WordBreak.BREAK_ALL;
}

export class SingleSelectMenuItem {
  public title?: ResourceStr;
  public isSelect?: boolean;
  public key?: number | string;
  public menuListItem?: ResourceStr;
}

export interface SingleChoiceEntryMenuData extends BaseEntryMenuData {
  selectIcon?: Resource;
  singleChoiceData?: SingleSelectMenuItem[];
}

export class SingleChoiceEntryMenu extends EntryMenu implements SingleChoiceEntryMenuData {
  public selectIcon?: Resource;
  public singleChoiceData?: SingleSelectMenuItem[];

  constructor(menu: Partial<SingleChoiceEntryMenuData>) {
    super(menu);
    this.singleChoiceData = menu.singleChoiceData as SingleSelectMenuItem[];
    this.selectIcon = menu.selectIcon as Resource;
    if (!menu?.menuType) {
      this.menuType = MenuType.SELECT;
    }
  }
}

class SingleChoiceEntryContainer extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_56'),
  };
}

class SingleChoiceRootContainer extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_56'),
  };
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
    top: $r('app.float.padding_4'),
    bottom: $r('app.float.padding_4'),
  };
}

export class SingleChoiceMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new SingleChoiceEntryContainer();
  public singleChoiceRootContainer: ContainerStyle = new SingleChoiceRootContainer();
  public menuItemWidth: Length = $r('app.float.length_224');
  public menuItemHeight: Length = $r('app.float.length_48');
  public menuItemIconSize: Length = $r('app.float.length_24');
  public menuItemIconMargin: Length = $r('app.float.margin_8');
  public menuItemPaddingLeft: Length = $r('app.float.padding_16');
  public menuItemPaddingRight: Length = $r('app.float.padding_24');
  public placement: Placement = Placement.BottomRight;
  public dividerWidth: string = '0.5vp';
  public dividerColor: Resource = $r('sys.color.ohos_id_color_list_separator');
}

export class SingleChoiceMenuOnlyStyle extends SingleChoiceMenuStyle {
  public stateIcon: ImageStyle = stateIconWifiStyle;
  public selectIconColor = $r('sys.color.ohos_id_color_primary')
}

export class PrivacySingleChoiceMenuStyle extends DefaultEntryMenuStyle {
  public menuItemWidth: Length = $r('app.float.length_224');
  public menuItemHeight: Length = $r('app.float.length_48');
  public menuItemIconSize: Length = $r('app.float.length_24');
  public menuItemIconMargin: Length = $r('app.float.margin_8');
  public menuItemPaddingLeft: Length = $r('app.float.padding_12');
  public menuItemPaddingRight: Length = $r('app.float.padding_12');
  public stateIcon: ImageStyle = stateIconWifiStyle;
  public placement: Placement = Placement.BottomRight;
  public dividerWidth: string = '0.5vp';
  public dividerColor: Resource = $r('sys.color.ohos_id_color_list_separator');
}

/**
 * 禁用功能消息主体提示样式
 *
 */
export class ForbiddenRootContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '36vp',
  };
}

let forbiddenRootContainerStyle = new ForbiddenRootContainerStyle();

/**
 * 禁用功能消息标题样式
 *
 */
export class ForbiddenTitleStyle extends TitleTextStyle {
  public padding: Padding = {
    bottom: $r('app.float.padding_8'),
  };
  public fontColor: ResourceColor = Color.Black;
}

let forbiddenTitleStyle = new ForbiddenTitleStyle();

export class DateForbiddenTitleStyle extends TitleTextStyle {
  public margin: Margin = {
    bottom: $r('app.float.padding_8'),
  };
  public fontColor: ResourceColor = Color.Black;
}

let dateForbiddenTitleStyle = new DateForbiddenTitleStyle();

/**
 * 禁用功能提示外部卡片样式
 */
export class ForbiddenCardStyle extends CardSectionListStyle {
  public backgroundColor: ResourceColor = $r('app.color.color_E5E6E8_grey');
  public horizontalAlign: HorizontalAlign = HorizontalAlign.Center;
}

export let pcForbiddenCardStyle = new ForbiddenCardStyle();

export class ForbiddenImageStyle extends IconImageStyle {
  public margin: Margin = {
    right: '8vp',
    left: '-4vp'
  };
  public padding: Padding = {
    bottom: $r('app.float.padding_8'),
  }
}

export class DateForbiddenImageStyle extends IconImageStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public margin: Margin = {
    right: '16vp',
    bottom: $r('app.float.padding_8'),
  };
}

let dateForbiddenImageStyle = new DateForbiddenImageStyle();


export class PCFirstVisibleSpaceHeaderStyle extends ForbiddenCardStyle {
  public margin: Margin = {
    bottom: $r('app.float.length_12')
  }
}

export class PCMarginSpaceHeaderStyle extends CardSectionStyle {
  public margin: Margin = {
    bottom: $r('app.float.length_12')
  }
}

export let pcMarginSpaceHeaderStyle = new PCMarginSpaceHeaderStyle();

export let pcFirstVisibleSpaceHeaderStyle = new PCFirstVisibleSpaceHeaderStyle();

let forbiddenImageStyle = new ForbiddenImageStyle();

export class DateForbiddenMessageStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = forbiddenRootContainerStyle;
  public title: TextStyle = dateForbiddenTitleStyle;
  public iconImage: ImageStyle = dateForbiddenImageStyle;
}

export class ForbiddenMessageStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = forbiddenRootContainerStyle;
  public title: TextStyle = forbiddenTitleStyle;
  public iconImage: ImageStyle = forbiddenImageStyle;
}

export let pcForbiddenMessageStyle = new ForbiddenMessageStyle();

export class IntentStateSwitchMenuStyle extends SliderMenuStyle {
  public iconImage?: ImageStyle = new IntentImageStyle();
  public title?: TextStyle = new IntentStateTitleTextStyle();
  public rootContainer?: ContainerStyle = new IntentSwitchTitleRootContainerStyle();
}

export class IntentSwitchMenuStyle extends DefaultSwitchMenuStyle {
  public rootContainer: ContainerStyle = new IntentSwitchMenuRootContainerStyle();
}

class IntentSwitchTitleRootContainerStyle extends RootContainerStyle {
  public padding: Padding = {
    left: $r('app.float.length_12'),
    right: $r('app.float.length_12'),
    top: $r('app.float.length_4'),
    bottom: 0
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.length_20'),
  };
}

class IntentSwitchMenuRootContainerStyle extends RootContainerStyle {
  public padding: Padding = {
    left: $r('app.float.length_12'),
    right: $r('app.float.length_8'),
    top: $r('app.float.length_12'),
    bottom: $r('app.float.length_12')
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.length_48'),
  };
}

/**
 * 多用户弹窗标题区容器样式
 */
export class UserManagementDialogTitleContainerStyle extends DialogTitleContainerStyle {
  public padding: Padding = {
    left: MAX_PADDING_START,
    right: MAX_PADDING_END
  };
}

/**
 * 多用户弹窗标题菜单样式
 */
export class UserManagementDialogTitleMenuStyle extends DialogTitleMenuStyle {
  public rootContainer?: ContainerStyle = new UserManagementDialogTitleContainerStyle();
}

export const userManagementDialogTitleTitleMenuStyle = new UserManagementDialogTitleMenuStyle();

/**
 * 多用户弹窗用户昵称输入框样式
 */
export class UserNicknameTextInputStyle extends TextInputStyle {
  public maxLength = 30;
  public showUnderline = true;
  public backgroundColor = Color.Transparent;
}

/**
 * 多用户弹窗用户昵称容器样式
 */
export class UserNicknameContainerStyle extends RootContainerStyle {
  public size: SizeOptions = {
    width: '100%'
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public horizontalAlign = HorizontalAlign.Start;
  public padding: Padding = {
    left: '12vp',
    right: '12vp'
  };
}

/**
 * 多用户弹窗输入框菜单样式
 */
export class UserManagementDialogTextInputMenuStyle extends TextInputMenuStyle {
  public rootContainer: ContainerStyle = new UserNicknameContainerStyle();
  public textInputStyle: TextInputStyle = new UserNicknameTextInputStyle();
}

export const userManagementDialogTextInputMenuStyle = new UserManagementDialogTextInputMenuStyle();

/**
 * 多用户弹窗操作按钮区容器样式
 */
export class UserManagementDialogButtonMenuContainerStyle extends ButtonMenuContainerStyle {
  public margin: Margin = {
    top: $r('sys.float.ohos_id_elements_margin_vertical_m'),
    bottom: $r('sys.float.ohos_id_dialog_margin_bottom'),
  };
  public gridGutter: Length = '12vp';
  public gridMargin: Length = MAX_PADDING_START;
}

/**
 * 多用户弹窗操作按钮菜单样式
 */
export class UserManagementDialogButtonMenuStyle extends TransparentButtonMenuStyle {
  public rootContainer = new UserManagementDialogButtonMenuContainerStyle();
}

export const userManagementDialogButtonMenuStyle = new UserManagementDialogButtonMenuStyle();

/**
 * Phone弹窗文本菜单样式
 */
export class PhoneDialogMsgStyle extends DialogMessageStyle {
  public rootContainer = new PhoneDialogMsgContainerStyle();
  public title = new PhoneMsgTextStyle();
}

export class PhoneDialogCenterMsgStyle extends DialogMessageStyle {
  public rootContainer = new PhoneDialogMsgCenterContainerStyle();
  public title = new PhoneBaseMsgTextStyle();
}

export class PhoneDialogMsgContainerStyle extends ContainerStyle {
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0')
  };
  public size: SizeOptions = {
    width: '100%',
  };
}

export class PhoneDialogMsgCenterContainerStyle extends PhoneDialogMsgContainerStyle {
  public justifyContent: FlexAlign | undefined = FlexAlign.Center;
}

export class PhoneBaseMsgTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('app.float.font_16'),
    family: 'HarmonyHeiTi',
    weight: FontWeight.Regular,
  };
  public lineHeight = 'app.float.lineHeight_19';
  public textAlign = TextAlign.Start;
}

export class PhoneMsgTextStyle extends PhoneBaseMsgTextStyle {
  public size: SizeOptions = {
    width: '100%',
  };
}

export class PhoneMsgIconStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.icon_secondary');
  public margin?: Margin = {
    right: $r('app.float.gridMargin_4')
  };
}

export class DeveloperDialogPageStyle extends PageStyle {
  public size: SizeOptions = {
    width: DeviceUtil.isDevicePc() ? '400vp' : '100%',
    height: '100%',
  };
  public backgroundColor: ResourceColor = $r('app.color.profile_back_color');
}

export class TransParentWithVerticalDividerPCButtonMenuStyle extends TextStyle {
  public rootContainer = new TransParentWithVerticalDividerPCButtonMenuContainerStyle();
  public buttonStyle1 = new TransParentWithVerticalDividerButtonStyle1();
  public buttonStyle2 = new TransParentWithVerticalDividerButtonStyle();
  public buttonStyle3 = new TransParentWithVerticalDividerButtonStyle3();
}
export class TransParentWithVerticalDividerPCButtonMenuContainerStyle extends TextStyle {
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_64'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_8'),
  };
  public padding: Padding = {
    left: $r('app.float.length_16'),
    right: $r('app.float.length_16'),
  };
}

export class TransParentWithVerticalDividerButtonStyle1 extends DefaultButtonStyle {
  public backgroundColor: Resource = $r('sys.color.ohos_id_color_button_normal');
  public fontColor = $r('sys.color.ohos_id_color_text_primary_activated');
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_40'),
  }
}

export class TransParentWithVerticalDividerButtonStyle3 extends DefaultButtonStyle {
  public backgroundColor: Resource = $r('sys.color.ohos_id_color_button_normal');
  public fontColor = $r('sys.color.ohos_id_color_warning');
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_40'),
  }
}

class DeveloperDialogTitleContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: 'auto',
  };
  public padding: Padding = {
    top: $r('app.float.length_16'),
    bottom: $r('app.float.length_16'),
    right: '24vp',
    left: '24vp',
  };
}

export class DeveloperDialogTitleStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new DeveloperDialogTitleContainerStyle();
  public title?: TextStyle = new DeveloperDialogTitleTextStyle();
}

class DeveloperDialogTitleTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: '20fp',
    weight: FontWeight.Bold,
    family: 'HarmonyHeiTi',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '27vp'
  };
  public borderRadius = $r('sys.float.ohos_id_corner_radius_dialog');
  public justifyContent: FlexAlign = FlexAlign.Center;
  public overflow: TextOverflow = TextOverflow.None;
  public maxLines: number = MAX_LINES_10;
}

export class DeveloperDialogButtonMenuContainerStyle extends ButtonMenuContainerStyle {
  public fontColor = $r('sys.color.ohos_id_color_text_primary_activated');
  public size: SizeOptions = {
    width: '100%',
  }
  public gridGutter: Length = DeviceUtil.isDevicePc() ? $r('app.float.gridGutter_16') : '8vp';
  public gridMargin: Length = $r('app.float.length_16');
}

export class DeveloperDialogMessageContainerStyle extends DialogMessageContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    left: '20vp',
    right: '20vp',
  };
}

export class DeveloperDialogMessageStyle implements Style {
  public rootContainer?: ContainerStyle = new DeveloperDialogMessageContainerStyle();
  public title?: TextStyle = new DeveloperDialogMessageTextStyle();
}

class DeveloperDialogMessageTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: '16fp',
    weight: FontWeight.Regular,
    family: 'HarmonyHeiTi',
  };
  public fontColor = $r('sys.color.ohos_id_color_text_primary');
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '21vp'
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
}

export class DeveloperDialogCancelButtonStyle extends ButtonStyle {
  public backgroundColor = DeviceUtil.isDevicePc() ? $r('app.color.ohos_id_color_button_normal') : $r('app.color.transparent');
  public fontColor = $r('sys.color.ohos_id_color_text_primary_activated');
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_40'),
  }
  public fontSize: Font = {
    size: '16vp',
    weight: FontWeight.Medium,
  };
  public margin: Margin = FontScaleUtils.isExtraLargeFontMode() ?
    { top: DeviceUtil.isDevicePc() ? '16vp' : '0vp', bottom: DeviceUtil.isDevicePc() ? '24vp' : '0vp', } :
    { top: DeviceUtil.isDevicePc() ? '16vp' : '8vp', bottom: DeviceUtil.isDevicePc() ? '24vp' : '16vp',
  };

  public layoutWeight: number = LAYOUT_WEIGHT_1;
  public lineHeight = '21vp';
}

export class DeveloperDialogConfirmButtonStyle extends ButtonStyle {
  public backgroundColor = DeviceUtil.isDevicePc() ? $r('app.color.ohos_id_color_button_normal')
    : $r('app.color.transparent');
  public fontColor = $r('sys.color.ohos_id_color_warning');
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_40'),
  }
  public margin: Margin = FontScaleUtils.isExtraLargeFontMode() ?
    { top: DeviceUtil.isDevicePc() ? '16vp' : '0vp', bottom: DeviceUtil.isDevicePc() ? '24vp' : '0vp', } :
    { top: DeviceUtil.isDevicePc() ? '16vp' : '8vp', bottom: DeviceUtil.isDevicePc() ? '24vp' : '16vp', };
  public layoutWeight: number = LAYOUT_WEIGHT_1;
  public lineHeight = '21vp';
}

export class IPDialogButtonMenuStyle extends ButtonMenuStyle {
  public backgroundColor: ResourceColor | Color | Resource = $r('sys.color.ohos_id_color_button_normal');
  public fontColor: ResourceColor | Color = $r('sys.color.ohos_id_color_emphasize');
  public size: SizeOptions = {
    width: DeviceUtil.isDevicePc() ? '448vp' : '100%',
    height: '40vp',
  };
  public margin: Margin = {
    top: $r('app.float.margin_16'),
    bottom: $r('app.float.margin_24'),
  };
}

export class IPDefaultButtonMenuStyle extends ButtonMenuStyle {
  public rootContainer = new ButtonMenuContainerStyle();
  public buttonStyle3 = new IPDialogButtonMenuStyle();
}

/**
 * 图案密码菜单
 *
 * @since 2024-06-24
 */
export class PatternPasswordMenu extends SettingsBaseMenu {
  constructor(menu: Partial<PatternPasswordBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.PASSWORD_PATTERN;
    }
  }
}

export interface PatternPasswordBaseMenuData extends SettingsBaseMenuData {}

export class DeveloperDialogButtonMenuStyle extends TextStyle {
  public rootContainer = new DeveloperDialogButtonMenuContainerStyle();
  public buttonStyle1 = new DeveloperDialogCancelButtonStyle();
  public buttonStyle3 = new DeveloperDialogConfirmButtonStyle();
}

export class ResetFactoryDialogButtonMenuStyle extends TextStyle {
  public rootContainer = new DeveloperDialogButtonMenuContainerStyle();
  public buttonStyle3 = new DeveloperDialogCancelButtonStyle();
  public buttonStyle1 = new DeveloperDialogConfirmButtonStyle();
  public buttonStyle2 = new DeveloperDialogConfirmButtonStyle();
}

export class HDCAuthorizationMenu extends SettingsBaseMenu implements BaseEntryMenuData {
  constructor(menu: Partial<BaseNavigatorEntryMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.WLAN_QRCODE_COMPONENT;
    }
  }
}

export class AccessibilitySwitchContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
    top: FontScaleUtils.getCurrentTopPadding(),
    bottom: FontScaleUtils.getCurrentTopPadding(),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '64vp',
  };
  public space: Length = SPACE_LENGTH_16;
}

export class DateTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.font_primary');
  public font: Font = {
    size: $r('sys.float.Subtitle_M'),
    weight: FontWeight.Medium,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines: number = MAX_LINES_19;
  public size: SizeOptions = {
    width: '95%',
  };
}

export class MenuSummaryTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
    weight: FontWeight.Regular,
  };
  public margin: Margin = {
    top: '2vp',
  };
  public maxLines: number = MAX_LINES_10;
}

export class AccessibilitySwitchMenuWithSummaryStyle extends DefaultSwitchMenuStyle {
  public rootContainer: ContainerStyle = new AccessibilitySwitchContainerStyle();
  public title: TextStyle = new DateTitleTextStyle();
  public summary: TextStyle = new MenuSummaryTextStyle();
  public toggleStyle = new SwitchToggleStyle();
}

export class InputSettingMenuStyle extends DefaultEntryMenuStyle {
  public stateStyles?: StateStyles = {
    pressed: new InputPressMenuStyle()
  };
}

export class InputPressMenuStyle extends BaseStyle {
  public borderRadius : Resource = $r(`sys.float.corner_radius_level6`)
}