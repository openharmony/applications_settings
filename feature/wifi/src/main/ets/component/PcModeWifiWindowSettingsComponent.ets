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

import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  EVENT_ID_PC_MODE_WLAN_LIST_COLLAPSE_STATE_CHANGE,
  EVENT_ID_PC_MODE_WLAN_LIST_VISIBLE,
  EVENT_ID_PC_MODE_WLAN_SWITCH,
  EVENT_ID_PC_MODE_WLAN_CONNECTED_VISIBLE,
  EVENT_ID_PC_MODE_SHARED_NETWORK_VISIBLE
} from '@ohos/settings.common/src/main/ets/event/types';
import { FOCUS_BOX_PADDING_METRICS, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { PcModeWifiSwitchController } from '../controller/new/PcModeWifiSwitchController';
import { PluginComponentUtil } from '@ohos/settings.common/src/main/ets/utils/PluginComponentUtil';
import { ApMenu } from '../model/WifiModel';
import {
  AVAILABLE_LIST_MAX_HEIGHT_UNCONNECTED,
  PcModeWifiWindowPageController,
  PLUGIN_WIFI_ICON_URL
} from '../controller/new/PcModeWifiWindowPageController';
import { PcModeWifiWindowDataSource } from '../model/PcModeWifiWindowDataSource';
import { PcModeWifiWindowItemComponent } from './PcModeWifiWindowItemComponent';
import { WifiUtils } from './../WifiUtils';
import { WifiState } from '../model/WifiModel';
import { PcModeSharedNetworkController } from '../controller/new/PcModeSharedNetworkController';
import { PcModeSharedNetworkDataSource } from '../model/PcModeSharedNetworkDataSource';
import { SharedNetworkMenu } from '../model/SharedNetworkPanelModel';
import { PcModeSharedNetworkComponent } from './PcModeSharedNetworkComponent';

/* instrument ignore file */
const TAG: string = 'PcModeWifiWindowSettingsComponent : ';

const RELATIVE_LENGTH: string = '100%';
const LIST_CONTENT_HEIGHT: string = 'calc(100% - 32vp)';
const DEFAULT_CACHE_COUNT: number = 3;
const LIST_COUNT_1: number = 1;

const SPAN_12: number = 12;
const MORE_WIFI_SETTINGS_BUTTON_LEFT_MARGIN: string = '3.68vp';
const MORE_WIFI_SETTINGS_BUTTON_RIGHT_MARGIN: string = '4vp';
const MORE_WIFI_SETTINGS_BUTTON_BOTTOM_MARGIN: string = '3.15vp';
const ENTER_EXTERNAL_ENTRY: string = 'enter_external_entry';

@Component
export struct PcModeWifiWindowSettingsComponent {
  @State isArrowHover: boolean = false;
  @State operationIcon: ResourceStr = $r('app.media.ic_arrow_down_light');
  @State buttonMoreSettingBgColor: ResourceColor = Color.Transparent;
  @State isListExpand: boolean = true;
  @State isAvailableListVisible: boolean = false;
  @State isConnectedWifiVisible: boolean = false;
  @State isSharedNetworkVisible: boolean = false;
  private isChecked: boolean = false;
  private wifiSwitchController: PcModeWifiSwitchController = new PcModeWifiSwitchController();
  private pcModeWifiWindowPageController: PcModeWifiWindowPageController = new PcModeWifiWindowPageController();
  private dataSource: PcModeWifiWindowDataSource = new PcModeWifiWindowDataSource();
  private connectedMenus: PcModeWifiWindowDataSource = new PcModeWifiWindowDataSource();
  private sharedNetworkDataSource: PcModeSharedNetworkDataSource = new PcModeSharedNetworkDataSource();
  private sharedNetworkController: PcModeSharedNetworkController = new PcModeSharedNetworkController();
  private scroller: Scroller = new Scroller;
  private onToggleChangeCallback = (toggleState: number) => {
    LogUtil.info(`${TAG} receive toggle state change: ${toggleState}`);
    let isToggleSwitchOn: boolean = toggleState === WifiState.ACTIVE;
    if (this.isChecked === isToggleSwitchOn) {
      LogUtil.info(`${TAG} toggleState is not change`);
      return;
    }
    this.isChecked = isToggleSwitchOn;
    if (!isToggleSwitchOn) {
      this.isConnectedWifiVisible = false;
      this.isSharedNetworkVisible = false;
    }
  }
  private onListVisibleChangeCallback = (isShow: boolean) => {
    LogUtil.info(`${TAG} onListVisibleChangeCallback Visible: ${isShow}`);
    this.isAvailableListVisible = isShow;
    if (!this.isAvailableListVisible) {
      this.isListExpand = true;
      this.operationIcon = $r('app.media.ic_arrow_down_light');
    }
  }
  private onConnectedWifiChangeCallback = (isShow: boolean) => {
    LogUtil.info(`${TAG} onConnectedWifiChangeCallback Visible: ${isShow}`);
    this.isConnectedWifiVisible = isShow;
  }
  private onSharedNetworkChangeCallback = (isShow: boolean) => {
    LogUtil.info(`${TAG} onSharedNetworkChangeCallback Visible: ${isShow}`);
    this.isSharedNetworkVisible = isShow;
  }

  build() {
    Column() {
      // WLAN开关
      this.titleAndSwitchBuilder();

      // 已连接
      this.wifiConnectedComponent();

      // 共享网络
      this.sharedNetworkComponent();

      // 可用列表
      this.wifiAvailableListBuilder();

      // 分割线
      this.windowDividerComponent();

      // WLAN 设置
      this.moreSettingBuilder();
    }
    .size({ width: '100%', height: '100%' })
    .keyboardShortcut(FunctionKey.ESC.toString(), [], () => {
      PluginComponentUtil.pushPluginAndData(PackagesConstant.SETTINGS_BUNDLE_NAME,
        PackagesConstant.SETTINGS_BUNDLE_NAME, PLUGIN_WIFI_ICON_URL, true);
    })
  }

  @Builder
  wifiConnectedComponent() {
    Column() {
      Column() {
        Text($r('app.string.wifi_connected_ap'))
          .fontColor($r('app.color.statusbar_blend_color'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .advancedBlendMode(BlendModeUtil.getBlenderTertiary())
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .constraintSize({
        minHeight: $r('app.float.height_32')
      })
      .margin({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      })

      Column() {
        List() {
          LazyForEach(this.connectedMenus, (item: ApMenu) => {
            ListItem() {
              PcModeWifiWindowItemComponent({ menu: item });
            }
          }, (item: ApMenu) => {
            let stateIconId: string = (item.stateIcon as Resource)?.id?.toString() || '';
            return `${item?.toString()}${stateIconId}${item.index}`;
          })
        }
        .scrollBar(BarState.Off)
        .alignSelf(ItemAlign.Start)
        .clip(true)
        .lanes(1)
        .padding({
          left: $r('sys.float.padding_level2'),
          right: $r('sys.float.padding_level2')
        })

        // show split lines
        this.windowDividerComponent();
      }
      .size({ width: RELATIVE_LENGTH });
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .visibility(this.isConnectedWifiVisible ? Visibility.Visible : Visibility.None);
  }

  @Builder
  sharedNetworkComponent() {
    Column() {
      Column() {
        Text($r('app.string.shared_network_ap_group'))
          .fontColor($r('app.color.statusbar_blend_color'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .advancedBlendMode(BlendModeUtil.getBlenderTertiary())
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .constraintSize({
        minHeight: $r('app.float.height_32')
      })
      .margin({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      })

      Column() {
        List() {
          LazyForEach(this.sharedNetworkDataSource, (item: SharedNetworkMenu) => {
            ListItem() {
              PcModeSharedNetworkComponent({ menu: item});
            }
          }, (item: SharedNetworkMenu) => {
            let stateIconId: string = (item.stateIcon as Resource)?.id?.toString() || '';
            return `${item?.toString()}${stateIconId}${item.index}`;
          })
        }
        .scrollBar(BarState.Off)
        .alignSelf(ItemAlign.Start)
        .clip(true)
        .lanes(1)
        .padding({
          left: $r('sys.float.padding_level2'),
          right: $r('sys.float.padding_level2')
        })

        this.windowDividerComponent();
      }
      .size({ width: RELATIVE_LENGTH});
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .visibility(this.isSharedNetworkVisible ? Visibility.Visible : Visibility.None);
  }

  @Builder
  wifiAvailableListBuilder() {
    Column() {
      // 可用wifi 收起
      this.collapseArrowBuilder()
      // wifi扫描列表
      this.listBuilder()
    }
    .flexShrink(1)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .visibility(this.isAvailableListVisible ? Visibility.Visible : Visibility.None);
  }

  @Builder
  collapseArrowBuilder() {
    // 可用wifi 收起
    Row({ space: SPAN_12 }) {
      Column() {
        Text($r('app.string.wifi_available_ap_group'))
          .fontColor($r('app.color.statusbar_blend_color'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .advancedBlendMode(BlendModeUtil.getBlenderTertiary());
      }
      .constraintSize({
        minHeight: $r('app.float.length_24'),
      })
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center);

      Column() {
        Image(this.operationIcon)
          .width($r('app.float.wh_value_24'))
          .height($r('app.float.wh_value_12'))
          .fillColor($r('app.color.statusbar_blend_color'))
          .advancedBlendMode(BlendModeUtil.getBlenderTertiary())
          .objectFit(ImageFit.Cover)
          .draggable(false);
      }
      .onHover((isHover) => {
        this.isArrowHover = isHover;
      })
      .padding({
        top: $r('sys.float.padding_level3'),
        bottom: $r('sys.float.padding_level3')
      })
      .stateStyles({
        normal: {
          .backgroundColor(this.isArrowHover ? $r('sys.color.interactive_hover') : Color.Transparent)
        },
        pressed: {
          .backgroundColor($r('sys.color.interactive_click'))
          .borderRadius($r('sys.float.corner_radius_level2'))
        }
      })
      .borderRadius($r('sys.float.corner_radius_level2'))
      .onClick(() => {
        this.isListExpand = !this.isListExpand;
        this.isArrowHover = false;
        if (this.isListExpand) {
          this.operationIcon = $r('app.media.ic_arrow_down_light');
        } else {
          this.operationIcon = $r('app.media.ic_arrow_up_light');
        }
        EventBus.getInstance().emit(EVENT_ID_PC_MODE_WLAN_LIST_COLLAPSE_STATE_CHANGE, this.isListExpand);
      });
    }
    .width('100%')
    .height($r('app.float.length_32'))
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    })
  }

  @Builder
  listBuilder() {
    Column() {
      List({ scroller: this.scroller }) {
        LazyForEach(this.dataSource, (item: ApMenu) => {
          ListItem() {
            PcModeWifiWindowItemComponent({ menu: item })
          }
        }, (item: ApMenu) => {
          let stateIconId: string = (item.stateIcon as Resource)?.id?.toString() || '';
          return `${item?.toString()}${stateIconId}${item.index}`;
        })
      }
      .flexShrink(1)
      .cachedCount(DEFAULT_CACHE_COUNT)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(this.dataSource?.totalCount() <= LIST_COUNT_1 ? BarState.Off : BarState.Auto)
      .height(RELATIVE_LENGTH)
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .lanes(1)
      .padding({
        left: '3.5vp',
        right: $r('sys.float.padding_level2'),
      })
      .constraintSize({
        maxHeight: AVAILABLE_LIST_MAX_HEIGHT_UNCONNECTED,
      })
      .visibility(this.isListExpand ? Visibility.Visible : Visibility.None);
    }
    .flexShrink(1)
    .size({ width: RELATIVE_LENGTH, height: LIST_CONTENT_HEIGHT });
  }

  @Builder
  titleAndSwitchBuilder() {
    Row() {
      Column() {
        Text($r('app.string.wifi_settings_title'))
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
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: (this.wifiSwitchController?.getChecked() ?? false) })
        .id(`entry_toggle_wifi`)
        .onChange((isOn: boolean) => {
          this.wifiSwitchController?.onToggleChange(isOn);
        })
        .switchPointColor(WifiUtils.isWifiEnabled() ? $r('sys.color.ohos_id_color_foreground_contrary') :
        $r('sys.color.ohos_id_color_foreground_contrary_disable'))
        .switchStyle({ unselectedColor: $r('sys.color.comp_background_secondary') })
        .hoverEffect(HoverEffect.None)
        .size({ width: $r('app.float.height_36'), height: $r('app.float.length_20') })
        .enabled(WifiUtils.isWifiEnabled())
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
    .enabled(WifiUtils.isWifiEnabled() ? true : false)
  }

  @Builder
  windowDividerComponent() {
    Row() {
      Divider()
        .height(px2vp(1))
        .color($r('sys.color.ohos_id_color_list_separator'))
    }
    .width('100%')
    .padding({
      top: $r('sys.float.padding_level2'),
      bottom: $r('sys.float.padding_level2'),
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12')
    })
  }

  @Builder
  moreSettingBuilder() {
    Column() {
      Column() {
        Text($r('app.string.wifi_settings'))
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
      .borderRadius('12vp')
      .backgroundColor(this.buttonMoreSettingBgColor)
      .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
      .onHover((isHover?: boolean) => {
        this.onMoreSettingHoverEvent(isHover);
      })
      .onTouch((event?: TouchEvent) => {
        this.onMoreSettingTouchEvent(event);
      })
      .onMouse((event?: MouseEvent): void => {
        this.onMoreSettingMouseEvent(event)
      })
      .onClick(() => {
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

  aboutToAppear(): void {
    LogUtil.info(TAG + 'aboutToAppear');
    this.wifiSwitchController.init();
    this.pcModeWifiWindowPageController.bindList(this.dataSource);
    this.pcModeWifiWindowPageController.bindConnectedWifiList(this.connectedMenus);
    this.pcModeWifiWindowPageController.aboutToAppear();
    this.pcModeWifiWindowPageController.resetCollapseState();
    EventBus.getInstance().on(EVENT_ID_PC_MODE_WLAN_SWITCH, this.onToggleChangeCallback);
    EventBus.getInstance().on(EVENT_ID_PC_MODE_WLAN_LIST_VISIBLE, this.onListVisibleChangeCallback);
    EventBus.getInstance().on(EVENT_ID_PC_MODE_WLAN_CONNECTED_VISIBLE, this.onConnectedWifiChangeCallback);
    EventBus.getInstance().on(EVENT_ID_PC_MODE_SHARED_NETWORK_VISIBLE, this.onSharedNetworkChangeCallback);
    // add sharedNetwork
    this.sharedNetworkController.init();
    this.sharedNetworkController.bindList(this.sharedNetworkDataSource);

    this.wifiSwitchController.onPageShow();
    this.pcModeWifiWindowPageController.onPageShow();
  }

  aboutToDisappear(): void {
    LogUtil.info(TAG + 'aboutToDisappear');
    this.wifiSwitchController.destroy();
    this.sharedNetworkController.destroy();
    this.pcModeWifiWindowPageController.onPageHide();
    this.pcModeWifiWindowPageController.aboutToDisappear();
    this.pcModeWifiWindowPageController.resetCollapseState();
    EventBus.getInstance().detach(EVENT_ID_PC_MODE_WLAN_SWITCH, this.onToggleChangeCallback);
    EventBus.getInstance().detach(EVENT_ID_PC_MODE_WLAN_LIST_VISIBLE, this.onListVisibleChangeCallback);
    EventBus.getInstance().detach(EVENT_ID_PC_MODE_WLAN_CONNECTED_VISIBLE, this.onConnectedWifiChangeCallback);
    EventBus.getInstance().detach(EVENT_ID_PC_MODE_SHARED_NETWORK_VISIBLE, this.onSharedNetworkChangeCallback);
  }

  private onMoreSettingHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.buttonMoreSettingBgColor = $r('sys.color.interactive_hover');
    } else {
      this.buttonMoreSettingBgColor = Color.Transparent;
    }
  }

  private onMoreSettingTouchEvent(event?: TouchEvent): void {
    if (event && event.type === TouchType.Down) {
      this.buttonMoreSettingBgColor = $r('sys.color.interactive_click');
    }
    if (event && event.type === TouchType.Up) {
      this.buttonMoreSettingBgColor = Color.Transparent;
    }
  }

  private onMoreSettingMouseEvent(event?: MouseEvent): void {
    if (event && event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.buttonMoreSettingBgColor = $r('sys.color.interactive_click');
    } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.buttonMoreSettingBgColor = Color.Transparent;
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
    LogUtil.info(`${TAG} onMoreSettingClick startAbilityForResult ${message}`);
    (getContext(this) as common.UIExtensionContext).startAbility(want).then(() => {
      LogUtil.info(`${TAG} startAbility success.`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} startAbility fail, error = { code: ${error?.code}, message: ${error?.message} }.`);
    })
  }
}