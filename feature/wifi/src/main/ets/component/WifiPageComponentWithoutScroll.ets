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

/* instrument ignore file */
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import emitter from '@ohos.events.emitter';
// import lazy { default as networkSharing } from '@hms.collaboration.networksharing';
import settings from '@ohos.settings';
import {
  MenuGroup,
  MenuPage,
  MenuSection,
  SettingsBaseMenu
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuController, MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { DialogPageRoot, PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { GroupStyle, PageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { HeaderPageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { MenuPageType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { MenuDataSource } from '@ohos/settings.common/src/main/ets/core/model/datasource/MenuDataSource';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';
import {
  EVENT_ID_WLAN_LIST_COLLAPSE_STATE_CHANGE,
  EVENT_ID_WLAN_LIST_COLLAPSE_STATE_RESET
} from '@ohos/settings.common/src/main/ets/event/types';
import { FOCUS_BOX_PADDING_METRICS, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  CardSectionStyle,
  defaultNavPageHeaderStyle,
  defaultPageHeaderStyle,
  DialogPageBuilder,
  HeaderComponent,
  MenusArray,
  NavHeaderComponent,
  pcDefaultNavPageHeaderStyle,
} from '@ohos/settings.uikit';
import {
  WIFI_CLOUD_SECURITY_CHECK,
  WIFI_CLOUD_SECURITY_ENABLED,
  WIFI_CLOUD_SECURITY_DISABLED,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { WifiSwitchController } from '../controller/WifiSwitchController';
import { WifiWindowItemComponent } from './WifiWindowItemComponent';
import { WifiManager } from '../WifiManager';
import { apConnectManager } from '../WifiTracker';
import { sharedNetworkTracker } from '../SharedNetworkTracker';

const TAG: string = 'WifiPageComponentWithoutScroll : ';
const GRID_COUNT_4: number = 4;
const COLUMN_LAYOUT_DEFAULT_NUM: number = 12;
const COLUMN_LAYOUT_DEFAULT_SPACE: string = '12vp';
const COLUMN_LAYOUT_DEFAULT_SIDE: string = '0vp';
const RELATIVE_LENGTH: string = '100%';
const LIST_CONTENT_HEIGHT: string = 'calc(100% - 32vp)';
const COUNT_EMPTY: number = 0;
const DEFAULT_CACHE_COUNT: number = 3;
const LIST_COUNT_1: number = 1;
const OFFSET_0: number = 0;
const OFFSET_2: number = 2;
const OFFSET_8: number = 8;
const USED_WIFI_CONNECT_COMPONENT_MENU_KEYS: string[] = ['wifi_connected_ap_group', 'wifi_page_connected_group'];
const USED_WIFI_LIST_COMPONENT_MENU_KEYS: string[] = ['wifi_list_group', 'wifi_window_list_group'];
const USED_SHARED_NETWORK_COMPONENT_MENU_KEYS: string[] = ['shared_network_ap_group', 'shared_network_available_group'];
const HOTSPOT_WINDOW_LIST_GROUP: string = 'hotSpot_window_list_group';
const SPAN_8: number = 8;
const SPAN_12: number = 12;
const OPACITY_PERCENT_FULL: number = 1;
const ALPHA_DISABLED: Resource = $r('sys.float.ohos_id_alpha_disabled');
const WLAN_CONNECTING_STATE: number = 1;
const WLAN_DISCONNECTING_STATE: number = -1;
const MORE_WIFI_SETTINGS_BUTTON_LEFT_MARGIN: string = '3.68vp';
const MORE_WIFI_SETTINGS_BUTTON_RIGHT_MARGIN: string = '4vp';
const MORE_WIFI_SETTINGS_BUTTON_BOTTOM_MARGIN: string = '3.15vp';
const ENTER_EXTERNAL_ENTRY: string = 'enter_external_entry';

export interface DeviceInfo {
  userName: string,
  deviceName: string,
  networkId: string,
  deviceConnectionState: DeviceConnectionState,
  networkState: NetworkState,
  errorResult: ErrorResult,
};

export enum NetworkState {
  INACTIVE = 0,
  ACTIVE = 1
};

export enum DeviceConnectionState {
  IDLE = 0,
  CONNECTING = 1,
  CONNECTED = 2,
  FAILED = 3,
  OFFLINE = 4,
};

export enum ErrorResult {
  SUCCESS = 0,
  ERR_NO_RESOURCE = 1,
  ERR_BUS_FAILURE = 2,
  ERR_ACTIVATION_FAILURE = 3,
  ERR_ROUTE_FAILURE = 4,
  NETWORK_ERROR_FAILED_MSG = 100,
  NETWORK_ERROR_DATA_NOT_ENABLED = 200,
  NETWORK_ERROR_SUB_SWITCH_OFF = 210,
  NETWORK_ERROR_UNAVAILABLE = 220,
};

@Component
export struct WifiPageComponentWithoutScroll {
  @State menuPage: MenuPage | undefined = undefined;
  @State pageStyle: PageStyle | undefined = undefined;
  @State navPageStyle: HeaderPageStyle | undefined = undefined;
  @State controller: MenuController | undefined = undefined;
  dialog: DialogPageRoot | undefined = new DialogPageRoot();
  autoCancelDialogController: CustomDialogController | undefined = new CustomDialogController({
    builder: DialogPageBuilder({ pageRoot: this.dialog }),
    cancel: this.dialog?.onSelfCancelBindThis,
    gridCount: GRID_COUNT_4,
    autoCancel: true,
    customStyle: true,
    offset: { dx: OFFSET_0, dy: OFFSET_8 },
  });
  dialogController: CustomDialogController | undefined = new CustomDialogController({
    builder: DialogPageBuilder({ pageRoot: this.dialog }),
    cancel: this.dialog?.onSelfCancelBindThis,
    gridCount: GRID_COUNT_4,
    autoCancel: false,
    customStyle: true,
  });
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;

  uiRefresherWatch(): void {
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      GridContainer({ columns: COLUMN_LAYOUT_DEFAULT_NUM, sizeType: SizeType.MD,
        gutter: COLUMN_LAYOUT_DEFAULT_SPACE, margin: COLUMN_LAYOUT_DEFAULT_SIDE }) {
        Column() {
          if (this.menuPage) {
            Column() {
              if (this.menuPage.menuType === MenuPageType.HEADER_PAGE && this.menuPage.isNavigation) {
                NavHeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  targetPageUrl: this.menuPage.targetPageUrl,
                  isShowBack: this.menuPage.isShowBack,
                  isShowAbout: this.menuPage.isShowAbout,
                  style: this.pageStyle instanceof HeaderPageStyle ? this.navPageStyle?.pageHeaderStyle :
                    defaultNavPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                  showALL: this.menuPage.showHeader,
                });
              } else if (this.menuPage.menuType === MenuPageType.PC_HEADER_PAGE && this.menuPage.isNavigation) {
                NavHeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  targetPageUrl: this.menuPage.targetPageUrl,
                  isShowBack: this.menuPage.isShowBack,
                  isShowAbout: this.menuPage.isShowAbout,
                  style: this.pageStyle instanceof HeaderPageStyle ? this.navPageStyle?.pageHeaderStyle :
                    pcDefaultNavPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                  showALL: this.menuPage.showHeader,
                });
              } else if (this.menuPage.menuType === MenuPageType.HEADER_PAGE) { // 页描述
                HeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  targetPageUrl: this.menuPage.targetPageUrl,
                  isShowBack: this.menuPage.isShowBack,
                  isShowAbout: this.menuPage.isShowAbout,
                  style: this.pageStyle instanceof HeaderPageStyle ? this.pageStyle.pageHeaderStyle :
                    defaultPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                });
              }
            }

            Flex({
              direction: FlexDirection.Column,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center,
            }) {
              Column() {
                if (this.menuPage.getHeader()) {
                  WifiGroupMenuComponent({ menuGroup: this.menuPage.getHeader() })
                }
              }
              .flexShrink(0);

              Column() {
                ForEach(this.menusArray?.menus, (menu: SettingsBaseMenu) => {
                  if (menu.isVisible()) {
                    if (menu instanceof MenuSection) {
                      if (USED_WIFI_CONNECT_COMPONENT_MENU_KEYS.includes(menu.key as string)) {
                        WifiConnectedComponent({ menuSection: menu });
                      } else if (USED_SHARED_NETWORK_COMPONENT_MENU_KEYS.includes(menu.key as string)) {
                        SharedNetworkComponent({ menuSection: menu });
                      } else if (USED_WIFI_LIST_COMPONENT_MENU_KEYS.includes(menu.key as string)) {
                        WifiListComponent({ menuSection: menu });
                      } else if (HOTSPOT_WINDOW_LIST_GROUP === menu.key) {
                        PcWindowHotSpotListComponent({ menuSection: menu })
                      }
                    }
                  }
                }, (menu: SettingsBaseMenu) => {
                  return menu.toString();
                });
              }
              // set wifi connect and list menu height
              .height('calc(100% - 102vp)')
              .width(RELATIVE_LENGTH);

              Column() {
                // 页尾
                if (this.menuPage.getFooter()) {
                  WifiGroupMenuComponent({ menuGroup: this.menuPage.getFooter() });
                }
              }
              .flexShrink(0);
            }
            .width(RELATIVE_LENGTH);
          }
        }
        .height(RELATIVE_LENGTH)
        .useSizeType({
          xs: { span: SPAN_12, offset: OFFSET_0 },
          sm: { span: SPAN_12, offset: OFFSET_0 },
          md: { span: SPAN_12, offset: OFFSET_0 },
          lg: { span: SPAN_8, offset: OFFSET_2 },
        })
      }
      .size({ width: RELATIVE_LENGTH, height: RELATIVE_LENGTH });
    }
    .size(this.pageStyle?.size)
    .clip(this.pageStyle?.clip)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenus(): MenusArray {
    let menus: SettingsBaseMenu[] = [];
    if (this.controller?.menu instanceof MenuSection || this.controller?.menu instanceof MenuGroup) {
      menus = this.controller?.menu?.getMenus();
    }
    if (!menus) {
      menus = this.menuPage?.getMenus() ?? [];
    }
    if (!menus) {
      menus = [];
    }
    return new MenusArray(menus);
  }

  aboutToAppear(): void {
    this.initDialog();

    if (!this.menuPage) {
      return;
    }

    if (this.menuPage.style instanceof PageStyle) {
      this.pageStyle = this.menuPage.style;
    }

    if (this.menuPage.navHeaderStyle instanceof PageStyle) {
      this.navPageStyle = this.menuPage.navHeaderStyle as HeaderPageStyle;
    }

    this.controller = this.menuPage.getControllerInstance(this.uiRefresher) as MenuController;
    this.menusArray = this.getMenus();

    let isChecked: boolean =
      SettingsDataUtils.getSettingsDataDomain(WIFI_CLOUD_SECURITY_CHECK, WIFI_CLOUD_SECURITY_DISABLED,
        settings.domainName.DEVICE_SHARED) === WIFI_CLOUD_SECURITY_ENABLED;
    WifiManager.getInstance().setWifiSecuritySwitchStatus(isChecked);
  }

  private initDialog(): void {
    // 弹框句柄
    this.dialog?.setDialogController(this.autoCancelDialogController, this.dialogController);
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setDialogPageRoot(this.dialog);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear `);
    this.controller?.aboutToDisappear();
    this.dialog?.setDialogController(undefined, undefined);
    this.dialog = undefined;
    this.autoCancelDialogController = undefined;
    this.dialogController = undefined;
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setDialogPageRoot(undefined);
    }
  }
}

@Component
export struct WindowDividerComponent {
  build() {
    Row() {
      Divider()
        .height(px2vp(1))
        .color($r('sys.color.ohos_id_color_list_separator'))
    }
    .width('100%')
    .height(9)
    .padding({
      top: $r('app.float.padding_4'),
      bottom: $r('app.float.padding_4'),
      left: $r('app.float.padding_24'),
      right: $r('app.float.padding_24'),
    })
  }
}

@Component
export struct SharedNetworkComponent {
  tag: string = 'SharedNetworkComponent : ';
  menuSection: MenuSection | undefined;
  style: GroupStyle | undefined = undefined;
  controller: MenuController | undefined = undefined;
  isRegister: boolean = false;
  @State lazyMenus: MenuDataSource = new MenuDataSource([]);
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();

  uiRefresherWatch(): void {
    this.getMenus();
  }

  private getMenus(): void {
    let menus = this.menuSection?.getMenus() ?? [];
    LogUtil.info(`${this.tag} get app list, size:  ${menus.length}`);
    this.style = this.menuSection?.style as GroupStyle;
    this.lazyMenus.refreshData(menus);
  }

  build() {
    Column() {
      Column() {
        Text(this.menuSection?.title)
          .titleTextStyles()
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .height($r('app.float.height_32'))
      .margin({
        left: $r('app.float.padding_24'),
        right: $r('app.float.padding_24'),
      })
      .visibility(this.isShowApView() && this?.lazyMenus?.mDataSource.length > 0 ?
      Visibility.Visible : Visibility.None);

      Column() {
        if (this.lazyMenus.totalCount() > COUNT_EMPTY) {
          List() {
            ForEach(this.lazyMenus.mDataSource, (menu: SettingsBaseMenu) => {
              ListItem() {
                WifiWindowItemComponent({ menu: menu });
              }
            }, (menu: SettingsBaseMenu) => {
              return JSON.stringify(menu.extra);
            });
          }
          .scrollBar(BarState.Off)
          .alignSelf(ItemAlign.Start)
          .clip(false)
          .lanes(this.style?.lanes)
          .padding({
            left: $r('sys.float.padding_level2'),
            right: $r('sys.float.padding_level2')
          })

          // show split lines
          WindowDividerComponent()
        }
      }
      .visibility(this.isShowApView() && this?.lazyMenus?.mDataSource.length > 0 ?
      Visibility.Visible : Visibility.Hidden);
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .visibility(this.isShowApView() && this?.lazyMenus?.mDataSource.length > 0 ?
    Visibility.Visible : Visibility.None);
  }

  private isShowApView(): boolean {
    return this.uiRefresher.isVisible() && this.lazyMenus.totalCount() > COUNT_EMPTY;
  }

  aboutToAppear(): void {
    if (this.menuSection) {
      LogUtil.info(`${this.tag} aboutToAppear ${this.menuSection.getLogKey()}`);
      this.controller = this.menuSection.getControllerInstance(this.uiRefresher) as MenuController;
      if (this.menuSection.style instanceof GroupStyle) {
        this.style = this.menuSection.style;
      }

      if (this.style instanceof CardSectionStyle) {
        this.style = this.style.listStyle;
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct WifiListComponent {
  tag: string = 'WifiListComponent : ';
  menuSection: MenuSection | undefined;
  style: GroupStyle | undefined;
  controller: MenuController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State lazyWifiMenus: MenuDataSource = new MenuDataSource([]);
  @State availableMenus: MenuDataSource = new MenuDataSource([]);
  scroller: Scroller = new Scroller;
  @State isListExpand: boolean = true;
  @State operationIcon: ResourceStr = $r('app.media.ic_arrow_down_light');
  @State isHover: boolean = false;

  uiRefresherWatch(): void {
    this.getWifiMenus();
    if (!this.uiRefresher.isVisible()) {
      this.isListExpand = true;
      this.operationIcon = $r('app.media.ic_arrow_down_light');
      this.sendCollapseStateResetEvent();
    }
  }

  build() {
    Column() {
      Row({ space: SPAN_12 }) {
        Column() {
          Text(this.menuSection?.title)
            .fontColor($r('app.color.statusbar_blend_color'))
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .advancedBlendMode(BlendModeUtil.getBlenderTertiary())
        }
        .constraintSize({
          minHeight: $r('app.float.length_24'),
        })
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)

        Column() {
          Image(this.operationIcon)
            .width($r('app.float.wh_value_24'))
            .height($r('app.float.wh_value_12'))
            .fillColor($r('app.color.statusbar_blend_color'))
            .advancedBlendMode(BlendModeUtil.getBlenderTertiary())
            .objectFit(ImageFit.Cover)
            .draggable(false)
        }
        .onHover((isHover) => {
          this.isHover = isHover;
        })
        .padding({
          top: $r('sys.float.padding_level3'),
          bottom: $r('sys.float.padding_level3')
        })
        .stateStyles({
          normal: {
            .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
          },
          pressed: pressedStyles
        })
        .borderRadius($r('sys.float.corner_radius_level2'))
        .onClick(() => {
          this.isListExpand = !this.isListExpand;
          this.isHover = false;
          if (this.isListExpand) {
            this.operationIcon = $r('app.media.ic_arrow_down_light');
          } else {
            this.operationIcon = $r('app.media.ic_arrow_up_light');
          }
          this.sendCollapseStateChangeEvent();
        })
      }
      .width('100%')
      .height($r('app.float.length_32'))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .padding({
        left: $r('app.float.margin_24'),
        right: $r('app.float.margin_24'),
      })
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);

      this.listBuilder()
    }
    .flexShrink(1)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  @Builder
  listBuilder() {
    Column() {
      if (this.lazyWifiMenus.totalCount() > COUNT_EMPTY) {
        List({ scroller: this.scroller }) {
          this.listContentBuilder()
        }
        .flexShrink(1)
        .cachedCount(DEFAULT_CACHE_COUNT)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(this.lazyWifiMenus.totalCount() <= LIST_COUNT_1 ? BarState.Off : BarState.Auto)
        .height(RELATIVE_LENGTH)
        .alignSelf(ItemAlign.Start)
        .clip(true)
        .lanes(this.style?.lanes)
        .padding({
          left: '3.5vp',
          right: $r('sys.float.padding_level2'),
        })
        .constraintSize((this.style as CardSectionStyle)?.listSize)
        .visibility(this.isListContentVisible() ? Visibility.Visible : Visibility.None);
      }
    }
    .flexShrink(1)
    .size({ width: RELATIVE_LENGTH, height: LIST_CONTENT_HEIGHT });
  }

  @Builder
  listContentBuilder() {
    LazyForEach(this.lazyWifiMenus, (menu: SettingsBaseMenu) => {
      ListItem() {
        WifiWindowItemComponent({ menu: menu });
      }
    }, (menu: SettingsBaseMenu) => {
      return menu.toString();
    });
  }

  private isListContentVisible(): boolean {
    return this.uiRefresher.isVisible() && this.lazyWifiMenus.totalCount() > COUNT_EMPTY && this.isListExpand;
  }

  private getWifiMenus(): void {
    let menus = this.menuSection?.getMenus() ?? [];
    LogUtil.info(`${this.tag} get app list, size:  ${menus.length}`);
    this.style = this.menuSection?.style as GroupStyle;
    this.lazyWifiMenus.refreshData(menus);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear ${this.menuSection?.getLogKey()}`);
    this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuController;
    this.getWifiMenus();
    this.bindScroller();
    this.sendCollapseStateResetEvent();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
    this.sendCollapseStateResetEvent();
  }

  private sendCollapseStateChangeEvent(): void {
    emitter.emit({
      eventId: EVENT_ID_WLAN_LIST_COLLAPSE_STATE_CHANGE,
      priority: emitter.EventPriority.IMMEDIATE,
    }, {
      data: {
        'isListExpand': this.isListExpand,
      }
    });
  }

  private sendCollapseStateResetEvent(): void {
    emitter.emit({
      eventId: EVENT_ID_WLAN_LIST_COLLAPSE_STATE_RESET,
      priority: emitter.EventPriority.IMMEDIATE,
    });
  }

  private bindScroller(): void {
    let rootMenu = this.menuSection?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setScroller(this.scroller);
    }
  }
}

