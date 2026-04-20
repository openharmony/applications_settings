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

import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { AppDetailController } from '@ohos/settings.application/src/main/ets/controller/AppDetailController';

function appDetailPage(): SettingPageModel {
  return {
    id: 'AppDetail',
    url: NavEntryKey.APPLICATION_INFO_ENTRY,
    type: PageType.PAGE_TYPE_DYNAMIC,
    title: '',
    compControl: new AppDetailController(),
    menus: []
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.APPLICATION_INFO_ENTRY, {
  configGenerator: appDetailPage,
});