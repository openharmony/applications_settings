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
import { LengthMetrics } from '@ohos.arkui.node';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_20,
  PADDING_23,
  PADDING_24
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { PluginComponentUtil } from '@ohos/settings.common/src/main/ets/utils/PluginComponentUtil';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { BtWindowSettingsBondDeviceItemComponent } from './BtWindowSettingsBondDeviceItemComponent';
import { BluetoothWindowSettingsViewModel } from '../ViewModel/BluetoothWindowSettingsViewModel';
import { BluetoothWindowBondDeviceViewModel } from '../ViewModel/BluetoothWindowBondDeviceViewModel';
import { MenuEntry } from '../model/MenuEntry';
import {
  DEVICE_ITEM_SPACE,
  PcModeBluetoothWindowBondDeviceViewModel
} from '../ViewModel/PcModeBluetoothWindowBondDevicViewModel';
import { PLUGIN_BLUETOOTH_ICON_URL } from '../constants/BluetoothConstants';
import { PcModeWindowSwitchViewModel } from '../model/PcModeWindowSwitchViewModel';

const TAG: string = 'PcModeBluetoothWindowSettingsComponent: ';
const ENTER_EXTERNAL_ENTRY: string = 'enter_external_entry';
const BLUETOOTH_SETTINGS_BUTTON_LEFT_MARGIN: LengthMetrics = LengthMetrics.vp(3.68);
const BLUETOOTH_SETTINGS_BUTTON_RIGHT_MARGIN: LengthMetrics = LengthMetrics.vp(4);
const BLUETOOTH_SETTINGS_BUTTON_BOTTOM_MARGIN: LengthMetrics = LengthMetrics.vp(3.15);
const BLUETOOTH_SETTINGS_BUTTON_HEIGHT: string = '39.5vp';

@Component
export struct PcModeBluetoothWindowSettingsComponent {
  @State buttonBgColor: ResourceColor = Color.Transparent;
  @State switchViewModel: PcModeWindowSwitchViewModel = new PcModeWindowSwitchViewModel();
  @State bondDevicesMenu: MenuEntry[] = [];
  scroller?: Scroller;
  bluetoothSettingsViewModel: BluetoothWindowSettingsViewModel = new BluetoothWindowSettingsViewModel();
  bondDeviceViewModel: BluetoothWindowBondDeviceViewModel = new PcModeBluetoothWindowBondDeviceViewModel();

  build() {
    Column() {
      // BlueTooth Title Switch
      this.titleAndSwitchBuilder()

      // Connected Device List
      this.bondedDeviceListBuilder()

      // Divider
      this.dividerBuilder()

      // BlueTooth Settings Button
      this.buttonBuilder()
    }
    .size({ width: '100%', height: '100%' })
    .keyboardShortcut(FunctionKey.ESC, [], () => {
      PluginComponentUtil.pushPluginAndData(PackagesConstant.SETTINGS_BUNDLE_NAME,
        PackagesConstant.SETTINGS_BUNDLE_NAME, PLUGIN_BLUETOOTH_ICON_URL, true);
    })
  }

