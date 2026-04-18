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

import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { settingSheetBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingSheet';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { HotSpotPasswordComponent } from './view/HotSpotPasswordComponent';
import { HotSpotPswConfirmComponent } from './view/HotSpotPswConfirmComponent';

export const HOT_SPOT_PSW_SHEET_PAGE: string = 'Setting.Hotspot.Password_config';

@Builder
export function hotspotPasswordBuilder(param: object): void {
  HotSpotPasswordComponent({
    item: param,
  });
}

@Builder
export function confirmComponentBuilder(param: object): void {
  HotSpotPswConfirmComponent({
    item: param as SettingGroupModel,
  });
}

function customPage(): SettingPageModel {
  return {
    id: 'hotspot_psw_page',
    url: HOT_SPOT_PSW_SHEET_PAGE,
    type: PageType.PAGE_TYPE_MODAL,
    layout: {
      backgroundColor: $r('app.color.component_ultra_thick_panel'),
    },
    title: $r('app.string.hotspot_password'),
    groups: [
      {
        id: 'hotspot_psw_input',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(hotspotPasswordBuilder),
      }
    ],
    groupForeground: {
      id: 'hotspot_psw_confirm',
      builder: wrapBuilder(confirmComponentBuilder),
    }
  }
}

ModalLoader.load(HOT_SPOT_PSW_SHEET_PAGE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingSheetBuilder),
});
