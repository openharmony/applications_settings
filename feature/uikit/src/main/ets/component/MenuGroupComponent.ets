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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  SettingsBaseMenu,
  MenuGroup,
  MenuSection
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  ContainerStyle,
  Style,
  GroupStyle,
  PageStyle
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { MenuType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { LazyMenuListKeys } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { MenuDataSource } from '@ohos/settings.common/src/main/ets/core/model/datasource/MenuDataSource';
import { MenuController, MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import {
  BaseTextInputMenu,
  BaseButtonMenu,
  UnderLineTextInputBaseMenu,
  BasePairEntryMenu
} from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { StyleConstant } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { HeaderComponent, SpaceComponent, TimeZoneReusableEntryComponent } from './BaseComponent';
import {
  EntryMenuComponent,
  NavigatorEntryMenuComponent,
  ImageMenuComponent,
  SwitchMenuComponent,
  DividerMenuComponent,
  SliderMenuComponent,
  StateMenuComponent,
  PermissionMenuComponent,
  SecondMenuComponent,
  ButtonMenuComponent,
  ButtonMenuLargeComponent,
  TextInputMenuComponent,
  ChainedTextInputMenuComponent,
  LoadingMenuComponent,
  CircleMenuComponent,
  DataPanelCircleMenuComponent,
  TextMenuComponent,
  RowTextMenuComponent,
  EditComponent,
  VerticalButtonMenuComponent,
  RadioMenuComponent,
  CoalesceRadioMenuComponent,
  CardRadioMenuComponent,
  EmailRadioMenuComponent,
  PasswordCircleMenuComponent,
  UnderLineTextInputMenuComponent,
  SelectEntryMenuComponent,
  CheckboxMenuComponent,
  ButtonWithVariableTitleMenuComponent,
  NavigationEntryMenuComponent,
  NavEntryMenuComponent,
  NavInfoEntryMenuComponent,
  UnderLineEditMenuComponent,
  FlatEntryMenuComponent,
  TransparentButtonMenuComponent,
  TransparentButtonMenuLargeComponent,
  PcCheckboxMenuDiaLogComponent,
  PhoneCheckboxMenuDiaLogComponent,
  SettingHomeEntryMenuComponent,
  PasswordUnderLineTextInputMenuComponent,
  CanvasMenuComponent,
  SingleChoiceMenuComponent,
  BrowserRadioMenuComponent,
  DivideButtonMenuComponent,
  DivideButtonMenuLargeComponent,
  ParagraphComponent,
  PadSwiperMenuComponent,
  PadWallpaperPreviewMenuComponent,
  MultiCheckboxMenuComponent,
  SelectImageMenuComponent,
  IconRadioMenuComponent,
  SimpleSpaceComponent,
  BtLoadingComponent,
  CheckboxOptionMenuComponent,
  SingleChooseComponent,
  BatterySavingModeSwitchMenuComponent,
  PatternPasswordMenuComponent,
  ConnectButtonMenuComponent,
  SwitchMenuLargeComponent,
  HdcAuthorizationButtonSwitchComponent,
  TextListMenuComponent,
  NavPairEntryMenuComponent
} from './MenuComponent';
import { ThemeEditorPcMenuComponent } from './ThemeEditorMenuComponent';
import { SheetMenuComponent, } from './bluetooth/SheetMenuComponent';
import { QrcodeComponent, } from './bluetooth/QrcodeComponent';
import { ConnectedHotSportComponent } from './wifi/ConnectedHotSportComponent';
import {
  NavigationCheckboxMenuComponent,
  WifiPrecisionComponent,
  DateZoneComponent,
  RingToneImageComponent,
  SliderPCMenuComponent,
  WLANQRCodeComponent,
  WifiHilinkComponent,
  BatteryMpChartComponent,
} from './MenuCustomComponent';
import {
  GridMenuGroup,
  CardSectionStyle,
  EntryMenu,
  DefaultEntryMenuStyle,
  GridGroupStyle,
  PaddingCardSectionListStyle,
  CardSectionListStyle,
} from '../menus/Menu';
import { PHONE_SETTING_HOME_MENU_KEYS, } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  ReusableBtEntryComponent,
  ReusableHotSpotEntryComponent,
  ReusableUsersEntryComponent,
  TitleSummaryImageEntryComponent,
  WifiEntryComponent,
} from './AtomicComponent';
import { TextTipsComponent } from './hotsport/TextTipsComponent';
import { LinkSwitchMenuComponent } from './LinkSwitchMenuComponent';
import { HwAccountInfoTextMenuComponent } from './HwAccountInfoTextMenuComponent';

/* instrument ignore file */
const TAG: string = 'MenuGroupComponent: ';
const LAZY_MENU_LIST_KEYS =
  new Set([LazyMenuListKeys.WIFI_LIST.toString(), LazyMenuListKeys.BLUETOOTH_LIST.toString()]);
const DEFAULT_CACHE_COUNT = 3;
const FRICTION_FACTOR: number = 1;
const IS_DEVICE_PAD: boolean = DeviceUtil.isDevicePad();
const IS_DEVICE_PHONE: boolean = DeviceUtil.isDevicePhone();
const IS_DEVICE_PC: boolean = DeviceUtil.isDevicePc();

export let cardSectionListStyle = new CardSectionListStyle();

@Observed
export class MenusArray {
  public menus: SettingsBaseMenu[];

  constructor(menus: Array<SettingsBaseMenu>) {
    this.menus = menus;
  }
}

@Observed
export class LazyMenusArray implements IDataSource {
  public menus: SettingsBaseMenu[];

  constructor(menus: Array<SettingsBaseMenu>) {
    this.menus = menus;
  }

  totalCount(): number {
    return this.menus.length;
  }

  getData(index: number): SettingsBaseMenu {
    return this.menus[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    LogUtil.info('LazyMenusArray registerDataChangeListener');
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    LogUtil.info('LazyMenusArray unregisterDataChangeListener');
  }
}

@Component
export struct MenuListComponent {
  @ObjectLink menusArray: MenusArray;
  style?: GroupStyle;
  @Link uiRefresher: UiRefresher;
  scroller?: Scroller;

  build() {
    if (this.menusArray) {
      List({ scroller: this.scroller }) {
        ForEach(this.menusArray.menus, (menu: SettingsBaseMenu) => {
          if (menu.isVisible()) {
            if (menu instanceof MenuGroup) {
              if (menu.key === 'wifi_list_group' && DeviceUtil.isDevicePc()) {
                if (menu instanceof MenuSection) {
                  ListItem() {
                    WifiMenuGroupComponent({ menuSection: menu });
                  }
                }
              } else if (menu.key === 'hotspot_list_group' && DeviceUtil.isDevicePc()) {
                if (menu instanceof MenuSection) {
                  ListItem() {
                    PcHotSpotListComponent({ menuSection: menu })
                  }
                }
              } else if (menu.key === 'other_users_group' && DeviceUtil.isDevicePc()) {
                if (menu instanceof MenuSection) {
                  ListItem() {
                    PcUsersListComponent({ menuSection: menu })
                  }
                }
              } else {
                ListItem() {
                  MenuGroupItemComponent({ menuGroup: menu })
                }
              }
            } else {
              ListItem() {
                if ((IS_DEVICE_PHONE || IS_DEVICE_PAD) && PHONE_SETTING_HOME_MENU_KEYS.has(menu.key as string)) {
                  SettingHomeMenuItemComponent({ menu: menu });
                } else {
                  MenuItemComponent({ menu: menu });
                }
              }
            }
          }
        }, (menu: SettingsBaseMenu) => {
          return menu.toString();
        });
      }
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .scrollBar(BarState.Off)
      .cachedCount(DEFAULT_CACHE_COUNT)
      .divider({
        strokeWidth: this.getListStrokeWidth() > 1 ? this.style?.divider?.strokeWidth as number : 0,
        color: this.style?.divider?.color,
        startMargin: this.style?.divider?.startMargin,
        endMargin: this.style?.divider?.endMargin,
      })
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .lanes(this.style?.lanes)
      .backgroundColor(this.style?.backgroundColor)
      .borderRadius(this.style?.borderRadius as Length)
      .padding(StyleConstant.getLocalizedPadding(this.style?.padding as Padding))
      .margin(StyleConstant.getLocalizedPadding(this.style?.margin as Padding))
      .visibility((this.uiRefresher.isVisible() && this.menusArray.menus.length > 0) ?
      Visibility.Visible : Visibility.None);
    }
  }

  private getListStrokeWidth(): number {
    if (this.menusArray.menus.length <= 1) {
      return 0;
    }

    let num = this.menusArray.menus.filter((menu: SettingsBaseMenu) => {
      return menu.isVisible();
    }).length;

    return num;
  }
}

@Component
export struct MenuLazyListComponent {
  @ObjectLink menusArray: MenusArray;
  style?: GroupStyle;
  @Link uiRefresher: UiRefresher;
  scroller?: Scroller;
  tag: string = 'MenuSingleListComponent:';

  build() {
    if (this.menusArray) {
      List({ scroller: this.scroller }) {
        ForEach(this.menusArray.menus, (menu: SettingsBaseMenu, index) => {
          if (menu.isVisible()) {
            if (menu instanceof MenuGroup) {
              if (index !== 0) {
                ListItem() {
                  SpaceComponent({ space: '12vp', uiRefresher: $uiRefresher });
                }
              }
              ListItemGroup() {
                LazyForEach(this.getMenus(menu), (menuGroupItem: SettingsBaseMenu) => {
                  ListItem() {
                    MenuItemComponent({ menu: menuGroupItem });
                  }
                }, (menuGroupItem: SettingsBaseMenu) => {
                  return menuGroupItem.toString();
                });
              }
              .divider({
                strokeWidth: this.getMenuListStyle(menu)?.divider?.strokeWidth as Length,
                color: this.getMenuListStyle(menu)?.divider?.color,
                startMargin: this.getMenuListStyle(menu)?.divider?.startMargin,
                endMargin: this.getMenuListStyle(menu)?.divider?.endMargin
              })
              .alignSelf(ItemAlign.Start)
              .clip(true)
              .borderRadius(this.getMenuListStyle(menu)?.borderRadius as Length)
              .backgroundColor(this.getMenuListStyle(menu)?.backgroundColor)
              .padding(this.getMenuListStyle(menu)?.padding as Padding)
              .margin(this.getMenuListStyle(menu)?.margin as Padding)
              .visibility((this.uiRefresher.isVisible() && menu.getMenus()
                .length > 0) ? Visibility.Visible : Visibility.None);
            } else {
              ListItem() {
                MenuItemComponent({ menu: menu });
              }
            }
          }
        }, (menu: SettingsBaseMenu) => {
          return menu.toString();
        });
        ListItem() {
          SpaceComponent({ space: '24vp', uiRefresher: $uiRefresher });
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .cachedCount(DEFAULT_CACHE_COUNT)
      .divider({
        strokeWidth: this.style?.divider?.strokeWidth as Length,
        color: this.style?.divider?.color,
        startMargin: this.style?.divider?.startMargin,
        endMargin: this.style?.divider?.endMargin
      })
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .lanes(this.style?.lanes as number)
      .borderRadius(this.style?.borderRadius as Length)
      .backgroundColor(this.style?.backgroundColor)
      .padding(this.style?.padding as Padding)
      .margin(this.style?.margin as Padding)
      .sticky(StickyStyle.None)
      .visibility((this.uiRefresher.isVisible() && this.menusArray.menus.length > 0) ?
      Visibility.Visible : Visibility.None);
    }
  }

  private getMenus(menu: MenuGroup): LazyMenusArray {
    let menus = menu.getMenus();
    if (!menus) {
      menus = [];
    }
    return new LazyMenusArray(menus);
  }

  private getMenuListStyle(menu: MenuGroup): GroupStyle | undefined {
    let style = menu.style;
    if (!style) {
      return undefined;
    }
    if (style instanceof CardSectionStyle) {
      return style.listStyle;
    }
    return undefined;
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear length : ${this.menusArray.menus.length}`);
    this.menusArray.menus.forEach((menu: SettingsBaseMenu) => {
      if (menu instanceof MenuGroup) {
        menu.getControllerInstance(this.uiRefresher);
      }
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear : ${this.menusArray.menus.length}`);
    this.menusArray.menus.forEach((menu: SettingsBaseMenu) => {
      if (menu instanceof MenuGroup) {
        menu.getControllerInstance(this.uiRefresher)?.aboutToDisappear();
      }
    });
  }
}

@Component
export struct MenuGridListComponent {
  menusArray?: MenusArray = undefined;
  style?: GridGroupStyle | Style;
  @Link uiRefresher: UiRefresher;
  @StorageLink('isPortraitOrientation') @Watch('getMenuGridSize') isPortraitOrientation: boolean = false;
  @StorageProp('calNavBarWidth') calNavBarWidth: number = 0;

  build() {
    Grid() {
      ForEach(this.menusArray?.menus, (menu: SettingsBaseMenu) => {
        if (menu instanceof MenuGroup) {
          GridItem() {
            MenuGroupItemComponent({ menuGroup: menu });
          }
          .columnStart(this.getMenuRootContainerStyle(menu.style)?.columnStart)
          .columnEnd(this.getMenuRootContainerStyle(menu.style)?.columnEnd)
          .width('100%')
        } else {
          GridItem() {
            MenuItemComponent({ menu: menu });
          }
          .columnStart(this.getMenuRootContainerStyle(menu.style)?.columnStart)
          .columnEnd(this.getMenuRootContainerStyle(menu.style)?.columnEnd)
          .width('100%')
        }
      }, (menu: SettingsBaseMenu) => {
        return menu.toString();
      });
    }
    .size(this.getMenuGridSize())
    .columnsTemplate((this.style as GridGroupStyle)?.columnsTemplate)
    .rowsTemplate((this.style as GridGroupStyle)?.rowsTemplate)
    .clip((this.style as GridGroupStyle)?.clip)
    .borderRadius((this.style as GridGroupStyle)?.borderRadius as Length)
    .backgroundColor((this.style as GridGroupStyle)?.backgroundColor)
    .padding((this.style as GridGroupStyle)?.padding as Padding)
    .margin((this.style as GridGroupStyle)?.margin as Padding)
    .visibility((this.uiRefresher.isVisible() && this.menusArray ? this.menusArray?.menus.length > 0 : false) ?
    Visibility.Visible : Visibility.None);
  }

  private getMenuRootContainerStyle(style: Style): ContainerStyle {
    return (style as PageStyle)?.rootContainer as ContainerStyle;
  }

  private getMenuGridSize(): SizeOptions | undefined {
    let size = (this.style as GridGroupStyle)?.size;
    if (!this.style || !DeviceUtil.isDevicePad()) {
      return size;
    }
    let menus = this.menusArray?.menus;
    if (!menus) {
      return size;
    }
    menus.forEach((menu?: SettingsBaseMenu) => {
      if (menu && menu.menuType === MenuType.WALLPAPER_PREVIEW) {
        const imageMargin: number = 32; // 图片左右外边距
        const imageTop: number = 65; // 图片上下外边距
        let imageWidth = DisplayUtils.getScreenWidth() - px2vp(this.calNavBarWidth) - imageMargin;
        let imageHeight = (imageWidth / DisplayUtils.getScreenRation());
        size = this.isPortraitOrientation ? { width: '100%', height: (imageTop + imageWidth) + 'vp' } :
          { width: '100%', height: (imageTop + imageHeight) + 'vp' };
      }
      return size;
    })
    return size;
  }
}

@Component
export struct MenuGroupItemComponent {
  tag: string = 'MenuGroupItemComponent : ';
  menuGroup?: MenuGroup;

  build() {
    if (this.menuGroup instanceof MenuSection) {
      MenuSectionComponent({ menuSection: this.menuGroup });
    } else {
      MenuGroupComponent({ menuGroup: this.menuGroup });
    }
  }
}

@Component
export struct MenuSectionComponent {
  tag: string = 'MenuSectionComponent : ';
  menuSection?: MenuSection;
  style?: CardSectionStyle = undefined; // any类型涉及源代码适配，后续需求SR000IAJ8T中会统一整改
  @State controller?: MenuGroupController = undefined; // any类型涉及源代码适配，后续需求SR000IAJ8T中会统一整改
  // setup callback on change to uiRefresher, we will update menu in it
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  // define as @State, observed. Changes will be pased to children
  @State menusArray?: MenusArray = undefined;

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      Column() {
        // 头
        if (this.menuSection?.getHeader()) {
          MenuGroupItemComponent({ menuGroup: this.menuSection?.getHeader() });
        }
      }

      // 内容
      Column() {
        Stack({ alignContent: Alignment.TopEnd }) {
          // Pass this.menusArray instead of call to getMenus, that creates new object on every call
          if (LAZY_MENU_LIST_KEYS.has(this.menuSection?.key as string)) {
            LazyMenuListComponent({
              menusArray: this.menusArray,
              style: this.style?.listStyle as CardSectionStyle,
              uiRefresher: this.uiRefresher,
              parentKey: this.menuSection?.key,
            });
          } else {
            MenuListComponent({
              menusArray: this.menusArray,
              style: this.style?.listStyle,
              uiRefresher: this.uiRefresher
            });
          }
          Image($r('app.media.ic_settings_hover_delete'))
            .width(this.style?.hoverIconSize?.width)
            .height(this.style?.hoverIconSize?.height as string)
            .offset(this.style?.hoverIconOffset)
            .onClick(() => {
              this.controller?.handleHoverButtonClick();
            })
            .visibility(this.controller?.isComponentHovered() ? Visibility.Visible : Visibility.None)
            .draggable(false);
        }
        .constraintSize(this.style?.listSize)
        .onHover((isHover?: boolean) => {
          this.controller?.handleHoverEvent(isHover ? true : false);
        })
      }

      Column() {
        // 尾
        if (this.menuSection?.getFooter()) {
          MenuGroupItemComponent({ menuGroup: this.menuSection?.getFooter() });
        }
      }
    }
    .constraintSize(this.style?.constraintSize)
    .flexGrow(1)
    .padding(this.style?.padding as Padding)
    .margin(this.style?.margin as Margin)
    .clip(this.style?.clip)
    .borderRadius(this.style?.borderRadius as Length)
    .backgroundColor(this.style?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenus(): MenusArray {
    let menus = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuSection?.getMenus() as Array<SettingsBaseMenu>;
    }
    if (!menus) {
      menus = []
    }
    LogUtil.debug(`${this.tag} getMenus ${menus.length},  key ${this.menuSection?.getLogKey()}`);
    this.style = this.menuSection?.style as CardSectionStyle;
    if (!this.menuSection?.tabIndex || this.menuSection?.tabIndex === TabIndexConstants.TAB_INDEX_DEFAULT) {
      return new MenusArray(menus);
    }
    let isFirstMenu: boolean = true;
    for (let i: number = 0; i < menus.length; i++) {
      if (menus[i] instanceof MenuGroup) {
        continue;
      }
      if (isFirstMenu && menus[i].isVisible() && menus[i].enable) {
        menus[i].tabIndex = this.menuSection?.tabIndex;
        isFirstMenu = false;
      } else {
        menus[i].tabIndex = TabIndexConstants.TAB_INDEX_DEFAULT;
      }
    }
    return new MenusArray(menus);
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear ${this.menuSection?.getLogKey()}`);
    this.style = this.menuSection?.style as CardSectionStyle;

    this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuGroupController;

    // initialize this.menusArray on appear
    this.menusArray = this.getMenus();
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct LazyMenuListComponent {
  @ObjectLink @Watch('uiRefresherWatch') menusArray: MenusArray;
  style?: PaddingCardSectionListStyle | CardSectionStyle;
  @Link @Watch('uiRefresherWatch') uiRefresher: UiRefresher;
  scroller?: Scroller;
  lazyMenus: MenuDataSource = new MenuDataSource([]);
  isMenuFlat: boolean = false;
  parentKey: string = '';

  uiRefresherWatch(): void {
    this.getLazyMenus();
  }

  build() {
    if (this.menusArray && this.lazyMenus.totalCount() > 0) {
      List(this.isMenuFlat ? {} : { scroller: this.scroller }) {
        LazyForEach(this.lazyMenus, (menu: SettingsBaseMenu) => {
          if (menu.isVisible()) {
            ListItem() {
              if (this.parentKey === 'time_zone_list_group') {
                // 此处特判时钟列表采用reusable组件
                TimeZoneReusableEntryComponent({
                  menu: menu as EntryMenu,
                  style: menu.style as DefaultEntryMenuStyle,
                  controller: menu.getControllerInstance(this.uiRefresher) as MenuController,
                  uiRefresher: this.uiRefresher,
                  showTitle: menu.title?.toString(),
                  showSummary: menu.summary?.toString(),
                })
              } else if (this.parentKey === 'bluetooth_list_group') {
                ReusableBtEntryComponent({
                  menu: menu as SettingsBaseMenu,
                  controller: menu.getControllerInstance(this.uiRefresher) as MenuController,
                  uiRefresher: this.uiRefresher,
                  showIcon: menu.icon,
                  showTitle: menu.title?.toString(),
                  showSummary: menu.summary as Resource,
                  style: menu.style as DefaultEntryMenuStyle,
                })
              } else {
                MenuItemComponent({ menu: menu, isMenuFlat: this.isMenuFlat });
              }
            }
            .backgroundColor(this.style?.backgroundColor)
          }
        }, (menu: SettingsBaseMenu) => {
          if (this.parentKey === 'time_zone_list_group') {
            return `${menu.title?.toString()} + ${menu.summary?.toString()}`;
          } else if (this.parentKey === 'bluetooth_list_group') {
            return `${menu.key?.toString()} + ${menu.title?.toString()} + ${menu.summary?.toString()}`;
          } else {
            return menu.toString();
          }
        });
      }
      .backgroundColor(this.style?.backgroundColor)
      .friction(FRICTION_FACTOR)
      .cachedCount(DEFAULT_CACHE_COUNT)
      .divider({
        strokeWidth: this.getListStrokeWidth() > 1 ? this.style?.divider?.strokeWidth as Length : 0,
        color: this.style?.divider?.color,
        startMargin: this.style?.divider?.startMargin,
        endMargin: this.style?.divider?.endMargin,
      })
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .lanes(this.style?.lanes as number)
      .borderRadius(this.style?.borderRadius as Length)
      .backgroundColor(this.style?.backgroundColor)
      .padding(this.style?.padding as Padding)
      .margin({
        top: this.style?.margin?.top ? this.style?.margin?.top : $r('app.float.margin_4'),
        left: this.style?.margin?.left,
        right: this.style?.margin?.right,
        bottom: this.style?.margin?.bottom
      })
    }
  }

  private getLazyMenus(): void {
    let menus = this.menusArray.menus;
    if (!menus) {
      menus = []
    }
    this.lazyMenus.refreshData(menus);
  }

  aboutToAppear(): void {
    this.getLazyMenus();
  }

  private getListStrokeWidth(): number {
    if (this.menusArray.menus.length <= 1) {
      return 0;
    }

    let num = this.menusArray.menus.filter((menu: SettingsBaseMenu) => {
      return menu.isVisible();
    }).length;
    return num;
  }
}

@Component
export struct MenuGroupComponent {
  tag: string = 'MenuGroupComponent : ';
  menuGroup?: MenuGroup;
  @State controller: MenuGroupController | undefined = undefined;
  groupStyle?: GridGroupStyle | Style;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      if (this.menuGroup instanceof GridMenuGroup) {
        MenuGridListComponent({ menusArray: this.menusArray, style: this.groupStyle, uiRefresher: $uiRefresher });
      } else {
        MenuListComponent({ menusArray: this.menusArray, style: this.groupStyle, uiRefresher: $uiRefresher });
      }
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  private getMenus(): MenusArray {
    let menus = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuGroup?.getMenus() as Array<SettingsBaseMenu>;
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${this.tag} getMenus ${menus.length}`);
    if (!this.menuGroup?.tabIndex || this.menuGroup?.tabIndex === TabIndexConstants.TAB_INDEX_DEFAULT) {
      return new MenusArray(menus);
    }
    let isFirstMenu: boolean = true;
    for (let i: number = 0; i < menus.length; i++) {
      if (menus[i] instanceof MenuGroup) {
        continue;
      }
      if (isFirstMenu && menus[i].isVisible() && menus[i].enable) {
        menus[i].tabIndex = this.menuGroup?.tabIndex;
        isFirstMenu = false;
      } else {
        menus[i].tabIndex = TabIndexConstants.TAB_INDEX_DEFAULT;
      }
    }
    return new MenusArray(menus);
  }

  aboutToAppear() {
    LogUtil.debug(`${this.tag} aboutToAppear length ${this.menuGroup?.getMenus().length}
    key : ${this.menuGroup?.getLogKey()}`);
    this.groupStyle = this.menuGroup?.style;

    this.controller = this.menuGroup?.getControllerInstance(this.uiRefresher) as MenuGroupController;
    this.menusArray = this.getMenus();
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menuGroup?.getLogKey()}`);
    if (this.controller) {
      this.controller.aboutToDisappear();
    }
  }
}

@Component
export struct MenuItemComponent {
  tag: string = 'MenuItemComponent : ';
  menu?: SettingsBaseMenu;
  @State uiRefresher: UiRefresher = new UiRefresher();
  isMenuFlat: boolean = false;

  build() {
    if (this.menu) {
      if (this.menu.menuType === MenuType.NAVIGATOR_ENTRY) {
        NavigatorEntryMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.SWITCH) {
        if (FontScaleUtils.isExtraLargeFontMode()) {
          SwitchMenuLargeComponent({ menu: this.menu });
        } else {
          SwitchMenuComponent({ menu: this.menu });
        }
      } else if (this.menu.menuType === MenuType.RECOVERY_KEY_SWITCH) {
        LinkSwitchMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.RECOVERY_KEY_TEXT) {
        HwAccountInfoTextMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.SHEET) {
        SheetMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.SINGLE_CHOOSE) {
        SingleChooseComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.ENTRY) {
        if (this.isMenuFlat) {
          FlatEntryMenuComponent({ menu: this.menu });
        } else {
          EntryMenuComponent({ menu: this.menu });
        }
      } else if (this.menu.menuType === MenuType.NAVIGATION_ENTRY) {
        NavEntryMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.NAVIGATION_PAIR_ENTRY) {
        NavPairEntryMenuComponent({ menu: this.menu as BasePairEntryMenu });
      } else if (this.menu.menuType === MenuType.NAVIGATION_INFO_ENTRY) {
        NavInfoEntryMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.STATE) {
        StateMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.PERMISSION) {
        PermissionMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.SECOND) {
        SecondMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.SLIDER) {
        SliderMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.PC_SLIDER) {
        SliderPCMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.IMAGE) {
        ImageMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.RINGTONE_IMAGE) {
        RingToneImageComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.TEXT_INPUT) {
        TextInputMenuComponent({ menu: this.menu as BaseTextInputMenu });
      } else if (this.menu.menuType === MenuType.CHAINED_TEXT_INPUT) {
        ChainedTextInputMenuComponent({ menu: this.menu as BaseTextInputMenu });
      } else if (this.menu.menuType === MenuType.CONNECT_BUTTON) {
        ConnectButtonMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.BUTTON) {
        if (FontScaleUtils.isExtraLargeFontMode()) {
          ButtonMenuLargeComponent({ menu: this.menu });
        } else {
          ButtonMenuComponent({ menu: this.menu });
        }
      } else if (this.menu.menuType === MenuType.DIVIDE_BUTTON) {
        if (FontScaleUtils.isExtraLargeFontMode()) {
          DivideButtonMenuLargeComponent({ menu: this.menu as BaseButtonMenu });
        } else {
          DivideButtonMenuComponent({ menu: this.menu as BaseButtonMenu });
        }
      } else if (this.menu.menuType === MenuType.TRANSPARENT_BUTTON) {
        if (FontScaleUtils.isExtraLargeFontMode()) {
          TransparentButtonMenuLargeComponent({ menu: this.menu as BaseButtonMenu });
        } else {
          TransparentButtonMenuComponent({ menu: this.menu as BaseButtonMenu });
        }
      } else if (this.menu.menuType === MenuType.RADIO) {
        RadioMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.MULTI_CHECKBOX) {
        MultiCheckboxMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.SELECT_IMAGE) {
        SelectImageMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.CARD_RADIO) {
        CardRadioMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.EMAIL_RADIO) {
        EmailRadioMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.CARD_ICON_RADIO) {
        BrowserRadioMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.COALESCE_RADIO) {
        CoalesceRadioMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.CIRCLE) {
        CircleMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.DATA_PANEL_CIRCLE) {
        DataPanelCircleMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.VERTICAL_BUTTON) {
        VerticalButtonMenuComponent({ menu: this.menu as BaseButtonMenu });
      } else if (this.menu.menuType === MenuType.SPACE) {
        SimpleSpaceComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.SIMPLE_SPACE) {
        SimpleSpaceComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.DIVIDER) {
        DividerMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.LOADING) {
        LoadingMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.BT_LOADING) {
        BtLoadingComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.PAGE_TITLE) {
        HeaderComponent({
          menuKey: this.menu.key,
          title: this.menu.title,
          isShowBack: false,
          style: this.menu.style,
          uiRefresher: $uiRefresher,
          isStartAbility: false,
        });
      } else if (this.menu.menuType === MenuType.TEXT) {
        TextMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.TEXT_LIST) {
        TextListMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.ROW_TEXT) {
        RowTextMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.EDIT) {
        EditComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.PASSWORD_CIRCLE) {
        PasswordCircleMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.PASSWORD_PATTERN) {
        PatternPasswordMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.UNDERLINE_TEXT_INPUT) {
        UnderLineTextInputMenuComponent({ menu: this.menu as UnderLineTextInputBaseMenu });
      } else if (this.menu.menuType === MenuType.PSD_UNDERLINE_TEXT_INPUT) {
        PasswordUnderLineTextInputMenuComponent({ menu: this.menu as UnderLineTextInputBaseMenu });
      } else if (this.menu.menuType === MenuType.SELECT_ENTRY) {
        SelectEntryMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.CHECKBOX) {
        CheckboxMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.CHECKBOX_OPTION) {
        CheckboxOptionMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.CHECKBOX_DIALOG_PC) {
        PcCheckboxMenuDiaLogComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.CHECKBOX_DIALOG_PHONE) {
        PhoneCheckboxMenuDiaLogComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.BUTTON_WITH_VARIABLE_TITLE) {
        ButtonWithVariableTitleMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.NAVIGATION_MENU_ENTRY) {
        NavigationEntryMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.NAVIGATION_CHECKBOX_MENU) {
        NavigationCheckboxMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.UNDERLINE_EDIT) {
        UnderLineEditMenuComponent({ menu: this.menu as UnderLineTextInputBaseMenu });
      } else if (this.menu.menuType === MenuType.CANVAS) {
        CanvasMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.SWIPER) {
        if (IS_DEVICE_PAD) {
          PadSwiperMenuComponent({ menu: this.menu });
        }
      } else if (this.menu.menuType === MenuType.THEME_EDITOR_MENU) {
        if (IS_DEVICE_PC) {
          ThemeEditorPcMenuComponent({ menu: this.menu });
        }
      } else if (this.menu.menuType === MenuType.THEME_EDITOR_ICON_STYLE_MENU ||
        this.menu.menuType === MenuType.THEME_EDITOR_FONT_STYLE_MENU) {
      } else if (this.menu.menuType === MenuType.WALLPAPER_PREVIEW) {
        PadWallpaperPreviewMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.SELECT) {
        SingleChoiceMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.WIFI_PRECISION) {
        WifiPrecisionComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.WIFI_HILINK) {
        WifiHilinkComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.DATE_ZONE) {
        DateZoneComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.PARAGRAPH) {
        ParagraphComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.ICON_RADIO) {
        IconRadioMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.QRCODE) {
        QrcodeComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.CONNECTED_HOT_SPORT) {
        ConnectedHotSportComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.TEXT_TIPS) {
        TextTipsComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.WLAN_QRCODE_COMPONENT) {
        WLANQRCodeComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.BATTERY_SAVING_MODE_SWITCH) {
        BatterySavingModeSwitchMenuComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.BATTERY_MP_CHART_COMPONENT) {
        BatteryMpChartComponent({ menu: this.menu });
      } else if (this.menu.menuType === MenuType.HDC_AUTHORIZATION_COMPONENT) {
        HdcAuthorizationButtonSwitchComponent({ menu: this.menu });
      }
    }
  }
}

@Component
export struct SettingHomeMenuItemComponent {
  tag: string = 'SettingHomeMenuItemComponent : ';
  menu?: SettingsBaseMenu;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    SettingHomeEntryMenuComponent({ menu: this.menu });
  }
}

@Component
export struct WifiMenuGroupComponent {
  tag: string = 'WifiMenuGroupComponent : ';
  menuSection: MenuSection | undefined;
  style: CardSectionListStyle = cardSectionListStyle;
  controller: MenuController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State lazyWifiMenus: MenuDataSource = new MenuDataSource([])
  COUNT_EMPTY: number = 0;

  uiRefresherWatch(): void {
    this.getWifiMenus();
  }

  build() {
    Column() {
      Column() {
        if (this.menuSection?.getHeader()) {
          MenuGroupItemComponent({ menuGroup: this.menuSection.getHeader() });
        }
      }

      Column() {
        Column() {
          if (this.lazyWifiMenus.totalCount() > this.COUNT_EMPTY) {
            List() {
              LazyForEach(this.lazyWifiMenus, (menu: SettingsBaseMenu) => {
                ListItem() {
                  WifiEntryComponent({
                    menu: menu as SettingsBaseMenu,
                    style: menu.style as DefaultEntryMenuStyle,
                    showTitle: menu.title?.toString(),
                  });
                }
                .backgroundColor(this.style?.backgroundColor)
              }, (menu: SettingsBaseMenu) => {
                return menu.toString();
              });
            }
            .backgroundColor(this.style?.backgroundColor)
            .cachedCount(DEFAULT_CACHE_COUNT)
            .edgeEffect(EdgeEffect.None)
            .scrollBar(BarState.Off)
            .divider({
              strokeWidth: this.style?.divider?.strokeWidth ?? 0,
              color: this.style?.divider?.color,
              startMargin: this.style?.divider?.startMargin,
              endMargin: this.style?.divider?.endMargin,
            })
            .alignSelf(ItemAlign.Start)
            .clip(true)
            .lanes(this.style?.lanes)
            .borderRadius(this.style?.borderRadius)
            .padding({
              top: $r('app.float.padding_4'),
              bottom: $r('app.float.padding_4'),
            })
            // 只有一个Ap时，可能是“添加其他网络”的占位，所以这种情况，也不展示列表。
            .visibility((this.uiRefresher.isVisible() && this.lazyWifiMenus.totalCount() > this.COUNT_EMPTY &&
              this.lazyWifiMenus.getData(0)?.key) ? Visibility.Visible : Visibility.None);
          }
        }
        .padding({
          bottom: $r('app.float.margin_24')
        })
      }
      .size({ width: '100%' })

      Column() {
        if (this.menuSection?.getFooter()) {
          MenuGroupItemComponent({ menuGroup: this.menuSection?.getFooter() });
        }
      }
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getWifiMenus(): void {
    let menus = this.menuSection?.getMenus() ?? [];
    LogUtil.info(`${this.tag} get app list, size:  ${menus.length}`);
    this.lazyWifiMenus.refreshData(menus);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear ${this.menuSection?.getLogKey()}`);
    this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuController;
    this.getWifiMenus();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}


