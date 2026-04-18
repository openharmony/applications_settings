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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { MoreConnectController } from './controller/MoreConnectController';

function moreConnectionPage(): SettingPageModel {
  return {
    id: 'MoreConnection',
    url: NavEntryKey.MORE_CONNECTION_ENTRY,
    type: PageType.PAGE_TYPE_DYNAMIC,
    title: ResourceUtil.getStringSync($r('app.string.multi_device_collaboration')),
    compControl: new MoreConnectController(),
    hdsNavDestinationUx: false,
    groups: [],
  };
}

PageLoader.load(NavEntryKey.MORE_CONNECTION_ENTRY, {
  configGenerator: moreConnectionPage,
});
