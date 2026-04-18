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

import display from '@ohos.display';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuPageType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { MenuGroup, MenuPage, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  ContainerStyle,
  GroupStyle,
  PageStyle
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { DialogPageRoot, PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { HeaderPageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayManager } from '@ohos/settings.common/src/main/ets/displaymanager/DisplayManager';
import { ExternalMenuPreloadManager } from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuPreloadManager';
import { MenuGroupController, PageController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { HeaderComponent, NavHeaderComponent, NavTitleHeaderComponent, SpaceComponent } from './BaseComponent';
import {
  MenuGroupItemComponent,
  MenuItemComponent,
  MenuLazyListComponent,
  MenuListComponent,
  MenusArray
} from './MenuGroupComponent';
import {
  defaultNavPageHeaderStyle,
  defaultPageHeaderStyle,
  pcDefaultNavPageHeaderStyle,
  PcWifiDialogPage,
} from '../menus/Menu';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
/* instrument ignore file */
const TAG: string = 'MenuPageComponent : ';
const GRID_COUNT_4: number = 4;
const GRID_COLUMN_COUNT: number = 12;
const MAX_HEIGHT_100_PERCENT: string = '100%';
const APPLICATION_PAGE_URL: string = 'pages/application/ApplicationSettings';
const FOLD_STATUS_FOLDED: number = 2;
let deviceType: string = DeviceUtil.deviceType;
const DEVICE_TYPE_PAD = 'tablet';
const DIALOG_WIDTH: number = 352;
const DIALOG_FOLDED_WIDTH: number = 313.6;
const DIALOG_EXPANDED_WIDTH: number = 400;
const OOBE_PAGE_KEY: string = 'pages/wifi/WifiSettings';
const BLUETOOTH_WINDOW_PAGE_URL: string = 'pages/bluetooth/BluetoothWindowSettings';
const WIFI_DIALOG_PAGE_URL: string = 'pages/wifi/WifiDialogSettings';
const THEME_PAGE_URL: string = 'pages/ThemePage';
const SCREEN_REFRESH_RATE_PAGE_URL: string = 'pages/display/ScreenRefreshRateSettings';
const THEME_COMPONENT_EXT_ABILITY: string = 'SettingThemeComponentExtAbility';

// 除了PC，其他都用系统弹框提供的样式
const dialogCustomStyle = DeviceUtil.isDevicePc();

@Component
export struct MenuPageComponent {
  @State menuPage?: MenuPage = undefined;
  @State pageStyle?: PageStyle = undefined;
  @State navPageStyle?: HeaderPageStyle = undefined;
  @State controller?: PageController = undefined;
  @State foldState: display.FoldStatus = DisplayUtils.getFoldStatus();
  scroller: Scroller = new Scroller();
  dialog: DialogPageRoot | undefined = new DialogPageRoot(); // 弹框页
  autoCancelDialogController: CustomDialogController | undefined = undefined;
  dialogController: CustomDialogController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;
  @Provide scrollDirection: ScrollDirection = ScrollDirection.Vertical;
  private isDialogShowInSubWindow: boolean = false;

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      if (this.menuPage) {
        GridContainer({ columns: 12, sizeType: SizeType.MD, gutter: '12vp', margin: '0vp' }) {
          Column() {
            if (this.menuPage.menuType === MenuPageType.HEADER_PAGE && this.menuPage.isNavigation) {
              Column() {
                NavHeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  targetPageUrl: this.menuPage.targetPageUrl,
                  isShowBack: this.menuPage.isShowBack,
                  isShowAbout: this.menuPage.isShowAbout,
                  isShowClose: this.menuPage.isShowClose,
                  titleMaxLine: this.menuPage.titleMaxLine,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.navPageStyle?.pageHeaderStyle : defaultNavPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                  showALL: this.menuPage.showHeader,
                });
              }.padding({
                top: this.menuPage.topAreaHeight ?? 0
              })
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            } else if (this.menuPage.menuType === MenuPageType.PC_HEADER_PAGE && this.menuPage.isNavigation) {
              Column() {
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
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            } else if (this.menuPage.menuType === MenuPageType.HEADER_PAGE) { // 页描述
              Column() {
                HeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  targetPageUrl: this.menuPage.targetPageUrl,
                  isShowBack: this.menuPage.isShowBack,
                  isShowAbout: this.menuPage.isShowAbout,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.pageStyle?.pageHeaderStyle : defaultPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                });
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            }

            Flex({
              direction: FlexDirection.Column,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center,
            }) {
              // 页头
              if (this.menuPage.getHeader()) {
                Column() {
                  MenuGroupItemComponent({ menuGroup: this.menuPage.getHeader() });
                  if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getHeader())) {
                    SpaceComponent({
                      space: this.menuPage?.key === OOBE_PAGE_KEY ? '0' : this.pageStyle?.space,
                      uiRefresher: $uiRefresher
                    });
                  }
                  if (this.menuPage?.key === OOBE_PAGE_KEY) {
                    Row() {
                      Divider()
                        .height($r('app.float.padding_8'))
                        .color($r('app.color.color_default_white'))
                    }
                    .width('100%')
                  }
                }
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                .padding(this.pageStyle?.padding as Padding)
                .flexShrink(0);
              }

              // 页中
              Column() {
                if (this.menuPage?.scrollable) {
                  Scroll(this.scroller) {
                    MenuListComponent({
                      menusArray: this.menusArray,
                      style: this.pageStyle?.listStyle,
                      uiRefresher: $uiRefresher,
                    })
                    .width('100%')
                    .padding({
                      left: this.pageStyle?.padding?.left,
                      right: this.pageStyle?.padding?.right,
                      top: this.pageStyle?.padding?.top,
                      bottom: (
                        this.menuPage.getFooter() ||
                          this.menuPage.menuType === MenuPageType.DIALOG_PAGE ||
                          this.menuPage.pageUrl === OOBE_PAGE_KEY
                      ) ? $r('app.float.padding_0') : $r('app.float.margin_16'),
                    })
                  }
                  .scrollable(this.scrollDirection)
                  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                  .borderRadius(this.menuPage.pageUrl ===
                    APPLICATION_PAGE_URL ? $r('app.float.border_radius_16') : $r('app.float.border_radius_0'))
                  .align(Alignment.TopStart)
                  .height(this.pageStyle?.listStyle?.height ?? '100%')
                  .edgeEffect(EdgeEffect.Spring)
                  .scrollBar(BarState.Auto)
                  .onScrollStart(() => {
                    LogUtil.info(`MenuPageComponent onScrollStart}`);
                    AppStorage.setOrCreate('ListScrollOn', true);
                  })
                  .onScrollStop(() => {
                    LogUtil.info(`MenuPageComponent onScrollStop}`);
                    AppStorage.setOrCreate('ListScrollOn', false);
                  })
                } else {
                  MenuListComponent({
                    menusArray: this.menusArray,
                    style: this.pageStyle?.listStyle,
                    uiRefresher: $uiRefresher,
                  })
                    .borderRadius($r('app.float.border_radius_0'))
                    .align(Alignment.TopStart)
                    .height(this.pageStyle?.listStyle?.height ?? '100%')
                    .padding({
                      left: this.pageStyle?.padding?.left,
                      right: this.pageStyle?.padding?.right,
                      top: this.pageStyle?.padding?.top,
                      bottom: this.menuPage.getFooter() ? $r('app.float.padding_0') : $r('app.float.margin_16')
                    });
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .padding({
                bottom: ((this.menuPage.menuType === MenuPageType.HEADER_PAGE && this.menuPage.showHeader) ||
                  this.menuPage.pageUrl === OOBE_PAGE_KEY) ? '68vp' : '0vp',
                left: (![WIFI_DIALOG_PAGE_URL, BLUETOOTH_WINDOW_PAGE_URL, THEME_PAGE_URL]
                  .includes(this.menuPage.pageUrl)) && DeviceUtil.isDevicePc() ?
                  $r('sys.float.ohos_id_default_padding_start') : '',
                right: ([SCREEN_REFRESH_RATE_PAGE_URL].includes(this.menuPage.pageUrl)) && DeviceUtil.isDevicePc() ?
                  $r('sys.float.ohos_id_default_padding_end') : '',
              })
              .width('100%')

              Column() {
                // 页尾
                if (this.menuPage.getFooter()) {
                  if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getFooter())) {
                    SpaceComponent({ space: this.pageStyle?.space, uiRefresher: $uiRefresher });
                  }
                  if (this.menuPage.getFooter().getKey() === 'wifi_password_button_group' ||
                    this.menuPage.getFooter().getKey() === 'key_add_other_wifi_button_group') {
                    MenuItemComponent({
                      menu: this.menuPage.getFooter().menus[0]
                    })
                  } else {
                    MenuGroupItemComponent({ menuGroup: this.menuPage.getFooter() })
                  }
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .padding(this.pageStyle?.padding as Padding)
            }
            .width('100%')
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .height('100%')
          .useSizeType({
            xs: { span: 12, offset: 0 },
            sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 },
            lg: { span: 8, offset: 2 }
          })
        }
        .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])
        .size({ width: '100%', height: '100%' })
      }
    }
    .padding(this.pageStyle?.pagePadding as Padding)
    .size(this.pageStyle?.size)
    .clip(this.pageStyle?.clip)
    .borderRadius(this.pageStyle?.borderRadius as Length)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  private getMenus(): MenusArray {
    let menus: SettingsBaseMenu[] | undefined = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuPage?.getMenus();
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  private registerFoldState(): void {
    try {
      display.on('foldStatusChange', (status: number) => {
        this.foldState = status;
        this.createDialogController();
      });
    } catch (e) {
      LogUtil.error(`${TAG} on foldStatusChangeCallback error error.code ${e?.code} error.message ${e?.message}`);
    }
  }

  private createDialogController() {
    this.autoCancelDialogController = new CustomDialogController({
      builder: DialogPageBuilder({ pageRoot: this.dialog }),
      cancel: this.dialog?.onSelfCancelBindThis,
      autoCancel: true,
      customStyle: dialogCustomStyle,
      alignment: DialogAlignment.Center,
      maskColor: $r('sys.color.ohos_id_color_mask_thin'),
      showInSubWindow: this.isDialogShowInSubWindow
    });
    this.dialogController = new CustomDialogController({
      builder: DialogPageBuilder({ pageRoot: this.dialog }),
      cancel: this.dialog?.onSelfCancelBindThis,
      autoCancel: false,
      customStyle: dialogCustomStyle,
      alignment: DialogAlignment.Center,
      maskColor: $r('sys.color.ohos_id_color_mask_thin'),
      showInSubWindow: this.isDialogShowInSubWindow
    });
    this.dialog?.setDialogController(this.autoCancelDialogController, this.dialogController); // 弹框句柄
  }

  aboutToAppear() {
    if (this.menuPage) {
      LogUtil.info(`${TAG} aboutToAppear length : ${this.menuPage.getMenus().length}`);
      this.createDialogController();
      this.setDialogPageRoot();
      this.bindScroller();
      this.registerFoldState();

      if (this.menuPage.style instanceof PageStyle) {
        this.pageStyle = this.menuPage.style;
      }

      if (this.menuPage.navHeaderStyle instanceof PageStyle) {
        this.navPageStyle = this.menuPage.navHeaderStyle as HeaderPageStyle;
      }

      this.controller = this.menuPage.getControllerInstance(this.uiRefresher) as PageController;
      this.menusArray = this.getMenus();
    }
  }

  private setDialogPageRoot(): void {
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu?.setDialogPageRoot(this.dialog);
    }
  }

  private bindScroller(): void {
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setScroller(this.scroller);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.controller?.aboutToDisappear();
    this.dialog?.closeSelf();
    this.dialog?.setDialogController(undefined, undefined);
    this.dialog = undefined;
    this.autoCancelDialogController = undefined;
    this.dialogController = undefined;
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu?.setDialogPageRoot(undefined);
    }
  }
}

