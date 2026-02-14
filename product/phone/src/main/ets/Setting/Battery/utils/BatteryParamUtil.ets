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

import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { AppPowerEntry } from '../controller/PowerConsumptionListController';

const PAD_SMART_POWER_SAVE_ENABLE = 'const.pad.pad_smart_power_save_enable';
const USE_PC_BATTERY_PAGE = 'const.settings.use_pc_battery_page';
const TAG = 'BatteryParamUtil';

export class BatteryParamUtil {
  private constructor() {
  }

  /*
   * 获取路由参数带过来的应用耗电信息(应用耗电详情页面使用)
   */
  public static getAppPowerEntryFromPathInfo(): AppPowerEntry {
    const pathInfoStack = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
    const intentParam = pathInfoStack?.getParamByIndex(pathInfoStack?.size() - 1) as PageParams;
    return (intentParam?.param as PushParam)?.config as AppPowerEntry;
  }

  public static ifUsePcBatteryPage(): boolean {
    try {
      const value = systemParameterEnhance.getSync(USE_PC_BATTERY_PAGE, 'false');
      LogUtil.showInfo(TAG, `ifUseNewPage: ${value}`);
      return value === 'true';
    } catch (err) {
      LogUtil.showError(TAG, `ifUsePcBatteryPage get value failed, code: ${err?.code}, msg: ${err?.message}`);
      return false;
    }
  }
}
