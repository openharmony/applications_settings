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

/* instrument ignore file */
import dataShare from '@ohos.data.dataShare';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NotDisturbTimerManager } from '@ohos/settings.notDisturb/src/main/ets/NotDisturbTimerManager';
import { FOCUS_MODE_ENABLED } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';

const TAG: string = 'NotDisturbController';

/**
 * 声音免打扰菜单控制器
 */
export class NotDisturbController implements ComponentControl {
  private dataHelper: dataShare.DataShareHelper | null = null;
  public dataShareHelper?: Promise<dataShare.DataShareHelper> | dataShare.DataShareHelper;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    let isChecked: boolean = NotDisturbTimerManager.getInstance().isNotDisturbOpen(ContextUtils.getContext());
    this.refreshTextUi(isChecked);
    this.registerDataChange();
  }

  registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, FOCUS_MODE_ENABLED, this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(FOCUS_MODE_ENABLED) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerSecurityDataChange(this.dataHelper, FOCUS_MODE_ENABLED, this.onDataChange);
          }
        })
    }
    LogUtil.info(`${TAG} registerDataChange`);
  }

  private onDataChange = () => {
    LogUtil.info(`${TAG} onDataChange`);
    let isChecked: boolean = NotDisturbTimerManager.getInstance().isNotDisturbOpen(ContextUtils.getContext());
    this.refreshTextUi(isChecked);
  }

  unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper, FOCUS_MODE_ENABLED);
    LogUtil.info(`${TAG} unRegisterDataChange`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unRegisterDataChange();
  }

  refreshTextUi(isChecked: boolean) {
    LogUtil.info(`${TAG} on refreshUi, isChecked: ${isChecked}`);
  }
}