@Component
export struct MenuPcPageComponent {
  @State menuPage?: MenuPage = undefined;
  @State pageStyle?: PageStyle = undefined;
  @State navPageStyle?: HeaderPageStyle = undefined;
  @State controller?: MenuGroupController = undefined;
  isWIFIUsed: boolean = false;
  scroller: Scroller = new Scroller();
  dialog: DialogPageRoot | undefined = new DialogPageRoot(); // 弹框页
  autoCancelDialogController: CustomDialogController | undefined = new CustomDialogController({
    builder: DialogPageBuilder({ pageRoot: this.dialog }),
    cancel: this.dialog?.onSelfCancelBindThis,
    gridCount: GRID_COUNT_4,
    autoCancel: true,
    customStyle: true,
    offset: { dx: 0, dy: 8 },
  });
  dialogController: CustomDialogController | undefined = new CustomDialogController({
    builder: DialogPageBuilder({ pageRoot: this.dialog }),
    cancel: this.dialog?.onSelfCancelBindThis,
    gridCount: GRID_COUNT_4,
    autoCancel: false,
    customStyle: true,
  });
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined; // remind-del-tag:可以考虑改为 new MenusArray([])
  @Provide scrollDirection: ScrollDirection = ScrollDirection.Vertical;

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      if (this.menuPage) {
        GridContainer({ columns: 12, sizeType: SizeType.MD, gutter: '12vp', margin: '0vp' }) {
          Column() {
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
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.pageStyle?.pageHeaderStyle : defaultPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                });
              }
            }

            Flex({
              direction: FlexDirection.Column,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center,
              wrap: FlexWrap.Wrap,
            }) {
              Column() {
                // 页头
                if (this.menuPage.getHeader()) {
                  MenuGroupItemComponent({ menuGroup: this.menuPage.getHeader() });
                  if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getHeader())) {
                    SpaceComponent({ space: this.pageStyle?.space, uiRefresher: $uiRefresher });
                  }
                }
              }
              .padding((this.menuPage.getHeader()?.key === 'bt_main_page_header_group' && DeviceUtil.isDevicePc()) ?
                { left: $r('app.float.margin_24'), right: $r('app.float.margin_16') } :
                { left: $r('app.float.margin_12'), right: $r('app.float.margin_24') }
              )
              .margin((this.menuPage.getHeader()?.key === 'bt_main_page_header_group' && DeviceUtil.isDevicePc()) ?
                { bottom: $r('app.float.margin_12') } : null
              )
              .flexShrink(0);

              // 页中
              Column() {
                Scroll(this.scroller) {
                  MenuListComponent({
                    menusArray: this.menusArray,
                    style: this.pageStyle?.listStyle,
                    uiRefresher: $uiRefresher,
                  });
                }
                .nestedScroll({
                  scrollForward: NestedScrollMode.PARENT_FIRST,
                  scrollBackward: NestedScrollMode.PARENT_FIRST
                })
                .borderRadius(this.menuPage.pageUrl ===
                  APPLICATION_PAGE_URL ? $r('app.float.border_radius_16') : $r('app.float.border_radius_0'))
                .align(Alignment.TopStart)
                .height('100%')
                .edgeEffect(EdgeEffect.Spring)
                .scrollBar(BarState.Auto)
                .border(this.isWIFIUsed ? {
                  width: $r('app.float.width_1_5'),
                  radius: $r('app.float.border_radius_16')
                } : {})
                .borderColor(this.isWIFIUsed ? '#F1F3F5' : '')
                .padding({
                  left: $r('app.float.margin_24'),
                  right: $r('app.float.margin_24'),
                  top: this.pageStyle?.padding?.top,
                  bottom: this.menuPage.getFooter() ? $r('app.float.padding_0') : $r('app.float.margin_24')
                });
              }
              .padding({
                bottom: this.menuPage.menuType === MenuPageType.HEADER_PAGE && this.menuPage.showHeader ? '68vp' : '0vp'
              })
              .width('100%')

              Column() {
                // 页尾
                if (this.menuPage.getFooter()) {
                  if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getFooter())) {
                    SpaceComponent({ space: this.pageStyle?.space, uiRefresher: $uiRefresher });
                  }
                  MenuGroupItemComponent({ menuGroup: this.menuPage.getFooter() });
                }
              }
              .padding({ left: $r('app.float.margin_12'), right: $r('app.float.margin_24') })
            }
            .width('100%')
          }

          .height('100%')
          .useSizeType({
            xs: { span: 12, offset: 0 },
            sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 },
            lg: { span: 8, offset: 2 }
          })
        }
        .size({ width: '100%', height: '100%' })
      }
    }
    .padding(this.pageStyle?.pagePadding as Padding)
    .size(this.pageStyle?.size)
    .clip(this.pageStyle?.clip)
    .borderRadius(this.pageStyle?.borderRadius as Length)
    .backgroundColor(DeviceUtil.isDevicePc() ? Color.Transparent : this.pageStyle?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenus(): MenusArray {
    let menus: SettingsBaseMenu[] | undefined = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuPage?.getMenus();
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  aboutToAppear() {
    if (this.menuPage) {
      LogUtil.info(`${TAG} aboutToAppear length : ${this.menuPage.getMenus().length}`);
      this.initDialog();
      this.bindScroller();

      if (this.menuPage.style instanceof PageStyle) {
        this.pageStyle = this.menuPage.style;
      }

      if (this.menuPage.navHeaderStyle instanceof PageStyle) {
        this.navPageStyle = this.menuPage.navHeaderStyle as HeaderPageStyle;
      }

      this.controller = this.menuPage.getControllerInstance(this.uiRefresher) as MenuGroupController;
      this.menusArray = this.getMenus();
    }
    try {
      ExternalMenuPreloadManager.getInstance().preloadUIExtensionAbility(THEME_COMPONENT_EXT_ABILITY, getContext());
    } catch (err) {
      LogUtil.warn(`${TAG} preload themeComponentExtAbilty failed, code: ${err?.code}, message: ${err?.message}`);
    }
  }

  private initDialog(): void {
    this.dialog?.setDialogController(this.autoCancelDialogController, this.dialogController); // 弹框句柄
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu?.setDialogPageRoot(this.dialog);
    }
  }

  private bindScroller(): void {
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setScroller(this.scroller);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.controller?.aboutToDisappear();
    this.dialog?.closeSelf();
    this.dialog?.setDialogController(undefined, undefined);
    this.dialog = undefined;
    this.autoCancelDialogController = undefined;
    this.dialogController = undefined;
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu?.setDialogPageRoot(undefined);
    }
  }
}

