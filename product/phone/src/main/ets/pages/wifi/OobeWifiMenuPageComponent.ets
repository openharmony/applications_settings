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

import { MenuController, MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import {
  MenuGroup,
  MenuPage,
  MenuSection,
  SettingsBaseMenu
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DialogPageRoot, PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { HeaderPageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { DialogPageBuilder } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { MenusArray } from '@ohos/settings.uikit/src/main/ets/component/MenuGroupComponent';
import {
  CardSectionListStyle,
  cardSectionListStyle,
  DefaultEntryMenuStyle,
  EntryMenu,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { HOT_LIST_GROUP, WIFI_CONNECTED_AP_GROUP, WIFI_LIST_GROUP } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import display from '@ohos.display';
import { OneTitleEntryComponent } from '@ohos/settings.uikit/src/main/ets/component/AtomicComponent';
import { WifiListController } from './controller/WifiListController';
import {
  AddOtherWifiMenuStyle,
  HotSpotListComponent,
  NgWifiPrecisionComponent,
  WifiConnectedComponent,
  WifiListComponent,
  WifiLoadingHeaderComponent,
  WifiSwitchMenuComponent
} from './WifiMenuPageComponent';

/* instrument ignore file */
const TAG: string = 'OobeWifiMenuPageComponent : ';
const GRID_COUNT_4: number = 4;
const RELATIVE_LENGTH: string = '100%'
const DEFAULT_VERTICAL_OFFSET = -64;
const PAD_CONTENT_WIDTH = '496vp';
const IS_PAD: boolean = DeviceUtil.isDevicePad();
let hasList: boolean = false;
const LIST_GROUP: string[] = [
  WIFI_LIST_GROUP,
  WIFI_CONNECTED_AP_GROUP,
  HOT_LIST_GROUP,
];

@Entry
@Component
export struct OobeWifiMenuPageComponent {
  menuPage: MenuPage | undefined = undefined;
  pageStyle: PageStyle | undefined = undefined;
  navPageStyle: HeaderPageStyle | undefined = undefined;
  controller: MenuController | undefined = undefined;
  headerController: MenuController | undefined = undefined;
  @State foldState: display.FoldStatus = DisplayUtils.getFoldStatus();
  scroller: Scroller = new Scroller();
  dialog: DialogPageRoot | undefined = new DialogPageRoot();
  autoCancelDialogController: CustomDialogController | undefined = undefined;
  dialogController: CustomDialogController | undefined = undefined;
  headerUiRefresher: UiRefresher = new UiRefresher();
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray: MenusArray | undefined = undefined;
  @State menusHeaderArray: MenusArray | undefined = undefined;
  @State loadPull: boolean = false;
  @State isTop: boolean = true;
  @State isScrolling: boolean = false;
  @StorageLink('WifiStateIsOn') wifiState: boolean = true;
  @State hasConnectedItem: boolean = true;
  verticalOffset: number = DEFAULT_VERTICAL_OFFSET;
  isReachStart: boolean = false;
  @State marBtm: number = 0;
  loadSize: SizeOptions = {
    width: '32vp',
    height: '32vp',
  };

  uiRefresherWatch(): void {
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      this.wifiContentBuilder()
    }
    .height(RELATIVE_LENGTH)
  }

  @Builder
  wifiContentBuilder(): void {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center, }) {
      Column() {
        this.wifiSwitchBuilder()
      }
      .zIndex(1)
      .padding({
        top: '0vp',
        left: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
        right: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
        bottom: $r('app.float.padding_16'),
      })
      .flexShrink(0);

      if (!this.wifiState) {
        this.ngWifiPrecisionBuilder()
      } else {
        this.wifiListGroupContentBuilder()
      }
    }
    .width(IS_PAD ? PAD_CONTENT_WIDTH : RELATIVE_LENGTH)
  }

  @Builder
  wifiListGroupContentBuilder(): void {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Start,
      alignItems: ItemAlign.Center,
    }) {
      this.loadingProgressBuilder()
      this.wifiListContentBuilder()
    }
    .align(Alignment.TopStart)
  }

  @Builder
  wifiListContentBuilder(): void {
    List({ scroller: this.scroller }) {
      this.WifiConnectedItem(this.menusArray?.menus[1] as MenuSection, this.uiRefresher)
      this.HotSpotListItem(this.menusArray?.menus[2] as MenuSection)
      this.WifiScanListItem(this.menusArray?.menus[3] as MenuSection)
      this.addOtherWifiBuilder()
    }
    .zIndex(0)
    .position({
      y: 0
    })
    .onScroll((yOffset: number) => {
      this.verticalOffset = this.verticalOffset + yOffset;
      if (this.verticalOffset > 0 && this.isTop) {
        this.isTop = false;
      }
      // 判断在列表顶部且向上滑，isTop为false
      if (this.loadPull && this.verticalOffset > (2 * DEFAULT_VERTICAL_OFFSET)) {
        this.loadPull = false;
      } else if (!this.loadPull && this.verticalOffset <= (2 * DEFAULT_VERTICAL_OFFSET)) {
        this.loadPull = true;
        if (this.isTop && this.wifiState && !this.isReachStart) {
          this.vibratorLoading();
        }
      }
      this.marBtm = this.verticalOffset;
    })
    .onReachStart(() => {
      // 有滑动且滑到列表起始位置时记录isReachStart
      if (this.verticalOffset !== DEFAULT_VERTICAL_OFFSET) {
        this.isReachStart = true;
      }
      this.isTop = true;
    })
    .onScrollStart(() => {
      this.onScrollStart();
    })
    .onScrollStop(() => {
      this.onScrollStop();
    })
    .offset({ y: DEFAULT_VERTICAL_OFFSET })
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Auto)
    .width(RELATIVE_LENGTH)
  }

  @Builder
  addOtherWifiBuilder(): void {
    ListItem() {
      Column() {
        OneTitleEntryComponent({
          menu: addOtherWifiEntry,
          style: addOtherWifiEntry.style as DefaultEntryMenuStyle,
        })
      }
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .backgroundColor($r('app.color.oobe_wlan_bg_color'))
      .borderRadius($r('sys.float.ohos_id_corner_radius_text_field'))
      .padding({ top: '4vp', bottom: '4vp' })
      .margin({ top: '16vp' })
    }
    .margin({
      left: IS_PAD ? $r('app.float.margin_24') : $r('app.float.padding_16'),
      right: IS_PAD ? $r('app.float.margin_24') : $r('app.float.padding_16'),
      bottom: $r('app.float.wh_value_68')
    })
  }

  @Builder
  wifiSwitchBuilder(): void {
    Column() {
      WifiSwitchMenuComponent({ menu: this.menusHeaderArray!.menus[0] });
    }
    .alignSelf(ItemAlign.Start)
    .clip(true)
    .backgroundColor($r('app.color.oobe_wlan_bg_color'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_text_field'))
    .padding({ top: '4vp', bottom: '4vp' })
  }

  @Builder
  loadingProgressBuilder() {
    Column() {
      if (this.isTop && this.loadPull && hasList && !this.isReachStart) {
        Row() {
          LoadingProgress()
            .color($r('app.color.loading_color'))
            .align(Alignment.Top)
            .size(this.loadSize);
        }
        .width('10%')
        .height(Math.abs(this.marBtm - DEFAULT_VERTICAL_OFFSET));
      }
    }
    .height('50%')
    .width('100%')
    .align(Alignment.Center)
  }

  @Builder
  ngWifiPrecisionBuilder() {
    Row() {
      NgWifiPrecisionComponent({ menu: this.menusArray?.menus[0] });
    }
    .padding({
      left: IS_PAD ? '24vp' : $r('app.float.padding_16'),
      right: IS_PAD ? '24vp' : $r('app.float.length_17'),
    })
  }

  @Builder
  WifiConnectedItem(myMenuSection: MenuSection, myUiRefresher: UiRefresher) {
    ListItem() {
      WifiLoadingHeaderComponent({
        wifiTitle: $r('app.string.wifi_connected_ap'),
        hasConnectedItem: this.hasConnectedItem
      })
    }

    WifiConnectedComponent({ menuSection: myMenuSection, hasConnectedItem: this.hasConnectedItem })
  }

  @Builder
  HotSpotListItem(myMenuSection: MenuSection) {
    HotSpotListComponent({ menuSection: myMenuSection })
  }

  @Builder
  WifiScanListItem(myMenuSection: MenuSection) {
    ListItem() {
      WifiLoadingHeaderComponent({
        wifiTitle: $r('app.string.wifi_available_ap_group'),
        hasConnectedItem: this.hasConnectedItem,
        setLoadingVisible: true
      })
    }

    WifiListComponent({ menuSection: myMenuSection })
  }

  private onScrollStart(): void {
    let controller: WifiListController =
      this.menuPage?.getControllerFromPage(WIFI_LIST_GROUP) as WifiListController;
    controller?.setListScrolling(true);
    this.isScrolling = true;
  }

  private onScrollStop(): void {
    this.verticalOffset = DEFAULT_VERTICAL_OFFSET;
    let controller: WifiListController =
      this.menuPage?.getControllerFromPage(WIFI_LIST_GROUP) as WifiListController;
    controller?.setListScrolling(false);
    controller?.scanList();
    this.loadPull = false;
    this.isReachStart = false;
    this.isScrolling = false;
  }

  private initSectionStyle(menus: Array<SettingsBaseMenu>): void {
    for (let sectionMenu of menus) {
      if (!LIST_GROUP.includes(sectionMenu?.getLogKey())) {
        continue;
      }
      let style: CardSectionListStyle = cardSectionListStyle;
      style.backgroundColor = $r('app.color.oobe_wlan_bg_color');
      sectionMenu.style = style;
    }
  }

  // 下拉刷新震感
  private async vibratorLoading(): Promise<void> {
    try {
      VibratorUtil.vibrateOnVibrateMode(100, 'physicalFeedback', 'haptic.drag');
    } catch (err) {
      LogUtil.error('err')
    }
  }

  private getMenus(): MenusArray {
    let menus: Array<SettingsBaseMenu> | undefined = [];
    if (this.controller?.menu instanceof MenuSection) {
      menus = this.controller?.menu?.getMenus();
      if (!CheckEmptyUtils.isEmpty(menus)) {
        this.initSectionStyle(menus);
      }
    } else if (this.controller?.menu instanceof MenuGroup) {
      menus = this.controller?.menu?.getMenus();
    }

    if (!menus) {
      menus = this.menuPage?.getMenus();
    }
    if (!menus) {
      menus = [];
    }
    LogUtil.debug(`${TAG} getMenus ${menus.length} key ${this.menuPage?.getLogKey()}`);
    return new MenusArray(menus);
  }

  private getHeaderMenus(): MenusArray {
    let menus = (this.menuPage?.getHeader() as MenuSection)?.getMenus() as Array<SettingsBaseMenu>;
    return new MenusArray(menus);
  }

  private registerFoldState(): void {
    try {
      display.on('foldStatusChange', (status: number) => {
        this.foldState = status;
        this.createDialogController();
      });
    } catch (err) {
      LogUtil.error(`${TAG} register fold state change err ${err?.message}`);
    }
  }

  private createDialogController() {
    this.autoCancelDialogController = new CustomDialogController({
      builder: DialogPageBuilder({ pageRoot: this.dialog }),
      cancel: this.dialog?.onSelfCancelBindThis,
      autoCancel: true,
      alignment: DialogAlignment.Center,
    });
    this.dialogController = new CustomDialogController({
      builder: DialogPageBuilder({ pageRoot: this.dialog }),
      cancel: this.dialog?.onSelfCancelBindThis,
      autoCancel: false,
      alignment: DialogAlignment.Center,
    });
    this.dialog?.setDialogController(this.autoCancelDialogController, this.dialogController); // 弹框句柄
  }

  aboutToAppear() {
    this.createDialogController();
    this.setDialogPageRoot();
    this.bindScroller();
    this.registerFoldState();
    if ((this.menuPage ?? false) && this.menuPage?.style instanceof PageStyle) {
      this.pageStyle = this.menuPage.style;
    }
    if ((this.menuPage ?? false) && this.menuPage?.navHeaderStyle instanceof PageStyle) {
      this.navPageStyle = this.menuPage.navHeaderStyle as HeaderPageStyle;
    }
    this.controller = this.menuPage?.getControllerInstance(this.uiRefresher) as MenuController;
    this.menusArray = this.getMenus();

    this.headerController =
      (this.menuPage?.getHeader() as MenuSection)?.getControllerInstance(this.headerUiRefresher) as MenuGroupController;
    this.menusHeaderArray = this.getHeaderMenus();
  }

  private setDialogPageRoot(): void {
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
    this.headerController?.aboutToDisappear();
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

let addOtherWifiEntry: EntryMenu = new EntryMenu({
  key: NavEntryKey.ADD_OTHER_WIFI_ENTRY,
  index: 10,
  title: $r('app.string.wifi_add_other_wifi'),
  style: new AddOtherWifiMenuStyle(),
})
