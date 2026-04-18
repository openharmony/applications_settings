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
import { PADDING_16, PADDING_8, PADDING_88 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { settingSheetBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingSheet';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ConnectWlanComponent, ADD_OTHER_WLAN_CONFIG } from './component/ConnectWlanComponent';
import { WlanNameInputComponent } from './component/WlanNameInputComponent';
import { AddOtherWlanController } from './controller/new/AddOtherWlanController';

export const URL_ADD_OTHER_WLAN_SHEET_PAGE: string = 'Setting.Wlan.AddOtherWlanSheetPage';

@Builder
export function connectOtherWlanComponentBuilder(param: object): void {
  ConnectWlanComponent({
    item: param,
    configFlag: ADD_OTHER_WLAN_CONFIG
  });
}
@Builder
export function wlanNameInputBuilder(param: object): void {
  WlanNameInputComponent({
    item: param,
  });
}

function customPage(): SettingPageModel {
  return {
    id: 'add_other_wlan_config',
    url: URL_ADD_OTHER_WLAN_SHEET_PAGE,
    type: PageType.PAGE_TYPE_MODAL,
    layout: {
      backgroundColor: DeviceUtil.isDevicePc() ? $r('sys.color.background_secondary') :
      $r('app.color.component_ultra_thick_panel'),
      blurStyle: DeviceUtil.isDevicePc() ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.NONE,
      padding: {
        start: DeviceUtil.isDevicePc() ? PADDING_16 : undefined,
        end: DeviceUtil.isDevicePc() ? PADDING_16 : undefined,
        bottom: PADDING_88,
        top: PADDING_8,
      },
    },
    title: $r('app.string.wifi_add_wifi'),
    compControl: new AddOtherWlanController(),
    groupForeground: {
      id: 'ConnectOtherWlan',
      builder: wrapBuilder(connectOtherWlanComponentBuilder),
    },
    groups: [],
  }
}

ModalLoader.load(URL_ADD_OTHER_WLAN_SHEET_PAGE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingSheetBuilder),
});
