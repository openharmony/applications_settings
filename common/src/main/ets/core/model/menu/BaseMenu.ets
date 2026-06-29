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

import image from '@ohos.multimedia.image';
import {
  BaseStyle,
  ButtonStyle,
  CanvasStyle,
  CommonBadgeStyle,
  ContainerStyle,
  ImageStyle,
  SymbolGlyphStyle,
  LoadingProgressStyle,
  PageHeaderStyle,
  PageStyle,
  SelectStyle,
  Style,
  TextInputStyle,
  TextStyle,
} from './ComponetStyle';
import {
  ControllerConstructorInter,
  MenuPage,
  MenuPageData,
  MenuSection,
  MenuSectionData,
  SettingsBaseMenu,
  SettingsBaseMenuData
} from './SettingsMenu';
import { DeviceUtil } from '../../../utils/BaseUtils';
import { ResourceUtil } from '../../../utils/ResourceUtil';
import { MenuGroupType, MenuPageType, MenuType } from './MenuType';
import { Controller, UiRefresher } from '../../controller/Controller';

/**
 * 页面构造关键参数
 */
export interface constructorParams {
  pageUrl?: string;
  targetPageUrl?: string;
  title?: string | Resource;
  style?: Style;
  menuType?: MenuPageType | string;
  isShowAbout?: boolean;
  isStartAbility?: boolean;
  controller?: ControllerConstructorInter;
}

/**
 * 开关菜单样式
 *
 * @since 2022-03-21
 */
export abstract class SwitchMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public title?: TextStyle;
  public summary?: TextStyle;
  public toggleStyle?: BaseStyle;
}

export interface BaseSwitchMenuData extends SettingsBaseMenuData {}

/**
 * 开关菜单数据
 *
 * @since 2022-03-21
 */
export class BaseSwitchMenu extends SettingsBaseMenu implements BaseSwitchMenuData {
  constructor(menu?: Partial<BaseSwitchMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.SWITCH;
    }
  }
}

/**
 * 入口菜单样式
 *
 * @since 2022-03-21
 */
export abstract class EntryMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public iconContainer?: ContainerStyle;
  public iconImage?: ImageStyle;
  public titleContainer?: ContainerStyle;
  public title?: TextStyle;
  public summary?: TextStyle;
  public secondSummary?: TextStyle;
  public stateContainer?: ContainerStyle;
  public state?: TextStyle;
  public stateIcon?: ImageStyle;
  public symbolIcon?: SymbolGlyphStyle;
  public secondStateContainer?: ContainerStyle;
  public secondState?: TextStyle;
  public secondStateIcon?: ImageStyle;
  public newInfoImage?: ImageStyle;
  public badge?: CommonBadgeStyle;
  public textStyle?: TextStyle;
  public fillColor?: ResourceColor | Color | Resource;
  public menuScale?: ScaleOptions;
  public focusCircleRadius?: number;
  public stateStyles?: StateStyles;
}

export interface BaseEntryMenuData extends SettingsBaseMenuData {
  showNewInfo?: boolean;
  secondSummary?: ResourceStr;
  secondState?: ResourceStr;
  secondStateIcon?: ResourceStr;
  isAccountMenu?: boolean;
}

/**
 * 入口菜单数据
 *
 * @since 2022-03-21
 */
export class BaseEntryMenu extends SettingsBaseMenu implements BaseEntryMenuData {
  /**
   * 显示新信息提示
   */
  public showNewInfo?: boolean;
  public secondSummary?: ResourceStr;
  public secondState?: ResourceStr;
  public secondStateIcon?: ResourceStr;

  constructor(menu?: Partial<BaseEntryMenuData>) {
    super(menu);
    this.showNewInfo = menu?.showNewInfo ?? false;
    this.secondSummary = menu?.secondSummary;
    this.secondState = menu?.secondState;
    this.secondStateIcon = menu?.secondStateIcon;
    if (!menu?.menuType) {
      this.menuType = MenuType.ENTRY;
    }
  }
}

export enum PairIconType {
  SYMBOL,
  IMAGE
}

export interface PairIcon {
  icon: ResourceStr | PixelMap,
  type: PairIconType,
  fontColor?: ResourceStr[]
}

