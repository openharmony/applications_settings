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
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemResultType,
  ItemType, SettingItemModel, } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { PowerSaveTaskManager } from '@ohos/settings.powersave/src/main/ets/PowerSaveTaskManager';
import { BatteryPageController } from './controller/BatteryPageController';
import { BatteryQuantityController } from './controller/BatteryQuantityController';
import { ChargingGroupInvisibleController } from './controller/ChargingGroupInvisibleController';
import { SUPPORTED_TASK_KEYS } from './controller/PowerSaveCardController';
import { BatteryQuantityComponentForPad } from './view/BatteryQuantityComponentForPad';
import { BatteryQuantityComponentForPhone } from './view/BatteryQuantityComponentForPhone';
/* instrument ignore file */

@Builder
export function batteryQuantityBuilder(param: object): void {
  if (DeviceUtil.isDevicePad()) {
    BatteryQuantityComponentForPad({item: param as SettingGroupModel});
  } else {
    BatteryQuantityComponentForPhone({item: param as SettingGroupModel});
  }
}

function batteryPage(): SettingPageModel {
  PowerSaveTaskManager.getInstance().initSupportedTask(SUPPORTED_TASK_KEYS);
  return {
    id: 'Battery',
    url: NavEntryKey.BATTERY_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.power_usage_summary_title'),
    compControl: new BatteryPageController(),
    hdsNavDestinationUx: false,
    groups: [
      // 电池电量
      {
        id: 'battery_info_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(batteryQuantityBuilder),
        compControl: new BatteryQuantityController(),
      },
      // 显示电量百分比
      {
        id: 'charging_group',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        compControl: new ChargingGroupInvisibleController(),
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.BATTERY_ENTRY, {
  configGenerator: batteryPage,
});