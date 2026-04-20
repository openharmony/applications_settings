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
import { ProxyPageController } from '@ohos/settings.network/src/main/ets/controller/ProxyPageController';

function pcProxySettingPage(): SettingPageModel {
  return {
    id: 'pc_proxy_settings_page',
    url: NavEntryKey.PC_NETWORK_PROXY_SETTINGS,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.network_proxy_title'),
    compControl: new ProxyPageController(),
    groups: []
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.PC_NETWORK_PROXY_SETTINGS, {
  configGenerator: pcProxySettingPage,
});