export interface BasePairEntryMenuData extends SettingsBaseMenuData {
  pairTitle: [ResourceStr, ResourceStr];
  pairState: [ResourceStr, ResourceStr];
  pairIcon: [PairIcon, PairIcon];
  pairKey: [string, string];
  pairController: [ControllerConstructorInter, ControllerConstructorInter];
  pairGrayed: [boolean, boolean];
}

export class BasePairEntryMenu extends SettingsBaseMenu implements BasePairEntryMenuData {
  public pairTitle: [ResourceStr, ResourceStr];
  public pairState: [ResourceStr, ResourceStr];
  public pairIcon: [PairIcon, PairIcon];
  public pairKey: [string, string];
  public pairController: [ControllerConstructorInter, ControllerConstructorInter];
  public pairGrayed: [boolean, boolean];

  constructor(menu: BasePairEntryMenuData) {
    super(menu);
    this.pairTitle = menu.pairTitle;
    this.pairState = menu.pairState;
    this.pairIcon = menu.pairIcon;
    this.pairKey = menu.pairKey;
    this.pairController = menu.pairController;
    this.pairGrayed = menu.pairGrayed ?? [false, false];
  }

  /**
   * 获取ui处理controller
   * @param uiRefresher
   */
  public getPairControllerInstance(uiRefresher: UiRefresher): Map<string, Controller> {
    const result = new Map<string, Controller>();
    for (let index = 0; index < this.pairKey.length; index++) {
      const controller = this.pairController[index];
      const controllerInstance = this.createPairController(controller);
      if (controllerInstance) {
        controllerInstance.bindUi(uiRefresher);
        controllerInstance.aboutToAppear();
      }
      result.set(this.pairKey[index], controllerInstance);
    }
    return result;
  }

  private createPairController(controller: ControllerConstructorInter): Controller {
    return controller.createControllerConstructorInter(this);
  }
}

export interface BaseNavigatorEntryMenuData extends BaseEntryMenuData {}

/**
 * 导航入口菜单数据
 *
 * @since 2022-03-21
 */
export class BaseNavigatorEntryMenu extends BaseEntryMenu implements BaseNavigatorEntryMenuData {
  constructor(menu: Partial<BaseNavigatorEntryMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.NAVIGATOR_ENTRY;
    }
  }
}

export interface BaseNavigationEntryMenuData extends BaseEntryMenuData {}

export class BaseNavigationEntryMenu extends BaseEntryMenu implements BaseNavigationEntryMenuData {
  constructor(menu: Partial<BaseNavigationEntryMenu>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.NAVIGATION_MENU_ENTRY;
    }
  }
}

/**
 * 状态菜单样式
 *
 * @since 2022-03-21
 */
export abstract class StateMenuStyle extends EntryMenuStyle {
}

export interface BaseStateMenuData extends BaseEntryMenuData {}

/**
 * 状态菜单数据
 *
 * @since 2022-03-21
 */
export class BaseStateMenu extends BaseEntryMenu implements BaseStateMenuData {
  constructor(menu: Partial<BaseStateMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.STATE;
    }
  }
}

export class BaseSecondMenu extends BaseEntryMenu implements BaseStateMenuData {
  constructor(menu: Partial<BaseStateMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.SECOND;
    }
  }
}


/**
 * 滑动条菜单样式
 *
 * @since 2022-03-21
 */
export abstract class SliderMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public topImage?: ImageStyle;
  public startImage?: ImageStyle;
  public endImage?: ImageStyle;
  public startSymbolIcon?: SymbolGlyphStyle;
  public endSymbolIcon?: SymbolGlyphStyle;
  public sliderStyle?: SliderStyle;
  public sliderPadding?: Padding;
  public sliderMargin?: Margin;
  public sliderConstraintSize?: ConstraintSizeOptions;
  public title?: TextStyle;
  public startIconAccessibilyText?: string;
  public endIconAccessibilyText?: string;
}

export interface BaseSliderMenuData extends SettingsBaseMenuData {
  topIcon?: ResourceStr;
  starIcon?: ResourceStr;
  endIcon?: ResourceStr;
  startSymbolIcon?: ResourceStr;
  endSymbolIcon?: ResourceStr;
}

/**
 * 滑动条菜单数据
 *
 * @since 2022-03-21
 */
export class BaseSliderMenu extends SettingsBaseMenu implements BaseSliderMenuData {
  public topIcon?: ResourceStr;
  public starIcon?: ResourceStr;
  public endIcon?: ResourceStr;