@Component
export struct PcHotSpotListComponent {
  tag: string = 'PcHotSpotListComponent : ';
  menuSection: MenuSection | undefined;
  style: CardSectionListStyle = cardSectionListStyle;
  controller: MenuController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State lazyHotSpotMenus: MenuDataSource = new MenuDataSource([])

  uiRefresherWatch(): void {
    this.getHotSpotMenus();
  }

  build() {
    Column() {
      Column() {
        if (this.menuSection?.getHeader()) {
          MenuGroupItemComponent({ menuGroup: this.menuSection.getHeader() });
        }
      }
      .margin({
        bottom: $r('app.float.margin_4')
      })

      Column() {
        Column() {
          if (this.lazyHotSpotMenus.totalCount() > 0) {
            List() {
              LazyForEach(this.lazyHotSpotMenus, (menu: SettingsBaseMenu) => {
                ListItem() {
                  if (!menu.summary) {
                    ReusableHotSpotEntryComponent({
                      menu: menu as SettingsBaseMenu,
                      style: menu.style as DefaultEntryMenuStyle,
                      showTitle: menu.title?.toString(),
                    })
                  } else {
                    HotSpotFlatEntryMenuComponent({ menu: menu })
                  }
                }
                .backgroundColor(this.style?.backgroundColor)
              }, (menu: SettingsBaseMenu) => {
                return menu.toString();
              });
            }
            .backgroundColor(this.style?.backgroundColor)
            .cachedCount(DEFAULT_CACHE_COUNT)
            .edgeEffect(EdgeEffect.None)
            .scrollBar(BarState.Off)
            .divider({
              strokeWidth: this.style?.divider?.strokeWidth ?? 0,
              color: this.style?.divider?.color,
              startMargin: this.style?.divider?.startMargin,
              endMargin: this.style?.divider?.endMargin,
            })
            .alignSelf(ItemAlign.Start)
            .clip(true)
            .lanes(this.style?.lanes)
            .borderRadius(this.style?.borderRadius)
            .padding({
              top: $r('app.float.padding_4'),
              bottom: $r('app.float.padding_4'),
            })
            .visibility((this.uiRefresher.isVisible() && this.lazyHotSpotMenus.totalCount() > 0) ?
            Visibility.Visible : Visibility.None);
          }
        }
      }
      .size({ width: '100%' })
    }
    .visibility((this.uiRefresher.isVisible() && this.lazyHotSpotMenus.totalCount() > 0) ?
    Visibility.Visible : Visibility.None);
  }

