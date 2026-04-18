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

import dataShare from '@ohos.data.dataShare';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysDisplayBrightnessEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { STR_OFF, STR_ON } from '@ohos/settings.display/src/main/ets/constant/DisplayConstant';
/* instrument ignore file */
const TAG: string = 'ForcedLandscapeController';
const LANDSCAPE_ENABLE_KEY: string = 'LandscapeWindow_Enable';
const FORCED_LANDSCAPE_ENABLE: string = '1';

export class ForcedLandscapeController implements ComponentControl {
  private dataHelper: dataShare.DataShareHelper | null = null;
  public onLandscapeEnableChange = () => {
    LogUtil.info(`${TAG} onLandscapeEnableChange`);
    this.refreshLandscapeEnable();
  }

  init(compParam: CompCtrlParam): void {
    this.refreshLandscapeEnable();
    this.registerLandscapeEnableChange();
    LogUtil.info(`${TAG} on init`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unregisterLandscapeEnableChange();
  }

  private registerLandscapeEnableChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, LANDSCAPE_ENABLE_KEY, this.onLandscapeEnableChange);
    } else {
      (SettingsDataUtils.createDataHelper(LANDSCAPE_ENABLE_KEY) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerDataChange(this.dataHelper, LANDSCAPE_ENABLE_KEY, this.onLandscapeEnableChange);
          }
        })
    }
    LogUtil.info(`${TAG} registerLandscapeEnableChange`);
  }

  private unregisterLandscapeEnableChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.unRegisterDataChange(this.dataHelper, LANDSCAPE_ENABLE_KEY);
    } else {
      (SettingsDataUtils.createDataHelper(LANDSCAPE_ENABLE_KEY) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.unRegisterDataChange(this.dataHelper, LANDSCAPE_ENABLE_KEY);
          }
        })
    }
    LogUtil.info(`${TAG} unregisterLandscapeEnableChange`);
  }

  private refreshLandscapeEnable(): void {
    const forceLandscapeEnable = SettingsDataUtils.getSettingsData(LANDSCAPE_ENABLE_KEY, FORCED_LANDSCAPE_ENABLE);
    LogUtil.info(`${TAG} forcelandscape switch: ${forceLandscapeEnable}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.FORCED_LANDSCAPE_SWITCH,
      forceLandscapeEnable === FORCED_LANDSCAPE_ENABLE ? STR_ON : STR_OFF);
  }
}