  constructor(menu?: Partial<BaseSliderMenuData>) {
    super(menu);
    this.topIcon = menu?.topIcon;
    this.starIcon = menu?.starIcon;
    this.endIcon = menu?.endIcon;
    if (!menu?.menuType && DeviceUtil.isDevicePc()) {
      this.menuType = MenuType.PC_SLIDER;
    } else {
      this.menuType = MenuType.SLIDER
    }
  }
}

/**
 * 桌面和个性化主题画廊设置
 *
 * @since 2023-11-03
 */
export class SwiperMenu extends SettingsBaseMenu implements SettingsBaseMenuData {
  constructor(menu?: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.SWIPER;
    }
  }
}

/**
 * 主题设置壁纸预览
 *
 * @since 2023-11-03
 */
export class WallpaperPreviewMenu extends SettingsBaseMenu implements SettingsBaseMenuData {
  constructor(menu?: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.WALLPAPER_PREVIEW;
    }
  }
}

/**
 * 合一编辑器菜单项
 *
 * @since 2024-04-11
 */
export class ThemeEditorMenu extends SettingsBaseMenu implements SettingsBaseMenuData {
  constructor(menu?: Partial<SettingsBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.THEME_EDITOR_MENU;
    }
  }
}

/**
 * 图片菜单样式
 *
 * @since 2022-03-21
 */
export abstract class ImageMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public iconImage?: ImageStyle;
  public stateIcon?: ImageStyle;
}

export abstract class CanvasMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public canvas?: CanvasStyle;
}

export interface BaseImageMenuData extends SettingsBaseMenuData {}

export interface BaseCanvasMenuData extends SettingsBaseMenuData {}

/**
 * 图片菜单数据
 *
 * @since 2022-03-21
 */
export class BaseImageMenu extends SettingsBaseMenu implements BaseImageMenuData {
  constructor(menu?: Partial<BaseImageMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.IMAGE;
    }
  }
}

export class BaseRingtoneImage extends SettingsBaseMenu implements BaseImageMenuData {
  constructor(menu?: Partial<BaseImageMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.RINGTONE_IMAGE;
    }
  }
}

export class BaseCanvasMenu extends SettingsBaseMenu implements BaseCanvasMenuData {
  constructor(menu?: Partial<BaseCanvasMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.CANVAS;
    }
  }
}

/**
 * 按钮菜单样式
 *
 * @since 2022-03-21
 */
export abstract class ButtonMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public buttonStyle1?: ButtonStyle;
  public buttonStyle2?: ButtonStyle;
  public buttonStyle3?: ButtonStyle;
}

export abstract class PhoneCommonButtonMenuStyle extends ButtonMenuStyle {
  public buttonStyle?: ButtonStyle;
}

export interface BaseButtonMenuData extends SettingsBaseMenuData {
  buttonTittle1?: ResourceStr;
  buttonTittle2?: ResourceStr;
  buttonTittle3?: ResourceStr;
}

/**
 * 按钮菜单数据，最多支持3个按钮
 *
 * @since 2022-03-21
 */
export class BaseButtonMenu extends SettingsBaseMenu implements BaseButtonMenuData {
  public buttonTittle1?: ResourceStr;
  public buttonTittle2?: ResourceStr;
  public buttonTittle3?: ResourceStr;
  public buttonTittleLoading?: ResourceStr;

  constructor(menu?: Partial<BaseButtonMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.BUTTON;
    }
    this.buttonTittle1 = ResourceUtil.getCapitalStringSync(menu?.buttonTittle1 as ResourceStr);
    this.buttonTittle2 = ResourceUtil.getCapitalStringSync(menu?.buttonTittle2 as ResourceStr);
    this.buttonTittle3 = ResourceUtil.getCapitalStringSync(menu?.buttonTittle3 as ResourceStr);
    this.buttonTittleLoading = ResourceUtil.getCapitalStringSync(menu?.buttonTittleLoading as ResourceStr);
  }
}

export class WindowBaseButtonMenu extends SettingsBaseMenu implements BaseButtonMenuData {
  public buttonTittle1?: ResourceStr;
  public buttonTittle2?: ResourceStr;
  public buttonTittle3?: ResourceStr;

