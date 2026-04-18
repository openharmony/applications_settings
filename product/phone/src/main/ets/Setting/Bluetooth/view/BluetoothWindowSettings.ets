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
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { MenuEntry } from '@ohos/settings.bluetooth/src/main/ets/model/MenuEntry';
import {
  BluetoothWindowSettingsViewModel
} from '@ohos/settings.bluetooth/src/main/ets/ViewModel/BluetoothWindowSettingsViewModel';
import {
  BluetoothWindowBondDeviceViewModel
} from '@ohos/settings.bluetooth/src/main/ets/ViewModel/BluetoothWindowBondDeviceViewModel';
import { BluetoothBondDeviceItemWindowComponent } from './BluetoothBondDeviceItemWindowComponent';
import {
  MoreSettingButtonComponent,
  NoPairedDeviceComponent,
  outerScreenTitleComponentBuilder,
  titleComponentBuilder,
} from '../../ControlCenterCommon/view/WindowCommonComponent';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'BluetoothWindowSettings : ';
const ENTER_EXTERNAL_ENTRY: string = 'enter_external_entry';
const DEFAULT_CACHE_COUNT = 3;
const BLUETOOTH_WLAN_TITLE: string = 'bluetooth_window_title';
let storage = LocalStorage.getShared();

interface ReceiveData {
  controlCenterColor?: number;
}

@Entry
@Component
struct BluetoothWindowSettings {
  scroller?: Scroller;
  session: UIExtensionContentSession | undefined =
    storage?.get<UIExtensionContentSession>('UIExtensionSession');
  private isOuterScreen: boolean = CommonUtils.isOuterScreen();
  @State controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  bluetoothSettingsViewModel: BluetoothWindowSettingsViewModel = new BluetoothWindowSettingsViewModel();
  bondDeviceViewModel: BluetoothWindowBondDeviceViewModel = new BluetoothWindowBondDeviceViewModel();
  @State @Watch('onBondDevicesMenuChange') bondDevicesMenu: MenuEntry[] = [];

  build() {
    Column() {
      if (this.isOuterScreen) {
        outerScreenTitleComponentBuilder($r('app.media.ic_bluetooth_device_public'),
          $r('app.string.bluetooth_settings_title'), BLUETOOTH_WLAN_TITLE)
      } else {
        titleComponentBuilder($r('app.media.ic_bluetooth_device_public'), $r('app.string.bluetooth_settings_title'),
          BLUETOOTH_WLAN_TITLE)
      }

      Column() {
        this.bondedDeviceListBuilder()
      }
      .layoutWeight(1)

      if (!this.isOuterScreen) {
        MoreSettingButtonComponent({
          controlCenterColor: this.controlCenterColor,
          onMoreSettingClick: () => {
            this.onMoreSettingClick();
          },
        })
      }
    }
    .size({ width: '100%', height: '100%' })
    .borderRadius(32)
  }

  @Builder
  bondedDeviceListBuilder() {
    if (this.bondDevicesMenu?.length > 0) {
      List({ scroller: this.scroller }) {
        ForEach(this.bondDevicesMenu, (menu: MenuEntry) => {
          BluetoothBondDeviceItemWindowComponent({
            menu: menu,
            bondDeviceViewModel: this.bondDeviceViewModel,
            controlCenterColor: this.controlCenterColor,
          })
        }, (menu: MenuEntry) => {
          return JSON.stringify(menu);
        });
      }
      .width('100%')
      .height('100%')
      .cachedCount(DEFAULT_CACHE_COUNT)
      .divider({
        strokeWidth: px2vp(1),
        color: $r('app.color.bluetooth_window_settings_divider_color'),
        startMargin: $r('app.float.wh_value_60'),
        endMargin: $r('app.float.wh_value_24'),
      })
      .alignSelf(ItemAlign.Start)
      .clip(true)
    } else {
      NoPairedDeviceComponent()
    }
  }

  onMoreSettingClick(): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.BLUETOOTH_CLICK_TITLE);
    let bundleName: string = PackagesConstant.SETTINGS_BUNDLE_NAME;
    let abilityName: string = PackagesConstant.SETTINGS_MAIN_ABILITY_NAME;
    let navEntryKey: string = NavEntryKey.BLUETOOTH_ENTRY;
    let message: string = `bundleName: ${bundleName}; abilityName: ${abilityName}`;
    HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
    LogUtil.info(`${TAG} onMoreSettingClick startAbilityForResult ${message}`);
    AbilityUtils.startAbilityForResult({
      bundleName: bundleName,
      abilityName: abilityName,
      uri: navEntryKey,
    }, () => {
      this.session?.sendData({ 'method': 'hideControlCenter' });
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.bluetoothSettingsViewModel.initConfig();
    this.bondDeviceViewModel.init(this.bondDevicesMenu);
    // 主题颜色
    const controlCenterSubPanelColor = AppStorage.get<number>('control_center_sub_panel_color');
    if (typeof controlCenterSubPanelColor === 'number') {
      this.controlCenterColor = controlCenterSubPanelColor;
      LogUtil.info(`${TAG} init controlCenterColor:${this.controlCenterColor}`);
    }
    this.initSessionReceiveDataCallback();
    // 无障碍
    AccessibilityUtils.requestFocusAccessibility(BLUETOOTH_WLAN_TITLE);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.bluetoothSettingsViewModel.deinitConfig();
    this.bondDeviceViewModel.destroy();
  }

  /**
   * 监听拉起方发送的数据
   */
  private initSessionReceiveDataCallback(): void {
    try {
      this.session?.setReceiveDataCallback((data: ReceiveData) => {
        const controlCenterSubPanelColor = data?.controlCenterColor;
        if (typeof controlCenterSubPanelColor === 'number') {
          LogUtil.info(`${TAG} setReceiveDataCallback new controlCenterColor:${controlCenterSubPanelColor}`);
          this.controlCenterColor = controlCenterSubPanelColor;
        }
      })
    } catch (error) {
      LogUtil.error(`${TAG} setReceiveDataCallback catch error. code:${error?.code} message:${error?.message}`);
    }
  }

  onBondDevicesMenuChange() {
    AccessibilityUtils.requestFocusAccessibility(BLUETOOTH_WLAN_TITLE);
  }
}