@Component
export struct MenuLazyListPageComponent {
  @State menuPage?: MenuPage = undefined;
  @State pageStyle?: PageStyle = undefined;
  @State controller?: PageController = undefined;
  @State navPageStyle?: HeaderPageStyle = undefined;
  scroller: Scroller = new Scroller;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      if (this.menuPage) {
        GridContainer({
          columns: GRID_COLUMN_COUNT,
          sizeType: this.menuPage.isOutPage ? SizeType.Auto : SizeType.MD,
          gutter: '12vp',
          margin: '0vp',
        }) {
          Column() {
            Column() {
              if (this.menuPage.menuType === MenuPageType.HEADER_PAGE && this.menuPage.isNavigation) {
                NavHeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  isShowBack: this.menuPage.isShowBack,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.navPageStyle?.pageHeaderStyle : defaultNavPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                  showALL: this.menuPage.showHeader,
                })
              } else if (this.menuPage.menuType === MenuPageType.PC_HEADER_PAGE && this.menuPage.isNavigation) {
                NavHeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  isShowBack: this.menuPage.isShowBack,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.navPageStyle?.pageHeaderStyle : pcDefaultNavPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                  showALL: this.menuPage.showHeader,
                });
              } else if (this.menuPage.menuType === MenuPageType.PC_HEADER_PAGE) {
                HeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  isShowBack: this.menuPage.isShowBack,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.pageStyle?.pageHeaderStyle : pcDefaultNavPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                });
              } else if (this.menuPage.menuType === MenuPageType.HEADER_PAGE) { // 页描述
                HeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  isShowBack: this.menuPage.isShowBack,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.pageStyle?.pageHeaderStyle : defaultPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                });
              }
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

            Flex({
              direction: FlexDirection.Column,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center,
              wrap: FlexWrap.Wrap,
            }) {
              Column() {
                // 页头
                if (this.menuPage.getHeader()) {
                  MenuGroupItemComponent({ menuGroup: this.menuPage.getHeader() });
                  if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getHeader())) {
                    SpaceComponent({ space: this.pageStyle?.space, uiRefresher: $uiRefresher });
                  }
                }
              }
              .padding((deviceType === 'tablet' || deviceType === '2in1') ? { left: '12vp', right: '24vp' } :
                { left: '12vp', right: '12vp' })
              .flexShrink(0);

              // 页中
              Column() {
                Scroll(this.scroller) {
                  MenuLazyListComponent({
                    menusArray: this.menusArray,
                    style: this.pageStyle?.listStyle,
                    uiRefresher: $uiRefresher,
                    scroller: this.scroller,
                  });
                }
                .align(Alignment.TopStart)
                .edgeEffect(EdgeEffect.Spring)
                .scrollBar((deviceType === 'tablet' || deviceType === '2in1') ? BarState.On : BarState.Auto)
                .padding((deviceType === 'tablet' || deviceType === '2in1') ? { left: '12vp', right: '24vp' } :
                  { left: '12vp', right: '12vp' })
              }
              .padding({
                bottom: this.menuPage.menuType === MenuPageType.HEADER_PAGE && this.menuPage.showHeader ? '68vp' : '0vp'
              })
              .width('100%')
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

              Column() {
                // 页尾
                if (this.menuPage.getFooter()) {
                  if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getFooter())) {
                    SpaceComponent({ space: this.pageStyle?.space, uiRefresher: $uiRefresher });
                  }
                  MenuGroupItemComponent({ menuGroup: this.menuPage.getFooter() });
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .padding((deviceType === 'tablet' || deviceType === '2in1') ? { left: '12vp', right: '24vp' } :
                { left: '12vp', right: '12vp' })
            }
            .width('100%')
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .height('100%')
          .useSizeType({
            xs: { span: 12, offset: 0 },
            sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 },
            lg: { span: 8, offset: 2 }
          })
        }
        .size({ width: '100%', height: '100%' })
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding(this.pageStyle?.pagePadding as Padding)
    .size(this.pageStyle?.size)
    .clip(this.pageStyle?.clip)
    .borderRadius(this.pageStyle?.borderRadius as Length)
    .backgroundColor(this.pageStyle?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenus(): MenusArray {
    let menus: SettingsBaseMenu[] | undefined = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuPage?.getMenus();
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  aboutToAppear(): void {
    if (this.menuPage) {
      LogUtil.info(`${TAG} aboutToAppear length : ${this.menuPage.getMenus().length}`);
      this.bindScroller();
      if (this.menuPage.style instanceof PageStyle) {
        this.pageStyle = this.menuPage.style;
      }

      if (this.menuPage.navHeaderStyle instanceof PageStyle) {
        this.navPageStyle = this.menuPage.navHeaderStyle as HeaderPageStyle;
      }

      this.controller = this.menuPage.getControllerInstance(this.uiRefresher) as PageController;
      this.menusArray = this.getMenus();
    }
  }

  private bindScroller(): void {
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setScroller(this.scroller);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear `);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct BottomMenuPageComponent {
  menuPage?: MenuPage;
  pageStyle?: PageStyle;
  @State controller?: PageController = undefined;
  scroller: Scroller = new Scroller;
  dialog: DialogPageRoot | undefined = new DialogPageRoot(); // 弹框页
  @State navPageStyle?: HeaderPageStyle = undefined;
  private isDialogShowInSubWindow: boolean = false;
  autoCancelDialogController: CustomDialogController | undefined = undefined;
  dialogController: CustomDialogController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      if (this.menuPage) {
        GridContainer({ columns: 12, sizeType: SizeType.MD, gutter: '12vp', margin: '0vp' }) {
          Column() {
            Column() {
              if (this.menuPage.menuType === MenuPageType.HEADER_PAGE && this.menuPage.isNavigation) {
                NavHeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  isShowBack: this.menuPage.isShowBack,
                  isShowClose: this.menuPage.isShowClose,
                  titleMaxLine: this.menuPage.titleMaxLine,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.navPageStyle?.pageHeaderStyle : defaultNavPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                  showALL: this.menuPage.showHeader,
                })
                  .padding({
                    top: this.menuPage.topAreaHeight ?? 0
                  });
              } else if (this.menuPage.menuType === MenuPageType.PC_HEADER_PAGE && this.menuPage.isNavigation) {
                NavHeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  isShowBack: this.menuPage.isShowBack,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.navPageStyle?.pageHeaderStyle : pcDefaultNavPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                  showALL: this.menuPage.showHeader,
                });
              } else if (this.menuPage.menuType === MenuPageType.HEADER_PAGE) { // 页描述
                HeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  isShowBack: this.menuPage.isShowBack,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                  this.pageStyle.pageHeaderStyle : defaultPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                });
              }
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

            Column() {
              Column() {
                // 页头
                if (this.menuPage.getHeader()) {
                  MenuGroupItemComponent({ menuGroup: this.menuPage.getHeader() });
                  if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getHeader())) {
                    SpaceComponent({ space: this.pageStyle?.space, uiRefresher: $uiRefresher });
                  }
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .padding((deviceType === 'tablet' || deviceType === '2in1') ? { left: '24vp', right: '24vp' } :
                { left: '16vp', right: '16vp' })
              .width('100%')

              Column() {
                // 页中
                Scroll(this.scroller) {
                  MenuListComponent({
                    menusArray: this.menusArray,
                    style: this.pageStyle?.listStyle,
                    uiRefresher: $uiRefresher,
                  });
                }
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                .height('100%')
                .padding((deviceType === 'tablet' || deviceType === '2in1') ? { left: '24vp', right: '24vp' } :
                  { left: '16vp', right: '16vp' })
                .align(Alignment.TopStart)
                .edgeEffect(EdgeEffect.Spring)
                .scrollBar((deviceType === 'tablet' || deviceType === '2in1') ? BarState.On : BarState.Auto)
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .width('100%')
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .width('100%')
            .flexShrink(1)

            Blank()

            Column() {
              // 页尾
              if (this.menuPage.getFooter()) {
                if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getFooter())) {
                  SpaceComponent({ space: this.pageStyle?.space, uiRefresher: $uiRefresher });
                }
                MenuGroupItemComponent({ menuGroup: this.menuPage.getFooter() });
              }
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .padding((deviceType === 'tablet' || deviceType === '2in1') ? { left: '24vp', right: '24vp' } :
              { left: '16vp', right: '16vp' })
            .width('100%')
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .height('100%')
          .useSizeType({
            xs: { span: 12, offset: 0 },
            sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 },
            lg: { span: 8, offset: 2 }
          })
        }
        .size({ width: '100%', height: '100%' })
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .size(this.pageStyle?.size)
    .clip(this.pageStyle?.clip)
    .borderRadius(this.pageStyle?.borderRadius as Length)
    .backgroundColor(this.pageStyle?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenus(): MenusArray {
    let menus: SettingsBaseMenu[] | undefined = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuPage?.getMenus();
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  aboutToAppear(): void {
    if (this.menuPage) {
      LogUtil.info(`${TAG} aboutToAppear length : ${this.menuPage.getMenus().length}`);
      this.initDialog();
      this.bindScroller();
      if (this.menuPage.style instanceof PageStyle) {
        this.pageStyle = this.menuPage.style;
      }
      if (this.menuPage.navHeaderStyle instanceof PageStyle) {
        this.navPageStyle = this.menuPage.navHeaderStyle as HeaderPageStyle;
      }
      this.controller = this.menuPage.getControllerInstance(this.uiRefresher) as PageController;
      this.menusArray = this.getMenus();
    }
  }

  private initDialog(): void {
    this.autoCancelDialogController = new CustomDialogController({
      builder: DialogPageBuilder({ pageRoot: this.dialog }),
      cancel: this.dialog?.onSelfCancelBindThis,
      autoCancel: true,
      customStyle: dialogCustomStyle,
      alignment: DialogAlignment.Center,
      showInSubWindow: this.isDialogShowInSubWindow
    });
    this.dialogController = new CustomDialogController({
      builder: DialogPageBuilder({ pageRoot: this.dialog }),
      cancel: this.dialog?.onSelfCancelBindThis,
      autoCancel: false,
      customStyle: dialogCustomStyle,
      alignment: DialogAlignment.Center,
      showInSubWindow: this.isDialogShowInSubWindow
    });
    this.dialog?.setDialogController(this.autoCancelDialogController, this.dialogController); // 弹框句柄
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setDialogPageRoot(this.dialog);
    }
  }

  private bindScroller(): void {
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setScroller(this.scroller);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear `);
    this.controller?.aboutToDisappear();
    this.dialog?.closeSelf();
    this.dialog?.setDialogController(undefined, undefined);
    this.dialog = undefined;
    this.autoCancelDialogController = undefined;
    this.dialogController = undefined;
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu?.setDialogPageRoot(undefined);
    }
  }
}