  constructor(menu?: Partial<BaseButtonMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.BUTTON;
    }
    this.buttonTittle1 = menu?.buttonTittle1;
    this.buttonTittle2 = menu?.buttonTittle2;
    this.buttonTittle3 = menu?.buttonTittle3;
  }
}

/**
 * 输入文本框菜单样式
 *
 * @since 2022-03-21
 */
export abstract class TextInputMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public textInputStyle?: TextInputStyle;
  public summaryStyle?: TextStyle;
  public stateStyle?: TextStyle;
  public dividerStyle?: BaseStyle;
}

export interface BaseTextInputMenuData extends SettingsBaseMenuData {
  hint?: ResourceStr;
}

/**
 * 输入文本框菜单数据
 *
 * @since 2022-03-21
 */
export class BaseTextInputMenu extends SettingsBaseMenu implements BaseTextInputMenuData {
  public hint?: ResourceStr | string;
  public showError?: boolean;

  constructor(menu?: Partial<BaseTextInputMenuData>) {
    super(menu);
    this.hint = menu?.hint;
    if (!menu?.menuType) {
      this.menuType = MenuType.TEXT_INPUT;
    }
  }
}

export interface BaseSubHeaderMenuData extends SettingsBaseMenuData {}

/**
 * 子标题菜单数据
 *
 * @since 2022-03-21
 */
export class BaseSubHeaderMenu extends SettingsBaseMenu implements BaseSubHeaderMenuData {
  constructor(menu: Partial<BaseSubHeaderMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.TEXT;
    }
  }
}

/**
 * 加载菜单样式
 *
 * @since 2022-03-21
 */
export abstract class LoadingMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public title?: TextStyle;
  public summary?: TextStyle;
  public loadingProgressStyle?: LoadingProgressStyle;
}

export interface BaseLoadingMenuData extends SettingsBaseMenuData {}

/**
 * 加载菜单数据
 *
 * @since 2022-03-21
 */
export class BaseLoadingMenu extends SettingsBaseMenu implements BaseLoadingMenuData {
  constructor(menu: Partial<BaseLoadingMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.LOADING;
    }
  }
}

export interface BaseCardSectionData extends MenuSectionData {}

/**
 * 卡片分段菜单数据
 *
 * @since 2022-03-21
 */
export class BaseCardSection extends MenuSection {
  constructor(params?: Partial<BaseCardSectionData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.menuType) {
      this.menuType = MenuGroupType.CARD_SECTION;
    }
  }
}

export interface BaseSubHeaderSectionData extends MenuSectionData {}

/**
 * 子标题分段菜单数据
 *
 * @since 2022-03-21
 */
export class BaseSubHeaderSection extends MenuSection {
  constructor(params?: Partial<BaseSubHeaderSectionData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.menuType) {
      this.menuType = MenuGroupType.SUBHEAD_SECTION;
    }
  }
}

export interface BaseLoadingSubHeaderSectionData extends MenuSectionData {}

/**
 * 加载子标题分段菜单数据
 *
 * @since 2022-03-21
 */
export class BaseLoadingSubHeaderSection extends MenuSection {
  constructor(params?: Partial<BaseLoadingSubHeaderSectionData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.menuType) {
      this.menuType = MenuGroupType.LOADING_SUBHEAD_SECTION;
    }
  }
}

/**
 * 标题页菜单样式
 *
 * @since 2022-03-21
 */
export abstract class HeaderPageStyle extends PageStyle {
  public pageHeaderStyle?: PageHeaderStyle;
}

export interface BaseHeaderPageData extends MenuPageData {}

/**
 * 标题页菜单数据
 *
 * @since 2022-03-21
 */
export class BaseHeaderPage extends MenuPage {
  constructor(params?: Partial<BaseHeaderPageData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.menuType) {
      this.menuType = MenuPageType.HEADER_PAGE;
    }
  }
}

export interface BaseDialogPageData extends MenuPageData {}

/**
 * 弹框页菜单数据
 *
 * @since 2022-03-21
 */
export class BaseDialogPage extends MenuPage {
  constructor(params?: Partial<BaseDialogPageData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (!params?.menuType) {
      this.menuType = MenuPageType.DIALOG_PAGE;
    }
    this.isPrivacy = params?.isPrivacy as boolean;
    this.pageStyle = params?.pageStyle;
  }
}

/**
 * 单选框卡片样式
 *
 * @since 2022-03-21
 */
