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

import { SettingAppGroupModel } from '@ohos/settings.application/src/main/ets/model/SettingAppItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PowerDataFormatUtil } from '@ohos/settings.common/src/main/ets/utils/PowerDataFormatUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { appInfoItemBuilder } from './view/AppInfoItem';
import { appEndRunButtonBuilder } from './view/AppEndRunButton';
import { BatteryParamUtil } from './utils/BatteryParamUtil';

const TAG: string = 'PowerConsumptionPage:';

function getPageConfig(): SettingPageModel {
  LogUtil.info(`${TAG} getPageConfig start.`);
  // 获取页面跳转参数
  const appPowerEntry = BatteryParamUtil.getAppPowerEntryFromPathInfo();
  LogUtil.info(`${TAG} getPageConfig. app:${appPowerEntry.name}`);
  // 拼接显示字串
  const title: string = ResourceUtil.getAnyStrFormatStringSync($r('app.string.start_time_to_end_time'),
    PowerDataFormatUtil.getDateTimeByTimeMillis(appPowerEntry.startTimestamp),
    PowerDataFormatUtil.getDateTimeByTimeMillis(appPowerEntry.endTimestamp));
  const foregroundSummary: string = ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_and_power_consumption'),
    PowerDataFormatUtil.formatTimeMillis(appPowerEntry.foregroundTime),
    PowerDataFormatUtil.formatPowerConsumption(appPowerEntry.foregroundPower));
  const backgroundSummary: string = ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_and_power_consumption'),
    PowerDataFormatUtil.formatTimeMillis(appPowerEntry.backgroundTime),
    PowerDataFormatUtil.formatPowerConsumption(appPowerEntry.backgroundPower));
  LogUtil.info(`${TAG} getPageConfig end.`);
  return {
    id: 'AppPowerConsumptionDetails',
    url: NavEntryKey.POWER_CONSUMPTION_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.battery_usage_details'),
    groups: [
      {
        id: 'app_info_header',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(appInfoItemBuilder),
        icon: appPowerEntry.icon,
        versionName: appPowerEntry.version,
        label: appPowerEntry.appEntry?.label,
        name: appPowerEntry.title,
        entry: appPowerEntry.appEntry
      } as SettingAppGroupModel,
      // 耗电量信息
      {
        id: 'app_power_info_group',
        header: { id: 'app_power_info_header', content: title },
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'app_foreground_power_info',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.foreground_time_power') },
            desc: { content: foregroundSummary },
            layout: {
              accessibilityGroup: true,
            },
          },
          {
            id: 'app_background_power_info',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.background_time_power') },
            desc: { content: backgroundSummary },
            layout: {
              accessibilityGroup: true,
            },
          },
        ],
      },
    ],
    // 底部结束运行按钮
    stickBottomContent: {
      id: 'end_run_button',
      builder: wrapBuilder(appEndRunButtonBuilder),
    },
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.POWER_CONSUMPTION_ENTRY, {
  configGenerator: getPageConfig,
});