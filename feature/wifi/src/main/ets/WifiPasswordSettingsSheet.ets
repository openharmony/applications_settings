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
import { PADDING_0, PADDING_16, PADDING_88 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { settingSheetBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingSheet';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { WifiHiLinkComponent } from './component/WifiHiLinkComponent';
import { FooterComponent } from './component/FooterComponent';
import { WlanPasswordComponent } from './component/WlanPasswordComponent';
import { ConnectWlanComponent, WIFI_PASSWORD_CONFIG } from './component/ConnectWlanComponent';
import { EapInputComponent } from './component/EapInputComponent';
import { WifiPasswordConfigController } from './controller/new/WifiPasswordConfigController';

export const URL_WLAN_DETAIL_PAGE: string = 'Setting.Wlan.WifiPasswordSettings';

@Builder
export function wifiHiLinkBuilder(param: object): void {
  WifiHiLinkComponent({
    hiLinkModel: param,
  });
}

@Builder
export function footerBuilder(param: object): void {
  FooterComponent();
}

@Builder
export function wlanPasswordBuilder(param: object): void {
  WlanPasswordComponent({
    item: param as SettingGroupModel,
  });
}

@Builder
export function connectWlanComponentBuilder(param: object): void {
  ConnectWlanComponent({
    item: param,
    configFlag: WIFI_PASSWORD_CONFIG
  });
}

@Builder
export function eapInputComponentBuilder(param: object): void {
  EapInputComponent({
    item: param,
  });
}

function customPage(): SettingPageModel {
  return {
    id: 'wifi_password_config',
    url: URL_WLAN_DETAIL_PAGE,
    type: PageType.PAGE_TYPE_MODAL,
    layout: {
      backgroundColor: DeviceUtil.isDevicePc() ? $r('sys.color.background_secondary') :
      $r('app.color.component_ultra_thick_panel'),
      blurStyle: DeviceUtil.isDevicePc() ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.NONE,
      padding: {
        start: DeviceUtil.isDevicePc() ? PADDING_16 : undefined,
        end: DeviceUtil.isDevicePc() ? PADDING_16 : undefined,
        bottom: PADDING_88,
      },
    },
    title: '',
    compControl: new WifiPasswordConfigController(),
    groups: [],
  }
}

ModalLoader.load(URL_WLAN_DETAIL_PAGE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingSheetBuilder),
});