export abstract class CardRadioMenuStyle extends PageStyle {
  public rootContainer?: ContainerStyle;
  public summary?: TextStyle;
  public spaceWidth?: Length;
  public title?: TextStyle;
  public menuContainerPadding?: Padding;
  public radioStyle?: RadioStyle;
}

/**
 * 多选框卡片样式
 *
 * @since 2023-11-06
 */
export abstract class CheckboxMenuStyle extends PageStyle {
  public summary?: TextStyle;
  public spaceWidth?: Length;
  public title?: TextStyle;
  public menuContainerPadding?: Padding;
  public mark?: MarkStyle;
}

/**
 * 选择图标卡片样式
 *
 * @since 2023-12-01
 */
export abstract class SelectImageMenuStyle extends PageStyle {
  public summary?: TextStyle;
  public spaceWidth?: Length;
  public title?: TextStyle;
  public imageIcon?: ImageStyle;
  public menuContainerPadding?: Padding;
}

export interface BaseRadioMenuData extends SettingsBaseMenuData {}

export class BaseRadioMenu extends SettingsBaseMenu implements BaseRadioMenuData {
  constructor(menu: Partial<BaseRadioMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.RADIO;
    }
  }
}

export class RadioIconAndText {
  public radioIcon?: string | PixelMap | ResourceStr;
  public radioText?: string | ResourceStr;
  public radioIconSelect?: ResourceStr;
  public bundleName?: string;
  public id?: number;
  public extra?: number;
}

export interface BrowserListPro {
  label?: Promise<string>;
  icon?: image.PixelMap;
  labelId?: number;
  bundleName?: string;
  name?: string;
  isSystemApp?: boolean;
  moduleName?: string;
}

export interface MailListPro {
  label?: Promise<string>;
  icon?: image.PixelMap;
  labelId?: number;
  bundleName?: string;
  name?: string;
  isSystemApp?: boolean;
}

export class RadioIconAndTextBrowser {
  public radioIcon?: ResourceStr | PixelMap;
  public radioText?: string | PixelMap;
  public extra?: number;
}

export interface BaseCardRadioMenuData extends BaseRadioMenuData {
  radioIconAndText: RadioIconAndText[];
  defaultName: string;
}

export interface BaseBrowserRadioMenuData extends BaseRadioMenuData {
  radioIconAndText: RadioIconAndText[];
}

/**
 * 单选框卡片数据
 *
 * @since 2022-05-29
 */
export class BaseCardRadioMenu extends BaseRadioMenu implements BaseCardRadioMenuData {
  public radioIconAndText: RadioIconAndText[];
  public defaultName: string;

  constructor(menu: Partial<BaseCardRadioMenuData>) {
    super(menu);
    this.radioIconAndText = menu.radioIconAndText as RadioIconAndText[];
    this.defaultName = menu.defaultName as string;
    if (!menu?.menuType) {
      this.menuType = MenuType.CARD_RADIO;
    }
  }
}

export class BaseEmailRadioMenu extends BaseRadioMenu implements BaseRadioMenuData {
  public radioIcon: ResourceStr;

  constructor(menu: Partial<BaseRadioMenuData>) {
    super(menu);
    this.radioIcon = menu.icon as ResourceStr;
    if (!menu?.menuType) {
      this.menuType = MenuType.EMAIL_RADIO;
    }
  }
}

export class BaseIconRadioMenu extends BaseRadioMenu implements BaseRadioMenuData {
  public radioIcon: ResourceStr;

  constructor(menu: Partial<BaseRadioMenuData>) {
    super(menu);
    this.radioIcon = menu.icon as ResourceStr;
    if (!menu?.menuType) {
      this.menuType = MenuType.ICON_RADIO;
    }
  }
}


export class BaseBrowserRadioMenu extends BaseRadioMenu implements BaseCardRadioMenuData {
  public radioIconAndText: RadioIconAndText[];
  public defaultName: string;

  constructor(menu: Partial<BaseCardRadioMenuData>) {
    super(menu);
    this.radioIconAndText = menu.radioIconAndText as RadioIconAndText[];
    this.defaultName = menu.defaultName as string;
    if (!menu?.menuType) {
      this.menuType = MenuType.CARD_ICON_RADIO;
    }
  }
}

export interface PasswordCircleBaseMenuData extends SettingsBaseMenuData {}