  @Builder
  titleAndSwitchBuilder() {
    Row() {
      Column() {
        Text($r('app.string.bluetooth_settings_title'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('app.color.statusbar_blend_color'))
          .advancedBlendMode(BlendModeUtil.getBlender())
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.switchViewModel.isChecked })
        .onChange((isOn: boolean) => {
          this.switchViewModel?.handleCheckedChange(isOn);
        })
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .switchStyle({ unselectedColor: $r('sys.color.comp_background_secondary') })
        .hoverEffect(HoverEffect.Highlight)
    }
    .flexShrink(0)
    .width('100%')
    .constraintSize({
      minHeight: $r('app.float.height_56')
    })
    .padding({
      start: PADDING_23,
      end: PADDING_20,
    })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  bondedDeviceListBuilder() {
    if (this.switchViewModel.isChecked) {
      Column() {
        if (this.bondDevicesMenu?.length > 0) {
          Column() {
            Text($r('app.string.bluetooth_bonded_devices'))
              .fontColor($r('app.color.statusbar_blend_color'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontFamily('HarmonyHeiTi')
              .advancedBlendMode(BlendModeUtil.getBlenderTertiary())
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .constraintSize({
            minHeight: $r('app.float.height_32')
          })
          .padding({
            start: PADDING_24,
          })
          .flexShrink(0)

          List({ scroller: this.scroller, space: DEVICE_ITEM_SPACE }) {
            ForEach(this.bondDevicesMenu, (menu: MenuEntry, index: number) => {
              ListItem() {
                BtWindowSettingsBondDeviceItemComponent({
                  menu: menu,
                  bondDeviceViewModel: this.bondDeviceViewModel,
                  index: index,
                  tabInd: !index ? TabIndexConstants.TAB_INDEX_LEVEL2_PAGE : TabIndexConstants.TAB_INDEX_DEFAULT,
                  menuLength: this.bondDevicesMenu?.length ?? 0,
                })
              }
            }, (menu: MenuEntry) => {
              return JSON.stringify(menu);
            });
          }
          .scrollBar(BarState.Off)
          .alignSelf(ItemAlign.Start)
          .clip(true)
          .flexShrink(1)
        } else {
          Column() {
            Text($r('app.string.bluetooth_no_paired_devices'))
              .fontColor($r('app.color.statusbar_blend_color'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .advancedBlendMode(BlendModeUtil.getBlender())
              .constraintSize({
                minHeight: $r('app.float.height_24'),
              })
          }
          .width('100%')
          .constraintSize({
            minHeight: $r('app.float.height_40'),
          })
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
          .padding({
            start: PADDING_24,
          })
        }
      }
      .flexShrink(1)
      .width('100%')
    }
  }

  @Builder
  dividerBuilder() {
    Row() {
      Divider()
        .vertical(false)
        .height(px2vp(1))
        .color($r('sys.color.comp_divider'))
    }
    .flexShrink(0)
    .height(8)
    .padding({
      top: $r('sys.float.padding_level2'),
      bottom: $r('sys.float.padding_level2'),
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    })
  }

  @Builder
  buttonBuilder() {
    Column() {
      Column() {
        Text($r('app.string.bluetooth_settings'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('app.color.statusbar_blend_color'))
          .advancedBlendMode(BlendModeUtil.getBlender())
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .padding({
        left: $r('sys.float.padding_level10'),
        right: $r('sys.float.padding_level10'),
      })
      .constraintSize({
        minHeight: BLUETOOTH_SETTINGS_BUTTON_HEIGHT
      })
      .width('100%')
      .borderRadius($r('sys.float.corner_radius_level6'))
      .backgroundColor(this.buttonBgColor)
    }
    .flexShrink(0)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .margin({
      start: BLUETOOTH_SETTINGS_BUTTON_LEFT_MARGIN,
      end: BLUETOOTH_SETTINGS_BUTTON_RIGHT_MARGIN,
      bottom: BLUETOOTH_SETTINGS_BUTTON_BOTTOM_MARGIN,
    })
    .borderRadius($r('sys.float.corner_radius_level6'))
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .onHover((isHover?: boolean) => {
      this.onHoverEvent(isHover);
    })
    .onTouch((event?: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .onMouse((event?: MouseEvent): void => {
      this.onMouseEvent(event)
    })
    .onClick((event) => {
      this.onMoreSettingClick();
    })
  }

  onMoreSettingClick(): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.BLUETOOTH_CLICK_TITLE);
    let message: string =
      `bundleName: ${PackagesConstant.SETTINGS_BUNDLE_NAME}; abilityName: ${PackagesConstant.SETTINGS_MAIN_ABILITY_NAME}`;
    HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
    AbilityUtils.startAbilityForResult({
      bundleName: PackagesConstant.SETTINGS_BUNDLE_NAME,
      abilityName: PackagesConstant.SETTINGS_MAIN_ABILITY_NAME,
      uri: NavEntryKey.BLUETOOTH_ENTRY,
    }, () => {
      WindowManager.closePluginWindow(PLUGIN_BLUETOOTH_ICON_URL, true);
    });
  }

  aboutToAppear(): void {
    LogUtil.info(TAG + 'aboutToAppear');
    this.bluetoothSettingsViewModel.initConfig();
    this.switchViewModel.init();
    this.bondDeviceViewModel.init(this.bondDevicesMenu);
  }

  private onHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.buttonBgColor = $r('sys.color.interactive_hover');
    } else {
      this.buttonBgColor = Color.Transparent;
    }
  }

  private onTouchEvent(event?: TouchEvent): void {
    if (event && event.type === TouchType.Down) {
      this.buttonBgColor = $r('sys.color.interactive_click');
    }
    if (event && event.type === TouchType.Up) {
      this.buttonBgColor = Color.Transparent;
    }
  }

  private onMouseEvent(event?: MouseEvent): void {
    if (event && event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.buttonBgColor = $r('sys.color.interactive_click');
    } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.buttonBgColor = Color.Transparent;
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(TAG + 'aboutToDisappear');
    this.switchViewModel.destroy();
    this.bluetoothSettingsViewModel.deinitConfig();
    this.bondDeviceViewModel.destroy();
  }

  onPageShow(): void {
    LogUtil.info(TAG + 'onPageShow');
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.CLICK_BLUETOOTH_TEXT_POP_UPS);
  }

  onPageHide(): void {
    LogUtil.info(TAG + 'onPageHide');
  }
}