@Component
export struct WifiConnectedComponent {
  tag: string = 'WifiConnectedComponent : ';
  menuSection: MenuSection | undefined;
  style: GroupStyle | undefined = undefined;
  controller: MenuController | undefined = undefined;
  @State lazyWifiMenus: MenuDataSource = new MenuDataSource([]);
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();

  uiRefresherWatch(): void {
    if (apConnectManager.wifiConnectState !== WLAN_DISCONNECTING_STATE) {
      this.getMenus();
    }
  }

  build() {
    Column() {
      Column() {
        Text(this.menuSection?.title)
          .titleTextStyles()
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .height($r('app.float.height_32'))
      .margin({
        left: $r('app.float.padding_24'),
        right: $r('app.float.padding_24'),
      })
      .visibility(this.isShowConnectedApView() && this?.lazyWifiMenus?.mDataSource.length > 0 ?
      Visibility.Visible : Visibility.None);

      Column() {
        if (this.lazyWifiMenus.totalCount() > COUNT_EMPTY) {
          List() {
            ForEach(this.lazyWifiMenus.mDataSource, (menu: SettingsBaseMenu) => {
              ListItem() {
                WifiWindowItemComponent({ menu: menu });
              }
            }, (menu: SettingsBaseMenu) => {
              return menu.toString();
            });
          }
          .scrollBar(BarState.Off)
          .alignSelf(ItemAlign.Start)
          .clip(true)
          .lanes(this.style?.lanes)
          .padding({
            left: $r('sys.float.padding_level2'),
            right: $r('sys.float.padding_level2')
          })

          // show split lines
          WindowDividerComponent()
        }
      }
      .visibility(this.isShowConnectedApView() && this?.lazyWifiMenus?.mDataSource.length > 0 ?
      Visibility.Visible : Visibility.Hidden);
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .visibility(this.isShowConnectedApView() && this?.lazyWifiMenus?.mDataSource.length > 0 ?
    Visibility.Visible : Visibility.None);
  }

  private getMenus(): void {
    let menus = this.menuSection?.getMenus();
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${this.tag} getMenus ${menus.length},  key ${this.menuSection?.getLogKey()}`);
    this.lazyWifiMenus.refreshData(menus);
  }

  private isShowConnectedApView(): boolean {
    return (this.uiRefresher.isVisible() || (apConnectManager.wifiConnectState === WLAN_CONNECTING_STATE));
  }

  aboutToAppear(): void {
    if (this.menuSection) {
      LogUtil.info(`${this.tag} aboutToAppear ${this.menuSection.getLogKey()}`);
      this.controller = this.menuSection.getControllerInstance(this.uiRefresher) as MenuController;
      if (this.menuSection.style instanceof GroupStyle) {
        this.style = this.menuSection.style;
      }

      if (this.style instanceof CardSectionStyle) {
        this.style = this.style.listStyle;
      }
      this.getMenus();
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct PcWindowHotSpotListComponent {
  tag: string = 'PcHotSpotListComponent : ';
  menuSection: MenuSection | undefined;
  style: GroupStyle | undefined = undefined;
  controller: MenuController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State lazyHotSpotMenus: MenuDataSource = new MenuDataSource([])

  uiRefresherWatch(): void {
    this.getHotSpotMenus();
  }

  build() {
    Column() {
      Column() {
        Text(this.menuSection?.title)
          .titleTextStyles()
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .constraintSize({
        minHeight: $r('app.float.height_32')
      })
      .margin({
        left: $r('app.float.padding_24'),
        right: $r('app.float.padding_24'),
      })

      Column() {
        Column() {
          if (this.lazyHotSpotMenus.totalCount() > 0) {
            List() {
              LazyForEach(this.lazyHotSpotMenus, (menu: SettingsBaseMenu) => {
                ListItem() {
                  WifiWindowItemComponent({ menu: menu });
                }
              }, (menu: SettingsBaseMenu) => {
                return menu.toString();
              });
            }
            .cachedCount(DEFAULT_CACHE_COUNT)
            .edgeEffect(EdgeEffect.None)
            .scrollBar(BarState.Off)
            .alignSelf(ItemAlign.Start)
            .clip(true)
            .lanes(this.style?.lanes)
            .padding({
              left: $r('app.float.padding_3'),
              right: $r('app.float.padding_3'),
            })
            .visibility((this.uiRefresher.isVisible() && this.lazyHotSpotMenus.totalCount() > 0) ?
            Visibility.Visible : Visibility.None);
          }
        }

        WindowDividerComponent()
          .margin({top: $r('app.float.margin_negative_2')})
      }
      .size({ width: '100%' })

    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .visibility((this.uiRefresher.isVisible() && this.lazyHotSpotMenus.totalCount() > 0) ? Visibility.Visible :
    Visibility.None);
  }

  private getHotSpotMenus(): void {
    let menus: SettingsBaseMenu[] = this.menuSection?.getMenus() ?? [];
    LogUtil.info(`${this.tag} get hotspot list, size:  ${menus.length}`);
    this.lazyHotSpotMenus.refreshData(menus);
  }

  aboutToAppear(): void {
    if (this.menuSection) {
      AppStorage.SetOrCreate<boolean>('isWindowWifi', true);
      LogUtil.info(`${this.tag} aboutToAppear ${this.menuSection?.getLogKey()}`);
      this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuController;
      if (this.menuSection.style instanceof GroupStyle) {
        this.style = this.menuSection.style;
      }

      if (this.style instanceof CardSectionStyle) {
        this.style = this.style.listStyle;
      }
      this.getHotSpotMenus();
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct WifiGroupMenuComponent {
  tag: string = 'WifiGroupMenuComponent: ';
  menuGroup?: MenuGroup;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State controller?: MenuGroupController = undefined;
  @State menusArray?: MenusArray = undefined;

  @State moreSettingController?: Controller = undefined;
  @State moreSettingUiRefresher: UiRefresher = new UiRefresher();
  @State buttonMoreSettingBgColor: ResourceColor = Color.Transparent;

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    if (this.menusArray) {
      List() {
        ForEach(this.menusArray.menus, (menu: SettingsBaseMenu) => {
          if (menu && menu.isVisible()) {
            if (menu.key === 'wifi_switch') {
              WifiSwitchMenuComponent({ menu: menu })
            } else if (menu.key === 'more_wifi_settings_button') {
              this.moreSettingBuilder(menu)
            } else if (menu.key === 'more_wifi_settings_divider') {
              WindowDividerComponent()
            }
          }
        }, (menu: SettingsBaseMenu) => {
          return menu.toString();
        });
      }
      .scrollBar(BarState.Off)
      .alignSelf(ItemAlign.Start)
      .clip(true)
    }
  }

  @Builder
  moreSettingBuilder(menu?: SettingsBaseMenu) {
    if (menu) {
      Column() {
        Column() {
          Text(menu?.title)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('app.color.statusbar_blend_color'))
            .width('100%')
            .halfLeading(true)
            .advancedBlendMode(BlendModeUtil.getBlender())
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .padding({
          left: $r('sys.float.padding_level10'),
          right: $r('sys.float.padding_level10'),
          top: $r('sys.float.padding_level4'),
          bottom: $r('sys.float.padding_level4')
        })
        .constraintSize({
          minHeight: $r('app.float.height_40')
        })
        .width('100%')
        .borderRadius($r('sys.float.corner_radius_level6'))
        .backgroundColor(this.buttonMoreSettingBgColor)
        .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
        .enabled(menu.enable)
        .opacity(menu.enable ? 1 : $r('sys.float.interactive_disable'))
        .onHover((isHover?: boolean) => {
          this.onMoreSettingHoverEvent(isHover);
        })
        .onTouch((event?: TouchEvent) => {
          this.onMoreSettingTouchEvent(event);
        })
        .onMouse((event?: MouseEvent): void => {
          this.onMoreSettingMouseEvent(event)
        })
        .onClick((event) => {
          this.onMoreSettingClick();
        })
      }
      .margin({
        left: MORE_WIFI_SETTINGS_BUTTON_LEFT_MARGIN,
        right: MORE_WIFI_SETTINGS_BUTTON_RIGHT_MARGIN,
        bottom: MORE_WIFI_SETTINGS_BUTTON_BOTTOM_MARGIN
      })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
  }

  private onMoreSettingClick(): void {
    let bundleName: string = PackagesConstant.SETTINGS_BUNDLE_NAME;
    let abilityName: string = PackagesConstant.SETTINGS_MAIN_ABILITY_NAME;
    let navEntryKey: string = NavEntryKey.WIFI_ENTRY;
    let message: string = `bundleName: ${bundleName}, abilityName: ${abilityName}, navEntryKey: ${navEntryKey}`;
    HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.ENTER_SETTINGS_WIFI_PAGE);
    let want: Want = {
      bundleName: bundleName,
      abilityName: abilityName,
      uri: navEntryKey,
      parameters: {
        // 从更多设置进入wifi详情页
        fromMoreSetting: true
      }
    }
    LogUtil.info(`${this.tag} onMoreSettingClick startAbilityForResult ${message}`);
    (getContext(this) as common.UIExtensionContext).startAbility(want).then(() => {
      LogUtil.info(`${this.tag} startAbility success.`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${this.tag} startAbility fail, error = { code: ${error?.code}, message: ${error?.message} }.`);
    })
  }

  private onMoreSettingHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.buttonMoreSettingBgColor = $r('sys.color.ohos_id_color_hover');
    } else {
      this.buttonMoreSettingBgColor = Color.Transparent;
    }
  }

  private onMoreSettingTouchEvent(event?: TouchEvent): void {
    if (event && event.type === TouchType.Down) {
      this.buttonMoreSettingBgColor = $r('sys.color.ohos_id_color_click_effect');
    }
    if (event && event.type === TouchType.Up) {
      this.buttonMoreSettingBgColor = Color.Transparent;
    }
  }

  private onMoreSettingMouseEvent(event?: MouseEvent): void {
    if (event && event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.buttonMoreSettingBgColor = $r('sys.color.ohos_id_color_click_effect');
    } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.buttonMoreSettingBgColor = Color.Transparent;
    }
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
    return new MenusArray(menus);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear key: ${this.menuGroup?.getLogKey()}`);
    this.controller = this.menuGroup?.getControllerInstance(this.uiRefresher) as MenuGroupController;
    this.menusArray = this.getMenus();
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menuGroup?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct WifiSwitchMenuComponent {
  tag: string = 'WifiSwitchMenuComponent: ';
  @State controller?: WifiSwitchController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  menu?: SettingsBaseMenu;

  build() {
    if (this.menu) {
      this.titleWithSwitchBuilder(this.menu)
    }
  }

  @Builder
  titleWithSwitchBuilder(menu: SettingsBaseMenu) {
    Row() {
      Column() {
        Text(menu?.title)
          .visibility(this.uiRefresher?.refreshTitleId ? (menu?.title ? Visibility.Visible : Visibility.None) :
            (menu?.title ? Visibility.Visible : Visibility.None))
          .fontFamily('HarmonyHeiTi')
          .fontColor($r('app.color.statusbar_blend_color'))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .advancedBlendMode(BlendModeUtil.getBlender())
      }
      .margin({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      })
      .opacity((menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.uiRefresher.refreshId ?
        (this.controller?.getChecked() ?? false) : (this.controller?.getChecked() ?? false) })
        .id(`entry_toggle_${menu?.key}`)
        .onChange((isOn: boolean) => {
          this.controller?.onToggleChange(isOn);
        })
        .switchPointColor(menu?.enable ? $r('sys.color.ohos_id_color_foreground_contrary') :
        $r('sys.color.ohos_id_color_foreground_contrary_disable'))
        .switchStyle({unselectedColor: $r('sys.color.comp_background_secondary')})
        .hoverEffect(HoverEffect.None)
        .size({ width: $r('app.float.height_36'), height: $r('app.float.length_20') })
        .enabled(this.uiRefresher.refreshId ?
          (this.controller?.getToggleState() ?? false) : (this.controller?.getToggleState() ?? false))
        .margin({
          end: PADDING_24
        })
    }
    .width('100%')
    .height($r('app.float.height_48'))
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .margin({
      top: $r('sys.float.padding_level2'),
      bottom: $r('sys.float.padding_level2')
    })
    .enabled(menu?.enable ? true : false)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}, ${this.menu?.menuType}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as WifiSwitchController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Styles
function pressedStyles() {
  .backgroundColor($r('sys.color.interactive_click'))
  .borderRadius($r('sys.float.corner_radius_level2'))
}

@Extend(Text)
function titleTextStyles() {
  .fontColor($r('app.color.statusbar_blend_color'))
  .fontSize($r('sys.float.ohos_id_text_size_body2'))
  .fontWeight(FontWeight.Medium)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .textAlign(TextAlign.Center)
  .maxLines(1)
  .advancedBlendMode(BlendModeUtil.getBlenderTertiary())
}


