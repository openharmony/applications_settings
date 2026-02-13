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
import { data } from '@kit.TelephonyKit';
import call from '@ohos.telephony.call';
import {
    ItemResultType,
    ItemType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { settingSheetBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingSheet';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { PADDING_0, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { AirPlaneUtils } from '@ohos/settings.common/src/main/ets/utils/AirPlaneUtils';
import { SatelliteUtils, DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { AddOtherWlanComponent } from './component/AddOtherWlanComponent';
import { WifiUtils } from './WifiUtils';
import OpenNetWorkListController from './controller/new/OpenNetWorkListController';
import { MobileNetworkSwitchController } from './controller/new/MobileNetworkSwitchController';
import { NetWorkSettingsController } from './controller/new/NetWorkSettingsController';
import { WifiSwitchController } from './controller/new/WifiSwitchController';

// 网络设置页面
export const URL_NETWORK_SETTING_PAGE: string = 'network_setting_entry';
const NETWORK_SETTING: string = 'NetworkSetting';
const TAG: string = 'NetworkSettingPage: ';

@Builder
export function addOtherWlanBuilder(param: object): void {
  AddOtherWlanComponent()
}

function networkSettingPage(): SettingPageModel {
  let isWifiActive: boolean = WifiUtils.isWifiActive();
  let isMobileDateAvailable: boolean = call.hasVoiceCapability();
  let openNetWorkListController: OpenNetWorkListController = new OpenNetWorkListController();
  let isMobileDateEnabled: boolean = false;
  let isCellularDataEnabled: boolean = false;
  let isAirplaneActive: boolean = false;
  if (isMobileDateAvailable) {
    isAirplaneActive = AirPlaneUtils.isAirplaneActive();
    isMobileDateEnabled = SimUtils.hasSimCard() && !isAirplaneActive &&
      !SatelliteUtils.isCommunicationOpen();
    try {
      isCellularDataEnabled = data.isCellularDataEnabledSync();
    } catch (err) {
      LogUtil.error(`${TAG} isCellularDataEnabledSync failed:${err?.code}`);
    }
  }
  let mobileNetworkSwitchController: MobileNetworkSwitchController =
    new MobileNetworkSwitchController(isMobileDateAvailable, isAirplaneActive, isCellularDataEnabled);
  LogUtil.info(`${TAG} networkSettingPage, isMobileDateAvailable: ${isMobileDateAvailable}, isWifiActive: ${isWifiActive}, isCellularDataEnabled: ${isCellularDataEnabled}`);
  return {
    id: NETWORK_SETTING,
    url: URL_NETWORK_SETTING_PAGE,
    titleIcon: $r('app.media.ic_settings_wlan'),
    type: PageType.PAGE_TYPE_MODAL,
    title: $r('app.string.wifi_network_setting'),
    compControl: new NetWorkSettingsController(),
    layout: {
      padding: {
        bottom: PADDING_0,
        top: PADDING_8,
      },
      backgroundColor: DeviceUtil.isDevicePc() ? Color.Transparent : $r('app.color.component_ultra_thick_panel'),
      blurStyle: DeviceUtil.isDevicePc() ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.NONE,
    },
    fixedGroups: [
      {
        id: 'WlanConfig',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'MobileNetworkSwitch',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.mobile_network_settings_title') },
            enabled: isMobileDateEnabled,
            result: {
              type: ItemResultType.RESULT_TYPE_TOGGLE,
              result: {
                state: isCellularDataEnabled,
              }
            },
            compControl: mobileNetworkSwitchController,
          },
          {
            id: 'WlanSwitch',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: 'WLAN' },
            result: {
              type: ItemResultType.RESULT_TYPE_TOGGLE,
              result: {
                state: isWifiActive,
                enabled: WifiUtils.isWifiEnabled(),
              }
            },
            compControl: new WifiSwitchController(),
            layout: { background: { pressedBackgroundColor: Color.Transparent }},
          }
        ],
      }
    ],
    groups: [
      {
        id: 'WlanList',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: isWifiActive,
        layout: {
          margin: {
            top: PADDING_0,
            bottom: PADDING_0
          }
        },
        compControl: openNetWorkListController,
      }
    ],
    stickBottomContent: {
      id: 'AddOtherWlan',
      visible: isWifiActive,
      builder: wrapBuilder(addOtherWlanBuilder),
    }
  };
}

ModalLoader.load(URL_NETWORK_SETTING_PAGE, {
  configGenerator: networkSettingPage,
  pageBuilder: wrapBuilder(settingSheetBuilder),
});