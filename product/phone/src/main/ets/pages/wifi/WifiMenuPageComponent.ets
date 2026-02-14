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
import { DeviceUtil, SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DialogPageRoot, PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { HeaderPageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  MenuController,
  MenuGroupController,
  SwitchMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { MenuDataSource } from '@ohos/settings.common/src/main/ets/core/model/datasource/MenuDataSource';
import { PageStyle, Style, TextStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  MenuGroup,
  MenuPage,
  MenuSection,
  SettingsBaseMenu
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { NavEntryKey, TextClickPosition } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Controller, PushParam, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { DialogPageBuilder } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { MenusArray, } from '@ohos/settings.uikit/src/main/ets/component/MenuGroupComponent';
import {
  CardSectionListStyle,
  cardSectionListStyle,
  DefaultEntryMenuStyle,
  EntryMenu,
  TitleTextStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { HotSpotMenu } from '@ohos/settings.wifi/src/main/ets/model/HotSpotModel';
import {
  OneTitleEntryComponent,
  ReusableHotSpotEntryComponent,
  ReusableWlanEntryComponent,
  TitleSummaryImageWlanEntryComponent,
} from '@ohos/settings.uikit/src/main/ets/component/AtomicComponent';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { WifiListController } from './controller/WifiListController';

/* instrument ignore file */
const TAG: string = 'MenuPageComponent : ';
const GRID_COUNT_4: number = 4;
const RELATIVE_LENGTH: string = '100%'
const COUNT_EMPTY: number = 0;
const DEFAULT_CACHE_COUNT = 3;
const DEFAULT_VERTICAL_OFFSET = -64;
const MAX_LINES_1: number = 1;
const IS_PAD: boolean = DeviceUtil.isDevicePad();
const OPACITY_PERCENT_FULL: number = 1;
const ALPHA_DISABLED: Resource = $r('sys.float.ohos_id_alpha_disabled');
let hasList: boolean = false;

@Entry
@Component
export struct WifiMenuPageComponent {
  menuPage: MenuPage | undefined = undefined;
  pageStyle: PageStyle | undefined = undefined;
  navPageStyle: HeaderPageStyle | undefined = undefined;
  controller: MenuController | undefined = undefined;
  @State foldState: display.FoldStatus = DisplayUtils.getFoldStatus();
  scroller: Scroller = new Scroller();
  dialog: DialogPageRoot | undefined = new DialogPageRoot();
  autoCancelDialogController: CustomDialogController | undefined = undefined;
  dialogController: CustomDialogController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray: MenusArray | undefined = undefined;
  @State loadPull: boolean = false;
  @State isTop: boolean = true;
  @StorageLink('WifiStateIsOn') @Watch('wifiStateWatch') wifiState: boolean = true;
  @State hasConnectedItem: boolean = false;
  verticalOffset: number = DEFAULT_VERTICAL_OFFSET;
  isPad: boolean = DeviceUtil.isDevicePad();
  isReachStart: boolean = false;
  @State marBtm: number = 0;
  @State defaultHeight: number = 10;
  @State marLeft: string = '0';
  loadSize: SizeOptions = {
    width: '32vp',
    height: '32vp',
  };

  wifiStateWatch(): void {
    this.loadPull = false;
    this.isReachStart = false;
  }

  uiRefresherWatch(): void {
    this.menusArray = this.getMenus();
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center, }) {
        Column() {
          SimpleMenuSectionComponent({ menuSection: this.menuPage?.getHeader() as MenuSection })

          Row() {
            Divider()
              .height($r('app.float.padding_0'))
              .color($r('sys.color.ohos_id_color_list_separator'))
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .width('100%')
        }
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .zIndex(1)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .padding({
          top: '0',
          bottom: '0',
          left: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
          right: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16')
        })
        .flexShrink(0);

        if (!this.wifiState) { // 用if判断，避免多余绘制，用visibility控制显隐性能太差
          this.ngWifiPrecisionBuilder()
        } else {
          Flex({
            direction: FlexDirection.Column,
            justifyContent: FlexAlign.Start,
            alignItems: ItemAlign.Center,
          }) {
            this.loadingProgressBuilder()

            Stack() {
              List({ scroller: this.scroller }) {
                this.WifiConnectedItem(this.menusArray?.menus[1] as MenuSection, this.uiRefresher)
                this.HotSpotListItem(this.menusArray?.menus[2] as MenuSection)
                this.WifiScanListItem(this.menusArray?.menus[3] as MenuSection)
                ListItem() {
                  Column() {
                    OneTitleEntryComponent({
                      menu: addOtherWifiEntry,
                      style: addOtherWifiEntry.style as DefaultEntryMenuStyle,
                    })
                  }
                  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                  .alignSelf(ItemAlign.Start)
                  .clip(true)
                  .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                  .borderRadius($r('sys.float.ohos_id_corner_radius_text_field'))
                  .padding({ top: '4vp', bottom: '4vp' })
                  .margin({ top: '16vp' })
                }
                .margin({
                  left: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
                  right: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
                  bottom: $r('app.float.wh_value_68')
                })
              }
              .zIndex(0)
              .position({
                y: 0
              })
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
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
                let controller: WifiListController =
                  this.menuPage?.getControllerFromPage('wifi_list_group') as WifiListController;
                controller?.setListScrolling(true);
              })
              .onScrollStop(() => {
                this.verticalOffset = DEFAULT_VERTICAL_OFFSET;
                let controller: WifiListController =
                  this.menuPage?.getControllerFromPage('wifi_list_group') as WifiListController;
                controller?.setListScrolling(false);
                controller?.scanList();
                this.loadPull = false;
                this.isReachStart = false;
              })
              .offset({ y: DEFAULT_VERTICAL_OFFSET })
              .edgeEffect(EdgeEffect.Spring)
              .scrollBar(BarState.Auto)
              .width(RELATIVE_LENGTH);
              // 间隙
              this.WifiPitchHeader()
            }
            .position({
              y: 0
            })
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .alignContent(Alignment.Top)
          }
          .align(Alignment.TopStart);
        }
      }
      .width(RELATIVE_LENGTH)
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .height(RELATIVE_LENGTH)
  }

  @Builder
  WifiPitchHeader() {
    Text() {
    }
    .width('100%')
    .height('8vp')
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
  }

  @Builder
  loadingProgressBuilder() {
    Column() {
      if (this.isTop && this.loadPull && hasList && !this.isReachStart) {
        Row() {
          LoadingProgress()
            .color($r('app.color.loading_color'))
            .align(Alignment.Top)
            .size(this.loadSize)
        }
        .width('10%')
        .height(Math.abs(this.marBtm - DEFAULT_VERTICAL_OFFSET))
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
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding({
      left: IS_PAD ? '24vp' : $r('app.float.padding_16'),
      right: '17vp'
    })
    .margin({ top: '8vp' })
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

  // 下拉刷新震感
  private async vibratorLoading(): Promise<void> {
    try {
      VibratorUtil.vibrateOnVibrateMode(100, 'physicalFeedback', 'haptic.drag');
    } catch (err) {
      LogUtil.error(`${TAG} vibrateOnVibrateMode err: ${err?.message}`);
    }
  }

  private getMenus(): MenusArray {
    let menus: Array<SettingsBaseMenu> | undefined = [];
    if (this.controller?.menu instanceof MenuSection || this.controller?.menu instanceof MenuGroup) {
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
      maskColor: $r('sys.color.ohos_id_color_mask_thin')
    });
    this.dialogController = new CustomDialogController({
      builder: DialogPageBuilder({ pageRoot: this.dialog }),
      cancel: this.dialog?.onSelfCancelBindThis,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      maskColor: $r('sys.color.ohos_id_color_mask_thin')
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

class AddOtherWifiTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_hyperlink');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body1'),
    weight: FontWeight.Medium,
  };
}

export class AddOtherWifiMenuStyle extends DefaultEntryMenuStyle {
  public startFlexShrink: number = 0;
  public endFlexShrink: number = 1;
  public title: TextStyle = new AddOtherWifiTextStyle();
}

let addOtherWifiEntry = new EntryMenu({
  key: NavEntryKey.ADD_OTHER_WIFI_ENTRY,
  index: 10,
  title: $r('app.string.wifi_add_other_wifi'),
  style: new AddOtherWifiMenuStyle(),
})

@Component
export struct SimpleMenuSectionComponent {
  menuSection?: MenuSection;
  controller?: MenuGroupController = undefined;
  uiRefresher: UiRefresher = new UiRefresher();
  menusArray?: MenusArray = undefined;

  build() {
    Column() {
      Column() {
        Divider()
          .height($r('app.float.padding_16'))
          .color($r('app.color.color_default_white'))
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column() {
        WifiSwitchMenuComponent({ menu: this.menusArray!.menus[0] });
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
      .borderRadius($r('sys.float.ohos_id_corner_radius_text_field'))
      .padding({ top: '4vp', bottom: '4vp' })
    }
  }

  private getMenus(): MenusArray {
    let menus = this.menuSection?.getMenus() as Array<SettingsBaseMenu>;
    return new MenusArray(menus);
  }

  aboutToAppear(): void {
    this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuGroupController;
    this.menusArray = this.getMenus();
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct WifiSwitchMenuComponent {
  menu?: SettingsBaseMenu;
  enable: boolean = true;
  controller?: SwitchMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column() {
        Text($r('app.string.wifi_settings_title'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .opacity(this.enable ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start);

      Toggle({ type: ToggleType.Switch, isOn: this.uiRefresher.refreshId ?
        (this.controller?.getChecked() ?? false) : (this.controller?.getChecked() ?? false) })
        .id(`entry_toggle_wifi_switch`)
        .onChange((isOn: boolean) => {
          this.controller?.onToggleChange(isOn);
        })
        .hoverEffect(DeviceUtil.isDevicePad() ? HoverEffect.Highlight : HoverEffect.None)
        .selectedColor(this.enable ? $r('sys.color.ohos_id_color_emphasize') : '#9ebefd')
        .switchPointColor(this.enable ? $r('sys.color.ohos_id_color_foreground_contrary') :
        $r('sys.color.ohos_id_color_foreground_contrary_disable'))
        .margin({
          left: $r('sys.float.ohos_id_text_margin_horizontal'),
          right: $r('app.float.margin_6'),
          top: $r('app.float.margin_0'),
          bottom: $r('app.float.margin_0')
        })
        .enabled(this.controller?.getToggleState() ?? false)
    }
    .opacity(1)
    .enabled(this.enable)
    .width('100%')
    .constraintSize({ minHeight: '48vp', })
    .padding({
      left: $r('sys.float.ohos_id_default_padding_start'),
      right: '6vp',
      top: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() : '0vp',
      bottom: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() : '0vp',
    })
    .margin(0)
    .layoutWeight(0)
  }

  aboutToAppear(): void {
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SwitchMenuController;
    this.enable = !SatelliteUtils.isCommunicationOpen();
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct NgWifiPrecisionComponent {
  tag: string = 'WifiPrecisionComponent : ';
  menu?: SettingsBaseMenu = undefined;
  style?: Style = undefined;
  controller?: Controller = undefined;
  start: string | ResourceStr = ''; // 首位
  middle: string | ResourceStr = ''; // 可点击的文本
  end: string | ResourceStr = ''; // 末尾
  clickTextPosition: string = ''; // 文本状态标注
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    Column() {
      Row() {
        Text() {
          Span(this.start)
            .fontSize($r('app.float.font_14'))
            .fontColor(this.clickTextPosition === TextClickPosition.START ?
            $r('sys.color.ohos_id_color_text_hyperlink') : $r('sys.color.ohos_id_color_text_hint'))
            .constraintSize({ minHeight: $r('app.float.length_19') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.START ? FontWeight.Medium : FontWeight.Regular)
            .onClick(() => {
              if (this.clickTextPosition === TextClickPosition.START) {
                this.onEntryClick();
              }
            })
          Span(this.middle)
            .fontSize($r('app.float.font_14'))
            .fontColor((this.clickTextPosition === TextClickPosition.MIDDLE) ?
            $r('sys.color.ohos_id_color_text_hyperlink') : $r('sys.color.ohos_id_color_text_hint'))
            .constraintSize({ minHeight: $r('app.float.length_19') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.MIDDLE ? FontWeight.Medium : FontWeight.Regular)
            .onClick(() => {
              if (this.clickTextPosition === TextClickPosition.MIDDLE) {
                this.onEntryClick();
              }
            })
          Span(this.end)
            .fontSize($r('app.float.font_14'))
            .fontColor((this.clickTextPosition === TextClickPosition.END) ?
            $r('sys.color.ohos_id_color_text_hyperlink') : $r('sys.color.ohos_id_color_text_hint'))
            .constraintSize({ minHeight: $r('app.float.length_19') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.END ? FontWeight.Medium : FontWeight.Regular)
            .onClick(() => {
              if (this.clickTextPosition === TextClickPosition.END) {
                this.onEntryClick();
              }
            })
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .size({ width: '100%' })
      .padding({
        top: DeviceUtil.isDevicePc() ? '12vp' : '0vp',
        left: $r('app.float.wh_value_12')
      })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .size({ width: '100%' })
  }

  pushName(key: string, params: PushParam | null): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu && this.menu.targetPageUrl) {
      this.pushName(this.menu.key as string, null);
    }
  }

  private transFormResource(resource: Resource): void {
    let result = ResourceUtil.getStringSync(resource);
    for (let i = 0; i < result.length; i++) {
      if (result[i] === '%' && result[i + 1] === 's') {
        if (i === 0) {
          this.clickTextPosition = TextClickPosition.START;
          this.start = $r('app.string.wifi_precision_title');
          this.middle = result.slice(0, i);
          this.end = result.slice(i + 2, result.length);
        } else if (i === (result.length - 1)) {
          this.clickTextPosition = TextClickPosition.END;
          this.start = result.slice(0, i);
          this.middle = result.slice(i + 2, result.length);
          this.end = $r('app.string.wifi_precision_title');
        } else {
          this.clickTextPosition = TextClickPosition.MIDDLE;
          this.start = result.slice(0, i);
          this.middle = $r('app.string.wifi_precision_title');
          this.end = result.slice(i + 2, result.length);
        }
        return
      }
    }
  }

  aboutToAppear(): void {
    this.style = this.menu?.style;
    let res = $r('app.string.wifi_precision_text');
    this.transFormResource(res);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct WifiLoadingHeaderComponent {
  private tag: string = 'WifiLoadingHeaderComponent:'
  @StorageLink('WlanListLoadingVisible') loadingVisible: boolean = false;
  @Link hasConnectedItem: boolean;
  setLoadingVisible: boolean = false;
  wifiTitle?: ResourceStr = '';

  build() {
    if (this.setLoadingVisible || this.hasConnectedItem) {
      Row() {
        Text(this.wifiTitle)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .font({
            size: $r('sys.float.ohos_id_text_size_sub_title3'),
            weight: FontWeight.Medium,
          })
          .margin({
            left: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16')
          })

        if (this.loadingVisible && this.setLoadingVisible) {
          LoadingProgress()
            .size({ width: '24vp', height: '24vp' })
            .margin({ right: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16') })
            .id('loading_progress_wifi_list_group')
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.SpaceBetween)
      .size({ width: '100%' })
      .constraintSize({ minHeight:this.getHeaderHeight() })
      .padding({
        top: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() : '0vp',
        bottom: FontScaleUtils.getCurrentTopPadding(),
        left: $r('sys.float.ohos_id_default_padding_start'),
        right: $r('sys.float.ohos_id_default_padding_end'),
      })
    }
  }

  getHeaderHeight(): number {
    let height = 56;
    const title = ResourceUtil.getStringSync(this.wifiTitle);
    // 已连接列表header
    if (title === ResourceUtil.getStringSync($r('app.string.wifi_connected_ap'))) {
      height = 48;
    }
    // 扫描列表header 如果上面有已连接热点则边距为56保持视觉一致
    if (title === ResourceUtil.getStringSync($r('app.string.wifi_available_ap_group'))) {
      height = this.hasConnectedItem ? 56 : 48;
    }
    LogUtil.info(`${this.tag} getHeaderHeight title：${title} height:${height}`);
    return height;
  }
}

@Component
export struct WifiListComponent {
  tag: string = 'WifiListComponent : ';
  menuSection: MenuSection | undefined;
  style: CardSectionListStyle = cardSectionListStyle;
  controller: MenuController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State lazyWifiMenus: MenuDataSource = new MenuDataSource([])

  uiRefresherWatch(): void {
    LogUtil.info(`${this.tag} uiRefresherWatch`)
    this.getWifiMenus();
  }

  build() {
    ListItemGroup() {
      if (this.lazyWifiMenus.totalCount() > COUNT_EMPTY) {
        LazyForEach(this.lazyWifiMenus, (menu: SettingsBaseMenu) => {
          ListItem() {
            ReusableWlanEntryComponent({
              menu: menu as SettingsBaseMenu,
              style: menu.style as DefaultEntryMenuStyle,
              controller: menu.getControllerInstance(this.uiRefresher) as MenuController,
              uiRefresher: this.uiRefresher,
              showTitle: menu.title?.toString(),
              showSummary: menu.summary as Resource,
              showStateIcon: menu.stateIcon,
              isHilink: menu.isNeedShowIcon as boolean,
            })
          }
        }, (menu: SettingsBaseMenu) => {
          return menu.toString();
        });
      }
    }
    .backgroundColor(this.style?.backgroundColor)
    .divider({
      strokeWidth: this.style?.divider?.strokeWidth ?? 0,
      color: this.style?.divider?.color,
      startMargin: this.style?.divider?.startMargin,
      endMargin: this.style?.divider?.endMargin,
    })
    .alignSelf(ItemAlign.Start)
    .clip(true)
    .borderRadius(this.style?.borderRadius)
    .margin({
      left: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
      right: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
    })
    .padding({
      top: $r('app.float.padding_4'),
      bottom: $r('app.float.padding_4'),
    })
    // （不要删除）手机版自定义组件不方便支持通用menu，目前通过占位方式显示入口。
    // 此处用以处理：没有可用WiFi只有占位时，不展示可用列表。（不要删除）
    .visibility((this.uiRefresher.isVisible() &&
      this.lazyWifiMenus.totalCount() > COUNT_EMPTY && this.lazyWifiMenus.getData(0)?.key) ?
    Visibility.Visible : Visibility.None);
  }

  private getWifiMenus(): void {
    let menus = (this.controller?.menu as MenuGroup)?.menus;
    if (!menus) {
      menus = this.menuSection?.getMenus() ?? [];
    }
    this.lazyWifiMenus.refreshData(menus);
    hasList = this.lazyWifiMenus.totalCount() > COUNT_EMPTY;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear ${this.menuSection?.getLogKey()}`);
    this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuController;
    if (this.menuSection?.style instanceof CardSectionListStyle) {
      this.style = this.menuSection.style as CardSectionListStyle;
    }
    this.getWifiMenus();
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct WifiConnectedComponent {
  tag: string = 'WifiConnectedComponent : ';
  menuSection: MenuSection | undefined;
  style: CardSectionListStyle = cardSectionListStyle;
  controller: MenuController | undefined = undefined;
  @State @Watch('uiRefresherWatch') uiRefresher: UiRefresher = new UiRefresher();
  @State menusArray: MenusArray | undefined = undefined;
  @Link hasConnectedItem: boolean;

  uiRefresherWatch(): void {
    this.menusArray = this.getMenus();
  }

  build() {
    if (this.menusArray) {
      ListItemGroup() {
        ForEach(this.menusArray.menus, (menu: SettingsBaseMenu) => {
          ListItem() {
            FlatEntryMenuComponent({ menu: menu });
          }
        }, (menu: SettingsBaseMenu) => {
          return menu.toString();
        });
      }
      .divider({
        strokeWidth: this.style?.divider?.strokeWidth ?? '0.5vp',
        color: this.style?.divider?.color,
        startMargin: this.style?.divider?.startMargin,
        endMargin: this.style?.divider?.endMargin,
      })
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .borderRadius(this.style?.borderRadius)
      .backgroundColor(this.style?.backgroundColor)
      .margin({
        left: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
        right: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
      })
      .padding({
        top: $r('app.float.padding_4'),
        bottom: $r('app.float.padding_4'),
      })
      .visibility((this.uiRefresher.isVisible() &&
        this.menusArray.menus.length > COUNT_EMPTY) ? Visibility.Visible : Visibility.None);
    }
  }

  private getMenus(): MenusArray {
    let menus = this.menuSection?.getMenus() ?? [];
    LogUtil.debug(`${this.tag} getMenus ${menus.length},  key ${this.menuSection?.getLogKey()}`);
    if (menus.length > 0) {
      this.hasConnectedItem = true;
    } else {
      this.hasConnectedItem = false;
    }
    return new MenusArray(menus);
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear ${this.menuSection?.getLogKey()}`);
    this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuController;
    if (this.menuSection?.style instanceof CardSectionListStyle) {
      this.style = this.menuSection.style as CardSectionListStyle;
    }
    this.menusArray = this.getMenus();
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct FlatEntryMenuComponent {
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
    TitleSummaryImageWlanEntryComponent({
      menu: $menu,
      style: this.style,
      controller: this.controller,
      uiRefresher: this.uiRefresher,
    });
  }

  aboutToAppear(): void {
    this.style = this.menu?.style as DefaultEntryMenuStyle;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct HotSpotListComponent {
  tag: string = 'HotSpotListComponent : ';
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
        Row() {
          Text($r('app.string.smart_hotspot_settings_title'))
            .id(`smart_hotspot_settings_title_ap_group`)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
            .fontWeight(FontWeight.Medium)
            .margin({ top: '12vp', bottom: '12vp' })
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .width('100%')
        .constraintSize({ minHeight: '48vp' })
        .padding({
          top: '0vp',
          bottom: '0vp',
          left: $r('sys.float.ohos_id_default_padding_start'),
          right: $r('sys.float.ohos_id_default_padding_end'),
        })
        .alignItems(VerticalAlign.Bottom)
        .justifyContent(FlexAlign.Start)
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .padding({
        left: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
        right: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
      })

      Column() {
        if (this.lazyHotSpotMenus.totalCount() > COUNT_EMPTY) {
          List() {
            LazyForEach(this.lazyHotSpotMenus, (menu: SettingsBaseMenu) => {
              ListItem() {
                if (menu instanceof HotSpotMenu) {
                  ReusableHotSpotEntryComponent({
                    menu: menu as SettingsBaseMenu,
                    style: menu.style as DefaultEntryMenuStyle,
                    showTitle: menu.title?.toString(),
                    isConnected: menu.isConnected,
                  })
                } else {
                  FlatEntryMenuComponent({ menu: menu })
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .backgroundColor(this.style?.backgroundColor)

            }, (menu: SettingsBaseMenu) => {
              return menu.toString();
            });
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
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
          .margin({
            left: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
            right: IS_PAD ? $r('app.float.padding_24') : $r('app.float.padding_16'),
          })
          .padding({
            top: $r('app.float.padding_4'),
            bottom: $r('app.float.padding_4'),
          })
          .visibility((this.uiRefresher.isVisible() && this.lazyHotSpotMenus.totalCount() > COUNT_EMPTY) ?
          Visibility.Visible : Visibility.None);
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .size({ width: RELATIVE_LENGTH })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .visibility((this.uiRefresher.isVisible() && this.lazyHotSpotMenus.totalCount() > COUNT_EMPTY) ?
    Visibility.Visible : Visibility.None);
  }

  private getHotSpotMenus(): void {
    let menus: SettingsBaseMenu[] = this.menuSection?.getMenus() ?? [];
    LogUtil.info(`${this.tag} get hotspot list, size:  ${menus.length}`);
    this.lazyHotSpotMenus.refreshData(menus);
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear ${this.menuSection?.getLogKey()}`);
    this.controller = this.menuSection?.getControllerInstance(this.uiRefresher) as MenuController;
    if (this.menuSection?.style instanceof CardSectionListStyle) {
      this.style = this.menuSection.style as CardSectionListStyle;
    }
    this.getHotSpotMenus();
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear ${this.menuSection?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}