  private getHotSpotMenus(): void {
    let menus: SettingsBaseMenu[] = this.menuSection?.getMenus() ?? [];
    LogUtil.info(`${this.tag} get hotspot list, size:  ${menus.length}`);
    this.lazyHotSpotMenus.refreshData(menus);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear ${this.menuSection?.getLogKey()}`);
    this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuController;
    this.getHotSpotMenus();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct HotSpotFlatEntryMenuComponent {
  tag: string = 'FlatEntryMenuComponent : ';
  @State menu: SettingsBaseMenu | undefined = undefined;
  style: DefaultEntryMenuStyle | undefined = undefined;
  controller: MenuController | undefined = undefined;
  uiRefresher: UiRefresher = new UiRefresher();

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(this.style?.rootContainer?.borderRadius ?? $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius(this.style?.rootContainer?.borderRadius ?? $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  build() {
    TitleSummaryImageEntryComponent({
      menu: $menu,
      style: this.style,
      controller: this.controller,
      uiRefresher: this.uiRefresher,
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} HotSpotFlatEntryMenuComponent aboutToAppear`);
    this.style = this.menu?.style as DefaultEntryMenuStyle;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct PcUsersListComponent {
  tag: string = 'PcUsersListComponent : ';
  menuSection: MenuSection | undefined;
  style: CardSectionListStyle = cardSectionListStyle;
  controller: MenuController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State lazyUsersMenus: MenuDataSource = new MenuDataSource([])

  uiRefresherWatch(): void {
    this.getUsersMenus();
  }

  build() {
    Column() {
      Column() {
        if (this.menuSection?.getHeader()) {
          MenuGroupItemComponent({ menuGroup: this.menuSection.getHeader() });
        }
      }
      .margin({
        bottom: $r('app.float.margin_4')
      })

      Column() {
        Column() {
          if (this.lazyUsersMenus.totalCount() > 0) {
            List() {
              LazyForEach(this.lazyUsersMenus, (menu: SettingsBaseMenu) => {
                ListItem() {
                  if (menu.extra) {
                    ReusableUsersEntryComponent({
                      menu: menu as SettingsBaseMenu,
                      style: menu.style as DefaultEntryMenuStyle,
                      showTitle: menu.title,
                    })
                  } else {
                    MenuItemComponent({ menu: menu });
                  }
                }
                .backgroundColor(this.style?.backgroundColor)
              }, (menu: SettingsBaseMenu) => {
                return menu.toString();
              });
            }
            .backgroundColor(this.style?.backgroundColor)
            .cachedCount(DEFAULT_CACHE_COUNT)
            .edgeEffect(EdgeEffect.None)
            .scrollBar(BarState.Off)
            .divider({
              strokeWidth: this.style?.divider?.strokeWidth ?? 0,
              color: this.style?.divider?.color,
              startMargin: this.style?.divider?.startMargin,
              endMargin: this.style?.divider?.endMargin,
            })
            .alignSelf(ItemAlign.Start)
            .clip(true)
            .lanes(this.style?.lanes)
            .borderRadius(this.style?.borderRadius)
            .padding({
              top: $r('app.float.padding_4'),
              bottom: $r('app.float.padding_4'),
            })
            .visibility((this.uiRefresher.isVisible() && this.lazyUsersMenus.totalCount() > 0) ?
            Visibility.Visible : Visibility.None);
          }
        }
      }
      .size({ width: '100%' })
    }
    .visibility((this.uiRefresher.isVisible() && this.lazyUsersMenus.totalCount() > 0) ?
    Visibility.Visible : Visibility.None);
  }

  private getUsersMenus(): void {
    let menus: SettingsBaseMenu[] = this.menuSection?.getMenus() ?? [];
    LogUtil.info(`${this.tag} get Users list, size:  ${menus.length}`);
    this.lazyUsersMenus.refreshData(menus);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear ${this.menuSection?.getLogKey()}`);
    this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuController;
    this.getUsersMenus();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}