@Component
export struct PcDialogPageComponent {
  menuPage?: MenuPage;
  pageStyle?: PageStyle;
  @State controller?: PageController = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;
  @State isShowHeader: boolean = true;
  @State isShowFooter: boolean = true;
  @State cardWidth: number = 0;
  @State cardHeight: number = 0;
  radius: number = vp2px(20);

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
    this.updateFooterAndHeader();
  }

  build() {
    Column() {
      if (this.menuPage) {
        if (this.isShowHeader) {
          Column() {
            // 页头
            MenuGroupItemComponent({ menuGroup: this.menuPage.getHeader() });
          }
          .height($r('app.float.pc_dialog_header_height'))
          .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
          .padding(this.pageStyle?.padding as Padding);
        }
        Column() {
          if (this.menuPage?.scrollable) {
            Stack({ alignContent: Alignment.Top }) {
              Scroll() {
                MenuListComponent({
                  menusArray: this.menusArray,
                  style: this.menuPage?.pageStyle?.listStyle ?? this.pageStyle?.listStyle,
                  uiRefresher: $uiRefresher,
                })
              }
              .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
                this.cardWidth = vp2px(newValue.width as number - 12 * 2);
                this.cardHeight = vp2px(newValue.height as number);
              })
              .scrollBar(BarState.On)
              .align(Alignment.TopStart)
              .edgeEffect(EdgeEffect.Spring)
              .borderColor(Color.Green)
              .padding(this.pageStyle?.padding as Padding);
              if (this.menuPage.getHeader() && this.cardWidth > 0) {
                Path()
                  .commands(`M 0 0 L 0 ${this.radius} Q 0 0 ${this.radius} 0 L ${this.cardWidth - this.radius}
                  0 Q ${this.cardWidth} 0 ${this.cardWidth} ${this.radius} L ${this.cardWidth} 0 L 0 0`)
                  .strokeWidth(0)
                  .fill(this.menuPage?.pageStyle?.rootContainer?.backgroundColor ??
                  $r('sys.color.ohos_id_color_panel_bg'));

                Path()
                  .offset({ x: 0, y: px2vp(this.cardHeight) - 20 })
                  .commands(`M 0 0 Q 0 ${this.radius} ${this.radius} ${this.radius}
                  L ${this.cardWidth - this.radius} ${this.radius} Q ${this.cardWidth} ${this.radius} ${this.cardWidth}
                  0 L ${this.cardWidth} ${this.radius} L 0 ${this.radius}`)
                  .strokeWidth(0)
                  .fill(this.menuPage?.pageStyle?.rootContainer?.backgroundColor ??
                  $r('sys.color.ohos_id_color_panel_bg'));
              }
            }
          } else {
            MenuListComponent({
              menusArray: this.menusArray,
              style: this.menuPage?.pageStyle?.listStyle ?? this.pageStyle?.listStyle,
              uiRefresher: $uiRefresher,
            }).padding(this.pageStyle?.padding as Padding);
          }
        }
        .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
        // 设置列表最大高度，没有header就不设置高度
        .constraintSize(this.menuPage.getHeader()
          ? { maxHeight: `calc(${this.menuPage?.pageStyle?.rootContainer?.constraintSize?.maxHeight ??
            MAX_HEIGHT_100_PERCENT} - 144vp)` }
          : undefined);

        if (this.isShowFooter) {
          Column() {
            // 页尾
            MenuGroupItemComponent({ menuGroup: this.menuPage.getFooter() });
          }
          .height($r('app.float.pc_dialog_footer_height'))
          .padding(this.pageStyle?.padding as Padding);
        }
      }
    }
    .backgroundColor(this.menuPage?.pageStyle?.rootContainer?.backgroundColor ?? $r('sys.color.ohos_id_color_panel_bg'))
    .margin({ left: $r('app.float.margin_16'), right: $r('app.float.margin_16') })
    .size(this.getSizeOption()) // 默认弹框宽度352vp
    .borderRadius(this.menuPage?.pageStyle?.rootContainer?.borderRadius ??
    $r('sys.float.ohos_id_corner_radius_panel')) // 默认圆角16vp改为32vp
    .constraintSize(this.menuPage?.pageStyle?.rootContainer?.constraintSize ?? {
      maxHeight: MAX_HEIGHT_100_PERCENT
    }); // 设置弹窗布局约束100%展示
  }

  private getSizeOption(): SizeOptions {
    if (this.menuPage?.pageStyle?.rootContainer?.size) {
      return this.menuPage?.pageStyle?.rootContainer?.size;
    }
    return { width: DIALOG_WIDTH * DisplayManager.getInstance().getDpiScale() };
  }

  private getMenus(): MenusArray {
    let menus: SettingsBaseMenu[] | undefined = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuPage?.getMenus();
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  private updateFooterAndHeader() {
    this.isShowHeader = !!this.menuPage?.getHeader();
    this.isShowFooter = !!this.menuPage?.getHeader();
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear length : ${this.menuPage?.getMenus().length}`);

    if (this.menuPage?.style instanceof PageStyle) {
      this.pageStyle = this.menuPage?.style;
    }

    this.controller = this.menuPage?.getControllerInstance(this.uiRefresher) as PageController;
    this.menusArray = this.getMenus();
    this.updateFooterAndHeader();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear `);
    this.controller?.aboutToDisappear();
  }
}

