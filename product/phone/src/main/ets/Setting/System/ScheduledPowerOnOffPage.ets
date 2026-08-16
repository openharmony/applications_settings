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
import {
  ScheduledPowerOnOffPageController
} from '@ohos/settings.system/src/main/ets/controller/ScheduledPowerOnOffPageController';

function customPage(): SettingPageModel {
  return {
    id: 'scheduled_power_settings',
    url: NavEntryKey.SCHEDULED_POWER_ON_OFF,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.scheduled_power_on_off_title'),
    compControl: new ScheduledPowerOnOffPageController(),
    groups: []
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.SCHEDULED_POWER_ON_OFF, {
  configGenerator: customPage,
});