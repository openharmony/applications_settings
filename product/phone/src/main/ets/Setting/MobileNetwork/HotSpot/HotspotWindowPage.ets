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

import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HotspotDevicesWindowController } from '../../../pages/mobilenetwork/controller/HotspotDevicesWindowController';
import { HotSpotUtils } from './utils/HotspotUtils';
import {
  connectDeviceItemWindowComponent,
  hotspotWindowTitleBuilder,
  MoreSettingButtonComponent,
  NoConnectedDeviceComponent
} from './view/HotspotWindowComponent';
/* instrument ignore file */
const HOTSPOT_WINDOW_TITLE: string = 'hotspot_window_title';
const TAG = 'HotspotWindowPage: ';
const DEFAULT_CACHE_COUNT = 3;
const ENTER_EXTERNAL_ENTRY: string = 'enter_hotspot_entry';

let storage = LocalStorage.getShared();

export class HotspotInfo {
  public deviceName: string = '';
  public ipInfo: string = '';
  public macInfo: string = '';
}

@Entry
@Component
struct HotspotWindowPage {
  @State controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  session: UIExtensionContentSession | undefined = storage?.get<UIExtensionContentSession>('uIExtensionSession');
  @State connectDevicesMenu: Array<HotspotInfo> = [];
  hotspotWindowController: HotspotDevicesWindowController = new HotspotDevicesWindowController();

  build() {
    Column() {
      hotspotWindowTitleBuilder($r('sys.symbol.hotspot'), $r('app.string.hotspot_settings_title'), HOTSPOT_WINDOW_TITLE)

      Column() {
        this.bondedDeviceListBuilder()
      }
      .layoutWeight(1)

      MoreSettingButtonComponent({
        controlCenterColor: this.controlCenterColor,
        onMoreSettingClick: () => {
          this.onMoreSettingClick();
        },
      })
    }
    .size({ width: '100%', height: '100%' })
    .borderRadius($r('app.float.wh_value_32'))
    .onAppear(() => {
      AccessibilityUtils.requestFocusAccessibilityWithBundleName(HOTSPOT_WINDOW_TITLE);
    })
  }

  onMoreSettingClick(): void {
    LogUtil.info(`${TAG} onMoreSettingClick startAbilityForResult`);
    let message: string =
      `bundleName: ${PackagesConstant.SETTINGS_BUNDLE_NAME}, abilityName: ` +
        `${PackagesConstant.SETTINGS_MAIN_ABILITY_NAME}, navEntryKey: ${NavEntryKey.HOTSPOT_ENTRY}`;
    HiSysEventUtil.reportEntryEventByUE(ENTER_EXTERNAL_ENTRY, message);
    AbilityUtils.startAbilityForResult({
      bundleName: PackagesConstant.SETTINGS_BUNDLE_NAME,
      abilityName: PackagesConstant.SETTINGS_MAIN_ABILITY_NAME,
      uri: NavEntryKey.HOTSPOT_ENTRY,
    }, () => {
      this.session?.sendData({ 'method': 'hideControlCenter' });
    });
  }

  aboutToAppear(): void {
    this.hotspotWindowController.bindList(this.connectDevicesMenu);
    this.hotspotWindowController.registerDataChange();
  }

  aboutToDisappear(): void {
    this.hotspotWindowController.unRegisterDataChange();
  }

  @Builder
  bondedDeviceListBuilder() {
    if (this.connectDevicesMenu?.length > 0) {
      List() {
        ForEach(this.connectDevicesMenu, (info: HotspotInfo, index: number) => {
          connectDeviceItemWindowComponent({
            deviceName: info.deviceName,
            ipString: info.ipInfo,
            macString: info.macInfo
          })
        }, (menu: HotspotInfo, index: number) => {
          return index + menu.deviceName + menu.ipInfo;
        });
      }
      .width('100%')
      .height('100%')
      .cachedCount(DEFAULT_CACHE_COUNT)
      .divider({
        strokeWidth: px2vp(1),
        color: $r('app.color.bluetooth_window_settings_divider_color'),
        startMargin: $r('app.float.wh_value_56'),
        endMargin: $r('app.float.wh_value_16'),
      })
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
    } else {
      NoConnectedDeviceComponent({
        isHotspotOn: HotSpotUtils.isHotspotActive()
      })
    }
  }
}