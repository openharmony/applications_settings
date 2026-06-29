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
import { settingSheetBuilder } from'@ohos/settings.common/src/main/ets/framework/view/SettingSheet';
import { buildConfirmButton } from './HotSpot/view/HotspotLimitConfimComponent'
import { HotspotLimitSheetPageController } from './HotSpot/controller/HotspotLimitSheetPageController';

export const URL_HOTSPOT_LIMIT_SHEET_PAGE:string = 'Setting.MobileNetwork.Hostpot.MoreShare.HostspotLimit';

function customPage(): SettingPageModel {
  let sheetPageController: HotspotLimitSheetPageController = new HotspotLimitSheetPageController();
  return {
    id:'hostspot limit',
    url: URL_HOTSPOT_LIMIT_SHEET_PAGE,
    compControl: sheetPageController,
    type: PageType.PAGE_TYPE_MODAL,
    layout: {
      backgroundColor: $r('app.color.component_ultra_thick_panel')
    },
    title: $r('app.string.once_limit'),
    groups: sheetPageController.getPreseatGroup(),
    stickBottomContent: {
      id: 'confirm',
      builder: wrapBuilder(buildConfirmButton)
    }
  };
}

ModalLoader.load(URL_HOTSPOT_LIMIT_SHEET_PAGE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingSheetBuilder),
});