/**
 * 密码圆圈数据
 *
 * @since 2023-01-17
 */
export class PasswordCircleBaseMenu extends SettingsBaseMenu implements PasswordCircleBaseMenuData {
  constructor(menu: Partial<PasswordCircleBaseMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.PASSWORD_CIRCLE;
    }
  }
}

export interface UnderLineTextInputBaseMenuData extends SettingsBaseMenuData {
  hint?: ResourceStr;
}

/**
 * 下划线输入文本框菜单数据
 *
 * @since 2023-01-18
 */
export class UnderLineTextInputBaseMenu extends SettingsBaseMenu implements UnderLineTextInputBaseMenuData {
  public hint: string;

  constructor(menu: Partial<UnderLineTextInputBaseMenuData>) {
    super(menu);
    this.hint = menu.hint as string;
    if (!menu?.menuType) {
      this.menuType = MenuType.UNDERLINE_TEXT_INPUT;
    }
  }
}

export interface BaseSelectEntryMenuData extends SettingsBaseMenuData {
  secondSummary?: ResourceStr;
  selectList?: Array<SelectOption>;
  selected?: number;
  value?: ResourceStr;
}

/**
 * 下拉选择框入口菜单数据
 *
 * @since 2023-02-07
 */
export class BaseSelectEntryMenu extends SettingsBaseMenu implements BaseSelectEntryMenuData {
  public secondSummary: ResourceStr;
  public selectList: Array<SelectOption>;
  public selected: number;
  public value: string;

  constructor(menu: Partial<BaseSelectEntryMenuData>) {
    super(menu);
    this.secondSummary = menu?.secondSummary as ResourceStr;
    this.selectList = menu?.selectList as SelectOption[];
    this.selected = menu?.selected as number;
    this.value = menu?.value as string;
    if (!menu?.menuType) {
      this.menuType = MenuType.SELECT_ENTRY;
    }
  }
}

/**
 * 下拉选择框入口菜单样式
 *
 * @since 2023-02-08
 */
export abstract class SelectEntryMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public iconContainer?: ContainerStyle;
  public iconImage?: ImageStyle;
  public titleContainer?: ContainerStyle;
  public title?: TextStyle;
  public summary?: TextStyle;
  public secondSummary?: TextStyle;
  public stateContainer?: ContainerStyle;
  public state?: TextStyle;
  public stateIcon?: ImageStyle;
  public newInfoImage?: ImageStyle;
  public selectStyle?: SelectStyle;
}

export interface BaseCheckboxMenuData extends SettingsBaseMenuData {
  selected?: boolean;
}

export interface MultiCheckboxMenuData extends SettingsBaseMenuData {
  isSelected?: boolean;
}

/**
 * 多选框菜单数据
 */
export class BaseCheckboxMenu extends SettingsBaseMenu implements BaseCheckboxMenuData {
  public selected: boolean;

  constructor(menu: Partial<BaseCheckboxMenuData>) {
    super(menu);
    this.selected = menu?.selected as boolean;
    if (!menu?.menuType) {
      this.menuType = MenuType.CHECKBOX;
    }
  }
}

export abstract class BaseCheckboxOptionStyle extends BaseStyle {
  public titleStyle?: TextStyle;
  public summaryStyle?: TextStyle;
}

export interface BaseCheckboxOptionMenuData extends SettingsBaseMenuData {
  isChecked?: boolean;
}

/**
 * 左边标题，右边checkbox样式的选项菜单
 */
export class BaseCheckboxOptionMenu extends SettingsBaseMenu implements BaseCheckboxOptionMenuData {
  public isChecked?: boolean;

  constructor(menu: Partial<BaseCheckboxOptionMenuData>) {
    super(menu);
    this.isChecked = menu?.isChecked ?? false;
    this.menuType = MenuType.CHECKBOX_OPTION;
  }
}

export interface BaseButtonWithVariableTitleMenuData extends SettingsBaseMenuData {}

/**
 * 带倒计时的按钮菜单数据
 */
export class BaseButtonWithVariableTitleMenu extends SettingsBaseMenu implements BaseButtonWithVariableTitleMenuData {
  constructor(menu: Partial<BaseButtonWithVariableTitleMenuData>) {
    super(menu);
    if (!menu?.menuType) {
      this.menuType = MenuType.BUTTON_WITH_VARIABLE_TITLE;
    }
  }
}