// 手机端弹框样式
@CustomDialog
export struct DialogPageBuilder {
  tag: string = 'DialogPageBuilder : ';
  controller?: CustomDialogController;
  pageRoot?: DialogPageRoot;

  build() {
    Column() {
      if (this.pageRoot?.menuPage?.style instanceof DialogPageStyleEx) {
        DialogPageComponentEx({ menuPage: this.pageRoot?.menuPage });
      } else if (this.pageRoot?.menuPage instanceof PcWifiDialogPage) {
        PcDialogPageComponent({ menuPage: this.pageRoot?.menuPage });
      } else {
        DialogPageComponent({ menuPage: this.pageRoot?.menuPage });
      }
    }
  }
}

@Component
export struct DialogPageComponent {
  menuPage?: MenuPage;
  pageStyle?: PageStyle;
  isOObeWifiConnectFailed?: boolean = false;
  @State controller?: PageController = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;
  @State foldState: display.FoldStatus = DisplayUtils.getFoldStatus();

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      if (this.menuPage) {

        Column() {
          // 页头
          if (this.menuPage.getHeader()) {
            MenuGroupItemComponent({ menuGroup: this.menuPage.getHeader() });
          }
        }
        .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
        .padding(this.pageStyle?.padding as Padding);

        Column() {
          if (this.menuPage?.scrollable) {
            Scroll() {
              MenuListComponent({
                menusArray: this.menusArray,
                style: this.menuPage?.pageStyle?.listStyle ?? this.pageStyle?.listStyle,
                uiRefresher: $uiRefresher,
              });
            }
            .align(Alignment.TopStart)
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar((deviceType === 'tablet' || deviceType === '2in1') ? BarState.On : BarState.Off)
            .padding(this.pageStyle?.padding as Padding);
          } else {
            MenuListComponent({
              menusArray: this.menusArray,
              style: this.menuPage?.pageStyle?.listStyle ?? this.pageStyle?.listStyle,
              uiRefresher: $uiRefresher,
            }).padding({
              left: this.isOObeWifiConnectFailed ? 0 : (this.pageStyle?.padding as Padding)?.left,
              right: this.isOObeWifiConnectFailed ? 0 : (this.pageStyle?.padding as Padding)?.right,
              top: (this.pageStyle?.padding as Padding)?.top,
              bottom: (this.pageStyle?.padding as Padding)?.bottom,
            });
          }
        }
        .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
        // 设置列表最大高度，没有header就不设置高度
        .constraintSize(this.menuPage.getHeader() ? { maxHeight: 'calc(100% - 180vp)' } : undefined)
        .padding(this.pageStyle?.margin as Padding ?? this.pageStyle?.padding as Padding);

        Column() {
          // 页尾
          if (this.menuPage.getFooter()) {
            MenuGroupItemComponent({ menuGroup: this.menuPage.getFooter() });
          }
        }
        .padding(this.pageStyle?.padding as Padding);
      }
    }
    .backgroundColor(this.menuPage?.pageStyle?.rootContainer?.backgroundColor ?? $r('sys.color.ohos_id_color_panel_bg'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .size({ width: DeviceUtil.isDevicePc() ? '400vp' : '100%' })
    .shadow(ShadowStyle.OUTER_FLOATING_SM)
    .borderRadius(this.menuPage?.pageStyle?.rootContainer?.borderRadius ??
    (DeviceUtil.isDevicePc() ? '16vp' : $r('sys.float.ohos_id_corner_radius_panel'))) // 默认圆角16vp改为32vp
    .constraintSize(this.menuPage?.pageStyle?.rootContainer?.constraintSize ?? {
      maxHeight: MAX_HEIGHT_100_PERCENT
    }); // 设置弹窗布局约束100%展示
  }

  private getMenus(): MenusArray {
    let menus: SettingsBaseMenu[] | undefined = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuPage?.getMenus();
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  private registerFoldState(): void {
    try {
      display.on('foldStatusChange', (status: number) => {
        this.foldState = status;
      });
    } catch (e) {
      LogUtil.error(`${TAG} on foldStatusChangeCallback error error.code ${e?.code} error.message ${e?.message}`);
    }
  }

  aboutToAppear(): void {
    if (this.menuPage?.pageUrl === 'pages/wifi/WifiSettings/showFailMessage') {
      this.isOObeWifiConnectFailed = true;
    }
    LogUtil.info(`${TAG} aboutToAppear rootContainer bottom :
${this.menuPage?.pageStyle?.rootContainer?.margin?.bottom}`);
    LogUtil.info(`${TAG} aboutToAppear length : ${this.menuPage?.getMenus().length}`);

    if (this.menuPage?.style instanceof PageStyle) {
      this.pageStyle = this.menuPage?.style;
    }

    this.controller = this.menuPage?.getControllerInstance(this.uiRefresher) as PageController;
    this.menusArray = this.getMenus();
    this.registerFoldState();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear `);
    this.controller?.aboutToDisappear();
  }
}

export class DialogPageStyleEx extends ContainerStyle {
  public headerStyle?: ContainerStyle;
  public contentStyle?: GroupStyle;
  public footerStyle?: ContainerStyle;
}

/**
 * 复刻DialogPageComponent，支持Header和Footer的动态高度，并动态调整内容区最大高度
 */
@Component
export struct DialogPageComponentEx {
  menuPage?: MenuPage;
  pageStyle?: DialogPageStyleEx;
  @State controller?: PageController = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;
  @State foldState: display.FoldStatus = DisplayUtils.getFoldStatus();
  @State headerAndFooterHeight: number = 0;
  headerHeight: number = 0;
  @State cardWidth: number = 0;
  @State cardHeight: number = 0;
  radius: number = vp2px(20);

  uiRefresherWatch(): void {
    this.menusArray = this.getMenus();
  }

  aboutToAppear(): void {
    if (this.menuPage?.style instanceof DialogPageStyleEx) {
      this.pageStyle = this.menuPage?.style;
    }
    this.controller = this.menuPage?.getControllerInstance(this.uiRefresher) as PageController;
    this.menusArray = this.getMenus();
    this.registerFoldState();
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }

  build() {
    Column() {
      if (this.menuPage) {
        // Header
        if (this.menuPage.getHeader()) {
          MenuGroupItemComponent({ menuGroup: this.menuPage.getHeader() })
            .height($r('app.float.pc_dialog_header_height'))
            .size(this.pageStyle?.headerStyle?.size)
            .padding(this.pageStyle?.headerStyle?.padding)
            .margin(this.pageStyle?.headerStyle?.margin)
            .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
              this.headerHeight = newValue.height as number;
            });
        }
        // Content
        Column() {
          if (this.menuPage?.scrollable) {
            Stack({ alignContent: Alignment.Top }) {
              Scroll() {
                MenuListComponent({
                  menusArray: this.menusArray,
                  style: this.pageStyle?.contentStyle?.listStyle,
                  uiRefresher: $uiRefresher,
                });
              }
              .align(Alignment.TopStart)
              .edgeEffect(EdgeEffect.Spring)
              .scrollBar((deviceType === 'tablet' || deviceType === '2in1') ? BarState.On : BarState.Auto)
              .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
                this.cardWidth = vp2px(newValue.width as number - 12 * 2);
                this.cardHeight = vp2px(newValue.height as number);
              })
              .padding(this.pageStyle?.contentStyle?.padding as Padding);
              if (this.cardWidth > 0) {
                Path()
                  .commands(`M 0 0 L 0 ${this.radius} Q 0 0 ${this.radius} 0 L ${this.cardWidth - this.radius}
                  0 Q ${this.cardWidth} 0 ${this.cardWidth} ${this.radius} L ${this.cardWidth} 0 L 0 0`)
                  .strokeWidth(0)
                  .fill(this.menuPage?.pageStyle?.rootContainer?.backgroundColor ??
                  $r('sys.color.ohos_id_color_panel_bg'));

                Path()
                  .offset({ x: 0, y: px2vp(this.cardHeight) - 20 })
                  .commands(`M 0 0 Q 0 ${this.radius} ${this.radius} ${this.radius}
                  L ${this.cardWidth - this.radius} ${this.radius} Q ${this.cardWidth} ${this.radius} ${this.cardWidth}
                  0 L ${this.cardWidth} ${this.radius} L 0 ${this.radius}`)
                  .strokeWidth(0)
                  .fill(this.menuPage?.pageStyle?.rootContainer?.backgroundColor ??
                  $r('sys.color.ohos_id_color_panel_bg'));
              }
            }
          } else {
            MenuListComponent({
              menusArray: this.menusArray,
              style: this.pageStyle?.contentStyle?.listStyle,
              uiRefresher: $uiRefresher,
            })
          }
        }
        .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
        .constraintSize({
          maxHeight: this.headerAndFooterHeight > 0 ?
            `calc(${this.pageStyle?.constraintSize?.maxHeight ?? '100%'} - ${this.headerAndFooterHeight}vp)`
            : this.pageStyle?.constraintSize?.maxHeight ?? '100%',
        })
        .size(this.pageStyle?.contentStyle?.size)

        // Footer
        if (this.menuPage.getFooter()) {
          MenuGroupItemComponent({ menuGroup: this.menuPage.getFooter() })
            .size(this.pageStyle?.footerStyle?.size)
            .padding(this.pageStyle?.footerStyle?.padding)
            .margin(this.pageStyle?.footerStyle?.margin)
            .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
              this.headerAndFooterHeight = this.headerHeight + (newValue.height as number);
            });
        }
      }
    }
    .backgroundColor(this.menuPage?.pageStyle?.rootContainer?.backgroundColor ?? $r('sys.color.ohos_id_color_panel_bg'))
    .margin((DisplayUtils.isFoldable() && this.foldState === FOLD_STATUS_FOLDED) ? {
      left: $r('app.float.margin_16'),
      right: $r('app.float.margin_16'),
      bottom: $r('app.float.margin_16')
    } : { left: $r('app.float.margin_16'), right: $r('app.float.margin_16'), bottom: $r('app.float.margin_16') })
    .size(this.getSizeOption()) // 默认弹框宽度352vp
    .borderRadius(this.pageStyle?.borderRadius ?? $r('sys.float.ohos_id_corner_radius_panel')) // 默认圆角16vp改为32vp
    .constraintSize(this.pageStyle?.constraintSize ?? {
      maxHeight: MAX_HEIGHT_100_PERCENT
    });
  }

  private getSizeOption(): SizeOptions {
    if (this.pageStyle?.size) {
      return this.pageStyle?.size;
    }
    if ((DisplayUtils.isFoldable() && this.foldState === FOLD_STATUS_FOLDED)) {
      return { width: DIALOG_FOLDED_WIDTH * DisplayManager.getInstance().getDpiScale() };
    } else if ((DisplayUtils.isFoldable() && this.foldState !== FOLD_STATUS_FOLDED) || deviceType === DEVICE_TYPE_PAD) {
      return { width: DIALOG_EXPANDED_WIDTH * DisplayManager.getInstance().getDpiScale() };
    } else {
      return { width: DIALOG_WIDTH * DisplayManager.getInstance().getDpiScale() };
    }
  }

  private getMenus(): MenusArray {
    let menus: SettingsBaseMenu[] | undefined = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuPage?.getMenus();
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  private registerFoldState(): void {
    try {
      display.on('foldStatusChange', (status: number) => {
        this.foldState = status;
      });
    } catch (e) {
      LogUtil.error(`${TAG} on foldStatusChangeCallback error error.code ${e?.code} error.message ${e?.message}`);
    }
  }
}

@Component
export struct MenuTitlePageComponent {
  @State menuPage?: MenuPage = undefined;
  @State pageStyle?: PageStyle = undefined;
  @State navPageStyle?: HeaderPageStyle = undefined;
  @State controller?: PageController = undefined;
  @State foldState: display.FoldStatus = DisplayUtils.getFoldStatus();
  scroller: Scroller = new Scroller();
  dialog: DialogPageRoot | undefined = new DialogPageRoot(); // 弹框页
  autoCancelDialogController: CustomDialogController | undefined = undefined;
  dialogController: CustomDialogController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray?: MenusArray = undefined;
  @Provide scrollDirection: ScrollDirection = ScrollDirection.Vertical;
  @Link title: ResourceStr;

  uiRefresherWatch(): void {
    // update @State menus on uiRefresher changes
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      if (this.menuPage) {
        GridContainer({ columns: 12, sizeType: SizeType.MD, gutter: '12vp', margin: '0vp' }) {
          Column() {
            if (this.menuPage.menuType === MenuPageType.HEADER_PAGE && this.menuPage.isNavigation) {
              Column() {
                NavTitleHeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.title,
                  targetPageUrl: this.menuPage.targetPageUrl,
                  isShowBack: this.menuPage.isShowBack,
                  isShowAbout: this.menuPage.isShowAbout,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.navPageStyle?.pageHeaderStyle : defaultNavPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                  showALL: this.menuPage.showHeader,
                });
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            } else if (this.menuPage.menuType === MenuPageType.PC_HEADER_PAGE && this.menuPage.isNavigation) {
              Column() {
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
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            } else if (this.menuPage.menuType === MenuPageType.HEADER_PAGE) { // 页描述
              Column() {
                HeaderComponent({
                  menuKey: this.menuPage.key,
                  title: this.menuPage.title,
                  targetPageUrl: this.menuPage.targetPageUrl,
                  isShowBack: this.menuPage.isShowBack,
                  isShowAbout: this.menuPage.isShowAbout,
                  style: this.pageStyle instanceof HeaderPageStyle ?
                    this.pageStyle?.pageHeaderStyle : defaultPageHeaderStyle,
                  isStartAbility: this.menuPage.isStartAbility,
                  uiRefresher: $uiRefresher,
                });
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            }

            Flex({
              direction: FlexDirection.Column,
              justifyContent: FlexAlign.Start,
              alignItems: ItemAlign.Center,
              wrap: FlexWrap.Wrap,
            }) {
              // 页头
              if (this.menuPage.getHeader()) {
                Column() {
                  MenuGroupItemComponent({ menuGroup: this.menuPage.getHeader() });
                  if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getHeader())) {
                    SpaceComponent({
                      space: this.menuPage?.key === OOBE_PAGE_KEY ? '0' : this.pageStyle?.space,
                      uiRefresher: $uiRefresher
                    });
                  }
                  if (this.menuPage?.key === OOBE_PAGE_KEY) {
                    Row() {
                      Divider()
                        .height($r('app.float.padding_8'))
                        .color($r('app.color.color_default_white'))
                    }
                    .width('100%')
                  }
                }
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                .padding(this.pageStyle?.padding as Padding)
                .flexShrink(0);
              }

              // 页中
              Column() {
                if (this.menuPage?.scrollable) {
                  Scroll(this.scroller) {
                    MenuListComponent({
                      menusArray: this.menusArray,
                      style: this.pageStyle?.listStyle,
                      uiRefresher: $uiRefresher,
                    })
                      .width('100%')
                      .padding({
                        left: this.pageStyle?.padding?.left,
                        right: this.pageStyle?.padding?.right,
                        top: this.pageStyle?.padding?.top,
                        bottom: (
                          this.menuPage.getFooter() ||
                            this.menuPage.menuType === MenuPageType.DIALOG_PAGE ||
                            this.menuPage.pageUrl === OOBE_PAGE_KEY
                        ) ? $r('app.float.padding_0') : $r('app.float.margin_16'),
                      })
                  }
                  .scrollable(this.scrollDirection)
                  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                  .borderRadius(this.menuPage.pageUrl === APPLICATION_PAGE_URL ?
                  $r('app.float.border_radius_16') : $r('app.float.border_radius_0')
                  )
                  .align(Alignment.TopStart)
                  .height(this.pageStyle?.listStyle?.height ?? '100%')
                  .edgeEffect(EdgeEffect.Spring)
                  .scrollBar((deviceType === '2in1' && this.menuPage.menuType !==
                  MenuPageType.DIALOG_PAGE) ? BarState.On : BarState.Auto)
                  .onHover(event => {
                    // 鼠标划出时候，归位
                    if (!event) {
                      this.scroller?.scrollBy(0, -(this.scroller?.currentOffset()?.yOffset ?? 0))
                    }
                  })
                  .onScrollStart(() => {
                    LogUtil.info(`MenuPageComponent onScrollStart}`);
                    AppStorage.setOrCreate('ListScrollOn', true);
                  })
                  .onScrollStop(() => {
                    LogUtil.info(`MenuPageComponent onScrollStop}`);
                    AppStorage.setOrCreate('ListScrollOn', false);
                  })
                } else {
                  MenuListComponent({
                    menusArray: this.menusArray,
                    style: this.pageStyle?.listStyle,
                    uiRefresher: $uiRefresher,
                  })
                    .borderRadius($r('app.float.border_radius_0'))
                    .align(Alignment.TopStart)
                    .height(this.pageStyle?.listStyle?.height ?? '100%')
                    .padding({
                      left: this.pageStyle?.padding?.left,
                      right: this.pageStyle?.padding?.right,
                      top: this.pageStyle?.padding?.top,
                      bottom: this.menuPage.getFooter() ? $r('app.float.padding_0') : $r('app.float.margin_16')
                    });
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .padding({
                bottom: ((this.menuPage.menuType === MenuPageType.HEADER_PAGE && this.menuPage.showHeader) ||
                  this.menuPage.pageUrl === OOBE_PAGE_KEY) ? '68vp' : '0vp',
                left: (![WIFI_DIALOG_PAGE_URL, BLUETOOTH_WINDOW_PAGE_URL].includes(this.menuPage.pageUrl)) &&
                DeviceUtil.isDevicePc() ? $r('sys.float.ohos_id_default_padding_start') : ''
              })
              .width('100%')

              Column() {
                // 页尾
                if (this.menuPage.getFooter()) {
                  if (this.menuPage.getRoot()?.getFirstVisibleMenu(this.menuPage.getFooter())) {
                    SpaceComponent({ space: this.pageStyle?.space, uiRefresher: $uiRefresher });
                  }
                  MenuGroupItemComponent({ menuGroup: this.menuPage.getFooter() });
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .padding(this.pageStyle?.padding as Padding)
            }
            .width('100%')
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .height('100%')
          .useSizeType({
            xs: { span: 12, offset: 0 },
            sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 },
            lg: { span: 8, offset: 2 }
          })
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .size({ width: '100%', height: '100%' })
      }
    }
    .padding(this.pageStyle?.pagePadding as Padding)
    .size(this.pageStyle?.size)
    .clip(this.pageStyle?.clip)
    .borderRadius(this.pageStyle?.borderRadius as Length)
    .backgroundColor(this.pageStyle?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  private getMenus(): MenusArray {
    let menus: SettingsBaseMenu[] | undefined = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuPage?.getMenus();
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  private registerFoldState(): void {
    try {
      display.on('foldStatusChange', (status: number) => {
        this.foldState = status;
        this.createDialogController();
      });
    } catch (e) {
      LogUtil.error(`${TAG} on foldStatusChangeCallback error error.code ${e?.code} error.message ${e?.message}`);
    }
  }

  private createDialogController() {
    this.autoCancelDialogController = new CustomDialogController({
      builder: DialogPageBuilder({ pageRoot: this.dialog }),
      cancel: this.dialog?.onSelfCancelBindThis,
      autoCancel: true,
      customStyle: dialogCustomStyle,
      alignment: DialogAlignment.Center,
      maskColor: $r('sys.color.ohos_id_color_mask_thin')
    });
    this.dialogController = new CustomDialogController({
      builder: DialogPageBuilder({ pageRoot: this.dialog }),
      cancel: this.dialog?.onSelfCancelBindThis,
      autoCancel: false,
      customStyle: dialogCustomStyle,
      alignment: DialogAlignment.Center,
      maskColor: $r('sys.color.ohos_id_color_mask_thin')
    });
    this.dialog?.setDialogController(this.autoCancelDialogController, this.dialogController); // 弹框句柄
  }

  aboutToAppear() {
    if (this.menuPage) {
      LogUtil.info(`${TAG} aboutToAppear length : ${this.menuPage.getMenus().length}`);
      this.createDialogController();
      this.setDialogPageRoot();
      this.bindScroller();
      this.registerFoldState();

      if (this.menuPage.style instanceof PageStyle) {
        this.pageStyle = this.menuPage.style;
      }

      if (this.menuPage.navHeaderStyle instanceof PageStyle) {
        this.navPageStyle = this.menuPage.navHeaderStyle as HeaderPageStyle;
      }

      this.controller = this.menuPage.getControllerInstance(this.uiRefresher) as PageController;
      this.menusArray = this.getMenus();
    }
  }

  private setDialogPageRoot(): void {
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu?.setDialogPageRoot(this.dialog);
    }
  }

  private bindScroller(): void {
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu.setScroller(this.scroller);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.controller?.aboutToDisappear();
    this.dialog?.closeSelf();
    this.dialog?.setDialogController(undefined, undefined);
    this.dialog = undefined;
    this.autoCancelDialogController = undefined;
    this.dialogController = undefined;
    let rootMenu = this.menuPage?.getRoot();
    if (rootMenu instanceof PageRoot) {
      rootMenu?.setDialogPageRoot(undefined);
    }
  }
}
