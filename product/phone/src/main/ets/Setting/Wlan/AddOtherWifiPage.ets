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

import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { AddOtherWifiPage } from '../../pages/wifi/AddOtherWifiPage';

@Builder function addOtherWifiBuilder(param: object): void {
  AddOtherWifiPage();
}

function customPage(): SettingPageModel {
  return {
    id: 'add_other_wifi',
    url: NavEntryKey.ADD_OTHER_WIFI_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: 'add_other_wifi',
  }
}

// 添加其他网络界面
PageLoader.load(NavEntryKey.ADD_OTHER_WIFI_ENTRY, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(addOtherWifiBuilder),
});